import React from 'react';
import { NavLink, useLocation } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import {
  LayoutDashboard, ShoppingCart, Package, Users,
  BarChart3, MessageSquare, Settings, X, Zap
} from 'lucide-react';
import { useApp } from '../../context/AppContext.jsx';

const NAV_ITEMS = [
  { to: '/dashboard',  icon: LayoutDashboard, label: 'Dashboard' },
  { to: '/assistant',  icon: MessageSquare,   label: 'AI Assistant', badge: 'AI' },
  { to: '/sales',      icon: ShoppingCart,    label: 'Sales Ledger' },
  { to: '/inventory',  icon: Package,         label: 'Inventory' },
  { to: '/customers',  icon: Users,           label: 'Customers' },
  { to: '/reports',    icon: BarChart3,       label: 'Reports' },
  { to: '/settings',   icon: Settings,        label: 'Settings' },
];

export default function Sidebar() {
  const { shopName, sidebarOpen, setSidebarOpen } = useApp();
  const location = useLocation();

  return (
    <>
      {/* Mobile overlay */}
      <AnimatePresence>
        {sidebarOpen && (
          <motion.div
            className="fixed inset-0 z-40 lg:hidden"
            style={{ background: 'rgba(15,23,42,0.6)' }}
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={() => setSidebarOpen(false)}
            aria-hidden="true"
          />
        )}
      </AnimatePresence>

      <aside
        className={`sidebar ${sidebarOpen ? 'open' : ''}`}
        style={{ width: 256 }}
        aria-label="Main navigation"
      >
        {/* Logo */}
        <div className="flex items-center justify-between px-5 py-5 border-b border-white/10">
          <div className="flex items-center gap-3">
            <div
              className="w-9 h-9 rounded-xl flex items-center justify-center"
              style={{ background: 'var(--color-primary)' }}
            >
              <Zap size={18} className="text-white" />
            </div>
            <div>
              <p className="text-white font-bold text-sm leading-tight">Kirana AI</p>
              <p className="text-white/40 text-xs leading-tight">Smart Ledger</p>
            </div>
          </div>
          <button
            onClick={() => setSidebarOpen(false)}
            className="lg:hidden text-white/40 hover:text-white/70 transition-colors"
            aria-label="Close sidebar"
          >
            <X size={20} />
          </button>
        </div>

        {/* Shop name */}
        <div className="px-5 py-3 border-b border-white/10">
          <p className="text-white/40 text-label text-xs mb-0.5">Your Shop</p>
          <p className="text-white font-semibold text-sm truncate">{shopName}</p>
        </div>

        {/* Navigation */}
        <nav className="flex-1 overflow-y-auto py-3 px-3" role="navigation">
          <ul className="space-y-0.5">
            {NAV_ITEMS.map(({ to, icon: Icon, label, badge }) => (
              <li key={to}>
                <NavLink
                  to={to}
                  onClick={() => setSidebarOpen(false)}
                  className={({ isActive }) =>
                    `flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-all duration-150 relative group ${
                      isActive
                        ? 'bg-emerald-500 text-white shadow-sm'
                        : 'text-white/60 hover:text-white hover:bg-white/8'
                    }`
                  }
                  style={({ isActive }) => isActive ? { background: 'var(--color-primary)' } : {}}
                >
                  <Icon size={18} />
                  <span>{label}</span>
                  {badge && (
                    <span
                      className="ml-auto text-xs font-bold px-1.5 py-0.5 rounded-md"
                      style={{ background: 'rgba(255,255,255,0.15)', color: 'inherit', fontSize: '10px' }}
                    >
                      {badge}
                    </span>
                  )}
                </NavLink>
              </li>
            ))}
          </ul>
        </nav>

        {/* Demo mode badge */}
        <div className="px-5 py-4 border-t border-white/10">
          <div
            className="flex items-center gap-2 px-3 py-2 rounded-xl"
            style={{ background: 'rgba(16,185,129,0.15)' }}
          >
            <span
              className="w-2 h-2 rounded-full animate-pulse-ring"
              style={{ background: 'var(--color-primary)', flexShrink: 0 }}
            />
            <span className="text-xs text-emerald-400 font-medium">Demo Mode Active</span>
          </div>
        </div>
      </aside>
    </>
  );
}
