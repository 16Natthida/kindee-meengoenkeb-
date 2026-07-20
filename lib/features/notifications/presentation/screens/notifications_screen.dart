import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../providers/notifications_provider.dart';
import '../widgets/notification_tile.dart';
import '../../domain/notification_models.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _hasCheckedThisSession = false;

  @override
  void initState() {
    super.initState();
    _runCheck();
  }

  Future<void> _runCheck() async {
    if (_hasCheckedThisSession) return;
    _hasCheckedThisSession = true;
    try {
      await ref.read(notificationsRepositoryProvider).checkAndGenerateNotifications();
      ref.invalidate(notificationsListProvider);
      ref.invalidate(unreadNotificationCountProvider);
    } catch (_) {
      // การตรวจสอบพื้นหลังล้มเหลวไม่ควรบล็อกการแสดงรายการเดิม
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('การแจ้งเตือน'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'อ่านทั้งหมด',
            onPressed: () async {
              await ref.read(notificationsRepositoryProvider).markAllRead();
              ref.invalidate(notificationsListProvider);
              ref.invalidate(unreadNotificationCountProvider);
            },
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const DashboardSkeleton(),
        error: (e, st) => ErrorStateView(
          message: AppException.from(e).message,
          onRetry: () => ref.invalidate(notificationsListProvider),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const EmptyStateView(
              message: 'ยังไม่มีการแจ้งเตือน',
              icon: Icons.notifications_none_outlined,
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              _hasCheckedThisSession = false;
              await _runCheck();
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final n = notifications[index];
                return NotificationTile(
                  notification: n,
                  onTap: () async {
                    if (!n.isRead) {
                      await ref.read(notificationsRepositoryProvider).markRead(n.id);
                      ref.invalidate(notificationsListProvider);
                      ref.invalidate(unreadNotificationCountProvider);
                    }
                    if (context.mounted) context.push(n.type.targetRoute);
                  },
                  onDelete: () async {
                    await ref.read(notificationsRepositoryProvider).delete(n.id);
                    ref.invalidate(notificationsListProvider);
                    ref.invalidate(unreadNotificationCountProvider);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
