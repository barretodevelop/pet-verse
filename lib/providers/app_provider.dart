// lib/providers/app_provider.dart - BACKGROUND SERVICE INTEGRATION
// ✅ MELHORADO: Integração com Background Service
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pet_model.dart';
import '../models/user_model.dart';
import '../providers/inventory_provider.dart';
import '../providers/pet_provider.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import '../services/background_service.dart'; // ✅ NOVO
import '../services/notification_service.dart'; // ✅ ATUALIZADO

final appProvider =
    StateNotifierProvider<AppNotifier, AppState>((ref) => AppNotifier(ref));

class AppState {
  final bool isLoading;
  final String? error;
  final UserModel? user;
  final int activePetIndex;
  final bool backgroundServiceActive; // ✅ NOVO

  AppState({
    this.isLoading = false,
    this.error,
    this.user,
    this.activePetIndex = 0,
    this.backgroundServiceActive = false, // ✅ NOVO
  });

  AppState copyWith({
    bool? isLoading,
    String? error,
    UserModel? user,
    int? activePetIndex,
    bool? backgroundServiceActive, // ✅ NOVO
  }) =>
      AppState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        user: user ?? this.user,
        activePetIndex: activePetIndex ?? this.activePetIndex,
        backgroundServiceActive:
            backgroundServiceActive ?? this.backgroundServiceActive, // ✅ NOVO
      );
}

class AppNotifier extends StateNotifier<AppState> {
  final Ref _ref;
  ProviderSubscription? _petListSubscription;
  Timer? _periodicCheckTimer; // ✅ NOVO

  AppNotifier(this._ref) : super(AppState()) {
    _init();
    _listenToPetChanges();
  }

  void _init() async {
    state = state.copyWith(isLoading: true);

    try {
      // ✅ NOVO: Inicializar serviços de background
      await _initializeBackgroundServices();

      // Ouvir mudanças de autenticação
      AuthService.authStateChanges.listen((firebaseUser) async {
        if (firebaseUser != null) {
          await _loadOrCreateUserData(firebaseUser);
          await _startBackgroundServices(); // ✅ NOVO
        } else {
          await _stopBackgroundServices(); // ✅ NOVO
          state = AppState(isLoading: false);
          _ref.read(userProvider.notifier).setUser(null);
          _ref.read(inventoryProvider.notifier).updateUserContext(null);
        }
      });
    } catch (e) {
      setError('Erro na inicialização: ${e.toString()}');
    }
  }

  // ✅ NOVO: Inicializar serviços de background
  Future<void> _initializeBackgroundServices() async {
    try {
      print('🔄 AppProvider: Inicializando serviços de background...');

      // Inicializar NotificationService
      await NotificationService.initialize();

      // Inicializar BackgroundService
      await BackgroundService.initialize();

      print('✅ AppProvider: Serviços de background inicializados');
    } catch (e) {
      print('❌ AppProvider: Erro ao inicializar serviços de background: $e');
      // Não bloquear app se background services falharem
    }
  }

  // ✅ NOVO: Iniciar serviços quando usuário faz login
  Future<void> _startBackgroundServices() async {
    try {
      print('🔄 AppProvider: Iniciando monitoramento em background...');

      // Fazer verificação manual inicial
      await BackgroundService.performManualCheck();

      // Iniciar timer para verificações periódicas (backup do WorkManager)
      _periodicCheckTimer?.cancel();
      _periodicCheckTimer = Timer.periodic(
        const Duration(hours: 2), // Verificar a cada 2h como backup
        (timer) async {
          print('⏰ AppProvider: Verificação periódica de backup');
          await BackgroundService.performManualCheck();
        },
      );

      state = state.copyWith(backgroundServiceActive: true);
      print('✅ AppProvider: Monitoramento em background ativo');
    } catch (e) {
      print('❌ AppProvider: Erro ao iniciar background services: $e');
    }
  }

  // ✅ NOVO: Parar serviços quando usuário faz logout
  Future<void> _stopBackgroundServices() async {
    try {
      print('🛑 AppProvider: Parando monitoramento em background...');

      // Parar timer periódico
      _periodicCheckTimer?.cancel();
      _periodicCheckTimer = null;

      // Parar BackgroundService
      await BackgroundService.stop();

      state = state.copyWith(backgroundServiceActive: false);
      print('✅ AppProvider: Monitoramento em background parado');
    } catch (e) {
      print('❌ AppProvider: Erro ao parar background services: $e');
    }
  }

  Future<void> _loadOrCreateUserData(User firebaseUser) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      UserModel? userModel =
          await AuthService.getOrCreateUserInFirestore(firebaseUser);

