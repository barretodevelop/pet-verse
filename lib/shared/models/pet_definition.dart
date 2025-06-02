// lib/shared/models/pet_definition.dart
import 'package:flutter/material.dart';

@immutable
class PetDefinition {
  final String id;
  final String name;
  final String emoji;
  const PetDefinition(
      {required this.id, required this.name, required this.emoji});
}
