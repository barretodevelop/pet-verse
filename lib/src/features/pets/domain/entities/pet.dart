import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // Para @immutable

@immutable
class Pet {
  final String id;
  final String name;
  final String species;
  final String icon;
  final String status; // 'available', 'pending', 'adopted'
  final String? adopter1; // Deverá ser o ID do usuário (AppUser.id)
  final String? adopter2; // Deverá ser o ID do usuário (AppUser.id)
  final PetNeeds needs;

  const Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.icon,
    required this.status,
    this.adopter1,
    this.adopter2,
    required this.needs,
  });

  Pet copyWith({
    String? id,
    String? name,
    String? species,
    String? icon,
    String? status,
    String? adopter1,
    bool clearAdopter1 = false,
    String? adopter2,
    bool clearAdopter2 = false,
    PetNeeds? needs,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      icon: icon ?? this.icon,
      status: status ?? this.status,
      adopter1: clearAdopter1 ? null : adopter1 ?? this.adopter1,
      adopter2: clearAdopter2 ? null : adopter2 ?? this.adopter2,
      needs: needs ?? this.needs,
    );
  }

  static fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {}
}

@immutable
class PetNeeds {
  final int hunger;
  final int care;
  final int fun;

  const PetNeeds({this.hunger = 70, this.care = 60, this.fun = 80});

  PetNeeds copyWith({
    int? hunger,
    int? care,
    int? fun,
  }) {
    return PetNeeds(
      hunger: hunger ?? this.hunger,
      care: care ?? this.care,
      fun: fun ?? this.fun,
    );
  }
}
