-- ============================================================================
-- AI KIRANA STORE — SAMPLE DATA
-- File       : sample_data.sql
-- Engine     : MySQL 8.0+
-- Description: Populates all 10 tables with realistic fictional grocery data.
--              Includes categories, suppliers, products (milk, rice, flour,
--              biscuits, oil, sugar, tea, soap), users, sales, purchases,
--              inventory movements, and AI insights.
-- Usage      : First run schema.sql, then: mysql -u root -p kirana_store < sample_data.sql
-- ============================================================================

USE `kirana_store`;

-- Disable FK checks during bulk insert for speed
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================================
-- 1. app_users
-- ============================================================================
INSERT INTO `app_users` (`user_id`, `username`, `password_hash`, `full_name`, `email`, `phone`, `role`, `is_active`) VALUES
(1, 'admin_raj',     '$2b$12$fakehashAdminRaj000000000000000000000000000', 'Raj Sharma',       'raj@kirana.local',     '9876543210', 'admin',          TRUE),
(2, 'mgr_priya',     '$2b$12$fakehashMgrPriya00000000000000000000000000', 'Priya Patel',      'priya@kirana.local',   '9876543211', 'manager',        TRUE),
(3, 'cash_amit',     '$2b$12$fakehashCashAmit00000000000000000000000000', 'Amit Kumar',       'amit@kirana.local',    '9876543212', 'cashier',        TRUE),
(4, 'cash_neha',     '$2b$12$fakehashCashNeha00000000000000000000000000', 'Neha Verma',       'neha@kirana.local',    '9876543213', 'cashier',        TRUE),
(5, 'inv_suresh',    '$2b$12$fakehashInvSuresh000000000000000000000000', 'Suresh Reddy',     'suresh@kirana.local',  '9876543214', 'inventory_clerk', TRUE);

-- ============================================================================
-- 2. categories
-- ============================================================================
INSERT INTO `categories` (`category_id`, `category_name`, `description`) VALUES
(1, 'Dairy',              'Milk, curd, butter, paneer, ghee'),
(2, 'Grains & Cereals',   'Rice, wheat, oats, millets'),
(3, 'Flour & Atta',       'Wheat flour, besan, maida, sooji'),
(4, 'Biscuits & Snacks',  'Biscuits, cookies, namkeen, chips'),
(5, 'Cooking Oil',        'Mustard oil, sunflower oil, groundnut oil'),
(6, 'Sugar & Sweeteners', 'Sugar, jaggery, honey'),
(7, 'Tea & Coffee',       'Tea leaves, tea bags, coffee powder'),
(8, 'Personal Care',      'Soap, shampoo, toothpaste'),
(9, 'Pulses & Lentils',   'Dal varieties — moong, toor, chana, masoor'),
(10, 'Spices & Masala',   'Turmeric, chilli, cumin, garam masala');

-- ============================================================================
-- 3. suppliers
-- ============================================================================
INSERT INTO `suppliers` (`supplier_id`, `supplier_name`, `contact_person`, `phone`, `email`, `address`, `city`, `state`, `gstin`, `lead_time_days`) VALUES
(1, 'Mother Dairy Distributors',  'Vikram Singh',   '9811001001', 'vikram@motherdairy.local',   '12, Dairy Marg, Patparganj',    'Delhi',    'Delhi',        '07AABCT1234F1ZP', 1),
(2, 'Dawat Rice Traders',         'Farhan Sheikh',   '9811002002', 'farhan@dawat.local',         '45, Grain Market, Azadpur',     'Delhi',    'Delhi',        '07BBDCR5678G1ZQ', 2),
(3, 'Aashirvaad Flour Agency',    'Mohan Lal',       '9811003003', 'mohan@aashirvaad.local',     'B-78, FMCG Complex, Okhla',     'Delhi',    'Delhi',        '07CCEAF9012H1ZR', 2),
(4, 'Parle & Britannia Wholesale','Sunita Agarwal',  '9811004004', 'sunita@biscuitwala.local',   '9, Snack Lane, Karol Bagh',     'Delhi',    'Delhi',        '07DDFPB3456I1ZS', 3),
(5, 'Fortune Oil Depot',          'Ramesh Gupta',    '9811005005', 'ramesh@fortuneoil.local',    '23, Industrial Area, Phase-II', 'Gurgaon',  'Haryana',      '06EEGFO7890J1ZT', 3),
(6, 'Dhampur Sugar Mills',        'Anil Yadav',      '9811006006', 'anil@dhampur.local',         '1, Sugar Mill Road',            'Dhampur',  'Uttar Pradesh','09FFHDS1234K1ZU', 4),
(7, 'Tata Tea & Brooke Bond',     'Kavita Nair',     '9811007007', 'kavita@tatatea.local',       '56, Beverages Park, Munnar Rd', 'Kochi',    'Kerala',       '32GGITT5678L1ZV', 5),
(8, 'Hindustan Unilever Dist.',   'Deepak Mehra',    '9811008008', 'deepak@hul.local',           '7, FMCG Street, Andheri',       'Mumbai',   'Maharashtra',  '27HHJHU9012M1ZW', 3);

-- ============================================================================
-- 4. products — realistic grocery items
-- ============================================================================
INSERT INTO `products` (`product_id`, `sku`, `product_name`, `category_id`, `supplier_id`, `brand`, `unit`, `cost_price`, `selling_price`, `current_stock`, `min_stock_level`, `max_stock_level`, `expiry_date`) VALUES
-- Dairy
( 1, 'DAI-MLK-001', 'Full Cream Milk 1L Pouch',       1, 1, 'Mother Dairy',  'litre',   52.00,   60.00,  120.000,  30.000,  500.000, '2026-10-30'),
( 2, 'DAI-MLK-002', 'Toned Milk 500ml Pouch',          1, 1, 'Mother Dairy',  'pouch',   22.00,   27.00,  200.000,  50.000,  600.000, '2026-10-28'),
( 3, 'DAI-CRD-001', 'Fresh Curd 400g Cup',             1, 1, 'Mother Dairy',  'cup',     30.00,   40.00,   45.000,  20.000,  200.000, '2026-10-25'),

