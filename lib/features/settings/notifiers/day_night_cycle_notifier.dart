// lib/features/settings/notifiers/day_night_cycle_notifier.dart (NOVO)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/services/persistence_service.dart'
    show PersistenceService;

class DayNightCycleNotifier extends StateNotifier<bool> {
  final PersistenceService _persistenceService;
  DayNightCycleNotifier(this._persistenceService)
      : super(true); // Padrão é habilitado

  Future<void> loadDayNightCyclePreference() async {
    state = await _persistenceService.loadDayNightCycleEnabled();
  }

  Future<void> setDayNightCycleEnabled(bool enabled) async {
    state = enabled;
    await _persistenceService.saveDayNightCycleEnabled(enabled);
  }
}
