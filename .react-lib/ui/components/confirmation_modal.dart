import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Para o ícone Gem (LucideIcons)
import '../../core/app_notifier.dart'; // Importa o appServiceProvider

class ConfirmationModal extends ConsumerWidget {
  final bool show;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final String title;
  final String message;
  final int? cost; // Custo opcional em gemas

  const ConfirmationModal({
    super.key,
    required this.show,
    required this.onConfirm,
    required this.onCancel,
    required this.title,
    required this.message,
    this.cost,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(appServiceProvider.select((state) => state.isDark));
    final gems = ref.watch(appServiceProvider.select((state) => state.gems));

    if (!show) {
      return const SizedBox.shrink(); // Não mostra nada se 'show' for false
    }

    return Stack(
      children: [
        // Fundo semi-transparente
        Positioned.fill(
          child: GestureDetector(
            onTap: onCancel, // Permite fechar clicando fora do modal
            child: Container(
              color: Colors.black54, // bg-black/50
            ),
          ),
        ),
        // Modal em si
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0), // p-6
            child: Material(
              color: isDark ? const Color(0xFF2D3748) : Colors.white, // bg-gray-800 ou bg-white
              borderRadius: BorderRadius.circular(24.0), // rounded-3xl
              elevation: 12.0, // sombra
              child: Padding(
                padding: const EdgeInsets.all(24.0), // p-6
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Ocupa o mínimo de espaço
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18.0, // text-lg
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8.0), // mb-2
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.0, // text-sm
                        color: isDark ? Colors.grey[300] : Colors.grey[600],
                      ),
                    ),
                    if (cost != null) ...[
                      const SizedBox(height: 16.0), // mb-4
                      Container(
                        padding: const EdgeInsets.all(12.0), // p-3
                        decoration: BoxDecoration(
                          color: Colors.purple.shade100, // bg-purple-100
                          borderRadius: BorderRadius.circular(16.0), // rounded-2xl
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.gem, color: Colors.purple[500], size: 20), // w-5 h-5
                            const SizedBox(width: 8.0), // mr-2
                            Text(
                              'Custo: $cost gemas',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.purple[700],
                              ),
                            ),
                            const SizedBox(width: 8.0), // ml-2
                            Text(
                              '(Você tem: $gems)',
                              style: TextStyle(
                                fontSize: 12.0, // text-sm
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16.0), // mb-4
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onCancel,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? Colors.grey[700]
                                  : Colors.grey[100], // bg-gray-700 ou bg-gray-100
                              foregroundColor: isDark
                                  ? Colors.grey[300]
                                  : Colors.grey[700], // text-gray-300 ou text-gray-700
                              padding: const EdgeInsets.symmetric(vertical: 12.0), // py-3
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0), // rounded-2xl
                              ),
                              elevation: 0,
                            ),
                            child: const Text('Cancelar',
                                style: TextStyle(fontWeight: FontWeight.w600)), // font-semibold
                          ),
                        ),
                        const SizedBox(width: 12.0), // space-x-3
                        Expanded(
                          child: ElevatedButton(
                            onPressed: (cost != null && gems < cost!)
                                ? null
                                : onConfirm, // Desabilita se não tiver gemas
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple[500], // bg-purple-500
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12.0), // py-3
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0), // rounded-2xl
                              ),
                              elevation: 4.0, // sombra
                            ).copyWith(
                              // Controla a opacidade do botão desabilitado
                              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.disabled)) {
                                    return Colors.purple[500]?.withOpacity(0.5); // opacity-50
                                  }
                                  return Colors.purple[500];
                                },
                              ),
                            ),
                            child: const Text('Confirmar',
                                style: TextStyle(fontWeight: FontWeight.w600)), // font-semibold
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
