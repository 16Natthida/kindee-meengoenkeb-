import 'package:flutter_test/flutter_test.dart';
import 'package:kindee_meengoenkeb/core/widgets/budget_status_badge.dart';
import 'package:kindee_meengoenkeb/features/dashboard/domain/dashboard_models.dart';

void main() {
  group('CategoryProgress', () {
    test('usedRatio calculates correctly', () {
      const c = CategoryProgress(
        categoryId: '1',
        name: 'ค่าอาหาร',
        icon: 'restaurant',
        budgetAmount: 5000,
        spentAmount: 2000,
      );
      expect(c.usedRatio, 0.4);
      expect(c.remaining, 3000);
    });

    test('usedRatio is 0 when budget is 0 (avoid divide by zero)', () {
      const c = CategoryProgress(
        categoryId: '1',
        name: 'อื่น ๆ',
        icon: 'category',
        budgetAmount: 0,
        spentAmount: 100,
      );
      expect(c.usedRatio, 0);
    });
  });

  group('budgetStatusFromRatio', () {
    test('below 70% is normal', () {
      expect(budgetStatusFromRatio(0.5), BudgetStatus.normal);
    });
    test('70-89% is near', () {
      expect(budgetStatusFromRatio(0.75), BudgetStatus.near);
    });
    test('90-100% is warning', () {
      expect(budgetStatusFromRatio(0.95), BudgetStatus.warning);
    });
    test('over 100% is over', () {
      expect(budgetStatusFromRatio(1.2), BudgetStatus.over);
    });
  });

  group('DashboardSummary - example from spec', () {
    test('เงินเดือน 25,000 งบอาหาร 5,000 ใช้ไป 2,000 เหลือ 15 วัน -> ~200/วัน', () {
      const summary = DashboardSummary(
        month: 1,
        year: 2026,
        totalIncome: 25000,
        salary: 25000,
        extraIncome: 0,
        totalExpense: 2000,
        remaining: 23000,
        savings: 0,
        foodBudget: 5000,
        foodSpent: 2000,
        daysLeftInMonth: 15,
        categories: [],
        recentExpenses: [],
      );

      expect(summary.foodBudgetRemaining, 3000);
      expect(summary.dailyFoodAllowance, closeTo(200, 0.01));
    });

    test('dailyFoodAllowance never negative when over budget', () {
      const summary = DashboardSummary(
        month: 1,
        year: 2026,
        totalIncome: 25000,
        salary: 25000,
        extraIncome: 0,
        totalExpense: 6000,
        remaining: 19000,
        savings: 0,
        foodBudget: 5000,
        foodSpent: 6000,
        daysLeftInMonth: 10,
        categories: [],
        recentExpenses: [],
      );

      expect(summary.dailyFoodAllowance, 0);
    });
  });
}
