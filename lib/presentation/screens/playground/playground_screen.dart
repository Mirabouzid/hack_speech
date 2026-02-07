import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/api_providers.dart';
import '../chat/salam_chat_screen.dart';

class PlaygroundScreen extends ConsumerStatefulWidget {
  const PlaygroundScreen({super.key});

  @override
  ConsumerState<PlaygroundScreen> createState() => _PlaygroundScreenState();
}

class _PlaygroundScreenState extends ConsumerState<PlaygroundScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  late TabController _tabController;

  bool _isAnalyzing = false;
  bool _showResult = false;
  String _detectionResult = '';
  String _reformulatedMessage = '';
  double _toxicityScore = 0.0;
  String _category = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _analyzeMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      _showResult = false;
    });

    try {
      final detectionRepo = ref.read(detectionRepositoryProvider);
      final result = await detectionRepo.analyzeText(
        _messageController.text.trim(),
      );
      final bool isHateful = result['isHateSpeech'] ?? false;

      String reformulated = '';
      if (isHateful) {
        reformulated = await detectionRepo.reformulateText(
          _messageController.text.trim(),
        );
      }

      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _showResult = true;
        if (isHateful) {
          _detectionResult = 'Discours haineux détecté';
          _toxicityScore = (result['confidence'] ?? 0.0).toDouble();
          _category = _formatCategory(result['category']);
          _reformulatedMessage = reformulated;
        } else {
          _detectionResult = 'Message positif';
          _toxicityScore = (result['confidence'] ?? 0.05).toDouble();
          _category = 'Aucune';
          _reformulatedMessage = 'Ton message est déjà bienveillant ! 💚';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _showResult = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur d\'analyse: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatCategory(String? category) {
    switch (category) {
      case 'racism':
        return 'Racisme';
      case 'sexism':
        return 'Sexisme';
      case 'homophobia':
        return 'Homophobie';
      case 'religious':
        return 'Religieux';
      case 'ableism':
        return 'Validisme';
      case 'general_insult':
        return 'Insulte générale';
      default:
        return 'Autre';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' Playground'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            color: AppColors.primaryPurple,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              tabs: const [
                Tab(text: ' Détection & Reformulation'),
                Tab(text: ' Mira chat'),
              ],
            ),
          ),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildDetectionTab(), _buildFactCheckTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info card with glassmorphism
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryPurple.withValues(alpha: 0.08),
                  AppColors.accentBlue.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primaryPurple.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryPurple.withValues(alpha: 0.2),
                        AppColors.primaryPurple.withValues(alpha: 0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPurple.withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.primaryPurple,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Teste un message pour voir comment l\'IA le détecte et le reformule',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.darkGray,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Input field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText:
                    'Écris un message à tester...\n\nExemple: "T\'es qu\'un idiot"',
                hintStyle: TextStyle(
                  color: AppColors.mediumGray.withValues(alpha: 0.6),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(20),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Analyze button with premium design
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  spreadRadius: -5,
                ),
              ],
            ),
            child: SizedBox(
              height: 64,
              child: ElevatedButton(
                onPressed: _isAnalyzing ? null : _analyzeMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  disabledBackgroundColor: AppColors.primaryPurple.withValues(
                    alpha: 0.6,
                  ),
                ),
                child: _isAnalyzing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Text(
                            'Analyse en cours...',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.psychology, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Analyser avec l\'IA',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),

          // Results
          if (_showResult) ...[const SizedBox(height: 32), _buildResultCard()],
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final isHateful = _toxicityScore > 0.5;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(scale: 0.9 + (value * 0.1), child: child),
        );
      },
      child: Column(
        children: [
          // Alert banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isHateful
                    ? [Color(0xFFEF4444), Color(0xFFDC2626)]
                    : [Color(0xFF10B981), Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (isHateful ? Colors.red : Colors.green).withValues(
                    alpha: 0.3,
                  ),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      isHateful ? '🚨' : '✅',
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _detectionResult,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Catégorie: $_category',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Toxicity score
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Score de toxicité',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGray,
                      ),
                    ),
                    Text(
                      '${(_toxicityScore * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isHateful ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _toxicityScore,
                    minHeight: 12,
                    backgroundColor: AppColors.lightGray,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isHateful ? Colors.red : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (isHateful) ...[
            const SizedBox(height: 16),

            // Reformulation
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentGreen.withValues(alpha: 0.1),
                    AppColors.accentGreen.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.accentGreen.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.auto_fix_high,
                          color: AppColors.accentGreen,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Suggestion de reformulation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkGray,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _reformulatedMessage,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.darkGray,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFactCheckTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                // gradient: AppColors.primaryGradient,
                // shape: BoxShape.circle,
              ),
              child: const Center(
                child: Image(
                  image: AssetImage('assets/images/image_agent.png'),
                  width: 150,
                  height: 150,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Mira',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Cette fonctionnalité sera disponible dans l\'écran Mira Chat',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.mediumGray,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MiraChatScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Aller au Chat Mira'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
