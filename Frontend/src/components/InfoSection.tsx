import React from 'react';
import { Link } from 'react-router-dom';
import { ArrowRight, BarChart3, Languages, MessageSquareText, Package, ReceiptText, UsersRound } from 'lucide-react';

const features = [
  { icon: MessageSquareText, title: 'Everyday text entry', copy: 'Describe a sale in plain language and review the organized record before saving.', tone: 'bg-[#e6eee5] text-[#436f4b]' },
  { icon: ReceiptText, title: 'A tidy sales ledger', copy: 'Find recent transactions, amounts, and payment methods together in one place.', tone: 'bg-[#f1eee5] text-[#927942]' },
  { icon: Package, title: 'Inventory at a glance', copy: 'See product quantities and identify items that need a restock.', tone: 'bg-[#e8edf0] text-[#5b768a]' },
  { icon: UsersRound, title: 'Customer credit', copy: 'Keep a simple view of udhaar balances and payments received.', tone: 'bg-[#efe9f1] text-[#806991]' },
  { icon: BarChart3, title: 'Useful summaries', copy: 'Review daily and monthly sales and expense trends from your records.', tone: 'bg-[#f4e8e2] text-[#a4664e]' },
  { icon: Languages, title: 'More languages, over time', copy: 'The experience is designed for local businesses; multilingual assistance is a planned capability.', tone: 'bg-[#e8eee8] text-[#577760]' },
];

export const InfoSection: React.FC = () => (
  <section id="features" className="scroll-mt-8 bg-[#F5F5F5] px-5 py-20 sm:px-6 md:py-24">
    <div className="mx-auto max-w-[88rem]">
      <div className="mb-12 grid grid-cols-1 items-end gap-8 md:mb-16 md:grid-cols-2 md:gap-12">
        <div>
          <p className="mb-3 text-sm font-medium text-black/50">A calmer way to keep the books</p>
          <h2 className="max-w-xl text-4xl font-medium leading-[1.08] tracking-[-.04em] text-black sm:text-5xl">Meet Kirana AI.</h2>
          <Link to="/dashboard" className="group mt-6 inline-flex items-center gap-3 rounded-full bg-black py-2 pl-6 pr-2 text-sm font-medium text-[#F3E8D0] transition-colors hover:bg-neutral-800 hover:font-bold">
            <span>Open the demo</span><span className="grid h-9 w-9 place-items-center rounded-full bg-white text-black transition-transform group-hover:translate-x-0.5"><ArrowRight className="h-4 w-4"/></span>
          </Link>
        </div>
        <p className="max-w-xl text-lg leading-relaxed text-black/60 sm:text-xl md:pb-1">A lightweight business assistant for the daily details: sales, stock, customer credit, and useful summaries. Sample figures in the app are clearly marked as demo data.</p>
      </div>
      <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
        {features.map(({ icon: Icon, title, copy, tone }, index) => (
          <article key={title} className={`flex min-h-[214px] flex-col justify-between rounded-2xl p-6 sm:min-h-[230px] sm:p-7 ${index === 0 ? 'bg-white' : 'bg-white/55'} transition-transform duration-300 hover:-translate-y-1`}>
            <div className="flex items-center justify-between"><span className={`grid h-11 w-11 place-items-center rounded-xl ${tone}`}><Icon className="h-5 w-5"/></span><span className="text-xs font-semibold tracking-[.12em] text-black/30">0{index + 1}</span></div>
            <div className="mt-10"><h3 className="text-xl font-medium tracking-tight text-black">{title}</h3><p className="mt-2 max-w-sm text-sm leading-6 text-black/55">{copy}</p></div>
          </article>
        ))}
      </div>
      <p className="mt-5 text-xs text-black/40">GST-ready summaries are for organizing records; confirm tax calculations with your accountant.</p>
    </div>
  </section>
);

export default InfoSection;
