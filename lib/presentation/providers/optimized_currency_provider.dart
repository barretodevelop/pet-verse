// lib/presentation/providers/optimized_currency_provider.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../core/cache/provider_cache.dart';
import '../../core/providers/firebase_providers.dart';
import '../../core/providers/selector_extensions.dart';
import '../../data/models/user_currency.dart';

/// Estado otimizado da moeda com operações pendentes
class OptimizedCurrencyState {
  final UserCurrency currency;
  final bool isLoading;
  final bool hasLocalChanges;
  final String? error;
  final DateTime lastUpdated;
  final Map<String, dynamic> pendingOperations;

  const OptimizedCurrencyState({
    required this.currency,
    this.isLoading = false,
    this.hasLocalChanges = false,
    this.error,
    required this.lastUpdated,
    this.pendingOperations = const {},
  });

  OptimizedCurrencyState copyWith({
    UserCurrency? currency,
    bool? isLoading,
    bool? hasLocalChanges,
    String? error,
    DateTime? lastUpdated,
    Map<String, dynamic>? pendingOperations,
  }) {
    return OptimizedCurrencyState(
      currency: currency ?? this.currency,
      isLoading: isLoading ?? this.isLoading,
      hasLocalChanges: hasLocalChanges ?? this.hasLocalChanges,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      pendingOperations: pendingOperations ?? this.pendingOperations,
    );
  }

  /// Verifica se os dados estão frescos
  bool get isDataFresh {
    const maxAge = Duration(minutes: 2);
    return DateTime.now().difference(lastUpdated) < maxAge;
  }

  /// Informações formatadas (computadas uma vez)
  FormattedCurrency get formatted => FormattedCurrency(
        coins: currency.coinsFormatted,
        gems: currency.gemsFormatted,
        xp: currency.xpFormatted,
      );

  /// Status de riqueza (computado uma vez)
  WealthStatus get wealthStatus {
    if (currency.isWealthy) return WealthStatus.wealthy;
    if (currency.isLowResources) return WealthStatus.poor;
    return WealthStatus.average;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OptimizedCurrencyState &&
          currency == other.currency &&
          isLoading == other.isLoading &&
          hasLocalChanges == other.hasLocalChanges &&
          error == other.error;

  @override
  int get hashCode => Object.hash(
        currency,
        isLoading,
        hasLocalChanges,
        error,
      );
}

/// Operação pendente de moeda
class CurrencyOperation {
  final String id;
  final CurrencyOperationType type;
  final Map<String, dynamic> params;
  final DateTime createdAt;

