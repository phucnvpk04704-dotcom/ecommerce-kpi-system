import { create } from 'zustand';
import type { Employee, EmployeeCreate, EmployeeUpdate } from '../services/employeeApi';
import {
  getEmployees,
  createEmployee,
  updateEmployee,
  deleteEmployee
} from '../services/employeeApi';

interface EmployeeState {
  employees: Employee[];
  loading: boolean;
  error: string | null;
  searchQuery: string;
  statusFilter: 'All' | 'Active' | 'Inactive';
  selectedEmployee: Employee | null;
  
  // Actions
  fetchEmployees: () => Promise<void>;
  setSearchQuery: (query: string) => void;
  setStatusFilter: (filter: 'All' | 'Active' | 'Inactive') => void;
  addEmployee: (data: EmployeeCreate) => Promise<void>;
  editEmployee: (id: string, data: EmployeeUpdate) => Promise<void>;
  deactivateEmployee: (id: string) => Promise<void>;
  selectEmployee: (employee: Employee | null) => void;
}

export const useEmployeeStore = create<EmployeeState>((set) => ({
  employees: [],
  loading: false,
  error: null,
  searchQuery: '',
  statusFilter: 'All',
  selectedEmployee: null,

  fetchEmployees: async () => {
    set({ loading: true, error: null });
    try {
      // Fetch employees list from the API
      const list = await getEmployees(0, 1000); // load up to 1000 items for frontend paging/search
      set({ employees: list, loading: false });
    } catch (err: any) {
      console.error(err);
      set({
        error: err.response?.data?.detail || 'Không thể tải danh sách nhân viên.',
        loading: false
      });
    }
  },

  setSearchQuery: (query: string) => set({ searchQuery: query }),
  
  setStatusFilter: (filter: 'All' | 'Active' | 'Inactive') => set({ statusFilter: filter }),

  addEmployee: async (data: EmployeeCreate) => {
    set({ loading: true, error: null });
    try {
      const newEmp = await createEmployee(data);
      set((state) => ({
        employees: [newEmp, ...state.employees],
        loading: false
      }));
    } catch (err: any) {
      console.error(err);
      const errMsg = err.response?.data?.detail || 'Lỗi khi tạo nhân viên mới.';
      set({ error: errMsg, loading: false });
      throw new Error(errMsg);
    }
  },

  editEmployee: async (id: string, data: EmployeeUpdate) => {
    set({ loading: true, error: null });
    try {
      const updated = await updateEmployee(id, data);
      set((state) => ({
        employees: state.employees.map((emp) => (emp.id === id ? updated : emp)),
        selectedEmployee: state.selectedEmployee?.id === id ? updated : state.selectedEmployee,
        loading: false
      }));
    } catch (err: any) {
      console.error(err);
      const errMsg = err.response?.data?.detail || 'Lỗi khi cập nhật thông tin nhân viên.';
      set({ error: errMsg, loading: false });
      throw new Error(errMsg);
    }
  },

  deactivateEmployee: async (id: string) => {
    set({ loading: true, error: null });
    try {
      const updated = await deleteEmployee(id); // backend soft-delete sets status to Inactive
      set((state) => ({
        employees: state.employees.map((emp) => (emp.id === id ? updated : emp)),
        selectedEmployee: state.selectedEmployee?.id === id ? updated : state.selectedEmployee,
        loading: false
      }));
    } catch (err: any) {
      console.error(err);
      const errMsg = err.response?.data?.detail || 'Lỗi khi vô hiệu hóa nhân viên.';
      set({ error: errMsg, loading: false });
      throw new Error(errMsg);
    }
  },

  selectEmployee: (employee: Employee | null) => set({ selectedEmployee: employee })
}));
