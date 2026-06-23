import React, { useEffect, useState } from 'react';
import { useEmployeeStore } from '../../store/employeeStore';
import type { Role, EmployeeStatus, Platform } from '../../services/employeeApi';
import { Search, Plus, UserCheck, UserX, Edit2, Trash2, Eye, X, Loader } from 'lucide-react';

const EmployeesPage: React.FC = () => {
  const {
    employees,
    loading,
    error,
    searchQuery,
    statusFilter,
    fetchEmployees,
    setSearchQuery,
    setStatusFilter,
    addEmployee,
    editEmployee,
    deactivateEmployee
  } = useEmployeeStore();

  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 8;

  // Modals visibility states
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [showEditModal, setShowEditModal] = useState(false);
  const [showDetailModal, setShowDetailModal] = useState(false);
  
  // Selected employee for Edit/Detail views
  const [selectedEmp, setSelectedEmp] = useState<any>(null);

  // Form states
  const [formError, setFormError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  // Create Form values
  const [createForm, setCreateForm] = useState({
    username: '',
    full_name: '',
    email: '',
    password: '',
    role: 'Employee' as Role,
    platforms: [] as Platform[]
  });

  // Edit Form values
  const [editForm, setEditForm] = useState({
    full_name: '',
    email: '',
    role: 'Employee' as Role,
    status: 'Active' as EmployeeStatus,
    platforms: [] as Platform[]
  });

  useEffect(() => {
    fetchEmployees();
  }, [fetchEmployees]);

  // Handle page resets when filters change
  useEffect(() => {
    setCurrentPage(1);
  }, [searchQuery, statusFilter]);

  // Filtered employees list
  const filteredEmployees = employees.filter((emp) => {
    const matchesSearch =
      emp.full_name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      emp.username.toLowerCase().includes(searchQuery.toLowerCase()) ||
      emp.email.toLowerCase().includes(searchQuery.toLowerCase()) ||
      emp.employee_code.toLowerCase().includes(searchQuery.toLowerCase());

    const matchesStatus =
      statusFilter === 'All' || emp.status === statusFilter;

    return matchesSearch && matchesStatus;
  });

  // Paginated employees
  const totalPages = Math.ceil(filteredEmployees.length / itemsPerPage);
  const paginatedEmployees = filteredEmployees.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage
  );

  const handlePlatformCheckboxChange = (
    platform: Platform,
    isCreate: boolean,
    checked: boolean
  ) => {
    if (isCreate) {
      if (checked) {
        setCreateForm((prev) => ({ ...prev, platforms: [...prev.platforms, platform] }));
      } else {
        setCreateForm((prev) => ({
          ...prev,
          platforms: prev.platforms.filter((p) => p !== platform)
        }));
      }
    } else {
      if (checked) {
        setEditForm((prev) => ({ ...prev, platforms: [...prev.platforms, platform] }));
      } else {
        setEditForm((prev) => ({
          ...prev,
          platforms: prev.platforms.filter((p) => p !== platform)
        }));
      }
    }
  };

  const handleCreateSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setFormError(null);
    setSubmitting(true);

    if (!createForm.username.trim() || !createForm.full_name.trim() || !createForm.email.trim() || !createForm.password) {
      setFormError('Vui lòng điền đầy đủ các thông tin bắt buộc.');
      setSubmitting(false);
      return;
    }

    try {
      await addEmployee(createForm);
      setShowCreateModal(false);
      // Reset form
      setCreateForm({
        username: '',
        full_name: '',
        email: '',
        password: '',
        role: 'Employee',
        platforms: []
      });
    } catch (err: any) {
      setFormError(err.message || 'Lỗi xảy ra khi tạo tài khoản nhân viên.');
    } finally {
      setSubmitting(false);
    }
  };

  const handleEditSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedEmp) return;
    setFormError(null);
    setSubmitting(true);

    if (!editForm.full_name.trim() || !editForm.email.trim()) {
      setFormError('Họ tên và email không được bỏ trống.');
      setSubmitting(false);
      return;
    }

    try {
      await editEmployee(selectedEmp.id, editForm);
      setShowEditModal(false);
    } catch (err: any) {
      setFormError(err.message || 'Lỗi xảy ra khi cập nhật thông tin.');
    } finally {
      setSubmitting(false);
    }
  };

  const openEditModal = (emp: any) => {
    setSelectedEmp(emp);
    setEditForm({
      full_name: emp.full_name,
      email: emp.email,
      role: emp.role,
      status: emp.status,
      platforms: emp.platforms || []
    });
    setFormError(null);
    setShowEditModal(true);
  };

  const openDetailModal = (emp: any) => {
    setSelectedEmp(emp);
    setShowDetailModal(true);
  };

  const handleDeactivate = async (id: string) => {
    if (window.confirm('Bạn có chắc chắn muốn vô hiệu hóa tài khoản nhân viên này? (Trạng thái chuyển sang Inactive)')) {
      try {
        await deactivateEmployee(id);
      } catch (err: any) {
        alert(err.message || 'Không thể vô hiệu hóa nhân viên.');
      }
    }
  };

  const formatDate = (dateStr: string) => {
    return new Date(dateStr).toLocaleDateString('vi-VN', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const availablePlatforms: Platform[] = ['Shopee', 'Lazada', 'TikTok Shop', 'Tiki', 'All'];

  return (
    <div className="employees-container animate-fade-in" style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      
      {/* Title & Actions */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h2 style={{ fontSize: '1.5rem', fontWeight: 700 }}>Danh Sách Nhân Viên</h2>
          <p style={{ fontSize: '0.875rem', color: 'var(--text-secondary)' }}>
            Quản lý tài khoản, phân quyền và giám sát hoạt động của nhân viên bán hàng.
          </p>
        </div>
        <button
          className="retry-btn"
          style={{ display: 'flex', alignItems: 'center', gap: '8px', padding: '8px 16px' }}
          onClick={() => {
            setFormError(null);
            setShowCreateModal(true);
          }}
        >
          <Plus size={16} /> Thêm Nhân Viên
        </button>
      </div>

      {/* Filters Bar */}
      <div className="dashboard-card" style={{ padding: '16px', display: 'flex', gap: '16px', flexWrap: 'wrap', alignItems: 'center' }}>
        <div style={{ position: 'relative', flex: 1, minWidth: '240px' }}>
          <Search
            size={16}
            style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }}
          />
          <input
            type="text"
            className="form-input"
            placeholder="Tìm kiếm theo mã, họ tên, email hoặc tài khoản..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            style={{ width: '100%', paddingLeft: '36px' }}
          />
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          <label style={{ fontSize: '0.8rem', color: 'var(--text-secondary)', fontWeight: 600 }}>TRẠNG THÁI</label>
          <select
            className="form-input"
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value as any)}
            style={{ padding: '8px 12px', minWidth: '120px' }}
          >
            <option value="All">Tất cả</option>
            <option value="Active">Đang Hoạt Động</option>
            <option value="Inactive">Ngừng Hoạt Động</option>
          </select>
        </div>
      </div>

      {/* Error block */}
      {error && (
        <div className="error-container" style={{ minHeight: 'auto', padding: '16px' }}>
          <div className="error-message">{error}</div>
          <button className="retry-btn" onClick={fetchEmployees}>Tải lại</button>
        </div>
      )}

      {/* Main Table */}
      {loading && filteredEmployees.length === 0 ? (
        <div className="loading-overlay" style={{ minHeight: '300px' }}>
          <div className="spinner"></div>
          <p className="text-secondary">Đang tải dữ liệu nhân viên...</p>
        </div>
      ) : filteredEmployees.length === 0 ? (
        <div className="dashboard-card" style={{ textAlign: 'center', padding: '48px 16px', color: 'var(--text-secondary)' }}>
          <p style={{ fontSize: '1rem', fontWeight: 500 }}>Không tìm thấy nhân viên nào</p>
          <p style={{ fontSize: '0.85rem', color: 'var(--text-muted)', marginTop: '4px' }}>
            Thử thay đổi từ khóa tìm kiếm hoặc điều kiện lọc trạng thái.
          </p>
        </div>
      ) : (
        <div className="dashboard-card" style={{ padding: '0px', overflowX: 'auto', borderRadius: 'var(--radius-lg)' }}>
          <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left', fontSize: '0.875rem' }}>
            <thead>
              <tr style={{ borderBottom: '1px solid var(--border-color)', color: 'var(--text-secondary)', fontWeight: 600 }}>
                <th style={{ padding: '16px' }}>Mã NV</th>
                <th style={{ padding: '16px' }}>Họ Tên / Username</th>
                <th style={{ padding: '16px' }}>Email</th>
                <th style={{ padding: '16px' }}>Vai Trò</th>
                <th style={{ padding: '16px' }}>Kênh Phụ Trách</th>
                <th style={{ padding: '16px' }}>Trạng Thái</th>
                <th style={{ padding: '16px' }}>Ngày Tạo</th>
                <th style={{ padding: '16px', textAlign: 'right' }}>Hành Động</th>
              </tr>
            </thead>
            <tbody>
              {paginatedEmployees.map((emp) => (
                <tr
                  key={emp.id}
                  style={{
                    borderBottom: '1px solid var(--border-color)',
                    transition: 'background-color 0.2s ease',
                    cursor: 'pointer'
                  }}
                  className="table-row-hover"
                >
                  <td style={{ padding: '16px', fontWeight: 600 }} onClick={() => openDetailModal(emp)}>
                    {emp.employee_code}
                  </td>
                  <td style={{ padding: '16px' }} onClick={() => openDetailModal(emp)}>
                    <div style={{ fontWeight: 600, color: 'var(--text-primary)' }}>{emp.full_name}</div>
                    <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>@{emp.username}</div>
                  </td>
                  <td style={{ padding: '16px' }}>{emp.email}</td>
                  <td style={{ padding: '16px' }}>
                    <span
                      className={`badge role-${emp.role.toLowerCase()}`}
                      style={{ padding: '3px 8px', borderRadius: '4px', fontSize: '0.7rem' }}
                    >
                      {emp.role}
                    </span>
                  </td>
                  <td style={{ padding: '16px' }}>
                    <div style={{ display: 'flex', gap: '4px', flexWrap: 'wrap' }}>
                      {emp.platforms && emp.platforms.length > 0 ? (
                        emp.platforms.map((p) => (
                          <span
                            key={p}
                            style={{
                              backgroundColor: 'rgba(255, 255, 255, 0.05)',
                              border: '1px solid var(--border-color)',
                              padding: '2px 6px',
                              borderRadius: '4px',
                              fontSize: '0.7rem'
                            }}
                          >
                            {p}
                          </span>
                        ))
                      ) : (
                        <span style={{ color: 'var(--text-muted)', fontSize: '0.75rem' }}>Chưa phân bổ</span>
                      )}
                    </div>
                  </td>
                  <td style={{ padding: '16px' }}>
                    {emp.status === 'Active' ? (
                      <span style={{ color: 'var(--success)', display: 'inline-flex', alignItems: 'center', gap: '4px', fontWeight: 600 }}>
                        <UserCheck size={14} /> Hoạt động
                      </span>
                    ) : (
                      <span style={{ color: 'var(--text-muted)', display: 'inline-flex', alignItems: 'center', gap: '4px' }}>
                        <UserX size={14} /> Ngừng hoạt động
                      </span>
                    )}
                  </td>
                  <td style={{ padding: '16px', color: 'var(--text-muted)' }}>
                    {formatDate(emp.created_at)}
                  </td>
                  <td style={{ padding: '16px', textAlign: 'right' }}>
                    <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px' }} onClick={(e) => e.stopPropagation()}>
                      <button
                        title="Xem chi tiết"
                        style={{ background: 'none', border: 'none', color: 'var(--text-secondary)', cursor: 'pointer', padding: '4px' }}
                        onClick={() => openDetailModal(emp)}
                      >
                        <Eye size={16} />
                      </button>
                      <button
                        title="Chỉnh sửa"
                        style={{ background: 'none', border: 'none', color: 'var(--primary)', cursor: 'pointer', padding: '4px' }}
                        onClick={() => openEditModal(emp)}
                      >
                        <Edit2 size={16} />
                      </button>
                      <button
                        title="Vô hiệu hóa"
                        onClick={() => handleDeactivate(emp.id)}
                        disabled={emp.status === 'Inactive'}
                        style={{
                          background: 'none',
                          border: 'none',
                          color: emp.status === 'Inactive' ? 'var(--text-muted)' : 'var(--danger)',
                          cursor: emp.status === 'Inactive' ? 'not-allowed' : 'pointer',
                          padding: '4px',
                          opacity: emp.status === 'Inactive' ? 0.3 : 1
                        }}
                      >
                        <Trash2 size={16} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>

          {/* Pagination controls */}
          {totalPages > 1 && (
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '16px', borderTop: '1px solid var(--border-color)' }}>
              <span style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>
                Hiển thị {(currentPage - 1) * itemsPerPage + 1} - {Math.min(currentPage * itemsPerPage, filteredEmployees.length)} trong tổng số {filteredEmployees.length} nhân viên
              </span>
              <div style={{ display: 'flex', gap: '8px' }}>
                <button
                  className="retry-btn"
                  disabled={currentPage === 1}
                  onClick={() => setCurrentPage((c) => Math.max(c - 1, 1))}
                  style={{ padding: '6px 12px', opacity: currentPage === 1 ? 0.5 : 1, cursor: currentPage === 1 ? 'not-allowed' : 'pointer' }}
                >
                  Trước
                </button>
                <span style={{ padding: '6px 12px', fontSize: '0.875rem' }}>Trang {currentPage} / {totalPages}</span>
                <button
                  className="retry-btn"
                  disabled={currentPage === totalPages}
                  onClick={() => setCurrentPage((c) => Math.min(c + 1, totalPages))}
                  style={{ padding: '6px 12px', opacity: currentPage === totalPages ? 0.5 : 1, cursor: currentPage === totalPages ? 'not-allowed' : 'pointer' }}
                >
                  Sau
                </button>
              </div>
            </div>
          )}
        </div>
      )}

      {/* CREATE MODAL */}
      {showCreateModal && (
        <div className="modal-backdrop" style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, backgroundColor: 'rgba(0,0,0,0.6)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000 }}>
          <div className="dashboard-card" style={{ width: '100%', maxWidth: '500px', padding: '24px', backgroundColor: 'var(--bg-secondary)', animation: 'fadeIn 0.3s ease-out', position: 'relative' }}>
            <button
              onClick={() => setShowCreateModal(false)}
              style={{ position: 'absolute', top: '16px', right: '16px', background: 'none', border: 'none', color: 'var(--text-secondary)', cursor: 'pointer' }}
            >
              <X size={20} />
            </button>
            <h3 style={{ fontSize: '1.25rem', fontWeight: 700, marginBottom: '16px' }}>Thêm Tài Khoản Nhân Viên</h3>
            
            {formError && (
              <div style={{ color: 'var(--danger)', fontSize: '0.8rem', backgroundColor: 'var(--danger-light)', padding: '10px', borderRadius: '4px', marginBottom: '16px', border: '1px solid rgba(239, 68, 68, 0.2)' }}>
                {formError}
              </div>
            )}

            <form onSubmit={handleCreateSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
              <div className="form-group">
                <label>Tài khoản đăng nhập (Username) *</label>
                <input
                  type="text"
                  className="form-input"
                  required
                  placeholder="Ví dụ: nguyenvanb"
                  value={createForm.username}
                  onChange={(e) => setCreateForm({ ...createForm, username: e.target.value })}
                />
              </div>

              <div className="form-group">
                <label>Họ tên đầy đủ *</label>
                <input
                  type="text"
                  className="form-input"
                  required
                  placeholder="Ví dụ: Nguyễn Văn B"
                  value={createForm.full_name}
                  onChange={(e) => setCreateForm({ ...createForm, full_name: e.target.value })}
                />
              </div>

              <div className="form-group">
                <label>Địa chỉ Email *</label>
                <input
                  type="email"
                  className="form-input"
                  required
                  placeholder="b.nguyen@ecommercekpi.com"
                  value={createForm.email}
                  onChange={(e) => setCreateForm({ ...createForm, email: e.target.value })}
                />
              </div>

              <div className="form-group">
                <label>Mật khẩu khởi tạo *</label>
                <input
                  type="password"
                  className="form-input"
                  required
                  placeholder="Tối thiểu 6 ký tự"
                  value={createForm.password}
                  onChange={(e) => setCreateForm({ ...createForm, password: e.target.value })}
                />
              </div>

              <div className="form-group">
                <label>Phân quyền hệ thống</label>
                <select
                  className="form-input"
                  value={createForm.role}
                  onChange={(e) => setCreateForm({ ...createForm, role: e.target.value as Role })}
                >
                  <option value="Employee">Employee (Nhân viên)</option>
                  <option value="Manager">Manager (Quản lý)</option>
                  <option value="Admin">Admin (Quản trị viên)</option>
                </select>
              </div>

              <div className="form-group">
                <label>Kênh phụ trách</label>
                <div style={{ display: 'flex', gap: '12px', flexWrap: 'wrap', marginTop: '6px' }}>
                  {availablePlatforms.map((platform) => (
                    <label key={platform} style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '0.85rem', cursor: 'pointer' }}>
                      <input
                        type="checkbox"
                        checked={createForm.platforms.includes(platform)}
                        onChange={(e) => handlePlatformCheckboxChange(platform, true, e.target.checked)}
                      />
                      {platform}
                    </label>
                  ))}
                </div>
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px', marginTop: '16px' }}>
                <button
                  type="button"
                  className="retry-btn"
                  style={{ backgroundColor: 'transparent', border: '1px solid var(--border-color)', color: 'var(--text-primary)' }}
                  onClick={() => setShowCreateModal(false)}
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
                  Tạo tài khoản
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* EDIT MODAL */}
      {showEditModal && selectedEmp && (
        <div className="modal-backdrop" style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, backgroundColor: 'rgba(0,0,0,0.6)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000 }}>
          <div className="dashboard-card" style={{ width: '100%', maxWidth: '500px', padding: '24px', backgroundColor: 'var(--bg-secondary)', animation: 'fadeIn 0.3s ease-out', position: 'relative' }}>
            <button
              onClick={() => setShowEditModal(false)}
              style={{ position: 'absolute', top: '16px', right: '16px', background: 'none', border: 'none', color: 'var(--text-secondary)', cursor: 'pointer' }}
            >
              <X size={20} />
            </button>
            <h3 style={{ fontSize: '1.25rem', fontWeight: 700, marginBottom: '16px' }}>Chỉnh Sửa Thông Tin Nhân Viên</h3>

            {formError && (
              <div style={{ color: 'var(--danger)', fontSize: '0.8rem', backgroundColor: 'var(--danger-light)', padding: '10px', borderRadius: '4px', marginBottom: '16px', border: '1px solid rgba(239, 68, 68, 0.2)' }}>
                {formError}
              </div>
            )}

            <form onSubmit={handleEditSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
              <div style={{ display: 'flex', gap: '12px' }}>
                <div className="form-group" style={{ flex: 1 }}>
                  <label>Mã nhân viên</label>
                  <input type="text" className="form-input" disabled value={selectedEmp.employee_code} style={{ opacity: 0.6 }} />
                </div>
                <div className="form-group" style={{ flex: 1 }}>
                  <label>Tên tài khoản</label>
                  <input type="text" className="form-input" disabled value={`@${selectedEmp.username}`} style={{ opacity: 0.6 }} />
                </div>
              </div>

              <div className="form-group">
                <label>Họ tên đầy đủ *</label>
                <input
                  type="text"
                  className="form-input"
                  required
                  value={editForm.full_name}
                  onChange={(e) => setEditForm({ ...editForm, full_name: e.target.value })}
                />
              </div>

              <div className="form-group">
                <label>Địa chỉ Email *</label>
                <input
                  type="email"
                  className="form-input"
                  required
                  value={editForm.email}
                  onChange={(e) => setEditForm({ ...editForm, email: e.target.value })}
                />
              </div>

              <div className="form-group">
                <label>Trạng thái hoạt động</label>
                <select
                  className="form-input"
                  value={editForm.status}
                  onChange={(e) => setEditForm({ ...editForm, status: e.target.value as EmployeeStatus })}
                >
                  <option value="Active">Hoạt động (Active)</option>
                  <option value="Inactive">Ngừng hoạt động (Inactive)</option>
                </select>
              </div>

              <div className="form-group">
                <label>Phân quyền hệ thống</label>
                <select
                  className="form-input"
                  value={editForm.role}
                  onChange={(e) => setEditForm({ ...editForm, role: e.target.value as Role })}
                >
                  <option value="Employee">Employee (Nhân viên)</option>
                  <option value="Manager">Manager (Quản lý)</option>
                  <option value="Admin">Admin (Quản trị viên)</option>
                </select>
              </div>

              <div className="form-group">
                <label>Kênh phụ trách</label>
                <div style={{ display: 'flex', gap: '12px', flexWrap: 'wrap', marginTop: '6px' }}>
                  {availablePlatforms.map((platform) => (
                    <label key={platform} style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '0.85rem', cursor: 'pointer' }}>
                      <input
                        type="checkbox"
                        checked={editForm.platforms.includes(platform)}
                        onChange={(e) => handlePlatformCheckboxChange(platform, false, e.target.checked)}
                      />
                      {platform}
                    </label>
                  ))}
                </div>
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px', marginTop: '16px' }}>
                <button
                  type="button"
                  className="retry-btn"
                  style={{ backgroundColor: 'transparent', border: '1px solid var(--border-color)', color: 'var(--text-primary)' }}
                  onClick={() => setShowEditModal(false)}
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
                  Lưu thay đổi
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* DETAIL MODAL */}
      {showDetailModal && selectedEmp && (
        <div className="modal-backdrop" style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, backgroundColor: 'rgba(0,0,0,0.6)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000 }}>
          <div className="dashboard-card" style={{ width: '100%', maxWidth: '500px', padding: '24px', backgroundColor: 'var(--bg-secondary)', animation: 'fadeIn 0.3s ease-out', position: 'relative' }}>
            <button
              onClick={() => setShowDetailModal(false)}
              style={{ position: 'absolute', top: '16px', right: '16px', background: 'none', border: 'none', color: 'var(--text-secondary)', cursor: 'pointer' }}
            >
              <X size={20} />
            </button>
            <h3 style={{ fontSize: '1.25rem', fontWeight: 700, marginBottom: '20px' }}>Hồ Sơ Nhân Viên</h3>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              
              <div style={{ display: 'flex', alignItems: 'center', gap: '16px', borderBottom: '1px solid var(--border-color)', paddingBottom: '16px' }}>
                <div
                  className="user-avatar"
                  style={{ width: '56px', height: '56px', fontSize: '1.25rem', fontWeight: 700 }}
                >
                  {selectedEmp.full_name.substring(0, 2).toUpperCase()}
                </div>
                <div>
                  <h4 style={{ fontSize: '1.15rem', fontWeight: 700 }}>{selectedEmp.full_name}</h4>
                  <p style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>Mã NV: {selectedEmp.employee_code} · @{selectedEmp.username}</p>
                </div>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px', fontSize: '0.875rem' }}>
                <div>
                  <div style={{ color: 'var(--text-muted)', fontSize: '0.75rem', fontWeight: 600, textTransform: 'uppercase', marginBottom: '4px' }}>Email liên hệ</div>
                  <div style={{ fontWeight: 500 }}>{selectedEmp.email}</div>
                </div>
                <div>
                  <div style={{ color: 'var(--text-muted)', fontSize: '0.75rem', fontWeight: 600, textTransform: 'uppercase', marginBottom: '4px' }}>Vai trò</div>
                  <div>
                    <span className={`badge role-${selectedEmp.role.toLowerCase()}`}>{selectedEmp.role}</span>
                  </div>
                </div>
                <div>
                  <div style={{ color: 'var(--text-muted)', fontSize: '0.75rem', fontWeight: 600, textTransform: 'uppercase', marginBottom: '4px' }}>Trạng thái</div>
                  <div>
                    {selectedEmp.status === 'Active' ? (
                      <span style={{ color: 'var(--success)', fontWeight: 600 }}>Đang Hoạt Động</span>
                    ) : (
                      <span style={{ color: 'var(--text-muted)' }}>Ngừng Hoạt Động</span>
                    )}
                  </div>
                </div>
                <div>
                  <div style={{ color: 'var(--text-muted)', fontSize: '0.75rem', fontWeight: 600, textTransform: 'uppercase', marginBottom: '4px' }}>Ngày tham gia</div>
                  <div style={{ color: 'var(--text-primary)' }}>{formatDate(selectedEmp.created_at)}</div>
                </div>
              </div>

              <div style={{ borderTop: '1px solid var(--border-color)', paddingTop: '16px', marginTop: '8px' }}>
                <div style={{ color: 'var(--text-muted)', fontSize: '0.75rem', fontWeight: 600, textTransform: 'uppercase', marginBottom: '8px' }}>Kênh bán hàng phụ trách</div>
                <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
                  {selectedEmp.platforms && selectedEmp.platforms.length > 0 ? (
                    selectedEmp.platforms.map((p: string) => (
                      <span
                        key={p}
                        style={{
                          backgroundColor: 'var(--bg-tertiary)',
                          border: '1px solid var(--border-color)',
                          padding: '4px 10px',
                          borderRadius: 'var(--radius-sm)',
                          fontWeight: 500,
                          fontSize: '0.8rem'
                        }}
                      >
                        {p}
                      </span>
                    ))
                  ) : (
                    <span style={{ color: 'var(--text-muted)', fontSize: '0.85rem' }}>Chưa được gán kênh nào</span>
                  )}
                </div>
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: '16px' }}>
                <button
                  type="button"
                  className="retry-btn"
                  style={{ width: '100%', padding: '10px 0', display: 'flex', justifyContent: 'center' }}
                  onClick={() => setShowDetailModal(false)}
                >
                  Đóng
                </button>
              </div>

            </div>
          </div>
        </div>
      )}

    </div>
  );
};

export default EmployeesPage;
