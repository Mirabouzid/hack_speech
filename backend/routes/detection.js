const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const Detection = require('../models/Detection');
const User = require('../models/User');


router.post('/analyze', auth, async (req, res) => {
  try {
    const { text } = req.body;

    if (!text || text.trim().length === 0) {
      return res.status(400).json({ error: 'Texte requis' });
    }


    const result = simulateDetection(text);

    const detection = new Detection({
      userId: req.userId,
      originalText: text,
      isHateSpeech: result.isHateSpeech,
      confidence: result.confidence,
      category: result.category,
      explanation: result.explanation,
    });
    await detection.save();

    if (result.isHateSpeech) {
      await User.findByIdAndUpdate(req.userId, { $inc: { points: 15 } });
    }

    res.json({
      isHateSpeech: result.isHateSpeech,
      confidence: result.confidence,
      category: result.category,
      explanation: result.explanation,
    });
  } catch (err) {
    console.error('Erreur analyze:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

const axios = require('axios');

router.post('/reformulate', auth, async (req, res) => {
  try {
    const { text } = req.body;

    if (!text || text.trim().length === 0) {
      return res.status(400).json({ error: 'Texte requis' });
    }

    const reformulated = await groqReformulate(text);

    res.json({ reformulatedText: reformulated });
  } catch (err) {
    console.error('Erreur reformulate:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});


async function groqReformulate(text) {
  const groqApiKey = process.env.API_CHAT;

  if (!groqApiKey) {
    return simulateReformulation(text);
  }

  try {
    const response = await axios.post(
      'https://api.groq.com/openai/v1/chat/completions',
      {
        model: "openai/gpt-oss-20b",
        messages: [
          {
            role: "system",
            content: "Tu es un expert en communication non-violente. Ta mission est de prendre un message agressif ou haineux et de le transformer en une version constructive, calme et respectueuse, tout en gardant l'intention originale si elle est légitime. Si le message est purement haineux, transforme-le en un message de paix ou de réflexion. Réponds uniquement avec le texte reformulé, sans introduction ni guillemets."
          },
          {
            role: "user",
            content: text
          }
        ],
        temperature: 0.6
      },
      {
        headers: {
          'Authorization': `Bearer ${groqApiKey}`,
          'Content-Type': 'application/json'
        }
      }
    );

    return response.data.choices[0].message.content.trim();
  } catch (err) {
    console.error('Erreur Groq Reformulate:', err.message);
    return simulateReformulation(text);
  }
}


router.get('/history', auth, async (req, res) => {
  try {
    const detections = await Detection.find({ userId: req.userId })
      .sort({ createdAt: -1 })
      .limit(50);
    res.json(detections);
  } catch (err) {
    console.error('Erreur history:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

function simulateDetection(text) {
  const lowerText = text.toLowerCase();

  const hateWords = {
    racism: ['sale', 'nègre', 'arabe', 'étranger', 'race'],
    sexism: ['femme', 'cuisine', 'faible', 'soumise'],
    general_insult: ['idiot', 'stupide', 'nul', 'débile', 'con', 'imbécile', 'crétin', 'merde'],
    homophobia: ['gay', 'homo', 'pd', 'tapette'],
    religious: ['mécréant', 'kafir', 'infidèle'],
  };

  let detectedCategory = null;
  let maxScore = 0;

  for (const [category, words] of Object.entries(hateWords)) {
    for (const word of words) {
      if (lowerText.includes(word)) {
        const score = 0.7 + Math.random() * 0.3;
        if (score > maxScore) {
          maxScore = score;
          detectedCategory = category;
        }
      }
    }
  }

  const isHateSpeech = maxScore > 0;

  return {
    isHateSpeech,
    confidence: isHateSpeech ? parseFloat(maxScore.toFixed(2)) : 0.05,
    category: detectedCategory,
    explanation: isHateSpeech
      ? `Ce message contient du contenu potentiellement offensant (catégorie: ${detectedCategory})`
      : 'Aucun discours haineux détecté',
  };
}

function simulateReformulation(text) {
  const reformulations = {
    'idiot': 'personne avec qui je suis en désaccord',
    'stupide': 'pas très réfléchi',
    'nul': 'qui peut s\'améliorer',
    'débile': 'qui ne comprend pas encore',
    'con': 'personne qui pense différemment',
    'imbécile': 'personne qui n\'a pas compris',
    'crétin': 'personne qui peut apprendre',
  };

  let result = text;
  for (const [bad, good] of Object.entries(reformulations)) {
    const regex = new RegExp(bad, 'gi');
    result = result.replace(regex, good);
  }

  if (result === text) {
    return `Version positive : "${text}" → Ce message pourrait être formulé de manière plus constructive.`;
  }

  return result;
}

module.exports = router;
