// lib/core/services/pet_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petverse/core/model/pet_model.dart';
import 'package:petverse/core/model/user_model.dart';
import 'package:petverse/core/services/firebase_service.dart';

class PetService {
  static Future<List<PetModel>> getAvailablePets({int limit = 20}) async {
    try {
      final query = await FirebaseService.pets
          .where('isAvailable', isEqualTo: true)
          .limit(limit)
          .get();

      return query.docs.map((doc) => PetModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar pets disponíveis: $e');
    }
  }

  static Future<List<PetModel>> getPetsByIds(List<String> petIds) async {
    if (petIds.isEmpty) return [];

    try {
      final List<PetModel> pets = [];

      // Firestore 'in' query limit is 10, so we need to batch
      for (int i = 0; i < petIds.length; i += 10) {
        final batch = petIds.skip(i).take(10).toList();
        final query = await FirebaseService.pets
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        pets.addAll(query.docs.map((doc) => PetModel.fromFirestore(doc)));
      }

      return pets;
    } catch (e) {
      throw Exception('Erro ao buscar pets por IDs: $e');
    }
  }

  static Future<PetModel?> getPetById(String petId) async {
    try {
      final doc = await FirebaseService.pets.doc(petId).get();
      if (doc.exists) {
        return PetModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar pet: $e');
    }
  }
}
