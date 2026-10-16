import { useEffect } from 'react';
import { useApp } from '../context/AppContext.jsx';
import { hi } from '../utils/translations.js';

const en = Object.fromEntries(Object.entries(hi).map(([english, hindi]) => [hindi, english]));

/** Applies the UI copy to the complete page, including lazy-loaded screens. */
export default function LanguageLayer() {
  const { language } = useApp();

  useEffect(() => {
    const translate = (root) => {
      const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT);
      let node;
      while ((node = walker.nextNode())) {
        const source = node.nodeValue;
        const trimmed = source.trim();
        const replacement = language === 'hi' ? hi[trimmed] : en[trimmed];
        if (replacement) node.nodeValue = source.replace(trimmed, replacement);
      }
      root.querySelectorAll?.('[placeholder], [aria-label], [title]').forEach((el) => {
        ['placeholder', 'aria-label', 'title'].forEach((attr) => {
          const value = el.getAttribute(attr);
          const replacement = value && (language === 'hi' ? hi[value] : en[value]);
          if (replacement) el.setAttribute(attr, replacement);
        });
      });
    };

    translate(document.body);
    const observer = new MutationObserver((records) => {
      records.forEach(({ target, addedNodes }) => {
        if (target.nodeType === Node.TEXT_NODE) translate(target.parentElement || document.body);
        addedNodes?.forEach((node) => { if (node.nodeType === Node.ELEMENT_NODE) translate(node); });
      });
    });
    observer.observe(document.body, { childList: true, characterData: true, subtree: true });
    return () => observer.disconnect();
  }, [language]);

  return null;
}
