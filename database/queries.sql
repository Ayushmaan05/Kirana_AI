-- ============================================================================
-- AI KIRANA STORE — SQL QUERIES
-- File       : queries.sql
-- Engine     : SQLite 3.35+
-- Description: Comprehensive query library — product search, alerts, sales
--              reports, profit analysis, AI data queries, moving average
--              demand forecasting, cash payment drawer management, and
--              online digital payment reconciliations.
-- Usage      : Open in any SQLite client or run with python / sqlite3 CLI.
-- ============================================================================

-- ############################################################################
-- SECTION 1: PRODUCT SEARCH & CATEGORY FILTERING
-- ############################################################################

-- 1.1  Search products by name (partial match)
SELECT p.product_id, p.sku, p.product_name, c.category_name,
       p.selling_price, p.current_stock, p.unit
FROM products p
JOIN categories c ON c.category_id = p.category_id
WHERE p.product_name LIKE '%rice%'
  AND p.is_active = 1;

-- 1.2  Filter all products in a specific category
SELECT p.product_id, p.sku, p.product_name, p.brand,
       p.selling_price, p.current_stock, p.unit
FROM products p
JOIN categories c ON c.category_id = p.category_id
WHERE c.category_name = 'Dairy'
  AND p.is_active = 1
ORDER BY p.product_name;

-- 1.3  List all products with category and supplier names
SELECT p.product_id, p.sku, p.product_name, c.category_name,
       COALESCE(s.supplier_name, 'N/A') AS supplier_name,
       p.brand, p.cost_price, p.selling_price,
       p.current_stock, p.unit, p.expiry_date
FROM products p
JOIN categories c ON c.category_id = p.category_id
LEFT JOIN suppliers s ON s.supplier_id = p.supplier_id
WHERE p.is_active = 1
ORDER BY c.category_name, p.product_name;

-- 1.4  Search by SKU
SELECT * FROM products WHERE sku = 'DAI-MLK-001';

-- ############################################################################
-- SECTION 2: LOW-STOCK ALERTS
-- ############################################################################

-- 2.1  Products below reorder point (uses view)
SELECT * FROM vw_low_stock_products;

-- 2.2  Direct query: low-stock with shortage quantity
SELECT p.sku, p.product_name, p.current_stock, p.min_stock_level,
       ROUND(p.min_stock_level - p.current_stock, 3) AS shortage,
       p.unit
FROM products p
WHERE p.current_stock < p.min_stock_level
  AND p.is_active = 1
ORDER BY shortage DESC;

-- 2.3  Products completely out of stock
SELECT p.sku, p.product_name, c.category_name,
       COALESCE(s.supplier_name, 'N/A') AS supplier
FROM products p
JOIN categories c ON c.category_id = p.category_id
LEFT JOIN suppliers s ON s.supplier_id = p.supplier_id
WHERE p.current_stock = 0
  AND p.is_active = 1;

-- ############################################################################
-- SECTION 3: EXPIRY ALERTS
-- ############################################################################

-- 3.1  Products expiring within 7 days
SELECT p.sku, p.product_name, p.expiry_date,
       CAST(ROUND(julianday(p.expiry_date) - julianday(DATE('now'))) AS INTEGER) AS days_left,
       p.current_stock, p.unit
FROM products p
WHERE p.expiry_date IS NOT NULL
  AND p.expiry_date BETWEEN DATE('now') AND DATE('now', '+7 days')
  AND p.current_stock > 0
ORDER BY p.expiry_date;

-- 3.2  Products expiring within 30 days (uses view)
SELECT * FROM vw_expiring_soon;

-- 3.3  Already expired products still in stock
SELECT p.sku, p.product_name, p.expiry_date,
       CAST(ROUND(julianday(DATE('now')) - julianday(p.expiry_date)) AS INTEGER) AS days_past_expiry,
       p.current_stock, p.unit
FROM products p
WHERE p.expiry_date IS NOT NULL
  AND p.expiry_date < DATE('now')
  AND p.current_stock > 0;

-- ############################################################################
-- SECTION 4: SALES REPORTS
-- ############################################################################

-- 4.1  Today's sales summary
SELECT COUNT(DISTINCT sale_id) AS total_bills,
       ROUND(SUM(net_amount), 2) AS total_revenue,
       ROUND(SUM(discount_amount), 2) AS total_discounts,
       ROUND(AVG(net_amount), 2) AS avg_bill_value
FROM sales
WHERE DATE(sale_date) = DATE('now')
  AND status = 'completed';

-- 4.2  Daily sales for last 7 days
SELECT DATE(sale_date) AS sale_day,
       COUNT(*) AS num_bills,
       ROUND(SUM(net_amount), 2) AS revenue,
       ROUND(SUM(discount_amount), 2) AS discounts
FROM sales
WHERE DATE(sale_date) >= DATE('now', '-7 days')
  AND status = 'completed'
GROUP BY DATE(sale_date)
ORDER BY sale_day DESC;

-- 4.3  Weekly sales for last 4 weeks
SELECT strftime('%Y-W%W', sale_date) AS year_week,
       MIN(DATE(sale_date)) AS week_start,
       MAX(DATE(sale_date)) AS week_end,
       COUNT(*) AS num_bills,
       ROUND(SUM(net_amount), 2) AS revenue
FROM sales
WHERE DATE(sale_date) >= DATE('now', '-28 days')
  AND status = 'completed'
GROUP BY strftime('%Y-W%W', sale_date)
ORDER BY year_week DESC;

