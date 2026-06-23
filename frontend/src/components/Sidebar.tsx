import React from 'react';
import { NavLink } from 'react-router-dom';
import {
  LayoutDashboard,
  LogOut,
  Settings,
  Users,
  BarChart3,
  AlertOctagon,
  FileText
} from 'lucide-react';
import { logout } from '../api/dashboard';

interface SidebarProps {
  onLogout: () => void;
  username: string;
}

const Sidebar: React.FC<SidebarProps> = ({ onLogout, username }) => {
  const handleLogoutClick = () => {
    logout();
    onLogout();
  };

  const navItems = [
    { to: '/', label: 'Tổng Quan Dashboard', icon: <LayoutDashboard size={18} /> },
    { to: '/employees', label: 'Nhân Viên (Employees)', icon: <Users size={18} /> },
    { to: '/revenues', label: 'Doanh Số (Revenues)', icon: <BarChart3 size={18} /> },
    { to: '/blacklist', label: 'Blacklist Khách Hàng', icon: <AlertOctagon size={18} /> },
    { to: '/reports', label: 'Báo Cáo (Reports)', icon: <FileText size={18} /> },
    { to: '/settings', label: 'Cấu Hình Hệ Thống', icon: <Settings size={18} /> }
  ];

  return (
    <div className="sidebar">
      {/* Brand Logo */}
      <div className="sidebar-logo">
        <div className="logo-icon">E</div>
        <div className="logo-text">Ecommerce KPI</div>
      </div>

      {/* Navigation Links */}
      <nav className="sidebar-nav">
        {navItems.map((item) => (
          <NavLink
            key={item.to}
            to={item.to}
            className={({ isActive }) => (isActive ? 'nav-link active' : 'nav-link')}
            end={item.to === '/'}
          >
            {item.icon}
            {item.label}
          </NavLink>
        ))}
      </nav>

      {/* Footer and Logout button */}
      <div className="sidebar-footer">
        <div style={{ padding: '0 8px 12px 8px', fontSize: '0.8rem', color: 'var(--text-muted)' }}>
          Đăng nhập: <strong style={{ color: 'var(--text-secondary)' }}>{username}</strong>
        </div>
        <button className="logout-btn" onClick={handleLogoutClick}>
          <LogOut size={16} />
          Đăng Xuất
        </button>
      </div>
    </div>
  );
};

export default Sidebar;
