const express = require('express');
const cors    = require('cors');
const app     = express();

app.use(cors());
app.use(express.json());

app.use('/api/restaurants', require('./routes/restaurants'));
app.use('/api/auth',        require('./routes/auth'));

app.listen(3000, () => console.log('FoodieFinder API running on :3000'));