      if (userModel != null) {
        state = state.copyWith(user: userModel, isLoading: false);
        _ref.read(userProvider.notifier).setUser(userModel);
        _ref.read(inventoryProvider.notifier).updateUserContext(userModel.id);

        // ✅ NOVO: Mostrar última verificação
        await _showLastCheckInfo();
      } else {
        setError('Falha ao carregar ou criar dados do usuário no Firestore.');
        _ref.read(userProvider.notifier).setUser(null);
      }
    } catch (e) {
      setError(
          'Erro durante o carregamento dos dados do usuário: ${e.toString()}');
      _ref.read(userProvider.notifier).setUser(null);
    }
  }

  // ✅ NOVO: Mostrar info da última verificação
  Future<void> _showLastCheckInfo() async {
    try {
      final lastCheck = await BackgroundService.getLastCheckTime();
      if (lastCheck != null) {
        final timeSinceCheck = DateTime.now().difference(lastCheck);
        print(
            'ℹ️ AppProvider: Última verificação: ${timeSinceCheck.inHours}h atrás');

        // Se faz muito tempo, fazer verificação manual
        if (timeSinceCheck.inHours > 6) {
          print(
              '🔄 AppProvider: Executando verificação manual (última há ${timeSinceCheck.inHours}h)');
          await BackgroundService.performManualCheck();
        }
      } else {
        print('ℹ️ AppProvider: Primeira verificação sendo executada');
        await BackgroundService.performManualCheck();
      }
    } catch (e) {
      print('❌ AppProvider: Erro ao verificar último check: $e');
    }
  }

  void _listenToPetChanges() {
    _petListSubscription =
        _ref.listen<List<PetModel>>(petProvider, (previousPets, newPets) {
      print(
          'AppNotifier: Detected pet list change. Previous count: ${previousPets?.length}, New count: ${newPets.length}');
      _validateActivePetIndex(newPets);

      // ✅ NOVO: Trigger verificação quando pets mudam
      if (state.backgroundServiceActive && previousPets != null) {
        print('🔄 AppProvider: Lista de pets mudou, executando verificação');
        _triggerDelayedCheck();
      }
    }, fireImmediately: true);
  }

  // ✅ NOVO: Trigger verificação com delay (debounce)
  void _triggerDelayedCheck() {
    Timer(const Duration(seconds: 5), () async {
      try {
        await BackgroundService.performManualCheck();
      } catch (e) {
        print('❌ AppProvider: Erro na verificação delayed: $e');
      }
    });
  }

  void _validateActivePetIndex(List<PetModel> currentPets) {
    int currentActiveIdx = state.activePetIndex;
    int newValidIndex = 0;

    if (currentPets.isNotEmpty) {
      newValidIndex = currentActiveIdx.clamp(0, currentPets.length - 1);
    }

    if (state.activePetIndex != newValidIndex) {
      state = state.copyWith(activePetIndex: newValidIndex);
      print(
          'AppProvider (validated): Active pet index set to $newValidIndex. Pet count: ${currentPets.length}');
    }
  }

  void setActivePetIndex(int desiredIndex) {
    final pets = _ref.read(petProvider);
    int newActualIndex =
        pets.isNotEmpty ? desiredIndex.clamp(0, pets.length - 1) : 0;
    if (state.activePetIndex != newActualIndex) {
      state = state.copyWith(activePetIndex: newActualIndex);
      print(
          'AppProvider (direct set): Active pet index set to $newActualIndex. Pet count: ${pets.length}');
    }
  }

  void setError(String? error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  // ✅ NOVO: Métodos públicos para controle manual

  /// Forçar verificação manual de pets
  Future<void> forceCheckPets() async {
    try {
      print('🔄 AppProvider: Verificação manual forçada pelo usuário');
      await BackgroundService.performManualCheck();
    } catch (e) {
      print('❌ AppProvider: Erro na verificação manual: $e');
      setError('Erro na verificação: ${e.toString()}');
    }
  }

  /// Verificar status do background service
  bool get isBackgroundServiceActive => state.backgroundServiceActive;

  /// Reiniciar background services
  Future<void> restartBackgroundServices() async {
    try {
      await _stopBackgroundServices();
      await Future.delayed(const Duration(seconds: 2));
      await _startBackgroundServices();
    } catch (e) {
      print('❌ AppProvider: Erro ao reiniciar background services: $e');
    }
  }

  /// Estatísticas do serviço
  Future<Map<String, dynamic>> getBackgroundServiceStats() async {
    try {
      final lastCheck = await BackgroundService.getLastCheckTime();
      return {
        'isActive': state.backgroundServiceActive,
        'isInitialized': BackgroundService.isInitialized,
        'lastCheck': lastCheck?.toIso8601String(),
        'timeSinceLastCheck': lastCheck != null
            ? DateTime.now().difference(lastCheck).inHours
            : null,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  @override
  void dispose() {
    _petListSubscription?.close();
    _periodicCheckTimer?.cancel();

    // Parar background services
    BackgroundService.stop().catchError((e) {
      print('❌ AppProvider: Erro ao parar background service no dispose: $e');
    });

    super.dispose();
  }
}
