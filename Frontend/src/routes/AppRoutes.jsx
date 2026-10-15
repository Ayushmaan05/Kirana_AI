import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import AppLayout from '../components/layout/AppLayout.jsx';
import LandingPage    from '../pages/LandingPage.jsx';
import DashboardPage  from '../pages/DashboardPage.jsx';
import AssistantPage  from '../pages/AssistantPage.jsx';
import SalesPage      from '../pages/SalesPage.jsx';
import InventoryPage  from '../pages/InventoryPage.jsx';
import CustomersPage  from '../pages/CustomersPage.jsx';
import ReportsPage    from '../pages/ReportsPage.jsx';
import SettingsPage   from '../pages/SettingsPage.jsx';

export default function AppRoutes() {
  return (
    <Routes>
      {/* Landing page — no sidebar */}
      <Route path="/" element={<LandingPage />} />

      {/* App shell — with sidebar & header */}
      <Route element={<AppLayout />}>
        <Route path="/dashboard"  element={<DashboardPage />} />
        <Route path="/assistant"  element={<AssistantPage />} />
        <Route path="/sales"      element={<SalesPage />} />
        <Route path="/inventory"  element={<InventoryPage />} />
        <Route path="/customers"  element={<CustomersPage />} />
        <Route path="/reports"    element={<ReportsPage />} />
        <Route path="/settings"   element={<SettingsPage />} />
        {/* Catch-all → dashboard */}
        <Route path="*" element={<Navigate to="/dashboard" replace />} />
      </Route>
    </Routes>
  );
}
