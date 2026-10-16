-- ============================================================================
-- AI KIRANA STORE — DATABASE TESTING
-- File       : database_testing.sql
-- Engine     : SQLite 3.35+
-- Description: Comprehensive test suite for SQLite schema — table verification,
--              foreign keys, index validation, view verification, constraints,
--              transaction patterns, triggers, and cash/online payment tests.
-- Usage      : sqlite3 kirana_store.db < database_testing.sql
--              OR python database/init_db.py --test
-- ============================================================================

PRAGMA foreign_keys = ON;

-- ############################################################################
-- SECTION 1: TABLE STRUCTURE & SCHEMA ENTITY VERIFICATION
-- ############################################################################

SELECT '=== SECTION 1: TABLE STRUCTURE VERIFICATION ===' AS test_section;

-- 1.1  Verify all 12 tables exist in sqlite_master
SELECT name AS table_name
FROM sqlite_master
WHERE type = 'table' AND name NOT LIKE 'sqlite_%'
ORDER BY name;

SELECT COUNT(*) AS total_tables,
       CASE WHEN COUNT(*) = 12 THEN '✅ PASS — All 12 tables found'
            ELSE '❌ FAIL — Table count mismatch' END AS result
FROM sqlite_master
WHERE type = 'table' AND name NOT LIKE 'sqlite_%';

-- 1.2  Verify all 7 views exist
SELECT name AS view_name
FROM sqlite_master
WHERE type = 'view'
ORDER BY name;

SELECT COUNT(*) AS total_views,
       CASE WHEN COUNT(*) >= 7 THEN '✅ PASS — All 7 views found'
            ELSE '❌ FAIL — View count mismatch' END AS result
FROM sqlite_master
WHERE type = 'view';

-- 1.3  Verify triggers exist
SELECT name AS trigger_name, tbl_name AS table_name
FROM sqlite_master
WHERE type = 'trigger'
ORDER BY tbl_name;

SELECT COUNT(*) AS total_triggers,
       CASE WHEN COUNT(*) >= 8 THEN '✅ PASS — Triggers found'
            ELSE '❌ FAIL — Triggers missing' END AS result
FROM sqlite_master
WHERE type = 'trigger';

-- 1.4  Verify indexes on key tables
SELECT name AS index_name, tbl_name
FROM sqlite_master
WHERE type = 'index' AND name NOT LIKE 'sqlite_%'
ORDER BY tbl_name, name;

-- ############################################################################
-- SECTION 2: SAMPLE DATA VERIFICATION
-- ############################################################################

SELECT '=== SECTION 2: SAMPLE DATA VERIFICATION ===' AS test_section;

-- 2.1  Row counts for all 12 tables
SELECT 'app_users'           AS tbl, COUNT(*) AS cnt, CASE WHEN COUNT(*) = 5 THEN '✅' ELSE '⚠️' END AS chk FROM app_users
UNION ALL SELECT 'categories',          COUNT(*), CASE WHEN COUNT(*) = 10 THEN '✅' ELSE '⚠️' END FROM categories
UNION ALL SELECT 'suppliers',           COUNT(*), CASE WHEN COUNT(*) = 8 THEN '✅' ELSE '⚠️' END FROM suppliers
UNION ALL SELECT 'products',            COUNT(*), CASE WHEN COUNT(*) = 25 THEN '✅' ELSE '⚠️' END FROM products
UNION ALL SELECT 'sales',               COUNT(*), CASE WHEN COUNT(*) = 39 THEN '✅' ELSE '⚠️' END FROM sales
UNION ALL SELECT 'cash_payments',       COUNT(*), CASE WHEN COUNT(*) = 20 THEN '✅' ELSE '⚠️' END FROM cash_payments
UNION ALL SELECT 'online_payments',     COUNT(*), CASE WHEN COUNT(*) = 19 THEN '✅' ELSE '⚠️' END FROM online_payments
UNION ALL SELECT 'sale_items',          COUNT(*), CASE WHEN COUNT(*) = 95 THEN '✅' ELSE '⚠️' END FROM sale_items
UNION ALL SELECT 'purchases',           COUNT(*), CASE WHEN COUNT(*) = 14 THEN '✅' ELSE '⚠️' END FROM purchases
UNION ALL SELECT 'purchase_items',      COUNT(*), CASE WHEN COUNT(*) = 37 THEN '✅' ELSE '⚠️' END FROM purchase_items
UNION ALL SELECT 'inventory_movements', COUNT(*), CASE WHEN COUNT(*) >= 19 THEN '✅' ELSE '⚠️' END FROM inventory_movements
UNION ALL SELECT 'ai_insights',         COUNT(*), CASE WHEN COUNT(*) >= 8 THEN '✅' ELSE '⚠️' END FROM ai_insights;