-- 4.4  Monthly sales for last 6 months
SELECT strftime('%Y-%m', sale_date) AS month,
       COUNT(*) AS num_bills,
       ROUND(SUM(net_amount), 2) AS revenue,
       ROUND(SUM(discount_amount), 2) AS discounts,
       ROUND(AVG(net_amount), 2) AS avg_bill
FROM sales
WHERE DATE(sale_date) >= DATE('now', '-6 months')
  AND status = 'completed'
GROUP BY strftime('%Y-%m', sale_date)
ORDER BY month DESC;

-- 4.5  Sales by payment method
SELECT payment_method,
       COUNT(*) AS num_bills,
       ROUND(SUM(net_amount), 2) AS total_revenue,
       ROUND(100.0 * SUM(net_amount) /
             (SELECT SUM(net_amount) FROM sales WHERE status = 'completed'), 1)
             AS pct_revenue
FROM sales
WHERE status = 'completed'
GROUP BY payment_method
ORDER BY total_revenue DESC;

-- 4.6  Daily sales summary (uses view)
SELECT * FROM vw_daily_sales_summary
LIMIT 30;

-- ############################################################################
-- SECTION 5: BEST-SELLING PRODUCTS
-- ############################################################################

-- 5.1  Top 10 products by quantity sold (all time)
SELECT p.sku, p.product_name, p.unit,
       SUM(si.quantity) AS total_qty_sold,
       COUNT(DISTINCT si.sale_id) AS num_transactions
FROM sale_items si
JOIN products p ON p.product_id = si.product_id
JOIN sales s ON s.sale_id = si.sale_id
WHERE s.status = 'completed'
GROUP BY p.product_id, p.sku, p.product_name, p.unit
ORDER BY total_qty_sold DESC
LIMIT 10;

-- 5.2  Top 10 products by revenue (all time)
SELECT p.sku, p.product_name,
       ROUND(SUM(si.line_total), 2) AS total_revenue,
       SUM(si.quantity) AS total_qty_sold
FROM sale_items si
JOIN products p ON p.product_id = si.product_id
JOIN sales s ON s.sale_id = si.sale_id
WHERE s.status = 'completed'
GROUP BY p.product_id, p.sku, p.product_name
ORDER BY total_revenue DESC
LIMIT 10;

-- 5.3  Top products this month
SELECT p.sku, p.product_name,
       SUM(si.quantity) AS qty_sold,
       ROUND(SUM(si.line_total), 2) AS revenue
FROM sale_items si
JOIN products p ON p.product_id = si.product_id
JOIN sales s ON s.sale_id = si.sale_id
WHERE s.status = 'completed'
  AND strftime('%Y-%m', s.sale_date) = strftime('%Y-%m', DATE('now'))
GROUP BY p.product_id, p.sku, p.product_name
ORDER BY qty_sold DESC
LIMIT 10;

-- 5.4  Best-selling categories
SELECT c.category_name,
       SUM(si.quantity) AS total_qty_sold,
       ROUND(SUM(si.line_total), 2) AS total_revenue,
       COUNT(DISTINCT si.product_id) AS products_sold
FROM sale_items si
JOIN products p ON p.product_id = si.product_id
JOIN categories c ON c.category_id = p.category_id
JOIN sales s ON s.sale_id = si.sale_id
WHERE s.status = 'completed'
GROUP BY c.category_id, c.category_name
ORDER BY total_revenue DESC;

-- ############################################################################
-- SECTION 6: PROFIT ANALYSIS
-- ############################################################################

-- 6.1  Estimated gross profit per product
SELECT p.sku, p.product_name,
       SUM(si.quantity) AS total_qty_sold,
       ROUND(SUM(si.line_total), 2) AS revenue,
       ROUND(SUM(si.cost_price * si.quantity), 2) AS cost,
       ROUND(SUM(si.line_total) - SUM(si.cost_price * si.quantity), 2) AS gross_profit,
       ROUND(100.0 * (SUM(si.line_total) - SUM(si.cost_price * si.quantity))
             / NULLIF(SUM(si.line_total), 0), 1) AS margin_pct
FROM sale_items si
JOIN products p ON p.product_id = si.product_id
JOIN sales s ON s.sale_id = si.sale_id
WHERE s.status = 'completed'
GROUP BY p.product_id, p.sku, p.product_name
ORDER BY gross_profit DESC;

-- 6.2  Daily profit report
SELECT DATE(s.sale_date) AS sale_day,
       ROUND(SUM(si.line_total), 2) AS revenue,
       ROUND(SUM(si.cost_price * si.quantity), 2) AS cost,
       ROUND(SUM(si.line_total) - SUM(si.cost_price * si.quantity), 2) AS daily_profit
FROM sale_items si
JOIN sales s ON s.sale_id = si.sale_id
WHERE s.status = 'completed'
GROUP BY DATE(s.sale_date)
ORDER BY sale_day DESC;

-- 6.3  Overall profit summary
SELECT
    ROUND(SUM(si.line_total), 2) AS total_revenue,
    ROUND(SUM(si.cost_price * si.quantity), 2) AS total_cost,
    ROUND(SUM(si.line_total) - SUM(si.cost_price * si.quantity), 2) AS total_profit,
    ROUND(100.0 * (SUM(si.line_total) - SUM(si.cost_price * si.quantity))
          / NULLIF(SUM(si.line_total), 0), 1) AS overall_margin_pct,
    COUNT(DISTINCT s.sale_id) AS total_bills,
    COUNT(DISTINCT si.product_id) AS products_sold
FROM sale_items si
JOIN sales s ON s.sale_id = si.sale_id
WHERE s.status = 'completed';

