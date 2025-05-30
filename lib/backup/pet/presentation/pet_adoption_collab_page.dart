// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:petverse/feature/pet/provider/pet_provider.dart';
// import 'package:petverse/feature/room/provider/room_provider.dart';

// class PetAdoptionPage extends ConsumerStatefulWidget {
//   final String roomId; // O ID da sala de onde o pet será adotado

//   const PetAdoptionPage({super.key, required this.roomId});

//   @override
//   ConsumerState<PetAdoptionPage> createState() => _PetAdoptionPageState();
// }

// class _PetAdoptionPageState extends ConsumerState<PetAdoptionPage> {
//   final _petNameController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   @override
//   void dispose() {
//     _petNameController.dispose();
//     super.dispose();
//   }

//   Future<void> _adoptPet() async {
//     if (!_formKey.currentState!.validate()) return;

//     final petController = ref.read(petControllerProvider.notifier);
//     final room = ref.read(roomControllerProvider).value; // Pega a sala atual

//     if (room == null || room.id != widget.roomId || room.parentIds.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//           content: Text('Erro: Não foi possível obter os dados da sala.')));
//       return;
//     }

//     // try {
//     //   await petController.adoptPet(
//     //     name: _petNameController.text.trim(),
//     //     roomId: widget.roomId,
//     //     parentIds: room.parentIds, // Usa os parentIds da sala
//     //   );
//     //   if (mounted) {
//     //     context.go('/home'); // Volta para a Home após adoção
//     //   }
//     // } catch (e) {
//     //   ScaffoldMessenger.of(context).showSnackBar(
//     //       SnackBar(content: Text('Falha ao adotar pet: ${e.toString()}')));
//     // }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final petState = ref.watch(petControllerProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Adotar um Novo Pet'),
//         centerTitle: true,
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.pets,
//                     size: 100, color: Theme.of(context).colorScheme.primary),
//                 const SizedBox(height: 24),
//                 Text(
//                   'Dê um nome ao seu novo amigo!',
//                   style: Theme.of(context).textTheme.headlineSmall,
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _petNameController,
//                   decoration: InputDecoration(
//                     labelText: 'Nome do Pet',
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Por favor, digite um nome para o seu pet';
//                     }
//                     if (value.length < 2) {
//                       return 'O nome deve ter pelo menos 2 caracteres';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 24),
//                 ElevatedButton.icon(
//                   onPressed: petState.isLoading ? null : _adoptPet,
//                   icon: petState.isLoading
//                       ? const CircularProgressIndicator(
//                           strokeWidth: 2, color: Colors.white)
//                       : const Icon(Icons.check),
//                   label: Text(
//                       petState.isLoading ? 'Adotando...' : 'Confirmar Adoção'),
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 40, vertical: 16),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
