import 'package:flutter/material.dart';
import 'package:hack_speech/presentation/screens/auth/login_screen.dart';
import '../../../core/constants/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.heroGradient,
          border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
        ),
        child: Stack(
          children: [
            // ✅ Contenu scrollable sans erreurs de layout
            SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: Column(
                  children: [
                    // ✨ Icône professionnelle améliorée
                    Padding(
                      padding: const EdgeInsets.only(top: 60, bottom: 20),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.15),
                              Colors.white.withValues(alpha: 0.05),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.2),
                              blurRadius: 25,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.chat_rounded, // ✨ Icône moderne et élégante
                            size: 52,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // Titre percutant
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          Text(
                            'Transformez\nLa Haine en\nHarmonie',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                              shadows: [
                                Shadow(
                                  blurRadius: 25,
                                  color: Colors.black.withValues(alpha: 0.4),
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Une IA empathique qui éduque sans juger',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.white.withValues(alpha: 0.92),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildFlag('🇹🇳', 'Tunisie'),
                        _buildFlag('🇫🇷', 'France'),
                        _buildFlag('🇬🇧', 'Royaume-Uni'),
                      ],
                    ),

                    const SizedBox(height: 40),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 25),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStat('+14', 'tonalités'),
                          _buildStat('+140', 'langues'),
                          _buildStat('AI', 'powered'),
                        ],
                      ),
                    ),

                    // Avis clients
                    const SizedBox(height: 30),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 25),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '★★★★★',
                            style: TextStyle(
                              fontSize: 28,
                              color: Colors.yellow,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '2M+ utilisateurs',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 25),
                      padding: const EdgeInsets.symmetric(vertical: 25),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildFeature(
                            '🛡️',
                            'Détection temps réel',
                            'Analyse instantanée des messages avec précision',
                          ),
                          const SizedBox(height: 20),
                          _buildFeature(
                            '💡',
                            'Suggestions intelligentes',
                            'Propositions constructives pour désamorcer les tensions',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // Bouton "Suivant" (toujours visible)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              right: 20,
              child: GestureDetector(
                onTap: () => _navigateToLogin(context),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 1.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.28),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlag(String emoji, String label) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 52,
      height: 68,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.8),
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildFeature(String icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.75),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
