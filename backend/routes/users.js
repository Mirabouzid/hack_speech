const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const User = require('../models/User');


router.get('/me', auth, async (req, res) => {
  try {
    const user = await User.findById(req.userId).select('-password');
    if (!user) {
      return res.status(404).json({ error: 'Utilisateur non trouvé' });
    }
    const userObj = user.toObject();
    if (userObj.stats && userObj.stats.totalPoints) {
      userObj.points = userObj.stats.totalPoints;
    }
    res.json(userObj);
  } catch (err) {
    console.error('Erreur get user:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});


router.put('/me', auth, async (req, res) => {
  try {
    const { name, avatar, settings } = req.body;
    const updateData = {};
    if (name) updateData.name = name;
    if (avatar) updateData.avatar = avatar;
    if (settings) updateData.settings = settings;

    const user = await User.findByIdAndUpdate(
      req.userId,
      updateData,
      { new: true }
    ).select('-password');

    if (!user) {
      return res.status(404).json({ error: 'Utilisateur non trouvé' });
    }
    const userObj = user.toObject();
    if (userObj.stats && userObj.stats.totalPoints) {
      userObj.points = userObj.stats.totalPoints;
    }
    res.json(userObj);
  } catch (err) {
    console.error('Erreur update user:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

module.exports = router;
