import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/extensions/formatting_extensions.dart';
import '../../domain/shopping_models.dart';

class ShoppingItemTile extends StatelessWidget {
  final ShoppingListItemModel item;
  final VoidCallback onTogglePurchased;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ShoppingItemTile({
    super.key,
    required this.item,
    required this.onTogglePurchased,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = item.isPurchased
        ? AppColors.textDark.withValues(alpha: 0.35)
        : AppColors.strawberry;
    final quantity = item.quantity == item.quantity.roundToDouble()
        ? item.quantity.toStringAsFixed(0)
        : item.quantity.toStringAsFixed(1);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: AppColors.softPink.withValues(alpha: item.isPurchased ? 0.45 : 0.9),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTogglePurchased,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: item.isPurchased
                      ? AppColors.softPink
                      : AppColors.pastelYellow.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                child: Checkbox(
                  value: item.isPurchased,
                  onChanged: (_) => onTogglePurchased(),
                  activeColor: AppColors.strawberry,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  side: BorderSide(color: accent, width: 1.5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        decoration: item.isPurchased ? TextDecoration.lineThrough : null,
                        color: item.isPurchased ? theme.colorScheme.outline : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$quantity ${item.unit}${item.linkedToMealPlan ? ' • จากแผนอาหาร' : ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textDark.withValues(alpha: 0.62),
                      ),
                    ),
                  ],
                ),
              ),
              if (item.isPurchased && item.actualPrice != null)
                Text(
                  '฿${item.actualPrice!.toBaht()}',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.strawberry),
                )
              else if (item.estimatedPrice != null)
                Text('≈฿${item.estimatedPrice!.toBaht()}', style: theme.textTheme.labelMedium),
              IconButton(
                icon: const Icon(Icons.more_horiz),
                tooltip: 'ตัวเลือก',
                onPressed: () => _showOptions(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('แก้ไขรายการ'),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.dangerRed),
              title: const Text('ลบรายการ', style: TextStyle(color: AppColors.dangerRed)),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}
