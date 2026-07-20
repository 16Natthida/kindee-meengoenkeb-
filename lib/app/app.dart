import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/presentation/providers/settings_provider.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class KinDeeMeeNgoenKebApp extends ConsumerWidget {
  const KinDeeMeeNgoenKebApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(appThemeModeProvider);

    return MaterialApp.router(
      title: 'กินดี มีเงินเก็บ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        // รองรับขนาดตัวอักษรของเครื่อง แต่จำกัดไม่ให้ใหญ่เกินจน UI พัง
        final mq = MediaQuery.of(context);
        final clampedScale = mq.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.3);
        return MediaQuery(
          data: mq.copyWith(textScaler: clampedScale),
          child: child!,
        );
      },
    );
  }
}