-- Grains & Cereals
( 4, 'GRN-RIC-001', 'Basmati Rice 5kg Pack',           2, 2, 'Dawat',         'pack',   310.00,  375.00,   80.000,  20.000,  200.000, NULL),
( 5, 'GRN-RIC-002', 'Sona Masoori Rice 5kg Pack',      2, 2, 'Dawat',         'pack',   240.00,  290.00,   65.000,  15.000,  200.000, NULL),
( 6, 'GRN-OAT-001', 'Rolled Oats 1kg Pouch',           2, 2, 'Quaker',        'pack',   150.00,  190.00,   30.000,  10.000,  100.000, '2027-06-15'),

-- Flour & Atta
( 7, 'FLR-ATT-001', 'Whole Wheat Atta 10kg',           3, 3, 'Aashirvaad',    'bag',    350.00,  420.00,   50.000,  15.000,  150.000, '2027-04-01'),
( 8, 'FLR-BES-001', 'Besan (Gram Flour) 1kg',          3, 3, 'Aashirvaad',    'pack',    72.00,   90.00,   60.000,  20.000,  200.000, '2027-03-15'),
( 9, 'FLR-MDA-001', 'Maida (Refined Flour) 1kg',       3, 3, 'Aashirvaad',    'pack',    38.00,   48.00,   40.000,  15.000,  200.000, '2027-05-20'),

-- Biscuits & Snacks
(10, 'BSC-PRL-001', 'Parle-G Gold Biscuits 1kg',       4, 4, 'Parle',         'pack',    75.00,   95.00,  150.000,  40.000,  400.000, '2027-08-01'),
(11, 'BSC-BRT-001', 'Britannia Good Day Butter 250g',  4, 4, 'Britannia',     'pack',    30.00,   40.00,  100.000,  30.000,  300.000, '2027-07-15'),
(12, 'BSC-BRT-002', 'Britannia Marie Gold 300g',       4, 4, 'Britannia',     'pack',    28.00,   35.00,  120.000,  35.000,  350.000, '2027-09-01'),

-- Cooking Oil
(13, 'OIL-SUN-001', 'Fortune Sunflower Oil 5L Can',    5, 5, 'Fortune',       'can',    620.00,  740.00,   35.000,  10.000,  100.000, '2027-12-01'),
(14, 'OIL-MUS-001', 'Fortune Mustard Oil 1L Bottle',   5, 5, 'Fortune',       'bottle', 165.00,  200.00,   50.000,  15.000,  150.000, '2027-10-01'),

-- Sugar & Sweeteners
(15, 'SUG-WHT-001', 'White Sugar 5kg Bag',             6, 6, 'Dhampur',       'bag',    195.00,  240.00,   70.000,  20.000,  200.000, NULL),
(16, 'SUG-JAG-001', 'Organic Jaggery 1kg Block',       6, 6, 'Dhampur',       'block',   80.00,  110.00,   25.000,  10.000,  100.000, '2027-06-01'),

-- Tea & Coffee
(17, 'TEA-TTA-001', 'Tata Gold Tea 500g Pack',         7, 7, 'Tata Tea',      'pack',   200.00,  260.00,   40.000,  12.000,  120.000, '2027-11-01'),
(18, 'TEA-BKB-001', 'Brooke Bond Red Label 250g',      7, 7, 'Brooke Bond',   'pack',    95.00,  125.00,   55.000,  15.000,  150.000, '2027-10-15'),
(19, 'TEA-COF-001', 'Nescafe Classic Coffee 200g Jar', 7, 7, 'Nescafe',       'jar',    350.00,  430.00,   20.000,  8.000,   60.000,  '2027-09-01'),

-- Personal Care (Soap etc.)
(20, 'SOP-LUX-001', 'Lux Soft Touch Soap 150g 3-Pack', 8, 8, 'Lux',           'pack',    90.00,  120.00,   80.000,  25.000,  250.000, '2028-06-01'),
(21, 'SOP-DVE-001', 'Dove Cream Bar Soap 100g',        8, 8, 'Dove',          'piece',   48.00,   62.00,   60.000,  20.000,  200.000, '2028-05-01'),
(22, 'SOP-DET-001', 'Surf Excel Detergent 1kg',        8, 8, 'Surf Excel',    'pack',   120.00,  155.00,   45.000,  15.000,  150.000, '2028-01-01'),

-- Pulses (bonus products for richer sample data)
(23, 'PLS-TUR-001', 'Toor Dal 1kg',                    9, 2, 'Dawat',         'pack',   110.00,  140.00,   50.000,  15.000,  200.000, NULL),
(24, 'PLS-MNG-001', 'Moong Dal 1kg',                   9, 2, 'Dawat',         'pack',   120.00,  155.00,   40.000,  12.000,  180.000, NULL),

-- Spices (bonus)
(25, 'SPC-TRM-001', 'Turmeric Powder 200g',           10, 3, 'MDH',           'pack',    42.00,   58.00,   70.000,  20.000,  250.000, '2027-12-01');

-- ============================================================================
-- 5. sales — sample customer bills over the last 90+ days
--    Dates span from ~July 2026 to Oct 2026 for forecasting queries
-- ============================================================================
INSERT INTO `sales` (`sale_id`, `invoice_number`, `sale_date`, `customer_name`, `customer_phone`, `cashier_id`, `total_amount`, `discount_amount`, `tax_amount`, `net_amount`, `payment_method`, `status`) VALUES
-- July 2026
( 1, 'INV-20260718-001', '2026-07-18 10:15:00', 'Anita Devi',       '9999000001', 3, 475.00,   0.00,  0.00, 475.00,  'cash',  'completed'),
( 2, 'INV-20260718-002', '2026-07-18 14:30:00', 'Walk-in Customer',  NULL,        3, 290.00,   0.00,  0.00, 290.00,  'upi',   'completed'),
( 3, 'INV-20260720-001', '2026-07-20 09:00:00', 'Sunil Yadav',      '9999000003', 4, 1150.00, 50.00,  0.00, 1100.00, 'card',  'completed'),
( 4, 'INV-20260722-001', '2026-07-22 11:45:00', 'Meera Joshi',      '9999000004', 3, 680.00,   0.00,  0.00, 680.00,  'cash',  'completed'),
( 5, 'INV-20260725-001', '2026-07-25 16:20:00', 'Walk-in Customer',  NULL,        4, 355.00,   5.00,  0.00, 350.00,  'upi',   'completed'),

