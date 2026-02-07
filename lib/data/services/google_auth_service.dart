import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/config/env_config.dart';

class GoogleAuthService {
  late final GoogleSignIn _googleSignIn;

  GoogleAuthService() {
    // Sur Android, le clientId n'est pas nécessaire (utilise google-services.json)
    // serverClientId = Web client ID, nécessaire pour obtenir idToken sur Android
    final clientId = EnvConfig.googleClientId;
    _googleSignIn = GoogleSignIn(
      clientId: clientId.isNotEmpty ? clientId : null,
      serverClientId: '523419302184-adncikquh0la93ocafmi8174ion8c2br.apps.googleusercontent.com',
      scopes: [
        'email',
        'profile',
      ],
    );
  }

  /// Se connecter avec Google
  Future<GoogleSignInAccount?> signIn() async {
    try {
      // Déconnecter d'abord pour forcer la sélection du compte
      await _googleSignIn.signOut();
      
      // Lancer le processus de connexion
      final account = await _googleSignIn.signIn();
      return account;
    } catch (error) {
      debugPrint('Erreur Google Sign In: $error');
      rethrow;
    }
  }

  /// Obtenir le token d'authentification Google
  Future<String?> getIdToken() async {
    try {
      final account = _googleSignIn.currentUser;
      if (account == null) return null;

      final auth = await account.authentication;
      return auth.idToken;
    } catch (error) {
      debugPrint('Erreur récupération token: $error');
      return null;
    }
  }

  /// Obtenir les informations de l'utilisateur connecté
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  /// Se déconnecter de Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (error) {
      debugPrint('Erreur déconnexion Google: $error');
    }
  }

  /// Déconnecter et révoquer l'accès
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
    } catch (error) {
      debugPrint('Erreur disconnect Google: $error');
    }
  }

  /// Vérifier si l'utilisateur est connecté
  bool get isSignedIn => _googleSignIn.currentUser != null;
}
