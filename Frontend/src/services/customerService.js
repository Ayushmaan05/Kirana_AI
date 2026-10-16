import apiClient from './apiClient.js';
import { normalizeCustomer } from '../models/customerModel.js';

// ─── Customer Service — calls real backend API ──────────────────────────────
// NOTE: The backend does not yet have /api/customers endpoints.
// These calls will return errors until the endpoints are implemented.
// The pages that use these will show an error notification.

export async function getCustomers(search = '') {
  const params = search ? `?search=${encodeURIComponent(search)}` : '';
  const res = await apiClient.get(`/api/customers${params}`);
  return (Array.isArray(res) ? res : []).map(normalizeCustomer);
}

export async function addCustomer(data) {
  return apiClient.post('/api/customers', data);
}

export async function recordUdhaarPayment(customerId, amount) {
  return apiClient.post(`/api/customers/${customerId}/payment`, { amount });
}
