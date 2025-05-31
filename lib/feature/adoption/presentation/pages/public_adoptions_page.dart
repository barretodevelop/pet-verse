// // lib/features/adoption/presentation/pages/public_adoptions_page.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';
// import 'package:lottie/lottie.dart';
// import 'package:petverse/core/constants/app_constants.dart';
// import 'package:petverse/core/model/adoption_request_model.dart';
// import 'package:petverse/core/providers/adoption_provider.dart';
// import 'package:petverse/core/providers/user_provider.dart';

// import '../../../../core/theme/app_theme.dart';
// import '../../../../core/utils/app_utils.dart';

// class PublicAdoptionsPage extends ConsumerStatefulWidget {
//   const PublicAdoptionsPage({super.key});

//   @override
//   ConsumerState<PublicAdoptionsPage> createState() =>
//       _PublicAdoptionsPageState();
// }

// class _PublicAdoptionsPageState extends ConsumerState<PublicAdoptionsPage>
//     with TickerProviderStateMixin {
//   late AnimationController _refreshController;
//   final ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     _refreshController = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );
//   }

//   @override
//   void dispose() {
//     _refreshController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleRefresh() async {
//     _refreshController.forward();
//     ref.refresh(watchPublicAdoptionRequestsProvider);
//     await Future.delayed(const Duration(milliseconds: 1000));
//     if (mounted) {
//       _refreshController.reverse();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final adoptionRequestsAsync =
//         ref.watch(watchPublicAdoptionRequestsProvider);
//     final filters = ref.watch(adoptionFiltersProvider);

//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: AppTheme.backgroundGradient,
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               _buildAppBar(),
//               SearchFilterBar(filters: filters),
//               Expanded(
//                 child: adoptionRequestsAsync.when(
//                   data: (requests) => _buildRequestsList(
//                     _filterRequests(requests, filters),
//                   ),
//                   loading: () => _buildLoadingState(),
//                   error: (error, stack) => _buildErrorState(error.toString()),
//                 ),
//               ),
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
//                   'Pedidos Públicos',
//                   style: AppTheme.headingMedium.copyWith(
//                     color: AppTheme.primarySoft,
//                   ),
//                 ),
//                 Text(
//                   'Encontre um pet para co-adotar',
//                   style: AppTheme.bodySmall.copyWith(
//                     color: AppTheme.textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Refresh button
//           AnimatedBuilder(
//             animation: _refreshController,
//             builder: (context, child) {
//               return Transform.rotate(
//                 angle: _refreshController.value * 2 * 3.14159,
//                 child: IconButton(
//                   onPressed: _handleRefresh,
//                   icon: Container(
//                     padding: EdgeInsets.all(8.w),
//                     decoration: BoxDecoration(
//                       color: AppTheme.primarySoft.withOpacity(0.1),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.refresh,
//                       color: AppTheme.primarySoft,
//                       size: 20.sp,
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.3, end: 0);
//   }

//   List<AdoptionRequestModel> _filterRequests(
//     List<AdoptionRequestModel> requests,
//     AdoptionFilters filters,
//   ) {
//     var filtered = requests.where((request) => request.isPending).toList();

//     // Filter by search term
//     if (filters.searchTerm.isNotEmpty) {
//       filtered = filtered.where((request) {
//         return request.requesterdisplayName
//             .toLowerCase()
//             .contains(filters.searchTerm.toLowerCase());
//       }).toList();
//     }

//     // Filter by max days remaining
//     filtered = filtered.where((request) {
//       return request.daysRemaining <= filters.maxDaysRemaining;
//     }).toList();

//     // Sort by creation date (newest first)
//     filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

//     return filtered;
//   }

//   Widget _buildRequestsList(List<AdoptionRequestModel> requests) {
//     if (requests.isEmpty) {
//       return _buildEmptyState();
//     }

