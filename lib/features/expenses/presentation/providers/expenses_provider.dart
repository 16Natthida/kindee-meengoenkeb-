import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/expenses_repository.dart';
import '../../domain/expense_models.dart';

final expensesRepositoryProvider = Provider<ExpensesRepository>((ref) {
  return ExpensesRepository();
});

final expenseFilterProvider = StateProvider<ExpenseFilter>((ref) {
  return const ExpenseFilter();
});

final filteredExpenseTotalProvider = FutureProvider.autoDispose<double>((ref) async {
  final filter = ref.watch(expenseFilterProvider);
  final repo = ref.watch(expensesRepositoryProvider);
  return repo.fetchFilteredTotal(filter: filter);
});

class ExpensesListState {
  final List<ExpenseModel> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final Object? error;

  const ExpensesListState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  ExpensesListState copyWith({
    List<ExpenseModel>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    Object? error,
    bool clearError = false,
  }) {
    return ExpensesListState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ExpensesListController extends StateNotifier<ExpensesListState> {
  final ExpensesRepository _repo;
  final Ref _ref;
  int _page = 0;

  ExpensesListController(this._repo, this._ref) : super(const ExpensesListState()) {
    refresh();
  }

  ExpenseFilter get _filter => _ref.read(expenseFilterProvider);

  Future<void> refresh() async {
    _page = 0;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _repo.fetchExpenses(filter: _filter, page: _page);
      state = state.copyWith(
        items: items,
        isLoading: false,
        hasMore: items.length == expensePageSize,
      );
      _ref.invalidate(filteredExpenseTotalProvider);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: AppException.from(e));
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      _page += 1;
      final items = await _repo.fetchExpenses(filter: _filter, page: _page);
      state = state.copyWith(
        items: [...state.items, ...items],
        isLoadingMore: false,
        hasMore: items.length == expensePageSize,
      );
    } catch (e) {
      _page -= 1;
      state = state.copyWith(isLoadingMore: false, error: AppException.from(e));
    }
  }

  Future<void> deleteExpense(String id) async {
    final previous = state.items;
    state = state.copyWith(items: previous.where((e) => e.id != id).toList());
    try {
      await _repo.deleteExpense(id);
      _ref.invalidate(filteredExpenseTotalProvider);
    } catch (e) {
      // คืนค่ารายการเดิมถ้าลบไม่สำเร็จ
      state = state.copyWith(items: previous, error: AppException.from(e));
    }
  }
}

final expensesListControllerProvider =
    StateNotifierProvider.autoDispose<ExpensesListController, ExpensesListState>((ref) {
  // rebuild ใหม่ทุกครั้งที่ filter เปลี่ยน
  ref.watch(expenseFilterProvider);
  final repo = ref.watch(expensesRepositoryProvider);
  return ExpensesListController(repo, ref);
});
