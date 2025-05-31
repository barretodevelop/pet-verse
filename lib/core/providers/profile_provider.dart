import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/model/mocks.dart';
import 'package:petverse/core/model/user_model.dart';
import 'package:petverse/feature/auth/providers/authentication_provider.dart';

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final authState = ref.watch(authenticationNotifierProvider);
  return ProfileNotifier(authState.userModel);
});

class ProfileState {
  final bool isLoading;
  final UserProfile? userProfile;
  final List<RankingUser> ranking;
  final String errorMessage;

  ProfileState({
    required this.isLoading,
    this.userProfile,
    required this.ranking,
    required this.errorMessage,
  });

  ProfileState copyWith({
    bool? isLoading,
    UserProfile? userProfile,
    List<RankingUser>? ranking,
    String? errorMessage,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      userProfile: userProfile ?? this.userProfile,
      ranking: ranking ?? this.ranking,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class RankingUser {
  final String codename;
  final int level;
  final int totalXP;
  final int colorTheme; // Exemplo: 0xFFFFD700 (Cor dourada)
  final int position;

  const RankingUser({
    required this.codename,
    required this.level,
    required this.totalXP,
    required this.colorTheme,
    required this.position,
  });

  @override
  String toString() {
    return 'RankingUser(codename: $codename, level: $level, totalXP: $totalXP, '
        'colorTheme: $colorTheme, position: $position)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RankingUser &&
          other.codename == codename &&
          other.level == level &&
          other.totalXP == totalXP &&
          other.colorTheme == colorTheme &&
          other.position == position;

  @override
  int get hashCode =>
      Object.hash(codename, level, totalXP, colorTheme, position);
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier(UserModel? initialUser)
      : super(ProfileState(
          isLoading: true,
          ranking: [],
          errorMessage: '',
        )) {
    _loadProfile(initialUser);
  }

  Future<void> _loadProfile(UserModel? user) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (user == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Usuário não encontrado',
      );
      return;
    }

    state = state.copyWith(
      isLoading: false,
      userProfile: _createUserProfileFromFirebase(user),
      ranking: _generateRanking(),
    );
  }

  void updateUser(UserModel? newUser) {
    if (newUser != null) {
      _loadProfile(newUser);
    }
  }

  UserProfile _createUserProfileFromFirebase(UserModel user) {
    return UserProfile(
      codename: user.displayName ?? 'Guardian Anônimo',
      level: user.level,
      currentXP: user.xp,
      xpToNextLevel: user.level * 100,
      colorTheme: 0xFF3B82F6, // Pode vir de user.settings futuramente
      totalPetsAdopted: user.stats.totalPetsCared,
      activePets: user.petIds.length,
      successRate: _calculateSuccessRate(user).toDouble(),
      currentStreak: user.stats.loginStreak,
      longestStreak: _calculateLongestStreak(user),
      daysActive: DateTime.now().difference(user.createdAt).inDays,
      totalXPEarned: user.totalXP,
      achievements: _convertAchievementsFromFirebase(user),
      adoptionHistory: _generateAdoptionHistoryFromFirebase(user),
      rankingPosition: _calculateRankingPosition(user),
      joinedDate: user.createdAt,
    );
  }

  int _calculateSuccessRate(UserModel user) {
    final stats = user.stats;
    if (stats.totalMissionsCompleted == 0) return 100;

    return ((stats.totalMissionsCompleted /
                (stats.totalMissionsCompleted + 1)) *
            100)
        .round();
  }

  int _calculateLongestStreak(UserModel user) {
    // Por enquanto, usar o streak atual como base
    // Na implementação real, você salvaria o longest streak no UserStats
    return user.stats.loginStreak + 10; // Simulação
  }

  List<Achievement> _convertAchievementsFromFirebase(UserModel user) {
    final achievements = <Achievement>[];

    // Converter achievements do Firebase para o modelo da UI
    for (String achievementId in user.achievements) {
      achievements.add(_createAchievementFromId(achievementId));
    }

    // Adicionar conquistas baseadas em estatísticas
    if (user.level >= 10) {
      achievements.add(Achievement(
        id: 'level_10',
        title: 'Guardião Experiente',
        description: 'Alcançou o nível 10',
        emoji: '⭐',
        rarity: 2,
        isUnlocked: true,
        unlockedAt: user.createdAt.add(Duration(days: user.level * 2)),
        xpReward: 100,
      ));
    }

    if (user.stats.totalPetsCared >= 5) {
      achievements.add(Achievement(
        id: 'pet_lover',
        title: 'Amante dos Pets',
        description: 'Cuidou de 5 pets diferentes',
        emoji: '🐾',
        rarity: 2,
        isUnlocked: true,
        unlockedAt: user.createdAt.add(const Duration(days: 30)),
        xpReward: 200,
      ));
    }

    return achievements;
  }

  Achievement _createAchievementFromId(String achievementId) {
    // Mapeamento de IDs para achievements
    final achievementMap = {
      'first_pet': Achievement(
        id: 'first_pet',
        title: 'Primeiro Pet',
        description: 'Adotou seu primeiro pet',
        emoji: '🐾',
        rarity: 1,
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 30)),
        xpReward: 100,
      ),
      'golden_heart': Achievement(
        id: 'golden_heart',
        title: 'Coração Dourado',
        description: 'Manteve pets felizes por 30 dias',
        emoji: '💝',
        rarity: 3,
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 15)),
        xpReward: 500,
      ),
    };

    return achievementMap[achievementId] ??
        Achievement(
          id: achievementId,
          title: 'Conquista Especial',
          description: 'Uma conquista única',
          emoji: '🏆',
          rarity: 1,
          isUnlocked: true,
          unlockedAt: DateTime.now(),
          xpReward: 50,
        );
  }

  List<AdoptionHistoryItem> _generateAdoptionHistoryFromFirebase(
      UserModel user) {
    // Converter petIds em histórico de adoção
    return user.petIds
        .map((petId) => _createAdoptionHistoryFromPetId(petId))
        .toList();
  }

  AdoptionHistoryItem _createAdoptionHistoryFromPetId(String petId) {
    // Na implementação real, buscaria dados do pet no Firebase
    final pets = [
      MockPet(name: 'Luna', type: 'Gato', age: '2 anos', photo: '🐱'),
      MockPet(name: 'Max', type: 'Cachorro', age: '3 anos', photo: '🐕'),
      MockPet(name: 'Bella', type: 'Coelho', age: '1 ano', photo: '🐰'),
    ];

    final pet = pets[petId.hashCode % pets.length];

    return AdoptionHistoryItem(
      pet: pet,
      coGuardianName: 'Guardião Colaborativo',
      adoptedAt: DateTime.now().subtract(Duration(days: petId.hashCode % 30)),
      daysActive: petId.hashCode % 30,
      isCurrentlyActive: petId.hashCode % 2 == 0,
      xpEarned: (petId.hashCode % 10 + 1) * 50,
    );
  }

  int _calculateRankingPosition(UserModel user) {
    // Calcular posição baseada no XP total
    // Na implementação real, consultaria outros usuários
    final basePosition = (user.totalXP / 1000).floor() + 1;
    return basePosition.clamp(1, 100);
  }

  List<RankingUser> _generateRanking() {
    // Por enquanto, gerar ranking mock
    // Na implementação real, consultaria Firestore com orderBy totalXP
    return [
      const RankingUser(
        codename: 'Mestre Supremo',
        level: 50,
        totalXP: 125000,
        colorTheme: 0xFFFFD700,
        position: 1,
      ),
      const RankingUser(
        codename: 'Anjo Celestial',
        level: 42,
        totalXP: 98500,
        colorTheme: 0xFFC0C0C0,
        position: 2,
      ),
      // ... mais usuários
    ];
  }

  void refreshProfile() {
    state = state.copyWith(isLoading: true);
    // Recarregar do Firebase
    // _loadProfile(currentUser);
  }
}

