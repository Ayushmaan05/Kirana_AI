# AI Kirana Store — Database Documentation

> **Module**: Database Design & SQL  
> **Database**: MySQL 8.0+ / InnoDB  
> **Project**: AI Kirana Store — Smart Grocery Management System

---

## 1. Project Overview

### What is AI Kirana Store?
AI Kirana Store is a smart grocery store management system designed for small Indian kirana (grocery) shops. It manages:
- **Products & Inventory** — Track stock levels, prices, expiry dates
- **Sales & Billing** — Record customer bills and payments
- **Purchases** — Track goods received from suppliers
- **AI Forecasting** — Predict demand and suggest restocking quantities

### What This Database Module Covers
This module provides the **complete database layer** for the application:
- 10 normalized tables with proper relationships
- Sample data with realistic Indian grocery products
- Analytical queries for reports and dashboards
- SQL-based demand forecasting using moving averages
- Transaction patterns for data integrity
- Views for common reports

### Technology Stack
| Component | Technology |
|---|---|
| RDBMS | MySQL 8.0+ |
| Storage Engine | InnoDB (supports transactions and FK) |
| Character Set | utf8mb4 (supports Hindi and emoji) |
| Collation | utf8mb4_unicode_ci |

---

## 2. Database Architecture

The database has **10 tables** organized into 4 logical groups:

### Master Data (reference tables)
1. **app_users** — Store staff and administrators
2. **categories** — Product categories
3. **suppliers** — Vendor information

### Transactional Data
4. **products** — Product catalog with stock levels
5. **sales** — Customer invoices/bills
6. **sale_items** — Products sold in each bill
7. **purchases** — Supplier purchase orders
8. **purchase_items** — Products received from suppliers

### Audit & Tracking
9. **inventory_movements** — Complete history of every stock change

### AI Integration
10. **ai_insights** — Demand forecasts and restocking suggestions

---

## 3. Detailed Table Documentation

### 3.1 app_users

**Purpose**: Stores information about store staff — admins, managers, cashiers, and inventory clerks.

| Column | Type | Constraints | Purpose |
|---|---|---|---|
| `user_id` | INT AUTO_INCREMENT | PRIMARY KEY | Unique identifier |
| `username` | VARCHAR(50) | NOT NULL, UNIQUE | Login username |
| `password_hash` | VARCHAR(255) | NOT NULL | Encrypted password (never plaintext) |
| `full_name` | VARCHAR(100) | NOT NULL | Employee's full name |
| `email` | VARCHAR(100) | UNIQUE | Email address |
| `phone` | VARCHAR(15) | | Phone number |
| `role` | ENUM | NOT NULL, DEFAULT 'cashier' | admin / manager / cashier / inventory_clerk |
| `is_active` | BOOLEAN | NOT NULL, DEFAULT TRUE | Whether the account is active |
| `created_at` | TIMESTAMP | NOT NULL, DEFAULT NOW | Account creation time |
| `updated_at` | TIMESTAMP | NOT NULL, AUTO-UPDATE | Last modification time |

**Indexes**: `idx_users_role` (role), `idx_users_active` (is_active)  
**Example**: Raj Sharma, admin, username: admin_raj

---

### 3.2 categories

**Purpose**: Organizes products into grocery categories like Dairy, Grains, Spices, etc.

| Column | Type | Constraints | Purpose |
|---|---|---|---|
| `category_id` | INT AUTO_INCREMENT | PRIMARY KEY | Unique identifier |
| `category_name` | VARCHAR(100) | NOT NULL, UNIQUE | Category name |
| `description` | VARCHAR(255) | | Brief description |
| `is_active` | BOOLEAN | NOT NULL, DEFAULT TRUE | Whether category is active |

**Example**: Dairy — "Milk, curd, butter, paneer, ghee"

---

### 3.3 suppliers

**Purpose**: Stores vendor/supplier information for procurement.

