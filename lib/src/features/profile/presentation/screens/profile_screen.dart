import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/src/core/navigation/app_routes.dart';
import 'package:petverse/src/features/auth/data/repositories/auth_repository.dart';

class ProfileScreen extends ConsumerWidget {
  // Mudar para ConsumerWidget
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Adicionar WidgetRef ref
    final authRepository = ref.watch(authRepositoryProvider);
    final currentUser = authRepository.getCurrentUser(); // fb_auth.User?

    return Scaffold(
      // AppBar opcional, pode ser removido se a HomeScreen já tiver uma AppBar global
      // appBar: AppBar(
      //   title: const Text('Meu Perfil'),
      // ),
      body: currentUser == null
          ? const Center(child: Text('Usuário não encontrado.'))
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: currentUser.photoURL != null
                        ? CachedNetworkImageProvider(currentUser.photoURL!)
                        : null,
                    child: currentUser.photoURL == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    currentUser.displayName ?? 'Usuário PetVerse',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Center(
                  child: Text(
                    currentUser.email ?? 'E-mail não disponível',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 32),
                // TODO: Adicionar mais opções de perfil (ex: editar perfil, minhas solicitações)
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  onPressed: () async {
                    await authRepository.signOut();
                    // O GoRouter redirect deve lidar com a navegação para /login
                    // Mas podemos forçar para garantir, caso o refresh não seja imediato
                    if (context.mounted) {
                      context.go(AppRoutes.login);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError),
                ),
              ],
            ),
    );
  }
}
