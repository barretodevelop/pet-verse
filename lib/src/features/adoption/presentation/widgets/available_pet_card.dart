import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:petverse/src/features/pets/data/models/pet_model.dart';

// Widget para exibir um pet disponível para seleção na tela de "Adotar Novo Pet"
class AvailablePetCard extends StatelessWidget {
  final Pet pet;
  final bool isSelected; // Indica se este pet está selecionado
  final VoidCallback onTap; // Callback quando o card é clicado

  const AvailablePetCard({
    super.key,
    required this.pet,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // Adiciona uma borda ou muda a cor se selecionado
      color: isSelected
          ? Theme.of(context).primaryColorLight.withOpacity(0.3)
          : null,
      child: ListTile(
        onTap: onTap, // Usa o callback onTap
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: CachedNetworkImage(
            imageUrl: pet.imageUrl,
            width: 60, // Um pouco maior que no PetOptionCard
            height: 60,
            fit: BoxFit.cover,
            placeholder: (context, url) => const SizedBox(
                width: 60,
                height: 60,
                child:
                    Center(child: CircularProgressIndicator(strokeWidth: 2.0))),
            errorWidget: (context, url, error) => const SizedBox(
                width: 60,
                height: 60,
                child: Icon(Icons.error_outline, size: 35)),
          ),
        ),
        title:
            Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${pet.species} - ${pet.breed}'),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Colors.green)
            : null, // Mostra checkmark se selecionado
      ),
    );
  }
}
