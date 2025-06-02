// lib/core/services/persistence_service.dart
// ALTERADO: Implementação completa com Firebase Firestore e SharedPreferences
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/models/pet_state.dart';
import '../../shared/models/user_state.dart';

class PersistenceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  SharedPreferences? _prefs;

  // Inicializar SharedPreferences
  Future<void> _ensurePrefsInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Chaves para SharedPreferences
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyDayNightCycle = 'day_night_cycle';
  static const String _keySelectedPetId = 'selected_pet_id_';
  static const String _keyOfflineUserData = 'offline_user_data_';
  static const String _keyOfflinePetStats = 'offline_pet_stats_';

  // Collections do Firestore
  static const String _usersCollection = 'users';
  static const String _userProfilesCollection = 'user_profiles';
  static const String _petStatsCollection = 'pet_stats';

  /// ===== TEMA E CONFIGURAÇÕES =====

  Future<ThemeMode> loadThemeMode() async {
    try {
      await _ensurePrefsInitialized();
      final themeModeString = _prefs!.getString(_keyThemeMode);

      switch (themeModeString) {
        case 'light':
          return ThemeMode.light;
        case 'dark':
          return ThemeMode.dark;
        case 'system':
          return ThemeMode.system;
        default:
          return ThemeMode.dark; // Padrão
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar tema: $e');
      return ThemeMode.dark;
    }
  }

  Future<void> saveThemeMode(ThemeMode themeMode) async {
    try {
      await _ensurePrefsInitialized();
      String themeModeString;

      switch (themeMode) {
        case ThemeMode.light:
          themeModeString = 'light';
          break;
        case ThemeMode.dark:
          themeModeString = 'dark';
          break;
        case ThemeMode.system:
          themeModeString = 'system';
          break;
      }

      await _prefs!.setString(_keyThemeMode, themeModeString);
      debugPrint('✅ Tema salvo: $themeModeString');
    } catch (e) {
      debugPrint('❌ Erro ao salvar tema: $e');
    }
  }

  Future<bool> loadDayNightCycleEnabled() async {
    try {
      await _ensurePrefsInitialized();
      return _prefs!.getBool(_keyDayNightCycle) ?? true; // Padrão: habilitado
    } catch (e) {
      debugPrint('❌ Erro ao carregar ciclo dia/noite: $e');
      return true;
    }
  }

  Future<void> saveDayNightCycleEnabled(bool enabled) async {
    try {
      await _ensurePrefsInitialized();
      await _prefs!.setBool(_keyDayNightCycle, enabled);
      debugPrint('✅ Ciclo dia/noite salvo: $enabled');
    } catch (e) {
      debugPrint('❌ Erro ao salvar ciclo dia/noite: $e');
    }
  }

  /// ===== USUÁRIO =====

  Future<UserProfile?> loadUserProfile(String firebaseUserId) async {
    try {
      // Tentar carregar do Firestore primeiro
      final doc = await _firestore
          .collection(_userProfilesCollection)
          .doc(firebaseUserId)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        debugPrint('✅ Perfil de usuário carregado do Firestore');
        return UserProfile.fromJson(data);
      }

      // Se não encontrar no Firestore, tentar carregar do cache local
      await _ensurePrefsInitialized();
      final cachedData =
          _prefs!.getString('$_keyOfflineUserData$firebaseUserId');

      if (cachedData != null) {
        final jsonData = jsonDecode(cachedData) as Map<String, dynamic>;
        debugPrint('✅ Perfil de usuário carregado do cache local');
        return UserProfile.fromJson(jsonData);
      }

      debugPrint('ℹ️ Nenhum perfil encontrado para usuário: $firebaseUserId');
      return null;
    } catch (e) {
      debugPrint('❌ Erro ao carregar perfil do usuário: $e');

      // Tentar fallback para cache local em caso de erro de rede
      try {
        await _ensurePrefsInitialized();
        final cachedData =
            _prefs!.getString('$_keyOfflineUserData$firebaseUserId');

        if (cachedData != null) {
          final jsonData = jsonDecode(cachedData) as Map<String, dynamic>;
          debugPrint('✅ Perfil carregado do cache local (fallback)');
          return UserProfile.fromJson(jsonData);
        }
      } catch (cacheError) {
        debugPrint('❌ Erro no cache local: $cacheError');
      }

      return null;
    }
  }

  Future<void> saveUserProfile(
      String firebaseUserId, UserProfile userProfile) async {
    try {
      final data = userProfile.toJson();
      data['updatedAt'] = FieldValue.serverTimestamp();

      // Salvar no Firestore
      await _firestore
          .collection(_userProfilesCollection)
          .doc(firebaseUserId)
          .set(data, SetOptions(merge: true));

      // Salvar cache local para acesso offline
      await _ensurePrefsInitialized();
      final jsonString = jsonEncode(data);
      await _prefs!
          .setString('$_keyOfflineUserData$firebaseUserId', jsonString);

      debugPrint('✅ Perfil de usuário salvo (Firestore + cache local)');
    } catch (e) {
      debugPrint('❌ Erro ao salvar perfil do usuário: $e');

      // Em caso de erro no Firestore, pelo menos salvar localmente
      try {
        await _ensurePrefsInitialized();
        final data = userProfile.toJson();
        final jsonString = jsonEncode(data);
        await _prefs!
            .setString('$_keyOfflineUserData$firebaseUserId', jsonString);
        debugPrint('✅ Perfil salvo apenas localmente (fallback)');
      } catch (localError) {
        debugPrint('❌ Erro crítico ao salvar localmente: $localError');
      }
    }
  }

  /// ===== PET =====

  Future<String?> loadSelectedPetId(String firebaseUserId) async {
    try {
      await _ensurePrefsInitialized();
      final petId = _prefs!.getString('$_keySelectedPetId$firebaseUserId');
      debugPrint('✅ Pet ID carregado: $petId');
      return petId;
    } catch (e) {
      debugPrint('❌ Erro ao carregar pet ID: $e');
      return null;
    }
  }

  Future<void> saveSelectedPetId(String firebaseUserId, String? petId) async {
    try {
      await _ensurePrefsInitialized();

      if (petId != null) {
        await _prefs!.setString('$_keySelectedPetId$firebaseUserId', petId);
        debugPrint('✅ Pet ID salvo: $petId');
      } else {
        await _prefs!.remove('$_keySelectedPetId$firebaseUserId');
        debugPrint('✅ Pet ID removido');
      }
    } catch (e) {
      debugPrint('❌ Erro ao salvar pet ID: $e');
    }
  }

  Future<PetStats?> loadPetStats(String firebaseUserId, String petId) async {
    try {
      final petDocId = '${firebaseUserId}_$petId';

      // Tentar carregar do Firestore primeiro
      final doc =
          await _firestore.collection(_petStatsCollection).doc(petDocId).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        debugPrint('✅ Stats do pet carregados do Firestore');
        return PetStats.fromJson(data);
      }

      // Se não encontrar no Firestore, tentar carregar do cache local
      await _ensurePrefsInitialized();
      final cachedData = _prefs!.getString('$_keyOfflinePetStats$petDocId');

      if (cachedData != null) {
        final jsonData = jsonDecode(cachedData) as Map<String, dynamic>;
        debugPrint('✅ Stats do pet carregados do cache local');
        return PetStats.fromJson(jsonData);
      }

      debugPrint('ℹ️ Nenhum stat encontrado para pet: $petId');
      return null;
    } catch (e) {
      debugPrint('❌ Erro ao carregar stats do pet: $e');

      // Tentar fallback para cache local
      try {
        final petDocId = '${firebaseUserId}_$petId';
        await _ensurePrefsInitialized();
        final cachedData = _prefs!.getString('$_keyOfflinePetStats$petDocId');

        if (cachedData != null) {
          final jsonData = jsonDecode(cachedData) as Map<String, dynamic>;
          debugPrint('✅ Stats carregados do cache local (fallback)');
          return PetStats.fromJson(jsonData);
        }
      } catch (cacheError) {
        debugPrint('❌ Erro no cache local: $cacheError');
      }

      return null;
    }
  }

  Future<void> savePetStats(
      String firebaseUserId, String petId, PetStats petStats) async {
    try {
      final petDocId = '${firebaseUserId}_$petId';
      final data = petStats.toJson();
      data['firebaseUserId'] = firebaseUserId;
      data['petId'] = petId;
      data['updatedAt'] = FieldValue.serverTimestamp();

      // Salvar no Firestore
      await _firestore
          .collection(_petStatsCollection)
          .doc(petDocId)
          .set(data, SetOptions(merge: true));

      // Salvar cache local para acesso offline
      await _ensurePrefsInitialized();
      final jsonString = jsonEncode(petStats.toJson());
      await _prefs!.setString('$_keyOfflinePetStats$petDocId', jsonString);

      debugPrint('✅ Stats do pet salvos (Firestore + cache local)');
    } catch (e) {
      debugPrint('❌ Erro ao salvar stats do pet: $e');

      // Em caso de erro no Firestore, pelo menos salvar localmente
      try {
        final petDocId = '${firebaseUserId}_$petId';
        await _ensurePrefsInitialized();
        final jsonString = jsonEncode(petStats.toJson());
        await _prefs!.setString('$_keyOfflinePetStats$petDocId', jsonString);
        debugPrint('✅ Stats salvos apenas localmente (fallback)');
      } catch (localError) {
        debugPrint('❌ Erro crítico ao salvar stats localmente: $localError');
      }
    }
  }

  /// ===== MÉTODOS DE LIMPEZA =====

  Future<void> clearUserData(String firebaseUserId) async {
    try {
      await _ensurePrefsInitialized();

      // Remover dados locais
      await _prefs!.remove('$_keySelectedPetId$firebaseUserId');
      await _prefs!.remove('$_keyOfflineUserData$firebaseUserId');

      // Remover dados de pets (buscar todas as chaves que começam com o padrão)
      final keys = _prefs!.getKeys();
      for (final key in keys) {
        if (key.startsWith('$_keyOfflinePetStats${firebaseUserId}_')) {
          await _prefs!.remove(key);
        }
      }

      debugPrint('✅ Dados locais do usuário limpos');
    } catch (e) {
      debugPrint('❌ Erro ao limpar dados do usuário: $e');
    }
  }

  Future<void> clearAllData() async {
    try {
      await _ensurePrefsInitialized();
      await _prefs!.clear();
      debugPrint('✅ Todos os dados locais foram limpos');
    } catch (e) {
      debugPrint('❌ Erro ao limpar todos os dados: $e');
    }
  }

  /// ===== MÉTODOS DE SINCRONIZAÇÃO =====

  Future<void> syncOfflineData(String firebaseUserId) async {
    try {
      debugPrint('🔄 Iniciando sincronização de dados offline...');

      await _ensurePrefsInitialized();

      // Sincronizar dados do usuário
      final userData = _prefs!.getString('$_keyOfflineUserData$firebaseUserId');
      if (userData != null) {
        try {
          final userJson = jsonDecode(userData) as Map<String, dynamic>;
          await _firestore
              .collection(_userProfilesCollection)
              .doc(firebaseUserId)
              .set(userJson, SetOptions(merge: true));
          debugPrint('✅ Dados do usuário sincronizados');
        } catch (e) {
          debugPrint('❌ Erro ao sincronizar dados do usuário: $e');
        }
      }

      // Sincronizar dados de pets
      final keys = _prefs!.getKeys();
      for (final key in keys) {
        if (key.startsWith('$_keyOfflinePetStats${firebaseUserId}_')) {
          try {
            final petData = _prefs!.getString(key);
            if (petData != null) {
              final petJson = jsonDecode(petData) as Map<String, dynamic>;
              final docId = key.replaceFirst(_keyOfflinePetStats, '');

              await _firestore
                  .collection(_petStatsCollection)
                  .doc(docId)
                  .set(petJson, SetOptions(merge: true));
              debugPrint('✅ Stats do pet sincronizados: $docId');
            }
          } catch (e) {
            debugPrint('❌ Erro ao sincronizar pet: $key - $e');
          }
        }
      }

      debugPrint('✅ Sincronização concluída');
    } catch (e) {
      debugPrint('❌ Erro na sincronização: $e');
    }
  }

  /// ===== MÉTODOS DE VERIFICAÇÃO =====

  Future<bool> hasInternetConnection() async {
    try {
      // Tentar uma operação simples no Firestore para verificar conectividade
      await _firestore.doc('_health_check/test').get();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      await _ensurePrefsInitialized();
      final keys = _prefs!.getKeys();

      int totalKeys = keys.length;
      int userDataKeys = 0;
      int petDataKeys = 0;
      int settingsKeys = 0;

      for (final key in keys) {
        if (key.contains('user_data')) {
          userDataKeys++;
        } else if (key.contains('pet_stats')) {
          petDataKeys++;
        } else if (key.contains('theme') || key.contains('cycle')) {
          settingsKeys++;
        }
      }

      return {
        'totalKeys': totalKeys,
        'userDataKeys': userDataKeys,
        'petDataKeys': petDataKeys,
        'settingsKeys': settingsKeys,
        'hasInternet': await hasInternetConnection(),
      };
    } catch (e) {
      debugPrint('❌ Erro ao obter informações de storage: $e');
      return {
        'error': e.toString(),
      };
    }
  }
}
