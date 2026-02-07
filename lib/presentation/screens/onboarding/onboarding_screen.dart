import 'package:flutter/material.dart';
import 'package:hack_speech/presentation/screens/auth/login_screen.dart';
import '../../../core/constants/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      imagePath: 'assets/images/logo-elv.png',
      title: 'Transforme tes mots,\nchange le monde',
      description:
          'Détecte et transforme les discours haineux en messages constructifs grâce à l\'IA',
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF6D28D9), Color(0xFF8B5CF6)],
      ),
    ),
    OnboardingPage(
      emoji: '🏆',
      title: 'Gagne des points\nen restant diplomate',
      description:
          'Débloque des badges, monte de niveau et compare-toi à tes amis',
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
      ),
    ),
    OnboardingPage(
      imagePath: 'assets/images/image_agent.png',
      title: 'Protégé par Mira,\nton assistant IA',
      description:
          'Vérifie les infos, reformule tes messages et apprends à débattre sainement',
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.fromARGB(255, 52, 179, 211),
          Color.fromARGB(255, 34, 212, 247),
        ],
      ),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Pages
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _buildPage(_pages[index]);
            },
          ),

          // Skip button
          if (_currentPage < _pages.length - 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 20,
              child: TextButton(
                onPressed: _navigateToLogin,
                child: Text(
                  'Passer',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).padding.bottom + 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _buildIndicator(index == _currentPage),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Next/Start button with premium design
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                          spreadRadius: -5,
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primaryPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentPage == _pages.length - 1
                                  ? 'C\'est parti !'
                                  : 'Suivant',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryPurple.withValues(
                                  alpha: 0.1,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _currentPage == _pages.length - 1
                                    ? Icons.rocket_launch
                                    : Icons.arrow_forward,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Container(
      decoration: BoxDecoration(gradient: page.gradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.25),
                            Colors.white.withValues(alpha: 0.1),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 40,
                            offset: const Offset(0, 15),
                            spreadRadius: -5,
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(-5, -5),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: page.imagePath != null
                            ? ClipOval(
                                child: Image.asset(
                                  page.imagePath!,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Text(
                                page.emoji ?? '',
                                style: const TextStyle(fontSize: 80),
                              ),
                      ),
                    ),
                  );
                },
              ),

              const Spacer(flex: 1),

              // Title with shadow
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.2,
                  letterSpacing: -0.5,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Description with glassmorphism container
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Text(
                  page.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white.withValues(alpha: 0.95),
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 32 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPage {
  final String? emoji;
  final String? imagePath;
  final String title;
  final String description;
  final Gradient gradient;

  OnboardingPage({
    this.emoji,
    this.imagePath,
    required this.title,
    required this.description,
    required this.gradient,
  });
}
