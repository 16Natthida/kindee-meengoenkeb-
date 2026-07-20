import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/extensions/formatting_extensions.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../providers/expenses_provider.dart';
import '../widgets/expense_filter_sheet.dart';
import '../widgets/expense_tile.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(expensesListControllerProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    final current = ref.read(expenseFilterProvider);
    ref.read(expenseFilterProvider.notifier).state =
        current.copyWith(searchText: value);
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(expensesListControllerProvider);
    final totalAsync = ref.watch(filteredExpenseTotalProvider);
    final filter = ref.watch(expenseFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายจ่าย'),
        actions: [
          IconButton(
            icon: Icon(filter.isActive ? Icons.filter_alt : Icons.filter_alt_outlined),
            onPressed: () async {
              final result = await showExpenseFilterSheet(context, current: filter);
              if (result != null) {
                ref.read(expenseFilterProvider.notifier).state = result;
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/expenses/add'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'ค้นหาจากชื่อรายการ',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.strawberry, AppColors.strawberry.withValues(alpha: 0.78)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.strawberry.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: DefaultTextStyle(
                style: const TextStyle(color: Colors.white),
                child: Row(
              children: [
                const Icon(Icons.account_balance_wallet_rounded, color: Colors.white),
                const SizedBox(width: 10),
                const Spacer(),
                const Text('ยอดรวม: '),
                totalAsync.when(
                  loading: () => const SizedBox(
                    width: 60,
                    child: AppSkeleton(height: 16),
                  ),
                  error: (_, __) => const Text('—'),
                  data: (total) => Text(
                    '฿${total.toBaht()}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
                ),
              ),
            ),
          Expanded(
            child: Builder(builder: (context) {
              if (listState.isLoading && listState.items.isEmpty) {
                return const DashboardSkeleton();
              }
              if (listState.error != null && listState.items.isEmpty) {
                return ErrorStateView(
                  message: AppException.from(listState.error!).message,
                  onRetry: () => ref.read(expensesListControllerProvider.notifier).refresh(),
                );
              }
              if (listState.items.isEmpty) {
                return const EmptyStateView(
                  message: 'ยังไม่มีรายจ่ายตามเงื่อนไขนี้',
                  icon: Icons.receipt_long_outlined,
                );
              }
              return RefreshIndicator(
                onRefresh: () => ref.read(expensesListControllerProvider.notifier).refresh(),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                  itemCount: listState.items.length + (listState.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= listState.items.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final expense = listState.items[index];
                    return ExpenseTile(
                      expense: expense,
                      onTap: () => context.push('/expenses/edit/${expense.id}'),
                      onDelete: () => ref
                          .read(expensesListControllerProvider.notifier)
                          .deleteExpense(expense.id),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
