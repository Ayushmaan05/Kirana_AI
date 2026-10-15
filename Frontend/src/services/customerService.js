import apiClient from './apiClient.js';
import { normalizeCustomer } from '../models/customerModel.js';

const delay = ms => new Promise(r => setTimeout(r, ms));

const MOCK_CUSTOMERS = [
  { id: '1', name: 'Ramesh Kumar', phone: '9876543210', outstanding_balance: 1350, total_purchased: 8500, total_paid: 7150, last_transaction: new Date(Date.now() - 86400000).toISOString() },
  { id: '2', name: 'Suresh Sharma', phone: '9856741230', outstanding_balance: 0, total_purchased: 6200, total_paid: 6200, last_transaction: new Date(Date.now() - 172800000).toISOString() },
  { id: '3', name: 'Priya Devi', phone: '9712345678', outstanding_balance: 2750, total_purchased: 4500, total_paid: 1750, last_transaction: new Date(Date.now() - 259200000).toISOString() },
  { id: '4', name: 'Mohan Lal', phone: '', outstanding_balance: 800, total_purchased: 3200, total_paid: 2400, last_transaction: new Date(Date.now() - 432000000).toISOString() },
  { id: '5', name: 'Geeta Singh', phone: '9934567891', outstanding_balance: 450, total_purchased: 1800, total_paid: 1350, last_transaction: new Date(Date.now() - 604800000).toISOString() },
];

export async function getCustomers(search = '') {
  if (apiClient.isDemoMode) {
    await delay(400);
    let customers = MOCK_CUSTOMERS.map(normalizeCustomer);
    if (search) {
      const s = search.toLowerCase();
      customers = customers.filter(c => c.name.toLowerCase().includes(s) || c.phone.includes(s));
    }
    return customers;
  }
  const params = search ? `?search=${encodeURIComponent(search)}` : '';
  const res = await apiClient.get(`/api/customers${params}`);
  return res.map(normalizeCustomer);
}

export async function addCustomer(data) {
  if (apiClient.isDemoMode) {
    await delay(600);
    return normalizeCustomer({ ...data, id: String(Date.now()) });
  }
  return apiClient.post('/api/customers', data);
}

export async function recordUdhaarPayment(customerId, amount) {
  if (apiClient.isDemoMode) {
    await delay(700);
    return { success: true, customerId, amount };
  }
  return apiClient.post(`/api/customers/${customerId}/payment`, { amount });
}
