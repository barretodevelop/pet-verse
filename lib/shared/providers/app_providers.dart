// lib/shared/providers/app_providers.dart (ou onde os providers globais ficariam)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/services/persistence_service.dart';
import 'package:petverse/data/event_manager.dart';

final persistenceServiceProvider = Provider((ref) => PersistenceService());
final eventManagerProvider = Provider((ref) => EventManager());
