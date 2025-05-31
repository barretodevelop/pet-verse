import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petverse/core/model/firebase_pet_model.dart';
import 'package:petverse/core/providers/active_request_provider.dart';
import 'package:petverse/feature/home/presentation/widgets/request_action_buttons.dart';
import 'package:petverse/feature/home/presentation/widgets/request_header.dart';
import 'package:petverse/feature/pet/presentation/widgets/request_pets_list.dart';

class ActiveRequestCard extends ConsumerWidget {
  final CollaborativeAdoptionRequest activeRequest;

  const ActiveRequestCard({super.key, required this.activeRequest});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(userActiveRequestPetsProvider);

    return Container(
      margin: EdgeInsets.all(20.w),
      child: SingleChildScrollView(
        child: Column(
          children: [
            RequestHeader(activeRequest: activeRequest),
            SizedBox(height: 20.h),
            petsAsync.when(
              data: (pets) =>
                  RequestPetsList(pets: pets, request: activeRequest),
              loading: () => const _PetsLoadingIndicator(),
              error: (_, __) => const _PetsErrorDisplay(),
            ),
            SizedBox(height: 20.h),
            RequestActionButtons(activeRequest: activeRequest),
          ],
        ),
      ),
    );
  }
}

class _PetsLoadingIndicator extends StatelessWidget {
  const _PetsLoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _PetsErrorDisplay extends StatelessWidget {
  const _PetsErrorDisplay();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        'Erro ao carregar pets',
        style: TextStyle(
          fontSize: 14.sp,
          color: const Color(0xFFEF4444),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
