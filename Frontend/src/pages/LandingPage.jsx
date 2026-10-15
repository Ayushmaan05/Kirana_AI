import { useState } from 'react'
import { Link } from 'react-router-dom'
import { motion } from 'framer-motion'
import {
  ArrowDown, ArrowRight, ArrowUpRight, AudioLines, Banknote, BarChart3,
  Check, ChevronDown, CircleHelp, Clock3, CreditCard, Menu, Mic2,
  Package, Plus, ScanLine, ShoppingBag, Sparkles, TrendingUp,
  Wallet, X,
} from 'lucide-react'

const reveal = {
  initial: { opacity: 0, y: 24 },
  whileInView: { opacity: 1, y: 0 },
  viewport: { once: true, amount: 0.18 },
  transition: { duration: 0.6, ease: [0.22, 1, 0.36, 1] },
}

const features = [
  { icon: AudioLines, no: '01', title: 'Just say what happened.', copy: 'A quick voice note becomes a neat sale entry. Speak naturally in Hindi, English, or Hinglish.', tone: 'mint' },
  { icon: Package, no: '02', title: 'Know before you run out.', copy: 'Keep an eye on fast movers and get a nudge when something needs restocking.', tone: 'butter' },
  { icon: Wallet, no: '03', title: 'Every udhaar, remembered.', copy: 'See who owes what, log repayments, and keep your khata up to date without the notebook hunt.', tone: 'lavender' },
  { icon: BarChart3, no: '04', title: 'The day, at a glance.', copy: 'Sales, expenses, and a simple daily summary—ready when you close the shutter.', tone: 'peach' },
]

const transactions = [
  { name: 'Asha General Store', detail: 'Today, 11:42 AM · Cash', amount: '+₹1,240', icon: ShoppingBag, color: 'green' },
  { name: 'Ramesh · udhaar payment', detail: 'Today, 10:18 AM · UPI', amount: '+₹500', icon: CreditCard, color: 'blue' },
  { name: 'Fresh stock · atta & dal', detail: 'Today, 9:06 AM · Expense', amount: '−₹2,180', icon: Package, color: 'amber' },
]

function Brand({ inverse = false }) {
  return <Link to="/" className={`brand ${inverse ? 'brand-inverse' : ''}`} aria-label="Kirana AI home">
    <span className="brand-mark"><Sparkles size={17} strokeWidth={2.3} /></span>
    <span>Kirana<span className="brand-light">AI</span></span>
  </Link>
}

