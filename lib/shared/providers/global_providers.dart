// lib/shared/providers/global_providers.dart (ou onde os providers principais ficariam)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/features/pet_care/notifiers/active_pet_notifier.dart';
import 'package:petverse/features/user_profile/notifiers/user_notifier.dart';
import 'package:petverse/shared/models/active_pet.dart';
import 'package:petverse/shared/models/user_state.dart';
import 'package:petverse/shared/providers/app_providers.dart';

// final userProvider = StateNotifierProvider<UserNotifier, User>((ref) =>
//     UserNotifier(ref.watch(persistenceServiceProvider),
//         ref.watch(eventManagerProvider).getActiveEvent()));
// final activePetProvider = StateNotifierProvider<ActivePetNotifier, ActivePet?>(
//     (ref) => ActivePetNotifier(ref.watch(persistenceServiceProvider), ref));

final userProvider = StateNotifierProvider<UserNotifier, UserProfile>((ref) =>
    UserNotifier(ref.watch(persistenceServiceProvider),
        ref.watch(eventManagerProvider).getActiveEvent()));
final activePetProvider = StateNotifierProvider<ActivePetNotifier, ActivePet?>(
    (ref) => ActivePetNotifier(ref.watch(persistenceServiceProvider), ref));
