import psycopg2
import sys
import os

def apply_sql():
    conn_str = os.environ.get("DATABASE_URL", "").strip()
    sql_file = os.environ.get("SQL_FILE", "database/add_external_dbs.sql")

    if not conn_str:
        print("Error: DATABASE_URL environment variable is required.")
        sys.exit(1)

    try:
        conn = psycopg2.connect(conn_str)
        conn.autocommit = True
        with conn.cursor() as cur:
            with open(sql_file, "r") as f:
                sql = f.read()
                cur.execute(sql)
        print("SQL migration applied successfully.")
        conn.close()
    except Exception as e:
        print(f"Error applying SQL: {e}")
        sys.exit(1)

if __name__ == "__main__":
    apply_sql()
