import React, { useEffect, useState } from 'react';
import { getReports, createReport, markReportAsSent, deleteReport } from '../../services/reportApi';
import type { Report, ReportType } from '../../services/reportApi';
import { getEmployees } from '../../services/employeeApi';
import type { Employee } from '../../services/employeeApi';
import {
  AreaChart,
  Area,
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Legend
} from 'recharts';
import { FileText, Send, Download, Plus, TrendingUp, Users, Loader, Trash2, X } from 'lucide-react';

const ReportsPage: React.FC = () => {
  const [reports, setReports] = useState<Report[]>([]);
  const [employees, setEmployees] = useState<Employee[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Tabs: 'kpi' | 'revenue' | 'employee'
  const [activeTab, setActiveTab] = useState<'kpi' | 'revenue' | 'employee'>('kpi');
  
  // Modal State
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  // New Report form
  const [newReport, setNewReport] = useState({
    report_type: 'Daily_Email' as ReportType,
    date: new Date().toISOString().slice(0, 10),
    recipients: 'admin@ecommercekpi.com, manager@ecommercekpi.com',
    total_revenue: 120000000,
    total_orders: 450,
    top_employee: '',
    new_blacklist_count: 2
  });

  const fetchReportsData = async () => {
    setLoading(true);
    setError(null);
    try {
      const [repList, empList] = await Promise.all([
        getReports(0, 500),
        getEmployees(0, 100)
      ]);
      // Sort reports by date descending
      setReports(repList.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime()));
      setEmployees(empList);
    } catch (err: any) {
      console.error(err);
      setError(err.response?.data?.detail || 'Không thể tải danh sách báo cáo.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchReportsData();
  }, []);

  const handleCreateSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setFormError(null);
    setSubmitting(true);

    const recipientList = newReport.recipients.split(',').map((r) => r.trim()).filter(Boolean);
    if (recipientList.length === 0) {
      setFormError('Vui lòng nhập ít nhất một email người nhận.');
      setSubmitting(false);
      return;
    }

    try {
      const created = await createReport({
        ...newReport,
        recipients: recipientList,
        summary_data: { note: 'Báo cáo khởi tạo thủ công từ quản trị viên.' }
      });
      setReports([created, ...reports]);
      setShowCreateModal(false);
    } catch (err: any) {
      console.error(err);
      setFormError(err.response?.data?.detail || 'Lỗi xảy ra khi tạo báo cáo.');
    } finally {
      setSubmitting(false);
    }
  };

  const handleSendReport = async (id: string) => {
    if (!window.confirm('Bạn muốn gửi báo cáo này đến danh sách email người nhận ngay lập tức?')) {
      return;
    }
    try {
      const updated = await markReportAsSent(id);
      setReports((prev) => prev.map((r) => (r.id === id ? updated : r)));
      alert('Đã gửi báo cáo thành công!');
    } catch (err: any) {
      console.error(err);
      alert(err.response?.data?.detail || 'Lỗi xảy ra khi gửi báo cáo.');
    }
  };

  const handleDeleteReport = async (id: string) => {
    if (!window.confirm('Bạn có chắc chắn muốn xóa vĩnh viễn báo cáo này?')) {
      return;
    }
    try {
      await deleteReport(id);
      setReports((prev) => prev.filter((r) => r.id !== id));
    } catch (err: any) {
      console.error(err);
      alert(err.response?.data?.detail || 'Không thể xóa báo cáo.');
    }
  };

  // Extract Chart Data (Chronological)
  const getChartData = () => {
    return [...reports]
      .reverse()
      .slice(-30) // last 30 reports
      .map((r) => ({
        date: new Date(r.date).toLocaleDateString('vi-VN', { month: '2-digit', day: '2-digit' }),
        'Doanh Thu': Number(r.total_revenue),
        'Đơn Hàng': r.total_orders,
        'Khách Blacklist Mới': r.new_blacklist_count
      }));
  };

  const chartData = getChartData();

  // Export Excel / CSV
  const handleExportCSV = () => {
    if (reports.length === 0) {
      alert('Không có dữ liệu báo cáo để xuất.');
      return;
    }

    const headers = ['Mã Báo Cáo', 'Loại Báo Cáo', 'Ngày Báo Cáo', 'Người Nhận', 'Doanh Thu (VND)', 'Đơn Hàng', 'Nhân Viên Xuất Sắc', 'Blacklist Mới', 'Trạng Thái Gửi'];
    const rows = reports.map((r) => [
      r.id,
      r.report_type,
      new Date(r.date).toLocaleDateString('vi-VN'),
      r.recipients.join('; '),
      Math.round(r.total_revenue),
      r.total_orders,
      r.top_employee || 'N/A',
      r.new_blacklist_count,
      r.sent_status
    ]);

    const csvContent =
      '\uFEFF' +
      [headers.join(','), ...rows.map((row) => row.map((val) => `"${val}"`).join(','))].join('\n');

    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.setAttribute('href', url);
    link.setAttribute('download', `kpi_bao_cao_tong_hop_${new Date().toISOString().slice(0, 10)}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  // Generate PDF via Browser Print
  const handleExportPDF = () => {
    window.print();
  };

  const formatCurrency = (val: number) => {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(val);
  };

  const formatShortCurrency = (val: number) => {
    if (val >= 1000000) return `${(val / 1000000).toFixed(0)}M`;
    if (val >= 1000) return `${(val / 1000).toFixed(0)}k`;
    return val.toString();
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      
      {/* Title block */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '12px' }}>
        <div>
          <h2 style={{ fontSize: '1.5rem', fontWeight: 700 }}>Hệ Thống Báo Cáo KPI & Doanh Số</h2>
          <p style={{ fontSize: '0.875rem', color: 'var(--text-secondary)' }}>
            Biên soạn báo cáo tự động, xuất bản báo cáo phân tích hiệu suất nhân viên và tổng hợp doanh thu đa kênh.
          </p>
        </div>
        <div style={{ display: 'flex', gap: '8px' }}>
          <button
            onClick={() => setShowCreateModal(true)}
            className="retry-btn"
            style={{ display: 'inline-flex', alignItems: 'center', gap: '6px' }}
          >
            <Plus size={14} /> Khởi Tạo Báo Cáo
          </button>
          <button
            onClick={handleExportCSV}
            className="retry-btn"
            style={{ display: 'inline-flex', alignItems: 'center', gap: '6px', backgroundColor: 'var(--bg-tertiary)', border: '1px solid var(--border-color)', color: 'var(--text-primary)' }}
          >
            <Download size={14} /> Xuất Excel
          </button>
          <button
            onClick={handleExportPDF}
            className="retry-btn"
            style={{ display: 'inline-flex', alignItems: 'center', gap: '6px', backgroundColor: 'var(--bg-tertiary)', border: '1px solid var(--border-color)', color: 'var(--text-primary)' }}
          >
            <FileText size={14} /> Xuất PDF (Print)
          </button>
        </div>
      </div>

      {/* Tabs list */}
      <div className="tabs-container" style={{ marginBottom: '0px' }}>
        <button
          className={`tab-btn ${activeTab === 'kpi' ? 'active' : ''}`}
          onClick={() => setActiveTab('kpi')}
        >
          Báo Cáo KPI Nhân Viên
        </button>
        <button
          className={`tab-btn ${activeTab === 'revenue' ? 'active' : ''}`}
          onClick={() => setActiveTab('revenue')}
        >
          Báo Cáo Tài Chính & Doanh Thu
        </button>
        <button
          className={`tab-btn ${activeTab === 'employee' ? 'active' : ''}`}
          onClick={() => setActiveTab('employee')}
        >
          Báo Cáo Hiệu Suất (Performance)
        </button>
      </div>

      {/* Error / Loading */}
      {loading && reports.length === 0 ? (
        <div className="loading-overlay" style={{ minHeight: '300px' }}>
          <div className="spinner"></div>
          <p className="text-secondary">Đang biên soạn dữ liệu báo cáo...</p>
        </div>
      ) : error ? (
        <div className="error-container">
          <div className="error-message">{error}</div>
          <button className="retry-btn" onClick={fetchReportsData}>Tải lại</button>
        </div>
      ) : reports.length === 0 ? (
        <div className="dashboard-card" style={{ textAlign: 'center', padding: '60px 16px' }}>
          <p style={{ color: 'var(--text-secondary)', fontWeight: 500 }}>Không có dữ liệu báo cáo nào</p>
          <button className="retry-btn" style={{ marginTop: '12px' }} onClick={() => setShowCreateModal(true)}>
            Bấm vào đây để tạo báo cáo đầu tiên
          </button>
        </div>
      ) : (
        <>
          {/* Visual Trends */}
          <div className="charts-grid" style={{ gridTemplateColumns: '1fr 1fr' }}>
            
            {/* Revenue Trend Area Chart */}
            <div className="dashboard-card">
              <div className="card-header">
                <span className="card-title" style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '1.05rem' }}>
                  <TrendingUp size={18} className="text-emerald-500" /> Xu Hướng Doanh Thu (Biên độ báo cáo)
                </span>
              </div>
              <div style={{ width: '100%', height: 240, marginTop: '16px' }}>
                <ResponsiveContainer width="100%" height="100%">
                  <AreaChart data={chartData}>
                    <defs>
                      <linearGradient id="reportRevenue" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="var(--success)" stopOpacity={0.2}/>
                        <stop offset="95%" stopColor="var(--success)" stopOpacity={0}/>
                      </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 3" stroke="var(--border-color)" />
                    <XAxis dataKey="date" stroke="var(--text-muted)" fontSize={10} />
                    <YAxis stroke="var(--text-muted)" fontSize={10} tickFormatter={formatShortCurrency} />
                    <Tooltip
                      contentStyle={{ backgroundColor: 'var(--bg-secondary)', borderColor: 'var(--border-color)' }}
                      formatter={(value: any) => [formatCurrency(value), 'Doanh Thu']}
                    />
                    <Area type="monotone" dataKey="Doanh Thu" stroke="var(--success)" fillOpacity={1} fill="url(#reportRevenue)" strokeWidth={2} />
                  </AreaChart>
                </ResponsiveContainer>
              </div>
            </div>

            {/* KPI Trend Chart */}
            <div className="dashboard-card">
              <div className="card-header">
                <span className="card-title" style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '1.05rem' }}>
                  <Users size={18} className="text-indigo-500" /> Xu Hướng Đơn Hàng & Thể Tích Đơn hàng
                </span>
              </div>
              <div style={{ width: '100%', height: 240, marginTop: '16px' }}>
                <ResponsiveContainer width="100%" height="100%">
                  <LineChart data={chartData}>
                    <CartesianGrid strokeDasharray="3 3" stroke="var(--border-color)" />
                    <XAxis dataKey="date" stroke="var(--text-muted)" fontSize={10} />
                    <YAxis stroke="var(--text-muted)" fontSize={10} />
                    <Tooltip contentStyle={{ backgroundColor: 'var(--bg-secondary)', borderColor: 'var(--border-color)' }} />
                    <Legend wrapperStyle={{ fontSize: '11px', paddingTop: '10px' }} />
                    <Line type="monotone" dataKey="Đơn Hàng" stroke="var(--primary)" strokeWidth={2.5} dot={{ r: 4 }} activeDot={{ r: 6 }} />
                    <Line type="monotone" dataKey="Khách Blacklist Mới" name="Mục Blacklist mới" stroke="var(--danger)" strokeDasharray="3 3" strokeWidth={2} />
                  </LineChart>
                </ResponsiveContainer>
              </div>
            </div>

          </div>

          {/* Grid Layout depending on Active Tab */}
          <div className="dashboard-card" style={{ padding: '0px', overflowX: 'auto' }}>
            <div style={{ padding: '20px', borderBottom: '1px solid var(--border-color)', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <h3 style={{ fontSize: '1.1rem', fontWeight: 600 }}>
                {activeTab === 'kpi'
                  ? 'KPI Performance Report (Bản ghi chi tiết)'
                  : activeTab === 'revenue'
                  ? 'Revenue & Financial Transactions List'
                  : 'Employee Performance Metrics Tracker'}
              </h3>
              <span style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>
                Đang hiển thị {reports.length} báo cáo tổng hợp
              </span>
            </div>

            <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left', fontSize: '0.875rem' }}>
              <thead>
                <tr style={{ borderBottom: '1px solid var(--border-color)', color: 'var(--text-secondary)', fontWeight: 600 }}>
                  <th style={{ padding: '16px 20px' }}>Ngày Ghi</th>
                  <th style={{ padding: '16px 20px' }}>Loại Báo Cáo</th>
                  <th style={{ padding: '16px 20px' }}>Danh sách Nhận</th>
                  
                  {activeTab === 'kpi' && (
                    <>
                      <th style={{ padding: '16px 20px' }}>NV Xuất Sắc Nhất</th>
                      <th style={{ padding: '16px 20px', textAlign: 'right' }}>Blacklist Mới</th>
                    </>
                  )}
                  {activeTab === 'revenue' && (
                    <>
                      <th style={{ padding: '16px 20px', textAlign: 'right' }}>Đơn Hàng</th>
                      <th style={{ padding: '16px 20px', textAlign: 'right' }}>Doanh Thu Tổng</th>
                    </>
                  )}
                  {activeTab === 'employee' && (
                    <>
                      <th style={{ padding: '16px 20px' }}>Đại Diện Xuất Sắc</th>
                      <th style={{ padding: '16px 20px', textAlign: 'right' }}>Tỉ Lệ Đạt KPI</th>
                    </>
                  )}

                  <th style={{ padding: '16px 20px', textAlign: 'center' }}>Trạng Thái Gửi</th>
                  <th style={{ padding: '16px 20px', textAlign: 'right' }}>Hành Động</th>
                </tr>
              </thead>
              <tbody>
                {reports.map((r) => {
                  return (
                    <tr key={r.id} style={{ borderBottom: '1px solid var(--border-color)' }} className="table-row-hover">
                      <td style={{ padding: '16px 20px', color: 'var(--text-secondary)' }}>
                        {new Date(r.date).toLocaleDateString('vi-VN', { year: 'numeric', month: '2-digit', day: '2-digit' })}
                      </td>
                      <td style={{ padding: '16px 20px', fontWeight: 600 }}>
                        <span style={{ display: 'inline-flex', alignItems: 'center', gap: '6px' }}>
                          <FileText size={14} className="text-primary" /> {r.report_type}
                        </span>
                      </td>
                      <td style={{ padding: '16px 20px', fontSize: '0.8rem', maxWidth: '240px', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                        {r.recipients.join(', ')}
                      </td>

                      {activeTab === 'kpi' && (
                        <>
                          <td style={{ padding: '16px 20px', fontWeight: 500 }}>
                            {r.top_employee || <span style={{ color: 'var(--text-muted)' }}>Chưa cập nhật</span>}
                          </td>
                          <td style={{ padding: '16px 20px', textAlign: 'right', color: 'var(--danger)', fontWeight: 600 }}>
                            +{r.new_blacklist_count} khách
                          </td>
                        </>
                      )}
                      {activeTab === 'revenue' && (
                        <>
                          <td style={{ padding: '16px 20px', textAlign: 'right', fontWeight: 500 }}>
                            {r.total_orders.toLocaleString('vi-VN')} đơn
                          </td>
                          <td style={{ padding: '16px 20px', textAlign: 'right', fontWeight: 700, color: 'var(--success)' }}>
                            {formatCurrency(Number(r.total_revenue))}
                          </td>
                        </>
                      )}
                      {activeTab === 'employee' && (
                        <>
                          <td style={{ padding: '16px 20px' }}>{r.top_employee || 'System'}</td>
                          <td style={{ padding: '16px 20px', textAlign: 'right', fontWeight: 600, color: 'var(--success)' }}>
                            100% (Đạt Mục Tiêu)
                          </td>
                        </>
                      )}

                      <td style={{ padding: '16px 20px', textAlign: 'center' }}>
                        <span
                          className={`badge ${
                            r.sent_status === 'Sent'
                              ? 'completed'
                              : r.sent_status === 'Pending'
                              ? 'pending'
                              : 'cancelled'
                          }`}
                          style={{ padding: '3px 8px', borderRadius: '4px', fontSize: '0.7rem' }}
                        >
                          {r.sent_status === 'Sent' ? 'Đã gửi' : r.sent_status === 'Pending' ? 'Đang Chờ' : 'Lỗi'}
                        </span>
                      </td>

                      <td style={{ padding: '16px 20px', textAlign: 'right' }}>
                        <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px' }}>
                          <button
                            title="Gửi báo cáo ngay"
                            style={{
                              background: 'none',
                              border: 'none',
                              color: r.sent_status === 'Sent' ? 'var(--text-muted)' : 'var(--success)',
                              cursor: r.sent_status === 'Sent' ? 'not-allowed' : 'pointer',
                              padding: '4px',
                              opacity: r.sent_status === 'Sent' ? 0.3 : 1
                            }}
                            onClick={() => handleSendReport(r.id)}
                            disabled={r.sent_status === 'Sent'}
                          >
                            <Send size={15} />
                          </button>
                          <button
                            title="Xóa báo cáo"
                            style={{ background: 'none', border: 'none', color: 'var(--danger)', cursor: 'pointer', padding: '4px' }}
                            onClick={() => handleDeleteReport(r.id)}
                          >
                            <Trash2 size={15} />
                          </button>
                        </div>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </>
      )}

      {/* CREATE MODAL */}
      {showCreateModal && (
        <div className="modal-backdrop" style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, backgroundColor: 'rgba(0,0,0,0.6)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000 }}>
          <div className="dashboard-card" style={{ width: '100%', maxWidth: '500px', padding: '24px', backgroundColor: 'var(--bg-secondary)', animation: 'fadeIn 0.3s ease-out', position: 'relative' }}>
            <button
              onClick={() => setShowCreateModal(false)}
              style={{ position: 'absolute', top: '16px', right: '16px', background: 'none', border: 'none', color: 'var(--text-secondary)', cursor: 'pointer' }}
            >
              <X size={20} />
            </button>
            <h3 style={{ fontSize: '1.25rem', fontWeight: 700, marginBottom: '16px' }}>Khởi Tạo Báo Cáo Định Kỳ</h3>

            {formError && (
              <div style={{ color: 'var(--danger)', fontSize: '0.8rem', backgroundColor: 'var(--danger-light)', padding: '10px', borderRadius: '4px', marginBottom: '16px', border: '1px solid rgba(239, 68, 68, 0.2)' }}>
                {formError}
              </div>
            )}

            <form onSubmit={handleCreateSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
              <div className="form-group">
                <label>Loại báo cáo *</label>
                <select
                  className="form-input"
                  value={newReport.report_type}
                  onChange={(e) => setNewReport({ ...newReport, report_type: e.target.value as ReportType })}
                >
                  <option value="Daily_Email">Daily_Email (Báo cáo ngày)</option>
                  <option value="Monthly_Summary">Monthly_Summary (Báo cáo tháng)</option>
                </select>
              </div>

              <div className="form-group">
                <label>Ngày lập báo cáo *</label>
                <input
                  type="date"
                  className="form-input"
                  required
                  value={newReport.date}
                  onChange={(e) => setNewReport({ ...newReport, date: e.target.value })}
                />
              </div>

              <div className="form-group">
                <label>Danh sách email nhận (ngăn cách bởi dấu phẩy) *</label>
                <input
                  type="text"
                  className="form-input"
                  required
                  placeholder="admin@ecommercekpi.com, manager@ecommercekpi.com"
                  value={newReport.recipients}
                  onChange={(e) => setNewReport({ ...newReport, recipients: e.target.value })}
                />
              </div>

              <div style={{ display: 'flex', gap: '12px' }}>
                <div className="form-group" style={{ flex: 1 }}>
                  <label>Doanh thu tổng hợp</label>
                  <input
                    type="number"
                    className="form-input"
                    value={newReport.total_revenue}
                    onChange={(e) => setNewReport({ ...newReport, total_revenue: parseFloat(e.target.value) || 0 })}
                  />
                </div>
                <div className="form-group" style={{ flex: 1 }}>
                  <label>Số lượng đơn hàng</label>
                  <input
                    type="number"
                    className="form-input"
                    value={newReport.total_orders}
                    onChange={(e) => setNewReport({ ...newReport, total_orders: parseInt(e.target.value) || 0 })}
                  />
                </div>
              </div>

              <div style={{ display: 'flex', gap: '12px' }}>
                <div className="form-group" style={{ flex: 1 }}>
                  <label>Nhân viên xuất sắc</label>
                  <select
                    className="form-input"
                    value={newReport.top_employee}
                    onChange={(e) => setNewReport({ ...newReport, top_employee: e.target.value })}
                  >
                    <option value="">Không phân bổ</option>
                    {employees.map((emp) => (
                      <option key={emp.id} value={emp.full_name}>
                        {emp.full_name}
                      </option>
                    ))}
                  </select>
                </div>
                <div className="form-group" style={{ flex: 1 }}>
                  <label>Blacklist mới</label>
                  <input
                    type="number"
                    className="form-input"
                    value={newReport.new_blacklist_count}
                    onChange={(e) => setNewReport({ ...newReport, new_blacklist_count: parseInt(e.target.value) || 0 })}
                  />
                </div>
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px', marginTop: '16px' }}>
                <button
                  type="button"
                  className="retry-btn"
                  style={{ backgroundColor: 'transparent', border: '1px solid var(--border-color)', color: 'var(--text-primary)' }}
                  onClick={() => setShowCreateModal(false)}
                >
                  Hủy
                </button>
                <button
                  type="submit"
                  className="retry-btn"
                  disabled={submitting}
                  style={{ display: 'flex', alignItems: 'center', gap: '8px' }}
                >
                  {submitting && <Loader size={14} className="animate-spin" />}
                  Khởi Tạo
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

    </div>
  );
};

export default ReportsPage;
