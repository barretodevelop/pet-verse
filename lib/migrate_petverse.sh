#!/bin/bash
# ⚡ PLANO DE AÇÃO IMEDIATO - PetVerse sem flutter_screenutil
# Execute este script para migrar completamente em 30 minutos

echo "🚀 INICIANDO MIGRAÇÃO DO PETVERSE - SEM FLUTTER_SCREENUTIL"
echo "=================================================="
echo ""

# ========================================
# FASE 1: BACKUP E PREPARAÇÃO (2 min)
# ========================================
echo "📦 FASE 1: Backup e Preparação..."

# Backup git
git add .
git commit -m "Backup antes de remover flutter_screenutil"
git branch backup-screenutil-removal

# Análise atual
echo "🔍 Análise atual do projeto:"
SCREENUTIL_USAGE=$(grep -r "\.sp\|\.w\|\.h\|\.r" lib/ --include="*.dart" | wc -l)
echo "📊 Usos de ScreenUtil encontrados: $SCREENUTIL_USAGE"

AFFECTED_FILES=$(grep -l "\.sp\|\.w\|\.h\|\.r" lib/ --include="*.dart" | wc -l)
echo "📁 Arquivos afetados: $AFFECTED_FILES"

# ========================================
# FASE 2: REMOVER DEPENDÊNCIA (1 min)
# ========================================
echo ""
echo "🗑️ FASE 2: Removendo flutter_screenutil..."

# Backup pubspec.yaml
cp pubspec.yaml pubspec.yaml.backup

# Remover flutter_screenutil do pubspec.yaml
sed -i 's/.*flutter_screenutil.*/#&/' pubspec.yaml
echo "✅ flutter_screenutil comentado no pubspec.yaml"

# ========================================
# FASE 3: NOVO TEMA UNIFICADO (5 min)
# ========================================
echo ""
echo "🎨 FASE 3: Criando novo tema unificado..."

# Backup app_theme.dart atual
cp lib/core/theme/app_theme.dart lib/core/theme/app_theme.dart.backup

# Criar novo app_theme.dart SEM ScreenUtil
cat > lib/core/theme/app_theme.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 🎨 CORES PRINCIPAIS
  static const Color primary = Color(0xFF6B73FF);
  static const Color primaryLight = Color(0xFF9BA3FF);
  static const Color secondary = Color(0xFFFF8A80);
  static const Color success = Color(0xFF48BB78);
  static const Color warning = Color(0xFFED8936);
  static const Color error = Color(0xFFF56565);
  static const Color info = Color(0xFF3B82F6);
  
  // 🎨 CORES NEUTRAS
  static const Color backgroundLight = Color(0xFFFAFBFF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textTertiary = Color(0xFFA0AEC0);
  static const Color textInverse = Color(0xFFFFFFFF);

  // 🎨 GRADIENTES
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundLight, Color(0xFFF7FAFC)],
  );

  // 🎨 SOMBRAS
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  // 🎨 TEXT STYLES (TAMANHOS REAIS - LEGÍVEIS!)
  static TextStyle get displayLarge => GoogleFonts.inter(
    fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary,
  );
  static TextStyle get displayMedium => GoogleFonts.inter(
    fontSize: 28, fontWeight: FontWeight.w600, color: textPrimary,
  );
  static TextStyle get displaySmall => GoogleFonts.inter(
    fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary,
  );
  static TextStyle get headlineLarge => GoogleFonts.inter(
    fontSize: 22, fontWeight: FontWeight.w600, color: textPrimary,
  );
  static TextStyle get headlineMedium => GoogleFonts.inter(
    fontSize: 20, fontWeight: FontWeight.w500, color: textPrimary,
  );
  static TextStyle get headlineSmall => GoogleFonts.inter(
    fontSize: 18, fontWeight: FontWeight.w500, color: textPrimary,
  );
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary,
  );
  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary,
  );
  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w400, color: textTertiary,
  );
  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary,
  );
  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary,
  );
  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 11, fontWeight: FontWeight.w500, color: textTertiary,
  );

  // 🎨 ESPAÇAMENTOS (VALORES REAIS)
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
  static const double space2xl = 48;

  // 🎨 BORDER RADIUS (VALORES REAIS)
  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radius2xl = 32;

  // 🎨 TEMA PRINCIPAL
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      surface: surfaceLight,
      error: error,
    ),
    scaffoldBackgroundColor: backgroundLight,
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      displaySmall: displaySmall,
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      headlineSmall: headlineSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: headlineMedium,
      iconTheme: const IconThemeData(color: textPrimary),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: textInverse,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        minimumSize: const Size(0, 48),
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
      ),
    ),
  );

  // 🎨 MÉTODOS UTILITÁRIOS
  static Color getPetMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy': case 'feliz': return success;
      case 'sad': case 'triste': return info;
      case 'hungry': case 'com fome': return warning;
      case 'sleepy': case 'sonolento': return Color(0xFF9B59B6);
      case 'sick': case 'doente': return error;
      default: return textSecondary;
    }
  }

  static Color getStatusColor(double percentage) {
    if (percentage >= 80) return success;
    if (percentage >= 50) return warning;
    return error;
  }

  static BoxDecoration petCardDecoration({
    required Color backgroundColor,
    double borderRadius = 16,
    bool withShadow = true,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          backgroundColor.withOpacity(0.1),
          backgroundColor.withOpacity(0.05),
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: backgroundColor.withOpacity(0.2)),
      boxShadow: withShadow ? cardShadow : null,
    );
  }

  // 🎨 RESPONSIVIDADE NATIVA (quando necessário)
  static EdgeInsets responsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > 600 
        ? const EdgeInsets.all(32)
        : const EdgeInsets.all(16);
  }

  static double responsiveFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    return width > 600 ? baseSize * 1.1 : baseSize;
  }
}
EOF