//     return RefreshIndicator(
//       onRefresh: _handleRefresh,
//       color: AppTheme.primarySoft,
//       child: ListView.builder(
//         controller: _scrollController,
//         padding: EdgeInsets.all(16.w),
//         physics: const BouncingScrollPhysics(),
//         itemCount: requests.length,
//         itemBuilder: (context, index) {
//           final request = requests[index];
//           return Padding(
//             padding: EdgeInsets.only(bottom: 16.h),
//             child: AdoptionRequestCard(
//               request: request,
//               onTap: () {
//                 AppUtils.lightImpact();
//                 context.push('/adoption-details/${request.id}');
//               },
//             )
//                 .animate()
//                 .fadeIn(
//                   duration: 400.ms,
//                   delay: Duration(milliseconds: index * 100),
//                 )
//                 .slideX(begin: 0.2, end: 0),
//           );
//         },
//       ),
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
//             'Carregando pedidos...',
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
//             'Erro ao carregar pedidos',
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
//             onPressed: _handleRefresh,
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
//             'Nenhum pedido encontrado',
//             style: AppTheme.headingSmall,
//           ),
//           SizedBox(height: 8.h),
//           Text(
//             'Não há pedidos de adoção disponíveis\nno momento.',
//             style: AppTheme.bodyMedium,
//             textAlign: TextAlign.center,
//           ),
//           SizedBox(height: 24.h),
//           ElevatedButton(
//             onPressed: () => context.push('/create-request'),
//             child: const Text('Criar Meu Pedido'),
//           ),
//         ],
//       ),
//     )
//         .animate()
//         .fadeIn(duration: 400.ms)
//         .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0));
//   }
// }

// // lib/features/adoption/presentation/widgets/search_filter_bar.dart
// class SearchFilterBar extends ConsumerStatefulWidget {
//   final AdoptionFilters filters;

//   const SearchFilterBar({
//     super.key,
//     required this.filters,
//   });

//   @override
//   ConsumerState<SearchFilterBar> createState() => _SearchFilterBarState();
// }

// class _SearchFilterBarState extends ConsumerState<SearchFilterBar> {
//   late TextEditingController _searchController;

//   @override
//   void initState() {
//     super.initState();
//     _searchController = TextEditingController(text: widget.filters.searchTerm);
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//       child: Column(
//         children: [
//           // Search bar
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16.r),
//               boxShadow: const [
//                 BoxShadow(
//                   color: AppTheme.cardShadow,
//                   blurRadius: 10,
//                   offset: Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: TextField(
//               controller: _searchController,
//               onChanged: (value) {
//                 ref
//                     .read(adoptionFiltersProvider.notifier)
//                     .updateSearchTerm(value);
//               },
//               decoration: InputDecoration(
//                 hintText: 'Buscar por nome do solicitante...',
//                 hintStyle: AppTheme.bodyMedium.copyWith(
//                   color: AppTheme.textLight,
//                 ),
//                 prefixIcon: Icon(
//                   Icons.search,
//                   color: AppTheme.textLight,
//                   size: 20.sp,
//                 ),
//                 suffixIcon: widget.filters.searchTerm.isNotEmpty
//                     ? IconButton(
//                         onPressed: () {
//                           _searchController.clear();
//                           ref
//                               .read(adoptionFiltersProvider.notifier)
//                               .updateSearchTerm('');
//                         },
//                         icon: Icon(
//                           Icons.clear,
//                           color: AppTheme.textLight,
//                           size: 20.sp,
//                         ),
//                       )
//                     : null,
//                 border: InputBorder.none,
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 16.w,
//                   vertical: 16.h,
//                 ),
//               ),
//             ),
//           ),

//           SizedBox(height: 12.h),

