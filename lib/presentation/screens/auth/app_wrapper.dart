// File: lib/presentation/screens/auth/app_wrapper.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/enums/enums/app_enums.dart';
import 'package:petverse/presentation/providers/auth_provider.dart';
import 'package:petverse/presentation/providers/user_provider.dart';
import 'package:petverse/presentation/screens/auth/login_screen.dart';
import 'package:petverse/presentation/screens/home/home_screen.dart';
import 'package:petverse/presentation/screens/splash/splash_screen.dart';

/// App wrapper that handles navigation between auth states
class AppWrapper extends ConsumerStatefulWidget {
  const AppWrapper({super.key});

  @override
  ConsumerState<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends ConsumerState<AppWrapper> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Simulate app initialization time
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userGameDataState = ref.watch(userGameDataProvider);

    // Show splash screen during initialization
    if (_isInitializing) {
      return const SplashScreen();
    }

    // Show splash screen while auth is loading
    if (authState.status == AuthStatus.loading) {
      return const SplashScreen();
    }

    // Show login screen if not authenticated
    if (!authState.isAuthenticated) {
      return const LoginScreen();
    }

    // Show splash screen while user data is loading (first time only)
    if (userGameDataState.status == LoadingState.loading && !userGameDataState.hasUser) {
      return const SplashScreen();
    }

    // Show error screen if user data failed to load
    if (userGameDataState.hasError && !userGameDataState.hasUser) {
      return _buildErrorScreen();
    }

    // Show home screen when everything is ready
    return const HomeScreen();
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF212121), Color(0xFF303030)],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.white70,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  ref.watch(userGameDataProvider).errorMessage ?? 'Unknown error occurred',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    // Try to reload user data
                    final authState = ref.read(authProvider);
                    if (authState.firebaseUser != null) {
                      // This will trigger a reload of user data
                      ref.invalidate(userGameDataProvider);
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).signOut();
                  },
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
