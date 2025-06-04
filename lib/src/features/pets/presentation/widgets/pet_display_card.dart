import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:petverse/src/features/pets/data/models/pet_model.dart';

// Widget para exibir um pet de forma genérica (ex: no Feed)
class PetDisplayCard extends StatelessWidget {
  final Pet pet;
  final VoidCallback? onTap;

  const PetDisplayCard({
    super.key,
    required this.pet,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      clipBehavior:
          Clip.antiAlias, // Para que a imagem respeite as bordas do card
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CachedNetworkImage(
              imageUrl: pet.imageUrl,
              height: 180, // Altura da imagem
              fit: BoxFit.cover,
              placeholder: (context, url) => const SizedBox(
                  height: 180,
                  child: Center(child: CircularProgressIndicator())),
              errorWidget: (context, url, error) => const SizedBox(
                  height: 180,
                  child: Center(child: Icon(Icons.pets, size: 50))),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pet.name,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text('${pet.species} - ${pet.breed}',
                      style: Theme.of(context).textTheme.bodyMedium),
                  // Você pode adicionar mais informações aqui, como idade, gênero, etc.
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
