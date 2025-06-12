#!/bin/bash
# ⚡ SCRIPT DE CORREÇÃO RÁPIDA - PetCare Flutter
# Resolve todos os erros copyWith de uma vez

echo "🔧 INICIANDO CORREÇÃO AUTOMÁTICA DOS MODELOS..."

# Verificar se estamos no diretório correto
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Execute este script na raiz do projeto Flutter!"
    exit 1
fi

# Criar diretório de modelos se não existir
mkdir -p lib/models

echo "📝 Criando UserModel corrigido..."
cat > lib/models/user_model.dart << 'EOF'
// lib/models/user_model.dart - UserModel
class UserModel {
  final String id, username, avatar, email;
  final int level, xp, coins, gems;
  final DateTime createdAt;
  final List<String> ownedPetIds;
  final Map<String, dynamic> aiConfig;

  UserModel({
    required this.id, required this.username, required this.avatar, required this.email,
    required this.level, required this.xp, required this.coins, required this.gems,
    required this.createdAt, required this.ownedPetIds, required this.aiConfig,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'username': username, 'avatar': avatar, 'email': email,
    'level': level, 'xp': xp, 'coins': coins, 'gems': gems,
    'createdAt': createdAt.millisecondsSinceEpoch, 'ownedPetIds': ownedPetIds, 'aiConfig': aiConfig,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] ?? '', username: json['username'] ?? '', avatar: json['avatar'] ?? '', email: json['email'] ?? '',
    level: json['level'] ?? 1, xp: json['xp'] ?? 0, coins: json['coins'] ?? 200, gems: json['gems'] ?? 20,
    createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? DateTime.now().millisecondsSinceEpoch),
    ownedPetIds: List<String>.from(json['ownedPetIds'] ?? []),
    aiConfig: Map<String, dynamic>.from(json['aiConfig'] ?? {}),
  );

  UserModel copyWith({
    String? id, String? username, String? avatar, String? email,
    int? level, int? xp, int? coins, int? gems, DateTime? createdAt,
    List<String>? ownedPetIds, Map<String, dynamic>? aiConfig,
  }) {
    return UserModel(
      id: id ?? this.id, username: username ?? this.username, avatar: avatar ?? this.avatar, email: email ?? this.email,
      level: level ?? this.level, xp: xp ?? this.xp, coins: coins ?? this.coins, gems: gems ?? this.gems,
      createdAt: createdAt ?? this.createdAt, ownedPetIds: ownedPetIds ?? this.ownedPetIds, aiConfig: aiConfig ?? this.aiConfig,
    );
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is UserModel && runtimeType == other.runtimeType && id == other.id;
  @override
  int get hashCode => id.hashCode;
}
EOF

echo "📝 Criando ItemModel corrigido..."
cat > lib/models/item_model.dart << 'EOF'
// lib/models/item_model.dart - ItemModel
class ItemModel {
  final int id, cost;
  final String name, emoji, type, effect, category;

  ItemModel({required this.id, required this.name, required this.emoji, required this.cost, required this.type, required this.effect, required this.category});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'emoji': emoji, 'cost': cost, 'type': type, 'effect': effect, 'category': category};

  factory ItemModel.fromJson(Map<String, dynamic> json) => ItemModel(id: json['id'] ?? 0, name: json['name'] ?? '', emoji: json['emoji'] ?? '', cost: json['cost'] ?? 0, type: json['type'] ?? '', effect: json['effect'] ?? '', category: json['category'] ?? '');

  ItemModel copyWith({int? id, String? name, String? emoji, int? cost, String? type, String? effect, String? category}) {
    return ItemModel(id: id ?? this.id, name: name ?? this.name, emoji: emoji ?? this.emoji, cost: cost ?? this.cost, type: type ?? this.type, effect: effect ?? this.effect, category: category ?? this.category);
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is ItemModel && runtimeType == other.runtimeType && id == other.id;
  @override
  int get hashCode => id.hashCode;
}
EOF

echo "📝 Criando MissionModel corrigido..."
cat > lib/models/mission_model.dart << 'EOF'
// lib/models/mission_model.dart - MissionModel
class MissionModel {
  final int id, reward, progress, max;
  final String title, desc;

