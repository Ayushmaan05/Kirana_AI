-- ============================================================================
-- AI KIRANA STORE — DATABASE SCHEMA
-- File       : schema.sql
-- Engine     : MySQL 8.0+ / InnoDB
-- Author     : Database & SQL Module
-- Description: Creates the `kirana_store` database with 10 tables, views,
--              indexes, and all referential-integrity constraints.
-- Usage      : mysql -u root -p < schema.sql
--              OR open in MySQL Workbench → File → Run SQL Script
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 0. CREATE DATABASE
-- ----------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS `kirana_store`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `kirana_store`;

-- ============================================================================
-- 1. app_users — staff and administrator records
-- ============================================================================
CREATE TABLE `app_users` (
    `user_id`       INT             AUTO_INCREMENT PRIMARY KEY,
    `username`      VARCHAR(50)     NOT NULL UNIQUE,
    `password_hash` VARCHAR(255)    NOT NULL
        COMMENT 'Store bcrypt/argon2 hash — NEVER plaintext',
    `full_name`     VARCHAR(100)    NOT NULL,
    `email`         VARCHAR(100)    UNIQUE,
    `phone`         VARCHAR(15),
    `role`          ENUM('admin', 'manager', 'cashier', 'inventory_clerk')
                    NOT NULL DEFAULT 'cashier',
    `is_active`     BOOLEAN         NOT NULL DEFAULT TRUE,
    `created_at`    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
                    ON UPDATE CURRENT_TIMESTAMP,

    INDEX `idx_users_role` (`role`),
    INDEX `idx_users_active` (`is_active`)
) ENGINE=InnoDB
  COMMENT = 'Store staff and administrator accounts';

