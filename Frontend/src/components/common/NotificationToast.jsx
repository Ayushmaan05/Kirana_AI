import React from 'react';
import { AnimatePresence, motion } from 'framer-motion';
import { X, CheckCircle2, AlertTriangle, AlertCircle, Info } from 'lucide-react';
import { useApp } from '../../context/AppContext.jsx';

const icons = {
  success: CheckCircle2,
  warning: AlertTriangle,
  error:   AlertCircle,
  info:    Info,
};
const colors = {
  success: '#10b981',
  warning: '#f59e0b',
  error:   '#ef4444',
  info:    '#3b82f6',
};

export default function NotificationToast() {
  const { notifications, removeNotification } = useApp();

  return (
    <div
      className="fixed bottom-20 right-4 lg:bottom-6 z-50 flex flex-col gap-2"
      style={{ maxWidth: 360 }}
      aria-live="polite"
      aria-atomic="false"
    >
      <AnimatePresence>
        {notifications.map(({ id, type = 'info', title, message }) => {
          const Icon = icons[type] || Info;
          const color = colors[type] || colors.info;
          return (
            <motion.div
              key={id}
              role="alert"
              className="card flex items-start gap-3 p-4 shadow-lg"
              initial={{ opacity: 0, y: 24, scale: 0.95 }}
              animate={{ opacity: 1, y: 0, scale: 1 }}
              exit={{ opacity: 0, y: 8, scale: 0.95 }}
              transition={{ duration: 0.22 }}
            >
              <Icon size={20} style={{ color, flexShrink: 0, marginTop: 1 }} />
              <div className="flex-1 min-w-0">
                {title && <p className="text-sm font-semibold text-slate-800">{title}</p>}
                {message && <p className="text-xs text-slate-500 mt-0.5">{message}</p>}
              </div>
              <button
                onClick={() => removeNotification(id)}
                className="text-slate-300 hover:text-slate-500 transition-colors"
                aria-label="Dismiss notification"
              >
                <X size={16} />
              </button>
            </motion.div>
          );
        })}
      </AnimatePresence>
    </div>
  );
}
