# 🕊️ ElevateAi
> **Transforme la haine en harmonie.**

![Banner](https://via.placeholder.com/1200x400/6A1B9A/ffffff?text=ElevateAi+|+Hackathon+2024)

---

##  Le Pitch
**ElevateAi** n'est pas simplement un filtre de modération. C'est le premier **compagnon d'intelligence artificielle** conçu pour éduquer, apaiser et transformer les interactions numériques. 

Là où les autres bloquent la haine, **nous l'analysons et la reformulons** pour réapprendre la communication non-violente à l'ère du numérique.

---

##  Le Problème
Le cyberharcèlement et les discours de haine (Hate Speech) polluent les réseaux sociaux, affectant la santé mentale de millions de jeunes.
*   **Les solutions actuelles** : Censurent et bannissent (réactif).
*   **Notre approche** : Éduque et prévient (proactif).

## La Solution : ElevateAi

Notre application mobile combine **l'analyse sémantique avancée** et la **psychologie comportementale** (Gamification) pour créer un cercle vertueux.

### ✨ Fonctionnalités Clés

#### 🛡️ 1. Détection & Analyse Temps Réel
Analyse instantanée des messages (Texte & Audio,image, vidéo) pour identifier 6 catégories de haine (Racisme, Sexisme, etc.) avec un score de confiance précis.

#### 🔄 2. Alchimie Verbale (Powered by GenAI)
Utilisation de modèles LLM (Groq/GPT) pour **reformuler** un message toxique en une version constructive, respectueuse, mais qui garde le sens initial.
> *Avant :* "Tu es stupide de penser ça."
> *Après :* "Je ne partage pas ton avis, peux-tu m'expliquer ton point de vue ?"

####  3. Gamification de la Bienveillance
*   **XP & Niveaux** : Gagnez des points à chaque reformulation positive.
*   **Badges** : Débloquez des succès ("Pacificateur", "Gardien de la Paix").
*   **Leaderboard** : Une compétition saine pour la communauté.

####  4. Mode Guardian
Un tableau de bord pour les parents ou modérateurs permettant de suivre l'évolution des interactions sans intrusion, via des statistiques agrégées et des alertes intelligentes.

---

##  Stack Technique

Ce projet démontre une expertise technique **Fullstack** et une architecture robuste.

###  Mobile (Flutter)
*   **Architecture** : Clean Architecture (Presentation, Domain, Data).
*   **State Management** : `Flutter Riverpod` pour une gestion d'état réactive et testable.
*   **Routing** : `GoRouter` pour une navigation fluide.
*   **Local Storage** : `Hive` pour la persistance performante hors-ligne.
*   **Network** : `Dio` avec intercepteurs pour la sécurité (JWT).

###  Backend & AI (Node.js)
*   **API** : Express.js & MongoDB (Mongoose).
*   **Auth** : JWT & Google OAuth.
*   **AI Engine** : Intégration de l'API **Groq** pour une inférence ultra-rapide (LLM) dédiée à la reformulation.

---

##  Aperçu de l'Interface

| Dashboard | Analyse IA | Salam Chat | Mode Guardian |
|:---:|:---:|:---:|:---:|
| ![Home](https://via.placeholder.com/200x400?text=Home) | ![Detection](https://via.placeholder.com/200x400?text=Detection) | ![Chat](https://via.placeholder.com/200x400?text=Chat) | ![Guardian](https://via.placeholder.com/200x400?text=Guardian) |

---

##  Installation & Démarrage

### Prérequis
*   Flutter SDK (3.x)
*   Node.js (18+)
*   MongoDB Instance

### 1. Backend
```bash
cd backend
npm install
# Créez un fichier .env avec vos clés (MONGO_URI, API_CHAT, etc.)
npm start
```

### 2. Application Mobile
```bash
flutter pub get
flutter run
```



##  Roadmap & Futur
*   [ ] Extension clavier (Keyboard Extension) pour intervenir directement dans WhatsApp/Messenger.
*   [ ] Analyse vocale en temps réel lors d'appels.
*   [ ] Modèle IA local (On-device) pour une confidentialité totale.


voici démonstration: https://www.youtube.com/watch?v=SjKiScPOw-c

Please check the landing page : https://elevate-erasmus-ai.lovable.app/?fbclid=IwY2xjawPzzeJleHRuA2FlbQIxMABicmlkETFERFB4UDZkTW1tTGNKYlB5c3J0YwZhcHBfaWQQMjIyMDM5MTc4ODIwMDg5MgABHrxfOOLvuIskqnDiIlQQUFE2gkmvK1I40raJ0x3NNzdjyAPYwhiVCpzRdHvo_aem__zSzxKraCs5VlxnbTDa0eQ



## L'Équipe
Développé avec ❤️ pour le Hackathon.


---
*ElevateAi - Changeons les mots pour changer le monde.*
