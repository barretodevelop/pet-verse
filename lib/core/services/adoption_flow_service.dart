// lib/core/services/adoption_flow_service.dart
// NOVO: Serviço robusto para gerenciar fluxo de adoção
// Integra com UnifiedUserStateProvider para sincronização perfeita

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/core/enums/enums.dart';
import 'package:petverse/core/providers/unified_user_state_provider.dart';
import 'package:petverse/core/utils/app_utils.dart';

class AdoptionFlowService {
  static AdoptionFlowService? _instance;
  static AdoptionFlowService get instance =>
      _instance ??= AdoptionFlowService._();
  AdoptionFlowService._();

  // Executar adoção completa com navegação integrada
  static Future<bool> executeAdoptionFlow({
    required BuildContext context,
    required WidgetRef ref,
    required String requestId,
    required String petId,
    required String coParentDisplayName,
    required String coParentCodename,
  }) async {
    try {
      // 1. Mostrar loading inicial
      _showAdoptionLoadingSnackbar(context);

      // 2. Executar adoção através do provider unificado
      final success =
          await ref.read(unifiedUserStateProvider.notifier).adoptPet(
                requestId: requestId,
                petId: petId,
                coParentDisplayName: coParentDisplayName,
                coParentCodename: coParentCodename,
              );

      if (success) {
        // 3. Mostrar sucesso e aguardar
        _showAdoptionSuccessSnackbar(context);
        await Future.delayed(const Duration(milliseconds: 1500));

        // 4. Navegar para home (onde o pet já deve aparecer)
        if (context.mounted) {
          context.go('/home');
        }

        return true;
      } else {
        _showAdoptionErrorSnackbar(context, 'Falha na verificação da adoção');
        return false;
      }
    } catch (e) {
      _showAdoptionErrorSnackbar(context, e.toString());
      return false;
    }
  }

  // Executar criação de solicitação com navegação
  static Future<String?> executeCreateRequestFlow({
    required BuildContext context,
    required WidgetRef ref,
    required List<String> selectedPetIds,
    required String codename,
    required int colorTheme,
    required String codedMessage,
    required List<String> personalityTags,
    required String region,
  }) async {
    try {
      // 1. Validar pré-condições
      final canCreate = ref.read(canCreateRequestProvider);
      if (!canCreate) {
        throw Exception('Não é possível criar solicitação no momento');
      }

      // 2. Mostrar loading
      _showCreateRequestLoadingSnackbar(context);

      // 3. Criar solicitação através do provider unificado
      final requestId = await ref
          .read(unifiedUserStateProvider.notifier)
          .createAdoptionRequest(
            selectedPetIds: selectedPetIds,
            codename: codename,
            colorTheme: colorTheme,
            codedMessage: codedMessage,
            personalityTags: personalityTags,
            region: region,
          );

      if (requestId != null) {
        // 4. Mostrar sucesso
        _showCreateRequestSuccessSnackbar(context, requestId);
        await Future.delayed(const Duration(milliseconds: 1000));

        // 5. Navegar para home (onde a solicitação ativa deve aparecer)
        if (context.mounted) {
          context.go('/home');
        }

        return requestId;
      } else {
        _showCreateRequestErrorSnackbar(context, 'Falha ao criar solicitação');
        return null;
      }
    } catch (e) {
      _showCreateRequestErrorSnackbar(context, e.toString());
      return null;
    }
  }

  // Executar cancelamento de solicitação
  static Future<bool> executeCancelRequestFlow({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    try {
      // 1. Verificar se tem solicitação ativa
      final activeRequest = ref.read(activeRequestUnifiedProvider);
      if (activeRequest == null) {
        throw Exception('Nenhuma solicitação ativa para cancelar');
      }

      // 2. Confirmar com o usuário
      final confirmed = await _showCancelConfirmationDialog(context);
      if (!confirmed) return false;

      // 3. Mostrar loading
      _showCancelRequestLoadingSnackbar(context);

      // 4. Cancelar através do provider unificado
      final success = await ref
          .read(unifiedUserStateProvider.notifier)
          .cancelActiveRequest();

      if (success) {
        // 5. Mostrar sucesso
        _showCancelRequestSuccessSnackbar(context);
        await Future.delayed(const Duration(milliseconds: 1000));

        // 6. A navegação não é necessária pois a home já vai detectar a mudança
        return true;
      } else {
        _showCancelRequestErrorSnackbar(
            context, 'Falha ao cancelar solicitação');
        return false;
      }
    } catch (e) {
      _showCancelRequestErrorSnackbar(context, e.toString());
      return false;
    }
  }

  // Verificar e reparar estado inconsistente
  static Future<void> verifyAndRepairState({
    required WidgetRef ref,
    bool forceRefresh = false,
  }) async {
    try {
      final state = ref.read(unifiedUserStateProvider);

      // Se há erro ou estado é inconsistente, forçar refresh
      if (state.hasError || forceRefresh || _isStateInconsistent(state)) {
        print('🔧 Estado inconsistente detectado, reparando...');
        await ref.read(unifiedUserStateProvider.notifier).refreshUserData();
      }
    } catch (e) {
      print('❌ Erro ao reparar estado: $e');
    }
  }

  // Verificar se o estado parece inconsistente
  static bool _isStateInconsistent(UnifiedUserState state) {
    // Verificações básicas de consistência
    if (state.isAuthenticated && state.user == null) return true;
    if (state.flow == AppFlow.hasPet &&
        state.userPets.isEmpty &&
        state.currentPetId == null) return true;
    if (state.flow == AppFlow.hasActiveRequest && state.activeRequest == null)
      return true;

    return false;
  }

  // =====================================================
  // MÉTODOS PRIVADOS PARA UI/UX
  // =====================================================

  static void _showAdoptionLoadingSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Text('Processando adoção...'),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 30), // Longo pois pode demorar
      ),
    );
  }

  static void _showAdoptionSuccessSnackbar(BuildContext context) {
    AppUtils.mediumImpact();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Adoção realizada com sucesso! 🎉'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  static void _showAdoptionErrorSnackbar(BuildContext context, String error) {
    AppUtils.heavyImpact();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text('Erro na adoção: $error')),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  static void _showCreateRequestLoadingSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Text('Criando solicitação...'),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 15),
      ),
    );
  }

  static void _showCreateRequestSuccessSnackbar(
      BuildContext context, String requestId) {
    AppUtils.mediumImpact();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Solicitação criada com sucesso! 🎉'),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'ID: ${requestId.substring(0, 8).toUpperCase()}',
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static void _showCreateRequestErrorSnackbar(
      BuildContext context, String error) {
    AppUtils.heavyImpact();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text('Erro ao criar solicitação: $error')),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  static void _showCancelRequestLoadingSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Text('Cancelando solicitação...'),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 10),
      ),
    );
  }

  static void _showCancelRequestSuccessSnackbar(BuildContext context) {
    AppUtils.lightImpact();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Solicitação cancelada com sucesso'),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
      ),
    );
  }

  static void _showCancelRequestErrorSnackbar(
      BuildContext context, String error) {
    AppUtils.heavyImpact();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text('Erro ao cancelar: $error')),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  static Future<bool> _showCancelConfirmationDialog(
      BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Solicitação'),
        content: const Text(
          'Tem certeza que deseja cancelar sua solicitação de adoção? '
          'Esta ação não pode ser desfeita e você precisará criar uma nova solicitação.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sim, Cancelar'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}

// Provider para o serviço
final adoptionFlowServiceProvider = Provider<AdoptionFlowService>((ref) {
  return AdoptionFlowService.instance;
});
