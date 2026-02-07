import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/api_providers.dart';

class GuardianModeScreen extends ConsumerStatefulWidget {
  const GuardianModeScreen({super.key});

  @override
  ConsumerState<GuardianModeScreen> createState() => _GuardianModeScreenState();
}

class _GuardianModeScreenState extends ConsumerState<GuardianModeScreen> {
  bool _isParentMode = false;
  bool _isPinVerified = false;
  bool _isLoading = false;
  bool _hasPin = false;
  bool _isSettingPin = false;
  String? _savedPin;

  List<LinkedChild> _linkedChildren = [];

  @override
  void initState() {
    super.initState();
    _initGuardian();
  }

  Future<void> _initGuardian() async {
    final box = await Hive.openBox(AppConstants.settingsKey);
    final pin = box.get('guardian_pin');
    setState(() {
      _savedPin = pin;
      _hasPin = pin != null;
    });
  }

  Future<void> _savePin(String pin) async {
    final box = Hive.box(AppConstants.settingsKey);
    await box.put('guardian_pin', pin);
    setState(() {
      _savedPin = pin;
      _hasPin = true;
      _isSettingPin = false;
      _isPinVerified = true;
    });
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    setState(() => _isLoading = true);
    try {
      final guardianRepo = ref.read(guardianRepositoryProvider);
      final children = await guardianRepo.getChildren();
      if (!mounted) return;
      setState(() {
        _linkedChildren = children.map((c) => LinkedChild(
          name: c['name'] ?? 'Enfant',
          device: 'Appareil',
          isOnline: c['isOnline'] ?? false,
          extensionActive: true,
          lastActivity: DateTime.now(),
          todayStats: ChildStats(
            messagesAnalyzed: c['stats']?['messagesAnalyzed'] ?? 0,
            hateSpeechBlocked: c['stats']?['hateDetected'] ?? 0,
            categories: {},
          ),
        )).toList();
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
      appBar: AppBar(
        title: const Text('Guardian Mode'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isParentMode
              ? (_isPinVerified ? _buildParentView() : _buildPinEntry())
              : _buildChildView(),
      floatingActionButton: !_isParentMode
          ? null
          : FloatingActionButton.extended(
              onPressed: _showPairingDialog,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Lier un enfant'),
              backgroundColor: AppColors.primaryPurple,
            ),
    );
  }

  Widget _buildChildView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Info card - Premium glassmorphism
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.9),
                  AppColors.lightPurple.withValues(alpha: 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.15),
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
              children: [
                // Container(
                //   width: 90,
                //   height: 90,
                //   decoration: BoxDecoration(
                //     gradient: LinearGradient(
                //       begin: Alignment.topLeft,
                //       end: Alignment.bottomRight,
                //       colors: [
                //         AppColors.primaryPurple.withValues(alpha: 0.2),
                //         AppColors.accentBlue.withValues(alpha: 0.2),
                //       ],
                //     ),
                //     shape: BoxShape.circle,
                //     boxShadow: [
                //       // BoxShadow(
                //       //   color: AppColors.primaryPurple.withValues(alpha: 0.2),
                //       //   blurRadius: 16,
                //       //   offset: const Offset(0, 4),
                //       // ),
                //     ],
                //   ),
                //   // child: const Center(
                //   //   child: Text('👶', style: TextStyle(fontSize: 44)),
                //   // ),
                // ),
                const SizedBox(height: 20),
                Text(
                  'Compte Protégé',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGray,
                    letterSpacing: -0.5,
                    shadows: [
                      Shadow(
                        color: AppColors.primaryPurple.withValues(alpha: 0.1),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ton compte est lié à tes parents pour ta sécurité',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.mediumGray,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Features
          _buildFeatureCard(
            '🛡️',
            'Protection Active',
            'L\'extension détecte et bloque les discours haineux en temps réel',
            AppColors.accentGreen,
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            '👨‍👩‍👧',
            'Supervision Parentale',
            'Tes parents peuvent voir ton activité pour t\'aider',
            AppColors.accentBlue,
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            '🔒',
            'Vie Privée Respectée',
            'Le contenu exact de tes messages reste privé',
            AppColors.primaryPurple,
          ),

          const SizedBox(height: 32),

          // Switch to parent mode - Premium button
          Container(
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryPurple.withValues(alpha: 0.1),
                  AppColors.accentBlue.withValues(alpha: 0.1),
                ],
              ),
              border: Border.all(
                color: AppColors.primaryPurple.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isParentMode = true;
                    _isPinVerified = false;
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Accès Parent',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Link Child Button (Display QR)
          TextButton.icon(
            onPressed: _showMyQrCode,
            icon: const Icon(Icons.qr_code),
            label: const Text('Afficher mon code de liaison'),
          ),
        ],
      ),
    );
  }

  void _showMyQrCode() {
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final userAsync = ref.watch(currentUserProvider);
          return userAsync.when(
            data: (user) => AlertDialog(
              title: const Text('Mon Code de Liaison'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: QrImageView(
                      data: user.id,
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ID: ${user.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Demandez à votre parent de scanner ce code pour lier votre compte.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.mediumGray),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fermer'),
                ),
              ],
            ),
            loading: () => const AlertDialog(
              content: SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (_, __) => const AlertDialog(
              content: Text('Erreur lors de la récupération de votre ID'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPinEntry() {
    final pinController = TextEditingController();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.lock, size: 56, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Code PIN Parent',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.darkGray,
                letterSpacing: -0.5,
                shadows: [
                  Shadow(
                    color: AppColors.primaryPurple.withValues(alpha: 0.1),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Entrez votre code PIN pour accéder au mode parent',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.mediumGray),
            ),
            const SizedBox(height: 32),
            Container(
              constraints: const BoxConstraints(maxWidth: 300),
              child: TextField(
                controller: pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 16,
                ),
                decoration: InputDecoration(
                  hintText: '••••',
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.lightGray,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              height: 64,
              constraints: const BoxConstraints(maxWidth: 300),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (!_hasPin || _isSettingPin) {
                      if (pinController.text.length == 4) {
                        _savePin(pinController.text);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Le code doit faire 4 chiffres')),
                        );
                      }
                    } else {
                      if (pinController.text == _savedPin) {
                        setState(() {
                          _isPinVerified = true;
                        });
                        _loadChildren();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Code PIN incorrect'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            (!_hasPin || _isSettingPin) ? Icons.save : Icons.lock_open,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          (!_hasPin || _isSettingPin) ? 'Confirmer le PIN' : 'Déverrouiller',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_hasPin && !_isPinVerified) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() => _isSettingPin = true);
                },
                child: const Text('Changer le code PIN'),
              ),
            ],
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _isParentMode = false;
                });
              },
              child: const Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParentView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
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
                  child: const Center(
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mode Parent',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Surveillez et protégez vos enfants',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Children list
          const Text(
            'Enfants liés',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 16),

          if (_linkedChildren.isEmpty)
            _buildEmptyState()
          else
            ..._linkedChildren.map((child) => _buildChildCard(child)),
        ],
      ),
    );
  }

  Widget _buildChildCard(LinkedChild child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            child.isOnline
                ? AppColors.accentGreen.withValues(alpha: 0.03)
                : AppColors.lightGray.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 2),
        boxShadow: [
          BoxShadow(
            color: child.isOnline
                ? AppColors.accentGreen.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.8),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.accentYellow.withValues(alpha: 0.3),
                      AppColors.accentYellow.withValues(alpha: 0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentYellow.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('👤', style: TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkGray,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      child.device,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.mediumGray,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: child.isOnline
                      ? AppColors.accentGreen.withValues(alpha: 0.2)
                      : AppColors.mediumGray.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: child.isOnline
                            ? AppColors.accentGreen
                            : AppColors.mediumGray,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      child.isOnline ? 'En ligne' : 'Hors ligne',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: child.isOnline
                            ? AppColors.accentGreen
                            : AppColors.mediumGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Status
          Row(
            children: [
              Expanded(
                child: _buildStatusItem(
                  child.extensionActive ? Icons.check_circle : Icons.warning,
                  'Extension',
                  child.extensionActive ? 'Active' : 'Désactivée',
                  child.extensionActive
                      ? AppColors.accentGreen
                      : AppColors.accentRed,
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.lightGray),
              Expanded(
                child: _buildStatusItem(
                  Icons.access_time,
                  'Dernière activité',
                  _formatLastActivity(child.lastActivity),
                  AppColors.accentBlue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Today's stats - Premium glassmorphism
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.8),
                  AppColors.lightGray.withValues(alpha: 0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Statistiques du jour',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        '📝',
                        '${child.todayStats.messagesAnalyzed}',
                        'Messages',
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        '🛡️',
                        '${child.todayStats.hateSpeechBlocked}',
                        'Bloqués',
                      ),
                    ),
                  ],
                ),
                if (child.todayStats.categories.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Catégories détectées:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mediumGray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...child.todayStats.categories.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.accentRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${entry.key}: ${entry.value}x',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.darkGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Actions - Premium buttons
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primaryPurple.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPurple.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showFullReport(child),
                      borderRadius: BorderRadius.circular(16),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bar_chart,
                              size: 20,
                              color: AppColors.primaryPurple,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Rapport',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPurple.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showSettings(child),
                      borderRadius: BorderRadius.circular(16),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.settings, size: 20, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Réglages',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.mediumGray),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.darkGray,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.mediumGray),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    String emoji,
    String title,
    String description,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, color.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.8),
            blurRadius: 8,
            offset: const Offset(0, -2),
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
                colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.1)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 26)),
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

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text('👨‍👩‍👧', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text(
            'Aucun enfant lié',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scannez le QR Code depuis l\'extension Chrome de votre enfant',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.mediumGray),
          ),
        ],
      ),
    );
  }

  String _formatLastActivity(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return 'Il y a ${diff.inMinutes}min';
    } else if (diff.inHours < 24) {
      return 'Il y a ${diff.inHours}h';
    } else {
      return 'Il y a ${diff.inDays}j';
    }
  }

