enum AuthProviderType {
  email,
  google,
  apple,
  facebook,
  anonymous,
}

// Enum para status de autenticação
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

// Enum para os estados da aplicação
enum AppState {
  loading,
  authenticated,
  needsAdoption,
  hasPet,
  error,
}

enum AdoptionRequestStatus {
  pending,
  accepted,
  expired,
  cancelled,
}

enum ItemCategory { food, toys, care, special }

enum ItemRarity { common, rare, epic, legendary }

enum PetType { cachorro, gato, coelho, hamster, passaro, tartaruga, furao }

enum TransactionType { purchase, reward, daily, achievement, refund }

// NOVO: Enum para identificar qual moeda foi usada
enum CurrencyType { coins, gems, both, free }

// Estados possíveis da aplicação
enum AppFlow {
  loading,
  unauthenticated,
  needsAdoption,
  hasActiveRequest,
  hasPet,
  error,
}

// Estados transitórios para melhor UX
enum TransitionState {
  none,
  adoptingPet,
  creatingRequest,
  cancelingRequest,
  refreshingData,
}
