import React, { useEffect, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';
import {
  TrendingUp, TrendingDown, ShoppingCart, Package,
  AlertTriangle, ArrowRight, Mic, Send, Receipt, Wallet
} from 'lucide-react';
import { getDashboardData } from '../services/dashboardService.js';
import { formatCurrency } from '../utils/formatCurrency.js';
import { formatDate, formatRelativeTime } from '../utils/formatDate.js';
import { getTransactionLabel, getTransactionColor } from '../models/transactionModel.js';
import { useApp } from '../context/AppContext.jsx';
import SalesChart from '../components/charts/SalesChart.jsx';
import InventoryChart from '../components/charts/InventoryChart.jsx';
import Badge from '../components/common/Badge.jsx';
import LoadingSpinner from '../components/common/LoadingSpinner.jsx';
import apiClient from '../services/apiClient.js';

function StatCard({ label, value, change, icon: Icon, iconColor, positive }) {
  return (
    <motion.div
      className="stat-card"
      initial={{ opacity: 0, y: 16 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.4 }}
    >
      <div className="flex items-center justify-between mb-2">
        <p className="text-xs font-semibold text-slate-400 uppercase tracking-wide">{label}</p>
        <div className="w-8 h-8 rounded-lg flex items-center justify-center" style={{ background: iconColor + '18' }}>
          <Icon size={16} style={{ color: iconColor }} />
        </div>
      </div>
      <p className="text-rupee text-slate-900">{value}</p>
      {change && (
        <div className="flex items-center gap-1 mt-1">
          {positive !== false ? (
            <TrendingUp size={12} style={{ color: 'var(--color-success)' }} />
          ) : (
            <TrendingDown size={12} style={{ color: 'var(--color-error)' }} />
          )}
          <span className="text-xs font-semibold" style={{ color: positive !== false ? 'var(--color-success)' : 'var(--color-error)' }}>
            {change}
          </span>
          <span className="text-xs text-slate-400">vs yesterday</span>
        </div>
      )}
    </motion.div>
  );
}

export default function DashboardPage() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [quickInput, setQuickInput] = useState('');
  const navigate = useNavigate();
  const { shopName, ownerName, addNotification } = useApp();

  useEffect(() => {
    getDashboardData()
      .then(setData)
      .catch(() => addNotification({ type: 'error', title: 'Load failed', message: 'Could not load dashboard data.' }))
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <LoadingSpinner message="Loading your dashboard…" />;
  if (!data) return null;

  return (
    <div className="space-y-5 max-w-7xl mx-auto">
      {/* Welcome & Shop Branding Banner */}
      <div className="card p-4 sm:p-5 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div className="flex items-center gap-3.5">
          <div className="w-12 h-12 rounded-xl flex items-center justify-center p-2 shrink-0 border border-emerald-100 bg-emerald-50 shadow-xs">
            <img src="/logo-icon.png" alt="Kirana AI" className="h-full w-full object-contain" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h2 className="text-h3 text-slate-900 font-bold">{shopName}</h2>
              <span className="badge badge-success text-[10px]">Active</span>
            </div>
            <p className="text-xs text-slate-400 mt-0.5 flex items-center gap-1.5">
              <span>Smart retail management powered by</span>
              <img src="/logo.png" alt="Kirana AI" className="h-3.5 w-auto object-contain opacity-90 inline-block align-middle" />
            </p>
          </div>
        </div>
        <div className="flex items-center gap-2 text-xs text-slate-500 bg-slate-50 border border-slate-200/80 rounded-xl px-3.5 py-2 self-start sm:self-auto">
          <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
          <span>Real-time shop intelligence</span>
        </div>
      </div>

      {/* Demo Mode Banner */}
      {apiClient.isDemoMode && (
        <div
          className="flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-medium"
          style={{ background: '#fef3c7', color: '#92400e', border: '1px solid #fde68a' }}
        >
          <AlertTriangle size={16} />
          <span><strong>Demo Mode</strong> — Showing sample data. Connect your backend to see real records.</span>
        </div>
      )}

      {/* Stat Cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        <StatCard
          label="Today's Sales"
          value={formatCurrency(data.todaySales)}
          change={data.salesChange}
          icon={ShoppingCart}
          iconColor="#10b981"
          positive
        />
        <StatCard
          label="Revenue"
          value={formatCurrency(data.todayRevenue ?? data.todaySales - data.todayExpenses)}
          change="Net today"
          icon={Wallet}
          iconColor="#477b58"
        />
        <StatCard
          label="Transactions"
          value={`${data.todayTransactions ?? data.recentTransactions.length} today`}
          icon={Receipt}
          iconColor="#758a72"
        />
        <StatCard
          label="Low Stock Items"
          value={`${data.lowStockCount} items`}
          icon={Package}
          iconColor="#ef4444"
        />
      </div>

      {/* Charts Row */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-5">
        {/* Sales Chart */}
        <div className="card p-5 lg:col-span-2">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h2 className="text-h3 text-slate-800">Weekly Overview</h2>
              <p className="text-xs text-slate-400 mt-0.5">Sales vs Expenses</p>
            </div>
            <span className="badge badge-success text-xs">This Week</span>
          </div>
          <SalesChart data={data.weeklyData} />
        </div>

        {/* Top Products */}
        <div className="card p-5">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-h3 text-slate-800">Top Products</h2>
            <Link to="/inventory" className="text-xs text-emerald-600 font-semibold hover:underline flex items-center gap-1">
              View all <ArrowRight size={12} />
            </Link>
          </div>
          <InventoryChart data={data.topProducts} height={200} />
          <div className="mt-3 space-y-2">
            {data.topProducts.slice(0, 4).map((p, i) => (
              <div key={p.name} className="flex items-center justify-between text-sm">
                <div className="flex items-center gap-2">
                  <span className="w-5 h-5 rounded-md flex items-center justify-center text-xs font-bold text-white"
                    style={{ background: ['#10b981','#059669','#047857','#065f46'][i] }}>
                    {i + 1}
                  </span>
                  <span className="text-slate-700 truncate max-w-[100px]">{p.name}</span>
                </div>
                <span className="font-semibold text-slate-800">{formatCurrency(p.revenue)}</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Quick AI Input + Recent Transactions */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
        {/* Quick AI Input */}
        <div className="card p-5">
          <h2 className="text-h3 text-slate-800 mb-1">Quick Record</h2>
          <p className="text-xs text-slate-400 mb-4">Type a sale, purchase, or udhaar in plain language</p>

          <div className="flex gap-2 mb-3">
            <input
              value={quickInput}
              onChange={e => setQuickInput(e.target.value)}
              className="input flex-1"
              placeholder="e.g. Sold rice 250 rs cash..."
              id="quick-record-input"
            />
            <Link to="/assistant" className="btn btn-ghost btn-icon text-slate-400" aria-label="Use voice input">
              <Mic size={18} />
            </Link>
            <button
              className="btn btn-primary btn-icon"
              aria-label="Send"
              onClick={() => {
                if (quickInput.trim()) {
                  navigate('/assistant', { state: { draftMessage: quickInput.trim() } });
                  setQuickInput('');
                }
              }}
            >
              <Send size={16} />
            </button>
          </div>

          {/* Suggested prompts */}
          <div className="flex flex-wrap gap-2">
            {[
              'Sold 5 kg rice ₹250 cash',
              'Ramesh ko ₹500 udhaar',
              'Show today\'s summary',
              'Which items low stock?',
            ].map(prompt => (
              <button
                key={prompt}
                onClick={() => setQuickInput(prompt)}
                className="text-xs px-3 py-1.5 rounded-full border font-medium transition-colors hover:border-emerald-400 hover:text-emerald-700"
                style={{ borderColor: 'var(--color-border)', color: 'var(--color-text-muted)', background: '#f8fafc' }}
              >
                {prompt}
              </button>
            ))}
          </div>

          <div className="mt-4 flex flex-wrap items-center gap-x-5 gap-y-2">
            <Link
              to="/assistant"
              state={{ draftMessage: 'Sold 5 kg rice for ₹300 cash' }}
              className="flex items-center gap-2 text-sm font-semibold text-emerald-700 hover:text-emerald-800 transition-colors"
            >
              <ShoppingCart size={14} /> Add a sale <ArrowRight size={14} />
            </Link>
            <Link
              to="/assistant"
              className="flex items-center gap-2 text-sm font-semibold text-slate-500 hover:text-slate-700 transition-colors"
            >
              Open full AI Assistant <ArrowRight size={14} />
            </Link>
          </div>
        </div>

        {/* Recent Transactions */}
        <div className="card p-5">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-h3 text-slate-800">Recent Activity</h2>
            <Link to="/sales" className="text-xs text-emerald-600 font-semibold hover:underline flex items-center gap-1">
              View all <ArrowRight size={12} />
            </Link>
          </div>
          <div className="space-y-2">
            {data.recentTransactions.map((txn, i) => (
              <motion.div
                key={txn.id || i}
                initial={{ opacity: 0, x: -8 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: i * 0.05 }}
                className="flex items-center gap-3 py-2 border-b last:border-0"
                style={{ borderColor: '#f1f5f9' }}
              >
                <div className="w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0"
                  style={{ background: txn.type === 'sale' ? '#d1fae5' : txn.type === 'expense' ? '#fee2e2' : '#fef3c7' }}>
                  <ShoppingCart size={14} style={{ color: txn.type === 'sale' ? '#065f46' : txn.type === 'expense' ? '#991b1b' : '#92400e' }} />
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium text-slate-700 truncate">{txn.description}</p>
                  <p className="text-xs text-slate-400">{formatRelativeTime(txn.createdAt)}</p>
                </div>
                <div className="text-right flex-shrink-0">
                  <p className="text-sm font-bold" style={{ color: ['sale','payment_received'].includes(txn.type) ? '#065f46' : '#991b1b' }}>
                    {['sale','payment_received'].includes(txn.type) ? '+' : '-'}{formatCurrency(txn.amount)}
                  </p>
                  <Badge variant={getTransactionColor(txn.type)} className="text-xs mt-0.5">
                    {txn.paymentMode?.toUpperCase() || 'CASH'}
                  </Badge>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
