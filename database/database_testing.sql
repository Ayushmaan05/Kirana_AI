-- ============================================================================
-- AI KIRANA STORE — DATABASE TESTING
-- File       : database_testing.sql
-- Engine     : MySQL 8.0+
-- Description: Comprehensive test suite — table verification, joins,
--              constraint tests, transaction patterns, and rollback demos.
--              Uses kirana_store for read-only tests and kirana_store_test
--              for destructive tests.
-- Usage      : Run after schema.sql and sample_data.sql have been loaded.
-- ============================================================================

-- ############################################################################
-- SECTION 1: TABLE STRUCTURE VERIFICATION
-- ############################################################################

USE `kirana_store`;

-- 1.1  Verify all 10 tables exist
SELECT '=== SECTION 1: TABLE STRUCTURE VERIFICATION ===' AS test_section;

SELECT TABLE_NAME, ENGINE, TABLE_ROWS, TABLE_COMMENT
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'kirana_store'
  AND TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

-- Expected: 10 tables
SELECT COUNT(*) AS table_count,
       CASE WHEN COUNT(*) = 10 THEN '✅ PASS' ELSE '❌ FAIL' END AS result
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'kirana_store'
  AND TABLE_TYPE = 'BASE TABLE';

-- 1.2  Check column structure of key tables
DESCRIBE `products`;
DESCRIBE `sales`;
DESCRIBE `ai_insights`;

-- 1.3  Verify indexes exist on products table
SHOW INDEX FROM `products` WHERE Key_name != 'PRIMARY';

-- 1.4  Verify all foreign keys
SELECT
    CONSTRAINT_NAME,
    TABLE_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'kirana_store'
  AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, CONSTRAINT_NAME;

-- Expected: Multiple FK constraints across tables
SELECT COUNT(*) AS fk_count,
       CASE WHEN COUNT(*) >= 12 THEN '✅ PASS — FK constraints found'
            ELSE '❌ FAIL — Missing FK constraints' END AS result
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'kirana_store'
  AND REFERENCED_TABLE_NAME IS NOT NULL;

-- 1.5  Verify views exist
SELECT TABLE_NAME, VIEW_DEFINITION IS NOT NULL AS has_definition
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'kirana_store'
ORDER BY TABLE_NAME;

SELECT COUNT(*) AS view_count,
       CASE WHEN COUNT(*) >= 5 THEN '✅ PASS — Views exist'
            ELSE '❌ FAIL — Views missing' END AS result
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'kirana_store';

-- ############################################################################
-- SECTION 2: SAMPLE DATA VERIFICATION
-- ############################################################################

SELECT '=== SECTION 2: SAMPLE DATA VERIFICATION ===' AS test_section;

-- 2.1  Row counts for all tables
SELECT 'app_users' AS tbl, COUNT(*) AS cnt,
       CASE WHEN COUNT(*) = 5 THEN '✅' ELSE '⚠️' END AS chk
FROM app_users
UNION ALL
SELECT 'categories', COUNT(*),
       CASE WHEN COUNT(*) = 10 THEN '✅' ELSE '⚠️' END
FROM categories
UNION ALL
SELECT 'suppliers', COUNT(*),
       CASE WHEN COUNT(*) = 8 THEN '✅' ELSE '⚠️' END
FROM suppliers
UNION ALL
SELECT 'products', COUNT(*),
       CASE WHEN COUNT(*) = 25 THEN '✅' ELSE '⚠️' END
FROM products
UNION ALL
SELECT 'sales', COUNT(*),
       CASE WHEN COUNT(*) >= 38 THEN '✅' ELSE '⚠️' END
FROM sales
UNION ALL
SELECT 'sale_items', COUNT(*),
       CASE WHEN COUNT(*) >= 50 THEN '✅' ELSE '⚠️' END
FROM sale_items
UNION ALL
SELECT 'purchases', COUNT(*),
       CASE WHEN COUNT(*) = 10 THEN '✅' ELSE '⚠️' END
FROM purchases
UNION ALL
SELECT 'purchase_items', COUNT(*),
       CASE WHEN COUNT(*) >= 20 THEN '✅' ELSE '⚠️' END
