import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/api_providers.dart';
import '../../../data/models/dashboard_stats_model.dart';
import '../chat/salam_chat_screen.dart';
import '../gamification/gamification_screen.dart';
import '../guardian/guardian_mode_screen.dart';
import '../playground/playground_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  String userName = '';
  int userPoints = 0;
  int userLevel = 1;
  int messagesAnalyzed = 0;
  int messagesImproved = 0;
  int badgesUnlocked = 0;
  int hatersStopped = 0;
  int harmonyScore = 100;
  List<int> weeklyData = [0, 0, 0, 0, 0, 0, 0];
  List<CategoryStat> categoryStats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    // Charger le nom utilisateur immédiatement via authRepo
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final user = await authRepo.getCurrentUser();
      if (!mounted) return;
      setState(() {
        userName = user.name;
        userPoints = user.points;
        userLevel = user.level;
      });
    } catch (_) {}

    // Charger les stats complètes
    try {
      final statsRepo = ref.read(statsRepositoryProvider);
      final stats = await statsRepo.getDashboardStats();
      debugPrint(
        '📊 Stats reçues: Analyzed=${stats.messagesAnalyzed}, Improved=${stats.messagesImproved}, Points=${stats.user.points}',
      );
      if (!mounted) return;
      setState(() {
        userName = stats.user.name;
        userPoints = stats.user.points;
        userLevel = stats.user.level;
        messagesAnalyzed = stats.messagesAnalyzed;
        messagesImproved = stats.messagesImproved;
        hatersStopped = stats
            .messagesImproved; // Utiliser le nombre de messages de haine/reformulés
        badgesUnlocked = stats.badgesUnlocked;
        harmonyScore = stats.harmonyScore;
        weeklyData = stats.weeklyData;
        categoryStats = stats.categoryStats;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboard(),
          const MiraChatScreen(),
          const GamificationScreen(),
          const GuardianModeScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primaryPurple,
          unselectedItemColor: AppColors.mediumGray,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Mira',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined),
              activeIcon: Icon(Icons.emoji_events),
              label: 'Game',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shield_outlined),
              activeIcon: Icon(Icons.shield),
              label: 'Family',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu),
              activeIcon: Icon(Icons.menu_open),
              label: 'Menu',
            ),
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentYellow.withValues(alpha: 0.4),
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PlaygroundScreen(),
                    ),
                  );
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.darkGray.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow, size: 20),
                ),
                label: const Text(
                  'Test l\'IA',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    letterSpacing: 0.3,
                  ),
                ),
                backgroundColor: AppColors.accentYellow,
                foregroundColor: AppColors.darkGray,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildDashboard() {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('ElevateAi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications: À implémenter')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildImpactCards(),
            const SizedBox(height: 20),
            _buildWeeklyChart(),
            const SizedBox(height: 20),
            _buildHateTypesPieChart(),
            const SizedBox(height: 20),
            _buildQuickActions(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bonjour ${userName.split(' ').first} ! 👋',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tu fais un excellent travail',
            style: TextStyle(
              fontSize: 17,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.25),
                  Colors.white.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Niveau',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$userLevel',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 2,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.5),
                        Colors.white.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Points',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$userPoints',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🏆', style: TextStyle(fontSize: 32)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            ' Mon Impact',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildImpactCard(
                  '🛡️',
                  '$hatersStopped',
                  'Haters stoppés\ncette semaine',
                  AppColors.accentRed,
                ),
                const SizedBox(width: 12),
                _buildImpactCard(
                  '✨',
                  '$messagesImproved',
                  'Messages\nreformulés',
                  AppColors.accentGreen,
                ),
                const SizedBox(width: 12),
                _buildImpactCard(
                  '💚',
                  '$harmonyScore/100',
                  'Score\nd\'Harmonie',
                  AppColors.primaryPurple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactCard(
    String emoji,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, color.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.8),
            blurRadius: 10,
            offset: const Offset(-5, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 32)),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.darkGray,
              height: 1.4,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
            const Text(
              'Évolution hebdomadaire',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: weeklyData.every((v) => v == 0)
                      ? 10
                      : (weeklyData.reduce((a, b) => a > b ? a : b).toDouble() *
                                1.2)
                            .ceilToDouble(),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = [
                            'Lun',
                            'Mar',
                            'Mer',
                            'Jeu',
                            'Ven',
                            'Sam',
                            'Dim',
                          ];
                          return Text(
                            days[value.toInt()],
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.mediumGray,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(
                    7,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: weeklyData[index].toDouble(),
                          gradient: AppColors.primaryGradient,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHateTypesPieChart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
            const Text(
              'Types de haine bloqués',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 150,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(
                            value: 40,
                            title: '40%',
                            color: AppColors.accentRed,
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            value: 20,
                            title: '20%',
                            color: AppColors.accentYellow,
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            value: 15,
                            title: '15%',
                            color: AppColors.accentBlue,
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            value: 25,
                            title: '25%',
                            color: AppColors.mediumGray,
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem('Racisme', AppColors.accentRed, '40%'),
                      const SizedBox(height: 8),
                      _buildLegendItem(
                        'Sexisme',
                        AppColors.accentYellow,
                        '20%',
                      ),
                      const SizedBox(height: 8),
                      _buildLegendItem(
                        'Religieux',
                        AppColors.accentBlue,
                        '15%',
                      ),
                      const SizedBox(height: 8),
                      _buildLegendItem('Autres', AppColors.mediumGray, '25%'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String percentage) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.darkGray),
          ),
        ),
        Text(
          percentage,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.darkGray,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions rapides',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  Icons.chat_bubble_outline,
                  'Chat Mira',
                  AppColors.primaryPurple,
                  () {
                    setState(() {
                      _currentIndex = 1;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  Icons.emoji_events_outlined,
                  'Classement',
                  AppColors.accentYellow,
                  () {
                    setState(() {
                      _currentIndex = 2;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
