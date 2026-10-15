// ─── Currency & Number Formatting ─────────────────────────────────────────────
export function formatCurrency(amount, options = {}) {
  const {
    showSymbol = true,
    compact = false,
    decimals = 0,
  } = options;

  const num = Number(amount) || 0;

  if (compact && Math.abs(num) >= 100000) {
    const lakhs = num / 100000;
    return `${showSymbol ? '₹' : ''}${lakhs.toFixed(1)}L`;
  }
  if (compact && Math.abs(num) >= 1000) {
    const thousands = num / 1000;
    return `${showSymbol ? '₹' : ''}${thousands.toFixed(1)}K`;
  }

  const formatted = Math.abs(num).toLocaleString('en-IN', {
    minimumFractionDigits: decimals,
    maximumFractionDigits: decimals,
  });

  const sign = num < 0 ? '-' : '';
  return `${sign}${showSymbol ? '₹' : ''}${formatted}`;
}

export function parseAmount(str) {
  return Number(String(str).replace(/[^0-9.-]/g, '')) || 0;
}
