// lib/services/ai_service.dart - ENHANCED com 3 Opções de Pets
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:petverse/services/storage_service.dart';

/// ✅ MODELO PARA OPÇÃO DE PET GERADO
class AIGeneratedPetOption {
  final String id;
  final String name;
  final String emoji;
  final String category;
  final String rarity;
  final String description; // Descrição baseada no prompt
  final String? imageUrl; // URL da imagem gerada (se houver)
  final Map<String, int> stats; // Stats sugeridos
  final bool isGenerated; // true = IA real, false = simulado

  AIGeneratedPetOption({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.rarity,
    required this.description,
    this.imageUrl,
    required this.stats,
    required this.isGenerated,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'category': category,
        'rarity': rarity,
        'description': description,
        'imageUrl': imageUrl,
        'stats': stats,
        'isGenerated': isGenerated,
      };

  factory AIGeneratedPetOption.fromJson(Map<String, dynamic> json) =>
      AIGeneratedPetOption(
        id: json['id'],
        name: json['name'],
        emoji: json['emoji'],
        category: json['category'],
        rarity: json['rarity'],
        description: json['description'],
        imageUrl: json['imageUrl'],
        stats: Map<String, int>.from(json['stats']),
        isGenerated: json['isGenerated'] ?? false,
      );
}

/// ✅ RESULTADO DA GERAÇÃO COM 3 OPÇÕES
class AIGenerationResult {
  final List<AIGeneratedPetOption> options;
  final bool hasRealGeneration; // Pelo menos 1 foi gerada com IA real
  final String prompt; // Prompt original
  final DateTime generatedAt;

  AIGenerationResult({
    required this.options,
    required this.hasRealGeneration,
    required this.prompt,
    required this.generatedAt,
  });

  /// Verificar se tem pelo menos 3 opções válidas
  bool get isValid => options.length >= 3;
}

class AIService {
  static const String _stabilityApiUrl =
      'https://api.stability.ai/v1/generation/stable-diffusion-xl-1024-v1-0/text-to-image';
  static const String _fallbackApiUrl =
      'https://api.openai.com/v1/images/generations';

  static bool _enableRealAI = true;
  static String? _stabilityApiKey;
  static String? _openaiApiKey;

