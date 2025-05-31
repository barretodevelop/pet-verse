// // lib/features/adoption/presentation/pages/create_request_page.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';
// import 'package:lottie/lottie.dart';
// import 'package:petverse/core/model/pet_model.dart';
// import 'package:petverse/core/providers/adoption_provider.dart';
// import 'package:petverse/core/providers/pet_provider.dart';
// import 'package:petverse/core/providers/user_provider.dart';
// import 'package:petverse/feature/adoption/presentation/widgets/pet_selection_card.dart';

// import '../../../../core/constants/app_constants.dart';
// import '../../../../core/theme/app_theme.dart' hide AppConstants;
// import '../../../../core/utils/app_utils.dart';

// class CreateRequestPage extends ConsumerStatefulWidget {
//   const CreateRequestPage({super.key});

//   @override
//   ConsumerState<CreateRequestPage> createState() => _CreateRequestPageState();
// }

// class _CreateRequestPageState extends ConsumerState<CreateRequestPage>
//     with TickerProviderStateMixin {
//   late AnimationController _listController;
//   late TabController _tabController;
//   bool _isCreating = false;
//   String? _createdRequestId;

//   @override
//   void initState() {
//     super.initState();
//     _listController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );
//     _tabController = TabController(length: 2, vsync: this);

//     _listController.forward();
//   }

