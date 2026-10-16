import React from 'react';
import { Link } from 'react-router-dom';
import { ArrowRight, ArrowUpRight, BarChart3, Check, Clock3, Package, Plus, Receipt, Sparkles, TrendingUp, Wallet } from 'lucide-react';

const metrics = [
  { label: "Today's sales", value: '₹12,480', note: '+12% from yesterday', icon: Wallet, color: 'bg-[#e9f1e9] text-[#497957]' },
  { label: 'Transactions', value: '32', note: 'sales recorded', icon: Receipt, color: 'bg-[#f3eee1] text-[#9a7b36]' },
  { label: 'Low stock', value: '3 items', note: 'Worth a quick look', icon: Package, color: 'bg-[#f5e9e5] text-[#a05f4b]' },
];

const activity = [
  { title: 'Rice · 5 kg', meta: 'Cash · 11:42 am', amount: '+ ₹300', tint: 'bg-[#e9f1e9] text-[#497957]' },
  { title: 'Biscuits · 2 packets', meta: 'UPI · 10:18 am', amount: '+ ₹240', tint: 'bg-[#eaf0f3] text-[#597e91]' },
  { title: 'Aashirvaad Atta', meta: 'Low stock · 4 bags left', amount: 'Restock', tint: 'bg-[#f5eee0] text-[#9a7b36]' },
];

function DashboardPreview() {
  return (
    <div className="relative z-10 w-full max-w-[690px] rounded-2xl border border-black/10 bg-white p-2.5 shadow-[0_24px_70px_rgba(0,0,0,0.12)] sm:p-3.5">
      <div className="flex items-center justify-between border-b border-black/[0.06] px-2 pb-3 sm:px-3">
        <div className="flex items-center gap-2"><span className="grid h-7 w-7 place-items-center rounded-lg bg-black text-white"><Sparkles className="h-3.5 w-3.5" /></span><div><p className="text-[10px] font-semibold leading-tight text-black sm:text-xs">Sharma General Store</p><p className="mt-0.5 text-[8px] text-black/40 sm:text-[9px]">Today at a glance</p></div></div>
        <span className="rounded-full bg-[#f3f4f1] px-2.5 py-1 text-[8px] text-black/50 sm:text-[9px]">Demo data</span>
        <button type="button" className="grid h-7 w-7 place-items-center rounded-full bg-black text-white" aria-label="Sample add transaction"><Plus className="h-3.5 w-3.5" /></button>
      </div>
      <div className="grid grid-cols-3 gap-1.5 px-1 pt-2.5 sm:gap-2 sm:px-1.5 sm:pt-3">
        {metrics.map(({ label, value, note, icon: Icon, color }) => <div key={label} className="min-w-0 rounded-xl border border-black/[0.06] bg-white p-2 sm:p-3"><div className="flex items-center justify-between gap-1"><span className="truncate text-[8px] text-black/50 sm:text-[10px]">{label}</span><span className={`grid h-5 w-5 shrink-0 place-items-center rounded-md ${color}`}><Icon className="h-3 w-3" /></span></div><p className="mt-2 truncate text-xs font-semibold tracking-tight text-black sm:text-base">{value}</p><p className="mt-1 truncate text-[7px] text-black/40 sm:text-[9px]">{note}</p></div>)}
      </div>
      <div className="grid gap-2 px-1 pb-1 pt-2 sm:grid-cols-[1.05fr_.95fr] sm:px-1.5 sm:pb-1.5 sm:pt-2.5">
        <div className="rounded-xl border border-black/[0.06] p-2.5 sm:p-3"><div className="flex items-center justify-between"><div><p className="text-[9px] font-semibold text-black sm:text-[10px]">Weekly sales</p><p className="mt-0.5 text-[8px] text-black/40 sm:text-[9px]">A steady week so far</p></div><span className="flex items-center gap-1 text-[8px] font-medium text-[#54825e]"><TrendingUp className="h-3 w-3"/> 8.4%</span></div><div className="mt-3 flex h-[72px] items-end gap-1.5 border-b border-black/[0.06] px-1 sm:h-[90px] sm:gap-2">{[35,52,44,70,58,88,75].map((height,i)=><div key={i} className={`flex-1 rounded-t-[4px] ${i===5?'bg-[#243b2e]':'bg-[#dce8dd]'}`} style={{height:`${height}%`}} />)}</div><div className="mt-1.5 flex justify-between px-1 text-[7px] text-black/35 sm:text-[8px]">{['Wed','Thu','Fri','Sat','Sun','Mon','Tue'].map(day=><span key={day}>{day}</span>)}</div></div>
        <div className="rounded-xl border border-black/[0.06] p-2.5 sm:p-3"><div className="mb-1 flex items-center justify-between"><div><p className="text-[9px] font-semibold text-black sm:text-[10px]">Recent activity</p><p className="mt-0.5 text-[8px] text-black/40 sm:text-[9px]">A few things from today</p></div><BarChart3 className="h-3.5 w-3.5 text-black/35" /></div><div>{activity.map(({title,meta,amount,tint})=><div key={title} className="flex items-center gap-2 border-b border-black/[0.05] py-1.5 last:border-0 sm:py-2"><span className={`grid h-6 w-6 shrink-0 place-items-center rounded-md ${tint}`}>{amount.startsWith('+')?<Check className="h-3 w-3"/>:<Clock3 className="h-3 w-3"/>}</span><span className="min-w-0 flex-1"><span className="block truncate text-[8px] font-medium text-black/75 sm:text-[9px]">{title}</span><span className="mt-0.5 block truncate text-[7px] text-black/40 sm:text-[8px]">{meta}</span></span><span className="shrink-0 text-[8px] font-semibold text-black/65 sm:text-[9px]">{amount}</span></div>)}</div></div>
      </div>
    </div>
  );
}

