# ====================================================================
# PETCARE FLUTTER PROJECT AUTOMATION SCRIPT
# Gera projeto Flutter completo com estrutura, dependências e arquivos base
# ====================================================================

param(
    [string]$ProjectName = "petverse",
    [string]$ProjectPath = "C:\Barreto-org\",
    [string]$FirebaseProjectId = "petcare-app-2025"
)

# Cores para output
$Green = "Green"
$Yellow = "Yellow" 
$Red = "Red"
$Blue = "Cyan"

function Write-Status($Message, $Color = "White") {
    Write-Host "🚀 $Message" -ForegroundColor $Color
}

function Write-Success($Message) {
    Write-Host "✅ $Message" -ForegroundColor $Green
}

function Write-Warning($Message) {
    Write-Host "⚠️  $Message" -ForegroundColor $Yellow
}

function Write-Error($Message) {
    Write-Host "❌ $Message" -ForegroundColor $Red
}

# ====================================================================
# 1. SETUP INICIAL
# ====================================================================

Write-Status "Iniciando automação do PetCare Flutter..." $Blue
Write-Status "Projeto: $ProjectName" $Blue
Write-Status "Caminho: $ProjectPath" $Blue

# Verificar se Flutter está instalado
if (!(Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Error "Flutter não encontrado! Instale o Flutter SDK primeiro."
    exit 1
}

# Criar diretório do projeto
$FullPath = Join-Path $ProjectPath $ProjectName
if (Test-Path $FullPath) {
    Write-Warning "Diretório já existe. Removendo..."
    Remove-Item $FullPath -Recurse -Force
}

Write-Status "Criando projeto Flutter..." $Blue
Set-Location $ProjectPath
flutter create $ProjectName --org com.petcare.app

Set-Location $FullPath
Write-Success "Projeto Flutter criado!"

# ====================================================================
# 2. CONFIGURAR PUBSPEC.YAML
# ====================================================================

Write-Status "Configurando dependências..." $Blue

$pubspecContent = @"
name: petverse
description: Pet care collaboration app with AI integration
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'
  flutter: ">=3.16.0"

dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_storage: ^11.5.6
  firebase_analytics: ^10.7.4
  firebase_messaging: ^14.7.10
  
  # Authentication
  google_sign_in: ^6.2.1
  
  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  
  # Navigation
  go_router: ^12.1.3
  
  # Local Storage
  shared_preferences: ^2.2.2
  
  # Network
  http: ^1.1.2
  dio: ^5.4.0
  
  # UI Components
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  lottie: ^2.7.0
  
  # Animations
  flutter_animate: ^4.3.0
  
  # Utils
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  uuid: ^4.2.1
  
  # Notifications
  flutter_local_notifications: ^16.3.2
  
  # Permissions
  permission_handler: ^11.2.0
  
  # Device Info
  device_info_plus: ^9.1.2
  package_info_plus: ^4.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  
  # Code Generation
  build_runner: ^2.4.7
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  riverpod_generator: ^2.3.9
  riverpod_lint: ^2.3.7

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
    - assets/animations/
    - assets/sounds/
  
  fonts:
    - family: Poppins
      fonts:
        - asset: assets/fonts/Poppins-Regular.ttf
        - asset: assets/fonts/Poppins-Medium.ttf
          weight: 500
        - asset: assets/fonts/Poppins-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Poppins-Bold.ttf
          weight: 700
"@

$pubspecContent | Out-File -FilePath "pubspec.yaml" -Encoding UTF8
Write-Success "pubspec.yaml configurado!"

# ====================================================================
# 3. CRIAR ESTRUTURA DE PASTAS
# ====================================================================

Write-Status "Criando estrutura de pastas..." $Blue

$folders = @(
    "lib\core\constants",
    "lib\core\error", 
    "lib\core\utils",
    "lib\core\theme",
    "lib\core\router",
    "lib\features\auth\data\datasources",
    "lib\features\auth\data\models", 
    "lib\features\auth\data\repositories",
    "lib\features\auth\domain\entities",
    "lib\features\auth\domain\repositories", 
    "lib\features\auth\domain\usecases",
    "lib\features\auth\presentation\pages",
    "lib\features\auth\presentation\widgets",
    "lib\features\auth\presentation\providers",
    "lib\features\pets\data\datasources",
    "lib\features\pets\data\models",
    "lib\features\pets\data\repositories", 
    "lib\features\pets\domain\entities",
    "lib\features\pets\domain\repositories",
    "lib\features\pets\domain\usecases",
    "lib\features\pets\presentation\pages",
    "lib\features\pets\presentation\widgets",
    "lib\features\pets\presentation\providers",
    "lib\features\shop\data\datasources",
    "lib\features\shop\data\models",
    "lib\features\shop\data\repositories",
    "lib\features\shop\domain\entities", 
    "lib\features\shop\domain\repositories",
    "lib\features\shop\domain\usecases",
    "lib\features\shop\presentation\pages",
    "lib\features\shop\presentation\widgets",
    "lib\features\shop\presentation\providers",
    "lib\features\missions\data\datasources",
    "lib\features\missions\data\models",
    "lib\features\missions\data\repositories",
    "lib\features\missions\domain\entities",
    "lib\features\missions\domain\repositories", 
    "lib\features\missions\domain\usecases",
    "lib\features\missions\presentation\pages",
    "lib\features\missions\presentation\widgets",
    "lib\features\missions\presentation\providers",
    "lib\features\dashboard\presentation\pages",
    "lib\features\dashboard\presentation\widgets",
    "lib\features\dashboard\presentation\providers",
    "lib\features\collaboration\data\datasources",
    "lib\features\collaboration\data\models", 
    "lib\features\collaboration\data\repositories",
    "lib\features\collaboration\domain\entities",
    "lib\features\collaboration\domain\repositories",
    "lib\features\collaboration\domain\usecases", 
    "lib\features\collaboration\presentation\pages",
    "lib\features\collaboration\presentation\widgets",
    "lib\features\collaboration\presentation\providers",
    "lib\shared\widgets",
    "lib\shared\extensions",
    "lib\shared\services",
    "assets\images",
    "assets\icons", 
    "assets\animations",
    "assets\sounds",
    "assets\fonts"
)

foreach ($folder in $folders) {
    New-Item -ItemType Directory -Path $folder -Force | Out-Null
}

Write-Success "Estrutura de pastas criada!"

# ====================================================================
# 4. GERAR ARQUIVOS BASE
# ====================================================================

Write-Status "Gerando arquivos base..." $Blue

# Main.dart
$mainDart = @"
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    const ProviderScope(
      child: PetCareApp(),
    ),
  );
}

