import React, { useState } from 'react';

interface OrdersEntry {
  date: string;
  order_count: number;
}

interface OrdersChartProps {
  data: OrdersEntry[];
}

const OrdersChart: React.FC<OrdersChartProps> = ({ data }) => {
  const [hoveredIndex, setHoveredIndex] = useState<number | null>(null);

  if (!data || data.length === 0) {
    return (
      <div className="dashboard-card" style={{ height: '320px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <p className="text-muted">Không có dữ liệu biểu đồ</p>
      </div>
    );
  }

  const values = data.map((d) => d.order_count);
  const maxVal = Math.max(...values, 10); // minimum scale limit of 10 orders

  // Chart layout dimensions
  const width = 600;
  const height = 220;
  const paddingLeft = 50;
  const paddingRight = 20;
  const paddingTop = 20;
  const paddingBottom = 30;

  const chartWidth = width - paddingLeft - paddingRight;
  const chartHeight = height - paddingTop - paddingBottom;

  const barStep = chartWidth / data.length;
  const barGapRatio = 0.3; // 30% gap
  const barWidth = barStep * (1 - barGapRatio);

  const yTicks = [0, Math.ceil(maxVal * 0.25), Math.ceil(maxVal * 0.5), Math.ceil(maxVal * 0.75), maxVal];

  return (
    <div className="dashboard-card">
      <div className="card-header">
        <span className="card-title" style={{ fontSize: '1.1rem', fontWeight: 600 }}>Sản lượng đơn hàng 30 ngày qua (Đơn)</span>
      </div>

      <div className="chart-container">
        <svg className="chart-svg" viewBox={`0 0 ${width} ${height}`} preserveAspectRatio="none">
          <defs>
            {/* Glowing bar gradient from cyan to dark blue */}
            <linearGradient id="bar-gradient-cyan" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stopColor="var(--info)" />
              <stop offset="100%" stopColor="var(--primary)" stopOpacity="0.3" />
            </linearGradient>
          </defs>

          {/* Grid lines */}
          {yTicks.map((tick, idx) => {
            const y = paddingTop + chartHeight - (tick / maxVal) * chartHeight;
            return (
              <g key={idx}>
                <line x1={paddingLeft} y1={y} x2={width - paddingRight} y2={y} className="chart-grid-line" />
                <text x={paddingLeft - 10} y={y + 4} textAnchor="end" className="chart-text">
                  {tick}
                </text>
              </g>
            );
          })}

          {/* Draw Bars */}
          {data.map((d, i) => {
            const x = paddingLeft + i * barStep + (barStep * barGapRatio) / 2;
            const barHeight = (d.order_count / maxVal) * chartHeight;
            const y = paddingTop + chartHeight - barHeight;

            // X-axis label display rule (every 5th date)
            const showXLabel = i % 6 === 0 || i === data.length - 1;
            const xLabelDate = d.date.split('-').slice(1).join('/'); // Show MM/DD

            const isHovered = hoveredIndex === i;

            return (
              <g key={i}>
                {/* Bar rectangle */}
                <rect
                  x={x}
                  y={y}
                  width={barWidth}
                  height={Math.max(barHeight, 2)} // ensure at least 2px height for visual feedback
                  rx={3} // rounded corners
                  fill={isHovered ? 'var(--info)' : 'url(#bar-gradient-cyan)'}
                  style={{ transition: 'fill 0.15s ease', cursor: 'pointer' }}
                  onMouseEnter={() => setHoveredIndex(i)}
                  onMouseLeave={() => setHoveredIndex(null)}
                />

                {/* X Axis dates */}
                {showXLabel && (
                  <text x={x + barWidth / 2} y={height - 10} textAnchor="middle" className="chart-text">
                    {xLabelDate}
                  </text>
                )}
              </g>
            );
          })}
        </svg>

        {/* Display Floating Tooltip */}
        {hoveredIndex !== null && data[hoveredIndex] && (
          <div
            className="chart-tooltip"
            style={{
              display: 'block',
              left: `${((hoveredIndex * barStep + paddingLeft) / width) * 80 + 10}%`,
              top: '10px',
            }}
          >
            <strong>{data[hoveredIndex].date}</strong>
            <div style={{ color: 'var(--info)', marginTop: '2px', fontWeight: 600 }}>
              {data[hoveredIndex].order_count} đơn hàng
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default OrdersChart;
