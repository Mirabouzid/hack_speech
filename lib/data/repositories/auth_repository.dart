import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);
      
      // Sauvegarder le token
      if (response['token'] != null) {
        _apiService.setAuthToken(response['token']);
      }
      
      // Retourner l'utilisateur
      return UserModel.fromJson(response['user']);
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  Future<UserModel> loginWithGoogle(
    String idToken, {
    String? email,
    String? name,
    String? avatar,
    String? googleId,
  }) async {
    try {
      final response = await _apiService.loginWithGoogle(
        idToken,
        email: email,
        name: name,
        avatar: avatar,
        googleId: googleId,
      );
      
      // Sauvegarder le token
      if (response['token'] != null) {
        _apiService.setAuthToken(response['token']);
      }
      
      // Retourner l'utilisateur
      return UserModel.fromJson(response['user']);
    } catch (e) {
      throw Exception('Erreur de connexion Google: ${e.toString()}');
    }
  }

  Future<UserModel> register(
    String email,
    String password,
    String name,
  ) async {
    try {
      final response = await _apiService.register(email, password, name);
      
      // Sauvegarder le token
      if (response['token'] != null) {
        _apiService.setAuthToken(response['token']);
      }
      
      // Retourner l'utilisateur
      return UserModel.fromJson(response['user']);
    } catch (e) {
      throw Exception('Erreur d\'inscription: ${e.toString()}');
    }
  }

  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _apiService.getCurrentUser();
      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Erreur de récupération utilisateur: ${e.toString()}');
    }
  }

  Future<UserModel> updateUserSettings(Map<String, dynamic> settings) async {
    try {
      final response = await _apiService.updateUser({'settings': settings});
      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Erreur de mise à jour des paramètres: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      _apiService.clearAuthToken();
    } catch (e) {
      throw Exception('Erreur de déconnexion: ${e.toString()}');
    }
  }
}
