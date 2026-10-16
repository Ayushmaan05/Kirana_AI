# Kirana-AI

Hindi-first AI ledger for small shops to track sales, manage stock, and generate daily summaries using simple text or voice notes.

---

## 🗄️ Database Architecture (SQLite 3)

The database engine is built on **SQLite 3.35+**, offering a serverless, zero-configuration, fully ACID-compliant relational data store tailored for edge deployment on shop PCs, mobile devices, or cloud containers.

### Tables (12 Total)

1. **`app_users`**: Store staff, managers, and cashiers
2. **`categories`**: Grocery departments (Dairy, Grains, Flour, Biscuits, Spices, etc.)
3. **`suppliers`**: Vendor master data with delivery lead times
4. **`products`**: Product catalog with SKU, purchase cost, MRP, current stock, and expiry dates
5. **`sales`**: Customer bill / invoice header
6. **`cash_payments`**: Physical cash ledger tracking tendered currency, net cash received, return change, and denomination breakdowns
7. **`online_payments`**: Digital payment ledger tracking UPI, QR, Card POS, providers (PhonePe, GPay, Paytm, Pine Labs), and UTR reference IDs
8. **`sale_items`**: Line items sold in each bill with snapshot historical pricing
9. **`purchases`**: Goods received / supplier purchase order headers
10. **`purchase_items`**: Batch quantities and costs received from vendors
11. **`inventory_movements`**: Immutable stock movement audit log
12. **`ai_insights`**: AI & SQL-based demand forecasts, moving averages, and restock suggestions

### Analytical Views (7 Total)

- **`vw_daily_payment_breakdown`**: Daily totals for cash collected, online payments received, change returned, and digital adoption %
- **`vw_cashier_cash_register`**: Cash drawer balancing and shift reconciliation per cashier
- **`vw_low_stock_products`**: Reorder alerts for items below minimum stock level
- **`vw_expiring_soon`**: Items nearing expiry within 30 days
- **`vw_daily_sales_summary`**: Daily sales, discounts, taxes, and estimated gross profit
- **`vw_product_daily_sales`**: Product-by-day sales time series for AI demand forecasting
- **`vw_inventory_valuation`**: Current inventory valued at cost vs selling price

---

## 🚀 Quick Start

### Initialize Database & Run Tests

```bash
# Initialize SQLite database (database/kirana_store.db) and run all tests
python database/init_db.py --test

# View table row statistics
python database/init_db.py --stats
```

### Direct SQLite CLI Usage

```bash
# Load schema
sqlite3 database/kirana_store.db < database/schema.sql

# Load sample data
sqlite3 database/kirana_store.db < database/sample_data.sql

# Run test suite
sqlite3 database/kirana_store.db < database/database_testing.sql
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