  void _showPairingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lier un enfant'),
        content: SizedBox(
          width: 300,
          height: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: MobileScanner(
                    onDetect: (capture) async {
                      final List<Barcode> barcodes = capture.barcodes;
                      for (final barcode in barcodes) {
                        if (barcode.rawValue != null) {
                          final String code = barcode.rawValue!;
                          Navigator.pop(context);
                          _linkChild(code);
                          break;
                        }
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Scannez le QR Code affiché sur l\'application de votre enfant',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  Future<void> _linkChild(String code) async {
    setState(() => _isLoading = true);
    try {
      final guardianRepo = ref.read(guardianRepositoryProvider);
      await guardianRepo.linkChild(code);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enfant lié avec succès'),
          backgroundColor: AppColors.accentGreen,
        ),
      );
      _loadChildren();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: AppColors.accentRed,
        ),
      );
    }
  }

  void _showFullReport(LinkedChild child) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rapport complet pour ${child.name}')),
    );
  }

  void _showSettings(LinkedChild child) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Réglages pour ${child.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Niveau de sensibilité',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildSensitivityOption('Bas', false),
            _buildSensitivityOption('Moyen', false),
            _buildSensitivityOption('Haut', true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Réglages sauvegardés')),
              );
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  Widget _buildSensitivityOption(String label, bool selected) {
    return ListTile(
      title: Text(label),
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: selected ? AppColors.primaryPurple : AppColors.mediumGray,
      ),
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Guardian Mode'),
        content: Text(
          'Le Guardian Mode permet aux parents de surveiller l\'activité '
          'de leurs enfants sans voir le contenu exact des messages.\n\n'
          'Vous pouvez voir :\n'
          '• Les catégories de discours haineux détectés\n'
          '• Le nombre de messages analysés\n'
          '• Le statut de l\'extension\n\n'
          'La vie privée de votre enfant est respectée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }
}

// Models
class LinkedChild {
  final String name;
  final String device;
  final bool isOnline;
  final bool extensionActive;
  final DateTime lastActivity;
  final ChildStats todayStats;

  LinkedChild({
    required this.name,
    required this.device,
    required this.isOnline,
    required this.extensionActive,
    required this.lastActivity,
    required this.todayStats,
  });
}

class ChildStats {
  final int messagesAnalyzed;
  final int hateSpeechBlocked;
  final Map<String, int> categories;

  ChildStats({
    required this.messagesAnalyzed,
    required this.hateSpeechBlocked,
    required this.categories,
  });
}
