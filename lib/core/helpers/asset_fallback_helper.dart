// lib/core/helpers/asset_fallback_helper.dart
// NOVO: Sistema de fallback para assets faltantes
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petverse/core/constants/app_colors.dart';

class AssetFallbackHelper {
  static const Map<String, Widget> _fallbackWidgets = {
    'google_logo': _GoogleLogoFallback(),
    'pet_placeholder': _PetPlaceholderFallback(),
    'bg_forest':
        _BackgroundFallback(color: Color(0xFF228B22), icon: Icons.forest),
    'bg_stars': _BackgroundFallback(color: Color(0xFF191970), icon: Icons.star),
    'loading': _LoadingAnimationFallback(),
    'success': _SuccessAnimationFallback(),
  };

  /// Constrói uma imagem com fallback automático
  static Widget buildImage({
    required String assetPath,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    String? fallbackKey,
  }) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('⚠️ Asset não encontrado: $assetPath');

        // Tentar usar fallback específico
        if (fallbackKey != null && _fallbackWidgets.containsKey(fallbackKey)) {
          return SizedBox(
            width: width,
            height: height,
            child: _fallbackWidgets[fallbackKey]!,
          );
        }

        // Fallback baseado no nome do arquivo
        final fileName = assetPath.split('/').last.split('.').first;
        if (_fallbackWidgets.containsKey(fileName)) {
          return SizedBox(
            width: width,
            height: height,
            child: _fallbackWidgets[fileName]!,
          );
        }

        // Fallback genérico
        return _GenericImageFallback(
          width: width,
          height: height,
          assetPath: assetPath,
        );
      },
    );
  }

  /// Constrói um ícone para asset de imagem
  static Widget buildIconFallback({
    required IconData icon,
    double? size,
    Color? color,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? 'Ícone de fallback',
      child: Icon(
        icon,
        size: size,
        color: color,
      ),
    );
  }

  /// Verifica se um asset existe
  static Future<bool> assetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Gera relatório de assets
  static Future<Map<String, bool>> checkAssets(List<String> assetPaths) async {
    final results = <String, bool>{};

    for (final path in assetPaths) {
      results[path] = await assetExists(path);
    }

    return results;
  }
}

// Widgets de fallback específicos

class _GoogleLogoFallback extends StatelessWidget {
  const _GoogleLogoFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Icon(
        Icons.g_mobiledata,
        color: Colors.red,
        size: 20,
      ),
    );
  }
}

class _PetPlaceholderFallback extends StatelessWidget {
  const _PetPlaceholderFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: const Icon(
        Icons.pets,
        color: AppColors.primary,
        size: 40,
      ),
    );
  }
}

class _BackgroundFallback extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _BackgroundFallback({
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withOpacity(0.7),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          color: Colors.white.withOpacity(0.3),
          size: 100,
        ),
      ),
    );
  }
}

class _LoadingAnimationFallback extends StatefulWidget {
  const _LoadingAnimationFallback();

  @override
  State<_LoadingAnimationFallback> createState() =>
      _LoadingAnimationFallbackState();
}

class _LoadingAnimationFallbackState extends State<_LoadingAnimationFallback>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * 3.14159,
            child: const Icon(
              Icons.refresh,
              color: AppColors.primary,
              size: 40,
            ),
          );
        },
      ),
    );
  }
}

class _SuccessAnimationFallback extends StatefulWidget {
  const _SuccessAnimationFallback();

  @override
  State<_SuccessAnimationFallback> createState() =>
      _SuccessAnimationFallbackState();
}

class _SuccessAnimationFallbackState extends State<_SuccessAnimationFallback>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: const Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 40,
            ),
          );
        },
      ),
    );
  }
}

class _GenericImageFallback extends StatelessWidget {
  final double? width;
  final double? height;
  final String assetPath;

  const _GenericImageFallback({
    this.width,
    this.height,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    final fileName = assetPath.split('/').last.split('.').first;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey.shade500,
            size: (height != null && height! < 50) ? 16 : 24,
          ),
          if (height == null || height! >= 50) ...[
            const SizedBox(height: 4),
            Text(
              fileName,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

// Extensões úteis
extension AssetPathExtension on String {
  /// Constrói widget de imagem com fallback
  Widget toImageWidget({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    String? fallbackKey,
  }) {
    return AssetFallbackHelper.buildImage(
      assetPath: this,
      width: width,
      height: height,
      fit: fit,
      fallbackKey: fallbackKey,
    );
  }

  /// Verifica se o asset existe
  Future<bool> get exists => AssetFallbackHelper.assetExists(this);
}

// Widget para debug de assets
class AssetDebugScreen extends StatefulWidget {
  const AssetDebugScreen({super.key});

  @override
  State<AssetDebugScreen> createState() => _AssetDebugScreenState();
}

class _AssetDebugScreenState extends State<AssetDebugScreen> {
  Map<String, bool> _assetStatus = {};
  bool _isLoading = true;

  final List<String> _assetsToCheck = [
    'assets/images/google_logo.png',
    'assets/images/bg_forest.png',
    'assets/images/bg_stars.png',
    'assets/images/pet_placeholder.png',
    'assets/lottie/loading.json',
    'assets/lottie/success.json',
  ];

  @override
  void initState() {
    super.initState();
    _checkAssets();
  }

  Future<void> _checkAssets() async {
    setState(() => _isLoading = true);

    final results = await AssetFallbackHelper.checkAssets(_assetsToCheck);

    if (mounted) {
      setState(() {
        _assetStatus = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug de Assets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkAssets,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _assetStatus.length,
              itemBuilder: (context, index) {
                final asset = _assetStatus.keys.elementAt(index);
                final exists = _assetStatus[asset] ?? false;

                return Card(
                  child: ListTile(
                    leading: Icon(
                      exists ? Icons.check_circle : Icons.error,
                      color: exists ? AppColors.success : AppColors.error,
                    ),
                    title: Text(
                      asset.split('/').last,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      asset,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: exists
                        ? const Text('OK',
                            style: TextStyle(color: AppColors.success))
                        : const Text('FALTANDO',
                            style: TextStyle(color: AppColors.error)),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Mostrar exemplo de fallbacks
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Exemplo de Fallbacks'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AssetFallbackHelper.buildImage(
                    assetPath: 'assets/images/google_logo.png',
                    width: 40,
                    height: 40,
                    fallbackKey: 'google_logo',
                  ),
                  const SizedBox(height: 16),
                  AssetFallbackHelper.buildImage(
                    assetPath: 'assets/images/nonexistent.png',
                    width: 100,
                    height: 100,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fechar'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.preview),
      ),
    );
  }
}
