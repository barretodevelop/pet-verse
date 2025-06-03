// lib/feature/adoption/presentation/pages/list_adoption_page.dart
// ATUALIZADO: Usa UnifiedUserStateProvider e AdoptionFlowService para fluxo robusto

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdoptionListPage extends ConsumerStatefulWidget {
  const AdoptionListPage({super.key});

  @override
  ConsumerState<AdoptionListPage> createState() => _AdoptionListPageState();
}

class _AdoptionListPageState extends ConsumerState<AdoptionListPage>
    with TickerProviderStateMixin {
  bool isLoading = true;
  String selectedFilter = 'Todas';

  late AnimationController _pulseController;

  // final List<String> filters = [
  //   'Todas',
  //   'Urgentes',
  //   'Novas',
  //   'Experientes',
  //   'Filhotes',
  //   'Especiais',
  //   'Sênior'
  // ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseController.repeat(reverse: true);

    // _initializeFirebaseData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // Future<void> _initializeFirebaseData() async {
  //   // await ref.read(initializeMockDataProvider.future);
  //   setState(() {
  //     isLoading = false;
  //   });
  // }

  // // List<CollaborativeAdoptionRequest> _getFilteredAdoptions(
  // //     List<CollaborativeAdoptionRequest> adoptions) {
  // //   switch (selectedFilter) {
  // //     case 'Urgentes':
  // //       return adoptions.where((a) => a.isUrgent).toList();
  // //     case 'Novas':
  // //       return adoptions.where((a) => a.isNew).toList();
  // //     case 'Experientes':
  // //       return adoptions.where((a) => a.requesterLevel >= 15).toList();
  // //     case 'Filhotes':
  // //       return adoptions.where((a) => _hasTraitInPets(a, 'filhote')).toList();
  // //     case 'Especiais':
  // //       return adoptions.where((a) => _hasTraitInPets(a, 'especial')).toList();
  // //     case 'Sênior':
  // //       return adoptions.where((a) => _hasTraitInPets(a, 'sênior')).toList();
  // //     default:
  // //       return adoptions;
  // //   }
  // // }

  // bool _hasTraitInPets(CollaborativeAdoptionRequest adoption, String trait) {
  //   return adoption.requesterLevel > 10; // Placeholder
  // }

  // void _onAdoptionTap(CollaborativeAdoptionRequest adoption) {
  //   HapticFeedback.lightImpact();

  //   ref
  //       .read(firebaseAdoptionNotifierProvider.notifier)
  //       .incrementViews(adoption.id);

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text('Abrindo adoção ${adoption.requesterCodename}...'),
  //       backgroundColor: Color(adoption.requesterColorTheme),
  //     ),
  //   );
  // }

  // void _onPetTap(String petId, CollaborativeAdoptionRequest adoption) {
  //   HapticFeedback.lightImpact();
  //   _showPetDetailsModal(petId, adoption);
  // }

  // void _showPetDetailsModal(
  //     String petId, CollaborativeAdoptionRequest adoption) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => _buildPetDetailsModal(petId, adoption),
  //   );
  // }

  // Widget _buildPetDetailsModal(
  //     String petId, CollaborativeAdoptionRequest adoption) {
  //   return FutureBuilder<List<FirebasePetModel>>(
  //     future: ref.read(petsFromRequestProvider(adoption.id).future),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return Container(
  //           height: MediaQuery.of(context).size.height * 0.85,
  //           decoration: const BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.only(
  //               topLeft: Radius.circular(24),
  //               topRight: Radius.circular(24),
  //             ),
  //           ),
  //           child: const Center(child: CircularProgressIndicator()),
  //         );
  //       }

  //       if (snapshot.hasError || !snapshot.hasData) {
  //         return Container(
  //           height: MediaQuery.of(context).size.height * 0.85,
  //           decoration: const BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.only(
  //               topLeft: Radius.circular(24),
  //               topRight: Radius.circular(24),
  //             ),
  //           ),
  //           child: const Center(child: Text('Erro ao carregar pet')),
  //         );
  //       }

  //       final pets = snapshot.data!;
  //       final pet = pets.firstWhere(
  //         (p) => p.id == petId,
  //         orElse: () => pets.first,
  //       );

  //       return _buildPetDetailsContent(pet, adoption);
  //     },
  //   );
  // }

  // Widget _buildPetDetailsContent(
  //     FirebasePetModel pet, CollaborativeAdoptionRequest adoption) {
  //   return Container(
  //     height: MediaQuery.of(context).size.height * 0.75,
  //     decoration: const BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.only(
  //         topLeft: Radius.circular(24),
  //         topRight: Radius.circular(24),
  //       ),
  //     ),
  //     child: Column(
  //       children: [
  //         // Handle bar
  //         Container(
  //           margin: const EdgeInsets.only(top: 8),
  //           width: 40,
  //           height: 4,
  //           decoration: BoxDecoration(
  //             color: const Color(0xFFE2E8F0),
  //             borderRadius: BorderRadius.circular(2),
  //           ),
  //         ),

  //         // Header compacto
  //         Padding(
  //           padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
  //           child: Row(
  //             children: [
  //               const Expanded(
  //                 child: Text(
  //                   'Detalhes do Pet',
  //                   style: TextStyle(
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.w700,
  //                     color: Color(0xFF0F172A),
  //                   ),
  //                 ),
  //               ),
  //               IconButton(
  //                 onPressed: () => Navigator.pop(context),
  //                 icon: const Icon(
  //                   Icons.close,
  //                   color: Color(0xFF64748B),
  //                   size: 22,
  //                 ),
  //                 padding: EdgeInsets.zero,
  //                 constraints: const BoxConstraints(
  //                   minWidth: 32,
  //                   minHeight: 32,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),

  //         // Content
  //         Expanded(
  //           child: Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 20),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 _buildCompactPetHeader(pet, adoption),
  //                 const SizedBox(height: 16),
  //                 _buildStatsAndTraits(pet, adoption),
  //                 const SizedBox(height: 16),
  //                 _buildCompactAdopterInfo(adoption),
  //                 const Spacer(),
  //               ],
  //             ),
  //           ),
  //         ),

  //         // Bottom action
  //         _buildCompactBottomAction(pet, adoption),
  //       ],
  //     ),
  //   )
  //       .animate()
  //       .slideY(begin: 1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
  // }

  // Widget _buildCompactPetHeader(
  //     FirebasePetModel pet, CollaborativeAdoptionRequest adoption) {
  //   return Row(
  //     children: [
  //       Container(
  //         width: 80,
  //         height: 80,
  //         decoration: BoxDecoration(
  //           gradient: LinearGradient(
  //             colors: [
  //               Color(adoption.requesterColorTheme).withOpacity(0.2),
  //               Color(adoption.requesterColorTheme).withOpacity(0.1),
  //             ],
  //             begin: Alignment.topLeft,
  //             end: Alignment.bottomRight,
  //           ),
  //           shape: BoxShape.circle,
  //           border: Border.all(
  //             color: Color(adoption.requesterColorTheme).withOpacity(0.3),
  //             width: 2,
  //           ),
  //         ),
  //         child: Center(
  //           child: Text(
  //             pet.photo,
  //             style: const TextStyle(fontSize: 36),
  //           ),
  //         ),
  //       ),
  //       const SizedBox(width: 16),
  //       Expanded(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Row(
  //               children: [
  //                 Expanded(
  //                   child: Text(
  //                     pet.name,
  //                     style: const TextStyle(
  //                       fontSize: 22,
  //                       fontWeight: FontWeight.w700,
  //                       color: Color(0xFF0F172A),
  //                     ),
  //                   ),
  //                 ),
  //                 Container(
  //                   padding:
  //                       const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //                   decoration: BoxDecoration(
  //                     color:
  //                         Color(adoption.requesterColorTheme).withOpacity(0.1),
  //                     borderRadius: BorderRadius.circular(8),
  //                   ),
  //                   child: Text(
  //                     pet.type,
  //                     style: TextStyle(
  //                       fontSize: 12,
  //                       fontWeight: FontWeight.w600,
  //                       color: Color(adoption.requesterColorTheme),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(height: 4),
  //             Text(
  //               '${pet.breed} • ${pet.age}',
  //               style: const TextStyle(
  //                 fontSize: 14,
  //                 color: Color(0xFF64748B),
  //               ),
  //             ),
  //             const SizedBox(height: 8),
  //             Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //               decoration: BoxDecoration(
  //                 color: _getPetMoodColor(pet).withOpacity(0.1),
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               child: Text(
  //                 _getPetMoodText(pet),
  //                 style: TextStyle(
  //                   fontSize: 11,
  //                   fontWeight: FontWeight.w600,
  //                   color: _getPetMoodColor(pet),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildStatsAndTraits(
  //     FirebasePetModel pet, CollaborativeAdoptionRequest adoption) {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: const Color(0xFFF8FAFC),
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(
  //         color: const Color(0xFFE2E8F0),
  //         width: 1,
  //       ),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Expanded(child: _buildCompactStat('❤️', 'Saúde', pet.health)),
  //             const SizedBox(width: 12),
  //             Expanded(
  //                 child: _buildCompactStat('😊', 'Felicidade', pet.happiness)),
  //           ],
  //         ),
  //         const SizedBox(height: 8),
  //         Row(
  //           children: [
  //             Expanded(child: _buildCompactStat('⚡', 'Energia', pet.energy)),
  //             const SizedBox(width: 12),
  //             Expanded(child: _buildCompactStat('✨', 'Higiene', pet.hygiene)),
  //           ],
  //         ),
  //         if (pet.traits.isNotEmpty) ...[
  //           const SizedBox(height: 12),
  //           const Text(
  //             'Características',
  //             style: TextStyle(
  //               fontSize: 14,
  //               fontWeight: FontWeight.w600,
  //               color: Color(0xFF0F172A),
  //             ),
  //           ),
  //           const SizedBox(height: 6),
  //           Wrap(
  //             spacing: 6,
  //             runSpacing: 4,
  //             children: pet.traits.take(4).map((trait) {
  //               return Container(
  //                 padding:
  //                     const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //                 decoration: BoxDecoration(
  //                   color: Color(adoption.requesterColorTheme).withOpacity(0.1),
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //                 child: Text(
  //                   trait,
  //                   style: TextStyle(
  //                     fontSize: 11,
  //                     fontWeight: FontWeight.w500,
  //                     color: Color(adoption.requesterColorTheme),
  //                   ),
  //                 ),
  //               );
  //             }).toList(),
  //           ),
  //         ],
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildCompactStat(String emoji, String label, int value) {
  //   return Row(
  //     children: [
  //       Text(emoji, style: const TextStyle(fontSize: 14)),
  //       const SizedBox(width: 6),
  //       Expanded(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               label,
  //               style: const TextStyle(
  //                 fontSize: 11,
  //                 color: Color(0xFF64748B),
  //               ),
  //             ),
  //             const SizedBox(height: 2),
  //             Stack(
  //               children: [
  //                 Container(
  //                   height: 6,
  //                   decoration: BoxDecoration(
  //                     color: _getStatColor(value).withOpacity(0.2),
  //                     borderRadius: BorderRadius.circular(3),
  //                   ),
  //                 ),
  //                 FractionallySizedBox(
  //                   widthFactor: value / 100,
  //                   child: Container(
  //                     height: 6,
  //                     decoration: BoxDecoration(
  //                       color: _getStatColor(value),
  //                       borderRadius: BorderRadius.circular(3),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(height: 2),
  //             Text(
  //               '$value%',
  //               style: TextStyle(
  //                 fontSize: 10,
  //                 fontWeight: FontWeight.w600,
  //                 color: _getStatColor(value),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildCompactAdopterInfo(CollaborativeAdoptionRequest adoption) {
  //   return Container(
  //     padding: const EdgeInsets.all(12),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: [
  //           Color(adoption.requesterColorTheme).withOpacity(0.1),
  //           Color(adoption.requesterColorTheme).withOpacity(0.05),
  //         ],
  //       ),
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(
  //         color: Color(adoption.requesterColorTheme).withOpacity(0.2),
  //         width: 1,
  //       ),
  //     ),
  //     child: Row(
  //       children: [
  //         Container(
  //           width: 36,
  //           height: 36,
  //           decoration: BoxDecoration(
  //             color: Color(adoption.requesterColorTheme).withOpacity(0.2),
  //             shape: BoxShape.circle,
  //             border: Border.all(
  //               color: Color(adoption.requesterColorTheme),
  //               width: 1,
  //             ),
  //           ),
  //           child: Center(
  //             child: Text(
  //               adoption.requesterCodename
  //                   .split(' ')
  //                   .map((word) => word[0])
  //                   .join(),
  //               style: TextStyle(
  //                 fontSize: 12,
  //                 fontWeight: FontWeight.w700,
  //                 color: Color(adoption.requesterColorTheme),
  //               ),
  //             ),
  //           ),
  //         ),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 adoption.requesterCodename,
  //                 style: const TextStyle(
  //                   fontSize: 14,
  //                   fontWeight: FontWeight.w600,
  //                   color: Color(0xFF0F172A),
  //                 ),
  //               ),
  //               Text(
  //                 'Lv.${adoption.requesterLevel} • ${adoption.region}',
  //                 style: const TextStyle(
  //                   fontSize: 11,
  //                   color: Color(0xFF64748B),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         Icon(
  //           Icons.people,
  //           color: Color(adoption.requesterColorTheme),
  //           size: 18,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildCompactBottomAction(
  //     FirebasePetModel pet, CollaborativeAdoptionRequest adoption) {
  //   return Container(
  //     padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       boxShadow: [
  //         BoxShadow(
  //           color: const Color(0xFF64748B).withOpacity(0.1),
  //           blurRadius: 12,
  //           offset: const Offset(0, -4),
  //         ),
  //       ],
  //     ),
  //     child: SafeArea(
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Container(
  //             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //             decoration: BoxDecoration(
  //               color: const Color(0xFF3B82F6).withOpacity(0.1),
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //             child: Row(
  //               children: [
  //                 const Icon(
  //                   Icons.info_outline,
  //                   color: Color(0xFF3B82F6),
  //                   size: 16,
  //                 ),
  //                 const SizedBox(width: 8),
  //                 Expanded(
  //                   child: Text(
  //                     'Ao adotar, você se tornará co-guardião junto com ${adoption.requesterCodename}',
  //                     style: const TextStyle(
  //                       fontSize: 11,
  //                       color: Color(0xFF3B82F6),
  //                       fontWeight: FontWeight.w500,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           const SizedBox(height: 12),
  //           Row(
  //             children: [
  //               Expanded(
  //                 child: TextButton(
  //                   onPressed: () => Navigator.pop(context),
  //                   style: TextButton.styleFrom(
  //                     padding: const EdgeInsets.symmetric(vertical: 12),
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(12),
  //                       side: const BorderSide(
  //                         color: Color(0xFFE2E8F0),
  //                         width: 1,
  //                       ),
  //                     ),
  //                   ),
  //                   child: const Text(
  //                     'Cancelar',
  //                     style: TextStyle(
  //                       fontSize: 14,
  //                       fontWeight: FontWeight.w600,
  //                       color: Color(0xFF64748B),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(width: 12),
  //               Expanded(
  //                 flex: 2,
  //                 child: Consumer(
  //                   builder: (context, ref, child) {
  //                     // NOVO: Verificar se pode adotar usando provider unificado
  //                     final canAdopt = ref.watch(canAdoptPetProvider);
  //                     final isInTransition = ref.watch(isInTransitionProvider);

  //                     return ElevatedButton(
  //                       onPressed: canAdopt && !isInTransition
  //                           ? () => _adoptPet(adoption, pet.id)
  //                           : null,
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: const Color(0xFF10B981),
  //                         padding: const EdgeInsets.symmetric(vertical: 12),
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(12),
  //                         ),
  //                         elevation: 0,
  //                       ),
  //                       child: isInTransition
  //                           ? const SizedBox(
  //                               width: 16,
  //                               height: 16,
  //                               child: CircularProgressIndicator(
  //                                 color: Colors.white,
  //                                 strokeWidth: 2,
  //                               ),
  //                             )
  //                           : Row(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 const Icon(
  //                                   Icons.favorite,
  //                                   color: Colors.white,
  //                                   size: 16,
  //                                 ),
  //                                 const SizedBox(width: 6),
  //                                 Text(
  //                                   'Adotar ${pet.name}',
  //                                   style: const TextStyle(
  //                                     fontSize: 14,
  //                                     fontWeight: FontWeight.w700,
  //                                     color: Colors.white,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                     );
  //                   },
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Color _getPetMoodColor(FirebasePetModel pet) {
  //   final avgMood = (pet.happiness + pet.health + pet.energy) / 3;
  //   if (avgMood >= 80) return const Color(0xFF10B981);
  //   if (avgMood >= 60) return const Color(0xFFF59E0B);
  //   return const Color(0xFFEF4444);
  // }

  // String _getPetMoodText(FirebasePetModel pet) {
  //   final avgMood = (pet.happiness + pet.health + pet.energy) / 3;
  //   if (avgMood >= 80) return 'Muito Feliz 😊';
  //   if (avgMood >= 60) return 'Feliz 😐';
  //   return 'Precisa de Cuidados 😔';
  // }

  // Color _getStatColor(int value) {
  //   if (value >= 80) return const Color(0xFF10B981);
  //   if (value >= 60) return const Color(0xFFF59E0B);
  //   return const Color(0xFFEF4444);
  // }

  // // NOVO: Método de adoção usando AdoptionFlowService
  // Future<void> _adoptPet(
  //     CollaborativeAdoptionRequest request, String petId) async {
  //   final success = await AdoptionFlowService.executeAdoptionFlow(
  //     context: context,
  //     ref: ref,
  //     requestId: request.id,
  //     petId: petId,
  //     coParentDisplayName: 'Co-guardião',
  //     coParentCodename: 'Guardião Colaborativo',
  //   );

  //   // Fechar modal se sucesso
  //   if (success && mounted) {
  //     Navigator.pop(context); // Fechar modal de detalhes
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
    // return Scaffold(
    //   backgroundColor: const Color(0xFFF8FAFC),
    //   appBar: _buildAppBar(),
    //   body: isLoading ? _buildLoadingState() : _buildContent(),
    // );
  }

  // PreferredSizeWidget _buildAppBar() {
  //   return AppBar(
  //     backgroundColor: Colors.transparent,
  //     elevation: 0,
  //     leading: IconButton(
  //       onPressed: () => Navigator.pop(context),
  //       icon: const Icon(
  //         Icons.arrow_back,
  //         color: Color(0xFF0F172A),
  //         size: 24,
  //       ),
  //     ),
  //     title: const Text(
  //       'Adoções Disponíveis',
  //       style: TextStyle(
  //         fontSize: 20,
  //         fontWeight: FontWeight.w700,
  //         color: Color(0xFF0F172A),
  //       ),
  //     ),
  //     actions: [
  //       IconButton(
  //         onPressed: () {
  //           ref.invalidate(publicAdoptionRequestsFirebaseProvider);
  //         },
  //         icon: const Icon(
  //           Icons.refresh,
  //           color: Color(0xFF64748B),
  //           size: 24,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildLoadingState() {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Container(
  //           width: 80,
  //           height: 80,
  //           decoration: BoxDecoration(
  //             color: const Color(0xFF3B82F6).withOpacity(0.1),
  //             shape: BoxShape.circle,
  //           ),
  //           child: const Icon(
  //             Icons.pets_rounded,
  //             color: Color(0xFF3B82F6),
  //             size: 40,
  //           ),
  //         )
  //             .animate(onPlay: (controller) => controller.repeat())
  //             .rotate(duration: 2000.ms)
  //             .scale(
  //               begin: const Offset(0.8, 0.8),
  //               end: const Offset(1.2, 1.2),
  //               duration: 1000.ms,
  //             ),
  //         const SizedBox(height: 24),
  //         const Text(
  //           'Carregando Adoções...',
  //           style: TextStyle(
  //             fontSize: 18,
  //             fontWeight: FontWeight.w600,
  //             color: Color(0xFF0F172A),
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //         const Padding(
  //           padding: EdgeInsets.symmetric(horizontal: 40),
  //           child: Text(
  //             'Conectando com Firebase...',
  //             style: TextStyle(
  //               fontSize: 14,
  //               color: Color(0xFF64748B),
  //             ),
  //             textAlign: TextAlign.center,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildContent() {
  //   // NOVO: Verificar se pode ver adoções usando provider unificado
  //   final unifiedState = ref.watch(unifiedUserStateProvider);

  //   if (!unifiedState.isAuthenticated) {
  //     return _buildUnauthenticatedState();
  //   }

  //   final adoptionRequestsAsync =
  //       ref.watch(publicAdoptionRequestsFirebaseProvider);

  //   return adoptionRequestsAsync.when(
  //     data: (adoptions) {
  //       final filteredAdoptions = _getFilteredAdoptions(adoptions);

  //       return Column(
  //         children: [
  //           _buildFilters(),
  //           _buildStats(adoptions, filteredAdoptions),
  //           Expanded(
  //             child: filteredAdoptions.isEmpty
  //                 ? _buildEmptyState()
  //                 : _buildAdoptionsList(filteredAdoptions),
  //           ),
  //         ],
  //       );
  //     },
  //     loading: () => _buildLoadingState(),
  //     error: (error, stackTrace) => _buildErrorState(error.toString()),
  //   );
  // }

  // Widget _buildUnauthenticatedState() {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         const Icon(
  //           Icons.login,
  //           size: 80,
  //           color: Color(0xFF64748B),
  //         ),
  //         const SizedBox(height: 16),
  //         const Text(
  //           'Login Necessário',
  //           style: TextStyle(
  //             fontSize: 18,
  //             fontWeight: FontWeight.w600,
  //             color: Color(0xFF0F172A),
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //         const Text(
  //           'Você precisa estar logado para ver as adoções disponíveis',
  //           textAlign: TextAlign.center,
  //           style: TextStyle(
  //             fontSize: 14,
  //             color: Color(0xFF64748B),
  //           ),
  //         ),
  //         const SizedBox(height: 20),
  //         ElevatedButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Voltar'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildFilters() {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  //     child: SingleChildScrollView(
  //       scrollDirection: Axis.horizontal,
  //       child: Row(
  //         children: filters.map((filter) {
  //           final isSelected = selectedFilter == filter;
  //           return GestureDetector(
  //             onTap: () {
  //               HapticFeedback.lightImpact();
  //               setState(() {
  //                 selectedFilter = filter;
  //               });
  //             },
  //             child: AnimatedContainer(
  //               duration: const Duration(milliseconds: 300),
  //               margin: const EdgeInsets.only(right: 12),
  //               padding:
  //                   const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //               decoration: BoxDecoration(
  //                 color: isSelected ? const Color(0xFF10B981) : Colors.white,
  //                 borderRadius: BorderRadius.circular(20),
  //                 border: Border.all(
  //                   color: isSelected
  //                       ? const Color(0xFF10B981)
  //                       : const Color(0xFFE2E8F0),
  //                   width: 1,
  //                 ),
  //                 boxShadow: isSelected
  //                     ? [
  //                         BoxShadow(
  //                           color: const Color(0xFF10B981).withOpacity(0.2),
  //                           blurRadius: 8,
  //                           offset: const Offset(0, 2),
  //                         ),
  //                       ]
  //                     : null,
  //               ),
  //               child: Text(
  //                 filter,
  //                 style: TextStyle(
  //                   fontSize: 14,
  //                   fontWeight: FontWeight.w600,
  //                   color: isSelected ? Colors.white : const Color(0xFF64748B),
  //                 ),
  //               ),
  //             ),
  //           );
  //         }).toList(),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildStats(List<CollaborativeAdoptionRequest> allAdoptions,
  //     List<CollaborativeAdoptionRequest> filteredAdoptions) {
  //   final totalAdoptions = allAdoptions.length;
  //   final urgentAdoptions = allAdoptions.where((a) => a.isUrgent).length;
  //   final filteredCount = filteredAdoptions.length;

  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 20),
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: [
  //           const Color(0xFF3B82F6).withOpacity(0.1),
  //           const Color(0xFF1E40AF).withOpacity(0.05),
  //         ],
  //       ),
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(
  //         color: const Color(0xFF3B82F6).withOpacity(0.2),
  //         width: 1,
  //       ),
  //     ),
  //     child: Row(
  //       children: [
  //         Expanded(
  //           child: Column(
  //             children: [
  //               Text(
  //                 '$filteredCount',
  //                 style: const TextStyle(
  //                   fontSize: 24,
  //                   fontWeight: FontWeight.w700,
  //                   color: Color(0xFF0F172A),
  //                 ),
  //               ),
  //               const Text(
  //                 'Disponíveis',
  //                 style: TextStyle(
  //                   fontSize: 12,
  //                   color: Color(0xFF64748B),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         Container(
  //           width: 1,
  //           height: 40,
  //           color: const Color(0xFFE2E8F0),
  //         ),
  //         Expanded(
  //           child: Column(
  //             children: [
  //               Text(
  //                 '$urgentAdoptions',
  //                 style: const TextStyle(
  //                   fontSize: 24,
  //                   fontWeight: FontWeight.w700,
  //                   color: Color(0xFFEF4444),
  //                 ),
  //               ),
  //               const Text(
  //                 'Urgentes',
  //                 style: TextStyle(
  //                   fontSize: 12,
  //                   color: Color(0xFF64748B),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         Container(
  //           width: 1,
  //           height: 40,
  //           color: const Color(0xFFE2E8F0),
  //         ),
  //         Expanded(
  //           child: Column(
  //             children: [
  //               Text(
  //                 '$totalAdoptions',
  //                 style: const TextStyle(
  //                   fontSize: 24,
  //                   fontWeight: FontWeight.w700,
  //                   color: Color(0xFF10B981),
  //                 ),
  //               ),
  //               const Text(
  //                 'Total',
  //                 style: TextStyle(
  //                   fontSize: 12,
  //                   color: Color(0xFF64748B),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0);
  // }

  // Widget _buildEmptyState() {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Container(
  //           width: 100,
  //           height: 100,
  //           decoration: BoxDecoration(
  //             color: const Color(0xFF64748B).withOpacity(0.1),
  //             shape: BoxShape.circle,
  //           ),
  //           child: const Icon(
  //             Icons.search_off,
  //             color: Color(0xFF64748B),
  //             size: 50,
  //           ),
  //         ),
  //         const SizedBox(height: 24),
  //         const Text(
  //           'Nenhuma adoção encontrada',
  //           style: TextStyle(
  //             fontSize: 18,
  //             fontWeight: FontWeight.w600,
  //             color: Color(0xFF0F172A),
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //         const Text(
  //           'Tente alterar os filtros ou aguarde novas adoções',
  //           style: TextStyle(
  //             fontSize: 14,
  //             color: Color(0xFF64748B),
  //           ),
  //           textAlign: TextAlign.center,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildErrorState(String error) {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         const Icon(
  //           Icons.error_outline,
  //           size: 64,
  //           color: Color(0xFFEF4444),
  //         ),
  //         const SizedBox(height: 16),
  //         const Text(
  //           'Erro ao carregar dados',
  //           style: TextStyle(
  //             fontSize: 18,
  //             fontWeight: FontWeight.w600,
  //             color: Color(0xFF0F172A),
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //         Text(
  //           error,
  //           style: const TextStyle(
  //             fontSize: 14,
  //             color: Color(0xFF64748B),
  //           ),
  //           textAlign: TextAlign.center,
  //         ),
  //         const SizedBox(height: 16),
  //         ElevatedButton(
  //           onPressed: () {
  //             ref.invalidate(publicAdoptionRequestsFirebaseProvider);
  //           },
  //           child: const Text('Tentar Novamente'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildAdoptionsList(List<CollaborativeAdoptionRequest> adoptions) {
  //   return ListView.builder(
  //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
  //     itemCount: adoptions.length,
  //     itemBuilder: (context, index) {
  //       final adoption = adoptions[index];
  //       return _buildAdoptionCard(adoption, index, ref);
  //     },
  //   );
  // }

  // Widget _buildAdoptionCard(
  //     CollaborativeAdoptionRequest adoption, int index, WidgetRef ref) {
  //   final isUrgent = adoption.isUrgent;
  //   final isHot = adoption.isHot;

  //   return GestureDetector(
  //     onTap: () => _onAdoptionTap(adoption),
  //     child: Container(
  //       margin: const EdgeInsets.only(bottom: 16),
  //       padding: const EdgeInsets.all(16),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(20),
  //         border: Border.all(
  //           color: isUrgent
  //               ? const Color(0xFFEF4444).withOpacity(0.3)
  //               : isHot
  //                   ? const Color(0xFFF59E0B).withOpacity(0.3)
  //                   : const Color(0xFFE2E8F0),
  //           width: isUrgent || isHot ? 2 : 1,
  //         ),
  //         boxShadow: [
  //           BoxShadow(
  //             color: const Color(0xFF64748B).withOpacity(0.1),
  //             blurRadius: 12,
  //             offset: const Offset(0, 4),
  //           ),
  //         ],
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           _buildCardHeader(adoption),
  //           const SizedBox(height: 12),
  //           _buildCardPetsPreview(adoption, ref),
  //           const SizedBox(height: 12),
  //           _buildCardMessage(adoption),
  //           const SizedBox(height: 12),
  //           _buildCardFooter(adoption),
  //         ],
  //       ),
  //     ),
  //   )
  //       .animate(delay: Duration(milliseconds: 100 * index))
  //       .fadeIn(duration: 600.ms)
  //       .slideX(begin: 0.3, end: 0);
  // }

  // Widget _buildCardHeader(CollaborativeAdoptionRequest adoption) {
  //   final isUrgent = adoption.isUrgent;
  //   final isHot = adoption.isHot;

  //   return Row(
  //     children: [
  //       Container(
  //         width: 50,
  //         height: 50,
  //         decoration: BoxDecoration(
  //           color: Color(adoption.requesterColorTheme).withOpacity(0.1),
  //           shape: BoxShape.circle,
  //           border: Border.all(
  //             color: Color(adoption.requesterColorTheme),
  //             width: 2,
  //           ),
  //         ),
  //         child: Center(
  //           child: Text(
  //             adoption.requesterCodename
  //                 .split(' ')
  //                 .map((word) => word[0])
  //                 .join(),
  //             style: TextStyle(
  //               fontSize: 16,
  //               fontWeight: FontWeight.w700,
  //               color: Color(adoption.requesterColorTheme),
  //             ),
  //           ),
  //         ),
  //       ),
  //       const SizedBox(width: 12),
  //       Expanded(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Row(
  //               children: [
  //                 Expanded(
  //                   child: Text(
  //                     adoption.requesterCodename,
  //                     style: const TextStyle(
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.w700,
  //                       color: Color(0xFF0F172A),
  //                     ),
  //                   ),
  //                 ),
  //                 if (adoption.isNew)
  //                   Container(
  //                     padding: const EdgeInsets.symmetric(
  //                         horizontal: 6, vertical: 2),
  //                     decoration: BoxDecoration(
  //                       color: const Color(0xFF10B981),
  //                       borderRadius: BorderRadius.circular(8),
  //                     ),
  //                     child: const Text(
  //                       'NOVO',
  //                       style: TextStyle(
  //                         fontSize: 10,
  //                         fontWeight: FontWeight.w700,
  //                         color: Colors.white,
  //                       ),
  //                     ),
  //                   ),
  //               ],
  //             ),
  //             Row(
  //               children: [
  //                 Text(
  //                   'Lv.${adoption.requesterLevel}',
  //                   style: TextStyle(
  //                     fontSize: 12,
  //                     fontWeight: FontWeight.w600,
  //                     color: Color(adoption.requesterColorTheme),
  //                   ),
  //                 ),
  //                 const SizedBox(width: 8),
  //                 Text(
  //                   adoption.region,
  //                   style: const TextStyle(
  //                     fontSize: 12,
  //                     color: Color(0xFF64748B),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //       Column(
  //         crossAxisAlignment: CrossAxisAlignment.end,
  //         children: [
  //           if (isUrgent)
  //             Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //               decoration: BoxDecoration(
  //                 color: const Color(0xFFEF4444),
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               child: const Text(
  //                 'URGENTE',
  //                 style: TextStyle(
  //                   fontSize: 10,
  //                   fontWeight: FontWeight.w700,
  //                   color: Colors.white,
  //                 ),
  //               ),
  //             )
  //           else if (isHot)
  //             Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //               decoration: BoxDecoration(
  //                 color: const Color(0xFFF59E0B),
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               child: const Text(
  //                 'HOT',
  //                 style: TextStyle(
  //                   fontSize: 10,
  //                   fontWeight: FontWeight.w700,
  //                   color: Colors.white,
  //                 ),
  //               ),
  //             ),
  //           const SizedBox(height: 4),
  //           Text(
  //             '${adoption.daysRemaining.toStringAsFixed(1)} dias',
  //             style: TextStyle(
  //               fontSize: 12,
  //               fontWeight: FontWeight.w600,
  //               color: isUrgent
  //                   ? const Color(0xFFEF4444)
  //                   : const Color(0xFF64748B),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildCardPetsPreview(
  //     CollaborativeAdoptionRequest adoption, WidgetRef ref) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Consumer(
  //         builder: (context, ref, child) {
  //           final petsAsync = ref.watch(petsFromRequestProvider(adoption.id));

  //           return petsAsync.when(
  //             data: (pets) => _buildPetsGrid(pets, adoption),
  //             loading: () => _buildPetsLoading(adoption),
  //             error: (error, _) => _buildPetsError(adoption),
  //           );
  //         },
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildPetsGrid(
  //     List<FirebasePetModel> pets, CollaborativeAdoptionRequest adoption) {
  //   if (pets.isEmpty) {
  //     return _buildPetsError(adoption);
  //   }

  //   return Container(
  //     padding: const EdgeInsets.all(12),
  //     decoration: BoxDecoration(
  //       color: Color(adoption.requesterColorTheme).withOpacity(0.05),
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(
  //         color: Color(adoption.requesterColorTheme).withOpacity(0.2),
  //         width: 1,
  //       ),
  //     ),
  //     child: Column(
  //       children: [
  //         Row(
  //           children: [
  //             Icon(
  //               Icons.pets,
  //               color: Color(adoption.requesterColorTheme),
  //               size: 16,
  //             ),
  //             const SizedBox(width: 6),
  //             Text(
  //               'Escolha um dos pets:',
  //               style: TextStyle(
  //                 fontSize: 12,
  //                 fontWeight: FontWeight.w600,
  //                 color: Color(adoption.requesterColorTheme),
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 8),
  //         Row(
  //           children: pets.asMap().entries.map((entry) {
  //             final index = entry.key;
  //             final pet = entry.value;
  //             final isLast = index == pets.length - 1;

  //             return Expanded(
  //               child: Container(
  //                 margin: EdgeInsets.only(right: isLast ? 0 : 8),
  //                 child: _buildPetPreviewCard(pet, adoption),
  //               ),
  //             );
  //           }).toList(),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildPetPreviewCard(
  //     FirebasePetModel pet, CollaborativeAdoptionRequest adoption) {
  //   return GestureDetector(
  //     onTap: () {
  //       HapticFeedback.lightImpact();
  //       _showPetDetailsModal(pet.id, adoption);
  //     },
  //     child: Container(
  //       padding: const EdgeInsets.all(8),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(10),
  //         border: Border.all(
  //           color: Color(adoption.requesterColorTheme).withOpacity(0.3),
  //           width: 1,
  //         ),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Color(adoption.requesterColorTheme).withOpacity(0.1),
  //             blurRadius: 4,
  //             offset: const Offset(0, 2),
  //           ),
  //         ],
  //       ),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Container(
  //             width: 32,
  //             height: 32,
  //             decoration: BoxDecoration(
  //               color: Color(adoption.requesterColorTheme).withOpacity(0.1),
  //               shape: BoxShape.circle,
  //             ),
  //             child: Center(
  //               child: Text(
  //                 pet.photo,
  //                 style: const TextStyle(fontSize: 16),
  //               ),
  //             ),
  //           ),
  //           const SizedBox(height: 4),
  //           Text(
  //             pet.name,
  //             style: const TextStyle(
  //               fontSize: 10,
  //               fontWeight: FontWeight.w600,
  //               color: Color(0xFF0F172A),
  //             ),
  //             maxLines: 1,
  //             overflow: TextOverflow.ellipsis,
  //             textAlign: TextAlign.center,
  //           ),
  //           Text(
  //             pet.type,
  //             style: const TextStyle(
  //               fontSize: 8,
  //               color: Color(0xFF64748B),
  //             ),
  //             maxLines: 1,
  //             overflow: TextOverflow.ellipsis,
  //             textAlign: TextAlign.center,
  //           ),
  //           const SizedBox(height: 2),
  //           Container(
  //             width: double.infinity,
  //             height: 2,
  //             decoration: BoxDecoration(
  //               color: _getHealthColor(pet.health).withOpacity(0.3),
  //               borderRadius: BorderRadius.circular(1),
  //             ),
  //             child: FractionallySizedBox(
  //               alignment: Alignment.centerLeft,
  //               widthFactor: pet.health / 100,
  //               child: Container(
  //                 decoration: BoxDecoration(
  //                   color: _getHealthColor(pet.health),
  //                   borderRadius: BorderRadius.circular(1),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Color _getHealthColor(int health) {
  //   if (health >= 80) return const Color(0xFF10B981);
  //   if (health >= 50) return const Color(0xFFF59E0B);
  //   return const Color(0xFFEF4444);
  // }

  // Widget _buildPetsLoading(CollaborativeAdoptionRequest adoption) {
  //   return Container(
  //     padding: const EdgeInsets.all(12),
  //     decoration: BoxDecoration(
  //       color: Color(adoption.requesterColorTheme).withOpacity(0.05),
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(
  //         color: Color(adoption.requesterColorTheme).withOpacity(0.2),
  //         width: 1,
  //       ),
  //     ),
  //     child: Row(
  //       children: [
  //         SizedBox(
  //           width: 16,
  //           height: 16,
  //           child: CircularProgressIndicator(
  //             strokeWidth: 2,
  //             color: Color(adoption.requesterColorTheme),
  //           ),
  //         ),
  //         const SizedBox(width: 8),
  //         Text(
  //           'Carregando pets...',
  //           style: TextStyle(
  //             fontSize: 12,
  //             color: Color(adoption.requesterColorTheme),
  //             fontStyle: FontStyle.italic,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildPetsError(CollaborativeAdoptionRequest adoption) {
  //   return Container(
  //     padding: const EdgeInsets.all(12),
  //     decoration: BoxDecoration(
  //       color: const Color(0xFFEF4444).withOpacity(0.05),
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(
  //         color: const Color(0xFFEF4444).withOpacity(0.2),
  //         width: 1,
  //       ),
  //     ),
  //     child: const Row(
  //       children: [
  //         Icon(
  //           Icons.error_outline,
  //           color: Color(0xFFEF4444),
  //           size: 16,
  //         ),
  //         SizedBox(width: 8),
  //         Expanded(
  //           child: Text(
  //             'Erro ao carregar pets desta adoção',
  //             style: TextStyle(
  //               fontSize: 12,
  //               color: Color(0xFFEF4444),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildCardMessage(CollaborativeAdoptionRequest adoption) {
  //   return Container(
  //     padding: const EdgeInsets.all(12),
  //     decoration: BoxDecoration(
  //       color: const Color(0xFFF8FAFC),
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(
  //         color: const Color(0xFFE2E8F0),
  //         width: 1,
  //       ),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           'Mensagem Codificada:',
  //           style: TextStyle(
  //             fontSize: 12,
  //             fontWeight: FontWeight.w600,
  //             color: Color(0xFF64748B),
  //           ),
  //         ),
  //         const SizedBox(height: 4),
  //         Text(
  //           adoption.codedMessage,
  //           style: const TextStyle(
  //             fontSize: 13,
  //             color: Color(0xFF0F172A),
  //             fontStyle: FontStyle.italic,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildCardFooter(CollaborativeAdoptionRequest adoption) {
  //   return Row(
  //     children: [
  //       if (adoption.personalityTags.isNotEmpty)
  //         Expanded(
  //           child: Wrap(
  //             spacing: 4,
  //             children: adoption.personalityTags.take(2).map((tag) {
  //               return Container(
  //                 padding:
  //                     const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  //                 decoration: BoxDecoration(
  //                   color: Color(adoption.requesterColorTheme).withOpacity(0.1),
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //                 child: Text(
  //                   tag,
  //                   style: TextStyle(
  //                     fontSize: 9,
  //                     fontWeight: FontWeight.w500,
  //                     color: Color(adoption.requesterColorTheme),
  //                   ),
  //                 ),
  //               );
  //             }).toList(),
  //           ),
  //         ),
  //       const SizedBox(width: 12),
  //       Row(
  //         children: [
  //           const Icon(
  //             Icons.visibility,
  //             size: 14,
  //             color: Color(0xFF64748B),
  //           ),
  //           const SizedBox(width: 4),
  //           Text(
  //             '${adoption.views}',
  //             style: const TextStyle(
  //               fontSize: 12,
  //               color: Color(0xFF64748B),
  //             ),
  //           ),
  //           const SizedBox(width: 12),
  //           const Icon(
  //             Icons.favorite_border,
  //             size: 14,
  //             color: Color(0xFF64748B),
  //           ),
  //           const SizedBox(width: 4),
  //           Text(
  //             '${adoption.interested}',
  //             style: const TextStyle(
  //               fontSize: 12,
  //               color: Color(0xFF64748B),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }
}
