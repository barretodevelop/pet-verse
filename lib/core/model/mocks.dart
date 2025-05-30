// ============================================
// ARQUIVO: lib/core/models/mock_models.dart
// ============================================

class AnonymousAdoption {
  final String missionId;
  final String codename;
  final int colorTheme;
  final int level;
  final List<String> badges;
  final int successRate;
  final int completedAdoptions;
  final int currentStreak;
  final String region;
  final int views;
  final int interested;
  final int potentialMatches;
  final double timeLeftDays;
  final List<MockPet> pets;
  final String codedMessage;
  final List<String> personalityTags;
  final String status;
  final bool isNew;

  AnonymousAdoption({
    required this.missionId,
    required this.codename,
    required this.colorTheme,
    required this.level,
    required this.badges,
    required this.successRate,
    required this.completedAdoptions,
    required this.currentStreak,
    required this.region,
    required this.views,
    required this.interested,
    required this.potentialMatches,
    required this.timeLeftDays,
    required this.pets,
    required this.codedMessage,
    required this.personalityTags,
    required this.status,
    required this.isNew,
  });

  // Método para criar cópia com modificações
  AnonymousAdoption copyWith({
    String? missionId,
    String? codename,
    int? colorTheme,
    int? level,
    List<String>? badges,
    int? successRate,
    int? completedAdoptions,
    int? currentStreak,
    String? region,
    int? views,
    int? interested,
    int? potentialMatches,
    double? timeLeftDays,
    List<MockPet>? pets,
    String? codedMessage,
    List<String>? personalityTags,
    String? status,
    bool? isNew,
  }) {
    return AnonymousAdoption(
      missionId: missionId ?? this.missionId,
      codename: codename ?? this.codename,
      colorTheme: colorTheme ?? this.colorTheme,
      level: level ?? this.level,
      badges: badges ?? this.badges,
      successRate: successRate ?? this.successRate,
      completedAdoptions: completedAdoptions ?? this.completedAdoptions,
      currentStreak: currentStreak ?? this.currentStreak,
      region: region ?? this.region,
      views: views ?? this.views,
      interested: interested ?? this.interested,
      potentialMatches: potentialMatches ?? this.potentialMatches,
      timeLeftDays: timeLeftDays ?? this.timeLeftDays,
      pets: pets ?? this.pets,
      codedMessage: codedMessage ?? this.codedMessage,
      personalityTags: personalityTags ?? this.personalityTags,
      status: status ?? this.status,
      isNew: isNew ?? this.isNew,
    );
  }

  // Método para converter para JSON (útil para debug)
  Map<String, dynamic> toJson() {
    return {
      'missionId': missionId,
      'codename': codename,
      'colorTheme': colorTheme,
      'level': level,
      'badges': badges,
      'successRate': successRate,
      'completedAdoptions': completedAdoptions,
      'currentStreak': currentStreak,
      'region': region,
      'views': views,
      'interested': interested,
      'potentialMatches': potentialMatches,
      'timeLeftDays': timeLeftDays,
      'pets': pets.map((pet) => pet.toJson()).toList(),
      'codedMessage': codedMessage,
      'personalityTags': personalityTags,
      'status': status,
      'isNew': isNew,
    };
  }
}

class MockPet {
  final String name;
  final String type;
  final String age;
  final String photo;
  final List<String>? traits; // Adicional para características
  final String? description; // Adicional para descrição

  MockPet({
    required this.name,
    required this.type,
    required this.age,
    required this.photo,
    this.traits,
    this.description,
  });

  // Método copyWith
  MockPet copyWith({
    String? name,
    String? type,
    String? age,
    String? photo,
    List<String>? traits,
    String? description,
  }) {
    return MockPet(
      name: name ?? this.name,
      type: type ?? this.type,
      age: age ?? this.age,
      photo: photo ?? this.photo,
      traits: traits ?? this.traits,
      description: description ?? this.description,
    );
  }

  // Método para converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'age': age,
      'photo': photo,
      'traits': traits,
      'description': description,
    };
  }
}

class InterestedUser {
  final String codename;
  final int level;
  final int colorTheme;
  final List<String>? badges;
  final int? successRate;