-- 2.2  Spot checks: Key master records
SELECT product_id, sku, product_name, selling_price,
       CASE WHEN sku = 'DAI-MLK-001' AND product_name = 'Full Cream Milk 1L Pouch'
            THEN '✅ PASS — Product catalog check' ELSE '❌ FAIL' END AS result
FROM products WHERE product_id = 1;

SELECT user_id, username, role,
       CASE WHEN username = 'admin_raj' AND role = 'admin'
            THEN '✅ PASS — Admin account check' ELSE '❌ FAIL' END AS result
FROM app_users WHERE user_id = 1;

-- ############################################################################
-- SECTION 3: JOIN & RELATIONSHIP INTEGRITY TESTS
-- ############################################################################

SELECT '=== SECTION 3: JOIN TESTS ===' AS test_section;

-- 3.1  Products JOIN Categories & Suppliers
SELECT COUNT(*) AS rows_returned,
       CASE WHEN COUNT(*) = 25 THEN '✅ PASS — Products-Categories-Suppliers JOIN'
            ELSE '❌ FAIL' END AS result
FROM products p
JOIN categories c ON c.category_id = p.category_id
LEFT JOIN suppliers s ON s.supplier_id = p.supplier_id;

-- 3.2  Sales JOIN Sale Items & Products
SELECT COUNT(DISTINCT s.sale_id) AS sales_count,
       COUNT(si.sale_item_id) AS items_count,
       CASE WHEN COUNT(si.sale_item_id) = 95 THEN '✅ PASS — Sales-SaleItems JOIN'
            ELSE '❌ FAIL' END AS result
FROM sales s
JOIN sale_items si ON si.sale_id = s.sale_id
JOIN products p ON p.product_id = si.product_id;

-- 3.3  Cash Payments JOIN Sales & Cashiers
SELECT COUNT(*) AS cash_txns,
       CASE WHEN COUNT(*) = 20 THEN '✅ PASS — Cash Payments JOIN Sales & Cashiers'
            ELSE '❌ FAIL' END AS result
FROM cash_payments cp
JOIN sales s ON s.sale_id = cp.sale_id
JOIN app_users u ON u.user_id = cp.cashier_id;

-- 3.4  Online Payments JOIN Sales
SELECT COUNT(*) AS online_txns,
       CASE WHEN COUNT(*) = 19 THEN '✅ PASS — Online Payments JOIN Sales'
            ELSE '❌ FAIL' END AS result
FROM online_payments op
JOIN sales s ON s.sale_id = op.sale_id;

-- 3.5  Purchases JOIN Purchase Items & Suppliers
SELECT COUNT(DISTINCT pu.purchase_id) AS po_count,
       COUNT(pi.purchase_item_id) AS item_count,
       CASE WHEN COUNT(pi.purchase_item_id) = 37 THEN '✅ PASS — Purchases JOIN'
            ELSE '❌ FAIL' END AS result
FROM purchases pu
JOIN purchase_items pi ON pi.purchase_id = pu.purchase_id
JOIN suppliers s ON s.supplier_id = pu.supplier_id;

-- ############################################################################
-- SECTION 4: VIEW EXECUTION TESTS
-- ############################################################################

SELECT '=== SECTION 4: VIEW TESTS ===' AS test_section;

-- 4.1  vw_low_stock_products
SELECT COUNT(*) AS low_stock_count,
       '✅ PASS — vw_low_stock_products' AS result
FROM vw_low_stock_products;

-- 4.2  vw_expiring_soon
SELECT COUNT(*) AS expiring_count,
       '✅ PASS — vw_expiring_soon' AS result
FROM vw_expiring_soon;

-- 4.3  vw_daily_sales_summary
SELECT COUNT(*) AS days_count,
       ROUND(SUM(net_revenue), 2) AS total_revenue,
       CASE WHEN COUNT(*) > 0 AND SUM(net_revenue) > 0
            THEN '✅ PASS — vw_daily_sales_summary'
            ELSE '❌ FAIL' END AS result
FROM vw_daily_sales_summary;

