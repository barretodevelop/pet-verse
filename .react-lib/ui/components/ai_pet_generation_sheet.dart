import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Para LucideIcons
import '../../core/app_notifier.dart'; // Para acessar o appServiceProvider
import 'bottom_sheet.dart'; // Para o BottomSheet base

class AIPetGenerationSheet extends ConsumerStatefulWidget {
  final bool show;
  final VoidCallback onClose;

  const AIPetGenerationSheet({super.key, required this.show, required this.onClose});

  @override
  ConsumerState<AIPetGenerationSheet> createState() => _AIPetGenerationSheetState();
}

class _AIPetGenerationSheetState extends ConsumerState<AIPetGenerationSheet> {
  final TextEditingController _promptController = TextEditingController();
  bool _generating = false;

  final List<String> _promptSuggestions = [
    'Um dragão fofo de cristal azul',
    'Gato ninja com poderes mágicos',
    'Unicórnio cósmico das estrelas',
    'Cachorro robótico futurista',
    'Fenix de fogo dourado',
    'Panda samurai guerreiro'
  ];

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _handleGenerate() async {
    if (_promptController.text.trim().isEmpty) return;

    setState(() {
      _generating = true;
    });

    final appService = ref.read(appServiceProvider.notifier);
    final success = await appService.generateUniquePet(_promptController.text.trim());

    if (mounted) {
      setState(() {
        _generating = false;
      });
      if (success) {
        _promptController.clear();
        widget.onClose(); // Fecha a folha ao gerar com sucesso
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiConfig = ref.watch(appServiceProvider.select((state) => state.aiConfig));
    final isDark = ref.watch(appServiceProvider.select((state) => state.isDark));
    final gems = ref.watch(appServiceProvider.select((state) => state.gems));
    final appService = ref.read(appServiceProvider.notifier); // Para setAIConfig

    return AppBottomSheet(
      show: widget.show,
      onClose: widget.onClose,
      title: '🎨 Gerar Pet Único',
      fullHeight: true,
      children: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Informações de Custo
          Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.shade100,
                  Colors.blue.shade100,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pet Único com IA',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade800, // Corrected
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Crie um pet personalizado usando inteligência artificial',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.purple.shade600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade500,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.gem, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      const Text(
                        '10',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Configuração da API (se não estiver habilitada)
          if (!aiConfig.enabled)
            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade700 : Colors.yellow.shade50, // Corrected
                borderRadius: BorderRadius.circular(16.0),
                border: Border(
                  left: BorderSide(
                    color: Colors.yellow.shade500, // Corrected
                    width: 4.0,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚙️ Configuração da IA',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.yellow.shade800, // Corrected
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Configure a API de IA para gerar pets únicos.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey.shade300 : Colors.yellow.shade700, // Corrected
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'URL da API de IA',
                      hintStyle: TextStyle(
                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade400), // Corrected
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100, // Corrected
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                            color:
                                isDark ? Colors.grey.shade600 : Colors.grey.shade300), // Corrected
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.purple.shade500),
                      ),
                    ),
                    style:
                        TextStyle(color: isDark ? Colors.white : Colors.grey.shade800), // Corrected
                    onChanged: (value) {
                      appService.setAIConfig(aiConfig.copyWith(apiUrl: value));
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Chave da API',
                      hintStyle: TextStyle(
                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade400), // Corrected
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100, // Corrected
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                            color:
                                isDark ? Colors.grey.shade600 : Colors.grey.shade300), // Corrected
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.purple.shade500),
                      ),
                    ),
                    style:
                        TextStyle(color: isDark ? Colors.white : Colors.grey.shade800), // Corrected
                    onChanged: (value) {
                      appService.setAIConfig(aiConfig.copyWith(apiKey: value));
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: aiConfig.apiUrl.isNotEmpty && aiConfig.apiKey.isNotEmpty
                        ? () {
                            appService.setAIConfig(aiConfig.copyWith(enabled: true));
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade500,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    child: const Center(
                      child: Text(
                        'Salvar Configuração',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Campo de Prompt
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Descreva seu pet ideal:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.grey.shade800, // Corrected
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _promptController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Ex: Um dragão fofo com asas de borboleta e olhos brilhantes...',
                      hintStyle: TextStyle(
                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade400), // Corrected
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade700 : Colors.white, // Corrected
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide: BorderSide(
                            color:
                                isDark ? Colors.grey.shade600 : Colors.grey.shade200), // Corrected
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide: BorderSide(color: Colors.purple.shade500),
                      ),
                      contentPadding: const EdgeInsets.all(16.0),
                    ),
                    style:
                        TextStyle(color: isDark ? Colors.white : Colors.grey.shade800), // Corrected
                  ),
                  const SizedBox(height: 16),

                  // Sugestões de Prompt
                  Text(
                    '💡 Sugestões:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade700, // Corrected
                    ),
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 2.5, // Proporção para botões de sugestão
                    ),
                    itemCount: _promptSuggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = _promptSuggestions[index];
                      return ElevatedButton(
                        onPressed: () {
                          _promptController.text = suggestion;
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDark ? Colors.grey.shade700 : Colors.grey.shade100, // Corrected
                          foregroundColor:
                              isDark ? Colors.grey.shade300 : Colors.grey.shade700, // Corrected
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                          elevation: 0,
                        ),
                        child: Text(
                          suggestion,
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Botão Gerar Pet Único
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: (_promptController.text.trim().isEmpty ||
                    gems < 10 ||
                    _generating ||
                    !aiConfig.enabled)
                ? null
                : _handleGenerate,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              elevation: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_generating)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                else
                  const Icon(LucideIcons.wand2, size: 20),
                const SizedBox(width: 8),
                Text(
                  _generating ? 'Gerando...' : 'Gerar Pet Único',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (!_generating) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.gem, color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        const Text(
                          '10',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Você tem: $gems gemas',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, // Corrected
              ),
            ),
          ),
        ],
      ),
    );
  }
}