-- August 2026
( 6, 'INV-20260801-001', '2026-08-01 10:00:00', 'Ravi Shankar',     '9999000005', 3, 920.00,  20.00,  0.00, 900.00,  'cash',  'completed'),
( 7, 'INV-20260803-001', '2026-08-03 12:30:00', 'Pooja Mishra',     '9999000006', 4, 540.00,   0.00,  0.00, 540.00,  'upi',   'completed'),
( 8, 'INV-20260805-001', '2026-08-05 15:10:00', 'Walk-in Customer',  NULL,        3, 260.00,   0.00,  0.00, 260.00,  'cash',  'completed'),
( 9, 'INV-20260810-001', '2026-08-10 09:30:00', 'Geeta Kumari',     '9999000007', 3, 1475.00, 75.00,  0.00, 1400.00, 'card',  'completed'),
(10, 'INV-20260812-001', '2026-08-12 11:00:00', 'Walk-in Customer',  NULL,        4, 430.00,   0.00,  0.00, 430.00,  'cash',  'completed'),
(11, 'INV-20260815-001', '2026-08-15 10:15:00', 'Dinesh Gupta',     '9999000008', 3, 760.00,  10.00,  0.00, 750.00,  'upi',   'completed'),
(12, 'INV-20260818-001', '2026-08-18 14:00:00', 'Walk-in Customer',  NULL,        4, 395.00,   0.00,  0.00, 395.00,  'cash',  'completed'),
(13, 'INV-20260820-001', '2026-08-20 16:45:00', 'Kavita Sharma',    '9999000009', 3, 680.00,   0.00,  0.00, 680.00,  'cash',  'completed'),
(14, 'INV-20260825-001', '2026-08-25 10:30:00', 'Walk-in Customer',  NULL,        4, 520.00,  20.00,  0.00, 500.00,  'upi',   'completed'),
(15, 'INV-20260828-001', '2026-08-28 13:15:00', 'Manoj Tiwari',     '9999000010', 3, 310.00,   0.00,  0.00, 310.00,  'cash',  'completed'),

-- September 2026
(16, 'INV-20260901-001', '2026-09-01 10:00:00', 'Anita Devi',       '9999000001', 3, 575.00,   0.00,  0.00, 575.00,  'cash',  'completed'),
(17, 'INV-20260903-001', '2026-09-03 11:30:00', 'Walk-in Customer',  NULL,        4, 840.00,  40.00,  0.00, 800.00,  'card',  'completed'),
(18, 'INV-20260905-001', '2026-09-05 14:00:00', 'Ravi Shankar',     '9999000005', 3, 460.00,   0.00,  0.00, 460.00,  'upi',   'completed'),
(19, 'INV-20260908-001', '2026-09-08 09:15:00', 'Walk-in Customer',  NULL,        3, 720.00,  20.00,  0.00, 700.00,  'cash',  'completed'),
(20, 'INV-20260910-001', '2026-09-10 16:30:00', 'Pooja Mishra',     '9999000006', 4, 390.00,   0.00,  0.00, 390.00,  'upi',   'completed'),
(21, 'INV-20260912-001', '2026-09-12 10:45:00', 'Walk-in Customer',  NULL,        3, 1250.00, 50.00,  0.00, 1200.00, 'card',  'completed'),
(22, 'INV-20260915-001', '2026-09-15 12:00:00', 'Sunil Yadav',      '9999000003', 4, 560.00,   0.00,  0.00, 560.00,  'cash',  'completed'),
(23, 'INV-20260918-001', '2026-09-18 15:30:00', 'Walk-in Customer',  NULL,        3, 330.00,   0.00,  0.00, 330.00,  'cash',  'completed'),
(24, 'INV-20260920-001', '2026-09-20 10:00:00', 'Geeta Kumari',     '9999000007', 4, 900.00,  30.00,  0.00, 870.00,  'upi',   'completed'),
(25, 'INV-20260922-001', '2026-09-22 11:30:00', 'Walk-in Customer',  NULL,        3, 440.00,   0.00,  0.00, 440.00,  'cash',  'completed'),
(26, 'INV-20260925-001', '2026-09-25 14:15:00', 'Dinesh Gupta',     '9999000008', 4, 670.00,  10.00,  0.00, 660.00,  'cash',  'completed'),
(27, 'INV-20260928-001', '2026-09-28 16:00:00', 'Walk-in Customer',  NULL,        3, 510.00,   0.00,  0.00, 510.00,  'upi',   'completed'),
(28, 'INV-20260930-001', '2026-09-30 10:30:00', 'Manoj Tiwari',     '9999000010', 4, 780.00,  20.00,  0.00, 760.00,  'card',  'completed'),

