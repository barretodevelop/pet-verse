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



'ao passar pelo login aplicao deve verificar se o usuario tem um pet cadastrado se tiver vai par a tela de pet  se nao tiver joga na pagina de precisa adotar um pet 
nessa tera tem 3 opçoes 
 
 lista onde escolhe um pet ja com uma adocao -- quando aceito a adocao ambos sao avisado e o sista direciona para a tela de pet com uma mensagem do pet
 cria uma nova adocao  e vai pra lista aguarda o segundo co parent  -  exibe aviso de que o pedido esta na lista e mosra o contador de 5 dias que o pedido fica na lista 
 ou gerar um codigo para enviar para um amigo  -- e fica esperando o codigo ser incluido la no amigo -  tambem deve ter a opção para o usuario inserir um codigo caso receba


 analise  a feture  adoption  no projeto para comprendeer os cenarios  

 quero codigo limpo e nao verboso ajuste esse fluxo no APP