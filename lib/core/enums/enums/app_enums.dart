// File: lib/core/enums/app_enums.dart

/// Authentication status enum
enum AuthStatus {
  authenticated,
  unauthenticated,
  loading,
  error,
}

/// App theme mode enum
enum AppTheme {
  light,
  dark,
  system,
}

/// Loading states for UI components
enum LoadingState {
  initial,
  loading,
  success,
  error,
}

/// Pet Game specific enums
enum AchievementType { petCare, gaming, collection, social, progression }

enum RewardType { coins, gems, xp, food, toy }

enum TransactionType {
  purchase,
  reward,
  achievement,
  dailyBonus,
  gameWin,
  petCare,
}

enum FoodRarity { common, uncommon, rare, epic, legendary }

enum ToyRarity { common, uncommon, rare, epic, legendary }

enum ToyType { ball, rope, puzzle, electronic, comfort, training }

/// Pet status enums

/// Pet evolution stages
enum EvolutionStage {
  baby, // Nível 1-4
  child, // Nível 5-9
  teenager, // Nível 10-19
  adult, // Nível 20-34
  elder, // Nível 35+
}

/// Pet action types for interactions
enum PetAction {
  feeding,
  playing,
  sleeping,
  idle,
}

/// Pet mood states
enum PetMood {
  happy,
  sad,
  excited,
  tired,
  hungry,
  playful,
  sleepy,
}

/// Navigation enums
enum BottomNavTab {
  dashboard,
  shop,
  pet,
  games,
  feed,
}

/// User level and progression
enum UserLevel {
  beginner,
  intermediate,
  advanced,
  expert,
  master,
}

/// Connection status
enum ConnectionStatus {
  connected,
  disconnected,
  connecting,
}

/// Notification types
enum NotificationType {
  petNeedsAttention,
  dailyReward,
  achievement,
  levelUp,
  general,
}

/// Gender enum for pets
enum PetGender {
  male,
  female,
  unknown,
}

/// Game difficulty levels
enum GameDifficulty {
  easy,
  medium,
  hard,
  expert,
}

/// Currency types
enum CurrencyType {
  coins,
  gems,
  xp,
}

/// Pet interaction results
enum InteractionResult {
  success,
  failed,
  insufficientResources,
  petTired,
  petNotFound,
}

enum ItemType {
  food,
  toy,
  medicine,
  accessory,
  special,
}

enum ItemRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
}

enum ItemCategory {
  food,
  toy,
  medicine,
  accessory,
  special,
  decoration,
}

enum ItemEffectType {
  hunger,
  happiness,
  energy,
  health,
  xp,
}

class ShopItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final CurrencyType currency;
  final ItemCategory category;
  final Map<ItemEffectType, int> effects;
  final String imageUrl;

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.category,
    required this.effects,
    required this.imageUrl,
  });
}

class InventoryItem {
  final String id;
  final String userId;
  final String shopItemId;
  final String name;
  final ItemCategory category;
  final int quantity;
  final Map<ItemEffectType, int> effects;
  final String imageUrl;

  InventoryItem({
    required this.id,
    required this.userId,
    required this.shopItemId,
    required this.name,
    required this.category,
    required this.quantity,
    required this.effects,
    required this.imageUrl,
  });

