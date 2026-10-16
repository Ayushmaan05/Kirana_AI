-- ============================================================================
-- AI KIRANA STORE — SAMPLE DATA
-- File       : sample_data.sql
-- Engine     : SQLite 3.35+
-- Description: Populates all 12 tables with realistic grocery data.
--              Includes categories, suppliers, products, users, sales,
--              cash payments, online payments, purchases, sale items,
--              purchase items, inventory movements, and AI insights.
-- Usage      : First run schema.sql, then: sqlite3 kirana_store.db < sample_data.sql
--              OR python database/init_db.py
-- ============================================================================

-- Disable foreign key checks temporarily during bulk loading
PRAGMA foreign_keys = OFF;

-- ============================================================================
-- 1. app_users
-- ============================================================================
INSERT INTO app_users (user_id, username, password_hash, full_name, email, phone, role, is_active) VALUES
(1, 'admin_raj',     '$2b$12$fakehashAdminRaj000000000000000000000000000', 'Raj Sharma',       'raj@kirana.local',     '9876543210', 'admin',          1),
(2, 'mgr_priya',     '$2b$12$fakehashMgrPriya00000000000000000000000000', 'Priya Patel',      'priya@kirana.local',   '9876543211', 'manager',        1),
(3, 'cash_amit',     '$2b$12$fakehashCashAmit00000000000000000000000000', 'Amit Kumar',       'amit@kirana.local',    '9876543212', 'cashier',        1),
(4, 'cash_neha',     '$2b$12$fakehashCashNeha00000000000000000000000000', 'Neha Verma',       'neha@kirana.local',    '9876543213', 'cashier',        1),
(5, 'inv_suresh',    '$2b$12$fakehashInvSuresh000000000000000000000000', 'Suresh Reddy',     'suresh@kirana.local',  '9876543214', 'inventory_clerk', 1);

-- ============================================================================
-- 2. categories
-- ============================================================================
INSERT INTO categories (category_id, category_name, description, is_active) VALUES
(1,  'Dairy',              'Milk, curd, butter, paneer, ghee', 1),
(2,  'Grains & Cereals',   'Rice, wheat, oats, millets',       1),
(3,  'Flour & Atta',       'Wheat flour, besan, maida, sooji', 1),
(4,  'Biscuits & Snacks',  'Biscuits, cookies, namkeen, chips',1),
(5,  'Cooking Oil',        'Mustard oil, sunflower oil, groundnut oil', 1),
(6,  'Sugar & Sweeteners', 'Sugar, jaggery, honey',            1),
(7,  'Tea & Coffee',       'Tea leaves, tea bags, coffee powder', 1),
(8,  'Personal Care',      'Soap, shampoo, toothpaste',        1),
(9,  'Pulses & Lentils',   'Dal varieties — moong, toor, chana, masoor', 1),
(10, 'Spices & Masala',   'Turmeric, chilli, cumin, garam masala', 1);

-- ============================================================================
-- 3. suppliers
-- ============================================================================
INSERT INTO suppliers (supplier_id, supplier_name, contact_person, phone, email, address, city, state, gstin, lead_time_days, is_active) VALUES
(1, 'Mother Dairy Distributors',   'Vikram Singh',   '9811001001', 'vikram@motherdairy.local',   '12, Dairy Marg, Patparganj',    'Delhi',    'Delhi',        '07AABCT1234F1ZP', 1, 1),
(2, 'Dawat Rice Traders',          'Farhan Sheikh',  '9811002002', 'farhan@dawat.local',         '45, Grain Market, Azadpur',     'Delhi',    'Delhi',        '07BBDCR5678G1ZQ', 2, 1),
(3, 'Aashirvaad Flour Agency',     'Mohan Lal',       '9811003003', 'mohan@aashirvaad.local',     'B-78, FMCG Complex, Okhla',     'Delhi',    'Delhi',        '07CCEAF9012H1ZR', 2, 1),
(4, 'Parle & Britannia Wholesale', 'Sunita Agarwal',  '9811004004', 'sunita@biscuitwala.local',   '9, Snack Lane, Karol Bagh',     'Delhi',    'Delhi',        '07DDFPB3456I1ZS', 3, 1),
(5, 'Fortune Oil Depot',           'Ramesh Gupta',    '9811005005', 'ramesh@fortuneoil.local',    '23, Industrial Area, Phase-II', 'Gurgaon',  'Haryana',      '06EEGFO7890J1ZT', 3, 1),
(6, 'Dhampur Sugar Mills',         'Anil Yadav',      '9811006006', 'anil@dhampur.local',         '1, Sugar Mill Road',            'Dhampur',  'Uttar Pradesh','09FFHDS1234K1ZU', 4, 1),
(7, 'Tata Tea & Brooke Bond',      'Kavita Nair',     '9811007007', 'kavita@tatatea.local',       '56, Beverages Park, Munnar Rd', 'Kochi',    'Kerala',       '32GGITT5678L1ZV', 5, 1),
(8, 'Hindustan Unilever Dist.',    'Deepak Mehra',    '9811008008', 'deepak@hul.local',           '7, FMCG Street, Andheri',       'Mumbai',   'Maharashtra',  '27HHJHU9012M1ZW', 3, 1);

-- ============================================================================
-- 4. products — realistic grocery items
-- ============================================================================
INSERT INTO products (product_id, sku, product_name, category_id, supplier_id, brand, unit, cost_price, selling_price, current_stock, min_stock_level, max_stock_level, expiry_date, is_active) VALUES
-- Dairy
( 1, 'DAI-MLK-001', 'Full Cream Milk 1L Pouch',       1, 1, 'Mother Dairy',  'litre',   52.00,   60.00,  120.000,  30.000,  500.000, '2026-10-30', 1),
( 2, 'DAI-MLK-002', 'Toned Milk 500ml Pouch',          1, 1, 'Mother Dairy',  'pouch',   22.00,   27.00,  200.000,  50.000,  600.000, '2026-10-28', 1),
( 3, 'DAI-CRD-001', 'Fresh Curd 400g Cup',             1, 1, 'Mother Dairy',  'cup',     30.00,   40.00,   45.000,  20.000,  200.000, '2026-10-25', 1),

-- Grains & Cereals
( 4, 'GRN-RIC-001', 'Basmati Rice 5kg Pack',           2, 2, 'Dawat',         'pack',   310.00,  375.00,   80.000,  20.000,  200.000, NULL,         1),
( 5, 'GRN-RIC-002', 'Sona Masoori Rice 5kg Pack',      2, 2, 'Dawat',         'pack',   240.00,  290.00,   65.000,  15.000,  200.000, NULL,         1),
( 6, 'GRN-OAT-001', 'Rolled Oats 1kg Pouch',           2, 2, 'Quaker',        'pack',   150.00,  190.00,   30.000,  10.000,  100.000, '2027-06-15', 1),

