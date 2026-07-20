import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_tables.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/meal_models.dart';

class MealsRepository {
  final SupabaseClient _client = SupabaseService.client;
  final _random = Random();

  // ---------------- Templates ----------------

  Future<List<MealTemplateModel>> fetchTemplates({String? category}) async {
    try {
      var query = _client.from(SupabaseTables.mealTemplates).select().eq('is_active', true);
      if (category != null) {
        query = query.eq('category', category);
      }
      final rows = await query.order('name', ascending: true);
      return rows.map((r) => MealTemplateModel.fromMap(r)).toList();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<List<MealTemplateIngredientModel>> fetchTemplateIngredients(String templateId) async {
    try {
      final rows = await _client
          .from(SupabaseTables.mealTemplateIngredients)
          .select()
          .eq('meal_template_id', templateId);
      return rows.map((r) => MealTemplateIngredientModel.fromMap(r)).toList();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// สร้างรายการเมนู "ปลอดภัย" ที่ผ่านการกรองแพ้อาหาร/อุปกรณ์/งบ/ไม่ชอบแล้ว
  /// ใช้ร่วมกันทั้งระบบสุ่มเมนูแบบเดิม (fallback) และส่งเป็นบริบทให้ AI เลือกต่อ
  /// จำกัดจำนวนไว้ที่ [limit] เพื่อไม่ให้ Prompt ยาวเกินไปตอนส่งให้ AI
  Future<List<MealTemplateModel>> fetchSafeCandidates({
    required MealPreferenceModel preferences,
    double? maxPrice,
    int limit = 20,
  }) async {
    try {
      final templates = await fetchTemplates();
      final candidates = <MealTemplateModel>[];

      for (final t in templates) {
        if (maxPrice != null && t.estimatedPricePerServing > maxPrice) continue;
        if (preferences.availableEquipment.isNotEmpty &&
            t.requiredEquipment.isNotEmpty &&
            !t.requiredEquipment.every((e) => preferences.availableEquipment.contains(e))) {
          continue;
        }
        if (preferences.allergies.isNotEmpty) {
          final ingredients = await fetchTemplateIngredients(t.id);
          final hasAllergen = ingredients.any((ing) => preferences.allergies
              .any((a) => ing.ingredientName.toLowerCase().contains(a.toLowerCase())));
          if (hasAllergen) continue;
        }
        if (preferences.dislikedFoods.any((d) => t.name.toLowerCase().contains(d.toLowerCase()))) {
          continue;
        }
        candidates.add(t);
        if (candidates.length >= limit) break;
      }

      return candidates;
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// เลือกเมนูแบบสุ่มจากรายการที่ปลอดภัยแล้ว (ระบบสำรองเมื่อ AI ใช้งานไม่ได้)
  Future<MealTemplateModel?> suggestMeal({
    required MealPreferenceModel preferences,
    double? maxPrice,
  }) async {
    final candidates = await fetchSafeCandidates(preferences: preferences, maxPrice: maxPrice);
    if (candidates.isEmpty) return null;
    return candidates[_random.nextInt(candidates.length)];
  }

  // ---------------- Preferences ----------------

  Future<MealPreferenceModel?> fetchPreferences() async {
    try {
      final userId = SupabaseService.currentUserId;
      final row = await _client
          .from(SupabaseTables.mealPreferences)
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      return row == null ? null : MealPreferenceModel.fromMap(row);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<MealPreferenceModel> savePreferences({
    required int peopleCount,
    required int mealsPerDay,
    double? dailyFoodBudget,
    double? weeklyFoodBudget,
    double? monthlyFoodBudget,
    required String cookingStyle,
    required List<String> dislikedFoods,
    required List<String> allergies,
    required List<String> availableEquipment,
    int? availableCookMinutes,
    required String preferredDifficulty,
  }) async {
    try {
      final userId = SupabaseService.currentUserId;
      final row = await _client
          .from(SupabaseTables.mealPreferences)
          .upsert({
            'user_id': userId,
            'people_count': peopleCount,
            'meals_per_day': mealsPerDay,
            'daily_food_budget': dailyFoodBudget,
            'weekly_food_budget': weeklyFoodBudget,
            'monthly_food_budget': monthlyFoodBudget,
            'cooking_style': cookingStyle,
            'disliked_foods': dislikedFoods,
            'allergies': allergies,
            'available_equipment': availableEquipment,
            'available_cook_minutes': availableCookMinutes,
            'preferred_difficulty': preferredDifficulty,
          }, onConflict: 'user_id')
          .select()
          .single();
      return MealPreferenceModel.fromMap(row);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  // ---------------- Weekly plan (get-or-create) ----------------

  /// คืนแผน (สร้างใหม่ถ้ายังไม่มี) ของสัปดาห์ที่ครอบคลุมวันที่ระบุ (จันทร์-อาทิตย์)
  Future<MealPlanModel> fetchOrCreateWeeklyPlan(DateTime anyDateInWeek) async {
    try {
      final userId = SupabaseService.currentUserId;
      final monday = anyDateInWeek.subtract(Duration(days: anyDateInWeek.weekday - 1));
      final start = DateTime(monday.year, monday.month, monday.day);
      final end = start.add(const Duration(days: 6));

      final existing = await _client
          .from(SupabaseTables.mealPlans)
          .select()
          .eq('user_id', userId)
          .eq('plan_type', 'weekly')
          .eq('start_date', _dateOnly(start))
          .maybeSingle();

      if (existing != null) return MealPlanModel.fromMap(existing);

      final created = await _client
          .from(SupabaseTables.mealPlans)
          .insert({
            'user_id': userId,
            'plan_type': 'weekly',
            'start_date': _dateOnly(start),
            'end_date': _dateOnly(end),
          })
          .select()
          .single();
      return MealPlanModel.fromMap(created);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  // ---------------- Plan items ----------------

  Future<List<MealPlanItemModel>> fetchPlanItems(String mealPlanId) async {
    try {
      final userId = SupabaseService.currentUserId;
      final rows = await _client
          .from(SupabaseTables.mealPlanItems)
          .select()
          .eq('user_id', userId)
          .eq('meal_plan_id', mealPlanId)
          .order('meal_date', ascending: true);
      return rows.map((r) => MealPlanItemModel.fromMap(r)).toList();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<MealPlanItemModel> addItem({
    required String mealPlanId,
    String? mealTemplateId,
    required DateTime mealDate,
    required String mealType,
    required String name,
    required bool isHomemade,
    required int peopleCount,
    required double estimatedPrice,
    int? prepMinutes,
    String? difficulty,
    String? note,
  }) async {
    try {
      final userId = SupabaseService.currentUserId;
      final row = await _client
          .from(SupabaseTables.mealPlanItems)
          .insert({
            'user_id': userId,
            'meal_plan_id': mealPlanId,
            'meal_template_id': mealTemplateId,
            'meal_date': _dateOnly(mealDate),
            'meal_type': mealType,
            'custom_name': name,
            'is_homemade': isHomemade,
            'people_count': peopleCount,
            'estimated_price': estimatedPrice,
            'prep_minutes': prepMinutes,
            'difficulty': difficulty,
            'status': 'pending',
            'note': note,
          })
          .select()
          .single();
      return MealPlanItemModel.fromMap(row);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      final userId = SupabaseService.currentUserId;
      await _client
          .from(SupabaseTables.mealPlanItems)
          .delete()
          .eq('id', itemId)
          .eq('user_id', userId);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> setItemStatus({required String itemId, required bool done}) async {
    try {
      final userId = SupabaseService.currentUserId;
      await _client
          .from(SupabaseTables.mealPlanItems)
          .update({'status': done ? 'done' : 'pending'})
          .eq('id', itemId)
          .eq('user_id', userId);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> clearDay({required String mealPlanId, required DateTime date}) async {
    try {
      final userId = SupabaseService.currentUserId;
      await _client
          .from(SupabaseTables.mealPlanItems)
          .delete()
          .eq('user_id', userId)
          .eq('meal_plan_id', mealPlanId)
          .eq('meal_date', _dateOnly(date));
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// คัดลอกเมนูทั้งหมดจากวันหนึ่งไปอีกวันหนึ่ง (คนละแผนได้)
  Future<void> copyDay({
    required String fromPlanId,
    required DateTime fromDate,
    required String toPlanId,
    required DateTime toDate,
  }) async {
    try {
      final items = await fetchPlanItems(fromPlanId);
      final dayItems = items.where((i) => _isSameDate(i.mealDate, fromDate));
      for (final item in dayItems) {
        await addItem(
          mealPlanId: toPlanId,
          mealTemplateId: item.mealTemplateId,
          mealDate: toDate,
          mealType: item.mealType,
          name: item.name,
          isHomemade: item.isHomemade,
          peopleCount: item.peopleCount,
          estimatedPrice: item.estimatedPrice,
          prepMinutes: item.prepMinutes,
          difficulty: item.difficulty,
          note: item.note,
        );
      }
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// รายชื่อเมนูล่าสุดที่ทานไปในช่วง [daysBack] วันก่อนวันที่ระบุ (ใช้ให้ AI เลี่ยงเมนูซ้ำ)
  Future<List<String>> fetchRecentMealNames({
    required String mealPlanId,
    required DateTime beforeDate,
    int daysBack = 3,
  }) async {
    try {
      final items = await fetchPlanItems(mealPlanId);
      final cutoff = beforeDate.subtract(Duration(days: daysBack));
      return items
          .where((i) => i.mealDate.isAfter(cutoff) && i.mealDate.isBefore(beforeDate))
          .map((i) => i.name)
          .where((n) => n.isNotEmpty)
          .toSet()
          .toList();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _dateOnly(DateTime d) => d.toIso8601String().split('T').first;
}
