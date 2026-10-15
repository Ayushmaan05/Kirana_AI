import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { Download, TrendingUp, TrendingDown, FileText, BarChart3 } from 'lucide-react';
import {
  AreaChart, Area, BarChart, Bar, PieChart, Pie, Cell,
  XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend
} from 'recharts';
import { formatCurrency } from '../utils/formatCurrency.js';

const MONTHLY_DATA = [
  { month: 'May', sales: 48000, expenses: 18000, udhaar: 5200 },
  { month: 'Jun', sales: 52000, expenses: 20000, udhaar: 4800 },
  { month: 'Jul', sales: 61000, expenses: 22000, udhaar: 7100 },
  { month: 'Aug', sales: 57000, expenses: 21000, udhaar: 6200 },
  { month: 'Sep', sales: 68000, expenses: 24000, udhaar: 5900 },
  { month: 'Oct', sales: 72000, expenses: 26000, udhaar: 8350 },
];

const PIE_DATA = [
  { name: 'Cash', value: 38000, color: '#10b981' },
  { name: 'UPI', value: 28000, color: '#3b82f6' },
  { name: 'Credit', value: 6000, color: '#f59e0b' },
];

const GST_ITEMS = [
  { category: 'Packaged Food (5% GST)', taxable: 28000, gst: 1400 },
  { category: 'Branded Snacks (12% GST)', taxable: 12000, gst: 1440 },
  { category: 'Exempt Items (0% GST)', taxable: 32000, gst: 0 },
];

const TABS = ['Overview', 'Monthly Trend', 'Payment Modes', 'GST Report'];

const CustomTooltip = ({ active, payload, label }) => {
  if (!active || !payload?.length) return null;
  return (
    <div className="card px-3 py-2 shadow-md text-sm">
      <p className="font-semibold text-slate-700 mb-1">{label}</p>
      {payload.map(e => (
        <div key={e.name} className="flex items-center gap-2">
          <span className="w-2 h-2 rounded-full" style={{ background: e.color }} />
          <span className="text-slate-500">{e.name}:</span>
          <span className="font-bold text-slate-800">{formatCurrency(e.value)}</span>
        </div>
      ))}
    </div>
  );
};