-- Flour & Atta
( 7, 'FLR-ATT-001', 'Whole Wheat Atta 10kg',           3, 3, 'Aashirvaad',    'bag',    350.00,  420.00,   50.000,  15.000,  150.000, '2027-04-01', 1),
( 8, 'FLR-BES-001', 'Besan (Gram Flour) 1kg',          3, 3, 'Aashirvaad',    'pack',    72.00,   90.00,   60.000,  20.000,  200.000, '2027-03-15', 1),
( 9, 'FLR-MDA-001', 'Maida (Refined Flour) 1kg',       3, 3, 'Aashirvaad',    'pack',    38.00,   48.00,   40.000,  15.000,  200.000, '2027-05-20', 1),

-- Biscuits & Snacks
(10, 'BSC-PRL-001', 'Parle-G Gold Biscuits 1kg',       4, 4, 'Parle',         'pack',    75.00,   95.00,  150.000,  40.000,  400.000, '2027-08-01', 1),
(11, 'BSC-BRT-001', 'Britannia Good Day Butter 250g',  4, 4, 'Britannia',     'pack',    30.00,   40.00,  100.000,  30.000,  300.000, '2027-07-15', 1),
(12, 'BSC-BRT-002', 'Britannia Marie Gold 300g',       4, 4, 'Britannia',     'pack',    28.00,   35.00,  120.000,  35.000,  350.000, '2027-09-01', 1),

-- Cooking Oil
(13, 'OIL-SUN-001', 'Fortune Sunflower Oil 5L Can',    5, 5, 'Fortune',       'can',    620.00,  740.00,   35.000,  10.000,  100.000, '2027-12-01', 1),
(14, 'OIL-MUS-001', 'Fortune Mustard Oil 1L Bottle',   5, 5, 'Fortune',       'bottle', 165.00,  200.00,   50.000,  15.000,  150.000, '2027-10-01', 1),

-- Sugar & Sweeteners
(15, 'SUG-WHT-001', 'White Sugar 5kg Bag',             6, 6, 'Dhampur',       'bag',    195.00,  240.00,   70.000,  20.000,  200.000, NULL,         1),
(16, 'SUG-JAG-001', 'Organic Jaggery 1kg Block',       6, 6, 'Dhampur',       'block',   80.00,  110.00,   25.000,  10.000,  100.000, '2027-06-01', 1),

-- Tea & Coffee
(17, 'TEA-TTA-001', 'Tata Gold Tea 500g Pack',         7, 7, 'Tata Tea',      'pack',   200.00,  260.00,   40.000,  12.000,  120.000, '2027-11-01', 1),
(18, 'TEA-BKB-001', 'Brooke Bond Red Label 250g',      7, 7, 'Brooke Bond',   'pack',    95.00,  125.00,   55.000,  15.000,  150.000, '2027-10-15', 1),
(19, 'TEA-COF-001', 'Nescafe Classic Coffee 200g Jar', 7, 7, 'Nescafe',       'jar',    350.00,  430.00,   20.000,  8.000,   60.000,  '2027-09-01', 1),

-- Personal Care
(20, 'SOP-LUX-001', 'Lux Soft Touch Soap 150g 3-Pack', 8, 8, 'Lux',           'pack',    90.00,  120.00,   80.000,  25.000,  250.000, '2028-06-01', 1),
(21, 'SOP-DVE-001', 'Dove Cream Bar Soap 100g',        8, 8, 'Dove',          'piece',   48.00,   62.00,   60.000,  20.000,  200.000, '2028-05-01', 1),
(22, 'SOP-DET-001', 'Surf Excel Detergent 1kg',        8, 8, 'Surf Excel',    'pack',   120.00,  155.00,   45.000,  15.000,  150.000, '2028-01-01', 1),

-- Pulses
(23, 'PLS-TUR-001', 'Toor Dal 1kg',                    9, 2, 'Dawat',         'pack',   110.00,  140.00,   50.000,  15.000,  200.000, NULL,         1),
(24, 'PLS-MNG-001', 'Moong Dal 1kg',                   9, 2, 'Dawat',         'pack',   120.00,  155.00,   40.000,  12.000,  180.000, NULL,         1),

-- Spices
(25, 'SPC-TRM-001', 'Turmeric Powder 200g',           10, 3, 'MDH',           'pack',    42.00,   58.00,   70.000,  20.000,  250.000, '2027-12-01', 1);

-- ============================================================================
-- 5. sales — sample customer bills over 90+ days
-- ============================================================================
INSERT INTO sales (sale_id, invoice_number, sale_date, customer_name, customer_phone, cashier_id, total_amount, discount_amount, tax_amount, net_amount, payment_method, status) VALUES
-- July 2026
( 1, 'INV-20260718-001', '2026-07-18 10:15:00', 'Anita Devi',       '9999000001', 3,  475.00,   0.00,  0.00,  475.00, 'cash', 'completed'),
( 2, 'INV-20260718-002', '2026-07-18 14:30:00', 'Walk-in Customer',  NULL,        3,  290.00,   0.00,  0.00,  290.00, 'upi',  'completed'),
( 3, 'INV-20260720-001', '2026-07-20 09:00:00', 'Sunil Yadav',      '9999000003', 4, 1150.00,  50.00,  0.00, 1100.00, 'card', 'completed'),
( 4, 'INV-20260722-001', '2026-07-22 11:45:00', 'Meera Joshi',      '9999000004', 3,  680.00,   0.00,  0.00,  680.00, 'cash', 'completed'),
( 5, 'INV-20260725-001', '2026-07-25 16:20:00', 'Walk-in Customer',  NULL,        4,  355.00,   5.00,  0.00,  350.00, 'upi',  'completed'),