//           // Filter chips
//           Row(
//             children: [
//               Expanded(
//                 child: SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   physics: const BouncingScrollPhysics(),
//                   child: Row(
//                     children: [
//                       _buildFilterChip(
//                         label: 'Todos os dias',
//                         isSelected: widget.filters.maxDaysRemaining == 5,
//                         onTap: () => ref
//                             .read(adoptionFiltersProvider.notifier)
//                             .updateMaxDays(5),
//                       ),
//                       SizedBox(width: 8.w),
//                       _buildFilterChip(
//                         label: 'Expira hoje',
//                         isSelected: widget.filters.maxDaysRemaining == 1,
//                         onTap: () => ref
//                             .read(adoptionFiltersProvider.notifier)
//                             .updateMaxDays(1),
//                       ),
//                       SizedBox(width: 8.w),
//                       _buildFilterChip(
//                         label: 'Próximos 3 dias',
//                         isSelected: widget.filters.maxDaysRemaining == 3,
//                         onTap: () => ref
//                             .read(adoptionFiltersProvider.notifier)
//                             .updateMaxDays(3),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               // Clear filters button
//               if (widget.filters.searchTerm.isNotEmpty ||
//                   widget.filters.maxDaysRemaining != 5)
//                 IconButton(
//                   onPressed: () {
//                     _searchController.clear();
//                     ref.read(adoptionFiltersProvider.notifier).clearFilters();
//                     AppUtils.lightImpact();
//                   },
//                   icon: Container(
//                     padding: EdgeInsets.all(6.w),
//                     decoration: BoxDecoration(
//                       color: AppTheme.error.withOpacity(0.1),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.clear_all,
//                       color: AppTheme.error,
//                       size: 16.sp,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ],
//       ),
//     )
//         .animate()
//         .fadeIn(duration: 500.ms, delay: 200.ms)
//         .slideY(begin: -0.2, end: 0);
//   }

//   Widget _buildFilterChip({
//     required String label,
//     required bool isSelected,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: () {
//         AppUtils.lightImpact();
//         onTap();
//       },
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
//         decoration: BoxDecoration(
//           color: isSelected ? AppTheme.primarySoft : Colors.white,
//           borderRadius: BorderRadius.circular(20.r),
//           border: Border.all(
//             color: isSelected
//                 ? AppTheme.primarySoft
//                 : AppTheme.textLight.withOpacity(0.3),
//             width: 1.w,
//           ),
//         ),
//         child: Text(
//           label,
//           style: AppTheme.bodySmall.copyWith(
//             color: isSelected ? Colors.white : AppTheme.textSecondary,
//             fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
//           ),
//         ),
//       ),
//     );
//   }
// }

// // lib/features/adoption/presentation/widgets/adoption_request_card.dart
// class AdoptionRequestCard extends StatefulWidget {
//   final AdoptionRequestModel request;
//   final VoidCallback onTap;

//   const AdoptionRequestCard({
//     super.key,
//     required this.request,
//     required this.onTap,
//   });

//   @override
//   State<AdoptionRequestCard> createState() => _AdoptionRequestCardState();
// }

// class _AdoptionRequestCardState extends State<AdoptionRequestCard>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _scaleController;
//   late Animation<double> _scaleAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _scaleController = AnimationController(
//       duration: const Duration(milliseconds: 100),
//       vsync: this,
//     );
//     _scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 0.98,
//     ).animate(CurvedAnimation(
//       parent: _scaleController,
//       curve: Curves.easeInOut,
//     ));
//   }

//   @override
//   void dispose() {
//     _scaleController.dispose();
//     super.dispose();
//   }

//   void _handleTapDown(TapDownDetails details) {
//     _scaleController.forward();
//   }

//   void _handleTapUp(TapUpDetails details) {
//     _scaleController.reverse();
//   }

//   void _handleTapCancel() {
//     _scaleController.reverse();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final urgencyColor = _getUrgencyColor(widget.request.daysRemaining);

