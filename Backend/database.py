
import sqlite3
from pathlib import Path
from contextlib import contextmanager

# Project root: Kirana-AI/
PROJECT_ROOT = Path(__file__).resolve().parent.parent

# Existing SQLite database
DB_PATH = PROJECT_ROOT / "database" / "kirana_store.db"


@contextmanager
def get_db_connection():
    if not DB_PATH.is_file():
        raise FileNotFoundError(
            f"Database not found at: {DB_PATH}"
        )

    conn = sqlite3.connect(str(DB_PATH), timeout=10)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")

    try:
        yield conn
    finally:
        conn.close()