-- August 2026
( 6, 'INV-20260801-001', '2026-08-01 10:00:00', 'Ravi Shankar',     '9999000005', 3,  920.00,  20.00,  0.00,  900.00, 'cash', 'completed'),
( 7, 'INV-20260803-001', '2026-08-03 12:30:00', 'Pooja Mishra',     '9999000006', 4,  540.00,   0.00,  0.00,  540.00, 'upi',  'completed'),
( 8, 'INV-20260805-001', '2026-08-05 15:10:00', 'Walk-in Customer',  NULL,        3,  260.00,   0.00,  0.00,  260.00, 'cash', 'completed'),
( 9, 'INV-20260810-001', '2026-08-10 09:30:00', 'Geeta Kumari',     '9999000007', 3, 1475.00,  75.00,  0.00, 1400.00, 'card', 'completed'),
(10, 'INV-20260812-001', '2026-08-12 11:00:00', 'Walk-in Customer',  NULL,        4,  430.00,   0.00,  0.00,  430.00, 'cash', 'completed'),
(11, 'INV-20260815-001', '2026-08-15 10:15:00', 'Dinesh Gupta',     '9999000008', 3,  760.00,  10.00,  0.00,  750.00, 'upi',  'completed'),
(12, 'INV-20260818-001', '2026-08-18 14:00:00', 'Walk-in Customer',  NULL,        4,  395.00,   0.00,  0.00,  395.00, 'cash', 'completed'),
(13, 'INV-20260820-001', '2026-08-20 16:45:00', 'Kavita Sharma',    '9999000009', 3,  680.00,   0.00,  0.00,  680.00, 'cash', 'completed'),
(14, 'INV-20260825-001', '2026-08-25 10:30:00', 'Walk-in Customer',  NULL,        4,  520.00,  20.00,  0.00,  500.00, 'upi',  'completed'),
(15, 'INV-20260828-001', '2026-08-28 13:15:00', 'Manoj Tiwari',     '9999000010', 3,  310.00,   0.00,  0.00,  310.00, 'cash', 'completed'),

-- September 2026
(16, 'INV-20260901-001', '2026-09-01 10:00:00', 'Anita Devi',       '9999000001', 3,  575.00,   0.00,  0.00,  575.00, 'cash', 'completed'),
(17, 'INV-20260903-001', '2026-09-03 11:30:00', 'Walk-in Customer',  NULL,        4,  840.00,  40.00,  0.00,  800.00, 'card', 'completed'),
(18, 'INV-20260905-001', '2026-09-05 14:00:00', 'Ravi Shankar',     '9999000005', 3,  460.00,   0.00,  0.00,  460.00, 'upi',  'completed'),
(19, 'INV-20260908-001', '2026-09-08 09:15:00', 'Walk-in Customer',  NULL,        3,  720.00,  20.00,  0.00,  700.00, 'cash', 'completed'),
(20, 'INV-20260910-001', '2026-09-10 16:30:00', 'Pooja Mishra',     '9999000006', 4,  390.00,   0.00,  0.00,  390.00, 'upi',  'completed'),
(21, 'INV-20260912-001', '2026-09-12 10:45:00', 'Walk-in Customer',  NULL,        3, 1250.00,  50.00,  0.00, 1200.00, 'card', 'completed'),
(22, 'INV-20260915-001', '2026-09-15 12:00:00', 'Sunil Yadav',      '9999000003', 4,  560.00,   0.00,  0.00,  560.00, 'cash', 'completed'),
(23, 'INV-20260918-001', '2026-09-18 15:30:00', 'Walk-in Customer',  NULL,        3,  330.00,   0.00,  0.00,  330.00, 'cash', 'completed'),
(24, 'INV-20260920-001', '2026-09-20 10:00:00', 'Geeta Kumari',     '9999000007', 4,  900.00,  30.00,  0.00,  870.00, 'upi',  'completed'),
(25, 'INV-20260922-001', '2026-09-22 11:30:00', 'Walk-in Customer',  NULL,        3,  440.00,   0.00,  0.00,  440.00, 'cash', 'completed'),
(26, 'INV-20260925-001', '2026-09-25 14:15:00', 'Dinesh Gupta',     '9999000008', 4,  670.00,  10.00,  0.00,  660.00, 'cash', 'completed'),
(27, 'INV-20260928-001', '2026-09-28 16:00:00', 'Walk-in Customer',  NULL,        3,  510.00,   0.00,  0.00,  510.00, 'upi',  'completed'),
(28, 'INV-20260930-001', '2026-09-30 10:30:00', 'Manoj Tiwari',     '9999000010', 4,  780.00,  20.00,  0.00,  760.00, 'card', 'completed'),

-- October 2026
(29, 'INV-20261001-001', '2026-10-01 09:30:00', 'Anita Devi',       '9999000001', 3,  620.00,   0.00,  0.00,  620.00, 'cash', 'completed'),
(30, 'INV-20261002-001', '2026-10-02 11:00:00', 'Walk-in Customer',  NULL,        4,  350.00,   0.00,  0.00,  350.00, 'upi',  'completed'),
(31, 'INV-20261003-001', '2026-10-03 14:30:00', 'Ravi Shankar',     '9999000005', 3,  940.00,  40.00,  0.00,  900.00, 'card', 'completed'),
(32, 'INV-20261005-001', '2026-10-05 10:15:00', 'Walk-in Customer',  NULL,        4,  480.00,   0.00,  0.00,  480.00, 'cash', 'completed'),
(33, 'INV-20261007-001', '2026-10-07 12:45:00', 'Kavita Sharma',    '9999000009', 3,  720.00,  20.00,  0.00,  700.00, 'cash', 'completed'),
(34, 'INV-20261008-001', '2026-10-08 15:00:00', 'Walk-in Customer',  NULL,        4,  560.00,   0.00,  0.00,  560.00, 'upi',  'completed'),
(35, 'INV-20261010-001', '2026-10-10 09:00:00', 'Pooja Mishra',     '9999000006', 3, 1100.00,  50.00,  0.00, 1050.00, 'card', 'completed'),
(36, 'INV-20261012-001', '2026-10-12 11:30:00', 'Walk-in Customer',  NULL,        4,  390.00,   0.00,  0.00,  390.00, 'cash', 'completed'),
(37, 'INV-20261014-001', '2026-10-14 14:00:00', 'Sunil Yadav',      '9999000003', 3,  830.00,  30.00,  0.00,  800.00, 'upi',  'completed'),
(38, 'INV-20261015-001', '2026-10-15 10:00:00', 'Geeta Kumari',     '9999000007', 4,  550.00,   0.00,  0.00,  550.00, 'cash', 'completed'),

-- Cancelled sale for audit/refund testing
(39, 'INV-20261005-002', '2026-10-05 17:00:00', 'Walk-in Customer',  NULL,        3,  260.00,   0.00,  0.00,  260.00, 'cash', 'cancelled');