| Column | Type | Constraints | Purpose |
|---|---|---|---|
| `supplier_id` | INT AUTO_INCREMENT | PRIMARY KEY | Unique identifier |
| `supplier_name` | VARCHAR(150) | NOT NULL | Company/vendor name |
| `contact_person` | VARCHAR(100) | | Point of contact |
| `phone` | VARCHAR(15) | | Contact phone |
| `email` | VARCHAR(100) | | Contact email |
| `address` | TEXT | | Full address |
| `city` | VARCHAR(80) | | City |
| `state` | VARCHAR(80) | | State |
| `gstin` | VARCHAR(15) | | GST Identification Number |
| `lead_time_days` | INT | NOT NULL, DEFAULT 3 | Average delivery time in days |
| `is_active` | BOOLEAN | NOT NULL, DEFAULT TRUE | Whether supplier is active |

**Why `lead_time_days` matters**: Used in restock calculations. If a supplier takes 3 days to deliver, we need to order 3 days before stock runs out.

**Example**: Mother Dairy Distributors, Delhi, lead_time = 1 day

---

### 3.4 products

**Purpose**: The central product catalog — stores prices, current stock levels, and expiry information. This is the most important table.

| Column | Type | Constraints | Purpose |
|---|---|---|---|
| `product_id` | INT AUTO_INCREMENT | PRIMARY KEY | Unique identifier |
| `sku` | VARCHAR(30) | NOT NULL, **UNIQUE** | Stock Keeping Unit — unique product code |
| `product_name` | VARCHAR(200) | NOT NULL | Product display name |
| `category_id` | INT | NOT NULL, FK → categories | Which category this product belongs to |
| `supplier_id` | INT | FK → suppliers | Primary supplier (NULL if unassigned) |
| `brand` | VARCHAR(100) | | Brand name |
| `unit` | VARCHAR(30) | NOT NULL, DEFAULT 'piece' | Unit of measurement (kg, litre, pack, etc.) |
| `cost_price` | DECIMAL(10,2) | NOT NULL, DEFAULT 0, CHECK ≥ 0 | How much we pay the supplier |
| `selling_price` | DECIMAL(10,2) | NOT NULL, DEFAULT 0, CHECK ≥ 0 | How much we charge the customer |
| `current_stock` | DECIMAL(12,3) | NOT NULL, DEFAULT 0, CHECK ≥ 0 | Current quantity available |
| `min_stock_level` | DECIMAL(12,3) | NOT NULL, DEFAULT 10 | Reorder point — alert when stock falls below this |
| `max_stock_level` | DECIMAL(12,3) | NOT NULL, DEFAULT 500 | Maximum storage capacity |
| `expiry_date` | DATE | NULL allowed | Expiry date (NULL for non-perishable like rice, sugar) |
| `is_active` | BOOLEAN | NOT NULL, DEFAULT TRUE | Soft delete flag |

**Foreign Keys**:
- `category_id` → `categories.category_id` (ON DELETE RESTRICT)
- `supplier_id` → `suppliers.supplier_id` (ON DELETE SET NULL)

**CHECK Constraints**: cost_price ≥ 0, selling_price ≥ 0, current_stock ≥ 0, min_stock_level ≥ 0

**Why DECIMAL(12,3) for stock?** Because some products are sold by weight (2.500 kg of rice) not just whole numbers.

**Example**: Full Cream Milk 1L Pouch, SKU: DAI-MLK-001, ₹52 cost / ₹60 selling, 120 units in stock

---

### 3.5 sales

**Purpose**: Records each customer bill/invoice. This is the header table — the actual products sold are in `sale_items`.

| Column | Type | Constraints | Purpose |
|---|---|---|---|
| `sale_id` | INT AUTO_INCREMENT | PRIMARY KEY | Unique identifier |
| `invoice_number` | VARCHAR(30) | NOT NULL, **UNIQUE** | Bill number (format: INV-YYYYMMDD-NNN) |
| `sale_date` | DATETIME | NOT NULL, DEFAULT NOW | When the sale happened |
| `customer_name` | VARCHAR(100) | DEFAULT 'Walk-in Customer' | Customer name (optional) |
| `customer_phone` | VARCHAR(15) | | Customer phone (optional) |
| `cashier_id` | INT | NOT NULL, FK → app_users | Which cashier processed this bill |
| `total_amount` | DECIMAL(12,2) | NOT NULL, CHECK ≥ 0 | Gross total before discount |
| `discount_amount` | DECIMAL(10,2) | NOT NULL, DEFAULT 0 | Total discount given |
| `tax_amount` | DECIMAL(10,2) | NOT NULL, DEFAULT 0 | Tax charged |
| `net_amount` | DECIMAL(12,2) | NOT NULL, CHECK ≥ 0 | Final amount = total - discount + tax |
| `payment_method` | ENUM | NOT NULL, DEFAULT 'cash' | cash / upi / card / credit |
| `status` | ENUM | NOT NULL, DEFAULT 'completed' | completed / cancelled / refunded |

