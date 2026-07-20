import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/report_models.dart';

class DailyExpenseLineChart extends StatelessWidget {
  final List<DailyExpensePoint> days;

  const DailyExpenseLineChart({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text('ยังไม่มีข้อมูล')),
      );
    }

    final maxY = days.map((d) => d.amount).fold<double>(0, (a, b) => a > b ? a : b);
    final safeMaxY = maxY <= 0 ? 100.0 : maxY * 1.2;
    final color = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: safeMaxY,
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (days.length / 6).ceilToDouble().clamp(1, days.length.toDouble()),
                getTitlesWidget: (value, meta) {
                  final day = value.toInt();
                  if (day < 1 || day > days.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('$day', style: const TextStyle(fontSize: 10)),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(enabled: true),
          lineBarsData: [
            LineChartBarData(
              spots: days.map((d) => FlSpot(d.day.toDouble(), d.amount)).toList(),
              isCurved: true,
              color: color,
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.12)),
            ),
          ],
        ),
      ),
    );
  }
}
