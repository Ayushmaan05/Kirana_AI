import React from 'react';
import { useLocation } from 'react-router-dom';
import { Menu, Bell, Search } from 'lucide-react';
import { useApp } from '../../context/AppContext.jsx';

const PAGE_TITLES = {
  '/dashboard': 'Dashboard',
  '/assistant': 'AI Assistant',
  '/sales':     'Sales & Ledger',
  '/inventory': 'Inventory',
  '/customers': 'Customer Credit',
  '/reports':   'Reports',
  '/settings':  'Settings',
};

export default function Header() {
  const { setSidebarOpen, ownerName } = useApp();
  const location = useLocation();
  const title = PAGE_TITLES[location.pathname] || 'Kirana AI';

  const now = new Date();
  const hour = now.getHours();
  const greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';

  return (
    <header
      className="flex items-center justify-between px-5 py-3 bg-white border-b sticky top-0 z-30"
      style={{ borderColor: 'var(--color-border)' }}
    >
      {/* Left: hamburger + title */}
      <div className="flex items-center gap-3">
        <button
          onClick={() => setSidebarOpen(true)}
          className="lg:hidden btn btn-ghost btn-icon text-slate-500"
          aria-label="Open navigation menu"
        >
          <Menu size={22} />
        </button>
        <div>
          <h1 className="text-h3 text-slate-800">{title}</h1>
          <p className="text-xs text-slate-400 leading-none mt-0.5 hidden sm:block">
            {greeting}, {ownerName.split(' ')[0]}! 👋
          </p>
        </div>
      </div>

      {/* Right: search + notifications + avatar */}
      <div className="flex items-center gap-2">
        <button
          className="hidden sm:flex btn btn-ghost btn-icon text-slate-400 hover:text-slate-600"
          aria-label="Search"
        >
          <Search size={18} />
        </button>
        <button
          className="btn btn-ghost btn-icon text-slate-400 hover:text-slate-600 relative"
          aria-label="Notifications"
        >
          <Bell size={18} />
          <span
            className="absolute top-1 right-1 w-2 h-2 rounded-full"
            style={{ background: 'var(--color-error)' }}
            aria-label="3 notifications"
          />
        </button>
        <div
          className="w-8 h-8 rounded-full flex items-center justify-center text-white font-bold text-sm cursor-pointer"
          style={{ background: 'var(--color-primary)' }}
          aria-label={`Profile: ${ownerName}`}
        >
          {ownerName.charAt(0)}
        </div>
      </div>
    </header>
  );
}
