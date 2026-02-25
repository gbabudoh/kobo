/**
 * KOBBO VPS API (Middleware)
 * 
 * Instructions:
 * 1. Install Node.js on your VPS.
 * 2. Create a folder and run: npm init -y && npm install express pg body-parser cors
 * 3. Save this file as index.js
 * 4. Run the SQL script below in your PostgreSQL database.
 * 5. Start the server: node index.js
 */

const express = require('express');
const { Pool } = require('pg');
const bodyParser = require('body-parser');
const cors = require('cors');
const crypto = require('crypto');

const app = express();
const port = 3000;

app.use(cors()); // Basic cors
// Add explicit headers for deeper compatibility
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');

    // Log all incoming requests
    console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);

    if (req.method === 'OPTIONS') {
        return res.sendStatus(200);
    }
    next();
});
app.use(bodyParser.json());
// Serve static files from the 'public' directory (where Flutter Web build goes)
app.use(express.static('public'));

// PostgreSQL Connection configuration
// UPDATE THESE WITH YOUR ACTUAL VPS DB DETAILS
const pool = new Pool({
    user: 'postgres',
    host: '109.205.181.195',
    database: 'kobo',
    password: 'LetMeGetaces232823',
    port: 5432,
});

// --- SQL SCHEMA (Run this in psql) ---
/*
CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    kobo_id TEXT UNIQUE,
    owner_name TEXT,
    first_name TEXT,
    surname TEXT,
    shop_name TEXT,
    business_name TEXT,
    phone TEXT,
    pin TEXT,
    state TEXT,
    city TEXT,
    country TEXT DEFAULT 'Nigeria',
    business_type TEXT,
    role TEXT DEFAULT 'user',
    is_pro BOOLEAN DEFAULT FALSE,
    account_status TEXT DEFAULT 'active',
    last_login TIMESTAMP,
    device_info JSONB,
    admin_notes TEXT,
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

CREATE TABLE IF NOT EXISTS login_history (
    id SERIAL PRIMARY KEY,
    user_id TEXT REFERENCES users(id),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address TEXT,
    successful BOOLEAN,
    device_info JSONB
);
*/

// API Endpoints

