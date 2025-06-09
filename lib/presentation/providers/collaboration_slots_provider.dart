// File: lib/presentation/providers/collaboration_slots_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/enums/collaboration/collaboration_enums.dart';

/// Estado dos slots de colaboração
class CollaborationSlotsState {
  final List<CollaborationSlot> slots;
  final int maxSlots;
  final bool isLoading;
  final String? errorMessage;

  const CollaborationSlotsState({
    this.slots = const [],
    this.maxSlots = 3,
    this.isLoading = false,
    this.errorMessage,
  });

  int get usedSlots => slots.where((slot) => slot.isOccupied).length;
  int get availableSlots => maxSlots - usedSlots;
  bool get hasAvailableSlots => availableSlots > 0;

  CollaborationSlotsState copyWith({
    List<CollaborationSlot>? slots,
    int? maxSlots,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CollaborationSlotsState(
      slots: slots ?? this.slots,
      maxSlots: maxSlots ?? this.maxSlots,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Representação de um slot de colaboração
class CollaborationSlot {
  final int index;
  final SlotType type;
  final bool isOccupied;
  final String? petId;
  final String? petName;
  final String? petImageUrl;
  final CollaborationStatus? collaborationStatus;

  const CollaborationSlot({
    required this.index,
    required this.type,
    required this.isOccupied,
    this.petId,
    this.petName,
    this.petImageUrl,
    this.collaborationStatus,
  });

  bool get isEmpty => !isOccupied;
  bool get isAvailable => isEmpty && type == SlotType.regular;
  bool get isPremium => type == SlotType.premium;
  bool get isSpecial => type == SlotType.special;

  CollaborationSlot copyWith({
    int? index,
    SlotType? type,
    bool? isOccupied,
    String? petId,
    String? petName,
    String? petImageUrl,
    CollaborationStatus? collaborationStatus,
    bool clearPet = false,
  }) {
    return CollaborationSlot(
      index: index ?? this.index,
      type: type ?? this.type,
      isOccupied: clearPet ? false : (isOccupied ?? this.isOccupied),
      petId: clearPet ? null : (petId ?? this.petId),
      petName: clearPet ? null : (petName ?? this.petName),
      petImageUrl: clearPet ? null : (petImageUrl ?? this.petImageUrl),
      collaborationStatus: clearPet ? null : (collaborationStatus ?? this.collaborationStatus),
    );
  }
}

/// Notifier dos slots de colaboração
class CollaborationSlotsNotifier extends StateNotifier<CollaborationSlotsState> {
  CollaborationSlotsNotifier() : super(const CollaborationSlotsState()) {
    _initializeSlots();
  }

  void _initializeSlots() {
    final slots = List.generate(3, (index) {
      return CollaborationSlot(
        index: index,
        type: index < 3 ? SlotType.regular : SlotType.premium,
        isOccupied: false,
      );
    });

    state = state.copyWith(slots: slots);
  }

  /// Ocupar slot com pet
  void occupySlot(
      int slotIndex, String petId, String petName, String petImageUrl, CollaborationStatus status) {
    final updatedSlots = [...state.slots];

    if (slotIndex < updatedSlots.length) {
      updatedSlots[slotIndex] = updatedSlots[slotIndex].copyWith(
        isOccupied: true,
        petId: petId,
        petName: petName,
        petImageUrl: petImageUrl,
        collaborationStatus: status,
      );

      state = state.copyWith(slots: updatedSlots);
    }
  }

  /// Liberar slot
  void freeSlot(int slotIndex) {
    final updatedSlots = [...state.slots];

    if (slotIndex < updatedSlots.length) {
      updatedSlots[slotIndex] = updatedSlots[slotIndex].copyWith(clearPet: true);
      state = state.copyWith(slots: updatedSlots);
    }
  }

  /// Atualizar status do pet no slot
  void updateSlotStatus(String petId, CollaborationStatus status) {
    final updatedSlots = state.slots.map((slot) {
      if (slot.petId == petId) {
        return slot.copyWith(collaborationStatus: status);
      }
      return slot;
    }).toList();

    state = state.copyWith(slots: updatedSlots);
  }

  /// Expandir slots (premium)
  void expandSlots(int newMaxSlots) {
    if (newMaxSlots > state.maxSlots) {
      final additionalSlots = List.generate(
        newMaxSlots - state.maxSlots,
        (index) => CollaborationSlot(
          index: state.maxSlots + index,
          type: SlotType.premium,
          isOccupied: false,
        ),
      );

      final allSlots = [...state.slots, ...additionalSlots];
      state = state.copyWith(
        slots: allSlots,
        maxSlots: newMaxSlots,
      );
    }
  }

  /// Sincronizar slots com pets do usuário
  void syncWithUserPets(List<dynamic> userPets) {
    // Reset all slots first
    final resetSlots = state.slots.map((slot) => slot.copyWith(clearPet: true)).toList();

    // Occupy slots with user's collaborative pets
    for (int i = 0; i < userPets.length && i < resetSlots.length; i++) {
      final pet = userPets[i];
      resetSlots[i] = resetSlots[i].copyWith(
        isOccupied: true,
        petId: pet.id,
        petName: pet.name,
        petImageUrl: pet.imageUrl,
        collaborationStatus: pet.status,
      );
    }

    state = state.copyWith(slots: resetSlots);
  }
}

/// Provider dos slots de colaboração
final collaborationSlotsProvider =
    StateNotifierProvider<CollaborationSlotsNotifier, CollaborationSlotsState>((ref) {
  return CollaborationSlotsNotifier();
});

/// Provider para buscar próximo slot disponível
final nextAvailableSlotProvider = Provider<int?>((ref) {
  final slotsState = ref.watch(collaborationSlotsProvider);

  for (int i = 0; i < slotsState.slots.length; i++) {
    if (slotsState.slots[i].isEmpty) {
      return i;
    }
  }

  return null; // Nenhum slot disponível
});
