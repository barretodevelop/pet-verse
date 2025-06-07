// lib/data/services/settings_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Modelo para configurações do usuário
class UserSettings {
  // Aparência
  final ThemeMode themeMode;

  // Notificações
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;

  // Privacidade
  final bool analyticsEnabled;
  final bool crashReportsEnabled;

  // Perfil
  final String displayName;
  final String? profileImageUrl;
  final DateTime lastUpdated;

  UserSettings({
    required this.themeMode,
    required this.notificationsEnabled,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.analyticsEnabled,
    required this.crashReportsEnabled,
    required this.displayName,
    this.profileImageUrl,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  /// Cria configurações padrão
  factory UserSettings.defaults() {
    return UserSettings(
      themeMode: ThemeMode.system,
      notificationsEnabled: true,
      soundEnabled: true,
      vibrationEnabled: true,
      analyticsEnabled: false,
      crashReportsEnabled: true,
      displayName: 'Usuário Pet Lover',
    );
  }

  /// Converte para Map para Firebase
  Map<String, dynamic> toFirestore() {
    return {
      'themeMode': themeMode.index,
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'analyticsEnabled': analyticsEnabled,
      'crashReportsEnabled': crashReportsEnabled,
      'displayName': displayName,
      'profileImageUrl': profileImageUrl,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  /// Cria a partir de documento Firebase
  factory UserSettings.fromFirestore(Map<String, dynamic> data) {
    return UserSettings(
      themeMode: ThemeMode.values[data['themeMode'] ?? 0],
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      soundEnabled: data['soundEnabled'] ?? true,
      vibrationEnabled: data['vibrationEnabled'] ?? true,
      analyticsEnabled: data['analyticsEnabled'] ?? false,
      crashReportsEnabled: data['crashReportsEnabled'] ?? true,
      displayName: data['displayName'] ?? 'Usuário Pet Lover',
      profileImageUrl: data['profileImageUrl'],
      lastUpdated: data['lastUpdated'] != null
          ? (data['lastUpdated'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Cria cópia com alterações
  UserSettings copyWith({
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? analyticsEnabled,
    bool? crashReportsEnabled,
    String? displayName,
    String? profileImageUrl,
  }) {
    return UserSettings(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      crashReportsEnabled: crashReportsEnabled ?? this.crashReportsEnabled,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      lastUpdated: DateTime.now(),
    );
  }
}

/// Serviço para gerenciar configurações no Firebase
class SettingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  /// Stream das configurações do usuário
  Stream<UserSettings> getUserSettings() {
    if (_userId == null) {
      return Stream.value(UserSettings.defaults());
    }

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('settings')
        .doc('preferences')
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return UserSettings.defaults();
      }
      return UserSettings.fromFirestore(snapshot.data()!);
    });
  }

  /// Busca configurações atuais
  Future<UserSettings> getCurrentSettings() async {
    if (_userId == null) {
      return UserSettings.defaults();
    }

    try {
      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('settings')
          .doc('preferences')
          .get();

      if (!doc.exists) {
        // Cria configurações padrão
        await _createDefaultSettings();
        return UserSettings.defaults();
      }

      return UserSettings.fromFirestore(doc.data()!);
    } catch (e) {
      print('Erro ao buscar configurações: $e');
      return UserSettings.defaults();
    }
  }

  /// Atualiza configurações
  Future<void> updateSettings(UserSettings settings) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('settings')
          .doc('preferences')
          .set(settings.toFirestore(), SetOptions(merge: true));

      // Registra atividade
      await _logSettingsActivity('Configurações atualizadas');
    } catch (e) {
      print('Erro ao atualizar configurações: $e');
      rethrow;
    }
  }

  /// Atualiza tema
  Future<void> updateTheme(ThemeMode themeMode) async {
    final currentSettings = await getCurrentSettings();
    final newSettings = currentSettings.copyWith(themeMode: themeMode);
    await updateSettings(newSettings);
  }

  /// Atualiza configurações de notificação
  Future<void> updateNotificationSettings({
    bool? enabled,
    bool? sound,
    bool? vibration,
  }) async {
    final currentSettings = await getCurrentSettings();
    final newSettings = currentSettings.copyWith(
      notificationsEnabled: enabled,
      soundEnabled: sound,
      vibrationEnabled: vibration,
    );
    await updateSettings(newSettings);
  }

  /// Atualiza configurações de privacidade
  Future<void> updatePrivacySettings({
    bool? analytics,
    bool? crashReports,
  }) async {
    final currentSettings = await getCurrentSettings();
    final newSettings = currentSettings.copyWith(
      analyticsEnabled: analytics,
      crashReportsEnabled: crashReports,
    );
    await updateSettings(newSettings);
  }

  /// Atualiza perfil do usuário
  Future<void> updateUserProfile({
    String? displayName,
    String? profileImageUrl,
  }) async {
    if (_userId == null) return;

    try {
      // Atualiza nas configurações
      final currentSettings = await getCurrentSettings();
      final newSettings = currentSettings.copyWith(
        displayName: displayName,
        profileImageUrl: profileImageUrl,
      );
      await updateSettings(newSettings);

      // Atualiza também no documento principal do usuário
      await _firestore.collection('users').doc(_userId).update({
        'displayName': displayName,
        'profileImageUrl': profileImageUrl,
        'profileUpdatedAt': FieldValue.serverTimestamp(),
      });

      // Atualiza no FirebaseAuth se disponível
      final user = _auth.currentUser;
      if (user != null && displayName != null) {
        await user.updateDisplayName(displayName);
      }

      await _logSettingsActivity('Perfil atualizado');
    } catch (e) {
      print('Erro ao atualizar perfil: $e');
      rethrow;
    }
  }

  /// Exporta dados do usuário
  Future<Map<String, dynamic>> exportUserData() async {
    if (_userId == null) {
      throw Exception('Usuário não autenticado');
    }

    try {
      final userData = <String, dynamic>{};

      // Dados do usuário principal
      final userDoc = await _firestore.collection('users').doc(_userId).get();
      if (userDoc.exists) {
        userData['user'] = userDoc.data();
      }

      // Configurações
      final settingsDoc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('settings')
          .doc('preferences')
          .get();
      if (settingsDoc.exists) {
        userData['settings'] = settingsDoc.data();
      }

      // Atividades (limitado às últimas 100)
      final activities = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('activities')
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();
      userData['activities'] =
          activities.docs.map((doc) => doc.data()).toList();

      // Pets
      final pets = await _firestore
          .collection('pets')
          .where('ownerId', isEqualTo: _userId)
          .get();
      userData['pets'] = pets.docs.map((doc) => doc.data()).toList();

      userData['exportDate'] = DateTime.now().toIso8601String();
      userData['appVersion'] = '1.0.0';

      await _logSettingsActivity('Dados exportados');

      return userData;
    } catch (e) {
      print('Erro ao exportar dados: $e');
      rethrow;
    }
  }

  /// Deleta conta e todos os dados
  Future<void> deleteAccount() async {
    if (_userId == null) {
      throw Exception('Usuário não autenticado');
    }

    try {
      final batch = _firestore.batch();

      // Deleta documento principal do usuário
      batch.delete(_firestore.collection('users').doc(_userId));

      // Deleta pets do usuário
      final petsQuery = await _firestore
          .collection('pets')
          .where('ownerId', isEqualTo: _userId)
          .get();
      for (final doc in petsQuery.docs) {
        batch.delete(doc.reference);
      }

      // Deleta solicitações de adoção
      final requestsQuery = await _firestore
          .collection('adoption_requests')
          .where('creatorUserId', isEqualTo: _userId)
          .get();
      for (final doc in requestsQuery.docs) {
        batch.delete(doc.reference);
      }

      // Executa todas as deleções
      await batch.commit();

      // Deleta a conta do Firebase Auth
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      }
    } catch (e) {
      print('Erro ao deletar conta: $e');
      rethrow;
    }
  }

  /// Faz logout
  Future<void> logout() async {
    try {
      await _logSettingsActivity('Logout realizado');
      await _auth.signOut();
    } catch (e) {
      print('Erro ao fazer logout: $e');
      rethrow;
    }
  }

  /// Cria configurações padrão
  Future<void> _createDefaultSettings() async {
    if (_userId == null) return;

    final defaultSettings = UserSettings.defaults();
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('settings')
        .doc('preferences')
        .set(defaultSettings.toFirestore());
  }

  /// Registra atividade relacionada a configurações
  Future<void> _logSettingsActivity(String action) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('activities')
          .add({
        'title': 'Configurações',
        'description': action,
        'type': 'settings',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Log silencioso
      print('Erro ao registrar atividade: $e');
    }
  }

  /// Verifica se o usuário tem permissão para deletar a conta
  Future<bool> canDeleteAccount() async {
    if (_userId == null) return false;

    try {
      // Verifica se há pets adotados
      final adoptedPets = await _firestore
          .collection('pets')
          .where('ownerId', isEqualTo: _userId)
          .where('isAdopted', isEqualTo: true)
          .limit(1)
          .get();

      if (adoptedPets.docs.isNotEmpty) {
        return false; // Não pode deletar com pets adotados
      }

      // Verifica se há solicitações de adoção ativas
      final activeRequests = await _firestore
          .collection('adoption_requests')
          .where('creatorUserId', isEqualTo: _userId)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      return activeRequests.docs.isEmpty;
    } catch (e) {
      print('Erro ao verificar permissão: $e');
      return false;
    }
  }
}
