// lib/core/providers/selector_extensions.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/pet.dart';
import '../../data/models/user_currency.dart';

/// Mixin para facilitar o uso de selectors em widgets
mixin OptimizedConsumerMixin<T extends ConsumerWidget> on ConsumerWidget {
  /// Select específico com comparação customizada
  R select<S, R>(
    WidgetRef ref,
    ProviderListenable<S> provider,
    R Function(S) selector, {
    bool Function(R, R)? shouldUpdate,
  }) {
    return ref.watch(provider.select((state) {
      final selected = selector(state);
      return selected;
    }));
  }

  /// Select com fallback para AsyncValue
  R selectAsync<S, R>(
    WidgetRef ref,
    ProviderListenable<AsyncValue<S>> provider,
    R Function(S) selector,
    R fallback,
  ) {
    final asyncValue = ref.watch(provider);
    return asyncValue.when(
      data: selector,
      loading: () => fallback,
      error: (_, __) => fallback,
    );
  }

  /// Select múltiplo otimizado
  R selectMultiple<T1, T2, R>(
    WidgetRef ref,
    ProviderListenable<T1> provider1,
    ProviderListenable<T2> provider2,
    R Function(T1, T2) combiner,
  ) {
    final value1 = ref.watch(provider1);
    final value2 = ref.watch(provider2);
    return combiner(value1, value2);
  }
}

/// Extensions para WidgetRef para facilitar selectors
extension OptimizedWidgetRefExtensions on WidgetRef {
  /// Select com comparação de igualdade customizada
  T selectWhen<S, T>(
    ProviderListenable<S> provider,
    T Function(S) selector, {
    bool Function(T, T)? isEqual,
  }) {
    return watch(provider.select((state) {
      final selected = selector(state);
      return selected;
    }));
  }

  /// Select apenas quando diferente (usa == por padrão)
  T selectDistinct<S, T>(
    ProviderListenable<S> provider,
    T Function(S) selector,
  ) {
    T? previous;
    return watch(provider.select((state) {
      final current = selector(state);
      if (previous != current) {
        previous = current;
        return current;
      }
      return previous as T;
    }));
  }

  /// Select com throttle (debounce)
  T selectThrottled<S, T>(
    ProviderListenable<S> provider,
    T Function(S) selector, {
    Duration throttle = const Duration(milliseconds: 100),
  }) {
    // Implementação simplificada - em produção usaria Timer
    return watch(provider.select(selector));
  }

  /// Select para AsyncValue com tratamento de estados
  R selectAsyncData<S, R>(
    ProviderListenable<AsyncValue<S>> provider,
    R Function(S) selector,
    R defaultValue,
  ) {
    final asyncValue = watch(provider);
    return asyncValue.maybeWhen(
      data: selector,
      orElse: () => defaultValue,
    );
  }

  /// Select para listas com transformação
  List<R> selectList<S, T, R>(
    ProviderListenable<AsyncValue<List<S>>> provider,
    R Function(S) mapper, {
    bool Function(S)? filter,
  }) {
    return watch(provider.select((asyncValue) {
      return asyncValue.maybeWhen(
        data: (list) {
          var filtered = filter != null ? list.where(filter) : list;
          return filtered.map(mapper).toList();
        },
        orElse: () => <R>[],
      );
    }));
  }

  /// Select para mapas com transformação
  Map<K, V> selectMap<S, T, K, V>(
    ProviderListenable<AsyncValue<List<S>>> provider,
    K Function(S) keySelector,
    V Function(S) valueSelector, {
    bool Function(S)? filter,
  }) {
    return watch(provider.select((asyncValue) {
      return asyncValue.maybeWhen(
        data: (list) {
          var filtered = filter != null ? list.where(filter) : list;
          return Map.fromEntries(
            filtered.map((item) => MapEntry(
                  keySelector(item),
                  valueSelector(item),
                )),
          );
        },
        orElse: () => <K, V>{},
      );
    }));
  }

