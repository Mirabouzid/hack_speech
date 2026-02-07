class AppConstants {
  static const String appName = 'ElevateAi';

  static const String appVersion = '1.0.0';
  static const String appTagline = 'Transforme la haine en harmonie'; //slogan

  static const int pointsPerSuggestion = 20;
  static const int pointsPerDetection = 15;
  static const int pointsForStreak = 10;
  static const int levelUpPoints = 100;

  static const int maxSuggestionsCount = 3;

  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'ar', 'name': 'العربية', 'flag': ' AR'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
  ];

  static const List<Map<String, String>> hateCategories = [
    {'id': 'racism', 'name': 'Racisme', 'icon': '🚫'},
    {'id': 'sexism', 'name': 'Sexisme', 'icon': '⚧️'},
    {'id': 'religious', 'name': 'Religieux', 'icon': '☪️'},
    {'id': 'homophobia', 'name': 'Homophobie', 'icon': '🏳️‍🌈'},
    {'id': 'ableism', 'name': 'Validisme', 'icon': '♿'},
    {'id': 'general_insult', 'name': 'Insulte générale', 'icon': '💬'},
  ];

  static const List<Map<String, dynamic>> sensitivityLevels = [
    {
      'id': 'low',
      'name': 'Faible',
      'threshold': 0.8, // Détecte seulement les cas très clairs
    },
    {
      'id': 'medium',
      'name': 'Moyenne',
      'threshold': 0.6, // Équilibre
    },
    {
      'id': 'high',
      'name': 'Forte',
      'threshold': 0.4, // Détecte même les cas ambigus
    },
  ];

  static const List<Map<String, String>> platforms = [
    {'id': 'whatsapp', 'name': 'WhatsApp', 'icon': '💬'},
    {'id': 'facebook', 'name': 'Facebook', 'icon': '📘'},
    {'id': 'twitter', 'name': 'Twitter', 'icon': '🐦'},
    {'id': 'instagram', 'name': 'Instagram', 'icon': '📸'},
    {'id': 'messenger', 'name': 'Messenger', 'icon': '💬'},
    {'id': 'telegram', 'name': 'Telegram', 'icon': '✈️'},
  ];

  static const String userKey = 'user';
  static const String settingsKey = 'settings';
  static const String tokenKey = 'auth_token';

  static const String onboardingKey = 'onboarding_complete';

  static const int minPasswordLength = 8; //min password
  static const int maxMessageLength = 500; //max ""

  static const String privacyPolicyUrl = 'https://hatetoharmony.com/privacy';
  static const String termsUrl = 'https://hatetoharmony.com/terms';
  static const String supportEmail = 'support@hatetoharmony.com';
}
