const { Client } = require('pg');

const client = new Client({
    user: 'postgres',
    host: '109.205.181.195',
    database: 'postgres', // Connect to default DB to create new one
    password: 'LetMeGetaces232823',
    port: 5432,
});

async function createDb() {
    try {
        await client.connect();
        console.log('Connected to postgres database...');

        // Check if database exists
        const res = await client.query("SELECT 1 FROM pg_database WHERE datname = 'kobo'");
        if (res.rowCount === 0) {
            console.log("Database 'kobo' does not exist. Creating...");
            await client.query('CREATE DATABASE kobo');
            console.log("Database 'kobo' created successfully!");
        } else {
            console.log("Database 'kobo' already exists.");
        }
    } catch (err) {
        console.error('Error creating database:', err);
    } finally {
        await client.end();
    }
}

createDb();
