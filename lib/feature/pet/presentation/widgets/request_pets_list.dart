import 'package:flutter/material.dart';
import 'package:petverse/core/model/firebase_pet_model.dart';

class RequestPetsList extends StatelessWidget {
  final List<FirebasePetModel> pets;
  final CollaborativeAdoptionRequest request;

  const RequestPetsList({super.key, required this.pets, required this.request});

  @override
  Widget build(BuildContext context) {
    if (pets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Text(
          'Nenhum pet selecionado para esta solicitação.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Seus Pets Selecionados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          ...pets.asMap().entries.map((entry) {
            final index = entry.key;
            final pet = entry.value;

            return _RequestPetListItem(
              pet: pet,
              requesterColorTheme: request.requesterColorTheme,
              isLast: index == pets.length - 1,
            );
          }),
        ],
      ),
    );
  }
}

class _RequestPetListItem extends StatelessWidget {
  final FirebasePetModel pet;
  final int requesterColorTheme;
  final bool isLast;

  const _RequestPetListItem({
    required this.pet,
    required this.requesterColorTheme,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: isLast ? 20 : 12,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(requesterColorTheme).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(requesterColorTheme).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Text(
            pet.photo,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  '${pet.breed} • ${pet.age}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'ATIVO',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
