import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:petverse/src/features/pets/data/models/pet_model.dart';

class PetDetailsScreen extends StatelessWidget {
  final Pet pet;

  const PetDetailsScreen({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: 'feed-pet-image-${pet.id}', // Tag única para animação Hero
              child: CachedNetworkImage(
                imageUrl: pet.imageUrl,
                height: 300, // Imagem maior
                fit: BoxFit.cover,
                placeholder: (context, url) => const SizedBox(
                    height: 300,
                    child: Center(child: CircularProgressIndicator())),
                errorWidget: (context, url, error) => const SizedBox(
                    height: 300,
                    child: Center(child: Icon(Icons.pets, size: 100))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pet.name, style: textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  _buildDetailRow(context, Icons.pets, 'Espécie:', pet.species),
                  _buildDetailRow(context, Icons.category, 'Raça:', pet.breed),
                  _buildDetailRow(
                      context, Icons.cake, 'Idade:', '${pet.age} anos'),
                  _buildDetailRow(context, Icons.wc, 'Gênero:', pet.gender),
                  const SizedBox(height: 16),
                  Text('Descrição:', style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(pet.description, style: textTheme.bodyLarge),
                  const SizedBox(height: 24),
                  // TODO: Adicionar botão de "Tenho Interesse" ou similar, se aplicável
                  // ElevatedButton(
                  //   onPressed: () {
                  //     // Lógica para demonstrar interesse
                  //   },
                  //   child: const Text('Tenho Interesse em Adotar'),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text('$label ', style: Theme.of(context).textTheme.titleSmall),
        Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
      ]),
    );
  }
}