  InterestedUser({
    required this.codename,
    required this.level,
    required this.colorTheme,
    this.badges,
    this.successRate,
  });

  // Método copyWith
  InterestedUser copyWith({
    String? codename,
    int? level,
    int? colorTheme,
    List<String>? badges,
    int? successRate,
  }) {
    return InterestedUser(
      codename: codename ?? this.codename,
      level: level ?? this.level,
      colorTheme: colorTheme ?? this.colorTheme,
      badges: badges ?? this.badges,
      successRate: successRate ?? this.successRate,
    );
  }

  // Método para converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'codename': codename,
      'level': level,
      'colorTheme': colorTheme,
      'badges': badges,
      'successRate': successRate,
    };
  }
}

// ============================================
// DADOS MOCK CENTRALIZADOS
// ============================================

class MockDataProvider {
  static List<AnonymousAdoption> getAdoptions() {
    return [
      AnonymousAdoption(
        missionId: 'ADT_001',
        codename: 'Guardian Azul',
        colorTheme: 0xFF3B82F6,
        level: 12,
        badges: ['golden_angel', 'shadow_protector'],
        successRate: 94,
        completedAdoptions: 15,
        currentStreak: 5,
        region: 'Zona Sul - SP',
        views: 47,
        interested: 12,
        potentialMatches: 3,
        timeLeftDays: 2.6,
        pets: [
          MockPet(
            name: 'Luna',
            type: 'Gato',
            age: '2 anos',
            photo: '🐱',
            traits: ['carinhoso', 'brincalhão', 'calmo'],
            description: 'Luna é uma gatinha muito dócil e carinhosa',
          ),
          MockPet(
            name: 'Max',
            type: 'Cachorro',
            age: '3 anos',
            photo: '🐕',
            traits: ['leal', 'energético', 'protetor'],
            description: 'Max é um cachorro muito leal e protetor',
          ),
          MockPet(
            name: 'Bella',
            type: 'Coelho',
            age: '1 ano',
            photo: '🐰',
            traits: ['tímido', 'fofo', 'tranquilo'],
            description: 'Bella é uma coelhinha muito fofa e tranquila',
          ),
        ],
        codedMessage:
            'Colaborador experiente busca parceiro dedicado para missão especial',
        personalityTags: ['dedicado', 'organizado', 'carinhoso'],
        status: 'hot',
        isNew: false,
      ),
      AnonymousAdoption(
        missionId: 'ADT_002',
        codename: 'Protetor Rosa',
        colorTheme: 0xFFEC4899,
        level: 8,
        badges: ['first_timer', 'cat_lover'],
        successRate: 89,
        completedAdoptions: 7,
        currentStreak: 3,
        region: 'Centro - RJ',
        views: 23,
        interested: 8,
        potentialMatches: 2,
        timeLeftDays: 4.2,
        pets: [
          MockPet(
            name: 'Mimi',
            type: 'Gato',
            age: '1 ano',
            photo: '🐱',
            traits: ['brincalhão', 'curioso', 'ativo'],
          ),
          MockPet(
            name: 'Toby',
            type: 'Cachorro',
            age: '2 anos',
            photo: '🐕',
            traits: ['amigável', 'obediente', 'carinhoso'],
          ),
          MockPet(
            name: 'Snow',
            type: 'Hamster',
            age: '6 meses',
            photo: '🐹',
            traits: ['pequeno', 'ativo', 'fofo'],
          ),
        ],
        codedMessage: 'Primeira missão em grupo, procuro mentor experiente',
        personalityTags: ['iniciante', 'entusiasmado', 'responsável'],
        status: 'normal',
        isNew: true,
      ),
      AnonymousAdoption(
        missionId: 'ADT_003',
        codename: 'Anjo Verde',
        colorTheme: 0xFF10B981,
        level: 20,
        badges: ['veteran', 'dog_whisperer', 'golden_heart'],
        successRate: 98,
        completedAdoptions: 32,
        currentStreak: 12,
        region: 'Zona Norte - SP',
        views: 89,
        interested: 23,
        potentialMatches: 7,
        timeLeftDays: 0.8,
        pets: [
          MockPet(
            name: 'Rex',
            type: 'Cachorro',
            age: '4 anos',
            photo: '🐕',
            traits: ['forte', 'leal', 'protetor'],
          ),
          MockPet(
            name: 'Whiskers',
            type: 'Gato',
            age: '3 anos',
            photo: '🐱',
            traits: ['independente', 'elegante', 'carinhoso'],
          ),
          MockPet(
            name: 'Pipoca',
            type: 'Papagaio',
            age: '2 anos',
            photo: '🦜',
            traits: ['falante', 'inteligente', 'colorido'],
          ),
        ],
        codedMessage:
            'Veterano em missão urgente, preciso de parceiro confiável',
        personalityTags: ['experiente', 'paciente', 'líder'],
        status: 'urgent',
        isNew: false,
      ),
    ];
  }