class PetCareApp extends ConsumerWidget {
  const PetCareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      title: 'PetCare',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
"@

$mainDart | Out-File -FilePath "lib\main.dart" -Encoding UTF8

# App Theme
$appTheme = @"
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color primaryTeal = Color(0xFF14B8A6);
  
  static const Color accentYellow = Color(0xFFFBBF24);
  static const Color accentPink = Color(0xFFEC4899);
  
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryPurple,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryPurple,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF111827),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1F2937),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF1F2937),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
"@

$appTheme | Out-File -FilePath "lib\core\theme\app_theme.dart" -Encoding UTF8

# App Router
$appRouter = @"
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/pets/presentation/pages/home_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.when(
        data: (user) => user != null,
        loading: () => false,
        error: (_, __) => false,
      );
      
      final isLoginRoute = state.location == '/login';
      
      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }
      
      if (isLoggedIn && isLoginRoute) {
        return '/home';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
});
"@

$appRouter | Out-File -FilePath "lib\core\router\app_router.dart" -Encoding UTF8

# Pet Entity
$petEntity = @"
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pet.freezed.dart';
part 'pet.g.dart';

@freezed
class Pet with _\$Pet {
  const factory Pet({
    required String id,
    required String name,
    required String emoji,
    String? imageUrl,
    @Default('comum') String rarity,
    required String category,
    @Default('solo') String type,
    @Default(1) int level,
    @Default(0) int xp,
    @Default(50) int happiness,
    @Default(50) int hunger,
    @Default(50) int energy,
    @Default(80) int health,
    @Default(false) bool isCollab,
    @Default(false) bool isUnique,
    String? partnerId,
    String? partnerAvatar,
    @Default(false) bool identityRevealed,
    @Default(5) int revealLevel,
    @Default(<String>[]) List<String> accessories,
    required DateTime lastCared,
    required DateTime adoptedAt,
    required String ownerId,
    String? prompt,
    @Default(true) bool canInteract,
  }) = _Pet;
  
