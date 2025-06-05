import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/currency_provider.dart';
import '../providers/theme_provider.dart';

/// Tipos de posts no feed
enum PostType {
  adoption('Adoção', Icons.favorite, Colors.red),
  tip('Dica', Icons.lightbulb, Colors.amber),
  community('Comunidade', Icons.people, Colors.blue),
  news('Notícias', Icons.article, Colors.green),
  achievement('Conquista', Icons.emoji_events, Colors.purple);

  const PostType(this.displayName, this.icon, this.color);
  final String displayName;
  final IconData icon;
  final Color color;
}

/// Modelo de post do feed
class FeedPost {
  final String id;
  final String title;
  final String content;
  final String author;
  final String timeAgo;
  final PostType type;
  final int likes;
  final int comments;
  final String? imageUrl;
  final bool isLiked;

  const FeedPost({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.timeAgo,
    required this.type,
    this.likes = 0,
    this.comments = 0,
    this.imageUrl,
    this.isLiked = false,
  });

  FeedPost copyWith({
    bool? isLiked,
    int? likes,
  }) {
    return FeedPost(
      id: id,
      title: title,
      content: content,
      author: author,
      timeAgo: timeAgo,
      type: type,
      likes: likes ?? this.likes,
      comments: comments,
      imageUrl: imageUrl,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

/// Tela do feed social
class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  PostType? _selectedFilter;
  final ScrollController _scrollController = ScrollController();
  List<FeedPost> _posts = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadPosts();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
  }

  void _loadPosts() {
    // Simulação de posts do feed
    _posts = [
      const FeedPost(
        id: '1',
        title: 'Max encontrou uma família!',
        content:
            'Nosso querido Max foi adotado hoje por uma família amorosa. Desejamos muito amor e felicidade para eles! 🐕💕',
        author: 'Pet Adote',
        timeAgo: '2h',
        type: PostType.adoption,
        likes: 156,
        comments: 23,
        imageUrl: 'https://placehold.co/400x200/4CAF50/FFFFFF?text=🐕',
      ),
      const FeedPost(
        id: '2',
        title: 'Dica: Como manter seu pet hidratado',
        content:
            'Sempre deixe água fresca disponível para seu pet. Troque a água diariamente e limpe a vasilha regularmente.',
        author: 'Dr. Veterinário',
        timeAgo: '4h',
        type: PostType.tip,
        likes: 89,
        comments: 12,
      ),
      const FeedPost(
        id: '3',
        title: 'Nova funcionalidade: Jogos!',
        content:
            'Agora você pode ganhar coins jogando mini-games divertidos no app. Experimente o Coin Clicker!',
        author: 'Equipe Pet Adote',
        timeAgo: '1d',
        type: PostType.news,
        likes: 234,
        comments: 45,
      ),
      const FeedPost(
        id: '4',
        title: 'Usuário @PetLover123 desbloqueou conquista!',
        content:
            'Parabéns! Você alcançou o nível 10 e desbloqueou a conquista "Pet Master". Continue cuidando bem dos seus pets! 🏆',
        author: 'Sistema',
        timeAgo: '2d',
        type: PostType.achievement,
        likes: 67,
        comments: 8,
      ),
      const FeedPost(
        id: '5',
        title: 'Evento da Comunidade: Adoção Especial',
        content:
            'Este fim de semana teremos um evento especial de adoção com pets únicos gerados por IA. Não percam!',
        author: 'Comunidade Pet Adote',
        timeAgo: '3d',
        type: PostType.community,
        likes: 312,
        comments: 78,
        imageUrl: 'https://placehold.co/400x200/9C27B0/FFFFFF?text=🎉',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isLightTheme = ref.watch(isLightThemeProvider);
    final filteredPosts = _getFilteredPosts();

    return Scaffold(
      backgroundColor: isLightTheme ? Colors.yellow[50] : Colors.yellow[900],
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: SafeArea(
              child: Column(
                children: [
                  // Header do feed
                  _buildFeedHeader(isLightTheme),

                  // Filtros
                  _buildFilters(isLightTheme),

                  // Lista de posts
                  Expanded(
                    child: _buildPostsList(filteredPosts, isLightTheme),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(isLightTheme),
    );
  }

  /// Constrói o cabeçalho do feed
  Widget _buildFeedHeader(bool isLightTheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLightTheme
              ? [Colors.yellow[400]!, Colors.orange[500]!]
              : [Colors.yellow[800]!, Colors.orange[900]!],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.article,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Feed da Comunidade',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Acompanhe as novidades e interaja',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _refreshFeed(),
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
              size: 24,
            ),
            tooltip: 'Atualizar feed',
          ),
        ],
      ),
    );
  }

  /// Constrói os filtros
  Widget _buildFilters(bool isLightTheme) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip(
            'Todos',
            null,
            Icons.all_inclusive,
            Colors.grey,
            isLightTheme,
          ),
          const SizedBox(width: 8),
          ...PostType.values.map((type) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildFilterChip(
                  type.displayName,
                  type,
                  type.icon,
                  type.color,
                  isLightTheme,
                ),
              )),
        ],
      ),
    );
  }

  /// Constrói um chip de filtro
  Widget _buildFilterChip(
    String label,
    PostType? type,
    IconData icon,
    Color color,
    bool isLightTheme,
  ) {
    final isSelected = _selectedFilter == type;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : (isLightTheme ? Colors.white : Colors.grey[800]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : (isLightTheme ? color : Colors.grey[400]),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isLightTheme ? color : Colors.grey[400]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói a lista de posts
  Widget _buildPostsList(List<FeedPost> posts, bool isLightTheme) {
    return RefreshIndicator(
      onRefresh: _refreshFeed,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildPostCard(post, isLightTheme),
          );
        },
      ),
    );
  }

  /// Constrói um card de post
  Widget _buildPostCard(FeedPost post, bool isLightTheme) {
    return Container(
      decoration: BoxDecoration(
        color: isLightTheme ? Colors.white : Colors.grey[800],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do post
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: post.type.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    post.type.icon,
                    color: post.type.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isLightTheme
                              ? Colors.grey[800]
                              : Colors.grey[100],
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: post.type.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              post.type.displayName,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: post.type.color,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            post.timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: isLightTheme
                                  ? Colors.grey[500]
                                  : Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showPostOptions(post),
                  icon: Icon(
                    Icons.more_vert,
                    color: isLightTheme ? Colors.grey[600] : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),

          // Conteúdo do post
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isLightTheme ? Colors.grey[800] : Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  post.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: isLightTheme ? Colors.grey[600] : Colors.grey[300],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Imagem (se existir)
          if (post.imageUrl != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 200,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image, size: 48, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],

          // Ações do post
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildActionButton(
                  post.isLiked ? Icons.favorite : Icons.favorite_border,
                  post.likes.toString(),
                  post.isLiked ? Colors.red : Colors.grey,
                  () => _toggleLike(post),
                ),
                const SizedBox(width: 24),
                _buildActionButton(
                  Icons.comment_outlined,
                  post.comments.toString(),
                  Colors.grey,
                  () => _showComments(post),
                ),
                const SizedBox(width: 24),
                _buildActionButton(
                  Icons.share_outlined,
                  'Compartilhar',
                  Colors.grey,
                  () => _sharePost(post),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _savePost(post),
                  icon: const Icon(Icons.bookmark_border),
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói um botão de ação
  Widget _buildActionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói o botão flutuante
  Widget _buildFloatingActionButton(bool isLightTheme) {
    return FloatingActionButton(
      onPressed: () => _createPost(),
      backgroundColor: Colors.orange[500],
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  /// Filtra os posts baseado no filtro selecionado
  List<FeedPost> _getFilteredPosts() {
    if (_selectedFilter == null) return _posts;
    return _posts.where((post) => post.type == _selectedFilter).toList();
  }

  /// Alterna o like de um post
  void _toggleLike(FeedPost post) {
    setState(() {
      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        _posts[index] = post.copyWith(
          isLiked: !post.isLiked,
          likes: post.isLiked ? post.likes - 1 : post.likes + 1,
        );
      }
    });

    // Ganhar XP por interação
    if (!post.isLiked) {
      ref.read(userCurrencyProvider.notifier).addXp(5);
    }
  }

  /// Atualiza o feed
  Future<void> _refreshFeed() async {
    await Future.delayed(const Duration(seconds: 1));
    // Aqui você faria uma requisição real para atualizar os posts
    setState(() {});
  }

  /// Mostra opções do post
  void _showPostOptions(FeedPost post) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('Reportar'),
              onTap: () {
                Navigator.pop(context);
                _reportPost(post);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Bloquear usuário'),
              onTap: () {
                Navigator.pop(context);
                _blockUser(post.author);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Mostra comentários
  void _showComments(FeedPost post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Comentários'),
        content:
            const Text('Funcionalidade de comentários em desenvolvimento.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  /// Compartilha um post
  void _sharePost(FeedPost post) {
    // Implementar compartilhamento
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post compartilhado!')),
    );
  }

  /// Salva um post
  void _savePost(FeedPost post) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post salvo!')),
    );
  }

  /// Cria um novo post
  void _createPost() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Post'),
        content: const Text(
            'Funcionalidade de criação de posts em desenvolvimento.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  /// Reporta um post
  void _reportPost(FeedPost post) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post reportado!')),
    );
  }

  /// Bloqueia um usuário
  void _blockUser(String username) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Usuário $username bloqueado!')),
    );
  }
}
