import React, { useState } from 'react';

interface RevenueEntry {
  date: string;
  revenue: string | number;
}

interface RevenueChartProps {
  data: RevenueEntry[];
}

const RevenueChart: React.FC<RevenueChartProps> = ({ data }) => {
  const [hoveredIndex, setHoveredIndex] = useState<number | null>(null);

  // If no data, render placeholder
  if (!data || data.length === 0) {
    return (
      <div className="dashboard-card" style={{ height: '320px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <p className="text-muted">Không có dữ liệu biểu đồ</p>
      </div>
    );
  }

  // Parse numeric values
  const parsedData = data.map((d) => ({
    date: d.date,
    revenue: typeof d.revenue === 'string' ? parseFloat(d.revenue) : d.revenue,
  }));

  const values = parsedData.map((d) => d.revenue);
  const maxVal = Math.max(...values, 1000000); // minimum scale limit

  // Chart layout dimensions
  const width = 600;
  const height = 220;
  const paddingLeft = 60;
  const paddingRight = 20;
  const paddingTop = 20;
  const paddingBottom = 30;

  const chartWidth = width - paddingLeft - paddingRight;
  const chartHeight = height - paddingTop - paddingBottom;

  // Map to points
  const points = parsedData.map((d, i) => {
    const x = paddingLeft + (i / (parsedData.length - 1)) * chartWidth;
    const y = paddingTop + chartHeight - (d.revenue / maxVal) * chartHeight;
    return { x, y, date: d.date, revenue: d.revenue };
  });

  // Generate SVG path for the stroke line
  const pathData = points.reduce((acc, p, i) => {
    return acc + (i === 0 ? `M ${p.x} ${p.y}` : ` L ${p.x} ${p.y}`);
  }, '');

  // Generate SVG path for the gradient area fill underneath the line
  const areaData = points.length > 0
    ? `${pathData} L ${points[points.length - 1].x} ${paddingTop + chartHeight} L ${points[0].x} ${paddingTop + chartHeight} Z`
    : '';

  // Format Y-axis ticks
  const formatYLabel = (val: number) => {
    if (val >= 1000000) return `${(val / 1000000).toFixed(1)}M`;
    if (val >= 1000) return `${(val / 1000).toFixed(0)}k`;
    return val.toString();
  };

  const yTicks = [0, maxVal * 0.25, maxVal * 0.5, maxVal * 0.75, maxVal];

  // Helper to format currency inside tooltip
  const formatCurrency = (val: number) => {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(val);
  };

  return (
    <div className="dashboard-card">
      <div className="card-header">
        <span className="card-title" style={{ fontSize: '1.1rem', fontWeight: 600 }}>Doanh thu 30 ngày qua (VND)</span>
      </div>

      <div className="chart-container">
        <svg className="chart-svg" viewBox={`0 0 ${width} ${height}`} preserveAspectRatio="none">
          <defs>
            {/* Smooth glowing gradient for the area chart */}
            <linearGradient id="chart-gradient-indigo" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stopColor="var(--primary)" stopOpacity="0.3" />
              <stop offset="100%" stopColor="var(--primary)" stopOpacity="0.0" />
            </linearGradient>
          </defs>

          {/* Grid lines */}
          {yTicks.map((tick, idx) => {
            const y = paddingTop + chartHeight - (tick / maxVal) * chartHeight;
            return (
              <g key={idx}>
                <line x1={paddingLeft} y1={y} x2={width - paddingRight} y2={y} className="chart-grid-line" />
                <text x={paddingLeft - 10} y={y + 4} textAnchor="end" className="chart-text">
                  {formatYLabel(tick)}
                </text>
              </g>
            );
          })}

          {/* Draw Area Fill */}
          <path d={areaData} className="chart-area" />

          {/* Draw Line Stroke */}
          <path d={pathData} className="chart-line" />

          {/* Draw Interactive Hover Dots & Vertical Guide Bars */}
          {points.map((p, i) => {
            // Draw x-axis dates for every 5th item to avoid overlap
            const showXLabel = i % 6 === 0 || i === points.length - 1;
            const xLabelDate = p.date.split('-').slice(1).join('/'); // Show MM/DD

            return (
              <g key={i}>
                {showXLabel && (
                  <text x={p.x} y={height - 10} textAnchor="middle" className="chart-text">
                    {xLabelDate}
                  </text>
                )}

                {/* Vertical interactive guide bar */}
                <rect
                  x={p.x - 6}
                  y={paddingTop}
                  width={12}
                  height={chartHeight}
                  fill="transparent"
                  style={{ cursor: 'pointer' }}
                  onMouseEnter={() => setHoveredIndex(i)}
                  onMouseLeave={() => setHoveredIndex(null)}
                />

                {/* Dot marker on hover */}
                {hoveredIndex === i && (
                  <>
                    <line
                      x1={p.x}
                      y1={paddingTop}
                      x2={p.x}
                      y2={paddingTop + chartHeight}
                      stroke="var(--primary)"
                      strokeWidth={1}
                      strokeDasharray="2,2"
                    />
                    <circle cx={p.x} cy={p.y} r={6} fill="var(--bg-primary)" stroke="var(--primary)" strokeWidth={3} />
                  </>
                )}
              </g>
            );
          })}
        </svg>

        {/* Display Floating Tooltip */}
        {hoveredIndex !== null && points[hoveredIndex] && (
          <div
            className="chart-tooltip"
            style={{
              display: 'block',
              left: `${((points[hoveredIndex].x - paddingLeft) / chartWidth) * 80 + 10}%`,
              top: '10px',
            }}
          >
            <strong>{points[hoveredIndex].date}</strong>
            <div style={{ color: 'var(--success)', marginTop: '2px' }}>
              {formatCurrency(points[hoveredIndex].revenue)}
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default RevenueChart;
