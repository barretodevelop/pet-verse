import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/src/features/auth/presentation/providers/auth_state_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login ComPets'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ElevatedButton.icon(
                icon: const Icon(Icons.login), // TODO: Usar ícone do Google
                label: const Text('Entrar com o Google'),
                onPressed: () async {
                  try {
                    await authNotifier.signInWithGoogle();
                    // A navegação será tratada pelo GoRouter e pelo AuthStateNotifier
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro no login: ${e.toString()}')),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              // TODO: Adicionar botão de Login com Apple (condicional para iOS)
              const Text('Outras opções de login em breve!',
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
