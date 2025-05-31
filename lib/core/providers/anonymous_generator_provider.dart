// lib/core/providers/anonymous_generator_provider.dart

import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/model/user_model.dart';

// Provider para gerar dados anônimos do usuário
final anonymousUserGeneratorProvider = Provider<AnonymousUserGenerator>((ref) {
  return AnonymousUserGenerator();
});

class AnonymousUserGenerator {
  static final Random _random = Random();

  // Codinomes anônimos
  static const List<String> _guardianNames = [
    'Guardian Azul',
    'Protetor Rosa',
    'Anjo Verde',
    'Sombra Violeta',
    'Mestre Dourado',
    'Guerreiro Coral',
    'Sábio Prateado',
    'Ninja Turquesa',
    'Dragão Carmesim',
    'Fênix Branca',
    'Lobo Cinza',
    'Águia Dourada',
    'Tigre Laranja',
    'Pantera Negra',
    'Urso Marrom',
    'Raposa Vermelha',
    'Leão Amarelo',
    'Tubarão Azul',
    'Cobra Verde',
    'Falcão Preto'
  ];

  // Cores temáticas
  static const List<int> _themeColors = [
    0xFF3B82F6, // Azul
    0xFFEC4899, // Rosa
    0xFF10B981, // Verde
    0xFF8B5CF6, // Violeta
    0xFFF59E0B, // Dourado
    0xFFEF4444, // Vermelho
    0xFF06B6D4, // Ciano
    0xFF84CC16, // Lima
    0xFFF97316, // Laranja
    0xFF6366F1, // Índigo
  ];

  // Tags de personalidade
  static const List<List<String>> _personalityGroups = [
    ['dedicado', 'organizado', 'carinhoso'],
    ['aventureiro', 'energético', 'divertido'],
    ['tranquilo', 'paciente', 'sábio'],
    ['criativo', 'artístico', 'expressivo'],
    ['protetor', 'leal', 'confiável'],
    ['curioso', 'investigativo', 'inteligente'],
    ['social', 'amigável', 'comunicativo'],
    ['independente', 'forte', 'determinado'],
    ['compassivo', 'empático', 'acolhedor'],
    ['otimista', 'alegre', 'positivo'],
  ];

  // Mensagens codificadas por nível
  static const Map<int, List<String>> _messagesByLevel = {
    1: [
      'Iniciante procura mentor experiente para primeira missão',
      'Novo guardião busca parceiro para aprender juntos',
      'Primeira adoção colaborativa, preciso de orientação'
    ],
    5: [
      'Guardião em desenvolvimento busca parceiro equilibrado',
      'Experiência crescente, pronto para colaboração séria',
      'Cinco missões completas, busco próximo desafio'
    ],
    10: [
      'Guardião experiente oferece conhecimento e parceria',
      'Veterano busca colaborador dedicado para missão especial',
      'Dez níveis de experiência, pronto para grandes desafios'
    ],
    15: [
      'Mestre guardião procura parceiro para missão complexa',
      'Experiência avançada disponível para colaboração elite',
      'Quinze níveis conquistados, busco parceiro à altura'
    ],
    20: [
      'Lenda dos guardiões oferece sabedoria e partnership',
      'Vinte níveis de maestria, aceito apenas os melhores',
      'Guardião supremo busca sucessor digno para colaboração'
    ]
  };

  // Regiões disponíveis
  static const List<String> _regions = [
    'Zona Sul - SP',
    'Centro - RJ',
    'Zona Norte - SP',
    'Zona Oeste - RJ',
    'Barra da Tijuca - RJ',
    'Vila Madalena - SP',
    'Copacabana - RJ',
    'Pinheiros - SP',
    'Leblon - RJ',
    'Moema - SP',
  ];

  /// Gera dados anônimos para o usuário
  AnonymousUserData generateAnonymousData(UserModel user) {
    // Selecionar codename baseado no nível
    final codenameIndex =
        (user.level + user.id.hashCode) % _guardianNames.length;
    final codename = _guardianNames[codenameIndex];

    // Selecionar cor baseada no usuário
    final colorIndex = user.id.hashCode % _themeColors.length;
    final colorTheme = _themeColors[colorIndex];

    // Selecionar personalidade baseada no nível
    final personalityIndex = user.level % _personalityGroups.length;
    final personalityTags = _personalityGroups[personalityIndex];

    // Gerar mensagem baseada no nível
    final levelGroup = _getLevelGroup(user.level);
    final messages = _messagesByLevel[levelGroup]!;
    final messageIndex = user.id.hashCode % messages.length;
    final codedMessage = messages[messageIndex];

    // Selecionar região
    final regionIndex = user.createdAt.day % _regions.length;
    final region = _regions[regionIndex];

    return AnonymousUserData(
      codename: codename,
      colorTheme: colorTheme,
      personalityTags: personalityTags,
      codedMessage: codedMessage,
      region: region,
    );
  }

  int _getLevelGroup(int level) {
    if (level >= 20) return 20;
    if (level >= 15) return 15;
    if (level >= 10) return 10;
    if (level >= 5) return 5;
    return 1;
  }

  /// Gera dados mock para testes
  AnonymousUserData generateMockData() {
    return AnonymousUserData(
      codename: _guardianNames[_random.nextInt(_guardianNames.length)],
      colorTheme: _themeColors[_random.nextInt(_themeColors.length)],
      personalityTags:
          _personalityGroups[_random.nextInt(_personalityGroups.length)],
      codedMessage:
          _messagesByLevel[10]![_random.nextInt(_messagesByLevel[10]!.length)],
      region: _regions[_random.nextInt(_regions.length)],
    );
  }
}

class AnonymousUserData {
  final String codename;
  final int colorTheme;
  final List<String> personalityTags;
  final String codedMessage;
  final String region;

  const AnonymousUserData({
    required this.codename,
    required this.colorTheme,
    required this.personalityTags,
    required this.codedMessage,
    required this.region,
  });

  Map<String, dynamic> toJson() {
    return {
      'codename': codename,
      'colorTheme': colorTheme,
      'personalityTags': personalityTags,
      'codedMessage': codedMessage,
      'region': region,
    };
  }

  @override
  String toString() {
    return 'AnonymousUserData(codename: $codename, colorTheme: $colorTheme, region: $region)';
  }
}
