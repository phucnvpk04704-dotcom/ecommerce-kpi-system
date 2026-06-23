import React, { useEffect, useState } from 'react';
import { getRevenues } from '../../services/revenueApi';
import type { Revenue } from '../../services/revenueApi';
import { getEmployees } from '../../services/employeeApi';
import type { Employee } from '../../services/employeeApi';
import {
  BarChart,
  Bar,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Legend,
  AreaChart,
  Area
} from 'recharts';
import { Download, RefreshCw, BarChart3, TrendingUp, DollarSign, Percent, Layers } from 'lucide-react';

const RevenuesPage: React.FC = () => {
  const [revenues, setRevenues] = useState<Revenue[]>([]);
  const [employees, setEmployees] = useState<Employee[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Filters
  const [selectedEmployeeId, setSelectedEmployeeId] = useState<string>('All');
  const [startDate, setStartDate] = useState<string>('');
  const [endDate, setEndDate] = useState<string>('');
  const [selectedPeriod, setSelectedPeriod] = useState<string>('All');

  const fetchRevenueData = async () => {
    setLoading(true);
    setError(null);
    try {
      const [revData, empData] = await Promise.all([
        getRevenues(0, 1000),
        getEmployees(0, 1000)
      ]);
      setRevenues(revData);
      setEmployees(empData);
    } catch (err: any) {
      console.error(err);
      setError(err.response?.data?.detail || 'Không thể tải dữ liệu doanh số.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchRevenueData();
  }, []);

  // Filter logic
  const filteredRevenues = revenues.filter((rev) => {
    const matchEmp = selectedEmployeeId === 'All' || rev.employee_id === selectedEmployeeId;
    const matchPeriod = selectedPeriod === 'All' || rev.period === selectedPeriod;
    
    // Date range check
    let matchDate = true;
    if (startDate) {
      matchDate = matchDate && new Date(rev.date) >= new Date(startDate);
    }
    if (endDate) {
      // Set end date to end of day
      const endLimit = new Date(endDate);
      endLimit.setHours(23, 59, 59, 999);
      matchDate = matchDate && new Date(rev.date) <= endLimit;
    }

    return matchEmp && matchPeriod && matchDate;
  });

  // Calculate statistics
  const totalRevenue = filteredRevenues.reduce((sum, item) => sum + Number(item.total_revenue), 0);
  const totalTarget = filteredRevenues.reduce((sum, item) => sum + Number(item.target_revenue), 0);
  const targetCompletion = totalTarget > 0 ? (totalRevenue / totalTarget) * 100 : 0;

  const totalOrders = filteredRevenues.reduce((sum, item) => sum + item.total_orders, 0);

  // Group data by Month for charts
  const getMonthlyChartData = () => {
    const monthsMap: Record<string, { month: string; revenue: number; target: number; growth: number }> = {};
    
    // Sort revenues chronologically first
    const sorted = [...filteredRevenues].sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
    
    sorted.forEach((item) => {
      const d = new Date(item.date);
      const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`; // YYYY-MM
      const label = d.toLocaleDateString('vi-VN', { month: 'short', year: 'numeric' });
      
      if (!monthsMap[key]) {
        monthsMap[key] = { month: label, revenue: 0, target: 0, growth: 0 };
      }
      monthsMap[key].revenue += Number(item.total_revenue);
      monthsMap[key].target += Number(item.target_revenue);
    });

    return Object.values(monthsMap);
  };

  // Group data chronologically for growth trend
  const getGrowthChartData = () => {
    const sorted = [...filteredRevenues].sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
    let runningRevenue = 0;
    let runningTarget = 0;
    
    // Limit to last 30 data points if daily to avoid overcrowded chart
    const step = Math.max(1, Math.floor(sorted.length / 30));
    const processed = [];
    
    for (let i = 0; i < sorted.length; i++) {
      runningRevenue += Number(sorted[i].total_revenue);
      runningTarget += Number(sorted[i].target_revenue);
      
      if (i % step === 0 || i === sorted.length - 1) {
        processed.push({
          date: new Date(sorted[i].date).toLocaleDateString('vi-VN', { month: '2-digit', day: '2-digit' }),
          'Doanh Thu Lũy Kế': Math.round(runningRevenue),
          'Mục Tiêu Lũy Kế': Math.round(runningTarget),
          'Tỉ Lệ Đạt (%)': runningTarget > 0 ? Math.round((runningRevenue / runningTarget) * 100) : 0
        });
      }
    }
    return processed;
  };

  const monthlyChartData = getMonthlyChartData();
  const growthChartData = getGrowthChartData();

  // Export CSV
  const handleExportCSV = () => {
    if (filteredRevenues.length === 0) {
      alert('Không có dữ liệu để xuất file.');
      return;
    }

    const headers = [
      'ID',
      'Mã Nhân Viên',
      'Họ Tên Nhân Viên',
      'Kênh Bán Hàng',
      'Ngày Ghi Nhận',
      'Định Kỳ',
      'Tổng Đơn',
      'Đơn Thành Công',
      'Đơn Trả Lại',
      'Đơn Hủy',
      'Doanh Thu Thực Tế (VND)',
      'Doanh Thu Chỉ Tiêu (VND)',
      'Tỉ Lệ Đạt (%)'
    ];

    const rows = filteredRevenues.map((rev) => {
      const emp = employees.find((e) => e.id === rev.employee_id);
      const completion = Number(rev.target_revenue) > 0 
        ? ((Number(rev.total_revenue) / Number(rev.target_revenue)) * 100).toFixed(1)
        : '0';

      return [
        rev.id,
        emp?.employee_code || 'N/A',
        emp?.full_name || 'N/A',
        rev.platform,
        new Date(rev.date).toLocaleDateString('vi-VN'),
        rev.period,
        rev.total_orders,
        rev.successful_orders,
        rev.returned_orders,
        rev.cancelled_orders,
        Math.round(Number(rev.total_revenue)),
        Math.round(Number(rev.target_revenue)),
        completion
      ];
    });

    const csvContent =
      '\uFEFF' + // UTF-8 BOM for Excel Vietnamese characters compatibility
      [headers.join(','), ...rows.map((row) => row.map((val) => `"${val}"`).join(','))].join('\n');

    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.setAttribute('href', url);
    link.setAttribute('download', `bao_cao_doanh_so_${new Date().toISOString().slice(0, 10)}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const formatCurrency = (val: number) => {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(val);
  };

  const formatShortCurrency = (val: number) => {
    if (val >= 1000000000) return `${(val / 1000000000).toFixed(2)} B`;
    if (val >= 1000000) return `${(val / 1000000).toFixed(1)} M`;
    if (val >= 1000) return `${(val / 1000).toFixed(0)} k`;
    return val.toString();
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      
      {/* Title & Top buttons */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '12px' }}>
        <div>
          <h2 style={{ fontSize: '1.5rem', fontWeight: 700 }}>Báo Cáo Doanh Số & Kênh Bán Hàng</h2>
          <p style={{ fontSize: '0.875rem', color: 'var(--text-secondary)' }}>
            Theo dõi chỉ tiêu doanh thu thực tế, tỉ lệ hoàn thành kpi theo chu kỳ và kênh thương mại điện tử.
          </p>
        </div>
        <div style={{ display: 'flex', gap: '8px' }}>
          <button
            onClick={fetchRevenueData}
            className="retry-btn"
            style={{ display: 'inline-flex', alignItems: 'center', gap: '6px', backgroundColor: 'var(--bg-tertiary)', border: '1px solid var(--border-color)', color: 'var(--text-primary)' }}
          >
            <RefreshCw size={14} className={loading ? 'animate-spin' : ''} /> Làm Mới
          </button>
          <button
            onClick={handleExportCSV}
            className="retry-btn"
            style={{ display: 'inline-flex', alignItems: 'center', gap: '6px' }}
          >
            <Download size={14} /> Xuất Báo Cáo
          </button>
        </div>
      </div>

      {/* Filters Area */}
      <div className="dashboard-card" style={{ padding: '16px', display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', gap: '16px' }}>
        
        <div className="form-group">
          <label style={{ fontSize: '0.75rem', fontWeight: 600, color: 'var(--text-secondary)' }}>Nhân viên</label>
          <select
            className="form-input"
            value={selectedEmployeeId}
            onChange={(e) => setSelectedEmployeeId(e.target.value)}
          >
            <option value="All">Tất cả nhân viên</option>
            {employees.map((emp) => (
              <option key={emp.id} value={emp.id}>
                {emp.full_name} ({emp.employee_code})
              </option>
            ))}
          </select>
        </div>

        <div className="form-group">
          <label style={{ fontSize: '0.75rem', fontWeight: 600, color: 'var(--text-secondary)' }}>Chu kỳ báo cáo</label>
          <select
            className="form-input"
            value={selectedPeriod}
            onChange={(e) => setSelectedPeriod(e.target.value)}
          >
            <option value="All">Tất cả định kỳ</option>
            <option value="DAILY">Hàng Ngày (Daily)</option>
            <option value="MONTHLY">Hàng Tháng (Monthly)</option>
          </select>
        </div>

        <div className="form-group">
          <label style={{ fontSize: '0.75rem', fontWeight: 600, color: 'var(--text-secondary)' }}>Từ Ngày</label>
          <input
            type="date"
            className="form-input"
            value={startDate}
            onChange={(e) => setStartDate(e.target.value)}
          />
        </div>

        <div className="form-group">
          <label style={{ fontSize: '0.75rem', fontWeight: 600, color: 'var(--text-secondary)' }}>Đến Ngày</label>
          <input
            type="date"
            className="form-input"
            value={endDate}
            onChange={(e) => setEndDate(e.target.value)}
          />
        </div>

      </div>

      {/* Loading Overlay */}
      {loading && revenues.length === 0 ? (
        <div className="loading-overlay" style={{ minHeight: '300px' }}>
          <div className="spinner"></div>
          <p className="text-secondary">Đang phân tích chỉ số doanh thu...</p>
        </div>
      ) : error ? (
        <div className="error-container" style={{ padding: '24px' }}>
          <div className="error-title">Lỗi tải dữ liệu doanh thu</div>
          <p className="error-message">{error}</p>
          <button className="retry-btn" onClick={fetchRevenueData}>Thử lại</button>
        </div>
      ) : filteredRevenues.length === 0 ? (
        <div className="dashboard-card" style={{ textAlign: 'center', padding: '60px 16px' }}>
          <p style={{ color: 'var(--text-secondary)', fontWeight: 500 }}>Không tìm thấy dữ liệu doanh số tương thích</p>
          <p style={{ color: 'var(--text-muted)', fontSize: '0.85rem', marginTop: '6px' }}>
            Vui lòng thay đổi khoảng thời gian lọc hoặc tiêu chí lọc nhân viên.
          </p>
        </div>
      ) : (
        <>
          {/* Stats Summary Cards */}
          <div className="summary-grid">
            
            <div className="dashboard-card summary-card">
              <div className="summary-icon" style={{ backgroundColor: 'var(--success-light)' }}>
                <DollarSign size={20} className="text-emerald-500" />
              </div>
              <div className="summary-info">
                <p>Tổng Doanh Thu</p>
                <h3>{formatCurrency(totalRevenue)}</h3>
              </div>
            </div>

            <div className="dashboard-card summary-card">
              <div className="summary-icon" style={{ backgroundColor: 'var(--primary-light)' }}>
                <Layers size={20} className="text-indigo-500" />
              </div>
              <div className="summary-info">
                <p>Mục Tiêu Doanh Số</p>
                <h3>{formatCurrency(totalTarget)}</h3>
              </div>
            </div>

            <div className="dashboard-card summary-card">
              <div className="summary-icon" style={{ backgroundColor: 'var(--warning-light)' }}>
                <Percent size={20} className="text-amber-500" />
              </div>
              <div className="summary-info">
                <p>Tỉ Lệ Hoàn Thành KPI</p>
                <h3>{targetCompletion.toFixed(1)}%</h3>
              </div>
            </div>

            <div className="dashboard-card summary-card">
              <div className="summary-icon" style={{ backgroundColor: 'var(--info-light)' }}>
                <BarChart3 size={20} className="text-cyan-500" />
              </div>
              <div className="summary-info">
                <p>Tổng Đơn Hàng</p>
                <h3>{totalOrders.toLocaleString('vi-VN')}</h3>
              </div>
            </div>

          </div>

          {/* Charts Area */}
          <div className="charts-grid" style={{ gridTemplateColumns: '1fr 1fr' }}>
            
            {/* Revenue By Month Bar Chart */}
            <div className="dashboard-card">
              <div className="card-header">
                <span className="card-title" style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '1.05rem' }}>
                  <BarChart3 size={18} className="text-indigo-500" /> Doanh Thu và Chỉ Tiêu theo Tháng
                </span>
              </div>
              <div style={{ width: '100%', height: 300, marginTop: '16px' }}>
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={monthlyChartData}>
                    <CartesianGrid strokeDasharray="3 3" stroke="var(--border-color)" />
                    <XAxis dataKey="month" stroke="var(--text-muted)" fontSize={11} />
                    <YAxis stroke="var(--text-muted)" fontSize={11} tickFormatter={formatShortCurrency} />
                    <Tooltip
                      contentStyle={{ backgroundColor: 'var(--bg-secondary)', borderColor: 'var(--border-color)', color: 'var(--text-primary)' }}
                      formatter={(value: any) => [formatCurrency(value), '']}
                    />
                    <Legend wrapperStyle={{ fontSize: '11px', paddingTop: '10px' }} />
                    <Bar dataKey="revenue" name="Thực Tế" fill="var(--success)" radius={[4, 4, 0, 0]} />
                    <Bar dataKey="target" name="Chỉ Tiêu" fill="var(--primary)" radius={[4, 4, 0, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </div>

            {/* Growth Rate / Cumulative Line Chart */}
            <div className="dashboard-card">
              <div className="card-header">
                <span className="card-title" style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '1.05rem' }}>
                  <TrendingUp size={18} className="text-emerald-500" /> Biểu Đồ Tăng Trưởng Doanh Thu Lũy Kế
                </span>
              </div>
              <div style={{ width: '100%', height: 300, marginTop: '16px' }}>
                <ResponsiveContainer width="100%" height="100%">
                  <AreaChart data={growthChartData}>
                    <defs>
                      <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="var(--success)" stopOpacity={0.2}/>
                        <stop offset="95%" stopColor="var(--success)" stopOpacity={0}/>
                      </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 3" stroke="var(--border-color)" />
                    <XAxis dataKey="date" stroke="var(--text-muted)" fontSize={10} />
                    <YAxis stroke="var(--text-muted)" fontSize={11} tickFormatter={formatShortCurrency} />
                    <Tooltip
                      contentStyle={{ backgroundColor: 'var(--bg-secondary)', borderColor: 'var(--border-color)' }}
                      formatter={(value: any, name: any) => [name === 'Tỉ Lệ Đạt (%)' ? `${value}%` : formatCurrency(value), name]}
                    />
                    <Legend wrapperStyle={{ fontSize: '11px', paddingTop: '10px' }} />
                    <Area type="monotone" dataKey="Doanh Thu Lũy Kế" stroke="var(--success)" fillOpacity={1} fill="url(#colorRevenue)" strokeWidth={2} />
                    <Line type="monotone" dataKey="Mục Tiêu Lũy Kế" stroke="var(--primary)" strokeDasharray="5 5" dot={false} strokeWidth={2} />
                  </AreaChart>
                </ResponsiveContainer>
              </div>
            </div>

          </div>

          {/* Details Table */}
          <div className="dashboard-card" style={{ padding: '0px', overflowX: 'auto' }}>
            <div style={{ padding: '20px', borderBottom: '1px solid var(--border-color)', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <h3 style={{ fontSize: '1.1rem', fontWeight: 600 }}>Chi Tiết Giao Dịch Báo Cáo</h3>
              <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>
                Đang hiển thị {filteredRevenues.length} bản ghi
              </span>
            </div>
            
            <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left', fontSize: '0.875rem' }}>
              <thead>
                <tr style={{ borderBottom: '1px solid var(--border-color)', color: 'var(--text-secondary)', fontWeight: 600 }}>
                  <th style={{ padding: '14px 20px' }}>Ngày</th>
                  <th style={{ padding: '14px 20px' }}>Nhân Viên</th>
                  <th style={{ padding: '14px 20px' }}>Kênh Phân Phối</th>
                  <th style={{ padding: '14px 20px' }}>Chu Kỳ</th>
                  <th style={{ padding: '14px 20px', textAlign: 'right' }}>Tổng Đơn</th>
                  <th style={{ padding: '14px 20px', textAlign: 'right' }}>Hủy / Trả</th>
                  <th style={{ padding: '14px 20px', textAlign: 'right' }}>Doanh Thu</th>
                  <th style={{ padding: '14px 20px', textAlign: 'right' }}>Chỉ Tiêu</th>
                  <th style={{ padding: '14px 20px', textAlign: 'right' }}>KPI Hoàn Thành</th>
                </tr>
              </thead>
              <tbody>
                {filteredRevenues.slice(0, 15).map((rev) => {
                  const emp = employees.find((e) => e.id === rev.employee_id);
                  const completionRate = Number(rev.target_revenue) > 0
                    ? (Number(rev.total_revenue) / Number(rev.target_revenue)) * 100
                    : 0;

                  return (
                    <tr key={rev.id} style={{ borderBottom: '1px solid var(--border-color)' }} className="table-row-hover">
                      <td style={{ padding: '14px 20px', color: 'var(--text-secondary)' }}>
                        {new Date(rev.date).toLocaleDateString('vi-VN')}
                      </td>
                      <td style={{ padding: '14px 20px' }}>
                        <div style={{ fontWeight: 600 }}>{emp?.full_name || 'Hệ thống'}</div>
                        <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>{emp?.employee_code || 'SYS'}</div>
                      </td>
                      <td style={{ padding: '14px 20px' }}>
                        <span style={{ backgroundColor: 'rgba(255,255,255,0.03)', border: '1px solid var(--border-color)', padding: '2px 8px', borderRadius: '4px', fontSize: '0.75rem', fontWeight: 500 }}>
                          {rev.platform}
                        </span>
                      </td>
                      <td style={{ padding: '14px 20px' }}>
                        <span style={{ fontSize: '0.75rem', fontWeight: 600 }}>{rev.period}</span>
                      </td>
                      <td style={{ padding: '14px 20px', textAlign: 'right', fontWeight: 500 }}>
                        {rev.total_orders} <span style={{ color: 'var(--text-muted)', fontSize: '0.75rem' }}>đơn</span>
                      </td>
                      <td style={{ padding: '14px 20px', textAlign: 'right', color: 'var(--danger)' }}>
                        {rev.cancelled_orders} <span style={{ color: 'var(--text-muted)' }}>/</span> {rev.returned_orders}
                      </td>
                      <td style={{ padding: '14px 20px', textAlign: 'right', fontWeight: 600, color: 'var(--success)' }}>
                        {formatCurrency(Number(rev.total_revenue))}
                      </td>
                      <td style={{ padding: '14px 20px', textAlign: 'right', color: 'var(--text-muted)' }}>
                        {formatCurrency(Number(rev.target_revenue))}
                      </td>
                      <td style={{ padding: '14px 20px', textAlign: 'right' }}>
                        <span
                          style={{
                            fontWeight: 700,
                            color: completionRate >= 100 ? 'var(--success)' : completionRate >= 70 ? 'var(--warning)' : 'var(--danger)'
                          }}
                        >
                          {completionRate.toFixed(0)}%
                        </span>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
            
            {filteredRevenues.length > 15 && (
              <div style={{ padding: '16px', textAlign: 'center', fontSize: '0.8rem', color: 'var(--text-muted)', borderTop: '1px solid var(--border-color)' }}>
                Để xem thêm dữ liệu và bộ lọc đầy đủ, hãy bấm nút <strong>Xuất Báo Cáo</strong> ở góc trên bên phải để nhận file Excel CSV hoàn chỉnh.
              </div>
            )}
          </div>
        </>
      )}

    </div>
  );
};

export default RevenuesPage;
