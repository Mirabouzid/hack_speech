const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true,
  },
  name: {
    type: String,
    required: true,
    trim: true,
    default: 'Utilisateur',
  },
  password: {
    type: String,
    default: null, // null pour les utilisateurs Google
  },
  avatar: {
    type: String,
    default: null,
  },
  googleId: {
    type: String,
    default: null,
  },
  authProvider: {
    type: String,
    enum: ['email', 'google'],
    default: 'email',
  },
  points: {
    type: Number,
    default: 0,
  },
  level: {
    type: Number,
    default: 1,
  },
  badges: {
    type: [String],
    default: [],
  },
  linkedChildren: {
    type: [mongoose.Schema.Types.ObjectId],
    ref: 'User',
    default: [],
  },
  stats: {
    totalAnalyzed: { type: Number, default: 0 },
    totalTransformed: { type: Number, default: 0 },
    totalPoints: { type: Number, default: 0 },
  },
  settings: {
    notificationSettings: {
      methods: {
        email: { type: Boolean, default: true },
        sms: { type: Boolean, default: false },
        phone: { type: Boolean, default: false },
        push: { type: Boolean, default: true },
      },
      types: {
        weeklyDigest: { type: Boolean, default: true },
        gamification: { type: Boolean, default: true },
        securityAlerts: { type: Boolean, default: true },
        educationalTips: { type: Boolean, default: true },
      },
    },
    soundEnabled: { type: Boolean, default: true },
    darkModeEnabled: { type: Boolean, default: false },
    language: { type: String, default: 'Français' },
    sensitivity: { type: String, default: 'Moyen' },
    detectionMode: { type: String, enum: ['block', 'reformulate'], default: 'reformulate' },
    reformulationStyle: { type: String, enum: ['neutralization', 'informative', 'de_escalation', 'empathy'], default: 'neutralization' },
    blockedCategories: { type: [String], default: ['racisme', 'sexisme', 'religieux'] },
    customCategories: { type: [String], default: [] },
  },
}, {
  timestamps: true, // createdAt + updatedAt automatiques
});

module.exports = mongoose.model('User', userSchema);
