import React from 'react';
import { TrendingUp, TrendingDown, ArrowRight, ShoppingCart, DollarSign, Users, Award } from 'lucide-react';

interface KPIData {
  orders_today: number;
  revenue_today: string | number;
  active_users_today: number;
  growth_rate: number;
}

interface KPIProps {
  data: KPIData;
}

const DashboardKPIs: React.FC<KPIProps> = ({ data }) => {
  const formatCurrency = (val: string | number) => {
    const num = typeof val === 'string' ? parseFloat(val) : val;
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(num);
  };

  const getGrowthTrend = (rate: number) => {
    if (rate > 0) {
      return (
        <span className="kpi-trend positive">
          <TrendingUp size={16} />
          +{ (rate * 100).toFixed(1) }% so với hôm qua
        </span>
      );
    } else if (rate < 0) {
      return (
        <span className="kpi-trend negative">
          <TrendingDown size={16} />
          { (rate * 100).toFixed(1) }% so với hôm qua
        </span>
      );
    }
    return (
      <span className="kpi-trend neutral">
        <ArrowRight size={16} />
        0% so với hôm qua
      </span>
    );
  };

  return (
    <div className="kpi-grid">
      {/* 1. Orders Today Card */}
      <div className="dashboard-card kpi-card orders">
        <div className="card-header">
          <span className="card-title">Đơn hàng hôm nay</span>
          <ShoppingCart size={18} className="text-muted" />
        </div>
        <div className="kpi-value">{data.orders_today}</div>
        <span className="kpi-trend neutral" style={{ color: 'var(--info)' }}>
          Cập nhật thời gian thực từ cửa hàng
        </span>
      </div>

      {/* 2. Revenue Today Card */}
      <div className="dashboard-card kpi-card revenue">
        <div className="card-header">
          <span className="card-title">Doanh thu hôm nay</span>
          <DollarSign size={18} className="text-muted" />
        </div>
        <div className="kpi-value">{formatCurrency(data.revenue_today)}</div>
        <span className="kpi-trend neutral" style={{ color: 'var(--success)' }}>
          Doanh thu hoàn thành phát sinh hôm nay
        </span>
      </div>

      {/* 3. Active Users Today Card */}
      <div className="dashboard-card kpi-card active-users">
        <div className="card-header">
          <span className="card-title">Nhân viên hoạt động hôm nay</span>
          <Users size={18} className="text-muted" />
        </div>
        <div className="kpi-value">{data.active_users_today}</div>
        <span className="kpi-trend neutral" style={{ color: 'var(--primary)' }}>
          Số nhân viên có session hoạt động hôm nay
        </span>
      </div>

      {/* 4. Growth Rate Card */}
      <div className="dashboard-card kpi-card growth">
        <div className="card-header">
          <span className="card-title">Tốc độ tăng trưởng doanh thu</span>
          <Award size={18} className="text-muted" />
        </div>
        <div className="kpi-value">
          {data.growth_rate >= 0 ? '+' : ''}{(data.growth_rate * 100).toFixed(0)}%
        </div>
        {getGrowthTrend(data.growth_rate)}
      </div>
    </div>
  );
};

export default DashboardKPIs;
