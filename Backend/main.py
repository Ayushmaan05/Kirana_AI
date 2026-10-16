import sqlite3
import uuid
from datetime import datetime
from typing import Literal

from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import Response
from pydantic import BaseModel, Field

from database import DB_PATH, get_db_connection


# =========================
# REQUEST MODELS
# =========================

class SaleItemInput(BaseModel):
    product_id: int = Field(gt=0)
    quantity: float = Field(gt=0)
    discount: float = Field(default=0, ge=0)


class SaleCreate(BaseModel):
    cashier_id: int = Field(gt=0)
    customer_name: str = Field(default="Walk-in Customer", max_length=150)
    customer_phone: str | None = Field(default=None, max_length=20)
    items: list[SaleItemInput] = Field(min_length=1, max_length=100)
    discount_amount: float = Field(default=0, ge=0)
    tax_rate: float = Field(default=0, ge=0, le=100)

    payment_method: Literal["cash", "upi"] = "cash"

    # Required for UPI; unused for cash.
    payment_provider: Literal[
        "PhonePe", "Google Pay", "Paytm", "BHIM", "Other"
    ] | None = None

    transaction_reference_id: str | None = Field(
        default=None, min_length=1, max_length=150
    )
    notes: str | None = Field(default=None, max_length=500)


# =========================
# APP SETUP
# =========================

app = FastAPI(
    title="Kirana AI API",
    description="Backend API for the Kirana AI assistant",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",
        "http://127.0.0.1:5173",
        "http://localhost:5174",
        "http://127.0.0.1:5174",
        "http://localhost:5175",
        "http://127.0.0.1:5175",
        "http://localhost:3000",
        "http://127.0.0.1:3000",
    ],
    allow_origin_regex=r"^https?://(localhost|127\.0\.0\.1)(:\d+)?$",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/favicon.ico", include_in_schema=False)
def favicon():
    return Response(status_code=204)


@app.get("/")
def root():
    return {
        "message": "Kirana AI backend is running",
        "docs": "/docs",
    }


@app.get("/api/health")
def health_check():
    return {
        "status": "ok",
        "service": "Kirana AI Backend",
    }


@app.get("/api/db/status")
def database_status():
    if not DB_PATH.exists():
        raise HTTPException(
            status_code=503,
            detail="SQLite database file not found",
        )

    try:
        with get_db_connection() as conn:
            tables = conn.execute(
                """
                SELECT name
                FROM sqlite_master
                WHERE type = 'table'
                  AND name NOT LIKE 'sqlite_%'
                ORDER BY name
                """
            ).fetchall()

        return {
            "status": "connected",
            "database": DB_PATH.name,
            "tables": [row["name"] for row in tables],
            "table_count": len(tables),
        }
    except sqlite3.Error as exc:
        raise HTTPException(
            status_code=503,
            detail="Unable to query SQLite database",
        ) from exc


# =========================
# CATEGORIES API
# =========================

@app.get("/api/categories")
def get_categories():
    with get_db_connection() as conn:
        rows = conn.execute(
            """
            SELECT category_id, category_name, description
            FROM categories
            WHERE is_active = 1
            ORDER BY category_name
            """
        ).fetchall()

    return [dict(row) for row in rows]


# =========================
# PRODUCTS API
# =========================

@app.get("/api/products")
def get_products(
    search: str | None = Query(default=None, max_length=100),
    category_id: int | None = Query(default=None, ge=1),
    limit: int = Query(default=100, ge=1, le=500),
    offset: int = Query(default=0, ge=0),
):
    sql = """
        SELECT
            p.product_id,
            p.sku,
            p.product_name,
            p.category_id,
            c.category_name,
            p.supplier_id,
            p.brand,
            p.unit,
            p.cost_price,
            p.selling_price,
            p.current_stock,
            p.min_stock_level,
            p.max_stock_level,
            p.expiry_date,
            p.is_active
        FROM products p
        JOIN categories c ON c.category_id = p.category_id
        WHERE p.is_active = 1
    """
    params = []

    if search:
        sql += " AND (p.product_name LIKE ? OR p.sku LIKE ?)"
        term = f"%{search}%"
        params.extend([term, term])

    if category_id is not None:
        sql += " AND p.category_id = ?"
        params.append(category_id)

    sql += " ORDER BY p.product_name LIMIT ? OFFSET ?"
    params.extend([limit, offset])

    with get_db_connection() as conn:
        rows = conn.execute(sql, params).fetchall()

    return [dict(row) for row in rows]


