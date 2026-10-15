// ─── Date Formatting ──────────────────────────────────────────────────────────
export function formatDate(date, format = 'medium') {
  if (!date) return '—';
  const d = date instanceof Date ? date : new Date(date);
  if (isNaN(d)) return '—';

  const formats = {
    short:  { day: '2-digit', month: '2-digit', year: '2-digit' },
    medium: { day: 'numeric', month: 'short', year: 'numeric' },
    long:   { day: 'numeric', month: 'long', year: 'numeric' },
    time:   { hour: '2-digit', minute: '2-digit', hour12: true },
    full:   { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', hour12: true },
  };

  return d.toLocaleDateString('en-IN', formats[format] || formats.medium);
}

export function formatRelativeTime(date) {
  if (!date) return '';
  const d = date instanceof Date ? date : new Date(date);
  const diff = Date.now() - d.getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 1)  return 'just now';
  if (mins < 60) return `${mins}m ago`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24)  return `${hrs}h ago`;
  const days = Math.floor(hrs / 24);
  if (days < 7)  return `${days}d ago`;
  return formatDate(d, 'medium');
}

export function getDateRange(preset) {
  const now = new Date();
  const start = new Date(now);
  switch (preset) {
    case 'today':
      start.setHours(0, 0, 0, 0);
      return { start, end: now };
    case 'week':
      start.setDate(now.getDate() - 7);
      return { start, end: now };
    case 'month':
      start.setMonth(now.getMonth() - 1);
      return { start, end: now };
    case 'year':
      start.setFullYear(now.getFullYear() - 1);
      return { start, end: now };
    default:
      return { start: null, end: null };
  }
}

export function isSameDay(a, b) {
  const da = a instanceof Date ? a : new Date(a);
  const db = b instanceof Date ? b : new Date(b);
  return da.toDateString() === db.toDateString();
}
