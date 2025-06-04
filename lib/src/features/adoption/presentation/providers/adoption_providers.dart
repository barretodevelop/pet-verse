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
