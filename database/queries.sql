-- ============================================================================
-- AI KIRANA STORE — SQL QUERIES
-- File       : queries.sql
-- Engine     : MySQL 8.0+
-- Description: Comprehensive query library — product search, alerts, sales
--              reports, profit analysis, AI data queries, and SQL-based
--              demand forecasting with moving averages.
-- Usage      : Open in MySQL Workbench and run individual sections.
-- ============================================================================

USE `kirana_store`;

-- ############################################################################
-- SECTION 1: PRODUCT SEARCH & CATEGORY FILTERING
-- ############################################################################

-- 1.1  Search products by name (partial match)
SELECT p.product_id, p.sku, p.product_name, c.category_name,
       p.selling_price, p.current_stock, p.unit
FROM products p
JOIN categories c ON c.category_id = p.category_id
WHERE p.product_name LIKE '%rice%'
  AND p.is_active = TRUE;

-- 1.2  Filter all products in a specific category
SELECT p.product_id, p.sku, p.product_name, p.brand,
       p.selling_price, p.current_stock, p.unit
FROM products p
JOIN categories c ON c.category_id = p.category_id
WHERE c.category_name = 'Dairy'
  AND p.is_active = TRUE
ORDER BY p.product_name;

-- 1.3  List all products with category and supplier names
SELECT p.product_id, p.sku, p.product_name, c.category_name,
       COALESCE(s.supplier_name, 'N/A') AS supplier_name,
       p.brand, p.cost_price, p.selling_price,
       p.current_stock, p.unit, p.expiry_date
FROM products p
JOIN categories c ON c.category_id = p.category_id
LEFT JOIN suppliers s ON s.supplier_id = p.supplier_id
WHERE p.is_active = TRUE
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
  AND p.is_active = TRUE
ORDER BY shortage DESC;

-- 2.3  Products completely out of stock
SELECT p.sku, p.product_name, c.category_name,
       COALESCE(s.supplier_name, 'N/A') AS supplier
FROM products p
JOIN categories c ON c.category_id = p.category_id
LEFT JOIN suppliers s ON s.supplier_id = p.supplier_id
WHERE p.current_stock = 0
  AND p.is_active = TRUE;

-- ############################################################################
-- SECTION 3: EXPIRY ALERTS
-- ############################################################################

-- 3.1  Products expiring within 7 days
SELECT p.sku, p.product_name, p.expiry_date,
       DATEDIFF(p.expiry_date, CURDATE()) AS days_left,
       p.current_stock, p.unit
FROM products p
WHERE p.expiry_date IS NOT NULL
  AND p.expiry_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)
  AND p.current_stock > 0
ORDER BY p.expiry_date;

-- 3.2  Products expiring within 30 days (uses view)
SELECT * FROM vw_expiring_soon;

-- 3.3  Already expired products still in stock
SELECT p.sku, p.product_name, p.expiry_date,
       DATEDIFF(CURDATE(), p.expiry_date) AS days_past_expiry,
       p.current_stock, p.unit
FROM products p
WHERE p.expiry_date IS NOT NULL
  AND p.expiry_date < CURDATE()
  AND p.current_stock > 0;

-- ############################################################################
-- SECTION 4: SALES REPORTS
-- ############################################################################

-- 4.1  Today's sales summary
SELECT COUNT(DISTINCT sale_id) AS total_bills,
       SUM(net_amount) AS total_revenue,
       SUM(discount_amount) AS total_discounts,
       ROUND(AVG(net_amount), 2) AS avg_bill_value
FROM sales
WHERE DATE(sale_date) = CURDATE()
  AND status = 'completed';

-- 4.2  Daily sales for last 7 days
SELECT DATE(sale_date) AS sale_day,
       COUNT(*) AS num_bills,
       SUM(net_amount) AS revenue,
       SUM(discount_amount) AS discounts
FROM sales
WHERE sale_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
  AND status = 'completed'
GROUP BY DATE(sale_date)
ORDER BY sale_day DESC;

-- 4.3  Weekly sales for last 4 weeks
SELECT YEARWEEK(sale_date, 1) AS year_week,
       MIN(DATE(sale_date)) AS week_start,
       MAX(DATE(sale_date)) AS week_end,
       COUNT(*) AS num_bills,
       SUM(net_amount) AS revenue
