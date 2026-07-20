import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_tables.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/budget_models.dart';

class BudgetRepository {
  final SupabaseClient _client = SupabaseService.client;

  // ---------------- Categories ----------------

  Future<List<BudgetCategoryModel>> fetchCategories({bool includeHidden = false}) async {
    try {
      final userId = SupabaseService.currentUserId;
      var query = _client
          .from(SupabaseTables.budgetCategories)
          .select()
          .eq('user_id', userId);
      if (!includeHidden) {
        query = query.eq('is_hidden', false);
      }
      final rows = await query.order('sort_order', ascending: true);
      return rows.map((r) => BudgetCategoryModel.fromMap(r)).toList();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<BudgetCategoryModel> createCategory({
    required String name,
    required String icon,
  }) async {
    try {
      final userId = SupabaseService.currentUserId;
      final row = await _client
          .from(SupabaseTables.budgetCategories)
          .insert({
            'user_id': userId,
            'name': name,
            'icon': icon,
            'is_default': false,
            'sort_order': 999,
          })
          .select()
          .single();
      return BudgetCategoryModel.fromMap(row);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> updateCategory({
    required String categoryId,
    String? name,
    String? icon,
    bool? isHidden,
  }) async {
    try {
      final userId = SupabaseService.currentUserId;
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (icon != null) data['icon'] = icon;
      if (isHidden != null) data['is_hidden'] = isHidden;
      if (data.isEmpty) return;

      await _client
          .from(SupabaseTables.budgetCategories)
          .update(data)
          .eq('id', categoryId)
          .eq('user_id', userId);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  // ---------------- Monthly income ----------------

  Future<MonthlyIncomeModel?> fetchIncome({required int month, required int year}) async {
    try {
      final userId = SupabaseService.currentUserId;
      final row = await _client
          .from(SupabaseTables.monthlyIncomes)
          .select()
          .eq('user_id', userId)
          .eq('month', month)
          .eq('year', year)
          .maybeSingle();
      return row == null ? null : MonthlyIncomeModel.fromMap(row);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// upsert ตาม unique(user_id, month, year)
  Future<MonthlyIncomeModel> saveIncome({
    required int month,
    required int year,
    required double salary,
    required double extraIncome,
    DateTime? incomeDate,
    String? note,
  }) async {
    try {
      final userId = SupabaseService.currentUserId;
      final row = await _client
          .from(SupabaseTables.monthlyIncomes)
          .upsert({
            'user_id': userId,
            'month': month,
            'year': year,
            'salary': salary,
            'extra_income': extraIncome,
            'income_date': incomeDate?.toIso8601String().split('T').first,
            'note': note,
          }, onConflict: 'user_id,month,year')
          .select()
          .single();
      return MonthlyIncomeModel.fromMap(row);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  // ---------------- Monthly budgets (allocation) ----------------

  Future<List<MonthlyBudgetModel>> fetchBudgets({required String incomeId}) async {
    try {
      final userId = SupabaseService.currentUserId;
      final rows = await _client
          .from(SupabaseTables.monthlyBudgets)
          .select()
          .eq('user_id', userId)
          .eq('income_id', incomeId);
      return rows.map((r) => MonthlyBudgetModel.fromMap(r)).toList();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// บันทึกแผนงบทั้งชุดของเดือนนั้น (upsert ทีละหมวดตาม unique(income_id, category_id))
  /// ไม่ลบแถวเดิมที่ไม่ได้อยู่ใน draft เพื่อไม่ให้กระทบรายจ่ายที่ผูกอยู่แล้วตามสเปก
  Future<void> saveBudgetAllocation({
    required String incomeId,
    required List<BudgetDraftRow> rows,
    required String allocationType,
  }) async {
    try {
      final userId = SupabaseService.currentUserId;
      final payload = rows
          .map((r) => {
                'user_id': userId,
                'income_id': incomeId,
                'category_id': r.category.id,
                'allocation_type': allocationType,
                'percentage': allocationType == 'percentage' ? r.percentage : null,
                'amount': r.amount,
              })
          .toList();

      if (payload.isEmpty) return;

      await _client
          .from(SupabaseTables.monthlyBudgets)
          .upsert(payload, onConflict: 'income_id,category_id');
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// คัดลอกแผนงบจากเดือนก่อนหน้ามาเป็น draft ของเดือนปัจจุบัน (ยังไม่บันทึก)
  Future<List<MonthlyBudgetModel>> fetchPreviousMonthBudgets({
    required int month,
    required int year,
  }) async {
    try {
      final prevMonth = month == 1 ? 12 : month - 1;
      final prevYear = month == 1 ? year - 1 : year;
      final prevIncome = await fetchIncome(month: prevMonth, year: prevYear);
      if (prevIncome == null) return [];
      return fetchBudgets(incomeId: prevIncome.id);
    } catch (e) {
      throw AppException.from(e);
    }
  }
}
