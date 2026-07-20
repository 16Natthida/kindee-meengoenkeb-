import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_tables.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/report_models.dart';

class ReportsRepository {
  final SupabaseClient _client = SupabaseService.client;

  Future<MonthlyReport> fetchMonthlyReport({required int month, required int year}) async {
    try {
      final userId = SupabaseService.currentUserId;
      final firstDay = DateTime(year, month, 1);
      final lastDay = DateTime(year, month + 1, 0);
      final daysInMonth = lastDay.day;

      // 1) รายรับ
      final incomeRow = await _client
          .from(SupabaseTables.monthlyIncomes)
          .select()
          .eq('user_id', userId)
          .eq('month', month)
          .eq('year', year)
          .maybeSingle();

      if (incomeRow == null) return MonthlyReport.empty(month, year);

      final salary = (incomeRow['salary'] as num).toDouble();
      final extraIncome = (incomeRow['extra_income'] as num).toDouble();
      final totalIncome = salary + extraIncome;
      final incomeId = incomeRow['id'] as String;

      // 2) งบประมาณของแต่ละหมวด (สำหรับหาเงินเก็บ + งบอาหารต่อวัน)
      final budgetRows = await _client
          .from(SupabaseTables.monthlyBudgets)
          .select('amount, budget_categories(name)')
          .eq('user_id', userId)
          .eq('income_id', incomeId);

      double savings = 0;
      double foodBudget = 0;
      for (final row in budgetRows) {
        final categoryMap = row['budget_categories'] as Map<String, dynamic>?;
        final name = categoryMap?['name'] as String?;
        final amount = (row['amount'] as num).toDouble();
        if (name == 'เงินเก็บ') savings = amount;
        if (name == 'ค่าอาหาร') foodBudget = amount;
      }
      final dailyFoodBudget = daysInMonth > 0 ? foodBudget / daysInMonth : 0;

      // 3) รายจ่ายทั้งเดือน พร้อมหมวด
      final expenseRows = await _client
          .from(SupabaseTables.expenses)
          .select('amount, expense_date, category_id, budget_categories(name, icon)')
          .eq('user_id', userId)
          .gte('expense_date', _dateOnly(firstDay))
          .lte('expense_date', _dateOnly(lastDay));

      double totalExpense = 0;
      double foodCost = 0;
      final Map<String, double> byCategory = {};
      final Map<String, String> categoryIcon = {};
      final Map<int, double> byDay = {};

      for (final row in expenseRows) {
        final amount = (row['amount'] as num).toDouble();
        totalExpense += amount;

        final categoryMap = row['budget_categories'] as Map<String, dynamic>?;
        final categoryName = categoryMap?['name'] as String? ?? 'ไม่ระบุหมวด';
        final icon = categoryMap?['icon'] as String? ?? 'category';
        byCategory[categoryName] = (byCategory[categoryName] ?? 0) + amount;
        categoryIcon[categoryName] = icon;
        if (categoryName == 'ค่าอาหาร') foodCost += amount;

        final date = DateTime.parse(row['expense_date'] as String);
        byDay[date.day] = (byDay[date.day] ?? 0) + amount;
      }

      final expenseByCategory = byCategory.entries
          .map((e) => CategoryExpenseSlice(
                categoryName: e.key,
                categoryIcon: categoryIcon[e.key] ?? 'category',
                amount: e.value,
              ))
          .toList()
        ..sort((a, b) => b.amount.compareTo(a.amount));

      final dailyExpenses = List.generate(daysInMonth, (i) {
        final day = i + 1;
        return DailyExpensePoint(day: day, amount: byDay[day] ?? 0);
      });

      // จัดกลุ่มเป็นรายสัปดาห์ (สัปดาห์ละ 7 วันจากวันที่ 1)
      final weeklyExpenses = <WeeklyExpensePoint>[];
      for (int start = 1; start <= daysInMonth; start += 7) {
        final end = (start + 6) > daysInMonth ? daysInMonth : start + 6;
        double sum = 0;
        for (int d = start; d <= end; d++) {
          sum += byDay[d] ?? 0;
        }
        weeklyExpenses.add(WeeklyExpensePoint(weekIndex: weeklyExpenses.length + 1, amount: sum));
      }

      final daysOverDailyFoodBudget = dailyFoodBudget > 0
          ? byDay.entries.where((e) => e.value > dailyFoodBudget).length
          : 0;

      // 4) เมนูอาหารที่วางแผน/ทำแล้วในเดือนนี้
      final mealItemRows = await _client
          .from(SupabaseTables.mealPlanItems)
          .select('status')
          .eq('user_id', userId)
          .gte('meal_date', _dateOnly(firstDay))
          .lte('meal_date', _dateOnly(lastDay));
      final mealsPlannedCount = mealItemRows.length;
      final mealsDoneCount = mealItemRows.where((r) => r['status'] == 'done').length;

      // 5) รายการซื้อของที่ซื้อแล้วในเดือนนี้ (อิงจาก created_at เป็นค่าประมาณ)
      final shoppingRows = await _client
          .from(SupabaseTables.shoppingListItems)
          .select('is_purchased, created_at')
          .eq('user_id', userId)
          .eq('is_purchased', true)
          .gte('created_at', firstDay.toIso8601String())
          .lte('created_at', lastDay.add(const Duration(days: 1)).toIso8601String());
      final shoppingItemsPurchased = shoppingRows.length;

      // 6) วัตถุดิบที่ซื้อในเดือนนี้ (ตาม purchase_date)
      final ingredientRows = await _client
          .from(SupabaseTables.ingredients)
          .select('id')
          .eq('user_id', userId)
          .gte('purchase_date', _dateOnly(firstDay))
          .lte('purchase_date', _dateOnly(lastDay));
      final ingredientsPurchasedCount = ingredientRows.length;

      return MonthlyReport(
        month: month,
        year: year,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        remaining: totalIncome - totalExpense,
        savings: savings,
        foodCost: foodCost,
        mealsPlannedCount: mealsPlannedCount,
        mealsDoneCount: mealsDoneCount,
        shoppingItemsPurchased: shoppingItemsPurchased,
        ingredientsPurchasedCount: ingredientsPurchasedCount,
        daysOverDailyFoodBudget: daysOverDailyFoodBudget,
        expenseByCategory: expenseByCategory,
        weeklyExpenses: weeklyExpenses,
        dailyExpenses: dailyExpenses,
      );
    } catch (e) {
      throw AppException.from(e);
    }
  }

  String _dateOnly(DateTime d) => d.toIso8601String().split('T').first;
}
