// File: lib/presentation/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/config/theme_config.dart';
import 'package:petverse/core/utils/helpers.dart';
import 'package:petverse/presentation/providers/auth_provider.dart';
import 'package:petverse/presentation/widgets/animations/pulse_animation.dart';
import 'package:petverse/presentation/widgets/animations/shake_animation.dart';
import 'package:petverse/presentation/widgets/animations/slide_fade_animation.dart';

/// Enhanced login screen with Google authentication
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  final GlobalKey<ShakeAnimationState> _formShakeKey = GlobalKey<ShakeAnimationState>();

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _fadeController.forward();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleLogin() async {
    final success = await ref.read(authProvider.notifier).signInWithGoogle();

    if (!success && mounted) {
      _formShakeKey.currentState?.shake();

      final errorMessage = ref.read(authProvider).errorMessage;
      if (errorMessage != null) {
        Helpers.showSnackBar(
          context,
          errorMessage,
          backgroundColor: ThemeConfig.errorColor,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: ThemeConfig.primaryGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(ThemeConfig.spacing20),
            child: SlideFadeAnimation(
              duration: const Duration(milliseconds: 900),
              child: ShakeAnimation(
                key: _formShakeKey,
                child: _buildLoginForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeConfig.spacing28,
          vertical: ThemeConfig.spacing32,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(ThemeConfig.borderRadius20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: ThemeConfig.spacing32),
            _buildErrorDisplay(),
            _buildGoogleButton(),
            const SizedBox(height: ThemeConfig.spacing16),
            _buildTermsText(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Animated app icon
        PulseAnimation(
          duration: const Duration(milliseconds: 2000),
          minScale: 0.95,
          maxScale: 1.05,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: ThemeConfig.primaryGradient,
              borderRadius: BorderRadius.circular(ThemeConfig.borderRadius20),
              boxShadow: [
                BoxShadow(
                  color: ThemeConfig.primaryColor.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.pets,
              size: ThemeConfig.iconSize48,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: ThemeConfig.spacing24),

        // Welcome text
        Text(
          'Welcome Back!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineSmall?.color,
              ),
        ),

        const SizedBox(height: ThemeConfig.spacing8),

        Text(
          'Sign in to continue caring for your virtual pets',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorDisplay() {
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authProvider);

        if (!authState.hasError) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.only(bottom: ThemeConfig.spacing20),
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConfig.spacing16,
            vertical: ThemeConfig.spacing12,
          ),
          decoration: BoxDecoration(
            color: ThemeConfig.errorColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
            border: Border.all(
              color: ThemeConfig.errorColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: ThemeConfig.errorColor,
                size: ThemeConfig.iconSize20,
              ),
              const SizedBox(width: ThemeConfig.spacing8),
              Expanded(
                child: Text(
                  authState.errorMessage!,
                  style: const TextStyle(
                    color: ThemeConfig.errorColor,
                    fontSize: ThemeConfig.fontSize14,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: ThemeConfig.errorColor,
                  size: ThemeConfig.iconSize16,
                ),
                onPressed: () => ref.read(authProvider.notifier).clearError(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGoogleButton() {
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authProvider);

        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: authState.isLoading ? null : _handleGoogleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
                side: BorderSide(
                  color: Colors.grey.withOpacity(0.3),
                ),
              ),
            ),
            icon: authState.isLoading
                ? const SizedBox(
                    width: ThemeConfig.iconSize20,
                    height: ThemeConfig.iconSize20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ThemeConfig.primaryColor,
                      ),
                    ),
                  )
                : Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/768px-Google_%22G%22_logo.svg.png',
                    width: ThemeConfig.iconSize20,
                    height: ThemeConfig.iconSize20,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.login,
                      size: ThemeConfig.iconSize20,
                      color: ThemeConfig.primaryColor,
                    ),
                  ),
            label: Text(
              authState.isLoading ? 'Signing in...' : 'Continue with Google',
              style: const TextStyle(
                fontSize: ThemeConfig.fontSize16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTermsText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ThemeConfig.spacing8),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
            fontSize: ThemeConfig.fontSize12,
            height: 1.4,
          ),
          children: const [
            TextSpan(
              text: 'By signing in, you agree to our ',
            ),
            TextSpan(
              text: 'Terms of Service',
              style: TextStyle(
                color: ThemeConfig.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: TextStyle(
                color: ThemeConfig.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }
}
