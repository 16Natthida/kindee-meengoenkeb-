import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/reports_repository.dart';
import '../../domain/report_models.dart';

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepository();
});

/// เดือน/ปีที่กำลังดูรายงาน (ค่าเริ่มต้น = เดือนปัจจุบัน)
final reportPeriodProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

/// โหลดเฉพาะเมื่อเปิดหน้ารายงาน (autoDispose) เพื่อไม่ให้กราฟโหลดพร้อม Dashboard
final monthlyReportProvider = FutureProvider.autoDispose<MonthlyReport>((ref) async {
  final period = ref.watch(reportPeriodProvider);
  final repo = ref.watch(reportsRepositoryProvider);
  return repo.fetchMonthlyReport(month: period.month, year: period.year);
});
