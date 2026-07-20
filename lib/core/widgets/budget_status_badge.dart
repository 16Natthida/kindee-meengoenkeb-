import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

enum BudgetStatus { normal, near, warning, over }

BudgetStatus budgetStatusFromRatio(double usedRatio) {
  if (usedRatio > AppConstants.budgetDangerMax) return BudgetStatus.over;
  if (usedRatio >= AppConstants.budgetWarningMax) return BudgetStatus.warning;
  if (usedRatio >= AppConstants.budgetNormalMax) return BudgetStatus.near;
  return BudgetStatus.normal;
}

class BudgetStatusBadge extends StatelessWidget {
  final BudgetStatus status;

  const BudgetStatusBadge({super.key, required this.status});

  ({Color color, IconData icon, String label}) get _config {
    switch (status) {
      case BudgetStatus.normal:
        return (color: const Color(0xFF3E8E5A), icon: Icons.check_circle, label: 'ปกติ');
      case BudgetStatus.near:
        return (color: const Color(0xFFC58A1F), icon: Icons.info, label: 'ใกล้เต็มงบ');
      case BudgetStatus.warning:
        return (color: const Color(0xFFE07B1E), icon: Icons.warning_amber, label: 'ควรระวัง');
      case BudgetStatus.over:
        return (color: const Color(0xFFD5473A), icon: Icons.error, label: 'เกินงบ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _config;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(c.icon, size: 14, color: c.color),
          const SizedBox(width: 4),
          Text(
            c.label,
            style: TextStyle(color: c.color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