export default function ReportsPage() {
  const [tab, setTab] = useState('Overview');

  const currentMonth = MONTHLY_DATA[MONTHLY_DATA.length - 1];
  const prevMonth = MONTHLY_DATA[MONTHLY_DATA.length - 2];
  const salesGrowth = (((currentMonth.sales - prevMonth.sales) / prevMonth.sales) * 100).toFixed(1);

  return (
    <div className="space-y-5 max-w-7xl mx-auto">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-h2 text-slate-800">Business Reports</h2>
          <p className="text-sm text-slate-400">October 2026 · Last 6 months</p>
        </div>
        <button className="btn btn-secondary gap-2">
          <Download size={16} /> Export PDF
        </button>
      </div>

      <div className="rounded-xl border border-amber-200 bg-amber-50 px-4 py-3 text-sm text-amber-900">
        <strong>Demo data.</strong> These sample figures are for preview only and are not your shop’s actual sales or GST records.
      </div>

      {/* Tab navigation */}
      <div className="card p-1.5 flex gap-1 overflow-x-auto no-scrollbar">
        {TABS.map(t => (
          <button
            key={t}
            onClick={() => setTab(t)}
            className={`flex-shrink-0 px-4 py-2 rounded-xl text-sm font-semibold transition-all ${
              tab === t ? 'text-white shadow-sm' : 'text-slate-500 hover:text-slate-700'
            }`}
            style={tab === t ? { background: 'var(--color-primary)' } : {}}
          >
            {t}
          </button>
        ))}
      </div>

      {/* Overview */}
      {tab === 'Overview' && (
        <div className="space-y-5">
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
            {[
              { label: 'Monthly Sales', val: formatCurrency(currentMonth.sales), icon: TrendingUp, color: '#10b981', change: `+${salesGrowth}%` },
              { label: 'Monthly Expenses', val: formatCurrency(currentMonth.expenses), icon: TrendingDown, color: '#ef4444', change: '+8.3%' },
              { label: 'Pending Udhaar', val: formatCurrency(currentMonth.udhaar), icon: FileText, color: '#f59e0b', change: '+41.5%' },
              { label: 'Avg Daily Sales', val: formatCurrency(Math.round(currentMonth.sales / 30)), icon: BarChart3, color: '#3b82f6' },
            ].map(({ label, val, icon: Icon, color, change }) => (
              <div key={label} className="stat-card">
                <div className="flex items-center justify-between mb-2">
                  <p className="text-xs text-slate-400 font-semibold uppercase">{label}</p>
                  <Icon size={16} style={{ color }} />
                </div>
                <p className="text-rupee font-bold text-slate-900">{val}</p>
                {change && <p className="text-xs font-semibold mt-1" style={{ color }}>{change} vs last month</p>}
              </div>
            ))}
          </div>

          <div className="card p-5">
            <h3 className="text-h3 text-slate-800 mb-4">6-Month Sales Trend</h3>
            <ResponsiveContainer width="100%" height={240}>
              <AreaChart data={MONTHLY_DATA} margin={{ top: 4, right: 8, left: -10, bottom: 0 }}>
                <defs>
                  <linearGradient id="rSales" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#10b981" stopOpacity={0.18} />
                    <stop offset="95%" stopColor="#10b981" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
                <XAxis dataKey="month" tick={{ fontSize: 12, fill: '#94a3b8' }} axisLine={false} tickLine={false} />
                <YAxis tick={{ fontSize: 12, fill: '#94a3b8' }} axisLine={false} tickLine={false}
                  tickFormatter={v => formatCurrency(v, { compact: true })} />
                <Tooltip content={<CustomTooltip />} />
                <Area type="monotone" dataKey="sales" name="Sales" stroke="#10b981" strokeWidth={2.5} fill="url(#rSales)" />
                <Area type="monotone" dataKey="expenses" name="Expenses" stroke="#f59e0b" strokeWidth={2} fill="none" strokeDasharray="5 3" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>
      )}

      {/* Monthly Trend */}
      {tab === 'Monthly Trend' && (
        <div className="card p-5">
          <h3 className="text-h3 text-slate-800 mb-4">Monthly Sales vs Expenses</h3>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={MONTHLY_DATA} margin={{ top: 4, right: 8, left: -10, bottom: 0 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" vertical={false} />
              <XAxis dataKey="month" tick={{ fontSize: 12, fill: '#94a3b8' }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fontSize: 12, fill: '#94a3b8' }} axisLine={false} tickLine={false}
                tickFormatter={v => formatCurrency(v, { compact: true })} />
              <Tooltip content={<CustomTooltip />} />
              <Legend wrapperStyle={{ fontSize: 12 }} iconType="circle" iconSize={8} />
              <Bar dataKey="sales" name="Sales" fill="#10b981" radius={[4, 4, 0, 0]} />
              <Bar dataKey="expenses" name="Expenses" fill="#fbbf24" radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>
      )}

      {/* Payment Modes */}
      {tab === 'Payment Modes' && (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
          <div className="card p-5">
            <h3 className="text-h3 text-slate-800 mb-4">Sales by Payment Mode</h3>
            <ResponsiveContainer width="100%" height={250}>
              <PieChart>
                <Pie data={PIE_DATA} dataKey="value" nameKey="name" cx="50%" cy="50%" outerRadius={90} paddingAngle={3}>
                  {PIE_DATA.map(({ color }, i) => <Cell key={i} fill={color} />)}
                </Pie>
                <Tooltip formatter={v => formatCurrency(v)} />
                <Legend wrapperStyle={{ fontSize: 12 }} iconType="circle" iconSize={8} />
              </PieChart>
            </ResponsiveContainer>
          </div>
          <div className="card p-5">
            <h3 className="text-h3 text-slate-800 mb-4">Breakdown</h3>
            <div className="space-y-4 mt-6">
              {PIE_DATA.map(({ name, value, color }) => (
                <div key={name}>
                  <div className="flex justify-between text-sm mb-1">
                    <span className="font-medium text-slate-700">{name}</span>
                    <span className="font-bold text-slate-800">{formatCurrency(value)}</span>
                  </div>
                  <div className="h-2 rounded-full bg-slate-100">
                    <div className="h-full rounded-full" style={{
                      width: `${(value / PIE_DATA.reduce((s, p) => s + p.value, 0)) * 100}%`,
                      background: color,
                    }} />
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* GST Report */}
      {tab === 'GST Report' && (
        <div className="space-y-4">
          <div
            className="flex items-start gap-3 p-4 rounded-xl text-sm"
            style={{ background: '#fffbeb', border: '1px solid #fde68a', color: '#92400e' }}
          >
            <FileText size={18} className="flex-shrink-0 mt-0.5" />
            <div>
              <p className="font-semibold mb-0.5">GST Report Preview</p>
              <p>This is a tax-oriented summary for reference. Consult a qualified CA for filing. Kirana AI does not file returns on your behalf.</p>
            </div>
          </div>

          <div className="card overflow-hidden">
            <div className="px-5 py-4 border-b flex items-center justify-between" style={{ borderColor: 'var(--color-border)' }}>
              <h3 className="text-h3 text-slate-800">GST Summary — October 2026</h3>
              <button className="btn btn-secondary btn-sm gap-1"><Download size={14} /> CSV</button>
            </div>
            <div className="table-wrapper" style={{ border: 0, borderRadius: 0 }}>
              <table className="table">
                <thead>
                  <tr>
                    <th>Category</th>
                    <th className="text-right">Taxable Value</th>
                    <th className="text-right">GST Amount</th>
                    <th className="text-right">Total</th>
                  </tr>
                </thead>
                <tbody>
                  {GST_ITEMS.map(item => (
                    <tr key={item.category}>
                      <td className="font-medium text-slate-700">{item.category}</td>
                      <td className="text-right">{formatCurrency(item.taxable)}</td>
                      <td className="text-right font-semibold" style={{ color: item.gst > 0 ? '#ef4444' : '#10b981' }}>
                        {formatCurrency(item.gst)}
                      </td>
                      <td className="text-right font-bold text-slate-800">{formatCurrency(item.taxable + item.gst)}</td>
                    </tr>
                  ))}
                  <tr style={{ borderTop: '2px solid var(--color-border)' }}>
                    <td className="font-bold text-slate-900">Total</td>
                    <td className="text-right font-bold">{formatCurrency(GST_ITEMS.reduce((s, i) => s + i.taxable, 0))}</td>
                    <td className="text-right font-bold text-red-600">{formatCurrency(GST_ITEMS.reduce((s, i) => s + i.gst, 0))}</td>
                    <td className="text-right font-black text-slate-900">{formatCurrency(GST_ITEMS.reduce((s, i) => s + i.taxable + i.gst, 0))}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
