// lib/core/services/persistence_service.dart
import 'package:flutter/material.dart';
import 'package:petverse/shared/models/pet_state.dart';
import 'package:petverse/shared/models/user_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

// class PersistenceService {
//   static const String _userKey =
//       'userData_v2'; // Incremented version for new User model
//   static const String _selectedPetIdKey = 'selectedPetId_v2';
//   static const String _petStatsKeyPrefix = 'petStats_v2_';
//   static const String _themeModeKey = 'themeMode_v2';

//   Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

//   Future<void> saveUser(UserProfile user) async =>
//       (await _prefs).setString(_userKey, jsonEncode(user.toJson()));
//   Future<UserProfile?> loadUser() async {
//     final s = (await _prefs).getString(_userKey);
//     if (s != null) {
//       try {
//         return UserProfile.fromJson(jsonDecode(s));
//       } catch (e) {
//         debugPrint("Erro ao carregar User: $e");
//         (await _prefs).remove(_userKey);
//       }
//     }
//     return null;
//   }

//   Future<void> saveSelectedPetId(String? id) async {
//     if (id == null) {
//       (await _prefs).remove(_selectedPetIdKey);
//     } else {
//       (await _prefs).setString(_selectedPetIdKey, id);
//     }
//   }

//   Future<String?> loadSelectedPetId() async =>
//       (await _prefs).getString(_selectedPetIdKey);
//   Future<void> savePetStats(String id, PetStats s) async => (await _prefs)
//       .setString('$_petStatsKeyPrefix$id', jsonEncode(s.toJson()));
//   Future<PetStats?> loadPetStats(String id) async {
//     final s = (await _prefs).getString('$_petStatsKeyPrefix$id');
//     if (s != null) {
//       try {
//         return PetStats.fromJson(jsonDecode(s));
//       } catch (e) {
//         debugPrint("Erro ao carregar PetStats para $id: $e");
//         (await _prefs).remove('$_petStatsKeyPrefix$id');
//       }
//     }
//     return null;
//   }

//   Future<void> saveThemeMode(ThemeMode mode) async =>
//       (await _prefs).setString(_themeModeKey, mode.toString());
//   Future<ThemeMode> loadThemeMode() async {
//     final s = (await _prefs).getString(_themeModeKey);
//     return ThemeMode.values
//         .firstWhere((e) => e.toString() == s, orElse: () => ThemeMode.dark);
//   }
// }

// lib/core/services/persistence_service.dart (ALTERADO)
class PersistenceService {
  // ... (outras chaves e métodos como saveUser, loadUser, etc.)
  static const String _themeModeKey = 'themeMode_v2';
  static const String _dayNightCycleKey = 'dayNightCycleEnabled_v1'; // NOVO

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<void> saveThemeMode(ThemeMode mode) async =>
      (await _prefs).setString(_themeModeKey, mode.toString());
  Future<ThemeMode> loadThemeMode() async {
    final s = (await _prefs).getString(_themeModeKey);
    return ThemeMode.values
        .firstWhere((e) => e.toString() == s, orElse: () => ThemeMode.dark);
  }

  // NOVO: Métodos para salvar/carregar preferência do ciclo dia/noite
  Future<void> saveDayNightCycleEnabled(bool enabled) async {
    await (await _prefs).setBool(_dayNightCycleKey, enabled);
  }

  Future<bool> loadDayNightCycleEnabled() async {
    return (await _prefs).getBool(_dayNightCycleKey) ??
        false; // Padrão é habilitado
  }

  // Mock methods from previous versions for UserNotifier to compile
  Future<void> clearUserData(String uid) async {}
  Future<UserProfile?> loadUserProfile(String uid) async {
    return null;
  }

  Future<void> saveUserProfile(String uid, UserProfile profile) async {}
  Future<String?> loadSelectedPetId(String uid) async {
    return null;
  }

  Future<void> saveSelectedPetId(String uid, String? petId) async {}
  Future<PetStats?> loadPetStats(String uid, String petId) async {
    return null;
  }

  Future<void> savePetStats(String uid, String petId, PetStats stats) async {}
}