// 1. Sync User Profile
app.post('/sync/profile', async (req, res) => {
    const profile = req.body;
    try {
        await pool.query(
            `INSERT INTO users (id, owner_name, shop_name, phone, state, city, business_type) 
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       ON CONFLICT (id) DO UPDATE SET 
       owner_name = EXCLUDED.owner_name, 
       shop_name = EXCLUDED.shop_name,
       state = EXCLUDED.state`,
            [profile.id, profile.ownerName, profile.shopName, profile.phoneNumber, profile.state, profile.city, profile.businessType]
        );
        res.status(200).json({ status: 'success' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});

// 2. Sync Items (Bulk)
app.post('/sync/items', async (req, res) => {
    const { userId, items } = req.body;
    try {
        for (const item of items) {
            await pool.query(
                `INSERT INTO items (id, user_id, name, price, quantity, is_service, category, cost_price) 
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
         ON CONFLICT (id) DO UPDATE SET 
         name = EXCLUDED.name, 
         price = EXCLUDED.price,
         quantity = EXCLUDED.quantity`,
                [item.id, userId, item.name, item.price, item.quantity, item.isService, item.category, item.costPrice]
            );
        }
        res.status(200).json({ status: 'success' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});

// 3. Sync Sales (Bulk)
app.post('/sync/sales', async (req, res) => {
    const { userId, sales } = req.body;
    try {
        for (const sale of sales) {
            await pool.query(
                `INSERT INTO sales (id, user_id, item_id, item_name, total, quantity, payment_method, created_at) 
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
         ON CONFLICT (id) DO NOTHING`,
                [sale.id, userId, sale.itemId, sale.itemName, sale.total, sale.quantity, sale.paymentMethod, sale.date]
            );
        }
        res.status(200).json({ status: 'success' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});

// 1. Auth - Register User
app.post('/auth/register', async (req, res) => {
    const { koboId, firstName, surname, businessName, pin, country, businessType, createdAt, role } = req.body;
    const id = crypto.randomUUID();
    try {
        await pool.query(
            `INSERT INTO users (id, kobo_id, first_name, surname, business_name, pin, country, business_type, created_at, role)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
            [id, koboId, firstName, surname, businessName, pin, country, businessType, createdAt || new Date(), role || 'user']
        );
        res.status(201).json({ message: 'User registered successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});

// 2. Auth - Login
app.post('/auth/login', async (req, res) => {
    const { koboId, pin, deviceInfo } = req.body;
    const ipAddress = req.ip || req.headers['x-forwarded-for'] || req.connection.remoteAddress;

    try {
        // Hardcoded Master Admin for recovery/initial access
        if (koboId === 'KOBO-ADMIN' && pin === '1234') {
            return res.json({
                status: 'success',
                user: {
                    kobo_id: 'KOBO-ADMIN',
                    first_name: 'Master',
                    surname: 'Admin',
                    business_name: 'Kobo HQ',
                    pin: '1234',
                    country: 'Nigeria',
                    business_type: 'Headquarters',
                    created_at: new Date().toISOString(),
                    role: 'admin'
                }
            });
        }

        const result = await pool.query(
            'SELECT * FROM users WHERE kobo_id = $1 AND pin = $2',
            [koboId, pin]
        );

        const successful = result.rows.length > 0;
        const user = successful ? result.rows[0] : null;

        // Record login history (if user exists, even if password wrong, track against their ID if possible)
        // For security, if multiple failed attempts, we can lock.
        if (user) {
            await pool.query(
                'UPDATE users SET last_login = CURRENT_TIMESTAMP, device_info = $1 WHERE id = $2',
                [deviceInfo, user.id]
            );
            await pool.query(
                'INSERT INTO login_history (user_id, ip_address, successful, device_info) VALUES ($1, $2, $3, $4)',
                [user.id, ipAddress, successful, deviceInfo]
            );
        }

        if (successful) {
            res.json({ status: 'success', user: user });
        } else {
            res.status(401).json({ status: 'error', message: 'Invalid credentials' });
        }
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});

// 5. Admin Stats
app.get('/admin/stats', async (req, res) => {
    try {
        const userCount = await pool.query('SELECT COUNT(*) FROM users');
        const salesSum = await pool.query('SELECT SUM(total) FROM sales');

        res.json({
            users: parseInt(userCount.rows[0].count),
            sales: parseInt(salesSum.rows[0].sum || 0)
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});

// 6. List All Users with Advanced Filtering & Search
app.get('/admin/users', async (req, res) => {
    const { search, country, category, status, tier, role } = req.query;

    let query = 'SELECT * FROM users WHERE 1=1';
    const params = [];

    if (search) {
        params.push(`%${search.toLowerCase()}%`);
        query += ` AND (LOWER(owner_name) LIKE $${params.length} OR LOWER(shop_name) LIKE $${params.length} OR LOWER(kobo_id) LIKE $${params.length} OR LOWER(business_name) LIKE $${params.length})`;
    }

    if (country) {
        params.push(country);
        query += ` AND country = $${params.length}`;
    }

    if (category) {
        params.push(category);
        query += ` AND business_type = $${params.length}`;
    }

    if (status) {
        params.push(status);
        query += ` AND account_status = $${params.length}`;
    }

    if (tier) {
        const isPro = tier === 'premium';
        params.push(isPro);
        query += ` AND is_pro = $${params.length}`;
    }

    if (role) {
        params.push(role);
        query += ` AND role = $${params.length}`;
    }

    query += ' ORDER BY created_at DESC';

    try {
        const result = await pool.query(query, params);
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});

// 7. Reset User PIN
app.post('/admin/users/reset-pin', async (req, res) => {
    const { koboId, newPin } = req.body;
    try {
        await pool.query('UPDATE users SET pin = $1 WHERE kobo_id = $2', [newPin, koboId]);
        res.json({ status: 'success' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});

// 8. Terminate User Account
app.post('/admin/users/terminate', async (req, res) => {
    const { koboId } = req.body;
    try {
        const userRes = await pool.query('SELECT id FROM users WHERE kobo_id = $1', [koboId]);
        if (userRes.rows.length === 0) return res.status(404).json({ error: 'User not found' });
        const uuid = userRes.rows[0].id;

        await pool.query('DELETE FROM sales WHERE user_id = $1', [uuid]);
        await pool.query('DELETE FROM items WHERE user_id = $1', [uuid]);
        await pool.query('DELETE FROM users WHERE id = $1', [uuid]);

        res.json({ status: 'success' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});

// 9. Detailed Analytics
app.get('/admin/analytics', async (req, res) => {
    try {
        const stats = await pool.query(`
            SELECT 
                (SELECT COUNT(*) FROM users) as total_users,
                (SELECT COALESCE(SUM(total), 0) FROM sales) as total_revenue,
                (SELECT COUNT(*) FROM sales) as total_sales,
                (SELECT COUNT(*) FROM items) as total_items
        `);

        const salesPerDay = await pool.query(`
            SELECT DATE_TRUNC('day', created_at) as day, SUM(total) as daily_total
            FROM sales
            GROUP BY day
            ORDER BY day DESC
            LIMIT 7
        `);

        res.json({
            summary: {
                totalUsers: parseInt(stats.rows[0].total_users),
                totalRevenue: parseInt(stats.rows[0].total_revenue),
                totalSales: parseInt(stats.rows[0].total_sales),
                totalItems: parseInt(stats.rows[0].total_items)
            },
            salesHistory: salesPerDay.rows
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});

// 10. Activate Subscription
app.post('/subscription/activate', async (req, res) => {
    const { koboId } = req.body;
    try {
        await pool.query('UPDATE users SET is_pro = TRUE WHERE kobo_id = $1', [koboId]);
        res.json({ status: 'success', message: 'Subscription activated' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});

// --- SCHEMA AUTOMATION ---
async function ensureSchema() {
    try {
        await pool.query(`
            DO $$ 
            BEGIN 
                -- users table extensions
                IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='kobo_id') THEN
                    ALTER TABLE users ADD COLUMN kobo_id TEXT UNIQUE;
                END IF;
                IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='account_status') THEN
                    ALTER TABLE users ADD COLUMN account_status TEXT DEFAULT 'active';
                END IF;
                IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='last_login') THEN
                    ALTER TABLE users ADD COLUMN last_login TIMESTAMP;
                END IF;
                IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='device_info') THEN
                    ALTER TABLE users ADD COLUMN device_info JSONB;
                END IF;
                IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='admin_notes') THEN
                    ALTER TABLE users ADD COLUMN admin_notes TEXT;
                END IF;
                IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='country') THEN
                    ALTER TABLE users ADD COLUMN country TEXT DEFAULT 'Nigeria';
                END IF;
                IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='role') THEN
                    ALTER TABLE users ADD COLUMN role TEXT DEFAULT 'user';
                END IF;
                IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='first_name') THEN
                    ALTER TABLE users ADD COLUMN first_name TEXT;
                END IF;
                IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='surname') THEN
                    ALTER TABLE users ADD COLUMN surname TEXT;
                END IF;
                IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='business_name') THEN
                    ALTER TABLE users ADD COLUMN business_name TEXT;
                END IF;
                IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='pin') THEN
                    ALTER TABLE users ADD COLUMN pin TEXT;
                END IF;

                -- login_history table
                CREATE TABLE IF NOT EXISTS login_history (
                    id SERIAL PRIMARY KEY,
                    user_id TEXT REFERENCES users(id),
                    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    ip_address TEXT,
                    successful BOOLEAN,
                    device_info JSONB
                );
            END $$;
        `);
        console.log('✅ Database schema verified and updated.');
    } catch (err) {
        console.error('❌ Schema Sync Error:', err);
    }
}

// 11. Get User Details & Engagement
app.get('/admin/users/:koboId/details', async (req, res) => {
    const { koboId } = req.params;
    try {
        const userRes = await pool.query('SELECT * FROM users WHERE kobo_id = $1', [koboId]);
        if (userRes.rows.length === 0) return res.status(404).json({ error: 'User not found' });
        const user = userRes.rows[0];
        const uuid = user.id;

        const itemsRes = await pool.query('SELECT * FROM items WHERE user_id = $1', [uuid]);
        const salesRes = await pool.query('SELECT * FROM sales WHERE user_id = $1 ORDER BY created_at DESC LIMIT 50', [uuid]);

        // Activity & Engagement
        const firstSaleRes = await pool.query('SELECT MIN(created_at) FROM sales WHERE user_id = $1', [uuid]);
        const lastSaleRes = await pool.query('SELECT MAX(created_at) FROM sales WHERE user_id = $1', [uuid]);
        const daysActiveRes = await pool.query(`
            SELECT COUNT(DISTINCT DATE_TRUNC('day', created_at)) as days
            FROM (
                SELECT created_at FROM sales WHERE user_id = $1
                UNION 
                SELECT timestamp as created_at FROM login_history WHERE user_id = $1
            ) as activity
        `, [uuid]);

        // Loan Readiness Heuristic
        const totalSales = salesRes.rows.length;
        const distinctMonths = await pool.query(`
            SELECT COUNT(DISTINCT DATE_TRUNC('month', created_at)) as months 
            FROM sales WHERE user_id = $1
        `, [uuid]);

        const loanReady = distinctMonths.rows[0].months >= 3;

        res.json({
            user: user,
            items: itemsRes.rows,
            sales: salesRes.rows,
            engagement: {
                totalSales: parseInt(totalSales),
                totalItems: itemsRes.rows.length,
                firstSale: firstSaleRes.rows[0].min,
                lastSale: lastSaleRes.rows[0].max,
                daysActive: parseInt(daysActiveRes.rows[0].days),
                loanReadiness: {
                    score: loanReady ? 'Ready ✅' : (distinctMonths.rows[0].months >= 1 ? 'Developing ⚠️' : 'Need Data ❌'),
                    monthsOfData: parseInt(distinctMonths.rows[0].months)
                }
            }
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});

// 14. Expand Analytics Dashboard
app.get('/admin/analytics/v2', async (req, res) => {
    try {
        const summary = await pool.query(`
            SELECT 
                (SELECT COUNT(*) FROM users) as total_users,
                (SELECT COUNT(*) FROM users WHERE is_pro = TRUE) as premium_users,
                (SELECT COALESCE(SUM(total), 0) FROM sales) as total_revenue,
                (SELECT COUNT(*) FROM sales) as total_sales
        `);

        const countryDist = await pool.query('SELECT country, COUNT(*) as count FROM users GROUP BY country');
        const categoryDist = await pool.query('SELECT business_type, COUNT(*) as count FROM users GROUP BY business_type');

        const signupsTrend = await pool.query(`
            SELECT DATE_TRUNC('day', created_at) as day, COUNT(*) as count
            FROM users 
            GROUP BY day 
            ORDER BY day DESC 
            LIMIT 30
        `);

        res.json({
            summary: summary.rows[0],
            distribution: {
                countries: countryDist.rows,
                categories: categoryDist.rows
            },
            trends: {
                signups: signupsTrend.rows
            }
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});

// 15. Get Individual User Login History
app.get('/admin/users/:koboId/login-history', async (req, res) => {
    const { koboId } = req.params;
    try {
        const result = await pool.query(`
            SELECT lh.* FROM login_history lh
            JOIN users u ON lh.user_id = u.id
            WHERE u.kobo_id = $1
            ORDER BY lh.timestamp DESC
            LIMIT 50
        `, [koboId]);
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});

// Update startup
app.listen(port, async () => {
    await ensureSchema();
    console.log(`KOBBO API listening at http://localhost:${port}`);
});
