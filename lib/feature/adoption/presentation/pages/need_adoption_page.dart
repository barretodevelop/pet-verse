// lib/features/adoption/presentation/pages/need_adoption_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:petverse/feature/adoption/presentation/widgets/collaboration_steps.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../widgets/action_button_card.dart';
import '../widgets/adoption_explanation_card.dart';

class NeedAdoptionPage extends ConsumerStatefulWidget {
  const NeedAdoptionPage({super.key});

  @override
  ConsumerState<NeedAdoptionPage> createState() => _NeedAdoptionPageState();
}

class _NeedAdoptionPageState extends ConsumerState<NeedAdoptionPage>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Start animations
    _mainController.forward();
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _floatingController.dispose();
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              _buildMainContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120.h,
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          AppUtils.lightImpact();
          context.go('/home');
        },
        icon: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: AppTheme.cardShadow,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: AppTheme.textPrimary,
            size: 20.sp,
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Adoção Colaborativa',
          style: AppTheme.headingMedium.copyWith(
            color: AppTheme.primarySoft,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, end: 0);
  }

  Widget _buildMainContent() {
    return SliverPadding(
      padding: EdgeInsets.all(AppConstants.defaultPadding.w),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // Hero Animation with Pet Illustration
          _buildHeroSection(),

          SizedBox(height: 32.h),

          // Explanation Card
          const AdoptionExplanationCard()
              .animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .slideX(begin: -0.2, end: 0),

          SizedBox(height: 24.h),

          // Collaboration Steps
          const CollaborationSteps()
              .animate()
              .fadeIn(duration: 600.ms, delay: 400.ms)
              .slideX(begin: 0.2, end: 0),

          SizedBox(height: 32.h),

          // Action Buttons
          _buildActionButtons(),

          SizedBox(height: 24.h),
        ]),
      ),
    );
  }

  Widget _buildHeroSection() {
    return SizedBox(
      height: 200.h,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background decoration
          Container(
            width: 180.w,
            height: 180.w,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient.scale(0.3),
              shape: BoxShape.circle,
            ),
          ).animate(controller: _floatingController).scale(
              begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1)),

          // Pet Lottie Animation
          SizedBox(
            width: 160.w,
            height: 160.w,
            child: Lottie.asset(
              AppConstants.petAnimation,
              fit: BoxFit.contain,
            ),
          )
              .animate()
              .fadeIn(duration: 800.ms, delay: 300.ms)
              .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.0, 1.0))
              .then()
              .animate(controller: _floatingController)
              .moveY(begin: 0, end: -10, duration: 2000.ms),

          // Floating hearts
          Positioned(
            top: 20.h,
            right: 40.w,
            child: Icon(
              Icons.favorite,
              color: AppTheme.accentCoral.withOpacity(0.6),
              size: 24.sp,
            )
                .animate(onPlay: (controller) => controller.repeat())
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.2, 1.2),
                  duration: 1500.ms,
                )
                .then()
                .fadeOut(duration: 500.ms),
          ),

          Positioned(
            bottom: 30.h,
            left: 30.w,
            child: Icon(
              Icons.favorite,
              color: AppTheme.accentPeach.withOpacity(0.6),
              size: 18.sp,
            )
                .animate(onPlay: (controller) => controller.repeat())
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.2, 1.2),
                  duration: 2000.ms,
                )
                .then()
                .fadeOut(duration: 500.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Explore Available Pets
        ActionButtonCard(
          title: 'Explorar pets disponíveis',
          description: 'Veja os pedidos de adoção de outros usuários',
          icon: Icons.search,
          color: AppTheme.primarySoft,
          onTap: _handleExploreAvailable,
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: 600.ms)
            .slideX(begin: -0.3, end: 0),

        SizedBox(height: 16.h),

        // Create Adoption Request
        ActionButtonCard(
          title: 'Criar pedido de adoção',
          description: 'Escolha até 3 pets e aguarde um co-parent',
          icon: Icons.add_circle_outline,
          color: AppTheme.accentCoral,
          onTap: _handleCreateRequest,
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: 700.ms)
            .slideX(begin: 0.3, end: 0),

        SizedBox(height: 16.h),

        // Share to Friend
        ActionButtonCard(
          title: 'Indicar adoção a um amigo',
          description: 'Convide alguém para ser seu co-parent',
          icon: Icons.share,
          color: AppTheme.accentPeach,
          onTap: _handleShareAdoption,
          isOutlined: true,
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: 800.ms)
            .slideY(begin: 0.2, end: 0),
      ],
    );
  }
}
