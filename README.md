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

### 1. Frontend (demo mode)

```bash
cd Frontend
npm ci
npm run dev
```

Visit `http://localhost:5173` in your browser.

The frontend runs with built-in demo data when `VITE_API_BASE_URL` is unset. To
connect it to a compatible API, copy `Frontend/.env.example` to
`Frontend/.env.local`, set `VITE_API_BASE_URL`, and restart the dev server.
Only `VITE_*` variables are exposed to browser code: never put API keys or other
secrets in a frontend environment file.

### 2. Backend

The `Backend/` directory currently contains setup notes only; it does not yet
include a runnable API application or dependency list. Backend configuration
belongs in `Backend/.env` (see `Backend/.env.example`) when the service is
implemented. Do not put server-side credentials in the frontend.
