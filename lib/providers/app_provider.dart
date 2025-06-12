// lib/providers/app_provider.dart - AppProvider
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../providers/inventory_provider.dart'; // Importar InventoryProvider
import '../providers/user_provider.dart'; // Importar o userProvider real
import '../services/auth_service.dart';

final appProvider =
    StateNotifierProvider<AppNotifier, AppState>((ref) => AppNotifier(ref));

class AppState {
  final bool isLoading;
  final String? error;
  final UserModel? user;
  final int activePetIndex;

  AppState(
      {this.isLoading = false, this.error, this.user, this.activePetIndex = 0});

  AppState copyWith(
          {bool? isLoading,
          String? error,
          UserModel? user, // Permitir definir user como null explicitamente
          int? activePetIndex}) =>
      AppState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        user: user ?? this.user,
        activePetIndex: activePetIndex ?? this.activePetIndex,
      );
}

class AppNotifier extends StateNotifier<AppState> {
  final Ref _ref;

  AppNotifier(this._ref) : super(AppState()) {
    _init();
  }

  void _init() async {
    state = state.copyWith(isLoading: true);

    // Ouça as mudanças de estado de autenticação do Firebase
    AuthService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        // Usuário logado
        await _loadOrCreateUserData(firebaseUser);
      } else {
        // Usuário deslogado
        state = AppState(isLoading: false); // Reseta o AppState
        _ref.read(userProvider.notifier).setUser(null); // Reseta o UserProvider
        // Informa ao InventoryNotifier que o usuário mudou (logout)
        _ref.read(inventoryProvider.notifier).updateUserContext(null);
      }
    });
  }

  Future<void> _loadOrCreateUserData(User firebaseUser) async {
    // Set loading state and clear previous user data from AppState (userProvider is handled separately)
    // Note: copyWith for user: `user: user ?? this.user` means passing null won't clear it here.
    // However, on logout, AppState is fully reset, so this.user would be null initially.
    // For clarity during load, we can ensure AppState's user is null if we are about to load a new one.
    // A simple way is to ensure the user field in AppState is nullable and can be set to null.
    // The current AppState constructor defaults user to null, and logout re-instantiates AppState.
    // So, state.user should be null here if coming from a logged-out state.
    state = state.copyWith(
        isLoading: true,
        error:
            null /*, user: null */); // user: null is optional here if logout correctly resets AppState

    try {
      // Use the new AuthService method to get/create user data from Firestore
      UserModel? userModel =
          await AuthService.getOrCreateUserInFirestore(firebaseUser);

      if (userModel != null) {
        state = state.copyWith(user: userModel, isLoading: false);
        _ref.read(userProvider.notifier).setUser(userModel);
        // Informa ao InventoryNotifier que o usuário mudou (login)
        _ref.read(inventoryProvider.notifier).updateUserContext(userModel.id);
      } else {
        setError('Falha ao carregar ou criar dados do usuário no Firestore.');
        _ref
            .read(userProvider.notifier)
            .setUser(null); // Ensure userProvider is also null
      }
    } catch (e) {
      setError(
          'Erro durante o carregamento dos dados do usuário: ${e.toString()}');
      _ref
          .read(userProvider.notifier)
          .setUser(null); // Ensure userProvider is also null
    }
  }

  void setActivePetIndex(int index) {
    state = state.copyWith(activePetIndex: index);
  }

  void setError(String? error) {
    state = state.copyWith(error: error, isLoading: false);
  }
}
