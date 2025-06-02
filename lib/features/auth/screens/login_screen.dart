// lib/features/auth/screens/login_screen.dart (NOVO)
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/core/constants/app_colors.dart';
import 'package:petverse/features/auth/providers/auth_providers.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Se o usuário já estiver autenticado e de alguma forma chegar aqui, redireciona
    final authState = ref.watch(authStateChangesProvider);
    if (authState.asData?.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted)
          context.go('/'); // Vai para splash que redireciona corretamente
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Bem-vindo ao\nMeu Pet Virtual!',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: -0.2, end: 0, curve: Curves.easeOutCubic),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: Image.asset('assets/images/google_logo.png',
                    height: 24.0,
                    width: 24.0), // ADICIONE ESTA IMAGEM À PASTA assets/images
                label: const Text('Entrar com Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  final authService = ref.read(authServiceProvider);
                  final user = await authService.signInWithGoogle();
                  if (user != null && context.mounted) {
                    // O StreamProvider authStateChangesProvider irá pegar a mudança
                    // e a SplashScreen/Router fará o redirecionamento correto.
                    // Apenas garantimos que a tela de login seja removida se o login for bem-sucedido.
                    // O context.go('/') irá reavaliar o estado de autenticação e dados do jogo.
                    context.go('/');
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Falha no login com Google. Tente novamente.'),
                          backgroundColor: AppColors.error),
                    );
                  }
                },
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
              const SizedBox(height: 20),
              Text(
                'Ao continuar, você concorda com nossos Termos de Serviço e Política de Privacidade.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
