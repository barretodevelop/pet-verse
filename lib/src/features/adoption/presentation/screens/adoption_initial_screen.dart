import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/src/core/navigation/app_routes.dart'; // Importe AppRoutes
import 'package:petverse/src/features/adoption/presentation/providers/user_active_adoption_request_provider.dart'; // Importar o novo provider
// Importe AppRoutes se for usar constantes de rota
// import 'package:petverse/src/core/navigation/app_routes.dart';

class AdoptionInitialScreen extends ConsumerWidget {
  const AdoptionInitialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeRequestAsyncValue =
        ref.watch(userActiveAdoptionRequestProvider);

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
              children: activeRequestAsyncValue.when(
                data: (activeRequest) {
                  bool canCreateNewRequest = activeRequest == null;

                  if (!canCreateNewRequest) {
                    // Se já existe uma solicitação ativa, mostrar apenas o card de aviso
                    return [
                      Card(
                        color: Theme.of(context)
                            .colorScheme
                            .secondaryContainer
                            .withOpacity(0.5),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize
                                .min, // Para o card não ocupar toda a altura
                            children: [
                              Icon(Icons.info_outline,
                                  size: 40,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer),
                              const SizedBox(height: 12),
                              Text(
                                'Você já possui uma solicitação de adoção pendente.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Aguarde até que ela seja completada ou cancelada para criar uma nova.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ];
                  } else {
                    // Se não há solicitação ativa, mostrar a mensagem e os botões
                    return <Widget>[
                      const Text(
                        'Parece que você ainda não tem um pet ou uma solicitação ativa. Vamos encontrar um parceiro para cuidar!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          context.push(AppRoutes.pendingAdoptions);
                        },
                        child: const Text('Ver pets aguardando parceiro'),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => context.push(AppRoutes.adoptNewPet),
                        child: const Text('Adotar um novo pet'),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () {
                          context.push(AppRoutes.enterFriendCode);
                        },
                        child: const Text('Inserir código de amigo'),
                      ),
                    ];
                  }
                },
                loading: () =>
                    [const Center(child: CircularProgressIndicator())],
                error: (error, stack) => [
                  Center(child: Text('Erro ao verificar solicitações: $error'))
                ],
              )),
        ),
      ),
    );
  }
}
