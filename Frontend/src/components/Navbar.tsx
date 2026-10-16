import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { ArrowRight, Menu, X } from 'lucide-react';
import LanguageToggle from './LanguageToggle.jsx';

const navLinks = [
  { label: 'Home', to: '/' },
  { label: 'Dashboard', to: '/dashboard' },
  { label: 'AI Assistant', to: '/assistant' },
  { label: 'Sales & Ledger', to: '/sales' },
  { label: 'Inventory', to: '/inventory' },
  { label: 'Customer Credit', to: '/customers' },
  { label: 'Reports', to: '/reports' },
];

export const Navbar: React.FC = () => {
  const [menuOpen, setMenuOpen] = useState(false);
  const closeMenu = () => setMenuOpen(false);

  return (
    <nav className="absolute left-0 right-0 top-0 z-30 px-5 py-4 sm:px-6 sm:py-5" aria-label="Main navigation">
      <div className="mx-auto flex max-w-[88rem] items-center justify-between gap-4">
        <Link to="/" onClick={closeMenu} className="flex shrink-0 items-center" aria-label="Kirana AI home">
          <img src="/logo.png" alt="Kirana AI" className="h-8 sm:h-9 w-auto object-contain" />
        </Link>

        <div className="hidden items-center gap-5 lg:flex xl:gap-7">
          {navLinks.slice(0, 6).map(({ label, to }) => (
            <Link key={to} to={to} className="whitespace-nowrap text-sm font-medium text-black/65 transition-colors hover:text-black">{label}</Link>
          ))}
          <Link to="/reports" className="whitespace-nowrap text-sm font-medium text-black/65 transition-colors hover:text-black">Reports</Link>
        </div>

        <div className="hidden shrink-0 items-center gap-3 lg:flex">
          <LanguageToggle />
          <Link to="/dashboard" className="group inline-flex items-center gap-3 rounded-full bg-black py-2 pl-5 pr-2 text-sm font-medium text-[#F3E8D0] transition-colors hover:bg-neutral-800 hover:font-bold">
            Open Dashboard
            <span className="grid h-8 w-8 place-items-center rounded-full bg-white text-black transition-transform group-hover:translate-x-0.5"><ArrowRight className="h-4 w-4" /></span>
          </Link>
        </div>

        <div className="flex items-center gap-3 lg:hidden">
          <LanguageToggle />
          <Link to="/dashboard" className="hidden rounded-full bg-black px-4 py-2.5 text-xs font-semibold text-[#F3E8D0] transition-[font-weight] hover:font-bold sm:inline-flex">Open Dashboard</Link>
          <button type="button" onClick={() => setMenuOpen(value => !value)} className="grid h-10 w-10 place-items-center rounded-full border border-black/10 bg-white/80 text-black" aria-expanded={menuOpen} aria-label={menuOpen ? 'Close navigation menu' : 'Open navigation menu'}>
            {menuOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
          </button>
        </div>
      </div>

      {menuOpen && (
        <div className="absolute left-4 right-4 top-[calc(100%-4px)] rounded-2xl border border-black/10 bg-white p-3 shadow-xl lg:hidden">
          <div className="flex justify-end px-2 pb-2"><LanguageToggle /></div>
          <div className="grid gap-1">
            {navLinks.map(({ label, to }) => (
              <Link key={to} to={to} onClick={closeMenu} className="rounded-xl px-3 py-3 text-sm font-medium text-black/75 transition-colors hover:bg-black/5 hover:text-black">{label}</Link>
            ))}
          </div>
          <Link to="/dashboard" onClick={closeMenu} className="mt-2 flex items-center justify-center gap-2 rounded-xl bg-black px-4 py-3 text-sm font-semibold text-[#F3E8D0] transition-[font-weight] hover:font-bold sm:hidden">Open Dashboard <ArrowRight className="h-4 w-4" /></Link>
        </div>
      )}
    </nav>
  );
};

export default Navbar;