  CurrencyOperation({
    required this.id,
    required this.type,
    required this.params,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Aplica a operação à moeda
  UserCurrency applyTo(UserCurrency currency) {
    switch (type) {
      case CurrencyOperationType.addCoins:
        return currency.addCoins(params['amount'] as int);
      case CurrencyOperationType.removeCoins:
        return currency.removeCoins(params['amount'] as int);
      case CurrencyOperationType.addGems:
        return currency.addGems(params['amount'] as int);
      case CurrencyOperationType.removeGems:
        return currency.removeGems(params['amount'] as int);
      case CurrencyOperationType.addXP:
        return currency.addXP(params['amount'] as int);
      case CurrencyOperationType.transaction:
        return _applyTransaction(currency, params);
    }
  }

  UserCurrency _applyTransaction(
      UserCurrency currency, Map<String, dynamic> params) {
    var result = currency;

    // Remove custos
    final coinsCost = params['coinsCost'] as int? ?? 0;
    final gemsCost = params['gemsCost'] as int? ?? 0;

    if (coinsCost > 0) result = result.removeCoins(coinsCost);
    if (gemsCost > 0) result = result.removeGems(gemsCost);

    // Adiciona recompensas
    final coinsReward = params['coinsReward'] as int? ?? 0;
    final gemsReward = params['gemsReward'] as int? ?? 0;
    final xpReward = params['xpReward'] as int? ?? 0;

    if (coinsReward > 0) result = result.addCoins(coinsReward);
    if (gemsReward > 0) result = result.addGems(gemsReward);
    if (xpReward > 0) result = result.addXP(xpReward);

    return result;
  }
}

enum CurrencyOperationType {
  addCoins,
  removeCoins,
  addGems,
  removeGems,
  addXP,
  transaction,
}

/// StateNotifier otimizado para moeda com batching
class OptimizedCurrencyNotifier extends StateNotifier<OptimizedCurrencyState> {
  static final Logger _logger = Logger();

  final String _userId;
  final ProviderCache _cache;
  final Ref _ref;

  Timer? _batchTimer;
  Timer? _syncTimer;
  final List<CurrencyOperation> _pendingOperations = [];

  OptimizedCurrencyNotifier(this._userId, this._cache, this._ref)
      : super(OptimizedCurrencyState(
          currency: UserCurrency.initial(_userId),
          lastUpdated: DateTime.now(),
        )) {
    _startPeriodicSync();
    _loadInitialData();
  }

  @override
  void dispose() {
    _batchTimer?.cancel();
    _syncTimer?.cancel();
    super.dispose();
  }

  // ========================================
  // MÉTODOS PÚBLICOS OTIMIZADOS
  // ========================================

  /// Carrega dados da moeda com cache
  Future<void> loadCurrency({bool forceRefresh = false}) async {
    try {
      // Usa cache se dados são frescos
      if (!forceRefresh && state.isDataFresh) {
        _logger.d('Using cached currency data for user: $_userId');
        return;
      }

      // Tenta cache local primeiro
      final cacheKey = 'currency_$_userId';
      final cached = _cache.get<UserCurrency>(cacheKey);

      if (cached != null && !forceRefresh) {
        state = state.copyWith(
          currency: cached,
          lastUpdated: DateTime.now(),
        );
        return;
      }

      state = state.copyWith(isLoading: true, error: null);

      // Carrega do Firebase
      final currencyAsync = _ref.read(userCurrencyFirebaseProvider(_userId));

      final currency = await currencyAsync.when(
        data: (data) async => data ?? UserCurrency.initial(_userId),
        loading: () => throw Exception('Loading timeout'),
        error: (error, _) => throw error,
      );

      // Atualiza cache
      _cache.set(cacheKey, currency, ttl: const Duration(minutes: 5));

      state = state.copyWith(
        currency: currency,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );

      _logger.d('Currency loaded for user: $_userId');
    } catch (e, stackTrace) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar moeda: $e',
      );

      _logger.e('Error loading currency', error: e, stackTrace: stackTrace);
    }
  }

  /// Adiciona coins com batching
  void addCoins(int amount) {
    if (amount <= 0) return;

    _queueOperation(CurrencyOperation(
      id: _generateOperationId(),
      type: CurrencyOperationType.addCoins,
      params: {'amount': amount},
    ));
  }

  /// Remove coins com validação
  bool removeCoins(int amount) {
    if (amount <= 0 || !state.currency.canAffordCoins(amount)) {
      return false;
    }

    _queueOperation(CurrencyOperation(
      id: _generateOperationId(),
      type: CurrencyOperationType.removeCoins,
      params: {'amount': amount},
    ));

    return true;
  }

  /// Adiciona gems com batching
  void addGems(int amount) {
    if (amount <= 0) return;

    _queueOperation(CurrencyOperation(
      id: _generateOperationId(),
      type: CurrencyOperationType.addGems,
      params: {'amount': amount},
    ));
  }

  /// Remove gems com validação
  bool removeGems(int amount) {
    if (amount <= 0 || !state.currency.canAffordGems(amount)) {
      return false;
    }

    _queueOperation(CurrencyOperation(
      id: _generateOperationId(),
      type: CurrencyOperationType.removeGems,
      params: {'amount': amount},
    ));

    return true;
  }

  /// Adiciona XP com batching
  void addXP(int amount) {
    if (amount <= 0) return;

    _queueOperation(CurrencyOperation(
      id: _generateOperationId(),
      type: CurrencyOperationType.addXP,
      params: {'amount': amount},
    ));
  }

  /// Executa transação completa com batching
  bool executeTransaction({
    int coinsCost = 0,
    int gemsCost = 0,
    int coinsReward = 0,
    int gemsReward = 0,
    int xpReward = 0,
  }) {
    // Verifica se pode pagar os custos
    if (!state.currency.canAffordCoins(coinsCost) ||
        !state.currency.canAffordGems(gemsCost)) {
      return false;
    }

    _queueOperation(CurrencyOperation(
      id: _generateOperationId(),
      type: CurrencyOperationType.transaction,
      params: {
        'coinsCost': coinsCost,
        'gemsCost': gemsCost,
        'coinsReward': coinsReward,
        'gemsReward': gemsReward,
        'xpReward': xpReward,
      },
    ));

    return true;
  }

