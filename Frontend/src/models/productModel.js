// ─── Product / Inventory Model ────────────────────────────────────────────────
export const STOCK_STATUS = {
  IN_STOCK:   'in_stock',
  LOW_STOCK:  'low_stock',
  OUT_OF_STOCK: 'out_of_stock',
};

export function normalizeProduct(raw) {
  const qty = Number(raw.quantity ?? raw.stock_quantity ?? raw.qty ?? 0);
  const low = Number(raw.low_stock_threshold ?? raw.lowStockThreshold ?? 10);
  return {
    id:          raw.id || raw._id || String(Date.now()),
    name:        raw.name || raw.product_name || '',
    category:    raw.category || 'General',
    quantity:    qty,
    unit:        raw.unit || 'pcs',
    purchasePrice: Number(raw.purchase_price ?? raw.purchasePrice ?? 0),
    sellingPrice:  Number(raw.selling_price ?? raw.sellingPrice ?? 0),
    lowStockThreshold: low,
    stockStatus: qty === 0
      ? STOCK_STATUS.OUT_OF_STOCK
      : qty <= low
        ? STOCK_STATUS.LOW_STOCK
        : STOCK_STATUS.IN_STOCK,
    sku:         raw.sku || '',
    barcode:     raw.barcode || '',
    updatedAt:   raw.updated_at ? new Date(raw.updated_at) : new Date(),
  };
}

export function getStockStatusLabel(status) {
  return {
    [STOCK_STATUS.IN_STOCK]:     'In Stock',
    [STOCK_STATUS.LOW_STOCK]:    'Low Stock',
    [STOCK_STATUS.OUT_OF_STOCK]: 'Out of Stock',
  }[status] || status;
}

export function getStockStatusColor(status) {
  return {
    [STOCK_STATUS.IN_STOCK]:     'success',
    [STOCK_STATUS.LOW_STOCK]:    'warning',
    [STOCK_STATUS.OUT_OF_STOCK]: 'error',
  }[status] || 'gray';
}
