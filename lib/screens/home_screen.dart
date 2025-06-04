import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PetVerse'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Bem-vindo ao PetVerse!',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            // Placeholder para conteúdo futuro, como lista de pets, feed, etc.
            ElevatedButton(
              onPressed: () {
                // TODO: Implementar navegação para outras seções ou logout
                // Exemplo: context.go('/settings');
              },
              child: const Text('Explorar Pets'),
            ),
          ],
        ),
      ),
      // TODO: Adicionar BottomNavigationBar ou Drawer para navegação principal
    );
  }
}
