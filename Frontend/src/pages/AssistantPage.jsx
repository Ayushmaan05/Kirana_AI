import React, { useState, useRef, useEffect, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Send, Mic, MicOff, Bot, User, CheckCircle2, X, RefreshCw, Sparkles } from 'lucide-react';
import { sendMessage, transcribeAudio } from '../services/assistantService.js';
import { addTransaction } from '../services/dashboardService.js';
import { formatCurrency } from '../utils/formatCurrency.js';
import { useApp } from '../context/AppContext.jsx';
import LoadingSpinner from '../components/common/LoadingSpinner.jsx';
import Badge from '../components/common/Badge.jsx';
import apiClient from '../services/apiClient.js';

const SUGGESTIONS = [
  'Sold 5 kg rice for ₹250 cash',
  'Ramesh ko ₹500 udhaar diya',
  'Show today\'s sales summary',
  'Which products are low on stock?',
  'Add 10 packets of Maggi to stock',
  'Suresh ne ₹200 diya (udhaar payment)',
];

function MessageBubble({ msg }) {
  const isUser = msg.role === 'user';
  return (
    <motion.div
      className={`flex gap-3 ${isUser ? 'flex-row-reverse' : 'flex-row'}`}
      initial={{ opacity: 0, y: 12 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.25 }}
    >
      {/* Avatar */}
      <div className={`w-8 h-8 rounded-xl flex items-center justify-center flex-shrink-0 ${
        isUser
          ? 'bg-emerald-500'
          : 'bg-slate-100 border border-slate-200'
      }`}>
        {isUser
          ? <User size={15} className="text-white" />
          : <Bot size={15} className="text-emerald-600" />
        }
      </div>

      <div className={`max-w-[75%] flex flex-col gap-2 ${isUser ? 'items-end' : 'items-start'}`}>
        {/* Text */}
        <div className={isUser ? 'chat-bubble-user' : 'chat-bubble-ai'}>
          <p className="text-sm leading-relaxed whitespace-pre-wrap">{msg.text}</p>
        </div>

        {/* Pending transaction card */}
        {msg.transaction && msg.transaction.status === 'pending_confirmation' && (
          <TransactionConfirmCard
            transaction={msg.transaction}
            onConfirm={msg.onConfirm}
            onDismiss={msg.onDismiss}
          />
        )}

        <p className="text-xs text-slate-400 px-1">{msg.time}</p>
      </div>
    </motion.div>
  );
}

function TransactionConfirmCard({ transaction, onConfirm, onDismiss }) {
  const [status, setStatus] = useState('pending'); // pending | confirming | confirmed | dismissed

  async function handleConfirm() {
    setStatus('confirming');
    try {
      await addTransaction(transaction);
      setStatus('confirmed');
    } catch {
      setStatus('pending');
    }
  }

  if (status === 'confirmed') {
    return (
      <div className="flex items-center gap-2 text-xs text-emerald-600 font-semibold px-1">
        <CheckCircle2 size={14} /> Saved to your ledger!
      </div>
    );
  }

  return (
    <div className="card p-3 border-emerald-200" style={{ background: '#f0fdf4', minWidth: 240 }}>
      <div className="flex items-center justify-between mb-2">
        <span className="text-xs font-bold text-emerald-700 uppercase tracking-wide">Confirm Entry</span>
        <button onClick={onDismiss} className="text-slate-400 hover:text-slate-600">
          <X size={14} />
        </button>
      </div>
      <div className="space-y-1 text-sm mb-3">
        <div className="flex justify-between">
          <span className="text-slate-500">Type</span>
          <span className="font-semibold text-slate-700 capitalize">{transaction.type?.replace(/_/g, ' ')}</span>
        </div>
        <div className="flex justify-between">
          <span className="text-slate-500">Amount</span>
          <span className="font-bold text-emerald-700">{formatCurrency(transaction.amount)}</span>
        </div>
        {transaction.customer_name && (
          <div className="flex justify-between">
            <span className="text-slate-500">Customer</span>
            <span className="font-semibold text-slate-700">{transaction.customer_name}</span>
          </div>
        )}
        {transaction.payment_mode && (
          <div className="flex justify-between">
            <span className="text-slate-500">Mode</span>
            <span className="font-semibold text-slate-700 capitalize">{transaction.payment_mode}</span>
          </div>
        )}
      </div>
      <button
        onClick={handleConfirm}
        disabled={status === 'confirming'}
        className="btn btn-primary w-full text-sm"
        style={{ padding: '0.4rem 1rem' }}
      >
        {status === 'confirming' ? (
          <><RefreshCw size={13} className="animate-spin" /> Saving…</>
        ) : (
          <><CheckCircle2 size={13} /> Confirm & Save</>
        )}
      </button>
    </div>
  );
}

