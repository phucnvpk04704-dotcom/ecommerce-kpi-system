import React from 'react';

const App: React.FC = () => {
  return (
    <div style={{
      width: '320px',
      padding: '20px',
      fontFamily: 'system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
      backgroundColor: '#f8fafc',
      color: '#0f172a',
      borderRadius: '8px',
      boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)'
    }}>
      <h2 style={{ margin: '0 0 8px 0', fontSize: '18px', color: '#1e40af' }}>Enterprise Extension</h2>
      <p style={{ margin: '0 0 16px 0', fontSize: '13px', color: '#64748b' }}>Version 1.0.0</p>
      
      <div style={{
        display: 'flex',
        alignItems: 'center',
        gap: '8px',
        padding: '10px 12px',
        backgroundColor: '#dcfce7',
        color: '#15803d',
        borderRadius: '6px',
        fontSize: '14px',
        fontWeight: 600
      }}>
        <span style={{
          width: '8px',
          height: '8px',
          backgroundColor: '#22c55e',
          borderRadius: '50%',
          display: 'inline-block'
        }}></span>
        System Ready
      </div>
    </div>
  );
};

export default App;
