const express = require('express');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.static(__dirname));

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

// ENDPOINT NECESARIO PARA BLUE-GREEN
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'OK',
    color: process.env.APP_COLOR || 'unknown'
  });
});

app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
});