**Why `status` matters**: Cancelled sales are NOT deleted — they are marked as 'cancelled'. This preserves the audit trail and allows the inventory reversal to be tracked.

---

### 3.6 sale_items

**Purpose**: Records each product line in a bill. One sale has many sale_items.

| Column | Type | Constraints | Purpose |
|---|---|---|---|
| `sale_item_id` | INT AUTO_INCREMENT | PRIMARY KEY | Unique identifier |
| `sale_id` | INT | NOT NULL, FK → sales | Which sale this belongs to |
| `product_id` | INT | NOT NULL, FK → products | Which product was sold |
| `quantity` | DECIMAL(10,3) | NOT NULL, CHECK > 0 | How many units sold |
| `unit_price` | DECIMAL(10,2) | NOT NULL, CHECK ≥ 0 | Selling price **at time of sale** |
| `cost_price` | DECIMAL(10,2) | NOT NULL, DEFAULT 0 | Cost price **at time of sale** |
| `discount` | DECIMAL(10,2) | NOT NULL, DEFAULT 0 | Discount on this line item |
| `line_total` | DECIMAL(12,2) | NOT NULL, CHECK ≥ 0 | = quantity × unit_price − discount |

**Why snapshot pricing?** We store `unit_price` and `cost_price` at the time of sale because product prices change over time. If milk costs ₹60 today and ₹65 next month, old sales should still show ₹60. This is called **price snapshotting**.

---

### 3.7 purchases

**Purpose**: Records goods received from suppliers. Like `sales`, this is a header table.

| Column | Type | Constraints | Purpose |
|---|---|---|---|
| `purchase_id` | INT AUTO_INCREMENT | PRIMARY KEY | Unique identifier |
| `purchase_number` | VARCHAR(30) | NOT NULL, **UNIQUE** | PO number (format: PO-YYYYMMDD-NNN) |
| `supplier_id` | INT | NOT NULL, FK → suppliers | Which supplier shipped the goods |
| `purchase_date` | DATETIME | NOT NULL | When goods were received |
| `received_by` | INT | NOT NULL, FK → app_users | Who accepted the delivery |
| `total_amount` | DECIMAL(12,2) | CHECK ≥ 0 | Total purchase cost |
| `payment_status` | ENUM | DEFAULT 'unpaid' | paid / unpaid / partial |
| `status` | ENUM | DEFAULT 'received' | received / pending / cancelled |

---

### 3.8 purchase_items

**Purpose**: Records each product received in a purchase order.

| Column | Type | Constraints | Purpose |
|---|---|---|---|
| `purchase_item_id` | INT AUTO_INCREMENT | PRIMARY KEY | Unique identifier |
| `purchase_id` | INT | NOT NULL, FK → purchases | Which purchase order |
| `product_id` | INT | NOT NULL, FK → products | Which product received |
| `quantity` | DECIMAL(10,3) | NOT NULL, CHECK > 0 | Quantity received |
| `unit_cost` | DECIMAL(10,2) | NOT NULL, CHECK ≥ 0 | Cost per unit in this order |
| `line_total` | DECIMAL(12,2) | CHECK ≥ 0 | = quantity × unit_cost |
| `expiry_date` | DATE | | Batch expiry date |

---

### 3.9 inventory_movements

**Purpose**: The **audit trail** — records every single stock change (increase or decrease) with who did it, when, and why.

| Column | Type | Constraints | Purpose |
|---|---|---|---|
| `movement_id` | INT AUTO_INCREMENT | PRIMARY KEY | Unique identifier |
| `product_id` | INT | NOT NULL, FK → products | Which product's stock changed |
| `movement_type` | ENUM | NOT NULL | sale / purchase / adjustment / return / damage / expired / opening_stock |
| `quantity_change` | DECIMAL(12,3) | NOT NULL | Positive = stock in, **Negative = stock out** |
| `stock_after` | DECIMAL(12,3) | NOT NULL | Stock level after this movement |
| `reference_type` | ENUM | DEFAULT 'manual' | sale / purchase / manual / system |
| `reference_id` | INT | | Links to sale_id or purchase_id |
| `performed_by` | INT | FK → app_users | Who did it |
| `remarks` | VARCHAR(255) | | Notes about the movement |