-- ============================================================================
-- 2. categories — grocery categories
-- ============================================================================
CREATE TABLE `categories` (
    `category_id`   INT             AUTO_INCREMENT PRIMARY KEY,
    `category_name` VARCHAR(100)    NOT NULL UNIQUE,
    `description`   VARCHAR(255),
    `is_active`     BOOLEAN         NOT NULL DEFAULT TRUE,
    `created_at`    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
                    ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB
  COMMENT = 'Grocery product categories (Dairy, Grains, etc.)';

-- ============================================================================
-- 3. suppliers — supplier information
-- ============================================================================
CREATE TABLE `suppliers` (
    `supplier_id`   INT             AUTO_INCREMENT PRIMARY KEY,
    `supplier_name` VARCHAR(150)    NOT NULL,
    `contact_person` VARCHAR(100),
    `phone`         VARCHAR(15),
    `email`         VARCHAR(100),
    `address`       TEXT,
    `city`          VARCHAR(80),
    `state`         VARCHAR(80),
    `gstin`         VARCHAR(15)
        COMMENT 'GST Identification Number (India)',
    `lead_time_days` INT            NOT NULL DEFAULT 3
        COMMENT 'Average days from order to delivery',
    `is_active`     BOOLEAN         NOT NULL DEFAULT TRUE,
    `created_at`    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
                    ON UPDATE CURRENT_TIMESTAMP,

    INDEX `idx_suppliers_city` (`city`)
) ENGINE=InnoDB
  COMMENT = 'Supplier / vendor master data';

-- ============================================================================
-- 4. products — product details, prices, stock, and expiry
-- ============================================================================
CREATE TABLE `products` (
    `product_id`        INT             AUTO_INCREMENT PRIMARY KEY,
    `sku`               VARCHAR(30)     NOT NULL UNIQUE
        COMMENT 'Stock Keeping Unit — must be unique',
    `product_name`      VARCHAR(200)    NOT NULL,
    `category_id`       INT             NOT NULL,
    `supplier_id`       INT,
    `brand`             VARCHAR(100),
    `unit`              VARCHAR(30)     NOT NULL DEFAULT 'piece'
        COMMENT 'e.g. kg, litre, piece, packet',
    `cost_price`        DECIMAL(10,2)   NOT NULL DEFAULT 0.00
        COMMENT 'Purchase / cost price per unit',
    `selling_price`     DECIMAL(10,2)   NOT NULL DEFAULT 0.00
        COMMENT 'MRP or selling price per unit',
    `current_stock`     DECIMAL(12,3)   NOT NULL DEFAULT 0.000
        COMMENT 'Current quantity in stock',
    `min_stock_level`   DECIMAL(12,3)   NOT NULL DEFAULT 10.000
        COMMENT 'Reorder point — alert when stock falls below this',
    `max_stock_level`   DECIMAL(12,3)   NOT NULL DEFAULT 500.000
        COMMENT 'Maximum storage capacity for this product',
    `expiry_date`       DATE
        COMMENT 'NULL for non-perishable items',
    `is_active`         BOOLEAN         NOT NULL DEFAULT TRUE,
    `created_at`        TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`        TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
                        ON UPDATE CURRENT_TIMESTAMP,

    -- Foreign keys
    CONSTRAINT `fk_products_category`
        FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT `fk_products_supplier`
        FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`supplier_id`)
        ON UPDATE CASCADE ON DELETE SET NULL,

    -- Constraints
    CONSTRAINT `chk_cost_price`    CHECK (`cost_price`    >= 0),
    CONSTRAINT `chk_selling_price` CHECK (`selling_price` >= 0),
    CONSTRAINT `chk_current_stock` CHECK (`current_stock` >= 0),
    CONSTRAINT `chk_min_stock`     CHECK (`min_stock_level` >= 0),

    -- Indexes
    INDEX `idx_products_name`     (`product_name`),
    INDEX `idx_products_category` (`category_id`),
    INDEX `idx_products_supplier` (`supplier_id`),
    INDEX `idx_products_expiry`   (`expiry_date`),
    INDEX `idx_products_stock`    (`current_stock`)
) ENGINE=InnoDB
  COMMENT = 'Product master — prices, stock quantities, and expiry';

-- ============================================================================
-- 5. sales — customer bills and payment details
-- ============================================================================
CREATE TABLE `sales` (
    `sale_id`           INT             AUTO_INCREMENT PRIMARY KEY,
    `invoice_number`    VARCHAR(30)     NOT NULL UNIQUE
        COMMENT 'Unique bill / invoice number',
    `sale_date`         DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `customer_name`     VARCHAR(100)    DEFAULT 'Walk-in Customer',
    `customer_phone`    VARCHAR(15),
    `cashier_id`        INT             NOT NULL
        COMMENT 'app_users.user_id who processed the sale',
    `total_amount`      DECIMAL(12,2)   NOT NULL DEFAULT 0.00,
    `discount_amount`   DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    `tax_amount`        DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    `net_amount`        DECIMAL(12,2)   NOT NULL DEFAULT 0.00
        COMMENT 'total - discount + tax',
    `payment_method`    ENUM('cash', 'upi', 'card', 'credit')
                        NOT NULL DEFAULT 'cash',
    `status`            ENUM('completed', 'cancelled', 'refunded')
                        NOT NULL DEFAULT 'completed',
    `notes`             TEXT,
    `created_at`        TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`        TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
                        ON UPDATE CURRENT_TIMESTAMP,

    -- Foreign keys
    CONSTRAINT `fk_sales_cashier`
        FOREIGN KEY (`cashier_id`) REFERENCES `app_users` (`user_id`)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    -- Constraints
    CONSTRAINT `chk_sale_total`    CHECK (`total_amount`    >= 0),
    CONSTRAINT `chk_sale_discount` CHECK (`discount_amount` >= 0),
    CONSTRAINT `chk_sale_tax`      CHECK (`tax_amount`      >= 0),
    CONSTRAINT `chk_sale_net`      CHECK (`net_amount`      >= 0),

    -- Indexes
    INDEX `idx_sales_date`    (`sale_date`),
    INDEX `idx_sales_cashier` (`cashier_id`),
    INDEX `idx_sales_status`  (`status`)
) ENGINE=InnoDB
  COMMENT = 'Customer bills / invoices';

-- ============================================================================
-- 6. sale_items — individual products sold in each bill
-- ============================================================================
CREATE TABLE `sale_items` (
    `sale_item_id`  INT             AUTO_INCREMENT PRIMARY KEY,
    `sale_id`       INT             NOT NULL,
    `product_id`    INT             NOT NULL,
    `quantity`      DECIMAL(10,3)   NOT NULL,
    `unit_price`    DECIMAL(10,2)   NOT NULL
        COMMENT 'Price at time of sale (snapshot)',
    `cost_price`    DECIMAL(10,2)   NOT NULL DEFAULT 0.00
        COMMENT 'Cost at time of sale for profit calculation',
    `discount`      DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    `line_total`    DECIMAL(12,2)   NOT NULL
        COMMENT 'quantity * unit_price - discount',
    `created_at`    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Foreign keys
    CONSTRAINT `fk_saleitems_sale`
        FOREIGN KEY (`sale_id`) REFERENCES `sales` (`sale_id`)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT `fk_saleitems_product`
        FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    -- Constraints
    CONSTRAINT `chk_si_quantity`   CHECK (`quantity`   > 0),
    CONSTRAINT `chk_si_unitprice`  CHECK (`unit_price` >= 0),
    CONSTRAINT `chk_si_linetotal`  CHECK (`line_total` >= 0),

    -- Indexes
    INDEX `idx_saleitems_sale`    (`sale_id`),
    INDEX `idx_saleitems_product` (`product_id`)
) ENGINE=InnoDB
  COMMENT = 'Line items for each sale / invoice';

-- ============================================================================
-- 7. purchases — supplier purchase records
-- ============================================================================
CREATE TABLE `purchases` (
    `purchase_id`       INT             AUTO_INCREMENT PRIMARY KEY,
    `purchase_number`   VARCHAR(30)     NOT NULL UNIQUE
        COMMENT 'Unique purchase order / GRN number',
    `supplier_id`       INT             NOT NULL,
    `purchase_date`     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `received_by`       INT             NOT NULL
        COMMENT 'app_users.user_id who received the goods',
    `total_amount`      DECIMAL(12,2)   NOT NULL DEFAULT 0.00,
    `tax_amount`        DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    `net_amount`        DECIMAL(12,2)   NOT NULL DEFAULT 0.00,
    `payment_status`    ENUM('paid', 'unpaid', 'partial')
                        NOT NULL DEFAULT 'unpaid',
    `status`            ENUM('received', 'pending', 'cancelled')
                        NOT NULL DEFAULT 'received',
    `notes`             TEXT,
    `created_at`        TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`        TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
                        ON UPDATE CURRENT_TIMESTAMP,

    -- Foreign keys
    CONSTRAINT `fk_purchases_supplier`
        FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`supplier_id`)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT `fk_purchases_receiver`
        FOREIGN KEY (`received_by`) REFERENCES `app_users` (`user_id`)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    -- Constraints
    CONSTRAINT `chk_pur_total` CHECK (`total_amount` >= 0),
    CONSTRAINT `chk_pur_tax`   CHECK (`tax_amount`   >= 0),
    CONSTRAINT `chk_pur_net`   CHECK (`net_amount`    >= 0),

    -- Indexes
    INDEX `idx_purchases_supplier` (`supplier_id`),
    INDEX `idx_purchases_date`     (`purchase_date`),
    INDEX `idx_purchases_status`   (`status`)
) ENGINE=InnoDB
  COMMENT = 'Goods received from suppliers';

-- ============================================================================
-- 8. purchase_items — products received from suppliers
-- ============================================================================
CREATE TABLE `purchase_items` (
    `purchase_item_id`  INT             AUTO_INCREMENT PRIMARY KEY,
    `purchase_id`       INT             NOT NULL,
    `product_id`        INT             NOT NULL,
    `quantity`          DECIMAL(10,3)   NOT NULL,
    `unit_cost`         DECIMAL(10,2)   NOT NULL
        COMMENT 'Cost per unit in this purchase',
    `line_total`        DECIMAL(12,2)   NOT NULL
        COMMENT 'quantity * unit_cost',
    `expiry_date`       DATE
        COMMENT 'Expiry of this specific batch',
    `created_at`        TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Foreign keys
    CONSTRAINT `fk_puritems_purchase`
        FOREIGN KEY (`purchase_id`) REFERENCES `purchases` (`purchase_id`)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT `fk_puritems_product`
        FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    -- Constraints
    CONSTRAINT `chk_pi_quantity`  CHECK (`quantity`   > 0),
    CONSTRAINT `chk_pi_unitcost`  CHECK (`unit_cost`  >= 0),
    CONSTRAINT `chk_pi_linetotal` CHECK (`line_total` >= 0),

    -- Indexes
    INDEX `idx_puritems_purchase` (`purchase_id`),
    INDEX `idx_puritems_product`  (`product_id`)
) ENGINE=InnoDB
  COMMENT = 'Line items for each supplier purchase';

-- ============================================================================
-- 9. inventory_movements — history of stock increases and decreases
-- ============================================================================
CREATE TABLE `inventory_movements` (
    `movement_id`       INT             AUTO_INCREMENT PRIMARY KEY,
    `product_id`        INT             NOT NULL,
    `movement_type`     ENUM('sale', 'purchase', 'adjustment', 'return',
                             'damage', 'expired', 'opening_stock')
                        NOT NULL,
    `quantity_change`   DECIMAL(12,3)   NOT NULL
        COMMENT 'Positive = stock in, Negative = stock out',
    `stock_after`       DECIMAL(12,3)   NOT NULL
        COMMENT 'Stock level after this movement',
    `reference_type`    ENUM('sale', 'purchase', 'manual', 'system')
                        NOT NULL DEFAULT 'manual',
    `reference_id`      INT
        COMMENT 'sale_id or purchase_id depending on reference_type',
    `performed_by`      INT
        COMMENT 'app_users.user_id who performed the action',
    `remarks`           VARCHAR(255),
    `created_at`        TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Foreign keys
    CONSTRAINT `fk_invmov_product`
        FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT `fk_invmov_user`
        FOREIGN KEY (`performed_by`) REFERENCES `app_users` (`user_id`)
        ON UPDATE CASCADE ON DELETE SET NULL,

    -- Indexes
    INDEX `idx_invmov_product`   (`product_id`),
    INDEX `idx_invmov_type`      (`movement_type`),
    INDEX `idx_invmov_date`      (`created_at`),
    INDEX `idx_invmov_reference` (`reference_type`, `reference_id`)
) ENGINE=InnoDB
  COMMENT = 'Audit trail of every stock change';

-- ============================================================================
-- 10. ai_insights — AI-generated demand forecasts and recommendations
-- ============================================================================
CREATE TABLE `ai_insights` (
    `insight_id`            INT             AUTO_INCREMENT PRIMARY KEY,
    `product_id`            INT             NOT NULL,
    `insight_type`          ENUM('demand_forecast', 'restock_suggestion',
                                 'expiry_alert', 'trend_analysis',
                                 'sql_moving_avg_forecast')
                            NOT NULL,
    `forecast_date`         DATE
        COMMENT 'The date this forecast applies to',
    `predicted_demand`      DECIMAL(12,3)
        COMMENT 'Predicted quantity to be sold',
    `suggested_restock_qty` DECIMAL(12,3)
        COMMENT 'Recommended quantity to order',
    `confidence_score`      DECIMAL(5,4)
        COMMENT 'Value between 0.0000 and 1.0000',
    `model_version`         VARCHAR(50)
        COMMENT 'e.g. sql_moving_avg_v1, ml_xgboost_v2',
    `parameters_used`       JSON
        COMMENT 'JSON with window sizes, weights, etc.',
    `explanation`           TEXT
        COMMENT 'Human-readable explanation of the insight',
    `data_period_start`     DATE
        COMMENT 'Start of historical data window used',
    `data_period_end`       DATE
        COMMENT 'End of historical data window used',
    `is_active`             BOOLEAN         NOT NULL DEFAULT TRUE
        COMMENT 'FALSE for superseded forecasts',
    `generated_by`          ENUM('sql_procedure', 'ml_model', 'manual')
                            NOT NULL DEFAULT 'sql_procedure',
    `created_at`            TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Foreign keys
    CONSTRAINT `fk_aiinsights_product`
        FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`)
        ON UPDATE CASCADE ON DELETE CASCADE,

    -- Constraints
    CONSTRAINT `chk_confidence`
        CHECK (`confidence_score` IS NULL
               OR (`confidence_score` >= 0 AND `confidence_score` <= 1)),

    -- Indexes
    INDEX `idx_ai_product`  (`product_id`),
    INDEX `idx_ai_type`     (`insight_type`),
    INDEX `idx_ai_date`     (`forecast_date`),
    INDEX `idx_ai_active`   (`is_active`),
    INDEX `idx_ai_generated`(`generated_by`)
) ENGINE=InnoDB
  COMMENT = 'AI / SQL-based demand forecasts and restocking suggestions';