-- ============================================================================
-- 6. cash_payments — physical cash payments corresponding to cash sales
-- ============================================================================
INSERT INTO cash_payments (cash_payment_id, sale_id, cashier_id, amount_tendered, amount_received, change_returned, denomination_breakdown, payment_status, payment_time, notes) VALUES
( 1,  1, 3,  500.00,  475.00,  25.00, '{"500": 1}',                        'completed', '2026-07-18 10:15:00', 'Exact change returned'),
( 2,  4, 3,  700.00,  680.00,  20.00, '{"500": 1, "200": 1}',               'completed', '2026-07-22 11:45:00', '₹20 coin returned'),
( 3,  6, 3, 1000.00,  900.00, 100.00, '{"500": 2}',                        'completed', '2026-08-01 10:00:00', '₹100 note returned'),
( 4,  8, 3,  300.00,  260.00,  40.00, '{"200": 1, "100": 1}',               'completed', '2026-08-05 15:10:00', 'Two ₹20 notes returned'),
( 5, 10, 4,  500.00,  430.00,  70.00, '{"500": 1}',                        'completed', '2026-08-12 11:00:00', '₹50 + ₹20 returned'),
( 6, 12, 4,  400.00,  395.00,   5.00, '{"200": 2}',                        'completed', '2026-08-18 14:00:00', '₹5 coin returned'),
( 7, 13, 3,  700.00,  680.00,  20.00, '{"500": 1, "100": 2}',               'completed', '2026-08-20 16:45:00', '₹20 note returned'),
( 8, 15, 3,  500.00,  310.00, 190.00, '{"500": 1}',                        'completed', '2026-08-28 13:15:00', '₹100 + ₹50 + two ₹20s returned'),
( 9, 16, 3,  600.00,  575.00,  25.00, '{"500": 1, "100": 1}',               'completed', '2026-09-01 10:00:00', '₹20 + ₹5 returned'),
(10, 19, 3,  700.00,  700.00,   0.00, '{"500": 1, "200": 1}',               'completed', '2026-09-08 09:15:00', 'Exact cash payment'),
(11, 22, 4,  600.00,  560.00,  40.00, '{"500": 1, "100": 1}',               'completed', '2026-09-15 12:00:00', 'Two ₹20 notes returned'),
(12, 23, 3,  350.00,  330.00,  20.00, '{"200": 1, "100": 1, "50": 1}',      'completed', '2026-09-18 15:30:00', '₹20 returned'),
(13, 25, 3,  500.00,  440.00,  60.00, '{"500": 1}',                        'completed', '2026-09-22 11:30:00', '₹50 + ₹10 returned'),
(14, 26, 4,  700.00,  660.00,  40.00, '{"500": 1, "100": 2}',               'completed', '2026-09-25 14:15:00', 'Two ₹20 notes returned'),
(15, 29, 3,  650.00,  620.00,  30.00, '{"500": 1, "100": 1, "50": 1}',      'completed', '2026-10-01 09:30:00', '₹20 + ₹10 returned'),
(16, 32, 4,  500.00,  480.00,  20.00, '{"500": 1}',                        'completed', '2026-10-05 10:15:00', '₹20 returned'),
(17, 33, 3,  700.00,  700.00,   0.00, '{"500": 1, "200": 1}',               'completed', '2026-10-07 12:45:00', 'Exact cash received'),
(18, 36, 4,  400.00,  390.00,  10.00, '{"200": 2}',                        'completed', '2026-10-12 11:30:00', '₹10 note returned'),
(19, 38, 4,  600.00,  550.00,  50.00, '{"500": 1, "100": 1}',               'completed', '2026-10-15 10:00:00', '₹50 note returned'),
(20, 39, 3,  260.00,  260.00,   0.00, '{"200": 1, "50": 1, "10": 1}',       'cancelled', '2026-10-05 17:00:00', 'Sale cancelled, cash refunded at counter');

-- ============================================================================
-- 7. online_payments — digital transactions (UPI & POS cards)
-- ============================================================================
INSERT INTO online_payments (online_payment_id, sale_id, payment_platform, provider, transaction_reference_id, amount, payer_upi_id, payer_phone, payment_status, gateway_fee, settlement_status, terminal_device_id, gateway_response, payment_time, notes) VALUES
( 1,  2, 'upi',      'PhonePe',    'UPI20260718001001',  290.00, 'walkin@ybl',        '9999000011', 'success',  0.00, 'settled', 'QR-COUNTER-1', '{"status":"SUCCESS","rrn":"180720260001"}', '2026-07-18 14:30:00', 'Dynamic UPI QR scanned'),
( 2,  3, 'card_pos', 'Pine Labs',  'POS20260720001002', 1100.00, NULL,                '9999000003', 'success', 16.50, 'settled', 'PL-POS-TERM-01', '{"auth_code":"882190","card_type":"Visa"}', '2026-07-20 09:00:00', 'Contactless chip tap'),
( 3,  5, 'upi',      'Google Pay', 'UPI20260725001003',  350.00, 'walkin@oksbi',      '9999000012', 'success',  0.00, 'settled', 'QR-COUNTER-2', '{"status":"SUCCESS","rrn":"250720260002"}', '2026-07-25 16:20:00', 'GPay Soundbox confirmed'),
( 4,  7, 'upi',      'Paytm',      'UPI20260803001004',  540.00, 'pooja@paytm',       '9999000006', 'success',  0.00, 'settled', 'QR-COUNTER-1', '{"status":"SUCCESS","rrn":"030820260003"}', '2026-08-03 12:30:00', 'Paytm voicebox announcement'),
( 5,  9, 'card_pos', 'HDFC POS',   'POS20260810001005', 1400.00, NULL,                '9999000007', 'success', 21.00, 'settled', 'HDFC-POS-02',    '{"auth_code":"445109","card_type":"Mastercard"}', '2026-08-10 09:30:00', 'Debit card pin verified'),
( 6, 11, 'upi',      'BHIM',       'UPI20260815001006',  750.00, 'dinesh@upi',        '9999000008', 'success',  0.00, 'settled', 'QR-COUNTER-1', '{"status":"SUCCESS","rrn":"150820260004"}', '2026-08-15 10:15:00', 'UPI direct debit'),
( 7, 14, 'upi',      'PhonePe',    'UPI20260825001007',  500.00, 'walkin@ibl',        '9999000013', 'success',  0.00, 'settled', 'QR-COUNTER-2', '{"status":"SUCCESS","rrn":"250820260005"}', '2026-08-25 10:30:00', 'PhonePe QR'),
( 8, 17, 'card_pos', 'Pine Labs',  'POS20260903001008',  800.00, NULL,                '9999000014', 'success', 12.00, 'settled', 'PL-POS-TERM-01', '{"auth_code":"773124","card_type":"RuPay"}', '2026-09-03 11:30:00', 'RuPay credit card tap'),
( 9, 18, 'upi',      'Google Pay', 'UPI20260905001009',  460.00, 'ravi@okhdfcbank',   '9999000005', 'success',  0.00, 'settled', 'QR-COUNTER-1', '{"status":"SUCCESS","rrn":"050920260006"}', '2026-09-05 14:00:00', 'Voice alert triggered'),
(10, 20, 'upi',      'Paytm',      'UPI20260910001010',  390.00, 'pooja@paytm',       '9999000006', 'success',  0.00, 'settled', 'QR-COUNTER-2', '{"status":"SUCCESS","rrn":"100920260007"}', '2026-09-10 16:30:00', 'Paytm QR'),
(11, 21, 'card_pos', 'HDFC POS',   'POS20260912001011', 1200.00, NULL,                '9999000015', 'success', 18.00, 'settled', 'HDFC-POS-02',    '{"auth_code":"112984","card_type":"Visa"}', '2026-09-12 10:45:00', 'Visa credit card swipe'),
(12, 24, 'upi',      'PhonePe',    'UPI20260920001012',  870.00, 'geeta@ybl',         '9999000007', 'success',  0.00, 'settled', 'QR-COUNTER-1', '{"status":"SUCCESS","rrn":"200920260008"}', '2026-09-20 10:00:00', 'Smart speaker confirmation'),
(13, 27, 'upi',      'Google Pay', 'UPI20260928001013',  510.00, 'walkin@okaxis',     '9999000016', 'success',  0.00, 'settled', 'QR-COUNTER-1', '{"status":"SUCCESS","rrn":"280920260009"}', '2026-09-28 16:00:00', 'GPay transaction ID verified'),
(14, 28, 'card_pos', 'Pine Labs',  'POS20260930001014',  760.00, NULL,                '9999000010', 'success', 11.40, 'settled', 'PL-POS-TERM-01', '{"auth_code":"993821","card_type":"Mastercard"}', '2026-09-30 10:30:00', 'Pine Labs slip generated'),
(15, 30, 'upi',      'Paytm',      'UPI20261002001015',  350.00, 'walkin@paytm',      '9999000017', 'success',  0.00, 'settled', 'QR-COUNTER-2', '{"status":"SUCCESS","rrn":"021020260010"}', '2026-10-02 11:00:00', 'Soundbox verified'),
(16, 31, 'card_pos', 'HDFC POS',   'POS20261003001016',  900.00, NULL,                '9999000005', 'success', 13.50, 'settled', 'HDFC-POS-02',    '{"auth_code":"338192","card_type":"RuPay"}', '2026-10-03 14:30:00', 'RuPay debit card PIN entry'),
(17, 34, 'upi',      'PhonePe',    'UPI20261008001017',  560.00, 'walkin@axl',        '9999000018', 'success',  0.00, 'settled', 'QR-COUNTER-1', '{"status":"SUCCESS","rrn":"081020260011"}', '2026-10-08 15:00:00', 'PhonePe instant confirmation'),
(18, 35, 'card_pos', 'Pine Labs',  'POS20261010001018', 1050.00, NULL,                '9999000006', 'success', 15.75, 'settled', 'PL-POS-TERM-01', '{"auth_code":"664819","card_type":"Visa"}', '2026-10-10 09:00:00', 'Visa contactless NFC tap'),
(19, 37, 'upi',      'Google Pay', 'UPI20261014001019',  800.00, 'sunil@oksbi',       '9999000003', 'success',  0.00, 'settled', 'QR-COUNTER-1', '{"status":"SUCCESS","rrn":"141020260012"}', '2026-10-14 14:00:00', 'GPay verified');