  InventoryItem copyWith({
    String? id,
    String? userId,
    String? shopItemId,
    String? name,
    ItemCategory? category,
    int? quantity,
    Map<ItemEffectType, int>? effects,
    String? imageUrl,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      shopItemId: shopItemId ?? this.shopItemId,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      effects: effects ?? this.effects,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class PurchaseResult {
  final bool success;
  final String message;
  final ShopItem? item;

  PurchaseResult({
    required this.success,
    required this.message,
    this.item,
  });
}

class UseItemResult {
  final bool success;
  final String message;
  final Map<ItemEffectType, int> effects;

  UseItemResult({
    required this.success,
    required this.message,
    required this.effects,
  });
}

// File: lib/core/enums/cart_enums.dart

/// Estados do carrinho de compras
enum CartStatus {
  /// Carrinho vazio
  empty,

  /// Carrinho com itens
  hasItems,

  /// Processando compra
  processing,

  /// Compra finalizada com sucesso
  purchaseSuccess,

  /// Erro durante a compra
  purchaseError,

  /// Carrinho sendo carregado
  loading,
}

/// Tipos de operação no carrinho
enum CartOperation {
  /// Adicionar item ao carrinho
  addItem,

  /// Remover item do carrinho
  removeItem,

  /// Atualizar quantidade de um item
  updateQuantity,

  /// Limpar carrinho completamente
  clearCart,

  /// Processar compra do carrinho
  processPurchase,

  /// Restaurar carrinho após erro
  restoreCart,
}

/// Tipos de erro relacionados ao carrinho
enum CartError {
  /// Item não encontrado no carrinho
  itemNotFound,

  /// Quantidade inválida
  invalidQuantity,

  /// Carrinho vazio
  emptyCart,

  /// Limite de itens no carrinho excedido
  cartLimitExceeded,

  /// Saldo insuficiente para a compra
  insufficientFunds,

  /// Item não está mais disponível
  itemUnavailable,

  /// Preço do item mudou
  priceChanged,

  /// Erro de rede durante operação
  networkError,

  /// Erro desconhecido
  unknown,
}

/// Tipos de validação do carrinho
enum CartValidation {
  /// Carrinho válido para compra
  valid,

  /// Saldo insuficiente
  insufficientBalance,

  /// Algum item ficou indisponível
  itemsUnavailable,

  /// Preços mudaram
  pricesChanged,

  /// Carrinho excede limites
  exceedsLimits,
  stockIssues,
}

/// Modos de exibição da loja
enum ShopDisplayMode {
  grid,

  list,

  compact,
}

/// Tipos de ordenação dos itens na loja
enum ShopSortType {
  nameAsc,

  nameDesc,

  priceAsc,
  priceDesc,

  category,

  popularity,

  newest,

  rarity,
}

/// Estados de loading específicos do carrinho
enum CartLoadingState {
  initial,

  /// Carregando itens do carrinho
  loadingCart,

  /// Adicionando item
  addingItem,

  /// Removendo item
  removingItem,

  /// Atualizando quantidade
  updatingQuantity,

  /// Processando compra
  processingPurchase,

  /// Validando carrinho
  validating,

  /// Limpando carrinho
  clearing,

  /// Sucesso
  success,

  /// Erro
  error,
}

/// Extensões para melhor usabilidade dos enums
extension CartStatusExtension on CartStatus {
  bool get isEmpty => this == CartStatus.empty;
  bool get hasItems => this == CartStatus.hasItems;
  bool get isProcessing => this == CartStatus.processing;
  bool get isSuccess => this == CartStatus.purchaseSuccess;
  bool get isError => this == CartStatus.purchaseError;
  bool get isLoading => this == CartStatus.loading;

  String get displayName {
    switch (this) {
      case CartStatus.empty:
        return 'Carrinho Vazio';
      case CartStatus.hasItems:
        return 'Itens no Carrinho';
      case CartStatus.processing:
        return 'Processando...';
      case CartStatus.purchaseSuccess:
        return 'Compra Realizada!';
      case CartStatus.purchaseError:
        return 'Erro na Compra';
      case CartStatus.loading:
        return 'Carregando...';
    }
  }
}

extension CartErrorExtension on CartError {
  String get message {
    switch (this) {
      case CartError.itemNotFound:
        return 'Item não encontrado no carrinho';
      case CartError.invalidQuantity:
        return 'Quantidade inválida';
      case CartError.emptyCart:
        return 'Carrinho está vazio';
      case CartError.cartLimitExceeded:
        return 'Limite de itens no carrinho excedido';
      case CartError.insufficientFunds:
        return 'Saldo insuficiente para esta compra';
      case CartError.itemUnavailable:
        return 'Um ou mais itens não estão mais disponíveis';
      case CartError.priceChanged:
        return 'O preço de alguns itens mudou';
      case CartError.networkError:
        return 'Erro de conexão. Tente novamente';
      case CartError.unknown:
        return 'Erro desconhecido. Tente novamente';
    }
  }

  bool get isRecoverable {
    switch (this) {
      case CartError.networkError:
      case CartError.unknown:
        return true;
      case CartError.priceChanged:
      case CartError.itemUnavailable:
        return true;
      case CartError.insufficientFunds:
      case CartError.invalidQuantity:
      case CartError.itemNotFound:
      case CartError.emptyCart:
      case CartError.cartLimitExceeded:
        return false;
    }
  }
}

extension ShopSortTypeExtension on ShopSortType {
  String get displayName {
    switch (this) {
      case ShopSortType.nameAsc:
        return 'Nome (A-Z)';
      case ShopSortType.nameDesc:
        return 'Nome (Z-A)';
      case ShopSortType.priceAsc:
        return 'Preço (Menor)';
      case ShopSortType.priceDesc:
        return 'Preço (Maior)';
      case ShopSortType.category:
        return 'Categoria';
      case ShopSortType.popularity:
        return 'Popularidade';
      case ShopSortType.newest:
        return 'Mais Recentes';
      case ShopSortType.rarity:
        return 'Raridade';
    }
  }
}