-- ############################################################################
-- SECTION 7: SUPPLIER & PURCHASE HISTORY
-- ############################################################################

-- 7.1  All purchases from a specific supplier
SELECT pu.purchase_number, pu.purchase_date, pu.net_amount,
       pu.payment_status, pu.status,
       u.full_name AS received_by
FROM purchases pu
JOIN app_users u ON u.user_id = pu.received_by
WHERE pu.supplier_id = 1  -- Mother Dairy
ORDER BY pu.purchase_date DESC;

-- 7.2  Purchase summary by supplier
SELECT s.supplier_name,
       COUNT(*) AS num_purchases,
       ROUND(SUM(pu.net_amount), 2) AS total_spent,
       MAX(pu.purchase_date) AS last_purchase,
       ROUND(SUM(CASE WHEN pu.payment_status = 'unpaid' THEN pu.net_amount ELSE 0 END), 2)
           AS outstanding_amount
FROM purchases pu
JOIN suppliers s ON s.supplier_id = pu.supplier_id
WHERE pu.status = 'received'
GROUP BY s.supplier_id, s.supplier_name
ORDER BY total_spent DESC;

-- 7.3  Recent purchases (last 30 days) with line items
SELECT pu.purchase_number, s.supplier_name, pu.purchase_date,
       p.product_name, pi.quantity, pi.unit_cost, pi.line_total
FROM purchases pu
JOIN suppliers s ON s.supplier_id = pu.supplier_id
JOIN purchase_items pi ON pi.purchase_id = pu.purchase_id
JOIN products p ON p.product_id = pi.product_id
WHERE DATE(pu.purchase_date) >= DATE('now', '-30 days')
ORDER BY pu.purchase_date DESC, p.product_name;

-- 7.4  Products supplied by each supplier
SELECT s.supplier_name, p.sku, p.product_name, p.cost_price, p.selling_price
FROM products p
JOIN suppliers s ON s.supplier_id = p.supplier_id
WHERE p.is_active = 1
ORDER BY s.supplier_name, p.product_name;

-- ############################################################################
-- SECTION 8: INVENTORY VALUATION
-- ############################################################################

-- 8.1  Full inventory valuation (uses view)
SELECT * FROM vw_inventory_valuation;

-- 8.2  Total inventory value
SELECT
    ROUND(SUM(current_stock * cost_price), 2) AS total_value_at_cost,
    ROUND(SUM(current_stock * selling_price), 2) AS total_value_at_selling,
    ROUND(SUM(current_stock * selling_price) - SUM(current_stock * cost_price), 2)
        AS potential_margin,
    COUNT(*) AS products_in_stock
FROM products
WHERE is_active = 1 AND current_stock > 0;

-- 8.3  Valuation by category
SELECT c.category_name,
       COUNT(*) AS num_products,
       ROUND(SUM(p.current_stock * p.cost_price), 2) AS value_at_cost,
       ROUND(SUM(p.current_stock * p.selling_price), 2) AS value_at_selling
FROM products p
JOIN categories c ON c.category_id = p.category_id
WHERE p.is_active = 1 AND p.current_stock > 0
GROUP BY c.category_id, c.category_name
ORDER BY value_at_cost DESC;

-- ############################################################################
-- SECTION 9: AI DATA QUERIES — DEMAND FORECASTING INPUT
-- ############################################################################

-- 9.1  Daily product-wise sales (AI input view)
SELECT * FROM vw_product_daily_sales
LIMIT 50;

-- 9.2  Historical demand — last 30 days per product
SELECT si.product_id, p.product_name, p.sku,
       SUM(si.quantity) AS total_qty_sold_30d,
       COUNT(DISTINCT DATE(s.sale_date)) AS days_with_sales,
       ROUND(SUM(si.quantity) / 30.0, 3) AS avg_daily_demand_30d
FROM sale_items si
JOIN products p ON p.product_id = si.product_id
JOIN sales s ON s.sale_id = si.sale_id
WHERE s.status = 'completed'
  AND DATE(s.sale_date) >= DATE('now', '-30 days')
GROUP BY si.product_id, p.product_name, p.sku
ORDER BY avg_daily_demand_30d DESC;

-- 9.3  Historical demand — last 60 days per product
SELECT si.product_id, p.product_name,
       SUM(si.quantity) AS total_qty_sold_60d,
       ROUND(SUM(si.quantity) / 60.0, 3) AS avg_daily_demand_60d
FROM sale_items si
JOIN products p ON p.product_id = si.product_id
JOIN sales s ON s.sale_id = si.sale_id
WHERE s.status = 'completed'
  AND DATE(s.sale_date) >= DATE('now', '-60 days')
GROUP BY si.product_id, p.product_name
ORDER BY avg_daily_demand_60d DESC;

-- 9.4  Historical demand — last 90 days per product
SELECT si.product_id, p.product_name,
       SUM(si.quantity) AS total_qty_sold_90d,
       ROUND(SUM(si.quantity) / 90.0, 3) AS avg_daily_demand_90d
FROM sale_items si
JOIN products p ON p.product_id = si.product_id
JOIN sales s ON s.sale_id = si.sale_id
WHERE s.status = 'completed'
  AND DATE(s.sale_date) >= DATE('now', '-90 days')
GROUP BY si.product_id, p.product_name
ORDER BY avg_daily_demand_90d DESC;

-- 9.5  Current stock levels with supplier lead times
SELECT p.product_id, p.sku, p.product_name,
       p.current_stock, p.min_stock_level, p.unit,
       p.cost_price, p.selling_price,
       COALESCE(s.supplier_name, 'N/A') AS supplier,
       COALESCE(s.lead_time_days, 0) AS lead_time_days
