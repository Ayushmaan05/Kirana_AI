import React from 'react';
import { Banknote, Scissors, ShoppingBasket, Store } from 'lucide-react';

const shopTypes = [
  { name: 'Kirana shops', icon: ShoppingBasket },
  { name: 'Tailors & boutiques', icon: Scissors },
  { name: 'Street vendors', icon: Store },
  { name: 'Independent businesses', icon: Banknote },
];

export const BackedBySection: React.FC = () => (
  <section className="overflow-hidden bg-[#F5F5F5] px-5 py-10 sm:px-6 sm:py-12" aria-label="Businesses Kirana AI is designed for">
    <style>{`
      @keyframes business-marquee { from { transform: translateX(0); } to { transform: translateX(-50%); } }
      .business-track { display:flex; width:max-content; animation:business-marquee 34s linear infinite; }
      @media (prefers-reduced-motion: reduce) { .business-track { animation:none; } }
    `}</style>
    <div className="mx-auto grid max-w-[88rem] grid-cols-1 items-center gap-6 md:grid-cols-[220px_1fr]">
      <p className="max-w-[220px] text-sm leading-relaxed text-black/55">Designed for the neighborhood businesses that keep every day moving.</p>
      <div className="overflow-hidden" aria-hidden="true">
        <div className="business-track">
          {[0, 1].map(copy => <div key={copy} className="flex items-center">{shopTypes.map(({ name, icon: Icon }) => <span key={`${copy}-${name}`} className="mx-5 inline-flex shrink-0 items-center gap-2.5 whitespace-nowrap text-sm font-medium text-black/45 sm:mx-8 sm:text-base"><Icon className="h-4 w-4 text-black/35"/>{name}</span>)}</div>)}
        </div>
      </div>
    </div>
  </section>
);

export default BackedBySection;
