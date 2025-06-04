import 'package:flutter/material.dart';
import 'package:petverse/src/features/adoption/data/models/adoption_request_model.dart';
import 'package:petverse/src/features/pets/data/models/pet_model.dart';

// A card to display a public adoption request in the list
class PublicAdoptionRequestCard extends StatelessWidget {
  final AdoptionRequest request;
  final List<Pet> petOptions; // The 3 pets associated with this request
  final Function(Pet pet, String requestId)
      onPetTap; // Callback when a pet is tapped

  const PublicAdoptionRequestCard({
    super.key,
    required this.request,
    required this.petOptions,
    required this.onPetTap,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure we have exactly 3 pets to display, or handle fewer
    final displayPets = petOptions.take(3).toList();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Optional: Display some request info
            // Text('Solicitação de Adoção Pública', style: Theme.of(context).textTheme.titleMedium),
            // Text('Iniciada em: ${request.createdAt.toDate().toLocal().toString().split(' ')[0]}'), // Basic date format
            // const SizedBox(height: 8),
            Text(
              'Escolha um pet para adotar:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            // Display the 3 pet options
            if (displayPets.isEmpty)
              const Text('Nenhum pet disponível para esta solicitação.'),
            if (displayPets.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: displayPets.map((pet) {
                  // Use a smaller, tappable representation of the pet
                  return Expanded(
                    // Use Expanded to distribute space
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: InkWell(
                        onTap: () => onPetTap(
                            pet, request.id), // Call the onTap callback
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                // Use Image.network for simplicity here, or CachedNetworkImage
                                pet.imageUrl,
                                width: 80, // Adjust size as needed
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const SizedBox(
                                        width: 80,
                                        height: 80,
                                        child: Icon(Icons.pets)),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(pet.name,
                                style: Theme.of(context).textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
