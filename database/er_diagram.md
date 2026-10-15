# AI Kirana Store — ER Diagram

## Entity-Relationship Diagram

```mermaid
erDiagram
    app_users {
        INT user_id PK
        VARCHAR username UK
        VARCHAR full_name
        ENUM role
        BOOLEAN is_active
    }

    categories {
        INT category_id PK
        VARCHAR category_name UK
        VARCHAR description
        BOOLEAN is_active
    }

    suppliers {
        INT supplier_id PK
        VARCHAR supplier_name
        VARCHAR contact_person
        VARCHAR gstin
        INT lead_time_days
    }

    products {
        INT product_id PK
        VARCHAR sku UK
        VARCHAR product_name
        INT category_id FK
        INT supplier_id FK
        DECIMAL cost_price
        DECIMAL selling_price
        DECIMAL current_stock
        DECIMAL min_stock_level
        DATE expiry_date
    }

    sales {
        INT sale_id PK
        VARCHAR invoice_number UK
        DATETIME sale_date
        INT cashier_id FK
        DECIMAL total_amount
        DECIMAL net_amount
        ENUM payment_method
        ENUM status
    }

    sale_items {
        INT sale_item_id PK
        INT sale_id FK
        INT product_id FK
        DECIMAL quantity
        DECIMAL unit_price
        DECIMAL cost_price
        DECIMAL line_total
    }

    purchases {
        INT purchase_id PK
        VARCHAR purchase_number UK
        INT supplier_id FK
        INT received_by FK
        DATETIME purchase_date
        DECIMAL net_amount
        ENUM payment_status
        ENUM status
    }

    purchase_items {
        INT purchase_item_id PK
        INT purchase_id FK
        INT product_id FK
        DECIMAL quantity
        DECIMAL unit_cost
        DECIMAL line_total
        DATE expiry_date
    }

    inventory_movements {
        INT movement_id PK
        INT product_id FK
        ENUM movement_type
        DECIMAL quantity_change
        DECIMAL stock_after
        ENUM reference_type
        INT reference_id
        INT performed_by FK
    }

    ai_insights {
        INT insight_id PK
        INT product_id FK
        ENUM insight_type
        DATE forecast_date
        DECIMAL predicted_demand
        DECIMAL suggested_restock_qty
        DECIMAL confidence_score
        VARCHAR model_version
        ENUM generated_by
    }

    %% Relationships
    categories ||--o{ products : "has many"
    suppliers ||--o{ products : "supplies"
    app_users ||--o{ sales : "processes as cashier"
    sales ||--o{ sale_items : "contains"
    products ||--o{ sale_items : "sold in"
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
| `suppliers` | `purchases` | `supplier_id` | One supplier has many purchase orders | RESTRICT |
| `app_users` | `purchases` | `received_by` | One user receives many purchases | RESTRICT |
| `purchases` | `purchase_items` | `purchase_id` | One purchase has many line items | CASCADE |
| `products` | `purchase_items` | `product_id` | One product appears in many purchase items | RESTRICT |
| `products` | `inventory_movements` | `product_id` | One product has many stock movements | RESTRICT |
| `app_users` | `inventory_movements` | `performed_by` | One user performs many stock changes | SET NULL |
| `products` | `ai_insights` | `product_id` | One product has many AI forecasts | CASCADE |

### What Each Relationship Means (Simple English)

1. **categories → products**: Every product belongs to exactly one category (like "Dairy" or "Grains"). A category can have many products. You cannot delete a category that has products (RESTRICT).

2. **suppliers → products**: A supplier can supply many products. If a supplier is deleted, the product's `supplier_id` becomes NULL (SET NULL) — the product still exists but has no supplier.

3. **app_users → sales**: Every sale is processed by one cashier (an app_user). One cashier can handle many sales. You cannot delete a user who has processed sales.

4. **sales → sale_items**: One bill (sale) contains one or more products (sale_items). If a sale is deleted, all its line items are also deleted (CASCADE).

5. **products → sale_items**: A product can appear on many different bills. You cannot delete a product that has been sold (RESTRICT) — this preserves sales history.

6. **suppliers → purchases**: Purchase orders are placed with suppliers. One supplier can have many purchase orders.

7. **purchases → purchase_items**: One purchase order contains one or more product line items. Deleting a purchase cascades to its items.

8. **products → inventory_movements**: Every stock change (sale, purchase, adjustment, damage) is recorded as a movement against a product.

9. **products → ai_insights**: AI forecasts and suggestions are linked to specific products.

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

    subgraph Sales_Flow["💰 Sales Flow"]
        SAL["sales"]
        SI["sale_items"]
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

## Quick Reference Table

| # | Table | Primary Key | Foreign Keys | Purpose |
|---|---|---|---|---|
| 1 | `app_users` | `user_id` | — | Staff and admin accounts |
| 2 | `categories` | `category_id` | — | Product categories (Dairy, Grains, etc.) |
| 3 | `suppliers` | `supplier_id` | — | Vendor/supplier master data |
| 4 | `products` | `product_id` | `category_id`, `supplier_id` | Product catalog with prices and stock |
| 5 | `sales` | `sale_id` | `cashier_id` | Customer bills/invoices |
| 6 | `sale_items` | `sale_item_id` | `sale_id`, `product_id` | Individual products in each bill |
| 7 | `purchases` | `purchase_id` | `supplier_id`, `received_by` | Supplier purchase orders |
| 8 | `purchase_items` | `purchase_item_id` | `purchase_id`, `product_id` | Products received in each purchase |
| 9 | `inventory_movements` | `movement_id` | `product_id`, `performed_by` | Audit trail of every stock change |
| 10 | `ai_insights` | `insight_id` | `product_id` | AI/SQL demand forecasts and suggestions |

---

## Key Design Decisions

1. **DECIMAL for money**: All prices and amounts use `DECIMAL(10,2)` or `DECIMAL(12,2)` to avoid floating-point rounding errors. Never use `FLOAT` or `DOUBLE` for money.

2. **Snapshot pricing**: `sale_items.unit_price` and `sale_items.cost_price` capture the price **at the time of sale**. If the product price changes later, historical sales still show the original price.

3. **Soft deletes**: `is_active` flags are used instead of deleting records, preserving historical data.

4. **Unique constraints**: `sku`, `invoice_number`, and `purchase_number` are UNIQUE to prevent duplicates.

5. **ON DELETE behavior**:
   - **CASCADE**: Deleting a sale removes its items (they have no meaning without the sale)
   - **RESTRICT**: Cannot delete a product that has been sold (preserves history)
   - **SET NULL**: Deleting a supplier sets the product's `supplier_id` to NULL (product still exists)