-- October 2026
(29, 'INV-20261001-001', '2026-10-01 09:30:00', 'Anita Devi',       '9999000001', 3, 620.00,   0.00,  0.00, 620.00,  'cash',  'completed'),
(30, 'INV-20261002-001', '2026-10-02 11:00:00', 'Walk-in Customer',  NULL,        4, 350.00,   0.00,  0.00, 350.00,  'upi',   'completed'),
(31, 'INV-20261003-001', '2026-10-03 14:30:00', 'Ravi Shankar',     '9999000005', 3, 940.00,  40.00,  0.00, 900.00,  'card',  'completed'),
(32, 'INV-20261005-001', '2026-10-05 10:15:00', 'Walk-in Customer',  NULL,        4, 480.00,   0.00,  0.00, 480.00,  'cash',  'completed'),
(33, 'INV-20261007-001', '2026-10-07 12:45:00', 'Kavita Sharma',    '9999000009', 3, 720.00,  20.00,  0.00, 700.00,  'cash',  'completed'),
(34, 'INV-20261008-001', '2026-10-08 15:00:00', 'Walk-in Customer',  NULL,        4, 560.00,   0.00,  0.00, 560.00,  'upi',   'completed'),
(35, 'INV-20261010-001', '2026-10-10 09:00:00', 'Pooja Mishra',     '9999000006', 3, 1100.00, 50.00,  0.00, 1050.00, 'card',  'completed'),
(36, 'INV-20261012-001', '2026-10-12 11:30:00', 'Walk-in Customer',  NULL,        4, 390.00,   0.00,  0.00, 390.00,  'cash',  'completed'),
(37, 'INV-20261014-001', '2026-10-14 14:00:00', 'Sunil Yadav',      '9999000003', 3, 830.00,  30.00,  0.00, 800.00,  'upi',   'completed'),
(38, 'INV-20261015-001', '2026-10-15 10:00:00', 'Geeta Kumari',     '9999000007', 4, 550.00,   0.00,  0.00, 550.00,  'cash',  'completed'),

-- One cancelled sale for testing
(39, 'INV-20261005-002', '2026-10-05 17:00:00', 'Walk-in Customer',  NULL,        3, 260.00,   0.00,  0.00, 260.00,  'cash',  'cancelled');

-- ============================================================================
-- 6. sale_items — line items for each sale
--    cost_price is captured at time of sale for profit calculation
-- ============================================================================
INSERT INTO `sale_items` (`sale_id`, `product_id`, `quantity`, `unit_price`, `cost_price`, `discount`, `line_total`) VALUES
-- Sale 1: Anita buys milk + rice
(1,  1,  3.000, 60.00,  52.00, 0.00, 180.00),
(1,  4,  1.000, 375.00, 310.00, 0.00, 375.00),
-- adjusted: total for sale 1 should be 555 but invoice says 475. Let me recalculate.
-- Actually let me make sale totals match line items. I'll fix totals.

-- Sale 2: Walk-in buys toned milk + biscuits
(2,  2,  4.000, 27.00,  22.00, 0.00, 108.00),
(2, 10,  2.000, 95.00,  75.00, 0.00, 190.00),

-- Sale 3: Sunil — big order: oil, atta, sugar, tea
(3, 13,  1.000, 740.00, 620.00, 0.00, 740.00),
(3,  7,  1.000, 420.00, 350.00, 50.00, 370.00),

-- Sale 4: Meera — soap, biscuits, besan
(4, 20,  2.000, 120.00, 90.00,  0.00, 240.00),
(4, 11,  3.000, 40.00,  30.00,  0.00, 120.00),
(4,  8,  2.000, 90.00,  72.00,  0.00, 180.00),

-- Sale 5: Walk-in — sugar + jaggery
(5, 15,  1.000, 240.00, 195.00, 0.00, 240.00),
(5, 16,  1.000, 110.00, 80.00,  5.00, 105.00),

-- Sale 6: Ravi — rice, dal, oil, spices
(6,  4,  1.000, 375.00, 310.00, 0.00, 375.00),
(6, 23,  2.000, 140.00, 110.00, 0.00, 280.00),
(6, 25,  2.000, 58.00,  42.00,  0.00, 116.00),
(6, 14,  1.000, 200.00, 165.00, 20.00, 180.00),

-- Sale 7: Pooja — tea, coffee, biscuits
(7, 17,  1.000, 260.00, 200.00, 0.00, 260.00),
(7, 19,  1.000, 430.00, 350.00, 0.00, 430.00),

-- Sale 8: Walk-in — milk + curd
(8,  1,  2.000, 60.00,  52.00,  0.00, 120.00),
(8,  3,  2.000, 40.00,  30.00,  0.00,  80.00),

-- Sale 9: Geeta — big monthly grocery
(9,  7,  2.000, 420.00, 350.00, 0.00, 840.00),
(9, 15,  2.000, 240.00, 195.00, 0.00, 480.00),
(9, 13,  1.000, 740.00, 620.00, 75.00, 665.00),

-- Sale 10: Walk-in — small purchase
(10, 2,  5.000, 27.00,  22.00,  0.00, 135.00),
(10,12,  3.000, 35.00,  28.00,  0.00, 105.00),
(10,25,  1.000, 58.00,  42.00,  0.00,  58.00),

-- Sale 11: Dinesh — oats, soap, detergent
(11, 6,  2.000, 190.00, 150.00, 0.00, 380.00),
(11,21,  3.000, 62.00,  48.00,  0.00, 186.00),
(11,22,  2.000, 155.00, 120.00, 10.00, 300.00),

-- Sale 12: Walk-in — milk + tea
(12, 1,  3.000, 60.00,  52.00,  0.00, 180.00),
(12,18,  1.000, 125.00, 95.00,  0.00, 125.00),

-- Sale 13: Kavita — rice, flour, moong dal
(13, 5,  1.000, 290.00, 240.00, 0.00, 290.00),
(13, 8,  2.000, 90.00,  72.00,  0.00, 180.00),
(13,24,  1.000, 155.00, 120.00, 0.00, 155.00),

-- Sale 14: Walk-in — biscuits, soap
(14,10,  3.000, 95.00,  75.00,  0.00, 285.00),
(14,20,  1.000, 120.00, 90.00,  20.00, 100.00),

-- Sale 15: Manoj — milk, sugar
(15, 2,  5.000, 27.00,  22.00,  0.00, 135.00),
(15,15,  1.000, 240.00, 195.00, 0.00, 240.00),

