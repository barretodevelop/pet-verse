// FeedProvider

// lib/providers/feed_provider.dart - CORREÇÃO: Feed Posts + Debug
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/models/feed_post_model.dart';

final feedProvider = StateNotifierProvider<FeedNotifier, List<FeedPostModel>>(
    (ref) => FeedNotifier());

class FeedNotifier extends StateNotifier<List<FeedPostModel>> {
  FeedNotifier() : super([]) {
    print('✅ FeedProvider: Inicializado'); // Debug
  }

  void setFeedPosts(List<FeedPostModel> posts) {
    state = posts;
    print('✅ FeedProvider: ${state.length} posts definidos'); // Debug
  }

  void addFeedPost(FeedPostModel post) {
    state = [post, ...state.take(19).toList()];
    print('✅ FeedProvider: Post adicionado - ${post.content}'); // Debug
  }

  // ✅ CORREÇÃO: Método principal para adicionar posts
  void addPost(String type, String content, String userId, {String? petId}) {
    final post = FeedPostModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      content: content,
      userId: userId,
      petId: petId,
      timestamp: DateTime.now(),
    );
    addFeedPost(post);
    print('✅ Post criado: $type - $content'); // Debug
  }

  // ✅ CORREÇÃO: Métodos específicos para diferentes tipos de posts
  void addAdoptionPost(
      String username, String petName, String userId, String petId) {
    addPost(
      'adoption',
      '🎉 $username adotou $petName!',
      userId,
      petId: petId,
    );
  }

  void addCollaborationPost(
      String username, String petName, String userId, String petId) {
    addPost(
      'collaboration',
      '🤝 $username e um parceiro adotaram $petName!',
      userId,
      petId: petId,
    );
  }

  void addLevelUpPost(String petName, int level, String userId, String petId) {
    addPost(
      'level_up',
      '⭐ $petName alcançou nível $level!',
      userId,
      petId: petId,
    );
  }

  void addUniqueGenerationPost(
      String username, String petName, String userId, String petId) {
    addPost(
      'unique_generation',
      '🎨 $username gerou um pet único: $petName!',
      userId,
      petId: petId,
    );
  }

  void addDeathPost(
      String petName, String username, String userId, String petId) {
    addPost(
      'death',
      '😢 $petName faleceu por negligência. $username perdeu 50 XP',
      userId,
      petId: petId,
    );
  }

  void addReturnPost(
      String username, String petName, String userId, String petId) {
    addPost(
      'return',
      '🔄 $username devolveu $petName',
      userId,
      petId: petId,
    );
  }

  // ✅ CORREÇÃO: Método para limpar feed (útil para testes)
  void clearFeed() {
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
}
