import 'package:dio/dio.dart';
import '../../core/config/env_config.dart';

class ApiService {
  late final Dio _dio;
  String? _authToken;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Intercepteur pour ajouter le token d'authentification
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // Gestion des erreurs
          if (error.response?.statusCode == 401) {
            // Token expiré, déconnecter l'utilisateur
            _authToken = null;
          }
          return handler.next(error);
        },
      ),
    );
  }

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  // Auth endpoints
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> loginWithGoogle(
    String idToken, {
    String? email,
    String? name,
    String? avatar,
    String? googleId,
  }) async {
    try {
      final response = await _dio.post('/auth/google', data: {
        'idToken': idToken,
        'email': email,
        'name': name,
        'avatar': avatar,
        'googleId': googleId,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String name,
  ) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'name': name,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // User endpoints
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _dio.get('/users/me');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateUser(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/users/me', data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Detection endpoints
  Future<Map<String, dynamic>> detectHateSpeech(String text) async {
    try {
      final response = await _dio.post('/detection/analyze', data: {
        'text': text,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> reformulateText(String text) async {
    try {
      final response = await _dio.post('/detection/reformulate', data: {
        'text': text,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getUserDetections() async {
    try {
      final response = await _dio.get('/detection/history');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Salam Chat endpoints
  Future<Map<String, dynamic>> sendChatMessage(String message) async {
    try {
      final response = await _dio.post('/chat/message', data: {
        'message': message,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getChatHistory() async {
    try {
      final response = await _dio.get('/chat/history');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearChatHistory() async {
    try {
      await _dio.delete('/chat/clear');
    } catch (e) {
      rethrow;
    }
  }

  // Gamification endpoints
  Future<List<dynamic>> getLeaderboard({int limit = 10}) async {
    try {
      final response = await _dio.get('/gamification/leaderboard', 
        queryParameters: {'limit': limit},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getUserBadges() async {
    try {
      final response = await _dio.get('/gamification/badges');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCurrentChallenge() async {
    try {
      final response = await _dio.get('/gamification/challenge/current');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Guardian Mode endpoints
  Future<List<dynamic>> getLinkedChildren() async {
    try {
      final response = await _dio.get('/guardian/children');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> linkChild(String childCode) async {
    try {
      final response = await _dio.post('/guardian/link', data: {
        'childCode': childCode,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getChildStats(String childId) async {
    try {
      final response = await _dio.get('/guardian/child/$childId/stats');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Stats endpoints
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _dio.get('/stats/dashboard');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