-- ============================================================================
-- VIEWS
-- ============================================================================

-- ---------------------------------------------------------------------------
-- View: Low-stock products (stock below reorder point)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW `vw_low_stock_products` AS
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
FROM `products` p
JOIN `categories` c ON c.category_id = p.category_id
LEFT JOIN `suppliers` s ON s.supplier_id = p.supplier_id
WHERE p.current_stock < p.min_stock_level
  AND p.is_active = TRUE
ORDER BY shortage_qty DESC;

-- ---------------------------------------------------------------------------
-- View: Products nearing expiry (within 30 days)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW `vw_expiring_soon` AS
SELECT
    p.product_id,
    p.sku,
    p.product_name,
    c.category_name,
    p.expiry_date,
    DATEDIFF(p.expiry_date, CURDATE()) AS days_until_expiry,
    p.current_stock,
    p.unit,
    p.selling_price
FROM `products` p
JOIN `categories` c ON c.category_id = p.category_id
WHERE p.expiry_date IS NOT NULL
  AND p.expiry_date <= DATE_ADD(CURDATE(), INTERVAL 30 DAY)
  AND p.current_stock > 0
  AND p.is_active = TRUE
ORDER BY p.expiry_date ASC;

-- ---------------------------------------------------------------------------
-- View: Daily sales summary
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW `vw_daily_sales_summary` AS
SELECT
    DATE(s.sale_date)                       AS sale_day,
    COUNT(DISTINCT s.sale_id)               AS total_bills,
    SUM(s.total_amount)                     AS gross_sales,
    SUM(s.discount_amount)                  AS total_discounts,
    SUM(s.tax_amount)                       AS total_tax,
    SUM(s.net_amount)                       AS net_revenue,
    SUM(si.quantity)                        AS total_items_sold,
    SUM(si.line_total - (si.cost_price * si.quantity))
                                            AS estimated_gross_profit