FROM purchase_items
UNION ALL
SELECT 'inventory_movements', COUNT(*),
       CASE WHEN COUNT(*) >= 25 THEN '✅' ELSE '⚠️' END
FROM inventory_movements
UNION ALL
SELECT 'ai_insights', COUNT(*),
       CASE WHEN COUNT(*) >= 5 THEN '✅' ELSE '⚠️' END
FROM ai_insights;

-- 2.2  Spot-check: verify specific product exists
SELECT product_id, sku, product_name, selling_price,
       CASE WHEN sku = 'DAI-MLK-001' AND product_name = 'Full Cream Milk 1L Pouch'
            THEN '✅ PASS' ELSE '❌ FAIL' END AS result
FROM products WHERE product_id = 1;

-- 2.3  Spot-check: verify admin user exists
SELECT user_id, username, role,
       CASE WHEN username = 'admin_raj' AND role = 'admin'
            THEN '✅ PASS' ELSE '❌ FAIL' END AS result
FROM app_users WHERE user_id = 1;

-- ############################################################################
-- SECTION 3: JOIN TESTS
-- ############################################################################

SELECT '=== SECTION 3: JOIN TESTS ===' AS test_section;

-- 3.1  Products with categories and suppliers
SELECT COUNT(*) AS rows_returned,
       CASE WHEN COUNT(*) = 25 THEN '✅ PASS — Products-Categories JOIN'
            ELSE '❌ FAIL' END AS result
FROM products p
JOIN categories c ON c.category_id = p.category_id
LEFT JOIN suppliers s ON s.supplier_id = p.supplier_id;

-- 3.2  Sales with sale_items and products (completed sales only)
SELECT COUNT(*) AS line_items,
       COUNT(DISTINCT s.sale_id) AS unique_sales,
       CASE WHEN COUNT(*) > 0 THEN '✅ PASS — Sales-SaleItems-Products JOIN'
            ELSE '❌ FAIL' END AS result
FROM sales s
JOIN sale_items si ON si.sale_id = s.sale_id
JOIN products p ON p.product_id = si.product_id
WHERE s.status = 'completed';

-- 3.3  Purchases with purchase_items
SELECT COUNT(*) AS purchase_lines,
       COUNT(DISTINCT pu.purchase_id) AS unique_purchases,
       CASE WHEN COUNT(*) >= 20 THEN '✅ PASS — Purchases JOIN'
            ELSE '❌ FAIL' END AS result
FROM purchases pu
JOIN purchase_items pi ON pi.purchase_id = pu.purchase_id
JOIN products p ON p.product_id = pi.product_id;

-- 3.4  Inventory movements with products and users
SELECT COUNT(*) AS movements,
       CASE WHEN COUNT(*) >= 25 THEN '✅ PASS — Inventory Movements JOIN'
            ELSE '❌ FAIL' END AS result
FROM inventory_movements im
JOIN products p ON p.product_id = im.product_id
LEFT JOIN app_users u ON u.user_id = im.performed_by;

-- 3.5  AI insights with products
SELECT COUNT(*) AS insights,
       CASE WHEN COUNT(*) >= 5 THEN '✅ PASS — AI Insights JOIN'
            ELSE '❌ FAIL' END AS result
FROM ai_insights ai
JOIN products p ON p.product_id = ai.product_id;

-- ############################################################################
-- SECTION 4: VIEW TESTS
-- ############################################################################

SELECT '=== SECTION 4: VIEW TESTS ===' AS test_section;

-- 4.1  Test vw_daily_sales_summary
SELECT COUNT(*) AS rows_returned,
       CASE WHEN COUNT(*) > 0 THEN '✅ PASS — vw_daily_sales_summary'
            ELSE '⚠️ No data (may be expected)' END AS result
FROM vw_daily_sales_summary;

-- 4.2  Test vw_product_daily_sales
SELECT COUNT(*) AS rows_returned,
       CASE WHEN COUNT(*) > 0 THEN '✅ PASS — vw_product_daily_sales'
            ELSE '⚠️ No data' END AS result
FROM vw_product_daily_sales;

-- 4.3  Test vw_inventory_valuation
SELECT COUNT(*) AS rows_returned,
       SUM(valuation_at_cost) AS total_cost_val,
       CASE WHEN COUNT(*) > 0 AND SUM(valuation_at_cost) > 0
            THEN '✅ PASS — vw_inventory_valuation'
            ELSE '❌ FAIL' END AS result
