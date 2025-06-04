import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/src/core/navigation/app_routes.dart';
import 'package:petverse/src/features/adoption/presentation/providers/adoption_providers.dart';

class EnterFriendCodeScreen extends ConsumerStatefulWidget {
  const EnterFriendCodeScreen({super.key});

  @override
  ConsumerState<EnterFriendCodeScreen> createState() =>
      _EnterFriendCodeScreenState();
}

class _EnterFriendCodeScreenState extends ConsumerState<EnterFriendCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _submitCode() {
    if (_formKey.currentState!.validate()) {
      final code = _codeController.text.trim().toUpperCase();
      // Dismiss keyboard before making the request
      FocusScope.of(context).unfocus();
      ref.read(findAdoptionByCodeNotifierProvider.notifier).findRequest(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(findAdoptionByCodeNotifierProvider, (previous, next) {
      next.when(
        data: (adoptionRequest) {
          if (adoptionRequest != null) {
            // Request found, navigate to details
            // Clear the text field upon successful navigation
            _codeController.clear();
            context.goNamed(AppRoutes.pendingRequestDetails,
                pathParameters: {'requestId': adoptionRequest.id});
          } else if (previous is AsyncLoading && adoptionRequest == null) {
            // Search completed, but no request found
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Nenhuma solicitação encontrada com este código ou ela não está mais pendente.')),
            );
          }
        },
        error: (e, s) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao buscar solicitação: $e')),
          );
          // Optionally, clear the field on error too
          // _codeController.clear();
        },
        loading: () {
          // Optional: Show a global loading indicator if needed
        },
      );
    });

    final findRequestState = ref.watch(findAdoptionByCodeNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Inserir Código do Amigo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Código do Amigo',
                  border: OutlineInputBorder(),
                  hintText: 'ABC123XYZ', // Example hint
                ),
                textCapitalization: TextCapitalization.characters,
                autocorrect: false,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira o código.';
                  }
                  // Example: If codes are always 8 characters
                  // if (value.trim().length != 8) {
                  //   return 'O código deve ter 8 caracteres.';
                  // }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: findRequestState.isLoading ? null : _submitCode,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50), // Full width button
                ),
                child: findRequestState.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Text('Buscar Solicitação'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
