import React, { useEffect, useState } from 'react';
import { getSettingByKey, createSetting, updateSetting } from '../../services/settingsApi';
import type { Setting } from '../../services/settingsApi';
import { Settings, Sliders, Bell, Globe, Save, RefreshCw, CheckCircle, AlertCircle, Loader } from 'lucide-react';

const SettingsPage: React.FC = () => {
  // Tabs: 'general' | 'dashboard' | 'notification'
  const [activeTab, setActiveTab] = useState<'general' | 'dashboard' | 'notification'>('general');
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  // Database settings items
  const [generalSetting, setGeneralSetting] = useState<Setting | null>(null);
  const [dashboardSetting, setDashboardSetting] = useState<Setting | null>(null);
  const [notificationSetting, setNotificationSetting] = useState<Setting | null>(null);

  // Form local state
  const [generalForm, setGeneralForm] = useState({
    system_name: 'Ecommerce KPI Management System',
    timezone: 'Asia/Ho_Chi_Minh',
    base_currency: 'VND',
    support_email: 'support@ecommercekpi.com',
    allow_registration: false
  });

  const [dashboardForm, setDashboardForm] = useState({
    default_date_range: 'Last 30 Days',
    auto_refresh_interval: 30, // seconds
    default_chart_style: 'Area',
    compact_view_by_default: false
  });

  const [notificationForm, setNotificationForm] = useState({
    email_daily_report: true,
    email_blacklist_alert: true,
    telegram_integration: false,
    telegram_bot_token: '',
    telegram_chat_id: '',
    alert_on_critical_kpi_fall: true
  });

  const defaultUpdatedBy = '60d5ec4983050119b4cfdc7d'; // fallback PyObjectId

  const fetchSettings = async () => {
    setLoading(true);
    setMessage(null);
    try {
      // Fetch each settings entry by its unique key
      const [genRes, dashRes, notifRes] = await Promise.allSettled([
        getSettingByKey('general_settings'),
        getSettingByKey('dashboard_settings'),
        getSettingByKey('notification_settings')
      ]);

      if (genRes.status === 'fulfilled') {
        setGeneralSetting(genRes.value);
        setGeneralForm({ ...generalForm, ...genRes.value.value });
      }
      if (dashRes.status === 'fulfilled') {
        setDashboardSetting(dashRes.value);
        setDashboardForm({ ...dashboardForm, ...dashRes.value.value });
      }
      if (notifRes.status === 'fulfilled') {
        setNotificationSetting(notifRes.value);
        setNotificationForm({ ...notificationForm, ...notifRes.value.value });
      }
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchSettings();
  }, []);

  const handleSaveSettings = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    setMessage(null);

    try {
      if (activeTab === 'general') {
        if (generalSetting) {
          // Update
          const updated = await updateSetting(generalSetting.id, {
            value: generalForm,
            updated_by: defaultUpdatedBy
          });
          setGeneralSetting(updated);
        } else {
          // Create
          const created = await createSetting({
            key: 'general_settings',
            value: generalForm,
            updated_by: defaultUpdatedBy
          });
          setGeneralSetting(created);
        }
      } else if (activeTab === 'dashboard') {
        if (dashboardSetting) {
          const updated = await updateSetting(dashboardSetting.id, {
            value: dashboardForm,
            updated_by: defaultUpdatedBy
          });
          setDashboardSetting(updated);
        } else {
          const created = await createSetting({
            key: 'dashboard_settings',
            value: dashboardForm,
            updated_by: defaultUpdatedBy
          });
          setDashboardSetting(created);
        }
      } else if (activeTab === 'notification') {
        if (notificationSetting) {
          const updated = await updateSetting(notificationSetting.id, {
            value: notificationForm,
            updated_by: defaultUpdatedBy
          });
          setNotificationSetting(updated);
        } else {
          const created = await createSetting({
            key: 'notification_settings',
            value: notificationForm,
            updated_by: defaultUpdatedBy
          });
          setNotificationSetting(created);
        }
      }

      setMessage({ type: 'success', text: 'Đã lưu cấu hình hệ thống thành công!' });
    } catch (err: any) {
      console.error(err);
      setMessage({
        type: 'error',
        text: err.response?.data?.detail || 'Lỗi khi lưu trữ thiết lập. Vui lòng xác thực quyền quản trị.'
      });
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      
      {/* Title block */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h2 style={{ fontSize: '1.5rem', fontWeight: 700 }}>Thiết Lập Hệ Thống</h2>
          <p style={{ fontSize: '0.875rem', color: 'var(--text-secondary)' }}>
            Cấu hình tham số hệ thống, chu kỳ tải bảng tin dashboard và tùy chọn kênh thông báo đẩy.
          </p>
        </div>
        <button
          onClick={fetchSettings}
          className="retry-btn"
          style={{ display: 'inline-flex', alignItems: 'center', gap: '6px', backgroundColor: 'var(--bg-tertiary)', border: '1px solid var(--border-color)', color: 'var(--text-primary)' }}
        >
          <RefreshCw size={14} className={loading ? 'animate-spin' : ''} /> Làm Mới
        </button>
      </div>

      {/* Tabs */}
      <div className="tabs-container" style={{ marginBottom: '0px' }}>
        <button
          className={`tab-btn ${activeTab === 'general' ? 'active' : ''}`}
          onClick={() => {
            setMessage(null);
            setActiveTab('general');
          }}
          style={{ display: 'inline-flex', alignItems: 'center', gap: '8px' }}
        >
          <Globe size={16} /> Cấu Hình Chung
        </button>
        <button
          className={`tab-btn ${activeTab === 'dashboard' ? 'active' : ''}`}
          onClick={() => {
            setMessage(null);
            setActiveTab('dashboard');
          }}
          style={{ display: 'inline-flex', alignItems: 'center', gap: '8px' }}
        >
          <Sliders size={16} /> Dashboard Settings
        </button>
        <button
          className={`tab-btn ${activeTab === 'notification' ? 'active' : ''}`}
          onClick={() => {
            setMessage(null);
            setActiveTab('notification');
          }}
          style={{ display: 'inline-flex', alignItems: 'center', gap: '8px' }}
        >
          <Bell size={16} /> Thông Báo & Cảnh Báo
        </button>
      </div>

      {loading ? (
        <div className="loading-overlay" style={{ minHeight: '260px' }}>
          <div className="spinner"></div>
          <p className="text-secondary">Đang nạp cấu hình hệ thống...</p>
        </div>
      ) : (
        <div style={{ display: 'grid', gridTemplateColumns: '3fr 1fr', gap: '20px', alignItems: 'start' }}>
          
          {/* Main Settings Form */}
          <div className="dashboard-card" style={{ padding: '24px' }}>
            
            {message && (
              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '8px',
                  fontSize: '0.875rem',
                  backgroundColor: message.type === 'success' ? 'var(--success-light)' : 'var(--danger-light)',
                  color: message.type === 'success' ? 'var(--success)' : 'var(--danger)',
                  padding: '12px',
                  borderRadius: '6px',
                  border: `1px solid ${message.type === 'success' ? 'rgba(16, 185, 129, 0.2)' : 'rgba(239, 68, 68, 0.2)'}`,
                  marginBottom: '20px'
                }}
              >
                {message.type === 'success' ? <CheckCircle size={16} /> : <AlertCircle size={16} />}
                <span>{message.text}</span>
              </div>
            )}

            <form onSubmit={handleSaveSettings}>
              
              {/* Tab 1: General */}
              {activeTab === 'general' && (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                  <h3 style={{ fontSize: '1.1rem', fontWeight: 600, borderBottom: '1px solid var(--border-color)', paddingBottom: '10px' }}>
                    Tham số hệ thống chung
                  </h3>
                  
                  <div className="form-group">
                    <label>Tên Hệ Thống / Thương Hiệu</label>
                    <input
                      type="text"
                      className="form-input"
                      value={generalForm.system_name}
                      onChange={(e) => setGeneralForm({ ...generalForm, system_name: e.target.value })}
                    />
                  </div>

                  <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
                    <div className="form-group">
                      <label>Múi Giờ (Timezone)</label>
                      <select
                        className="form-input"
                        value={generalForm.timezone}
                        onChange={(e) => setGeneralForm({ ...generalForm, timezone: e.target.value })}
                      >
                        <option value="Asia/Ho_Chi_Minh">Asia/Ho_Chi_Minh (UTC+7)</option>
                        <option value="UTC">Coordinated Universal Time (UTC)</option>
                        <option value="America/New_York">Eastern Time (US/Eastern)</option>
                      </select>
                    </div>

                    <div className="form-group">
                      <label>Đơn Vị Tiền Tệ Định Giá</label>
                      <select
                        className="form-input"
                        value={generalForm.base_currency}
                        onChange={(e) => setGeneralForm({ ...generalForm, base_currency: e.target.value })}
                      >
                        <option value="VND">Vietnamese Dong (VND)</option>
                        <option value="USD">US Dollar (USD)</option>
                        <option value="EUR">Euro (EUR)</option>
                      </select>
                    </div>
                  </div>

                  <div className="form-group">
                    <label>Hộp thư hỗ trợ kỹ thuật</label>
                    <input
                      type="email"
                      className="form-input"
                      value={generalForm.support_email}
                      onChange={(e) => setGeneralForm({ ...generalForm, support_email: e.target.value })}
                    />
                  </div>

                  <div className="form-group" style={{ display: 'flex', flexDirection: 'row', alignItems: 'center', gap: '10px', marginTop: '6px' }}>
                    <input
                      type="checkbox"
                      id="allow_reg"
                      style={{ cursor: 'pointer', width: '16px', height: '16px' }}
                      checked={generalForm.allow_registration}
                      onChange={(e) => setGeneralForm({ ...generalForm, allow_registration: e.target.checked })}
                    />
                    <label htmlFor="allow_reg" style={{ cursor: 'pointer', textTransform: 'none', fontWeight: 500, fontSize: '0.875rem' }}>
                      Cho phép nhân viên tự đăng ký tài khoản trực tuyến (Pending approval)
                    </label>
                  </div>
                </div>
              )}

              {/* Tab 2: Dashboard Settings */}
              {activeTab === 'dashboard' && (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                  <h3 style={{ fontSize: '1.1rem', fontWeight: 600, borderBottom: '1px solid var(--border-color)', paddingBottom: '10px' }}>
                    Cấu hình tải bảng tin Dashboard
                  </h3>

                  <div className="form-group">
                    <label>Khoảng thời gian nạp mặc định</label>
                    <select
                      className="form-input"
                      value={dashboardForm.default_date_range}
                      onChange={(e) => setDashboardForm({ ...dashboardForm, default_date_range: e.target.value })}
                    >
                      <option value="Today">Hôm nay (Today)</option>
                      <option value="Yesterday">Hôm qua (Yesterday)</option>
                      <option value="Last 7 Days">7 ngày gần nhất (Last 7 Days)</option>
                      <option value="Last 30 Days">30 ngày gần nhất (Last 30 Days)</option>
                      <option value="This Month">Tháng này (This Month)</option>
                      <option value="This Year">Năm nay (This Year)</option>
                    </select>
                  </div>

                  <div className="form-group">
                    <label>Khoảng thời gian Tự động Tải lại (Giây): {dashboardForm.auto_refresh_interval}s</label>
                    <input
                      type="range"
                      min="5"
                      max="300"
                      step="5"
                      style={{ accentColor: 'var(--primary)', cursor: 'pointer' }}
                      value={dashboardForm.auto_refresh_interval}
                      onChange={(e) => setDashboardForm({ ...dashboardForm, auto_refresh_interval: parseInt(e.target.value) || 30 })}
                    />
                    <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>Thời gian để UI fetch lại API dashboard định kỳ. Mặc định 30 giây.</div>
                  </div>

                  <div className="form-group">
                    <label>Kiểu Biểu Đồ Mặc Định</label>
                    <select
                      className="form-input"
                      value={dashboardForm.default_chart_style}
                      onChange={(e) => setDashboardForm({ ...dashboardForm, default_chart_style: e.target.value })}
                    >
                      <option value="Area">Biểu đồ Vùng (Area Chart)</option>
                      <option value="Bar">Biểu đồ Cột (Bar Chart)</option>
                      <option value="Line">Biểu đồ Đường (Line Chart)</option>
                    </select>
                  </div>

                  <div className="form-group" style={{ display: 'flex', flexDirection: 'row', alignItems: 'center', gap: '10px', marginTop: '6px' }}>
                    <input
                      type="checkbox"
                      id="compact_view"
                      style={{ cursor: 'pointer', width: '16px', height: '16px' }}
                      checked={dashboardForm.compact_view_by_default}
                      onChange={(e) => setDashboardForm({ ...dashboardForm, compact_view_by_default: e.target.checked })}
                    />
                    <label htmlFor="compact_view" style={{ cursor: 'pointer', textTransform: 'none', fontWeight: 500, fontSize: '0.875rem' }}>
                      Bật giao diện thu gọn (Compact View) mặc định cho bảng biểu
                    </label>
                  </div>
                </div>
              )}

              {/* Tab 3: Notifications */}
              {activeTab === 'notification' && (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                  <h3 style={{ fontSize: '1.1rem', fontWeight: 600, borderBottom: '1px solid var(--border-color)', paddingBottom: '10px' }}>
                    Tùy chọn cảnh báo tự động
                  </h3>

                  <div className="form-group" style={{ display: 'flex', flexDirection: 'row', alignItems: 'center', gap: '10px' }}>
                    <input
                      type="checkbox"
                      id="email_daily"
                      style={{ cursor: 'pointer', width: '16px', height: '16px' }}
                      checked={notificationForm.email_daily_report}
                      onChange={(e) => setNotificationForm({ ...notificationForm, email_daily_report: e.target.checked })}
                    />
                    <label htmlFor="email_daily" style={{ cursor: 'pointer', textTransform: 'none', fontWeight: 500, fontSize: '0.875rem' }}>
                      Gửi email báo cáo KPI tổng hợp hàng ngày cho người phụ trách
                    </label>
                  </div>

                  <div className="form-group" style={{ display: 'flex', flexDirection: 'row', alignItems: 'center', gap: '10px' }}>
                    <input
                      type="checkbox"
                      id="email_bl"
                      style={{ cursor: 'pointer', width: '16px', height: '16px' }}
                      checked={notificationForm.email_blacklist_alert}
                      onChange={(e) => setNotificationForm({ ...notificationForm, email_blacklist_alert: e.target.checked })}
                    />
                    <label htmlFor="email_bl" style={{ cursor: 'pointer', textTransform: 'none', fontWeight: 500, fontSize: '0.875rem' }}>
                      Cảnh báo ngay lập tức qua email khi phát hiện khách hàng rủi ro cao (Blacklist)
                    </label>
                  </div>

                  <div className="form-group" style={{ display: 'flex', flexDirection: 'row', alignItems: 'center', gap: '10px' }}>
                    <input
                      type="checkbox"
                      id="kpi_fall"
                      style={{ cursor: 'pointer', width: '16px', height: '16px' }}
                      checked={notificationForm.alert_on_critical_kpi_fall}
                      onChange={(e) => setNotificationForm({ ...notificationForm, alert_on_critical_kpi_fall: e.target.checked })}
                    />
                    <label htmlFor="kpi_fall" style={{ cursor: 'pointer', textTransform: 'none', fontWeight: 500, fontSize: '0.875rem' }}>
                      Cảnh báo khi điểm số KPI trung bình của cửa hàng giảm đột ngột {'>'}15%
                    </label>
                  </div>

                  <h3 style={{ fontSize: '1.05rem', fontWeight: 600, borderBottom: '1px solid var(--border-color)', paddingBottom: '8px', marginTop: '12px' }}>
                    Tích hợp kênh Telegram Bot (Real-time alerting)
                  </h3>

                  <div className="form-group" style={{ display: 'flex', flexDirection: 'row', alignItems: 'center', gap: '10px' }}>
                    <input
                      type="checkbox"
                      id="tele_int"
                      style={{ cursor: 'pointer', width: '16px', height: '16px' }}
                      checked={notificationForm.telegram_integration}
                      onChange={(e) => setNotificationForm({ ...notificationForm, telegram_integration: e.target.checked })}
                    />
                    <label htmlFor="tele_int" style={{ cursor: 'pointer', textTransform: 'none', fontWeight: 500, fontSize: '0.875rem' }}>
                      Kích hoạt cảnh báo thời gian thực về Telegram Channel
                    </label>
                  </div>

                  {notificationForm.telegram_integration && (
                    <div style={{ display: 'flex', flexDirection: 'column', gap: '12px', paddingLeft: '26px', animation: 'fadeIn 0.3s ease-out' }}>
                      <div className="form-group">
                        <label>Telegram Bot Token API</label>
                        <input
                          type="password"
                          className="form-input"
                          placeholder="Ví dụ: 123456789:ABCdefGhIJKlmNoPQRsTUVwxyZ"
                          value={notificationForm.telegram_bot_token}
                          onChange={(e) => setNotificationForm({ ...notificationForm, telegram_bot_token: e.target.value })}
                        />
                      </div>
                      <div className="form-group">
                        <label>Telegram Chat ID / Channel ID</label>
                        <input
                          type="text"
                          className="form-input"
                          placeholder="Ví dụ: -100123456789"
                          value={notificationForm.telegram_chat_id}
                          onChange={(e) => setNotificationForm({ ...notificationForm, telegram_chat_id: e.target.value })}
                        />
                      </div>
                    </div>
                  )}

                </div>
              )}

              <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: '24px', borderTop: '1px solid var(--border-color)', paddingTop: '16px' }}>
                <button
                  type="submit"
                  className="retry-btn"
                  disabled={submitting}
                  style={{ display: 'inline-flex', alignItems: 'center', gap: '8px' }}
                >
                  {submitting ? (
                    <Loader size={16} className="animate-spin" />
                  ) : (
                    <Save size={16} />
                  )}
                  Lưu thiết lập
                </button>
              </div>

            </form>

          </div>

          {/* Settings Help sidebar card */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            
            <div className="dashboard-card" style={{ padding: '16px' }}>
              <h4 style={{ fontSize: '0.9rem', fontWeight: 700, marginBottom: '8px', display: 'flex', alignItems: 'center', gap: '6px' }}>
                <Settings size={14} className="text-primary" /> Hướng dẫn cấu hình
              </h4>
              <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)', lineHeight: 1.5 }}>
                Các thiết lập ở trang này được lưu trực tiếp vào cơ sở dữ liệu MongoDB ở dạng thực thể cấu hình động.
              </p>
              <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)', lineHeight: 1.5, marginTop: '8px' }}>
                Chỉ người dùng có quyền Quản Trị Viên (Admin) hoặc Giám Đốc Kênh (Manager) mới có thể thực hiện thay đổi giá trị cấu hình.
              </p>
            </div>

            <div className="dashboard-card" style={{ padding: '16px' }}>
              <h4 style={{ fontSize: '0.9rem', fontWeight: 700, marginBottom: '8px', display: 'flex', alignItems: 'center', gap: '6px' }}>
                <Sliders size={14} className="text-emerald-500" /> Tần suất cập nhật
              </h4>
              <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)', lineHeight: 1.5 }}>
                Các thiết lập liên quan tới tần suất cập nhật dashboard sẽ có hiệu lực ngay sau khi lưu và tải lại trình duyệt.
              </p>
            </div>

          </div>

        </div>
      )}

    </div>
  );
};

export default SettingsPage;
