// File: lib/core/helpers/adoption_modal_helper.dart
// Helper para padronizar chamadas do novo Enhanced Adoption Modal

import 'package:flutter/material.dart';
import 'package:petverse/presentation/widgets/pet/enhanced_adoption_modal.dart';

class AdoptionModalHelper {
  /// Mostra o modal de adoção otimizado com UX rica
  static Future<void> showEnhancedAdoptionModal(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      builder: (context) => const EnhancedAdoptionModal(),
    );
  }

  /// Mostra o modal com animação customizada (opcional)
  static Future<void> showEnhancedAdoptionModalWithAnimation(
    BuildContext context, {
    Duration? duration,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const EnhancedAdoptionModal();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: duration ?? const Duration(milliseconds: 500),
        barrierDismissible: true,
        barrierColor: Colors.black54,
        opaque: false,
      ),
    );
  }
}

// MIGRATION GUIDE:
// ================
// 
// BEFORE (nos arquivos existentes):
// showModalBottomSheet(
//   context: context,
//   builder: (context) => BasicAdoptionModal(),
// );
//
// AFTER (substituir por):
// AdoptionModalHelper.showEnhancedAdoptionModal(context);
//
// ARQUIVOS PARA ATUALIZAR:
// 1. lib/presentation/screens/home/pet/new_pet_screen.dart
//    - Método: _showAdoptionOptions() -> linha ~200
//    - Substituir showModalBottomSheet básico
//
// 2. lib/presentation/screens/home/pet/enhanced_pet_screen.dart  
//    - Método: _buildNoPetsState() -> botão "Adopt Pet"
//    - Adicionar import e substituir navegação
//
// 3. lib/presentation/screens/home/dashboard/dashboard_screen.dart
//    - Se houver botão de adoção no dashboard
//
// EXEMPLO DE INTEGRAÇÃO NO NEW_PET_SCREEN.dart:
// 
// // Adicionar import no topo:
// import 'package:petverse/core/helpers/adoption_modal_helper.dart';
//
// // Substituir método _showAdoptionOptions por:
// void _showAdoptionOptions(BuildContext context) {
//   AdoptionModalHelper.showEnhancedAdoptionModal(context);
// }
//
// EXEMPLO DE INTEGRAÇÃO NO ENHANCED_PET_SCREEN.dart:
//
// // No método _buildNoPetsState, substituir onPressed do botão por:
// onPressed: () => AdoptionModalHelper.showEnhancedAdoptionModal(context),
//
// VANTAGENS DA INTEGRAÇÃO:
// ✅ UX rica com abas Individual vs Colaborativa
// ✅ Animações nativas e responsivas  
// ✅ Integração com todos os providers existentes
// ✅ Maintain backward compatibility
// ✅ Fácil migração incremental
// ✅ Design game-first consistente