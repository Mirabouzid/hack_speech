const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const User = require('../models/User');
const Detection = require('../models/Detection');


router.get('/dashboard', auth, async (req, res) => {
  try {
    const user = await User.findById(req.userId).select('-password');
    if (!user) {
      return res.status(404).json({ error: 'Utilisateur non trouvé' });
    }
    const totalDetections = await Detection.countDocuments({ userId: req.userId });

    
    const hateDetections = await Detection.countDocuments({ userId: req.userId, isHateSpeech: true });

    const categoryStats = await Detection.aggregate([
      { $match: { userId: user._id, isHateSpeech: true, category: { $ne: null } } },
      { $group: { _id: '$category', count: { $sum: 1 } } },
      { $sort: { count: -1 } },
    ]);

    const weekAgo = new Date();
    weekAgo.setDate(weekAgo.getDate() - 7);
    const weeklyDetections = await Detection.aggregate([
      { $match: { userId: user._id, createdAt: { $gte: weekAgo } } },
      {
        $group: {
          _id: { $dayOfWeek: '$createdAt' },
          count: { $sum: 1 },
        },
      },
      { $sort: { '_id': 1 } },
    ]);

   
    const weeklyData = [0, 0, 0, 0, 0, 0, 0];
    weeklyDetections.forEach((d) => {
      const dayIndex = d._id - 1; // MongoDB $dayOfWeek: 1=dimanche
      if (dayIndex >= 0 && dayIndex < 7) {
        weeklyData[dayIndex] = d.count;
      }
    });

    const harmonyScore = totalDetections > 0
      ? Math.round(((totalDetections - hateDetections) / totalDetections) * 100)
      : 100;

    res.json({
      user: {
        _id: user._id,
        name: user.name,
        email: user.email,
        avatar: user.avatar,
        points: user.stats && user.stats.totalPoints ? user.stats.totalPoints : user.points,
        level: user.level,
        badges: user.badges,
      },
      stats: {
        messagesAnalyzed: Math.max(totalDetections, (user.stats && user.stats.totalAnalyzed) || 0),
        messagesImproved: Math.max(hateDetections, (user.stats && user.stats.totalTransformed) || 0),
        badgesUnlocked: (user.badges && user.badges.length) || 0,
        harmonyScore,
        weeklyData,
        categoryStats: categoryStats.map((c) => ({
          category: c._id,
          count: c.count,
        })),
      },
    });
  } catch (err) {
    console.error('Erreur dashboard stats:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

module.exports = router;
