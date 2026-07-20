import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/extensions/formatting_extensions.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../expenses/presentation/providers/recurring_expenses_provider.dart';
import '../../../ingredients/presentation/providers/ingredients_provider.dart';
import '../../../ingredients/presentation/widgets/ingredient_tile.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../../shopping/presentation/providers/shopping_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/category_progress_list.dart';
import '../widgets/summary_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final profileAsync = ref.watch(currentProfileProvider);
    final expiringAsync = ref.watch(expiringIngredientsProvider);
    final shoppingAsync = ref.watch(shoppingItemsProvider);
    final unreadAsync = ref.watch(unreadNotificationCountProvider);
    ref.watch(recurringExpenseSyncProvider);
    final unreadCount = unreadAsync.valueOrNull ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: profileAsync.maybeWhen(
          data: (p) => Text('สวัสดี, ${p?.username ?? ''}'),
          orElse: () => const Text('หน้าหลัก'),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.push('/notifications'),
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/expenses/add'),
        child: const Icon(Icons.add),
      ),
      body: summaryAsync.when(
        loading: () => const DashboardSkeleton(),
        error: (err, st) => ErrorStateView(
          message: AppException.from(err).message,
          onRetry: () => ref.invalidate(dashboardSummaryProvider),
        ),
        data: (summary) {
          final hasIncome = summary.totalIncome > 0 || summary.categories.isNotEmpty;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(dashboardSummaryProvider);
              ref.invalidate(expiringIngredientsProvider);
              ref.invalidate(shoppingItemsProvider);
              try {
                await ref.read(notificationsRepositoryProvider).checkAndGenerateNotifications();
              } catch (_) {
                // ไม่บล็อกการรีเฟรชหลักถ้าตรวจสอบการแจ้งเตือนไม่สำเร็จ
              }
              ref.invalidate(unreadNotificationCountProvider);
              await ref.read(dashboardSummaryProvider.future);
            },
            child: !hasIncome
                ? ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const SizedBox(height: 60),
                      EmptyStateView(
                        message:
                            'ยังไม่มีข้อมูลเงินเดือนของเดือนนี้\nเริ่มต้นด้วยการกรอกเงินเดือนและแบ่งงบประมาณ',
                        icon: Icons.savings_outlined,
                        action: FilledButton.icon(
                          onPressed: () => context.push('/income-entry'),
                          icon: const Icon(Icons.add),
                          label: const Text('กรอกเงินเดือน'),
                        ),
                      ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      SummaryCard(summary: summary),
                      const SizedBox(height: 16),
                      const _QuickActions(),
                      const SizedBox(height: 20),
                      FoodBudgetCard(summary: summary),
                      const SizedBox(height: 20),
                      Text('งบประมาณแต่ละหมวด',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 10),
                      CategoryProgressList(categories: summary.categories),
                      const SizedBox(height: 20),
                      Text('รายจ่ายล่าสุด',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 10),
                      RecentExpensesList(expenses: summary.recentExpenses),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Text('วัตถุดิบใกล้หมดอายุ',
                              style: Theme.of(context).textTheme.titleMedium),
                          const Spacer(),
                          TextButton(
                            onPressed: () => context.push('/ingredients'),
                            child: const Text('ดูทั้งหมด'),
                          ),
                        ],
                      ),
                      expiringAsync.when(
                        loading: () => const AppSkeleton(height: 60),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (list) {
                          if (list.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text('ไม่มีวัตถุดิบใกล้หมดอายุ'),
                            );
                          }
                          return Column(
                            children: list.take(3).map((ingredient) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  onTap: () =>
                                      context.push('/ingredients/edit/${ingredient.id}'),
                                  leading: CircleAvatar(
                                    backgroundImage: ingredient.imageUrl != null
                                        ? NetworkImage(ingredient.imageUrl!)
                                        : null,
                                    child: ingredient.imageUrl == null
                                        ? const Icon(Icons.kitchen_outlined)
                                        : null,
                                  ),
                                  title: Text(ingredient.name),
                                  subtitle: IngredientStatusChip(status: ingredient.computedStatus),
                                  trailing: ingredient.expiryDate != null
                                      ? Text(ingredient.expiryDate!.toThaiShort())
                                      : null,
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text('รายการซื้อของที่ยังไม่ได้ซื้อ',
                              style: Theme.of(context).textTheme.titleMedium),
                          const Spacer(),
                          TextButton(
                            onPressed: () => context.push('/shopping'),
                            child: const Text('ดูทั้งหมด'),
                          ),
                        ],
                      ),
                      shoppingAsync.when(
                        loading: () => const AppSkeleton(height: 60),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (items) {
                          final pending = items.where((i) => !i.isPurchased).toList();
                          if (pending.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text('ซื้อของครบตามรายการแล้ว'),
                            );
                          }
                          return Column(
                            children: pending.take(3).map((item) {
                              final qtyLabel = item.quantity == item.quantity.roundToDouble()
                                  ? item.quantity.toStringAsFixed(0)
                                  : item.quantity.toStringAsFixed(1);
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: const Icon(Icons.shopping_cart_outlined),
                                  title: Text(item.productName),
                                  subtitle: Text('$qtyLabel ${item.unit}'),
                                  trailing: item.estimatedPrice != null
                                      ? Text('≈฿${item.estimatedPrice!.toBaht()}')
                                      : null,
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.receipt_long_outlined, 'เพิ่มรายจ่าย', '/expenses/add'),
      (Icons.savings_outlined, 'เพิ่มรายรับ', '/income-entry'),
      (Icons.restaurant_menu_outlined, 'วางแผนอาหาร', '/meals'),
      (Icons.kitchen_outlined, 'เพิ่มวัตถุดิบ', '/ingredients/add'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ทำอะไรต่อดี?', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.8,
          ),
          itemBuilder: (context, index) {
            final (icon, label, route) = actions[index];
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.push(route),
              child: Ink(
                decoration: BoxDecoration(
                  color: index.isEven ? AppColors.softPink : AppColors.pastelYellow.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Icon(icon, color: AppColors.strawberry, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.chevron_right, size: 18),
                    const SizedBox(width: 6),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
