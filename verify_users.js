const { Pool } = require('pg');

const pool = new Pool({
    user: 'postgres',
    host: '109.205.181.195',
    database: 'kobo',
    password: 'LetMeGetaces232823',
    port: 5432,
    ssl: false // explicit disable for this test
});

async function checkUsers() {
    try {
        const res = await pool.query('SELECT kobo_id, pin, first_name, surname, role, created_at FROM users ORDER BY created_at DESC LIMIT 5');
        console.log("Recent Users:");
        console.table(res.rows);
    } catch (err) {
        console.error("Error querying DB:", err);
    } finally {
        await pool.end();
    }
}

checkUsers();
