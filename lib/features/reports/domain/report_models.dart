class CategoryExpenseSlice {
  final String categoryName;
  final String categoryIcon;
  final double amount;

  const CategoryExpenseSlice({
    required this.categoryName,
    required this.categoryIcon,
    required this.amount,
  });
}

class WeeklyExpensePoint {
  final int weekIndex; // 1-based ภายในเดือน
  final double amount;

  const WeeklyExpensePoint({required this.weekIndex, required this.amount});
}

class DailyExpensePoint {
  final int day;
  final double amount;

  const DailyExpensePoint({required this.day, required this.amount});
}

class MonthlyReport {
  final int month;
  final int year;
  final double totalIncome;
  final double totalExpense;
  final double remaining;
  final double savings;
  final double foodCost;
  final int mealsPlannedCount;
  final int mealsDoneCount;
  final int shoppingItemsPurchased;
  final int ingredientsPurchasedCount;
  final int daysOverDailyFoodBudget;
  final List<CategoryExpenseSlice> expenseByCategory;
  final List<WeeklyExpensePoint> weeklyExpenses;
  final List<DailyExpensePoint> dailyExpenses;

  const MonthlyReport({
    required this.month,
    required this.year,
    required this.totalIncome,
    required this.totalExpense,
    required this.remaining,
    required this.savings,
    required this.foodCost,
    required this.mealsPlannedCount,
    required this.mealsDoneCount,
    required this.shoppingItemsPurchased,
    required this.ingredientsPurchasedCount,
    required this.daysOverDailyFoodBudget,
    required this.expenseByCategory,
    required this.weeklyExpenses,
    required this.dailyExpenses,
  });

  factory MonthlyReport.empty(int month, int year) => MonthlyReport(
        month: month,
        year: year,
        totalIncome: 0,
        totalExpense: 0,
        remaining: 0,
        savings: 0,
        foodCost: 0,
        mealsPlannedCount: 0,
        mealsDoneCount: 0,
        shoppingItemsPurchased: 0,
        ingredientsPurchasedCount: 0,
        daysOverDailyFoodBudget: 0,
        expenseByCategory: const [],
        weeklyExpenses: const [],
        dailyExpenses: const [],
      );
}
