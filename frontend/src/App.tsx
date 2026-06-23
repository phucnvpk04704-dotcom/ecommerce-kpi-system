import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate, useNavigate } from 'react-router-dom';
import Sidebar from './components/Sidebar';
import Header from './components/Header';
import DashboardSummary from './components/DashboardSummary';
import DashboardKPIs from './components/DashboardKPIs';
import RevenueChart from './components/RevenueChart';
import OrdersChart from './components/OrdersChart';
import RecentActivities from './components/RecentActivities';

// Import new page modules
import EmployeesPage from './pages/employees/EmployeesPage';
import RevenuesPage from './pages/revenues/RevenuesPage';
import BlacklistPage from './pages/blacklist/BlacklistPage';
import ReportsPage from './pages/reports/ReportsPage';
import SettingsPage from './pages/settings/SettingsPage';

import {
  login as loginApi,
  getSummary,
  getKPI,
  getRevenueChart,
  getOrdersChart,
  getRecentActivities
} from './api/dashboard';

import { Calendar, RefreshCw, Download, FileText } from 'lucide-react';

// ==========================================
// 1. LOGIN PAGE COMPONENT
// ==========================================
const LoginPage: React.FC<{ onLoginSuccess: (user: string) => void }> = ({ onLoginSuccess }) => {
  const [username, setUsername] = useState('admin');
  const [password, setPassword] = useState('admin123456');
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleLoginSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);

    try {
      await loginApi(username, password);
      localStorage.setItem('logged_username', username);
      onLoginSuccess(username);
      navigate('/');
    } catch (err: any) {
      console.error(err);
      setError(
        err.response?.data?.detail || 
        'Đăng nhập thất bại. Vui lòng kiểm tra tài khoản, mật khẩu hoặc kết nối mạng.'
      );
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="login-container">
      <form className="login-box" onSubmit={handleLoginSubmit}>
        <div className="login-header">
          <h2>Đăng nhập Hệ thống</h2>
          <p>Ecommerce KPI Management Dashboard</p>
        </div>

        {error && (
          <div style={{ color: 'var(--danger)', fontSize: '0.85rem', backgroundColor: 'var(--danger-light)', padding: '10px 14px', borderRadius: 'var(--radius-sm)', border: '1px solid rgba(239, 68, 68, 0.2)' }}>
            {error}
          </div>
        )}

        <div className="form-group">
          <label>Tài khoản</label>
          <input
            type="text"
            className="form-input"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
            disabled={loading}
            required
          />
        </div>

        <div className="form-group">
          <label>Mật khẩu</label>
          <input
            type="password"
            className="form-input"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            disabled={loading}
            required
          />
        </div>

        <button type="submit" className="login-btn" disabled={loading}>
          {loading ? 'Đang xác thực...' : 'Đăng Nhập'}
        </button>
      </form>
    </div>
  );
};