FROM products p
LEFT JOIN suppliers s ON s.supplier_id = p.supplier_id
WHERE p.is_active = 1
ORDER BY p.current_stock ASC;

-- 9.6  Inventory movement history for a specific product
SELECT im.created_at, im.movement_type, im.quantity_change,
       im.stock_after, im.reference_type, im.remarks,
       COALESCE(u.full_name, 'System') AS performed_by
FROM inventory_movements im
LEFT JOIN app_users u ON u.user_id = im.performed_by
WHERE im.product_id = 1  -- Full Cream Milk
ORDER BY im.created_at DESC;

-- 9.7  Active AI forecasts and restock suggestions
SELECT ai.insight_id, p.sku, p.product_name,
       ai.insight_type, ai.forecast_date,
       ai.predicted_demand, ai.suggested_restock_qty,
       ai.confidence_score, ai.model_version,
       ai.explanation, ai.generated_by
FROM ai_insights ai
JOIN products p ON p.product_id = ai.product_id
WHERE ai.is_active = 1
ORDER BY ai.forecast_date DESC, ai.insight_type;

-- ############################################################################
-- SECTION 10: SQL-BASED DEMAND FORECASTING MODULE
-- ############################################################################

-- ============================================================================
-- 10.1  AVERAGE DAILY DEMAND (7, 30, 90 days)
-- ============================================================================
WITH RECURSIVE date_series(dt) AS (
    SELECT DATE('now', '-90 days')
    UNION ALL
    SELECT DATE(dt, '+1 day')
    FROM date_series
    WHERE dt < DATE('now')
),
active_products AS (
    SELECT product_id, product_name, sku
    FROM products
    WHERE is_active = 1
),
daily_sales AS (
    SELECT DATE(s.sale_date) AS sale_day,
           si.product_id,
           SUM(si.quantity) AS qty_sold
    FROM sale_items si
    JOIN sales s ON s.sale_id = si.sale_id
    WHERE s.status = 'completed'
      AND DATE(s.sale_date) >= DATE('now', '-90 days')
    GROUP BY DATE(s.sale_date), si.product_id
),
product_date_grid AS (
    SELECT ap.product_id, ap.product_name, ap.sku,
           ds.dt AS sale_day,
           COALESCE(dl.qty_sold, 0) AS qty_sold
    FROM active_products ap
    CROSS JOIN date_series ds
    LEFT JOIN daily_sales dl
        ON dl.product_id = ap.product_id AND dl.sale_day = ds.dt
)
SELECT product_id, product_name, sku,
    ROUND(SUM(CASE WHEN sale_day >= DATE('now', '-7 days') THEN qty_sold ELSE 0 END) / 7.0, 3) AS avg_daily_7d,
    ROUND(SUM(CASE WHEN sale_day >= DATE('now', '-30 days') THEN qty_sold ELSE 0 END) / 30.0, 3) AS avg_daily_30d,
    ROUND(SUM(qty_sold) / 90.0, 3) AS avg_daily_90d,
    SUM(CASE WHEN sale_day >= DATE('now', '-7 days') THEN qty_sold ELSE 0 END) AS total_7d,
    SUM(CASE WHEN sale_day >= DATE('now', '-30 days') THEN qty_sold ELSE 0 END) AS total_30d,
    SUM(qty_sold) AS total_90d
FROM product_date_grid
GROUP BY product_id, product_name, sku
HAVING total_90d > 0
ORDER BY avg_daily_30d DESC;

-- ============================================================================
-- 10.2  SIMPLE MOVING AVERAGE (7-day and 30-day rolling windows)
-- ============================================================================
WITH RECURSIVE date_series(dt) AS (
    SELECT DATE('now', '-90 days')
    UNION ALL
    SELECT DATE(dt, '+1 day') FROM date_series WHERE dt < DATE('now')
),
daily_sales AS (
    SELECT DATE(s.sale_date) AS sale_day,
           si.product_id,
           SUM(si.quantity) AS qty_sold
    FROM sale_items si
    JOIN sales s ON s.sale_id = si.sale_id
    WHERE s.status = 'completed'
      AND DATE(s.sale_date) >= DATE('now', '-90 days')
    GROUP BY DATE(s.sale_date), si.product_id
),
product_daily AS (
    SELECT ds.dt AS sale_day,
           COALESCE(dl.qty_sold, 0) AS qty_sold
    FROM date_series ds
    LEFT JOIN daily_sales dl ON dl.sale_day = ds.dt AND dl.product_id = 1
)
SELECT sale_day,
       qty_sold,
       ROUND(AVG(qty_sold) OVER (
           ORDER BY sale_day
           ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
       ), 3) AS sma_7d,
       ROUND(AVG(qty_sold) OVER (
           ORDER BY sale_day
           ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
       ), 3) AS sma_30d
FROM product_daily
WHERE sale_day >= DATE('now', '-30 days')
ORDER BY sale_day;

