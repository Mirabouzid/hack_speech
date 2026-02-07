const mongoose = require('mongoose');

const detectionSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  originalText: {
    type: String,
    required: true,
  },
  isHateSpeech: {
    type: Boolean,
    default: false,
  },
  confidence: {
    type: Number,
    default: 0,
    min: 0,
    max: 1,
  },
  category: {
    type: String,
    enum: ['racism', 'sexism', 'religious', 'homophobia', 'ableism', 'general_insult', null],
    default: null,
  },
  explanation: {
    type: String,
    default: null,
  },
  reformulatedText: {
    type: String,
    default: null,
  },
}, {
  timestamps: true,
});

module.exports = mongoose.model('Detection', detectionSchema);