//     return AnimatedBuilder(
//       animation: _scaleAnimation,
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _scaleAnimation.value,
//           child: GestureDetector(
//             onTapDown: _handleTapDown,
//             onTapUp: _handleTapUp,
//             onTapCancel: _handleTapCancel,
//             onTap: widget.onTap,
//             child: Container(
//               width: double.infinity,
//               padding: EdgeInsets.all(20.w),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Colors.white,
//                     urgencyColor.withOpacity(0.02),
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(20.r),
//                 border: Border.all(
//                   color: urgencyColor.withOpacity(0.2),
//                   width: 1.w,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: urgencyColor.withOpacity(0.1),
//                     blurRadius: 15,
//                     offset: const Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Header
//                   Row(
//                     children: [
//                       // Avatar
//                       Container(
//                         width: 48.w,
//                         height: 48.w,
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                             colors: [
//                               urgencyColor,
//                               urgencyColor.withOpacity(0.7)
//                             ],
//                           ),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Center(
//                           child: Text(
//                             widget.request.requesterdisplayName
//                                 .substring(0, 1)
//                                 .toUpperCase(),
//                             style: AppTheme.bodyLarge.copyWith(
//                               color: Colors.white,
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                         ),
//                       ),

//                       SizedBox(width: 12.w),

//                       // Name and time
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               widget.request.requesterdisplayName,
//                               style: AppTheme.bodyLarge.copyWith(
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             Text(
//                               'Criado ${AppUtils.formatDate(widget.request.createdAt)}',
//                               style: AppTheme.bodySmall.copyWith(
//                                 color: AppTheme.textSecondary,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       // Time remaining
//                       Container(
//                         padding: EdgeInsets.symmetric(
//                             horizontal: 8.w, vertical: 4.h),
//                         decoration: BoxDecoration(
//                           color: urgencyColor.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(12.r),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(
//                               Icons.access_time,
//                               color: urgencyColor,
//                               size: 14.sp,
//                             ),
//                             SizedBox(width: 4.w),
//                             Text(
//                               AppUtils.formatTimeRemaining(
//                                   widget.request.expiresAt),
//                               style: AppTheme.captionText.copyWith(
//                                 color: urgencyColor,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),

//                   SizedBox(height: 16.h),

//                   // Pets count
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.pets,
//                         color: AppTheme.primarySoft,
//                         size: 16.sp,
//                       ),
//                       SizedBox(width: 6.w),
//                       Text(
//                         '${widget.request.selectedPetIds.length} pet${widget.request.selectedPetIds.length > 1 ? 's' : ''} disponível${widget.request.selectedPetIds.length > 1 ? 'eis' : ''}',
//                         style: AppTheme.bodyMedium.copyWith(
//                           color: AppTheme.primarySoft,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       const Spacer(),
//                       Icon(
//                         Icons.arrow_forward_ios,
//                         color: AppTheme.textLight,
//                         size: 14.sp,
//                       ),
//                     ],
//                   ),

//                   SizedBox(height: 12.h),

//                   // Progress bar
//                   Row(
//                     children: [
//                       Text(
//                         'Tempo restante',
//                         style: AppTheme.bodySmall.copyWith(
//                           color: AppTheme.textSecondary,
//                         ),
//                       ),
//                       const Spacer(),
//                       Text(
//                         '${widget.request.daysRemaining}/5 dias',
//                         style: AppTheme.bodySmall.copyWith(
//                           color: urgencyColor,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),

//                   SizedBox(height: 8.h),

//                   LinearProgressIndicator(
//                     value: (5 - widget.request.daysRemaining) / 5,
//                     backgroundColor: urgencyColor.withOpacity(0.1),
//                     valueColor: AlwaysStoppedAnimation<Color>(urgencyColor),
//                     borderRadius: BorderRadius.circular(4.r),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Color _getUrgencyColor(int daysRemaining) {
//     if (daysRemaining <= 1) return AppTheme.error;
//     if (daysRemaining <= 2) return AppTheme.warning;
//     return AppTheme.success;
//   }
// }

// // lib/features/adoption/presentation/pages/adoption_details_page.dart
// class AdoptionDetailsPage extends ConsumerStatefulWidget {
//   final String requestId;
//   final bool isSharedLink;

//   const AdoptionDetailsPage({
//     super.key,
//     required this.requestId,
//     this.isSharedLink = false,
//   });

//   @override
//   ConsumerState<AdoptionDetailsPage> createState() =>
//       _AdoptionDetailsPageState();
// }

// class _AdoptionDetailsPageState extends ConsumerState<AdoptionDetailsPage> {
//   String? _selectedPetId;
//   bool _isAccepting = false;

//   Future<void> _handleAcceptAdoption() async {
//     if (_selectedPetId == null) {
//       AppUtils.showErrorSnackbar(context, 'Selecione um pet primeiro');
//       return;
//     }

//     final user = ref.read(currentUserProvider).value;
//     if (user == null) {
//       AppUtils.showErrorSnackbar(context, 'Usuário não encontrado');
//       return;
//     }

//     setState(() => _isAccepting = true);
//     AppUtils.mediumImpact();

//     try {
//       await ref.read(adoptionNotifierProvider.notifier).acceptAdoptionRequest(
//             requestId: widget.requestId,
//             petId: _selectedPetId!,
//             coParentId: user.id,
//             coParentName: user.displayName,
//           );

//       // Refresh user data
//       ref.refresh(currentUserProvider);

//       if (mounted) {
//         AppUtils.showSuccessSnackbar(
//           context,
//           AppConstants.adoptionAccepted,
//         );

//         // Navigate to pet main page
//         context.go('/pet-main');
//       }
//     } catch (e) {
//       setState(() => _isAccepting = false);
//       if (mounted) {
//         AppUtils.showErrorSnackbar(
//           context,
//           'Erro ao aceitar adoção: ${e.toString()}',
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // For now, we'll create a simple details page
//     // In a real app, you'd fetch the adoption request details

//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: AppTheme.backgroundGradient,
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // App bar
//               Container(
//                 padding: EdgeInsets.all(16.w),
//                 child: Row(
//                   children: [
//                     IconButton(
//                       onPressed: () => context.pop(),
//                       icon: Container(
//                         padding: EdgeInsets.all(8.w),
//                         decoration: const BoxDecoration(
//                           color: Colors.white,
//                           shape: BoxShape.circle,
//                           boxShadow: [
//                             BoxShadow(
//                               color: AppTheme.cardShadow,
//                               blurRadius: 10,
//                               offset: Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: Icon(
//                           Icons.arrow_back_ios_new,
//                           color: AppTheme.textPrimary,
//                           size: 20.sp,
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 16.w),
//                     Expanded(
//                       child: Text(
//                         'Detalhes da Adoção',
//                         style: AppTheme.headingMedium.copyWith(
//                           color: AppTheme.primarySoft,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // Content placeholder
//               Expanded(
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.pets,
//                         size: 80.sp,
//                         color: AppTheme.primarySoft,
//                       ),
//                       SizedBox(height: 24.h),
//                       Text(
//                         'Detalhes da Adoção',
//                         style: AppTheme.headingMedium,
//                       ),
//                       SizedBox(height: 8.h),
//                       Text(
//                         'ID: ${widget.requestId.substring(0, 8).toUpperCase()}',
//                         style: AppTheme.bodyMedium.copyWith(
//                           fontFamily: 'monospace',
//                           color: AppTheme.textSecondary,
//                         ),
//                       ),
//                       if (widget.isSharedLink) ...[
//                         SizedBox(height: 16.h),
//                         Container(
//                           padding: EdgeInsets.all(12.w),
//                           decoration: BoxDecoration(
//                             color: AppTheme.accentCoral.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(12.r),
//                           ),
//                           child: Text(
//                             'Compartilhado via link',
//                             style: AppTheme.bodySmall.copyWith(
//                               color: AppTheme.accentCoral,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ],
//                       SizedBox(height: 32.h),
//                       Text(
//                         'Esta página mostraria os detalhes completos\ndo pedido de adoção e os pets disponíveis.',
//                         style: AppTheme.bodyMedium,
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
