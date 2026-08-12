import axios from 'axios';
import apiClient, { API_BASE } from '../services/apiClient';

export const login = async (username: string, password: string) => {
  const params = new URLSearchParams();
  params.append('username', username);
  params.append('password', password);

  try {
    const res = await axios.post(`${API_BASE}/auth/login`, params, {
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    });
    localStorage.setItem('access_token', res.data.access_token);
    return res.data;
  } catch (error) {
    // Fallback to JSON payload if Form Data is not supported
    const res = await axios.post(`${API_BASE}/auth/login`, { username, password });
    localStorage.setItem('access_token', res.data.access_token);
    return res.data;
  }
};

export const logout = () => {
  localStorage.removeItem('access_token');
};

export const getSummary = async () => {
  const res = await apiClient.get('/dashboard/summary');
  return res.data;
};

export const getKPI = async () => {
  const res = await apiClient.get('/dashboard/kpi');
  return res.data;
};

export const getRevenueChart = async () => {
  const res = await apiClient.get('/dashboard/revenue-chart');
  return res.data;
};

export const getOrdersChart = async () => {
  const res = await apiClient.get('/dashboard/orders-chart');
  return res.data;
};

export const getRecentActivities = async () => {
  const res = await apiClient.get('/dashboard/recent-activities');
  return res.data;
};
