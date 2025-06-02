// lib/features/settings/providers/day_night_cycle_provider.dart (NOVO)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/features/settings/notifiers/day_night_cycle_notifier.dart';
import 'package:petverse/shared/providers/app_providers.dart';

final dayNightCycleProvider =
    StateNotifierProvider<DayNightCycleNotifier, bool>((ref) {
  return DayNightCycleNotifier(ref.read(persistenceServiceProvider));
});
