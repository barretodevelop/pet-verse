// lib/core/providers/firebase_providers.dart
import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../data/models/adoption_request_status.dart';
import '../../data/models/pet.dart';
import '../../data/models/user_currency.dart';
import '../auth/auth_middleware.dart';
import '../firebase/firebase_auth_service.dart';
import '../firebase/firebase_storage_service.dart';
import '../firebase/firestore_service.dart';

// ========================================
// PROVIDERS DE SERVIÇOS FIREBASE
// ========================================

/// Provider para FirebaseAuthService
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService.instance;
});

/// Provider para FirestoreService
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService.instance;
});

/// Provider para FirebaseStorageService
final firebaseStorageServiceProvider = Provider<FirebaseStorageService>((ref) {
  return FirebaseStorageService.instance;
});

// ========================================
// PROVIDERS DE ESTADO DE AUTENTICAÇÃO
// ========================================

/// Provider para stream de mudanças de autenticação
final firebaseAuthStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  return authService.authStateChanges;
});

/// Provider para usuário atual do Firebase
final firebaseCurrentUserProvider = Provider<User?>((ref) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  return authService.currentUser;
});

/// Provider para verificar se está logado
final isFirebaseAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(firebaseCurrentUserProvider);
  return user != null;
});

// ========================================
// PROVIDERS DE PETS
// ========================================

/// Provider para pets disponíveis
final availablePetsFirebaseProvider = FutureProvider<List<Pet>>((ref) async {
  final firestoreService = ref.watch(firestoreServiceProvider);

  try {
    final result = await firestoreService.getAvailablePets(limit: 50);

    if (result.success) {
      return result.data ?? [];
    } else {
      throw Exception(result.error ?? 'Erro ao buscar pets');
    }
  } catch (e) {
    Logger().e('Failed to load available pets: $e');
    return [];
  }
});

/// Provider para pets do usuário
final userPetsFirebaseProvider =
    FutureProvider.family<List<Pet>, String>((ref, userId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);

  try {
    final result = await firestoreService.getUserPets(userId);

    if (result.success) {
      return result.data ?? [];
    } else {
      throw Exception(result.error ?? 'Erro ao buscar pets do usuário');
    }
  } catch (e) {
    Logger().e('Failed to load user pets: $e');
    return [];
  }
});

/// StateNotifier para gerenciar pets
class PetsNotifier extends StateNotifier<AsyncValue<List<Pet>>> {
  static final Logger _logger = Logger();

  final FirestoreService _firestoreService;
  final Ref _ref;

  PetsNotifier(this._firestoreService, this._ref)
      : super(const AsyncValue.loading()) {
    loadPets();
  }