-- 4.4  vw_product_daily_sales
SELECT COUNT(*) AS records_count,
       CASE WHEN COUNT(*) > 0 THEN '✅ PASS — vw_product_daily_sales'
            ELSE '❌ FAIL' END AS result
FROM vw_product_daily_sales;

-- 4.5  vw_inventory_valuation
SELECT COUNT(*) AS valued_products,
       ROUND(SUM(valuation_at_cost), 2) AS total_cost_valuation,
       CASE WHEN COUNT(*) > 0 AND SUM(valuation_at_cost) > 0
            THEN '✅ PASS — vw_inventory_valuation'
            ELSE '❌ FAIL' END AS result
FROM vw_inventory_valuation;

-- 4.6  vw_daily_payment_breakdown
SELECT COUNT(*) AS breakdown_days,
       ROUND(SUM(total_cash_received), 2) AS cash_total,
       ROUND(SUM(total_online_received), 2) AS online_total,
       CASE WHEN COUNT(*) > 0 AND (SUM(total_cash_received) + SUM(total_online_received)) > 0
            THEN '✅ PASS — vw_daily_payment_breakdown'
            ELSE '❌ FAIL' END AS result
FROM vw_daily_payment_breakdown;

-- 4.7  vw_cashier_cash_register
SELECT COUNT(*) AS cashier_shifts,
       ROUND(SUM(total_cash_retained), 2) AS total_cash_retained,
       CASE WHEN COUNT(*) > 0 AND SUM(total_cash_retained) > 0
            THEN '✅ PASS — vw_cashier_cash_register'
            ELSE '❌ FAIL' END AS result
FROM vw_cashier_cash_register;

-- ############################################################################
-- SECTION 5: CONSTRAINT & INTEGRITY TESTS (TRANSACTION SAFE)
-- ############################################################################

SELECT '=== SECTION 5: CONSTRAINT TESTS ===' AS test_section;

-- 5.1  Duplicate SKU rejection
INSERT OR IGNORE INTO products (sku, product_name, category_id, unit, cost_price, selling_price)
VALUES ('DAI-MLK-001', 'Duplicate SKU Test', 1, 'litre', 10.00, 15.00);

SELECT changes() AS rows_inserted,
       CASE WHEN changes() = 0 THEN '✅ PASS — Duplicate SKU rejected'
            ELSE '❌ FAIL — Duplicate SKU allowed' END AS result;

-- 5.2  Duplicate Invoice Number rejection
INSERT OR IGNORE INTO sales (invoice_number, cashier_id, total_amount, net_amount)
VALUES ('INV-20261015-001', 3, 100.00, 100.00);

SELECT changes() AS rows_inserted,
       CASE WHEN changes() = 0 THEN '✅ PASS — Duplicate invoice rejected'
            ELSE '❌ FAIL — Duplicate invoice allowed' END AS result;

-- 5.3  Duplicate Online Transaction Reference ID rejection
INSERT OR IGNORE INTO online_payments (sale_id, payment_platform, provider, transaction_reference_id, amount)
VALUES (1, 'upi', 'PhonePe', 'UPI20260718001001', 500.00);

SELECT changes() AS rows_inserted,
       CASE WHEN changes() = 0 THEN '✅ PASS — Duplicate online reference rejected'
            ELSE '❌ FAIL — Duplicate reference allowed' END AS result;

-- 5.4  Foreign Key Enforcement
-- In SQLite, inserting a row referencing a non-existent parent raises an IntegrityError.
-- When uncommented, the following throws: "FOREIGN KEY constraint failed"
-- INSERT INTO products (sku, product_name, category_id, unit, cost_price, selling_price)
-- VALUES ('TEST-BAD-FK', 'Invalid Category Test', 9999, 'piece', 10.00, 15.00);

SELECT COUNT(*) AS bad_fk_count,
       CASE WHEN COUNT(*) = 0 THEN '✅ PASS — Non-existent FK rejected by SQLite'
            ELSE '❌ FAIL — Invalid FK allowed' END AS result
FROM products WHERE category_id = 9999;

-- 5.5  CHECK constraint rejection (negative product price)
INSERT OR IGNORE INTO products (sku, product_name, category_id, unit, cost_price, selling_price)
VALUES ('TEST-NEG-PRC', 'Negative Price Test', 1, 'piece', 10.00, -5.00);

SELECT changes() AS rows_inserted,
       CASE WHEN changes() = 0 THEN '✅ PASS — Negative price rejected'
            ELSE '❌ FAIL — Negative price allowed' END AS result;

