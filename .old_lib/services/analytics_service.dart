// File: lib/services/analytics_service.dart

import 'dart:developer' as developer;

/// Analytics service for tracking user events and app usage
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  bool _isEnabled = true;

  /// Enable or disable analytics
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Track user login event
  Future<void> trackLogin(String method) async {
    if (!_isEnabled) return;

    await _logEvent('user_login', {
      'method': method,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track pet adoption event
  Future<void> trackPetAdoption(String petId, String petType) async {
    if (!_isEnabled) return;

    await _logEvent('pet_adoption', {
      'pet_id': petId,
      'pet_type': petType,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track pet interaction event
  Future<void> trackPetInteraction(String action, String petId) async {
    if (!_isEnabled) return;

    await _logEvent('pet_interaction', {
      'action': action,
      'pet_id': petId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track daily reward claim
  Future<void> trackDailyRewardClaim(int day, int coins, int gems) async {
    if (!_isEnabled) return;

    await _logEvent('daily_reward_claim', {
      'day': day,
      'coins_earned': coins,
      'gems_earned': gems,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track level up event
  Future<void> trackLevelUp(int newLevel, String entityType, String entityId) async {
    if (!_isEnabled) return;

    await _logEvent('level_up', {
      'new_level': newLevel,
      'entity_type': entityType,
      'entity_id': entityId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track currency spent
  Future<void> trackCurrencySpent(String currency, int amount, String reason) async {
    if (!_isEnabled) return;

    await _logEvent('currency_spent', {
      'currency_type': currency,
      'amount': amount,
      'reason': reason,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track app screen views
  Future<void> trackScreenView(String screenName) async {
    if (!_isEnabled) return;

    await _logEvent('screen_view', {
      'screen_name': screenName,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track errors
  Future<void> trackError(String error, String? stackTrace, String? context) async {
    if (!_isEnabled) return;

    await _logEvent('app_error', {
      'error': error,
      'stack_trace': stackTrace,
      'context': context,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track user properties
  Future<void> setUserProperties({
    required String userId,
    int? level,
    int? totalPets,
    int? daysSinceInstall,
  }) async {
    if (!_isEnabled) return;

    developer.log(
      'Setting user properties for $userId',
      name: 'AnalyticsService',
      error: {
        'user_id': userId,
        'level': level,
        'total_pets': totalPets,
        'days_since_install': daysSinceInstall,
      },
    );
  }

  /// Log custom event
  Future<void> logCustomEvent(String eventName, Map<String, dynamic> parameters) async {
    if (!_isEnabled) return;

    await _logEvent(eventName, parameters);
  }

  /// Internal method to log events
  Future<void> _logEvent(String eventName, Map<String, dynamic> parameters) async {
    try {
      // In a real app, this would send to Firebase Analytics, Crashlytics, etc.
      developer.log(
        'Analytics Event: $eventName',
        name: 'AnalyticsService',
        error: parameters,
      );

      // Here you would implement actual analytics SDK calls:
      // await FirebaseAnalytics.instance.logEvent(name: eventName, parameters: parameters);
    } catch (e) {
      developer.log(
        'Failed to log analytics event: $eventName',
        name: 'AnalyticsService',
        error: e,
      );
    }
  }
}