**Why this table is critical**: It creates a complete audit trail. If current_stock shows 50 units, you can trace exactly how it got to 50 by looking at all movements. This is essential for accounting and dispute resolution.

---

### 3.10 ai_insights

**Purpose**: Stores demand forecasts, trend analyses, and restocking suggestions — generated either by SQL queries or by an ML model.

| Column | Type | Constraints | Purpose |
|---|---|---|---|
| `insight_id` | INT AUTO_INCREMENT | PRIMARY KEY | Unique identifier |
| `product_id` | INT | NOT NULL, FK → products | Which product this insight is about |
| `insight_type` | ENUM | NOT NULL | demand_forecast / restock_suggestion / expiry_alert / trend_analysis / sql_moving_avg_forecast |
| `forecast_date` | DATE | | Target date the forecast applies to |
| `predicted_demand` | DECIMAL(12,3) | | Predicted quantity to be sold |
| `suggested_restock_qty` | DECIMAL(12,3) | | Recommended order quantity |
| `confidence_score` | DECIMAL(5,4) | CHECK 0 to 1 | How confident the prediction is (0 to 1) |
| `model_version` | VARCHAR(50) | | e.g. "sql_moving_avg_v1" or "ml_xgboost_v2" |
| `parameters_used` | JSON | | Configuration used (window sizes, weights) |
| `explanation` | TEXT | | Human-readable explanation |
| `data_period_start` | DATE | | Start of data window used |
| `data_period_end` | DATE | | End of data window used |
| `is_active` | BOOLEAN | DEFAULT TRUE | FALSE for superseded forecasts |
| `generated_by` | ENUM | DEFAULT 'sql_procedure' | sql_procedure / ml_model / manual |

**`generated_by` is crucial**: It distinguishes SQL-based statistical estimates from actual ML model predictions. The AI team uses 'ml_model', and SQL forecasting uses 'sql_procedure'.

---

## 4. Database Relationships & Normalization

### What is Normalization?

Normalization is the process of organizing a database to reduce data redundancy (duplicate data) and improve data integrity.

### First Normal Form (1NF)
**Rule**: Every column must hold a single value (no lists or arrays).

✅ **Applied**: We do NOT store "Dairy, Grains" in a single column. Each product has exactly one `category_id`. If a product needs multiple categories, a separate junction table would be used (not needed here).

### Second Normal Form (2NF)
**Rule**: Every non-key column must depend on the entire primary key.

✅ **Applied**: In `sale_items`, the `unit_price` depends on the combination of which sale and which product — not just one of them. The price could vary by sale (discounts, promotions).

### Third Normal Form (3NF)
**Rule**: No column should depend on another non-key column.

✅ **Applied**: We don't store `category_name` in the `products` table. Instead, we store `category_id` and look up the name via a JOIN. This way, if a category is renamed, we only change it in one place.

### Benefits of Normalization
- **No duplicate data** — Supplier name stored once, referenced by ID everywhere
- **Easy updates** — Change a supplier's phone number in one row
- **Data consistency** — Impossible to have conflicting data
- **Smaller database** — Less storage used

---

## 5. Primary Keys & Foreign Keys Explained

### Primary Key (PK)
A primary key is a column (or set of columns) that **uniquely identifies** every row in a table.

**In this database**: Every table uses `INT AUTO_INCREMENT` as its PK. MySQL automatically assigns 1, 2, 3, ... to each new row.

**Example**: `products.product_id = 1` always refers to "Full Cream Milk 1L Pouch" and no other product.

### Foreign Key (FK)
A foreign key is a column that **references** the primary key of another table, creating a link between them.

**Example**: `products.category_id = 1` references `categories.category_id = 1` (Dairy). This means "this product belongs to the Dairy category."

### ON UPDATE CASCADE / ON DELETE behavior

