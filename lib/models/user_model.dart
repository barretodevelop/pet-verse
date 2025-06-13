// lib/models/user_model.dart - ENHANCED com configuração de IA
class UserModel {
  final String id, username, avatar, email;
  final int level, xp, coins, gems, purchasedSlotsCount;
  final DateTime createdAt;
  final List<String> ownedPetIds;
  final Map<String, dynamic> aiConfig; // ✅ JÁ EXISTE - melhorar uso

  UserModel({
    required this.id,
    required this.username,
    required this.avatar,
    required this.email,
    required this.level,
    required this.xp,
    required this.coins,
    required this.gems,
    required this.createdAt,
    required this.ownedPetIds,
    required this.aiConfig,
    this.purchasedSlotsCount = 2,
  });

  // ✅ HELPER METHODS para aiConfig

  /// Obter chave da Stability AI
  String? get stabilityApiKey => aiConfig['stabilityApiKey'] as String?;

  /// Obter chave do OpenAI
  String? get openaiApiKey => aiConfig['openaiApiKey'] as String?;

  /// Verificar se IA está habilitada
  bool get isAIEnabled => aiConfig['enabled'] as bool? ?? false;

  /// Obter URL da API personalizada (se houver)
  String? get customApiUrl => aiConfig['apiUrl'] as String?;

  /// Verificar se tem configuração de IA válida
  bool get hasValidAIConfig {
    return (stabilityApiKey?.isNotEmpty == true) ||
        (openaiApiKey?.isNotEmpty == true) ||
        (customApiUrl?.isNotEmpty == true);
  }

  /// ✅ MÉTODO PARA CRIAR aiConfig PADRÃO
  static Map<String, dynamic> get defaultAIConfig => {
        'enabled': false,
        'stabilityApiKey': '',
        'openaiApiKey': '',
        'apiUrl': '',
        'lastConfigUpdate': DateTime.now().millisecondsSinceEpoch,
        'preferences': {
          'style': 'digital-art',
          'quality': 'standard',
          'steps': 30,
          'cfg_scale': 7,
        }
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'avatar': avatar,
        'email': email,
        'level': level,
        'xp': xp,
        'coins': coins,
        'gems': gems,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'ownedPetIds': ownedPetIds,
        'aiConfig': aiConfig,
        'purchasedSlotsCount': purchasedSlotsCount,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        username: json['username'],
        avatar: json['avatar'],
        email: json['email'],
        level: json['level'],
        xp: json['xp'],
        coins: json['coins'],
        gems: json['gems'],
        createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
        ownedPetIds: List<String>.from(json['ownedPetIds'] ?? []),
        // ✅ ENHANCED: Usar defaultAIConfig se não existir
        aiConfig: json['aiConfig'] as Map<String, dynamic>? ?? defaultAIConfig,
        purchasedSlotsCount: json['purchasedSlotsCount'] as int? ?? 2,
      );

  UserModel copyWith({
    String? id,
    String? username,
    String? avatar,
    String? email,
    int? level,
    int? xp,
    int? coins,
    int? gems,
    DateTime? createdAt,
    List<String>? ownedPetIds,
    Map<String, dynamic>? aiConfig,
    int? purchasedSlotsCount,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      email: email ?? this.email,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      createdAt: createdAt ?? this.createdAt,
      ownedPetIds: ownedPetIds ?? this.ownedPetIds,
      aiConfig: aiConfig ?? this.aiConfig,
      purchasedSlotsCount: purchasedSlotsCount ?? this.purchasedSlotsCount,
    );
  }

  // ✅ MÉTODO CONVENIENTE para atualizar só a configuração de IA
  UserModel copyWithAIConfig({
    String? stabilityApiKey,
    String? openaiApiKey,
    String? apiUrl,
    bool? enabled,
    Map<String, dynamic>? preferences,
  }) {
    final newAIConfig = Map<String, dynamic>.from(aiConfig);

    if (stabilityApiKey != null)
      newAIConfig['stabilityApiKey'] = stabilityApiKey;
    if (openaiApiKey != null) newAIConfig['openaiApiKey'] = openaiApiKey;
    if (apiUrl != null) newAIConfig['apiUrl'] = apiUrl;
    if (enabled != null) newAIConfig['enabled'] = enabled;
    if (preferences != null) newAIConfig['preferences'] = preferences;

    newAIConfig['lastConfigUpdate'] = DateTime.now().millisecondsSinceEpoch;

    return copyWith(aiConfig: newAIConfig);
  }
}