  factory Pet.fromJson(Map<String, dynamic> json) => _\$PetFromJson(json);
}
"@

$petEntity | Out-File -FilePath "lib\features\pets\domain\entities\pet.dart" -Encoding UTF8

# User Entity  
$userEntity = @"
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _\$User {
  const factory User({
    required String id,
    required String username,
    required String avatar,
    required String email,
    @Default(1) int level,
    @Default(0) int xp,
    @Default(300) int coins,
    @Default(30) int gems,
    required DateTime createdAt,
    @Default(<String>[]) List<String> ownedPetIds,
    Map<String, dynamic>? aiConfig,
  }) = _User;
  
  factory User.fromJson(Map<String, dynamic> json) => _\$UserFromJson(json);
}
"@

$userEntity | Out-File -FilePath "lib\features\auth\domain\entities\user.dart" -Encoding UTF8

# Auth Provider
$authProvider = @"
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../domain/entities/user.dart' as app_user;

final authStateProvider = StreamProvider<firebase_auth.User?>((ref) {
  return firebase_auth.FirebaseAuth.instance.authStateChanges();
});

final currentUserProvider = FutureProvider<app_user.User?>((ref) async {
  final authUser = await ref.watch(authStateProvider.future);
  if (authUser == null) return null;
  
  // TODO: Fetch user data from Firestore
  return app_user.User(
    id: authUser.uid,
    username: authUser.displayName ?? 'User',
    avatar: authUser.photoURL ?? '👨',
    email: authUser.email ?? '',
    createdAt: DateTime.now(),
  );
});
"@

$authProvider | Out-File -FilePath "lib\features\auth\presentation\providers\auth_provider.dart" -Encoding UTF8

# Login Page
$loginPage = @"
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF8B5CF6),
              Color(0xFF3B82F6),
              Color(0xFF14B8A6),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '🐾',
                  style: TextStyle(fontSize: 120),
                ),
                const SizedBox(height: 32),
                const Text(
                  'PetCare',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Cuidado Colaborativo',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 64),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement Google Sign-in
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Entrar com Google'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1F2937),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
"@

$loginPage | Out-File -FilePath "lib\features\auth\presentation\pages\login_page.dart" -Encoding UTF8

# Home Page
$homePage = @"
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 2; // Pet tab as center

  final List<Widget> _pages = [
    const FeedPage(),
    const MissionsPage(), 
    const PetPage(),
    const ShopPage(),
    const DashboardPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.rss_feed),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: 'Missões',
          ),
          BottomNavigationBarItem(
            icon: Text('🐾', style: TextStyle(fontSize: 24)),
            label: 'Pet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Loja',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
        ],
      ),
    );
  }
}

// Placeholder pages
class FeedPage extends StatelessWidget {
  const FeedPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'Feed'),
      body: Center(child: Text('Feed Page')),
    );
  }
}

class MissionsPage extends StatelessWidget {
  const MissionsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'Missões'),
      body: Center(child: Text('Missions Page')),
    );
  }
}

