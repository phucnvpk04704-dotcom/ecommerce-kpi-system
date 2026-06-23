import apiClient from './apiClient';
import type { Platform } from './employeeApi';

export type RiskLevel = 'Low' | 'Medium' | 'High' | 'Blacklist';

export interface BlacklistEntry {
  id: string;
  customer_id: string;
  platform: Platform;
  customer_name?: string;
  customer_phone: string;
  total_orders: number;
  cancelled_orders: number;
  returned_orders: number;
  risk_score: number;
  risk_level: RiskLevel;
  last_order_at?: string;
  added_at: string;
  created_at: string;
  updated_at: string;
}

export interface BlacklistCreate {
  customer_id: string;
  platform: Platform;
  customer_name?: string;
  customer_phone: string;
  total_orders?: number;
  cancelled_orders?: number;
  returned_orders?: number;
  risk_score?: number;
  risk_level?: RiskLevel;
  last_order_at?: string;
}

export interface BlacklistUpdate {
  customer_id?: string;
  platform?: Platform;
  customer_name?: string;
  customer_phone?: string;
  total_orders?: number;
  cancelled_orders?: number;
  returned_orders?: number;
  risk_score?: number;
  risk_level?: RiskLevel;
  last_order_at?: string;
}

export const getBlacklistEntries = async (skip = 0, limit = 100): Promise<BlacklistEntry[]> => {
  const res = await apiClient.get<BlacklistEntry[]>('/customer_blacklist', { params: { skip, limit } });
  return res.data;
};

export const getBlacklistEntry = async (id: string): Promise<BlacklistEntry> => {
  const res = await apiClient.get<BlacklistEntry>(`/customer_blacklist/${id}`);
  return res.data;
};

export const createBlacklistEntry = async (data: BlacklistCreate): Promise<BlacklistEntry> => {
  const res = await apiClient.post<BlacklistEntry>('/customer_blacklist', data);
  return res.data;
};

export const updateBlacklistEntry = async (id: string, data: BlacklistUpdate): Promise<BlacklistEntry> => {
  const res = await apiClient.put<BlacklistEntry>(`/customer_blacklist/${id}`, data);
  return res.data;
};

export const deleteBlacklistEntry = async (id: string): Promise<{ success: boolean }> => {
  const res = await apiClient.delete<{ success: boolean }>(`/customer_blacklist/${id}`);
  return res.data;
};

export const findByPhone = async (phone: string): Promise<BlacklistEntry> => {
  const res = await apiClient.get<BlacklistEntry>(`/customer_blacklist/phone/${phone}`);
  return res.data;
};

export const evaluateRisk = async (data: {
  customer_id: string;
  customer_phone: string;
  platform: Platform;
}): Promise<BlacklistEntry> => {
  const res = await apiClient.post<BlacklistEntry>('/customer_blacklist/evaluate', data);
  return res.data;
};