FROM sales
WHERE sale_date >= DATE_SUB(CURDATE(), INTERVAL 4 WEEK)
  AND status = 'completed'
GROUP BY YEARWEEK(sale_date, 1)
ORDER BY year_week DESC;

-- 4.4  Monthly sales for last 6 months
SELECT DATE_FORMAT(sale_date, '%Y-%m') AS month,
       COUNT(*) AS num_bills,
       SUM(net_amount) AS revenue,
       SUM(discount_amount) AS discounts,
       ROUND(AVG(net_amount), 2) AS avg_bill
FROM sales
WHERE sale_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
  AND status = 'completed'
GROUP BY DATE_FORMAT(sale_date, '%Y-%m')
ORDER BY month DESC;

-- 4.5  Sales by payment method
SELECT payment_method,
       COUNT(*) AS num_bills,
       SUM(net_amount) AS total_revenue,
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
       SUM(si.line_total) AS total_revenue,
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
       SUM(si.line_total) AS revenue
FROM sale_items si
JOIN products p ON p.product_id = si.product_id
JOIN sales s ON s.sale_id = si.sale_id
WHERE s.status = 'completed'
  AND DATE_FORMAT(s.sale_date, '%Y-%m') = DATE_FORMAT(CURDATE(), '%Y-%m')
GROUP BY p.product_id, p.sku, p.product_name
ORDER BY qty_sold DESC
LIMIT 10;

-- 5.4  Best-selling categories
SELECT c.category_name,
       SUM(si.quantity) AS total_qty_sold,
       SUM(si.line_total) AS total_revenue,
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
       SUM(si.line_total) AS revenue,
       SUM(si.cost_price * si.quantity) AS cost,
       SUM(si.line_total) - SUM(si.cost_price * si.quantity) AS gross_profit,
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
       SUM(si.line_total) AS revenue,
       SUM(si.cost_price * si.quantity) AS cost,
       SUM(si.line_total) - SUM(si.cost_price * si.quantity) AS daily_profit
FROM sale_items si
JOIN sales s ON s.sale_id = si.sale_id
WHERE s.status = 'completed'
GROUP BY DATE(s.sale_date)
ORDER BY sale_day DESC;

-- 6.3  Overall profit summary
SELECT
    SUM(si.line_total) AS total_revenue,
    SUM(si.cost_price * si.quantity) AS total_cost,
    SUM(si.line_total) - SUM(si.cost_price * si.quantity) AS total_profit,
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
       SUM(pu.net_amount) AS total_spent,
       MAX(pu.purchase_date) AS last_purchase,
       SUM(CASE WHEN pu.payment_status = 'unpaid' THEN pu.net_amount ELSE 0 END)
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
WHERE pu.purchase_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
ORDER BY pu.purchase_date DESC, p.product_name;

-- 7.4  Products supplied by each supplier
SELECT s.supplier_name, p.sku, p.product_name, p.cost_price, p.selling_price
FROM products p
JOIN suppliers s ON s.supplier_id = p.supplier_id
WHERE p.is_active = TRUE
ORDER BY s.supplier_name, p.product_name;

-- ############################################################################
-- SECTION 8: INVENTORY VALUATION
-- ############################################################################

-- 8.1  Full inventory valuation (uses view)
SELECT * FROM vw_inventory_valuation;

-- 8.2  Total inventory value
SELECT
    SUM(current_stock * cost_price) AS total_value_at_cost,
    SUM(current_stock * selling_price) AS total_value_at_selling,
    SUM(current_stock * selling_price) - SUM(current_stock * cost_price)
        AS potential_margin,
    COUNT(*) AS products_in_stock
FROM products
WHERE is_active = TRUE AND current_stock > 0;

-- 8.3  Valuation by category
SELECT c.category_name,
       COUNT(*) AS num_products,
       SUM(p.current_stock * p.cost_price) AS value_at_cost,
       SUM(p.current_stock * p.selling_price) AS value_at_selling
FROM products p
JOIN categories c ON c.category_id = p.category_id
WHERE p.is_active = TRUE AND p.current_stock > 0
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
       ROUND(SUM(si.quantity) / 30, 3) AS avg_daily_demand_30d
FROM sale_items si
JOIN products p ON p.product_id = si.product_id
JOIN sales s ON s.sale_id = si.sale_id
WHERE s.status = 'completed'
  AND s.sale_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY si.product_id, p.product_name, p.sku
