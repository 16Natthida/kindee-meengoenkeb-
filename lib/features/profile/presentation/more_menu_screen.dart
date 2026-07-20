import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../notifications/presentation/providers/notifications_provider.dart';

class MoreMenuScreen extends ConsumerWidget {
  const MoreMenuScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ออกจากระบบ'),
        content: const Text('คุณต้องการออกจากระบบใช่หรือไม่?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ยกเลิก')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('ออกจากระบบ')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authFormControllerProvider.notifier).signOut();
      if (context.mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider).valueOrNull ?? 0;
    final items = <_MenuItem>[
      _MenuItem(Icons.repeat_rounded, 'รายจ่ายประจำ', 'จัดการรายการที่เกิดขึ้นซ้ำ', () => context.push('/expenses/recurring')),
      _MenuItem(Icons.pie_chart_outline_rounded, 'แบ่งเงินเดือน', 'บันทึกรายรับและวางแผนเงิน', () => context.push('/income-entry')),
      _MenuItem(Icons.kitchen_outlined, 'วัตถุดิบ', 'ดูของในครัวและวันหมดอายุ', () => context.push('/ingredients')),
      _MenuItem(Icons.tune_rounded, 'ตั้งค่าการกิน', 'ปรับความชอบสำหรับแผนอาหาร', () => context.push('/meal-preferences')),
      _MenuItem(Icons.history_rounded, 'ประวัติย้อนหลัง', 'ดูภาพรวมการเงินที่ผ่านมา', () => context.push('/reports')),
      _MenuItem(Icons.notifications_outlined, 'การแจ้งเตือน', 'เช็กการแจ้งเตือนทั้งหมด', () => context.push('/notifications'), badgeCount: unreadCount),
      _MenuItem(Icons.person_outline_rounded, 'โปรไฟล์', 'แก้ไขข้อมูลส่วนตัว', () => context.push('/edit-profile')),
      _MenuItem(Icons.settings_outlined, 'ตั้งค่า', 'ธีม สกุลเงิน และการแจ้งเตือน', () => context.push('/settings')),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('อื่น ๆ')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.pastelYellow, AppColors.softPink],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.auto_awesome_rounded, color: AppColors.strawberry),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('จัดการแอปของคุณ', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 3),
                      Text('เครื่องมือทั้งหมดอยู่ที่นี่', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text('เครื่องมือและการตั้งค่า', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  _MenuTile(item: items[i]),
                  if (i != items.length - 1) const Divider(height: 1, indent: 72, endIndent: 16),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          Card(
            color: AppColors.softPink.withValues(alpha: 0.35),
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.dangerRed),
              title: const Text('ออกจากระบบ', style: TextStyle(color: AppColors.dangerRed, fontWeight: FontWeight.w700)),
              subtitle: const Text('ออกจากบัญชีบนอุปกรณ์นี้'),
              onTap: () => _confirmLogout(context, ref),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final _MenuItem item;
  const _MenuTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: AppColors.softPink, borderRadius: BorderRadius.circular(14)),
        child: Icon(item.icon, color: AppColors.strawberry),
      ),
      title: Text(item.label, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(item.description),
      isThreeLine: false,
      trailing: item.badgeCount > 0
          ? CircleAvatar(
              radius: 13,
              backgroundColor: AppColors.strawberry,
              child: Text('${item.badgeCount}', style: const TextStyle(color: Colors.white, fontSize: 12)),
            )
          : const Icon(Icons.chevron_right_rounded),
      onTap: item.onTap,
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;
  final int badgeCount;

  _MenuItem(this.icon, this.label, this.description, this.onTap, {this.badgeCount = 0});
}
