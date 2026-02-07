require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const detectionRoutes = require('./routes/detection');
const statsRoutes = require('./routes/stats');
const gamificationRoutes = require('./routes/gamification');
const chatRoutes = require('./routes/chat');
const guardianRoutes = require('./routes/guardian');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Connexion MongoDB Atlas
mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log('✅ Connecté à MongoDB Atlas'))
  .catch(err => console.error('❌ Erreur MongoDB:', err.message));

// Routes
app.use('/auth', authRoutes);
app.use('/users', userRoutes);
app.use('/detection', detectionRoutes);
app.use('/stats', statsRoutes);
app.use('/gamification', gamificationRoutes);
app.use('/chat', chatRoutes);
app.use('/guardian', guardianRoutes);

// Route de test
app.get('/', (req, res) => {
  res.json({ message: 'ElevateAi API is running', status: 'ok' });
});

// Démarrer le serveur
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Serveur démarré sur le port ${PORT}`);
});