class UserProfile {
  final String codename;
  final int level;
  final int currentXP;
  final int xpToNextLevel;
  final int colorTheme;
  final int totalPetsAdopted;
  final int activePets;
  final double successRate;
  final int currentStreak;
  final int longestStreak;
  final int daysActive;
  final int totalXPEarned;
  final List<Achievement> achievements;
  final List<AdoptionHistoryItem> adoptionHistory;
  final int rankingPosition;
  final DateTime joinedDate;

  const UserProfile({
    required this.codename,
    required this.level,
    required this.currentXP,
    required this.xpToNextLevel,
    required this.colorTheme,
    required this.totalPetsAdopted,
    required this.activePets,
    required this.successRate,
    required this.currentStreak,
    required this.longestStreak,
    required this.daysActive,
    required this.totalXPEarned,
    required this.achievements,
    required this.adoptionHistory,
    required this.rankingPosition,
    required this.joinedDate,
  });

  // Opcional: método para facilitar debug ou logs
  @override
  String toString() {
    return 'UserProfile(codename: $codename, level: $level, currentXP: $currentXP, '
        'xpToNextLevel: $xpToNextLevel, colorTheme: $colorTheme, '
        'totalPetsAdopted: $totalPetsAdopted, activePets: $activePets, '
        'successRate: $successRate, currentStreak: $currentStreak, '
        'longestStreak: $longestStreak, daysActive: $daysActive, '
        'totalXPEarned: $totalXPEarned, achievements: $achievements, '
        'adoptionHistory: $adoptionHistory, rankingPosition: $rankingPosition, '
        'joinedDate: $joinedDate)';
  }
}

