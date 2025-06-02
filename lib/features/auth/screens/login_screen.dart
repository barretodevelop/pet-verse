// lib/features/auth/screens/login_screen.dart
// ALTERADO: Design profissional e tratamento completo de erros
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    // Listener para mudanças no estado de autenticação
    ref.listen<AsyncValue<User?>>(authStateChangesProvider, (previous, next) {
      next.whenData((user) {
        if (user != null && mounted) {
          // Usuário logado com sucesso, navegar para splash que fará o redirecionamento correto
          context.go('/');
        }
      });
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.8),
              AppColors.secondary.withOpacity(0.9),
              AppColors.accent,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo animado
                  _buildAnimatedLogo(),

                  const SizedBox(height: 48),

                  // Card principal
                  _buildMainCard(theme),

                  const SizedBox(height: 32),

                  // Informações sobre privacidade
                  _buildPrivacyInfo(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animationController.value * 0.1,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.pets,
              size: 60,
              color: Colors.white,
            ),
          ),
        );
      },
    )
        .animate()
        .fadeIn(duration: 800.ms)
        .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.0, 1.0))
        .then()
        .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3));
  }

  Widget _buildMainCard(ThemeData theme) {
    return Card(
      elevation: 24,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.white.withOpacity(0.95),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título principal
            Text(
              'PetVerse',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 600.ms)
                .slideY(begin: -0.3, end: 0),

            const SizedBox(height: 8),

            // Subtítulo
            Text(
              'Cuidado Virtual de Pets Colaborativo',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            )
                .animate()
                .fadeIn(delay: 500.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 40),

            // Descrição
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.handshake_outlined,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adote pets virtuais de forma colaborativa e\ncrie laços únicos com outros cuidadores!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 700.ms, duration: 600.ms)
                .scale(begin: const Offset(0.9, 0.9)),

            const SizedBox(height: 32),

            // Botão de login
            _buildGoogleSignInButton(),

            const SizedBox(height: 16),

            // Indicador de carregamento
            if (_isLoading)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Conectando com sua conta...',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .scale(begin: const Offset(0.8, 0.8)),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 800.ms)
        .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildGoogleSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        icon: Container(
          width: 24,
          height: 24,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Image.asset(
            'assets/images/google_logo.png',
            errorBuilder: (context, error, stackTrace) {
              // Fallback se a imagem não existir
              return const Icon(
                Icons.g_mobiledata,
                color: Colors.red,
                size: 20,
              );
            },
          ),
        ),
        label: Text(
          'Continuar com Google',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.grey.shade800,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
        ),
        onPressed: _isLoading ? null : _handleGoogleSignIn,
      ),
    )
        .animate()
        .fadeIn(delay: 900.ms, duration: 600.ms)
        .scale(begin: const Offset(0.9, 0.9))
        .then()
        .shimmer(
          delay: 2000.ms,
          duration: 1500.ms,
          color: AppColors.primary.withOpacity(0.1),
        );
  }

  Widget _buildPrivacyInfo(ThemeData theme) {
    return Column(
      children: [
        Text(
          'Ao continuar, você concorda com nossos',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => _showTermsDialog(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              child: Text(
                'Termos de Serviço',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Text(
              ' e ',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            TextButton(
              onPressed: () => _showPrivacyDialog(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              child: Text(
                'Política de Privacidade',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 1100.ms, duration: 600.ms)
        .slideY(begin: 0.5, end: 0);
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signInWithGoogle();

      if (user != null && mounted) {
        // Mostrar feedback de sucesso
        _showSuccessSnackBar('Login realizado com sucesso!');

        // A navegação será feita automaticamente pelo listener do authStateChangesProvider
      } else if (mounted) {
        // Usuário cancelou o login
        _showErrorSnackBar('Login cancelado pelo usuário');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Erro no login: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Termos de Serviço'),
        content: SingleChildScrollView(
          child: Text(
            'Ao usar o PetVerse, você concorda em:\n\n'
            '• Usar o aplicativo de forma respeitosa\n'
            '• Não compartilhar informações pessoais\n'
            '• Respeitar outros usuários na adoção colaborativa\n'
            '• Seguir as diretrizes da comunidade\n\n'
            'O PetVerse se reserva o direito de modificar estes termos.',
            style: GoogleFonts.inter(height: 1.4),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Política de Privacidade'),
        content: SingleChildScrollView(
          child: Text(
            'Sua privacidade é importante para nós:\n\n'
            '• Coletamos apenas dados necessários para o funcionamento\n'
            '• Informações de login são criptografadas\n'
            '• Dados de jogo são armazenados de forma segura\n'
            '• Não compartilhamos informações com terceiros\n'
            '• Você pode deletar sua conta a qualquer momento\n\n'
            'Para mais detalhes, visite nossa política completa.',
            style: GoogleFonts.inter(height: 1.4),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }
}
