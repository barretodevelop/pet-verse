/// Modelo de dados para representar um Pet no sistema
class Pet {
  final String id;
  final String name;
  final String imageUrl;
  final String type;
  final String description;
  bool isAdopted;
  final String? generatedByUserId; // Null para pets padrão

  // Stats do Pet no jogo
  int hunger;
  int happiness;
  int energy;
  int level;
  int xp;
  int xpToNextLevel;

  Pet({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.type,
    required this.description,
    this.isAdopted = false,
    this.generatedByUserId,
    this.hunger = 80,
    this.happiness = 70,
    this.energy = 90,
    this.level = 1,
    this.xp = 0,
    this.xpToNextLevel = 100,
  });

  /// Cria uma cópia do Pet com novos valores opcionais
  Pet copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? type,
    String? description,
    bool? isAdopted,
    String? generatedByUserId,
    int? hunger,
    int? happiness,
    int? energy,
    int? level,
    int? xp,
    int? xpToNextLevel,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      description: description ?? this.description,
      isAdopted: isAdopted ?? this.isAdopted,
      generatedByUserId: generatedByUserId ?? this.generatedByUserId,
      hunger: hunger ?? this.hunger,
      happiness: happiness ?? this.happiness,
      energy: energy ?? this.energy,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
    );
  }

  /// Converte o Pet para Map para serialização
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'type': type,
      'description': description,
      'isAdopted': isAdopted,
      'generatedByUserId': generatedByUserId,
      'hunger': hunger,
      'happiness': happiness,
      'energy': energy,
      'level': level,
      'xp': xp,
      'xpToNextLevel': xpToNextLevel,
    };
  }

  /// Cria um Pet a partir de Map (deserialização)
  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      isAdopted: json['isAdopted'] as bool? ?? false,
      generatedByUserId: json['generatedByUserId'] as String?,
      hunger: json['hunger'] as int? ?? 80,
      happiness: json['happiness'] as int? ?? 70,
      energy: json['energy'] as int? ?? 90,
      level: json['level'] as int? ?? 1,
      xp: json['xp'] as int? ?? 0,
      xpToNextLevel: json['xpToNextLevel'] as int? ?? 100,
    );
  }

  /// Verifica se o pet está com status crítico (qualquer stat abaixo de 20)
  bool get isCriticalStatus {
    return hunger < 20 || happiness < 20 || energy < 20;
  }

  /// Verifica se o pet está feliz (todos os stats acima de 60)
  bool get isHappy {
    return hunger >= 60 && happiness >= 60 && energy >= 60;
  }

  /// Calcula a porcentagem para o próximo nível
  double get levelProgress {
    if (xpToNextLevel == 0) return 0.0;
    return xp / xpToNextLevel;
  }

  /// Retorna a cor da borda baseada no nível do pet
  String get borderColorByLevel {
    if (level >= 10) return '#FFD700'; // Dourado para níveis altos
    if (level >= 5) return '#C0C0C0'; // Prata para níveis médios
    return '#CD7F32'; // Bronze para níveis baixos
  }

  /// Calcula o próximo XP necessário baseado no nível atual
  int calculateNextLevelXP() {
    return (100 * (level * 1.5)).floor();
  }

  @override
  String toString() {
    return 'Pet(id: $id, name: $name, type: $type, level: $level, isAdopted: $isAdopted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Pet && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
