const Database = require('better-sqlite3');
const db = new Database('./db/foodiefinder.db');

db.exec(`
  CREATE TABLE IF NOT EXISTS users (
    id       INTEGER PRIMARY KEY AUTOINCREMENT,
    name     TEXT    NOT NULL,
    email    TEXT    UNIQUE NOT NULL,
    password TEXT    NOT NULL,
    avatar   TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );
`);

module.exports = db;
