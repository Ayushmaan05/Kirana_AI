# AI Kirana Store — Database Documentation

> **Module**: Database Design & SQL  
> **Database Engine**: SQLite 3.35+ (Serverless, Embedded ACID Relational DB)  
> **Project**: AI Kirana Store — Hindi-first AI Ledger & Smart Grocery Management System  

---

## 1. Project Overview

### What is AI Kirana Store?
AI Kirana Store is an intelligent grocery store management system and Hindi-first AI ledger designed for Indian kirana (grocery) shops. It manages:
- **Products & Inventory** — Track stock levels, prices, batch expiry dates
- **Sales & Billing** — Record customer bills with line-item discounts
- **Cash & Online Payments** — Dual-channel payment ledger tracking cash drawer denominations, change returned, and UPI/Card digital transaction references
- **Purchases** — Track goods received from suppliers and purchase orders
- **AI Forecasting** — Predict demand, moving averages, and restocking recommendations

### What This Database Module Covers
This module provides the **complete database layer** for the application:
- 12 normalized SQLite tables with strict referential integrity
- Dedicated schemas for cash and online digital payments
- Sample data with realistic Indian grocery products and 90+ days of sales
- Comprehensive analytical queries for daily sales, revenue, drawer tally, and digital adoption
- SQL-based moving average demand forecasting module
- Automated triggers for `updated_at` modification timestamps
- SQLite views for reporting, low-stock alerts, expiry warnings, and cashier cash registers

### Technology Stack
| Component | Technology |
|---|---|
| RDBMS | SQLite 3.35+ (built into Python standard library) |
| Storage Mode | Serverless, single-file database (`kirana_store.db`) |
| Foreign Key Integrity | Enabled via `PRAGMA foreign_keys = ON;` |
| Character Encoding | UTF-8 (native Hindi and multi-language support) |
| Concurrency & ACID | Full ACID compliance with WAL (Write-Ahead Logging) support |

---

## 2. Database Architecture

The database comprises **12 tables** organized into 5 logical groups:

### Master Data (reference tables)
1. **app_users** — Store staff and administrators
2. **categories** — Grocery product categories
3. **suppliers** — Vendor master information

### Inventory Catalog
4. **products** — Product catalog with prices, stock levels, and expiry dates

### Sales & Payments Ledger
5. **sales** — Customer bill / invoice headers
6. **cash_payments** — Physical cash drawer transactions, amount tendered, and return change
7. **online_payments** — Digital payments (UPI, QR code, Card POS, provider, UTR / reference IDs)
8. **sale_items** — Individual product lines sold in each invoice

### Procurement Data
9. **purchases** — Supplier purchase orders / GRN headers
10. **purchase_items** — Line items received from suppliers

### Audit & Intelligence
11. **inventory_movements** — Complete audit trail of every stock increase and decrease
12. **ai_insights** — AI/SQL demand forecasts and restocking suggestions

---

## 3. Detailed Table Documentation

### 3.1 app_users

**Purpose**: Stores information about store staff — administrators, managers, cashiers, and inventory clerks.

| Column | Type | Constraints | Purpose |
|---|---|---|---|
| `user_id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique user identifier |
| `username` | TEXT | NOT NULL, UNIQUE | Login handle |
| `password_hash` | TEXT | NOT NULL | Salted bcrypt/argon2 hash (never plaintext) |
| `full_name` | TEXT | NOT NULL | Employee's full name |
| `email` | TEXT | UNIQUE | Contact email address |
| `phone` | TEXT | | Mobile phone number |
| `role` | TEXT | NOT NULL, DEFAULT 'cashier' | `admin` / `manager` / `cashier` / `inventory_clerk` |
| `is_active` | INTEGER | NOT NULL, DEFAULT 1 | `1` (Active) or `0` (Inactive) |
| `created_at` | TEXT | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Account creation timestamp |
| `updated_at` | TEXT | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Last modification timestamp (via trigger) |

---

### 3.2 categories

**Purpose**: Organizes products into grocery categories like Dairy, Grains, Flour, Biscuits, Spices, etc.

| Column | Type | Constraints | Purpose |
|---|---|---|---|
| `category_id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique category identifier |
| `category_name` | TEXT | NOT NULL, UNIQUE | Category display name |
| `description` | TEXT | | Brief category description |
| `is_active` | INTEGER | NOT NULL, DEFAULT 1 | `1` (Active) or `0` (Inactive) |
| `created_at` | TEXT | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Record created timestamp |
| `updated_at` | TEXT | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Record updated timestamp |

