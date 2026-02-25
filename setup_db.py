import psycopg2
from psycopg2 import sql

# Database credentials
DB_NAME = "kobo"
DB_USER = "postgres"
DB_PASS = "LetMeGetaces232823"
DB_HOST = "109.205.181.195"
DB_PORT = "5432"

def setup_database():
    try:
        conn = psycopg2.connect(
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASS,
            host=DB_HOST,
            port=DB_PORT
        )
        cur = conn.cursor()
        
        print("Connected to database successfully!")

        # Alter Users Table to add missing columns if they don't exist
        print("Updating 'users' table schema...")
        alter_statements = [
            "ALTER TABLE users ADD COLUMN IF NOT EXISTS kobo_id VARCHAR(50) UNIQUE;",
            "ALTER TABLE users ADD COLUMN IF NOT EXISTS pin VARCHAR(10);",
            "ALTER TABLE users ADD COLUMN IF NOT EXISTS first_name VARCHAR(100);",
            "ALTER TABLE users ADD COLUMN IF NOT EXISTS surname VARCHAR(100);",
            "ALTER TABLE users ADD COLUMN IF NOT EXISTS business_name VARCHAR(100);",
            "ALTER TABLE users ADD COLUMN IF NOT EXISTS country VARCHAR(50);",
            "ALTER TABLE users ADD COLUMN IF NOT EXISTS role VARCHAR(20) DEFAULT 'user';",
            # We can map existing columns if needed, but for now just adding new ones for compatibility
        ]
        
        for stmt in alter_statements:
            cur.execute(stmt)
            
        # Create Items Table (if not exists)
        cur.execute("""
            CREATE TABLE IF NOT EXISTS items (
                id SERIAL PRIMARY KEY,
                name VARCHAR(100) NOT NULL,
                price INTEGER NOT NULL,
                quantity INTEGER NOT NULL,
                category VARCHAR(50),
                is_service BOOLEAN DEFAULT FALSE,
                user_kobo_id VARCHAR(50), -- Relaxed FK for now as we might have data issues
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        """)

        # Create Sales Table (if not exists)
        cur.execute("""
            CREATE TABLE IF NOT EXISTS sales (
                id SERIAL PRIMARY KEY,
                item_id INTEGER,
                item_name VARCHAR(100),
                quantity INTEGER NOT NULL,
                total INTEGER NOT NULL,
                user_kobo_id VARCHAR(50), 
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        """)

        print("Schema updated successfully.")

        # Create Admin User
        admin_kobo_id = "KOBO-ADMIN"
        admin_pin = "1234" 
        
        cur.execute("SELECT * FROM users WHERE kobo_id = %s", (admin_kobo_id,))
        if cur.fetchone() is None:
            # We need to handle the 'id' column if it's NOT NULL and no default.
            # Inspecting 'id' column type from previous step: 'text'. 
            # We should generate a UUID or unique string for 'id' if needed.
            # Let's check if we can insert without 'id' (if it has default) or provide one.
            # Safe bet: generate a random ID for the admin.
            import uuid
            admin_id = str(uuid.uuid4())
            
            cur.execute("""
                INSERT INTO users (id, kobo_id, pin, first_name, surname, business_name, country, business_type, role)
                VALUES (%s, %s, %s, 'Super', 'Admin', 'Kobo HQ', 'Nigeria', 'Tech', 'admin')
            """, (admin_id, admin_kobo_id, admin_pin))
            print(f"Admin user created: ID={admin_kobo_id}, PIN={admin_pin}")
        else:
            print("Admin user already exists.")

        conn.commit()
        cur.close()
        conn.close()
        return True

    except Exception as e:
        print(f"Error: {e}")
        return False

if __name__ == "__main__":
    setup_database()
