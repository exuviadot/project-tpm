const router = require('express').Router();
const bcrypt = require('bcrypt');
const jwt    = require('jsonwebtoken');
const db     = require('../db/database');
const authMiddleware = require('../middleware/auth_middleware');
const SECRET = process.env.JWT_SECRET || 'foodiefinder_secret';

// POST /api/auth/register
router.post('/register', async (req, res) => {
  const { name, email, password } = req.body;
  if (!name || !email || !password) {
    return res.status(400).json({ error: 'All fields are required' });
  }
  
  try {
    const hashed = await bcrypt.hash(password, 12);
    db.prepare(`INSERT INTO users (name, email, password) VALUES (?, ?, ?)`).run(name, email, hashed);
    res.json({ message: 'Registered successfully' });
  } catch (e) {
    if (e.message.includes('UNIQUE constraint failed')) {
      res.status(400).json({ error: 'Email already exists' });
    } else {
      res.status(500).json({ error: 'Internal server error' });
    }
  }
});

// POST /api/auth/login
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) return res.status(400).json({ error: 'Email and password required' });
  
  const user = db.prepare(`SELECT * FROM users WHERE email = ?`).get(email);
  if (!user || !(await bcrypt.compare(password, user.password))) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }
  
  const token = jwt.sign({ userId: user.id, email: user.email }, SECRET, { expiresIn: '30d' });
  res.json({ token, user: { id: user.id, name: user.name, email: user.email } });
});

// GET /api/auth/profile (protected)
router.get('/profile', authMiddleware, (req, res) => {
  const user = db.prepare(`SELECT id, name, email FROM users WHERE id = ?`).get(req.userId);
  if (!user) return res.status(404).json({ error: 'User not found' });
  res.json(user);
});

module.exports = router;
