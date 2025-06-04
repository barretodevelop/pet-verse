import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:petverse/src/features/pets/data/models/pet_model.dart';

// Widget para exibir um pet que o usuário já adotou na HomeScreen
class AdoptedPetCard extends StatelessWidget {
  final Pet pet;

  const AdoptedPetCard({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: CachedNetworkImage(
            imageUrl: pet.imageUrl,
            width: 70,
            height: 70,
            fit: BoxFit.cover,
            placeholder: (context, url) => const SizedBox(
                width: 70,
                height: 70,
                child:
                    Center(child: CircularProgressIndicator(strokeWidth: 2.0))),
            errorWidget: (context, url, error) => const SizedBox(
                width: 70, height: 70, child: Icon(Icons.pets, size: 40)),
          ),
        ),
        title: Text(pet.name, style: Theme.of(context).textTheme.titleLarge),
        subtitle: Text('${pet.species} - ${pet.breed}\nIdade: ${pet.age} anos'),
        isThreeLine: true,
        // TODO: Adicionar um onTap para ver mais detalhes do pet ou interagir com ele
      ),
    );
  }
}
