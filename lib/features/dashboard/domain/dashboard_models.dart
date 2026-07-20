class CategoryProgress {
  final String categoryId;
  final String name;
  final String icon;
  final double budgetAmount;
  final double spentAmount;

  const CategoryProgress({
    required this.categoryId,
    required this.name,
    required this.icon,
    required this.budgetAmount,
    required this.spentAmount,
  });

  double get remaining => budgetAmount - spentAmount;

  double get usedRatio => budgetAmount <= 0 ? 0 : (spentAmount / budgetAmount);
}

class RecentExpense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String? categoryName;

  const RecentExpense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.categoryName,
  });
}

class DashboardSummary {
  final int month;
  final int year;
  final double totalIncome;
  final double salary;
  final double extraIncome;
  final double totalExpense;
  final double remaining;
  final double savings;
  final double foodBudget;
  final double foodSpent;
  final int daysLeftInMonth;
  final List<CategoryProgress> categories;
  final List<RecentExpense> recentExpenses;

  const DashboardSummary({
    required this.month,
    required this.year,
    required this.totalIncome,
    required this.salary,
    required this.extraIncome,
    required this.totalExpense,
    required this.remaining,
    required this.savings,
    required this.foodBudget,
    required this.foodSpent,
    required this.daysLeftInMonth,
    required this.categories,
    required this.recentExpenses,
  });

  double get foodBudgetRemaining => foodBudget - foodSpent;

  /// จำนวนเงินค่าอาหารที่ใช้ได้ต่อวันจากงบที่เหลือ
  double get dailyFoodAllowance {
    if (daysLeftInMonth <= 0) return foodBudgetRemaining.clamp(0, double.infinity);
    final v = foodBudgetRemaining / daysLeftInMonth;
    return v < 0 ? 0 : v;
  }

  factory DashboardSummary.empty(int month, int year) => DashboardSummary(
        month: month,
        year: year,
        totalIncome: 0,
        salary: 0,
        extraIncome: 0,
        totalExpense: 0,
        remaining: 0,
        savings: 0,
        foodBudget: 0,
        foodSpent: 0,
        daysLeftInMonth: 0,
        categories: const [],
        recentExpenses: const [],
      );
}