-- ============================================================================
-- 10.3  TREND DETECTION
-- ============================================================================
WITH demand_periods AS (
    SELECT si.product_id,
           p.product_name,
           p.sku,
           SUM(CASE
               WHEN DATE(s.sale_date) >= DATE('now', '-30 days')
               THEN si.quantity ELSE 0 END) AS recent_30d_qty,
           SUM(CASE
               WHEN DATE(s.sale_date) >= DATE('now', '-60 days')
                AND DATE(s.sale_date) < DATE('now', '-30 days')
               THEN si.quantity ELSE 0 END) AS prev_30d_qty
    FROM sale_items si
    JOIN products p ON p.product_id = si.product_id
    JOIN sales s ON s.sale_id = si.sale_id
    WHERE s.status = 'completed'
      AND DATE(s.sale_date) >= DATE('now', '-60 days')
    GROUP BY si.product_id, p.product_name, p.sku
)
SELECT product_id, product_name, sku,
       recent_30d_qty,
       prev_30d_qty,
       CASE
           WHEN prev_30d_qty = 0 AND recent_30d_qty > 0 THEN 100.0
           WHEN prev_30d_qty = 0 AND recent_30d_qty = 0 THEN 0.0
           ELSE ROUND(100.0 * (recent_30d_qty - prev_30d_qty) / prev_30d_qty, 1)
       END AS pct_change,
       CASE
           WHEN prev_30d_qty = 0 AND recent_30d_qty > 0 THEN 'NEW_DEMAND'
           WHEN prev_30d_qty = 0 AND recent_30d_qty = 0 THEN 'NO_SALES'
           WHEN (recent_30d_qty - prev_30d_qty) * 1.0 / prev_30d_qty > 0.15  THEN 'INCREASING'
           WHEN (recent_30d_qty - prev_30d_qty) * 1.0 / prev_30d_qty < -0.15 THEN 'DECREASING'
           ELSE 'STABLE'
       END AS trend
FROM demand_periods
ORDER BY recent_30d_qty DESC;

-- ============================================================================
-- 10.4  7-DAY DEMAND FORECAST
-- ============================================================================
WITH RECURSIVE date_series(dt) AS (
    SELECT DATE('now', '-30 days')
    UNION ALL
    SELECT DATE(dt, '+1 day') FROM date_series WHERE dt < DATE('now')
),
daily_sales AS (
    SELECT DATE(s.sale_date) AS sale_day,
           si.product_id,
           SUM(si.quantity) AS qty_sold
    FROM sale_items si
    JOIN sales s ON s.sale_id = si.sale_id
    WHERE s.status = 'completed'
      AND DATE(s.sale_date) >= DATE('now', '-30 days')
    GROUP BY DATE(s.sale_date), si.product_id
),
product_avg AS (
    SELECT p.product_id, p.product_name, p.sku,
           p.current_stock, p.min_stock_level, p.unit,
           COALESCE(
               SUM(CASE WHEN ds.dt >= DATE('now', '-7 days')
                        THEN COALESCE(dl.qty_sold, 0) ELSE 0 END) / 7.0,
               0
           ) AS avg_daily_7d
    FROM products p
    CROSS JOIN date_series ds
    LEFT JOIN daily_sales dl ON dl.product_id = p.product_id AND dl.sale_day = ds.dt
    WHERE p.is_active = 1
    GROUP BY p.product_id, p.product_name, p.sku,
             p.current_stock, p.min_stock_level, p.unit
)
SELECT product_id, product_name, sku, unit,
       current_stock,
       ROUND(avg_daily_7d, 3) AS avg_daily_demand,
       ROUND(avg_daily_7d * 7, 3) AS predicted_demand_7d,
       ROUND(current_stock - (avg_daily_7d * 7), 3) AS predicted_stock_after_7d,
       CASE
           WHEN current_stock - (avg_daily_7d * 7) < min_stock_level
           THEN 'RESTOCK NEEDED'
           WHEN current_stock - (avg_daily_7d * 7) < 0
           THEN 'WILL STOCKOUT'
           ELSE 'OK'
       END AS stock_status
FROM product_avg
WHERE avg_daily_7d > 0
ORDER BY predicted_stock_after_7d ASC;

-- ============================================================================
-- 10.5  RESTOCK SUGGESTION QUERY
-- ============================================================================
WITH RECURSIVE date_series(dt) AS (
    SELECT DATE('now', '-30 days')
    UNION ALL
    SELECT DATE(dt, '+1 day') FROM date_series WHERE dt < DATE('now')
),
daily_sales AS (
    SELECT DATE(s.sale_date) AS sale_day,
           si.product_id,
           SUM(si.quantity) AS qty_sold
    FROM sale_items si
    JOIN sales s ON s.sale_id = si.sale_id
    WHERE s.status = 'completed'
      AND DATE(s.sale_date) >= DATE('now', '-30 days')
    GROUP BY DATE(s.sale_date), si.product_id
),
product_demand AS (
    SELECT p.product_id, p.product_name, p.sku,
           p.current_stock, p.min_stock_level, p.cost_price, p.unit,
           COALESCE(s.supplier_name, 'N/A') AS supplier_name,
           COALESCE(s.lead_time_days, 3) AS lead_time_days,
           COALESCE(
               SUM(CASE WHEN ds.dt >= DATE('now', '-7 days')
                        THEN COALESCE(dl.qty_sold, 0) ELSE 0 END) / 7.0,
               0
           ) AS avg_daily_7d
    FROM products p
    LEFT JOIN suppliers s ON s.supplier_id = p.supplier_id
    CROSS JOIN date_series ds
    LEFT JOIN daily_sales dl ON dl.product_id = p.product_id AND dl.sale_day = ds.dt
    WHERE p.is_active = 1
    GROUP BY p.product_id, p.product_name, p.sku,
             p.current_stock, p.min_stock_level, p.cost_price, p.unit,
             s.supplier_name, s.lead_time_days
)
SELECT product_id, product_name, sku, unit,
       current_stock,
       ROUND(avg_daily_7d, 3) AS avg_daily_demand,
       lead_time_days,
       supplier_name,
       ROUND(avg_daily_7d * 7, 3) AS predicted_7d_demand,
       ROUND(avg_daily_7d * lead_time_days, 3) AS lead_time_demand,
       MAX(0, ROUND(
           (avg_daily_7d * 7 * 1.25)
         + (avg_daily_7d * lead_time_days)
         - current_stock,
       3)) AS suggested_order_qty,
       ROUND(MAX(0,
           (avg_daily_7d * 7 * 1.25)
         + (avg_daily_7d * lead_time_days)
         - current_stock
       ) * cost_price, 2) AS estimated_order_cost
