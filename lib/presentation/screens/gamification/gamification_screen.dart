import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/api_providers.dart';

class GamificationScreen extends ConsumerStatefulWidget {
  const GamificationScreen({super.key});

  @override
  ConsumerState<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends ConsumerState<GamificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int userRank = 0;
  final String userCountry = 'Tunisie';
  int userPoints = 0;
  bool _isLoading = true;

  List<LeaderboardEntry> topUsers = [];
  List<BadgeItem> badges = [];
  WeeklyChallenge? currentChallenge;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadGamificationData();
  }

  Future<void> _loadGamificationData() async {
    try {
      final gamRepo = ref.read(gamificationRepositoryProvider);
      final statsRepo = ref.read(statsRepositoryProvider);

      final leaderboardFuture = gamRepo.getLeaderboard(limit: 10);
      final badgesFuture = gamRepo.getBadges();
      final challengeFuture = gamRepo.getCurrentChallenge();
      final statsFuture = statsRepo.getDashboardStats();

      final results = await Future.wait([
        leaderboardFuture,
        badgesFuture,
        challengeFuture,
        statsFuture,
      ]);

      if (!mounted) return;

      final leaderboard = results[0] as List;
      final apiBadges = results[1] as List;
      final apiChallenge = results[2];
      final stats = results[3];

      setState(() {
        userPoints = (stats as dynamic).user.points;

        topUsers = leaderboard
            .map(
              (e) => LeaderboardEntry(
                rank: (e as dynamic).rank,
                name: e.name,
                points: e.points,
                avatar: e.avatar ?? '👤',
              ),
            )
            .toList();

        // Find user rank
        for (int i = 0; i < topUsers.length; i++) {
          if (topUsers[i].points <= userPoints) {
            userRank = i + 1;
            break;
          }
        }
        if (userRank == 0 && topUsers.isNotEmpty) {
          userRank = topUsers.length + 1;
        }

        badges = apiBadges
            .map(
              (b) => BadgeItem(
                emoji: (b as dynamic).emoji,
                name: b.name,
                description: b.description,
                unlocked: b.unlocked,
                unlockedDate: b.unlockedDate,
              ),
            )
            .toList();

        if (badges.isEmpty) {
          badges = _getDefaultBadges();
        }

        if (apiChallenge != null) {
          final c = apiChallenge as dynamic;
          currentChallenge = WeeklyChallenge(
            title: c.title,
            description: c.description,
            progress: c.progress,
            total: c.target,
            reward: c.reward,
            emoji: c.emoji,
          );
        } else {
          currentChallenge = WeeklyChallenge(
            title: 'Analyse 5 messages aujourd\'hui',
            description: 'Utilise le playground pour analyser des messages',
            progress: 0,
            total: 5,
            reward: 50,
            emoji: '🎯',
          );
        }

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        badges = _getDefaultBadges();
        currentChallenge = WeeklyChallenge(
          title: 'Analyse 5 messages aujourd\'hui',
          description: 'Utilise le playground pour analyser des messages',
          progress: 0,
          total: 5,
          reward: 50,
          emoji: '🎯',
        );
        _isLoading = false;
      });
    }
  }

  List<BadgeItem> _getDefaultBadges() {
    return [
      BadgeItem(
        emoji: '🥇',
        name: 'Premier Pas',
        description: 'Première intervention réussie',
        unlocked: false,
      ),
      BadgeItem(
        emoji: '🌟',
        name: 'Diplomate',
        description: 'Reformulé 10 messages',
        unlocked: false,
      ),
      BadgeItem(
        emoji: '💚',
        name: 'Pacificateur',
        description: 'Stoppé 50 discours haineux',
        unlocked: false,
      ),
      BadgeItem(
        emoji: '🎯',
        name: 'Expert',
        description: 'Atteint le niveau 10',
        unlocked: false,
      ),
      BadgeItem(
        emoji: '🏅',
        name: 'Champion',
        description: 'Top 50 du classement',
        unlocked: false,
      ),
      BadgeItem(
        emoji: '🔥',
        name: 'Série',
        description: '7 jours consécutifs',
        unlocked: false,
      ),
    ];
  }

  Widget _buildAvatarWidget(String avatar, double fontSize) {
    if (avatar.startsWith('http')) {
      return ClipOval(
        child: Image.network(
          avatar,
          width: fontSize * 1.8,
          height: fontSize * 1.8,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Text('👤', style: TextStyle(fontSize: fontSize)),
        ),
      );
    }
    return Text(avatar, style: TextStyle(fontSize: fontSize));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gamification'),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          tabs: const [
            Tab(text: 'Classement'),
            Tab(text: 'Badges'),
            Tab(text: 'Défis'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLeaderboardTab(),
                _buildBadgesTab(),
                _buildChallengesTab(),
              ],
            ),
    );
  }

  Widget _buildLeaderboardTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // User rank card
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Mon Classement',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '#$userRank',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'en $userCountry',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 2,
                      height: 60,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    Column(
                      children: [
                        Text(
                          '$userPoints',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Points',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Top 3 Podium
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🏆 Top 3',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 16),
                if (topUsers.length >= 3)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPodiumPlace(topUsers[1], 2, 140),
                      const SizedBox(width: 8),
                      _buildPodiumPlace(topUsers[0], 1, 180),
                      const SizedBox(width: 8),
                      _buildPodiumPlace(topUsers[2], 3, 120),
                    ],
                  )
                else if (topUsers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'Aucun classement disponible',
                        style: TextStyle(color: AppColors.mediumGray, fontSize: 14),
                      ),
                    ),
                  )
                else
                  Column(
                    children: topUsers
                        .map((entry) => _buildLeaderboardTile(entry))
                        .toList(),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Other rankings
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Autres classements',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 12),
                ...topUsers
                    .skip(3)
                    .map((entry) => _buildLeaderboardTile(entry)),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPodiumPlace(LeaderboardEntry entry, int place, double height) {
    Color color;
    String medal;
    List<Color> gradientColors;

    switch (place) {
      case 1:
        color = const Color(0xFFFFD700); // Gold
        medal = '🥇';
        gradientColors = [const Color(0xFFFFD700), const Color(0xFFFFB800)];
        break;
      case 2:
        color = const Color(0xFFC0C0C0); // Silver
        medal = '🥈';
        gradientColors = [const Color(0xFFC0C0C0), const Color(0xFFA8A8A8)];
        break;
      case 3:
        color = const Color(0xFFCD7F32); // Bronze
        medal = '🥉';
        gradientColors = [const Color(0xFFCD7F32), const Color(0xFFB86F28)];
        break;
      default:
        color = AppColors.mediumGray;
        medal = '';
        gradientColors = [AppColors.mediumGray, AppColors.mediumGray];
    }

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.2),
                  color.withValues(alpha: 0.1),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 3),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Center(
              child: _buildAvatarWidget(entry.avatar, 32),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            entry.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.darkGray,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${entry.points} pts',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.mediumGray,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: gradientColors,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Center(
              child: Text(medal, style: const TextStyle(fontSize: 48)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTile(LeaderboardEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, AppColors.lightGray.withValues(alpha: 0.3)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.6),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#${entry.rank}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGray,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accentYellow.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: _buildAvatarWidget(entry.avatar, 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGray,
              ),
            ),
          ),
          Text(
            '${entry.points}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryPurple,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'pts',
            style: TextStyle(fontSize: 12, color: AppColors.mediumGray),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesTab() {
    final unlockedBadges = badges.where((b) => b.unlocked).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.successGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🏆', style: TextStyle(fontSize: 30)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$unlockedBadges sur ${badges.length} badges',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkGray,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: unlockedBadges / badges.length,
                          minHeight: 8,
                          backgroundColor: Colors.white.withValues(alpha: 0.5),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.accentGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Badges grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: badges.length,
            itemBuilder: (context, index) {
              return _buildBadgeCard(badges[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(BadgeItem badge) {
    return GestureDetector(
      onTap: () => _showBadgeDetails(badge),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: badge.unlocked
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    AppColors.accentYellow.withValues(alpha: 0.1),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.lightGray.withValues(alpha: 0.5),
                    AppColors.lightGray.withValues(alpha: 0.3),
                  ],
                ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: badge.unlocked
                ? AppColors.accentYellow.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: badge.unlocked
              ? [
                  BoxShadow(
                    color: AppColors.accentYellow.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.8),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: badge.unlocked ? 1.0 : 0.3,
              child: Text(badge.emoji, style: const TextStyle(fontSize: 50)),
            ),
            const SizedBox(height: 12),
            Text(
              badge.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: badge.unlocked
                    ? AppColors.darkGray
                    : AppColors.mediumGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              badge.description,
              style: TextStyle(fontSize: 12, color: AppColors.mediumGray),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (badge.unlocked && badge.unlockedDate != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge.unlockedDate!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentGreen,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChallengesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            ' Défi de la semaine',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 16),

          // Current challenge
          if (currentChallenge != null) _buildChallengeCard(currentChallenge!),

          const SizedBox(height: 32),

          const Text(
            'Défis à venir',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 16),

          // Upcoming challenges
          _buildUpcomingChallenge(
            '🌟',
            'Série de 7 jours',
            'Utilise l\'app pendant 7 jours consécutifs',
            100,
          ),
          const SizedBox(height: 12),
          _buildUpcomingChallenge(
            '💬',
            'Reformule 5 messages',
            'Utilise les suggestions de l\'IA',
            75,
          ),
          const SizedBox(height: 12),
          _buildUpcomingChallenge(
            '🔍',
            'Vérifie 3 infos',
            'Utilise Mira pour fact-checker',
            50,
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(WeeklyChallenge challenge) {
    final progress = challenge.progress / challenge.total;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, AppColors.accentYellow.withValues(alpha: 0.2)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentYellow.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.8),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    challenge.emoji,
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
                      challenge.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkGray,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      challenge.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.darkGray.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${challenge.progress}/${challenge.total}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGray,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentYellow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${challenge.reward} pts',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.white.withValues(alpha: 0.5),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.accentYellow,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingChallenge(
    String emoji,
    String title,
    String description,
    int reward,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGray, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.mediumGray,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+$reward',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.accentYellow,
            ),
          ),
        ],
      ),
    );
  }

  void _showBadgeDetails(BadgeItem badge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(badge.emoji, style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            Text(
              badge.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badge.description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: AppColors.mediumGray),
            ),
            if (badge.unlocked && badge.unlockedDate != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '✅ Débloqué le ${badge.unlockedDate}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentGreen,
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.mediumGray.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '🔒 Pas encore débloqué',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mediumGray,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

// Models
class LeaderboardEntry {
  final int rank;
  final String name;
  final int points;
  final String avatar;

  LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.points,
    required this.avatar,
  });
}

class BadgeItem {
  final String emoji;
  final String name;
  final String description;
  final bool unlocked;
  final String? unlockedDate;

  BadgeItem({
    required this.emoji,
    required this.name,
    required this.description,
    required this.unlocked,
    this.unlockedDate,
  });
}

class WeeklyChallenge {
  final String title;
  final String description;
  final int progress;
  final int total;
  final int reward;
  final String emoji;

  WeeklyChallenge({
    required this.title,
    required this.description,
    required this.progress,
    required this.total,
    required this.reward,
    required this.emoji,
  });
}
