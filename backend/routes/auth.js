const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { OAuth2Client } = require('google-auth-library');
const User = require('../models/User');

function generateToken(userId) {
  return jwt.sign({ userId }, process.env.JWT_SECRET, { expiresIn: '30d' });
}

router.post('/register', async (req, res) => {
  try {
    const { email, password, name } = req.body;

    if (!email || !password || !name) {
      return res.status(400).json({ error: 'Email, mot de passe et nom requis' });
    }

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ error: 'Cet email est déjà utilisé' });
    }

    const hashedPassword = await bcrypt.hash(password, 12);


    const user = new User({
      email,
      password: hashedPassword,
      name,
      authProvider: 'email',
    });
    await user.save();

    const token = generateToken(user._id);

    res.status(201).json({
      token,
      user: {
        _id: user._id,
        email: user.email,
        name: user.name,
        avatar: user.avatar,
        points: user.stats && user.stats.totalPoints ? user.stats.totalPoints : user.points,
        level: user.level,
        badges: user.badges,
        createdAt: user.createdAt,
      },
    });
  } catch (err) {
    console.error('Erreur register:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});


router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email et mot de passe requis' });
    }

    const user = await User.findOne({ email });
    if (!user || !user.password) {
      return res.status(401).json({ error: 'Email ou mot de passe incorrect' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ error: 'Email ou mot de passe incorrect' });
    }

    const token = generateToken(user._id);

    res.json({
      token,
      user: {
        _id: user._id,
        email: user.email,
        name: user.name,
        avatar: user.avatar,
        points: user.stats && user.stats.totalPoints ? user.stats.totalPoints : user.points,
        level: user.level,
        badges: user.badges,
        createdAt: user.createdAt,
      },
    });
  } catch (err) {
    console.error('Erreur login:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});


router.post('/google', async (req, res) => {
  try {
    console.log('📩 /auth/google - Body reçu:', JSON.stringify(req.body, null, 2));
    const { idToken, email, name, avatar, googleId } = req.body;

    let userEmail = email;
    let userName = name;
    let userAvatar = avatar;
    let userGoogleId = googleId;


    if (idToken && idToken.length > 10 && process.env.GOOGLE_CLIENT_ID) {
      try {
        const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);
        const ticket = await client.verifyIdToken({
          idToken,
          audience: process.env.GOOGLE_CLIENT_ID,
        });
        const payload = ticket.getPayload();
        userEmail = payload.email;
        userName = payload.name;
        userAvatar = payload.picture;
        userGoogleId = payload.sub;
        console.log('✅ Token Google vérifié pour:', userEmail);
      } catch (verifyErr) {
        console.log('⚠️ Vérification token échouée, utilisation des données directes:', verifyErr.message);
      }
    }

    if (!userEmail) {
      console.log('❌ Pas d\'email fourni');
      return res.status(400).json({ error: 'Email requis pour la connexion Google' });
    }

    // Chercher ou créer l'utilisateur
    let user = await User.findOne({ email: userEmail });

    if (!user) {
      // Créer un nouvel utilisateur Google
      user = new User({
        email: userEmail,
        name: userName || userEmail.split('@')[0],
        avatar: userAvatar,
        googleId: userGoogleId,
        authProvider: 'google',
      });
      await user.save();
      console.log(`✅ Nouvel utilisateur Google créé: ${userEmail}`);
    } else {
      // Mettre à jour les infos Google
      if (userGoogleId && !user.googleId) {
        user.googleId = userGoogleId;
        user.authProvider = 'google';
      }
      if (userName && (user.name === 'Utilisateur' || !user.name)) {
        user.name = userName;
      }
      if (userAvatar) {
        user.avatar = userAvatar;
      }
      await user.save();
    }

    const token = generateToken(user._id);

    res.json({
      token,
      user: {
        _id: user._id,
        email: user.email,
        name: user.name,
        avatar: user.avatar,
        points: user.stats && user.stats.totalPoints ? user.stats.totalPoints : user.points,
        level: user.level,
        badges: user.badges,
        createdAt: user.createdAt,
      },
    });
  } catch (err) {
    console.error('Erreur Google auth:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

module.exports = router;
