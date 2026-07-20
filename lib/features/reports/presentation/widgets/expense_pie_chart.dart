import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/extensions/formatting_extensions.dart';
import '../../domain/report_models.dart';

const _palette = [
  AppColors.strawberry,
  AppColors.pastelYellow,
  Color(0xFFFFB3C1),
  Color(0xFFF7C6A3),
  Color(0xFFE9B7D4),
  Color(0xFFE58B91),
  Color(0xFFFFE08A),
  Color(0xFFD9BFA9),
];

class ExpensePieChart extends StatelessWidget {
  final List<CategoryExpenseSlice> slices;

  const ExpensePieChart({super.key, required this.slices});

  @override
  Widget build(BuildContext context) {
    if (slices.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text('ยังไม่มีรายจ่ายในเดือนนี้')),
      );
    }

    final total = slices.fold<double>(0, (s, e) => s + e.amount);

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: List.generate(slices.length, (i) {
                final s = slices[i];
                final pct = total == 0 ? 0 : (s.amount / total * 100);
                return PieChartSectionData(
                  value: s.amount,
                  title: '${pct.toStringAsFixed(0)}%',
                  color: _palette[i % _palette.length],
                  radius: 56,
                  titleStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(slices.length, (i) {
            final s = slices[i];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _palette[i % _palette.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text('${s.categoryName} ฿${s.amount.toBaht()}',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            );
          }),
        ),
      ],
    );
  }
}