FROM `sales` s
JOIN `sale_items` si ON si.sale_id = s.sale_id
WHERE s.status = 'completed'
GROUP BY DATE(s.sale_date)
ORDER BY sale_day DESC;

-- ---------------------------------------------------------------------------
-- View: Product-wise daily sales (for AI demand forecasting)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW `vw_product_daily_sales` AS
SELECT
    DATE(s.sale_date)       AS sale_day,
    si.product_id,
    p.product_name,
    p.sku,
    SUM(si.quantity)        AS total_qty_sold,
    SUM(si.line_total)      AS total_revenue,
    COUNT(DISTINCT s.sale_id) AS num_transactions
FROM `sales` s
JOIN `sale_items` si ON si.sale_id = s.sale_id
JOIN `products` p    ON p.product_id = si.product_id
WHERE s.status = 'completed'
GROUP BY DATE(s.sale_date), si.product_id, p.product_name, p.sku
ORDER BY sale_day DESC, total_qty_sold DESC;

-- ---------------------------------------------------------------------------
-- View: Current inventory valuation
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW `vw_inventory_valuation` AS
SELECT
    p.product_id,
    p.sku,
    p.product_name,
    c.category_name,
    p.current_stock,
    p.unit,
    p.cost_price,
    p.selling_price,
    ROUND(p.current_stock * p.cost_price, 2)    AS valuation_at_cost,
    ROUND(p.current_stock * p.selling_price, 2)  AS valuation_at_selling
FROM `products` p
JOIN `categories` c ON c.category_id = p.category_id
WHERE p.is_active = TRUE
  AND p.current_stock > 0
ORDER BY valuation_at_cost DESC;

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================
