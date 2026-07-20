import 'package:flutter/material.dart';

import '../../domain/budget_models.dart';

Future<BudgetTemplate?> showBudgetTemplateSheet(BuildContext context) {
  return showModalBottomSheet<BudgetTemplate>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('เลือกสูตรสำเร็จรูป',
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              const SizedBox(height: 8),
              ...BudgetTemplate.values.map((t) {
                return ListTile(
                  leading: const Icon(Icons.auto_awesome_outlined),
                  title: Text(t.label),
                  onTap: () => Navigator.pop(context, t),
                );
              }),
            ],
          ),
        ),
      );
    },
  );
}
