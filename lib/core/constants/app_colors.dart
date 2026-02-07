import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color darkPurple = Color(0xFF5B21B6); //Pour textes

  static const Color accentYellow = Color(0xFFFBBF24);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentBlue = Color(0xFF3B82F6);

  static const Color darkGray = Color(0xFF1F2937); //pour les titres
  static const Color mediumGray = Color(0xFF6B7280); //pour textes secandaire

  static const Color lightGray = Color(0xFFF3F4F6); //pour bordures

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color background = Color(0xFFF8F9FF); //Fond des cartes
  static const Color success = Color(0xFF10B981); //succes
  static const Color successLight = Color(0xFFD1FAE5);

  static const Color warning = Color(0xFFFBBF24); //avertissement
  static const Color warningLight = Color(0xFFFEF3C7);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);

  static const Color info = Color(0xFF3B82F6); //informations
  static const Color infoLight = Color(0xFFDBEAFE);

  static const Color lightPurple = Color(0xFFE6D9FF);
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft, // Début en haut à gauche
    end: Alignment.bottomRight, // Fin en bas à droite
    colors: [lightPurple, primaryPurple], // Du clair au foncé
  );

  /// Dégradé pour l'écran d'accueil
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [lightPurple, primaryPurple, darkPurple],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD1FAE5), Color(0xFFA7F3D0)],
  );

  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
  );
}
