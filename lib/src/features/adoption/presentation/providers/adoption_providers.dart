import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/src/features/adoption/data/models/adoption_request_model.dart';
import 'package:petverse/src/features/adoption/data/repositories/adoption_repository.dart';
import 'package:petverse/src/features/pets/data/models/pet_model.dart'; // Corrigido: Import Pet model do local correto

// Provider que expõe o stream de solicitações de adoção pendentes
final pendingAdoptionRequestsStreamProvider =
    StreamProvider.autoDispose<List<AdoptionRequest>>((ref) {
  // Observa o adoptionRepositoryProvider
  final adoptionRepository = ref.watch(adoptionRepositoryProvider);
  // Retorna o stream de solicitações pendentes
  return adoptionRepository.getPendingAdoptionRequests();
});

// Provider que busca uma solicitação de adoção específica pelo ID
// Usamos .family para que o provider possa receber um parâmetro (o requestId)
final adoptionRequestByIdProvider = FutureProvider.autoDispose
    .family<AdoptionRequest?, String>((ref, requestId) async {
  // Observa o adoptionRepositoryProvider
  final adoptionRepository = ref.watch(adoptionRepositoryProvider);
  // Busca a solicitação pelo ID
  return adoptionRepository.getAdoptionRequestById(requestId);
});

// Provider que busca os detalhes dos pets opcionais de uma solicitação de adoção
final adoptionRequestPetOptionsProvider = FutureProvider.autoDispose
    .family<List<Pet>, List<String>>((ref, petIds) async {
  if (petIds.isEmpty) {
    return [];
  }
  final adoptionRepository = ref.watch(adoptionRepositoryProvider);
  return adoptionRepository.getPetsByIds(petIds);
});

// Provider que gerencia o ID do pet selecionado na tela de detalhes da solicitação
// O parâmetro é o ID da solicitação de adoção
final selectedPetIdProvider =
    StateProvider.autoDispose.family<String?, String>((ref, requestId) {
  return null; // Nenhum pet selecionado inicialmente
});

// Notifier para gerenciar o estado da operação de confirmação de adoção
final adoptionConfirmationNotifierProvider =
    AsyncNotifierProvider<AdoptionConfirmationNotifier, void>(() {
  return AdoptionConfirmationNotifier();
});

class AdoptionConfirmationNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Nada para carregar inicialmente
  }

  // Método para confirmar a adoção
  Future<void> confirm(String requestId, String selectedPetId) async {
    state = const AsyncLoading(); // Define o estado como carregando
    final adoptionRepository = ref.read(adoptionRepositoryProvider);
    state = await AsyncValue.guard(() => adoptionRepository.confirmAdoption(
        requestId, selectedPetId)); // Executa a operação e atualiza o estado
  }
}

// Notifier para gerenciar o estado da operação de criação de solicitação de adoção
// O estado AsyncValue<String?> conterá o friendCode em caso de sucesso, ou null.
final createAdoptionRequestNotifierProvider =
    AsyncNotifierProvider<CreateAdoptionRequestNotifier, String?>(() {
  return CreateAdoptionRequestNotifier();
});

class CreateAdoptionRequestNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    return null; // Nenhum código de amigo inicialmente
  }

  Future<void> createRequest(List<String> petOptionIds,
      {required bool isPublic}) async {
    state = const AsyncLoading();
    final adoptionRepository = ref.read(adoptionRepositoryProvider);
    state = await AsyncValue.guard(() => adoptionRepository
        .createAdoptionRequest(petOptionIds, isPublic: isPublic));
  }
}

// Notifier para gerenciar o estado da busca de uma solicitação de adoção por código de amigo
final findAdoptionByCodeNotifierProvider =
    AsyncNotifierProvider<FindAdoptionByCodeNotifier, AdoptionRequest?>(() {
  return FindAdoptionByCodeNotifier();
});

class FindAdoptionByCodeNotifier extends AsyncNotifier<AdoptionRequest?> {
  @override
  Future<AdoptionRequest?> build() async {
    return null; // Nenhuma solicitação encontrada inicialmente
  }

  Future<void> findRequest(String friendCode) async {
    state = const AsyncLoading();
    final adoptionRepository = ref.read(adoptionRepositoryProvider);
    state = await AsyncValue.guard(
        () => adoptionRepository.getAdoptionRequestByFriendCode(friendCode));
  }
}

// Notifier para gerenciar o estado da operação de rejeição de adoção
final adoptionRejectionNotifierProvider =
    AsyncNotifierProvider<AdoptionRejectionNotifier, void>(() {
  return AdoptionRejectionNotifier();
});

class AdoptionRejectionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Nada para carregar inicialmente
  }

  // Método para rejeitar a adoção
  Future<void> reject(String requestId) async {
    state = const AsyncLoading(); // Define o estado como carregando
    final adoptionRepository = ref.read(adoptionRepositoryProvider);
    state = await AsyncValue.guard(() =>
        adoptionRepository.rejectAdoptionRequest(
            requestId)); // Executa a operação e atualiza o estado
  }
}
