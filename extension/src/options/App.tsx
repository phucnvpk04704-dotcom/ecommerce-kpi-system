import React from 'react';

const App: React.FC = () => {
  return (
    <div style={{
      maxWidth: '600px',
      margin: '40px auto',
      padding: '24px',
      fontFamily: 'system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
      backgroundColor: '#ffffff',
      borderRadius: '8px',
      boxShadow: '0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1)'
    }}>
      <h1 style={{ margin: '0 0 8px 0', fontSize: '24px', color: '#0f172a' }}>Agent Configuration Settings</h1>
      <p style={{ margin: '0 0 24px 0', fontSize: '14px', color: '#64748b' }}>Configure extension attributes and endpoints.</p>
      
      <hr style={{ border: '0', borderTop: '1px solid #e2e8f0', margin: '0 0 24px 0' }} />
      
      <div style={{ padding: '40px 0', textAlign: 'center', color: '#94a3b8' }}>
        <p style={{ margin: 0, fontSize: '15px' }}>Settings Dashboard Placeholder</p>
        <p style={{ margin: '8px 0 0 0', fontSize: '13px' }}>Business rules and configurations will be loaded here.</p>
      </div>
    </div>
  );
};

export default App;