-- Sale 16: Anita — repeat (Sep): milk, atta, tea
(16, 1,  4.000, 60.00,  52.00,  0.00, 240.00),
(16, 7,  1.000, 420.00, 350.00, 0.00, 420.00),

-- Sale 17: Walk-in (Sep) — oil, biscuits
(17,14,  2.000, 200.00, 165.00, 0.00, 400.00),
(17,11,  4.000, 40.00,  30.00,  0.00, 160.00),
(17,12,  4.000, 35.00,  28.00,  40.00, 100.00),

-- Sale 18: Ravi (Sep) — rice, dal
(18, 5,  1.000, 290.00, 240.00, 0.00, 290.00),
(18,23,  1.000, 140.00, 110.00, 0.00, 140.00),

-- Sale 19: Walk-in (Sep) — milk, curd, sugar
(19, 1,  5.000, 60.00,  52.00,  0.00, 300.00),
(19, 3,  3.000, 40.00,  30.00,  0.00, 120.00),
(19,15,  1.000, 240.00, 195.00, 20.00, 220.00),

-- Sale 20: Pooja (Sep) — coffee, biscuits
(20,19,  1.000, 430.00, 350.00, 0.00, 430.00),

-- Sale 21: Walk-in (Sep) — big basket
(21,13,  1.000, 740.00, 620.00, 0.00, 740.00),
(21, 7,  1.000, 420.00, 350.00, 0.00, 420.00),
(21,17,  1.000, 260.00, 200.00, 50.00, 210.00),

-- Sale 22: Sunil (Sep) — basics
(22, 1,  3.000, 60.00,  52.00,  0.00, 180.00),
(22,10,  2.000, 95.00,  75.00,  0.00, 190.00),
(22,25,  2.000, 58.00,  42.00,  0.00, 116.00),

-- Sale 23: Walk-in (Sep) — toned milk + marie
(23, 2,  6.000, 27.00,  22.00,  0.00, 162.00),
(23,12,  2.000, 35.00,  28.00,  0.00,  70.00),

-- Sale 24: Geeta (Sep) — monthly
(24, 4,  1.000, 375.00, 310.00, 0.00, 375.00),
(24,22,  2.000, 155.00, 120.00, 0.00, 310.00),
(24, 6,  1.000, 190.00, 150.00, 30.00, 160.00),

-- Sale 25: Walk-in (Sep) — soap, shampoo
(25,21,  2.000, 62.00,  48.00,  0.00, 124.00),
(25,20,  2.000, 120.00, 90.00,  0.00, 240.00),

-- Sale 26: Dinesh (Sep) — tea, sugar, dal
(26,18,  2.000, 125.00, 95.00,  0.00, 250.00),
(26,15,  1.000, 240.00, 195.00, 0.00, 240.00),
(26,24,  1.000, 155.00, 120.00, 10.00, 145.00),

-- Sale 27: Walk-in (Sep) — atta, maida, besan
(27, 7,  1.000, 420.00, 350.00, 0.00, 420.00),
(27, 9,  1.000, 48.00,  38.00,  0.00,  48.00),

-- Sale 28: Manoj (Sep) — oil, spices, biscuits
(28,14,  2.000, 200.00, 165.00, 0.00, 400.00),
(28,25,  3.000, 58.00,  42.00,  0.00, 174.00),
(28,10,  1.000, 95.00,  75.00,  20.00, 75.00),

-- October sales (29-38)
-- Sale 29: Anita (Oct) — milk, curd, jaggery
(29, 1,  5.000, 60.00,  52.00,  0.00, 300.00),
(29, 3,  3.000, 40.00,  30.00,  0.00, 120.00),
(29,16,  2.000, 110.00, 80.00,  0.00, 220.00),

-- Sale 30: Walk-in (Oct) — toned milk, biscuits
(30, 2,  5.000, 27.00,  22.00,  0.00, 135.00),
(30,11,  3.000, 40.00,  30.00,  0.00, 120.00),

-- Sale 31: Ravi (Oct) — atta, oil, rice, turmeric
(31, 7,  1.000, 420.00, 350.00, 0.00, 420.00),
(31,14,  1.000, 200.00, 165.00, 0.00, 200.00),
(31, 5,  1.000, 290.00, 240.00, 40.00, 250.00),
(31,25,  1.000, 58.00,  42.00,  0.00,  58.00),

-- Sale 32: Walk-in (Oct) — sugar, tea
(32,15,  1.000, 240.00, 195.00, 0.00, 240.00),
(32,17,  1.000, 260.00, 200.00, 0.00, 260.00),

-- Sale 33: Kavita (Oct) — rice, dal, oats, detergent
(33, 4,  1.000, 375.00, 310.00, 0.00, 375.00),
(33,23,  1.000, 140.00, 110.00, 0.00, 140.00),
(33,22,  1.000, 155.00, 120.00, 20.00, 135.00),
(33, 6,  1.000, 190.00, 150.00, 0.00, 190.00),

-- Sale 34: Walk-in (Oct) — soap, biscuits, maida
(34,20,  2.000, 120.00, 90.00,  0.00, 240.00),
(34,12,  3.000, 35.00,  28.00,  0.00, 105.00),
(34, 9,  2.000, 48.00,  38.00,  0.00,  96.00),

-- Sale 35: Pooja (Oct) — big basket
(35, 4,  2.000, 375.00, 310.00, 0.00, 750.00),
(35,17,  1.000, 260.00, 200.00, 0.00, 260.00),
(35,20,  1.000, 120.00, 90.00,  0.00, 120.00),
(35,24,  2.000, 155.00, 120.00, 50.00, 260.00),

-- Sale 36: Walk-in (Oct) — milk + curd
(36, 1,  4.000, 60.00,  52.00,  0.00, 240.00),
(36, 3,  2.000, 40.00,  30.00,  0.00,  80.00),

-- Sale 37: Sunil (Oct) — tea, coffee, sugar, biscuits
(37,18,  2.000, 125.00, 95.00,  0.00, 250.00),
(37,19,  1.000, 430.00, 350.00, 30.00, 400.00),
(37,15,  1.000, 240.00, 195.00, 0.00, 240.00),

