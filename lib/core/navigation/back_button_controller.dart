// lib/core/navigation/back_button_controller.dart
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

/// Controlador customizado para o botão de voltar
class BackButtonController {
  static final Logger _logger = Logger();
  static BackButtonController? _instance;

  DateTime? _lastBackPressed;
  bool _isControlled = false;
  VoidCallback? _onBackPressed;
  Duration _doubleTapThreshold = const Duration(seconds: 2);

  BackButtonController._();

  static BackButtonController get instance {
    return _instance ??= BackButtonController._();
  }

  /// Configura controle do botão de voltar
  void configure({
    VoidCallback? onBackPressed,
    Duration? doubleTapThreshold,
  }) {
    _onBackPressed = onBackPressed;
    _doubleTapThreshold = doubleTapThreshold ?? _doubleTapThreshold;
    _isControlled = true;

    _logger.d('Back button controller configured');
  }

  /// Remove controle do botão de voltar
  void release() {
    _onBackPressed = null;
    _isControlled = false;
    _lastBackPressed = null;

    _logger.d('Back button controller released');
  }

  /// Manipula pressionamento do botão voltar
  Future<bool> handleBackPressed() async {
    try {
      final now = DateTime.now();

      // Se há um callback customizado, usa ele
      if (_onBackPressed != null) {
        _onBackPressed!();
        return false; // Impede o comportamento padrão
      }

      // Lógica de duplo toque para sair do app
      if (_lastBackPressed == null ||
          now.difference(_lastBackPressed!) > _doubleTapThreshold) {
        _lastBackPressed = now;
        return false; // Primeira vez, não sai
      }

      // Segunda vez em pouco tempo, permite sair
      return true;
    } catch (e, stackTrace) {
      _logger.e('Back button handling error', error: e, stackTrace: stackTrace);
      return true; // Em caso de erro, permite o comportamento padrão
    }
  }

  /// Verifica se está sendo controlado
  bool get isControlled => _isControlled;

  /// Configura threshold para duplo toque
  void setDoubleTapThreshold(Duration threshold) {
    _doubleTapThreshold = threshold;
  }

  /// Força reset do timer de duplo toque
  void resetDoubleTapTimer() {
    _lastBackPressed = null;
  }
}

/// Widget helper para controle de back button
class BackButtonHandler extends StatefulWidget {
  final Widget child;
  final VoidCallback? onBackPressed;
  final bool enableDoubleTapToExit;
  final String? exitMessage;

  const BackButtonHandler({
    super.key,
    required this.child,
    this.onBackPressed,
    this.enableDoubleTapToExit = true,
    this.exitMessage,
  });

  @override
  State<BackButtonHandler> createState() => _BackButtonHandlerState();
}

class _BackButtonHandlerState extends State<BackButtonHandler> {
  @override
  void initState() {
    super.initState();

    if (widget.onBackPressed != null) {
      BackButtonController.instance.configure(
        onBackPressed: widget.onBackPressed,
      );
    }
  }

  @override
  void dispose() {
    BackButtonController.instance.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableDoubleTapToExit) {
      return widget.child;
    }

    return WillPopScope(
      onWillPop: () async {
        final shouldExit =
            await BackButtonController.instance.handleBackPressed();

        if (!shouldExit && widget.exitMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.exitMessage!),
              duration: const Duration(seconds: 2),
            ),
          );
        }

        return shouldExit;
      },
      child: widget.child,
    );
  }
}
