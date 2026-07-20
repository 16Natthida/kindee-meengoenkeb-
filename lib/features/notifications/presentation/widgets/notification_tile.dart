import 'package:flutter/material.dart';

import '../../domain/notification_models.dart';

IconData _iconFor(String name) {
  switch (name) {
    case 'account_balance_wallet':
      return Icons.account_balance_wallet_outlined;
    case 'kitchen':
      return Icons.kitchen_outlined;
    case 'restaurant_menu':
      return Icons.restaurant_menu_outlined;
    case 'shopping_cart':
      return Icons.shopping_cart_outlined;
    case 'trending_up':
      return Icons.trending_up;
    default:
      return Icons.notifications_outlined;
  }
}

class NotificationTile extends StatelessWidget {
  final AppNotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  static const _thaiMonths = [
    'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
    'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
  ];

  String _formatDate(DateTime d) => '${d.day} ${_thaiMonths[d.month - 1]} ${(d.year + 543).toString().substring(2)}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(color: theme.colorScheme.error, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        color: notification.isRead ? null : theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(_iconFor(notification.type.icon), size: 20),
          ),
          title: Text(
            notification.title,
            style: TextStyle(fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w700),
          ),
          subtitle: Text(notification.detail, maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_formatDate(notification.createdAt), style: theme.textTheme.bodySmall),
              if (!notification.isRead)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
