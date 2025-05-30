// lib/features/home/presentation/widgets/adoption_options_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:petverse/core/constants/app_constants.dart';
import 'package:petverse/core/model/user_model.dart';
import 'package:petverse/core/theme/app_theme.dart';
import 'package:petverse/core/utils/app_utils.dart';

class AdoptionOptionsWidget extends ConsumerStatefulWidget {
  final UserModel user;

  const AdoptionOptionsWidget({
    super.key,
    required this.user,
  });

  @override
  ConsumerState<AdoptionOptionsWidget> createState() =>
      _AdoptionOptionsWidgetState();
}

class _AdoptionOptionsWidgetState extends ConsumerState<AdoptionOptionsWidget>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _floatingController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleExploreAvailable() {
    AppUtils.lightImpact();
    context.push('/public-adoptions');
  }

  void _handleCreateRequest() {
    AppUtils.lightImpact();
    context.push('/create-request');
  }

  Future<void> _handleShareAdoption() async {
    AppUtils.mediumImpact();

    try {
      const shareText =
          'Oi! Estou procurando um co-parent para adotar um pet de forma colaborativa. '
          'Que tal cuidarmos juntos de um bichinho? 🐾\n\n'
          'Baixe o app: https://yourapp.com';

      await AppUtils.shareText(shareText,
          subject: 'Vamos adotar um pet juntos!');

      if (mounted) {
        AppUtils.showSuccessSnackbar(context, 'Convite compartilhado!');
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showErrorSnackbar(context, 'Erro ao compartilhar convite');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Hero Section
        _buildHeroSection(),

        SizedBox(height: 32.h),

        // Explanation Card
        _buildExplanationCard(),

        SizedBox(height: 24.h),

        // Action Options
        _buildActionOptions(),

        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppTheme.primarySoft.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.cardShadow,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Greeting
          Text(
            'Olá, ${widget.user.displayName}! 👋',
            style: AppTheme.headingMedium.copyWith(
              color: AppTheme.primarySoft,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 8.h),

          Text(
            'Você ainda não tem um pet!',
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 4.h),

          Text(
            'Que tal adotar um em parceria?',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 32.h),

          // Animated Pet Illustration
          Stack(
            alignment: Alignment.center,
            children: [
              // Background glow
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: (160 + _pulseController.value * 20).w,
                    height: (160 + _pulseController.value * 20).w,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.primarySoft.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),

              // Main illustration
              AnimatedBuilder(
                animation: _floatingController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatingController.value * 15),
                    child: SizedBox(
                      width: 140.w,
                      height: 140.w,
                      child: Lottie.asset(
                        AppConstants.petAnimation,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),

              // Floating hearts
              ...List.generate(3, (index) {
                return Positioned(
                  top: (20 + index * 30).h,
                  right: (20 + index * 15).w,
                  child: Icon(
                    Icons.favorite,
                    color: [
                      AppTheme.accentCoral,
                      AppTheme.accentPeach,
                      AppTheme.primarySoft,
                    ][index]
                        .withOpacity(0.6),
                    size: (16 + index * 2).sp,
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.2, 1.2),
                        duration: Duration(milliseconds: 1500 + index * 200),
                      )
                      .then()
                      .fadeOut(duration: 500.ms),
                );
              }),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildExplanationCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accentCoral.withOpacity(0.05),
            AppTheme.accentPeach.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppTheme.accentCoral.withOpacity(0.1),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Adoção Colaborativa',
                  style: AppTheme.headingSmall.copyWith(
                    color: AppTheme.accentCoral,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Description
          Text(
            'Duas pessoas cuidam de um pet juntas, dividindo responsabilidades, custos e criando laços especiais com o animal. É uma forma moderna e colaborativa de dar amor aos pets!',
            style: AppTheme.bodyMedium.copyWith(
              height: 1.6,
              color: AppTheme.textSecondary,
            ),
          ),

          SizedBox(height: 16.h),

          // Benefits
          Wrap(
            spacing: 12.w,
            runSpacing: 8.h,
            children: [
              _buildBenefitChip('🤝', 'Parceria'),
              _buildBenefitChip('💰', 'Economia'),
              _buildBenefitChip('❤️', 'Mais amor'),
              _buildBenefitChip('👥', 'Conexão'),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 200.ms)
        .slideX(begin: -0.2, end: 0);
  }

  Widget _buildBenefitChip(String emoji, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppTheme.accentCoral.withOpacity(0.2),
          width: 1.w,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: 12.sp),
          ),
          SizedBox(width: 4.w),
          Text(
            text,
            style: AppTheme.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(
          'Como você quer começar?',
          style: AppTheme.headingSmall.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),

        SizedBox(height: 4.h),

        Text(
          'Escolha uma das opções abaixo para iniciar sua jornada',
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),

        SizedBox(height: 20.h),

        // Option 1: Explore Available
        _buildActionCard(
          title: 'Explorar pets disponíveis',
          description:
              'Veja os pedidos de adoção de outros usuários e escolha um pet para co-adotar',
          icon: Icons.search,
          color: AppTheme.primarySoft,
          gradient: AppTheme.primaryGradient,
          onTap: _handleExploreAvailable,
          delay: 0,
        ),

        SizedBox(height: 16.h),

        // Option 2: Create Request
        _buildActionCard(
          title: 'Criar pedido de adoção',
          description:
              'Escolha até 3 pets e publique seu pedido para encontrar um co-parent',
          icon: Icons.add_circle_outline,
          color: AppTheme.accentCoral,
          gradient: AppTheme.accentGradient,
          onTap: _handleCreateRequest,
          delay: 100,
        ),

        SizedBox(height: 16.h),

        // Option 3: Share Invitation
        _buildActionCard(
          title: 'Indicar a um amigo',
          description:
              'Convide alguém especial para ser seu co-parent na adoção',
          icon: Icons.share,
          color: AppTheme.accentPeach,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.accentPeach, AppTheme.warning],
          ),
          onTap: _handleShareAdoption,
          isOutlined: true,
          delay: 200,
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required Gradient gradient,
    required VoidCallback onTap,
    bool isOutlined = false,
    required int delay,
  }) {
    return _ActionCard(
      title: title,
      description: description,
      icon: icon,
      color: color,
      gradient: gradient,
      onTap: onTap,
      isOutlined: isOutlined,
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: Duration(milliseconds: 400 + delay))
        .slideX(begin: 0.3, end: 0);
  }
}

class _ActionCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Gradient gradient;
  final VoidCallback onTap;
  final bool isOutlined;

  const _ActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.gradient,
    required this.onTap,
    this.isOutlined = false,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 1.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.onTap,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: widget.isOutlined ? null : widget.gradient,
                color: widget.isOutlined ? Colors.white : null,
                borderRadius: BorderRadius.circular(20.r),
                border: widget.isOutlined
                    ? Border.all(color: widget.color, width: 2.w)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: widget.color
                        .withOpacity(0.2 * _elevationAnimation.value),
                    blurRadius: 20 * _elevationAnimation.value,
                    offset: Offset(0, 8 * _elevationAnimation.value),
                    spreadRadius: 2 * _elevationAnimation.value,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icon Container
                  Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: BoxDecoration(
                      gradient: widget.isOutlined
                          ? widget.gradient.scale(0.1)
                          : LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.2),
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.isOutlined ? widget.color : Colors.white,
                      size: 28.sp,
                    ),
                  ),

                  SizedBox(width: 16.w),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: AppTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color:
                                widget.isOutlined ? widget.color : Colors.white,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          widget.description,
                          style: AppTheme.bodySmall.copyWith(
                            color: widget.isOutlined
                                ? AppTheme.textSecondary
                                : Colors.white.withOpacity(0.9),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 8.w),

                  // Arrow
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: widget.isOutlined
                          ? widget.color.withOpacity(0.1)
                          : Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: widget.isOutlined
                          ? widget.color
                          : Colors.white.withOpacity(0.8),
                      size: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Extension helper for gradient scaling
extension GradientExtension on Gradient {
  Gradient scale(double opacity) {
    if (this is LinearGradient) {
      final linear = this as LinearGradient;
      return LinearGradient(
        begin: linear.begin,
        end: linear.end,
        colors:
            linear.colors.map((color) => color.withOpacity(opacity)).toList(),
        stops: linear.stops,
      );
    }
    return this;
  }
}