  static List<InterestedUser> getInterestedUsers() {
    return [
      InterestedUser(
        codename: 'Protetor Dourado',
        level: 15,
        colorTheme: 0xFFF59E0B,
        badges: ['golden_heart'],
        successRate: 92,
      ),
      InterestedUser(
        codename: 'Guardian Prata',
        level: 11,
        colorTheme: 0xFF6B7280,
        badges: ['consistent'],
        successRate: 88,
      ),
      InterestedUser(
        codename: 'Anjo Roxo',
        level: 9,
        colorTheme: 0xFF8B5CF6,
        badges: ['newcomer'],
        successRate: 85,
      ),
    ];
  }

  static List<AnonymousAdoption> getExtendedAdoptions() {
    return [
      // Adoções existentes
      ...getAdoptions(),

      // Novas adoções para maior variedade
      AnonymousAdoption(
        missionId: 'ADT_004',
        codename: 'Sombra Violeta',
        colorTheme: 0xFF8B5CF6,
        level: 5,
        badges: ['newcomer'],
        successRate: 78,
        completedAdoptions: 3,
        currentStreak: 2,
        region: 'Zona Oeste - SP',
        views: 15,
        interested: 4,
        potentialMatches: 1,
        timeLeftDays: 3.8,
        pets: [
          MockPet(
            name: 'Hope',
            type: 'Coelho',
            age: '4 anos',
            photo: '🐰',
            traits: ['especial', 'forte', 'inspirador'],
            description: 'Coelho com três patas, muito inspirador',
          ),
        ],
        codedMessage:
            'MISSÃO ESPECIAL: Veterano experiente precisa de parceiro para pets com necessidades especiais',
        personalityTags: ['especialista', 'compassivo', 'experiente'],
        status: 'urgent',
        isNew: false,
      ),

      AnonymousAdoption(
        missionId: 'ADT_007',
        codename: 'Protetor Coral',
        colorTheme: 0xFFFF6B6B,
        level: 10,
        badges: ['dog_lover', 'active'],
        successRate: 87,
        completedAdoptions: 12,
        currentStreak: 4,
        region: 'Zona Norte - RJ',
        views: 32,
        interested: 9,
        potentialMatches: 2,
        timeLeftDays: 2.1,
        pets: [
          MockPet(
            name: 'Bolt',
            type: 'Cachorro',
            age: '1 ano',
            photo: '🐕',
            traits: ['energético', 'atlético', 'brincalhão'],
            description: 'Cachorro muito energético, precisa de exercícios',
          ),
          MockPet(
            name: 'Flash',
            type: 'Gato',
            age: '2 anos',
            photo: '🐱',
            traits: ['ativo', 'ágil', 'aventureiro'],
            description: 'Gato muito ativo e aventureiro',
          ),
          MockPet(
            name: 'Rocket',
            type: 'Furão',
            age: '1 ano',
            photo: '🦔',
            traits: ['rápido', 'curioso', 'travesso'],
            description: 'Furão muito rápido e travesso',
          ),
        ],
        codedMessage:
            'Busco parceiro ativo para pets de alta energia - aventura garantida!',
        personalityTags: ['ativo', 'aventureiro', 'energético'],
        status: 'normal',
        isNew: false,
      ),

      AnonymousAdoption(
        missionId: 'ADT_008',
        codename: 'Sábio Dourado',
        colorTheme: 0xFFEAB308,
        level: 30,
        badges: ['master', 'golden_heart', 'wise_mentor'],
        successRate: 100,
        completedAdoptions: 67,
        currentStreak: 25,
        region: 'Interior - SP',
        views: 89,
        interested: 12,
        potentialMatches: 4,
        timeLeftDays: 4.7,
        pets: [
          MockPet(
            name: 'Wisdom',
            type: 'Tartaruga',
            age: '15 anos',
            photo: '🐢',
            traits: ['sábio', 'tranquilo', 'longevo'],
            description: 'Tartaruga muito antiga e sábia',
          ),
          MockPet(
            name: 'Sage',
            type: 'Gato',
            age: '12 anos',
            photo: '🐱',
            traits: ['sênior', 'calmo', 'sábio'],
            description: 'Gato sênior muito sábio e calmo',
          ),
          MockPet(
            name: 'Elder',
            type: 'Cachorro',
            age: '10 anos',
            photo: '🐕',
            traits: ['sênior', 'gentil', 'experiente'],
            description: 'Cachorro idoso muito gentil',
          ),
        ],
        codedMessage:
            'Mestre experiente oferece sabedoria em troca de companhia para pets sêniores',
        personalityTags: ['mestre', 'sábio', 'mentor'],
        status: 'normal',
        isNew: false,
      ),
    ];
  }