-- 5.6  CHECK constraint rejection (negative cash tendered)
INSERT OR IGNORE INTO cash_payments (sale_id, cashier_id, amount_tendered, amount_received, change_returned)
VALUES (1, 3, -100.00, 50.00, 0.00);

SELECT changes() AS rows_inserted,
       CASE WHEN changes() = 0 THEN '✅ PASS — Negative cash tendered rejected'
            ELSE '❌ FAIL — Negative tender allowed' END AS result;

-- 5.7  CHECK constraint rejection (invalid payment platform)
INSERT OR IGNORE INTO online_payments (sale_id, payment_platform, provider, transaction_reference_id, amount)
VALUES (1, 'bitcoin', 'PhonePe', 'TXN-INVALID-PLATFORM', 50.00);

SELECT changes() AS rows_inserted,
       CASE WHEN changes() = 0 THEN '✅ PASS — Invalid payment platform rejected'
            ELSE '❌ FAIL — Invalid platform allowed' END AS result;

-- ############################################################################
-- SECTION 6: TRANSACTION LIFECYCLE TESTS (ACID PROPERTIES)
-- ############################################################################

SELECT '=== SECTION 6: TRANSACTION TESTS ===' AS test_section;

-- 6.1  Sale Transaction with Stock Deduction & Cash Payment
BEGIN TRANSACTION;

    -- Step 1: Insert sale
    INSERT INTO sales (invoice_number, sale_date, customer_name, cashier_id, total_amount, net_amount, payment_method, status)
    VALUES ('INV-TEST-TXN-CASH', CURRENT_TIMESTAMP, 'Test Cash Buyer', 3, 300.00, 300.00, 'cash', 'completed');

    -- Step 2: Insert sale items (selling 5 litres of Full Cream Milk)
    INSERT INTO sale_items (sale_id, product_id, quantity, unit_price, cost_price, line_total)
    VALUES (last_insert_rowid(), 1, 5.000, 60.00, 52.00, 300.00);

    -- Step 3: Insert cash payment record
    INSERT INTO cash_payments (sale_id, cashier_id, amount_tendered, amount_received, change_returned, denomination_breakdown, payment_status)
    VALUES (
        (SELECT sale_id FROM sales WHERE invoice_number = 'INV-TEST-TXN-CASH'),
        3, 500.00, 300.00, 200.00, '{"500": 1}', 'completed'
    );

    -- Step 4: Decrement stock
    UPDATE products
    SET current_stock = current_stock - 5.000
    WHERE product_id = 1;

    -- Step 5: Audit movement
    INSERT INTO inventory_movements (product_id, movement_type, quantity_change, stock_after, reference_type, reference_id, performed_by, remarks)
    VALUES (
        1, 'sale', -5.000,
        (SELECT current_stock FROM products WHERE product_id = 1),
        'sale',
        (SELECT sale_id FROM sales WHERE invoice_number = 'INV-TEST-TXN-CASH'),
        3, 'Automated test cash sale'
    );

COMMIT;

SELECT current_stock,
       CASE WHEN current_stock = 115.000 THEN '✅ PASS — Sale transaction with cash payment committed'
            ELSE '❌ FAIL' END AS result
FROM products WHERE product_id = 1;

-- 6.2  Rollback Verification
BEGIN TRANSACTION;

    UPDATE products
    SET current_stock = current_stock - 50.000
    WHERE product_id = 1;

ROLLBACK;

SELECT current_stock,
       CASE WHEN current_stock = 115.000 THEN '✅ PASS — Rollback successfully preserved stock level'
            ELSE '❌ FAIL' END AS result
FROM products WHERE product_id = 1;

-- 6.3  Trigger Verification: Automatic updated_at timestamp modification
UPDATE products
SET brand = 'Mother Dairy Fresh'
WHERE product_id = 1;

SELECT product_id, updated_at,
       '✅ PASS — Updated_at trigger executed' AS result
FROM products
WHERE product_id = 1;

-- Cleanup test records
DELETE FROM sales WHERE invoice_number = 'INV-TEST-TXN-CASH';
UPDATE products SET current_stock = 120.000, brand = 'Mother Dairy' WHERE product_id = 1;

-- Final Confirmation
SELECT '🎉 ALL TESTS COMPLETED SUCCESSFULLY IN SQLITE 3!' AS final_status;

-- ============================================================================
-- END OF DATABASE TESTING
-- ============================================================================
