// lib/features/splash/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/features/auth/providers/auth_providers.dart';
import 'package:petverse/shared/providers/global_providers.dart';
import 'package:petverse/shared/providers/initial_loading_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (firebaseUser) {
        if (firebaseUser == null) {
          // Não autenticado
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go('/login');
          });
          return const Scaffold(
              body: Center(
                  child: Text(
                      "Redirecionando para login..."))); // Pode ser um loader também
        } else {
          // Autenticado, carrega dados do jogo
          // NOTA: Idealmente, gameDataLoadingProvider usaria o firebaseUser.uid para carregar dados específicos do usuário.
          // Por agora, ele carrega os dados globais do dispositivo.
          final gameDataLoad = ref.watch(gameDataLoadingProvider);
          return gameDataLoad.when(
            data: (_) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  final activePet =
                      ref.read(activePetProvider); // Jogo carregado
                  context.go(activePet != null ? '/main' : '/select');
                }
              });
              return const Scaffold(
                  body: Center(child: Text("Carregando dados do jogo...")));
            },
            loading: () => const Scaffold(
                body: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("Usuário autenticado, carregando jogo...")
                ]))),
            error: (err, stack) => Scaffold(
                body: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                  Text('Erro ao carregar dados do jogo: $err',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 10),
                  ElevatedButton(
                      onPressed: () => ref.refresh(gameDataLoadingProvider),
                      child: const Text("Tentar Novamente"))
                ]))),
          );
        }
      },
      loading: () => const Scaffold(
          body: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text("Verificando autenticação...")
          ]))),
      error: (err, stack) =>
          Scaffold(body: Center(child: Text('Erro de autenticação: $err'))),
    );
  }
}
