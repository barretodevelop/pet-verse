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
