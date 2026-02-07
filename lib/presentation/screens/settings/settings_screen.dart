import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/api_providers.dart';
import '../../../data/models/user_model.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSettings();
  }

  Future<void> _loadUserData() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final user = await authRepo.getCurrentUser();
      if (!mounted) { return; }
      setState(() {
        _user = user;
        // Mettre à jour les réglages depuis le serveur si disponibles
        _notificationsEnabled = true;
        _soundEnabled = user.soundEnabled;
        _darkModeEnabled = user.darkModeEnabled;
        _selectedLanguage = user.language;
        _selectedSensitivity = user.sensitivity;
        _detectionMode = user.detectionMode;
        _reformulationStyle = user.reformulationStyle;
        _blockedCategories = List<String>.from(user.blockedCategories);
        _customCategories = List<String>.from(user.customCategories);
        
        _notifEmail = user.notificationMethods.email;
        _notifSms = user.notificationMethods.sms;
        _notifPhone = user.notificationMethods.phone;
        _notifPush = user.notificationMethods.push;
        
        _typeWeekly = user.notificationTypes.weeklyDigest;
        _typeGamification = user.notificationTypes.gamification;
        _typeSecurity = user.notificationTypes.securityAlerts;
        _typeTips = user.notificationTypes.educationalTips;
      });
      // Synchroniser Hive avec les données serveur
      final box = Hive.box(AppConstants.settingsKey);
      await box.putAll({
        'notifications_enabled': true, // Keep for compatibility if needed
        'sound_enabled': user.soundEnabled,
        'dark_mode_enabled': user.darkModeEnabled,
        'language': user.language,
        'sensitivity': user.sensitivity,
        'detection_mode': user.detectionMode,
        'reformulation_style': user.reformulationStyle,
        'blocked_categories': user.blockedCategories,
        'custom_categories': user.customCategories,
        'notif_email': user.notificationMethods.email,
        'notif_sms': user.notificationMethods.sms,
        'notif_phone': user.notificationMethods.phone,
        'notif_push': user.notificationMethods.push,
        'type_weekly': user.notificationTypes.weeklyDigest,
        'type_gamification': user.notificationTypes.gamification,
        'type_security': user.notificationTypes.securityAlerts,
        'type_tips': user.notificationTypes.educationalTips,
      });
    } catch (_) {
      // En cas d'erreur API, charger au moins Hive
      _loadSettings();
    }
  }

  Future<void> _loadSettings() async {
    final box = Hive.box(AppConstants.settingsKey);
    setState(() {
      _notificationsEnabled = box.get('notifications_enabled', defaultValue: true);
      _soundEnabled = box.get('sound_enabled', defaultValue: true);
      _darkModeEnabled = box.get('dark_mode_enabled', defaultValue: false);
      _selectedLanguage = box.get('language', defaultValue: 'Français');
      _selectedSensitivity = box.get('sensitivity', defaultValue: 'Moyen');
      _detectionMode = box.get('detection_mode', defaultValue: 'reformulate');
      _reformulationStyle = box.get('reformulation_style', defaultValue: 'neutralization');
      _blockedCategories = List<String>.from(box.get('blocked_categories', defaultValue: ['racisme', 'sexisme', 'religieux']));
      _customCategories = List<String>.from(box.get('custom_categories', defaultValue: <String>[]));
      
      _notifEmail = box.get('notif_email', defaultValue: true);
      _notifSms = box.get('notif_sms', defaultValue: false);
      _notifPhone = box.get('notif_phone', defaultValue: false);
      _notifPush = box.get('notif_push', defaultValue: true);
      
      _typeWeekly = box.get('type_weekly', defaultValue: true);
      _typeGamification = box.get('type_gamification', defaultValue: true);
      _typeSecurity = box.get('type_security', defaultValue: true);
      _typeTips = box.get('type_tips', defaultValue: true);
    });
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    // 1. Sauvegarde locale immédiate (Hive)
    final box = Hive.box(AppConstants.settingsKey);
    await box.put(key, value);
    
    setState(() {
      if (key == 'notifications_enabled') { _notificationsEnabled = value; }
      if (key == 'sound_enabled') { _soundEnabled = value; }
      if (key == 'dark_mode_enabled') { _darkModeEnabled = value; }
      if (key == 'language') { _selectedLanguage = value; }
      if (key == 'sensitivity') { _selectedSensitivity = value; }
      if (key == 'detection_mode') { _detectionMode = value; }
      if (key == 'reformulation_style') { _reformulationStyle = value; }
      if (key == 'blocked_categories') { _blockedCategories = List<String>.from(value); }
      if (key == 'custom_categories') { _customCategories = List<String>.from(value); }
      if (key == 'notif_email') { _notifEmail = value; }
      if (key == 'notif_sms') { _notifSms = value; }
      if (key == 'notif_phone') { _notifPhone = value; }
      if (key == 'notif_push') { _notifPush = value; }
      if (key == 'type_weekly') { _typeWeekly = value; }
      if (key == 'type_gamification') { _typeGamification = value; }
      if (key == 'type_security') { _typeSecurity = value; }
      if (key == 'type_tips') { _typeTips = value; }
    });

    // 2. Synchronisation serveur
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.updateUserSettings({
        'notificationsEnabled': _notificationsEnabled,
        'soundEnabled': _soundEnabled,
        'darkModeEnabled': _darkModeEnabled,
        'language': _selectedLanguage,
        'sensitivity': _selectedSensitivity,
        'notificationSettings': {
          'methods': {
            'email': _notifEmail,
            'sms': _notifSms,
            'phone': _notifPhone,
            'push': _notifPush,
          },
          'types': {
            'weeklyDigest': _typeWeekly,
            'gamification': _typeGamification,
            'securityAlerts': _typeSecurity,
            'educationalTips': _typeTips,
          },
        },
        'detectionMode': _detectionMode,
      });
    } catch (e) {
      debugPrint('Erreur sync serveur: $e');
      // On ne bloque pas l'utilisateur car Hive a sauvegardé localement
    }

    if (!mounted) { return; }
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Paramètre synchronisé'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        width: 200,
        backgroundColor: AppColors.primaryPurple,
      ),
    );
  }

  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'Français';
  String _selectedSensitivity = 'Moyen';
  String _detectionMode = 'reformulate';
  String _reformulationStyle = 'neutralization';
  List<String> _blockedCategories = ['racisme', 'sexisme', 'religieux'];
  List<String> _customCategories = [];

  bool _notifEmail = true;
  bool _notifSms = false;
  bool _notifPhone = false;
  bool _notifPush = true;

  bool _typeWeekly = true;
  bool _typeGamification = true;
  bool _typeSecurity = true;
  bool _typeTips = true;

  final TextEditingController _customCategoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            _buildPremiumCard(
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryPurple.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: (_user?.avatar != null && _user!.avatar!.isNotEmpty)
                          ? Image.network(
                              _user!.avatar!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(child: Text('👤', style: TextStyle(fontSize: 36))),
                            )
                          : const Center(
                              child: Text('👤', style: TextStyle(fontSize: 36)),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _user?.name ?? 'Chargement...',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkGray,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _user?.email ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.mediumGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 20,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Detection & Reformulation Section
            _buildSectionTitle('Détection & Reformulation'),
            const SizedBox(height: 12),
            _buildPremiumCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mode de fonctionnement',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkGray),
                  ),
                  const SizedBox(height: 12),
                  _buildModeOption(
                    'block',
                    'Blocage Strict',
                    'Empêche l\'affichage de tout contenu haineux',
                    Icons.block,
                  ),
                  _buildModeOption(
                    'reformulate',
                    'Reformulation Intelligente',
                    'Transforme les messages pour les rendre positifs',
                    Icons.auto_awesome,
                  ),
                  
                  if (_detectionMode == 'reformulate') ...[
                    const Divider(height: 32),
                    const Text(
                      'Style de reformulation',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkGray),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildStyleOption('neutralization', 'Neutralisation'),
                        _buildStyleOption('informative', 'Informatif'),
                        _buildStyleOption('de_escalation', 'Désamorçage'),
                        _buildStyleOption('empathy', 'Empathie'),
                      ],
                    ),
                  ],

                  const Divider(height: 32),
                  const Text(
                    'Sensibilité de l\'IA',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkGray),
                  ),
                  const SizedBox(height: 12),
                  _buildSensitivityOption(
                    'Bas',
                    'Moins restrictif, tolère les nuances',
                  ),
                  const SizedBox(height: 12),
                  _buildSensitivityOption(
                    'Moyen',
                    'Équilibre idéal entre sécurité et liberté',
                  ),
                  const SizedBox(height: 12),
                  _buildSensitivityOption(
                    'Haut',
                    'Filtrage maximal des contenus douteux',
                  ),

                  const Divider(height: 32),
                  const Text(
                    'Catégories de haine ciblées',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkGray),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      'racisme', 'sexisme', 'religieux', 'homophobie', 'handicap'
                    ].map((cat) {
                      bool isSelected = _blockedCategories.contains(cat);
                      return FilterChip(
                        label: Text(cat[0].toUpperCase() + cat.substring(1)),
                        selected: isSelected,
                        onSelected: (val) {
                          final newList = List<String>.from(_blockedCategories);
                          if (val) {
                            newList.add(cat);
                          } else {
                            newList.remove(cat);
                          }
                          _updateSetting('blocked_categories', newList);
                        },
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 16),
                  const Text(
                    'Catégories personnalisées',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.mediumGray),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _customCategories.map((cat) {
                      return Chip(
                        label: Text(cat),
                        onDeleted: () {
                          final newList = List<String>.from(_customCategories)..remove(cat);
                          _updateSetting('custom_categories', newList);
                        },
                        deleteIcon: const Icon(Icons.close, size: 14),
                        backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.1),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customCategoryController,
                          decoration: InputDecoration(
                            hintText: 'Ajouter un type (ex: Cyberharcèlement)',
                            hintStyle: TextStyle(fontSize: 13, color: AppColors.mediumGray),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onSubmitted: (_) => _addCustomCategory(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _addCustomCategory,
                        icon: const Icon(Icons.add),
                        style: IconButton.styleFrom(backgroundColor: AppColors.primaryPurple),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Notifications Section
            _buildSectionTitle('Canaux de Notifications'),
            const SizedBox(height: 12),
            _buildPremiumCard(
              child: Column(
                children: [
                  _buildSwitchTile(
                    'Email',
                    'Recevoir par courrier électronique',
                    _notifEmail,
                    (value) => _updateSetting('notif_email', value),
                    icon: Icons.email_outlined,
                  ),
                  const Divider(height: 16),
                  _buildSwitchTile(
                    'SMS',
                    'Recevoir par message texte',
                    _notifSms,
                    (value) => _updateSetting('notif_sms', value),
                    icon: Icons.sms_outlined,
                  ),
                  const Divider(height: 16),
                  _buildSwitchTile(
                    'Appel Téléphonique',
                    'Alerte par appel vocal',
                    _notifPhone,
                    (value) => _updateSetting('notif_phone', value),
                    icon: Icons.phone_android_outlined,
                  ),
                  const Divider(height: 16),
                  _buildSwitchTile(
                    'Notification Push',
                    'Sur cette application mobile',
                    _notifPush,
                    (value) => _updateSetting('notif_push', value),
                    icon: Icons.notifications_active_outlined,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            
            _buildSectionTitle('Types de Contenus'),
            const SizedBox(height: 12),
            _buildPremiumCard(
              child: Column(
                children: [
                  _buildSwitchTile(
                    'Synthèse Hebdomadaire',
                    'Le rituel du dimanche soir',
                    _typeWeekly,
                    (value) => _updateSetting('type_weekly', value),
                    icon: Icons.auto_graph,
                  ),
                  const Divider(height: 16),
                  _buildSwitchTile(
                    'Gamification & Récompenses',
                    'L\'encouragement immédiat',
                    _typeGamification,
                    (value) => _updateSetting('type_gamification', value),
                    icon: Icons.emoji_events_outlined,
                  ),
                  const Divider(height: 16),
                  _buildSwitchTile(
                    'Alertes Sécurité',
                    'Protection en temps réel',
                    _typeSecurity,
                    (value) => _updateSetting('type_security', value),
                    icon: Icons.security_outlined,
                  ),
                  const Divider(height: 16),
                  _buildSwitchTile(
                    'Tips Éducatifs',
                    'Micro-learning discret (Smart Nudges)',
                    _typeTips,
                    (value) => _updateSetting('type_tips', value),
                    icon: Icons.lightbulb_outline,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Sound Settings move to Appearance or separate
            _buildSectionTitle('Sons & Retours'),
            const SizedBox(height: 12),
            _buildPremiumCard(
              child: Column(
                children: [
                  _buildSwitchTile(
                    'Sons',
                    'Jouer un son lors des interactions',
                    _soundEnabled,
                    (value) => _updateSetting('sound_enabled', value),
                    icon: Icons.volume_up_outlined,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Appearance
            _buildSectionTitle(' Apparence'),
            const SizedBox(height: 12),
            _buildPremiumCard(
              child: Column(
                children: [
                  _buildSwitchTile(
                    'Mode sombre',
                    'Activer le thème sombre',
                    _darkModeEnabled,
                    (value) => _updateSetting('dark_mode_enabled', value),
                  ),
                  const Divider(height: 24),
                  _buildSelectTile(
                    'Langue',
                    _selectedLanguage,
                    Icons.language,
                    () => _showLanguageDialog(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Account
            _buildSectionTitle('Compte'),
            const SizedBox(height: 12),
            _buildPremiumCard(
              child: Column(
                children: [
                  _buildActionTile(
                    'Changer le mot de passe',
                    Icons.lock_outline,
                    AppColors.accentBlue,
                    () => _showAccountActionDialog('Changer le mot de passe'),
                  ),
                  const Divider(height: 24),
                  _buildActionTile(
                    'Exporter mes données',
                    Icons.download,
                    AppColors.accentGreen,
                    () => _showAccountActionDialog('Exporter mes données'),
                  ),
                  const Divider(height: 24),
                  _buildActionTile(
                    'Supprimer mon compte',
                    Icons.delete_outline,
                    AppColors.accentRed,
                    () => _showAccountActionDialog('Supprimer mon compte', isDestructive: true),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // About
            _buildSectionTitle(' À propos'),
            const SizedBox(height: 12),
            _buildPremiumCard(
              child: Column(
                children: [
                  _buildInfoTile('Version', '1.0.0'),
                  const Divider(height: 24),
                  _buildActionTile(
                    'Conditions d\'utilisation',
                    Icons.description_outlined,
                    AppColors.primaryPurple,
                    () {},
                  ),
                  const Divider(height: 24),
                  _buildActionTile(
                    'Politique de confidentialité',
                    Icons.privacy_tip_outlined,
                    AppColors.primaryPurple,
                    () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Logout Button
            Container(
              width: double.infinity,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.accentRed.withValues(alpha: 0.1),
                    AppColors.accentRed.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.accentRed.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentRed.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showLogoutDialog(),
                  borderRadius: BorderRadius.circular(20),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.accentRed.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.logout,
                            color: AppColors.accentRed,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Se déconnecter',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accentRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: AppColors.darkGray,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildPremiumCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, AppColors.lightGray.withValues(alpha: 0.3)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.08),
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
      child: child,
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged, {
    IconData? icon,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primaryPurple, size: 18),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGray,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.mediumGray,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              // activeColor is deprecated in some Flutter versions/linters for adaptive
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectTile(
    String title,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryPurple.withValues(alpha: 0.2),
                    AppColors.accentBlue.withValues(alpha: 0.2),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryPurple, size: 20),
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
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.mediumGray,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.mediumGray),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
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
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGray,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.mediumGray),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.accentBlue.withValues(alpha: 0.2),
                AppColors.accentBlue.withValues(alpha: 0.1),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.info_outline,
            color: AppColors.accentBlue,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGray,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryPurple,
          ),
        ),
      ],
    );
  }

  Widget _buildModeOption(String mode, String title, String description, IconData icon) {
    bool isSelected = _detectionMode == mode;
    return GestureDetector(
      onTap: () => _updateSetting('detection_mode', mode),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPurple.withValues(alpha: 0.05) : AppColors.lightGray.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryPurple : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primaryPurple : AppColors.mediumGray),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primaryPurple : AppColors.darkGray,
                    ),
                  ),
                  Text(description, style: TextStyle(fontSize: 12, color: AppColors.mediumGray)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.primaryPurple),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleOption(String style, String label) {
    bool isSelected = _reformulationStyle == style;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _updateSetting('reformulation_style', style);
        }
      },
      selectedColor: AppColors.primaryPurple.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryPurple : AppColors.darkGray,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  void _addCustomCategory() {
    final text = _customCategoryController.text.trim();
    if (text.isNotEmpty && !_customCategories.contains(text) && !_blockedCategories.contains(text)) {
      final newList = List<String>.from(_customCategories)..add(text);
      _updateSetting('custom_categories', newList);
      _customCategoryController.clear();
    }
  }

  Widget _buildSensitivityOption(String level, String description) {
    final isSelected = _selectedSensitivity == level;
    return InkWell(
      onTap: () => _updateSetting('sensitivity', level),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryPurple.withValues(alpha: 0.1),
                    AppColors.accentBlue.withValues(alpha: 0.1),
                  ],
                )
              : null,
          color: isSelected ? null : AppColors.lightGray.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryPurple.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryPurple
                      : AppColors.mediumGray,
                  width: 2,
                ),
                color: isSelected
                    ? AppColors.primaryPurple
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppColors.primaryPurple
                          : AppColors.darkGray,
                    ),
                  ),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.mediumGray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('Français'),
            _buildLanguageOption('العربية'),
            _buildLanguageOption('English'),
          ],
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

  Widget _buildLanguageOption(String language) {
    final isSelected = _selectedLanguage == language;
    return ListTile(
      title: Text(language),
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? AppColors.primaryPurple : AppColors.mediumGray,
      ),
      onTap: () {
        _updateSetting('language', language);
        Navigator.pop(context);
      },
    );
  }

  void _showAccountActionDialog(String action, {bool isDestructive = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(action),
        content: Text('Cette fonctionnalité est en cours de déploiement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Se déconnecter'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Déconnexion réussie'),
                  backgroundColor: AppColors.accentGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentRed,
            ),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
  }
}
