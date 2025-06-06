// lib/core/cache/provider_cache.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

/// Entrada do cache com TTL (Time To Live)
class CacheEntry<T> {
  final T data;
  final DateTime createdAt;
  final Duration ttl;
  final String key;

  CacheEntry({
    required this.data,
    required this.createdAt,
    required this.ttl,
    required this.key,
  });

  /// Verifica se a entrada ainda é válida
  bool get isValid {
    return DateTime.now().difference(createdAt) < ttl;
  }

  /// Tempo restante até expirar
  Duration get timeToExpire {
    final elapsed = DateTime.now().difference(createdAt);
    return ttl - elapsed;
  }

  /// Progresso de expiração (0.0 a 1.0)
  double get expirationProgress {
    final elapsed = DateTime.now().difference(createdAt);
    return (elapsed.inMilliseconds / ttl.inMilliseconds).clamp(0.0, 1.0);
  }
}

/// Configuração do cache
class CacheConfig {
  final Duration defaultTtl;
  final int maxEntries;
  final bool enableAutoCleanup;
  final Duration cleanupInterval;

  const CacheConfig({
    this.defaultTtl = const Duration(minutes: 5),
    this.maxEntries = 100,
    this.enableAutoCleanup = true,
    this.cleanupInterval = const Duration(minutes: 2),
  });

  static const CacheConfig aggressive = CacheConfig(
    defaultTtl: Duration(minutes: 1),
    maxEntries: 50,
    cleanupInterval: Duration(seconds: 30),
  );

  static const CacheConfig conservative = CacheConfig(
    defaultTtl: Duration(minutes: 15),
    maxEntries: 200,
    cleanupInterval: Duration(minutes: 5),
  );
}

/// Cache inteligente para providers com TTL e limpeza automática
class ProviderCache {
  static final Logger _logger = Logger();
  static ProviderCache? _instance;

  final CacheConfig _config;
  final Map<String, CacheEntry<dynamic>> _cache = {};
  Timer? _cleanupTimer;

  ProviderCache._(this._config) {
    if (_config.enableAutoCleanup) {
      _startAutoCleanup();
    }
  }

  /// Singleton instance
  static ProviderCache get instance {
    return _instance ??= ProviderCache._(const CacheConfig());
  }

  /// Inicializa com configuração específica
  static void initialize(CacheConfig config) {
    _instance?._cleanupTimer?.cancel();
    _instance = ProviderCache._(config);
  }

  /// Armazena dados no cache
  void set<T>(
    String key,
    T data, {
    Duration? ttl,
    bool overwrite = true,
  }) {
    final effectiveTtl = ttl ?? _config.defaultTtl;

    // Verifica se já existe e se deve sobrescrever
    if (_cache.containsKey(key) && !overwrite) {
      return;
    }

    // Remove entrada mais antiga se atingiu o limite
    if (_cache.length >= _config.maxEntries) {
      _removeOldestEntry();
    }

    final entry = CacheEntry<T>(
      data: data,
      createdAt: DateTime.now(),
      ttl: effectiveTtl,
      key: key,
    );

    _cache[key] = entry;
    _logger.d('Cache set: $key (TTL: ${effectiveTtl.inMinutes}min)');
  }

  /// Recupera dados do cache
  T? get<T>(String key) {
    final entry = _cache[key];

    if (entry == null) {
      return null;
    }

    // Verifica se ainda é válido
    if (!entry.isValid) {
      _cache.remove(key);
      _logger.d('Cache expired: $key');
      return null;
    }

    _logger.d('Cache hit: $key');
    return entry.data as T;
  }

  /// Recupera ou computa se não existir
  Future<T> getOrCompute<T>(
    String key,
    Future<T> Function() compute, {
    Duration? ttl,
  }) async {
    // Tenta recuperar do cache primeiro
    final cached = get<T>(key);
    if (cached != null) {
      return cached;
    }

    // Computa o valor
    _logger.d('Cache miss, computing: $key');
    final value = await compute();

    // Armazena no cache
    set(key, value, ttl: ttl);

    return value;
  }