class AdoptionRecord {
  final String petId;
  final DateTime adoptionDate;

  AdoptionRecord({
    required this.petId,
    required this.adoptionDate,
  });
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int rarity; // Ex: 1 = Comum, 2 = Raro, 3 = Épico, etc.
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int xpReward;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.rarity,
    required this.isUnlocked,
    this.unlockedAt,
    required this.xpReward,
  });

  @override
  String toString() {
    return 'Achievement(id: $id, title: $title, description: $description, '
        'emoji: $emoji, rarity: $rarity, isUnlocked: $isUnlocked, '
        'unlockedAt: $unlockedAt, xpReward: $xpReward)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Achievement &&
          other.id == id &&
          other.title == title &&
          other.description == description &&
          other.emoji == emoji &&
          other.rarity == rarity &&
          other.isUnlocked == isUnlocked &&
          other.unlockedAt == unlockedAt &&
          other.xpReward == xpReward;

  @override
  int get hashCode => Object.hash(
        id,
        title,
        description,
        emoji,
        rarity,
        isUnlocked,
        unlockedAt,
        xpReward,
      );

  // Opcional: para salvar/carregar de JSON (Firebase, SharedPreferences, etc.)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'emoji': emoji,
      'rarity': rarity,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'xpReward': xpReward,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      emoji: json['emoji'],
      rarity: json['rarity'],
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
      xpReward: json['xpReward'],
    );
  }
}

class AdoptionHistoryItem {
  final MockPet pet; // Pode ser substituído por um objeto Pet, se existir
  final String coGuardianName;
  final DateTime adoptedAt;
  final int daysActive;
  final bool isCurrentlyActive;
  final int xpEarned;

  const AdoptionHistoryItem({
    required this.pet,
    required this.coGuardianName,
    required this.adoptedAt,
    required this.daysActive,
    required this.isCurrentlyActive,
    required this.xpEarned,
  });

  @override
  String toString() {
    return 'AdoptionHistoryItem(pet: $pet, coGuardianName: $coGuardianName, '
        'adoptedAt: $adoptedAt, daysActive: $daysActive, '
        'isCurrentlyActive: $isCurrentlyActive, xpEarned: $xpEarned)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdoptionHistoryItem &&
          other.pet == pet &&
          other.coGuardianName == coGuardianName &&
          other.adoptedAt == adoptedAt &&
          other.daysActive == daysActive &&
          other.isCurrentlyActive == isCurrentlyActive &&
          other.xpEarned == xpEarned;

  @override
  int get hashCode => Object.hash(
        pet,
        coGuardianName,
        adoptedAt,
        daysActive,
        isCurrentlyActive,
        xpEarned,
      );

  // Opcional: Serialização para JSON (útil para Firestore, Hive, etc.)
  Map<String, dynamic> toJson() {
    return {
      'pet': pet,
      'coGuardianName': coGuardianName,
      'adoptedAt': adoptedAt.toIso8601String(),
      'daysActive': daysActive,
      'isCurrentlyActive': isCurrentlyActive,
      'xpEarned': xpEarned,
    };
  }

  factory AdoptionHistoryItem.fromJson(Map<String, dynamic> json) {
    return AdoptionHistoryItem(
      pet: json['pet'],
      coGuardianName: json['coGuardianName'],
      adoptedAt: DateTime.parse(json['adoptedAt']),
      daysActive: json['daysActive'],
      isCurrentlyActive: json['isCurrentlyActive'] ?? false,
      xpEarned: json['xpEarned'],
    );
  }
}
