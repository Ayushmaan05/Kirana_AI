import React from 'react';

export default function LoadingSpinner({ size = 20, message = '' }) {
  return (
    <div className="flex flex-col items-center justify-center gap-3 py-8">
      <span
        className="spinner"
        style={{ width: size, height: size }}
        role="status"
        aria-label="Loading"
      />
      {message && <p className="text-sm text-slate-400">{message}</p>}
    </div>
  );
}

export function InlineSpinner({ size = 16 }) {
  return (
    <span
      className="spinner inline-block"
      style={{ width: size, height: size }}
      role="status"
    />
  );
}