ORDER BY avg_daily_demand_30d DESC;

-- 9.3  Historical demand — last 60 days per product
SELECT si.product_id, p.product_name,
       SUM(si.quantity) AS total_qty_sold_60d,
       ROUND(SUM(si.quantity) / 60, 3) AS avg_daily_demand_60d
FROM sale_items si
JOIN products p ON p.product_id = si.product_id
JOIN sales s ON s.sale_id = si.sale_id
WHERE s.status = 'completed'
  AND s.sale_date >= DATE_SUB(CURDATE(), INTERVAL 60 DAY)
GROUP BY si.product_id, p.product_name
ORDER BY avg_daily_demand_60d DESC;

-- 9.4  Historical demand — last 90 days per product
SELECT si.product_id, p.product_name,
       SUM(si.quantity) AS total_qty_sold_90d,
       ROUND(SUM(si.quantity) / 90, 3) AS avg_daily_demand_90d
FROM sale_items si
JOIN products p ON p.product_id = si.product_id
JOIN sales s ON s.sale_id = si.sale_id
WHERE s.status = 'completed'
  AND s.sale_date >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
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
WHERE p.is_active = TRUE
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
WHERE ai.is_active = TRUE
ORDER BY ai.forecast_date DESC, ai.insight_type;

-- ############################################################################
-- SECTION 10: SQL-BASED DEMAND FORECASTING MODULE
-- ############################################################################
-- This section implements demand forecasting using MySQL 8.0+ features:
-- CTEs, window functions, and date arithmetic.
-- These are STATISTICAL estimates, NOT machine learning predictions.

-- ============================================================================
-- 10.1  AVERAGE DAILY DEMAND (7, 30, 90 days)
--        Uses a calendar CTE to include zero-sale days
-- ============================================================================
WITH RECURSIVE date_series AS (
    -- Generate all dates from 90 days ago to today
    SELECT DATE_SUB(CURDATE(), INTERVAL 90 DAY) AS dt
    UNION ALL
    SELECT DATE_ADD(dt, INTERVAL 1 DAY)
    FROM date_series
    WHERE dt < CURDATE()
),
active_products AS (
    SELECT product_id, product_name, sku
    FROM products
    WHERE is_active = TRUE
),
daily_sales AS (
    -- Actual daily sales per product (only completed sales)
    SELECT DATE(s.sale_date) AS sale_day,
           si.product_id,
           SUM(si.quantity) AS qty_sold
    FROM sale_items si
    JOIN sales s ON s.sale_id = si.sale_id
    WHERE s.status = 'completed'
      AND s.sale_date >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
    GROUP BY DATE(s.sale_date), si.product_id
),
product_date_grid AS (
    -- Cross-join products × dates, then LEFT JOIN sales
    -- This ensures days with zero sales are counted as zero (not excluded)
    SELECT ap.product_id, ap.product_name, ap.sku,
           ds.dt AS sale_day,
           COALESCE(dl.qty_sold, 0) AS qty_sold
    FROM active_products ap
    CROSS JOIN date_series ds
    LEFT JOIN daily_sales dl
        ON dl.product_id = ap.product_id AND dl.sale_day = ds.dt
)
SELECT product_id, product_name, sku,
    -- 7-day average
    ROUND(SUM(CASE WHEN sale_day >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
                   THEN qty_sold ELSE 0 END) / 7, 3) AS avg_daily_7d,
    -- 30-day average
    ROUND(SUM(CASE WHEN sale_day >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
                   THEN qty_sold ELSE 0 END) / 30, 3) AS avg_daily_30d,
    -- 90-day average
    ROUND(SUM(qty_sold) / 90, 3) AS avg_daily_90d,
    -- Total sold in each period
    SUM(CASE WHEN sale_day >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
             THEN qty_sold ELSE 0 END) AS total_7d,
    SUM(CASE WHEN sale_day >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
             THEN qty_sold ELSE 0 END) AS total_30d,
    SUM(qty_sold) AS total_90d
FROM product_date_grid
GROUP BY product_id, product_name, sku
HAVING total_90d > 0  -- Exclude products never sold
ORDER BY avg_daily_30d DESC;

