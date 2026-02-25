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

const app = express();
const port = 3000;

app.use(cors());
app.use(bodyParser.json());
// Serve static files from the 'public' directory (where Flutter Web build goes)
app.use(express.static('public'));

// PostgreSQL Connection configuration
const pool = new Pool({
    user: 'postgres',
    host: '109.205.181.195',
    database: 'kobo',
    password: 'LetMeGetaces232823',
    port: 5432,
});

// --- AUTH ENDPOINTS ---

// Login
app.post('/auth/login', async (req, res) => {
    const { koboId, pin } = req.body;
    try {
        const result = await pool.query(
            'SELECT * FROM users WHERE kobo_id = $1 AND pin = $2',
            [koboId, pin]
        );
        if (result.rows.length > 0) {
            res.json({ status: 'success', user: result.rows[0] });
        } else {
            res.status(401).json({ status: 'error', message: 'Invalid credentials' });
        }
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});

// Register User
app.post('/auth/register', async (req, res) => {
    const { koboId, firstName, surname, businessName, pin, country, businessType, createdAt, role } = req.body;
    try {
        await pool.query(
            `INSERT INTO users (kobo_id, first_name, surname, business_name, pin, country, business_type, created_at, role)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
             ON CONFLICT (kobo_id) DO UPDATE SET
             first_name = EXCLUDED.first_name,
             surname = EXCLUDED.surname,
             business_name = EXCLUDED.business_name,
             country = EXCLUDED.country,
             business_type = EXCLUDED.business_type`,
            [koboId, firstName, surname, businessName, pin, country, businessType, createdAt || new Date(), role || 'user']
        );
        res.status(201).json({ status: 'success', message: 'User registered' });
    } catch (err) {
        console.error('Register error:', err);
        res.status(500).json({ error: err.message });
    }
});

// --- ADMIN ENDPOINTS ---

// Get All Users
app.get('/admin/users', async (req, res) => {
    try {
        const { search, country, category, status, tier, role } = req.query;
        
        let query = 'SELECT * FROM users WHERE 1=1';
        const params = [];
        let paramIndex = 1;

        if (search) {
            query += ` AND (kobo_id ILIKE $${paramIndex} OR first_name ILIKE $${paramIndex} OR surname ILIKE $${paramIndex} OR business_name ILIKE $${paramIndex})`;
            params.push(`%${search}%`);
            paramIndex++;
        }
        if (country) {
            query += ` AND country = $${paramIndex}`;
            params.push(country);
            paramIndex++;
        }
        if (category) {
            query += ` AND business_type = $${paramIndex}`;
            params.push(category);
            paramIndex++;
        }
        if (tier === 'pro') {
            query += ` AND is_pro = true`;
        } else if (tier === 'free') {
            query += ` AND (is_pro = false OR is_pro IS NULL)`;
        }
        if (role) {
            query += ` AND role = $${paramIndex}`;
            params.push(role);
            paramIndex++;
        }

        query += ' ORDER BY created_at DESC';

        const result = await pool.query(query, params);
        res.json(result.rows);
    } catch (err) {
        console.error('Fetch users error:', err);
        res.status(500).json({ error: err.message });
    }
});

// Get User Details
app.get('/admin/users/:koboId/details', async (req, res) => {
    const { koboId } = req.params;
    try {
        const userResult = await pool.query('SELECT id FROM users WHERE kobo_id = $1', [koboId]);
        if (userResult.rows.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }
        const userId = userResult.rows[0].id;

        const itemsResult = await pool.query('SELECT * FROM items WHERE user_id = $1', [userId]);
        const salesResult = await pool.query('SELECT * FROM sales WHERE user_id = $1 ORDER BY created_at DESC LIMIT 50', [userId]);

        res.json({
            items: itemsResult.rows,
            sales: salesResult.rows
        });
    } catch (err) {
        console.error('Fetch user details error:', err);
        res.status(500).json({ error: err.message });
    }
});

// Get User Login History
app.get('/admin/users/:koboId/login-history', async (req, res) => {
    const { koboId } = req.params;
    try {
        const userResult = await pool.query('SELECT id FROM users WHERE kobo_id = $1', [koboId]);
        if (userResult.rows.length === 0) {
            return res.json([]);
        }
        const userId = userResult.rows[0].id;

        const historyResult = await pool.query(
            'SELECT * FROM login_history WHERE user_id = $1 ORDER BY timestamp DESC LIMIT 50',
            [userId]
        );
        res.json(historyResult.rows);
    } catch (err) {
        console.error('Fetch login history error:', err);
        res.json([]);
    }
});

// Reset User PIN
app.post('/admin/users/reset-pin', async (req, res) => {
    const { koboId, newPin } = req.body;
    try {
        await pool.query('UPDATE users SET pin = $1 WHERE kobo_id = $2', [newPin, koboId]);
        res.json({ status: 'success' });
    } catch (err) {
        console.error('Reset PIN error:', err);
        res.status(500).json({ error: err.message });
    }
});

// Terminate User
app.post('/admin/users/terminate', async (req, res) => {
    const { koboId } = req.body;
    try {
        const userResult = await pool.query('SELECT id FROM users WHERE kobo_id = $1', [koboId]);
        if (userResult.rows.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }
        const userId = userResult.rows[0].id;

        // Delete related data first
        await pool.query('DELETE FROM sales WHERE user_id = $1', [userId]);
        await pool.query('DELETE FROM items WHERE user_id = $1', [userId]);
        await pool.query('DELETE FROM users WHERE id = $1', [userId]);

        res.json({ status: 'success' });
    } catch (err) {
        console.error('Terminate user error:', err);
        res.status(500).json({ error: err.message });
    }
});

// Update User Role
app.post('/admin/users/update-role', async (req, res) => {
    const { koboId, role } = req.body;
    try {
        await pool.query('UPDATE users SET role = $1 WHERE kobo_id = $2', [role, koboId]);
        res.json({ status: 'success' });
    } catch (err) {
        console.error('Update role error:', err);
        res.status(500).json({ error: err.message });
    }
});

// Toggle Pro Status
app.post('/admin/users/toggle-pro', async (req, res) => {
    const { koboId, isPro } = req.body;
    try {
        await pool.query('UPDATE users SET is_pro = $1 WHERE kobo_id = $2', [isPro, koboId]);
        res.json({ status: 'success' });
    } catch (err) {
        console.error('Toggle pro error:', err);
        res.status(500).json({ error: err.message });
    }
});

// Admin Analytics
app.get('/admin/analytics', async (req, res) => {
    try {
        const statsResult = await pool.query(`
            SELECT 
                (SELECT COUNT(*) FROM users) as total_users,
                (SELECT COALESCE(SUM(total), 0) FROM sales) as total_revenue,
                (SELECT COUNT(*) FROM sales) as total_sales,
                (SELECT COUNT(*) FROM items) as total_items
        `);

        const stats = statsResult.rows[0];

        res.json({
            summary: {
                totalUsers: parseInt(stats.total_users),
                totalRevenue: parseInt(stats.total_revenue),
                totalSales: parseInt(stats.total_sales),
                totalItems: parseInt(stats.total_items)
            }
        });
    } catch (err) {
        console.error('Analytics error:', err);
        res.status(500).json({ error: err.message });
    }
});

// Admin Analytics V2
app.get('/admin/analytics/v2', async (req, res) => {
    try {
        const statsResult = await pool.query(`
            SELECT 
                (SELECT COUNT(*) FROM users) as total_users,
                (SELECT COALESCE(SUM(total), 0) FROM sales) as total_revenue,
                (SELECT COUNT(*) FROM sales) as total_sales,
                (SELECT COUNT(*) FROM items) as total_items,
                (SELECT COUNT(*) FROM users WHERE is_pro = true) as pro_users
        `);

        const stats = statsResult.rows[0];

        res.json({
            summary: {
                totalUsers: parseInt(stats.total_users),
                totalRevenue: parseInt(stats.total_revenue),
                totalSales: parseInt(stats.total_sales),
                totalItems: parseInt(stats.total_items),
                proUsers: parseInt(stats.pro_users || 0)
            }
        });
    } catch (err) {
        console.error('Analytics V2 error:', err);
        res.status(500).json({ error: err.message });
    }
});

// --- SYNC ENDPOINTS ---

// Sync User Profile
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

// Sync Items (Bulk)
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

// Sync Sales (Bulk)
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

// Legacy Admin Stats
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

app.listen(port, () => {
    console.log(`KOBBO API listening at http://localhost:${port}`);
});
