import apiClient from './apiClient';

export type ReportType = 'Daily_Email' | 'Monthly_Summary';
export type ReportSentStatus = 'Pending' | 'Sent' | 'Failed';

export interface Report {
  id: string;
  report_type: ReportType;
  date: string;
  recipients: string[];
  total_revenue: number;
  total_orders: number;
  top_employee?: string;
  new_blacklist_count: number;
  summary_data: Record<string, any>;
  sent_status: ReportSentStatus;
  created_at: string;
}

export interface ReportCreate {
  report_type: ReportType;
  date: string;
  recipients: string[];
  total_revenue?: number;
  total_orders?: number;
  top_employee?: string;
  new_blacklist_count?: number;
  summary_data?: Record<string, any>;
  sent_status?: ReportSentStatus;
}

export const getReports = async (skip = 0, limit = 100): Promise<Report[]> => {
  const res = await apiClient.get<Report[]>('/reports', { params: { skip, limit } });
  return res.data;
};

export const getUnsentReports = async (): Promise<Report[]> => {
  const res = await apiClient.get<Report[]>('/reports/unsent');
  return res.data;
};

export const getReportByDate = async (date: string): Promise<Report> => {
  const res = await apiClient.get<Report>('/reports/date', { params: { date } });
  return res.data;
};

export const getReport = async (id: string): Promise<Report> => {
  const res = await apiClient.get<Report>(`/reports/${id}`);
  return res.data;
};

export const createReport = async (data: ReportCreate): Promise<Report> => {
  const res = await apiClient.post<Report>('/reports', data);
  return res.data;
};

export const markReportAsSent = async (id: string): Promise<Report> => {
  const res = await apiClient.post<Report>(`/reports/${id}/sent`);
  return res.data;
};

export const deleteReport = async (id: string): Promise<{ success: boolean }> => {
  const res = await apiClient.delete<{ success: boolean }>(`/reports/${id}`);
  return res.data;
};