-- ============================================================================
-- 8. sale_items — line items for each sale
-- ============================================================================
INSERT INTO sale_items (sale_id, product_id, quantity, unit_price, cost_price, discount, line_total) VALUES
-- Sale 1
( 1,  1, 3.000,  60.00,  52.00,  0.00, 180.00),
( 1,  5, 1.000, 290.00, 240.00,  0.00, 290.00),
( 1, 12, 1.000,   5.00,  28.00,  0.00,   5.00),

-- Sale 2
( 2,  2, 4.000,  27.00,  22.00,  0.00, 108.00),
( 2, 10, 1.000,  95.00,  75.00,  0.00,  95.00),
( 2, 18, 1.000,  87.00,  95.00,  0.00,  87.00),

-- Sale 3
( 3, 13, 1.000, 740.00, 620.00,  0.00, 740.00),
( 3,  7, 1.000, 410.00, 350.00, 50.00, 360.00),

-- Sale 4
( 4, 20, 2.000, 120.00,  90.00,  0.00, 240.00),
( 4, 11, 3.000,  40.00,  30.00,  0.00, 120.00),
( 4,  8, 2.000,  90.00,  72.00,  0.00, 180.00),
( 4, 23, 1.000, 140.00, 110.00,  0.00, 140.00),

-- Sale 5
( 5, 15, 1.000, 240.00, 195.00,  0.00, 240.00),
( 5, 16, 1.000, 115.00,  80.00,  5.00, 110.00),

-- Sale 6
( 6,  4, 1.000, 375.00, 310.00,  0.00, 375.00),
( 6, 23, 2.000, 140.00, 110.00,  0.00, 280.00),
( 6, 25, 1.000,  58.00,  42.00,  0.00,  58.00),
( 6, 14, 1.000, 207.00, 165.00, 20.00, 187.00),

-- Sale 7
( 7, 17, 1.000, 260.00, 200.00,  0.00, 260.00),
( 7, 24, 1.000, 155.00, 120.00,  0.00, 155.00),
( 7, 18, 1.000, 125.00,  95.00,  0.00, 125.00),

-- Sale 8
( 8,  1, 3.000,  60.00,  52.00,  0.00, 180.00),
( 8,  3, 2.000,  40.00,  30.00,  0.00,  80.00),

-- Sale 9
( 9,  4, 1.000, 375.00, 310.00,  0.00, 375.00),
( 9,  7, 1.000, 420.00, 350.00,  0.00, 420.00),
( 9, 13, 1.000, 680.00, 620.00, 75.00, 605.00),

-- Sale 10
(10, 15, 1.000, 240.00, 195.00,  0.00, 240.00),
(10,  6, 1.000, 190.00, 150.00,  0.00, 190.00),

-- Sale 11
(11, 14, 2.000, 200.00, 165.00,  0.00, 400.00),
(11, 17, 1.000, 260.00, 200.00,  0.00, 260.00),
(11, 20, 1.000, 100.00,  90.00, 10.00,  90.00),

-- Sale 12
(12, 10, 3.000,  95.00,  75.00,  0.00, 285.00),
(12, 16, 1.000, 110.00,  80.00,  0.00, 110.00),

-- Sale 13
(13,  7, 1.000, 420.00, 350.00,  0.00, 420.00),
(13, 17, 1.000, 260.00, 200.00,  0.00, 260.00),

-- Sale 14
(14,  5, 1.000, 290.00, 240.00,  0.00, 290.00),
(14, 23, 1.000, 140.00, 110.00,  0.00, 140.00),
(14,  8, 1.000,  90.00,  72.00, 20.00,  70.00),

