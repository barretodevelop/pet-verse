// lib/presentation/providers/optimized_pet_provider.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../core/cache/provider_cache.dart';
import '../../core/firebase/firebase_analytics_service.dart';
import '../../core/firebase/firestore_service.dart';
import '../../core/providers/firebase_providers.dart';
import '../../core/providers/selector_extensions.dart';
import '../../data/models/pet.dart';

/// Estado otimizado dos pets com cache inteligente
class OptimizedPetsState {
  final List<Pet> pets;
  final DateTime lastUpdated;
  final bool isLoading;
  final String? error;
  final Map<String, DateTime> petLastModified;

  const OptimizedPetsState({
    this.pets = const [],
    required this.lastUpdated,
    this.isLoading = false,
    this.error,
    this.petLastModified = const {},
  });

  OptimizedPetsState copyWith({
    List<Pet>? pets,
    DateTime? lastUpdated,
    bool? isLoading,
    String? error,
    Map<String, DateTime>? petLastModified,
  }) {
    return OptimizedPetsState(
      pets: pets ?? this.pets,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      petLastModified: petLastModified ?? this.petLastModified,
    );
  }

  /// Verifica se os dados estão atualizados
  bool get isDataFresh {
    const maxAge = Duration(minutes: 5);
    return DateTime.now().difference(lastUpdated) < maxAge;
  }

  /// Obtém pets não adotados (computado uma vez)
  List<Pet> get availablePets => pets.where((pet) => !pet.isAdopted).toList();

  /// Contagem por tipo (computado uma vez)
  Map<String, int> get petCountByType {
    final counts = <String, int>{};
    for (final pet in pets) {
      counts[pet.type] = (counts[pet.type] ?? 0) + 1;
    }
    return counts;
  }

  /// Pets críticos que precisam de atenção
  List<Pet> get criticalPets =>
      pets.where((pet) => pet.isCriticalStatus).toList();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OptimizedPetsState &&
          SelectorHelper.listEquals(pets, other.pets) &&
          lastUpdated == other.lastUpdated &&
          isLoading == other.isLoading &&
          error == other.error;

  @override
  int get hashCode => Object.hash(
        pets.length,
        lastUpdated,
        isLoading,
        error,
      );
}

/// StateNotifier otimizado para pets com cache inteligente
class OptimizedPetsNotifier extends StateNotifier<OptimizedPetsState> {
  static final Logger _logger = Logger();

  final FirestoreService _firestoreService;
  final FirebaseAnalyticsService _analyticsService;
  final ProviderCache _cache;
  final Ref _ref;

  Timer? _refreshTimer;
  StreamSubscription? _petsSubscription;

  OptimizedPetsNotifier(
    this._firestoreService,
    this._analyticsService,
    this._cache,
    this._ref,
  ) : super(OptimizedPetsState(lastUpdated: DateTime.now())) {
    _startAutoRefresh();
    _loadInitialData();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _petsSubscription?.cancel();
    super.dispose();
  }

  // ========================================
  // MÉTODOS PÚBLICOS OTIMIZADOS
  // ========================================

