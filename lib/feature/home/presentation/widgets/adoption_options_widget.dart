// lib/features/home/presentation/widgets/adoption_options_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/core/model/user_model.dart';
import 'package:petverse/core/utils/app_utils.dart';
import 'package:petverse/core/widgets/custom_action_button.dart';

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

  @override
  Widget build(BuildContext context) {
    return _buildAdoptPetCard();
  }

  Widget _buildAdoptPetCard() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Card informativo - altura controlada
              Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight: 120.h,
                  maxHeight: 210.h,
                ),
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFF8FAFC), // Branco azulado
                      Color(0xFFF1F5F9), // Cinza azulado muito claro
                      Color(0xFFE2E8F0), // Cinza claro
                    ],
                    stops: [0.0, 0.6, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: const Color(0xFFCBD5E1).withOpacity(0.3),
                    width: 1.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF64748B).withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: const Color(0xFF94A3B8).withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ícone do pet - centralizado
                    Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF60A5FA), // Azul claro
                            Color(0xFF3B82F6), // Azul médio
                            Color(0xFF2563EB), // Azul escuro
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.pets_rounded,
                        size: 30.sp,
                        color: Colors.white,
                      ),
                    )
                        .animate(
                            onPlay: (controller) =>
                                controller.repeat(reverse: true))
                        .scale(
                          begin: const Offset(1.0, 1.0),
                          end: const Offset(1.08, 1.08),
                          duration: 2500.ms,
                        )
                        .shimmer(
                          delay: 1200.ms,
                          duration: 1800.ms,
                          color: Colors.white.withOpacity(0.4),
                        ),

                    SizedBox(height: 12.h),

                    // Título
                    Text(
                      'Adote um Pet',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    )
                        .animate(delay: 300.ms)
                        .fadeIn(duration: 800.ms)
                        .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),

                    SizedBox(height: 6.h),

                    // Descrição
                    Text(
                      'Encontre seu companheiro perfeito\ne transforme duas vidas para sempre',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF64748B),
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                        .animate(delay: 500.ms)
                        .fadeIn(duration: 800.ms)
                        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 1000.ms)
                  .slideY(begin: -0.2, end: 0, curve: Curves.easeOutCubic),

              SizedBox(height: 16.h),

              // Botões - altura controlada
              ...List.generate(3, (index) {
                final buttons = [
                  {
                    'text': 'Ver Pets Disponíveis',
                    'subtitle': 'pets disponiveis para adoção compartilhada',
                    'icon': Icons.pets_outlined,
                    'gradient': const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                    ),
                    'onTap': () {
                      AppUtils.mediumImpact();
                      context.push('/list-adoption');
                    },
                  },
                  {
                    'text': 'Criar uma Adoção',
                    'subtitle':
                        'Após sua escolha, o pet aguardará a aprovação da segunda pessoa para a adoção.',
                    'icon': Icons.add_circle_outline,
                    'gradient': const LinearGradient(
                      colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                    ),
                    'onTap': () {
                      AppUtils.mediumImpact();
                      context.push('/create-adoption');
                    },
                  },
                  {
                    'text': 'Convidar Amigo',
                    'subtitle':
                        'Aqui você convida uma amigo pra fazer a adoção conjunta com voce.',
                    'icon': Icons.share_outlined,
                    'gradient': const LinearGradient(
                      colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
                    ),
                    'onTap': () {
                      AppUtils.mediumImpact();
                      // _showShareBottomSheet();
                    },
                  },
                ];

                return Column(
                  children: [
                    BuildActionButton(
                      onTap: buttons[index]['onTap'] as VoidCallback,
                      text: buttons[index]['text'] as String,
                      subtitle: buttons[index]['subtitle'] as String,
                      icon: buttons[index]['icon'] as IconData,
                      gradient: buttons[index]['gradient'] as Gradient,
                      delay: 700 + (index * 150),
                    ),
                    if (index < 2) SizedBox(height: 10.h),
                  ],
                );
              }),

              // Espaço final para evitar overlap com bottom navigator
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
