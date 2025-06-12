// File: lib/core/middleware/error_handler.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../errors/exceptions.dart';
import '../errors/failures.dart';
import '../utils/helpers.dart';

/// Global error handler for the application
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  /// Handle errors globally
  static void handleError(
    dynamic error, {
    StackTrace? stackTrace,
    BuildContext? context,
    String? customMessage,
  }) {
    // Log error in debug mode
    if (kDebugMode) {
      debugPrint('🔴 Error: $error');
      if (stackTrace != null) {
        debugPrint('📍 Stack trace: $stackTrace');
      }
    }

    // Determine error message
    String message = customMessage ?? _getErrorMessage(error);

    // Show user-friendly message if context is available
    if (context != null && context.mounted) {
      _showErrorToUser(context, message);
    }

    // Report to analytics service
    _reportError(error, stackTrace);
  }

  /// Convert errors to user-friendly messages
  static String _getErrorMessage(dynamic error) {
    if (error is Failure) {
      return _getFailureMessage(error);
    }

    if (error is Exception) {
      return _getExceptionMessage(error);
    }

    return 'An unexpected error occurred';
  }

  /// Get message from Failure objects
  static String _getFailureMessage(Failure failure) {
    switch (failure.runtimeType) {
      case AuthFailure:
        return 'Authentication failed. Please try again.';
      case NetworkFailure:
        return 'Please check your internet connection.';
      case DatabaseFailure:
        return 'Failed to save data. Please try again.';
      case PetGameFailure:
        return failure.message;
      case UserDataFailure:
        return 'Failed to load user data. Please refresh.';
      case TransactionFailure:
        return 'Transaction failed. Please try again.';
      case ValidationFailure:
        return failure.message;
      case ServerFailure:
        return 'Server error. Please try again later.';
      default:
        return failure.message;
    }
  }

  /// Get message from Exception objects
  static String _getExceptionMessage(Exception exception) {
    if (exception is AuthException) {
      return 'Authentication error. Please sign in again.';
    }
    if (exception is DatabaseException) {
      return 'Database error. Please try again.';
    }
    if (exception is NetworkException) {
      return 'Network error. Please check your connection.';
    }
    if (exception is CacheException) {
      return 'Cache error. Please restart the app.';
    }
    if (exception is PetGameException) {
      return exception.message;
    }

    return exception.toString();
  }

  /// Show error message to user
  static void _showErrorToUser(BuildContext context, String message) {
    if (!context.mounted) return;

    // Use helpers to show snackbar
    Helpers.showSnackBar(
      context,
      message,
      backgroundColor: Colors.red[600],
      duration: const Duration(seconds: 4),
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );
  }

  /// Report error to analytics
  static void _reportError(dynamic error, StackTrace? stackTrace) {
    // This would integrate with Firebase Crashlytics or other analytics
    if (kDebugMode) {
      debugPrint('📊 Error reported to analytics: $error');
    }
  }

  /// Handle uncaught errors
  static void setupGlobalErrorHandling() {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      handleError(
        details.exception,
        stackTrace: details.stack,
        customMessage: 'A Flutter framework error occurred',
      );
    };

    // Handle other uncaught errors
    PlatformDispatcher.instance.onError = (error, stack) {
      handleError(
        error,
        stackTrace: stack,
        customMessage: 'An uncaught error occurred',
      );
      return true;
    };
  }
}

/// Error boundary widget to catch widget errors
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error)? errorBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!) ?? _buildDefaultErrorWidget(context);
    }

    return widget.child;
  }

  Widget _buildDefaultErrorWidget(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Please try restarting the app',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                  });
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _catchErrors();
  }

  void _catchErrors() {
    try {
      // Potential error-prone operations
    } catch (error, stackTrace) {
      setState(() {
        _error = error;
      });

      ErrorHandler.handleError(
        error,
        stackTrace: stackTrace,
        context: context,
      );
    }
  }
}
