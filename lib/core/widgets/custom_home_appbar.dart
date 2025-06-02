import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/providers/theme_provider.dart';
import 'package:petverse/core/theme/app_thema.dart';

class CustomHomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CustomHomeAppBar({super.key});

  @override
  Size get preferredSize => const Size(double.infinity, 110);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppTheme.spaceLg, 45, AppTheme.spaceLg, AppTheme.spaceSm),
      decoration: BoxDecoration(
        gradient: isDark
            ? AppTheme.backgroundGradientDark
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFBAD4F5), // Azul muito claro
                  AppTheme.backgroundLight,
                ],
                stops: [0.0, 0.7],
              ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar com tema responsivo
              _buildUserAvatar(context, isDark),
              const SizedBox(width: 10),

              // Saudação
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá, Jogador',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Text(
                      'Pronto para se divertir?',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              // Ações
              Row(
                children: [
                  _HeaderActionButton(
                    icon: Icons.emoji_events_outlined,
                    color: AppTheme.warning,
                    onTap: () {},
                  ),
                  const SizedBox(width: AppTheme.spaceSm),
                  _HeaderActionButton(
                    icon: Icons.brightness_6_outlined,
                    color: AppTheme.primarySoft,
                    onTap: () => ref.read(themeProvider.notifier).toggleTheme(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),

          // Segunda linha - Recursos
          Row(
            children: [
              _buildResourceChip('⭐', 'LEVEL', '5', AppTheme.accentCoral),
              const SizedBox(width: 6),
              _buildResourceChip('🪙', 'COINS', '1250', AppTheme.warning),
              const SizedBox(width: 6),
              _buildResourceChip('💎', 'GEMS', '45', AppTheme.info),
              const SizedBox(width: 6),
              _buildResourceChip('🏪', 'LOJA', '', AppTheme.success),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context, bool isDark) {
    return Stack(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primarySoft.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.person,
            color: Colors.white,
            size: 20,
          ),
        ),
        Positioned(
          bottom: -1,
          right: -1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
            decoration: BoxDecoration(
              gradient: AppTheme.accentGradient,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white, width: 1),
            ),
            child: Text(
              '5',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResourceChip(
      String icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(icon, style: const TextStyle(fontSize: 12)),
                if (value.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            if (label.isNotEmpty)
              Text(
                label,
                style: TextStyle(
                  fontSize: 8,
                  color: color.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HeaderActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          color: color,
          size: 18,
        ),
      ),
    );
  }
}

// ============ EXEMPLO: CUSTOM BUTTON ATUALIZADO ============

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isOutlined;
  final bool isLoading;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isOutlined = false,
    this.isLoading = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingButton(context);
    }

    if (isOutlined) {
      return _buildOutlinedButton(context);
    }

    return _buildFilledButton(context);
  }

  Widget _buildFilledButton(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: onPressed,
        child: _buildButtonContent(context),
      ),
    );
  }

  Widget _buildOutlinedButton(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 48,
      child: OutlinedButton(
        onPressed: onPressed,
        child: _buildButtonContent(context),
      ),
    );
  }

  Widget _buildLoadingButton(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: null,
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent(BuildContext context) {
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: AppTheme.spaceSm),
          Text(text),
        ],
      );
    }

    return Text(text);
  }
}

// ============ EXEMPLO: ENTRADA DE ANIMAÇÃO ATUALIZADA ============

class EntryAnimation extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color color;

  const EntryAnimation({
    super.key,
    required this.message,
    required this.icon,
    required this.color,
  });

  @override
  State<EntryAnimation> createState() => _EntryAnimationState();
}

class _EntryAnimationState extends State<EntryAnimation>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseController.repeat(reverse: true);
    _rotateController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Ícone animado
        AnimatedBuilder(
          animation: Listenable.merge([_pulseController, _rotateController]),
          builder: (context, child) {
            return Transform.scale(
              scale: 0.8 + (_pulseController.value * 0.4),
              child: Transform.rotate(
                angle: _rotateController.value * 0.1,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.color,
                        widget.color.withOpacity(0.7),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.icon,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 32),

        // Mensagem
        Text(
          widget.message,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: widget.color,
                fontWeight: FontWeight.w500,
              ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: 200.ms)
            .slideY(begin: 0.3, end: 0),

        const SizedBox(height: 24),

        // Indicador de progresso
        SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            backgroundColor: widget.color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(widget.color),
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 400.ms)
            .scaleX(begin: 0, end: 1),
      ],
    );
  }
}