  /// Carrega pets disponíveis
  Future<void> loadPets() async {
    try {
      state = const AsyncValue.loading();

      final result = await _firestoreService.getAvailablePets();

      if (result.success) {
        state = AsyncValue.data(result.data ?? []);
      } else {
        state = AsyncValue.error(
            result.error ?? 'Erro ao carregar pets', StackTrace.current);
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to load pets', error: e, stackTrace: stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Adiciona novo pet
  Future<bool> addPet(Pet pet) async {
    try {
      final result = await _firestoreService.savePet(pet);

      if (result.success) {
        // Recarrega a lista
        await loadPets();
        return true;
      } else {
        _logger.e('Failed to add pet: ${result.error}');
        return false;
      }
    } catch (e, stackTrace) {
      _logger.e('Error adding pet', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Atualiza status do pet
  Future<bool> updatePetStatus(
    String petId, {
    int? hunger,
    int? happiness,
    int? energy,
    int? level,
    int? xp,
    bool? isAdopted,
  }) async {
    try {
      final result = await _firestoreService.updatePetStatus(
        petId,
        hunger: hunger,
        happiness: happiness,
        energy: energy,
        level: level,
        xp: xp,
        isAdopted: isAdopted,
      );

      if (result.success) {
        // Atualiza o estado local
        state.whenData((pets) {
          final updatedPets = pets.map((pet) {
            if (pet.id == petId) {
              return pet.copyWith(
                hunger: hunger,
                happiness: happiness,
                energy: energy,
                level: level,
                xp: xp,
                isAdopted: isAdopted,
              );
            }
            return pet;
          }).toList();

          state = AsyncValue.data(updatedPets);
        });

        return true;
      } else {
        _logger.e('Failed to update pet status: ${result.error}');
        return false;
      }
    } catch (e, stackTrace) {
      _logger.e('Error updating pet status', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Refresh manual
  Future<void> refresh() => loadPets();
}

/// Provider para PetsNotifier
final petsNotifierProvider =
    StateNotifierProvider<PetsNotifier, AsyncValue<List<Pet>>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return PetsNotifier(firestoreService, ref);
});

// ========================================
// PROVIDERS DE SOLICITAÇÕES DE ADOÇÃO
// ========================================

/// Provider para solicitações de adoção ativas
final activeAdoptionRequestsFirebaseProvider =
    FutureProvider<List<AdoptionRequest>>((ref) async {
  final firestoreService = ref.watch(firestoreServiceProvider);

  try {
    final result = await firestoreService.getActiveAdoptionRequests();

    if (result.success) {
      return result.data ?? [];
    } else {
      throw Exception(result.error ?? 'Erro ao buscar solicitações');
    }
  } catch (e) {
    Logger().e('Failed to load adoption requests: $e');
    return [];
  }
});

// ========================================
// PROVIDERS DE MOEDA DO USUÁRIO
// ========================================

/// Provider para moeda do usuário
final userCurrencyFirebaseProvider =
    FutureProvider.family<UserCurrency?, String>((ref, userId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);

  try {
    final result = await firestoreService.getUserCurrency(userId);

    if (result.success) {
      return result.data;
    } else {
      throw Exception(result.error ?? 'Erro ao buscar moeda do usuário');
    }
  } catch (e) {
    Logger().e('Failed to load user currency: $e');
    return null;
  }
});

/// StateNotifier para gerenciar moeda do usuário
class UserCurrencyFirebaseNotifier
    extends StateNotifier<AsyncValue<UserCurrency?>> {
  static final Logger _logger = Logger();

  final FirestoreService _firestoreService;
  final String _userId;

  UserCurrencyFirebaseNotifier(this._firestoreService, this._userId)
      : super(const AsyncValue.loading()) {
    loadCurrency();
  }

  /// Carrega moeda do usuário
  Future<void> loadCurrency() async {
    try {
      state = const AsyncValue.loading();

      final result = await _firestoreService.getUserCurrency(_userId);

      if (result.success) {
        state = AsyncValue.data(result.data);
      } else {
        state = AsyncValue.error(
            result.error ?? 'Erro ao carregar moeda', StackTrace.current);
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to load currency', error: e, stackTrace: stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Atualiza moeda
  Future<bool> updateCurrency(Map<String, dynamic> updates) async {
    try {
      final result = await _firestoreService.updateUserCurrencyTransaction(
          _userId, updates);

      if (result.success) {
        // Recarrega dados
        await loadCurrency();
        return true;
      } else {
        _logger.e('Failed to update currency: ${result.error}');
        return false;
      }
    } catch (e, stackTrace) {
      _logger.e('Error updating currency', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Adiciona coins
  Future<bool> addCoins(int amount) async {
    return updateCurrency({'coins': FieldValue.increment(amount)});
  }

  /// Adiciona gems
  Future<bool> addGems(int amount) async {
    return updateCurrency({'gems': FieldValue.increment(amount)});
  }

  /// Adiciona XP
  Future<bool> addXP(int amount) async {
    return updateCurrency({'xp': FieldValue.increment(amount)});
  }

  /// Executa transação
  Future<bool> executeTransaction({
    int coinsCost = 0,
    int gemsCost = 0,
    int coinsReward = 0,
    int gemsReward = 0,
    int xpReward = 0,
  }) async {
    final updates = <String, dynamic>{};

    if (coinsCost > 0) updates['coins'] = FieldValue.increment(-coinsCost);
    if (gemsCost > 0) updates['gems'] = FieldValue.increment(-gemsCost);
    if (coinsReward > 0) updates['coins'] = FieldValue.increment(coinsReward);
    if (gemsReward > 0) updates['gems'] = FieldValue.increment(gemsReward);
    if (xpReward > 0) updates['xp'] = FieldValue.increment(xpReward);

    return updateCurrency(updates);
  }
}

/// Provider para UserCurrencyFirebaseNotifier
final userCurrencyFirebaseNotifierProvider = StateNotifierProvider.family<
    UserCurrencyFirebaseNotifier,
    AsyncValue<UserCurrency?>,
    String>((ref, userId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return UserCurrencyFirebaseNotifier(firestoreService, userId);
});

// ========================================
// PROVIDERS DE UPLOAD
// ========================================

/// StateNotifier para gerenciar uploads
class UploadNotifier extends StateNotifier<Map<String, UploadProgress?>> {
  static final Logger _logger = Logger();

  final FirebaseStorageService _storageService;

  UploadNotifier(this._storageService) : super({});

  /// Upload de imagem de pet
  Future<UploadResult> uploadPetImage({
    required File imageFile,
    required String petId,
    String? userId,
  }) async {
    try {
      final uploadKey = 'pet_$petId';

      // Stream controller para progresso
      final progressController = StreamController<UploadProgress>();

      // Atualiza estado com progresso
      progressController.stream.listen((progress) {
        state = {...state, uploadKey: progress};
      });

      final result = await _storageService.uploadPetImage(
        imageFile: imageFile,
        petId: petId,
        userId: userId,
        // onProgress: progressController.stream,
      );

      // Remove do estado quando completado
      state = Map.from(state)..remove(uploadKey);
      progressController.close();

      return result;
    } catch (e, stackTrace) {
      _logger.e('Pet image upload failed', error: e, stackTrace: stackTrace);
      return UploadResult.failure('Erro no upload: $e');
    }
  }

  /// Upload de avatar do usuário
  Future<UploadResult> uploadUserAvatar({
    required File imageFile,
    required String userId,
  }) async {
    try {
      final uploadKey = 'avatar_$userId';

      final progressController = StreamController<UploadProgress>();

      progressController.stream.listen((progress) {
        state = {...state, uploadKey: progress};
      });

      final result = await _storageService.uploadUserAvatar(
        imageFile: imageFile,
        userId: userId,
        // onProgress: progressController.stream,
      );

      state = Map.from(state)..remove(uploadKey);
      progressController.close();

      return result;
    } catch (e, stackTrace) {
      _logger.e('Avatar upload failed', error: e, stackTrace: stackTrace);
      return UploadResult.failure('Erro no upload: $e');
    }
  }

  /// Cancela upload
  void cancelUpload(String uploadKey) {
    state = Map.from(state)..remove(uploadKey);
  }

  /// Limpa todos os uploads
  void clearUploads() {
    state = {};
  }
}

/// Provider para UploadNotifier
final uploadNotifierProvider =
    StateNotifierProvider<UploadNotifier, Map<String, UploadProgress?>>((ref) {
  final storageService = ref.watch(firebaseStorageServiceProvider);
  return UploadNotifier(storageService);
});

// ========================================
// PROVIDERS DE INTEGRAÇÃO
// ========================================

/// Provider para sincronizar auth local com Firebase
final firebaseAuthIntegrationProvider =
    Provider<FirebaseAuthIntegration>((ref) {
  final firebaseAuthService = ref.watch(firebaseAuthServiceProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);

  return FirebaseAuthIntegration(
    firebaseAuthService: firebaseAuthService,
    firestoreService: firestoreService,
  );
});

/// Classe para integração de autenticação Firebase com sistema local
class FirebaseAuthIntegration {
  static final Logger _logger = Logger();

  final FirebaseAuthService firebaseAuthService;
  final FirestoreService firestoreService;

  FirebaseAuthIntegration({
    required this.firebaseAuthService,
    required this.firestoreService,
  });

  /// Converte resultado Firebase para AuthResult
  AuthResult _convertToAuthResult(FirebaseAuthResult firebaseResult) {
    if (firebaseResult.success && firebaseResult.user != null) {
      final user = firebaseResult.user!;

      return AuthResult.success(
        token: firebaseResult.idToken ?? '',
        userData: {
          'id': user.uid,
          'email': user.email,
          'name': user.displayName,
          'avatarUrl': user.photoURL,
          'authType': firebaseResult.authType?.name ?? 'unknown',
          'createdAt': DateTime.now().toIso8601String(),
          'lastLoginAt': DateTime.now().toIso8601String(),
        },
        authType: firebaseResult.authType,
      );
    } else {
      return AuthResult.failure(
        firebaseResult.error ?? 'Erro de autenticação',
        authType: firebaseResult.authType,
      );
    }
  }

  /// Login com Google integrado
  Future<AuthResult> loginWithGoogle() async {
    try {
      final firebaseResult = await firebaseAuthService.signInWithGoogle();
      final authResult = _convertToAuthResult(firebaseResult);

      // Salva/atualiza usuário no Firestore se sucesso
      if (authResult.success && authResult.userData != null) {
        final authUser = AuthUser.fromJson(authResult.userData!);
        await firestoreService.saveUser(authUser);
      }

      return authResult;
    } catch (e, stackTrace) {
      _logger.e('Integrated Google login failed',
          error: e, stackTrace: stackTrace);
      return AuthResult.failure('Erro interno no login com Google');
    }
  }

  /// Login com Apple integrado
  Future<AuthResult> loginWithApple() async {
    try {
      final firebaseResult = await firebaseAuthService.signInWithApple();
      final authResult = _convertToAuthResult(firebaseResult);

      if (authResult.success && authResult.userData != null) {
        final authUser = AuthUser.fromJson(authResult.userData!);
        await firestoreService.saveUser(authUser);
      }

      return authResult;
    } catch (e, stackTrace) {
      _logger.e('Integrated Apple login failed',
          error: e, stackTrace: stackTrace);
      return AuthResult.failure('Erro interno no login com Apple');
    }
  }

  /// Login anônimo integrado
  Future<AuthResult> loginAnonymously() async {
    try {
      final firebaseResult = await firebaseAuthService.signInAnonymously();
      final authResult = _convertToAuthResult(firebaseResult);

      if (authResult.success && authResult.userData != null) {
        final authUser = AuthUser.fromJson(authResult.userData!);
        await firestoreService.saveUser(authUser);
      }

      return authResult;
    } catch (e, stackTrace) {
      _logger.e('Integrated anonymous login failed',
          error: e, stackTrace: stackTrace);
      return AuthResult.failure('Erro interno no login anônimo');
    }
  }

  /// Logout integrado
  Future<void> logout() async {
    try {
      await firebaseAuthService.signOut();
      _logger.i('Integrated logout completed');
    } catch (e, stackTrace) {
      _logger.e('Integrated logout failed', error: e, stackTrace: stackTrace);
    }
  }
}

// ========================================
// EXTENSIONS UTILITÁRIAS
// ========================================

extension FirebaseProviderExtensions on WidgetRef {
  /// Obtém usuário atual do Firebase
  User? get firebaseUser => read(firebaseCurrentUserProvider);

  /// Verifica se está autenticado no Firebase
  bool get isFirebaseAuthenticated => read(isFirebaseAuthenticatedProvider);

  /// Força refresh dos pets
  Future<void> refreshPets() async {
    read(petsNotifierProvider.notifier).refresh();
  }

  /// Upload rápido de imagem de pet
  Future<UploadResult> uploadPetImage(File imageFile, String petId) async {
    return read(uploadNotifierProvider.notifier).uploadPetImage(
      imageFile: imageFile,
      petId: petId,
      userId: firebaseUser?.uid,
    );
  }

  /// Atualiza moeda do usuário se autenticado
  Future<bool> updateUserCurrency(Map<String, dynamic> updates) async {
    final userId = firebaseUser?.uid;
    if (userId == null) return false;

    return read(userCurrencyFirebaseNotifierProvider(userId).notifier)
        .updateCurrency(updates);
  }
}
