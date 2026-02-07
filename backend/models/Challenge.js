const mongoose = require('mongoose');

const challengeSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
  },
  description: {
    type: String,
    required: true,
  },
  emoji: {
    type: String,
    default: '🎯',
  },
  type: {
    type: String,
    enum: ['daily', 'weekly'],
    default: 'weekly',
  },
  target: {
    type: Number,
    required: true,
  },
  reward: {
    type: Number,
    default: 100,
  },
  startDate: {
    type: Date,
    default: Date.now,
  },
  endDate: {
    type: Date,
    required: true,
  },
  isActive: {
    type: Boolean,
    default: true,
  },
}, {
  timestamps: true,
});

module.exports = mongoose.model('Challenge', challengeSchema);