// ==========================================
// 2. DASHBOARD PAGE COMPONENT (ENHANCED)
// ==========================================
const DashboardPage: React.FC = () => {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  
  // Dashboard data states
  const [summary, setSummary] = useState<any>(null);
  const [kpi, setKpi] = useState<any>(null);
  const [revenueChart, setRevenueChart] = useState<any>(null);
  const [ordersChart, setOrdersChart] = useState<any>(null);
  const [activities, setActivities] = useState<any>(null);

  // Filters and Control States
  const [dateRange, setDateRange] = useState<string>('Last 30 Days');
  const [customStart, setCustomStart] = useState<string>('');
  const [customEnd, setCustomEnd] = useState<string>('');
  const [lastRefreshed, setLastRefreshed] = useState<Date>(new Date());
  const [isRefreshing, setIsRefreshing] = useState<boolean>(false);

  const fetchDashboardData = async (silent = false) => {
    if (!silent) setLoading(true);
    else setIsRefreshing(true);
    
    setError(null);
    try {
      const [sumRes, kpiRes, revChartRes, ordChartRes, actRes] = await Promise.all([
        getSummary(),
        getKPI(),
        getRevenueChart(),
        getOrdersChart(),
        getRecentActivities()
      ]);

      setSummary(sumRes);
      setKpi(kpiRes);
      setRevenueChart(revChartRes);
      setOrdersChart(ordChartRes);
      setActivities(actRes);
      setLastRefreshed(new Date());
    } catch (err: any) {
      console.error(err);
      setError(
        err.response?.data?.detail || 
        'Không thể kết nối tới server. Vui lòng đảm bảo Backend API đang hoạt động tại port 8000.'
      );
    } finally {
      setLoading(false);
      setIsRefreshing(false);
    }
  };

  useEffect(() => {
    fetchDashboardData();
  }, []);

  // Auto Refresh Hook (every 30 seconds)
  useEffect(() => {
    const timer = setInterval(() => {
      fetchDashboardData(true);
    }, 30000);

    return () => clearInterval(timer);
  }, []);

  // Filter Data based on Date Range
  const filterChartData = (data: any[], dateField = 'date') => {
    if (!data) return [];
    const now = new Date();
    let startDateLimit: Date | null = null;

    if (dateRange === 'Today') {
      startDateLimit = new Date();
      startDateLimit.setHours(0, 0, 0, 0);
    } else if (dateRange === 'Yesterday') {
      startDateLimit = new Date();
      startDateLimit.setDate(now.getDate() - 1);
      startDateLimit.setHours(0, 0, 0, 0);
      const endLimit = new Date();
      endLimit.setDate(now.getDate() - 1);
      endLimit.setHours(23, 59, 59, 999);
      return data.filter((item) => {
        const itemDate = new Date(item[dateField]);
        return itemDate >= startDateLimit! && itemDate <= endLimit;
      });
    } else if (dateRange === 'Last 7 Days') {
      startDateLimit = new Date();
      startDateLimit.setDate(now.getDate() - 7);
    } else if (dateRange === 'Last 30 Days') {
      startDateLimit = new Date();
      startDateLimit.setDate(now.getDate() - 30);
    } else if (dateRange === 'This Month') {
      startDateLimit = new Date(now.getFullYear(), now.getMonth(), 1);
    } else if (dateRange === 'This Year') {
      startDateLimit = new Date(now.getFullYear(), 0, 1);
    } else if (dateRange === 'Custom Range') {
      if (customStart) startDateLimit = new Date(customStart);
      let endLimit: Date | null = null;
      if (customEnd) {
        endLimit = new Date(customEnd);
        endLimit.setHours(23, 59, 59, 999);
      }
      return data.filter((item) => {
        const itemDate = new Date(item[dateField]);
        const matchStart = startDateLimit ? itemDate >= startDateLimit : true;
        const matchEnd = endLimit ? itemDate <= endLimit : true;
        return matchStart && matchEnd;
      });
    }

    if (!startDateLimit) return data;

    return data.filter((item) => {
      const itemDate = new Date(item[dateField]);
      return itemDate >= startDateLimit!;
    });
  };

  // Export Dashboard Summary Data as CSV/Excel
  const handleExportDashboardExcel = () => {
    if (!summary || !kpi) return;

    const headers = ['Mục Chỉ Số', 'Giá Trị Thực Tế'];
    const rows = [
      ['Tổng Doanh Thu Tích Lũy', summary.total_revenue],
      ['Tổng Số Đơn Hàng', summary.total_orders],
      ['Tổng Số Nhân Viên', summary.total_employees],
      ['Sessions Hoạt Động', summary.active_sessions],
      ['Cảnh Báo Hệ Thống', summary.total_notifications],
      ['Khách Hàng Bị Khóa (Blacklist)', summary.blacklisted_customers],
      ['Đơn Hàng Hôm Nay', kpi.orders_today],
      ['Doanh Thu Hôm Nay', kpi.revenue_today],
      ['Người Dùng Active Hôm Nay', kpi.active_users_today],
      ['Tỉ Lệ Tăng Trưởng', `${(kpi.growth_rate * 100).toFixed(1)}%`],
      ['Ngày Xuất Báo Cáo', new Date().toLocaleString('vi-VN')]
    ];

    const csvContent =
      '\uFEFF' +
      [headers.join(','), ...rows.map((row) => row.map((val) => `"${val}"`).join(','))].join('\n');

    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.setAttribute('href', url);
    link.setAttribute('download', `dashboard_summary_${new Date().toISOString().slice(0, 10)}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  // Export Dashboard layout as PDF via window print
  const handleExportDashboardPDF = () => {
    window.print();
  };

  if (loading) {
    return (
      <div className="loading-overlay" style={{ minHeight: '300px' }}>
        <div className="spinner"></div>
        <p className="text-secondary">Đang tải dữ liệu báo cáo tổng quan...</p>
      </div>
    );
  }

  if (error) {
    return (
      <div className="error-container">
        <div className="error-title">Đã xảy ra lỗi hệ thống</div>
        <div className="error-message">{error}</div>
        <button className="retry-btn" onClick={() => fetchDashboardData()}>Thử lại</button>
      </div>
    );
  }

  const filteredRevenueChart = filterChartData(revenueChart, 'date');
  const filteredOrdersChart = filterChartData(ordersChart, 'date');

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      
      {/* Filters Toolbar */}
      <div className="dashboard-card" style={{ padding: '16px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '16px' }}>
        
        {/* Date presets */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px', flexWrap: 'wrap' }}>
          <Calendar size={16} className="text-primary" />
          <span style={{ fontSize: '0.85rem', fontWeight: 600, color: 'var(--text-secondary)' }}>Thời Gian</span>
          <select
            className="form-input"
            value={dateRange}
            onChange={(e) => setDateRange(e.target.value)}
            style={{ padding: '6px 12px', fontSize: '0.85rem' }}
          >
            <option value="Today">Hôm nay (Today)</option>
            <option value="Yesterday">Hôm qua (Yesterday)</option>
            <option value="Last 7 Days">7 ngày qua (Last 7)</option>
            <option value="Last 30 Days">30 ngày qua (Last 30)</option>
            <option value="This Month">Tháng này</option>
            <option value="This Year">Năm nay</option>
            <option value="Custom Range">Tự chọn khoảng...</option>
          </select>

          {dateRange === 'Custom Range' && (
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px', animation: 'fadeIn 0.2s ease-out' }}>
              <input
                type="date"
                className="form-input"
                value={customStart}
                onChange={(e) => setCustomStart(e.target.value)}
                style={{ padding: '4px 8px', fontSize: '0.8rem' }}
              />
              <span style={{ color: 'var(--text-muted)' }}>-</span>
              <input
                type="date"
                className="form-input"
                value={customEnd}
                onChange={(e) => setCustomEnd(e.target.value)}
                style={{ padding: '4px 8px', fontSize: '0.8rem' }}
              />
            </div>
          )}
        </div>

        {/* Sync time / actions */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
            <span
              style={{
                width: '8px',
                height: '8px',
                borderRadius: '50%',
                backgroundColor: 'var(--success)',
                display: 'inline-block',
                animation: 'pulse-light 2s infinite'
              }}
            />
            <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>
              Auto Sync · Cập nhật lúc {lastRefreshed.toLocaleTimeString('vi-VN')}
            </span>
          </div>

          <button
            onClick={() => fetchDashboardData(true)}
            className="retry-btn"
            style={{
              padding: '6px 12px',
              fontSize: '0.85rem',
              display: 'flex',
              alignItems: 'center',
              gap: '6px',
              backgroundColor: 'var(--bg-tertiary)',
              border: '1px solid var(--border-color)',
              color: 'var(--text-primary)'
            }}
          >
            <RefreshCw size={12} className={isRefreshing ? 'animate-spin' : ''} /> Tải Lại
          </button>

          <button
            onClick={handleExportDashboardExcel}
            className="retry-btn"
            style={{ padding: '6px 12px', fontSize: '0.85rem', display: 'flex', alignItems: 'center', gap: '6px' }}
          >
            <Download size={12} /> Excel
          </button>
          
          <button
            onClick={handleExportDashboardPDF}
            className="retry-btn"
            style={{ padding: '6px 12px', fontSize: '0.85rem', display: 'flex', alignItems: 'center', gap: '6px' }}
          >
            <FileText size={12} /> PDF (Print)
          </button>

        </div>

      </div>

      {/* 1. Global KPI Metrics cards */}
      {summary && <DashboardSummary data={summary} />}
      
      {/* 2. Daily KPI & Growth indicators */}
      {kpi && <DashboardKPIs data={kpi} />}
      
      {/* 3. Charts Area */}
      <div className="charts-grid">
        {revenueChart && <RevenueChart data={filteredRevenueChart} />}
        {ordersChart && <OrdersChart data={filteredOrdersChart} />}
      </div>
      
      {/* 4. Log Feeds Activities */}
      {activities && <RecentActivities data={activities} />}

    </div>
  );
};

// ==========================================
// 3. MAIN ROUTER WRAPPER
// ==========================================
const App: React.FC = () => {
  const [isAuthenticated, setIsAuthenticated] = useState(!!localStorage.getItem('access_token'));
  const [loggedUsername, setLoggedUsername] = useState(localStorage.getItem('logged_username') || '');

  const handleLoginSuccess = (user: string) => {
    setIsAuthenticated(true);
    setLoggedUsername(user);
  };

  const handleLogout = () => {
    setIsAuthenticated(false);
    setLoggedUsername('');
    localStorage.removeItem('logged_username');
  };

  // Protected Layout component containing sidebar & header
  const ProtectedLayout: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    return isAuthenticated ? (
      <div className="app-container">
        <Sidebar username={loggedUsername} onLogout={handleLogout} />
        <div className="main-content">
          <Header username={loggedUsername} />
          {children}
        </div>
      </div>
    ) : (
      <Navigate to="/login" replace />
    );
  };

  return (
    <Router>
      <Routes>
        <Route
          path="/login"
          element={
            !isAuthenticated ? (
              <LoginPage onLoginSuccess={handleLoginSuccess} />
            ) : (
              <Navigate to="/" replace />
            )
          }
        />
        
        {/* Protected Dashboard Route */}
        <Route
          path="/"
          element={
            <ProtectedLayout>
              <DashboardPage />
            </ProtectedLayout>
          }
        />

        {/* Protected Employees Route */}
        <Route
          path="/employees"
          element={
            <ProtectedLayout>
              <EmployeesPage />
            </ProtectedLayout>
          }
        />

        {/* Protected Revenues Route */}
        <Route
          path="/revenues"
          element={
            <ProtectedLayout>
              <RevenuesPage />
            </ProtectedLayout>
          }
        />

        {/* Protected Blacklist Route */}
        <Route
          path="/blacklist"
          element={
            <ProtectedLayout>
              <BlacklistPage />
            </ProtectedLayout>
          }
        />

        {/* Protected Reports Route */}
        <Route
          path="/reports"
          element={
            <ProtectedLayout>
              <ReportsPage />
            </ProtectedLayout>
          }
        />

        {/* Protected Settings Route */}
        <Route
          path="/settings"
          element={
            <ProtectedLayout>
              <SettingsPage />
            </ProtectedLayout>
          }
        />

        {/* Wildcard Fallback */}
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </Router>
  );
};

export default App;
