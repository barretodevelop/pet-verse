// // lib/features/pet/pages/pet_adoption_page.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:petverse/feature/pet/provider/pet_provider.dart';
// import 'package:petverse/feature/pet/widgets/pet_preview_card.dart';

// class PetAdoptionPage extends ConsumerStatefulWidget {
//   final String roomId;

//   const PetAdoptionPage({super.key, required this.roomId});

//   @override
//   ConsumerState<PetAdoptionPage> createState() => _PetAdoptionPageState();
// }

// class _PetAdoptionPageState extends ConsumerState<PetAdoptionPage> {
//   final PageController _pageController = PageController();
//   final TextEditingController _nameController = TextEditingController();

//   int _selectedPetIndex = 0;
//   bool _showNameInput = false;
//   bool _isCreatingPet = false;

//   // Lista de pets disponíveis (futuramente virá do backend)
//   final List<Map<String, dynamic>> _availablePets = [
//     {
//       'id': 'cat_1',
//       'type': 'cat',
//       'name': 'Gato',
//       'color': Colors.orange,
//       'personality': 'Brincalhão e carinhoso',
//       'icon': '🐱',
//     },
//     {
//       'id': 'dog_1',
//       'type': 'dog',
//       'name': 'Cachorro',
//       'color': Colors.brown,
//       'personality': 'Leal e energético',
//       'icon': '🐶',
//     },
//     {
//       'id': 'rabbit_1',
//       'type': 'rabbit',
//       'name': 'Coelho',
//       'color': Colors.grey,
//       'personality': 'Fofo e tranquilo',
//       'icon': '🐰',
//     },
//     {
//       'id': 'hamster_1',
//       'type': 'hamster',
//       'name': 'Hamster',
//       'color': Colors.amber,
//       'personality': 'Pequeno e esperto',
//       'icon': '🐹',
//     },
//   ];

//   @override
//   void dispose() {
//     _pageController.dispose();
//     _nameController.dispose();
//     super.dispose();
//   }

//   Future<void> _adoptPet() async {
//     if (_nameController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Dê um nome ao seu pet!')),
//       );
//       return;
//     }

//     setState(() => _isCreatingPet = true);

//     try {
//       final selectedPet = _availablePets[_selectedPetIndex];
//       await ref.read(petControllerProvider.notifier).adoptPet(
//         roomId: widget.roomId,
//         petName: _nameController.text.trim(),
//         parentIds: [],
//       );

//       if (mounted) {
//         // Navegar para a tela do pet com animação
//         context.go('/');
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Erro ao adotar pet: $e')),
//         );
//       }
//     } finally {
//       setState(() => _isCreatingPet = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               theme.colorScheme.primaryContainer.withOpacity(0.3),
//               theme.colorScheme.surface,
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Header
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Row(
//                   children: [
//                     IconButton(
//                       onPressed: () => context.pop(),
//                       icon: const Icon(Icons.arrow_back),
//                     ),
//                     Expanded(
//                       child: Text(
//                         'Escolha seu Pet',
//                         style: theme.textTheme.headlineSmall?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                     const SizedBox(width: 48), // Balancear com o IconButton
//                   ],
//                 ),
//               ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, end: 0),

//               // Pet Carousel
//               Expanded(
//                 child: Stack(
//                   children: [
//                     PageView.builder(
//                       controller: _pageController,
//                       onPageChanged: (index) {
//                         setState(() {
//                           _selectedPetIndex = index;
//                           _showNameInput = false;
//                         });
//                       },
//                       itemCount: _availablePets.length,
//                       itemBuilder: (context, index) {
//                         final pet = _availablePets[index];
//                         return PetPreviewCard(
//                           pet: pet,
//                           isSelected: index == _selectedPetIndex,
//                         );
//                       },
//                     ),

//                     // Indicadores de página
//                     Positioned(
//                       bottom: 20,
//                       left: 0,
//                       right: 0,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: List.generate(
//                           _availablePets.length,
//                           (index) => Container(
//                             margin: const EdgeInsets.symmetric(horizontal: 4),
//                             width: index == _selectedPetIndex ? 24 : 8,
//                             height: 8,
//                             decoration: BoxDecoration(
//                               color: index == _selectedPetIndex
//                                   ? theme.colorScheme.primary
//                                   : theme.colorScheme.primary.withOpacity(0.3),
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                           )
//                               .animate(
//                                   target: index == _selectedPetIndex ? 1 : 0)
//                               .scaleX(begin: 1, end: 3, duration: 300.ms),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // Bottom Actions
//               Container(
//                 padding: const EdgeInsets.all(24),
//                 decoration: BoxDecoration(
//                   color: theme.colorScheme.surface,
//                   borderRadius: const BorderRadius.vertical(
//                     top: Radius.circular(32),
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 10,
//                       offset: const Offset(0, -5),
//                     ),
//                   ],
//                 ),
//                 child: AnimatedCrossFade(
//                   duration: const Duration(milliseconds: 300),
//                   crossFadeState: _showNameInput
//                       ? CrossFadeState.showSecond
//                       : CrossFadeState.showFirst,
//                   firstChild: _buildSelectionView(theme),
//                   secondChild: _buildNameInputView(theme),
//                 ),
//               ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSelectionView(ThemeData theme) {
//     final selectedPet = _availablePets[_selectedPetIndex];

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           selectedPet['name'],
//           style: theme.textTheme.headlineMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           selectedPet['personality'],
//           style: theme.textTheme.bodyLarge?.copyWith(
//             color: Colors.grey[600],
//           ),
//         ),
//         const SizedBox(height: 24),
//         SizedBox(
//           width: double.infinity,
//           height: 56,
//           child: ElevatedButton(
//             onPressed: () {
//               setState(() => _showNameInput = true);
//             },
//             style: ElevatedButton.styleFrom(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(28),
//               ),
//             ),
//             child: const Text(
//               'Escolher este Pet',
//               style: TextStyle(fontSize: 18),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildNameInputView(ThemeData theme) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           'Dê um nome ao seu pet!',
//           style: theme.textTheme.titleLarge?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 16),
//         TextField(
//           controller: _nameController,
//           textAlign: TextAlign.center,
//           style: const TextStyle(fontSize: 20),
//           decoration: InputDecoration(
//             hintText: 'Digite o nome...',
//             filled: true,
//             fillColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: BorderSide.none,
//             ),
//           ),
//           onSubmitted: (_) => _adoptPet(),
//         ),
//         const SizedBox(height: 24),
//         Row(
//           children: [
//             Expanded(
//               child: OutlinedButton(
//                 onPressed: _isCreatingPet
//                     ? null
//                     : () => setState(() => _showNameInput = false),
//                 style: OutlinedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(28),
//                   ),
//                 ),
//                 child: const Text('Voltar'),
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               flex: 2,
//               child: ElevatedButton(
//                 onPressed: _isCreatingPet ? null : _adoptPet,
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(28),
//                   ),
//                 ),
//                 child: _isCreatingPet
//                     ? const SizedBox(
//                         height: 24,
//                         width: 24,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                     : const Text(
//                         'Adotar!',
//                         style: TextStyle(fontSize: 18),
//                       ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

// // lib/features/pet/widgets/pet_preview_card.dart
