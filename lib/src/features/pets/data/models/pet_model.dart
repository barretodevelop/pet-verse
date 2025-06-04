import 'package:cloud_firestore/cloud_firestore.dart';

class Pet {
  final String id; // ID do documento no Firestore
  final String name;
  final String species; // Ex: 'dog', 'cat'
  final String breed;
  final int age;
  final String gender; // Ex: 'male', 'female'
  final String description;
  final String imageUrl; // URL da imagem do pet
  final bool isAdopted; // Se já foi adotado
  final String?
      currentAdoptionRequestId; // ID da solicitação de adoção atual (se houver)

  Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.gender,
    required this.description,
    required this.imageUrl,
    required this.isAdopted,
    this.currentAdoptionRequestId,
  });

  factory Pet.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Pet(
      id: doc.id,
      name: data['name'] ?? '',
      species: data['species'] ?? '',
      breed: data['breed'] ?? '',
      age: data['age'] ?? 0,
      gender: data['gender'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      isAdopted: data['isAdopted'] ?? false,
      currentAdoptionRequestId: data['currentAdoptionRequestId'],
    );
  }
}