| Behavior | Meaning | Example |
|---|---|---|
| ON UPDATE CASCADE | If parent PK changes, child FK updates automatically | If category_id 1→100, all products with category_id=1 update to 100 |
| ON DELETE RESTRICT | Cannot delete parent if children exist | Cannot delete "Dairy" category if dairy products exist |
| ON DELETE CASCADE | Deleting parent deletes children | Deleting a sale also deletes its sale_items |
| ON DELETE SET NULL | Deleting parent sets child FK to NULL | Deleting a supplier sets product's supplier_id to NULL |

### Complete FK Reference Map

```
categories.category_id  ←── products.category_id       (RESTRICT)
suppliers.supplier_id   ←── products.supplier_id        (SET NULL)
app_users.user_id       ←── sales.cashier_id            (RESTRICT)
sales.sale_id           ←── sale_items.sale_id           (CASCADE)
products.product_id     ←── sale_items.product_id        (RESTRICT)
suppliers.supplier_id   ←── purchases.supplier_id        (RESTRICT)
app_users.user_id       ←── purchases.received_by        (RESTRICT)
purchases.purchase_id   ←── purchase_items.purchase_id    (CASCADE)
products.product_id     ←── purchase_items.product_id     (RESTRICT)
products.product_id     ←── inventory_movements.product_id(RESTRICT)
app_users.user_id       ←── inventory_movements.performed_by (SET NULL)
products.product_id     ←── ai_insights.product_id        (CASCADE)
```

---

## 6. Joins Explained

### What is a JOIN?
A JOIN combines rows from two or more tables based on a related column (usually FK → PK).

### INNER JOIN
Returns only rows that have matching values in **both** tables.

```sql
-- Get products with their category names
SELECT p.product_name, c.category_name
FROM products p
INNER JOIN categories c ON c.category_id = p.category_id;
```
This returns only products that have a valid category. If a product somehow had category_id=999 (non-existent), it would be excluded.

### LEFT JOIN
Returns **all** rows from the left table, even if there's no match in the right table.

```sql
-- Get products with supplier names (some products might not have a supplier)
SELECT p.product_name, COALESCE(s.supplier_name, 'No Supplier') AS supplier
FROM products p
LEFT JOIN suppliers s ON s.supplier_id = p.supplier_id;
```
Products without a supplier will show "No Supplier" instead of being excluded.

### Multi-Table JOIN Example: Sales Report
```sql
-- Full sales report: bill → items → product → category
SELECT
    s.invoice_number,
    s.sale_date,
    p.product_name,
    c.category_name,
    si.quantity,
    si.unit_price,
    si.line_total
FROM sales s
JOIN sale_items si ON si.sale_id = s.sale_id
JOIN products p ON p.product_id = si.product_id
JOIN categories c ON c.category_id = p.category_id
WHERE s.status = 'completed'
ORDER BY s.sale_date DESC;
```

---

## 7. Indexes Explained

### What is an Index?
An index is like the **index at the back of a textbook** — instead of reading every page to find "Normalization," you look it up in the index and go directly to page 47. Similarly, a database index helps MySQL find rows quickly without scanning the entire table.

### Indexes in This Database

| Table | Index | Column(s) | Why It Exists |
|---|---|---|---|
| products | idx_products_name | product_name | Fast product name search |
| products | idx_products_category | category_id | Fast category filtering |
| products | idx_products_expiry | expiry_date | Fast expiry alerts |
| products | idx_products_stock | current_stock | Fast low-stock queries |
| sales | idx_sales_date | sale_date | Fast date-range reports |
| sales | idx_sales_status | status | Fast completed/cancelled filtering |
| inventory_movements | idx_invmov_product | product_id | Fast movement history lookup |
| inventory_movements | idx_invmov_date | created_at | Fast date-range queries |
| ai_insights | idx_ai_product | product_id | Fast per-product forecast lookup |
| ai_insights | idx_ai_active | is_active | Fast active forecast filtering |

### When to Add More Indexes
- Add indexes on columns you frequently use in WHERE, JOIN, or ORDER BY clauses
- Don't add too many indexes — they slow down INSERT/UPDATE operations
- MySQL automatically creates indexes for PRIMARY KEY and UNIQUE columns

---

## 8. Constraints & Data Integrity

### UNIQUE Constraints
Prevent duplicate values in a column.

| Table | Column | Purpose |
|---|---|---|
| products | sku | No two products can have the same SKU code |
| sales | invoice_number | No two bills can have the same invoice number |
| purchases | purchase_number | No duplicate purchase order numbers |
| app_users | username | No duplicate usernames |
| categories | category_name | No duplicate category names |

