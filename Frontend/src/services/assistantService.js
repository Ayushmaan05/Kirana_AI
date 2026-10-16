import apiClient from './apiClient.js';

// ─── AI Response Parser (client-side fallback) ───────────────────────────────
// Used when the backend doesn't have an /api/assistant/message endpoint yet.
// This provides a local NLP-style parser so the assistant page still works.

function parseLocalInput(text) {
  const lower = text.toLowerCase();

  if (/bech|sold|sale|bikri|diya(?! udhar)/.test(lower)) {
    const itemMatches = [...text.matchAll(/(\d+(?:\.\d+)?)\s*(kg|g|ltr|litre|liter|packet(?:s)?|pkt|pcs|piece(?:s)?)?\s*([a-z][a-z0-9 -]*?)\s+(?:for|at)\s*(?:\u20b9|rs\.?\s*)?(\d{1,3}(?:,\d{3})+|\d+(?:\.\d{1,2})?)/gi)];
    const items = itemMatches.map(([, quantity, unit = 'pcs', name, amount]) => ({
      name: name.trim().replace(/^of\s+/i, '').replace(/\s+/g, ' '),
      quantity: Number(quantity),
      unit: unit || 'pcs',
      amount: Number(amount.replace(/,/g, '')),
    }));
    if (items.length) {
      const amount = items.reduce((sum, item) => sum + item.amount, 0);
      const payment_mode = lower.includes('upi') ? 'upi' : 'cash';
      return {
        intent: 'SALE',
        extracted: { amount, payment_mode, items },
        reply: `I understood ${items.length} sale items totalling ₹${amount}. Please review the record before saving.`,
        transaction: { type: 'sale', amount, payment_mode, items, description: text, status: 'pending_confirmation' },
      };
    }
    const amountMatch = text.match(/₹?\s*(\d[\d,]*(?:\.\d{1,2})?)/);
    const amount = amountMatch ? Number(amountMatch[1].replace(/,/g, '')) : null;
    return {
      intent: 'SALE',
      extracted: { amount, payment_mode: lower.includes('upi') ? 'upi' : 'cash' },
      reply: amount
        ? `✅ Got it! Sale of ₹${amount} recorded (${lower.includes('upi') ? 'UPI' : 'Cash'}).`
        : `I understood this as a sale but couldn't extract the amount. Can you clarify?`,
      transaction: amount ? {
        type: 'sale', amount, payment_mode: lower.includes('upi') ? 'upi' : 'cash',
        description: text, status: 'pending_confirmation',
      } : null,
    };
  }

  if (/udhar|udhaar|credit|baaki|baki/.test(lower)) {
    const amountMatch = text.match(/₹?\s*(\d[\d,]*(?:\.\d{1,2})?)/);
    const amount = amountMatch ? Number(amountMatch[1].replace(/,/g, '')) : null;
    const nameMatch = text.match(/([A-Z][a-z]+ [A-Z][a-z]+|[A-Z][a-z]+)\s*(ko|ne|ka)?/);
    const name = nameMatch ? nameMatch[1] : null;
    return {
      intent: 'UDHAAR',
      extracted: { amount, customerName: name },
      reply: `📝 Udhaar entry noted! ${name ? `Customer: ${name}. ` : ''}${amount ? `Amount: ₹${amount}.` : ''} Confirm to save.`,
      transaction: amount ? {
        type: 'udhaar_given', amount, customer_name: name,
        description: text, status: 'pending_confirmation',
      } : null,
    };
  }

  if (/kharcha|expense|rent|bijli|electricity|payment/.test(lower)) {
    const amountMatch = text.match(/₹?\s*(\d[\d,]*(?:\.\d{1,2})?)/);
    const amount = amountMatch ? Number(amountMatch[1].replace(/,/g, '')) : null;
    return {
      intent: 'EXPENSE',
      extracted: { amount },
      reply: `💸 Expense of ₹${amount || '?'} noted. ${amount ? 'Confirm to save.' : 'Please specify the amount.'}`,
      transaction: amount ? {
        type: 'expense', amount, description: text, status: 'pending_confirmation',
      } : null,
    };
  }

  if (/stock|inventory|maal|product|item|add.*pack|mila/.test(lower)) {
    return {
      intent: 'STOCK_UPDATE',
      extracted: {},
      reply: `📦 Stock update registered. Check your Inventory page for updates.`,
      transaction: null,
    };
  }

  if (/summary|aaj ka|today|report|kitna/.test(lower)) {
    return {
      intent: 'QUERY_SUMMARY',
      extracted: {},
      reply: `📊 Loading your summary from the dashboard…`,
      transaction: null,
    };
  }

  if (/low stock|khatam|kya bacha|kya hai/.test(lower)) {
    return {
      intent: 'QUERY_STOCK',
      extracted: {},
      reply: `📦 Checking inventory for low stock items…`,
      transaction: null,
    };
  }

  // Default
  return {
    intent: 'UNKNOWN',
    extracted: {},
    reply: `I'm your Kirana AI assistant 🤖\n\nYou can tell me things like:\n• "Sold rice ₹200 cash"\n• "Ramesh ko ₹500 udhaar diya"\n• "Show today's summary"\n• "Which items are low stock?"`,
    transaction: null,
  };
}

export async function sendMessage(text) {
  // Try the backend AI endpoint first; fall back to local parsing
  try {
    return await apiClient.post('/api/assistant/message', { message: text });
  } catch {
    // Backend doesn't have this endpoint yet — use local parser
    return parseLocalInput(text);
  }
}

export async function transcribeAudio(audioBlob) {
  const formData = new FormData();
  formData.append('audio', audioBlob, 'recording.webm');
  const url = `${import.meta.env.VITE_API_BASE_URL || ''}/api/assistant/transcribe`;
  const res = await fetch(url, {
    method: 'POST',
    body: formData,
  });
  if (!res.ok) throw new Error('Transcription failed');
  return res.json();
}
