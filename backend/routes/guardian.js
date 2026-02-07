const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const User = require('../models/User');
const Detection = require('../models/Detection');


router.get('/children', auth, async (req, res) => {
  try {
    const user = await User.findById(req.userId);
    if (!user) {
      return res.status(404).json({ error: 'Utilisateur non trouvé' });
    }

    const childrenIds = user.linkedChildren || [];
    const children = await User.find({ _id: { $in: childrenIds } })
      .select('name avatar points level createdAt');

    const childrenWithStats = await Promise.all(
      children.map(async (child) => {
        const totalDetections = await Detection.countDocuments({ userId: child._id });
        const hateDetections = await Detection.countDocuments({ userId: child._id, isHateSpeech: true });

        return {
          _id: child._id,
          name: child.name,
          avatar: child.avatar,
          points: child.points,
          level: child.level,
          isOnline: false, // À implémenter avec WebSocket
          stats: {
            messagesAnalyzed: totalDetections,
            hateDetected: hateDetections,
            safetyScore: totalDetections > 0
              ? Math.round(((totalDetections - hateDetections) / totalDetections) * 100)
              : 100,
          },
        };
      })
    );

    res.json(childrenWithStats);
  } catch (err) {
    console.error('Erreur guardian children:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});


router.post('/link', auth, async (req, res) => {
  try {
    const { childCode } = req.body;

    if (!childCode) {
      return res.status(400).json({ error: 'Code enfant requis' });
    }

    const children = await User.find();
    const child = children.find(
      (u) => u._id.toString().slice(-6).toUpperCase() === childCode.toUpperCase()
    );

    if (!child) {
      return res.status(404).json({ error: 'Code enfant invalide' });
    }

    if (child._id.toString() === req.userId) {
      return res.status(400).json({ error: 'Vous ne pouvez pas vous lier à vous-même' });
    }

    await User.findByIdAndUpdate(req.userId, {
      $addToSet: { linkedChildren: child._id },
    });

    res.json({
      message: 'Enfant lié avec succès',
      child: {
        _id: child._id,
        name: child.name,
        avatar: child.avatar,
      },
    });
  } catch (err) {
    console.error('Erreur guardian link:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});


router.get('/child/:childId/stats', auth, async (req, res) => {
  try {
    const child = await User.findById(req.params.childId).select('-password');
    if (!child) {
      return res.status(404).json({ error: 'Enfant non trouvé' });
    }

    const totalDetections = await Detection.countDocuments({ userId: child._id });
    const hateDetections = await Detection.countDocuments({ userId: child._id, isHateSpeech: true });


    const weekAgo = new Date();
    weekAgo.setDate(weekAgo.getDate() - 7);
    const recentDetections = await Detection.find({
      userId: child._id,
      createdAt: { $gte: weekAgo },
    }).sort({ createdAt: -1 });

    const categoryStats = await Detection.aggregate([
      { $match: { userId: child._id, isHateSpeech: true, category: { $ne: null } } },
      { $group: { _id: '$category', count: { $sum: 1 } } },
      { $sort: { count: -1 } },
    ]);

    res.json({
      child: {
        _id: child._id,
        name: child.name,
        avatar: child.avatar,
        points: child.points,
        level: child.level,
      },
      stats: {
        totalDetections,
        hateDetections,
        safetyScore: totalDetections > 0
          ? Math.round(((totalDetections - hateDetections) / totalDetections) * 100)
          : 100,
        categoryStats,
        recentActivity: recentDetections.slice(0, 10).map((d) => ({
          text: d.originalText.substring(0, 50) + (d.originalText.length > 50 ? '...' : ''),
          isHateSpeech: d.isHateSpeech,
          category: d.category,
          date: d.createdAt,
        })),
      },
    });
  } catch (err) {
    console.error('Erreur child stats:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

module.exports = router;
