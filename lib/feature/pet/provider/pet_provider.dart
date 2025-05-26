import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/feature/pet/model/pet.dart';
import 'package:petverse/feature/pet/service/pet_service.dart';

// Provider do serviço
final petServiceProvider = Provider<PetService>((ref) {
  return PetService(ref);
});

// Stream do pet do usuário
final petStreamProvider = StreamProvider<Pet?>((ref) {
  final service = ref.watch(petServiceProvider);
  return service.streamUserPet();
});

// Controller para ações do pet
class PetController extends StateNotifier<AsyncValue<void>> {
  final PetService _service;
  final Ref _ref;

  PetController(this._service, this._ref) : super(const AsyncData(null));

  Future<void> createPet({
    required String roomId,
    required String petName,
    required String petType,
  }) async {
    state = const AsyncLoading();
    try {
      await _service.createPet(
        roomId: roomId,
        petName: petName,
        petType: petType,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> feedPet() async {
    final pet = _ref.read(petStreamProvider).valueOrNull;
    if (pet == null) return;

    state = const AsyncLoading();
    try {
      await _service.feedPet(pet.id);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> playWithPet() async {
    final pet = _ref.read(petStreamProvider).valueOrNull;
    if (pet == null) return;

    state = const AsyncLoading();
    try {
      await _service.playWithPet(pet.id);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> cleanPet() async {
    final pet = _ref.read(petStreamProvider).valueOrNull;
    if (pet == null) return;

    state = const AsyncLoading();
    try {
      await _service.cleanPet(pet.id);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

// Provider do controller
final petControllerProvider =
    StateNotifierProvider<PetController, AsyncValue<void>>((ref) {
  final service = ref.watch(petServiceProvider);
  return PetController(service, ref);
});