  /// Conversões otimizadas
  bool convertGemsToCoins(int gemsAmount) {
    if (gemsAmount <= 0 || !state.currency.canAffordGems(gemsAmount)) {
      return false;
    }

    const conversionRate = 10;
    return executeTransaction(
      gemsCost: gemsAmount,
      coinsReward: gemsAmount * conversionRate,
    );
  }

  bool buyGemsWithCoins(int gemsAmount) {
    if (gemsAmount <= 0) return false;

    const conversionRate = 15;
    final coinsCost = gemsAmount * conversionRate;

    return executeTransaction(
      coinsCost: coinsCost,
      gemsReward: gemsAmount,
    );
  }

  /// Recompensas otimizadas
  bool claimDailyReward() {
    final lastUpdate = state.currency.lastUpdated;
    final now = DateTime.now();
    final daysDifference = now.difference(lastUpdate).inDays;

    if (daysDifference >= 1) {
      return executeTransaction(
        coinsReward: 100,
        gemsReward: 5,
        xpReward: 50,
      );
    }
    return false;
  }

  bool claimAdReward() {
    return executeTransaction(
      coinsReward: 50,
      gemsReward: 1,
    );
  }

  /// Força sincronização imediata
  Future<void> forcSync() async {
    await _processPendingOperations();
  }

  /// Reset para estado inicial
  Future<void> reset() async {
    _pendingOperations.clear();
    _batchTimer?.cancel();

    final initialCurrency = UserCurrency.initial(_userId);
    state = state.copyWith(
      currency: initialCurrency,
      hasLocalChanges: false,
      pendingOperations: {},
    );

    // Atualiza cache
    _cache.invalidateUserCurrency(_userId);

    // Salva no Firebase
    await _saveToFirebase(initialCurrency);
  }

  // ========================================
  // MÉTODOS PRIVADOS
  // ========================================

  /// Adiciona operação à fila de batching
  void _queueOperation(CurrencyOperation operation) {
    // Aplica otimisticamente ao estado local
    final newCurrency = operation.applyTo(state.currency);

    state = state.copyWith(
      currency: newCurrency,
      hasLocalChanges: true,
      pendingOperations: {
        ...state.pendingOperations,
        operation.id: operation.params,
      },
    );

    _pendingOperations.add(operation);
    _scheduleBatchProcessing();

    _logger.d('Queued operation: ${operation.type.name} for user: $_userId');
  }

  /// Agenda processamento em batch
  void _scheduleBatchProcessing() {
    _batchTimer?.cancel();
    _batchTimer = Timer(const Duration(seconds: 2), () {
      _processPendingOperations();
    });
  }

  /// Processa operações pendentes em batch
  Future<void> _processPendingOperations() async {
    if (_pendingOperations.isEmpty) return;

    try {
      _logger.d('Processing ${_pendingOperations.length} pending operations');

      // Calcula estado final
      var finalCurrency = state.currency;

      // Consolida operações similares
      final consolidatedOps = _consolidateOperations(_pendingOperations);

      // Salva no Firebase
      await _saveToFirebase(finalCurrency);

      // Atualiza cache
      _cache.set('currency_$_userId', finalCurrency);

      // Limpa operações pendentes
      _pendingOperations.clear();

      state = state.copyWith(
        hasLocalChanges: false,
        pendingOperations: {},
        lastUpdated: DateTime.now(),
      );

      _logger.d('Currency operations synced successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to sync currency operations',
          error: e, stackTrace: stackTrace);

      state = state.copyWith(
        error: 'Erro ao sincronizar moeda: $e',
      );
    }
  }

  /// Consolida operações similares para otimizar
  List<CurrencyOperation> _consolidateOperations(
      List<CurrencyOperation> operations) {
    final consolidated = <CurrencyOperationType, int>{};

    for (final op in operations) {
      if (op.type == CurrencyOperationType.addCoins ||
          op.type == CurrencyOperationType.removeCoins ||
          op.type == CurrencyOperationType.addGems ||
          op.type == CurrencyOperationType.removeGems ||
          op.type == CurrencyOperationType.addXP) {
        final amount = op.params['amount'] as int;
        consolidated[op.type] = (consolidated[op.type] ?? 0) + amount;
      }
    }

    // Retorna operações consolidadas
    return consolidated.entries
        .map((entry) => CurrencyOperation(
              id: _generateOperationId(),
              type: entry.key,
              params: {'amount': entry.value},
            ))
        .toList();
  }

