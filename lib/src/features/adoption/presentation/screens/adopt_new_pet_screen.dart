import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/src/features/adoption/presentation/providers/adoption_providers.dart'; // Importar o novo provider
import 'package:petverse/src/features/adoption/presentation/providers/available_pets_provider.dart'; // Importa o provider
import 'package:petverse/src/features/adoption/presentation/widgets/available_pet_card.dart'; // Importa o novo widget de card

class AdoptNewPetScreen extends ConsumerStatefulWidget {
  // Mudar para ConsumerStatefulWidget
  const AdoptNewPetScreen({super.key});

  @override
  ConsumerState<AdoptNewPetScreen> createState() => _AdoptNewPetScreenState();
}

class _AdoptNewPetScreenState extends ConsumerState<AdoptNewPetScreen> {
  // Criar State
  // Lista para armazenar os IDs dos pets selecionados
  final List<String> _selectedPetIds = [];
  final int _maxSelectionCount = 3;

  // Estado para controlar o tipo de adoção
  // true para pública, false para convidar amigo
  bool _isPublicAdoption = true;

  void _togglePetSelection(String petId) {
    setState(() {
      if (_selectedPetIds.contains(petId)) {
        _selectedPetIds.remove(petId);
      } else {
        if (_selectedPetIds.length < _maxSelectionCount) {
          _selectedPetIds.add(petId);
        } else {
          // Opcional: Mostrar uma mensagem de que o limite foi atingido
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Você pode selecionar no máximo $_maxSelectionCount pets.')),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Observa o provider de pets disponíveis
    ref.listen<AsyncValue<String?>>(createAdoptionRequestNotifierProvider,
        (previous, next) {
      next.when(
        data: (friendCode) {
          if (friendCode != null) {
            // Sucesso! Mostrar o código de amigo e limpar seleção
            // Isso só acontece se !isPublicAdoption
            showDialog(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Solicitação Criada!'),
                content: Text(
                    'Seu código para convidar um amigo é: $friendCode\nCompartilhe com ele!'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('OK'))
                ],
              ),
            ).then((_) => Navigator.of(context)
                .pop()); // Volta para tela anterior após OK
            setState(() => _selectedPetIds.clear()); // Limpa a seleção
          } else if (previous is AsyncLoading &&
              next is AsyncData &&
              friendCode == null &&
              _isPublicAdoption) {
            // Sucesso para adoção pública
            ScaffoldMessenger.of(context)
                .showSnackBar(
                  const SnackBar(
                      content:
                          Text('Sua solicitação de adoção foi publicada!')),
                )
                .closed
                .then((_) =>
                    Navigator.of(context).pop()); // Volta para tela anterior
            setState(() => _selectedPetIds.clear()); // Limpa a seleção
          }
        },
        error: (e, s) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao criar solicitação: $e'))),
        loading: () {/* Opcional: mostrar indicador de carregamento global */},
      );
    });

    final availablePetsAsyncValue = ref.watch(availablePetsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Adotar Novo Pet')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Passo 1: Selecione $_maxSelectionCount pets que você gostaria de adotar em conjunto.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: availablePetsAsyncValue.when(
              data: (pets) {
                if (pets.isEmpty) {
                  return const Center(
                    child:
                        Text('Nenhum pet disponível para adoção no momento.'),
                  );
                }
                // Exibe a lista de pets disponíveis
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: pets.length,
                  itemBuilder: (context, index) {
                    final pet = pets[index];
                    return AvailablePetCard(
                      pet: pet,
                      // Verifica se o pet atual está na lista de selecionados
                      isSelected: _selectedPetIds.contains(pet.id),
                      onTap: () => _togglePetSelection(pet.id),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) {
                debugPrint('Erro ao carregar pets disponíveis: $error');
                debugPrint('Stacktrace: $stack');
                return Center(
                  child: Text('Erro ao carregar pets: ${error.toString()}'),
                );
              },
            ),
          ),
          if (_selectedPetIds.length == _maxSelectionCount) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Passo 2: Como deseja prosseguir?',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
            RadioListTile<bool>(
              title: const Text('Publicar para Adoção Anônima'),
              subtitle:
                  const Text('Sua solicitação aparecerá para outros usuários.'),
              value: true,
              groupValue: _isPublicAdoption,
              onChanged: (bool? value) {
                if (value != null) setState(() => _isPublicAdoption = value);
              },
            ),
            RadioListTile<bool>(
              title: const Text('Convidar um Amigo'),
              subtitle:
                  const Text('Você receberá um código para compartilhar.'),
              value: false,
              groupValue: _isPublicAdoption,
              onChanged: (bool? value) {
                if (value != null) setState(() => _isPublicAdoption = value);
              },
            ),
            const SizedBox(height: 20), // Espaçamento antes do botão
          ],
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _selectedPetIds.length == _maxSelectionCount
          ? FloatingActionButton.extended(
              onPressed: ref
                      .watch(createAdoptionRequestNotifierProvider)
                      .isLoading
                  ? null // Desabilitar botão enquanto carrega
                  : () {
                      ref
                          .read(createAdoptionRequestNotifierProvider.notifier)
                          .createRequest(_selectedPetIds,
                              isPublic: _isPublicAdoption);
                    },
              // Mostrar um indicador de progresso no botão se estiver carregando
              icon: ref.watch(createAdoptionRequestNotifierProvider).isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.check),
              label: Text(_isPublicAdoption
                  ? 'Publicar Solicitação'
                  : 'Gerar Código para Amigo'),
            )
          : null,
    );
  }
}
