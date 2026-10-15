import React from 'react';

const variants = {
  success: 'badge-success',
  warning: 'badge-warning',
  error:   'badge-error',
  info:    'badge-info',
  gray:    'badge-gray',
  primary: 'badge-primary',
};

export default function Badge({ children, variant = 'gray', className = '', dot = false }) {
  return (
    <span className={`badge ${variants[variant] || 'badge-gray'} ${className}`}>
      {dot && (
        <span
          className="w-1.5 h-1.5 rounded-full inline-block"
          style={{ backgroundColor: 'currentColor', opacity: 0.8 }}
        />
      )}
      {children}
    </span>
  );
}