class PetPage extends StatelessWidget {
  const PetPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'Pet'),
      body: Center(child: Text('Pet Page')),
    );
  }
}

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'Loja'),
      body: Center(child: Text('Shop Page')),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'Dashboard'),
      body: Center(child: Text('Dashboard Page')),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  
  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      elevation: 0,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.monetization_on, size: 16, color: Colors.white),
              SizedBox(width: 4),
              Text('300', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.purple,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.diamond, size: 16, color: Colors.white),
              SizedBox(width: 4),
              Text('30', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
"@

$homePage | Out-File -FilePath "lib\features\pets\presentation\pages\home_page.dart" -Encoding UTF8

Write-Success "Arquivos base gerados!"

# ====================================================================
# 5. FIREBASE SETUP
# ====================================================================

Write-Status "Configurando Firebase..." $Blue

# Firebase Options (placeholder)
$firebaseOptions = @"
// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'your-web-api-key',
    appId: 'your-web-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: '$FirebaseProjectId',
    authDomain: '$FirebaseProjectId.firebaseapp.com',
    storageBucket: '$FirebaseProjectId.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'your-android-api-key',
    appId: 'your-android-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: '$FirebaseProjectId',
    storageBucket: '$FirebaseProjectId.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your-ios-api-key',
    appId: 'your-ios-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: '$FirebaseProjectId',
    storageBucket: '$FirebaseProjectId.appspot.com',
    iosBundleId: 'com.petcare.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'your-macos-api-key',
    appId: 'your-macos-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: '$FirebaseProjectId',
    storageBucket: '$FirebaseProjectId.appspot.com',
    iosBundleId: 'com.petcare.app',
  );
}
"@

$firebaseOptions | Out-File -FilePath "lib\firebase_options.dart" -Encoding UTF8

# Android Configuration
$androidManifest = @"
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    
    <application
        android:label="PetCare"
        android:name="`${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
              
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
            
    </application>
</manifest>
"@

$androidManifest | Out-File -FilePath "android\app\src\main\AndroidManifest.xml" -Encoding UTF8

Write-Success "Configuração Firebase criada!"

# ====================================================================
# 6. GERAR BUILD RUNNER E FINALIZAR
# ====================================================================

Write-Status "Executando build_runner..." $Blue
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

Write-Status "Criando arquivos de configuração adicionais..." $Blue

# Analysis Options
$analysisOptions = @"
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  
linter:
  rules:
    - prefer_const_constructors
    - prefer_const_literals_to_create_immutables
    - avoid_print
    - prefer_typing_uninitialized_variables
    - avoid_unnecessary_containers
"@

$analysisOptions | Out-File -FilePath "analysis_options.yaml" -Encoding UTF8

# README
$readmeContent = @"
# PetCare Flutter

Uma aplicação mobile de cuidado colaborativo de pets virtuais com integração de IA.

## Características

🐾 **Pets Virtuais**: Sistema completo de cuidado com stats realistas
🤝 **Colaboração**: Adoção colaborativa com usuários anônimos  
🎨 **IA Integration**: Geração de pets únicos usando prompts
🎮 **Gamificação**: Sistema de XP, níveis, missões e economia
🔥 **Firebase**: Backend completo com Firestore e Authentication
📱 **UI Moderna**: Design responsivo com animações fluidas

## Setup

1. Configure Firebase:
   ```bash
   flutterfire configure --project=$FirebaseProjectId
   ```

2. Instale dependências:
   ```bash
   flutter pub get
   ```

3. Execute build runner:
   ```bash
   flutter pub run build_runner build
   ```

4. Execute o app:
   ```bash
   flutter run
   ```

## Estrutura

```
lib/
├── core/                 # Configurações globais
├── features/            # Features organizadas por domínio
│   ├── auth/           # Autenticação
│   ├── pets/           # Sistema de pets
│   ├── shop/           # Loja e economia
│   ├── missions/       # Sistema de missões
│   └── collaboration/  # Funcionalidades colaborativas
└── shared/             # Widgets e utilitários compartilhados
```

## Configuração Firebase

1. Crie projeto no Firebase Console
2. Habilite Authentication (Google Sign-in)
3. Configure Firestore Database
4. Configure Storage para imagens
5. Adicione SHA-1 fingerprints para Android
6. Baixe e configure google-services.json / GoogleService-Info.plist

