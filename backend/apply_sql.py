import psycopg2
import sys

def apply_sql():
    conn_str = "postgresql://postgres:Medifindsdgp12345@db.zdgugonfvsadghkijfnh.supabase.co:5432/postgres"
    sql_file = "database/add_external_dbs.sql"

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
