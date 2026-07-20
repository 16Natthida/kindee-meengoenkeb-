import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/notifications_repository.dart';
import '../../domain/notification_models.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepository();
});

final notificationsListProvider =
    FutureProvider.autoDispose<List<AppNotificationModel>>((ref) async {
  final repo = ref.watch(notificationsRepositoryProvider);
  return repo.fetchNotifications();
});

final unreadNotificationCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repo = ref.watch(notificationsRepositoryProvider);
  return repo.fetchUnreadCount();
});