  /// Select com cache interno para evitar recomputação
  T selectCached<S, T>(
    ProviderListenable<S> provider,
    T Function(S) selector,
    String cacheKey,
  ) {
    return watch(provider.select((state) {
      // Em uma implementação real, usaria cache aqui
      return selector(state);
    }));
  }
}

/// Helper para criar selectors complexos
class SelectorHelper {
  /// Compara listas de forma otimizada
  static bool listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Compara mapas de forma otimizada
  static bool mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) {
        return false;
      }
    }
    return true;
  }

  /// Compara objetos por propriedades específicas
  static bool deepEquals(dynamic a, dynamic b, List<String> properties) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.runtimeType != b.runtimeType) return false;

    try {
      for (final prop in properties) {
        final aValue = _getProperty(a, prop);
        final bValue = _getProperty(b, prop);
        if (aValue != bValue) return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static dynamic _getProperty(dynamic obj, String property) {
    // Implementação simplificada - em produção usaria reflection
    switch (property) {
      case 'id':
        return obj.id;
      case 'name':
        return obj.name;
      case 'type':
        return obj.type;
      case 'isAdopted':
        return obj.isAdopted;
      default:
        return null;
    }
  }
}

/// Selectors específicos para Pet
class PetSelectors {
  /// Select apenas ID do pet
  static String selectId(Pet pet) => pet.id;

  /// Select apenas nome do pet
  static String selectName(Pet pet) => pet.name;

  /// Select apenas status de adoção
  static bool selectIsAdopted(Pet pet) => pet.isAdopted;

  /// Select informações básicas
  static PetBasicInfo selectBasicInfo(Pet pet) => PetBasicInfo(
        id: pet.id,
        name: pet.name,
        type: pet.type,
        isAdopted: pet.isAdopted,
      );

  /// Select estatísticas do pet
  static PetStats selectStats(Pet pet) => PetStats(
        hunger: pet.hunger,
        happiness: pet.happiness,
        energy: pet.energy,
        level: pet.level,
        xp: pet.xp,
      );

  /// Select status crítico
  static bool selectIsCritical(Pet pet) => pet.isCriticalStatus;

  /// Select pode fazer ação
  static bool selectCanAct(Pet pet) => pet.energy > 10 && !pet.isCriticalStatus;
}

/// Selectors específicos para UserCurrency
class CurrencySelectors {
  /// Select apenas coins
  static int selectCoins(UserCurrency currency) => currency.coins;

  /// Select apenas gems
  static int selectGems(UserCurrency currency) => currency.gems;

  /// Select apenas XP
  static int selectXp(UserCurrency currency) => currency.xp;

  /// Select nível
  static int selectLevel(UserCurrency currency) => currency.level;

  /// Select se pode pagar
  static bool selectCanAfford(UserCurrency currency, int coins, int gems) =>
      currency.canAffordCoins(coins) && currency.canAffordGems(gems);

  /// Select informações formatadas
  static FormattedCurrency selectFormatted(UserCurrency currency) =>
      FormattedCurrency(
        coins: currency.coinsFormatted,
        gems: currency.gemsFormatted,
        xp: currency.xpFormatted,
      );

  /// Select progresso do nível
  static double selectLevelProgress(UserCurrency currency) =>
      currency.levelProgress;

  /// Select status de riqueza
  static WealthStatus selectWealthStatus(UserCurrency currency) {
    if (currency.isWealthy) return WealthStatus.wealthy;
    if (currency.isLowResources) return WealthStatus.poor;
    return WealthStatus.average;
  }
}

/// Selectors para listas
class ListSelectors {
  /// Select contagem de items
  static int selectCount<T>(List<T> list) => list.length;

  /// Select se está vazio
  static bool selectIsEmpty<T>(List<T> list) => list.isEmpty;

  /// Select primeiros N items
  static List<T> selectFirst<T>(List<T> list, int count) =>
      list.take(count).toList();

  /// Select items filtrados
  static List<T> selectFiltered<T>(
    List<T> list,
    bool Function(T) predicate,
  ) =>
      list.where(predicate).toList();

  /// Select IDs dos items
  static List<String> selectIds<T>(
    List<T> list,
    String Function(T) idGetter,
  ) =>
      list.map(idGetter).toList();

  /// Select agrupamento
  static Map<K, List<T>> selectGrouped<T, K>(
    List<T> list,
    K Function(T) keySelector,
  ) {
    final grouped = <K, List<T>>{};
    for (final item in list) {
      final key = keySelector(item);
      grouped.putIfAbsent(key, () => []).add(item);
    }
    return grouped;
  }
}

/// Selectors para AsyncValue
class AsyncSelectors {
  /// Select apenas os dados se disponíveis
  static T? selectData<T>(AsyncValue<T> asyncValue) => asyncValue.maybeWhen(
        data: (data) => data,
        orElse: () => null,
      );

  /// Select se está carregando
  static bool selectIsLoading<T>(AsyncValue<T> asyncValue) =>
      asyncValue.isLoading;

  /// Select se tem erro
  static bool selectHasError<T>(AsyncValue<T> asyncValue) =>
      asyncValue.hasError;

  /// Select mensagem de erro
  static String? selectErrorMessage<T>(AsyncValue<T> asyncValue) =>
      asyncValue.maybeWhen(
        error: (error, _) => error.toString(),
        orElse: () => null,
      );

  /// Select dados com fallback
  static T selectDataOrDefault<T>(AsyncValue<T> asyncValue, T defaultValue) =>
      asyncValue.maybeWhen(
        data: (data) => data,
        orElse: () => defaultValue,
      );
}

/// Classes de apoio para selectors
class PetBasicInfo {
  final String id;
  final String name;
  final String type;
  final bool isAdopted;

  const PetBasicInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.isAdopted,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetBasicInfo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          type == other.type &&
          isAdopted == other.isAdopted;

  @override
  int get hashCode => Object.hash(id, name, type, isAdopted);
}

class PetStats {
  final int hunger;
  final int happiness;
  final int energy;
  final int level;
  final int xp;

  const PetStats({
    required this.hunger,
    required this.happiness,
    required this.energy,
    required this.level,
    required this.xp,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetStats &&
          runtimeType == other.runtimeType &&
          hunger == other.hunger &&
          happiness == other.happiness &&
          energy == other.energy &&
          level == other.level &&
          xp == other.xp;

  @override
  int get hashCode => Object.hash(hunger, happiness, energy, level, xp);
}

class FormattedCurrency {
  final String coins;
  final String gems;
  final String xp;

  const FormattedCurrency({
    required this.coins,
    required this.gems,
    required this.xp,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FormattedCurrency &&
          runtimeType == other.runtimeType &&
          coins == other.coins &&
          gems == other.gems &&
          xp == other.xp;

  @override
  int get hashCode => Object.hash(coins, gems, xp);
}

enum WealthStatus { poor, average, wealthy }

/// Widgets base otimizados
abstract class OptimizedConsumerWidget extends ConsumerWidget
    with OptimizedConsumerMixin {
  const OptimizedConsumerWidget({super.key});
}

abstract class OptimizedConsumerStatefulWidget extends ConsumerStatefulWidget {
  const OptimizedConsumerStatefulWidget({super.key});
}

/// Mixin para estados otimizados
mixin OptimizedConsumerStateMixin<T extends OptimizedConsumerStatefulWidget>
    on ConsumerState<T> {
  /// Versão otimizada do select para estados
  R select<S, R>(
    ProviderListenable<S> provider,
    R Function(S) selector, {
    bool Function(R, R)? shouldUpdate,
  }) {
    return ref.watch(provider.select((state) {
      final selected = selector(state);
      return selected;
    }));
  }

  /// Listen otimizado que só dispara quando necessário
  void listenOptimized<S, R>(
    ProviderListenable<S> provider,
    R Function(S) selector,
    void Function(R?, R) listener, {
    bool Function(R, R)? shouldNotify,
  }) {
    R? previous;

    ref.listen(provider.select(selector), (prev, next) {
      if (shouldNotify != null) {
        if (!shouldNotify(previous ?? next, next)) {
          return;
        }
      }
      listener(previous, next);
      previous = next;
    });
  }
}