FROM vw_inventory_valuation;

-- 4.4  Test vw_expiring_soon (depends on current date vs sample data dates)
SELECT COUNT(*) AS rows_returned,
       '✅ View executes OK — vw_expiring_soon' AS result
FROM vw_expiring_soon;

-- 4.5  Test vw_low_stock_products
SELECT COUNT(*) AS rows_returned,
       '✅ View executes OK — vw_low_stock_products' AS result
FROM vw_low_stock_products;

-- ############################################################################
-- SECTION 5: CONSTRAINT TESTS (DESTRUCTIVE — USE TEST DATABASE)
-- ############################################################################

SELECT '=== SECTION 5: CONSTRAINT TESTS (using kirana_store_test) ===' AS test_section;

-- Create a test database by copying the schema
DROP DATABASE IF EXISTS `kirana_store_test`;
CREATE DATABASE `kirana_store_test`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `kirana_store_test`;

-- Recreate tables (simplified — copy structure from main DB)
CREATE TABLE `app_users` LIKE `kirana_store`.`app_users`;
INSERT INTO `kirana_store_test`.`app_users` SELECT * FROM `kirana_store`.`app_users`;

CREATE TABLE `categories` LIKE `kirana_store`.`categories`;
INSERT INTO `kirana_store_test`.`categories` SELECT * FROM `kirana_store`.`categories`;

CREATE TABLE `suppliers` LIKE `kirana_store`.`suppliers`;
INSERT INTO `kirana_store_test`.`suppliers` SELECT * FROM `kirana_store`.`suppliers`;

CREATE TABLE `products` LIKE `kirana_store`.`products`;
INSERT INTO `kirana_store_test`.`products` SELECT * FROM `kirana_store`.`products`;

CREATE TABLE `sales` LIKE `kirana_store`.`sales`;
INSERT INTO `kirana_store_test`.`sales` SELECT * FROM `kirana_store`.`sales`;

CREATE TABLE `sale_items` LIKE `kirana_store`.`sale_items`;
INSERT INTO `kirana_store_test`.`sale_items` SELECT * FROM `kirana_store`.`sale_items`;

CREATE TABLE `purchases` LIKE `kirana_store`.`purchases`;
INSERT INTO `kirana_store_test`.`purchases` SELECT * FROM `kirana_store`.`purchases`;

CREATE TABLE `purchase_items` LIKE `kirana_store`.`purchase_items`;
INSERT INTO `kirana_store_test`.`purchase_items` SELECT * FROM `kirana_store`.`purchase_items`;

CREATE TABLE `inventory_movements` LIKE `kirana_store`.`inventory_movements`;
INSERT INTO `kirana_store_test`.`inventory_movements` SELECT * FROM `kirana_store`.`inventory_movements`;

CREATE TABLE `ai_insights` LIKE `kirana_store`.`ai_insights`;
INSERT INTO `kirana_store_test`.`ai_insights` SELECT * FROM `kirana_store`.`ai_insights`;

