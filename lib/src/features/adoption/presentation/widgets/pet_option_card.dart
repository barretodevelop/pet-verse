import 'package:cached_network_image/cached_network_image.dart'; // Importa CachedNetworkImage
import 'package:flutter/material.dart';
import 'package:petverse/src/features/pets/data/models/pet_model.dart'; // Importa o modelo Pet

// Widget para exibir cada opção de pet em uma solicitação de adoção pendente
class PetOptionCard extends StatelessWidget {
  final Pet pet;
  final bool isSelected; // Indica se este pet está selecionado
  final ValueChanged<String>
      onSelect; // Callback quando o botão "Escolher" é clicado

  const PetOptionCard({
    super.key,
    required this.pet,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    // Adiciona uma borda ou muda a cor se selecionado
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: isSelected
          ? Theme.of(context).primaryColorLight.withOpacity(0.3)
          : null,
      child: ListTile(
        onTap: () {
          // Adiciona onTap para mostrar detalhes do pet
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: Text(pet.name),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      CachedNetworkImage(
                        // Exibe a imagem maior no diálogo
                        imageUrl: pet.imageUrl,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.pets, size: 50),
                        fit: BoxFit.contain,
                        height: 150, // Ajuste a altura conforme necessário
                      ),
                      const SizedBox(height: 10),
                      Text('Espécie: ${pet.species}'),
                      Text('Raça: ${pet.breed}'),
                      Text(
                          'Idade: ${pet.age} anos'), // Assumindo que 'age' é em anos
                      Text('Gênero: ${pet.gender}'),
                      const SizedBox(height: 10),
                      Text('Descrição: ${pet.description}'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Fechar'),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
        leading: ClipRRect(
          // Usar ClipRRect para bordas arredondadas se desejar
          borderRadius:
              BorderRadius.circular(8.0), // Ajuste o raio conforme necessário
          child: CachedNetworkImage(
            imageUrl: pet.imageUrl, // Usa a URL da imagem do pet
            width: 50, // Largura da miniatura
            height: 50, // Altura da miniatura
            fit: BoxFit.cover, // Garante que a imagem cubra a área
            placeholder: (context, url) => const SizedBox(
                width: 50,
                height: 50,
                child: Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2.0))), // Placeholder enquanto carrega
            errorWidget: (context, url, error) => const SizedBox(
                width: 50,
                height: 50,
                child: Icon(Icons.error_outline,
                    size: 30)), // Ícone em caso de erro
          ),
        ),
        title:
            Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${pet.species} - ${pet.breed}'),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Colors.green)
            : ElevatedButton(
                onPressed: () => onSelect(
                    pet.id), // Chama o callback onSelect com o ID do pet
                child: const Text('Escolher'),
              ),
      ),
    );
  }
}
