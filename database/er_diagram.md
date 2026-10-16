# AI Kirana Store — ER Diagram

## Entity-Relationship Diagram

```mermaid
erDiagram
    app_users {
        INTEGER user_id PK
        TEXT username UK
        TEXT full_name
        TEXT role
        INTEGER is_active
    }

    categories {
        INTEGER category_id PK
        TEXT category_name UK
        TEXT description
        INTEGER is_active
    }

    suppliers {
        INTEGER supplier_id PK
        TEXT supplier_name
        TEXT contact_person
        TEXT gstin
        INTEGER lead_time_days
    }

    products {
        INTEGER product_id PK
        TEXT sku UK
        TEXT product_name
        INTEGER category_id FK
        INTEGER supplier_id FK
        NUMERIC cost_price
        NUMERIC selling_price
        NUMERIC current_stock
        NUMERIC min_stock_level
        TEXT expiry_date
    }

    sales {
        INTEGER sale_id PK
        TEXT invoice_number UK
        TEXT sale_date
        INTEGER cashier_id FK
        NUMERIC total_amount
        NUMERIC net_amount
        TEXT payment_method
        TEXT status
    }

    cash_payments {
        INTEGER cash_payment_id PK
        INTEGER sale_id FK
        INTEGER cashier_id FK
        NUMERIC amount_tendered
        NUMERIC amount_received
        NUMERIC change_returned
        TEXT denomination_breakdown
        TEXT payment_status
        TEXT payment_time
    }

    online_payments {
        INTEGER online_payment_id PK
        INTEGER sale_id FK
        TEXT payment_platform
        TEXT provider
        TEXT transaction_reference_id UK
        NUMERIC amount
        TEXT payer_upi_id
        TEXT payer_phone
        TEXT payment_status
        NUMERIC gateway_fee
        TEXT settlement_status
        TEXT payment_time
    }

    sale_items {
        INTEGER sale_item_id PK
        INTEGER sale_id FK
        INTEGER product_id FK
        NUMERIC quantity
        NUMERIC unit_price
        NUMERIC cost_price
        NUMERIC line_total
    }

    purchases {
        INTEGER purchase_id PK
        TEXT purchase_number UK
        INTEGER supplier_id FK
        INTEGER received_by FK
        TEXT purchase_date
        NUMERIC net_amount
        TEXT payment_status
        TEXT status
    }

    purchase_items {
        INTEGER purchase_item_id PK
        INTEGER purchase_id FK
        INTEGER product_id FK
        NUMERIC quantity
        NUMERIC unit_cost
        NUMERIC line_total
        TEXT expiry_date
    }

    inventory_movements {
        INTEGER movement_id PK
        INTEGER product_id FK
        TEXT movement_type
        NUMERIC quantity_change
        NUMERIC stock_after
        TEXT reference_type
        INTEGER reference_id
        INTEGER performed_by FK
    }

    ai_insights {
        INTEGER insight_id PK
        INTEGER product_id FK
        TEXT insight_type
        TEXT forecast_date
        NUMERIC predicted_demand
        NUMERIC suggested_restock_qty
        NUMERIC confidence_score
        TEXT model_version
        TEXT generated_by
    }

    %% Relationships
    categories ||--o{ products : "has many"
    suppliers ||--o{ products : "supplies"
    app_users ||--o{ sales : "processes as cashier"
    sales ||--o{ sale_items : "contains"
    products ||--o{ sale_items : "sold in"
    sales ||--o{ cash_payments : "paid with cash"
    app_users ||--o{ cash_payments : "cashier receives cash"
    sales ||--o{ online_payments : "paid with UPI/card"
    suppliers ||--o{ purchases : "receives from"
    app_users ||--o{ purchases : "received by"
    purchases ||--o{ purchase_items : "contains"
    products ||--o{ purchase_items : "received as"
    products ||--o{ inventory_movements : "tracked in"
    app_users ||--o{ inventory_movements : "performed by"
    products ||--o{ ai_insights : "forecast for"
```

---

## Table Relationships Explained

### One-to-Many Relationships

| Parent Table | Child Table | FK Column | Relationship | ON DELETE |
|---|---|---|---|---|
| `categories` | `products` | `category_id` | One category has many products | RESTRICT |
| `suppliers` | `products` | `supplier_id` | One supplier supplies many products | SET NULL |
| `app_users` | `sales` | `cashier_id` | One cashier processes many sales | RESTRICT |
| `sales` | `sale_items` | `sale_id` | One sale has many line items | CASCADE |
| `products` | `sale_items` | `product_id` | One product appears in many sale items | RESTRICT |
| `sales` | `cash_payments` | `sale_id` | One sale can have cash payments | CASCADE |
| `app_users` | `cash_payments` | `cashier_id` | One cashier verifies and handles cash | RESTRICT |
| `sales` | `online_payments` | `sale_id` | One sale can have online payments | CASCADE |
| `suppliers` | `purchases` | `supplier_id` | One supplier has many purchase orders | RESTRICT |
| `app_users` | `purchases` | `received_by` | One user receives many purchases | RESTRICT |
| `purchases` | `purchase_items` | `purchase_id` | One purchase has many line items | CASCADE |
| `products` | `purchase_items` | `product_id` | One product appears in many purchase items | RESTRICT |
| `products` | `inventory_movements` | `product_id` | One product has many stock movements | RESTRICT |
| `app_users` | `inventory_movements` | `performed_by` | One user performs many stock changes | SET NULL |
| `products` | `ai_insights` | `product_id` | One product has many AI forecasts | CASCADE |

