import React from 'react';
import { ShoppingBag, DollarSign, Users, ShieldAlert, Activity, Bell } from 'lucide-react';

interface SummaryData {
  total_orders: number;
  total_revenue: string | number;
  total_employees: number;
  active_sessions: number;
  total_notifications: number;
  blacklisted_customers: number;
}

interface SummaryProps {
  data: SummaryData;
}

const DashboardSummary: React.FC<SummaryProps> = ({ data }) => {
  // Format revenue to currency string (VND)
  const formatCurrency = (val: string | number) => {
    const num = typeof val === 'string' ? parseFloat(val) : val;
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(num);
  };

  const cards = [
    {
      title: 'Doanh Thu Tích Lũy',
      value: formatCurrency(data.total_revenue),
      icon: <DollarSign size={20} className="text-emerald-500" />,
      iconBg: 'var(--success-light)',
      textColor: 'text-emerald-500'
    },
    {
      title: 'Tổng Số Đơn Hàng',
      value: data.total_orders.toLocaleString('vi-VN'),
      icon: <ShoppingBag size={20} className="text-indigo-500" />,
      iconBg: 'var(--primary-light)',
      textColor: 'text-indigo-500'
    },
    {
      title: 'Tổng Số Nhân Viên',
      value: data.total_employees.toLocaleString('vi-VN'),
      icon: <Users size={20} className="text-cyan-500" />,
      iconBg: 'var(--info-light)',
      textColor: 'text-cyan-500'
    },
    {
      title: 'Sessions Đang Chạy',
      value: data.active_sessions.toLocaleString('vi-VN'),
      icon: <Activity size={20} className="text-violet-500" />,
      iconBg: 'rgba(139, 92, 246, 0.1)',
      textColor: 'text-violet-500'
    },
    {
      title: 'Thông Báo Hệ Thống',
      value: data.total_notifications.toLocaleString('vi-VN'),
      icon: <Bell size={20} className="text-amber-500" />,
      iconBg: 'var(--warning-light)',
      textColor: 'text-amber-500'
    },
    {
      title: 'Khách Hàng Blacklist',
      value: data.blacklisted_customers.toLocaleString('vi-VN'),
      icon: <ShieldAlert size={20} className="text-rose-500" />,
      iconBg: 'var(--danger-light)',
      textColor: 'text-rose-500'
    }
  ];

  return (
    <div className="summary-grid">
      {cards.map((card, idx) => (
        <div key={idx} className="dashboard-card summary-card">
          <div className="summary-icon" style={{ backgroundColor: card.iconBg }}>
            {card.icon}
          </div>
          <div className="summary-info">
            <p>{card.title}</p>
            <h3>{card.value}</h3>
          </div>
        </div>
      ))}
    </div>
  );
};

export default DashboardSummary;
