// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:petverse/feature/pet/presentation/pet_screen.dart';
// import 'package:petverse/feature/room/presentation/rooms_page.dart';

// //  class HomePage extends ConsumerStatefulWidget {
// //   final int selectedIndex;

// //   const HomePage({super.key, this.selectedIndex = 0});

// //   @override
// //   ConsumerState<HomePage> createState() => _HomePageState();
// // }

// // class _HomePageState extends ConsumerState<HomePage> {
// //   late int _selectedIndex;

// //   final List<Widget> _pages = [
// //     const PetPage(),
// //     const RoomsPage(),
// //     const ProfilePage(),
// //   ];

// //   @override
// //   void initState() {
// //     super.initState();
// //     _selectedIndex = widget.selectedIndex;
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: IndexedStack(
// //         index: _selectedIndex,
// //         children: _pages,
// //       ),
// //       bottomNavigationBar: NavigationBar(
// //         selectedIndex: _selectedIndex,
// //         onDestinationSelected: (index) {
// //           setState(() => _selectedIndex = index);
// //         },
// //         destinations: const [
// //           NavigationDestination(
// //             icon: Icon(Icons.pets_outlined),
// //             selectedIcon: Icon(Icons.pets),
// //             label: 'Meu Pet',
// //           ),
// //           NavigationDestination(
// //             icon: Icon(Icons.people_outline),
// //             selectedIcon: Icon(Icons.people),
// //             label: 'Salas',
// //           ),
// //           NavigationDestination(
// //             icon: Icon(Icons.person_outline),
// //             selectedIcon: Icon(Icons.person),
// //             label: 'Perfil',
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// class HomePage extends ConsumerStatefulWidget {
//   final int selectedIndex;

//   const HomePage({super.key, this.selectedIndex = 0});

//   @override
//   ConsumerState<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends ConsumerState<HomePage> {
//   late int _selectedIndex;

//   final List<Widget> _pages = [
//     const PetPage(),
//     const RoomsPage(),
//     Container(),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _selectedIndex = widget.selectedIndex;
//   }

//   void _showGameMenu() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => const GameMenuSheet(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // final userCoins = ref.watch(userCoinsProvider);
//     final theme = Theme.of(context);

//     return Scaffold(
//       body: IndexedStack(
//         index: _selectedIndex,
//         children: _pages,
//       ),
//       // App Bar flutuante com moedas
//       extendBody: true,
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showGameMenu,
//         backgroundColor: theme.colorScheme.primary,
//         child: const Icon(Icons.videogame_asset),
//       ),
//       // .animate(
//       //   onPlay: (controller) => controller.repeat(),
//       // )
//       // .scale(
//       //   begin: const Offset(1.0, 0),
//       //   end: const Offset(1.1, 0),
//       //   duration: 1.seconds,
//       //   curve: Curves.easeInOut,
//       // )
//       // .then()
//       // .scale(
//       //   begin: const Offset(1.1, 0),
//       //   end: const Offset(1.0, 0),
//       //   duration: 1.seconds,
//       //   curve: Curves.easeInOut,
//       // ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       bottomNavigationBar: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         child: BottomAppBar(
//           shape: const CircularNotchedRectangle(),
//           notchMargin: 8,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               // Pet
//               IconButton(
//                 icon: Icon(
//                   _selectedIndex == 0 ? Icons.pets : Icons.pets_outlined,
//                   color: _selectedIndex == 0
//                       ? theme.colorScheme.primary
//                       : Colors.grey,
//                 ),
//                 onPressed: () => setState(() => _selectedIndex = 0),
//               ),
//               // Salas
//               IconButton(
//                 icon: Icon(
//                   _selectedIndex == 1 ? Icons.people : Icons.people_outline,
//                   color: _selectedIndex == 1
//                       ? theme.colorScheme.primary
//                       : Colors.grey,
//                 ),
//                 onPressed: () => setState(() => _selectedIndex = 1),
//               ),
//               const SizedBox(width: 48), // Espaço para o FAB
//               // Shop
//               IconButton(
//                 icon: const Icon(Icons.shopping_bag_outlined),
//                 onPressed: () => context.push('/shop'),
//               ),
//               // Perfil
//               IconButton(
//                 icon: Icon(
//                   _selectedIndex == 2 ? Icons.person : Icons.person_outline,
//                   color: _selectedIndex == 2
//                       ? theme.colorScheme.primary
//                       : Colors.grey,
//                 ),
//                 onPressed: () => setState(() => _selectedIndex = 2),
//               ),
//             ],
//           ),
//         ),
//       ),
//       // Header com moedas
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         actions: [
//           // Botão de missões
//           IconButton(
//             icon: const Icon(Icons.flag),
//             onPressed: () => context.push('/missions'),
//           ),
//           // Display de moedas
//           Container(
//             margin: const EdgeInsets.only(right: 16),
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             decoration: BoxDecoration(
//               color: Colors.amber.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: Colors.amber, width: 2),
//             ),
//             child: const Row(
//               children: [
//                 Icon(Icons.monetization_on, color: Colors.amber),
//                 SizedBox(width: 8),
//                 // userCoins.when(
//                 //   data: (coins) => Text(
//                 //     '$coins',
//                 //     style: const TextStyle(
//                 //       fontSize: 16,
//                 //       fontWeight: FontWeight.bold,
//                 //       color: Colors.amber,
//                 //     ),
//                 //   ),
//                 //   loading: () => const SizedBox(
//                 //     width: 20,
//                 //     height: 20,
//                 //     child: CircularProgressIndicator(strokeWidth: 2),
//                 //   ),
//                 //   error: (_, __) => const Text('0'),
//                 // ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Menu de jogos
// class GameMenuSheet extends StatelessWidget {
//   const GameMenuSheet({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 50,
//             height: 5,
//             decoration: BoxDecoration(
//               color: Colors.grey[300],
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//           const SizedBox(height: 20),
//           const Text(
//             'Mini Games',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 20),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               _GameOption(
//                 icon: '🍎',
//                 title: 'Pegar Comida',
//                 onTap: () {
//                   Navigator.pop(context);
//                   context.push('/games/catch-food');
//                 },
//               ),
//               _GameOption(
//                 icon: '🏃',
//                 title: 'Pet Jump',
//                 onTap: () {
//                   Navigator.pop(context);
//                   context.push('/games/pet-jump');
//                 },
//               ),
//               const _GameOption(
//                 icon: '🧩',
//                 title: 'Em breve',
//                 onTap: null,
//                 isLocked: true,
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//         ],
//       ),
//     ).animate().slideY(begin: 1, end: 0, duration: 300.ms).fadeIn();
//   }
// }

// class _GameOption extends StatelessWidget {
//   final String icon;
//   final String title;
//   final VoidCallback? onTap;
//   final bool isLocked;

//   const _GameOption({
//     required this.icon,
//     required this.title,
//     this.onTap,
//     this.isLocked = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: isLocked ? null : onTap,
//       borderRadius: BorderRadius.circular(16),
//       child: Container(
//         width: 100,
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: isLocked
//               ? Colors.grey[200]
//               : Theme.of(context).colorScheme.primaryContainer,
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Column(
//           children: [
//             Text(
//               icon,
//               style: TextStyle(
//                 fontSize: 40,
//                 color: isLocked ? Colors.grey : null,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               title,
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: isLocked ? Colors.grey : null,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             if (isLocked) ...[
//               const SizedBox(height: 4),
//               const Icon(
//                 Icons.lock,
//                 size: 16,
//                 color: Colors.grey,
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }



  // Widget _buildGameContent(UserModel? user) {
  //   if (user == null) return _buildErrorState();

  //   return Column(
  //     children: [
  //       // Compact Game Header
  //       _buildCompactGameHeader(user),

  //       // Main Content Area
  //       Expanded(
  //         child: Padding(
  //           padding: EdgeInsets.symmetric(horizontal: 20.w),
  //           child: user.hasPet
  //               ? _buildPetSection(user.currentPetId!)
  //               : _buildAdoptionSection(),
  //         ),
  //       ),
  //     ],
  //   );
  // }