---

## Data Flow Diagram

```mermaid
flowchart TD
    subgraph Master_Data["📦 Master Data"]
        CAT["categories"]
        SUP["suppliers"]
        USR["app_users"]
        PRD["products"]
    end

    subgraph Sales_Flow["💰 Sales & Billing"]
        SAL["sales"]
        SI["sale_items"]
        CP["cash_payments"]
        OP["online_payments"]
    end

    subgraph Purchase_Flow["🚚 Purchase Flow"]
        PUR["purchases"]
        PI["purchase_items"]
    end

    subgraph Inventory_Tracking["📊 Inventory & AI"]
        INV["inventory_movements"]
        AI["ai_insights"]
    end

    CAT -->|categorizes| PRD
    SUP -->|supplies| PRD

    USR -->|cashier processes| SAL
    PRD -->|sold in| SI
    SAL -->|contains| SI

    SAL -->|settled via cash| CP
    USR -->|cashier verifies cash| CP
    SAL -->|settled via UPI/card| OP

    USR -->|receives goods| PUR
    SUP -->|ships to| PUR
    PUR -->|contains| PI
    PRD -->|received as| PI

    SI -->|"stock OUT (−)"| INV
    PI -->|"stock IN (+)"| INV
    PRD -->|stock tracked| INV

    SAL -->|"historical sales data"| AI
    PRD -->|"current stock & demand"| AI
    INV -->|"movement history"| AI

    style Master_Data fill:#e3f2fd,stroke:#1565c0
    style Sales_Flow fill:#fce4ec,stroke:#c62828
    style Purchase_Flow fill:#e8f5e9,stroke:#2e7d32
    style Inventory_Tracking fill:#fff3e0,stroke:#e65100
```

---

## Quick Reference Table (12 Tables)

| # | Table | Primary Key | Foreign Keys | Purpose |
|---|---|---|---|---|
| 1 | `app_users` | `user_id` | — | Staff and administrator accounts |
| 2 | `categories` | `category_id` | — | Product categories (Dairy, Grains, etc.) |
| 3 | `suppliers` | `supplier_id` | — | Vendor/supplier master data |
| 4 | `products` | `product_id` | `category_id`, `supplier_id` | Product catalog with prices, stock, and expiry |
| 5 | `sales` | `sale_id` | `cashier_id` | Customer bills/invoices header |
| 6 | `cash_payments` | `cash_payment_id` | `sale_id`, `cashier_id` | Cash payment details, tendered, change & denominations |
| 7 | `online_payments` | `online_payment_id` | `sale_id` | Digital payments (UPI, QR, Card POS, provider, UTR) |
| 8 | `sale_items` | `sale_item_id` | `sale_id`, `product_id` | Individual products sold in each bill |
| 9 | `purchases` | `purchase_id` | `supplier_id`, `received_by` | Supplier purchase orders header |
| 10 | `purchase_items` | `purchase_item_id` | `purchase_id`, `product_id` | Line items received in each purchase order |
| 11 | `inventory_movements` | `movement_id` | `product_id`, `performed_by` | Immutable audit trail of every stock change |
| 12 | `ai_insights` | `insight_id` | `product_id` | AI/SQL demand forecasts and restocking recommendations |

---

## Key Design Decisions

1. **SQLite 3 Type Affinity**: SQLite is serverless and lightweight with zero external server dependencies, making it optimal for local Kirana AI edge deployments, laptops, Raspberry Pi, and mobile setups. Currency and quantities use `NUMERIC` with explicit `CHECK` constraints (e.g. `>= 0`).
2. **Dedicated Payment Schemas**: Two specialized tables (`cash_payments` and `online_payments`) provide clean separation of concerns. Cash tracks drawer balance, amount tendered, and return change; Online tracks provider, UTR reference number, settlement status, and gateway fees.
3. **Snapshot pricing**: `sale_items.unit_price` and `sale_items.cost_price` capture the price **at the time of sale**.
4. **Soft deletes**: `is_active` integer flags (`1`/`0`) are used instead of deleting records.
5. **Unique constraints**: `sku`, `invoice_number`, `purchase_number`, and `transaction_reference_id` are enforced UNIQUE to prevent duplicates.
6. **ON DELETE behavior**:
   - **CASCADE**: Deleting a sale cascades to its sale items, cash payments, and online payments.
   - **RESTRICT**: Cannot delete categories, suppliers, or products that have historical references.
   - **SET NULL**: Deleting an optional reference (like performed_by user on an inventory adjustment) sets the foreign key to NULL.