  MissionModel({required this.id, required this.title, required this.desc, required this.reward, required this.progress, required this.max});

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'desc': desc, 'reward': reward, 'progress': progress, 'max': max};

  factory MissionModel.fromJson(Map<String, dynamic> json) => MissionModel(id: json['id'] ?? 0, title: json['title'] ?? '', desc: json['desc'] ?? '', reward: json['reward'] ?? 0, progress: json['progress'] ?? 0, max: json['max'] ?? 1);

  MissionModel copyWith({int? id, String? title, String? desc, int? reward, int? progress, int? max}) {
    return MissionModel(id: id ?? this.id, title: title ?? this.title, desc: desc ?? this.desc, reward: reward ?? this.reward, progress: progress ?? this.progress, max: max ?? this.max);
  }

  bool get isCompleted => progress >= max;
  @override
  bool operator ==(Object other) => identical(this, other) || other is MissionModel && runtimeType == other.runtimeType && id == other.id;
  @override
  int get hashCode => id.hashCode;
}
EOF

echo "📝 Criando FeedPostModel corrigido..."
cat > lib/models/feed_post_model.dart << 'EOF'
// lib/models/feed_post_model.dart - FeedPostModel
class FeedPostModel {
  final String id, type, content, userId;
  final String? petId;
  final DateTime timestamp;

  FeedPostModel({required this.id, required this.type, required this.content, required this.userId, this.petId, required this.timestamp});

  Map<String, dynamic> toJson() => {'id': id, 'type': type, 'content': content, 'userId': userId, 'petId': petId, 'timestamp': timestamp.millisecondsSinceEpoch};

  factory FeedPostModel.fromJson(Map<String, dynamic> json) => FeedPostModel(id: json['id'] ?? '', type: json['type'] ?? '', content: json['content'] ?? '', userId: json['userId'] ?? '', petId: json['petId'], timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch));

  FeedPostModel copyWith({String? id, String? type, String? content, String? userId, String? petId, DateTime? timestamp}) {
    return FeedPostModel(id: id ?? this.id, type: type ?? this.type, content: content ?? this.content, userId: userId ?? this.userId, petId: petId ?? this.petId, timestamp: timestamp ?? this.timestamp);
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is FeedPostModel && runtimeType == other.runtimeType && id == other.id;
  @override
  int get hashCode => id.hashCode;
}
EOF

echo "📝 Atualizando ChatMessageModel..."
cat > lib/models/chat_message_model.dart << 'EOF'
// lib/models/chat_message_model.dart - ChatMessageModel
class ChatMessageModel {
  final String id, petId, senderId, senderAvatar, message;
  final DateTime timestamp;

  ChatMessageModel({required this.id, required this.petId, required this.senderId, required this.senderAvatar, required this.message, required this.timestamp});

  Map<String, dynamic> toJson() => {'id': id, 'petId': petId, 'senderId': senderId, 'senderAvatar': senderAvatar, 'message': message, 'timestamp': timestamp.millisecondsSinceEpoch};

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) => ChatMessageModel(id: json['id'] ?? '', petId: json['petId'] ?? '', senderId: json['senderId'] ?? '', senderAvatar: json['senderAvatar'] ?? '', message: json['message'] ?? '', timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch));

  ChatMessageModel copyWith({String? id, String? petId, String? senderId, String? senderAvatar, String? message, DateTime? timestamp}) {
    return ChatMessageModel(id: id ?? this.id, petId: petId ?? this.petId, senderId: senderId ?? this.senderId, senderAvatar: senderAvatar ?? this.senderAvatar, message: message ?? this.message, timestamp: timestamp ?? this.timestamp);
  }
}
EOF

echo "✅ Todos os modelos corrigidos!"
echo ""
echo "🧹 Limpando projeto..."
flutter clean

echo "📦 Instalando dependências..."
flutter pub get

echo ""
echo "🎉 CORREÇÃO CONCLUÍDA!"
echo ""
echo "📋 PRÓXIMOS PASSOS:"
echo "1. Execute: flutter run"
echo "2. Se ainda houver erros, verifique os imports nos providers"
echo "3. Todos os métodos copyWith agora estão funcionais!"
echo ""
echo "✅ Projeto pronto para executar!"