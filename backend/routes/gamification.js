const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const User = require('../models/User');
const Badge = require('../models/Badge');
const UserBadge = require('../models/UserBadge');
const Challenge = require('../models/Challenge');
const UserChallenge = require('../models/UserChallenge');
const Detection = require('../models/Detection');


router.get('/leaderboard', auth, async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 10;
    const users = await User.find()
      .select('name avatar points level')
      .sort({ points: -1 })
      .limit(limit);

    const leaderboard = users.map((user, index) => ({
      rank: index + 1,
      _id: user._id,
      name: user.name,
      avatar: user.avatar,
      points: user.points,
      level: user.level,
    }));

    res.json(leaderboard);
  } catch (err) {
    console.error('Erreur leaderboard:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});


router.get('/badges', auth, async (req, res) => {
  try {

    const allBadges = await Badge.find().sort({ category: 1 });

    const userBadges = await UserBadge.find({ userId: req.userId });
    const unlockedBadgeIds = userBadges.map((ub) => ub.badgeId.toString());

    const badges = allBadges.map((badge) => {
      const userBadge = userBadges.find((ub) => ub.badgeId.toString() === badge._id.toString());
      return {
        _id: badge._id,
        name: badge.name,
        emoji: badge.emoji,
        description: badge.description,
        category: badge.category,
        unlocked: unlockedBadgeIds.includes(badge._id.toString()),
        unlockedAt: userBadge ? userBadge.unlockedAt : null,
      };
    });

    res.json(badges);
  } catch (err) {
    console.error('Erreur badges:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});


router.get('/challenge/current', auth, async (req, res) => {
  try {
    const now = new Date();
    const challenge = await Challenge.findOne({
      isActive: true,
      startDate: { $lte: now },
      endDate: { $gte: now },
    });

    if (!challenge) {
      return res.json({ challenge: null });
    }


    let userChallenge = await UserChallenge.findOne({
      userId: req.userId,
      challengeId: challenge._id,
    });

    if (!userChallenge) {
      userChallenge = new UserChallenge({
        userId: req.userId,
        challengeId: challenge._id,
        progress: 0,
      });


      const detectionsCount = await Detection.countDocuments({
        userId: req.userId,
        createdAt: { $gte: challenge.startDate },
      });
      userChallenge.progress = detectionsCount;
      await userChallenge.save();
    }

    res.json({
      challenge: {
        _id: challenge._id,
        title: challenge.title,
        description: challenge.description,
        emoji: challenge.emoji,
        type: challenge.type,
        target: challenge.target,
        reward: challenge.reward,
        progress: userChallenge.progress,
        completed: userChallenge.completed,
        startDate: challenge.startDate,
        endDate: challenge.endDate,
      },
    });
  } catch (err) {
    console.error('Erreur challenge:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

module.exports = router;
