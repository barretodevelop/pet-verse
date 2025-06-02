// lib/main.dart
// ALTERADO: Inicialização completa com Firebase e tratamento de erros
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_widget.dart';

Future<void> main() async {
  // Garantir que o Flutter esteja inicializado
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Configurar orientação da tela
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Configurar cor da barra de status
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // Inicializar Firebase
    debugPrint('🔥 Inicializando Firebase...');
    await Firebase.initializeApp(
        // Descomentar quando tiver firebase_options.dart configurado
        // options: DefaultFirebaseOptions.currentPlatform,
        );
    debugPrint('✅ Firebase inicializado com sucesso');

    // Configurar listeners globais de erro
    FlutterError.onError = (FlutterErrorDetails details) {
      debugPrint('❌ Erro Flutter: ${details.exception}');
      debugPrint('Stack trace: ${details.stack}');

      // Em produção, enviar para serviço de crash reporting
      // FirebaseCrashlytics.instance.recordFlutterError(details);
    };

    // Executar aplicação
    runApp(
      ProviderScope(
        observers: [
          // Observer para debug em desenvolvimento
          if (!kReleaseMode) _ProviderLogger(),
        ],
        child: const MeuPetVirtualApp(),
      ),
    );
  } catch (error, stackTrace) {
    debugPrint('❌ Erro crítico na inicialização da aplicação: $error');
    debugPrint('Stack trace: $stackTrace');

    // Mostrar tela de erro crítico
    runApp(
      MaterialApp(
        home: _CriticalErrorScreen(
          error: error.toString(),
          stackTrace: stackTrace.toString(),
        ),
      ),
    );
  }
}

// Observer para debug dos providers (apenas em desenvolvimento)
class _ProviderLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    if (newValue is AsyncError) {
      debugPrint(
          '🔴 Provider Error [${provider.name ?? provider.runtimeType}]: ${newValue.error}');
    } else if (newValue is AsyncLoading) {
      debugPrint(
          '🟡 Provider Loading [${provider.name ?? provider.runtimeType}]');
    } else if (newValue is AsyncData) {
      debugPrint(
          '🟢 Provider Success [${provider.name ?? provider.runtimeType}]');
    }
  }

  @override
  void providerDidFail(
    ProviderBase provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    debugPrint(
        '💥 Provider Failed [${provider.name ?? provider.runtimeType}]: $error');
  }
}

// Tela de erro crítico
class _CriticalErrorScreen extends StatelessWidget {
  final String error;
  final String stackTrace;

  const _CriticalErrorScreen({
    required this.error,
    required this.stackTrace,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        title: const Text('Erro Crítico'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'Erro na Inicialização',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'O aplicativo encontrou um erro crítico durante a inicialização.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detalhes do erro:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    child: Text(
                      error,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Tentar reiniciar a aplicação
                    main();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Tentar Novamente'),
                ),
                OutlinedButton(
                  onPressed: () {
                    // Copiar erro para clipboard
                    Clipboard.setData(ClipboardData(
                      text: 'Erro: $error\n\nStack Trace:\n$stackTrace',
                    ));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Erro copiado para área de transferência'),
                      ),
                    );
                  },
                  child: const Text('Copiar Erro'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Constantes globais para configuração
const bool kReleaseMode = bool.fromEnvironment('dart.vm.product');
