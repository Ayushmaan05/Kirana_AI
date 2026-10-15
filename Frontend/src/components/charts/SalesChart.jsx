import React from 'react';
import {
  AreaChart, Area, XAxis, YAxis, CartesianGrid,
  Tooltip, ResponsiveContainer, Legend
} from 'recharts';
import { formatCurrency } from '../../utils/formatCurrency.js';

const CustomTooltip = ({ active, payload, label }) => {
  if (!active || !payload?.length) return null;
  return (
    <div className="card px-4 py-3 shadow-lg text-sm" style={{ minWidth: 160 }}>
      <p className="font-semibold text-slate-700 mb-1">{label}</p>
      {payload.map(entry => (
        <div key={entry.dataKey} className="flex items-center gap-2">
          <span className="w-2 h-2 rounded-full" style={{ background: entry.color }} />
          <span className="text-slate-500 capitalize">{entry.name}:</span>
          <span className="font-semibold text-slate-800">{formatCurrency(entry.value)}</span>
        </div>
      ))}
    </div>
  );
};

export default function SalesChart({ data = [], height = 260 }) {
  return (
    <ResponsiveContainer width="100%" height={height}>
      <AreaChart data={data} margin={{ top: 4, right: 8, left: -10, bottom: 0 }}>
        <defs>
          <linearGradient id="salesGrad" x1="0" y1="0" x2="0" y2="1">
            <stop offset="5%"  stopColor="#10b981" stopOpacity={0.18} />
            <stop offset="95%" stopColor="#10b981" stopOpacity={0.01} />
          </linearGradient>
          <linearGradient id="expGrad" x1="0" y1="0" x2="0" y2="1">
            <stop offset="5%"  stopColor="#f59e0b" stopOpacity={0.15} />
            <stop offset="95%" stopColor="#f59e0b" stopOpacity={0.01} />
          </linearGradient>
        </defs>
        <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
        <XAxis dataKey="day" tick={{ fontSize: 12, fill: '#94a3b8' }} axisLine={false} tickLine={false} />
        <YAxis tick={{ fontSize: 12, fill: '#94a3b8' }} axisLine={false} tickLine={false}
          tickFormatter={v => formatCurrency(v, { compact: true })} />
        <Tooltip content={<CustomTooltip />} cursor={{ stroke: '#e2e8f0', strokeWidth: 1 }} />
        <Legend
          wrapperStyle={{ fontSize: 12, paddingTop: 8 }}
          iconType="circle" iconSize={8}
        />
        <Area
          type="monotone" dataKey="sales" name="Sales"
          stroke="#10b981" strokeWidth={2.5}
          fill="url(#salesGrad)" dot={false} activeDot={{ r: 4, fill: '#10b981' }}
        />
        <Area
          type="monotone" dataKey="expenses" name="Expenses"
          stroke="#f59e0b" strokeWidth={2}
          fill="url(#expGrad)" dot={false} activeDot={{ r: 4, fill: '#f59e0b' }}
          strokeDasharray="5 3"
        />
      </AreaChart>
    </ResponsiveContainer>
  );
}
