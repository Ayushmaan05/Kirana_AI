# Kirana AI (किराना AI) 🛒

An AI-powered voice & text business assistant designed for Indian small business owners (kirana shops, tailors, street vendors). Simplifies bookkeeping, inventory management, customer credit (udhaar), and GST-ready summaries through natural language and voice input.

---

## Project Structure

```
Kirana-AI/
├── Frontend/         # React 18 + Vite + Tailwind/Modern UI frontend
│   ├── public/       # Static assets & favicons
│   ├── src/          # Application source code
│   │   ├── components/ # Common, layout, charts, audio UI components
│   │   ├── context/    # App global state (AppContext)
│   │   ├── data/       # Rich Indian shopkeeper mock datasets
│   │   ├── models/     # Data models (transactions, inventory, udhaar)
│   │   ├── pages/      # Landing, Dashboard, Assistant, Sales, Inventory, Customers, Reports, Settings
│   │   ├── routes/     # App routing configuration
│   │   ├── services/   # API client & local mock storage services
│   │   └── utils/      # Currency (INR) and formatting utilities
│   ├── package.json
│   └── vite.config.js
│
├── Backend/          # FastAPI backend service (Python)
│   └── README.md     # Architecture and planned endpoints
│
└── README.md         # Project documentation
```

---

## Getting Started

### 1. Frontend Development

```bash
cd Frontend
npm install
npm run dev
```

Visit `http://localhost:5173` in your browser.

### 2. Backend Development (FastAPI)

```bash
cd Backend
python -m venv .venv
.venv\Scripts\activate
# uvicorn app.main:app --reload --port 8000
```