@app.get("/api/products/{product_id}")
def get_product(product_id: int):
    with get_db_connection() as conn:
        row = conn.execute(
            """
            SELECT
                p.*,
                c.category_name,
                s.supplier_name
            FROM products p
            JOIN categories c ON c.category_id = p.category_id
            LEFT JOIN suppliers s ON s.supplier_id = p.supplier_id
            WHERE p.product_id = ?
              AND p.is_active = 1
            """,
            (product_id,),
        ).fetchone()

    if row is None:
        raise HTTPException(status_code=404, detail="Product not found")

    return dict(row)


# =========================
# INVENTORY API
# =========================

@app.get("/api/inventory/low-stock")
def get_low_stock():
    with get_db_connection() as conn:
        rows = conn.execute(
            """
            SELECT *
            FROM vw_low_stock_products
            ORDER BY shortage_qty DESC
            """
        ).fetchall()

    return [dict(row) for row in rows]


@app.get("/api/inventory/expiring")
def get_expiring_products():
    with get_db_connection() as conn:
        rows = conn.execute(
            """
            SELECT *
            FROM vw_expiring_soon
            ORDER BY expiry_date ASC
            """
        ).fetchall()

    return [dict(row) for row in rows]


@app.get("/api/inventory/valuation")
def get_inventory_valuation():
    with get_db_connection() as conn:
        summary = conn.execute(
            """
            SELECT
                COUNT(*) AS product_count,
                COALESCE(SUM(current_stock), 0) AS total_units,
                ROUND(COALESCE(SUM(current_stock * cost_price), 0), 2)
                    AS total_cost_value,
                ROUND(COALESCE(SUM(current_stock * selling_price), 0), 2)
                    AS total_selling_value
            FROM products
            WHERE is_active = 1
            """
        ).fetchone()

    return dict(summary)


# =========================
# CREATE SALE / GENERATE BILL
# =========================