  /// ✅ MÉTODO PRINCIPAL ATUALIZADO - Retorna 3 opções
  static Future<AIGenerationResult?> generatePetOptions(String prompt) async {
    try {
      print('🎨 [AIService] Gerando 3 opções para: "$prompt"');

      final options = <AIGeneratedPetOption>[];
      bool hasRealGeneration = false;

      if (_enableRealAI &&
          (_stabilityApiKey?.isNotEmpty == true ||
              _openaiApiKey?.isNotEmpty == true)) {
        // ✅ TENTAR GERAR COM IA REAL (1-3 opções)
        final realOptions = await _generateRealOptions(prompt);
        options.addAll(realOptions);
        hasRealGeneration = realOptions.isNotEmpty;

        print('✅ [AIService] Geradas ${realOptions.length} opções reais');
      }

      // ✅ COMPLETAR COM OPÇÕES SIMULADAS se necessário
      while (options.length < 3) {
        final simulatedOption =
            _generateSimulatedOption(prompt, options.length + 1);
        options.add(simulatedOption);
      }

      print(
          '✅ [AIService] Total: ${options.length} opções (${hasRealGeneration ? 'com' : 'sem'} IA real)');

      return AIGenerationResult(
        options: options.take(3).toList(), // Garantir máximo 3
        hasRealGeneration: hasRealGeneration,
        prompt: prompt,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      print('❌ [AIService] Erro na geração: $e');

      // ✅ FALLBACK TOTAL - 3 opções simuladas
      final fallbackOptions = <AIGeneratedPetOption>[];
      for (int i = 0; i < 3; i++) {
        fallbackOptions.add(_generateSimulatedOption(prompt, i + 1));
      }

      return AIGenerationResult(
        options: fallbackOptions,
        hasRealGeneration: false,
        prompt: prompt,
        generatedAt: DateTime.now(),
      );
    }
  }

  /// ✅ MÉTODO LEGADO MANTIDO PARA BACKWARD COMPATIBILITY
  static Future<bool> generateUniquePet(String prompt) async {
    final result = await generatePetOptions(prompt);
    return result != null && result.isValid;
  }

  /// ✅ GERAR OPÇÕES REAIS COM IA
  static Future<List<AIGeneratedPetOption>> _generateRealOptions(
      String prompt) async {
    final options = <AIGeneratedPetOption>[];

    // ✅ GERAR 3 VARIAÇÕES DO PROMPT
    final promptVariations = _createPromptVariations(prompt);

    for (int i = 0; i < promptVariations.length && i < 3; i++) {
      try {
        final variation = promptVariations[i];
        String? imageUrl;

        // Tentar Stability AI primeiro
        if (_stabilityApiKey?.isNotEmpty == true) {
          imageUrl = await _generateWithStabilityAI(variation.prompt);
        }

        // Fallback para OpenAI se Stability falhar
        if (imageUrl == null && _openaiApiKey?.isNotEmpty == true) {
          imageUrl = await _generateWithOpenAI(variation.prompt);
        }

        if (imageUrl != null) {
          options.add(AIGeneratedPetOption(
            id: 'ai_${DateTime.now().millisecondsSinceEpoch}_$i',
            name: variation.name,
            emoji: variation.emoji,
            category: variation.category,
            rarity: 'único',
            description: variation.description,
            imageUrl: imageUrl,
            stats: variation.stats,
            isGenerated: true,
          ));

          print('✅ [AIService] Opção ${i + 1} gerada com IA real');
        }

        // ✅ TIMEOUT PROTECTION - Não esperar muito tempo
        if (i == 0) {
          await Future.delayed(
              const Duration(milliseconds: 500)); // Delay entre gerações
        }
      } catch (e) {
        print('⚠️ [AIService] Falha na opção ${i + 1}: $e');
        continue; // Tentar próxima opção
      }
    }

    return options;
  }

  /// ✅ CRIAR VARIAÇÕES DO PROMPT PARA DIVERSIDADE
  static List<_PetVariation> _createPromptVariations(String basePrompt) {
    final variations = <_PetVariation>[];
    final random = Random();

    // ✅ ANALISAR PROMPT BASE
    final category = _detectCategoryFromPrompt(basePrompt.toLowerCase());
    final baseName = _generateNameFromPrompt(basePrompt.toLowerCase());

    // ✅ VARIAÇÃO 1: Versão mais fofa
    variations.add(_PetVariation(
      prompt: _enhancePromptForPet(basePrompt + ', extra cute, kawaii style'),
      name: '${baseName}inho', // Diminutivo fofo
      emoji: _getEmojiForCategory(category),
      category: category,
      description: 'Versão super fofa: $basePrompt',
      stats: {
        'happiness': 75 + random.nextInt(15),
        'hunger': 65 + random.nextInt(15),
        'energy': 75 + random.nextInt(15),
        'health': 85 + random.nextInt(15),
      },
    ));

    // ✅ VARIAÇÃO 2: Versão épica
    variations.add(_PetVariation(
      prompt: _enhancePromptForPet(basePrompt + ', epic, majestic, powerful'),
      name: '${baseName} Real', // Versão real/épica
      emoji: _getAlternativeEmoji(category),
      category: category,
      description: 'Versão épica: $basePrompt',
      stats: {
        'happiness': 70 + random.nextInt(20),
        'hunger': 60 + random.nextInt(20),
        'energy': 80 + random.nextInt(15),
        'health': 90 + random.nextInt(10),
      },
    ));

    // ✅ VARIAÇÃO 3: Versão única/especial
    variations.add(_PetVariation(
      prompt:
          _enhancePromptForPet(basePrompt + ', unique, rare, special features'),
      name: '${baseName} Especial', // Versão especial
      emoji: _getSpecialEmoji(category),
      category: category,
      description: 'Versão especial: $basePrompt',
      stats: {
        'happiness': 80 + random.nextInt(15),
        'hunger': 70 + random.nextInt(15),
        'energy': 75 + random.nextInt(20),
        'health': 85 + random.nextInt(15),
      },
    ));

    return variations;
  }

  /// ✅ GERAR OPÇÃO SIMULADA
  static AIGeneratedPetOption _generateSimulatedOption(
      String prompt, int optionNumber) {
    final random = Random();
    final category = _detectCategoryFromPrompt(prompt.toLowerCase());
    final baseName = _generateNameFromPrompt(prompt.toLowerCase());

    final suffixes = ['inho', 'zinho', 'lindo', 'real', 'especial', 'mágico'];
    final suffix = suffixes[random.nextInt(suffixes.length)];

    return AIGeneratedPetOption(
      id: 'sim_${DateTime.now().millisecondsSinceEpoch}_$optionNumber',
      name: '$baseName $suffix',
      emoji: _getRandomEmojiForCategory(category),
      category: category,
      rarity: 'único',
      description: 'Inspirado em: $prompt',
      imageUrl: null, // Sem imagem para simulação
      stats: {
        'happiness': 65 + random.nextInt(25),
        'hunger': 60 + random.nextInt(25),
        'energy': 70 + random.nextInt(25),
        'health': 75 + random.nextInt(25),
      },
      isGenerated: false,
    );
  }

  // ✅ MÉTODOS AUXILIARES EXISTENTES (manter todos)
  static void configureAPIKeys({String? stabilityKey, String? openaiKey}) {
    _stabilityApiKey = stabilityKey;
    _openaiApiKey = openaiKey;
    print('🔧 [AIService] API Keys configuradas');
  }

  static void setRealAIEnabled(bool enabled) {
    _enableRealAI = enabled;
    print('🔧 [AIService] IA Real ${enabled ? 'habilitada' : 'desabilitada'}');
  }

  static Future<String?> _generateWithStabilityAI(String prompt) async {
    if (_stabilityApiKey == null || _stabilityApiKey!.isEmpty) return null;

    try {
      final response = await http
          .post(
            Uri.parse(_stabilityApiUrl),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_stabilityApiKey',
            },
            body: jsonEncode({
              'text_prompts': [
                {'text': prompt, 'weight': 1.0},
                {
                  'text': 'blurry, bad quality, nsfw, violent, scary',
                  'weight': -1.0
                }
              ],
              'cfg_scale': 7,
              'height': 512,
              'width': 512,
              'samples': 1,
              'steps': 20, // ✅ REDUZIDO para ser mais rápido
              'style_preset': 'digital-art',
            }),
          )
          .timeout(const Duration(seconds: 20)); // ✅ TIMEOUT REDUZIDO

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final artifacts = data['artifacts'] as List;

        if (artifacts.isNotEmpty) {
          final base64Image = artifacts[0]['base64'] as String;
          return await _uploadGeneratedImage(base64Image);
        }
      }
    } catch (e) {
      print('❌ [AIService] Erro Stability AI: $e');
    }

