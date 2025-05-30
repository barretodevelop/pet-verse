// lib/feature/auth/model/user_settings.dart
import 'dart:convert';

class UserSettings {
  final NotificationSettings notifications;
  final PrivacySettings privacy;
  final GameplaySettings gameplay;

  const UserSettings({
    required this.notifications,
    required this.privacy,
    required this.gameplay,
  });

  factory UserSettings.defaultSettings() {
    return UserSettings(
      notifications: NotificationSettings.defaultSettings(),
      privacy: PrivacySettings.defaultSettings(),
      gameplay: GameplaySettings.defaultSettings(),
    );
  }

  factory UserSettings.fromMap(Map<String, dynamic>? map) {
    map = map ?? {};
    return UserSettings(
      notifications: NotificationSettings.fromMap(map['notifications']),
      privacy: PrivacySettings.fromMap(map['privacy']),
      gameplay: GameplaySettings.fromMap(map['gameplay']),
    );
  }

  factory UserSettings.fromJson(String jsonString) {
    return UserSettings.fromMap(jsonDecode(jsonString));
  }

  Map<String, dynamic> toMap() {
    return {
      'notifications': notifications.toMap(),
      'privacy': privacy.toMap(),
      'gameplay': gameplay.toMap(),
    };
  }

  String toJson() => jsonEncode(toMap());

  UserSettings copyWith({
    NotificationSettings? notifications,
    PrivacySettings? privacy,
    GameplaySettings? gameplay,
  }) {
    return UserSettings(
      notifications: notifications ?? this.notifications,
      privacy: privacy ?? this.privacy,
      gameplay: gameplay ?? this.gameplay,
    );
  }
}

class NotificationSettings {
  final bool feeding;
  final bool playing;
  final bool cleaning;
  final bool luckyHour;
  final bool collaboration;
  final bool missions;
  final bool achievements;
  final bool social;

  const NotificationSettings({
    required this.feeding,
    required this.playing,
    required this.cleaning,
    required this.luckyHour,
    required this.collaboration,
    required this.missions,
    required this.achievements,
    required this.social,
  });

  factory NotificationSettings.defaultSettings() {
    return const NotificationSettings(
      feeding: true,
      playing: true,
      cleaning: true,
      luckyHour: true,
      collaboration: true,
      missions: true,
      achievements: true,
      social: false,
    );
  }

  factory NotificationSettings.fromMap(Map<String, dynamic>? map) {
    map = map ?? {};
    return NotificationSettings(
      feeding: map['feeding'] ?? true,
      playing: map['playing'] ?? true,
      cleaning: map['cleaning'] ?? true,
      luckyHour: map['luckyHour'] ?? true,
      collaboration: map['collaboration'] ?? true,
      missions: map['missions'] ?? true,
      achievements: map['achievements'] ?? true,
      social: map['social'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'feeding': feeding,
      'playing': playing,
      'cleaning': cleaning,
      'luckyHour': luckyHour,
      'collaboration': collaboration,
      'missions': missions,
      'achievements': achievements,
      'social': social,
    };
  }
}

class PrivacySettings {
  final bool showOnlineStatus;
  final bool allowCollaboration;
  final bool showInLeaderboards;
  final bool allowFriendRequests;

  const PrivacySettings({
    required this.showOnlineStatus,
    required this.allowCollaboration,
    required this.showInLeaderboards,
    required this.allowFriendRequests,
  });

  factory PrivacySettings.defaultSettings() {
    return const PrivacySettings(
      showOnlineStatus: true,
      allowCollaboration: true,
      showInLeaderboards: true,
      allowFriendRequests: true,
    );
  }

  factory PrivacySettings.fromMap(Map<String, dynamic>? map) {
    map = map ?? {};
    return PrivacySettings(
      showOnlineStatus: map['showOnlineStatus'] ?? true,
      allowCollaboration: map['allowCollaboration'] ?? true,
      showInLeaderboards: map['showInLeaderboards'] ?? true,
      allowFriendRequests: map['allowFriendRequests'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'showOnlineStatus': showOnlineStatus,
      'allowCollaboration': allowCollaboration,
      'showInLeaderboards': showInLeaderboards,
      'allowFriendRequests': allowFriendRequests,
    };
  }
}

class GameplaySettings {
  final bool autoSave;
  final bool soundEffects;
  final bool animations;
  final bool hapticFeedback;
  final double volume;

  const GameplaySettings({
    required this.autoSave,
    required this.soundEffects,
    required this.animations,
    required this.hapticFeedback,
    required this.volume,
  });

  factory GameplaySettings.defaultSettings() {
    return const GameplaySettings(
      autoSave: true,
      soundEffects: true,
      animations: true,
      hapticFeedback: true,
      volume: 0.8,
    );
  }

  factory GameplaySettings.fromMap(Map<String, dynamic>? map) {
    map = map ?? {};
    return GameplaySettings(
      autoSave: map['autoSave'] ?? true,
      soundEffects: map['soundEffects'] ?? true,
      animations: map['animations'] ?? true,
      hapticFeedback: map['hapticFeedback'] ?? true,
      volume: (map['volume'] ?? 0.8).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'autoSave': autoSave,
      'soundEffects': soundEffects,
      'animations': animations,
      'hapticFeedback': hapticFeedback,
      'volume': volume,
    };
  }
}