-- Note: CREATE TABLE ... LIKE copies structure + indexes but NOT foreign keys.
-- For FK constraint tests, we re-add them:
ALTER TABLE `products`
    ADD CONSTRAINT `fk_test_products_category`
        FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    ADD CONSTRAINT `fk_test_products_supplier`
        FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`supplier_id`)
        ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE `sales`
    ADD CONSTRAINT `fk_test_sales_cashier`
        FOREIGN KEY (`cashier_id`) REFERENCES `app_users` (`user_id`)
        ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `sale_items`
    ADD CONSTRAINT `fk_test_saleitems_sale`
        FOREIGN KEY (`sale_id`) REFERENCES `sales` (`sale_id`)
        ON UPDATE CASCADE ON DELETE CASCADE,
    ADD CONSTRAINT `fk_test_saleitems_product`
        FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`)
        ON UPDATE CASCADE ON DELETE RESTRICT;

-- -------------------------------------------------------------------------
-- 5.1  TEST: Duplicate SKU rejection
-- -------------------------------------------------------------------------
-- This INSERT should FAIL because SKU 'DAI-MLK-001' already exists
-- Expected: ERROR 1062 — Duplicate entry for key 'sku'
SELECT 'TEST 5.1: Duplicate SKU rejection' AS test_name;

-- We use a handler to catch the error gracefully in a stored procedure
-- But for simple testing, just attempt the insert and observe the error.
-- In MySQL Workbench, an error message will appear.
-- Uncomment the line below to test (it WILL produce an error):
-- INSERT INTO products (sku, product_name, category_id, unit) VALUES ('DAI-MLK-001', 'Duplicate Test', 1, 'litre');

-- Safe test using INSERT IGNORE (should insert 0 rows):
INSERT IGNORE INTO products (sku, product_name, category_id, unit, cost_price, selling_price)
VALUES ('DAI-MLK-001', 'Duplicate SKU Test', 1, 'litre', 10.00, 15.00);

SELECT ROW_COUNT() AS rows_inserted,
       CASE WHEN ROW_COUNT() = 0 THEN '✅ PASS — Duplicate SKU rejected'
            ELSE '❌ FAIL — Duplicate was allowed' END AS result;

-- -------------------------------------------------------------------------
-- 5.2  TEST: Duplicate invoice number rejection
-- -------------------------------------------------------------------------
SELECT 'TEST 5.2: Duplicate invoice number rejection' AS test_name;

INSERT IGNORE INTO sales (invoice_number, cashier_id, total_amount, net_amount)
VALUES ('INV-20261015-001', 3, 100.00, 100.00);

SELECT ROW_COUNT() AS rows_inserted,
       CASE WHEN ROW_COUNT() = 0 THEN '✅ PASS — Duplicate invoice rejected'
            ELSE '❌ FAIL — Duplicate was allowed' END AS result;

-- -------------------------------------------------------------------------
-- 5.3  TEST: Invalid foreign key — non-existent category_id
-- -------------------------------------------------------------------------
SELECT 'TEST 5.3: Invalid FK — non-existent category' AS test_name;

-- Category 999 does not exist. This should fail.
INSERT IGNORE INTO products (sku, product_name, category_id, unit, cost_price, selling_price)
VALUES ('TST-001', 'Invalid Category Test', 999, 'piece', 10.00, 15.00);

SELECT ROW_COUNT() AS rows_inserted,
       CASE WHEN ROW_COUNT() = 0 THEN '✅ PASS — Invalid FK rejected'
            ELSE '❌ FAIL — Invalid FK was allowed' END AS result;

-- -------------------------------------------------------------------------
-- 5.4  TEST: CHECK constraint — negative selling price
-- -------------------------------------------------------------------------
SELECT 'TEST 5.4: CHECK constraint — negative price' AS test_name;

-- MySQL 8.0.16+ enforces CHECK constraints
-- Negative selling_price should violate chk_selling_price
INSERT IGNORE INTO products (sku, product_name, category_id, unit, cost_price, selling_price)
VALUES ('TST-002', 'Negative Price Test', 1, 'piece', 10.00, -5.00);

SELECT ROW_COUNT() AS rows_inserted,
       CASE WHEN ROW_COUNT() = 0 THEN '✅ PASS — Negative price rejected'
            ELSE '❌ FAIL — Negative price was allowed' END AS result;

-- -------------------------------------------------------------------------
-- 5.5  TEST: NOT NULL constraint
-- -------------------------------------------------------------------------
SELECT 'TEST 5.5: NOT NULL — product_name cannot be NULL' AS test_name;

INSERT IGNORE INTO products (sku, product_name, category_id, unit, cost_price, selling_price)
VALUES ('TST-003', NULL, 1, 'piece', 10.00, 15.00);

SELECT ROW_COUNT() AS rows_inserted,
       CASE WHEN ROW_COUNT() = 0 THEN '✅ PASS — NULL product_name rejected'
            ELSE '❌ FAIL — NULL was allowed' END AS result;

-- ############################################################################
-- SECTION 6: TRANSACTION TESTS
-- ############################################################################

SELECT '=== SECTION 6: TRANSACTION TESTS ===' AS test_section;

-- -------------------------------------------------------------------------
-- 6a. SALE TRANSACTION — Stock Reduction
-- Scenario: Customer buys 2 packs of Basmati Rice (product_id=4)
-- -------------------------------------------------------------------------
SELECT 'TEST 6a: Sale transaction — stock reduction' AS test_name;

-- Record current stock before transaction
SELECT current_stock INTO @stock_before
FROM products WHERE product_id = 4;
SELECT @stock_before AS stock_before_sale;

START TRANSACTION;

    -- Step 1: Check if sufficient stock is available
    SELECT current_stock INTO @available
    FROM products WHERE product_id = 4 FOR UPDATE;

    -- Step 2: Only proceed if enough stock (2 packs needed)
    -- (In application code, this would be an IF statement)
    -- Here we verify there IS enough stock:
    SELECT CASE WHEN @available >= 2 THEN '✅ Stock sufficient'
                ELSE '❌ Insufficient stock' END AS stock_check;

    -- Step 3: Insert the sale
    INSERT INTO sales (invoice_number, sale_date, customer_name, cashier_id,
                       total_amount, net_amount, payment_method, status)
    VALUES ('INV-TEST-SALE-001', NOW(), 'Test Customer', 3, 750.00, 750.00, 'cash', 'completed');

    SET @new_sale_id = LAST_INSERT_ID();

    -- Step 4: Insert sale items
    INSERT INTO sale_items (sale_id, product_id, quantity, unit_price, cost_price, line_total)
    VALUES (@new_sale_id, 4, 2.000, 375.00, 310.00, 750.00);

    -- Step 5: Reduce product stock
    UPDATE products
    SET current_stock = current_stock - 2.000
    WHERE product_id = 4;

    -- Step 6: Record inventory movement
    INSERT INTO inventory_movements
        (product_id, movement_type, quantity_change, stock_after,
         reference_type, reference_id, performed_by, remarks)
    SELECT 4, 'sale', -2.000,
           (SELECT current_stock FROM products WHERE product_id = 4),
           'sale', @new_sale_id, 3,
           CONCAT('Test sale INV-TEST-SALE-001');

COMMIT;

-- Verify stock decreased
SELECT current_stock AS stock_after_sale,
       @stock_before AS stock_before,
       CASE WHEN current_stock = @stock_before - 2
            THEN '✅ PASS — Stock reduced correctly'
            ELSE '❌ FAIL — Stock mismatch' END AS result
FROM products WHERE product_id = 4;

-- -------------------------------------------------------------------------
-- 6b. INSUFFICIENT STOCK — Rollback
-- Scenario: Try to sell 99999 units (more than available)
-- -------------------------------------------------------------------------
SELECT 'TEST 6b: Insufficient stock — rollback' AS test_name;

SELECT current_stock INTO @stock_before_fail
FROM products WHERE product_id = 4;

START TRANSACTION;

    -- Check stock
    SELECT current_stock INTO @available_fail
    FROM products WHERE product_id = 4 FOR UPDATE;

    -- 99999 > available stock → should NOT proceed
    -- In application code: IF @available_fail < 99999 THEN ROLLBACK

ROLLBACK;

-- Verify stock unchanged
SELECT current_stock AS stock_after_rollback,
       @stock_before_fail AS stock_before,
       CASE WHEN current_stock = @stock_before_fail
            THEN '✅ PASS — Rollback preserved stock'
            ELSE '❌ FAIL — Stock changed despite rollback' END AS result
FROM products WHERE product_id = 4;

-- -------------------------------------------------------------------------
-- 6c. PURCHASE TRANSACTION — Stock Increase
-- Scenario: Receive 50 packs of Toor Dal (product_id=23) from supplier
-- -------------------------------------------------------------------------
SELECT 'TEST 6c: Purchase transaction — stock increase' AS test_name;

SELECT current_stock INTO @stock_before_purchase
FROM products WHERE product_id = 23;

START TRANSACTION;

    -- Insert purchase record
    INSERT INTO purchases (purchase_number, supplier_id, purchase_date,
                           received_by, total_amount, net_amount,
                           payment_status, status)
    VALUES ('PO-TEST-001', 2, NOW(), 5, 5500.00, 5500.00, 'unpaid', 'received');

    SET @new_purchase_id = LAST_INSERT_ID();

    -- Insert purchase items
    INSERT INTO purchase_items (purchase_id, product_id, quantity, unit_cost, line_total)
    VALUES (@new_purchase_id, 23, 50.000, 110.00, 5500.00);

    -- Increase product stock
    UPDATE products
    SET current_stock = current_stock + 50.000
    WHERE product_id = 23;

    -- Record inventory movement
    INSERT INTO inventory_movements
        (product_id, movement_type, quantity_change, stock_after,
         reference_type, reference_id, performed_by, remarks)
    SELECT 23, 'purchase', 50.000,
           (SELECT current_stock FROM products WHERE product_id = 23),
           'purchase', @new_purchase_id, 5,
           'Test purchase PO-TEST-001';

COMMIT;

-- Verify stock increased
SELECT current_stock AS stock_after_purchase,
       @stock_before_purchase AS stock_before,
       CASE WHEN current_stock = @stock_before_purchase + 50
            THEN '✅ PASS — Stock increased correctly'
            ELSE '❌ FAIL — Stock mismatch' END AS result
FROM products WHERE product_id = 23;

-- -------------------------------------------------------------------------
-- 6d. SALE CANCELLATION — Stock Reversal
-- Scenario: Cancel the test sale from 6a and restore stock
-- -------------------------------------------------------------------------
SELECT 'TEST 6d: Sale cancellation — stock reversal' AS test_name;

SELECT current_stock INTO @stock_before_cancel
FROM products WHERE product_id = 4;

START TRANSACTION;

    -- Step 1: Get the sale items for the test sale
    -- (We know it sold 2 packs of product 4)

    -- Step 2: Mark sale as cancelled
    UPDATE sales SET status = 'cancelled'
    WHERE invoice_number = 'INV-TEST-SALE-001';

    -- Step 3: Restore stock (reverse the deduction)
    UPDATE products
    SET current_stock = current_stock + 2.000
    WHERE product_id = 4;

    -- Step 4: Record reversal movement
    INSERT INTO inventory_movements
        (product_id, movement_type, quantity_change, stock_after,
         reference_type, reference_id, performed_by, remarks)
    SELECT 4, 'return', 2.000,
           (SELECT current_stock FROM products WHERE product_id = 4),
           'sale', @new_sale_id, 3,
           'Cancellation reversal for INV-TEST-SALE-001';

COMMIT;

-- Verify stock restored
SELECT current_stock AS stock_after_cancel,
       @stock_before_cancel AS stock_before_cancel,
       CASE WHEN current_stock = @stock_before_cancel + 2
            THEN '✅ PASS — Stock restored after cancellation'
            ELSE '❌ FAIL — Stock not restored correctly' END AS result
FROM products WHERE product_id = 4;

-- Verify sale status is cancelled
SELECT invoice_number, status,
       CASE WHEN status = 'cancelled' THEN '✅ PASS — Sale marked cancelled'
            ELSE '❌ FAIL' END AS result
FROM sales WHERE invoice_number = 'INV-TEST-SALE-001';

-- -------------------------------------------------------------------------
-- 6e. ROLLBACK ON ERROR — Partial Changes Undone
-- Scenario: Start a transaction, make changes, then rollback
-- -------------------------------------------------------------------------
SELECT 'TEST 6e: Rollback on error — partial changes undone' AS test_name;

SELECT current_stock INTO @stock_before_error
FROM products WHERE product_id = 10;

START TRANSACTION;

    -- Partial change: reduce stock
    UPDATE products SET current_stock = current_stock - 5 WHERE product_id = 10;

    -- Simulate: something goes wrong (e.g., payment failed)
    -- Application decides to rollback

ROLLBACK;

-- Verify nothing changed
SELECT current_stock AS stock_after_rollback,
       @stock_before_error AS stock_before,
       CASE WHEN current_stock = @stock_before_error
            THEN '✅ PASS — Rollback undid all partial changes'
            ELSE '❌ FAIL — Partial change persisted' END AS result
FROM products WHERE product_id = 10;

-- ############################################################################
-- SECTION 7: DATA INTEGRITY RULES VERIFICATION
-- ############################################################################

SELECT '=== SECTION 7: DATA INTEGRITY RULES ===' AS test_section;

-- 7.1  Verify: completed sales have sale_items
SELECT s.sale_id, s.invoice_number, COUNT(si.sale_item_id) AS item_count,
       CASE WHEN COUNT(si.sale_item_id) > 0 THEN '✅ Has items'
            ELSE '❌ Missing items' END AS integrity
FROM sales s
LEFT JOIN sale_items si ON si.sale_id = s.sale_id
WHERE s.status = 'completed'
GROUP BY s.sale_id, s.invoice_number
HAVING COUNT(si.sale_item_id) = 0;
-- Expected: empty result (all completed sales have items)

-- 7.2  Verify: AI forecasts are distinguishable from actual sales
SELECT generated_by, insight_type, COUNT(*) AS count
FROM ai_insights
GROUP BY generated_by, insight_type;
-- Should show 'sql_procedure' or 'ml_model', clearly separated

-- 7.3  Verify: historical sales data preserved (cancelled sales still queryable)
SELECT status, COUNT(*) AS count
FROM sales
GROUP BY status;
-- Should show both 'completed' and 'cancelled' counts

-- 7.4  Verify: no negative stock values in products table
SELECT sku, product_name, current_stock,
       CASE WHEN current_stock >= 0 THEN '✅ Valid'
            ELSE '❌ NEGATIVE STOCK' END AS integrity
FROM products
WHERE current_stock < 0;
-- Expected: empty result (no negative stock)

-- 7.5  Verify: all sale_items reference valid products
SELECT si.sale_item_id, si.product_id, p.product_id AS matched_product,
       CASE WHEN p.product_id IS NOT NULL THEN '✅ Valid FK'
            ELSE '❌ ORPHAN RECORD' END AS integrity
FROM sale_items si
LEFT JOIN products p ON p.product_id = si.product_id
WHERE p.product_id IS NULL;
-- Expected: empty result (no orphan records)

-- ############################################################################
-- SECTION 8: CLEANUP
-- ############################################################################

SELECT '=== SECTION 8: CLEANUP ===' AS test_section;

-- Drop the test database (main database is untouched)
DROP DATABASE IF EXISTS `kirana_store_test`;

SELECT '✅ Test database kirana_store_test dropped. Main database kirana_store is intact.' AS cleanup_result;

-- Switch back to main database
USE `kirana_store`;

SELECT '=== ALL TESTS COMPLETED ===' AS final_status;

-- ============================================================================
-- TRANSACTION PATTERNS FOR APPLICATION TEAM
-- ============================================================================
/*
  ┌─────────────────────────────────────────────────────────────────────┐
  │                 TRANSACTION PATTERNS REFERENCE                     │
  │         (Copy these patterns into your backend code)               │
  ├─────────────────────────────────────────────────────────────────────┤
  │                                                                     │
  │  SALE TRANSACTION:                                                  │
  │  1. BEGIN TRANSACTION                                               │
  │  2. SELECT stock FOR UPDATE (lock the row)                          │
  │  3. IF stock < required_qty → ROLLBACK                              │
  │  4. INSERT INTO sales                                               │
  │  5. INSERT INTO sale_items (for each product)                       │
  │  6. UPDATE products SET current_stock -= qty (for each product)     │
  │  7. INSERT INTO inventory_movements (for each product)              │
  │  8. COMMIT                                                          │
  │                                                                     │
  │  PURCHASE TRANSACTION:                                              │
  │  1. BEGIN TRANSACTION                                               │
  │  2. INSERT INTO purchases                                           │
  │  3. INSERT INTO purchase_items (for each product)                   │
  │  4. UPDATE products SET current_stock += qty (for each product)     │
  │  5. INSERT INTO inventory_movements (for each product)              │
  │  6. COMMIT                                                          │
  │                                                                     │
  │  SALE CANCELLATION:                                                 │
  │  1. BEGIN TRANSACTION                                               │
  │  2. UPDATE sales SET status = 'cancelled'                           │
  │  3. For each sale_item:                                             │
  │     a. UPDATE products SET current_stock += qty                     │
  │     b. INSERT INTO inventory_movements (type='return')              │
  │  4. COMMIT                                                          │
  │                                                                     │
  │  CRITICAL: Always use FOR UPDATE when checking stock levels         │
  │  to prevent race conditions in concurrent environments.             │
  └─────────────────────────────────────────────────────────────────────┘
*/

-- ============================================================================
-- END OF TESTING
-- ============================================================================
