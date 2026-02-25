const { Pool } = require('pg');

const pool = new Pool({
    user: 'postgres',
    host: '109.205.181.195',
    database: 'kobo',
    password: 'LetMeGetaces232823',
    port: 5432,
});

const schema = `
CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    owner_name TEXT,
    shop_name TEXT,
    phone TEXT,
    state TEXT,
    city TEXT,
    business_type TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS items (
    id TEXT PRIMARY KEY,
    user_id TEXT REFERENCES users(id),
    name TEXT,
    price INT,
    quantity INT,
    is_service BOOLEAN,
    category TEXT,
    cost_price INT
);

CREATE TABLE IF NOT EXISTS sales (
    id TEXT PRIMARY KEY,
    user_id TEXT REFERENCES users(id),
    item_id TEXT,
    item_name TEXT,
    total INT,
    quantity INT,
    payment_method TEXT,
    created_at TIMESTAMP
);
`;

async function initDb() {
    try {
        console.log('Connecting to database...');
        await pool.query(schema);
        console.log('Database schema initialized successfully!');
    } catch (err) {
        console.error('Error initializing database:', err);
    } finally {
        await pool.end();
    }
}

initDb();
