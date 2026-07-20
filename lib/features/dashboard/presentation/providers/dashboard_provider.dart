import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/dashboard_repository.dart';
import '../../domain/dashboard_models.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

/// เดือน/ปีที่กำลังดูอยู่บน Dashboard (ค่าเริ่มต้น = เดือนปัจจุบัน)
final dashboardPeriodProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

final dashboardSummaryProvider = FutureProvider.autoDispose<DashboardSummary>((ref) async {
  final period = ref.watch(dashboardPeriodProvider);
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.fetchMonthlySummary(month: period.month, year: period.year);
});
