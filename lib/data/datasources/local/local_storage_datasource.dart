// File: lib/data/datasources/local/local_storage_datasource.dart

import 'dart:convert';

import 'package:petverse/core/config/app_config.dart';
import 'package:petverse/core/errors/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local storage datasource interface
abstract class LocalStorageDatasource {
  Future<void> cacheUserData(String userId, Map<String, dynamic> userData);
  Future<Map<String, dynamic>?> getCachedUserData(String userId);
  Future<void> clearUserCache(String userId);
  Future<void> setThemeMode(String themeMode);
  Future<String?> getThemeMode();
  Future<void> setOnboardingComplete(bool isComplete);
  Future<bool> getOnboardingComplete();
  Future<void> setLastDailyReward(String userId, DateTime dateTime);
  Future<DateTime?> getLastDailyReward(String userId);
  Future<void> clearAllCache();
}

/// Implementation of Local storage datasource
class LocalStorageDatasourceImpl implements LocalStorageDatasource {
  final SharedPreferences _prefs;

  LocalStorageDatasourceImpl(this._prefs);

  @override
  Future<void> cacheUserData(String userId, Map<String, dynamic> userData) async {
    try {
      final cacheKey = '${AppConstants.userDataCacheKey}_$userId';
      final jsonString = json.encode(userData);
      await _prefs.setString(cacheKey, jsonString);

      // Also store timestamp for cache expiry
      await _prefs.setInt('${cacheKey}_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      throw CacheException('Failed to cache user data: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getCachedUserData(String userId) async {
    try {
      final cacheKey = '${AppConstants.userDataCacheKey}_$userId';
      final jsonString = _prefs.getString(cacheKey);

      if (jsonString == null) return null;

      // Check if cache is expired (24 hours)
      final timestamp = _prefs.getInt('${cacheKey}_timestamp');
      if (timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final now = DateTime.now();
        if (now.difference(cacheTime).inHours > 24) {
          // Cache expired, remove it
          await clearUserCache(userId);
          return null;
        }
      }

      return Map<String, dynamic>.from(json.decode(jsonString));
    } catch (e) {
      throw CacheException('Failed to get cached user data: $e');
    }
  }

  @override
  Future<void> clearUserCache(String userId) async {
    try {
      final cacheKey = '${AppConstants.userDataCacheKey}_$userId';
      await _prefs.remove(cacheKey);
      await _prefs.remove('${cacheKey}_timestamp');
    } catch (e) {
      throw CacheException('Failed to clear user cache: $e');
    }
  }

  @override
  Future<void> setThemeMode(String themeMode) async {
    try {
      await _prefs.setString(AppConstants.themeCacheKey, themeMode);
    } catch (e) {
      throw CacheException('Failed to set theme mode: $e');
    }
  }

  @override
  Future<String?> getThemeMode() async {
    try {
      return _prefs.getString(AppConstants.themeCacheKey);
    } catch (e) {
      throw CacheException('Failed to get theme mode: $e');
    }
  }

  @override
  Future<void> setOnboardingComplete(bool isComplete) async {
    try {
      await _prefs.setBool(AppConstants.onboardingCompleteKey, isComplete);
    } catch (e) {
      throw CacheException('Failed to set onboarding status: $e');
    }
  }

  @override
  Future<bool> getOnboardingComplete() async {
    try {
      return _prefs.getBool(AppConstants.onboardingCompleteKey) ?? false;
    } catch (e) {
      throw CacheException('Failed to get onboarding status: $e');
    }
  }

  @override
  Future<void> setLastDailyReward(String userId, DateTime dateTime) async {
    try {
      final key = '${AppConstants.lastDailyRewardKey}_$userId';
      await _prefs.setString(key, dateTime.toIso8601String());
    } catch (e) {
      throw CacheException('Failed to set last daily reward: $e');
    }
  }

  @override
  Future<DateTime?> getLastDailyReward(String userId) async {
    try {
      final key = '${AppConstants.lastDailyRewardKey}_$userId';
      final dateString = _prefs.getString(key);
      return dateString != null ? DateTime.parse(dateString) : null;
    } catch (e) {
      throw CacheException('Failed to get last daily reward: $e');
    }
  }

  @override
  Future<void> clearAllCache() async {
    try {
      final keys = _prefs
          .getKeys()
          .where((key) =>
              key.startsWith(AppConstants.userDataCacheKey) ||
              key.startsWith(AppConstants.lastDailyRewardKey) ||
              key == AppConstants.themeCacheKey)
          .toList();

      for (final key in keys) {
        await _prefs.remove(key);
      }
    } catch (e) {
      throw CacheException('Failed to clear all cache: $e');
    }
  }
}
