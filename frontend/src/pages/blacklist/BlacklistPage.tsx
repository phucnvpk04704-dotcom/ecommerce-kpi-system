import React, { useEffect, useState } from 'react';
import {
  getBlacklistEntries,
  createBlacklistEntry,
  deleteBlacklistEntry,
  findByPhone,
  evaluateRisk
} from '../../services/blacklistApi';
import type { BlacklistEntry, RiskLevel } from '../../services/blacklistApi';
import type { Platform } from '../../services/employeeApi';
import {
  Search,
  Plus,
  ShieldCheck,
  Trash2,
  Eye,
  X,
  Phone,
  AlertTriangle,
  RotateCcw,
  Sparkles,
  Loader
} from 'lucide-react';

const BlacklistPage: React.FC = () => {
  const [blacklist, setBlacklist] = useState<BlacklistEntry[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Search filter
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedRiskLevel, setSelectedRiskLevel] = useState<string>('All');
  const [phoneSearchTerm, setPhoneSearchTerm] = useState('');
  const [phoneSearchResult, setPhoneSearchResult] = useState<BlacklistEntry | null>(null);
  const [searchingPhone, setSearchingPhone] = useState(false);

  // Modal Visibility
  const [showAddModal, setShowAddModal] = useState(false);
  const [showDetailModal, setShowDetailModal] = useState(false);
  const [selectedEntry, setSelectedEntry] = useState<BlacklistEntry | null>(null);

  // Form states
  const [formError, setFormError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  const [addForm, setAddForm] = useState({
    customer_id: '',
    platform: 'Shopee' as Platform,
    customer_name: '',
    customer_phone: '',
    total_orders: 0,
    cancelled_orders: 0,
    returned_orders: 0,
    risk_score: 0,
    risk_level: 'Low' as RiskLevel
  });

  const fetchBlacklist = async () => {
    setLoading(true);
    setError(null);
    try {
      const list = await getBlacklistEntries(0, 1000);
      setBlacklist(list);
    } catch (err: any) {
      console.error(err);
      setError(err.response?.data?.detail || 'Không thể tải danh sách khách hàng bị hạn chế.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchBlacklist();
  }, []);

  // Search by phone using the API
  const handlePhoneSearch = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!phoneSearchTerm.trim()) return;

    setSearchingPhone(true);
    setPhoneSearchResult(null);
    setError(null);

    try {
      const result = await findByPhone(phoneSearchTerm.trim());
      setPhoneSearchResult(result);
    } catch (err: any) {
      console.error(err);
      alert(err.response?.data?.detail || 'Không tìm thấy hồ sơ cho số điện thoại này.');
    } finally {
      setSearchingPhone(false);
    }
  };

  // Trigger Backend Risk Evaluation
  const handleTriggerRiskEvaluate = async (entry: BlacklistEntry) => {
    if (!window.confirm(`Yêu cầu hệ thống phân tích rủi ro đơn hàng cho khách hàng ${entry.customer_name || entry.customer_id}?`)) {
      return;
    }

    setLoading(true);
    try {
      const updated = await evaluateRisk({
        customer_id: entry.customer_id,
        customer_phone: entry.customer_phone,
        platform: entry.platform
      });

      // Update state
      setBlacklist((prev) => prev.map((item) => (item.id === entry.id ? updated : item)));
      if (selectedEntry?.id === entry.id) {
        setSelectedEntry(updated);
      }
      alert(`Đánh giá rủi ro hoàn tất! Mức độ rủi ro mới: ${updated.risk_level} (Điểm: ${updated.risk_score}%)`);
    } catch (err: any) {
      console.error(err);
      alert(err.response?.data?.detail || 'Không thể thực hiện đánh giá rủi ro lúc này.');
    } finally {
      setLoading(false);
    }
  };

  const handleAddSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setFormError(null);
    setSubmitting(true);

    if (!addForm.customer_id.trim() || !addForm.customer_phone.trim()) {
      setFormError('ID khách hàng và số điện thoại là bắt buộc.');
      setSubmitting(false);
      return;
    }

    try {
      const newEntry = await createBlacklistEntry(addForm);
      setBlacklist([newEntry, ...blacklist]);
      setShowAddModal(false);
      // Reset form
      setAddForm({
        customer_id: '',
        platform: 'Shopee',
        customer_name: '',
        customer_phone: '',
        total_orders: 0,
        cancelled_orders: 0,
        returned_orders: 0,
        risk_score: 0,
        risk_level: 'Low'
      });
    } catch (err: any) {
      console.error(err);
      setFormError(err.response?.data?.detail || 'Lỗi xảy ra khi thêm khách hàng.');
    } finally {
      setSubmitting(false);
    }
  };

  const handleRemove = async (id: string) => {
    if (window.confirm('Bạn có chắc chắn muốn gỡ khách hàng này ra khỏi danh sách đen/hạn chế?')) {
      try {
        await deleteBlacklistEntry(id);
        setBlacklist((prev) => prev.filter((item) => item.id !== id));
        if (phoneSearchResult?.id === id) {
          setPhoneSearchResult(null);
        }
        setShowDetailModal(false);
      } catch (err: any) {
        console.error(err);
        alert(err.response?.data?.detail || 'Không thể xóa bản ghi blacklist.');
      }
    }
  };

  const openDetailModal = (entry: BlacklistEntry) => {
    setSelectedEntry(entry);
    setShowDetailModal(true);
  };

  const filteredBlacklist = blacklist.filter((item) => {
    const term = searchQuery.toLowerCase();
    const matchSearch =
      item.customer_id.toLowerCase().includes(term) ||
      (item.customer_name || '').toLowerCase().includes(term) ||
      item.customer_phone.includes(term);

    const matchRisk = selectedRiskLevel === 'All' || item.risk_level === selectedRiskLevel;

    return matchSearch && matchRisk;
  });

  const getRiskColor = (level: RiskLevel) => {
    switch (level) {
      case 'Blacklist':
        return 'var(--danger)';
      case 'High':
        return 'var(--warning)';
      case 'Medium':
        return 'var(--info)';
      default:
        return 'var(--success)';
    }
  };

  const getRiskBg = (level: RiskLevel) => {
    switch (level) {
      case 'Blacklist':
        return 'var(--danger-light)';
      case 'High':
        return 'var(--warning-light)';
      case 'Medium':
        return 'var(--info-light)';
      default:
        return 'var(--success-light)';
    }
  };

  const formatDate = (dateStr?: string) => {
    if (!dateStr) return 'Chưa ghi nhận';
    return new Date(dateStr).toLocaleDateString('vi-VN', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      
      {/* Title & Top button */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h2 style={{ fontSize: '1.5rem', fontWeight: 700 }}>Hạn Chế Khách Hàng (Blacklist)</h2>
          <p style={{ fontSize: '0.875rem', color: 'var(--text-secondary)' }}>
            Theo dõi hành vi gian lận đơn hàng, tỉ lệ hủy/trả bất thường và cấu hình mức độ rủi ro khách hàng.
          </p>
        </div>
        <button
          className="retry-btn"
          style={{ display: 'flex', alignItems: 'center', gap: '8px' }}
          onClick={() => {
            setFormError(null);
            setShowAddModal(true);
          }}
        >
          <Plus size={16} /> Thêm Khách Hàng Hạn Chế
        </button>
      </div>

      {/* Lookup Bar & Search Phone */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px' }}>
        
        {/* Phone Search Tool */}
        <div className="dashboard-card" style={{ padding: '16px' }}>
          <span className="card-title" style={{ fontSize: '0.9rem', marginBottom: '12px', display: 'block' }}>
            <Phone size={14} style={{ display: 'inline', marginRight: '4px', verticalAlign: 'text-bottom' }} /> Tra cứu nhanh số điện thoại (API Direct)
          </span>
          <form onSubmit={handlePhoneSearch} style={{ display: 'flex', gap: '10px' }}>
            <input
              type="text"
              className="form-input"
              placeholder="Nhập số điện thoại cần tra cứu..."
              value={phoneSearchTerm}
              onChange={(e) => setPhoneSearchTerm(e.target.value)}
              style={{ flex: 1 }}
              required
            />
            <button
              type="submit"
              className="retry-btn"
              disabled={searchingPhone}
              style={{ display: 'flex', alignItems: 'center', gap: '6px' }}
            >
              {searchingPhone ? 'Đang tra...' : 'Tìm kiếm'}
            </button>
          </form>
          
          {phoneSearchResult && (
            <div
              style={{
                marginTop: '12px',
                padding: '12px',
                backgroundColor: 'rgba(255,255,255,0.02)',
                border: '1px solid var(--border-color)',
                borderRadius: '8px',
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center'
              }}
            >
              <div>
                <strong style={{ fontSize: '0.9rem' }}>{phoneSearchResult.customer_name || 'Khách ẩn'}</strong>
                <div style={{ fontSize: '0.75rem', color: 'var(--text-secondary)', marginTop: '2px' }}>
                  ID: {phoneSearchResult.customer_id} · SĐT: {phoneSearchResult.customer_phone}
                </div>
              </div>
              <div style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
                <span
                  style={{
                    backgroundColor: getRiskBg(phoneSearchResult.risk_level),
                    color: getRiskColor(phoneSearchResult.risk_level),
                    fontSize: '0.75rem',
                    fontWeight: 700,
                    padding: '3px 8px',
                    borderRadius: '4px'
                  }}
                >
                  {phoneSearchResult.risk_level}
                </span>
                <button
                  className="retry-btn"
                  style={{ padding: '4px 8px', fontSize: '0.75rem', backgroundColor: 'var(--bg-tertiary)' }}
                  onClick={() => openDetailModal(phoneSearchResult)}
                >
                  Xem
                </button>
                <button
                  onClick={() => setPhoneSearchResult(null)}
                  style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer' }}
                >
                  <RotateCcw size={14} />
                </button>
              </div>
            </div>
          )}
        </div>

        {/* Directory filter */}
        <div className="dashboard-card" style={{ padding: '16px', display: 'flex', gap: '16px', alignItems: 'flex-end' }}>
          <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
            <label style={{ fontSize: '0.75rem', fontWeight: 600, color: 'var(--text-secondary)' }}>Tìm trong danh bạ</label>
            <div style={{ position: 'relative' }}>
              <Search
                size={14}
                style={{ position: 'absolute', left: '10px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }}
              />
              <input
                type="text"
                className="form-input"
                placeholder="Tìm ID, Tên, Số điện thoại..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                style={{ width: '100%', paddingLeft: '32px' }}
              />
            </div>
          </div>
          <div className="form-group" style={{ width: '140px', marginBottom: 0 }}>
            <label style={{ fontSize: '0.75rem', fontWeight: 600, color: 'var(--text-secondary)' }}>Mức rủi ro</label>
            <select
              className="form-input"
              value={selectedRiskLevel}
              onChange={(e) => setSelectedRiskLevel(e.target.value)}
            >
              <option value="All">Tất cả</option>
              <option value="Low">Low</option>
              <option value="Medium">Medium</option>
              <option value="High">High</option>
              <option value="Blacklist">Blacklist</option>
            </select>
          </div>
        </div>

      </div>

      {/* Blacklist table */}
      {loading && blacklist.length === 0 ? (
        <div className="loading-overlay" style={{ minHeight: '260px' }}>
          <div className="spinner"></div>
          <p className="text-secondary">Đang tải danh sách đen...</p>
        </div>
      ) : error ? (
        <div className="error-container" style={{ padding: '24px' }}>
          <div className="error-message">{error}</div>
          <button className="retry-btn" onClick={fetchBlacklist}>Thử lại</button>
        </div>
      ) : filteredBlacklist.length === 0 ? (
        <div className="dashboard-card" style={{ textAlign: 'center', padding: '60px 16px' }}>
          <p style={{ color: 'var(--text-secondary)', fontWeight: 500 }}>Không tìm thấy khách hàng hạn chế nào khớp</p>
          <p style={{ color: 'var(--text-muted)', fontSize: '0.85rem', marginTop: '6px' }}>
            Vui lòng thay đổi từ khóa tìm kiếm hoặc mức độ rủi ro cần lọc.
          </p>
        </div>
      ) : (
        <div className="dashboard-card" style={{ padding: '0px', overflowX: 'auto' }}>
          <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left', fontSize: '0.875rem' }}>
            <thead>
              <tr style={{ borderBottom: '1px solid var(--border-color)', color: 'var(--text-secondary)', fontWeight: 600 }}>
                <th style={{ padding: '16px' }}>Khách Hàng ID</th>
                <th style={{ padding: '16px' }}>Tên Khách Hàng</th>
                <th style={{ padding: '16px' }}>Số Điện Thoại</th>
                <th style={{ padding: '16px' }}>Kênh Mua</th>
                <th style={{ padding: '16px', textAlign: 'right' }}>Mức Độ Rủi Ro</th>
                <th style={{ padding: '16px', textAlign: 'right' }}>Lý Do Cụ Thể (Hủy/Trả)</th>
                <th style={{ padding: '16px' }}>Ngày Cập Nhật</th>
                <th style={{ padding: '16px', textAlign: 'right' }}>Hành Động</th>
              </tr>
            </thead>
            <tbody>
              {filteredBlacklist.map((item) => {
                const cancelRate = item.total_orders > 0 ? (item.cancelled_orders / item.total_orders) * 100 : 0;
                
                // Reason string summarizing stats
                const reasonSummary = `Tỉ lệ hủy đơn ${cancelRate.toFixed(0)}% (${item.cancelled_orders}/${item.total_orders} đơn), trả hàng ${item.returned_orders} đơn`;

                return (
                  <tr key={item.id} style={{ borderBottom: '1px solid var(--border-color)' }} className="table-row-hover">
                    <td style={{ padding: '16px', fontWeight: 600 }}>{item.customer_id}</td>
                    <td style={{ padding: '16px', fontWeight: 500 }}>{item.customer_name || 'Khách hàng ẩn'}</td>
                    <td style={{ padding: '16px', fontFamily: 'monospace' }}>{item.customer_phone}</td>
                    <td style={{ padding: '16px' }}>
                      <span style={{ backgroundColor: 'rgba(255,255,255,0.03)', border: '1px solid var(--border-color)', padding: '2px 6px', borderRadius: '4px', fontSize: '0.75rem' }}>
                        {item.platform}
                      </span>
                    </td>
                    <td style={{ padding: '16px', textAlign: 'right' }}>
                      <span
                        style={{
                          backgroundColor: getRiskBg(item.risk_level),
                          color: getRiskColor(item.risk_level),
                          fontSize: '0.7rem',
                          fontWeight: 700,
                          padding: '3px 8px',
                          borderRadius: '4px',
                          textTransform: 'uppercase'
                        }}
                      >
                        {item.risk_level}
                      </span>
                    </td>
                    <td style={{ padding: '16px', textAlign: 'right', fontSize: '0.8rem', color: 'var(--text-secondary)' }}>
                      {reasonSummary}
                    </td>
                    <td style={{ padding: '16px', color: 'var(--text-muted)' }}>
                      {formatDate(item.updated_at)}
                    </td>
                    <td style={{ padding: '16px', textAlign: 'right' }}>
                      <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px' }}>
                        <button
                          title="Phân tích rủi ro qua AI"
                          style={{ background: 'none', border: 'none', color: 'var(--info)', cursor: 'pointer', padding: '4px' }}
                          onClick={() => handleTriggerRiskEvaluate(item)}
                        >
                          <Sparkles size={16} />
                        </button>
                        <button
                          title="Xem chi tiết"
                          style={{ background: 'none', border: 'none', color: 'var(--text-secondary)', cursor: 'pointer', padding: '4px' }}
                          onClick={() => openDetailModal(item)}
                        >
                          <Eye size={16} />
                        </button>
                        <button
                          title="Khôi phục trạng thái"
                          style={{ background: 'none', border: 'none', color: 'var(--danger)', cursor: 'pointer', padding: '4px' }}
                          onClick={() => handleRemove(item.id)}
                        >
                          <Trash2 size={16} />
                        </button>
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}

      {/* ADD MODAL */}
      {showAddModal && (
        <div className="modal-backdrop" style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, backgroundColor: 'rgba(0,0,0,0.6)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000 }}>
          <div className="dashboard-card" style={{ width: '100%', maxWidth: '500px', padding: '24px', backgroundColor: 'var(--bg-secondary)', animation: 'fadeIn 0.3s ease-out', position: 'relative' }}>
            <button
              onClick={() => setShowAddModal(false)}
              style={{ position: 'absolute', top: '16px', right: '16px', background: 'none', border: 'none', color: 'var(--text-secondary)', cursor: 'pointer' }}
            >
              <X size={20} />
            </button>
            <h3 style={{ fontSize: '1.25rem', fontWeight: 700, marginBottom: '16px' }}>Thêm Khách Hàng Bị Hạn Chế</h3>

            {formError && (
              <div style={{ color: 'var(--danger)', fontSize: '0.8rem', backgroundColor: 'var(--danger-light)', padding: '10px', borderRadius: '4px', marginBottom: '16px', border: '1px solid rgba(239, 68, 68, 0.2)' }}>
                {formError}
              </div>
            )}

            <form onSubmit={handleAddSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
              <div className="form-group">
                <label>Mã Khách Hàng (Customer ID) *</label>
                <input
                  type="text"
                  className="form-input"
                  required
                  placeholder="Ví dụ: CUST-1002"
                  value={addForm.customer_id}
                  onChange={(e) => setAddForm({ ...addForm, customer_id: e.target.value })}
                />
              </div>

              <div className="form-group">
                <label>Họ Tên Khách Hàng</label>
                <input
                  type="text"
                  className="form-input"
                  placeholder="Nhập họ tên (nếu có)"
                  value={addForm.customer_name}
                  onChange={(e) => setAddForm({ ...addForm, customer_name: e.target.value })}
                />
              </div>

              <div className="form-group">
                <label>Số Điện Thoại Khách Hàng *</label>
                <input
                  type="text"
                  className="form-input"
                  required
                  placeholder="Nhập số điện thoại liên lạc"
                  value={addForm.customer_phone}
                  onChange={(e) => setAddForm({ ...addForm, customer_phone: e.target.value })}
                />
              </div>

              <div style={{ display: 'flex', gap: '12px' }}>
                <div className="form-group" style={{ flex: 1 }}>
                  <label>Kênh Thương Mại</label>
                  <select
                    className="form-input"
                    value={addForm.platform}
                    onChange={(e) => setAddForm({ ...addForm, platform: e.target.value as Platform })}
                  >
                    <option value="Shopee">Shopee</option>
                    <option value="Lazada">Lazada</option>
                    <option value="TikTok Shop">TikTok Shop</option>
                    <option value="Tiki">Tiki</option>
                  </select>
                </div>
                <div className="form-group" style={{ flex: 1 }}>
                  <label>Mức Độ Rủi Ro</label>
                  <select
                    className="form-input"
                    value={addForm.risk_level}
                    onChange={(e) => setAddForm({ ...addForm, risk_level: e.target.value as RiskLevel })}
                  >
                    <option value="Low">Low (Thấp)</option>
                    <option value="Medium">Medium (Vừa)</option>
                    <option value="High">High (Cao)</option>
                    <option value="Blacklist">Blacklist (Khóa hẳn)</option>
                  </select>
                </div>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: '10px' }}>
                <div className="form-group">
                  <label style={{ fontSize: '0.65rem' }}>Tổng Số Đơn</label>
                  <input
                    type="number"
                    min={0}
                    className="form-input"
                    value={addForm.total_orders}
                    onChange={(e) => setAddForm({ ...addForm, total_orders: parseInt(e.target.value) || 0 })}
                  />
                </div>
                <div className="form-group">
                  <label style={{ fontSize: '0.65rem' }}>Hủy Đơn</label>
                  <input
                    type="number"
                    min={0}
                    className="form-input"
                    value={addForm.cancelled_orders}
                    onChange={(e) => setAddForm({ ...addForm, cancelled_orders: parseInt(e.target.value) || 0 })}
                  />
                </div>
                <div className="form-group">
                  <label style={{ fontSize: '0.65rem' }}>Trả Hàng</label>
                  <input
                    type="number"
                    min={0}
                    className="form-input"
                    value={addForm.returned_orders}
                    onChange={(e) => setAddForm({ ...addForm, returned_orders: parseInt(e.target.value) || 0 })}
                  />
                </div>
              </div>

              <div className="form-group">
                <label>Điểm rủi ro (Risk Score %): {addForm.risk_score}%</label>
                <input
                  type="range"
                  min="0"
                  max="100"
                  style={{ accentColor: 'var(--primary)', cursor: 'pointer' }}
                  value={addForm.risk_score}
                  onChange={(e) => setAddForm({ ...addForm, risk_score: parseInt(e.target.value) || 0 })}
                />
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px', marginTop: '16px' }}>
                <button
                  type="button"
                  className="retry-btn"
                  style={{ backgroundColor: 'transparent', border: '1px solid var(--border-color)', color: 'var(--text-primary)' }}
                  onClick={() => setShowAddModal(false)}
                >
                  Hủy
                </button>
                <button
                  type="submit"
                  className="retry-btn"
                  disabled={submitting}
                  style={{ display: 'flex', alignItems: 'center', gap: '8px' }}
                >
                  {submitting && <Loader size={14} className="animate-spin" />}
                  Lưu hồ sơ
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* DETAIL MODAL */}
      {showDetailModal && selectedEntry && (
        <div className="modal-backdrop" style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, backgroundColor: 'rgba(0,0,0,0.6)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000 }}>
          <div className="dashboard-card" style={{ width: '100%', maxWidth: '500px', padding: '24px', backgroundColor: 'var(--bg-secondary)', animation: 'fadeIn 0.3s ease-out', position: 'relative' }}>
            <button
              onClick={() => setShowDetailModal(false)}
              style={{ position: 'absolute', top: '16px', right: '16px', background: 'none', border: 'none', color: 'var(--text-secondary)', cursor: 'pointer' }}
            >
              <X size={20} />
            </button>
            <h3 style={{ fontSize: '1.25rem', fontWeight: 700, marginBottom: '20px' }}>Hồ Sơ Rủi Ro Khách Hàng</h3>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              
              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '12px',
                  backgroundColor: getRiskBg(selectedEntry.risk_level),
                  border: `1px solid ${getRiskColor(selectedEntry.risk_level)}`,
                  padding: '16px',
                  borderRadius: '12px'
                }}
              >
                <AlertTriangle size={24} style={{ color: getRiskColor(selectedEntry.risk_level) }} />
                <div>
                  <h4 style={{ fontWeight: 700, color: 'var(--text-primary)' }}>Phân Lớp: {selectedEntry.risk_level}</h4>
                  <p style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>Điểm số rủi ro tích hợp: {selectedEntry.risk_score}%</p>
                </div>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px', fontSize: '0.875rem' }}>
                <div>
                  <div style={{ color: 'var(--text-muted)', fontSize: '0.75rem', fontWeight: 600, textTransform: 'uppercase', marginBottom: '4px' }}>Tên Khách Hàng</div>
                  <div style={{ fontWeight: 500 }}>{selectedEntry.customer_name || 'Khách hàng ẩn'}</div>
                </div>
                <div>
                  <div style={{ color: 'var(--text-muted)', fontSize: '0.75rem', fontWeight: 600, textTransform: 'uppercase', marginBottom: '4px' }}>Số Điện Thoại</div>
                  <div style={{ fontWeight: 500, fontFamily: 'monospace' }}>{selectedEntry.customer_phone}</div>
                </div>
                <div>
                  <div style={{ color: 'var(--text-muted)', fontSize: '0.75rem', fontWeight: 600, textTransform: 'uppercase', marginBottom: '4px' }}>Khách Hàng ID</div>
                  <div style={{ fontWeight: 500 }}>{selectedEntry.customer_id}</div>
                </div>
                <div>
                  <div style={{ color: 'var(--text-muted)', fontSize: '0.75rem', fontWeight: 600, textTransform: 'uppercase', marginBottom: '4px' }}>Kênh Giao Dịch</div>
                  <div style={{ fontWeight: 500 }}>{selectedEntry.platform}</div>
                </div>
              </div>

              <div style={{ borderTop: '1px solid var(--border-color)', paddingTop: '16px', marginTop: '8px' }}>
                <div style={{ color: 'var(--text-muted)', fontSize: '0.75rem', fontWeight: 600, textTransform: 'uppercase', marginBottom: '12px' }}>Chỉ Số Lịch Sử Đơn Hàng</div>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: '12px', textAlign: 'center' }}>
                  
                  <div style={{ backgroundColor: 'rgba(255,255,255,0.02)', padding: '12px', borderRadius: '8px', border: '1px solid var(--border-color)' }}>
                    <div style={{ fontSize: '1.25rem', fontWeight: 700 }}>{selectedEntry.total_orders}</div>
                    <div style={{ fontSize: '0.7rem', color: 'var(--text-muted)', marginTop: '2px' }}>TỔNG ĐƠN</div>
                  </div>

                  <div style={{ backgroundColor: 'rgba(239, 68, 68, 0.05)', padding: '12px', borderRadius: '8px', border: '1px solid rgba(239, 68, 68, 0.15)' }}>
                    <div style={{ fontSize: '1.25rem', fontWeight: 700, color: 'var(--danger)' }}>{selectedEntry.cancelled_orders}</div>
                    <div style={{ fontSize: '0.7rem', color: 'var(--danger)', marginTop: '2px' }}>ĐƠN HỦY</div>
                  </div>

                  <div style={{ backgroundColor: 'rgba(245, 158, 11, 0.05)', padding: '12px', borderRadius: '8px', border: '1px solid rgba(245, 158, 11, 0.15)' }}>
                    <div style={{ fontSize: '1.25rem', fontWeight: 700, color: 'var(--warning)' }}>{selectedEntry.returned_orders}</div>
                    <div style={{ fontSize: '0.7rem', color: 'var(--warning)', marginTop: '2px' }}>ĐƠN TRẢ</div>
                  </div>

                </div>
              </div>

              <div style={{ borderTop: '1px solid var(--border-color)', paddingTop: '16px', fontSize: '0.8rem', color: 'var(--text-muted)' }}>
                <div>Ngày đưa vào danh sách đen: {formatDate(selectedEntry.added_at)}</div>
                <div style={{ marginTop: '4px' }}>Đơn hàng cuối cùng ghi nhận: {formatDate(selectedEntry.last_order_at)}</div>
              </div>

              <div style={{ display: 'flex', gap: '12px', marginTop: '16px' }}>
                <button
                  type="button"
                  className="retry-btn"
                  style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px' }}
                  onClick={() => handleTriggerRiskEvaluate(selectedEntry)}
                >
                  <Sparkles size={14} /> Chạy Lại AI Analyze
                </button>
                <button
                  type="button"
                  className="retry-btn"
                  style={{ flex: 1, backgroundColor: 'var(--danger)', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px' }}
                  onClick={() => handleRemove(selectedEntry.id)}
                >
                  <ShieldCheck size={14} /> Gỡ Khỏi Danh Sách
                </button>
              </div>

            </div>
          </div>
        </div>
      )}

    </div>
  );
};

export default BlacklistPage;