//   @override
//   void dispose() {
//     _listController.dispose();
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleCreateRequest() async {
//     final selectedPets = ref.read(selectedPetsProvider);
//     final user = ref.read(currentUserProvider).value;

//     if (selectedPets.isEmpty) {
//       AppUtils.showErrorSnackbar(context, 'Selecione pelo menos um pet');
//       return;
//     }

//     if (user == null) {
//       AppUtils.showErrorSnackbar(context, 'Usuário não encontrado');
//       return;
//     }

//     setState(() => _isCreating = true);
//     AppUtils.mediumImpact();

//     try {
//       final requestId = await ref
//           .read(adoptionNotifierProvider.notifier)
//           .createAdoptionRequest(
//             requesterId: user.id,
//             requesterName: user.displayName,
//             selectedPetIds: selectedPets,
//           );

//       setState(() {
//         _isCreating = false;
//         _createdRequestId = requestId;
//       });

//       // Clear selection
//       ref.read(selectedPetsProvider.notifier).clear();

//       AppUtils.showSuccessSnackbar(
//         context,
//         AppConstants.adoptionRequestCreated,
//       );
//     } catch (e) {
//       setState(() => _isCreating = false);
//       AppUtils.showErrorSnackbar(
//         context,
//         'Erro ao criar pedido: ${e.toString()}',
//       );
//     }
//   }

//   void _handleShareRequest() async {
//     if (_createdRequestId == null) return;

//     try {
//       final shareLink = await ref
//           .read(adoptionNotifierProvider.notifier)
//           .generateShareLink(_createdRequestId!);

//       await AppUtils.shareAdoptionRequest(_createdRequestId!, 'Você');
//       AppUtils.showSuccessSnackbar(context, AppConstants.linkCopied);
//     } catch (e) {
//       AppUtils.showErrorSnackbar(context, 'Erro ao compartilhar');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_createdRequestId != null) {
//       return CreateRequestSuccess(
//         requestId: _createdRequestId!,
//         onShare: _handleShareRequest,
//         onViewPublicList: () => context.go('/public-adoptions'),
//         onGoHome: () => context.go('/home'),
//       );
//     }

//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: AppTheme.backgroundGradient,
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               _buildAppBar(),
//               _buildTabBar(),
//               Expanded(child: _buildTabContent()),
//               _buildBottomActions(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAppBar() {
//     return Container(
//       padding: EdgeInsets.all(16.w),
//       child: Row(
//         children: [
//           IconButton(
//             onPressed: () {
//               AppUtils.lightImpact();
//               context.pop();
//             },
//             icon: Container(
//               padding: EdgeInsets.all(8.w),
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 shape: BoxShape.circle,
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppTheme.cardShadow,
//                     blurRadius: 10,
//                     offset: Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Icon(
//                 Icons.arrow_back_ios_new,
//                 color: AppTheme.textPrimary,
//                 size: 20.sp,
//               ),
//             ),
//           ),
//           SizedBox(width: 16.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Criar Pedido',
//                   style: AppTheme.headingMedium.copyWith(
//                     color: AppTheme.primarySoft,
//                   ),
//                 ),
//                 Text(
//                   'Escolha até ${AppConstants.maxPetsPerRequest} pets',
//                   style: AppTheme.bodySmall.copyWith(
//                     color: AppTheme.textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.3, end: 0);
//   }

//   Widget _buildTabBar() {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 16.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         boxShadow: const [
//           BoxShadow(
//             color: AppTheme.cardShadow,
//             blurRadius: 10,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: TabBar(
//         controller: _tabController,
//         indicator: BoxDecoration(
//           gradient: AppTheme.primaryGradient,
//           borderRadius: BorderRadius.circular(16.r),
//         ),
//         indicatorSize: TabBarIndicatorSize.tab,
//         dividerColor: Colors.transparent,
//         labelColor: Colors.white,
//         unselectedLabelColor: AppTheme.textSecondary,
//         labelStyle: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
//         tabs: const [
//           Tab(text: 'Pets Disponíveis'),
//           Tab(text: 'Selecionados'),
//         ],
//       ),
//     )
//         .animate()
//         .fadeIn(duration: 500.ms, delay: 200.ms)
//         .slideY(begin: -0.2, end: 0);
//   }

//   Widget _buildTabContent() {
//     return TabBarView(
//       controller: _tabController,
//       children: [
//         _buildAvailablePetsTab(),
//         _buildSelectedPetsTab(),
//       ],
//     );
//   }

//   Widget _buildAvailablePetsTab() {
//     final availablePetsAsync = ref.watch(availablePetsProvider);

//     return availablePetsAsync.when(
//       data: (pets) => _buildPetsList(pets),
//       loading: () => _buildLoadingState(),
//       error: (error, stack) => _buildErrorState(error.toString()),
//     );
//   }

//   Widget _buildSelectedPetsTab() {
//     final selectedPetIds = ref.watch(selectedPetsProvider);

//     if (selectedPetIds.isEmpty) {
//       return _buildEmptySelectedState();
//     }

//     final selectedPetsAsync = ref.watch(petsByIdsProvider(selectedPetIds));

//     return selectedPetsAsync.when(
//       data: (pets) => SelectedPetsSummary(pets: pets),
//       loading: () => _buildLoadingState(),
//       error: (error, stack) => _buildErrorState(error.toString()),
//     );
//   }

//   Widget _buildPetsList(List<PetModel> pets) {
//     if (pets.isEmpty) {
//       return _buildEmptyState();
//     }

//     return AnimatedList(
//       padding: EdgeInsets.all(16.w),
//       physics: const BouncingScrollPhysics(),
//       initialItemCount: pets.length,
//       itemBuilder: (context, index, animation) {
//         final pet = pets[index];
//         return SlideTransition(
//           position: animation.drive(
//             Tween(begin: const Offset(1, 0), end: Offset.zero)
//                 .chain(CurveTween(curve: Curves.easeOutCubic)),
//           ),
//           child: FadeTransition(
//             opacity: animation,
//             child: Padding(
//               padding: EdgeInsets.only(bottom: 16.h),
//               child: PetSelectionCard(pet: pet),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildLoadingState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(
//             width: 80.w,
//             height: 80.w,
//             child: Lottie.asset(
//               AppConstants.loadingAnimation,
//               fit: BoxFit.contain,
//             ),
//           ),
//           SizedBox(height: 16.h),
//           Text(
//             'Carregando pets...',
//             style: AppTheme.bodyMedium,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorState(String error) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.error_outline,
//             size: 64.sp,
//             color: AppTheme.error,
//           ),
//           SizedBox(height: 16.h),
//           Text(
//             'Erro ao carregar pets',
//             style: AppTheme.headingSmall,
//           ),
//           SizedBox(height: 8.h),
//           Text(
//             error,
//             style: AppTheme.bodySmall,
//             textAlign: TextAlign.center,
//           ),
//           SizedBox(height: 24.h),
//           ElevatedButton(
//             onPressed: () => ref.refresh(availablePetsProvider),
//             child: const Text('Tentar Novamente'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(
//             width: 120.w,
//             height: 120.w,
//             child: Lottie.asset(
//               AppConstants.emptyStateAnimation,
//               fit: BoxFit.contain,
//             ),
//           ),
//           SizedBox(height: 24.h),
//           Text(
//             'Nenhum pet disponível',
//             style: AppTheme.headingSmall,
//           ),
//           SizedBox(height: 8.h),
//           Text(
//             'Não há pets disponíveis para adoção no momento.',
//             style: AppTheme.bodyMedium,
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptySelectedState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 100.w,
//             height: 100.w,
//             decoration: BoxDecoration(
//               color: AppTheme.primarySoft.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.pets,
//               size: 48.sp,
//               color: AppTheme.primarySoft,
//             ),
//           ),
//           SizedBox(height: 24.h),
//           Text(
//             'Nenhum pet selecionado',
//             style: AppTheme.headingSmall,
//           ),
//           SizedBox(height: 8.h),
//           Text(
//             'Volte para a aba anterior e escolha\nuns pets para adotar!',
//             style: AppTheme.bodyMedium,
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     )
//         .animate()
//         .fadeIn(duration: 400.ms)
//         .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0));
//   }