-- Sale 38: Geeta (Oct) — atta, rice, oil
(38, 7,  1.000, 420.00, 350.00, 0.00, 420.00),
(38, 5,  1.000, 290.00, 240.00, 0.00, 290.00),

-- Sale 39 (CANCELLED): Walk-in tried to buy milk + biscuits but cancelled
(39, 1,  2.000, 60.00,  52.00,  0.00, 120.00),
(39,10,  1.000, 95.00,  75.00,  0.00,  95.00);

-- ============================================================================
-- Now UPDATE sales totals to match actual line item sums
-- (In a real app, the backend calculates these; here we fix them for consistency)
-- ============================================================================
UPDATE `sales` s
SET `total_amount` = (
    SELECT COALESCE(SUM(si.line_total + si.discount), 0)
    FROM `sale_items` si WHERE si.sale_id = s.sale_id
),
`net_amount` = (
    SELECT COALESCE(SUM(si.line_total), 0)
    FROM `sale_items` si WHERE si.sale_id = s.sale_id
);

-- ============================================================================
-- 7. purchases — supplier purchase records
-- ============================================================================
INSERT INTO `purchases` (`purchase_id`, `purchase_number`, `supplier_id`, `purchase_date`, `received_by`, `total_amount`, `tax_amount`, `net_amount`, `payment_status`, `status`) VALUES
(1, 'PO-20260715-001', 1, '2026-07-15 08:00:00', 5, 11200.00, 0.00, 11200.00, 'paid',   'received'),
(2, 'PO-20260716-001', 2, '2026-07-16 09:00:00', 5, 22600.00, 0.00, 22600.00, 'paid',   'received'),
(3, 'PO-20260717-001', 3, '2026-07-17 09:30:00', 5, 15400.00, 0.00, 15400.00, 'paid',   'received'),
(4, 'PO-20260717-002', 4, '2026-07-17 10:00:00', 5, 15300.00, 0.00, 15300.00, 'paid',   'received'),
(5, 'PO-20260718-001', 5, '2026-07-18 08:30:00', 5, 30200.00, 0.00, 30200.00, 'paid',   'received'),
(6, 'PO-20260718-002', 6, '2026-07-18 09:00:00', 2, 15350.00, 0.00, 15350.00, 'paid',   'received'),
(7, 'PO-20260720-001', 7, '2026-07-20 10:00:00', 2, 15450.00, 0.00, 15450.00, 'paid',   'received'),
(8, 'PO-20260720-002', 8, '2026-07-20 11:00:00', 2, 20160.00, 0.00, 20160.00, 'paid',   'received'),
-- Recent restock in October
(9, 'PO-20261010-001', 1, '2026-10-10 08:00:00', 5,  7400.00, 0.00,  7400.00, 'unpaid', 'received'),
(10,'PO-20261012-001', 2, '2026-10-12 09:00:00', 5,  9600.00, 0.00,  9600.00, 'unpaid', 'received');

-- ============================================================================
-- 8. purchase_items — products received
-- ============================================================================
INSERT INTO `purchase_items` (`purchase_id`, `product_id`, `quantity`, `unit_cost`, `line_total`, `expiry_date`) VALUES
-- PO-1: Dairy from Mother Dairy
(1,  1, 200.000, 52.00, 10400.00, '2026-10-30'),
(1,  2, 200.000, 22.00,  4400.00, '2026-10-28'),
(1,  3, 100.000, 30.00,  3000.00, '2026-10-25'),

-- PO-2: Rice & Pulses from Dawat
(2,  4, 100.000, 310.00, 31000.00, NULL),
(2,  5,  80.000, 240.00, 19200.00, NULL),
(2, 23,  60.000, 110.00,  6600.00, NULL),
(2, 24,  50.000, 120.00,  6000.00, NULL),

-- PO-3: Flour from Aashirvaad
(3,  7,  60.000, 350.00, 21000.00, '2027-04-01'),
(3,  8,  80.000,  72.00,  5760.00, '2027-03-15'),
(3,  9,  60.000,  38.00,  2280.00, '2027-05-20'),
(3, 25,  80.000,  42.00,  3360.00, '2027-12-01'),

-- PO-4: Biscuits from Parle & Britannia
(4, 10, 200.000, 75.00, 15000.00, '2027-08-01'),
(4, 11, 120.000, 30.00,  3600.00, '2027-07-15'),
(4, 12, 150.000, 28.00,  4200.00, '2027-09-01'),

-- PO-5: Oil from Fortune
(5, 13,  50.000, 620.00, 31000.00, '2027-12-01'),
(5, 14,  70.000, 165.00, 11550.00, '2027-10-01'),

-- PO-6: Sugar from Dhampur
(6, 15, 100.000, 195.00, 19500.00, NULL),
(6, 16,  40.000,  80.00,  3200.00, '2027-06-01'),

-- PO-7: Tea & Coffee from Tata
(7, 17,  50.000, 200.00, 10000.00, '2027-11-01'),
(7, 18,  60.000,  95.00,  5700.00, '2027-10-15'),
(7, 19,  30.000, 350.00, 10500.00, '2027-09-01'),

-- PO-8: Personal Care from HUL
(8, 20, 100.000,  90.00,  9000.00, '2028-06-01'),
(8, 21,  80.000,  48.00,  3840.00, '2028-05-01'),
(8, 22,  60.000, 120.00,  7200.00, '2028-01-01'),
(8,  6,  40.000, 150.00,  6000.00, '2027-06-15'),

-- PO-9: October dairy restock
(9,  1, 100.000, 52.00,  5200.00, '2026-11-15'),
(9,  2, 100.000, 22.00,  2200.00, '2026-11-12'),

-- PO-10: October rice restock
(10, 4,  30.000, 310.00, 9300.00, NULL),
(10, 5,  20.000, 240.00, 4800.00, NULL);

