import React from 'react';
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid,
  Tooltip, ResponsiveContainer, Cell
} from 'recharts';

const COLORS = ['#10b981','#059669','#047857','#065f46','#064e3b'];

const CustomTooltip = ({ active, payload, label }) => {
  if (!active || !payload?.length) return null;
  return (
    <div className="card px-3 py-2 shadow-md text-sm">
      <p className="font-semibold text-slate-700 text-xs">{label}</p>
      <p className="text-emerald-600 font-bold">{payload[0].value} units</p>
    </div>
  );
};

export default function InventoryChart({ data = [], height = 200 }) {
  return (
    <ResponsiveContainer width="100%" height={height}>
      <BarChart data={data} margin={{ top: 4, right: 4, left: -20, bottom: 0 }}>
        <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" vertical={false} />
        <XAxis dataKey="name" tick={{ fontSize: 11, fill: '#94a3b8' }} axisLine={false} tickLine={false}
          tickFormatter={v => v.length > 10 ? v.slice(0, 10) + '…' : v}
        />
        <YAxis tick={{ fontSize: 11, fill: '#94a3b8' }} axisLine={false} tickLine={false} />
        <Tooltip content={<CustomTooltip />} cursor={{ fill: 'rgba(16,185,129,0.05)' }} />
        <Bar dataKey="sales" radius={[6, 6, 0, 0]}>
          {data.map((_, i) => <Cell key={i} fill={COLORS[i % COLORS.length]} />)}
        </Bar>
      </BarChart>
    </ResponsiveContainer>
  );
}