  static List<AnonymousAdoption> getAdoptionsByFilter(String filter) {
    final allAdoptions = getExtendedAdoptions();

    switch (filter) {
      case 'Urgentes':
        return allAdoptions
            .where((a) => a.status == 'urgent' || a.timeLeftDays < 1.0)
            .toList();
      case 'Novas':
        return allAdoptions.where((a) => a.isNew).toList();
      case 'Experientes':
        return allAdoptions.where((a) => a.level >= 15).toList();
      case 'Filhotes':
        return allAdoptions
            .where((a) =>
                a.pets.any((pet) => pet.traits?.contains('filhote') ?? false))
            .toList();
      case 'Especiais':
        return allAdoptions
            .where((a) =>
                a.pets.any((pet) => pet.traits?.contains('especial') ?? false))
            .toList();
      case 'Sênior':
        return allAdoptions
            .where((a) =>
                a.pets.any((pet) => pet.traits?.contains('sênior') ?? false))
            .toList();
      default:
        return allAdoptions;
    }
  }

  // Método para simular mudanças de status em tempo real
  static AnonymousAdoption updateAdoptionStatus(AnonymousAdoption adoption) {
    // Simular aumento de visualizações e interesse
    final random = DateTime.now().millisecond;
    return adoption.copyWith(
      views: adoption.views + (random % 5),
      interested: adoption.interested + (random % 3),
      timeLeftDays: adoption.timeLeftDays - 0.1,
    );
  }

  // Método para ordenar adoções por diferentes critérios
  static List<AnonymousAdoption> sortAdoptions(
      List<AnonymousAdoption> adoptions, String sortBy) {
    switch (sortBy) {
      case 'Mais Urgentes':
        adoptions.sort((a, b) => a.timeLeftDays.compareTo(b.timeLeftDays));
        break;
      case 'Mais Populares':
        adoptions.sort((a, b) => b.interested.compareTo(a.interested));
        break;
      case 'Nível Alto':
        adoptions.sort((a, b) => b.level.compareTo(a.level));
        break;
      case 'Recentes':
        adoptions.sort((a, b) => b.isNew ? 1 : -1);
        break;
      default:
        // Ordenação padrão por tempo restante e popularidade
        adoptions.sort((a, b) {
          if (a.status == 'urgent' && b.status != 'urgent') return -1;
          if (b.status == 'urgent' && a.status != 'urgent') return 1;
          if (a.status == 'hot' && b.status != 'hot') return -1;
          if (b.status == 'hot' && a.status != 'hot') return 1;
          return b.interested.compareTo(a.interested);
        });
    }
    return adoptions;
  }
}
