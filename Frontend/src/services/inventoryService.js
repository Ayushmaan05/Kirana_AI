import apiClient from './apiClient.js';
import { normalizeProduct } from '../models/productModel.js';

// ─── Inventory Service — calls real backend API ──────────────────────────────

export async function getInventory(filters = {}) {
  const params = new URLSearchParams();
  if (filters.search) params.set('search', filters.search);
  if (filters.category_id) params.set('category_id', filters.category_id);
  if (filters.limit) params.set('limit', filters.limit);
  if (filters.offset) params.set('offset', filters.offset);
  const qs = params.toString();

  // Backend returns an array of product objects from /api/products
  const rows = await apiClient.get(`/api/products${qs ? '?' + qs : ''}`);

  // Map backend product shape → frontend normalizeProduct shape
  return rows.map(row => normalizeProduct({
    id: String(row.product_id),
    name: row.product_name,
    category: row.category_name || 'General',
    quantity: row.current_stock,
    unit: row.unit,
    purchase_price: row.cost_price,
    selling_price: row.selling_price,
    low_stock_threshold: row.min_stock_level,
    sku: row.sku,
    updated_at: row.updated_at,
  }));
}

export async function getLowStock() {
  const rows = await apiClient.get('/api/inventory/low-stock');
  return rows.map(row => normalizeProduct({
    id: String(row.product_id),
    name: row.product_name,
    category: row.category_name || 'General',
    quantity: row.current_stock,
    unit: row.unit,
    purchase_price: row.cost_price,
    selling_price: row.selling_price,
    low_stock_threshold: row.min_stock_level,
    sku: row.sku,
  }));
}

export async function getExpiringProducts() {
  return apiClient.get('/api/inventory/expiring');
}

export async function getInventoryValuation() {
  return apiClient.get('/api/inventory/valuation');
}

export async function addProduct(data) {
  // NOTE: Backend does not yet have a POST /api/products endpoint.
  // This will need to be added when product creation from the UI is required.
  return apiClient.post('/api/products', data);
}

export async function updateProduct(id, data) {
  // NOTE: Backend does not yet have a PUT /api/products/:id endpoint.
  return apiClient.put(`/api/products/${id}`, data);
}

export async function adjustStock(id, adjustment) {
  // NOTE: Backend does not yet have a stock adjustment endpoint.
  return apiClient.patch(`/api/products/${id}/stock`, { adjustment });
}