-- ============================================================================
-- 10.2  SIMPLE MOVING AVERAGE (7-day and 30-day rolling windows)
--        Uses window functions over the date grid
-- ============================================================================
WITH RECURSIVE date_series AS (
    SELECT DATE_SUB(CURDATE(), INTERVAL 90 DAY) AS dt
    UNION ALL
    SELECT DATE_ADD(dt, INTERVAL 1 DAY) FROM date_series WHERE dt < CURDATE()
),
daily_sales AS (
    SELECT DATE(s.sale_date) AS sale_day,
           si.product_id,
           SUM(si.quantity) AS qty_sold
    FROM sale_items si
    JOIN sales s ON s.sale_id = si.sale_id
    WHERE s.status = 'completed'
      AND s.sale_date >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
    GROUP BY DATE(s.sale_date), si.product_id
),
-- Focus on a specific product for readability (change product_id as needed)
product_daily AS (
    SELECT ds.dt AS sale_day,
           COALESCE(dl.qty_sold, 0) AS qty_sold
    FROM date_series ds
    LEFT JOIN daily_sales dl ON dl.sale_day = ds.dt AND dl.product_id = 1
)
SELECT sale_day,
       qty_sold,
       -- 7-day Simple Moving Average
       ROUND(AVG(qty_sold) OVER (
           ORDER BY sale_day
           ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
       ), 3) AS sma_7d,
       -- 30-day Simple Moving Average
       ROUND(AVG(qty_sold) OVER (
           ORDER BY sale_day
           ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
       ), 3) AS sma_30d
FROM product_daily
-- Show only the last 30 days of results (the early days lack full windows)
WHERE sale_day >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
ORDER BY sale_day;

-- ============================================================================
-- 10.3  TREND DETECTION
--        Compare recent 30-day demand vs previous 30-day demand
--        Flag as 'increasing', 'decreasing', or 'stable'
-- ============================================================================
WITH demand_periods AS (
    SELECT si.product_id,
           p.product_name,
           p.sku,
           -- Recent 30 days
           SUM(CASE
               WHEN DATE(s.sale_date) >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
               THEN si.quantity ELSE 0 END) AS recent_30d_qty,
           -- Previous 30 days (day 31 to day 60 ago)
           SUM(CASE
               WHEN DATE(s.sale_date) >= DATE_SUB(CURDATE(), INTERVAL 60 DAY)
                AND DATE(s.sale_date) < DATE_SUB(CURDATE(), INTERVAL 30 DAY)
               THEN si.quantity ELSE 0 END) AS prev_30d_qty
    FROM sale_items si
    JOIN products p ON p.product_id = si.product_id
    JOIN sales s ON s.sale_id = si.sale_id
    WHERE s.status = 'completed'
      AND s.sale_date >= DATE_SUB(CURDATE(), INTERVAL 60 DAY)
    GROUP BY si.product_id, p.product_name, p.sku
)
SELECT product_id, product_name, sku,
       recent_30d_qty,
       prev_30d_qty,
       -- Percentage change
       CASE
           WHEN prev_30d_qty = 0 AND recent_30d_qty > 0 THEN 100.0
           WHEN prev_30d_qty = 0 AND recent_30d_qty = 0 THEN 0.0
           ELSE ROUND(100.0 * (recent_30d_qty - prev_30d_qty) / prev_30d_qty, 1)
       END AS pct_change,
       -- Trend classification
       CASE
           WHEN prev_30d_qty = 0 AND recent_30d_qty > 0 THEN 'NEW_DEMAND'
           WHEN prev_30d_qty = 0 AND recent_30d_qty = 0 THEN 'NO_SALES'
           WHEN (recent_30d_qty - prev_30d_qty) / prev_30d_qty > 0.15  THEN 'INCREASING'
           WHEN (recent_30d_qty - prev_30d_qty) / prev_30d_qty < -0.15 THEN 'DECREASING'
           ELSE 'STABLE'
       END AS trend
FROM demand_periods
ORDER BY recent_30d_qty DESC;