---

### 3.3 suppliers

**Purpose**: Stores vendor information for procurement and restocking.

| Column | Type | Constraints | Purpose |
|---|---|---|---|
| `supplier_id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique supplier identifier |
| `supplier_name` | TEXT | NOT NULL | Company / vendor name |
| `contact_person` | TEXT | | Point of contact person |
| `phone` | TEXT | | Contact phone number |
| `email` | TEXT | | Vendor email address |
| `address` | TEXT | | Physical premises address |
| `city` | TEXT | | City |
| `state` | TEXT | | State |
| `gstin` | TEXT | | 15-digit GST Identification Number (India) |
| `lead_time_days` | INTEGER | NOT NULL, DEFAULT 3, CHECK ≥ 0 | Average delivery lead time in days |
| `is_active` | INTEGER | NOT NULL, DEFAULT 1 | Active status flag |
| `created_at` | TEXT | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Created timestamp |
| `updated_at` | TEXT | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Updated timestamp |

---

### 3.4 products

**Purpose**: Central product master table — stores purchase cost, selling MRP, real-time stock levels, and batch expiry.

| Column | Type | Constraints | Purpose |
|---|---|---|---|
| `product_id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique product identifier |
| `sku` | TEXT | NOT NULL, UNIQUE | Stock Keeping Unit code |
| `product_name` | TEXT | NOT NULL | Display item name |
| `category_id` | INTEGER | NOT NULL, FK → categories | Category foreign key |
| `supplier_id` | INTEGER | FK → suppliers | Primary supplier (NULL if unassigned) |
| `brand` | TEXT | | Brand name (e.g., Mother Dairy, Parle) |
| `unit` | TEXT | NOT NULL, DEFAULT 'piece' | Unit of measure (kg, litre, pouch, pack) |
| `cost_price` | NUMERIC | NOT NULL, DEFAULT 0, CHECK ≥ 0 | Unit cost price from supplier |
| `selling_price` | NUMERIC | NOT NULL, DEFAULT 0, CHECK ≥ 0 | Retail selling price (MRP) |
| `current_stock` | NUMERIC | NOT NULL, DEFAULT 0, CHECK ≥ 0 | Current quantity on shop floor |
| `min_stock_level` | NUMERIC | NOT NULL, DEFAULT 10, CHECK ≥ 0 | Reorder point for low-stock alerts |
| `max_stock_level` | NUMERIC | NOT NULL, DEFAULT 500, CHECK ≥ 0 | Maximum shelf / storage limit |
| `expiry_date` | TEXT | NULL allowed | Expiry date in YYYY-MM-DD format |
| `is_active` | INTEGER | NOT NULL, DEFAULT 1 | Soft-delete flag (1 = active) |
| `created_at` | TEXT | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Timestamp created |
| `updated_at` | TEXT | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Timestamp updated |

---

### 3.5 sales

**Purpose**: Records each customer bill header and high-level transaction state.

