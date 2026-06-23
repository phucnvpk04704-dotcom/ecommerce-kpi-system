import apiClient from './apiClient';
import type { Platform } from './employeeApi';

export type Period = 'DAILY' | 'MONTHLY';

export interface Revenue {
  id: string;
  employee_id: string;
  platform: Platform;
  date: string;
  period: Period;
  total_orders: number;
  successful_orders: number;
  returned_orders: number;
  cancelled_orders: number;
  total_revenue: number;
  target_revenue: number;
  created_at: string;
  updated_at: string;
}

export interface RevenueCreate {
  employee_id: string;
  platform: Platform;
  date: string;
  period: Period;
  total_orders: number;
  successful_orders: number;
  returned_orders: number;
  cancelled_orders: number;
  total_revenue: number;
  target_revenue: number;
}

export interface RevenueUpdate {
  employee_id?: string;
  platform?: Platform;
  date?: string;
  period?: Period;
  total_orders?: number;
  successful_orders?: number;
  returned_orders?: number;
  cancelled_orders?: number;
  total_revenue?: number;
  target_revenue?: number;
}

export interface RevenueStats {
  total_revenue: number;
  target_revenue: number;
  total_orders: number;
  successful_orders: number;
  returned_orders: number;
  cancelled_orders: number;
}

export const getRevenues = async (skip = 0, limit = 100): Promise<Revenue[]> => {
  const res = await apiClient.get<Revenue[]>('/revenues', { params: { skip, limit } });
  return res.data;
};

export const getRevenue = async (id: string): Promise<Revenue> => {
  const res = await apiClient.get<Revenue>(`/revenues/${id}`);
  return res.data;
};

export const createRevenue = async (data: RevenueCreate): Promise<Revenue> => {
  const res = await apiClient.post<Revenue>('/revenues', data);
  return res.data;
};

export const updateRevenue = async (id: string, data: RevenueUpdate): Promise<Revenue> => {
  const res = await apiClient.put<Revenue>(`/revenues/${id}`, data);
  return res.data;
};

export const deleteRevenue = async (id: string): Promise<{ success: boolean }> => {
  const res = await apiClient.delete<{ success: boolean }>(`/revenues/${id}`);
  return res.data;
};

export const getEmployeeStats = async (
  employeeId: string,
  platform: string,
  startDate: string,
  endDate: string
): Promise<RevenueStats> => {
  const res = await apiClient.get<RevenueStats>(`/revenues/stats/employee/${employeeId}`, {
    params: {
      platform,
      start_date: startDate,
      end_date: endDate,
    },
  });
  return res.data;
};