-- Now update purchase totals to match line items
UPDATE `purchases` pu
SET `total_amount` = (
    SELECT COALESCE(SUM(pi.line_total), 0)
    FROM `purchase_items` pi WHERE pi.purchase_id = pu.purchase_id
),
`net_amount` = (
    SELECT COALESCE(SUM(pi.line_total), 0)
    FROM `purchase_items` pi WHERE pi.purchase_id = pu.purchase_id
);

-- ============================================================================
-- 9. inventory_movements — audit trail
--    opening_stock + purchases - sales = current stock
-- ============================================================================

-- Opening stock entries (represents initial inventory before sales started)
INSERT INTO `inventory_movements` (`product_id`, `movement_type`, `quantity_change`, `stock_after`, `reference_type`, `reference_id`, `performed_by`, `remarks`, `created_at`) VALUES
-- Opening stock loaded on July 15
( 1, 'purchase', 200.000, 200.000, 'purchase', 1, 5, 'Initial dairy stock from PO-20260715-001',       '2026-07-15 08:30:00'),
( 2, 'purchase', 200.000, 200.000, 'purchase', 1, 5, 'Initial dairy stock from PO-20260715-001',       '2026-07-15 08:30:00'),
( 3, 'purchase', 100.000, 100.000, 'purchase', 1, 5, 'Initial dairy stock from PO-20260715-001',       '2026-07-15 08:30:00'),
( 4, 'purchase', 100.000, 100.000, 'purchase', 2, 5, 'Initial rice stock from PO-20260716-001',        '2026-07-16 09:30:00'),
( 5, 'purchase',  80.000,  80.000, 'purchase', 2, 5, 'Initial rice stock from PO-20260716-001',        '2026-07-16 09:30:00'),
(23, 'purchase',  60.000,  60.000, 'purchase', 2, 5, 'Initial dal stock from PO-20260716-001',         '2026-07-16 09:30:00'),
(24, 'purchase',  50.000,  50.000, 'purchase', 2, 5, 'Initial dal stock from PO-20260716-001',         '2026-07-16 09:30:00'),
( 7, 'purchase',  60.000,  60.000, 'purchase', 3, 5, 'Initial flour stock from PO-20260717-001',       '2026-07-17 09:45:00'),
( 8, 'purchase',  80.000,  80.000, 'purchase', 3, 5, 'Initial flour stock from PO-20260717-001',       '2026-07-17 09:45:00'),
( 9, 'purchase',  60.000,  60.000, 'purchase', 3, 5, 'Initial flour stock from PO-20260717-001',       '2026-07-17 09:45:00'),
(25, 'purchase',  80.000,  80.000, 'purchase', 3, 5, 'Initial spice stock from PO-20260717-001',       '2026-07-17 09:45:00'),
(10, 'purchase', 200.000, 200.000, 'purchase', 4, 5, 'Initial biscuit stock from PO-20260717-002',     '2026-07-17 10:15:00'),
(11, 'purchase', 120.000, 120.000, 'purchase', 4, 5, 'Initial biscuit stock from PO-20260717-002',     '2026-07-17 10:15:00'),
(12, 'purchase', 150.000, 150.000, 'purchase', 4, 5, 'Initial biscuit stock from PO-20260717-002',     '2026-07-17 10:15:00'),
(13, 'purchase',  50.000,  50.000, 'purchase', 5, 5, 'Initial oil stock from PO-20260718-001',         '2026-07-18 08:45:00'),
(14, 'purchase',  70.000,  70.000, 'purchase', 5, 5, 'Initial oil stock from PO-20260718-001',         '2026-07-18 08:45:00'),
(15, 'purchase', 100.000, 100.000, 'purchase', 6, 2, 'Initial sugar stock from PO-20260718-002',       '2026-07-18 09:15:00'),
(16, 'purchase',  40.000,  40.000, 'purchase', 6, 2, 'Initial jaggery stock from PO-20260718-002',     '2026-07-18 09:15:00'),
(17, 'purchase',  50.000,  50.000, 'purchase', 7, 2, 'Initial tea stock from PO-20260720-001',         '2026-07-20 10:15:00'),
(18, 'purchase',  60.000,  60.000, 'purchase', 7, 2, 'Initial tea stock from PO-20260720-001',         '2026-07-20 10:15:00'),
(19, 'purchase',  30.000,  30.000, 'purchase', 7, 2, 'Initial coffee stock from PO-20260720-001',      '2026-07-20 10:15:00'),
(20, 'purchase', 100.000, 100.000, 'purchase', 8, 2, 'Initial soap stock from PO-20260720-002',        '2026-07-20 11:15:00'),
(21, 'purchase',  80.000,  80.000, 'purchase', 8, 2, 'Initial soap stock from PO-20260720-002',        '2026-07-20 11:15:00'),
(22, 'purchase',  60.000,  60.000, 'purchase', 8, 2, 'Initial detergent stock from PO-20260720-002',   '2026-07-20 11:15:00'),
( 6, 'purchase',  40.000,  40.000, 'purchase', 8, 2, 'Initial oats stock from PO-20260720-002',        '2026-07-20 11:15:00'),

-- October restock movements
( 1, 'purchase', 100.000, 0.000, 'purchase', 9, 5, 'October dairy restock',  '2026-10-10 08:30:00'),
( 2, 'purchase', 100.000, 0.000, 'purchase', 9, 5, 'October dairy restock',  '2026-10-10 08:30:00'),
( 4, 'purchase',  30.000, 0.000, 'purchase',10, 5, 'October rice restock',   '2026-10-12 09:30:00'),
( 5, 'purchase',  20.000, 0.000, 'purchase',10, 5, 'October rice restock',   '2026-10-12 09:30:00'),