| Column | Type | Constraints | Purpose |
|---|---|---|---|
| `sale_id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique sale identifier |
| `invoice_number` | TEXT | NOT NULL, UNIQUE | Bill reference (e.g. `INV-20261015-001`) |
| `sale_date` | TEXT | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Date and time of sale |
| `customer_name` | TEXT | DEFAULT 'Walk-in Customer' | Customer name (optional) |
| `customer_phone` | TEXT | | Customer mobile number |
| `cashier_id` | INTEGER | NOT NULL, FK → app_users | Cashier who generated invoice |
| `total_amount` | NUMERIC | NOT NULL, CHECK ≥ 0 | Gross subtotal before discounts |
| `discount_amount` | NUMERIC | NOT NULL, DEFAULT 0, CHECK ≥ 0 | Total discount given on the bill |
| `tax_amount` | NUMERIC | NOT NULL, DEFAULT 0, CHECK ≥ 0 | Tax charged (GST) |
| `net_amount` | NUMERIC | NOT NULL, CHECK ≥ 0 | Final amount = total - discount + tax |
| `payment_method` | TEXT | NOT NULL, DEFAULT 'cash' | `cash`, `upi`, `card`, `credit`, `mixed`, `online` |
| `status` | TEXT | NOT NULL, DEFAULT 'completed' | `completed`, `cancelled`, `refunded` |
| `notes` | TEXT | | Optional notes |
| `created_at` | TEXT | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Created timestamp |
| `updated_at` | TEXT | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Updated timestamp |

---

### 3.6 cash_payments (NEW SCHEMA)

**Purpose**: Dedicated cash payment ledger for physical currency handling at the billing counter. Tracks currency tendered, exact change returned, cashier cash drawer custody, and denomination breakdown.

| Column | Type | Constraints | Purpose |
|---|---|---|---|
| `cash_payment_id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique cash payment transaction ID |
| `sale_id` | INTEGER | NOT NULL, FK → sales (CASCADE) | Associated invoice ID |
| `cashier_id` | INTEGER | NOT NULL, FK → app_users (RESTRICT) | Cashier who accepted and verified the cash |
| `amount_tendered` | NUMERIC | NOT NULL, CHECK ≥ 0 | Physical cash handed over by customer (e.g., ₹500 note) |
| `amount_received` | NUMERIC | NOT NULL, CHECK ≥ 0 | Net cash amount retained for the bill |
| `change_returned` | NUMERIC | NOT NULL, DEFAULT 0, CHECK ≥ 0 | Change given back to customer (`tendered - received`) |
| `denomination_breakdown` | TEXT | JSON string check | Currency notes breakdown (e.g. `{"500": 1, "100": 2}`) |
| `payment_status` | TEXT | NOT NULL, DEFAULT 'completed' | `completed`, `cancelled`, `refunded` |
| `payment_time` | TEXT | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Exact transaction timestamp |
| `notes` | TEXT | | Shift notes or drawer remarks |
| `created_at` | TEXT | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Created timestamp |
| `updated_at` | TEXT | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Updated timestamp |

---

### 3.7 online_payments (NEW SCHEMA)

**Purpose**: Dedicated digital payment ledger for tracking UPI, dynamic QR codes, Card POS swiping machines, soundbox alerts, UTR reference numbers, and payment gateway fees.

| Column | Type | Constraints | Purpose |
|---|---|---|---|
| `online_payment_id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique digital payment ID |
| `sale_id` | INTEGER | NOT NULL, FK → sales (CASCADE) | Associated invoice ID |
| `payment_platform` | TEXT | NOT NULL | `upi`, `card_pos`, `qr_code`, `net_banking`, `wallet`, `other` |
| `provider` | TEXT | NOT NULL | `PhonePe`, `Google Pay`, `Paytm`, `BHIM`, `Pine Labs`, `HDFC POS`, `Razorpay`, `SBI`, `Other` |
| `transaction_reference_id` | TEXT | NOT NULL, UNIQUE | 12-digit UTR, RRN, or bank authorization code |
| `amount` | NUMERIC | NOT NULL, CHECK > 0 | Amount credited electronically |
| `payer_upi_id` | TEXT | | Customer VPA / UPI address (e.g. `name@okhdfcbank`) |
| `payer_phone` | TEXT | | Customer mobile number linked to UPI/wallet |
| `payment_status` | TEXT | NOT NULL, DEFAULT 'success' | `initiated`, `success`, `pending`, `failed`, `refunded` |
| `gateway_fee` | NUMERIC | NOT NULL, DEFAULT 0, CHECK ≥ 0 | MDR or payment terminal processing fee |
| `settlement_status` | TEXT | NOT NULL, DEFAULT 'settled' | `pending`, `settled`, `failed` |
| `terminal_device_id` | TEXT | | POS terminal ID or soundbox hardware identifier |
| `gateway_response` | TEXT | JSON string check | Gateway webhook payload or auth response |
| `payment_time` | TEXT | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Payment settlement timestamp |
| `notes` | TEXT | | Transaction remarks |
| `created_at` | TEXT | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Created timestamp |
| `updated_at` | TEXT | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Updated timestamp |

---

### 3.8 sale_items

**Purpose**: Records individual line items for each bill. Snapshot pricing captures prices at time of sale.

| Column | Type | Constraints | Purpose |
|---|---|---|---|
| `sale_item_id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique line item identifier |
| `sale_id` | INTEGER | NOT NULL, FK → sales (CASCADE) | Parent invoice identifier |
| `product_id` | INTEGER | NOT NULL, FK → products (RESTRICT) | Product sold |
| `quantity` | NUMERIC | NOT NULL, CHECK > 0 | Quantity sold (supports fractional weights) |
| `unit_price` | NUMERIC | NOT NULL, CHECK ≥ 0 | Price per unit at time of sale (snapshot) |
| `cost_price` | NUMERIC | NOT NULL, DEFAULT 0, CHECK ≥ 0 | Purchase cost at time of sale |
| `discount` | NUMERIC | NOT NULL, DEFAULT 0, CHECK ≥ 0 | Line-item discount |
| `line_total` | NUMERIC | NOT NULL, CHECK ≥ 0 | `= quantity * unit_price - discount` |
| `created_at` | TEXT | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Created timestamp |