-- Sale 15
(15,  1, 3.000,  60.00,  52.00,  0.00, 180.00),
(15, 18, 1.000, 125.00,  95.00,  0.00, 125.00),
(15, 12, 1.000,   5.00,  28.00,  0.00,   5.00),

-- Sale 16
(16,  7, 1.000, 420.00, 350.00,  0.00, 420.00),
(16, 24, 1.000, 155.00, 120.00,  0.00, 155.00),

-- Sale 17
(17, 13, 1.000, 740.00, 620.00,  0.00, 740.00),
(17, 20, 1.000, 100.00,  90.00, 40.00,  60.00),

-- Sale 18
(18,  5, 1.000, 290.00, 240.00,  0.00, 290.00),
(18, 17, 1.000, 170.00, 200.00,  0.00, 170.00),

-- Sale 19
(19, 14, 2.000, 200.00, 165.00,  0.00, 400.00),
(19, 15, 1.000, 240.00, 195.00,  0.00, 240.00),
(19,  8, 1.000,  80.00,  72.00, 20.00,  60.00),

-- Sale 20
(20,  1, 4.000,  60.00,  52.00,  0.00, 240.00),
(20,  6, 1.000, 150.00, 150.00,  0.00, 150.00),

-- Sale 21
(21,  4, 2.000, 375.00, 310.00,  0.00, 750.00),
(21,  7, 1.000, 420.00, 350.00,  0.00, 420.00),
(21, 10, 1.000,  80.00,  75.00, 50.00,  30.00),

-- Sale 22
(22, 13, 1.000, 560.00, 620.00,  0.00, 560.00),

-- Sale 23
(23,  2, 5.000,  27.00,  22.00,  0.00, 135.00),
(23, 11, 3.000,  40.00,  30.00,  0.00, 120.00),
(23, 25, 1.000,  75.00,  42.00,  0.00,  75.00),

-- Sale 24
(24, 14, 2.000, 200.00, 165.00,  0.00, 400.00),
(24,  7, 1.000, 420.00, 350.00,  0.00, 420.00),
(24, 20, 1.000,  80.00,  90.00, 30.00,  50.00),

-- Sale 25
(25, 15, 1.000, 240.00, 195.00,  0.00, 240.00),
(25, 14, 1.000, 200.00, 165.00,  0.00, 200.00),

-- Sale 26
(26,  7, 1.000, 420.00, 350.00,  0.00, 420.00),
(26, 15, 1.000, 240.00, 195.00,  0.00, 240.00),
(26, 12, 1.000,  10.00,  28.00, 10.00,   0.00),

-- Sale 27
(27, 17, 1.000, 260.00, 200.00,  0.00, 260.00),
(27, 18, 2.000, 125.00,  95.00,  0.00, 250.00),

-- Sale 28
(28,  4, 1.000, 375.00, 310.00,  0.00, 375.00),
(28, 14, 2.000, 200.00, 165.00,  0.00, 400.00),
(28, 25, 1.000,   5.00,  42.00, 20.00,   0.00),

-- Sale 29
(29,  1, 5.000,  60.00,  52.00,  0.00, 300.00),
(29,  8, 2.000,  90.00,  72.00,  0.00, 180.00),
(29, 23, 1.000, 140.00, 110.00,  0.00, 140.00),

-- Sale 30
(30, 11, 5.000,  40.00,  30.00,  0.00, 200.00),
(30, 24, 1.000, 150.00, 120.00,  0.00, 150.00),

-- Sale 31
(31, 13, 1.000, 740.00, 620.00,  0.00, 740.00),
(31, 14, 1.000, 200.00, 165.00, 40.00, 160.00),

-- Sale 32
(32, 15, 2.000, 240.00, 195.00,  0.00, 480.00),

-- Sale 33
(33,  5, 2.000, 290.00, 240.00,  0.00, 580.00),
(33, 23, 1.000, 140.00, 110.00, 20.00, 120.00),

-- Sale 34
(34,  7, 1.000, 420.00, 350.00,  0.00, 420.00),
(34, 23, 1.000, 140.00, 110.00,  0.00, 140.00),

-- Sale 35
(35,  4, 2.000, 375.00, 310.00,  0.00, 750.00),
(35, 14, 1.000, 200.00, 165.00,  0.00, 200.00),
(35, 24, 1.000, 150.00, 120.00, 50.00, 100.00),

-- Sale 36
(36,  1, 5.000,  60.00,  52.00,  0.00, 300.00),
(36, 12, 2.000,  35.00,  28.00,  0.00,  70.00),
(36, 20, 1.000,  20.00,  90.00,  0.00,  20.00),

-- Sale 37
(37, 13, 1.000, 740.00, 620.00,  0.00, 740.00),
(37, 10, 1.000,  90.00,  75.00, 30.00,  60.00),

-- Sale 38
(38,  5, 1.000, 290.00, 240.00,  0.00, 290.00),
(38, 17, 1.000, 260.00, 200.00,  0.00, 260.00),

-- Sale 39 (Cancelled)
(39, 17, 1.000, 260.00, 200.00,  0.00, 260.00);

-- ============================================================================
-- 9. purchases — supplier purchase orders
-- ============================================================================
INSERT INTO purchases (purchase_id, purchase_number, supplier_id, purchase_date, received_by, total_amount, tax_amount, net_amount, payment_status, status, notes) VALUES
( 1, 'PO-20260715-001', 1, '2026-07-15 08:00:00', 5,  7540.00, 0.00,  7540.00, 'paid',    'received', 'Weekly dairy supply'),
( 2, 'PO-20260716-001', 2, '2026-07-16 11:00:00', 5, 23200.00, 0.00, 23200.00, 'paid',    'received', 'Bulk rice shipment'),
( 3, 'PO-20260717-001', 3, '2026-07-17 10:00:00', 5, 14260.00, 0.00, 14260.00, 'paid',    'received', 'Flour delivery'),
( 4, 'PO-20260720-001', 4, '2026-07-20 14:00:00', 5,  8650.00, 0.00,  8650.00, 'paid',    'received', 'Biscuits wholesale'),
( 5, 'PO-20260722-001', 5, '2026-07-22 09:30:00', 5, 21850.00, 0.00, 21850.00, 'paid',    'received', 'Cooking oil stock'),
( 6, 'PO-20260801-001', 1, '2026-08-01 08:00:00', 5,  7540.00, 0.00,  7540.00, 'paid',    'received', 'Monthly milk restock'),
( 7, 'PO-20260810-001', 6, '2026-08-10 12:00:00', 5, 11750.00, 0.00, 11750.00, 'paid',    'received', 'Sugar from Dhampur'),
( 8, 'PO-20260815-001', 7, '2026-08-15 10:30:00', 5, 12500.00, 0.00, 12500.00, 'paid',    'received', 'Tea and coffee batch'),
( 9, 'PO-20260820-001', 8, '2026-08-20 15:00:00', 5, 11700.00, 0.00, 11700.00, 'paid',    'received', 'Personal care items'),
(10, 'PO-20260901-001', 1, '2026-09-01 08:00:00', 5,  7540.00, 0.00,  7540.00, 'paid',    'received', 'September milk delivery'),
(11, 'PO-20260915-001', 2, '2026-09-15 11:30:00', 5, 18600.00, 0.00, 18600.00, 'paid',    'received', 'Rice & pulses restock'),
(12, 'PO-20261001-001', 1, '2026-10-01 08:00:00', 5,  7540.00, 0.00,  7540.00, 'paid',    'received', 'October milk batch'),
(13, 'PO-20261010-001', 5, '2026-10-10 10:00:00', 5, 14450.00, 0.00, 14450.00, 'partial', 'received', 'Oil stock — partial payment done'),
(14, 'PO-20261014-001', 4, '2026-10-14 14:00:00', 5,  5600.00, 0.00,  5600.00, 'unpaid',  'pending',  'Biscuit order pending delivery');

