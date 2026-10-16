import { useApp } from '../context/AppContext.jsx';

export default function LanguageToggle({ dark = false, className = '' }) {
  const { language, setLanguage } = useApp();
  const next = language === 'en' ? 'hi' : 'en';
  return (
    <button
      type="button"
      onClick={() => setLanguage(next)}
      className={`inline-flex shrink-0 items-center justify-center rounded-full border px-3 py-2 text-xs font-semibold transition-colors ${dark ? 'border-white/15 text-white/80 hover:bg-white/10' : 'border-black/10 bg-white/80 text-black/75 hover:bg-white'} ${className}`}
      aria-label={language === 'en' ? 'Switch language to Hindi' : 'भाषा अंग्रेज़ी में बदलें'}
      title={language === 'en' ? 'Switch language to Hindi' : 'Switch language to English'}
    >
      {language === 'en' ? 'हिंदी' : 'English'}
    </button>
  );
}