## Economia do Jogo

- **Coins**: Moeda básica para pets e itens
- **Gems**: Moeda premium para features especiais
- **Progressão**: Sistema balanceado de XP e níveis
- **Slots**: Expansão paga de slots de pets

Feito com ❤️ e Flutter
"@

$readmeContent | Out-File -FilePath "README.md" -Encoding UTF8

# ====================================================================
# 7. FINALIZAÇÃO
# ====================================================================

Write-Status "Criando script de desenvolvimento..." $Blue

$devScript = @"
@echo off
echo 🚀 PetCare Development Tools

:menu
echo.
echo 1. Executar app
echo 2. Build runner (watch)
echo 3. Build runner (one-time)
echo 4. Limpar build
echo 5. Pub get
echo 6. Analisar código
echo 7. Sair
echo.
set /p choice="Escolha uma opção: "

if "%choice%"=="1" (
    flutter run
    goto menu
)
if "%choice%"=="2" (
    flutter pub run build_runner watch --delete-conflicting-outputs
    goto menu
)
if "%choice%"=="3" (
    flutter pub run build_runner build --delete-conflicting-outputs
    goto menu
)
if "%choice%"=="4" (
    flutter clean && flutter pub get
    goto menu
)
if "%choice%"=="5" (
    flutter pub get
    goto menu
)
if "%choice%"=="6" (
    flutter analyze
    goto menu
)
if "%choice%"=="7" (
    exit
)

goto menu
"@

$devScript | Out-File -FilePath "dev.bat" -Encoding ASCII

# Script de configuração Firebase
$firebaseSetup = @"
#!/bin/bash
# Firebase Setup Script

echo "🔥 Configurando Firebase para PetCare..."

# Instalar FlutterFire CLI
echo "Instalando FlutterFire CLI..."
dart pub global activate flutterfire_cli

# Configurar projeto
echo "Configurando projeto Firebase..."
flutterfire configure --project=$FirebaseProjectId

echo "✅ Configuração Firebase concluída!"
echo "📝 Próximos passos:"
echo "1. Configure Authentication no Console Firebase"
echo "2. Habilite Google Sign-in"
echo "3. Configure Firestore Database"
echo "4. Configure Storage"
echo "5. Adicione SHA-1 fingerprints para Android"
"@

$firebaseSetup | Out-File -FilePath "firebase_setup.sh" -Encoding UTF8

Write-Success "Projeto PetCare Flutter criado com sucesso! 🎉"
Write-Status "Localização: $FullPath" $Blue

Write-Host "`n📋 PRÓXIMOS PASSOS:" -ForegroundColor $Yellow
Write-Host "1.⚙️ Execute: firebase_setup.sh (ou configure Firebase manualmente)" -ForegroundColor White
Write-Host "2.   Configure Authentication no Firebase Console" -ForegroundColor White  
Write-Host "3.📱 Adicione SHA-1 fingerprints para Android" -ForegroundColor White
Write-Host "4.🏃 Execute: dev.bat para ferramentas de desenvolvimento" -ForegroundColor White
Write-Host "5.🚀 Execute: flutter run" -ForegroundColor White

Write-Host "`n🎯 FUNCIONALIDADES IMPLEMENTADAS:" -ForegroundColor $Green
Write-Host "✅ Estrutura completa de pastas" -ForegroundColor White
Write-Host "✅ Dependências configuradas" -ForegroundColor White
Write-Host "✅ State management (Riverpod)" -ForegroundColor White
Write-Host "✅ Navegação (GoRouter)" -ForegroundColor White
Write-Host "✅ Theme system (Dark/Light)" -ForegroundColor White
Write-Host "✅ Firebase setup preparado" -ForegroundColor White
Write-Host "✅ Models com Freezed" -ForegroundColor White
Write-Host "✅ Telas base implementadas" -ForegroundColor White

Write-Host "`n🔥 PRONTO PARA DESENVOLVIMENTO!" -ForegroundColor $Blue