    return null;
  }

  static Future<String?> _generateWithOpenAI(String prompt) async {
    if (_openaiApiKey == null || _openaiApiKey!.isEmpty) return null;

    try {
      final response = await http
          .post(
            Uri.parse(_fallbackApiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_openaiApiKey',
            },
            body: jsonEncode({
              'model': 'dall-e-3',
              'prompt': prompt,
              'n': 1,
              'size': '1024x1024',
              'quality': 'standard',
              'style': 'vivid',
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final imageUrl = data['data'][0]['url'] as String;
        return await _downloadAndReupload(imageUrl);
      }
    } catch (e) {
      print('❌ [AIService] Erro OpenAI: $e');
    }

    return null;
  }

  static String _enhancePromptForPet(String userPrompt) {
    return '''
A cute, adorable pet character based on: $userPrompt
Style: cartoon, digital art, kawaii, friendly, colorful
Quality: high quality, detailed, professional illustration
Character: happy, cute, playful expression
Background: simple, clean, transparent or solid color
Safe: family-friendly, no violence, wholesome
'''
        .trim();
  }

  static Future<String?> _uploadGeneratedImage(String base64Image) async {
    try {
      final Uint8List imageBytes = base64Decode(base64Image);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
          '${tempDir.path}/generated_pet_${DateTime.now().millisecondsSinceEpoch}.png');
      await tempFile.writeAsBytes(imageBytes);

      final petId = 'ai_pet_${DateTime.now().millisecondsSinceEpoch}';
      final downloadUrl = await StorageService.uploadPetImage(tempFile, petId);

      await tempFile.delete();
      return downloadUrl;
    } catch (e) {
      print('❌ [AIService] Erro no upload: $e');
      return null;
    }
  }

  static Future<String?> _downloadAndReupload(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) return null;

      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
          '${tempDir.path}/dalle_pet_${DateTime.now().millisecondsSinceEpoch}.png');
      await tempFile.writeAsBytes(response.bodyBytes);

      final petId = 'dalle_pet_${DateTime.now().millisecondsSinceEpoch}';
      final downloadUrl = await StorageService.uploadPetImage(tempFile, petId);

