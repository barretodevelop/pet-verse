
// // lib/features/pet_care/screens/pet_care_screen.dart (ALTERADO)
// class PetCareScreen extends ConsumerWidget {
//   const PetCareScreen({super.key});

//   Widget _buildStatBar(BuildContext context, int value, String label, Color color, IconData icon) { /* ... */ return Container(); }
//   Widget _buildXpBar(BuildContext context, int level, int xp, int xpForNext) { /* ... */ return Container(); }
//   void _showItemSelectionDialog(BuildContext context, WidgetRef ref, ItemCategory category, String title, Function(ShopItem) onItemSelected) { /* ... */ }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     ref.listen<ActivePet?>(activePetProvider, (previous, next) { /* ... Level Up Dialog ... */ });

//     final activePet = ref.watch(activePetProvider);
//     final firebaseUser = ref.watch(authStateChangesProvider).asData?.value; // Pega o usuário do Firebase

//     if (activePet == null || firebaseUser == null) { // Precisa de ambos para a tela principal
//       // A SplashScreen e o redirect do router devem lidar com isso, mas como fallback:
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     final userProfile = ref.watch(userProvider); // Nosso modelo de perfil de jogo
//     final pet = activePet.definition;
//     final stats = activePet.stats;
//     // ... resto da lógica de busca de itens ...

//     String petVisualEmoji = pet.emoji; /* ... lógica de emoji de humor ... */
//     final theme = Theme.of(context);
//     final petDisplayCircleBg = theme.brightness == Brightness.dark ? AppColors.petDisplayCircleBgDark : AppColors.petDisplayCircleBgLight;

//     return Scaffold(
//       appBar: StyledAppBar(
//         title: 'Cuidando de ${pet.name} $petVisualEmoji', 
//         actions: [
//           GestureDetector( // NOVO: Avatar clicável
//             onTap: () => context.go('/profile'),
//             child: Padding(
//               padding: const EdgeInsets.only(right: 10.0),
//               child: CircleAvatar(
//                 radius: 18,
//                 backgroundImage: firebaseUser.photoURL != null ? NetworkImage(firebaseUser.photoURL!) : null,
//                 child: firebaseUser.photoURL == null ? const Icon(Icons.person, size: 18) : null,
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: Container( /* ...código do corpo da tela sem alterações significativas na estrutura, apenas o avatar na AppBar... */ ),
//     );
//   }
// }