import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/extensions/formatting_extensions.dart';
import '../../domain/dashboard_models.dart';

class SummaryCard extends StatelessWidget {
  final DashboardSummary summary;

  const SummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.seedGreen, AppColors.seedGreen.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'เงินคงเหลือเดือนนี้',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            '฿${summary.remaining.toBaht()}',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MiniStat(label: 'รายรับ', value: summary.totalIncome),
              const SizedBox(width: 20),
              _MiniStat(label: 'รายจ่าย', value: summary.totalExpense),
              const SizedBox(width: 20),
              _MiniStat(label: 'เงินเก็บ', value: summary.savings),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final double value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 2),
          Text(
            value.toBaht(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class FoodBudgetCard extends StatelessWidget {
  final DashboardSummary summary;

  const FoodBudgetCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant, color: AppColors.seedGreen),
                const SizedBox(width: 8),
                Text('งบค่าอาหาร', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'เหลือ ฿${summary.foodBudgetRemaining.toBaht()} '
              'จากงบ ฿${summary.foodBudget.toBaht()}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              summary.daysLeftInMonth > 0
                  ? 'เหลืออีก ${summary.daysLeftInMonth} วัน • ใช้ได้ไม่เกินวันละ ฿${summary.dailyFoodAllowance.toBaht()}'
                  : 'สิ้นเดือนแล้ว',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