-- ============================================================================
-- 10.4  7-DAY DEMAND FORECAST
--        Predict next 7 days using 7-day moving average
--        Show current stock and predicted remaining stock
-- ============================================================================
WITH RECURSIVE date_series AS (
    SELECT DATE_SUB(CURDATE(), INTERVAL 30 DAY) AS dt
    UNION ALL
    SELECT DATE_ADD(dt, INTERVAL 1 DAY) FROM date_series WHERE dt < CURDATE()
),
daily_sales AS (
    SELECT DATE(s.sale_date) AS sale_day,
           si.product_id,
           SUM(si.quantity) AS qty_sold
    FROM sale_items si
    JOIN sales s ON s.sale_id = si.sale_id
    WHERE s.status = 'completed'
      AND s.sale_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    GROUP BY DATE(s.sale_date), si.product_id
),
product_avg AS (
    SELECT p.product_id, p.product_name, p.sku,
           p.current_stock, p.min_stock_level, p.unit,
           -- Use 7-day avg: total sold in last 7 days / 7
           COALESCE(
               SUM(CASE WHEN ds.dt >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
                        THEN COALESCE(dl.qty_sold, 0) ELSE 0 END) / 7,
               0
           ) AS avg_daily_7d
    FROM products p
    CROSS JOIN date_series ds
    LEFT JOIN daily_sales dl ON dl.product_id = p.product_id AND dl.sale_day = ds.dt
    WHERE p.is_active = TRUE
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
WHERE avg_daily_7d > 0  -- Only products with recent sales
ORDER BY predicted_stock_after_7d ASC;

-- ============================================================================
-- 10.5  RESTOCK SUGGESTION QUERY
--        Formula: suggested_order = MAX(0,
--            (predicted_7day_demand × safety_factor)
--          + (lead_time_days × avg_daily_demand)
--          - current_stock )
--        safety_factor = 1.25 (25% safety buffer)
-- ============================================================================
WITH RECURSIVE date_series AS (
    SELECT DATE_SUB(CURDATE(), INTERVAL 30 DAY) AS dt
    UNION ALL
    SELECT DATE_ADD(dt, INTERVAL 1 DAY) FROM date_series WHERE dt < CURDATE()
),
daily_sales AS (
    SELECT DATE(s.sale_date) AS sale_day,
           si.product_id,
           SUM(si.quantity) AS qty_sold
    FROM sale_items si
    JOIN sales s ON s.sale_id = si.sale_id
    WHERE s.status = 'completed'
      AND s.sale_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    GROUP BY DATE(s.sale_date), si.product_id
),
product_demand AS (
    SELECT p.product_id, p.product_name, p.sku,
           p.current_stock, p.min_stock_level, p.cost_price, p.unit,
           COALESCE(s.supplier_name, 'N/A') AS supplier_name,
           COALESCE(s.lead_time_days, 3) AS lead_time_days,
           COALESCE(
               SUM(CASE WHEN ds.dt >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
                        THEN COALESCE(dl.qty_sold, 0) ELSE 0 END) / 7,
               0
           ) AS avg_daily_7d
    FROM products p
    LEFT JOIN suppliers s ON s.supplier_id = p.supplier_id
    CROSS JOIN date_series ds
    LEFT JOIN daily_sales dl ON dl.product_id = p.product_id AND dl.sale_day = ds.dt
    WHERE p.is_active = TRUE
    GROUP BY p.product_id, p.product_name, p.sku,
             p.current_stock, p.min_stock_level, p.cost_price, p.unit,
             s.supplier_name, s.lead_time_days
)
SELECT product_id, product_name, sku, unit,
       current_stock,
       ROUND(avg_daily_7d, 3) AS avg_daily_demand,
       lead_time_days,
       supplier_name,
       -- Predicted 7-day demand
       ROUND(avg_daily_7d * 7, 3) AS predicted_7d_demand,
       -- Lead time demand
       ROUND(avg_daily_7d * lead_time_days, 3) AS lead_time_demand,
       -- Suggested order quantity (with 1.25x safety factor)
       GREATEST(0, ROUND(
           (avg_daily_7d * 7 * 1.25)         -- 7-day demand × safety
         + (avg_daily_7d * lead_time_days)    -- lead time coverage
         - current_stock,                      -- minus what we have
       3)) AS suggested_order_qty,
       -- Estimated cost of restock
       ROUND(GREATEST(0,
           (avg_daily_7d * 7 * 1.25)
         + (avg_daily_7d * lead_time_days)
         - current_stock
       ) * cost_price, 2) AS estimated_order_cost
FROM product_demand
WHERE avg_daily_7d > 0
ORDER BY suggested_order_qty DESC;

-- ============================================================================
-- 10.6  INSERT FORECASTS INTO ai_insights TABLE
--        Stores calculated moving-average forecasts for the application
--        and AI team to reference.
-- ============================================================================

-- First, deactivate previous SQL-based forecasts
UPDATE ai_insights
SET is_active = FALSE
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
WITH RECURSIVE date_series AS (
    SELECT DATE_SUB(CURDATE(), INTERVAL 30 DAY) AS dt
    UNION ALL
    SELECT DATE_ADD(dt, INTERVAL 1 DAY) FROM date_series WHERE dt < CURDATE()
),
daily_sales AS (
    SELECT DATE(s.sale_date) AS sale_day,
           si.product_id,
           SUM(si.quantity) AS qty_sold
    FROM sale_items si
    JOIN sales s ON s.sale_id = si.sale_id
    WHERE s.status = 'completed'
      AND s.sale_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    GROUP BY DATE(s.sale_date), si.product_id
),
product_forecast AS (
    SELECT p.product_id,
           p.product_name,
           p.current_stock,
           COALESCE(sup.lead_time_days, 3) AS lead_time_days,
           -- 7-day moving average
           COALESCE(
               SUM(CASE WHEN ds.dt >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
                        THEN COALESCE(dl.qty_sold, 0) ELSE 0 END) / 7,
               0) AS avg_daily_7d,
           -- 30-day moving average
           COALESCE(SUM(COALESCE(dl.qty_sold, 0)) / 30, 0) AS avg_daily_30d,
           -- Days with actual sales (for confidence calculation)
           COUNT(DISTINCT CASE WHEN dl.qty_sold > 0 THEN ds.dt END) AS days_with_sales
    FROM products p
    CROSS JOIN date_series ds
    LEFT JOIN daily_sales dl ON dl.product_id = p.product_id AND dl.sale_day = ds.dt
    LEFT JOIN suppliers sup ON sup.supplier_id = p.supplier_id
    WHERE p.is_active = TRUE
    GROUP BY p.product_id, p.product_name, p.current_stock, sup.lead_time_days
    HAVING avg_daily_7d > 0 OR avg_daily_30d > 0
)
SELECT
    product_id,
    'sql_moving_avg_forecast',
    DATE_ADD(CURDATE(), INTERVAL 7 DAY),                -- forecast for 7 days ahead
    ROUND(avg_daily_7d * 7, 3),                          -- predicted demand
    GREATEST(0, ROUND(
        (avg_daily_7d * 7 * 1.25) + (avg_daily_7d * lead_time_days) - current_stock
    , 3)),                                                -- suggested restock
    -- Confidence: based on data availability (more sales days = higher confidence)
    ROUND(LEAST(1.0, days_with_sales / 20.0), 4),
    'sql_moving_avg_v1',
    JSON_OBJECT(
        'window_7day', 7,
        'window_30day', 30,
        'safety_factor', 1.25,
        'lead_time_days', lead_time_days
    ),
    CONCAT('SQL moving-average forecast. 7-day avg demand: ',
           ROUND(avg_daily_7d, 3), '/day. ',
           '30-day avg demand: ', ROUND(avg_daily_30d, 3), '/day. ',
           'Based on ', days_with_sales, ' days with actual sales out of 30.'),
    DATE_SUB(CURDATE(), INTERVAL 30 DAY),
    CURDATE(),
    TRUE,
    'sql_procedure'
FROM product_forecast;

-- Verify the inserted forecasts
SELECT ai.insight_id, p.sku, p.product_name,
       ai.predicted_demand, ai.suggested_restock_qty,
       ai.confidence_score, ai.explanation
FROM ai_insights ai
JOIN products p ON p.product_id = ai.product_id
WHERE ai.is_active = TRUE
  AND ai.generated_by = 'sql_procedure'
  AND ai.insight_type = 'sql_moving_avg_forecast'
ORDER BY ai.predicted_demand DESC;

-- ============================================================================
-- 10.7  EDGE CASES AND CONSIDERATIONS
-- ============================================================================

-- Products with NO sales history at all (cannot be forecast)
SELECT p.sku, p.product_name, p.current_stock,
       'NO SALES DATA - Cannot forecast' AS note
FROM products p
LEFT JOIN sale_items si ON si.product_id = p.product_id
LEFT JOIN sales s ON s.sale_id = si.sale_id AND s.status = 'completed'
WHERE p.is_active = TRUE
  AND s.sale_id IS NULL;

-- Products with very sparse sales (low confidence forecasts)
WITH product_sales_freq AS (
    SELECT si.product_id,
           p.product_name,
           COUNT(DISTINCT DATE(s.sale_date)) AS days_with_sales,
           MIN(DATE(s.sale_date)) AS first_sale,
           MAX(DATE(s.sale_date)) AS last_sale,
           DATEDIFF(MAX(DATE(s.sale_date)), MIN(DATE(s.sale_date))) + 1 AS span_days
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
WITH RECURSIVE date_series AS (
    SELECT DATE_SUB(CURDATE(), INTERVAL 30 DAY) AS dt
    UNION ALL
    SELECT DATE_ADD(dt, INTERVAL 1 DAY) FROM date_series WHERE dt < CURDATE()
),
daily_sales AS (
    SELECT DATE(s.sale_date) AS sale_day,
           si.product_id,
           SUM(si.quantity) AS qty_sold
    FROM sale_items si
    JOIN sales s ON s.sale_id = si.sale_id
    WHERE s.status = 'completed'
      AND s.sale_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    GROUP BY DATE(s.sale_date), si.product_id
),
restock_calc AS (
    SELECT p.product_id, p.product_name, p.sku, p.unit,
           p.current_stock, p.min_stock_level, p.cost_price,
           COALESCE(s.supplier_name, 'N/A') AS supplier_name,
           COALESCE(s.lead_time_days, 3) AS lead_time_days,
           COALESCE(
               SUM(CASE WHEN ds.dt >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
                        THEN COALESCE(dl.qty_sold, 0) ELSE 0 END) / 7,
               0) AS avg_daily_7d,
           p.expiry_date
    FROM products p
    LEFT JOIN suppliers s ON s.supplier_id = p.supplier_id
    CROSS JOIN date_series ds
    LEFT JOIN daily_sales dl ON dl.product_id = p.product_id AND dl.sale_day = ds.dt
    WHERE p.is_active = TRUE
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
       -- Days of stock remaining
       CASE WHEN avg_daily_7d > 0
            THEN ROUND(current_stock / avg_daily_7d, 1)
            ELSE 9999
       END AS days_of_stock_left,
       -- Suggested order
       GREATEST(0, ROUND(
           (avg_daily_7d * 7 * 1.25)
         + (avg_daily_7d * lead_time_days)
         - current_stock, 3)) AS suggested_order_qty,
       -- Estimated cost
       ROUND(GREATEST(0,
           (avg_daily_7d * 7 * 1.25)
         + (avg_daily_7d * lead_time_days)
         - current_stock) * cost_price, 2) AS estimated_cost,
       -- Priority ranking
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

-- ============================================================================
-- LIMITATIONS OF MOVING AVERAGE FORECASTING
-- ============================================================================
/*
  IMPORTANT — READ THIS SECTION
  ==============================

  The SQL-based forecasting in this module uses Simple Moving Averages (SMA).
  This is a STATISTICAL method, NOT machine learning. Key limitations:

  1. NO SEASONALITY DETECTION
     Moving averages cannot detect weekly, monthly, or festival-season
     patterns. Sales spike during Diwali/Eid will not be predicted.

  2. STOCKOUT BIAS
     If a product was out of stock for 5 days, those 5 days show zero sales.
     The moving average treats this as "no demand" when in reality demand
     existed but could not be fulfilled. This underestimates true demand.

  3. EQUAL WEIGHTING
     A 7-day SMA gives equal weight to each of the 7 days. More recent days
     might be more indicative of current trends. An Exponential Moving
     Average (EMA) or ML model would handle this better.

  4. NO EXTERNAL FACTORS
     Price changes, promotions, weather, nearby competitor opening — none
     of these are considered.

  5. NEW PRODUCTS
     Products with fewer than 7 days of sales history will have unreliable
     7-day averages. The confidence_score reflects this.

  DIFFERENCE FROM LOW-STOCK ALERTS:
  - A low-stock alert simply checks: current_stock < min_stock_level
    This is a static rule-based check.
  - Demand forecasting PREDICTS future demand using historical sales data
    and calculates how much stock WILL be needed, accounting for lead time
    and safety stock.

  The AI team should replace these SQL forecasts with ML models (e.g.,
  ARIMA, Prophet, XGBoost) for better accuracy. The ai_insights table
  supports both via the generated_by column ('sql_procedure' vs 'ml_model').
*/

-- ============================================================================
-- END OF QUERIES
-- ============================================================================
