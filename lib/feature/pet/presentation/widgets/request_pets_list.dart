import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petverse/core/model/firebase_pet_model.dart';

class RequestPetsList extends StatelessWidget {
  final List<FirebasePetModel> pets;
  final CollaborativeAdoptionRequest request;

  const RequestPetsList({super.key, required this.pets, required this.request});

  @override
  Widget build(BuildContext context) {
    if (pets.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          'Nenhum pet selecionado para esta solicitação.',
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF64748B),
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
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
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Text(
              'Seus Pets Selecionados',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
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
        left: 20.w,
        right: 20.w,
        bottom: isLast ? 20.w : 12.w,
      ),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Color(requesterColorTheme).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Color(requesterColorTheme).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Text(
            pet.photo,
            style: TextStyle(fontSize: 32.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  '${pet.breed} • ${pet.age}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              'ATIVO',
              style: TextStyle(
                fontSize: 10.sp,
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
