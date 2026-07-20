import 'package:flutter/material.dart';

import '../../../../core/extensions/formatting_extensions.dart';
import '../../domain/ingredient_models.dart';

({Color color, IconData icon}) _statusStyle(IngredientStatus status) {
  switch (status) {
    case IngredientStatus.available:
      return (color: const Color(0xFF3E8E5A), icon: Icons.check_circle);
    case IngredientStatus.low:
      return (color: const Color(0xFFC58A1F), icon: Icons.trending_down);
    case IngredientStatus.expiringSoon:
      return (color: const Color(0xFFE07B1E), icon: Icons.warning_amber);
    case IngredientStatus.expired:
      return (color: const Color(0xFFD5473A), icon: Icons.error);
    case IngredientStatus.outOfStock:
      return (color: const Color(0xFF9E9E9E), icon: Icons.remove_circle_outline);
  }
}

class IngredientStatusChip extends StatelessWidget {
  final IngredientStatus status;
  const IngredientStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final s = _statusStyle(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: s.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: s.color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(s.icon, size: 12, color: s.color),
          const SizedBox(width: 3),
          Text(status.label, style: TextStyle(color: s.color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class IngredientTile extends StatelessWidget {
  final IngredientModel ingredient;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const IngredientTile({
    super.key,
    required this.ingredient,
    required this.onTap,
    required this.onDelete,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(ingredient.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('ลบวัตถุดิบ'),
                content: Text('ต้องการลบ "${ingredient.name}" ใช่หรือไม่?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ยกเลิก')),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('ลบ'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundImage: ingredient.imageUrl != null ? NetworkImage(ingredient.imageUrl!) : null,
            child: ingredient.imageUrl == null ? const Icon(Icons.kitchen_outlined) : null,
          ),
          title: Text(ingredient.name),
          subtitle: Row(
            children: [
              IngredientStatusChip(status: ingredient.computedStatus),
              const SizedBox(width: 6),
              if (ingredient.expiryDate != null)
                Text('หมดอายุ ${ingredient.expiryDate!.toThaiShort()}',
                    style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 20),
                onPressed: onDecrement,
              ),
              Text('${ingredient.quantity.toStringAsFixed(ingredient.quantity == ingredient.quantity.roundToDouble() ? 0 : 1)} ${ingredient.unit}'),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                onPressed: onIncrement,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
