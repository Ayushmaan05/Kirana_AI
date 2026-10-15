// ─── Validators ───────────────────────────────────────────────────────────────
export function isRequired(value) {
  if (value === null || value === undefined) return 'This field is required';
  if (typeof value === 'string' && !value.trim()) return 'This field is required';
  return null;
}

export function isPositiveNumber(value) {
  const n = Number(value);
  if (isNaN(n)) return 'Must be a valid number';
  if (n <= 0)   return 'Must be greater than zero';
  return null;
}

export function isPhoneNumber(value) {
  if (!value) return null; // optional
  if (!/^[6-9]\d{9}$/.test(String(value).replace(/\s/g, ''))) {
    return 'Enter a valid 10-digit Indian mobile number';
  }
  return null;
}

export function validateForm(fields, rules) {
  const errors = {};
  Object.entries(rules).forEach(([field, validators]) => {
    for (const validator of validators) {
      const error = validator(fields[field]);
      if (error) { errors[field] = error; break; }
    }
  });
  return errors;
}