FROM product_demand
WHERE avg_daily_7d > 0
ORDER BY suggested_order_qty DESC;

-- ============================================================================
-- 10.6  STORE FORECASTS INTO ai_insights
-- ============================================================================
-- Deactivate previous SQL-based forecasts
UPDATE ai_insights
SET is_active = 0
WHERE generated_by = 'sql_procedure'
  AND insight_type = 'sql_moving_avg_forecast';

-- Insert new forecasts
INSERT INTO ai_insights (
    product_id, insight_type, forecast_date,
    predicted_demand, suggested_restock_qty, confidence_score,
    model_version, parameters_used, explanation,
    data_period_start, data_period_end,
    is_active, generated_by
)
WITH RECURSIVE date_series(dt) AS (
    SELECT DATE('now', '-30 days')
    UNION ALL
    SELECT DATE(dt, '+1 day') FROM date_series WHERE dt < DATE('now')
),
daily_sales AS (
    SELECT DATE(s.sale_date) AS sale_day,
           si.product_id,
           SUM(si.quantity) AS qty_sold
    FROM sale_items si
    JOIN sales s ON s.sale_id = si.sale_id
    WHERE s.status = 'completed'
      AND DATE(s.sale_date) >= DATE('now', '-30 days')
    GROUP BY DATE(s.sale_date), si.product_id
),
product_forecast AS (
    SELECT p.product_id,
           p.product_name,
           p.current_stock,
           COALESCE(sup.lead_time_days, 3) AS lead_time_days,
           COALESCE(
               SUM(CASE WHEN ds.dt >= DATE('now', '-7 days')
                        THEN COALESCE(dl.qty_sold, 0) ELSE 0 END) / 7.0,
               0) AS avg_daily_7d,
           COALESCE(SUM(COALESCE(dl.qty_sold, 0)) / 30.0, 0) AS avg_daily_30d,
           COUNT(DISTINCT CASE WHEN dl.qty_sold > 0 THEN ds.dt END) AS days_with_sales
    FROM products p
    CROSS JOIN date_series ds
    LEFT JOIN daily_sales dl ON dl.product_id = p.product_id AND dl.sale_day = ds.dt
    LEFT JOIN suppliers sup ON sup.supplier_id = p.supplier_id
    WHERE p.is_active = 1
    GROUP BY p.product_id, p.product_name, p.current_stock, sup.lead_time_days
    HAVING avg_daily_7d > 0 OR avg_daily_30d > 0
)
SELECT
    product_id,
    'sql_moving_avg_forecast',
    DATE('now', '+7 days'),
    ROUND(avg_daily_7d * 7, 3),
    MAX(0, ROUND((avg_daily_7d * 7 * 1.25) + (avg_daily_7d * lead_time_days) - current_stock, 3)),
    ROUND(MIN(1.0, days_with_sales / 20.0), 4),
    'sql_moving_avg_v1',
    json_object(
        'window_7day', 7,
        'window_30day', 30,
        'safety_factor', 1.25,
        'lead_time_days', lead_time_days
    ),
    'SQL moving-average forecast. 7-day avg demand: ' || ROUND(avg_daily_7d, 3) || '/day. ' ||
    '30-day avg demand: ' || ROUND(avg_daily_30d, 3) || '/day. ' ||
    'Based on ' || days_with_sales || ' days with actual sales out of 30.',
    DATE('now', '-30 days'),
    DATE('now'),
    1,
    'sql_procedure'
FROM product_forecast;

-- ============================================================================
-- 10.7  EDGE CASES AND CONSIDERATIONS
-- ============================================================================

-- Products with NO sales history at all (cannot be forecast)
SELECT p.sku, p.product_name, p.current_stock,
       'NO SALES DATA - Cannot forecast' AS note
FROM products p
LEFT JOIN sale_items si ON si.product_id = p.product_id
LEFT JOIN sales s ON s.sale_id = si.sale_id AND s.status = 'completed'
WHERE p.is_active = 1
  AND s.sale_id IS NULL;

-- Products with very sparse sales (low confidence forecasts)
WITH product_sales_freq AS (
    SELECT si.product_id,
           p.product_name,
           COUNT(DISTINCT DATE(s.sale_date)) AS days_with_sales,
           MIN(DATE(s.sale_date)) AS first_sale,
           MAX(DATE(s.sale_date)) AS last_sale,
           CAST(ROUND(julianday(MAX(DATE(s.sale_date))) - julianday(MIN(DATE(s.sale_date)))) AS INTEGER) + 1 AS span_days
    FROM sale_items si
    JOIN products p ON p.product_id = si.product_id
    JOIN sales s ON s.sale_id = si.sale_id
    WHERE s.status = 'completed'
    GROUP BY si.product_id, p.product_name
)
SELECT product_id, product_name,
       days_with_sales, span_days,
       ROUND(100.0 * days_with_sales / NULLIF(span_days, 0), 1) AS sale_frequency_pct,
       CASE
           WHEN days_with_sales <= 3 THEN 'VERY LOW — forecast unreliable'
           WHEN days_with_sales <= 7 THEN 'LOW — use with caution'
           WHEN days_with_sales <= 15 THEN 'MODERATE — reasonable estimate'
           ELSE 'GOOD — sufficient data'
       END AS data_quality
