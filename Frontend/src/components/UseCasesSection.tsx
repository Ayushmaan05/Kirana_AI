import React from 'react';
import { Link } from 'react-router-dom';
import { ArrowRight, Check, MessageSquareText, Package, ReceiptText, Sparkles } from 'lucide-react';

const sample = 'Sold 5 kg rice for ₹300 and 2 packets of biscuits for ₹40.';

export const UseCasesSection: React.FC = () => (
  <section id="how-it-works" className="scroll-mt-8 bg-[#e9e9e4] px-5 py-20 sm:px-6 md:py-24">
    <div className="mx-auto grid max-w-[88rem] grid-cols-1 items-center gap-10 lg:grid-cols-[.85fr_1.15fr] lg:gap-20">
      <div className="lg:pr-8">
        <p className="mb-3 text-sm font-medium text-black/50">From quick note to clear record</p>
        <h2 className="text-4xl font-medium leading-[1.08] tracking-[-.04em] text-black sm:text-5xl">A few words.<br/>A clearer picture.</h2>
        <p className="mt-5 max-w-lg text-base leading-7 text-black/60">Use the text assistant to describe what happened. Review the details it prepares, make changes, then confirm the entry.</p>
        <div className="mt-8 space-y-5">
          <div className="flex gap-4"><span className="grid h-9 w-9 shrink-0 place-items-center rounded-xl bg-white text-black/70"><MessageSquareText className="h-4 w-4"/></span><div><h3 className="text-sm font-semibold">Write it naturally</h3><p className="mt-1 text-sm leading-6 text-black/55">For example: “Sold 5 kg rice for ₹300 and 2 packets of biscuits for ₹40.”</p></div></div>
          <div className="flex gap-4"><span className="grid h-9 w-9 shrink-0 place-items-center rounded-xl bg-white text-black/70"><ReceiptText className="h-4 w-4"/></span><div><h3 className="text-sm font-semibold">Check the parsed items</h3><p className="mt-1 text-sm leading-6 text-black/55">The demo assistant organizes quantities and amounts into a preview you can edit.</p></div></div>
          <div className="flex gap-4"><span className="grid h-9 w-9 shrink-0 place-items-center rounded-xl bg-white text-black/70"><Package className="h-4 w-4"/></span><div><h3 className="text-sm font-semibold">Confirm when it looks right</h3><p className="mt-1 text-sm leading-6 text-black/55">Confirmed records appear in the sales ledger. You stay in control before saving.</p></div></div>
        </div>
      </div>

      <div className="relative overflow-hidden rounded-3xl bg-[#222] p-5 text-white sm:p-8 lg:p-10">
        <div className="pointer-events-none absolute -right-20 -top-20 h-64 w-64 rounded-full bg-white/10 blur-3xl" />
        <div className="relative z-10 flex items-center justify-between border-b border-white/10 pb-5"><div className="flex items-center gap-3"><span className="grid h-10 w-10 place-items-center rounded-xl bg-white/10 text-white"><Sparkles className="h-5 w-5"/></span><div><p className="text-sm font-medium">AI Assistant</p><p className="mt-1 text-xs text-white/45">Mock processing · Demo data</p></div></div><span className="rounded-full border border-white/15 px-3 py-1 text-[10px] text-white/60">TEXT PREVIEW</span></div>
        <div className="ml-auto mt-6 max-w-md rounded-2xl rounded-br-md bg-white/10 px-4 py-3 text-sm leading-6 text-white/85">{sample}</div>
        <div className="mt-5 rounded-2xl border border-white/10 bg-white/[0.06] p-4 sm:p-5">
          <div className="flex items-center gap-2 text-sm font-medium"><span className="grid h-6 w-6 place-items-center rounded-full bg-[#cce6ce] text-[#315b39]"><Check className="h-3.5 w-3.5"/></span>Review sale entry</div>
          <div className="mt-4 divide-y divide-white/10">
            <div className="flex items-center justify-between gap-4 py-3 text-sm"><span className="text-white/65">5 kg rice</span><span>₹300</span></div>
            <div className="flex items-center justify-between gap-4 py-3 text-sm"><span className="text-white/65">2 packets biscuits</span><span>₹40</span></div>
            <div className="flex items-center justify-between gap-4 pt-4 text-sm font-semibold"><span>Total</span><span>₹340</span></div>
          </div>
          <Link to="/assistant" state={{ draftMessage: sample }} className="mt-5 flex w-full items-center justify-center gap-2 rounded-xl bg-white px-4 py-3 text-sm font-semibold text-black transition-colors hover:bg-white/90">Try this example <ArrowRight className="h-4 w-4"/></Link>
        </div>
        <p className="relative z-10 mt-4 text-center text-[10px] leading-5 text-white/40">Example preview only. Check the assistant’s parsed details before confirming a real entry.</p>
      </div>
    </div>
  </section>
);

export default UseCasesSection;
