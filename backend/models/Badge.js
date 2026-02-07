const mongoose = require('mongoose');

const badgeSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  emoji: {
    type: String,
    required: true,
  },
  description: {
    type: String,
    required: true,
  },
  requirement: {
    type: String,
    required: true,
  },
  requiredValue: {
    type: Number,
    default: 1,
  },
  category: {
    type: String,
    enum: ['detection', 'reformulation', 'streak', 'social', 'special'],
    default: 'detection',
  },
}, {
  timestamps: true,
});

module.exports = mongoose.model('Badge', badgeSchema);