  /// Computa síncrono ou usa cache
  T getOrComputeSync<T>(
    String key,
    T Function() compute, {
    Duration? ttl,
  }) {
    // Tenta recuperar do cache primeiro
    final cached = get<T>(key);
    if (cached != null) {
      return cached;
    }

    // Computa o valor
    _logger.d('Cache miss, computing sync: $key');
    final value = compute();

    // Armazena no cache
    set(key, value, ttl: ttl);

    return value;
  }

  /// Remove entrada específica
  bool remove(String key) {
    final removed = _cache.remove(key) != null;
    if (removed) {
      _logger.d('Cache removed: $key');
    }
    return removed;
  }

  /// Remove entradas por padrão
  int removeByPattern(RegExp pattern) {
    final keysToRemove = _cache.keys.where((key) => pattern.hasMatch(key));
    final count = keysToRemove.length;

    for (final key in keysToRemove) {
      _cache.remove(key);
    }

    if (count > 0) {
      _logger.d('Cache removed $count entries matching pattern');
    }

    return count;
  }

  /// Limpa cache por prefixo
  int clearByPrefix(String prefix) {
    return removeByPattern(RegExp('^$prefix'));
  }

  /// Limpa todo o cache
  void clear() {
    final count = _cache.length;
    _cache.clear();
    _logger.d('Cache cleared: $count entries removed');
  }

  /// Verifica se uma chave existe e é válida
  bool contains(String key) {
    final entry = _cache[key];
    return entry != null && entry.isValid;
  }

  /// Verifica se uma chave existe (independente da validade)
  bool hasKey(String key) {
    return _cache.containsKey(key);
  }

  /// Atualiza TTL de uma entrada existente
  bool updateTtl(String key, Duration newTtl) {
    final entry = _cache[key];
    if (entry == null) return false;

    final updatedEntry = CacheEntry(
      data: entry.data,
      createdAt: DateTime.now(), // Reset da data
      ttl: newTtl,
      key: key,
    );

    _cache[key] = updatedEntry;
    _logger.d('Cache TTL updated: $key (${newTtl.inMinutes}min)');
    return true;
  }

  /// Pré-carrega dados no cache
  Future<void> preload<T>(
    String key,
    Future<T> Function() loader, {
    Duration? ttl,
  }) async {
    if (contains(key)) {
      return; // Já existe
    }

    try {
      final data = await loader();
      set(key, data, ttl: ttl);
      _logger.d('Cache preloaded: $key');
    } catch (e) {
      _logger.w('Cache preload failed: $key - $e');
    }
  }

  /// Estatísticas do cache
  CacheStats getStats() {
    final now = DateTime.now();
    var validEntries = 0;
    var expiredEntries = 0;
    var totalSize = 0;

    for (final entry in _cache.values) {
      totalSize++;
      if (entry.isValid) {
        validEntries++;
      } else {
        expiredEntries++;
      }
    }

    return CacheStats(
      totalEntries: totalSize,
      validEntries: validEntries,
      expiredEntries: expiredEntries,
      hitRate: _hitRate,
      config: _config,
    );
  }

  /// Informações detalhadas sobre as entradas
  Map<String, Map<String, dynamic>> getDetailedStats() {
    final details = <String, Map<String, dynamic>>{};

    for (final entry in _cache.values) {
      details[entry.key] = {
        'isValid': entry.isValid,
        'createdAt': entry.createdAt.toIso8601String(),
        'ttl': entry.ttl.inMilliseconds,
        'timeToExpire': entry.timeToExpire.inMilliseconds,
        'expirationProgress': entry.expirationProgress,
        'dataType': entry.data.runtimeType.toString(),
      };
    }

    return details;
  }

  // ========================================
  // MÉTODOS PRIVADOS
  // ========================================

  /// Inicia limpeza automática
  void _startAutoCleanup() {
    _cleanupTimer = Timer.periodic(_config.cleanupInterval, (_) {
      _performCleanup();
    });
  }

  /// Executa limpeza das entradas expiradas
  void _performCleanup() {
    final keysToRemove = <String>[];

    for (final entry in _cache.values) {
      if (!entry.isValid) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      _cache.remove(key);
    }

    if (keysToRemove.isNotEmpty) {
      _logger
          .d('Cache cleanup: removed ${keysToRemove.length} expired entries');
    }
  }

