import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/features/settings/notifiers/theme_mode_notifier.dart';
import 'package:petverse/shared/providers/app_providers.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
    (ref) => ThemeModeNotifier(ref.read(persistenceServiceProvider)));
