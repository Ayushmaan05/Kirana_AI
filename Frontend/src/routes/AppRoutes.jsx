import React, { lazy, Suspense } from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import AppLayout from '../components/layout/AppLayout.jsx';
import LoadingSpinner from '../components/common/LoadingSpinner.jsx';

const LandingPage = lazy(() => import('../pages/LandingPage.jsx'));
const DashboardPage = lazy(() => import('../pages/DashboardPage.jsx'));
const AssistantPage = lazy(() => import('../pages/AssistantPage.jsx'));
const SalesPage = lazy(() => import('../pages/SalesPage.jsx'));
const InventoryPage = lazy(() => import('../pages/InventoryPage.jsx'));
const CustomersPage = lazy(() => import('../pages/CustomersPage.jsx'));
const ReportsPage = lazy(() => import('../pages/ReportsPage.jsx'));
const SettingsPage = lazy(() => import('../pages/SettingsPage.jsx'));

export default function AppRoutes() {
  return (
    <Suspense fallback={<LoadingSpinner message="Opening your business workspace…" />}>
      <Routes>
        {/* Landing page — no sidebar */}
        <Route path="/" element={<LandingPage />} />

        {/* App shell — with sidebar & header */}
        <Route element={<AppLayout />}>
          <Route path="/dashboard" element={<DashboardPage />} />
          <Route path="/assistant" element={<AssistantPage />} />
          <Route path="/sales" element={<SalesPage />} />
          <Route path="/inventory" element={<InventoryPage />} />
          <Route path="/customers" element={<CustomersPage />} />
          <Route path="/reports" element={<ReportsPage />} />
          <Route path="/settings" element={<SettingsPage />} />
          {/* Catch-all → dashboard */}
          <Route path="*" element={<Navigate to="/dashboard" replace />} />
        </Route>
      </Routes>
    </Suspense>
  );
}