  /// Remove a entrada mais antiga
  void _removeOldestEntry() {
    if (_cache.isEmpty) return;

    final oldestKey = _cache.keys.first;
    _cache.remove(oldestKey);
    _logger.d('Cache evicted oldest: $oldestKey');
  }

  /// Taxa de hit (simplificada)
  double get _hitRate {
    // Em uma implementação completa, manteria estatísticas de hit/miss
    return 0.85; // Placeholder
  }

  /// Dispose dos recursos
  void dispose() {
    _cleanupTimer?.cancel();
    clear();
  }
}

/// Estatísticas do cache
class CacheStats {
  final int totalEntries;
  final int validEntries;
  final int expiredEntries;
  final double hitRate;
  final CacheConfig config;

  const CacheStats({
    required this.totalEntries,
    required this.validEntries,
    required this.expiredEntries,
    required this.hitRate,
    required this.config,
  });

  double get validPercentage =>
      totalEntries > 0 ? (validEntries / totalEntries) * 100 : 0;

  double get expiredPercentage =>
      totalEntries > 0 ? (expiredEntries / totalEntries) * 100 : 0;

  double get utilization => (totalEntries / config.maxEntries) * 100;

  Map<String, dynamic> toJson() {
    return {
      'totalEntries': totalEntries,
      'validEntries': validEntries,
      'expiredEntries': expiredEntries,
      'hitRate': hitRate,
      'validPercentage': validPercentage,
      'expiredPercentage': expiredPercentage,
      'utilization': utilization,
      'maxEntries': config.maxEntries,
      'defaultTtl': config.defaultTtl.inMinutes,
    };
  }

  @override
  String toString() {
    return 'CacheStats(entries: $validEntries/$totalEntries, '
        'hit: ${(hitRate * 100).toStringAsFixed(1)}%, '
        'util: ${utilization.toStringAsFixed(1)}%)';
  }
}

/// Provider para o cache
final providerCacheProvider = Provider<ProviderCache>((ref) {
  return ProviderCache.instance;
});

/// Provider para estatísticas do cache
final cacheStatsProvider = Provider<CacheStats>((ref) {
  final cache = ref.watch(providerCacheProvider);
  return cache.getStats();
});

/// Enum para tipos de cache
enum CacheType {
  pets('pets'),
  users('users'),
  requests('requests'),
  currency('currency'),
  config('config');

  const CacheType(this.prefix);
  final String prefix;

  String key(String id) => '${prefix}_$id';
}

/// Extensions para facilitar o uso do cache
extension CacheExtensions on ProviderCache {
  /// Métodos específicos para pets
  Future<T> getPetData<T>(String petId, Future<T> Function() loader) {
    return getOrCompute(
      CacheType.pets.key(petId),
      loader,
      ttl: const Duration(minutes: 10),
    );
  }

  /// Métodos específicos para usuários
  Future<T> getUserData<T>(String userId, Future<T> Function() loader) {
    return getOrCompute(
      CacheType.users.key(userId),
      loader,
      ttl: const Duration(minutes: 15),
    );
  }

  /// Métodos específicos para solicitações
  Future<T> getRequestData<T>(String requestId, Future<T> Function() loader) {
    return getOrCompute(
      CacheType.requests.key(requestId),
      loader,
      ttl: const Duration(minutes: 5),
    );
  }

  /// Cache para dados de moeda
  Future<T> getCurrencyData<T>(String userId, Future<T> Function() loader) {
    return getOrCompute(
      CacheType.currency.key(userId),
      loader,
      ttl: const Duration(minutes: 2),
    );
  }

  /// Invalidação específica por tipo
  void invalidatePets() => clearByPrefix(CacheType.pets.prefix);
  void invalidateUsers() => clearByPrefix(CacheType.users.prefix);
  void invalidateRequests() => clearByPrefix(CacheType.requests.prefix);
  void invalidateCurrency() => clearByPrefix(CacheType.currency.prefix);

  /// Invalidação específica por ID
  void invalidatePet(String petId) => remove(CacheType.pets.key(petId));
  void invalidateUser(String userId) => remove(CacheType.users.key(userId));
  void invalidateRequest(String reqId) => remove(CacheType.requests.key(reqId));
  void invalidateUserCurrency(String userId) =>
      remove(CacheType.currency.key(userId));
}
