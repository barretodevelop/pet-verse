import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/src/core/navigation/app_routes.dart'; // Importe AppRoutes
// Importe AppRoutes se for usar constantes de rota
// import 'package:petverse/src/core/navigation/app_routes.dart';

class AdoptionInitialScreen extends ConsumerWidget {
  const AdoptionInitialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adote um Pet'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Parece que você ainda não tem um pet. Vamos encontrar um parceiro para cuidar!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implementar navegação para "Ver lista de pets aguardando um parceiro"
                  // Navega para a tela que lista as solicitações de adoção pendentes
                  context.push(AppRoutes.pendingAdoptions);
                },
                child: const Text('Ver pets aguardando parceiro'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  context.push(AppRoutes.adoptNewPet);
                },
                child: const Text('Adotar um novo pet'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  context.push(AppRoutes.enterFriendCode);
                },
                child: const Text('Inserir código de amigo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
