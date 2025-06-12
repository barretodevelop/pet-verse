// FeedProvider

import 'dart:async'; // For StreamSubscription

// lib/providers/feed_provider.dart - CORREÇÃO: Feed Posts + Debug
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/models/feed_post_model.dart';
import 'package:petverse/models/user_model.dart'; // To get user avatar
import 'package:petverse/services/firestore_service.dart'; // For Firestore integration

final feedProvider =
    StateNotifierProvider<FeedNotifier, List<FeedPostModel>>((ref) {
  // Pass FirestoreService if you're using it as a provider, or instantiate directly
  return FeedNotifier(FirestoreService());
});

class FeedNotifier extends StateNotifier<List<FeedPostModel>> {
  final FirestoreService _firestoreService;
  StreamSubscription? _feedSubscription;

  FeedNotifier(this._firestoreService) : super([]) {
    _listenToFeedChanges(); // Listen to Firestore feed
    print('✅ FeedProvider: Initialized and listening to Firestore');
  }

  void _listenToFeedChanges() {
    _feedSubscription?.cancel();
    _feedSubscription = _firestoreService.getFeedPosts().listen((posts) {
      state = posts;
      print(
          '✅ FeedProvider: Feed updated from Firestore with ${state.length} posts.');
    }, onError: (error) {
      print('❌ FeedProvider: Error listening to feed changes: $error');
      // Optionally, handle the error, e.g., by setting state to an empty list or showing an error state
    });
  }

  void setFeedPosts(List<FeedPostModel> posts) {
    state = posts;
    print('✅ FeedProvider: ${state.length} posts definidos'); // Debug
  }

  // This method now primarily adds to Firestore; the stream will update the local state.
  Future<void> _addFeedPostToFirestore(FeedPostModel post) async {
    try {
      await _firestoreService.addFeedPost(post);
      print('✅ FeedProvider: Post sent to Firestore - ${post.content}');
    } catch (e) {
      print(
          '❌ FeedProvider: Failed to add post to Firestore - ${post.content}: $e');
      rethrow;
    }
    // No direct state manipulation here, listener will update it.
    // If immediate UI update is desired before Firestore confirmation, you could add it here,
    // but be mindful of potential inconsistencies if Firestore write fails.
  }

  // ✅ CORREÇÃO: Método principal para adicionar posts
  Future<void> addPost(String type, String content, UserModel user,
      {String? petId}) async {
    final post = FeedPostModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      content: content,
      userId: user.id,
      // username: user.username, // Store username
      // userAvatar: user.avatar,  // Store avatar
      petId: petId,
      timestamp: DateTime.now(),
    );
    await _addFeedPostToFirestore(post);
    print('✅ Post criado: $type - $content'); // Debug
  }

  // ✅ CORREÇÃO: Métodos específicos para diferentes tipos de posts
  void addAdoptionPost(UserModel user, String petName, String petId,
      {bool isUnique = false}) {
    final contentMessage = isUnique
        ? '🎨 ${user.username} gerou e adotou um pet único: $petName!'
        : '🎉 ${user.username} adotou $petName!';
    addPost(
      // Pass the whole user object
      'adoption',
      contentMessage,
      user,
      petId: petId,
    );
  }

  void addCollaborationPost(
      String username, String petName, String userId, String petId) {
    addPost(
      // Consider passing UserModel here too if you need avatar/username
      'collaboration',
      '🤝 $username e um parceiro adotaram $petName!',
      UserModel(
          id: userId,
          username: username,
          avatar: '🧑',
          email: '',
          level: 1,
          xp: 0,
          coins: 0,
          gems: 0,
          createdAt: DateTime.now(),
          ownedPetIds: [],
          aiConfig: {},
          purchasedSlotsCount: 2), // Placeholder UserModel
      petId: petId,
    );
  }

  void addLevelUpPost(UserModel user, String petName, int level, String petId) {
    addPost(
      'level_up',
      '⭐ $petName alcançou nível $level!',
      user,
      petId: petId,
    );
  }

  void addDeathPost(UserModel user, String petName, String petId) {
    addPost(
      'death',
      '😢 $petName faleceu por negligência. ${user.username} perdeu 50 XP',
      user,
      petId: petId,
    );
  }

  void addReturnPost(UserModel user, String petName, String petId) {
    addPost(
      'return',
      '🔄 ${user.username} devolveu $petName',
      user,
      petId: petId,
    );
  }

  // ✅ CORREÇÃO: Método para limpar feed (útil para testes)
  Future<void> clearFeed() async {
    // This would typically involve deleting posts from Firestore, which can be complex.
    // For local state reset during testing:
    state = [];
    print('✅ FeedProvider: Feed limpo'); // Debug
  }

  // ✅ CORREÇÃO: Método para obter posts por tipo
  List<FeedPostModel> getPostsByType(String type) {
    return state.where((post) => post.type == type).toList();
  }

  // ✅ CORREÇÃO: Método para obter posts de um usuário específico
  List<FeedPostModel> getPostsByUser(String userId) {
    return state.where((post) => post.userId == userId).toList();
  }

  @override
  void dispose() {
    _feedSubscription?.cancel();
    super.dispose();
  }
}
