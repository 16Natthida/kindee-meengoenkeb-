import 'package:flutter_test/flutter_test.dart';
import 'package:kindee_meengoenkeb/features/notifications/domain/notification_models.dart';
import 'package:kindee_meengoenkeb/features/reports/domain/report_models.dart';

void main() {
  group('NotificationType mapping', () {
    test('every type round-trips through dbValue correctly', () {
      for (final type in NotificationType.values) {
        final dbValue = type.dbValue;
        final parsed = NotificationTypeX.fromDb(dbValue);
        expect(parsed, type, reason: 'round-trip failed for $type');
      }
    });

    test('unknown db value falls back to budgetLow without throwing', () {
      final parsed = NotificationTypeX.fromDb('unknown_type_xyz');
      expect(parsed, NotificationType.budgetLow);
    });

    test('each type has a non-empty target route', () {
      for (final type in NotificationType.values) {
        expect(type.targetRoute, isNotEmpty);
        expect(type.targetRoute.startsWith('/'), isTrue);
      }
    });
  });

  group('MonthlyReport.empty', () {
    test('produces zeroed report with empty chart data', () {
      final report = MonthlyReport.empty(7, 2026);
      expect(report.totalIncome, 0);
      expect(report.totalExpense, 0);
      expect(report.expenseByCategory, isEmpty);
      expect(report.dailyExpenses, isEmpty);
      expect(report.weeklyExpenses, isEmpty);
    });
  });

  group('Weekly grouping logic (mirrors ReportsRepository grouping)', () {
    List<WeeklyExpensePoint> groupIntoWeeks(Map<int, double> byDay, int daysInMonth) {
      final weeks = <WeeklyExpensePoint>[];
      for (int start = 1; start <= daysInMonth; start += 7) {
        final end = (start + 6) > daysInMonth ? daysInMonth : start + 6;
        double sum = 0;
        for (int d = start; d <= end; d++) {
          sum += byDay[d] ?? 0;
        }
        weeks.add(WeeklyExpensePoint(weekIndex: weeks.length + 1, amount: sum));
      }
      return weeks;
    }

    test('31-day month groups into 5 weeks with last week partial', () {
      final byDay = {for (int d = 1; d <= 31; d++) d: 100.0};
      final weeks = groupIntoWeeks(byDay, 31);
      expect(weeks.length, 5);
      expect(weeks.first.amount, 700); // days 1-7
      expect(weeks.last.amount, 300); // days 29-31 (3 days)
    });

    test('empty spending still produces correct week count', () {
      final weeks = groupIntoWeeks({}, 28);
      expect(weeks.length, 4);
      expect(weeks.every((w) => w.amount == 0), isTrue);
    });
  });
}