### CHECK Constraints (MySQL 8.0.16+)
Enforce value rules on columns.

```sql
CONSTRAINT chk_cost_price    CHECK (cost_price >= 0)     -- No negative prices
CONSTRAINT chk_selling_price CHECK (selling_price >= 0)   -- No negative prices
CONSTRAINT chk_current_stock CHECK (current_stock >= 0)   -- No negative stock
CONSTRAINT chk_si_quantity   CHECK (quantity > 0)          -- Must sell at least something
CONSTRAINT chk_confidence    CHECK (confidence_score BETWEEN 0 AND 1)
```

### NOT NULL Constraints
Columns that must always have a value:
- `product_name` — every product needs a name
- `category_id` — every product must belong to a category
- `invoice_number` — every sale must have a bill number
- `cashier_id` — every sale must be processed by a cashier

### ENUM Constraints
Limit a column to specific allowed values:
- `role`: admin, manager, cashier, inventory_clerk
- `payment_method`: cash, upi, card, credit
- `movement_type`: sale, purchase, adjustment, return, damage, expired, opening_stock
- `generated_by`: sql_procedure, ml_model, manual

---

## 9. Transactions & ACID Properties

### What is a Transaction?
A transaction is a group of SQL operations that must **all succeed or all fail** together. Think of it like transferring money between bank accounts — you can't debit one account without crediting the other.

### ACID Properties (Simple Explanation)

| Property | Meaning | Example |
|---|---|---|
| **A**tomicity | All or nothing | If the stock update fails, the sale record is also cancelled |
| **C**onsistency | Database stays valid | Stock cannot go negative; foreign keys always point to real records |
| **I**solation | Transactions don't interfere | Two cashiers can't sell the last 1 milk simultaneously |
| **D**urability | Committed = permanent | After COMMIT, data survives even a power failure |

### Transaction Syntax
```sql
START TRANSACTION;   -- Begin the group of operations

-- ... do your operations ...

COMMIT;              -- Make all changes permanent
-- OR
ROLLBACK;            -- Cancel all changes (as if nothing happened)
```

### Sale Transaction Pattern
```sql
START TRANSACTION;

-- 1. Lock the product row to prevent race conditions
SELECT current_stock INTO @available
FROM products WHERE product_id = 4 FOR UPDATE;

-- 2. Check if enough stock
IF @available < @required_qty THEN
    ROLLBACK;       -- Not enough stock — cancel everything
END IF;

-- 3. Create the sale
INSERT INTO sales (...) VALUES (...);
SET @sale_id = LAST_INSERT_ID();

-- 4. Add line items
INSERT INTO sale_items (...) VALUES (...);

-- 5. Reduce stock
UPDATE products SET current_stock = current_stock - @qty WHERE product_id = 4;

-- 6. Record movement
INSERT INTO inventory_movements (product_id, movement_type, quantity_change, ...)
VALUES (4, 'sale', -@qty, ...);

-- 7. Commit
COMMIT;
```

> **FOR UPDATE** is critical! It locks the row so another cashier can't read the same stock level simultaneously. Without it, two cashiers could both see "1 left" and both try to sell it.

---

## 10. Inventory Management Rules

### Rule 1: A completed sale reduces stock
When a sale is completed, `products.current_stock` decreases by the quantity sold.

### Rule 2: A received purchase increases stock
When goods arrive from a supplier, `products.current_stock` increases.

### Rule 3: Every stock change has a corresponding inventory_movement
The `inventory_movements` table is the audit trail. The application team must insert a movement record for every stock change.

### Rule 4: Insufficient stock must not allow a sale
Before selling, the application must check `current_stock >= required_quantity`. If not, the transaction must ROLLBACK.

### Rule 5: Failed transactions must roll back
If ANY step in a transaction fails (stock update, payment processing, etc.), ALL changes must be undone with ROLLBACK.

### Rule 6: Cancelled sales must reverse inventory effects
When a sale is cancelled:
1. Update `sales.status = 'cancelled'`
2. Increase `products.current_stock` by the quantity that was sold
3. Insert an inventory_movement with `movement_type = 'return'`

