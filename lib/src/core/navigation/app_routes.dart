// Usar 'part of' pode ser útil se você dividir a configuração do router em múltiplos arquivos.
// Por enquanto, manteremos simples.

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String home =
      '/'; // A tela principal será a raiz após o login/onboarding
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String adoptionInitial = '/adoption/initial';
  static const String pendingAdoptions =
      '/adoption/pending'; // Nova rota para a lista de pendentes
  static const String adoptNewPet =
      '/adoption/new'; // Corrigido: Rota para adotar novo pet
  static const String enterFriendCode =
      '/adoption/code'; // Corrigido: Rota para inserir código de amigo
  static const String pendingRequestDetails =
      '/adoption/pending/:requestId'; // Nova rota para detalhes da solicitação
  static const String petDetails = '/pet-details'; // Nova rota
}