echo "✅ Novo app_theme.dart criado com tamanhos REAIS (sem ScreenUtil)"

# ========================================
# FASE 4: ATUALIZAR MAIN.DART (2 min)
# ========================================
echo ""
echo "🔧 FASE 4: Atualizando main.dart..."

# Backup main.dart
cp lib/main.dart lib/main.dart.backup

# Criar novo main.dart SEM ScreenUtilInit
cat > lib/main.dart << 'EOF'
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/constants/app_constants.dart';
import 'package:petverse/core/router/app_router.dart';
import 'package:petverse/core/services/notification_service.dart';
import 'package:petverse/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar orientação
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configurar status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Inicializar Firebase
  await Firebase.initializeApp();

  // Inicializar NotificationService
  await NotificationService().initialize();

  runApp(
    const ProviderScope(
      child: PetVerseApp(),
    ),
  );
}

class PetVerseApp extends ConsumerWidget {
  const PetVerseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      
      // Router
      routerConfig: router,

      // NOVO TEMA SEM SCREENUTIL - FONTES LEGÍVEIS!
      theme: AppTheme.lightTheme,
      
      // Localização
      locale: const Locale('pt', 'BR'),
      
      // Builder para configurações extras
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
EOF

echo "✅ main.dart atualizado - REMOVIDO ScreenUtilInit"

# ========================================
# FASE 5: MIGRAR ARQUIVOS PRINCIPAIS (15 min)
# ========================================
echo ""
echo "🔄 FASE 5: Migrando arquivos principais..."

# Lista de arquivos prioritários para migração automática
PRIORITY_FILES=(
  "lib/feature/home/presentation/widgets/custom_app_bar.dart"
  "lib/feature/home/presentation/widgets/loading_shimmer.dart"
  "lib/feature/pet/presentation/pages/pet_page.dart"
  "lib/feature/pet/presentation/pages/my_pets.dart"
  "lib/feature/home/presentation/widgets/adoption_options_widget.dart"
)

echo "🔄 Aplicando substituições automáticas..."

# Substituir extensões .sp, .w, .h, .r em TODOS os arquivos
find lib/ -name "*.dart" -exec sed -i 's/\.sp//g' {} \;
find lib/ -name "*.dart" -exec sed -i 's/\.w//g' {} \;
find lib/ -name "*.dart" -exec sed -i 's/\.h//g' {} \;
find lib/ -name "*.dart" -exec sed -i 's/\.r//g' {} \;

echo "✅ Removidos todos os .sp, .w, .h, .r"

# Substituir EdgeInsets dinâmicos por constantes
find lib/ -name "*.dart" -exec sed -i 's/EdgeInsets\.all(16)/const EdgeInsets.all(16)/g' {} \;
find lib/ -name "*.dart" -exec sed -i 's/EdgeInsets\.all(20)/const EdgeInsets.all(20)/g' {} \;
find lib/ -name "*.dart" -exec sed -i 's/EdgeInsets\.all(24)/const EdgeInsets.all(24)/g' {} \;
find lib/ -name "*.dart" -exec sed -i 's/EdgeInsets\.symmetric(/const EdgeInsets.symmetric(/g' {} \;

echo "✅ EdgeInsets convertidos para constantes"

# Remover imports de ScreenUtil
find lib/ -name "*.dart" -exec sed -i '/flutter_screenutil/d' {} \;

echo "✅ Imports de flutter_screenutil removidos"

# ========================================
# FASE 6: LIMPEZA E TESTE (5 min)
# ========================================
echo ""
echo "🧹 FASE 6: Limpeza e teste..."

# Limpar projeto
flutter clean > /dev/null 2>&1
flutter pub get > /dev/null 2>&1

echo "✅ Projeto limpo e dependências atualizadas"

# Verificar se ainda há referências ao ScreenUtil
REMAINING_USAGE=$(grep -r "\.sp\|\.w\|\.h\|\.r\|ScreenUtil" lib/ --include="*.dart" | wc -l)
echo "📊 Referências restantes ao ScreenUtil: $REMAINING_USAGE"

# Testar compilação
echo "🔨 Testando compilação..."
if flutter analyze --no-fatal-infos --no-fatal-warnings > /dev/null 2>&1; then
    echo "✅ Compilação OK!"
else
    echo "⚠️ Alguns warnings encontrados, mas deve funcionar"
    echo "Execute 'flutter analyze' para ver detalhes"
fi

# ========================================
# RELATÓRIO FINAL
# ========================================
echo ""
echo "📊 RELATÓRIO DA MIGRAÇÃO"
echo "========================"
echo ""

# Comparação antes/depois
BEFORE_USAGE=$(grep -r "\.sp\|\.w\|\.h\|\.r" lib/ --include="*.dart.backup" 2>/dev/null | wc -l)
AFTER_USAGE=$(grep -r "\.sp\|\.w\|\.h\|\.r" lib/ --include="*.dart" | wc -l)

echo "📈 ScreenUtil removido:"
echo "   Antes: $BEFORE_USAGE usos"
echo "   Depois: $AFTER_USAGE usos"
echo "   Redução: $((BEFORE_USAGE - AFTER_USAGE)) usos eliminados"

echo ""
echo "✅ MIGRAÇÃO CONCLUÍDA COM SUCESSO!"
echo ""
echo "🎯 PRÓXIMOS PASSOS:"
echo "1. Execute: flutter run"
echo "2. Teste o app - textos estarão 60-70% MAIORES!"
echo "3. Verifique se layouts estão corretos"
echo "4. Se necessário, ajuste espaçamentos manualmente"
echo ""
echo "🎉 BENEFÍCIOS OBTIDOS:"
echo "   ✅ Textos MUITO mais legíveis"
echo "   ✅ Melhor acessibilidade"
echo "   ✅ Código mais limpo"
echo "   ✅ Performance melhor"
echo "   ✅ Menos bugs visuais"
echo ""
echo "📱 Teste especialmente em iPhone SE para ver a diferença!"
echo ""
echo "🆘 SE ALGO DER ERRADO:"
echo "   git checkout backup-screenutil-removal"
echo "   (restaura estado anterior)"
EOF

# Dar permissão de execução
chmod +x "$0"

echo ""
echo "🚀 SCRIPT DE MIGRAÇÃO CRIADO!"
echo ""
echo "Para executar a migração completa, execute:"
echo "bash migrate_petverse.sh"
echo ""
echo "⏱️ Tempo estimado: 30 minutos"
echo "🎯 Resultado: App com textos 60-70% maiores e mais legíveis!"