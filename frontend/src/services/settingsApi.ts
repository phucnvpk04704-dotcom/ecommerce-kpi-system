import apiClient from './apiClient';

export interface Setting {
  id: string;
  key: string;
  value: Record<string, any>;
  updated_by: string;
  created_at: string;
  updated_at: string;
}

export interface SettingCreate {
  key: string;
  value: Record<string, any>;
  updated_by: string;
}

export interface SettingUpdate {
  value: Record<string, any>;
  updated_by: string;
}

export const getSettings = async (skip = 0, limit = 100): Promise<Setting[]> => {
  const res = await apiClient.get<Setting[]>('/settings', { params: { skip, limit } });
  return res.data;
};

export const getSettingByKey = async (key: string): Promise<Setting> => {
  const res = await apiClient.get<Setting>(`/settings/key/${key}`);
  return res.data;
};

export const createSetting = async (data: SettingCreate): Promise<Setting> => {
  const res = await apiClient.post<Setting>('/settings', data);
  return res.data;
};

export const updateSetting = async (id: string, data: SettingUpdate): Promise<Setting> => {
  const res = await apiClient.put<Setting>(`/settings/${id}`, data);
  return res.data;
};

export const deleteSetting = async (id: string): Promise<{ success: boolean }> => {
  const res = await apiClient.delete<{ success: boolean }>(`/settings/${id}`);
  return res.data;
};