---

### 3.9 purchases

**Purpose**: Records goods received from suppliers (Purchase Orders / GRN header).

| Column | Type | Constraints | Purpose |
|---|---|---|---|
| `purchase_id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique purchase identifier |
| `purchase_number` | TEXT | NOT NULL, UNIQUE | PO reference number |
| `supplier_id` | INTEGER | NOT NULL, FK → suppliers | Supplier identifier |
| `purchase_date` | TEXT | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Date goods were received |
| `received_by` | INTEGER | NOT NULL, FK → app_users | Staff user who accepted the delivery |
| `total_amount` | NUMERIC | NOT NULL, DEFAULT 0, CHECK ≥ 0 | Total purchase cost |
| `tax_amount` | NUMERIC | NOT NULL, DEFAULT 0, CHECK ≥ 0 | Input GST |
| `net_amount` | NUMERIC | NOT NULL, DEFAULT 0, CHECK ≥ 0 | Final purchase invoice total |
| `payment_status` | TEXT | NOT NULL, DEFAULT 'unpaid' | `paid`, `unpaid`, `partial` |
| `status` | TEXT | NOT NULL, DEFAULT 'received' | `received`, `pending`, `cancelled` |
| `notes` | TEXT | | Shipment notes |
| `created_at` | TEXT | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Created timestamp |
| `updated_at` | TEXT | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Updated timestamp |

---

### 3.10 purchase_items

**Purpose**: Records each product batch received in a purchase order.

| Column | Type | Constraints | Purpose |
|---|---|---|---|
| `purchase_item_id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique purchase line item ID |
| `purchase_id` | INTEGER | NOT NULL, FK → purchases (CASCADE) | Parent purchase order ID |
| `product_id` | INTEGER | NOT NULL, FK → products (RESTRICT) | Product received |
| `quantity` | NUMERIC | NOT NULL, CHECK > 0 | Quantity delivered |
| `unit_cost` | NUMERIC | NOT NULL, CHECK ≥ 0 | Cost price per unit in this batch |
| `line_total` | NUMERIC | NOT NULL, CHECK ≥ 0 | `= quantity * unit_cost` |
| `expiry_date` | TEXT | | Expiry date of this specific batch |
| `created_at` | TEXT | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Created timestamp |

---

### 3.11 inventory_movements

**Purpose**: Immutable audit log of every stock increase, decrease, adjustment, or write-off.

| Column | Type | Constraints | Purpose |
|---|---|---|---|
| `movement_id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique movement identifier |
| `product_id` | INTEGER | NOT NULL, FK → products | Product whose stock changed |
| `movement_type` | TEXT | NOT NULL | `sale`, `purchase`, `adjustment`, `return`, `damage`, `expired`, `opening_stock` |
| `quantity_change` | NUMERIC | NOT NULL | Positive = stock in (+), Negative = stock out (−) |
| `stock_after` | NUMERIC | NOT NULL | Stock quantity immediately following movement |
| `reference_type` | TEXT | NOT NULL, DEFAULT 'manual' | `sale`, `purchase`, `manual`, `system` |
| `reference_id` | INTEGER | | Links to `sale_id` or `purchase_id` |
| `performed_by` | INTEGER | FK → app_users (SET NULL) | User who executed the action |
| `remarks` | TEXT | | Reason for adjustment |
| `created_at` | TEXT | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Movement timestamp |

---

### 3.12 ai_insights

**Purpose**: Stores AI/ML model predictions, statistical moving-average demand forecasts, and restocking suggestions.

| Column | Type | Constraints | Purpose |
|---|---|---|---|
| `insight_id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique insight identifier |
| `product_id` | INTEGER | NOT NULL, FK → products (CASCADE) | Product analyzed |
| `insight_type` | TEXT | NOT NULL | `demand_forecast`, `restock_suggestion`, `expiry_alert`, `trend_analysis`, `sql_moving_avg_forecast` |
| `forecast_date` | TEXT | | Forecast target date |
| `predicted_demand` | NUMERIC | | Projected units demanded |
| `suggested_restock_qty` | NUMERIC | | Recommended order quantity |
| `confidence_score` | NUMERIC | CHECK 0.0 to 1.0 | Statistical confidence rating |
| `model_version` | TEXT | | Algorithm tag (e.g. `sql_moving_avg_v1`, `xgboost_v2`) |
| `parameters_used` | TEXT | JSON string check | Parameters (window size, safety factor) |
| `explanation` | TEXT | | Human-readable explanation in English/Hindi |
| `data_period_start` | TEXT | | Beginning of training data window |
| `data_period_end` | TEXT | | End of training data window |
| `is_active` | INTEGER | NOT NULL, DEFAULT 1 | `1` (Current) or `0` (Superseded) |
| `generated_by` | TEXT | NOT NULL, DEFAULT 'sql_procedure' | `sql_procedure`, `ml_model`, `manual` |
| `created_at` | TEXT | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Forecast generation timestamp |