  /// Salva no Firebase
  Future<void> _saveToFirebase(UserCurrency currency) async {
    try {
      final notifier =
          _ref.read(userCurrencyFirebaseNotifierProvider(_userId).notifier);

      final updates = {
        'coins': currency.coins,
        'gems': currency.gems,
        'xp': currency.xp,
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      await notifier.updateCurrency(updates);
    } catch (e) {
      _logger.e('Failed to save currency to Firebase: $e');
      rethrow;
    }
  }

  /// Carrega dados iniciais
  void _loadInitialData() {
    Future.microtask(() => loadCurrency());
  }

  /// Inicia sincronização periódica
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (state.hasLocalChanges && _pendingOperations.isNotEmpty) {
        _processPendingOperations();
      }
    });
  }

  /// Gera ID único para operação
  String _generateOperationId() {
    return 'op_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }
}

// ========================================
// PROVIDERS OTIMIZADOS
// ========================================

/// Provider principal otimizado por usuário
final optimizedCurrencyProvider = StateNotifierProvider.family<
    OptimizedCurrencyNotifier, OptimizedCurrencyState, String>((ref, userId) {
  final cache = ref.watch(providerCacheProvider);
  return OptimizedCurrencyNotifier(userId, cache, ref);
});

/// Selectors específicos para evitar rebuilds
final coinsSelector = Provider.family<int, String>((ref, userId) {
  return ref.watch(optimizedCurrencyProvider(userId)
      .select((state) => state.currency.coins));
});

final gemsSelector = Provider.family<int, String>((ref, userId) {
  return ref.watch(
      optimizedCurrencyProvider(userId).select((state) => state.currency.gems));
});

final xpSelector = Provider.family<int, String>((ref, userId) {
  return ref.watch(
      optimizedCurrencyProvider(userId).select((state) => state.currency.xp));
});

final levelSelector = Provider.family<int, String>((ref, userId) {
  return ref.watch(optimizedCurrencyProvider(userId)
      .select((state) => state.currency.level));
});

final levelProgressSelector = Provider.family<double, String>((ref, userId) {
  return ref.watch(optimizedCurrencyProvider(userId)
      .select((state) => state.currency.levelProgress));
});

final formattedCurrencySelector =
    Provider.family<FormattedCurrency, String>((ref, userId) {
  return ref.watch(
      optimizedCurrencyProvider(userId).select((state) => state.formatted));
});

final wealthStatusSelector =
    Provider.family<WealthStatus, String>((ref, userId) {
  return ref.watch(
      optimizedCurrencyProvider(userId).select((state) => state.wealthStatus));
});

final canAffordSelector =
    Provider.family<bool, Map<String, dynamic>>((ref, params) {
  final userId = params['userId'] as String;
  final coins = params['coins'] as int? ?? 0;
  final gems = params['gems'] as int? ?? 0;

  return ref.watch(optimizedCurrencyProvider(userId).select((state) =>
      state.currency.canAffordCoins(coins) &&
      state.currency.canAffordGems(gems)));
});

final currencyLoadingSelector = Provider.family<bool, String>((ref, userId) {
  return ref.watch(
      optimizedCurrencyProvider(userId).select((state) => state.isLoading));
});

final currencyErrorSelector = Provider.family<String?, String>((ref, userId) {
  return ref
      .watch(optimizedCurrencyProvider(userId).select((state) => state.error));
});

final hasLocalChangesSelector = Provider.family<bool, String>((ref, userId) {
  return ref.watch(optimizedCurrencyProvider(userId)
      .select((state) => state.hasLocalChanges));
});

// ========================================
// EXTENSIONS PARA FACILITAR O USO
// ========================================

extension OptimizedCurrencyExtensions on WidgetRef {
  /// Obtém moeda do usuário atual
  OptimizedCurrencyState? get currentUserCurrency {
    final userId = watch(firebaseCurrentUserProvider)?.uid;
    return userId != null ? watch(optimizedCurrencyProvider(userId)) : null;
  }

  /// Selectors otimizados para usuário atual
  int get currentUserCoins {
    final userId = watch(firebaseCurrentUserProvider)?.uid;
    return userId != null ? watch(coinsSelector(userId)) : 0;
  }

  int get currentUserGems {
    final userId = watch(firebaseCurrentUserProvider)?.uid;
    return userId != null ? watch(gemsSelector(userId)) : 0;
  }

