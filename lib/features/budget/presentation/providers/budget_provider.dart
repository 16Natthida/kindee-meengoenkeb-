import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/budget_repository.dart';
import '../../domain/budget_models.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository();
});

/// เดือน/ปีที่กำลังแก้ไขแผนงบ (ค่าเริ่มต้น = เดือนปัจจุบัน)
final budgetPeriodProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

final categoriesProvider =
    FutureProvider.autoDispose<List<BudgetCategoryModel>>((ref) async {
  final repo = ref.watch(budgetRepositoryProvider);
  return repo.fetchCategories();
});

final currentIncomeProvider =
    FutureProvider.autoDispose<MonthlyIncomeModel?>((ref) async {
  final period = ref.watch(budgetPeriodProvider);
  final repo = ref.watch(budgetRepositoryProvider);
  return repo.fetchIncome(month: period.month, year: period.year);
});

/// รายการแผนงบของเดือนที่เลือก (ว่างถ้ายังไม่มีรายรับของเดือนนั้น)
final currentBudgetsProvider =
    FutureProvider.autoDispose<List<MonthlyBudgetModel>>((ref) async {
  final income = await ref.watch(currentIncomeProvider.future);
  if (income == null) return [];
  final repo = ref.watch(budgetRepositoryProvider);
  return repo.fetchBudgets(incomeId: income.id);
});
