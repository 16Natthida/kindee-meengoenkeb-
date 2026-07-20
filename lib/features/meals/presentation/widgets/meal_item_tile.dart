import 'package:flutter/material.dart';

import '../../../../core/extensions/formatting_extensions.dart';
import '../../domain/meal_models.dart';

class MealItemTile extends StatelessWidget {
  final MealPlanItemModel item;
  final VoidCallback onToggleDone;
  final VoidCallback onDelete;
  final VoidCallback onAddToShoppingList;

  const MealItemTile({
    super.key,
    required this.item,
    required this.onToggleDone,
    required this.onDelete,
    required this.onAddToShoppingList,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(value: item.isDone, onChanged: (_) => onToggleDone()),
        title: Text(
          item.name,
          style: TextStyle(
            decoration: item.isDone ? TextDecoration.lineThrough : null,
            color: item.isDone ? Theme.of(context).colorScheme.outline : null,
          ),
        ),
        subtitle: Text(
          '${item.isHomemade ? "ทำเอง" : "ซื้อ"} • '
          '${item.peopleCount} คน • ฿${item.estimatedPrice.toBaht()}'
          '${item.prepMinutes != null ? " • ${item.prepMinutes} นาที" : ""}',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'shopping') onAddToShoppingList();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'shopping', child: Text('เพิ่มวัตถุดิบลงรายการซื้อของ')),
            const PopupMenuItem(value: 'delete', child: Text('ลบเมนูนี้')),
          ],
        ),
      ),
    );
  }
}