  /// Carrega pets com cache inteligente
  Future<void> loadPets({bool forceRefresh = false}) async {
    try {
      // Verifica cache primeiro se não for refresh forçado
      if (!forceRefresh && state.isDataFresh) {
        _logger.d('Using cached pets data');
        return;
      }

      state = state.copyWith(isLoading: true, error: null);

      // Tenta carregar do cache local
      final cachedPets = _cache.get<List<Pet>>('all_pets');
      if (cachedPets != null && !forceRefresh) {
        state = state.copyWith(
          pets: cachedPets,
          isLoading: false,
          lastUpdated: DateTime.now(),
        );
        return;
      }

      // Carrega do Firestore
      final result = await _firestoreService.getAvailablePets(limit: 100);

      if (result.success) {
        final pets = result.data ?? [];

        // Atualiza cache
        _cache.set(
          'all_pets',
          pets,
          ttl: const Duration(minutes: 10),
        );

        // Atualiza estado
        state = state.copyWith(
          pets: pets,
          isLoading: false,
          lastUpdated: DateTime.now(),
          petLastModified: _buildLastModifiedMap(pets),
        );

        // Log analytics
        await _analyticsService.logEvent(
          AnalyticsEvent.userLogin, // placeholder
          parameters: {
            'action': 'pets_loaded',
            'count': pets.length,
            'from_cache': cachedPets != null,
          },
        );

        _logger.d('Pets loaded successfully: ${pets.length}');
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.error,
        );
        _logger.e('Failed to load pets: ${result.error}');
      }
    } catch (e, stackTrace) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar pets: $e',
      );

      await _analyticsService.logError(
        error: e,
        stackTrace: stackTrace,
        reason: 'Failed to load pets',
      );

      _logger.e('Error loading pets', error: e, stackTrace: stackTrace);
    }
  }

  /// Adiciona pet com otimização de cache
  Future<bool> addPet(Pet pet) async {
    try {
      final result = await _firestoreService.savePet(pet);

      if (result.success) {
        // Atualização otimista do estado
        final updatedPets = [...state.pets, pet];
        state = state.copyWith(
          pets: updatedPets,
          lastUpdated: DateTime.now(),
          petLastModified: {
            ...state.petLastModified,
            pet.id: DateTime.now(),
          },
        );

        // Invalida cache relacionado
        _cache.invalidatePets();
        _cache.set('all_pets', updatedPets);

        // Log analytics
        await _analyticsService.logPetGenerated(
          petId: result.data ?? pet.id,
          petType: pet.type,
          userId: pet.generatedByUserId,
          isUnique: pet.generatedByUserId != null,
        );

        _logger.d('Pet added successfully: ${pet.id}');
        return true;
      }

      _logger.e('Failed to add pet: ${result.error}');
      return false;
    } catch (e, stackTrace) {
      await _analyticsService.logError(
        error: e,
        stackTrace: stackTrace,
        reason: 'Failed to add pet',
      );
      _logger.e('Error adding pet', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Atualiza stats do pet com batching
  Future<bool> updatePetStats(
    String petId, {
    int? hunger,
    int? happiness,
    int? energy,
    int? level,
    int? xp,
  }) async {
    try {
      // Atualização otimista local
      final updatedPets = state.pets.map((pet) {
        if (pet.id == petId) {
          return pet.copyWith(
            hunger: hunger,
            happiness: happiness,
            energy: energy,
            level: level,
            xp: xp,
          );
        }
        return pet;
      }).toList();

      state = state.copyWith(
        pets: updatedPets,
        petLastModified: {
          ...state.petLastModified,
          petId: DateTime.now(),
        },
      );

      // Atualiza cache
      _cache.set('all_pets', updatedPets);
      _cache.invalidatePet(petId);

      // Atualização no Firestore (pode ser batched)
      final result = await _firestoreService.updatePetStatus(
        petId,
        hunger: hunger,
        happiness: happiness,
        energy: energy,
        level: level,
        xp: xp,
      );

      if (!result.success) {
        // Reverte se falhou no Firestore
        await loadPets(forceRefresh: true);
        _logger.e('Failed to update pet stats in Firestore: ${result.error}');
        return false;
      }

      _logger.d('Pet stats updated: $petId');
      return true;
    } catch (e, stackTrace) {
      // Reverte em caso de erro
      await loadPets(forceRefresh: true);

      await _analyticsService.logError(
        error: e,
        stackTrace: stackTrace,
        reason: 'Failed to update pet stats',
      );

      _logger.e('Error updating pet stats', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Marca pet como adotado com cache update
  Future<bool> markPetAsAdopted(String petId, {String? adopterId}) async {
    try {
      // Atualização otimista
      final updatedPets = state.pets.map((pet) {
        return pet.id == petId ? pet.copyWith(isAdopted: true) : pet;
      }).toList();

      state = state.copyWith(
        pets: updatedPets,
        petLastModified: {
          ...state.petLastModified,
          petId: DateTime.now(),
        },
      );

      // Atualiza cache
      _cache.set('all_pets', updatedPets);
      _cache.invalidatePet(petId);

      // Atualiza no Firestore
      final result = await _firestoreService.updatePetStatus(
        petId,
        isAdopted: true,
      );

      if (result.success) {
        // Log analytics
        final pet = getPetById(petId);
        if (pet != null) {
          await _analyticsService.logPetAdopted(
            petId: petId,
            petType: pet.type,
            adoptionType: 'individual',
            userId: adopterId,
          );
        }

        _logger.d('Pet marked as adopted: $petId');
        return true;
      } else {
        // Reverte se falhou
        await loadPets(forceRefresh: true);
        _logger.e('Failed to mark pet as adopted: ${result.error}');
        return false;
      }
    } catch (e, stackTrace) {
      // Reverte em caso de erro
      await loadPets(forceRefresh: true);

      await _analyticsService.logError(
        error: e,
        stackTrace: stackTrace,
        reason: 'Failed to mark pet as adopted',
      );

      _logger.e('Error marking pet as adopted',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Ações combinadas no pet (feed, play, etc)
  Future<bool> performPetAction(
    String petId,
    PetAction action, {
    String? userId,
  }) async {
    final pet = getPetById(petId);
    if (pet == null) return false;

    final effects = _getActionEffects(action);

    return await updatePetStats(
      petId,
      hunger: (pet.hunger + effects.hungerChange).clamp(0, 100),
      happiness: (pet.happiness + effects.happinessChange).clamp(0, 100),
      energy: (pet.energy + effects.energyChange).clamp(0, 100),
      xp: pet.xp + effects.xpChange,
    );
  }

  /// Busca pet por ID (otimizada)
  Pet? getPetById(String petId) {
    return state.pets.firstWhere(
      (pet) => pet.id == petId,
      orElse: () =>
          Pet(id: '', name: '', imageUrl: '', type: '', description: ''),
    );
  }

  /// Força refresh dos dados
  Future<void> refresh() => loadPets(forceRefresh: true);

  // ========================================
  // MÉTODOS PRIVADOS
  // ========================================

  /// Carrega dados iniciais
  void _loadInitialData() {
    // Carrega imediatamente sem aguardar
    Future.microtask(() => loadPets());
  }

  /// Inicia auto-refresh periódico
  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (!state.isDataFresh) {
        loadPets();
      }
    });
  }

  /// Constrói mapa de última modificação
  Map<String, DateTime> _buildLastModifiedMap(List<Pet> pets) {
    final now = DateTime.now();
    return Map.fromEntries(
      pets.map((pet) => MapEntry(pet.id, now)),
    );
  }

  /// Obtém efeitos da ação
  PetActionEffects _getActionEffects(PetAction action) {
    switch (action) {
      case PetAction.feed:
        return const PetActionEffects(
          hungerChange: 20,
          happinessChange: 5,
          energyChange: 0,
          xpChange: 0,
        );
      case PetAction.play:
        return const PetActionEffects(
          hungerChange: -10,
          happinessChange: 25,
          energyChange: -15,
          xpChange: 10,
        );
      case PetAction.rest:
        return const PetActionEffects(
          hungerChange: -5,
          happinessChange: 5,
          energyChange: 30,
          xpChange: 5,
        );
    }
  }
}

/// Enum para ações do pet
enum PetAction { feed, play, rest }

/// Efeitos das ações
class PetActionEffects {
  final int hungerChange;
  final int happinessChange;
  final int energyChange;
  final int xpChange;

  const PetActionEffects({
    required this.hungerChange,
    required this.happinessChange,
    required this.energyChange,
    required this.xpChange,
  });
}

// ========================================
// PROVIDERS OTIMIZADOS
// ========================================

/// Provider principal otimizado
final optimizedPetsProvider =
    StateNotifierProvider<OptimizedPetsNotifier, OptimizedPetsState>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final analyticsService = FirebaseAnalyticsService.instance;
  final cache = ref.watch(providerCacheProvider);

  return OptimizedPetsNotifier(
    firestoreService,
    analyticsService,
    cache,
    ref,
  );
});

/// Selectors otimizados para evitar rebuilds
final availablePetsSelector = Provider<List<Pet>>((ref) {
  return ref
      .watch(optimizedPetsProvider.select((state) => state.availablePets));
});

final petCountByTypeSelector = Provider<Map<String, int>>((ref) {
  return ref
      .watch(optimizedPetsProvider.select((state) => state.petCountByType));
});

final criticalPetsSelector = Provider<List<Pet>>((ref) {
  return ref.watch(optimizedPetsProvider.select((state) => state.criticalPets));
});

final petsLoadingStateSelector = Provider<bool>((ref) {
  return ref.watch(optimizedPetsProvider.select((state) => state.isLoading));
});

final petsErrorSelector = Provider<String?>((ref) {
  return ref.watch(optimizedPetsProvider.select((state) => state.error));
});

final petsCountSelector = Provider<int>((ref) {
  return ref.watch(optimizedPetsProvider.select((state) => state.pets.length));
});

final petsLastUpdatedSelector = Provider<DateTime>((ref) {
  return ref.watch(optimizedPetsProvider.select((state) => state.lastUpdated));
});

/// Provider para pet específico por ID
final petByIdProvider = Provider.family<Pet?, String>((ref, petId) {
  final pets = ref.watch(optimizedPetsProvider.select((state) => state.pets));

  try {
    return pets.firstWhere((pet) => pet.id == petId);
  } catch (e) {
    return null;
  }
});

/// Provider para pets por tipo
final petsByTypeProvider = Provider.family<List<Pet>, String>((ref, type) {
  return ref.watch(optimizedPetsProvider
      .select((state) => state.pets.where((pet) => pet.type == type).toList()));
});

/// Provider para verificar se um pet existe
final petExistsProvider = Provider.family<bool, String>((ref, petId) {
  return ref.watch(optimizedPetsProvider
      .select((state) => state.pets.any((pet) => pet.id == petId)));
});

/// Provider para stats específicas de um pet
final petStatsProvider = Provider.family<PetStats?, String>((ref, petId) {
  final pet = ref.watch(petByIdProvider(petId));
  return pet != null ? PetSelectors.selectStats(pet) : null;
});

/// Provider para informações básicas de um pet
final petBasicInfoProvider =
    Provider.family<PetBasicInfo?, String>((ref, petId) {
  final pet = ref.watch(petByIdProvider(petId));
  return pet != null ? PetSelectors.selectBasicInfo(pet) : null;
});

// ========================================
// EXTENSIONS PARA FACILITAR O USO
// ========================================

extension OptimizedPetProviderExtensions on WidgetRef {
  /// Obtém pets disponíveis otimizado
  List<Pet> get availablePets => watch(availablePetsSelector);

  /// Obtém contagem por tipo otimizada
  Map<String, int> get petCountByType => watch(petCountByTypeSelector);

  /// Obtém pets críticos otimizado
  List<Pet> get criticalPets => watch(criticalPetsSelector);

  /// Verifica se está carregando pets
  bool get isPetsLoading => watch(petsLoadingStateSelector);

  /// Obtém erro de pets se houver
  String? get petsError => watch(petsErrorSelector);

  /// Obtém contagem total otimizada
  int get petsCount => watch(petsCountSelector);

  /// Obtém pet por ID otimizado
  Pet? getPetById(String petId) => watch(petByIdProvider(petId));

  /// Obtém pets por tipo otimizado
  List<Pet> getPetsByType(String type) => watch(petsByTypeProvider(type));

  /// Verifica se pet existe otimizado
  bool petExists(String petId) => watch(petExistsProvider(petId));

  /// Obtém stats de pet otimizado
  PetStats? getPetStats(String petId) => watch(petStatsProvider(petId));

  /// Obtém informações básicas otimizado
  PetBasicInfo? getPetBasicInfo(String petId) =>
      watch(petBasicInfoProvider(petId));

  /// Ações otimizadas
  Future<bool> feedPet(String petId) async {
    final userId = watch(firebaseCurrentUserProvider)?.uid;
    return read(optimizedPetsProvider.notifier).performPetAction(
      petId,
      PetAction.feed,
      userId: userId,
    );
  }

  Future<bool> playWithPet(String petId) async {
    final userId = watch(firebaseCurrentUserProvider)?.uid;
    return read(optimizedPetsProvider.notifier).performPetAction(
      petId,
      PetAction.play,
      userId: userId,
    );
  }

  Future<bool> letPetRest(String petId) async {
    final userId = watch(firebaseCurrentUserProvider)?.uid;
    return read(optimizedPetsProvider.notifier).performPetAction(
      petId,
      PetAction.rest,
      userId: userId,
    );
  }

  /// Refresh otimizado
  Future<void> refreshPets() async {
    read(optimizedPetsProvider.notifier).refresh();
  }

  /// Adiciona pet otimizado
  Future<bool> addPet(Pet pet) async {
    return read(optimizedPetsProvider.notifier).addPet(pet);
  }

  /// Marca como adotado otimizado
  Future<bool> adoptPet(String petId) async {
    final userId = watch(firebaseCurrentUserProvider)?.uid;
    return read(optimizedPetsProvider.notifier).markPetAsAdopted(
      petId,
      adopterId: userId,
    );
  }
}
