import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/supabase_tables.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/notification_models.dart';

class NotificationsRepository {
  final SupabaseClient _client = SupabaseService.client;

  Future<List<AppNotificationModel>> fetchNotifications() async {
    try {
      final userId = SupabaseService.currentUserId;
      final rows = await _client
          .from(SupabaseTables.notifications)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(100);
      return rows.map((r) => AppNotificationModel.fromMap(r)).toList();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<int> fetchUnreadCount() async {
    try {
      final userId = SupabaseService.currentUserId;
      final rows = await _client
          .from(SupabaseTables.notifications)
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false);
      return rows.length;
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> markRead(String id) async {
    try {
      final userId = SupabaseService.currentUserId;
      await _client
          .from(SupabaseTables.notifications)
          .update({'is_read': true})
          .eq('id', id)
          .eq('user_id', userId);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> markAllRead() async {
    try {
      final userId = SupabaseService.currentUserId;
      await _client
          .from(SupabaseTables.notifications)
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> delete(String id) async {
    try {
      final userId = SupabaseService.currentUserId;
      await _client.from(SupabaseTables.notifications).delete().eq('id', id).eq('user_id', userId);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> _createIfNotExistsToday({
    required String title,
    required String detail,
    required NotificationType type,
    String? referenceId,
  }) async {
    final userId = SupabaseService.currentUserId;
    final todayStart = DateTime.now().toUtc();
    final since = DateTime(todayStart.year, todayStart.month, todayStart.day).toIso8601String();

    var query = _client
        .from(SupabaseTables.notifications)
        .select('id')
        .eq('user_id', userId)
        .eq('type', type.dbValue)
        .gte('created_at', since);

    if (referenceId != null) {
      query = query.eq('reference_id', referenceId);
    }

    final existing = await query.limit(1);
    if (existing.isNotEmpty) return;

    await _client.from(SupabaseTables.notifications).insert({
      'user_id': userId,
      'title': title,
      'detail': detail,
      'type': type.dbValue,
      'reference_id': referenceId,
    });
  }

  /// อ่านการตั้งค่าแจ้งเตือนของผู้ใช้ (จากหน้า "ตั้งค่า") — ถ้ายังไม่มีแถวให้ถือว่าเปิดทั้งหมด (ค่าเริ่มต้น)
  Future<({bool notifyBudgetLow, bool notifyExpiry})> _fetchNotificationPreferences(
    String userId,
  ) async {
    final row = await _client
        .from(SupabaseTables.userSettings)
        .select('notify_budget_low, notify_expiry')
        .eq('user_id', userId)
        .maybeSingle();

    if (row == null) return (notifyBudgetLow: true, notifyExpiry: true);
    return (
      notifyBudgetLow: row['notify_budget_low'] as bool? ?? true,
      notifyExpiry: row['notify_expiry'] as bool? ?? true,
    );
  }

  /// ตรวจสอบเงื่อนไขทั้งหมดของแอปและสร้างการแจ้งเตือนใหม่ (ข้ามถ้าสร้างไปแล้ววันนี้)
  /// เรียกจากหน้าการแจ้งเตือนตอนเปิด และตอน Pull-to-refresh บน Dashboard
  Future<void> checkAndGenerateNotifications() async {
    try {
      final userId = SupabaseService.currentUserId;
      final now = DateTime.now();
      final prefs = await _fetchNotificationPreferences(userId);

      final tasks = <Future<void>>[];
      if (prefs.notifyBudgetLow) {
        tasks.add(_checkBudgetStatus(userId, now));
        tasks.add(_checkFoodBudget(userId, now));
      }
      if (prefs.notifyExpiry) {
        tasks.add(_checkIngredients(userId));
      }
      // เงื่อนไขที่ไม่ผูกกับ toggle ในหน้าตั้งค่า (เกี่ยวกับแผนอาหาร/ซื้อของ/พฤติกรรมใช้จ่าย) ทำงานเสมอ
      tasks.add(_checkMealPlan(userId, now));
      tasks.add(_checkShoppingList(userId));
      tasks.add(_checkExpenseAboveAverage(userId, now));

      await Future.wait(tasks);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> _checkBudgetStatus(String userId, DateTime now) async {
    final incomeRow = await _client
        .from(SupabaseTables.monthlyIncomes)
        .select('id, salary, extra_income')
        .eq('user_id', userId)
        .eq('month', now.month)
        .eq('year', now.year)
        .maybeSingle();
    if (incomeRow == null) return;
    final incomeId = incomeRow['id'] as String;

    final budgetRows = await _client
        .from(SupabaseTables.monthlyBudgets)
        .select('id, amount, category_id, budget_categories(name)')
        .eq('user_id', userId)
        .eq('income_id', incomeId);

    final firstDay = DateTime(now.year, now.month, 1);
    final expenseRows = await _client
        .from(SupabaseTables.expenses)
        .select('amount, category_id')
        .eq('user_id', userId)
        .gte('expense_date', firstDay.toIso8601String().split('T').first);

    final Map<String, double> spentByCategory = {};
    for (final row in expenseRows) {
      final catId = row['category_id'] as String?;
      if (catId == null) continue;
      spentByCategory[catId] = (spentByCategory[catId] ?? 0) + (row['amount'] as num).toDouble();
    }

    for (final row in budgetRows) {
      final categoryMap = row['budget_categories'] as Map<String, dynamic>?;
      final categoryName = categoryMap?['name'] as String? ?? 'หมวด';
      final categoryId = row['category_id'] as String;
      final budgetAmount = (row['amount'] as num).toDouble();
      if (budgetAmount <= 0) continue;
      final spent = spentByCategory[categoryId] ?? 0;
      final ratio = spent / budgetAmount;

      if (ratio > 1.0) {
        await _createIfNotExistsToday(
          title: 'ใช้เงินเกินงบ',
          detail: 'หมวด "$categoryName" ใช้ไปแล้ว ฿${spent.toStringAsFixed(0)} เกินงบที่ตั้งไว้ ฿${budgetAmount.toStringAsFixed(0)}',
          type: NotificationType.overBudget,
          referenceId: categoryId,
        );
      } else if (ratio >= AppConstants.budgetWarningMax) {
        await _createIfNotExistsToday(
          title: 'งบเหลือน้อย',
          detail: 'หมวด "$categoryName" ใช้ไปแล้ว ${(ratio * 100).toStringAsFixed(0)}% ของงบที่ตั้งไว้',
          type: NotificationType.budgetLow,
          referenceId: categoryId,
        );
      }
    }
  }

  Future<void> _checkFoodBudget(String userId, DateTime now) async {
    final incomeRow = await _client
        .from(SupabaseTables.monthlyIncomes)
        .select('id')
        .eq('user_id', userId)
        .eq('month', now.month)
        .eq('year', now.year)
        .maybeSingle();
    if (incomeRow == null) return;
    final incomeId = incomeRow['id'] as String;

    final foodBudgetRow = await _client
        .from(SupabaseTables.monthlyBudgets)
        .select('amount, category_id, budget_categories!inner(name)')
        .eq('user_id', userId)
        .eq('income_id', incomeId)
        .eq('budget_categories.name', 'ค่าอาหาร')
        .maybeSingle();
    if (foodBudgetRow == null) return;

    final foodBudget = (foodBudgetRow['amount'] as num).toDouble();
    if (foodBudget <= 0) return;
    final categoryId = foodBudgetRow['category_id'] as String;

    final firstDay = DateTime(now.year, now.month, 1);
    final expenseRows = await _client
        .from(SupabaseTables.expenses)
        .select('amount')
        .eq('user_id', userId)
        .eq('category_id', categoryId)
        .gte('expense_date', firstDay.toIso8601String().split('T').first);

    double spent = 0;
    for (final row in expenseRows) {
      spent += (row['amount'] as num).toDouble();
    }

    final remaining = foodBudget - spent;
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = daysInMonth - now.day + 1;
    if (daysLeft <= 0) return;
    final dailyAllowance = remaining / daysLeft;

    if (remaining < foodBudget * 0.1 && remaining >= 0) {
      await _createIfNotExistsToday(
        title: 'งบค่าอาหารเหลือน้อย',
        detail: 'งบค่าอาหารเหลือ ฿${remaining.toStringAsFixed(0)} และเหลืออีก $daysLeft วัน '
            'คุณควรใช้ไม่เกินวันละ ฿${dailyAllowance.clamp(0, double.infinity).toStringAsFixed(2)}',
        type: NotificationType.foodBudgetLow,
        referenceId: categoryId,
      );
    }
  }

  Future<void> _checkIngredients(String userId) async {
    final rows = await _client
        .from(SupabaseTables.ingredients)
        .select('id, name, quantity, minimum_quantity, expiry_date')
        .eq('user_id', userId);

    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);

    for (final row in rows) {
      final id = row['id'] as String;
      final name = row['name'] as String;
      final quantity = (row['quantity'] as num).toDouble();
      final minQuantity = (row['minimum_quantity'] as num?)?.toDouble() ?? 0;
      final expiryStr = row['expiry_date'] as String?;

      if (expiryStr != null) {
        final expiry = DateTime.parse(expiryStr);
        final expiryDateOnly = DateTime(expiry.year, expiry.month, expiry.day);
        if (expiryDateOnly.isBefore(todayDateOnly)) {
          await _createIfNotExistsToday(
            title: 'วัตถุดิบหมดอายุแล้ว',
            detail: '"$name" หมดอายุไปแล้ว กรุณาตรวจสอบและนำออกจากคลัง',
            type: NotificationType.ingredientExpired,
            referenceId: id,
          );
          continue;
        }
        if (expiryDateOnly.difference(todayDateOnly).inDays <= 3) {
          await _createIfNotExistsToday(
            title: 'วัตถุดิบใกล้หมดอายุ',
            detail: '"$name" จะหมดอายุในอีก ${expiryDateOnly.difference(todayDateOnly).inDays} วัน',
            type: NotificationType.ingredientExpiring,
            referenceId: id,
          );
        }
      }

      if (quantity > 0 && quantity <= minQuantity) {
        await _createIfNotExistsToday(
          title: 'วัตถุดิบใกล้หมด',
          detail: '"$name" เหลือน้อยกว่าที่ควรมี กรุณาเพิ่มลงรายการซื้อของ',
          type: NotificationType.ingredientLow,
          referenceId: id,
        );
      }
    }
  }

  Future<void> _checkMealPlan(String userId, DateTime now) async {
    final today = DateTime(now.year, now.month, now.day);
    final rows = await _client
        .from(SupabaseTables.mealPlanItems)
        .select('id')
        .eq('user_id', userId)
        .eq('meal_date', today.toIso8601String().split('T').first)
        .limit(1);

    if (rows.isEmpty) {
      await _createIfNotExistsToday(
        title: 'ยังไม่ได้วางแผนอาหารวันนี้',
        detail: 'วันนี้ยังไม่มีเมนูอาหารในแผน ลองวางแผนหรือสุ่มเมนูดูสิ',
        type: NotificationType.noMealPlan,
        referenceId: today.toIso8601String().split('T').first,
      );
    }
  }

  Future<void> _checkShoppingList(String userId) async {
    final rows = await _client
        .from(SupabaseTables.shoppingListItems)
        .select('id')
        .eq('user_id', userId)
        .eq('is_purchased', false);

    if (rows.isNotEmpty) {
      await _createIfNotExistsToday(
        title: 'รายการซื้อของยังไม่ครบ',
        detail: 'มีรายการซื้อของที่ยังไม่ได้ซื้ออีก ${rows.length} รายการ',
        type: NotificationType.shoppingIncomplete,
      );
    }
  }

  Future<void> _checkExpenseAboveAverage(String userId, DateTime now) async {
    final firstDay = DateTime(now.year, now.month, 1);
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (yesterday.isBefore(firstDay)) return;

    final monthRows = await _client
        .from(SupabaseTables.expenses)
        .select('amount, expense_date')
        .eq('user_id', userId)
        .gte('expense_date', firstDay.toIso8601String().split('T').first)
        .lt('expense_date', today.toIso8601String().split('T').first);

    if (monthRows.isEmpty) return;

    final Map<String, double> byDay = {};
    for (final row in monthRows) {
      final date = row['expense_date'] as String;
      byDay[date] = (byDay[date] ?? 0) + (row['amount'] as num).toDouble();
    }
    if (byDay.isEmpty) return;

    final average = byDay.values.reduce((a, b) => a + b) / byDay.length;
    final todayRows = await _client
        .from(SupabaseTables.expenses)
        .select('amount')
        .eq('user_id', userId)
        .eq('expense_date', today.toIso8601String().split('T').first);

    double todayTotal = 0;
    for (final row in todayRows) {
      todayTotal += (row['amount'] as num).toDouble();
    }

    if (todayTotal > average * 1.5 && todayTotal > 0) {
      await _createIfNotExistsToday(
        title: 'รายจ่ายวันนี้สูงกว่าค่าเฉลี่ย',
        detail: 'วันนี้ใช้จ่ายไป ฿${todayTotal.toStringAsFixed(0)} '
            'สูงกว่าค่าเฉลี่ยต่อวัน (฿${average.toStringAsFixed(0)}) ของเดือนนี้',
        type: NotificationType.expenseAboveAverage,
      );
    }
  }
}
