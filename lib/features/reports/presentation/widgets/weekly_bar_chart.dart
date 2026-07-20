import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/report_models.dart';

class WeeklyExpenseBarChart extends StatelessWidget {
  final List<WeeklyExpensePoint> weeks;

  const WeeklyExpenseBarChart({super.key, required this.weeks});

  @override
  Widget build(BuildContext context) {
    if (weeks.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text('ยังไม่มีข้อมูล')),
      );
    }

    final maxY = weeks.map((w) => w.amount).fold<double>(0, (a, b) => a > b ? a : b);
    final safeMaxY = maxY <= 0 ? 100.0 : maxY * 1.2;
    final color = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: safeMaxY,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= weeks.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('สัปดาห์ ${weeks[index].weekIndex}',
                        style: const TextStyle(fontSize: 10)),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(weeks.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: weeks[i].amount,
                  color: color,
                  width: 22,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
