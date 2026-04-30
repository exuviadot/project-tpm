const express = require('express');
const cors = require('cors');
const sqlite3 = require('sqlite3').verbose();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = 3000;
const SECRET_KEY = 'foodiefinder_secret_key_demo'; // In a real app, use environment variables

app.use(cors());
app.use(express.json());

// Initialize SQLite Database
const db = new sqlite3.Database(path.join(__dirname, 'users.db'), (err) => {
    if (err) {
        console.error('Error connecting to database:', err);
    } else {
        console.log('Connected to SQLite database');
        db.run(`
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT UNIQUE NOT NULL,
                password TEXT NOT NULL
            )
        `);
    }
});

// Middleware to authenticate JWT
function authenticateToken(req, res, next) {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    
    if (token == null) return res.sendStatus(401); // Unauthorized
    
    jwt.verify(token, SECRET_KEY, (err, user) => {
        if (err) return res.sendStatus(403); // Forbidden
        req.user = user;
        next();
    });
}

// Routes
// 1. Register
app.post('/register', async (req, res) => {
    const { username, password } = req.body;
    
    if (!username || !password) {
        return res.status(400).json({ message: 'Username and password are required' });
    }

    try {
        const hashedPassword = await bcrypt.hash(password, 10);
        
        db.run('INSERT INTO users (username, password) VALUES (?, ?)', [username, hashedPassword], function(err) {
            if (err) {
                if (err.message.includes('UNIQUE constraint failed')) {
                    return res.status(400).json({ message: 'Username already exists' });
                }
                return res.status(500).json({ message: 'Database error' });
            }
            res.status(201).json({ message: 'User registered successfully', userId: this.lastID });
        });
    } catch (err) {
        res.status(500).json({ message: 'Error hashing password' });
    }
});

// 2. Login
app.post('/login', (req, res) => {
    const { username, password } = req.body;
    
    if (!username || !password) {
        return res.status(400).json({ message: 'Username and password are required' });
    }

    db.get('SELECT * FROM users WHERE username = ?', [username], async (err, user) => {
        if (err) return res.status(500).json({ message: 'Database error' });
        if (!user) return res.status(400).json({ message: 'User not found' });

        try {
            if (await bcrypt.compare(password, user.password)) {
                const token = jwt.sign({ id: user.id, username: user.username }, SECRET_KEY, { expiresIn: '24h' });
                res.json({ message: 'Login successful', token: token });
            } else {
                res.status(401).json({ message: 'Incorrect password' });
            }
        } catch (err) {
            res.status(500).json({ message: 'Error checking password' });
        }
    });
});

// 3. Get Restaurants (Reading from GeoJSON)
app.get('/restaurants', authenticateToken, (req, res) => {
    const geojsonPath = path.join(__dirname, 'export.geojson');
    
    fs.readFile(geojsonPath, 'utf8', (err, data) => {
        if (err) {
            console.error('Error reading geojson', err);
            return res.status(500).json({ message: 'Error reading restaurant data' });
        }
        try {
            const restaurants = JSON.parse(data);
            res.json(restaurants);
        } catch (e) {
            res.status(500).json({ message: 'Error parsing geojson data' });
        }
    });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});
