const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const ChatMessage = require('../models/ChatMessage');

const axios = require('axios');


async function generateMiraResponse(userMessage) {
  const groqApiKey = process.env.API_CHAT;

  if (!groqApiKey) {
    console.warn('API_CHAT manquante dans .env, utilisation du mode simulé.');
    return getSimulatedResponse(userMessage);
  }

  try {
    const response = await axios.post(
      'https://api.groq.com/openai/v1/chat/completions',
      {
        model: "openai/gpt-oss-20b",
        messages: [
          {
            role: "system",
            content: "Tu es Mira, une assistante IA bienveillante et empathique intégrée à l'application 'Hack Speech'. Ton but est d'aider les utilisateurs à lutter contre les discours de haine, à reformuler des messages blessants de manière constructive, et à promouvoir la bienveillance en ligne. Réponds de manière concise, chaleureuse et utilise des emojis. Tu parles principalement en Français et parfois en Arabe (Darija) si l'utilisateur l'utilise."
          },
          {
            role: "user",
            content: userMessage
          }
        ],
        temperature: 0.7,
        max_tokens: 500
      },
      {
        headers: {
          'Authorization': `Bearer ${groqApiKey}`,
          'Content-Type': 'application/json'
        }
      }
    );

    return response.data.choices[0].message.content;
  } catch (err) {
    console.error('Erreur API Groq:', err.response ? err.response.data : err.message);
    return getSimulatedResponse(userMessage);
  }
}


function getSimulatedResponse(userMessage) {
  const lowerMsg = userMessage.toLowerCase();
  if (lowerMsg.includes('bonjour') || lowerMsg.includes('salut')) return 'Salam ! 👋 Je suis Mira en mode hors-ligne. Comment puis-je t\'aider ?';
  if (lowerMsg.includes('haine')) return 'Les discours de haine font mal. Tu veux qu\'on en parle ?';
  return 'Je suis actuellement en mode limité, mais je suis là pour t\'écouter ! 💜';
}

router.post('/message', auth, async (req, res) => {
  try {
    const { message } = req.body;

    if (!message || message.trim().length === 0) {
      return res.status(400).json({ error: 'Message requis' });
    }


    const userMsg = new ChatMessage({
      userId: req.userId,
      text: message.trim(),
      isUser: true,
    });
    await userMsg.save();

    const miraResponseText = await generateMiraResponse(message);
    const miraMsg = new ChatMessage({
      userId: req.userId,
      text: miraResponseText,
      isUser: false,
    });
    await miraMsg.save();

    res.json({
      userMessage: {
        _id: userMsg._id,
        text: userMsg.text,
        isUser: true,
        createdAt: userMsg.createdAt,
      },
      miraResponse: {
        _id: miraMsg._id,
        text: miraResponseText,
        isUser: false,
        createdAt: miraMsg.createdAt,
      },
    });
  } catch (err) {
    console.error('Erreur chat message:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

router.get('/history', auth, async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 50;
    const messages = await ChatMessage.find({ userId: req.userId })
      .sort({ createdAt: -1 })
      .limit(limit);


    res.json(messages.reverse());
  } catch (err) {
    console.error('Erreur chat history:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});


router.delete('/clear', auth, async (req, res) => {
  try {
    await ChatMessage.deleteMany({ userId: req.userId });
    res.json({ message: 'Historique du chat réinitialisé avec succès' });
  } catch (err) {
    console.error('Erreur chat clear:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

module.exports = router;
