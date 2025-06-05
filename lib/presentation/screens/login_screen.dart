import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_provider.dart';

/// Tipos de login disponíveis
enum LoginType {
  google('Google', Icons.g_mobiledata, Colors.red),
  apple('Apple', Icons.apple, Colors.black),
  facebook('Facebook', Icons.facebook, Color(0xFF1877F2)),
  email('Email', Icons.email_outlined, Colors.blue);

  const LoginType(this.displayName, this.icon, this.color);
  final String displayName;
  final IconData icon;
  final Color color;
}

/// Estado do processo de login
enum LoginState {
  idle,
  loading,
  success,
  error,
}

/// Tela de login moderna e animada
class LoginScreen extends ConsumerStatefulWidget {
  final VoidCallback onLoginSuccess;
  final Function(String error)? onLoginError;
  final List<LoginType> enabledMethods;
  final bool showSkipOption;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
    this.onLoginError,
    this.enabledMethods = const [LoginType.google, LoginType.apple],
    this.showSkipOption = false,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  LoginState _loginState = LoginState.idle;
  String _message = '';
  LoginType? _selectedLoginType;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startIntroAnimation();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
  }

  void _startIntroAnimation() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();

    await Future.delayed(const Duration(milliseconds: 100));
    _slideController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isLightTheme = ref.watch(isLightThemeProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isLightTheme
                ? [
                    const Color(0xFF8A05BE),
                    const Color(0xFF4B0082),
                    const Color(0xFF2E0054),
                  ]
                : [
                    const Color(0xFF1A1A1A),
                    const Color(0xFF000000),
                    const Color(0xFF0A0A0A),
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: _buildLoginCard(isLightTheme),
            ),
          ),
        ),
      ),
    );
  }

  /// Constrói o card principal de login
  Widget _buildLoginCard(bool isLightTheme) {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [_slideController, _fadeController, _scaleController]),
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildWelcomeText(),
                      const SizedBox(height: 24),
                      if (_message.isNotEmpty) ...[
                        _buildMessage(),
                        const SizedBox(height: 24),
                      ],
                      _buildLoginButtons(),
                      if (widget.showSkipOption) ...[
                        const SizedBox(height: 24),
                        _buildSkipOption(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Constrói o cabeçalho com logo
  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF8A05BE),
                Color(0xFF4B0082),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8A05BE).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.pets,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Pet Adote',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color(0xFF8A05BE),
          ),
        ),
      ],
    );
  }

  /// Constrói o texto de boas-vindas
  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          'Bem-vindo de volta!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Faça login para continuar sua jornada\nde adoção de pets',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Constrói a mensagem de status
  Widget _buildMessage() {
    final isError = _loginState == LoginState.error;
    final isSuccess = _loginState == LoginState.success;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isError
            ? Colors.red[50]
            : isSuccess
                ? Colors.green[50]
                : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError
              ? Colors.red[200]!
              : isSuccess
                  ? Colors.green[200]!
                  : Colors.blue[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError
                ? Icons.error_outline
                : isSuccess
                    ? Icons.check_circle_outline
                    : Icons.info_outline,
            color: isError
                ? Colors.red[600]
                : isSuccess
                    ? Colors.green[600]
                    : Colors.blue[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _message,
              style: TextStyle(
                color: isError
                    ? Colors.red[800]
                    : isSuccess
                        ? Colors.green[800]
                        : Colors.blue[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói os botões de login
  Widget _buildLoginButtons() {
    return Column(
      children: [
        ...widget.enabledMethods.map((loginType) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildLoginButton(loginType),
          );
        }),
      ],
    );
  }

  /// Constrói um botão de login específico
  Widget _buildLoginButton(LoginType loginType) {
    final isLoading =
        _loginState == LoginState.loading && _selectedLoginType == loginType;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : () => _handleLogin(loginType),
        style: ElevatedButton.styleFrom(
          backgroundColor: loginType.color,
          foregroundColor: Colors.white,
          elevation: isLoading ? 2 : 6,
          shadowColor: loginType.color.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    loginType.icon,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Entrar com ${loginType.displayName}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Constrói a opção de pular login
  Widget _buildSkipOption() {
    return TextButton(
      onPressed: _loginState == LoginState.loading ? null : _handleSkip,
      child: Text(
        'Continuar sem login',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Manipula o processo de login
  void _handleLogin(LoginType loginType) async {
    if (_loginState == LoginState.loading) return;

    setState(() {
      _loginState = LoginState.loading;
      _selectedLoginType = loginType;
      _message = '';
    });

    try {
      // Simula o processo de login
      await _simulateLogin(loginType);

      setState(() {
        _loginState = LoginState.success;
        _message = 'Login realizado com sucesso!';
      });

      // Aguarda um pouco para mostrar a mensagem de sucesso
      await Future.delayed(const Duration(milliseconds: 1500));

      widget.onLoginSuccess();
    } catch (error) {
      setState(() {
        _loginState = LoginState.error;
        _message = 'Erro no login: $error';
      });

      if (widget.onLoginError != null) {
        widget.onLoginError!(error.toString());
      }

      // Limpa o erro após alguns segundos
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _loginState = LoginState.idle;
            _message = '';
            _selectedLoginType = null;
          });
        }
      });
    }
  }

  /// Manipula a opção de pular login
  void _handleSkip() {
    setState(() {
      _message = 'Continuando como visitante...';
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      widget.onLoginSuccess();
    });
  }

  /// Simula o processo de login
  Future<void> _simulateLogin(LoginType loginType) async {
    // Simula tempo de resposta da API
    await Future.delayed(const Duration(seconds: 2));

    // Simula chance de erro (10%)
    if (DateTime.now().millisecond % 10 == 0) {
      throw Exception('Falha na conexão');
    }

    // Sucesso simulado
    return;
  }
}

/// Widget de login simplificado para uso rápido
class SimpleLoginScreen extends StatelessWidget {
  final VoidCallback onLoginSuccess;

  const SimpleLoginScreen({
    super.key,
    required this.onLoginSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return LoginScreen(
      onLoginSuccess: onLoginSuccess,
      enabledMethods: const [LoginType.google, LoginType.apple],
      showSkipOption: true,
    );
  }
}

/// Extensões úteis para o LoginScreen
extension LoginScreenExtensions on BuildContext {
  /// Mostra a tela de login como um dialog
  Future<bool?> showLoginDialog({
    required VoidCallback onSuccess,
    List<LoginType> methods = const [LoginType.google, LoginType.apple],
  }) {
    return showDialog<bool>(
      context: this,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: LoginScreen(
          onLoginSuccess: () {
            Navigator.of(context).pop(true);
            onSuccess();
          },
          enabledMethods: methods,
        ),
      ),
    );
  }
}
