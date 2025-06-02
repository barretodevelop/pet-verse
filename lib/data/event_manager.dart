// lib/data/event_manager.dart
import 'package:flutter/material.dart';
import 'package:petverse/shared/models/app_event.dart';

class EventManager {
  final List<AppEvent> _allEvents = [
    AppEvent(
      id: 'summer2025',
      name: '☀️ Evento de Verão ☀️',
      startDate: DateTime(2025, 6, 1),
      endDate: DateTime(2025, 8, 31),
      eventItemIds: ['sunglasses', 'ice_cream'],
      eventQuestIds: ['summer_play'],
      themeColor: Colors.orange,
    ),
  ];

  AppEvent? getActiveEvent() {
    final now = DateTime.now();
    try {
      return _allEvents.firstWhere((event) => event.isActive(now));
    } catch (e) {
      return null;
    }
  }
}
