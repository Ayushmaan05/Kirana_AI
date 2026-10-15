import React, { useEffect, useState, useMemo } from 'react';
import { motion } from 'framer-motion';
import { Search, Filter, Download, ShoppingCart, ChevronLeft, ChevronRight } from 'lucide-react';
import { getTransactions } from '../services/dashboardService.js';
import { getTransactionLabel, getTransactionColor, TRANSACTION_TYPES } from '../models/transactionModel.js';
import { formatCurrency } from '../utils/formatCurrency.js';
import { formatDate } from '../utils/formatDate.js';
import Badge from '../components/common/Badge.jsx';
import EmptyState from '../components/common/EmptyState.jsx';
import LoadingSpinner from '../components/common/LoadingSpinner.jsx';

const PAGE_SIZE = 8;
const TYPE_FILTERS = [
  { value: '', label: 'All Types' },
  { value: TRANSACTION_TYPES.SALE, label: 'Sales' },
  { value: TRANSACTION_TYPES.PURCHASE, label: 'Purchases' },
  { value: TRANSACTION_TYPES.EXPENSE, label: 'Expenses' },
  { value: TRANSACTION_TYPES.UDHAAR_GIVEN, label: 'Udhaar Given' },
  { value: TRANSACTION_TYPES.PAYMENT_RECEIVED, label: 'Payments' },
];

export default function SalesPage() {
  const [transactions, setTransactions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [typeFilter, setTypeFilter] = useState('');
  const [page, setPage] = useState(1);

  useEffect(() => {
    setLoading(true);
    getTransactions()
      .then(setTransactions)
      .finally(() => setLoading(false));
  }, []);

  const filtered = useMemo(() => {
    let txns = transactions;
    if (search) {
      const s = search.toLowerCase();
      txns = txns.filter(t =>
        t.description.toLowerCase().includes(s) ||
        (t.customerName || '').toLowerCase().includes(s)
      );
    }
    if (typeFilter) txns = txns.filter(t => t.type === typeFilter);
    return txns;
  }, [transactions, search, typeFilter]);

  const totalPages = Math.max(1, Math.ceil(filtered.length / PAGE_SIZE));
  const paginated = filtered.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE);

  // Summaries
  const totalSales = transactions.filter(t => t.type === 'sale').reduce((s, t) => s + t.amount, 0);
  const totalExpenses = transactions.filter(t => t.type === 'expense').reduce((s, t) => s + t.amount, 0);
  const totalUdhaar = transactions.filter(t => t.type === 'udhaar_given').reduce((s, t) => s + t.amount, 0);

  return (
    <div className="space-y-5 max-w-7xl mx-auto">
      {/* Summary cards */}
      <div className="grid grid-cols-3 gap-3">
        {[
          { label: 'Total Sales', val: formatCurrency(totalSales), color: '#10b981', bg: '#d1fae5' },
          { label: 'Total Expenses', val: formatCurrency(totalExpenses), color: '#ef4444', bg: '#fee2e2' },
          { label: 'Udhaar Given', val: formatCurrency(totalUdhaar), color: '#f59e0b', bg: '#fef3c7' },
        ].map(({ label, val, color, bg }) => (
          <div key={label} className="stat-card">
            <p className="text-xs text-slate-400 font-semibold uppercase">{label}</p>
            <p className="text-rupee font-bold mt-1" style={{ color }}>{val}</p>
          </div>
        ))}
      </div>

      {/* Filters */}
      <div className="card p-4">
        <div className="flex flex-col sm:flex-row gap-3">
          <div className="relative flex-1">
            <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
            <input
              value={search}
              onChange={e => { setSearch(e.target.value); setPage(1); }}
              placeholder="Search by description or customer…"
              className="input pl-9"
              id="sales-search"
            />
          </div>
          <select
            value={typeFilter}
            onChange={e => { setTypeFilter(e.target.value); setPage(1); }}
            className="input w-auto"
            aria-label="Filter by type"
          >
            {TYPE_FILTERS.map(f => <option key={f.value} value={f.value}>{f.label}</option>)}
          </select>
          <button className="btn btn-secondary gap-1.5 flex-shrink-0" aria-label="Export data">
            <Download size={15} /> Export
          </button>
        </div>
      </div>

      {/* Table */}
      <div className="card overflow-hidden">
        <div className="flex items-center justify-between px-5 py-4 border-b" style={{ borderColor: 'var(--color-border)' }}>
          <h2 className="text-h3 text-slate-800">Transaction History</h2>
          <span className="badge badge-gray">{filtered.length} entries</span>
        </div>

        {loading ? (
          <LoadingSpinner message="Loading transactions…" />
        ) : filtered.length === 0 ? (
          <EmptyState
            icon={ShoppingCart}
            title="No transactions found"
            description="Try changing your filters or record a new sale using the AI Assistant."
          />
        ) : (
          <div className="table-wrapper" style={{ borderRadius: 0, border: 0 }}>
            <table className="table">
              <thead>
                <tr>
                  <th>Date</th>
                  <th>Description</th>
                  <th>Type</th>
                  <th>Mode</th>
                  <th className="text-right">Amount</th>
                </tr>
              </thead>
              <tbody>
                {paginated.map((txn, i) => (
                  <motion.tr
                    key={txn.id}
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    transition={{ delay: i * 0.04 }}
                  >
                    <td className="text-slate-500 text-xs whitespace-nowrap">
                      {formatDate(txn.createdAt, 'medium')}
                    </td>
                    <td>
                      <p className="font-medium text-slate-700">{txn.description || '—'}</p>
                      {txn.customerName && <p className="text-xs text-slate-400">{txn.customerName}</p>}
                    </td>
                    <td>
                      <Badge variant={getTransactionColor(txn.type)}>
                        {getTransactionLabel(txn.type)}
                      </Badge>
                    </td>
                    <td>
                      <span className="badge badge-gray uppercase text-xs">{txn.paymentMode || 'cash'}</span>
                    </td>
                    <td className="text-right font-bold">
                      <span style={{ color: ['sale','payment_received'].includes(txn.type) ? '#065f46' : '#991b1b' }}>
                        {['sale','payment_received'].includes(txn.type) ? '+' : '-'}
                        {formatCurrency(txn.amount)}
                      </span>
                    </td>
                  </motion.tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        {/* Pagination */}
        {totalPages > 1 && (
          <div className="flex items-center justify-between px-5 py-3 border-t" style={{ borderColor: 'var(--color-border)' }}>
            <p className="text-xs text-slate-400">
              Showing {(page - 1) * PAGE_SIZE + 1}–{Math.min(page * PAGE_SIZE, filtered.length)} of {filtered.length}
            </p>
            <div className="flex gap-1">
              <button onClick={() => setPage(p => Math.max(1, p - 1))} disabled={page === 1}
                className="btn btn-ghost btn-icon btn-sm" aria-label="Previous page">
                <ChevronLeft size={16} />
              </button>
              <span className="flex items-center px-3 text-sm font-medium text-slate-600">{page} / {totalPages}</span>
              <button onClick={() => setPage(p => Math.min(totalPages, p + 1))} disabled={page === totalPages}
                className="btn btn-ghost btn-icon btn-sm" aria-label="Next page">
                <ChevronRight size={16} />
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
