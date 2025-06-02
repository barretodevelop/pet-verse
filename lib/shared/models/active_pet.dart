// lib/shared/models/active_pet.dart
import 'package:flutter/material.dart';
import 'package:petverse/shared/models/pet_definition.dart';
import 'package:petverse/shared/models/pet_state.dart';

@immutable
class ActivePet {
  final PetDefinition definition;
  final PetStats stats;
  const ActivePet({required this.definition, required this.stats});
  ActivePet copyWith({PetDefinition? definition, PetStats? stats}) => ActivePet(
        definition: definition ?? this.definition,
        stats: stats ?? this.stats,
      );
}
