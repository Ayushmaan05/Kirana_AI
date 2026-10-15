import React from 'react';
import { Link } from 'react-router-dom';
import Navbar from '../components/Navbar.tsx';
import HeroSection from '../components/HeroSection.tsx';
import InfoSection from '../components/InfoSection.tsx';
import BackedBySection from '../components/BackedBySection.tsx';
import UseCasesSection from '../components/UseCasesSection.tsx';

export default function LandingPage() {
  return (
    <div className="kirana-landing flex min-h-screen flex-col bg-[#F5F5F5] text-black selection:bg-black selection:text-white">
      <div className="relative flex min-h-[760px] h-screen max-h-[1000px] flex-col overflow-hidden">
        <Navbar />
        <HeroSection />
      </div>
      <InfoSection />
      <BackedBySection />
      <UseCasesSection />
      <footer className="bg-[#F5F5F5] px-6 pb-8 pt-12">
        <div className="mx-auto flex max-w-[88rem] flex-col justify-between gap-8 border-t border-black/10 pt-6 sm:flex-row sm:items-center">
          <Link to="/" className="flex items-center gap-2 text-lg font-semibold tracking-tight" aria-label="Kirana AI home">
            <span className="grid h-8 w-8 place-items-center rounded-lg bg-black text-xs font-bold text-white">क</span>
            Kirana AI
          </Link>
          <p className="max-w-sm text-sm text-black/55">A simpler way to keep the everyday business details in order.</p>
          <nav className="flex flex-wrap gap-x-5 gap-y-2 text-sm text-black/65" aria-label="Footer navigation">
            <Link to="/dashboard" className="hover:text-black">Dashboard</Link>
            <Link to="/assistant" className="hover:text-black">AI Assistant</Link>
            <Link to="/sales" className="hover:text-black">Sales &amp; Ledger</Link>
            <Link to="/reports" className="hover:text-black">Reports</Link>
          </nav>
        </div>
      </footer>
    </div>
  );
}
