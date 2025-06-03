// // lib/feature/adoption/providers/create_adoption_provider.dart

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:petverse/core/model/firebase_pet_model.dart';
// import 'package:petverse/core/providers/anonymous_generator_provider.dart';
// import 'package:petverse/core/services/firebase_adoption_service.dart';
// import 'package:petverse/feature/auth/providers/authentication_provider.dart';

// // Provider para o estado de criação de adoção
// final createAdoptionProvider =
//     StateNotifierProvider<CreateAdoptionNotifier, CreateAdoptionState>((ref) {
//   final authState = ref.watch(authenticationNotifierProvider);
//   final anonymousGenerator = ref.read(anonymousUserGeneratorProvider);

//   return CreateAdoptionNotifier(
//     user: authState.userModel,
//     anonymousGenerator: anonymousGenerator,
//   );
// });

// // Estado da criação de adoção
// class CreateAdoptionState {
//   final bool isLoading;
//   final bool isCreating;
//   final List<FirebasePetModel> availablePets;
//   final List<String> selectedPetIds;
//   final String? error;
//   final String? successRequestId;

//   const CreateAdoptionState({
//     this.isLoading = true,
//     this.isCreating = false,
//     this.availablePets = const [],
//     this.selectedPetIds = const [],
//     this.error,
//     this.successRequestId,
//   });

//   CreateAdoptionState copyWith({
//     bool? isLoading,
//     bool? isCreating,
//     List<FirebasePetModel>? availablePets,
//     List<String>? selectedPetIds,
//     String? error,
//     String? successRequestId,
//   }) {
//     return CreateAdoptionState(
//       isLoading: isLoading ?? this.isLoading,
//       isCreating: isCreating ?? this.isCreating,
//       availablePets: availablePets ?? this.availablePets,
//       selectedPetIds: selectedPetIds ?? this.selectedPetIds,
//       error: error,
//       successRequestId: successRequestId,
//     );
//   }

//   // Getters de conveniência
//   bool get canCreate => selectedPetIds.length == 3 && !isCreating;
//   bool get hasSelection => selectedPetIds.isNotEmpty;
//   int get remainingSelections => 3 - selectedPetIds.length;

//   List<FirebasePetModel> get selectedPets {
//     return availablePets
//         .where((pet) => selectedPetIds.contains(pet.id))
//         .toList();
//   }
// }

// // Notifier para criação de adoção
// class CreateAdoptionNotifier extends StateNotifier<CreateAdoptionState> {
//   final dynamic user; // UserModel
//   final AnonymousUserGenerator anonymousGenerator;

//   CreateAdoptionNotifier({
//     required this.user,
//     required this.anonymousGenerator,
//   }) : super(const CreateAdoptionState()) {
//     _loadAvailablePets();
//   }

//   // Carregar pets disponíveis do Firebase
//   Future<void> _loadAvailablePets() async {
//     try {
//       state = state.copyWith(isLoading: true, error: null);

//       final pets =
//           await FirebaseAdoptionService.getAvailablePetsForCollaboration();

//       state = state.copyWith(
//         isLoading: false,
//         availablePets: pets,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: 'Erro ao carregar pets: $e',
//       );
//     }
//   }

//   // Selecionar/desselecionar pet
//   void togglePetSelection(String petId) {
//     final currentSelection = List<String>.from(state.selectedPetIds);

//     if (currentSelection.contains(petId)) {
//       currentSelection.remove(petId);
//     } else if (currentSelection.length < 3) {
//       currentSelection.add(petId);
//     } else {
//       // Já tem 3 selecionados, não adiciona mais
//       return;
//     }

//     state = state.copyWith(selectedPetIds: currentSelection);
//   }

//   // Limpar seleção
//   void clearSelection() {
//     state = state.copyWith(selectedPetIds: []);
//   }

//   // Verificar se pet está selecionado
//   bool isPetSelected(String petId) {
//     return state.selectedPetIds.contains(petId);
//   }

//   // Criar pedido de adoção colaborativa
//   Future<String?> createAdoptionRequest() async {
//     if (!state.canCreate || user == null) {
//       state =
//           state.copyWith(error: 'Seleção inválida ou usuário não autenticado');
//       return null;
//     }

//     try {
//       state = state.copyWith(isCreating: true, error: null);

//       // Gerar dados anônimos para o usuário
//       final anonymousData = anonymousGenerator.generateAnonymousData(user);

//       // Criar pedido no Firebase
//       final requestId =
//           await FirebaseAdoptionService.createCollaborativeAdoptionRequest(
//         requesterId: user.id,
//         requesterDisplayName: user.displayName ?? 'Usuário',
//         requesterCodename: anonymousData.codename,
//         requesterColorTheme: anonymousData.colorTheme,
//         requesterLevel: user.level,
//         selectedPetIds: state.selectedPetIds,
//         codedMessage: anonymousData.codedMessage,
//         personalityTags: anonymousData.personalityTags,
//         region: anonymousData.region,
//       );

//       state = state.copyWith(
//         isCreating: false,
//         successRequestId: requestId,
//       );

//       return requestId;
//     } catch (e) {
//       state = state.copyWith(
//         isCreating: false,
//         error: 'Erro ao criar adoção: $e',
//       );
//       return null;
//     }
//   }

//   // Refresh da lista de pets
//   Future<void> refreshPets() async {
//     await _loadAvailablePets();
//   }

//   // Reset do estado após sucesso
//   void resetAfterSuccess() {
//     state = const CreateAdoptionState();
//     _loadAvailablePets();
//   }

//   // Compartilhar link da adoção
//   Future<String?> generateShareLink(String requestId) async {
//     try {
//       return await FirebaseAdoptionService.generateShareLink(requestId);
//     } catch (e) {
//       state = state.copyWith(error: 'Erro ao gerar link: $e');
//       return null;
//     }
//   }
// }

// // Provider para pets selecionados (para compatibilidade com UI existente)
// final selectedPetsForAdoptionProvider = Provider<List<String>>((ref) {
//   final createAdoptionState = ref.watch(createAdoptionProvider);
//   return createAdoptionState.selectedPetIds;
// });

// // Provider para verificar se pode criar adoção
// final canCreateAdoptionProvider = Provider<bool>((ref) {
//   final createAdoptionState = ref.watch(createAdoptionProvider);
//   return createAdoptionState.canCreate;
// });

// // Provider para pets disponíveis
// final availablePetsForAdoptionProvider =
//     Provider<List<FirebasePetModel>>((ref) {
//   final createAdoptionState = ref.watch(createAdoptionProvider);
//   return createAdoptionState.availablePets;
// });

// // Provider para estado de loading
// final isCreatingAdoptionProvider = Provider<bool>((ref) {
//   final createAdoptionState = ref.watch(createAdoptionProvider);
//   return createAdoptionState.isCreating;
// });

// // Provider para erro atual
// final adoptionCreationErrorProvider = Provider<String?>((ref) {
//   final createAdoptionState = ref.watch(createAdoptionProvider);
//   return createAdoptionState.error;
// });

// // Provider para ID de sucesso
// final adoptionSuccessIdProvider = Provider<String?>((ref) {
//   final createAdoptionState = ref.watch(createAdoptionProvider);
//   return createAdoptionState.successRequestId;
// });
