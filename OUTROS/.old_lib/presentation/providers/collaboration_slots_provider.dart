// File: lib/presentation/providers/collaboration_slots_provider.dart
// Provider para gerenciar slots dinâmicos de pets colaborativos

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/enums/collaboration/collaboration_enums.dart';
import 'package:petverse/domain/entities/collaboration/collaborative_pet_entity.dart';

/// Estado de um slot de colaboração
class CollaborationSlot {
  final int index;
  final String? petId;
  final CollaborativePetEntity? pet;
  final SlotType type; // ✅ ADICIONADA: propriedade type correta
  final bool isOccupied;
  final CollaborationStatus? status;

  const CollaborationSlot({
    required this.index,
    this.petId,
    this.pet,
    required this.type, // ✅ REQUERIDA: type é obrigatório
    this.isOccupied = false,
    this.status,
  });

  bool get isAvailable => !isOccupied && (type == SlotType.regular || _hasUserPremium);
  bool get isLocked => type == SlotType.premium && !_hasUserPremium;
  bool get isPremium => type == SlotType.premium;
  bool get isSpecial => type == SlotType.special;
  bool get _hasUserPremium => true; // TODO: Integrar com user premium status

  CollaborationSlot copyWith({
    int? index,
    String? petId,
    CollaborativePetEntity? pet,
    SlotType? type,
    bool? isOccupied,
    CollaborationStatus? status,
    bool clearPet = false,
  }) {
    return CollaborationSlot(
      index: index ?? this.index,
      petId: clearPet ? null : (petId ?? this.petId),
      pet: clearPet ? null : (pet ?? this.pet),
      type: type ?? this.type,
      isOccupied: clearPet ? false : (isOccupied ?? this.isOccupied),
      status: clearPet ? null : (status ?? this.status),
    );
  }
}

/// Estado dos slots de colaboração
class CollaborationSlotsState {
  final List<CollaborationSlot> slots;
  final int maxSlots;
  final int occupiedSlots; // ✅ ADICIONADO: campo faltante
  final bool isLoading;

  const CollaborationSlotsState({
    this.slots = const [],
    this.maxSlots = 3,
    this.occupiedSlots = 0, // ✅ ADICIONADO: valor padrão
    this.isLoading = false,
  });

  int get availableSlots => maxSlots - occupiedSlots;
  bool get hasAvailableSlots => availableSlots > 0;
  List<CollaborationSlot> get availableSlotsOnly =>
      slots.where((slot) => slot.isAvailable).toList();
  List<CollaborationSlot> get occupiedSlotsOnly => slots.where((slot) => slot.isOccupied).toList();

  CollaborationSlotsState copyWith({
    List<CollaborationSlot>? slots,
    int? maxSlots,
    int? occupiedSlots,
    bool? isLoading,
  }) {
    return CollaborationSlotsState(
      slots: slots ?? this.slots,
      maxSlots: maxSlots ?? this.maxSlots,
      occupiedSlots: occupiedSlots ?? this.occupiedSlots,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Notifier para gerenciar slots de colaboração
class CollaborationSlotsNotifier extends StateNotifier<CollaborationSlotsState> {
  CollaborationSlotsNotifier() : super(const CollaborationSlotsState()) {
    _initializeSlots();
  }

  void _initializeSlots() {
    final slots = List.generate(3, (index) {
      return CollaborationSlot(
        index: index,
        type: index == 0 ? SlotType.regular : SlotType.premium, // ✅ CORRIGIDO: usar SlotType
      );
    });

    state = state.copyWith(slots: slots);
  }

  /// Sincroniza slots com pets do usuário
  void syncWithUserPets(List<CollaborativePetEntity> userPets) {
    final updatedSlots = <CollaborationSlot>[];

    for (int i = 0; i < state.maxSlots; i++) {
      if (i < userPets.length) {
        // Slot ocupado com pet
        final pet = userPets[i];
        updatedSlots.add(CollaborationSlot(
          index: i,
          petId: pet.id,
          pet: pet,
          type: i == 0 ? SlotType.regular : SlotType.premium, // ✅ CORRIGIDO: usar SlotType
          isOccupied: true,
          status: pet.status,
        ));
      } else {
        // Slot vazio
        updatedSlots.add(CollaborationSlot(
          index: i,
          type: i == 0 ? SlotType.regular : SlotType.premium, // ✅ CORRIGIDO: usar SlotType
          isOccupied: false,
        ));
      }
    }

    state = state.copyWith(
      slots: updatedSlots,
      occupiedSlots: userPets.length,
    );
  }

  /// Adiciona pet a um slot específico
  void addPetToSlot(int slotIndex, CollaborativePetEntity pet) {
    if (slotIndex >= state.slots.length) return;

    final updatedSlots = List<CollaborationSlot>.from(state.slots);
    updatedSlots[slotIndex] = updatedSlots[slotIndex].copyWith(
      petId: pet.id,
      pet: pet,
      isOccupied: true,
      status: pet.status,
    );

    state = state.copyWith(
      slots: updatedSlots,
      occupiedSlots: state.occupiedSlots + 1,
    );
  }

  /// Remove pet de um slot
  void removePetFromSlot(int slotIndex) {
    if (slotIndex >= state.slots.length) return;

    final updatedSlots = List<CollaborationSlot>.from(state.slots);
    updatedSlots[slotIndex] = updatedSlots[slotIndex].copyWith(
      clearPet: true,
    );

    state = state.copyWith(
      slots: updatedSlots,
      occupiedSlots: state.occupiedSlots - 1,
    );
  }

  /// Atualiza status de um pet em slot específico
  void updatePetStatus(String petId, CollaborationStatus newStatus) {
    final updatedSlots = state.slots.map((slot) {
      if (slot.petId == petId) {
        return slot.copyWith(status: newStatus);
      }
      return slot;
    }).toList();

    state = state.copyWith(slots: updatedSlots);
  }
}

/// Provider dos slots de colaboração
final collaborationSlotsProvider =
    StateNotifierProvider<CollaborationSlotsNotifier, CollaborationSlotsState>((ref) {
  return CollaborationSlotsNotifier();
});
