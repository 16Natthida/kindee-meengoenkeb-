import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/settings_repository.dart';
import '../../domain/settings_models.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final userSettingsProvider = FutureProvider.autoDispose<UserSettingsModel>((ref) async {
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.fetchOrCreateSettings();
});

/// แปลงค่า theme_mode จากฐานข้อมูล ('light'/'dark'/'system') เป็น Flutter ThemeMode
/// ให้ MaterialApp.router ใช้ได้ตรง ๆ — ถ้ายังโหลดไม่เสร็จหรือ error จะ fallback เป็น system
final appThemeModeProvider = Provider<ThemeMode>((ref) {
  final settingsAsync = ref.watch(userSettingsProvider);
  return settingsAsync.when(
    data: (settings) {
      switch (settings.themeMode) {
        case 'light':
          return ThemeMode.light;
        case 'dark':
          return ThemeMode.dark;
        default:
          return ThemeMode.system;
      }
    },
    loading: () => ThemeMode.system,
    error: (_, __) => ThemeMode.system,
  );
});
