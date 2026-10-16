import { normalizeTransaction } from '../models/transactionModel.js';
import apiClient from './apiClient.js';

// ─── Service Functions ────────────────────────────────────────────────────────

export async function getDashboardData() {
  // The /api/dashboard endpoint returns the exact shape the DashboardPage expects.
  const data = await apiClient.get('/api/dashboard');

  // Normalize the recent transactions for the UI
  return {
    ...data,
    recentTransactions: (data.recentTransactions || []).map(normalizeTransaction),
  };
}

export async function getTransactions(filters = {}) {
  const params = new URLSearchParams();
  if (filters.limit) params.set('limit', filters.limit);
  if (filters.offset) params.set('offset', filters.offset);
  const qs = params.toString();
  const res = await apiClient.get(`/api/sales${qs ? '?' + qs : ''}`);

  // Backend returns { success, count, sales: [...] }
  const sales = res.sales || [];

  // Map backend sale records into the frontend transaction shape
  return sales.map(sale => normalizeTransaction({
    id: String(sale.sale_id),
    type: 'sale',
    description: sale.invoice_number,
    amount: sale.net_amount,
    payment_mode: sale.payment_method,
    customer_name: sale.customer_name,
    created_at: sale.sale_date,
    status: sale.status === 'completed' ? 'confirmed' : sale.status,
  }));
}

export async function addTransaction(data) {
  return apiClient.post('/api/sales', data);
}