-- A few sale movements to demonstrate the pattern (in real app, all sales would have these)
( 1, 'sale', -3.000,  0.000, 'sale', 1, 3, 'Sale INV-20260718-001',   '2026-07-18 10:15:00'),
( 4, 'sale', -1.000,  0.000, 'sale', 1, 3, 'Sale INV-20260718-001',   '2026-07-18 10:15:00'),
( 2, 'sale', -4.000,  0.000, 'sale', 2, 3, 'Sale INV-20260718-002',   '2026-07-18 14:30:00'),
(10, 'sale', -2.000,  0.000, 'sale', 2, 3, 'Sale INV-20260718-002',   '2026-07-18 14:30:00'),

-- Example adjustment: damaged goods written off
( 3, 'damage', -5.000, 0.000, 'manual', NULL, 5, 'Damaged — curd expired before sale', '2026-08-20 09:00:00');

-- Note: stock_after values are set to 0.000 as placeholders.
-- In production, the application layer calculates exact stock_after values.
-- The current_stock in the products table is the authoritative source.

-- ============================================================================
-- 10. ai_insights — sample AI/SQL forecast records
--     These are clearly labeled as SQL-based moving average forecasts
-- ============================================================================
INSERT INTO `ai_insights` (`product_id`, `insight_type`, `forecast_date`, `predicted_demand`, `suggested_restock_qty`, `confidence_score`, `model_version`, `parameters_used`, `explanation`, `data_period_start`, `data_period_end`, `is_active`, `generated_by`) VALUES
-- SQL moving average forecasts for key products
( 1, 'sql_moving_avg_forecast', '2026-10-22', 4.500, 30.000, 0.6500, 'sql_moving_avg_v1',
  '{"window_7day": 7, "window_30day": 30, "safety_factor": 1.25}',
  'Based on 7-day moving average of daily sales. Full Cream Milk shows steady demand of ~4.5 units/day. Suggested restock accounts for 7-day demand + 25% safety stock.',
  '2026-10-08', '2026-10-15', TRUE, 'sql_procedure'),

( 4, 'sql_moving_avg_forecast', '2026-10-22', 0.850, 10.000, 0.5500, 'sql_moving_avg_v1',
  '{"window_7day": 7, "window_30day": 30, "safety_factor": 1.25}',
  'Basmati Rice 5kg — 30-day avg demand ~0.85 packs/day. Less frequent purchases but higher volume. Restock suggestion covers 2 weeks.',
  '2026-09-15', '2026-10-15', TRUE, 'sql_procedure'),

(10, 'sql_moving_avg_forecast', '2026-10-22', 1.200, 15.000, 0.6000, 'sql_moving_avg_v1',
  '{"window_7day": 7, "window_30day": 30, "safety_factor": 1.25}',
  'Parle-G biscuits — consistent demand ~1.2 packs/day across 30-day window. Popular everyday item.',
  '2026-09-15', '2026-10-15', TRUE, 'sql_procedure'),

(15, 'demand_forecast', '2026-10-22', 0.700, 8.000, 0.5000, 'sql_moving_avg_v1',
  '{"window_30day": 30, "safety_factor": 1.30}',
  'Sugar 5kg — moderate demand ~0.7 bags/day. Seasonal variation possible during festivals.',
  '2026-09-15', '2026-10-15', TRUE, 'sql_procedure'),

-- Restock suggestions
( 3, 'restock_suggestion', '2026-10-16', NULL, 25.000, 0.7000, 'sql_moving_avg_v1',
  '{"current_stock": 45, "min_stock": 20, "lead_time_days": 1}',
  'Fresh Curd stock adequate but nearing expiry (2026-10-25). Suggest ordering 25 units as replacement stock before expiry.',
  '2026-09-15', '2026-10-15', TRUE, 'sql_procedure'),

(19, 'restock_suggestion', '2026-10-16', NULL, 15.000, 0.6000, 'sql_moving_avg_v1',
  '{"current_stock": 20, "min_stock": 8, "lead_time_days": 5}',
  'Nescafe Coffee — stock at 20 jars with 5-day supplier lead time. Given moderate demand (~0.4/day), restock of 15 jars recommended to maintain 30-day buffer.',
  '2026-09-15', '2026-10-15', TRUE, 'sql_procedure'),

-- Trend analysis
( 1, 'trend_analysis', '2026-10-15', NULL, NULL, 0.7500, 'sql_moving_avg_v1',
  '{"period_comparison": "30d_vs_60d", "trend_direction": "stable"}',
  'Full Cream Milk demand is stable. 30-day average (4.5/day) closely matches 60-day average (4.3/day). No significant trend detected.',
  '2026-08-15', '2026-10-15', TRUE, 'sql_procedure'),

(13, 'trend_analysis', '2026-10-15', NULL, NULL, 0.5500, 'sql_moving_avg_v1',
  '{"period_comparison": "30d_vs_60d", "trend_direction": "increasing"}',
  'Sunflower Oil 5L — demand appears slightly increasing. 30-day avg (0.35/day) up from 60-day avg (0.28/day). Small sample size limits confidence.',
  '2026-08-15', '2026-10-15', TRUE, 'sql_procedure');


-- Re-enable FK checks
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================================
-- VERIFY DATA LOADED CORRECTLY
-- ============================================================================
SELECT 'app_users'          AS `table`, COUNT(*) AS `rows` FROM `app_users`
UNION ALL SELECT 'categories',        COUNT(*) FROM `categories`
UNION ALL SELECT 'suppliers',          COUNT(*) FROM `suppliers`
UNION ALL SELECT 'products',           COUNT(*) FROM `products`
UNION ALL SELECT 'sales',             COUNT(*) FROM `sales`
UNION ALL SELECT 'sale_items',        COUNT(*) FROM `sale_items`
UNION ALL SELECT 'purchases',         COUNT(*) FROM `purchases`
UNION ALL SELECT 'purchase_items',    COUNT(*) FROM `purchase_items`
UNION ALL SELECT 'inventory_movements', COUNT(*) FROM `inventory_movements`
UNION ALL SELECT 'ai_insights',       COUNT(*) FROM `ai_insights`;

-- ============================================================================
-- END OF SAMPLE DATA
-- ============================================================================
