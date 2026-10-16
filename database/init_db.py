#!/usr/bin/env python3
"""
AI Kirana Store — Database Initializer & Verification Utility
File       : init_db.py
Description: Creates the SQLite database (kirana_store.db), loads schema.sql,
             populates sample_data.sql, and optionally runs test verification.
Usage      :
    python database/init_db.py          # Initialize DB with schema and sample data
    python database/init_db.py --test   # Initialize and run test verification
    python database/init_db.py --stats  # Display current database table counts
"""

import sys
import os
import sqlite3
import argparse
from pathlib import Path

# Ensure UTF-8 output on Windows consoles
if sys.stdout.encoding != "utf-8":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass

BASE_DIR = Path(__file__).resolve().parent
DB_FILE = BASE_DIR / "kirana_store.db"
SCHEMA_FILE = BASE_DIR / "schema.sql"
SAMPLE_DATA_FILE = BASE_DIR / "sample_data.sql"
TESTING_FILE = BASE_DIR / "database_testing.sql"


def get_connection(db_path=DB_FILE):
    """Establish connection to SQLite database with foreign keys enabled."""
    conn = sqlite3.connect(db_path)
    conn.execute("PRAGMA foreign_keys = ON;")
    return conn


def init_database(db_path=DB_FILE, load_sample=True):
    """Create tables, triggers, views, and load sample data."""
    if db_path.exists():
        print(f"[*] Removing existing database at: {db_path}")
        db_path.unlink()

    print(f"[*] Creating new SQLite database at: {db_path}")
    conn = get_connection(db_path)

    # 1. Apply Schema
    print(f"[*] Applying schema from: {SCHEMA_FILE.name}")
    with open(SCHEMA_FILE, "r", encoding="utf-8") as f:
        schema_sql = f.read()
    conn.executescript(schema_sql)
    print("    [OK] Schema applied successfully.")

    # 2. Apply Sample Data
    if load_sample and SAMPLE_DATA_FILE.exists():
        print(f"[*] Populating sample data from: {SAMPLE_DATA_FILE.name}")
        with open(SAMPLE_DATA_FILE, "r", encoding="utf-8") as f:
            sample_sql = f.read()
        conn.executescript(sample_sql)
        print("    [OK] Sample data populated successfully.")

    conn.close()


def print_stats(db_path=DB_FILE):
    """Print table row counts and views overview."""
    if not db_path.exists():
        print(f"[!] Database file not found at {db_path}. Run without --stats first.")
        return

    conn = get_connection(db_path)
    cur = conn.cursor()

    cur.execute("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name;")
    tables = [row[0] for row in cur.fetchall()]

    print("\n" + "=" * 50)
    print(f"DATABASE SUMMARY: {db_path.name}")
    print("=" * 50)
    print(f"{'Table Name':<25} | {'Row Count':>10}")
    print("-" * 50)

    total_rows = 0
    for tbl in tables:
        count = cur.execute(f"SELECT COUNT(*) FROM {tbl};").fetchone()[0]
        total_rows += count
        print(f"{tbl:<25} | {count:>10}")

    print("-" * 50)
    print(f"{'Total (12 Tables)':<25} | {total_rows:>10}")

    cur.execute("SELECT name FROM sqlite_master WHERE type='view' ORDER BY name;")
    views = [row[0] for row in cur.fetchall()]
    print("\nVIEWS DEFINED (" + str(len(views)) + "):")
    for v in views:
        print(f"  - {v}")

    conn.close()


def run_tests(db_path=DB_FILE):
    """Run database testing suite."""
    print("\n[*] Running test suite from: database_testing.sql")
    conn = get_connection(db_path)
    with open(TESTING_FILE, "r", encoding="utf-8") as f:
        test_sql = f.read()

    try:
        conn.executescript(test_sql)
        print("    [OK] All tests in database_testing.sql passed successfully!")
    except Exception as e:
        print(f"    [FAIL] Test failed: {e}")
        conn.close()
        sys.exit(1)

    conn.close()


def main():
    parser = argparse.ArgumentParser(description="AI Kirana Store SQLite Database Manager")
    parser.add_argument("--test", action="store_true", help="Run testing suite after initialization")
    parser.add_argument("--stats", action="store_true", help="Print table counts only")
    parser.add_argument("--no-sample", action="store_true", help="Do not load sample data")
    args = parser.parse_args()

    if args.stats:
        print_stats()
        return

    init_database(DB_FILE, load_sample=not args.no_sample)
    print_stats(DB_FILE)

    if args.test:
        run_tests(DB_FILE)


if __name__ == "__main__":
    main()
