// ========================================
// 3. TELA DE LOGIN ATUALIZADA
// lib/presentation/screens/login_screen.dart (ATUALIZADO)

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/auth_provider.dart';

enum LoginType { google, apple, anonymous }

class LoginScreen extends ConsumerStatefulWidget {
  final VoidCallback? onLoginSuccess;
  final Function(String)? onLoginError;
  final List<LoginType> enabledMethods;
  final bool showSkipOption;

  const LoginScreen({
    super.key,
    this.onLoginSuccess,
    this.onLoginError,
    this.enabledMethods = const [LoginType.google, LoginType.apple],
    this.showSkipOption = false,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  void initState() {
    super.initState();

    // Escuta mudanças no estado de autenticação
    ref.listenManual(authNotifierProvider, (previous, next) {
      if (previous?.isAuthenticated != next.isAuthenticated) {
        if (next.isAuthenticated) {
          widget.onLoginSuccess?.call();
        }
      }

      if (next.error != null && previous?.error != next.error) {
        widget.onLoginError?.call(next.error!);
        _showErrorSnackBar(next.error!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.primaryColor,
              theme.primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Logo e título
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.pets,
                          size: 60,
                          color: Color(0xFF8A05BE),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'PetVerse',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Adote seu pet virtual e cuide dele com amor',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                // Botões de login
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Google Sign-In
                      if (widget.enabledMethods.contains(LoginType.google))
                        _buildGoogleSignInButton(authState.isLoading),

                      const SizedBox(height: 16),

                      // Apple Sign-In (apenas iOS)
                      if (widget.enabledMethods.contains(LoginType.apple) &&
                          (Platform.isIOS || kIsWeb))
                        _buildAppleSignInButton(authState.isLoading),

                      const SizedBox(height: 16),

                      // Login anônimo (desenvolvimento)
                      if (widget.enabledMethods.contains(LoginType.anonymous))
                        _buildAnonymousSignInButton(authState.isLoading),

                      const SizedBox(height: 32),

                      // Termos e condições
                      Text(
                        'Ao continuar, você concorda com nossos\nTermos de Uso e Política de Privacidade',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Botão Google Sign-In
  Widget _buildGoogleSignInButton(bool isLoading) {
    return ElevatedButton.icon(
      onPressed: isLoading
          ? null
          : () => ref.read(authNotifierProvider.notifier).signInWithGoogle(),
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Image.asset(
              'assets/images/google_logo.png',
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.login,
                color: Colors.black87,
              ),
            ),
      label: Text(
        isLoading ? 'Entrando...' : 'Entrar com Google',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2,
        shadowColor: Colors.black26,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Botão Apple Sign-In
  Widget _buildAppleSignInButton(bool isLoading) {
    return ElevatedButton.icon(
      onPressed: isLoading
          ? null
          : () => ref.read(authNotifierProvider.notifier).signInWithApple(),
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(
              Icons.apple,
              color: Colors.white,
              size: 24,
            ),
      label: Text(
        isLoading ? 'Entrando...' : 'Entrar com Apple',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black26,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Botão login anônimo
  Widget _buildAnonymousSignInButton(bool isLoading) {
    return OutlinedButton.icon(
      onPressed: isLoading
          ? null
          : () => ref.read(authNotifierProvider.notifier).signInAnonymously(),
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(
              Icons.person_outline,
              color: Colors.white,
            ),
      label: Text(
        isLoading ? 'Entrando...' : 'Continuar como Visitante',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.white, width: 2),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Mostra erro
  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Tentar Novamente',
          textColor: Colors.white,
          onPressed: () => ref.read(authNotifierProvider.notifier).clearError(),
        ),
      ),
    );
  }
}
