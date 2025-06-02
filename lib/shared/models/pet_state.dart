// lib/shared/models/pet_state.dart
import 'dart:math';

import 'package:flutter/material.dart';

// lib/shared/models/pet_state.dart (ALTERADO)
@immutable
class PetStats {
  final int happiness; // 0-100 (0 = triste, 100 = feliz)
  final int hunger; // 0-100 (0 = saciado, 100 = faminto)
  final int level;
  final int xp;
  final DateTime lastUpdate;
  // NOVO: Estado de saúde para futuras implementações de doença
  // final bool isSick;

  PetStats({
    this.happiness = 70,
    this.hunger = 30,
    this.level = 1,
    this.xp = 0,
    DateTime? lastUpdate,
    // this.isSick = false,
  }) : lastUpdate = lastUpdate ?? DateTime.now();

  int get xpForNextLevel => (100 * pow(level, 1.5)).floor();
  bool get isSatiated => hunger == 0;
  bool get isVeryHungry => hunger > 80;
  bool get isHappy => happiness > 70;
  bool get isVeryHappy => happiness > 85;
  bool get isSad => happiness < 40;
  bool get isInBadMood =>
      isSad || isVeryHungry; // Combina tristeza e fome extrema para mau humor

  PetStats copyWith(
          {int? happiness,
          int? hunger,
          int? level,
          int? xp,
          DateTime? lastUpdate /*, bool? isSick*/}) =>
      PetStats(
        happiness: happiness ?? this.happiness, hunger: hunger ?? this.hunger,
        level: level ?? this.level, xp: xp ?? this.xp,
        lastUpdate: lastUpdate ?? this.lastUpdate,
        // isSick: isSick ?? this.isSick,
      );

  Map<String, dynamic> toJson() => {
        'happiness': happiness, 'hunger': hunger, 'level': level, 'xp': xp,
        'lastUpdate': lastUpdate.toIso8601String(),
        // 'isSick': isSick,
      };

  factory PetStats.fromJson(Map<String, dynamic> json) => PetStats(
        happiness: json['happiness'] ?? 70, hunger: json['hunger'] ?? 30,
        level: json['level'] ?? 1, xp: json['xp'] ?? 0,
        lastUpdate: json['lastUpdate'] != null
            ? DateTime.parse(json['lastUpdate'])
            : DateTime.now(),
        // isSick: json['isSick'] ?? false,
      );
}
