import 'package:flutter/material.dart';

import '../../../../core/extensions/formatting_extensions.dart';
import '../../../../core/widgets/budget_status_badge.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../domain/dashboard_models.dart';

class CategoryProgressList extends StatelessWidget {
  final List<CategoryProgress> categories;

  const CategoryProgressList({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const EmptyStateView(
        message: 'ยังไม่มีการแบ่งงบประมาณของเดือนนี้',
        icon: Icons.pie_chart_outline,
      );
    }

    return Column(
      children: categories.map((c) {
        final status = budgetStatusFromRatio(c.usedRatio);
        final ratio = c.usedRatio.clamp(0, 1).toDouble();

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        c.name,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    BudgetStatusBadge(status: status),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 8,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'ใช้ไป ฿${c.spentAmount.toBaht()} จากงบ ฿${c.budgetAmount.toBaht()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class RecentExpensesList extends StatelessWidget {
  final List<RecentExpense> expenses;

  const RecentExpensesList({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const EmptyStateView(
        message: 'ยังไม่มีรายจ่ายในเดือนนี้',
        icon: Icons.receipt_long_outlined,
      );
    }

    return Column(
      children: expenses.map((e) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.shopping_bag_outlined)),
            title: Text(e.title),
            subtitle: Text(e.categoryName ?? 'ไม่ระบุหมวด'),
            trailing: Text(
              '-฿${e.amount.toBaht()}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        );
      }).toList(),
    );
  }
}
