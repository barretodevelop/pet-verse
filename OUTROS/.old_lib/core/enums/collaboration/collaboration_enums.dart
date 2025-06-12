// File: lib/core/enums/collaboration/collaboration_enums.dart

/// Status de colaboração entre usuários
enum CollaborationStatus {
  waitingForPartner, // Aguardando parceiro
  activeCollaboration, // Colaboração ativa
  revealAvailable, // Reveal disponível
  revealed, // Parceiros revelados
  abandoned, // Colaboração abandonada
  completed // Colaboração concluída com sucesso
}

enum SlotType {
  regular, // Slot regular (gratuito)
  premium, // Slot premium
  special // Slot especial (eventos)
}

extension SlotTypeExtension on SlotType {
  String get displayName {
    switch (this) {
      case SlotType.regular:
        return 'Regular';
      case SlotType.premium:
        return 'Premium';
      case SlotType.special:
        return 'Especial';
    }
  }

  String get emoji {
    switch (this) {
      case SlotType.regular:
        return '🔵';
      case SlotType.premium:
        return '💎';
      case SlotType.special:
        return '⭐';
    }
  }

  bool get isFree {
    return this == SlotType.regular;
  }

  bool get requiresPremium {
    return this == SlotType.premium || this == SlotType.special;
  }
}

extension CollaborationStatusExtension on CollaborationStatus {
  String get displayName {
    switch (this) {
      case CollaborationStatus.waitingForPartner:
        return 'Aguardando Parceiro';
      case CollaborationStatus.activeCollaboration:
        return 'Colaboração Ativa';
      case CollaborationStatus.revealAvailable:
        return 'Reveal Disponível';
      case CollaborationStatus.revealed:
        return 'Parceiros Revelados';
      case CollaborationStatus.abandoned:
        return 'Abandonada';
      case CollaborationStatus.completed:
        return 'Concluída';
    }
  }

  String get emoji {
    switch (this) {
      case CollaborationStatus.waitingForPartner:
        return '⏳';
      case CollaborationStatus.activeCollaboration:
        return '🤝';
      case CollaborationStatus.revealAvailable:
        return '🎁';
      case CollaborationStatus.revealed:
        return '👥';
      case CollaborationStatus.abandoned:
        return '❌';
      case CollaborationStatus.completed:
        return '✅';
    }
  }
}

/// Tipos de ação colaborativa
enum CollaborativeActionType {
  feed, // Alimentar
  play, // Brincar
  rest, // Descansar
  medicine, // Medicina
  clean, // Limpar
  train, // Treinar
  pet, // Fazer carinho
  exercise // Exercitar
}

extension CollaborativeActionTypeExtension on CollaborativeActionType {
  String get displayName {
    switch (this) {
      case CollaborativeActionType.feed:
        return 'Alimentar';
      case CollaborativeActionType.play:
        return 'Brincar';
      case CollaborativeActionType.rest:
        return 'Descansar';
      case CollaborativeActionType.medicine:
        return 'Dar Remédio';
      case CollaborativeActionType.clean:
        return 'Limpar';
      case CollaborativeActionType.train:
        return 'Treinar';
      case CollaborativeActionType.pet:
        return 'Fazer Carinho';
      case CollaborativeActionType.exercise:
        return 'Exercitar';
    }
  }

  String get emoji {
    switch (this) {
      case CollaborativeActionType.feed:
        return '🍖';
      case CollaborativeActionType.play:
        return '🎾';
      case CollaborativeActionType.rest:
        return '😴';
      case CollaborativeActionType.medicine:
        return '💊';
      case CollaborativeActionType.clean:
        return '🧽';
      case CollaborativeActionType.train:
        return '🎯';
      case CollaborativeActionType.pet:
        return '💕';
      case CollaborativeActionType.exercise:
        return '🏃';
    }
  }

  /// XP ganho por cada tipo de ação
  int get xpReward {
    switch (this) {
      case CollaborativeActionType.feed:
        return 15;
      case CollaborativeActionType.play:
        return 20;
      case CollaborativeActionType.rest:
        return 10;
      case CollaborativeActionType.medicine:
        return 25;
      case CollaborativeActionType.clean:
        return 15;
      case CollaborativeActionType.train:
        return 30;
      case CollaborativeActionType.pet:
        return 12;
      case CollaborativeActionType.exercise:
        return 25;
    }
  }
}

/// Nível de dificuldade de cuidado do pet
enum CollaborationDifficulty {
  beginner, // Iniciante
  intermediate, // Intermediário
  advanced, // Avançado
  expert // Especialista
}

extension CollaborationDifficultyExtension on CollaborationDifficulty {
  String get displayName {
    switch (this) {
      case CollaborationDifficulty.beginner:
        return 'Iniciante';
      case CollaborationDifficulty.intermediate:
        return 'Intermediário';
      case CollaborationDifficulty.advanced:
        return 'Avançado';
      case CollaborationDifficulty.expert:
        return 'Especialista';
    }
  }

  /// Nível necessário para reveal baseado na dificuldade
  int get revealLevel {
    switch (this) {
      case CollaborationDifficulty.beginner:
        return 8;
      case CollaborationDifficulty.intermediate:
        return 12;
      case CollaborationDifficulty.advanced:
        return 16;
      case CollaborationDifficulty.expert:
        return 20;
    }
  }

  /// Recompensa extra por dificuldade (multiplicador)
  double get rewardMultiplier {
    switch (this) {
      case CollaborationDifficulty.beginner:
        return 1.0;
      case CollaborationDifficulty.intermediate:
        return 1.2;
      case CollaborationDifficulty.advanced:
        return 1.5;
      case CollaborationDifficulty.expert:
        return 2.0;
    }
  }
}

// /// Tipo de slot de colaboração
// enum SlotType {
//   regular, // Slot regular (gratuito)
//   premium, // Slot premium
//   special // Slot especial (eventos)
// }

// extension SlotTypeExtension on SlotType {
//   String get displayName {
//     switch (this) {
//       case SlotType.regular:
//         return 'Regular';
//       case SlotType.premium:
//         return 'Premium';
//       case SlotType.special:
//         return 'Especial';
//     }
//   }

//   String get emoji {
//     switch (this) {
//       case SlotType.regular:
//         return '🔵';
//       case SlotType.premium:
//         return '💎';
//       case SlotType.special:
//         return '⭐';
//     }
//   }
// }

// /// Tipo de slot de colaboração
// enum SlotType {
//   regular, // Slot regular (gratuito)
//   premium, // Slot premium
//   special // Slot especial (eventos)
// }

// extension SlotTypeExtension on SlotType {
//   String get displayName {
//     switch (this) {
//       case SlotType.regular:
//         return 'Regular';
//       case SlotType.premium:
//         return 'Premium';
//       case SlotType.special:
//         return 'Especial';
//     }
//   }

//   String get emoji {
//     switch (this) {
//       case SlotType.regular:
//         return '🔵';
//       case SlotType.premium:
//         return '💎';
//       case SlotType.special:
//         return '⭐';
//     }
//   }

//   bool get isFree {
//     return this == SlotType.regular;
//   }

//   bool get requiresPremium {
//     return this == SlotType.premium || this == SlotType.special;
//   }
// }
