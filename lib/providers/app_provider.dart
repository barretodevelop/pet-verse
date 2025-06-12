// lib/providers/app_provider.dart - AppProvider
import 'dart:async'; // For StreamSubscription

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pet_model.dart'; // Import PetModel for type in listener
import '../models/user_model.dart';
import '../providers/inventory_provider.dart'; // Importar InventoryProvider
import '../providers/pet_provider.dart'; // Import PetProvider
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
  ProviderSubscription? _petListSubscription; // To listen to pet changes

  AppNotifier(this._ref) : super(AppState()) {
    _init();
    _listenToPetChanges(); // Start listening to pet changes
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

  void _old_setActivePetIndex(int index) {
    // Renamed to avoid conflict, will be replaced
    final pets = _ref.read(petProvider); // Read the CURRENT list of pets
    int newActualIndex = 0; // Default to 0 if list becomes empty or for safety

    if (pets.isNotEmpty) {
      // Clamp the desired index to be within the valid range of the current pet list
      newActualIndex = index.clamp(0, pets.length - 1);
    }

    // Only update the state if the calculated new index is different from the current one,
    // or if the list is empty and the index wasn't already 0 (to ensure reset).
    if (state.activePetIndex != newActualIndex) {
      state = state.copyWith(activePetIndex: newActualIndex);
      print(
          'AppProvider: Active pet index updated to $newActualIndex. Pet count: ${pets.length}');
    } else if (pets.isEmpty && state.activePetIndex != 0) {
      // Special case: if the list became empty and the index wasn't 0, force it to 0.
      // This ensures that if the last pet is removed, activePetIndex is 0.
      state = state.copyWith(activePetIndex: 0);
      print('AppProvider: Pet list empty. Active pet index set to 0.');
    }
  }

  void _listenToPetChanges() {
    _petListSubscription = _ref.listen<List<PetModel>>(petProvider,
        (previousPets, newPets) {
      print(
          'AppNotifier: Detected pet list change. Previous count: ${previousPets?.length}, New count: ${newPets.length}');
      _validateActivePetIndex(newPets);
    },
        fireImmediately:
            true); // fireImmediately to validate on initial load too
  }

  // Validates and adjusts the activePetIndex based on the current list of pets
  void _validateActivePetIndex(List<PetModel> currentPets) {
    int currentActiveIdx = state.activePetIndex;
    int newValidIndex = 0; // Default to 0 if list is empty

    if (currentPets.isNotEmpty) {
      newValidIndex = currentActiveIdx.clamp(0, currentPets.length - 1);
    }

    if (state.activePetIndex != newValidIndex) {
      state = state.copyWith(activePetIndex: newValidIndex);
      print(
          'AppProvider (validated): Active pet index set to $newValidIndex. Pet count: ${currentPets.length}');
    }
  }

  // Public method to set active pet index, e.g., when user clicks a slot
  void setActivePetIndex(int desiredIndex) {
    final pets = _ref.read(petProvider); // Get the latest pet list
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

  @override
  void dispose() {
    _petListSubscription?.close();
    super.dispose();
  }
}
