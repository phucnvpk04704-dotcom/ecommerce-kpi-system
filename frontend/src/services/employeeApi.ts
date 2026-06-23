import apiClient from './apiClient';

export type Role = 'Admin' | 'Manager' | 'Employee';
export type EmployeeStatus = 'Active' | 'Inactive';
export type Platform = 'Shopee' | 'Lazada' | 'TikTok Shop' | 'Tiki' | 'All';

export interface Employee {
  id: string;
  employee_code: string;
  username: string;
  full_name: string;
  email: string;
  role: Role;
  status: EmployeeStatus;
  platforms: Platform[];
  created_at: string;
  updated_at: string;
}

export interface EmployeeCreate {
  username: string;
  full_name: string;
  email: string;
  password?: string;
  role: Role;
  platforms: Platform[];
}

export interface EmployeeUpdate {
  full_name?: string;
  email?: string;
  role?: Role;
  status?: EmployeeStatus;
  platforms?: Platform[];
}

export const getEmployees = async (skip = 0, limit = 100): Promise<Employee[]> => {
  const res = await apiClient.get<Employee[]>('/employees', { params: { skip, limit } });
  return res.data;
};

export const getEmployee = async (id: string): Promise<Employee> => {
  const res = await apiClient.get<Employee>(`/employees/${id}`);
  return res.data;
};

export const createEmployee = async (data: EmployeeCreate): Promise<Employee> => {
  const res = await apiClient.post<Employee>('/employees', data);
  return res.data;
};

export const updateEmployee = async (id: string, data: EmployeeUpdate): Promise<Employee> => {
  const res = await apiClient.put<Employee>(`/employees/${id}`, data);
  return res.data;
};

export const deleteEmployee = async (id: string): Promise<Employee> => {
  const res = await apiClient.delete<Employee>(`/employees/${id}`);
  return res.data;
};