      await tempFile.delete();
      return downloadUrl;
    } catch (e) {
      print('❌ [AIService] Erro no re-upload: $e');
      return null;
    }
  }

  // ✅ HELPER METHODS MELHORADOS
  static String _generateNameFromPrompt(String prompt) {
    final mysticalNames = [
      'Aurora',
      'Nova',
      'Cosmo',
      'Luna',
      'Stella',
      'Orion',
      'Phoenix',
      'Zara'
    ];
    final cuteNames = [
      'Milo',
      'Luna',
      'Charlie',
      'Bella',
      'Max',
      'Lucy',
      'Cooper',
      'Lola'
    ];
    final magicalNames = [
      'Merlin',
      'Elara',
      'Sage',
      'Raven',
      'Iris',
      'Jade',
      'Ruby',
      'Onyx'
    ];

    if (prompt.contains('mágico') ||
        prompt.contains('místico') ||
        prompt.contains('cosmic')) {
      return mysticalNames[Random().nextInt(mysticalNames.length)];
    } else if (prompt.contains('fofo') ||
        prompt.contains('cute') ||
        prompt.contains('kawaii')) {
      return cuteNames[Random().nextInt(cuteNames.length)];
    } else {
      return magicalNames[Random().nextInt(magicalNames.length)];
    }
  }

  static String _detectCategoryFromPrompt(String prompt) {
    if (prompt.contains('dragão') || prompt.contains('dragon')) return 'dragão';
    if (prompt.contains('unicórnio') || prompt.contains('unicorn'))
      return 'místico';
    if (prompt.contains('gato') || prompt.contains('cat')) return 'felino';
    if (prompt.contains('cachorro') || prompt.contains('dog')) return 'canino';
    if (prompt.contains('pássaro') || prompt.contains('bird')) return 'ave';
    if (prompt.contains('peixe') || prompt.contains('fish')) return 'aquático';
    if (prompt.contains('robô') || prompt.contains('robot')) return 'digital';
    if (prompt.contains('cristal') || prompt.contains('crystal'))
      return 'elemental';
    return 'único';
  }

  static String _getEmojiForCategory(String category) {
    switch (category) {
      case 'dragão':
        return '🐉';
      case 'místico':
        return '🦄';
      case 'felino':
        return '🐱';
      case 'canino':
        return '🐕';
      case 'ave':
        return '🦅';
      case 'aquático':
        return '🐠';
      case 'digital':
        return '🤖';
      case 'elemental':
        return '💎';
      default:
        return '✨';
    }
  }

  static String _getAlternativeEmoji(String category) {
    switch (category) {
      case 'dragão':
        return '🐲';
      case 'místico':
        return '🌟';
      case 'felino':
        return '🦁';
      case 'canino':
        return '🐺';
      case 'ave':
        return '🦜';
      case 'aquático':
        return '🐙';
      case 'digital':
        return '👾';
      case 'elemental':
        return '🔮';
      default:
        return '⭐';
    }
  }

  static String _getSpecialEmoji(String category) {
    switch (category) {
      case 'dragão':
        return '🔥';
      case 'místico':
        return '✨';
      case 'felino':
        return '👑';
      case 'canino':
        return '⚡';
      case 'ave':
        return '🌈';
      case 'aquático':
        return '🌊';
      case 'digital':
        return '💫';
      case 'elemental':
        return '💖';
      default:
        return '🎭';
    }
  }

  static String _getRandomEmojiForCategory(String category) {
    final options = [
      _getEmojiForCategory(category),
      _getAlternativeEmoji(category),
      _getSpecialEmoji(category),
    ];
    return options[Random().nextInt(options.length)];
  }

  static Future<bool> checkAIServiceHealth() async {
    try {
      if (_stabilityApiKey != null && _stabilityApiKey!.isNotEmpty) {
        final response = await http.get(
          Uri.parse('https://api.stability.ai/v1/user/account'),
          headers: {'Authorization': 'Bearer $_stabilityApiKey'},
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          print('✅ [AIService] Stability AI funcionando');
          return true;
        }
      }

      print('⚠️ [AIService] APIs não disponíveis, usando fallback');
      return false;
    } catch (e) {
      print('❌ [AIService] Health check falhou: $e');
      return false;
    }
  }
}

/// ✅ CLASSE AUXILIAR PARA VARIAÇÕES
class _PetVariation {
  final String prompt;
  final String name;
  final String emoji;
  final String category;
  final String description;
  final Map<String, int> stats;

  _PetVariation({
    required this.prompt,
    required this.name,
    required this.emoji,
    required this.category,
    required this.description,
    required this.stats,
  });
}