FROM product_sales_freq
ORDER BY days_with_sales ASC;

-- ############################################################################
-- SECTION 11: SUGGESTED RESTOCKING — PRIORITY-RANKED
-- ############################################################################

-- 11.1  Products needing restock with priority ranking
WITH RECURSIVE date_series(dt) AS (
    SELECT DATE('now', '-30 days')
    UNION ALL
    SELECT DATE(dt, '+1 day') FROM date_series WHERE dt < DATE('now')
),
daily_sales AS (
    SELECT DATE(s.sale_date) AS sale_day,
           si.product_id,
           SUM(si.quantity) AS qty_sold
    FROM sale_items si
    JOIN sales s ON s.sale_id = si.sale_id
    WHERE s.status = 'completed'
      AND DATE(s.sale_date) >= DATE('now', '-30 days')
    GROUP BY DATE(s.sale_date), si.product_id
),
restock_calc AS (
    SELECT p.product_id, p.product_name, p.sku, p.unit,
           p.current_stock, p.min_stock_level, p.cost_price,
           COALESCE(s.supplier_name, 'N/A') AS supplier_name,
           COALESCE(s.lead_time_days, 3) AS lead_time_days,
           COALESCE(
               SUM(CASE WHEN ds.dt >= DATE('now', '-7 days')
                        THEN COALESCE(dl.qty_sold, 0) ELSE 0 END) / 7.0,
               0) AS avg_daily_7d,
           p.expiry_date
    FROM products p
    LEFT JOIN suppliers s ON s.supplier_id = p.supplier_id
    CROSS JOIN date_series ds
    LEFT JOIN daily_sales dl ON dl.product_id = p.product_id AND dl.sale_day = ds.dt
    WHERE p.is_active = 1
    GROUP BY p.product_id, p.product_name, p.sku, p.unit,
             p.current_stock, p.min_stock_level, p.cost_price,
             s.supplier_name, s.lead_time_days, p.expiry_date
)
SELECT product_id, product_name, sku, unit,
       current_stock,
       min_stock_level,
       ROUND(avg_daily_7d, 3) AS avg_daily_demand,
       lead_time_days,
       supplier_name,
       CASE WHEN avg_daily_7d > 0
            THEN ROUND(current_stock / avg_daily_7d, 1)
            ELSE 9999
       END AS days_of_stock_left,
       MAX(0, ROUND(
           (avg_daily_7d * 7 * 1.25)
         + (avg_daily_7d * lead_time_days)
         - current_stock, 3)) AS suggested_order_qty,
       ROUND(MAX(0,
           (avg_daily_7d * 7 * 1.25)
         + (avg_daily_7d * lead_time_days)
         - current_stock) * cost_price, 2) AS estimated_cost,
       CASE
           WHEN current_stock = 0 THEN '🔴 CRITICAL — OUT OF STOCK'
           WHEN current_stock < min_stock_level THEN '🟠 HIGH — BELOW REORDER POINT'
           WHEN avg_daily_7d > 0 AND current_stock / avg_daily_7d < lead_time_days
                THEN '🟡 MEDIUM — STOCK < LEAD TIME'
           WHEN avg_daily_7d > 0 AND current_stock / avg_daily_7d < 14
                THEN '🔵 LOW — LESS THAN 2 WEEKS'
           ELSE '🟢 OK — ADEQUATE STOCK'
       END AS priority
FROM restock_calc
ORDER BY
    CASE
        WHEN current_stock = 0 THEN 1
        WHEN current_stock < min_stock_level THEN 2
        WHEN avg_daily_7d > 0 AND current_stock / avg_daily_7d < lead_time_days THEN 3
        WHEN avg_daily_7d > 0 AND current_stock / avg_daily_7d < 14 THEN 4
        ELSE 5
    END,
    current_stock ASC;

-- ############################################################################
-- SECTION 12: CASH PAYMENTS & CASH DRAWER RECONCILIATION (NEW SCHEMA)
-- ############################################################################

-- 12.1  Shift-wise Cash Drawer Summary (uses view)
SELECT * FROM vw_cashier_cash_register;

-- 12.2  Detailed Cash Log with Customer and Cashier Information
SELECT cp.cash_payment_id,
       s.invoice_number,
       cp.payment_time,
       s.customer_name,
       u.full_name AS cashier_name,
       cp.amount_tendered,
       cp.amount_received,
       cp.change_returned,
       cp.denomination_breakdown,
       cp.payment_status
FROM cash_payments cp
JOIN sales s ON s.sale_id = cp.sale_id
JOIN app_users u ON u.user_id = cp.cashier_id
ORDER BY cp.payment_time DESC;

-- 12.3  High-Value Cash Bills (bills >= ₹500 paid in cash)
SELECT s.invoice_number,
       cp.payment_time,
       s.customer_name,
       cp.amount_received,
       cp.amount_tendered,
       cp.change_returned,
       cp.denomination_breakdown
FROM cash_payments cp
JOIN sales s ON s.sale_id = cp.sale_id
WHERE cp.amount_received >= 500.00
  AND cp.payment_status = 'completed'
ORDER BY cp.amount_received DESC;

-- 12.4  Total Change Returned by Day (Coin and small note requirements)
SELECT DATE(cp.payment_time) AS payment_date,
       COUNT(*) AS total_cash_sales,
       ROUND(SUM(cp.amount_received), 2) AS cash_intake,
       ROUND(SUM(cp.change_returned), 2) AS total_change_dispensed,
       ROUND(AVG(cp.change_returned), 2) AS avg_change_per_bill
