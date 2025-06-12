import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_notifier.dart'; // Importa o appServiceProvider

class AppBottomSheet extends ConsumerWidget {
  final bool show;
  final VoidCallback onClose;
  final String title;
  final Widget children;
  final bool fullHeight; // Se a folha deve ocupar a maior parte da tela

  const AppBottomSheet({
    super.key,
    required this.show,
    required this.onClose,
    required this.title,
    required this.children,
    this.fullHeight = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(appServiceProvider.select((state) => state.isDark));

    if (!show) {
      return const SizedBox.shrink(); // Não mostra nada se 'show' for false
    }

    return Stack(
      children: [
        // Fundo semi-transparente que fecha a folha ao clicar
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            child: Container(
              color: Colors.black54, // bg-black/50
            ),
          ),
        ),
        // A folha deslizante em si
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300), // Tempo da animação
          curve: Curves.easeOut, // Curva da animação (slide-up)
          left: 0,
          right: 0,
          bottom: show ? 0 : -MediaQuery.of(context).size.height, // Desliza para cima/baixo
          child: SafeArea(
            // Garante que a UI não seja obstruída pela barra de navegação/gestos
            child: Container(
              height: fullHeight ? MediaQuery.of(context).size.height * 0.9 : null, // 90vh
              constraints: BoxConstraints(
                maxHeight: fullHeight
                    ? MediaQuery.of(context).size.height * 0.9
                    : MediaQuery.of(context).size.height * 0.8, // max-h-[80vh]
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2D3748) : Colors.white, // bg-gray-800 ou bg-white
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24.0), // rounded-t-3xl
                  topRight: Radius.circular(24.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ), // shadow-2xl
                ],
              ),
              padding: const EdgeInsets.all(24.0), // p-6
              child: Column(
                mainAxisSize: fullHeight
                    ? MainAxisSize.max
                    : MainAxisSize.min, // Ocupa o máximo ou o mínimo de espaço vertical
                children: [
                  // Cabeçalho da folha
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0), // mb-6
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 20.0, // text-xl
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.grey[800],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close), // Ícone de fechar
                          color: isDark ? Colors.grey[300] : Colors.grey[600],
                          onPressed: onClose,
                          style: IconButton.styleFrom(
                            backgroundColor: isDark
                                ? Colors.grey[700]
                                : Colors.grey[100], // bg-gray-700 ou bg-gray-100
                            shape: const CircleBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Conteúdo da folha
                  Expanded(
                    child: SingleChildScrollView(
                      // Permite rolagem se o conteúdo for grande
                      child: children,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
