import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/core/model/firebase_pet_model.dart';
import 'package:petverse/core/providers/active_request_provider.dart';
import 'package:petverse/core/providers/firebase_adoption_provider.dart';
import 'package:petverse/core/utils/app_utils.dart';

class RequestActionButtons extends ConsumerWidget {
  final CollaborativeAdoptionRequest activeRequest;

  const RequestActionButtons({super.key, required this.activeRequest});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              AppUtils.lightImpact();
              context.push('/list-adoption');
            },
            icon: const Icon(Icons.list),
            label: const Text('Ver na Lista Pública'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(activeRequest.requesterColorTheme),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () =>
                _showCancelRequestDialog(context, ref, activeRequest),
            icon: const Icon(Icons.close),
            label: const Text('Cancelar Solicitação'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
              side: const BorderSide(color: Color(0xFFEF4444)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCancelRequestDialog(BuildContext context, WidgetRef ref,
      CollaborativeAdoptionRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Solicitação'),
        content: const Text(
          'Tem certeza que deseja cancelar sua solicitação de adoção? '
          'Esta ação não pode ser desfeita e você precisará criar uma nova solicitação.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _cancelRequest(context, ref, request.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Sim, Cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelRequest(
      BuildContext context, WidgetRef ref, String requestId) async {
    try {
      await ref
          .read(firebaseAdoptionNotifierProvider.notifier)
          .cancelAdoptionRequest(requestId);

      ref.invalidate(userActiveRequestProvider);
      ref.invalidate(publicAdoptionRequestsFirebaseProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitação cancelada com sucesso'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao cancelar: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }
}