export default function AssistantPage() {
  const [messages, setMessages] = useState([
    {
      id: 'welcome',
      role: 'ai',
      text: `Namaste! 🙏 Main aapka AI Business Assistant hoon.\n\nAap mujhe bata sakte hain:\n• "Sold 5 kg rice ₹250 cash"\n• "Ramesh ko ₹500 udhaar diya"\n• "Aaj kitni sales hui?"\n• "Kaunsa maal khatam ho raha hai?"\n\nBolo ya likho — main samjhunga! 😊`,
      time: 'Just now',
    },
  ]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const [recording, setRecording] = useState(false);
  const [recorderError, setRecorderError] = useState('');
  const messagesEndRef = useRef(null);
  const inputRef = useRef(null);
  const mediaRecorderRef = useRef(null);
  const chunksRef = useRef([]);
  const { addNotification } = useApp();

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  async function handleSend(text = input.trim()) {
    if (!text || loading) return;
    setInput('');
    setLoading(true);

    const userMsg = {
      id: Date.now(),
      role: 'user',
      text,
      time: new Date().toLocaleTimeString('en-IN', { hour: '2-digit', minute: '2-digit', hour12: true }),
    };
    setMessages(prev => [...prev, userMsg]);

    try {
      const response = await sendMessage(text);
      const aiMsgId = Date.now() + 1;
      const aiMsg = {
        id: aiMsgId,
        role: 'ai',
        text: response.reply,
        time: new Date().toLocaleTimeString('en-IN', { hour: '2-digit', minute: '2-digit', hour12: true }),
        transaction: response.transaction,
        onConfirm: () => {},
        onDismiss: () => setMessages(prev =>
          prev.map(m => m.id === aiMsgId ? { ...m, transaction: null } : m)
        ),
      };
      setMessages(prev => [...prev, aiMsg]);
    } catch (err) {
      setMessages(prev => [...prev, {
        id: Date.now() + 2,
        role: 'ai',
        text: 'Sorry, kuch technical gadbad ho gayi. Dobara try karein.',
        time: new Date().toLocaleTimeString('en-IN', { hour: '2-digit', minute: '2-digit', hour12: true }),
      }]);
    } finally {
      setLoading(false);
      inputRef.current?.focus();
    }
  }

  async function toggleRecording() {
    if (recording) {
      mediaRecorderRef.current?.stop();
      setRecording(false);
      return;
    }

    setRecorderError('');
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      chunksRef.current = [];
      const mr = new MediaRecorder(stream);
      mediaRecorderRef.current = mr;

      mr.ondataavailable = e => { if (e.data.size > 0) chunksRef.current.push(e.data); };
      mr.onstop = async () => {
        stream.getTracks().forEach(t => t.stop());
        const blob = new Blob(chunksRef.current, { type: 'audio/webm' });
        setLoading(true);
        try {
          const { text } = await transcribeAudio(blob);
          if (text) await handleSend(text);
        } catch {
          addNotification({ type: 'error', title: 'Transcription failed', message: 'Could not process audio.' });
        } finally {
          setLoading(false);
        }
      };

      mr.start();
      setRecording(true);
    } catch {
      setRecorderError('Microphone access denied. Please allow microphone permission.');
    }
  }

  return (
    <div className="flex flex-col h-[calc(100vh-130px)] lg:h-[calc(100vh-90px)] max-w-4xl mx-auto">
      {/* Header */}
      <div className="card p-4 mb-3 flex items-center gap-3">
        <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ background: 'var(--color-primary-light)' }}>
          <Bot size={22} style={{ color: 'var(--color-primary)' }} />
        </div>
        <div>
          <div className="flex items-center gap-2">
            <h2 className="text-h3 text-slate-800">AI Business Assistant</h2>
            <span className="flex items-center gap-1 text-xs font-semibold text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded-full">
              <Sparkles size={11} /> AI
            </span>
          </div>
          <p className="text-xs text-slate-400">
            {apiClient.isDemoMode ? '🎭 Demo Mode — Smart mock responses' : 'Connected to backend'}
          </p>
        </div>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto card p-4 space-y-4 mb-3">
        {messages.map(msg => (
          <MessageBubble key={msg.id} msg={msg} />
        ))}
        {loading && (
          <div className="flex gap-3">
            <div className="w-8 h-8 rounded-xl bg-slate-100 border border-slate-200 flex items-center justify-center">
              <Bot size={15} className="text-emerald-600" />
            </div>
            <div className="chat-bubble-ai">
              <div className="flex items-center gap-1.5">
                {[0, 0.15, 0.3].map(d => (
                  <span key={d} className="w-2 h-2 rounded-full bg-slate-300"
                    style={{ animation: `blink 1s ${d}s step-start infinite` }} />
                ))}
              </div>
            </div>
          </div>
        )}
        <div ref={messagesEndRef} />
      </div>

      {/* Suggestions */}
      <div className="flex gap-2 mb-3 overflow-x-auto no-scrollbar pb-1">
        {SUGGESTIONS.map(s => (
          <button
            key={s}
            onClick={() => handleSend(s)}
            disabled={loading}
            className="flex-shrink-0 text-xs px-3 py-1.5 rounded-full border font-medium transition-colors hover:border-emerald-400 hover:text-emerald-700"
            style={{ borderColor: 'var(--color-border)', color: 'var(--color-text-muted)', background: 'white' }}
          >
            {s}
          </button>
        ))}
      </div>

      {/* Input */}
      {recorderError && (
        <p className="text-xs text-red-500 mb-2 px-1">{recorderError}</p>
      )}
      <div className="card flex items-center gap-2 p-2 shadow-md">
        {/* Mic */}
        <button
          onClick={toggleRecording}
          disabled={loading}
          className={`btn btn-icon flex-shrink-0 transition-all ${recording ? 'animate-pulse-ring' : ''}`}
          style={{
            background: recording ? '#fef2f2' : 'var(--color-primary-light)',
            color: recording ? 'var(--color-error)' : 'var(--color-primary)',
          }}
          aria-label={recording ? 'Stop recording' : 'Start voice input'}
        >
          {recording ? <MicOff size={18} /> : <Mic size={18} />}
        </button>

        {/* Text input */}
        <input
          ref={inputRef}
          value={input}
          onChange={e => setInput(e.target.value)}
          onKeyDown={e => { if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); handleSend(); } }}
          placeholder={recording ? '🎙️ Listening… tap mic to stop' : 'Type a sale, purchase, udhaar… (Hindi/English)'}
          className="flex-1 border-0 outline-none text-sm text-slate-700 bg-transparent placeholder-slate-400 py-2 px-1"
          disabled={loading || recording}
          id="assistant-input"
          aria-label="Message input"
        />

        {/* Send */}
        <button
          onClick={() => handleSend()}
          disabled={!input.trim() || loading}
          className="btn btn-primary btn-icon flex-shrink-0"
          aria-label="Send message"
        >
          <Send size={16} />
        </button>
      </div>
    </div>
  );
}
