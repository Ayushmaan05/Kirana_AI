// ─── Transaction Model ───────────────────────────────────────────────────────
export const TRANSACTION_TYPES = {
  SALE: 'sale',
  PURCHASE: 'purchase',
  EXPENSE: 'expense',
  UDHAAR_GIVEN: 'udhaar_given',
  UDHAAR_RECEIVED: 'udhaar_received',
  PAYMENT_RECEIVED: 'payment_received',
};

export const PAYMENT_MODES = {
  CASH: 'cash',
  UPI: 'upi',
  CREDIT: 'credit',
  BANK: 'bank',
};

/**
 * Normalize a raw API transaction into a consistent shape.
 * @param {Object} raw
 * @returns {Object}
 */
export function normalizeTransaction(raw) {
  return {
    id:          raw.id || raw._id || String(Date.now()),
    type:        raw.transaction_type || raw.type || TRANSACTION_TYPES.SALE,
    description: raw.description || raw.items?.map(i => i.name).join(', ') || '',
    amount:      Number(raw.amount) || 0,
    paymentMode: raw.payment_mode || raw.paymentMode || PAYMENT_MODES.CASH,
    customerName: raw.customer_name || raw.customerName || null,
    items:       raw.items || [],
    createdAt:   raw.created_at ? new Date(raw.created_at) : new Date(),
    notes:       raw.notes || '',
    status:      raw.status || 'confirmed',
  };
}

export function getTransactionLabel(type) {
  const labels = {
    [TRANSACTION_TYPES.SALE]:             'Sale',
    [TRANSACTION_TYPES.PURCHASE]:         'Purchase',
    [TRANSACTION_TYPES.EXPENSE]:          'Expense',
    [TRANSACTION_TYPES.UDHAAR_GIVEN]:     'Udhaar Given',
    [TRANSACTION_TYPES.UDHAAR_RECEIVED]:  'Udhaar Received',
    [TRANSACTION_TYPES.PAYMENT_RECEIVED]: 'Payment Received',
  };
  return labels[type] || type;
}

export function getTransactionColor(type) {
  const colors = {
    [TRANSACTION_TYPES.SALE]:             'success',
    [TRANSACTION_TYPES.PURCHASE]:         'info',
    [TRANSACTION_TYPES.EXPENSE]:          'error',
    [TRANSACTION_TYPES.UDHAAR_GIVEN]:     'warning',
    [TRANSACTION_TYPES.UDHAAR_RECEIVED]:  'warning',
    [TRANSACTION_TYPES.PAYMENT_RECEIVED]: 'success',
  };
  return colors[type] || 'gray';
}
