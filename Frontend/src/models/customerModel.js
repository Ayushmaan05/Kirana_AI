// ─── Customer Model ───────────────────────────────────────────────────────────
export function normalizeCustomer(raw) {
  return {
    id:              raw.id || raw._id || String(Date.now()),
    name:            raw.name || raw.customer_name || '',
    phone:           raw.phone || raw.mobile || '',
    outstandingBalance: Number(raw.outstanding_balance ?? raw.balance ?? 0),
    totalPurchased:  Number(raw.total_purchased ?? 0),
    totalPaid:       Number(raw.total_paid ?? 0),
    lastTransaction: raw.last_transaction ? new Date(raw.last_transaction) : null,
    transactions:    (raw.transactions || []),
    notes:           raw.notes || '',
    createdAt:       raw.created_at ? new Date(raw.created_at) : new Date(),
  };
}

export function getCustomerStatus(balance) {
  if (balance <= 0) return { label: 'Cleared', color: 'success' };
  if (balance < 500) return { label: 'Low Credit', color: 'warning' };
  return { label: 'Outstanding', color: 'error' };
}
