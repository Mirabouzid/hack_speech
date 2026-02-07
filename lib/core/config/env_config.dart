import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  // API Backend
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
  
  // MongoDB Atlas
  static String get mongodbUri => dotenv.env['MONGODB_URI'] ?? '';
  
  // Google OAuth (utilisé uniquement pour Web/iOS, Android utilise google-services.json)
  static String get googleClientId => dotenv.env['GOOGLE_CLIENT_ID'] ?? '';
  
  // Validation
  static bool get isConfigured {
    return apiBaseUrl.isNotEmpty;
  }
  
  static void validateConfig() {
    debugPrint('📋 API Base URL: $apiBaseUrl');
    if (mongodbUri.isNotEmpty) {
      debugPrint('📊 MongoDB: configuré');
    }
    if (googleClientId.isNotEmpty) {
      debugPrint('🔐 Google Client ID: configuré');
    } else {
      debugPrint('ℹ️ Google Client ID: non configuré (Android utilise google-services.json)');
    }
  }
}
