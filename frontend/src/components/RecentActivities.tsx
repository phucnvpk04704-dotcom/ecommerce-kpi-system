import React, { useState } from 'react';
import { ShoppingCart, ClipboardList, Key, Bell, Check, User, ShieldAlert } from 'lucide-react';

interface Order {
  id?: string;
  order_id: string;
  platform: string;
  customer_name?: string;
  customer_phone: string;
  total_amount: number;
  status: string;
  created_at: string;
}

interface AuditLog {
  id?: string;
  user_id: string;
  action: string;
  entity_type: string;
  entity_id: string;
  created_at: string;
}

interface EmployeeSession {
  id?: string;
  employee_id: string;
  session_id: string;
  ip_address?: string;
  user_agent?: string;
  created_at: string;
}

interface Notification {
  id?: string;
  recipient_role?: string;
  title: string;
  body: string;
  type: string;
  is_read: boolean;
  created_at: string;
}

interface RecentActivitiesProps {
  data: {
    recent_orders: Order[];
    recent_audit_logs: AuditLog[];
    recent_sessions: EmployeeSession[];
    recent_notifications: Notification[];
  };
}

const RecentActivities: React.FC<RecentActivitiesProps> = ({ data }) => {
  const [activeTab, setActiveTab] = useState<'orders' | 'audits' | 'sessions' | 'notifications'>('orders');

  const formatCurrency = (val: number) => {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(val);
  };

  const formatDate = (dateStr: string) => {
    const d = new Date(dateStr);
    return d.toLocaleString('vi-VN', {
      hour: '2-digit',
      minute: '2-digit',
      day: '2-digit',
      month: '2-digit',
      year: 'numeric'
    });
  };

  // Safe Fallback defaults
  const orders = data?.recent_orders || [];
  const audits = data?.recent_audit_logs || [];
  const sessions = data?.recent_sessions || [];
  const notifications = data?.recent_notifications || [];

  return (
    <div className="dashboard-card" style={{ gridColumn: 'span 2' }}>
      <div className="card-header" style={{ marginBottom: '8px' }}>
        <span className="card-title" style={{ fontSize: '1.1rem', fontWeight: 600 }}>Hoạt động hệ thống gần đây</span>
      </div>

      {/* Tab Buttons */}
      <div className="tabs-container">
        <button
          className={`tab-btn ${activeTab === 'orders' ? 'active' : ''}`}
          onClick={() => setActiveTab('orders')}
        >
          <ShoppingCart size={16} style={{ marginRight: '6px', verticalAlign: 'middle' }} />
          Đơn Hàng Mới ({orders.length})
        </button>
        <button
          className={`tab-btn ${activeTab === 'audits' ? 'active' : ''}`}
          onClick={() => setActiveTab('audits')}
        >
          <ClipboardList size={16} style={{ marginRight: '6px', verticalAlign: 'middle' }} />
          Nhật Ký Audit ({audits.length})
        </button>
        <button
          className={`tab-btn ${activeTab === 'sessions' ? 'active' : ''}`}
          onClick={() => setActiveTab('sessions')}
        >
          <Key size={16} style={{ marginRight: '6px', verticalAlign: 'middle' }} />
          Phiên Đăng Nhập ({sessions.length})
        </button>
        <button
          className={`tab-btn ${activeTab === 'notifications' ? 'active' : ''}`}
          onClick={() => setActiveTab('notifications')}
        >
          <Bell size={16} style={{ marginRight: '6px', verticalAlign: 'middle' }} />
          Thông Báo ({notifications.length})
        </button>
      </div>

      {/* Tab Content Panels */}
      <div className="activity-list">
        {activeTab === 'orders' && (
          orders.length === 0 ? (
            <p className="text-muted" style={{ padding: '24px 0', textAlign: 'center' }}>Không có đơn hàng gần đây</p>
          ) : (
            orders.map((order, idx) => (
              <div key={order.id || idx} className="activity-item">
                <div className="activity-details">
                  <div className="activity-title">
                    Đơn hàng {order.order_id} <span className="badge completed" style={{ marginLeft: '8px' }}>{order.platform}</span>
                  </div>
                  <div className="activity-desc">
                    Khách hàng: {order.customer_name || 'Khách vãng lai'} ({order.customer_phone})
                  </div>
                </div>
                <div className="activity-meta">
                  <div style={{ fontWeight: 700, color: 'var(--text-primary)' }}>{formatCurrency(order.total_amount)}</div>
                  <div className="activity-time">{formatDate(order.created_at)}</div>
                  <span className={`badge ${order.status.toLowerCase() === 'completed' ? 'completed' : order.status.toLowerCase() === 'cancelled' ? 'cancelled' : 'pending'}`}>
                    {order.status}
                  </span>
                </div>
              </div>
            ))
          )
        )}

        {activeTab === 'audits' && (
          audits.length === 0 ? (
            <p className="text-muted" style={{ padding: '24px 0', textAlign: 'center' }}>Không có nhật ký ghi nhận</p>
          ) : (
            audits.map((log, idx) => (
              <div key={log.id || idx} className="activity-item">
                <div className="activity-details">
                  <div className="activity-title" style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <User size={14} className="text-muted" />
                    Nhân viên ID: {log.user_id.slice(-8)}
                  </div>
                  <div className="activity-desc">
                    Hành động: <strong>{log.action}</strong> | Đối tượng: {log.entity_type} ({log.entity_id.slice(-8)})
                  </div>
                </div>
                <div className="activity-meta">
                  <div className="activity-time">{formatDate(log.created_at)}</div>
                  <span className="badge pending" style={{ textTransform: 'none' }}>Audit Log</span>
                </div>
              </div>
            ))
          )
        )}

        {activeTab === 'sessions' && (
          sessions.length === 0 ? (
            <p className="text-muted" style={{ padding: '24px 0', textAlign: 'center' }}>Không có phiên đăng nhập hoạt động</p>
          ) : (
            sessions.map((session, idx) => (
              <div key={session.id || idx} className="activity-item">
                <div className="activity-details">
                  <div className="activity-title">
                    Nhân viên ID: {session.employee_id.slice(-8)}
                  </div>
                  <div className="activity-desc" style={{ fontFamily: 'monospace', fontSize: '0.7rem', color: 'var(--text-muted)' }}>
                    IP: {session.ip_address || 'N/A'} | Browser: {session.user_agent ? session.user_agent.split(' ')[0] : 'N/A'}
                  </div>
                </div>
                <div className="activity-meta">
                  <div className="activity-time">{formatDate(session.created_at)}</div>
                  <span className="badge completed" style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                    <Check size={10} /> Active
                  </span>
                </div>
              </div>
            ))
          )
        )}

        {activeTab === 'notifications' && (
          notifications.length === 0 ? (
            <p className="text-muted" style={{ padding: '24px 0', textAlign: 'center' }}>Không có thông báo hệ thống</p>
          ) : (
            notifications.map((notif, idx) => (
              <div key={notif.id || idx} className="activity-item">
                <div className="activity-details">
                  <div className="activity-title" style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    {notif.type === 'SYSTEM' ? <ShieldAlert size={14} className="text-rose-500" /> : <Bell size={14} className="text-amber-500" />}
                    {notif.title}
                  </div>
                  <div className="activity-desc" style={{ color: 'var(--text-secondary)' }}>
                    {notif.body}
                  </div>
                </div>
                <div className="activity-meta">
                  <div className="activity-time">{formatDate(notif.created_at)}</div>
                  <span className={`badge ${notif.is_read ? 'completed' : 'cancelled'}`}>
                    {notif.is_read ? 'Đã xem' : 'Mới'}
                  </span>
                </div>
              </div>
            ))
          )
        )}
      </div>
    </div>
  );
};

export default RecentActivities;
