import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_tables.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/dashboard_models.dart';

class DashboardRepository {
  final SupabaseClient _client = SupabaseService.client;

  Future<DashboardSummary> fetchMonthlySummary({
    required int month,
    required int year,
  }) async {
    try {
      final userId = SupabaseService.currentUserId;

      // 1) รายรับของเดือนนี้
      final incomeRow = await _client
          .from(SupabaseTables.monthlyIncomes)
          .select()
          .eq('user_id', userId)
          .eq('month', month)
          .eq('year', year)
          .maybeSingle();

      if (incomeRow == null) {
        return DashboardSummary.empty(month, year);
      }

      final salary = (incomeRow['salary'] as num).toDouble();
      final extraIncome = (incomeRow['extra_income'] as num).toDouble();
      final incomeId = incomeRow['id'] as String;

      // 2) แผนงบประมาณของแต่ละหมวด พร้อมชื่อ/ไอคอนหมวด (join)
      final budgetRows = await _client
          .from(SupabaseTables.monthlyBudgets)
          .select('id, amount, category_id, budget_categories(id, name, icon)')
          .eq('user_id', userId)
          .eq('income_id', incomeId);

      // 3) รายจ่ายทั้งหมดของเดือนนี้
      final firstDay = DateTime(year, month, 1);
      final lastDay = DateTime(year, month + 1, 0);
      final expenseRows = await _client
          .from(SupabaseTables.expenses)
          .select('id, title, amount, category_id, expense_date')
          .eq('user_id', userId)
          .gte('expense_date', firstDay.toIso8601String().split('T').first)
          .lte('expense_date', lastDay.toIso8601String().split('T').first)
          .order('expense_date', ascending: false)
          .order('created_at', ascending: false);

      // สร้าง map ยอดใช้จ่ายต่อหมวด
      final Map<String, double> spentByCategory = {};
      double totalExpense = 0;
      for (final row in expenseRows) {
        final amount = (row['amount'] as num).toDouble();
        totalExpense += amount;
        final catId = row['category_id'] as String?;
        if (catId != null) {
          spentByCategory[catId] = (spentByCategory[catId] ?? 0) + amount;
        }
      }

      final categories = <CategoryProgress>[];
      double foodBudget = 0;
      double foodSpent = 0;

      for (final row in budgetRows) {
        final categoryMap = row['budget_categories'] as Map<String, dynamic>?;
        if (categoryMap == null) continue;
        final categoryId = categoryMap['id'] as String;
        final name = categoryMap['name'] as String;
        final icon = categoryMap['icon'] as String? ?? 'category';
        final budgetAmount = (row['amount'] as num).toDouble();
        final spent = spentByCategory[categoryId] ?? 0;

        categories.add(CategoryProgress(
          categoryId: categoryId,
          name: name,
          icon: icon,
          budgetAmount: budgetAmount,
          spentAmount: spent,
        ));

        if (name == 'ค่าอาหาร') {
          foodBudget = budgetAmount;
          foodSpent = spent;
        }
      }

      // รายจ่ายล่าสุด 5 รายการ พร้อมชื่อหมวด
      final categoryNameById = {
        for (final c in categories) c.categoryId: c.name,
      };
      final recentExpenses = expenseRows.take(5).map((row) {
        return RecentExpense(
          id: row['id'] as String,
          title: row['title'] as String,
          amount: (row['amount'] as num).toDouble(),
          date: DateTime.parse(row['expense_date'] as String),
          categoryName: categoryNameById[row['category_id'] as String?],
        );
      }).toList();

      final totalIncome = salary + extraIncome;
      final remaining = totalIncome - totalExpense;

      final savingsCategory = categories.where((c) => c.name == 'เงินเก็บ');
      final savings = savingsCategory.isEmpty ? 0.0 : savingsCategory.first.budgetAmount;

      final now = DateTime.now();
      final isCurrentMonth = now.year == year && now.month == month;
      final daysInMonth = DateTime(year, month + 1, 0).day;
      final daysLeft = isCurrentMonth ? (daysInMonth - now.day + 1) : daysInMonth;

      return DashboardSummary(
        month: month,
        year: year,
        totalIncome: totalIncome,
        salary: salary,
        extraIncome: extraIncome,
        totalExpense: totalExpense,
        remaining: remaining,
        savings: savings,
        foodBudget: foodBudget,
        foodSpent: foodSpent,
        daysLeftInMonth: daysLeft,
        categories: categories,
        recentExpenses: recentExpenses,
      );
    } catch (e) {
      throw AppException.from(e);
    }
  }
}
