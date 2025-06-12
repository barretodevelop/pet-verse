// AppRouter
// lib/config/app_router.dart - AppRouter
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/screens/ai_generation_screen.dart';
import 'package:petverse/screens/home_screen.dart';
import 'package:petverse/screens/login_screen.dart';
import 'package:petverse/screens/splash_screen.dart';
import 'package:petverse/screens/user_profile_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics:
        true, // ✅ CORREÇÃO 1: Habilitar debug para diagnosticar problemas
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      // ✅ CORREÇÃO 2: Rota IA como rota independente (não subrota)
      GoRoute(
        path: '/ai-generation',
        name: 'ai-generation',
        builder: (context, state) => const AIGenerationScreen(),
      ),
      // ✅ CORREÇÃO 3: Rota perfil como rota independente
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const UserProfileScreen(),
      ),
    ],
    // ✅ CORREÇÃO 4: Error handler melhorado
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFF1F2937),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFEF4444)),
            const SizedBox(height: 16),
            const Text(
              'Erro de Navegação',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${state.error}',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.home),
              label: const Text('Voltar ao Início'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => print('Rota atual: ${state.uri.toString()}'),
              icon: const Icon(Icons.info_outline, color: Colors.white70),
              label: const Text(
                'Debug Info',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    ),
    // ✅ CORREÇÃO 5: Redirect logic para autenticação
    redirect: (context, state) {
      // Permitir todas as rotas por enquanto para facilitar debug
      print('✅ Navegando para: ${state.uri.toString()}');
      return null;
    },
  );

  // ✅ CORREÇÃO 6: Métodos auxiliares para navegação
  static void navigateToAIGeneration(BuildContext context) {
    try {
      context.push('/ai-generation');
      print('✅ Navegação IA: sucesso');
    } catch (e) {
      print('❌ Navegação IA: erro - $e');
    }
  }

  static void navigateToProfile(BuildContext context) {
    try {
      context.push('/profile');
      print('✅ Navegação Perfil: sucesso');
    } catch (e) {
      print('❌ Navegação Perfil: erro - $e');
    }
  }

  static void navigateToHome(BuildContext context) {
    try {
      context.go('/home');
      print('✅ Navegação Home: sucesso');
    } catch (e) {
      print('❌ Navegação Home: erro - $e');
    }
  }
}