export const HeroSection: React.FC = () => (
  <section className="flex-1 px-4 pb-4 pt-[76px] sm:px-6 sm:pb-6 sm:pt-24">
    <div className="relative mx-auto grid h-full min-h-[640px] max-w-[88rem] overflow-hidden rounded-2xl bg-[#e8e8e4] px-5 py-8 sm:rounded-3xl sm:px-9 sm:py-10 lg:grid-cols-[.9fr_1.1fr] lg:items-center lg:px-14 lg:py-12">
      <div className="pointer-events-none absolute -right-24 -top-32 h-[420px] w-[420px] rounded-full bg-white/60 blur-3xl" />
      <div className="relative z-10 flex flex-col items-start lg:py-8">
        <span className="mb-5 inline-flex items-center gap-2 rounded-full border border-black/10 bg-white/55 px-3 py-1.5 text-[10px] font-semibold uppercase tracking-[.13em] text-black/55"><Sparkles className="h-3 w-3"/> Kirana AI · Your daily business assistant</span>
        <h1 className="max-w-[590px] text-4xl font-medium leading-[1.06] tracking-[-.045em] text-black sm:text-5xl md:text-6xl xl:text-7xl">Your Shop.<br/>Your Records.<br/><span className="text-black/45">Simplified by AI.</span></h1>
        <p className="mt-5 max-w-[450px] text-sm leading-6 text-black/65 sm:text-base sm:leading-7">Manage sales, track inventory, and organize daily business records using simple text notes. Voice transcription is planned for a future update.</p>
        <div className="mt-7 flex flex-wrap items-center gap-3">
          <Link to="/dashboard" className="group inline-flex items-center gap-3 rounded-full bg-black py-2 pl-6 pr-2 text-sm font-medium text-[#F3E8D0] transition-colors hover:bg-neutral-800 hover:font-bold"><span>Get Started</span><span className="coin-hover grid h-9 w-9 place-items-center rounded-full bg-white text-black"><ArrowRight className="h-4 w-4" /></span></Link>
          <a href="#features" className="inline-flex items-center gap-2 rounded-full border border-black/15 bg-white/40 px-5 py-3 text-sm font-medium text-black/75 transition-colors hover:bg-white/80">Explore Features <ArrowUpRight className="h-4 w-4"/></a>
        </div>
        <p className="mt-5 text-[10px] font-medium text-black/40">A clear view of your business, in one simple place.</p>
      </div>
      <div className="relative mt-10 flex min-w-0 items-center justify-center lg:mt-0 lg:pl-4">
        <div className="absolute h-[75%] w-[95%] rounded-full bg-[#d7dbd2]/80 blur-3xl" />
        <DashboardPreview />
        <div className="absolute -bottom-2 right-0 z-20 hidden items-center gap-2 rounded-xl border border-black/10 bg-white px-3 py-2 text-[10px] shadow-lg sm:flex lg:-right-4"><span className="grid h-6 w-6 place-items-center rounded-lg bg-[#e9f1e9] text-[#497957]"><Check className="h-3.5 w-3.5" /></span><span><b className="block font-semibold">Your day, at a glance</b><span className="text-black/45">Sample shop data</span></span></div>
      </div>
    </div>
  </section>
);

export default HeroSection;