function DashboardPreview() {
  return <div className="dashboard-window">
    <div className="window-top"><div className="window-dots"><i /><i /><i /></div><span className="window-url">app.kirana.ai / overview</span><span className="window-live"><span /> Live demo</span></div>
    <div className="dashboard-body">
      <aside className="dash-sidebar">
        <div className="dash-brand"><span className="dash-brand-mark"><Sparkles size={15} /></span><span>Kirana<span>AI</span></span></div>
        <div className="shop-switch"><span className="shop-avatar">A</span><span><b>Asha General Store</b><small>New Delhi, India</small></span><ChevronDown size={13} /></div>
        <div className="dash-label">YOUR BUSINESS</div>
        <div className="dash-nav-item active"><BarChart3 size={15} /> Overview</div>
        <div className="dash-nav-item"><CreditCard size={15} /> Sales & khata</div>
        <div className="dash-nav-item"><Package size={15} /> Inventory <span className="nav-count">3</span></div>
        <div className="dash-nav-item"><Wallet size={15} /> Customers</div>
        <div className="dash-label dash-label-lower">ASSISTANT</div>
        <div className="dash-nav-item"><Mic2 size={15} /> Voice entry</div>
        <div className="dash-help"><CircleHelp size={15} /><span>Need a hand?<small>Ask your assistant</small></span><ArrowUpRight size={12} /></div>
        <div className="dash-profile"><span className="profile-avatar">AS</span><span><b>Asha Sharma</b><small>Shop owner</small></span><ChevronDown size={13} /></div>
      </aside>
      <main className="dash-main">
        <div className="dash-greeting"><div><div className="dash-date"><span className="live-dot" /> TUESDAY, 15 OCTOBER 2026</div><h3>Namaste, Asha <span>☀️</span></h3><p>Here’s how your shop is doing today.</p></div><button className="dash-add"><Plus size={15} /> Add entry</button></div>
        <div className="metric-grid">
          <div className="metric-card"><span>Today’s sales <Banknote size={15} /></span><b>₹12,480</b><small><TrendingUp size={12} /> 12.8% <em>vs. yesterday</em></small></div>
          <div className="metric-card"><span>Collected <Wallet size={15} /></span><b>₹9,360</b><small><Check size={12} /> 75% <em>of sales</em></small></div>
          <div className="metric-card"><span>Udhaar pending <Clock3 size={15} /></span><b>₹3,120</b><small className="metric-warn"><Clock3 size={12} /> 4 customers <em>to follow up</em></small></div>
          <div className="metric-card"><span>Low stock <Package size={15} /></span><b>3 items</b><small className="metric-alert"><span /> Needs attention</small></div>
        </div>
        <div className="dash-lower">
          <section className="sales-panel"><div className="panel-heading"><div><b>Sales this week</b><small>A little progress, every day.</small></div><button>This week <ChevronDown size={12} /></button></div><div className="chart-total">₹48,290 <span><TrendingUp size={12} /> 8.4%</span></div><div className="chart-area"><div className="chart-y"><span>₹15k</span><span>₹10k</span><span>₹5k</span><span>₹0</span></div><div className="chart-visual"><div className="chart-gridline g1"/><div className="chart-gridline g2"/><div className="chart-gridline g3"/><svg viewBox="0 0 420 125" preserveAspectRatio="none" aria-label="Weekly sales trend rising across the week"><defs><linearGradient id="chartFill" x1="0" x2="0" y1="0" y2="1"><stop offset="0%" stopColor="#27845d" stopOpacity=".19"/><stop offset="100%" stopColor="#27845d" stopOpacity="0"/></linearGradient></defs><path d="M0 94 C28 82 38 82 60 91 S96 80 120 69 S152 81 180 69 S214 55 240 66 S275 48 300 54 S340 31 360 43 S398 19 420 15 L420 125 L0 125Z" fill="url(#chartFill)"/><path d="M0 94 C28 82 38 82 60 91 S96 80 120 69 S152 81 180 69 S214 55 240 66 S275 48 300 54 S340 31 360 43 S398 19 420 15" fill="none" stroke="#27845d" strokeWidth="3" strokeLinecap="round"/><circle cx="420" cy="15" r="4" fill="#fff" stroke="#27845d" strokeWidth="3"/></svg><div className="chart-x"><span>Wed</span><span>Thu</span><span>Fri</span><span>Sat</span><span>Sun</span><span>Mon</span><span>Tue</span></div></div></div></section>
          <section className="transactions-panel"><div className="panel-heading"><div><b>Recent activity</b><small>Your shop, as it happens.</small></div><button className="more-button" aria-label="View all activity"><ArrowUpRight size={14} /></button></div><div className="transaction-list">{transactions.map(({ name, detail, amount, icon: Icon, color }) => <div className="transaction-row" key={name}><span className={`transaction-icon ${color}`}><Icon size={14} /></span><span className="transaction-copy"><b>{name}</b><small>{detail}</small></span><b className={amount.startsWith('−') ? 'amount-negative' : 'amount-positive'}>{amount}</b></div>)}</div><div className="ai-note"><span className="ai-spark"><Sparkles size={14} /></span><span><b>A small win today</b><small>Your evening sales are up. Nice going, Asha!</small></span></div></section>
        </div>
        <div className="voice-entry"><span className="voice-icon"><Mic2 size={17} /></span><span className="voice-copy"><b>Your assistant is listening</b><small>Try saying “2 kilo chawal, 120 rupaye cash”</small></span><button aria-label="Record a voice entry"><AudioLines size={18} /></button></div>
      </main>
    </div>
  </div>
}