### Rule 7: AI forecasts are distinguishable from actual sales
The `ai_insights.generated_by` column distinguishes:
- `sql_procedure` — Generated by SQL moving average queries
- `ml_model` — Generated by the AI team's machine learning model
- `manual` — Manually entered by staff

### Rule 8: Historical sales data must remain available
Sales are NEVER deleted. Cancelled sales are marked with `status = 'cancelled'`. This preserves history for analysis and auditing.

---

## 11. AI Integration Support

### Purpose of the ai_insights Table
The `ai_insights` table serves as a **shared interface** between:
- The **Database module** (this project) — which writes SQL-based forecasts
- The **AI module** (your teammate's project) — which writes ML-based forecasts
- The **Backend/Frontend** — which reads forecasts and displays them

### What Data the AI Team Needs

The AI teammate should query these views/tables for training data:

| Data Needed | Query/View |
|---|---|
| Daily product sales | `vw_product_daily_sales` |
| Historical demand (30/60/90 days) | See queries.sql Section 9 |
| Current stock levels | `products` table |
| Low-stock products | `vw_low_stock_products` |
| Inventory movement history | `inventory_movements` table |
| Product catalog | `products` + `categories` |

### Expected Inputs/Outputs

**Input to AI Model** (from database):
```
product_id | sale_date | quantity_sold | current_stock | category | season
```

**Output from AI Model** (stored in database):
```
product_id | forecast_date | predicted_demand | confidence_score | model_version
```

### How to Store ML Predictions
```sql
INSERT INTO ai_insights (
    product_id, insight_type, forecast_date,
    predicted_demand, suggested_restock_qty, confidence_score,
    model_version, explanation,
    data_period_start, data_period_end,
    is_active, generated_by
) VALUES (
    1, 'demand_forecast', '2026-10-22',
    5.200, 35.000, 0.8500,
    'ml_xgboost_v2', 'XGBoost model predicts 5.2 units/day for next week',
    '2026-07-15', '2026-10-15',
    TRUE, 'ml_model'  -- <-- Important: 'ml_model' not 'sql_procedure'
);
```

---

## 12. Views Explained

### vw_low_stock_products
Products where `current_stock < min_stock_level`. Useful for a dashboard alert widget.

### vw_expiring_soon
Products expiring within 30 days that still have stock. Helps prevent selling expired goods.

### vw_daily_sales_summary
Aggregated daily totals — number of bills, gross sales, discounts, net revenue, items sold, estimated profit. Perfect for a daily sales chart.

### vw_product_daily_sales
Product-wise daily sales breakdown. This is the **primary view for AI demand forecasting** — it provides the time series data the model needs.

### vw_inventory_valuation
Current stock × cost_price and × selling_price for each product. Shows total inventory value.

---

## 13. Setup Instructions

### Install MySQL 8.0
1. Download from https://dev.mysql.com/downloads/mysql/
2. Run the installer, choose "Developer Default"
3. Set a root password during setup
4. Optionally install MySQL Workbench for a graphical interface

### Import Using Command Line
```bash
# Step 1: Create database and tables
mysql -u root -p < database/schema.sql

# Step 2: Load sample data
mysql -u root -p < database/sample_data.sql

# Step 3: Run test suite
mysql -u root -p < database/database_testing.sql

# Step 4: Explore queries
mysql -u root -p kirana_store < database/queries.sql
```

### Import Using MySQL Workbench
1. Open MySQL Workbench
2. Connect to your MySQL server
3. Go to **File → Open SQL Script**
4. Open `schema.sql` and click the ⚡ lightning bolt to execute
5. Open `sample_data.sql` and execute
6. Open `queries.sql` — run individual queries by selecting them and pressing Ctrl+Shift+Enter

### Verify Installation
```sql
USE kirana_store;
SHOW TABLES;
SELECT COUNT(*) FROM products;  -- Should return 25
SELECT COUNT(*) FROM sales;     -- Should return 39
```

### Troubleshooting Common Errors

| Error | Solution |
|---|---|
| `ERROR 1049: Unknown database` | Run `schema.sql` first to create the database |
| `ERROR 1062: Duplicate entry` | Data already loaded. Run `DROP DATABASE kirana_store;` first |
| `ERROR 1452: FK constraint fails` | Run `schema.sql` before `sample_data.sql` (tables must exist first) |
| `ERROR 3819: CHECK constraint violated` | You're trying to insert invalid data (negative price, etc.) |

---

## 14. SQL-Based Demand Forecasting

### What is a Moving Average?
A moving average smooths out daily fluctuations to reveal the underlying trend. Instead of looking at one day's sales (which might be unusually high or low), we look at the **average over the last N days**.

**7-day moving average**: Average of the last 7 days of sales  
**30-day moving average**: Average of the last 30 days of sales

### Example
If milk sales for the last 7 days were: 5, 3, 7, 4, 6, 2, 8

7-day SMA = (5 + 3 + 7 + 4 + 6 + 2 + 8) / 7 = **5.0 units/day**

### How Trend Detection Works
Compare recent demand vs earlier demand:
- **Recent 30 days average**: 4.5 units/day
- **Previous 30 days average**: 3.8 units/day
- **Change**: +18.4% → **INCREASING** trend

Thresholds:
- \> +15% → INCREASING
- \< −15% → DECREASING
- Between → STABLE

### Restock Suggestion Formula
```
suggested_order = MAX(0,
    (predicted_7day_demand × safety_factor)
  + (lead_time_days × avg_daily_demand)
  - current_stock
)
```

Where:
- `predicted_7day_demand` = avg_daily_7d × 7
- `safety_factor` = 1.25 (25% buffer for unexpected demand)
- `lead_time_days` = from `suppliers.lead_time_days`
- `current_stock` = from `products.current_stock`

### Limitations of Moving Averages vs ML

| Aspect | Moving Average (SQL) | Machine Learning |
|---|---|---|
| Seasonal patterns | ❌ Cannot detect | ✅ Can learn |
| External factors | ❌ Ignored | ✅ Can incorporate |
| Stockout periods | ❌ Biased (shows 0) | ✅ Can handle |
| Accuracy | Moderate | Higher |
| Simplicity | ✅ Very simple | ❌ Complex |
| Dependencies | ✅ Just SQL | ❌ Python, libraries |

### Edge Cases
1. **New products** (no sales history): Cannot forecast. The query excludes them and flags as "NO SALES DATA."
2. **Stockout periods**: If a product was out of stock for 5 days, those days show zero sales. The moving average underestimates true demand. The confidence_score is lower for such products.
3. **Missing dates**: The queries use a date series CTE to generate ALL dates, so days with zero sales are correctly counted as zero (not skipped).

---

## 15. Glossary

| Term | Meaning |
|---|---|
| **AUTO_INCREMENT** | MySQL automatically assigns increasing numbers (1, 2, 3...) |
| **CASCADE** | When parent is deleted/updated, automatically do the same to children |
| **CHECK constraint** | Rule that a column's value must satisfy (e.g., price ≥ 0) |
| **CTE** | Common Table Expression — a temporary named result set using WITH...AS |
| **DECIMAL** | Exact numeric type — never use FLOAT for money |
| **ENUM** | Column type that only allows predefined values |
| **Foreign Key (FK)** | Column that references another table's primary key |
| **FOR UPDATE** | Locks a row during a transaction to prevent concurrent modification |
| **GRN** | Goods Received Note — document when goods arrive from supplier |
| **GST/GSTIN** | Goods and Services Tax / GST Identification Number (India) |
| **InnoDB** | MySQL storage engine that supports transactions and foreign keys |
| **JOIN** | Combining rows from multiple tables based on related columns |
| **Kirana** | Hindi word for a small neighborhood grocery store |
| **MRP** | Maximum Retail Price |
| **Normalization** | Organizing tables to reduce redundancy |
| **Primary Key (PK)** | Column that uniquely identifies each row |
| **RESTRICT** | Prevents deleting a parent row if children exist |
| **ROLLBACK** | Undo all changes in the current transaction |
| **SKU** | Stock Keeping Unit — unique product code |
| **SMA** | Simple Moving Average |
| **Soft Delete** | Mark as inactive instead of actually deleting |
| **Transaction** | Group of operations that must all succeed or all fail |
| **UPI** | Unified Payments Interface (Indian digital payment system) |
| **View** | A saved query that acts like a virtual table |
| **Window Function** | SQL function that performs calculations across related rows |

---

*Last updated: October 2026*  
*Database module for AI Kirana Store college project*
