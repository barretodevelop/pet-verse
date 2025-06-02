// lib/shared/providers/initial_loading_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/features/auth/providers/auth_providers.dart';
import 'package:petverse/features/settings/providers/day_night_cycle_provider.dart';
import 'package:petverse/features/settings/providers/theme_provider.dart';
import 'package:petverse/shared/providers/global_providers.dart';

final gameDataLoadingProvider = FutureProvider<void>((ref) async {
  final firebaseUser = ref.watch(authStateChangesProvider).asData?.value;
  if (firebaseUser == null) {
    // Não deveria ser chamado se não estiver autenticado, mas como segurança:
    debugPrint("gameDataLoadingProvider chamado sem usuário autenticado.");
    return;
  }
  // Agora passamos o UID para carregar/salvar dados específicos do usuário
  await ref
      .read(userProvider.notifier)
      .loadDataAndCheckQuests(firebaseUser.uid);
  await ref.read(activePetProvider.notifier).loadInitialPet(firebaseUser.uid);
});

final initialLoadingProvider = FutureProvider<void>((ref) async {
  await ref.read(themeModeProvider.notifier).loadTheme();
  await ref
      .read(dayNightCycleProvider.notifier)
      .loadDayNightCyclePreference(); // NOVO: Carrega preferência do ciclo
  // ... (carregamento de UserProfile e ActivePet como antes, dependendo do UID do Firebase)
  // Exemplo:
  // final firebaseUser = ref.watch(authStateChangesProvider).asData?.value;
  // if (firebaseUser != null) {
  //   await ref.read(userProvider.notifier).loadDataAndCheckQuests(firebaseUser.uid);
  //   await ref.read(activePetProvider.notifier).loadInitialPet(firebaseUser.uid);
  // }
});
