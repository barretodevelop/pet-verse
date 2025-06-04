import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/src/features/adoption/data/repositories/adoption_repository.dart';
import 'package:petverse/src/features/pets/data/models/pet_model.dart';

// Provider que expõe o stream de pets disponíveis
final availablePetsProvider = StreamProvider<List<Pet>>((ref) {
  final adoptionRepository = ref.watch(adoptionRepositoryProvider);
  // Retorna o stream de pets não adotados do repositório
  return adoptionRepository.getAvailablePets();
});
