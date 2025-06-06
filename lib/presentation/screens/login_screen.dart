// lib/presentation/screens/login_screen.dart - ATUALIZADO
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/auth/auth_middleware.dart';
import 'package:petverse/core/navigation/navigation_helpers.dart';
import 'package:petverse/core/navigation/route_names.dart';

enum LoginType { google, apple, email, guest }

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

class _LoginScreenState extends ConsumerState<LoginScreen>
    with NavigationControlMixin {
  bool _isLoading = false;

  Future<void> _handleLogin(AuthType authType) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final authNotifier = ref.read(authStateProvider.notifier);
      AuthResult result;

      switch (authType) {
        case AuthType.google:
          result = await authNotifier.loginWithGoogle();
          break;
        case AuthType.apple:
          result = await authNotifier.loginWithApple();
          break;
        case AuthType.guest:
          result = await authNotifier.loginAsGuest();
          break;
        default:
          throw UnimplementedError('Auth type not implemented: $authType');
      }

      if (result.success) {
        widget.onLoginSuccess?.call();
        safeNavigateTo(RouteNames.dashboard);
      } else {
        widget.onLoginError?.call(result.error ?? 'Erro desconhecido');
        _showErrorMessage(result.error ?? 'Erro no login');
      }
    } catch (e) {
      final errorMessage = 'Erro interno: $e';
      widget.onLoginError?.call(errorMessage);
      _showErrorMessage(errorMessage);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo e título
                _buildHeader(),

                const SizedBox(height: 48),

                // Botões de login
                _buildLoginButtons(),

                if (widget.showSkipOption) ...[
                  const SizedBox(height: 24),
                  _buildSkipButton(),
                ],

                const SizedBox(height: 32),

                // Termos e condições
                _buildTermsText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.pets,
            size: 50,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Bem-vindo ao Pet Adote',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Entre para encontrar seu companheiro perfeito',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginButtons() {
    return Column(
      children: [
        if (widget.enabledMethods.contains(LoginType.google))
          _buildLoginButton(
            text: 'Continuar com Google',
            icon: Icons.account_circle,
            onPressed: () => _handleLogin(AuthType.google),
            backgroundColor: Colors.white,
            textColor: Colors.black87,
          ),
        if (widget.enabledMethods.contains(LoginType.google) &&
            widget.enabledMethods.contains(LoginType.apple))
          const SizedBox(height: 16),
        if (widget.enabledMethods.contains(LoginType.apple))
          _buildLoginButton(
            text: 'Continuar com Apple',
            icon: Icons.apple,
            onPressed: () => _handleLogin(AuthType.apple),
            backgroundColor: Colors.black,
            textColor: Colors.white,
          ),
      ],
    );
  }

  Widget _buildLoginButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : onPressed,
        icon: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Icon(icon, color: textColor),
        label: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return TextButton(
      onPressed: _isLoading ? null : () => _handleLogin(AuthType.guest),
      child: Text(
        'Continuar como convidado',
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: 16,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return Text(
      'Ao continuar, você concorda com nossos\nTermos de Uso e Política de Privacidade',
      style: TextStyle(
        fontSize: 12,
        color: Colors.white.withOpacity(0.7),
      ),
      textAlign: TextAlign.center,
    );
  }
}
