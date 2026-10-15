import React from 'react';
import { Outlet } from 'react-router-dom';
import Sidebar from './Sidebar.jsx';
import Header from './Header.jsx';
import MobileNavigation from './MobileNavigation.jsx';
import NotificationToast from '../common/NotificationToast.jsx';

export default function AppLayout() {
  return (
    <div className="flex min-h-screen" style={{ background: 'var(--color-bg)' }}>
      {/* Sidebar — fixed 256px on desktop, overlaid on mobile */}
      <Sidebar />

      {/* Main content — pushed right by sidebar width on desktop */}
      <div
        className="flex-1 flex flex-col min-w-0"
        style={{ marginLeft: 'clamp(0px, calc((100vw - 1024px) * 999), 256px)' }}
      >
        <Header />
        <main className="flex-1 overflow-y-auto p-4 md:p-5 pb-20 lg:pb-5">
          <Outlet />
        </main>
      </div>

      {/* Mobile bottom navigation */}
      <MobileNavigation />

      {/* Global toast notifications */}
      <NotificationToast />
    </div>
  );
}
