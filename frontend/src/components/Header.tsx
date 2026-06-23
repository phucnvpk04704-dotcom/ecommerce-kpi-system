import React from 'react';

interface HeaderProps {
  username: string;
}

const Header: React.FC<HeaderProps> = ({ username }) => {
  const getTodayString = () => {
    return new Date().toLocaleDateString('vi-VN', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  };

  return (
    <div className="header-bar">
      <div className="header-title">
        <h1>Hệ thống Quản lý KPI & Doanh số</h1>
        <p>{getTodayString()}</p>
      </div>

      <div className="user-profile">
        <div className="user-info">
          <div className="user-name" style={{ textAlign: 'right' }}>{username}</div>
          <div className="user-role" style={{ textAlign: 'right' }}>Administrator</div>
        </div>
        <div className="user-avatar">
          {username.substring(0, 2).toUpperCase()}
        </div>
      </div>
    </div>
  );
};

export default Header;
