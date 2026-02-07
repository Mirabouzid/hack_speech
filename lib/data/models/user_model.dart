class UserModel {
  final String id;
  final String email;
  final String name;
  final String? avatar;
  final int points;
  final int level;
  final List<String> badges;
  final bool soundEnabled;
  final bool darkModeEnabled;
  final String language;
  final String sensitivity;
  final NotificationMethods notificationMethods;
  final NotificationTypes notificationTypes;
  final String detectionMode;
  final String reformulationStyle;
  final List<String> blockedCategories;
  final List<String> customCategories;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
    this.points = 0,
    this.level = 1,
    this.badges = const [],
    this.soundEnabled = true,
    this.darkModeEnabled = false,
    this.language = 'Français',
    this.sensitivity = 'Moyen',
    required this.notificationMethods,
    required this.notificationTypes,
    this.detectionMode = 'reformulate',
    this.reformulationStyle = 'neutralization',
    this.blockedCategories = const ['racisme', 'sexisme', 'religieux'],
    this.customCategories = const [],
    required this.createdAt,
    this.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final settings = json['settings'] ?? {};
    final notifSettings = settings['notificationSettings'] ?? {};
    
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'],
      points: json['points'] ?? 0,
      level: json['level'] ?? 1,
      badges: List<String>.from(json['badges'] ?? []),
      soundEnabled: settings['soundEnabled'] ?? json['soundEnabled'] ?? true,
      darkModeEnabled: settings['darkModeEnabled'] ?? json['darkModeEnabled'] ?? false,
      language: settings['language'] ?? json['language'] ?? 'Français',
      sensitivity: settings['sensitivity'] ?? json['sensitivity'] ?? 'Moyen',
      notificationMethods: NotificationMethods.fromJson(notifSettings['methods'] ?? {}),
      notificationTypes: NotificationTypes.fromJson(notifSettings['types'] ?? {}),
      detectionMode: settings['detectionMode'] ?? 'reformulate',
      reformulationStyle: settings['reformulationStyle'] ?? 'neutralization',
      blockedCategories: List<String>.from(settings['blockedCategories'] ?? ['racisme', 'sexisme', 'religieux']),
      customCategories: List<String>.from(settings['customCategories'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'name': name,
      'avatar': avatar,
      'points': points,
      'level': level,
      'badges': badges,
      'soundEnabled': soundEnabled,
      'darkModeEnabled': darkModeEnabled,
      'language': language,
      'sensitivity': sensitivity,
      'notificationSettings': {
        'methods': notificationMethods.toJson(),
        'types': notificationTypes.toJson(),
      },
      'detectionMode': detectionMode,
      'reformulationStyle': reformulationStyle,
      'blockedCategories': blockedCategories,
      'customCategories': customCategories,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? avatar,
    int? points,
    int? level,
    List<String>? badges,
    bool? soundEnabled,
    bool? darkModeEnabled,
    String? language,
    String? sensitivity,
    NotificationMethods? notificationMethods,
    NotificationTypes? notificationTypes,
    String? detectionMode,
    String? reformulationStyle,
    List<String>? blockedCategories,
    List<String>? customCategories,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      points: points ?? this.points,
      level: level ?? this.level,
      badges: badges ?? this.badges,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      language: language ?? this.language,
      sensitivity: sensitivity ?? this.sensitivity,
      notificationMethods: notificationMethods ?? this.notificationMethods,
      notificationTypes: notificationTypes ?? this.notificationTypes,
      detectionMode: detectionMode ?? this.detectionMode,
      reformulationStyle: reformulationStyle ?? this.reformulationStyle,
      blockedCategories: blockedCategories ?? this.blockedCategories,
      customCategories: customCategories ?? this.customCategories,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}

class NotificationMethods {
  final bool email;
  final bool sms;
  final bool phone;
  final bool push;

  NotificationMethods({
    this.email = true,
    this.sms = false,
    this.phone = false,
    this.push = true,
  });

  factory NotificationMethods.fromJson(Map<String, dynamic> json) {
    return NotificationMethods(
      email: json['email'] ?? true,
      sms: json['sms'] ?? false,
      phone: json['phone'] ?? false,
      push: json['push'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'sms': sms,
      'phone': phone,
      'push': push,
    };
  }

  NotificationMethods copyWith({
    bool? email,
    bool? sms,
    bool? phone,
    bool? push,
  }) {
    return NotificationMethods(
      email: email ?? this.email,
      sms: sms ?? this.sms,
      phone: phone ?? this.phone,
      push: push ?? this.push,
    );
  }
}

class NotificationTypes {
  final bool weeklyDigest;
  final bool gamification;
  final bool securityAlerts;
  final bool educationalTips;

  NotificationTypes({
    this.weeklyDigest = true,
    this.gamification = true,
    this.securityAlerts = true,
    this.educationalTips = true,
  });

  factory NotificationTypes.fromJson(Map<String, dynamic> json) {
    return NotificationTypes(
      weeklyDigest: json['weeklyDigest'] ?? true,
      gamification: json['gamification'] ?? true,
      securityAlerts: json['securityAlerts'] ?? true,
      educationalTips: json['educationalTips'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weeklyDigest': weeklyDigest,
      'gamification': gamification,
      'securityAlerts': securityAlerts,
      'educationalTips': educationalTips,
    };
  }

  NotificationTypes copyWith({
    bool? weeklyDigest,
    bool? gamification,
    bool? securityAlerts,
    bool? educationalTips,
  }) {
    return NotificationTypes(
      weeklyDigest: weeklyDigest ?? this.weeklyDigest,
      gamification: gamification ?? this.gamification,
      securityAlerts: securityAlerts ?? this.securityAlerts,
      educationalTips: educationalTips ?? this.educationalTips,
    );
  }
}
