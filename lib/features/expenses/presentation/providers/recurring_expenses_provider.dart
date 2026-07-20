import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/expenses_repository.dart';
import '../../domain/recurring_expense_models.dart';
import 'expenses_provider.dart';

final recurringExpensesProvider = FutureProvider.autoDispose<List<RecurringExpenseModel>>((ref) async {
  return ref.watch(expensesRepositoryProvider).fetchRecurringExpenses();
});

final recurringExpenseSyncProvider = FutureProvider.autoDispose<int>((ref) async {
  final count = await ref.watch(expensesRepositoryProvider).createDueRecurringExpenses();
  if (count > 0) ref.invalidate(expensesListControllerProvider);
  return count;
});