-- ============================================================================
-- 10. purchase_items — line items for each purchase
-- ============================================================================
INSERT INTO purchase_items (purchase_id, product_id, quantity, unit_cost, line_total, expiry_date) VALUES
-- PO 1: Mother Dairy
( 1,  1,  80.000,  52.00, 4160.00, '2026-07-22'),
( 1,  2, 120.000,  22.00, 2640.00, '2026-07-20'),
( 1,  3,  24.000,  30.00,  720.00, '2026-07-18'),

-- PO 2: Dawat Rice
( 2,  4,  50.000, 310.00, 15500.00, NULL),
( 2,  5,  30.000, 240.00,  7200.00, NULL),

-- PO 3: Aashirvaad
( 3,  7,  30.000, 350.00, 10500.00, '2027-04-01'),
( 3,  8,  30.000,  72.00,  2160.00, '2027-03-15'),
( 3,  9,  40.000,  38.00,  1520.00, '2027-05-20'),

-- PO 4: Parle & Britannia
( 4, 10,  60.000,  75.00,  4500.00, '2027-08-01'),
( 4, 11,  80.000,  30.00,  2400.00, '2027-07-15'),
( 4, 12,  60.000,  28.00,  1680.00, '2027-09-01'),

-- PO 5: Fortune Oil
( 5, 13,  25.000, 620.00, 15500.00, '2027-12-01'),
( 5, 14,  35.000, 165.00,  5775.00, '2027-10-01'),

-- PO 6: Mother Dairy Aug
( 6,  1,  80.000,  52.00,  4160.00, '2026-08-08'),
( 6,  2, 120.000,  22.00,  2640.00, '2026-08-06'),
( 6,  3,  24.000,  30.00,   720.00, '2026-08-04'),

-- PO 7: Dhampur Sugar
( 7, 15,  50.000, 195.00,  9750.00, NULL),
( 7, 16,  25.000,  80.00,  2000.00, '2027-06-01'),

-- PO 8: Tata Tea
( 8, 17,  30.000, 200.00,  6000.00, '2027-11-01'),
( 8, 18,  40.000,  95.00,  3800.00, '2027-10-15'),
( 8, 19,  10.000, 350.00,  3500.00, '2027-09-01'),

-- PO 9: HUL Personal Care
( 9, 20,  50.000,  90.00,  4500.00, '2028-06-01'),
( 9, 21,  50.000,  48.00,  2400.00, '2028-05-01'),
( 9, 22,  40.000, 120.00,  4800.00, '2028-01-01'),

-- PO 10: Mother Dairy Sep
(10,  1,  80.000,  52.00,  4160.00, '2026-09-08'),
(10,  2, 120.000,  22.00,  2640.00, '2026-09-06'),
(10,  3,  24.000,  30.00,   720.00, '2026-09-04'),

-- PO 11: Dawat Rice & Pulses
(11,  4,  30.000, 310.00,  9300.00, NULL),
(11, 23,  40.000, 110.00,  4400.00, NULL),
(11, 24,  40.000, 120.00,  4800.00, NULL),

-- PO 12: Mother Dairy Oct
(12,  1,  80.000,  52.00,  4160.00, '2026-10-08'),
(12,  2, 120.000,  22.00,  2640.00, '2026-10-06'),
(12,  3,  24.000,  30.00,   720.00, '2026-10-04'),

-- PO 13: Fortune Oil Oct
(13, 13,  15.000, 620.00,  9300.00, '2027-12-01'),
(13, 14,  30.000, 165.00,  4950.00, '2027-10-01'),

-- PO 14: Parle pending
(14, 10,  40.000,  75.00,  3000.00, '2027-08-01'),
(14, 11,  50.000,  30.00,  1500.00, '2027-07-15');

-- ============================================================================
-- 11. inventory_movements — stock movements audit trail
-- ============================================================================
INSERT INTO inventory_movements (product_id, movement_type, quantity_change, stock_after, reference_type, reference_id, performed_by, remarks, created_at) VALUES
-- Opening stock
( 1, 'opening_stock', 100.000, 100.000, 'manual', NULL, 1, 'Initial inventory count', '2026-07-01 00:00:00'),
( 2, 'opening_stock', 150.000, 150.000, 'manual', NULL, 1, 'Initial inventory count', '2026-07-01 00:00:00'),
( 3, 'opening_stock',  30.000,  30.000, 'manual', NULL, 1, 'Initial inventory count', '2026-07-01 00:00:00'),
( 4, 'opening_stock',  60.000,  60.000, 'manual', NULL, 1, 'Initial inventory count', '2026-07-01 00:00:00'),
( 5, 'opening_stock',  50.000,  50.000, 'manual', NULL, 1, 'Initial inventory count', '2026-07-01 00:00:00'),
( 7, 'opening_stock',  40.000,  40.000, 'manual', NULL, 1, 'Initial inventory count', '2026-07-01 00:00:00'),
(10, 'opening_stock', 120.000, 120.000, 'manual', NULL, 1, 'Initial inventory count', '2026-07-01 00:00:00'),
(13, 'opening_stock',  25.000,  25.000, 'manual', NULL, 1, 'Initial inventory count', '2026-07-01 00:00:00'),
(15, 'opening_stock',  50.000,  50.000, 'manual', NULL, 1, 'Initial inventory count', '2026-07-01 00:00:00'),
(17, 'opening_stock',  35.000,  35.000, 'manual', NULL, 1, 'Initial inventory count', '2026-07-01 00:00:00'),

