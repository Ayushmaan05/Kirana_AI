import { normalizeTransaction } from '../models/transactionModel.js';

// ─── Mock Data ────────────────────────────────────────────────────────────────
const MOCK_TRANSACTIONS = [
  { id: '1', type: 'sale', description: 'Aata, Daal, Chawal', amount: 480, payment_mode: 'cash', customer_name: null, created_at: new Date().toISOString() },
  { id: '2', type: 'udhaar_given', description: 'Grocery - Ramesh Kumar', amount: 350, payment_mode: 'credit', customer_name: 'Ramesh Kumar', created_at: new Date(Date.now() - 3600000).toISOString() },
  { id: '3', type: 'sale', description: 'Maggi, Biscuit, Cold Drink', amount: 120, payment_mode: 'upi', customer_name: null, created_at: new Date(Date.now() - 7200000).toISOString() },
  { id: '4', type: 'purchase', description: 'Stock purchase - Maggi 5 peti', amount: 1200, payment_mode: 'cash', customer_name: 'Ramesh Kumar', created_at: new Date(Date.now() - 86400000).toISOString() },
  { id: '5', type: 'sale', description: 'Amul Butter, Bread', amount: 110, payment_mode: 'upi', customer_name: null, created_at: new Date(Date.now() - 90000000).toISOString() },
  { id: '6', type: 'payment_received', description: 'Udhaar payment from Suresh', amount: 500, payment_mode: 'cash', customer_name: 'Suresh Sharma', created_at: new Date(Date.now() - 172800000).toISOString() },
  { id: '7', type: 'expense', description: 'Shop rent', amount: 5000, payment_mode: 'bank', customer_name: null, created_at: new Date(Date.now() - 259200000).toISOString() },
  { id: '8', type: 'sale', description: 'Pooja Samagri', amount: 750, payment_mode: 'cash', customer_name: 'Priya Devi', created_at: new Date(Date.now() - 300000000).toISOString() },
];

const MOCK_WEEKLY = [
  { day: 'Mon', sales: 1800, expenses: 400 },
  { day: 'Tue', sales: 2200, expenses: 600 },
  { day: 'Wed', sales: 1400, expenses: 300 },
  { day: 'Thu', sales: 2800, expenses: 800 },
  { day: 'Fri', sales: 3200, expenses: 1200 },
  { day: 'Sat', sales: 4100, expenses: 500 },
  { day: 'Sun', sales: 3600, expenses: 400 },
];

const MOCK_DASHBOARD = {
  todaySales:        4760,
  todayExpenses:     1200,
  outstandingCredit: 8350,
  totalInventoryValue: 45000,
  salesChange:       '+12%',
  expenseChange:     '+3%',
  creditChange:      '-5%',
  weeklyData:        MOCK_WEEKLY,
  recentTransactions: MOCK_TRANSACTIONS.slice(0, 5),
  topProducts: [
    { name: 'Parle-G Biscuit', sales: 142, revenue: 1136 },
    { name: 'Amul Milk 1L',    sales: 98,  revenue: 5096 },
    { name: 'Maggi Noodles',   sales: 87,  revenue: 1740 },
    { name: 'Aashirvaad Aata', sales: 65,  revenue: 6500 },
    { name: 'Bisleri 1L',      sales: 54,  revenue: 1080 },
  ],
  lowStockCount: 3,
};

// ─── Service Functions ────────────────────────────────────────────────────────
import apiClient from './apiClient.js';

export async function getDashboardData() {
  if (apiClient.isDemoMode) {
    await delay(600);
    return MOCK_DASHBOARD;
  }
  return apiClient.get('/api/dashboard');
}

export async function getTransactions(filters = {}) {
  if (apiClient.isDemoMode) {
    await delay(400);
    let txns = MOCK_TRANSACTIONS.map(normalizeTransaction);
    if (filters.type) txns = txns.filter(t => t.type === filters.type);
    if (filters.search) {
      const s = filters.search.toLowerCase();
      txns = txns.filter(t =>
        t.description.toLowerCase().includes(s) ||
        (t.customerName || '').toLowerCase().includes(s)
      );
    }
    return txns;
  }
  const params = new URLSearchParams(filters).toString();
  const res = await apiClient.get(`/api/transactions?${params}`);
  return res.map(normalizeTransaction);
}

export async function addTransaction(data) {
  if (apiClient.isDemoMode) {
    await delay(800);
    return { ...data, id: String(Date.now()), created_at: new Date().toISOString(), status: 'confirmed' };
  }
  return apiClient.post('/api/transactions', data);
}

// ─── Helper ───────────────────────────────────────────────────────────────────
function delay(ms) { return new Promise(r => setTimeout(r, ms)); }