---

## 4. Views & Reporting Layer

The database defines **7 pre-built views** for real-time dashboards and analytics:

1. **`vw_low_stock_products`**: Lists all products currently below `min_stock_level` with supplier lead times and shortage quantities.
2. **`vw_expiring_soon`**: Lists products nearing expiration within the next 30 days using SQLite `julianday()` calculations.
3. **`vw_daily_sales_summary`**: Aggregates daily transaction volume, gross revenue, discounts, net sales, and estimated gross profit.
4. **`vw_product_daily_sales`**: Product-by-product daily sales matrix used directly by AI forecasting pipelines.
5. **`vw_inventory_valuation`**: Current stock valued at cost price vs selling price MRP with potential retail margins.
6. **`vw_daily_payment_breakdown`** *(NEW)*: Daily breakdown of total bills, cash collected, online payments received, change returned, and digital payment adoption percentage.
7. **`vw_cashier_cash_register`** *(NEW)*: Cash drawer shift balancing tally per cashier, tracking total cash tendered, cash retained, and change returned.

---

## 5. Setup & Usage Instructions

SQLite is embedded and serverless. No server daemon, port, or user authentication configuration is required.

### Quick Start via Python
A zero-dependency initialization script is provided in `database/init_db.py`:

```bash
# 1. Initialize SQLite database with schema and sample data
python database/init_db.py

# 2. Run the automated test suite
python database/init_db.py --test

# 3. View table statistics and summary
python database/init_db.py --stats
```

### Quick Start via SQLite CLI
If you have `sqlite3` installed:

```bash
# Create database and apply schema
sqlite3 database/kirana_store.db < database/schema.sql

# Load sample data (12 tables)
sqlite3 database/kirana_store.db < database/sample_data.sql

# Run test suite
sqlite3 database/kirana_store.db < database/database_testing.sql
```

---

## 6. SQL-Based Demand Forecasting Module

The database includes statistical demand forecasting using SQLite recursive CTEs and window functions:

- **7-day & 30-day Simple Moving Averages (SMA)**: Computes rolling window sales to smooth day-to-day volatility.
- **Calendar Expansion**: Generates continuous date series so days with zero sales are properly averaged rather than omitted.
- **Safety Factor & Lead Time Coverage**:
  $$\text{Suggested Order} = \max\left(0, (\text{Avg Daily Demand} \times 7 \times 1.25) + (\text{Avg Daily Demand} \times \text{Lead Time}) - \text{Current Stock}\right)$$

---

## 7. Glossary

| Term | Meaning in SQLite Architecture |
|---|---|
| **AUTOINCREMENT** | Automatically assigns 1, 2, 3... to integer primary keys via `sqlite_sequence` |
| **PRAGMA foreign_keys = ON** | Mandatory SQLite command to enforce foreign key referential integrity |
| **NUMERIC Affinity** | SQLite data type affinity that preserves decimal precision without floating point errors |
| **CHECK Constraint** | Enforces business rules (e.g., non-negative prices, valid payment platforms) |
| **JSON_VALID()** | SQLite built-in function to validate JSON payload integrity for payment breakdowns |
| **TRIGGER** | Automated SQLite procedure (used to maintain `updated_at` timestamps on row updates) |
| **UTR / RRN** | Unique Transaction Reference / Retrieval Reference Number for UPI and card payments |
