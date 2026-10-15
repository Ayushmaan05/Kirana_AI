import React, { useState } from 'react';
import { Store, User, Globe, Bell, Shield, ChevronRight } from 'lucide-react';
import Input from '../components/common/Input.jsx';
import Button from '../components/common/Button.jsx';
import { useApp } from '../context/AppContext.jsx';

const LANGUAGES = ['English', 'Hindi', 'Hinglish', 'Marathi', 'Bengali', 'Telugu', 'Tamil'];
const BUSINESS_TYPES = ['Kirana / General Store', 'Tailor Shop', 'Vegetable / Fruit Vendor', 'Tea Stall', 'Pharmacy', 'Electronics', 'Stationery', 'Other'];

const SECTIONS = [
  { id: 'shop', icon: Store, label: 'Shop Profile' },
  { id: 'account', icon: User, label: 'Account' },
  { id: 'preferences', icon: Globe, label: 'Preferences' },
  { id: 'notifications', icon: Bell, label: 'Notifications' },
  { id: 'security', icon: Shield, label: 'Privacy & Security' },
];

export default function SettingsPage() {
  const { shopName, setShopName, ownerName, setOwnerName } = useApp();
  const [active, setActive] = useState('shop');
  const [form, setForm] = useState({
    shopName,
    ownerName,
    businessType: 'Kirana / General Store',
    gstNumber: '',
    phone: '',
    language: 'Hindi',
    currency: '₹ INR',
    lowStockAlerts: true,
    dailySummary: true,
    udhaarReminders: true,
    whatsappNotify: false,
  });
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);

  const set = (k, v) => setForm(f => ({ ...f, [k]: v }));

  async function handleSave() {
    setSaving(true);
    await new Promise(r => setTimeout(r, 800));
    setShopName(form.shopName);
    setOwnerName(form.ownerName);
    setSaving(false);
    setSaved(true);
    setTimeout(() => setSaved(false), 2500);
  }

  return (
    <div className="max-w-4xl mx-auto flex gap-5">
      {/* Sidebar nav */}
      <div className="card p-2 hidden sm:flex flex-col gap-0.5 w-52 flex-shrink-0 self-start">
        {SECTIONS.map(({ id, icon: Icon, label }) => (
          <button
            key={id}
            onClick={() => setActive(id)}
            className={`flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium text-left transition-all ${
              active === id ? 'bg-emerald-50 text-emerald-700' : 'text-slate-600 hover:bg-slate-50'
            }`}
          >
            <Icon size={16} />
            {label}
          </button>
        ))}
      </div>

      {/* Content */}
      <div className="flex-1 space-y-5">
        {/* Shop Profile */}
        {active === 'shop' && (
          <div className="card p-6 space-y-4">
            <h2 className="text-h2 text-slate-800">Shop Profile</h2>
            <Input label="Shop Name" value={form.shopName} onChange={e => set('shopName', e.target.value)} required id="setting-shop-name" />
            <Input label="Owner Name" value={form.ownerName} onChange={e => set('ownerName', e.target.value)} required id="setting-owner-name" />
            <div>
              <label className="label">Business Type</label>
              <select className="input" value={form.businessType} onChange={e => set('businessType', e.target.value)} id="setting-business-type">
                {BUSINESS_TYPES.map(b => <option key={b}>{b}</option>)}
              </select>
            </div>
            <Input label="GST Number (optional)" value={form.gstNumber} onChange={e => set('gstNumber', e.target.value)} id="setting-gst" placeholder="22AAAAA0000A1Z5" hint="Used in GST-oriented reports" />
            <Input label="Mobile Number" value={form.phone} onChange={e => set('phone', e.target.value)} id="setting-phone" placeholder="98XXXXXXXX" type="tel" />
          </div>
        )}

        {/* Preferences */}
        {active === 'preferences' && (
          <div className="card p-6 space-y-4">
            <h2 className="text-h2 text-slate-800">Preferences</h2>
            <div>
              <label className="label">Preferred Language</label>
              <select className="input" value={form.language} onChange={e => set('language', e.target.value)} id="setting-language">
                {LANGUAGES.map(l => <option key={l}>{l}</option>)}
              </select>
              <p className="text-xs text-slate-400 mt-1">The AI assistant will respond in your preferred language.</p>
            </div>
            <div>
              <label className="label">Currency Display</label>
              <select className="input" value={form.currency} onChange={e => set('currency', e.target.value)} id="setting-currency">
                <option>₹ INR</option>
              </select>
            </div>
          </div>
        )}

        {/* Notifications */}
        {active === 'notifications' && (
          <div className="card p-6 space-y-4">
            <h2 className="text-h2 text-slate-800">Notifications</h2>
            {[
              { key: 'lowStockAlerts', label: 'Low Stock Alerts', desc: 'Get notified when a product goes below the threshold.' },
              { key: 'dailySummary', label: 'Daily Business Summary', desc: 'Receive an end-of-day summary at 9:30 PM.' },
              { key: 'udhaarReminders', label: 'Udhaar Reminders', desc: 'Remind customers with long-pending balances.' },
              { key: 'whatsappNotify', label: 'WhatsApp Notifications', desc: 'Receive summaries on WhatsApp (requires backend).' },
            ].map(({ key, label, desc }) => (
              <div key={key} className="flex items-center justify-between py-3 border-b last:border-0" style={{ borderColor: '#f1f5f9' }}>
                <div>
                  <p className="font-semibold text-slate-700 text-sm">{label}</p>
                  <p className="text-xs text-slate-400 mt-0.5">{desc}</p>
                </div>
                <label className="relative inline-flex items-center cursor-pointer" aria-label={label}>
                  <input
                    type="checkbox"
                    className="sr-only peer"
                    checked={form[key]}
                    onChange={e => set(key, e.target.checked)}
                    id={`notify-${key}`}
                  />
                  <div className="w-10 h-6 rounded-full peer-focus:ring-2 transition-all"
                    style={{ background: form[key] ? 'var(--color-primary)' : '#e2e8f0' }}>
                    <div className="absolute top-1 left-1 w-4 h-4 rounded-full bg-white transition-transform"
                      style={{ transform: form[key] ? 'translateX(16px)' : 'translateX(0)' }} />
                  </div>
                </label>
              </div>
            ))}
          </div>
        )}

        {/* Account */}
        {active === 'account' && (
          <div className="card p-6">
            <h2 className="text-h2 text-slate-800 mb-4">Account</h2>
            <div className="p-4 rounded-xl mb-4" style={{ background: 'var(--color-primary-light)', border: '1px solid rgba(16,185,129,0.3)' }}>
              <p className="text-sm font-semibold text-emerald-800">Demo Mode Account</p>
              <p className="text-xs text-emerald-700 mt-1">This is a demo instance. Sign in functionality is available when connected to a backend.</p>
            </div>
            <div className="space-y-3 text-sm">
              <div className="flex justify-between py-2 border-b" style={{ borderColor: '#f1f5f9' }}>
                <span className="text-slate-500">Plan</span>
                <span className="font-semibold text-emerald-600">Free (Demo)</span>
              </div>
              <div className="flex justify-between py-2 border-b" style={{ borderColor: '#f1f5f9' }}>
                <span className="text-slate-500">Data Export</span>
                <span className="font-semibold text-slate-700">Available (CSV / PDF)</span>
              </div>
            </div>
          </div>
        )}

        {/* Security */}
        {active === 'security' && (
          <div className="card p-6">
            <h2 className="text-h2 text-slate-800 mb-4">Privacy & Security</h2>
            <div className="space-y-3 text-sm text-slate-600">
              <p>✅ Your business data is stored locally in demo mode and never shared.</p>
              <p>✅ When connected to a backend, data is encrypted in transit (HTTPS).</p>
              <p>✅ No API secrets are stored in the frontend code.</p>
              <p>✅ Customer data is protected and not used for advertising.</p>
            </div>
          </div>
        )}

        {/* Save button */}
        {['shop', 'preferences', 'notifications'].includes(active) && (
          <div className="flex items-center gap-3">
            <Button variant="primary" loading={saving} onClick={handleSave} id="settings-save-btn">
              {saving ? 'Saving…' : saved ? '✓ Saved!' : 'Save Settings'}
            </Button>
            {saved && <span className="text-sm text-emerald-600 font-semibold">Changes saved successfully.</span>}
          </div>
        )}
      </div>
    </div>
  );
}
