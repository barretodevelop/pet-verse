// lib/app_widget.dart
// ALTERADO: Uso do novo sistema de roteamento e configurações melhoradas
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/providers/theme_provider.dart';

class MeuPetVirtualApp extends ConsumerWidget {
  const MeuPetVirtualApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'PetVerse',

      // Configuração de tema
      theme: AppTheme.light.copyWith(
        textTheme: GoogleFonts.interTextTheme(AppTheme.light.textTheme),
      ),
      darkTheme: AppTheme.dark.copyWith(
        textTheme: GoogleFonts.interTextTheme(AppTheme.dark.textTheme),
      ),
      themeMode: currentThemeMode,

      // Sistema de roteamento
      routerConfig: router,

      // Configurações de debug e localização
      debugShowCheckedModeBanner: false,

      // Configurações de acessibilidade
      builder: (context, child) {
        return MediaQuery(
          // Configurar tamanho mínimo de texto para acessibilidade
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
                MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2)),
          ),
          child: child!,
        );
      },

      // Configurações de localização (futuro)
      // locale: const Locale('pt', 'BR'),
      // supportedLocales: const [
      //   Locale('pt', 'BR'),
      //   Locale('en', 'US'),
      // ],
    );
  }
}







// voce e um analista senior em desenvolvimento de sotware especialidade em games com adocao de melhores praticas de desenvolvimento e arquitetura clean com altos conhecimentos em design e modelagem de jogos,  para analisar o código e corrigir os erros encontrados  ou incrmentar funcionalidades estaremos usando a estratégia de desenvolvimento incremental.
// Usar Artifacts  para cada arquivo Se o código não couber numa resposta,  usar a função update para adicionar mais partes. para evitar atingir o limite de mensagem.nao precisa enviar feeedback completo da alteração apenas se solicitado , sempre incluir  o nome e caminho do arquivo no inicio e add comentarios se e alteracao ou nova inclusao. enviar a resposta em portugues. 


// analise curta do funcionamento >
// 'ao passar pelo login aplicao deve verificar se o usuario tem um pet cadastrado se tiver vai par a tela de pet  se nao tiver joga na pagina de precisa adotar um pet 
// nessa tera tem 3 opçoes 
 
//  lista onde escolhe um pet ja com uma adocao -- quando aceito a adocao ambos sao avisado e o sista direciona para a tela de pet com uma mensagem do pet
//  cria uma nova adocao  e vai pra lista aguarda o segundo co parent  -  exibe aviso de que o pedido esta na lista e mosra o contador de 5 dias que o pedido fica na lista 
//  ou gerar um codigo para enviar para um amigo  -- e fica esperando o codigo ser incluido la no amigo -  tambem deve ter a opção para o usuario inserir um codigo caso receba


//  analise  a feture  adoption  no projeto para comprendeer os cenarios  

//  quero codigo limpo e nao verboso ajuste esse fluxo no APP





//   Roadmap - Fluxo de Adoção PetVerse
// 📋 Análise Atual
// O projeto já possui uma base sólida para adoção colaborativa, mas o fluxo pós-login precisa ser refinado. Atualmente existe:

// Sistema de autenticação completo
// Providers para adoção colaborativa
// Telas de criação e listagem de adoções
// Sistema de pets Firebase

// 🎯 Objetivo do Fluxo
// Implementar decisão pós-login: Usuário tem pet? → Tela do Pet | Não tem pet? → Tela de Escolha de Adoção

// 🛠️ Fases de Implementação
// Fase 1: Router e Navegação Inteligente
// Arquivos a criar/modificar:

// lib/core/router/auth_guard.dart (NOVO)
// lib/core/router/app_router.dart (MODIFICAR)
// lib/features/splash/splash_screen.dart (MODIFICAR)

// Funcionalidades:

// Guard que verifica se usuário tem pet ativo após login
// Redirecionamento inteligente: /pet ou /adoption-choice
// Middleware de autenticação


// Fase 2: Tela Principal de Escolha de Adoção
// Arquivo a criar:

// lib/features/adoption/screens/adoption_choice_screen.dart (NOVO)

// Layout da Tela:
