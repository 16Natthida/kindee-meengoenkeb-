import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/extensions/formatting_extensions.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../domain/report_models.dart';
import '../providers/reports_provider.dart';
import '../widgets/daily_line_chart.dart';
import '../widgets/expense_pie_chart.dart';
import '../widgets/weekly_bar_chart.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  static const _thaiMonths = [
    'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
    'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
  ];

  void _changeMonth(WidgetRef ref, int delta) {
    final current = ref.read(reportPeriodProvider);
    final next = DateTime(current.year, current.month + delta);
    ref.read(reportPeriodProvider.notifier).state = next;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(reportPeriodProvider);
    final reportAsync = ref.watch(monthlyReportProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ประวัติและรายงาน')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changeMonth(ref, -1),
                ),
                Text(
                  '${_thaiMonths[period.month - 1]} ${period.year + 543}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _changeMonth(ref, 1),
                ),
              ],
            ),
          ),
          Expanded(
            child: reportAsync.when(
              loading: () => const DashboardSkeleton(),
              error: (e, st) => ErrorStateView(
                message: AppException.from(e).message,
                onRetry: () => ref.invalidate(monthlyReportProvider),
              ),
              data: (report) {
                if (report.totalIncome == 0 && report.totalExpense == 0) {
                  return const EmptyStateView(
                    message: 'ไม่มีข้อมูลของเดือนนี้',
                    icon: Icons.bar_chart_outlined,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(monthlyReportProvider),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    children: [
                      _SummaryGrid(report: report),
                      const SizedBox(height: 20),
                      _SectionCard(
                        title: 'สัดส่วนรายจ่ายตามหมวด',
                        child: ExpensePieChart(slices: report.expenseByCategory),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'รายจ่ายรายสัปดาห์',
                        child: WeeklyExpenseBarChart(weeks: report.weeklyExpenses),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'ค่าใช้จ่ายรายวัน',
                        child: DailyExpenseLineChart(days: report.dailyExpenses),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'สรุปเพิ่มเติม',
                        child: Column(
                          children: [
                            _InfoRow(label: 'ค่าอาหารรวม', value: '฿${report.foodCost.toBaht()}'),
                            _InfoRow(
                              label: 'เมนูที่วางแผน / ทำแล้ว',
                              value: '${report.mealsPlannedCount} / ${report.mealsDoneCount} เมนู',
                            ),
                            _InfoRow(
                              label: 'รายการซื้อของที่ซื้อแล้ว',
                              value: '${report.shoppingItemsPurchased} รายการ',
                            ),
                            _InfoRow(
                              label: 'วัตถุดิบที่ซื้อเข้าบ้าน',
                              value: '${report.ingredientsPurchasedCount} รายการ',
                            ),
                            _InfoRow(
                              label: 'วันที่ใช้เงินเกินงบอาหารรายวัน',
                              value: '${report.daysOverDailyFoodBudget} วัน',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final MonthlyReport report;
  const _SummaryGrid({required this.report});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.4,
      children: [
        _StatCard(label: 'รายรับทั้งหมด', value: report.totalIncome, color: AppColors.strawberry),
        _StatCard(label: 'รายจ่ายทั้งหมด', value: report.totalExpense, color: AppColors.dangerRed),
        _StatCard(label: 'เงินคงเหลือ', value: report.remaining, color: const Color(0xFFE4A84D)),
        _StatCard(label: 'เงินเก็บ', value: report.savings, color: AppColors.pastelYellow),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              '฿${value.toBaht()}',
              style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
