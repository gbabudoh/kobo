import psycopg2

# Database credentials
DB_NAME = "kobo"
DB_USER = "postgres"
DB_PASS = "LetMeGetaces232823"
DB_HOST = "109.205.181.195"
DB_PORT = "5432"

def inspect_schema():
    try:
        conn = psycopg2.connect(
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASS,
            host=DB_HOST,
            port=DB_PORT
        )
        cur = conn.cursor()
        
        print("Connected. Inspecting 'users' table columns...")
        cur.execute("""
            SELECT column_name, data_type 
            FROM information_schema.columns 
            WHERE table_name = 'users';
        """)
        
        columns = cur.fetchall()
        if not columns:
            print("Table 'users' does not exist (or no columns found).")
        else:
            for col in columns:
                print(f" - {col[0]}: {col[1]}")

        conn.close()

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    inspect_schema()