  int get currentUserXP {
    final userId = watch(firebaseCurrentUserProvider)?.uid;
    return userId != null ? watch(xpSelector(userId)) : 0;
  }

  int get currentUserLevel {
    final userId = watch(firebaseCurrentUserProvider)?.uid;
    return userId != null ? watch(levelSelector(userId)) : 1;
  }

  FormattedCurrency get currentUserFormattedCurrency {
    final userId = watch(firebaseCurrentUserProvider)?.uid;
    return userId != null
        ? watch(formattedCurrencySelector(userId))
        : const FormattedCurrency(coins: '0', gems: '0', xp: '0');
  }

  WealthStatus get currentUserWealthStatus {
    final userId = watch(firebaseCurrentUserProvider)?.uid;
    return userId != null
        ? watch(wealthStatusSelector(userId))
        : WealthStatus.poor;
  }

  /// Verifica se pode pagar custos
  bool canAfford({int coins = 0, int gems = 0}) {
    final userId = watch(firebaseCurrentUserProvider)?.uid;
    if (userId == null) return false;

    return watch(canAffordSelector({
      'userId': userId,
      'coins': coins,
      'gems': gems,
    }));
  }

  /// Ações otimizadas
  void addCoins(int amount) {
    final userId = watch(firebaseCurrentUserProvider)?.uid;
    if (userId != null) {
      read(optimizedCurrencyProvider(userId).notifier).addCoins(amount);
    }
  }

  bool spendCoins(int amount) {
    final userId = watch(firebaseCurrentUserProvider)?.uid;
    if (userId != null) {
      return read(optimizedCurrencyProvider(userId).notifier)
          .removeCoins(amount);
    }
    return false;
  }

  void addGems(int amount) {
    final userId = watch(firebaseCurrentUserProvider)?.uid;
    if (userId != null) {
      read(optimizedCurrencyProvider(userId).notifier).addGems(amount);
    }
  }

  bool spendGems(int amount) {
    final userId = watch(firebaseCurrentUserProvider)?.uid;
    if (userId != null) {
      return read(optimizedCurrencyProvider(userId).notifier)
          .removeGems(amount);
    }
    return false;
  }

  void addXP(int amount) {
    final userId = watch(firebaseCurrentUserProvider)?.uid;
    if (userId != null) {
      read(optimizedCurrencyProvider(userId).notifier).addXP(amount);
    }
  }

  /// Transações otimizadas
  bool executeTransaction({
    int coinsCost = 0,
    int gemsCost = 0,
    int coinsReward = 0,
    int gemsReward = 0,
    int xpReward = 0,
  }) {
    final userId = watch(firebaseCurrentUserProvider)?.uid;
    if (userId != null) {
      return read(optimizedCurrencyProvider(userId).notifier)
          .executeTransaction(
        coinsCost: coinsCost,
        gemsCost: gemsCost,
        coinsReward: coinsReward,
        gemsReward: gemsReward,
        xpReward: xpReward,
      );
    }
    return false;
  }

  /// Conversões
  bool convertGemsToCoins(int gems) {
    final userId = watch(firebaseCurrentUserProvider)?.uid;
    if (userId != null) {
      return read(optimizedCurrencyProvider(userId).notifier)
          .convertGemsToCoins(gems);
    }
    return false;
  }

  bool buyGemsWithCoins(int gems) {
    final userId = watch(firebaseCurrentUserProvider)?.uid;
    if (userId != null) {
      return read(optimizedCurrencyProvider(userId).notifier)
          .buyGemsWithCoins(gems);
    }
    return false;
  }

  /// Recompensas
  bool claimDailyReward() {
    final userId = watch(firebaseCurrentUserProvider)?.uid;
    if (userId != null) {
      return read(optimizedCurrencyProvider(userId).notifier)
          .claimDailyReward();
    }
    return false;
  }

  bool claimAdReward() {
    final userId = watch(firebaseCurrentUserProvider)?.uid;
    if (userId != null) {
      return read(optimizedCurrencyProvider(userId).notifier).claimAdReward();
    }
    return false;
  }

  /// Força sincronização
  Future<void> syncCurrency() async {
    final userId = watch(firebaseCurrentUserProvider)?.uid;
    if (userId != null) {
      await read(optimizedCurrencyProvider(userId).notifier).forcSync();
    }
  }
}
