// lib/presentation/providers/settings_provider.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:petverse/core/service/settings_service.dart';

import 'package:petverse/presentation/providers/theme_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Provider para o serviço de configurações
final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

/// Provider para stream de configurações do usuário
final userSettingsStreamProvider = StreamProvider<UserSettings>((ref) {
  final service = ref.watch(settingsServiceProvider);
  return service.getUserSettings();
});

/// Provider para configurações atuais (não stream)
final currentUserSettingsProvider = FutureProvider<UserSettings>((ref) async {
  final service = ref.watch(settingsServiceProvider);
  return service.getCurrentSettings();
});

/// StateNotifier para gerenciar ações de configurações
class SettingsActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final SettingsService _service;
  final Ref _ref;

  SettingsActionsNotifier(this._service, this._ref)
      : super(const AsyncData(null));

  /// Atualiza o tema
  Future<void> updateTheme(ThemeMode themeMode) async {
    state = const AsyncLoading();

    try {
      await _service.updateTheme(themeMode);

      // Atualiza o provider de tema global
      _ref.read(themeModeProvider.notifier).setTheme(themeMode);

      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  /// Atualiza notificações
  Future<void> updateNotifications({
    bool? enabled,
    bool? sound,
    bool? vibration,
  }) async {
    state = const AsyncLoading();

    try {
      await _service.updateNotificationSettings(
        enabled: enabled,
        sound: sound,
        vibration: vibration,
      );

      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  /// Atualiza privacidade
  Future<void> updatePrivacy({
    bool? analytics,
    bool? crashReports,
  }) async {
    state = const AsyncLoading();

    try {
      await _service.updatePrivacySettings(
        analytics: analytics,
        crashReports: crashReports,
      );

      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  /// Atualiza perfil
  Future<void> updateProfile({
    String? displayName,
    String? profileImageUrl,
  }) async {
    state = const AsyncLoading();

    try {
      await _service.updateUserProfile(
        displayName: displayName,
        profileImageUrl: profileImageUrl,
      );

      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  /// Exporta dados do usuário
  Future<void> exportUserData(BuildContext context) async {
    state = const AsyncLoading();

    try {
      final data = await _service.exportUserData();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      // Salva em arquivo temporário
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/petverse_data_export.json');
      await file.writeAsString(jsonString);

      // Compartilha o arquivo
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'PetVerse - Exportação de Dados',
      );

      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  /// Deleta a conta
  Future<bool> deleteAccount() async {
    state = const AsyncLoading();

    try {
      // Verifica se pode deletar
      final canDelete = await _service.canDeleteAccount();
      if (!canDelete) {
        state = const AsyncError(
          'Você não pode deletar sua conta enquanto tiver pets adotados ou solicitações ativas',
          StackTrace.empty,
        );
        return false;
      }

      await _service.deleteAccount();
      state = const AsyncData(null);
      return true;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      return false;
    }
  }

  /// Faz logout
  Future<void> logout() async {
    state = const AsyncLoading();

    try {
      await _service.logout();
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}

/// Provider para ações de configurações
final settingsActionsProvider =
    StateNotifierProvider<SettingsActionsNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(settingsServiceProvider);
  return SettingsActionsNotifier(service, ref);
});

/// Provider computado para sincronizar tema
final syncedThemeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(userSettingsStreamProvider);

  return settings.when(
    data: (userSettings) => userSettings.themeMode,
    loading: () => ThemeMode.system,
    error: (_, __) => ThemeMode.system,
  );
});

/// Provider para validar se pode deletar conta
final canDeleteAccountProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(settingsServiceProvider);
  return service.canDeleteAccount();
});

/// Provider para mensagens de erro/sucesso
final settingsMessageProvider = StateProvider<String?>((ref) => null);

/// Extension para facilitar o uso
extension SettingsProviderExtensions on WidgetRef {
  /// Atualiza configuração de notificação rapidamente
  Future<void> toggleNotification(String type, bool value) async {
    final actions = read(settingsActionsProvider.notifier);

    switch (type) {
      case 'main':
        await actions.updateNotifications(enabled: value);
        break;
      case 'sound':
        await actions.updateNotifications(sound: value);
        break;
      case 'vibration':
        await actions.updateNotifications(vibration: value);
        break;
    }
  }

  /// Atualiza configuração de privacidade rapidamente
  Future<void> togglePrivacy(String type, bool value) async {
    final actions = read(settingsActionsProvider.notifier);

    switch (type) {
      case 'analytics':
        await actions.updatePrivacy(analytics: value);
        break;
      case 'crashReports':
        await actions.updatePrivacy(crashReports: value);
        break;
    }
  }
}
