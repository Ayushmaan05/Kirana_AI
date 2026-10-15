import React, { useEffect, useState, useMemo } from 'react';
import { motion } from 'framer-motion';
import { Search, UserPlus, Phone, IndianRupee, ChevronRight, CheckCircle2 } from 'lucide-react';
import { getCustomers, addCustomer, recordUdhaarPayment } from '../services/customerService.js';
import { getCustomerStatus } from '../models/customerModel.js';
import { formatCurrency } from '../utils/formatCurrency.js';
import { formatDate } from '../utils/formatDate.js';
import Badge from '../components/common/Badge.jsx';
import EmptyState from '../components/common/EmptyState.jsx';
import LoadingSpinner from '../components/common/LoadingSpinner.jsx';
import Modal from '../components/common/Modal.jsx';
import Button from '../components/common/Button.jsx';
import Input from '../components/common/Input.jsx';
import { useApp } from '../context/AppContext.jsx';

function PaymentModal({ customer, onClose, onPaid }) {
  const [amount, setAmount] = useState('');
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  async function handlePay() {
    const amt = Number(amount);
    if (!amt || amt <= 0) { setError('Enter a valid amount'); return; }
    if (amt > customer.outstandingBalance) { setError(`Max payable: ${formatCurrency(customer.outstandingBalance)}`); return; }
    setSaving(true);
    try {
      await recordUdhaarPayment(customer.id, amt);
      onPaid(customer.id, amt);
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="space-y-4">
      <div className="p-4 rounded-xl" style={{ background: '#f0fdf4' }}>
        <p className="text-sm text-slate-600">Customer: <strong>{customer.name}</strong></p>
        <p className="text-sm text-slate-600 mt-1">Outstanding: <strong className="text-red-600">{formatCurrency(customer.outstandingBalance)}</strong></p>
      </div>
      <Input
        label="Payment Amount (₹)"
        type="number"
        min="1"
        max={customer.outstandingBalance}
        value={amount}
        onChange={e => { setAmount(e.target.value); setError(''); }}
        error={error}
        required
        id="payment-amount"
        placeholder={`Max: ₹${customer.outstandingBalance}`}
      />
      <div className="flex gap-2">
        <Button variant="secondary" onClick={onClose} className="flex-1">Cancel</Button>
        <Button variant="primary" loading={saving} onClick={handlePay} className="flex-1" icon={CheckCircle2}>
          Record Payment
        </Button>
      </div>
    </div>
  );
}

export default function CustomersPage() {
  const [customers, setCustomers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [selected, setSelected] = useState(null);
  const [payingCustomer, setPayingCustomer] = useState(null);
  const [showAdd, setShowAdd] = useState(false);
  const [newName, setNewName] = useState('');
  const [newPhone, setNewPhone] = useState('');
  const [addSaving, setAddSaving] = useState(false);
  const { addNotification } = useApp();

  useEffect(() => { loadCustomers(); }, []);

  async function loadCustomers() {
    setLoading(true);
    try { setCustomers(await getCustomers()); }
    finally { setLoading(false); }
  }

  const filtered = useMemo(() => {
    if (!search) return customers;
    const s = search.toLowerCase();
    return customers.filter(c => c.name.toLowerCase().includes(s) || c.phone.includes(s));
  }, [customers, search]);

  const totalOutstanding = customers.reduce((s, c) => s + c.outstandingBalance, 0);

  function handlePaid(customerId, amount) {
    setCustomers(prev => prev.map(c =>
      c.id === customerId ? { ...c, outstandingBalance: Math.max(0, c.outstandingBalance - amount) } : c
    ));
    setPayingCustomer(null);
    if (selected?.id === customerId) setSelected(s => ({ ...s, outstandingBalance: Math.max(0, s.outstandingBalance - amount) }));
    addNotification({ type: 'success', title: 'Payment Recorded', message: `₹${amount} received from ${payingCustomer?.name}.` });
  }

  async function handleAddCustomer() {
    if (!newName.trim()) return;
    setAddSaving(true);
    try {
      const c = await addCustomer({ name: newName, phone: newPhone });
      setCustomers(prev => [c, ...prev]);
      setShowAdd(false);
      setNewName(''); setNewPhone('');
      addNotification({ type: 'success', title: 'Customer Added', message: `${c.name} added.` });
    } finally {
      setAddSaving(false);
    }
  }

  return (
    <div className="max-w-7xl mx-auto space-y-5">
      {/* Summary */}
      <div className="grid grid-cols-3 gap-3">
        {[
          { label: 'Total Customers', val: customers.length, color: '#10b981' },
          { label: 'Outstanding Udhaar', val: formatCurrency(totalOutstanding), color: '#ef4444' },
          { label: 'Cleared Accounts', val: customers.filter(c => c.outstandingBalance === 0).length, color: '#3b82f6' },
        ].map(({ label, val, color }) => (
          <div key={label} className="stat-card">
            <p className="text-xs text-slate-400 font-semibold uppercase">{label}</p>
            <p className="text-rupee font-bold mt-1" style={{ color }}>{val}</p>
          </div>
        ))}
      </div>

      {/* Controls */}
      <div className="flex gap-3 items-center">
        <div className="relative flex-1">
          <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
          <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search customers…" className="input pl-9" id="customers-search" />
        </div>
        <Button icon={UserPlus} onClick={() => setShowAdd(true)} id="add-customer-btn">Add Customer</Button>
      </div>

      {/* List + Detail */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
        {/* Customer list */}
        <div className="card overflow-hidden">
          <div className="px-5 py-4 border-b flex items-center justify-between" style={{ borderColor: 'var(--color-border)' }}>
            <h2 className="text-h3 text-slate-800">Customer List</h2>
            <span className="badge badge-gray">{filtered.length}</span>
          </div>
          {loading ? <LoadingSpinner /> : filtered.length === 0 ? (
            <EmptyState icon={UserPlus} title="No customers yet" description="Add your first customer to start tracking udhaar." />
          ) : (
            <ul className="divide-y" style={{ borderColor: '#f1f5f9' }}>
              {filtered.map((c, i) => {
                const status = getCustomerStatus(c.outstandingBalance);
                const isSelected = selected?.id === c.id;
                return (
                  <motion.li
                    key={c.id}
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    transition={{ delay: i * 0.04 }}
                    className={`flex items-center gap-3 px-5 py-3.5 cursor-pointer transition-colors ${isSelected ? 'bg-emerald-50' : 'hover:bg-slate-50'}`}
                    onClick={() => setSelected(c)}
                  >
                    <div className="w-10 h-10 rounded-xl flex items-center justify-center font-bold text-sm text-white flex-shrink-0"
                      style={{ background: 'var(--color-primary)' }}>
                      {c.name.charAt(0)}
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="font-semibold text-slate-800 text-sm truncate">{c.name}</p>
                      <p className="text-xs text-slate-400 flex items-center gap-1">
                        {c.phone ? <><Phone size={11} />{c.phone}</> : 'No phone'}
                      </p>
                    </div>
                    <div className="text-right flex-shrink-0">
                      <p className="font-bold text-sm" style={{ color: c.outstandingBalance > 0 ? '#ef4444' : '#10b981' }}>
                        {formatCurrency(c.outstandingBalance)}
                      </p>
                      <Badge variant={status.color} className="text-xs">{status.label}</Badge>
                    </div>
                    <ChevronRight size={16} className="text-slate-300 flex-shrink-0" />
                  </motion.li>
                );
              })}
            </ul>
          )}
        </div>

        {/* Customer detail */}
        <div className="card p-5">
          {selected ? (
            <div>
              <div className="flex items-start gap-4 mb-5">
                <div className="w-14 h-14 rounded-2xl flex items-center justify-center font-black text-xl text-white"
                  style={{ background: 'linear-gradient(135deg, #10b981, #047857)' }}>
                  {selected.name.charAt(0)}
                </div>
                <div className="flex-1">
                  <h2 className="text-h2 text-slate-800">{selected.name}</h2>
                  {selected.phone && <p className="text-sm text-slate-400 flex items-center gap-1 mt-0.5"><Phone size={13} /> {selected.phone}</p>}
                </div>
              </div>

              <div className="grid grid-cols-3 gap-3 mb-5">
                {[
                  { label: 'Total Bought', val: formatCurrency(selected.totalPurchased), color: '#3b82f6' },
                  { label: 'Total Paid', val: formatCurrency(selected.totalPaid), color: '#10b981' },
                  { label: 'Outstanding', val: formatCurrency(selected.outstandingBalance), color: selected.outstandingBalance > 0 ? '#ef4444' : '#10b981' },
                ].map(({ label, val, color }) => (
                  <div key={label} className="p-3 rounded-xl text-center" style={{ background: '#f8fafc' }}>
                    <p className="text-xs text-slate-400 mb-1">{label}</p>
                    <p className="font-bold text-sm" style={{ color }}>{val}</p>
                  </div>
                ))}
              </div>

              {selected.lastTransaction && (
                <p className="text-xs text-slate-400 mb-4">Last transaction: {formatDate(selected.lastTransaction)}</p>
              )}

              {selected.outstandingBalance > 0 && (
                <Button
                  variant="primary"
                  className="w-full"
                  icon={IndianRupee}
                  onClick={() => setPayingCustomer(selected)}
                  id="record-payment-btn"
                >
                  Record Payment from {selected.name.split(' ')[0]}
                </Button>
              )}
              {selected.outstandingBalance === 0 && (
                <div className="flex items-center gap-2 justify-center text-emerald-600 font-semibold text-sm py-3">
                  <CheckCircle2 size={18} /> Account cleared! No outstanding balance.
                </div>
              )}
            </div>
          ) : (
            <div className="flex flex-col items-center justify-center h-full py-12 text-center">
              <div className="w-14 h-14 rounded-2xl flex items-center justify-center mb-3" style={{ background: 'var(--color-primary-light)' }}>
                <UserPlus size={24} style={{ color: 'var(--color-primary)' }} />
              </div>
              <p className="text-slate-500 text-sm">Select a customer to view details and record payments.</p>
            </div>
          )}
        </div>
      </div>

      {/* Payment Modal */}
      {payingCustomer && (
        <Modal isOpen={!!payingCustomer} onClose={() => setPayingCustomer(null)} title="Record Payment" size="sm">
          <PaymentModal customer={payingCustomer} onClose={() => setPayingCustomer(null)} onPaid={handlePaid} />
        </Modal>
      )}

      {/* Add Customer Modal */}
      <Modal isOpen={showAdd} onClose={() => setShowAdd(false)} title="Add Customer" size="sm">
        <div className="space-y-4">
          <Input label="Customer Name" value={newName} onChange={e => setNewName(e.target.value)} required id="new-customer-name" placeholder="Ramesh Kumar" />
          <Input label="Phone Number (optional)" value={newPhone} onChange={e => setNewPhone(e.target.value)} id="new-customer-phone" placeholder="98XXXXXXXX" />
          <div className="flex gap-2">
            <Button variant="secondary" onClick={() => setShowAdd(false)} className="flex-1">Cancel</Button>
            <Button variant="primary" loading={addSaving} onClick={handleAddCustomer} className="flex-1">Add Customer</Button>
          </div>
        </div>
      </Modal>
    </div>
  );
}