export default function LandingPage() {
  const [menuOpen, setMenuOpen] = useState(false)
  const closeMenu = () => setMenuOpen(false)
  return <div className="landing">
    <div className="announcement"><Sparkles size={13} /> The little helper your shop has been waiting for <ArrowRight size={13} /></div>
    <header className="site-header"><div className="site-header-inner"><Brand /><nav className={`site-nav ${menuOpen ? 'nav-open' : ''}`}><a href="#product" onClick={closeMenu}>The product</a><a href="#features" onClick={closeMenu}>What it does</a><a href="#how-it-works" onClick={closeMenu}>How it works</a><a href="#for-every-shop" onClick={closeMenu}>For your shop</a><div className="nav-mobile-actions"><Link className="nav-signin" to="/dashboard" onClick={closeMenu}>See the demo <ArrowRight size={15} /></Link></div></nav><div className="header-actions"><Link to="/dashboard" className="nav-signin">Sign in</Link><Link to="/dashboard" className="nav-cta">Try Kirana AI <ArrowRight size={15} /></Link></div><button className="menu-toggle" onClick={() => setMenuOpen(!menuOpen)} aria-label={menuOpen ? 'Close navigation' : 'Open navigation'}>{menuOpen ? <X size={21} /> : <Menu size={21} />}</button></div></header>
    <main>
      <section className="hero-section"><div className="hero-orbit orbit-one"/><div className="hero-orbit orbit-two"/><div className="hero-content"><motion.div {...reveal} className="hero-kicker"><span className="kicker-icon"><Sparkles size={13} /></span> A happier way to run your shop</motion.div><motion.h1 {...reveal} transition={{ ...reveal.transition, delay: .08 }}>More time for your<br className="desktop-break"/> customers. <span>Less time on khata.</span></motion.h1><motion.p {...reveal} transition={{ ...reveal.transition, delay: .14 }} className="hero-copy">Meet your AI business assistant. Track sales, remember udhaar, and keep stock in check—just by talking, in the language you use every day.</motion.p><motion.div {...reveal} transition={{ ...reveal.transition, delay: .2 }} className="hero-actions"><Link to="/dashboard" className="button-primary">Take a look inside <ArrowRight size={17} /></Link><a href="#how-it-works" className="button-text">See how it works <ArrowDown size={15} /></a></motion.div><motion.div {...reveal} transition={{ ...reveal.transition, delay: .26 }} className="hero-proof"><div className="proof-avatars"><span>R</span><span>S</span><span>M</span><span>+</span></div><div><div className="proof-stars">★★★★★ <span>Made for the people who keep India moving</span></div><small>From the kirana counter to the tailor’s table</small></div></motion.div></div><motion.div {...reveal} transition={{ ...reveal.transition, delay: .18 }} className="hero-visual" id="product"><div className="visual-glow"/><div className="visual-caption"><span className="caption-dot"/> YOUR SHOP, IN GOOD SHAPE</div><DashboardPreview/><div className="float-card float-card-voice"><span><Mic2 size={17}/></span><div><small>VOICE ENTRY</small><b>Sale added, Asha!</b></div><Check size={15}/></div><div className="float-card float-card-stock"><span><ScanLine size={17}/></span><div><small>STOCK CHECK</small><b>Atta running low</b></div></div></motion.div></section>
      <div className="shop-ribbon"><div className="ribbon-label">A good fit for your kind of business</div><div className="ribbon-types"><span><ShoppingBag size={17}/> Kirana shops</span><i/><span><ScanLine size={17}/> Tailors</span><i/><span><Banknote size={17}/> Street vendors</span><i/><span><Package size={17}/> And the neighbourhood around them</span></div></div>
      <section className="feature-section" id="features"><motion.div {...reveal} className="section-intro"><div><div className="eyebrow">A little less to remember</div><h2>Running a shop is a lot.<br/><span>Your khata shouldn’t be.</span></h2></div><p>Good days get busy. Kirana AI takes care of the small details, so you can stay with the people and work that matter.</p></motion.div><div className="feature-grid">{features.map(({ icon: Icon, no, title, copy, tone }, i) => <motion.article key={no} {...reveal} transition={{ ...reveal.transition, delay: i * .06 }} className="feature-card"><div className={`feature-icon ${tone}`}><Icon size={19}/></div><span className="feature-number">{no}</span><h3>{title}</h3><p>{copy}</p><a href="#how-it-works" aria-label={`Learn more: ${title}`}><ArrowUpRight size={17}/></a></motion.article>)}</div></section>
      <section className="steps-section" id="how-it-works"><motion.div {...reveal} className="steps-heading"><div className="eyebrow eyebrow-light">No new routine to learn</div><h2>It fits into the way<br/>you already work.</h2><p>No forms. No complicated setup. Just talk to your assistant, like you’d tell someone at the counter.</p><Link to="/assistant" className="steps-link">Try the voice assistant <ArrowRight size={16}/></Link></motion.div><div className="steps-list"><motion.div {...reveal} className="step-card"><span className="step-count">01</span><div className="step-content"><span className="step-icon"><Mic2 size={19}/></span><div><h3>Say it your way</h3><p>“Asha ji ko 500 ka udhaar likh do.” English, Hindi, Hinglish—whatever feels natural.</p></div></div><div className="chat-bubble"><span className="chat-wave"><AudioLines size={14}/></span> Asha ji ko 500 ka udhaar likh do <span>0:04</span></div></motion.div><motion.div {...reveal} transition={{ ...reveal.transition, delay: .1 }} className="step-card"><span className="step-count">02</span><div className="step-content"><span className="step-icon step-icon-saffron"><Sparkles size={19}/></span><div><h3>We’ll take it from there</h3><p>Your assistant understands, tidies things up, and asks if anything needs a quick check.</p></div></div><div className="parsed-bubble"><span className="parsed-check"><Check size={13}/></span><div><b>Udhaar recorded</b><small>Asha ji <i>·</i> ₹500 <i>·</i> Today</small></div><span className="parsed-tag">KHATA</span></div></motion.div><motion.div {...reveal} transition={{ ...reveal.transition, delay: .18 }} className="step-card"><span className="step-count">03</span><div className="step-content"><span className="step-icon step-icon-blue"><BarChart3 size={19}/></span><div><h3>Get back to your day</h3><p>Sales, stock, and payments all land in one clear view. Close up knowing where things stand.</p></div></div><div className="day-summary"><span className="summary-spark"><Sparkles size={14}/></span><span><b>Tuesday, sorted.</b><small>12 sales · 4 payments · 3 stock reminders</small></span><ArrowUpRight size={15}/></div></motion.div></div></section>
      <section className="promise-section" id="for-every-shop"><motion.div {...reveal} className="promise-inner"><div className="promise-copy"><div className="eyebrow">Built for real life</div><h2>Your business is personal.<br/><span>Your tools should be, too.</span></h2><p>Not everyone runs a shop from a laptop. Kirana AI is built for the busy counter, the stitching table, and the handcart on the move—on the phone you already have.</p><div className="promise-list"><span><Check size={15}/> Talk, type, or tap</span><span><Check size={15}/> Hindi, English & Hinglish</span><span><Check size={15}/> Your business stays yours</span></div><Link to="/dashboard" className="promise-link">Have a look around <ArrowRight size={16}/></Link></div><div className="promise-art"><div className="art-sun"/><div className="art-window"><div className="art-window-top"><span/><span/><span/></div><div className="art-greeting">Good evening, Asha <span>✦</span></div><div className="art-summary-label">YOUR TUESDAY, AT A GLANCE</div><div className="art-stat"><span className="art-stat-icon"><Banknote size={16}/></span><span><small>SALES TODAY</small><b>₹12,480</b></span><span className="art-stat-trend"><TrendingUp size={12}/> 12.8%</span></div><div className="art-stat"><span className="art-stat-icon art-stat-saffron"><Wallet size={16}/></span><span><small>PAYMENTS COLLECTED</small><b>₹9,360</b></span><span className="art-stat-check"><Check size={13}/></span></div><div className="art-assistant"><span><Sparkles size={14}/></span>“Aaj ka din accha raha, Asha ji!”</div></div><div className="art-decoration art-leaf">✳</div><div className="art-decoration art-flower">✿</div></div></motion.div></section>
      <section className="final-cta"><motion.div {...reveal} className="final-cta-inner"><div className="cta-sparkle cta-sparkle-one">✳</div><div className="cta-sparkle cta-sparkle-two">✦</div><div className="eyebrow eyebrow-light">A fresh start for your khata</div><h2>Ready for a lighter<br/>end to the day?</h2><p>Come see what a little help can do.</p><Link to="/dashboard" className="button-cream">Meet your assistant <ArrowRight size={17}/></Link><small>Free to explore · No setup required</small></motion.div></section>
    </main>
    <footer className="site-footer"><div className="footer-main"><div className="footer-brand"><Brand inverse/><p>A little help for the people<br/>who keep the neighbourhood going.</p></div><div className="footer-links"><div><b>Take a look</b><a href="#product">The product</a><a href="#features">What it does</a><a href="#how-it-works">How it works</a></div><div><b>Your shop</b><Link to="/dashboard">Explore the demo</Link><Link to="/assistant">Try the assistant</Link><a href="#for-every-shop">Who it’s for</a></div><div><b>Made with care</b><span>Designed for small<br/>businesses across India</span><span className="footer-made">Made for Bharat <span>♥</span></span></div></div></div><div className="footer-bottom"><span>© 2026 Kirana AI. Made for the everyday.</span><span>Simple tools. Good days. <span>✳</span></span></div></footer>
  </div>
}
