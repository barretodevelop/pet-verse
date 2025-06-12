import 'package:flutter/material.dart'; // Para @immutable
import '../models/accessory.dart';
import '../models/pet.dart';
import '../models/shop_item.dart';
import '../models/mission.dart';
import '../models/app_notification.dart';
import '../models/feed_post.dart';
import '../models/chat_message.dart';
import '../models/particle.dart';
import '../models/adoption_request.dart';
import '../models/user.dart';
import '../models/ai_config.dart';
import '../data/mock_data.dart'; // Para MISSIONS default

// --- AppState: O estado completo da aplicação (imutável) ---
@immutable
class AppState {
  final bool isDark;
  final User? user;
  final List<Pet> pets;
  final List<Pet> deadPets;
  final List<Pet> returnedPets;
  final List<Pet> uniquePets;
  final List<AdoptionRequest> pendingAdoptions;
  final int activePetIndex;
  final int coins;
  final int gems;
  final List<ShopItem> inventory;
  final List<Mission> missions;
  final List<AppNotification> notifications;
  final List<FeedPost> feedPosts;
  final Map<String, List<ChatMessage>> chatMessages;
  final List<Particle> particles;
  final AIConfig aiConfig;

  const AppState({
    this.isDark = false,
    this.user,
    this.pets = const [],
    this.deadPets = const [],
    this.returnedPets = const [],
    this.uniquePets = const [],
    this.pendingAdoptions = const [],
    this.activePetIndex = 0,
    this.coins = 200,
    this.gems = 20,
    this.inventory = const [],
    required this.missions, // Inicialize com MISSIONS mockadas
    this.notifications = const [],
    this.feedPosts = const [],
    this.chatMessages = const {},
    this.particles = const [],
    required this.aiConfig, // Inicialize com AIConfig padrão
  });

  // Construtor factory para criar AppState de um JSON
  factory AppState.fromJson(Map<String, dynamic> json) {
    return AppState(
      isDark: json['isDark'] ?? false,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      pets: (json['pets'] as List<dynamic>?)
              ?.map((e) => Pet.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      deadPets: (json['deadPets'] as List<dynamic>?)
              ?.map((e) => Pet.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      returnedPets: (json['returnedPets'] as List<dynamic>?)
              ?.map((e) => Pet.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      uniquePets: (json['uniquePets'] as List<dynamic>?)
              ?.map((e) => Pet.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      pendingAdoptions: (json['pendingAdoptions'] as List<dynamic>?)
              ?.map((e) => AdoptionRequest.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      activePetIndex: json['activePetIndex'] ?? 0,
      coins: json['coins'] ?? 200,
      gems: json['gems'] ?? 20,
      inventory: (json['inventory'] as List<dynamic>?)
              ?.map((e) => ShopItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      missions: (json['missions'] as List<dynamic>?)
              ?.map((e) => Mission.fromJson(e as Map<String, dynamic>))
              .toList() ??
          List.from(MISSIONS), // Fallback para missões mockadas
      notifications: (json['notifications'] as List<dynamic>?)
              ?.map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      feedPosts: (json['feedPosts'] as List<dynamic>?)
              ?.map((e) => FeedPost.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      chatMessages: (json['chatMessages'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as List).map((e) => ChatMessage.fromJson(e)).toList()),
          ) ??
          const {},
      particles: (json['particles'] as List<dynamic>?)
              ?.map((e) => Particle.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      aiConfig: json['aiConfig'] != null ? AIConfig.fromJson(json['aiConfig']) : AIConfig(),
    );
  }

  // Converte AppState para um JSON
  Map<String, dynamic> toJson() {
    return {
      'isDark': isDark,
      'user': user?.toJson(),
      'pets': pets.map((e) => e.toJson()).toList(),
      'deadPets': deadPets.map((e) => e.toJson()).toList(),
      'returnedPets': returnedPets.map((e) => e.toJson()).toList(),
      'uniquePets': uniquePets.map((e) => e.toJson()).toList(),
      'pendingAdoptions': pendingAdoptions.map((e) => e.toJson()).toList(),
      'activePetIndex': activePetIndex,
      'coins': coins,
      'gems': gems,
      'inventory': inventory.map((e) => e.toJson()).toList(),
      'missions': missions.map((e) => e.toJson()).toList(),
      'notifications': notifications.map((e) => e.toJson()).toList(),
      'feedPosts': feedPosts.map((e) => e.toJson()).toList(),
      'chatMessages': chatMessages.map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList())),
      'particles': particles.map((e) => e.toJson()).toList(),
      'aiConfig': aiConfig.toJson(),
    };
  }

  // Método copyWith para criar novas instâncias de AppState (imutabilidade)
  AppState copyWith({
    bool? isDark,
    User? user,
    List<Pet>? pets,
    List<Pet>? deadPets,
    List<Pet>? returnedPets,
    List<Pet>? uniquePets,
    List<AdoptionRequest>? pendingAdoptions,
    int? activePetIndex,
    int? coins,
    int? gems,
    List<ShopItem>? inventory,
    List<Mission>? missions,
    List<AppNotification>? notifications,
    List<FeedPost>? feedPosts,
    Map<String, List<ChatMessage>>? chatMessages,
    List<Particle>? particles,
    AIConfig? aiConfig,
  }) {
    return AppState(
      isDark: isDark ?? this.isDark,
      user: user ?? this.user,
      pets: pets ?? this.pets,
      deadPets: deadPets ?? this.deadPets,
      returnedPets: returnedPets ?? this.returnedPets,
      uniquePets: uniquePets ?? this.uniquePets,
      pendingAdoptions: pendingAdoptions ?? this.pendingAdoptions,
      activePetIndex: activePetIndex ?? this.activePetIndex,
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      inventory: inventory ?? this.inventory,
      missions: missions ?? this.missions,
      notifications: notifications ?? this.notifications,
      feedPosts: feedPosts ?? this.feedPosts,
      chatMessages: chatMessages ?? this.chatMessages,
      particles: particles ?? this.particles,
      aiConfig: aiConfig ?? this.aiConfig,
    );
  }
}