@app.post("/api/sales", status_code=201)
def create_sale(sale: SaleCreate):
    conn = None

    try:
        conn = sqlite3.connect(str(DB_PATH), timeout=10)
        conn.row_factory = sqlite3.Row
        conn.execute("PRAGMA foreign_keys = ON")
        conn.execute("BEGIN IMMEDIATE")

        # Validate payment details.
        if sale.payment_method == "upi":
            if not sale.payment_provider:
                raise HTTPException(
                    status_code=400,
                    detail="UPI payment provider is required.",
                )
            if not sale.transaction_reference_id or not sale.transaction_reference_id.strip():
                raise HTTPException(
                    status_code=400,
                    detail="UPI transaction reference is required.",
                )
        elif sale.payment_method == "cash":
            if sale.payment_provider or sale.transaction_reference_id:
                raise HTTPException(
                    status_code=400,
                    detail="UPI details must not be supplied for cash payments.",
                )

        # 1. Validate cashier.
        cashier = conn.execute(
            """
            SELECT user_id
            FROM app_users
            WHERE user_id = ? AND is_active = 1
            """,
            (sale.cashier_id,),
        ).fetchone()

        if cashier is None:
            raise HTTPException(
                status_code=400,
                detail="Invalid or inactive cashier",
            )

        # 2. Validate products, prices, discounts, and stock.
        prepared_items = []
        subtotal = 0.0
        item_discount_total = 0.0

        for item in sale.items:
            product = conn.execute(
                """
                SELECT product_id, product_name, sku,
                       selling_price, cost_price, current_stock
                FROM products
                WHERE product_id = ? AND is_active = 1
                """,
                (item.product_id,),
            ).fetchone()

            if product is None:
                raise HTTPException(
                    status_code=404,
                    detail=f"Product {item.product_id} not found",
                )

            quantity = item.quantity
            unit_price = float(product["selling_price"])
            cost_price = float(product["cost_price"])
            current_stock = float(product["current_stock"])

            if quantity > current_stock:
                raise HTTPException(
                    status_code=400,
                    detail=(
                        f"Insufficient stock for {product['product_name']}. "
                        f"Available: {current_stock}"
                    ),
                )

            gross_line = round(quantity * unit_price, 2)
            line_discount = round(item.discount, 2)

            if line_discount > gross_line:
                raise HTTPException(
                    status_code=400,
                    detail=f"Discount exceeds line amount for {product['product_name']}",
                )

            line_total = round(gross_line - line_discount, 2)

            prepared_items.append({
                "product_id": item.product_id,
                "product_name": product["product_name"],
                "quantity": quantity,
                "unit_price": unit_price,
                "cost_price": cost_price,
                "discount": line_discount,
                "line_total": line_total,
            })

            subtotal += gross_line
            item_discount_total += line_discount

        subtotal = round(subtotal, 2)
        item_discount_total = round(item_discount_total, 2)

        # 3. Calculate final bill.
        bill_discount = round(sale.discount_amount, 2)
        remaining_after_item_discount = round(
            subtotal - item_discount_total, 2
        )

        if bill_discount > remaining_after_item_discount:
            raise HTTPException(
                status_code=400,
                detail="Bill discount exceeds the remaining bill amount",
            )

        taxable_amount = round(
            remaining_after_item_discount - bill_discount, 2
        )
        tax_amount = round(taxable_amount * sale.tax_rate / 100, 2)
        total_discount = round(item_discount_total + bill_discount, 2)
        net_amount = round(taxable_amount + tax_amount, 2)

        # 4. Create sale header.
        invoice_number = (
            "KIR-"
            + datetime.now().strftime("%Y%m%d")
            + "-"
            + uuid.uuid4().hex[:8].upper()
        )

        cursor = conn.execute(
            """
            INSERT INTO sales (
                invoice_number, customer_name, customer_phone,
                cashier_id, total_amount, discount_amount,
                tax_amount, net_amount, payment_method, status, notes
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'completed', ?)
            """,
            (
                invoice_number,
                sale.customer_name,
                sale.customer_phone,
                sale.cashier_id,
                subtotal,
                total_discount,
                tax_amount,
                net_amount,
                sale.payment_method,
                sale.notes,
            ),
        )
        sale_id = cursor.lastrowid

        # 5. Insert items, deduct stock, and record inventory movements.
        for item in prepared_items:
            conn.execute(
                """
                INSERT INTO sale_items (
                    sale_id, product_id, quantity,
                    unit_price, cost_price, discount, line_total
                )
                VALUES (?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    sale_id,
                    item["product_id"],
                    item["quantity"],
                    item["unit_price"],
                    item["cost_price"],
                    item["discount"],
                    item["line_total"],
                ),
            )

            conn.execute(
                """
                UPDATE products
                SET current_stock = current_stock - ?
                WHERE product_id = ?
                """,
                (item["quantity"], item["product_id"]),
            )

            new_stock = conn.execute(
                "SELECT current_stock FROM products WHERE product_id = ?",
                (item["product_id"],),
            ).fetchone()["current_stock"]

            conn.execute(
                """
                INSERT INTO inventory_movements (
                    product_id, movement_type, quantity_change,
                    stock_after, reference_type, reference_id,
                    performed_by, remarks
                )
                VALUES (?, 'sale', ?, ?, 'sale', ?, ?, ?)
                """,
                (
                    item["product_id"],
                    -item["quantity"],
                    new_stock,
                    sale_id,
                    sale.cashier_id,
                    f"Sale invoice {invoice_number}",
                ),
            )

        # 6. Record payment ONCE per sale, outside the item loop.
        if sale.payment_method == "cash":
            # Exact-amount cash checkout; no change is returned.
            conn.execute(
                """
                INSERT INTO cash_payments (
                    sale_id, cashier_id, amount_tendered,
                    amount_received, change_returned, payment_status
                )
                VALUES (?, ?, ?, ?, 0, 'completed')
                """,
                (
                    sale_id,
                    sale.cashier_id,
                    net_amount,
                    net_amount,
                ),
            )

        elif sale.payment_method == "upi":
            # Use this path only after the cashier has manually confirmed
            # that payment was received. This is not gateway verification.
            conn.execute(
                """
                INSERT INTO online_payments (
                    sale_id, payment_platform, provider,
                    transaction_reference_id, amount,
                    payment_status, settlement_status, notes
                )
                VALUES (?, 'qr_code', ?, ?, ?, 'success', 'pending', ?)
                """,
                (
                    sale_id,
                    sale.payment_provider,
                    sale.transaction_reference_id.strip(),
                    net_amount,
                    "QR payment manually confirmed by cashier",
                ),
            )

        # 7. Commit sale, stock, inventory movements, and payment together.
        conn.commit()

        return {
            "success": True,
            "message": "Sale created successfully",
            "sale_id": sale_id,
            "invoice_number": invoice_number,
            "items": prepared_items,
            "subtotal": subtotal,
            "discount_amount": total_discount,
            "tax_rate": sale.tax_rate,
            "tax_amount": tax_amount,
            "net_amount": net_amount,
            "payment_method": sale.payment_method,
        }

    except HTTPException:
        if conn is not None:
            conn.rollback()
        raise

    except sqlite3.IntegrityError as exc:
        if conn is not None:
            conn.rollback()
        raise HTTPException(
            status_code=400,
            detail=f"Database constraint failed: {exc}",
        ) from exc

    except sqlite3.Error as exc:
        if conn is not None:
            conn.rollback()
        raise HTTPException(
            status_code=500,
            detail="Database operation failed",
        ) from exc

    finally:
        if conn is not None:
            conn.close()


# ==============================
# SALES HISTORY
# ==============================

# =========================
# DASHBOARD API
# =========================

@app.get("/api/dashboard")
def get_dashboard():
    with get_db_connection() as conn:
        # ── Today's sales summary ──
        today_row = conn.execute(
            """
            SELECT
                COALESCE(SUM(net_amount), 0)       AS today_sales,
                COUNT(*)                            AS today_transactions,
                COALESCE(SUM(discount_amount), 0)   AS today_discounts,
                COALESCE(SUM(tax_amount), 0)        AS today_tax
            FROM sales
            WHERE DATE(sale_date) = DATE('now')
              AND status = 'completed'
            """
        ).fetchone()

        today_sales = float(today_row["today_sales"])
        today_transactions = int(today_row["today_transactions"])

        # ── Yesterday's sales (for change %) ──
        yesterday_row = conn.execute(
            """
            SELECT COALESCE(SUM(net_amount), 0) AS yesterday_sales
            FROM sales
            WHERE DATE(sale_date) = DATE('now', '-1 day')
              AND status = 'completed'
            """
        ).fetchone()
        yesterday_sales = float(yesterday_row["yesterday_sales"])

        if yesterday_sales > 0:
            sales_pct = round(
                ((today_sales - yesterday_sales) / yesterday_sales) * 100
            )
            sales_change = f"{'+' if sales_pct >= 0 else ''}{sales_pct}%"
        else:
            sales_change = "+0%" if today_sales == 0 else "+100%"

        # ── Weekly data (last 7 days) ──
        weekly_rows = conn.execute(
            """
            SELECT
                CASE CAST(strftime('%w', sale_day) AS INTEGER)
                    WHEN 0 THEN 'Sun' WHEN 1 THEN 'Mon' WHEN 2 THEN 'Tue'
                    WHEN 3 THEN 'Wed' WHEN 4 THEN 'Thu' WHEN 5 THEN 'Fri'
                    WHEN 6 THEN 'Sat'
                END AS day,
                COALESCE(SUM(net_amount), 0) AS sales
            FROM (
                SELECT DATE('now', '-6 days') AS sale_day
                UNION ALL SELECT DATE('now', '-5 days')
                UNION ALL SELECT DATE('now', '-4 days')
                UNION ALL SELECT DATE('now', '-3 days')
                UNION ALL SELECT DATE('now', '-2 days')
                UNION ALL SELECT DATE('now', '-1 days')
                UNION ALL SELECT DATE('now')
            ) days
            LEFT JOIN sales s
                ON DATE(s.sale_date) = days.sale_day
                AND s.status = 'completed'
            GROUP BY days.sale_day
            ORDER BY days.sale_day
            """
        ).fetchall()
        weekly_data = [
            {"day": row["day"], "sales": round(float(row["sales"]), 2), "expenses": 0}
            for row in weekly_rows
        ]

        # ── Top products (by revenue, last 30 days) ──
        top_rows = conn.execute(
            """
            SELECT
                p.product_name AS name,
                CAST(SUM(si.quantity) AS INTEGER) AS sales,
                ROUND(SUM(si.line_total), 2) AS revenue
            FROM sale_items si
            JOIN products p ON p.product_id = si.product_id
            JOIN sales s ON s.sale_id = si.sale_id
            WHERE s.status = 'completed'
              AND DATE(s.sale_date) >= DATE('now', '-30 days')
            GROUP BY p.product_id, p.product_name
            ORDER BY revenue DESC
            LIMIT 5
            """
        ).fetchall()
        top_products = [dict(row) for row in top_rows]

        # ── Low stock count ──
        low_stock_row = conn.execute(
            """
            SELECT COUNT(*) AS cnt
            FROM products
            WHERE current_stock < min_stock_level
              AND is_active = 1
            """
        ).fetchone()
        low_stock_count = int(low_stock_row["cnt"])

        # ── Recent transactions (last 5 sales) ──
        recent_rows = conn.execute(
            """
            SELECT
                s.sale_id      AS id,
                'sale'         AS type,
                s.customer_name,
                s.net_amount   AS amount,
                s.payment_method AS payment_mode,
                s.sale_date    AS created_at,
                s.status,
                GROUP_CONCAT(p.product_name, ', ') AS description
            FROM sales s
            LEFT JOIN sale_items si ON si.sale_id = s.sale_id
            LEFT JOIN products p   ON p.product_id = si.product_id
            WHERE s.status = 'completed'
            GROUP BY s.sale_id
            ORDER BY s.sale_id DESC
            LIMIT 5
            """
        ).fetchall()
        recent_transactions = [dict(row) for row in recent_rows]

        # ── Inventory valuation ──
        valuation = conn.execute(
            """
            SELECT
                ROUND(COALESCE(SUM(current_stock * selling_price), 0), 2)
                    AS total_inventory_value
            FROM products
            WHERE is_active = 1
            """
        ).fetchone()

    return {
        "todaySales": today_sales,
        "todayRevenue": today_sales,
        "todayTransactions": today_transactions,
        "todayExpenses": 0,
        "outstandingCredit": 0,
        "totalInventoryValue": float(valuation["total_inventory_value"]),
        "salesChange": sales_change,
        "expenseChange": "+0%",
        "creditChange": "+0%",
        "weeklyData": weekly_data,
        "topProducts": top_products,
        "lowStockCount": low_stock_count,
        "recentTransactions": recent_transactions,
    }


# ==============================
# SALES HISTORY
# ==============================

@app.get("/api/sales")
def get_sales(
    limit: int = Query(default=20, ge=1, le=100),
    offset: int = Query(default=0, ge=0),
):
    with get_db_connection() as conn:
        rows = conn.execute(
            """
            SELECT
                sale_id,
                invoice_number,
                sale_date,
                customer_name,
                cashier_id,
                total_amount,
                discount_amount,
                tax_amount,
                net_amount,
                payment_method,
                status
            FROM sales
            ORDER BY sale_id DESC
            LIMIT ? OFFSET ?
            """,
            (limit, offset),
        ).fetchall()

    return {
        "success": True,
        "count": len(rows),
        "sales": [dict(row) for row in rows],
    }


@app.get("/api/sales/{sale_id}")
def get_sale_detail(sale_id: int):
    with get_db_connection() as conn:
        sale = conn.execute(
            "SELECT * FROM sales WHERE sale_id = ?",
            (sale_id,),
        ).fetchone()

        if sale is None:
            raise HTTPException(status_code=404, detail="Sale not found")

        items = conn.execute(
            """
            SELECT
                si.sale_item_id,
                si.product_id,
                p.product_name,
                p.sku,
                si.quantity,
                si.unit_price,
                si.cost_price,
                si.discount,
                si.line_total
            FROM sale_items si
            JOIN products p ON p.product_id = si.product_id
            WHERE si.sale_id = ?
            ORDER BY si.sale_item_id
            """,
            (sale_id,),
        ).fetchall()

        cash_payments = conn.execute(
            """
            SELECT *
            FROM cash_payments
            WHERE sale_id = ?
            ORDER BY cash_payment_id
            """,
            (sale_id,),
        ).fetchall()

        upi_payments = conn.execute(
            """
            SELECT *
            FROM online_payments
            WHERE sale_id = ?
            ORDER BY online_payment_id
            """,
            (sale_id,),
        ).fetchall()

    return {
        "success": True,
        "sale": dict(sale),
        "items": [dict(row) for row in items],
        "cash_payments": [dict(row) for row in cash_payments],
        "upi_payments": [dict(row) for row in upi_payments],
    }
