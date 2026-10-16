import apiClient from './apiClient.js';
import { normalizeProduct } from '../models/productModel.js';

const delay = ms => new Promise(r => setTimeout(r, ms));

const MOCK_PRODUCTS = [
  { id: '1', name: 'Parle-G Biscuit', category: 'Snacks', quantity: 240, unit: 'pkt', purchase_price: 5, selling_price: 8, low_stock_threshold: 50 },
  { id: '2', name: 'Amul Milk 1L', category: 'Dairy', quantity: 12, unit: 'ltr', purchase_price: 52, selling_price: 60, low_stock_threshold: 20 },
  { id: '3', name: 'Aashirvaad Aata 5kg', category: 'Staples', quantity: 8, unit: 'bag', purchase_price: 90, selling_price: 100, low_stock_threshold: 10 },
  { id: '4', name: 'Maggi Noodles', category: 'Snacks', quantity: 6, unit: 'pkt', purchase_price: 14, selling_price: 20, low_stock_threshold: 30 },
  { id: '5', name: 'Bisleri 1L', category: 'Beverages', quantity: 48, unit: 'btl', purchase_price: 15, selling_price: 20, low_stock_threshold: 24 },
  { id: '6', name: 'Lifebuoy Soap', category: 'Personal Care', quantity: 0, unit: 'pcs', purchase_price: 25, selling_price: 35, low_stock_threshold: 10 },
  { id: '7', name: 'Tata Salt 1kg', category: 'Staples', quantity: 35, unit: 'pkt', purchase_price: 18, selling_price: 25, low_stock_threshold: 10 },
  { id: '8', name: 'Kurkure Masala', category: 'Snacks', quantity: 100, unit: 'pkt', purchase_price: 10, selling_price: 15, low_stock_threshold: 30 },
];

export async function getInventory(filters = {}) {
  if (apiClient.isDemoMode) {
    await delay(400);
    let products = MOCK_PRODUCTS.map(normalizeProduct);
    if (filters.category) products = products.filter(p => p.category === filters.category);
    if (filters.search) {
      const s = filters.search.toLowerCase();
      products = products.filter(p => p.name.toLowerCase().includes(s));
    }
    if (filters.lowStock) products = products.filter(p => p.stockStatus !== 'in_stock');
    return products;
  }
  const params = new URLSearchParams(filters).toString();
  const res = await apiClient.get(`/api/inventory?${params}`);
  return res.map(normalizeProduct);
}

export async function addProduct(data) {
  if (apiClient.isDemoMode) {
    await delay(600);
    return normalizeProduct({ ...data, id: String(Date.now()) });
  }
  return apiClient.post('/api/inventory', data);
}

export async function updateProduct(id, data) {
  if (apiClient.isDemoMode) {
    await delay(500);
    return normalizeProduct({ ...data, id });
  }
  return apiClient.put(`/api/inventory/${id}`, data);
}

export async function adjustStock(id, adjustment) {
  if (apiClient.isDemoMode) {
    await delay(500);
    return { id, adjustment, success: true };
  }
  return apiClient.patch(`/api/inventory/${id}/stock`, { adjustment });
}