-- Purchase additions
( 1, 'purchase',  80.000, 180.000, 'purchase', 1, 5, 'PO-20260715-001 received', '2026-07-15 08:30:00'),
( 2, 'purchase', 120.000, 270.000, 'purchase', 1, 5, 'PO-20260715-001 received', '2026-07-15 08:30:00'),
( 4, 'purchase',  50.000, 110.000, 'purchase', 2, 5, 'PO-20260716-001 received', '2026-07-16 11:30:00'),
( 7, 'purchase',  30.000,  70.000, 'purchase', 3, 5, 'PO-20260717-001 received', '2026-07-17 10:30:00'),

-- Sales deductions
( 1, 'sale', -3.000, 177.000, 'sale', 1, 3, 'Sale INV-20260718-001', '2026-07-18 10:15:00'),
( 5, 'sale', -1.000,  49.000, 'sale', 1, 3, 'Sale INV-20260718-001', '2026-07-18 10:15:00'),
( 2, 'sale', -4.000, 266.000, 'sale', 2, 3, 'Sale INV-20260718-002', '2026-07-18 14:30:00'),
(10, 'sale', -1.000, 119.000, 'sale', 2, 3, 'Sale INV-20260718-002', '2026-07-18 14:30:00'),

-- Damage write-off
( 3, 'damage', -5.000, 25.000, 'manual', NULL, 5, 'Damaged — curd expired before sale', '2026-08-20 09:00:00');

-- ============================================================================
-- 12. ai_insights — sample AI/SQL forecast records
-- ============================================================================
INSERT INTO ai_insights (product_id, insight_type, forecast_date, predicted_demand, suggested_restock_qty, confidence_score, model_version, parameters_used, explanation, data_period_start, data_period_end, is_active, generated_by) VALUES
( 1, 'sql_moving_avg_forecast', '2026-10-22', 4.500, 30.000, 0.6500, 'sql_moving_avg_v1',
  '{"window_7day": 7, "window_30day": 30, "safety_factor": 1.25}',
  'Based on 7-day moving average of daily sales. Full Cream Milk shows steady demand of ~4.5 units/day. Suggested restock accounts for 7-day demand + 25% safety stock.',
  '2026-10-08', '2026-10-15', 1, 'sql_procedure'),

( 4, 'sql_moving_avg_forecast', '2026-10-22', 0.850, 10.000, 0.5500, 'sql_moving_avg_v1',
  '{"window_7day": 7, "window_30day": 30, "safety_factor": 1.25}',
  'Basmati Rice 5kg — 30-day avg demand ~0.85 packs/day. Less frequent purchases but higher volume. Restock suggestion covers 2 weeks.',
  '2026-09-15', '2026-10-15', 1, 'sql_procedure'),

(10, 'sql_moving_avg_forecast', '2026-10-22', 1.200, 15.000, 0.6000, 'sql_moving_avg_v1',
  '{"window_7day": 7, "window_30day": 30, "safety_factor": 1.25}',
  'Parle-G biscuits — consistent demand ~1.2 packs/day across 30-day window. Popular everyday item.',
  '2026-09-15', '2026-10-15', 1, 'sql_procedure'),

(15, 'demand_forecast', '2026-10-22', 0.700, 8.000, 0.5000, 'sql_moving_avg_v1',
  '{"window_30day": 30, "safety_factor": 1.30}',
  'Sugar 5kg — moderate demand ~0.7 bags/day. Seasonal variation possible during festivals.',
  '2026-09-15', '2026-10-15', 1, 'sql_procedure'),

( 3, 'restock_suggestion', '2026-10-16', NULL, 25.000, 0.7000, 'sql_moving_avg_v1',
  '{"current_stock": 45, "min_stock": 20, "lead_time_days": 1}',
  'Fresh Curd stock adequate but nearing expiry (2026-10-25). Suggest ordering 25 units as replacement stock before expiry.',
  '2026-09-15', '2026-10-15', 1, 'sql_procedure'),

(19, 'restock_suggestion', '2026-10-16', NULL, 15.000, 0.6000, 'sql_moving_avg_v1',
  '{"current_stock": 20, "min_stock": 8, "lead_time_days": 5}',
  'Nescafe Coffee — stock at 20 jars with 5-day supplier lead time. Given moderate demand (~0.4/day), restock of 15 jars recommended to maintain 30-day buffer.',
  '2026-09-15', '2026-10-15', 1, 'sql_procedure'),

( 1, 'trend_analysis', '2026-10-15', NULL, NULL, 0.7500, 'sql_moving_avg_v1',
  '{"period_comparison": "30d_vs_60d", "trend_direction": "stable"}',
  'Full Cream Milk demand is stable. 30-day average (4.5/day) closely matches 60-day average (4.3/day). No significant trend detected.',
  '2026-08-15', '2026-10-15', 1, 'sql_procedure'),

(13, 'trend_analysis', '2026-10-15', NULL, NULL, 0.5500, 'sql_moving_avg_v1',
  '{"period_comparison": "30d_vs_60d", "trend_direction": "increasing"}',
  'Sunflower Oil 5L — demand appears slightly increasing. 30-day avg (0.35/day) up from 60-day avg (0.28/day). Small sample size limits confidence.',
  '2026-08-15', '2026-10-15', 1, 'sql_procedure');

-- Re-enable foreign key checks
PRAGMA foreign_keys = ON;

-- ============================================================================
-- VERIFY DATA LOADED CORRECTLY (Run to confirm all 12 tables)
-- ============================================================================
SELECT 'app_users'           AS tbl, COUNT(*) AS row_count FROM app_users
UNION ALL SELECT 'categories',          COUNT(*) FROM categories
UNION ALL SELECT 'suppliers',           COUNT(*) FROM suppliers
UNION ALL SELECT 'products',            COUNT(*) FROM products
UNION ALL SELECT 'sales',               COUNT(*) FROM sales
UNION ALL SELECT 'cash_payments',       COUNT(*) FROM cash_payments
UNION ALL SELECT 'online_payments',     COUNT(*) FROM online_payments
UNION ALL SELECT 'sale_items',          COUNT(*) FROM sale_items
UNION ALL SELECT 'purchases',           COUNT(*) FROM purchases
UNION ALL SELECT 'purchase_items',      COUNT(*) FROM purchase_items
UNION ALL SELECT 'inventory_movements', COUNT(*) FROM inventory_movements
UNION ALL SELECT 'ai_insights',         COUNT(*) FROM ai_insights;

-- ============================================================================
-- END OF SAMPLE DATA
-- ============================================================================
