-- ============================================================================
-- AI KIRANA STORE — DATABASE SCHEMA
-- File       : schema.sql
-- Engine     : SQLite 3.35+
-- Author     : Database & SQL Module
-- Description: Creates the Kirana Store database schema with 12 tables,
--              triggers for updated_at timestamps, indexes, analytical views,
--              and full referential-integrity constraints.
--              Includes dedicated schemas for cash and online payments.
-- Usage      : sqlite3 kirana_store.db < schema.sql
--              OR python database/init_db.py
-- ============================================================================

-- Enable Foreign Key enforcement in SQLite
PRAGMA foreign_keys = ON;

-- ============================================================================
-- 1. app_users — staff and administrator records
-- ============================================================================
CREATE TABLE IF NOT EXISTS app_users (
    user_id         INTEGER PRIMARY KEY AUTOINCREMENT,
    username        TEXT NOT NULL UNIQUE,
    password_hash   TEXT NOT NULL,
    full_name       TEXT NOT NULL,
    email           TEXT UNIQUE,
    phone           TEXT,
    role            TEXT NOT NULL DEFAULT 'cashier'
                    CHECK (role IN ('admin', 'manager', 'cashier', 'inventory_clerk')),
    is_active       INTEGER NOT NULL DEFAULT 1
                    CHECK (is_active IN (0, 1)),
    created_at      TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_users_role ON app_users(role);
CREATE INDEX IF NOT EXISTS idx_users_active ON app_users(is_active);

-- ============================================================================
-- 2. categories — grocery categories
-- ============================================================================
CREATE TABLE IF NOT EXISTS categories (
    category_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    category_name   TEXT NOT NULL UNIQUE,
    description     TEXT,
    is_active       INTEGER NOT NULL DEFAULT 1
                    CHECK (is_active IN (0, 1)),
    created_at      TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 3. suppliers — supplier information
-- ============================================================================
CREATE TABLE IF NOT EXISTS suppliers (
    supplier_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    supplier_name   TEXT NOT NULL,
    contact_person  TEXT,
    phone           TEXT,
    email           TEXT,
    address         TEXT,
    city            TEXT,
    state           TEXT,
    gstin           TEXT,
    lead_time_days  INTEGER NOT NULL DEFAULT 3
                    CHECK (lead_time_days >= 0),
    is_active       INTEGER NOT NULL DEFAULT 1
                    CHECK (is_active IN (0, 1)),
    created_at      TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_suppliers_city ON suppliers(city);

-- ============================================================================
-- 4. products — product details, prices, stock, and expiry
-- ============================================================================
CREATE TABLE IF NOT EXISTS products (
    product_id        INTEGER PRIMARY KEY AUTOINCREMENT,
    sku               TEXT NOT NULL UNIQUE,
    product_name      TEXT NOT NULL,
    category_id       INTEGER NOT NULL,
    supplier_id       INTEGER,
    brand             TEXT,
    unit              TEXT NOT NULL DEFAULT 'piece',
    cost_price        NUMERIC NOT NULL DEFAULT 0.00 CHECK (cost_price >= 0),
    selling_price     NUMERIC NOT NULL DEFAULT 0.00 CHECK (selling_price >= 0),
    current_stock     NUMERIC NOT NULL DEFAULT 0.000 CHECK (current_stock >= 0),
    min_stock_level   NUMERIC NOT NULL DEFAULT 10.000 CHECK (min_stock_level >= 0),
    max_stock_level   NUMERIC NOT NULL DEFAULT 500.000 CHECK (max_stock_level >= 0),
    expiry_date       TEXT,
    is_active         INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
    created_at        TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Foreign keys
    FOREIGN KEY (category_id) REFERENCES categories (category_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (supplier_id) REFERENCES suppliers (supplier_id)
        ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_products_name ON products(product_name);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_supplier ON products(supplier_id);
CREATE INDEX IF NOT EXISTS idx_products_expiry ON products(expiry_date);
CREATE INDEX IF NOT EXISTS idx_products_stock ON products(current_stock);

-- ============================================================================
-- 5. sales — customer bills and header details
-- ============================================================================
CREATE TABLE IF NOT EXISTS sales (
    sale_id           INTEGER PRIMARY KEY AUTOINCREMENT,
    invoice_number    TEXT NOT NULL UNIQUE,
    sale_date         TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    customer_name     TEXT DEFAULT 'Walk-in Customer',
    customer_phone    TEXT,
    cashier_id        INTEGER NOT NULL,
    total_amount      NUMERIC NOT NULL DEFAULT 0.00 CHECK (total_amount >= 0),
    discount_amount   NUMERIC NOT NULL DEFAULT 0.00 CHECK (discount_amount >= 0),
    tax_amount        NUMERIC NOT NULL DEFAULT 0.00 CHECK (tax_amount >= 0),
    net_amount        NUMERIC NOT NULL DEFAULT 0.00 CHECK (net_amount >= 0),
    payment_method    TEXT NOT NULL DEFAULT 'cash'
                      CHECK (payment_method IN ('cash', 'upi', 'card', 'credit', 'mixed', 'online')),
    status            TEXT NOT NULL DEFAULT 'completed'
                      CHECK (status IN ('completed', 'cancelled', 'refunded')),
    notes             TEXT,
    created_at        TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Foreign keys
    FOREIGN KEY (cashier_id) REFERENCES app_users (user_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_sales_date ON sales(sale_date);
CREATE INDEX IF NOT EXISTS idx_sales_cashier ON sales(cashier_id);
CREATE INDEX IF NOT EXISTS idx_sales_status ON sales(status);
CREATE INDEX IF NOT EXISTS idx_sales_payment_method ON sales(payment_method);

-- ============================================================================
-- 6. cash_payments — physical cash payment transaction details
-- ============================================================================
CREATE TABLE IF NOT EXISTS cash_payments (
    cash_payment_id        INTEGER PRIMARY KEY AUTOINCREMENT,
    sale_id                INTEGER NOT NULL,
    cashier_id             INTEGER NOT NULL,
    amount_tendered        NUMERIC NOT NULL CHECK (amount_tendered >= 0),
    amount_received        NUMERIC NOT NULL CHECK (amount_received >= 0),
    change_returned        NUMERIC NOT NULL DEFAULT 0.00 CHECK (change_returned >= 0),
    denomination_breakdown TEXT CHECK (denomination_breakdown IS NULL OR json_valid(denomination_breakdown) = 1),
    payment_status         TEXT NOT NULL DEFAULT 'completed'
                           CHECK (payment_status IN ('completed', 'cancelled', 'refunded')),
    payment_time           TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes                  TEXT,
    created_at             TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at             TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Foreign keys
    FOREIGN KEY (sale_id) REFERENCES sales (sale_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (cashier_id) REFERENCES app_users (user_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_cash_payments_sale ON cash_payments(sale_id);
CREATE INDEX IF NOT EXISTS idx_cash_payments_cashier ON cash_payments(cashier_id);
CREATE INDEX IF NOT EXISTS idx_cash_payments_date ON cash_payments(payment_time);
CREATE INDEX IF NOT EXISTS idx_cash_payments_status ON cash_payments(payment_status);

-- ============================================================================
-- 7. online_payments — digital transactions (UPI, QR, Card POS, NetBanking)
-- ============================================================================
CREATE TABLE IF NOT EXISTS online_payments (
    online_payment_id        INTEGER PRIMARY KEY AUTOINCREMENT,
    sale_id                  INTEGER NOT NULL,
    payment_platform         TEXT NOT NULL
                             CHECK (payment_platform IN ('upi', 'card_pos', 'qr_code', 'net_banking', 'wallet', 'other')),
    provider                 TEXT NOT NULL
                             CHECK (provider IN ('PhonePe', 'Google Pay', 'Paytm', 'BHIM', 'Pine Labs', 'HDFC POS', 'Razorpay', 'SBI', 'Other')),
    transaction_reference_id TEXT NOT NULL UNIQUE,
    amount                   NUMERIC NOT NULL CHECK (amount > 0),
    payer_upi_id             TEXT,
    payer_phone              TEXT,
    payment_status           TEXT NOT NULL DEFAULT 'success'
                             CHECK (payment_status IN ('initiated', 'success', 'pending', 'failed', 'refunded')),
    gateway_fee              NUMERIC NOT NULL DEFAULT 0.00 CHECK (gateway_fee >= 0),
    settlement_status        TEXT NOT NULL DEFAULT 'settled'
                             CHECK (settlement_status IN ('pending', 'settled', 'failed')),
    terminal_device_id       TEXT,
    gateway_response         TEXT CHECK (gateway_response IS NULL OR json_valid(gateway_response) = 1),
    payment_time             TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes                    TEXT,
    created_at               TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at               TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Foreign keys
    FOREIGN KEY (sale_id) REFERENCES sales (sale_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_online_payments_sale ON online_payments(sale_id);
CREATE INDEX IF NOT EXISTS idx_online_payments_ref ON online_payments(transaction_reference_id);
CREATE INDEX IF NOT EXISTS idx_online_payments_status ON online_payments(payment_status);
CREATE INDEX IF NOT EXISTS idx_online_payments_date ON online_payments(payment_time);
CREATE INDEX IF NOT EXISTS idx_online_payments_provider ON online_payments(provider);

-- ============================================================================
-- 8. sale_items — individual products sold in each bill
-- ============================================================================
CREATE TABLE IF NOT EXISTS sale_items (
    sale_item_id    INTEGER PRIMARY KEY AUTOINCREMENT,
    sale_id         INTEGER NOT NULL,
    product_id      INTEGER NOT NULL,
    quantity        NUMERIC NOT NULL CHECK (quantity > 0),
    unit_price      NUMERIC NOT NULL CHECK (unit_price >= 0),
    cost_price      NUMERIC NOT NULL DEFAULT 0.00 CHECK (cost_price >= 0),
    discount        NUMERIC NOT NULL DEFAULT 0.00 CHECK (discount >= 0),
    line_total      NUMERIC NOT NULL CHECK (line_total >= 0),
    created_at      TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Foreign keys
    FOREIGN KEY (sale_id) REFERENCES sales (sale_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products (product_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_saleitems_sale ON sale_items(sale_id);
CREATE INDEX IF NOT EXISTS idx_saleitems_product ON sale_items(product_id);

-- ============================================================================
-- 9. purchases — supplier purchase records
-- ============================================================================
CREATE TABLE IF NOT EXISTS purchases (
    purchase_id       INTEGER PRIMARY KEY AUTOINCREMENT,
    purchase_number   TEXT NOT NULL UNIQUE,
    supplier_id       INTEGER NOT NULL,
    purchase_date     TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    received_by       INTEGER NOT NULL,
    total_amount      NUMERIC NOT NULL DEFAULT 0.00 CHECK (total_amount >= 0),
    tax_amount        NUMERIC NOT NULL DEFAULT 0.00 CHECK (tax_amount >= 0),
    net_amount        NUMERIC NOT NULL DEFAULT 0.00 CHECK (net_amount >= 0),
    payment_status    TEXT NOT NULL DEFAULT 'unpaid'
                      CHECK (payment_status IN ('paid', 'unpaid', 'partial')),
    status            TEXT NOT NULL DEFAULT 'received'
                      CHECK (status IN ('received', 'pending', 'cancelled')),
    notes             TEXT,
    created_at        TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Foreign keys
    FOREIGN KEY (supplier_id) REFERENCES suppliers (supplier_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (received_by) REFERENCES app_users (user_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_purchases_supplier ON purchases(supplier_id);
CREATE INDEX IF NOT EXISTS idx_purchases_date ON purchases(purchase_date);
CREATE INDEX IF NOT EXISTS idx_purchases_status ON purchases(status);

-- ============================================================================
-- 10. purchase_items — products received from suppliers
-- ============================================================================
CREATE TABLE IF NOT EXISTS purchase_items (
    purchase_item_id  INTEGER PRIMARY KEY AUTOINCREMENT,
    purchase_id       INTEGER NOT NULL,
    product_id        INTEGER NOT NULL,
    quantity          NUMERIC NOT NULL CHECK (quantity > 0),
    unit_cost         NUMERIC NOT NULL CHECK (unit_cost >= 0),
    line_total        NUMERIC NOT NULL CHECK (line_total >= 0),
    expiry_date       TEXT,
    created_at        TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Foreign keys
    FOREIGN KEY (purchase_id) REFERENCES purchases (purchase_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products (product_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_puritems_purchase ON purchase_items(purchase_id);
CREATE INDEX IF NOT EXISTS idx_puritems_product ON purchase_items(product_id);

-- ============================================================================
-- 11. inventory_movements — history of stock increases and decreases
-- ============================================================================
CREATE TABLE IF NOT EXISTS inventory_movements (
    movement_id       INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id        INTEGER NOT NULL,
    movement_type     TEXT NOT NULL
                      CHECK (movement_type IN ('sale', 'purchase', 'adjustment', 'return',
                                               'damage', 'expired', 'opening_stock')),
    quantity_change   NUMERIC NOT NULL,
    stock_after       NUMERIC NOT NULL,
    reference_type    TEXT NOT NULL DEFAULT 'manual'
                      CHECK (reference_type IN ('sale', 'purchase', 'manual', 'system')),
    reference_id      INTEGER,
    performed_by      INTEGER,
    remarks           TEXT,
    created_at        TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Foreign keys
    FOREIGN KEY (product_id) REFERENCES products (product_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (performed_by) REFERENCES app_users (user_id)
        ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_invmov_product ON inventory_movements(product_id);
CREATE INDEX IF NOT EXISTS idx_invmov_type ON inventory_movements(movement_type);
CREATE INDEX IF NOT EXISTS idx_invmov_date ON inventory_movements(created_at);
CREATE INDEX IF NOT EXISTS idx_invmov_reference ON inventory_movements(reference_type, reference_id);

-- ============================================================================
-- 12. ai_insights — AI-generated demand forecasts and recommendations
-- ============================================================================
CREATE TABLE IF NOT EXISTS ai_insights (
    insight_id            INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id            INTEGER NOT NULL,
    insight_type          TEXT NOT NULL
                          CHECK (insight_type IN ('demand_forecast', 'restock_suggestion',
                                                  'expiry_alert', 'trend_analysis',
                                                  'sql_moving_avg_forecast')),
    forecast_date         TEXT,
    predicted_demand      NUMERIC,
    suggested_restock_qty NUMERIC,
    confidence_score      NUMERIC
                          CHECK (confidence_score IS NULL
                                 OR (confidence_score >= 0.0 AND confidence_score <= 1.0)),
    model_version         TEXT,
    parameters_used       TEXT CHECK (parameters_used IS NULL OR json_valid(parameters_used) = 1),
    explanation           TEXT,
    data_period_start     TEXT,
    data_period_end       TEXT,
    is_active             INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
    generated_by          TEXT NOT NULL DEFAULT 'sql_procedure'
                          CHECK (generated_by IN ('sql_procedure', 'ml_model', 'manual')),
    created_at            TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Foreign keys
    FOREIGN KEY (product_id) REFERENCES products (product_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_ai_product ON ai_insights(product_id);
CREATE INDEX IF NOT EXISTS idx_ai_type ON ai_insights(insight_type);
CREATE INDEX IF NOT EXISTS idx_ai_date ON ai_insights(forecast_date);
CREATE INDEX IF NOT EXISTS idx_ai_active ON ai_insights(is_active);
CREATE INDEX IF NOT EXISTS idx_ai_generated ON ai_insights(generated_by);

-- ============================================================================
-- TRIGGERS — Automatic updated_at Timestamps
-- ============================================================================
CREATE TRIGGER IF NOT EXISTS trg_users_updated_at
AFTER UPDATE ON app_users FOR EACH ROW
BEGIN
    UPDATE app_users SET updated_at = CURRENT_TIMESTAMP WHERE user_id = OLD.user_id;
END;

CREATE TRIGGER IF NOT EXISTS trg_categories_updated_at
AFTER UPDATE ON categories FOR EACH ROW
BEGIN
    UPDATE categories SET updated_at = CURRENT_TIMESTAMP WHERE category_id = OLD.category_id;
END;

CREATE TRIGGER IF NOT EXISTS trg_suppliers_updated_at
AFTER UPDATE ON suppliers FOR EACH ROW
BEGIN
    UPDATE suppliers SET updated_at = CURRENT_TIMESTAMP WHERE supplier_id = OLD.supplier_id;
END;

CREATE TRIGGER IF NOT EXISTS trg_products_updated_at
AFTER UPDATE ON products FOR EACH ROW
BEGIN
    UPDATE products SET updated_at = CURRENT_TIMESTAMP WHERE product_id = OLD.product_id;
END;

CREATE TRIGGER IF NOT EXISTS trg_sales_updated_at
AFTER UPDATE ON sales FOR EACH ROW
BEGIN
    UPDATE sales SET updated_at = CURRENT_TIMESTAMP WHERE sale_id = OLD.sale_id;
END;

CREATE TRIGGER IF NOT EXISTS trg_cash_payments_updated_at
AFTER UPDATE ON cash_payments FOR EACH ROW
BEGIN
    UPDATE cash_payments SET updated_at = CURRENT_TIMESTAMP WHERE cash_payment_id = OLD.cash_payment_id;
END;

CREATE TRIGGER IF NOT EXISTS trg_online_payments_updated_at
AFTER UPDATE ON online_payments FOR EACH ROW
BEGIN
    UPDATE online_payments SET updated_at = CURRENT_TIMESTAMP WHERE online_payment_id = OLD.online_payment_id;
END;

CREATE TRIGGER IF NOT EXISTS trg_purchases_updated_at
AFTER UPDATE ON purchases FOR EACH ROW
BEGIN
    UPDATE purchases SET updated_at = CURRENT_TIMESTAMP WHERE purchase_id = OLD.purchase_id;
END;

-- ============================================================================
-- VIEWS
-- ============================================================================

-- ---------------------------------------------------------------------------
-- View 1: Low-stock products (stock below reorder point)
-- ---------------------------------------------------------------------------
DROP VIEW IF EXISTS vw_low_stock_products;
CREATE VIEW vw_low_stock_products AS
SELECT
    p.product_id,
    p.sku,
    p.product_name,
    c.category_name,
    p.current_stock,
    p.min_stock_level,
    p.unit,
    ROUND(p.min_stock_level - p.current_stock, 3) AS shortage_qty,
    s.supplier_name,
    s.lead_time_days,
    p.cost_price,
    p.selling_price
FROM products p
JOIN categories c ON c.category_id = p.category_id
LEFT JOIN suppliers s ON s.supplier_id = p.supplier_id
WHERE p.current_stock < p.min_stock_level
  AND p.is_active = 1
ORDER BY shortage_qty DESC;

-- ---------------------------------------------------------------------------
-- View 2: Products nearing expiry (within 30 days)
-- ---------------------------------------------------------------------------
DROP VIEW IF EXISTS vw_expiring_soon;
CREATE VIEW vw_expiring_soon AS
SELECT
    p.product_id,
    p.sku,
    p.product_name,
    c.category_name,
    p.expiry_date,
    CAST(ROUND(julianday(p.expiry_date) - julianday(DATE('now'))) AS INTEGER) AS days_until_expiry,
    p.current_stock,
    p.unit,
    p.selling_price
FROM products p
JOIN categories c ON c.category_id = p.category_id
WHERE p.expiry_date IS NOT NULL
  AND p.expiry_date <= DATE('now', '+30 days')
  AND p.current_stock > 0
  AND p.is_active = 1
ORDER BY p.expiry_date ASC;

-- ---------------------------------------------------------------------------
-- View 3: Daily sales summary
-- ---------------------------------------------------------------------------
DROP VIEW IF EXISTS vw_daily_sales_summary;
CREATE VIEW vw_daily_sales_summary AS
SELECT
    DATE(s.sale_date)                       AS sale_day,
    COUNT(DISTINCT s.sale_id)               AS total_bills,
    ROUND(SUM(s.total_amount), 2)           AS gross_sales,
    ROUND(SUM(s.discount_amount), 2)        AS total_discounts,
    ROUND(SUM(s.tax_amount), 2)             AS total_tax,
    ROUND(SUM(s.net_amount), 2)             AS net_revenue,
    SUM(si.quantity)                        AS total_items_sold,
    ROUND(SUM(si.line_total - (si.cost_price * si.quantity)), 2)
                                            AS estimated_gross_profit
FROM sales s
JOIN sale_items si ON si.sale_id = s.sale_id
WHERE s.status = 'completed'
GROUP BY DATE(s.sale_date)
ORDER BY sale_day DESC;

-- ---------------------------------------------------------------------------
-- View 4: Product-wise daily sales (for AI demand forecasting)
-- ---------------------------------------------------------------------------
DROP VIEW IF EXISTS vw_product_daily_sales;
CREATE VIEW vw_product_daily_sales AS
SELECT
    DATE(s.sale_date)       AS sale_day,
    si.product_id,
    p.product_name,
    p.sku,
    SUM(si.quantity)        AS total_qty_sold,
    ROUND(SUM(si.line_total), 2) AS total_revenue,
    COUNT(DISTINCT s.sale_id) AS num_transactions
FROM sales s
JOIN sale_items si ON si.sale_id = s.sale_id
JOIN products p    ON p.product_id = si.product_id
WHERE s.status = 'completed'
GROUP BY DATE(s.sale_date), si.product_id, p.product_name, p.sku
ORDER BY sale_day DESC, total_qty_sold DESC;

-- ---------------------------------------------------------------------------
-- View 5: Current inventory valuation
-- ---------------------------------------------------------------------------
DROP VIEW IF EXISTS vw_inventory_valuation;
CREATE VIEW vw_inventory_valuation AS
SELECT
    p.product_id,
    p.sku,
    p.product_name,
    c.category_name,
    p.current_stock,
    p.unit,
    p.cost_price,
    p.selling_price,
    ROUND(p.current_stock * p.cost_price, 2)     AS valuation_at_cost,
    ROUND(p.current_stock * p.selling_price, 2)  AS valuation_at_selling
FROM products p
JOIN categories c ON c.category_id = p.category_id
WHERE p.is_active = 1
  AND p.current_stock > 0
ORDER BY valuation_at_cost DESC;

-- ---------------------------------------------------------------------------
-- View 6: Daily Payment Breakdown (Cash vs Online Digital Split)
-- ---------------------------------------------------------------------------
DROP VIEW IF EXISTS vw_daily_payment_breakdown;
CREATE VIEW vw_daily_payment_breakdown AS
SELECT
    DATE(s.sale_date) AS payment_day,
    COUNT(DISTINCT s.sale_id) AS total_sales_count,
    ROUND(SUM(s.net_amount), 2) AS total_billed_amount,
    ROUND(COALESCE(SUM(cp.amount_received), 0), 2) AS total_cash_received,
    ROUND(COALESCE(SUM(op.amount), 0), 2) AS total_online_received,
    ROUND(COALESCE(SUM(cp.change_returned), 0), 2) AS total_cash_change_returned,
    ROUND(
        CASE
            WHEN SUM(s.net_amount) > 0
            THEN (COALESCE(SUM(op.amount), 0) * 100.0) / SUM(s.net_amount)
            ELSE 0.0
        END, 2
    ) AS digital_collection_pct
FROM sales s
LEFT JOIN cash_payments cp ON cp.sale_id = s.sale_id AND cp.payment_status = 'completed'
LEFT JOIN online_payments op ON op.sale_id = s.sale_id AND op.payment_status = 'success'
WHERE s.status = 'completed'
GROUP BY DATE(s.sale_date)
ORDER BY payment_day DESC;

-- ---------------------------------------------------------------------------
-- View 7: Cashier Cash Register (Shift Balancing & Cash drawer tally)
-- ---------------------------------------------------------------------------
DROP VIEW IF EXISTS vw_cashier_cash_register;
CREATE VIEW vw_cashier_cash_register AS
SELECT
    DATE(cp.payment_time) AS shift_date,
    u.user_id AS cashier_id,
    u.full_name AS cashier_name,
    COUNT(cp.cash_payment_id) AS cash_bills_count,
    ROUND(SUM(cp.amount_tendered), 2) AS total_tendered,
    ROUND(SUM(cp.amount_received), 2) AS total_cash_retained,
    ROUND(SUM(cp.change_returned), 2) AS total_change_returned
FROM cash_payments cp
JOIN app_users u ON u.user_id = cp.cashier_id
WHERE cp.payment_status = 'completed'
GROUP BY DATE(cp.payment_time), u.user_id, u.full_name
ORDER BY shift_date DESC, total_cash_retained DESC;

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================
