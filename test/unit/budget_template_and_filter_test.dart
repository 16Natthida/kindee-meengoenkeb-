import 'package:flutter_test/flutter_test.dart';
import 'package:kindee_meengoenkeb/features/budget/domain/budget_models.dart';
import 'package:kindee_meengoenkeb/features/expenses/domain/expense_models.dart';

void main() {
  group('BudgetTemplate', () {
    test('every template (except custom) sums to 100%', () {
      for (final t in BudgetTemplate.values) {
        if (t == BudgetTemplate.custom) continue;
        final total = t.percentagesByCategoryName.values.fold(0.0, (a, b) => a + b);
        expect(total, 100, reason: '${t.label} ต้องรวมเป็น 100%');
      }
    });
  });

  group('BudgetDraftRow', () {
    test('percentage-based amount calculation', () {
      const category = BudgetCategoryModel(
        id: '1',
        userId: 'u1',
        name: 'ค่าอาหาร',
        icon: 'restaurant',
        isDefault: true,
        isHidden: false,
        sortOrder: 2,
      );
      final row = BudgetDraftRow(category: category, percentage: 20);
      const totalIncome = 25000.0;
      row.amount = totalIncome * row.percentage / 100;
      expect(row.amount, 5000);
    });
  });

  group('ExpenseFilter', () {
    test('isActive is false when nothing is set', () {
      const filter = ExpenseFilter();
      expect(filter.isActive, isFalse);
    });

    test('isActive is true when searchText is set', () {
      const filter = ExpenseFilter(searchText: 'ข้าว');
      expect(filter.isActive, isTrue);
    });

    test('copyWith clears fields when clear flags are used', () {
      final base = ExpenseFilter(categoryId: 'cat-1', fromDate: DateTime(2026, 7, 1));
      final cleared = base.copyWith(clearCategory: true, clearFromDate: true);
      expect(cleared.categoryId, isNull);
      expect(cleared.fromDate, isNull);
    });
  });
}