//   Widget _buildBottomActions() {
//     final selectedPets = ref.watch(selectedPetsProvider);
//     final hasSelection = selectedPets.isNotEmpty;

//     return Container(
//       padding: EdgeInsets.all(16.w),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: AppTheme.cardShadow,
//             blurRadius: 10,
//             offset: Offset(0, -2),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Selection counter
//             if (hasSelection)
//               Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
//                 margin: EdgeInsets.only(bottom: 16.h),
//                 decoration: BoxDecoration(
//                   gradient: AppTheme.primaryGradient.scale(0.1),
//                   borderRadius: BorderRadius.circular(12.r),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.check_circle,
//                       color: AppTheme.primarySoft,
//                       size: 20.sp,
//                     ),
//                     SizedBox(width: 8.w),
//                     Text(
//                       '${selectedPets.length} pet${selectedPets.length > 1 ? 's' : ''} selecionado${selectedPets.length > 1 ? 's' : ''}',
//                       style: AppTheme.bodyMedium.copyWith(
//                         color: AppTheme.primarySoft,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.3, end: 0),

//             // Create request button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed:
//                     hasSelection && !_isCreating ? _handleCreateRequest : null,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor:
//                       hasSelection ? AppTheme.primarySoft : AppTheme.textLight,
//                   padding: EdgeInsets.symmetric(vertical: 16.h),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16.r),
//                   ),
//                 ),
//                 child: _isCreating
//                     ? SizedBox(
//                         height: 20.h,
//                         width: 20.w,
//                         child: const CircularProgressIndicator(
//                           color: Colors.white,
//                           strokeWidth: 2,
//                         ),
//                       )
//                     : Text(
//                         hasSelection
//                             ? 'Criar Pedido de Adoção'
//                             : 'Selecione pelo menos um pet',
//                         style: AppTheme.buttonText,
//                       ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     )
//         .animate()
//         .fadeIn(duration: 600.ms, delay: 400.ms)
//         .slideY(begin: 0.3, end: 0);
//   }
// }
