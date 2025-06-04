import 'package:petverse/src/features/pets/domain/entities/pet.dart';

// --- MOCK DATA ---
// TODO: Substituir mock data por integração com Firestore na FASE 1

final List<Pet> initialMockPets = [
  const Pet(
      id: 'p1',
      name: 'Fagulha',
      species: 'Cachorro',
      icon: '🐶',
      status: 'available', // Pet disponível para um segundo adotante
      needs: PetNeeds(hunger: 70, care: 60, fun: 80)),
  const Pet(
      id: 'p2',
      name: 'Biscoito',
      species: 'Gato',
      icon: '🐱',
      status: 'available',
      needs: PetNeeds(hunger: 60, care: 80, fun: 70)),
  const Pet(
      id: 'p3',
      name: 'Asinhas',
      species: 'Pássaro',
      icon: '🐦',
      status:
          'pending', // Um usuário já selecionou este pet e aguarda um parceiro
      adopter1:
          'user_firebase_id_1', // ID do Firebase Auth do primeiro adotante
      needs: PetNeeds(hunger: 80, care: 50, fun: 60)),
  const Pet(
      id: 'p4',
      name: 'Saltitão',
      species: 'Coelho',
      icon: '🐰',
      status: 'available',
      needs: PetNeeds(hunger: 50, care: 70, fun: 90)),
  const Pet(
      id: 'p5',
      name: 'Nemo',
      species: 'Peixe',
      icon: '🐠',
      status: 'adopted', // Pet já adotado por dois usuários
      adopter1: 'user_firebase_id_A',
      adopter2: 'user_firebase_id_B',
      needs: PetNeeds(hunger: 90, care: 90, fun: 90)),
];
