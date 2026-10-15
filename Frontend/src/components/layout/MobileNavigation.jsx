import React from 'react';
import { NavLink } from 'react-router-dom';
import { LayoutDashboard, ShoppingCart, Package, Users, MessageSquare } from 'lucide-react';

const MOBILE_NAV = [
  { to: '/dashboard',  icon: LayoutDashboard, label: 'Home' },
  { to: '/sales',      icon: ShoppingCart,    label: 'Sales' },
  { to: '/assistant',  icon: MessageSquare,   label: 'Assistant' },
  { to: '/inventory',  icon: Package,         label: 'Stock' },
  { to: '/customers',  icon: Users,           label: 'Udhaar' },
];

export default function MobileNavigation() {
  return (
    <nav
      className="fixed bottom-0 left-0 right-0 lg:hidden z-40 bg-white border-t"
      style={{ borderColor: 'var(--color-border)' }}
      aria-label="Mobile navigation"
    >
      <ul className="flex">
        {MOBILE_NAV.map(({ to, icon: Icon, label }) => (
          <li key={to} className="flex-1">
            <NavLink
              to={to}
              className={({ isActive }) =>
                `flex flex-col items-center justify-center py-2 px-1 gap-0.5 text-xs font-medium transition-colors ${
                  isActive ? 'text-emerald-500' : 'text-slate-400'
                }`
              }
            >
              {({ isActive }) => (
                <>
                  <Icon size={20} strokeWidth={isActive ? 2.5 : 1.8} />
                  <span>{label}</span>
                </>
              )}
            </NavLink>
          </li>
        ))}
      </ul>
    </nav>
  );
}