FROM cash_payments cp
WHERE cp.payment_status = 'completed'
GROUP BY DATE(cp.payment_time)
ORDER BY payment_date DESC;

-- 12.5  Cancelled / Refunded Cash Transactions
SELECT cp.cash_payment_id,
       s.invoice_number,
       cp.payment_time,
       u.full_name AS cashier_name,
       cp.amount_received AS refunded_cash,
       cp.notes
FROM cash_payments cp
JOIN sales s ON s.sale_id = cp.sale_id
JOIN app_users u ON u.user_id = cp.cashier_id
WHERE cp.payment_status IN ('cancelled', 'refunded')
ORDER BY cp.payment_time DESC;

-- ############################################################################
-- SECTION 13: ONLINE PAYMENTS & DIGITAL SETTLEMENTS (NEW SCHEMA)
-- ############################################################################

-- 13.1  Digital Transaction Log (UPI & POS Cards)
SELECT op.online_payment_id,
       s.invoice_number,
       op.payment_time,
       op.payment_platform,
       op.provider,
       op.transaction_reference_id,
       op.amount,
       op.payer_upi_id,
       op.payer_phone,
       op.payment_status,
       op.settlement_status,
       op.terminal_device_id
FROM online_payments op
JOIN sales s ON s.sale_id = op.sale_id
ORDER BY op.payment_time DESC;

-- 13.2  Provider Market Share (PhonePe vs Google Pay vs Paytm vs Pine Labs)
SELECT op.provider,
       op.payment_platform,
       COUNT(*) AS transaction_count,
       ROUND(SUM(op.amount), 2) AS total_processed,
       ROUND(100.0 * SUM(op.amount) / (SELECT SUM(amount) FROM online_payments WHERE payment_status = 'success'), 2) AS share_pct,
       ROUND(SUM(op.gateway_fee), 2) AS total_gateway_fees,
       ROUND(SUM(op.amount) - SUM(op.gateway_fee), 2) AS net_settlement_amount
FROM online_payments op
WHERE op.payment_status = 'success'
GROUP BY op.provider, op.payment_platform
ORDER BY total_processed DESC;

-- 13.3  UPI vs Card POS Breakdown
SELECT op.payment_platform,
       COUNT(*) AS transaction_count,
       ROUND(SUM(op.amount), 2) AS total_volume,
       ROUND(AVG(op.amount), 2) AS avg_ticket_size,
       ROUND(SUM(op.gateway_fee), 2) AS total_charges
FROM online_payments op
WHERE op.payment_status = 'success'
GROUP BY op.payment_platform
ORDER BY total_volume DESC;

-- 13.4  Search Online Payment by Transaction Reference ID or UPI ID
SELECT op.online_payment_id,
       s.invoice_number,
       s.customer_name,
       op.payment_platform,
       op.provider,
       op.transaction_reference_id,
       op.amount,
       op.payer_upi_id,
       op.payment_status,
       op.payment_time
FROM online_payments op
JOIN sales s ON s.sale_id = op.sale_id
WHERE op.transaction_reference_id LIKE '%20260718%'
   OR op.payer_upi_id LIKE '%ybl%';

-- ############################################################################
-- SECTION 14: UNIFIED PAYMENT RECONCILIATION (CASH VS DIGITAL)
-- ############################################################################

-- 14.1  Daily Payment Breakdown (uses view)
SELECT * FROM vw_daily_payment_breakdown
LIMIT 30;

-- 14.2  Bill-Level Payment Reconciliation Check
-- Confirms that billed amount strictly equals cash received + online payment
SELECT s.invoice_number,
       s.sale_date,
       s.net_amount AS bill_total,
       COALESCE(cp.amount_received, 0.0) AS cash_amount,
       COALESCE(op.amount, 0.0) AS online_amount,
       ROUND(COALESCE(cp.amount_received, 0.0) + COALESCE(op.amount, 0.0), 2) AS total_paid,
       ROUND(s.net_amount - (COALESCE(cp.amount_received, 0.0) + COALESCE(op.amount, 0.0)), 2) AS reconciliation_diff,
       CASE
           WHEN ABS(s.net_amount - (COALESCE(cp.amount_received, 0.0) + COALESCE(op.amount, 0.0))) < 0.01
           THEN '✅ MATCH'
           ELSE '❌ MISMATCH'
       END AS audit_status
FROM sales s
LEFT JOIN cash_payments cp ON cp.sale_id = s.sale_id AND cp.payment_status = 'completed'
LEFT JOIN online_payments op ON op.sale_id = s.sale_id AND op.payment_status = 'success'
WHERE s.status = 'completed'
ORDER BY s.sale_date DESC;

-- 14.3  Overall Digital Adoption Rate across Kirana Store
SELECT
    COUNT(s.sale_id) AS total_sales_count,
    ROUND(SUM(s.net_amount), 2) AS total_revenue,
    ROUND(SUM(CASE WHEN s.payment_method = 'cash' THEN s.net_amount ELSE 0 END), 2) AS cash_revenue,
    ROUND(SUM(CASE WHEN s.payment_method IN ('upi', 'card', 'online') THEN s.net_amount ELSE 0 END), 2) AS digital_revenue,
    ROUND(100.0 * SUM(CASE WHEN s.payment_method IN ('upi', 'card', 'online') THEN s.net_amount ELSE 0 END) / SUM(s.net_amount), 2) AS digital_adoption_pct
FROM sales s
WHERE s.status = 'completed';

-- ============================================================================
-- END OF QUERIES
-- ============================================================================
