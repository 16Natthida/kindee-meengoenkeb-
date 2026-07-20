import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_tables.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/supabase_service.dart';
import '../../ingredients/data/ingredients_repository.dart';
import '../../meals/data/meals_repository.dart';
import '../../meals/domain/meal_models.dart';
import '../domain/shopping_models.dart';

class ShoppingRepository {
  final SupabaseClient _client = SupabaseService.client;

  Future<List<ShoppingListModel>> fetchLists() async {
    try {
      final userId = SupabaseService.currentUserId;
      final rows = await _client
          .from(SupabaseTables.shoppingLists)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return rows.map((r) => ShoppingListModel.fromMap(r)).toList();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// คืนรายการล่าสุด ถ้ายังไม่มีให้สร้างใหม่ (ใช้เป็นรายการซื้อของ "หลัก" บนแอป)
  Future<ShoppingListModel> fetchOrCreateActiveList() async {
    try {
      final lists = await fetchLists();
      if (lists.isNotEmpty) return lists.first;

      final userId = SupabaseService.currentUserId;
      final row = await _client
          .from(SupabaseTables.shoppingLists)
          .insert({'user_id': userId, 'title': 'รายการซื้อของ'})
          .select()
          .single();
      return ShoppingListModel.fromMap(row);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<List<ShoppingListItemModel>> fetchItems(String shoppingListId) async {
    try {
      final userId = SupabaseService.currentUserId;
      final rows = await _client
          .from(SupabaseTables.shoppingListItems)
          .select()
          .eq('user_id', userId)
          .eq('shopping_list_id', shoppingListId)
          .order('is_purchased', ascending: true)
          .order('created_at', ascending: false);
      return rows.map((r) => ShoppingListItemModel.fromMap(r)).toList();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<ShoppingListItemModel> addItem({
    required String shoppingListId,
    required String productName,
    required double quantity,
    required String unit,
    double? estimatedPrice,
    String? category,
    String? storeName,
    DateTime? dueDate,
    String? note,
    bool linkedToMealPlan = false,
  }) async {
    try {
      final userId = SupabaseService.currentUserId;
      final row = await _client
          .from(SupabaseTables.shoppingListItems)
          .insert({
            'user_id': userId,
            'shopping_list_id': shoppingListId,
            'product_name': productName,
            'quantity': quantity,
            'unit': unit,
            'estimated_price': estimatedPrice,
            'category': category,
            'store_name': storeName,
            'due_date': dueDate?.toIso8601String().split('T').first,
            'note': note,
            'linked_to_meal_plan': linkedToMealPlan,
          })
          .select()
          .single();
      return ShoppingListItemModel.fromMap(row);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> updateItem({
    required String id,
    String? productName,
    double? quantity,
    String? unit,
    double? estimatedPrice,
    String? note,
  }) async {
    try {
      final userId = SupabaseService.currentUserId;
      final data = <String, dynamic>{};
      if (productName != null) data['product_name'] = productName;
      if (quantity != null) data['quantity'] = quantity;
      if (unit != null) data['unit'] = unit;
      if (estimatedPrice != null) data['estimated_price'] = estimatedPrice;
      if (note != null) data['note'] = note;
      if (data.isEmpty) return;

      await _client
          .from(SupabaseTables.shoppingListItems)
          .update(data)
          .eq('id', id)
          .eq('user_id', userId);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      final userId = SupabaseService.currentUserId;
      await _client
          .from(SupabaseTables.shoppingListItems)
          .delete()
          .eq('id', id)
          .eq('user_id', userId);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> deleteAllItems(String shoppingListId) async {
    try {
      await _client
          .from(SupabaseTables.shoppingListItems)
          .delete()
          .eq('shopping_list_id', shoppingListId)
          .eq('user_id', SupabaseService.currentUserId);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> setPurchased({required String id, required bool purchased, double? actualPrice}) async {
    try {
      final userId = SupabaseService.currentUserId;
      final data = <String, dynamic>{'is_purchased': purchased};
      if (actualPrice != null) data['actual_price'] = actualPrice;
      await _client
          .from(SupabaseTables.shoppingListItems)
          .update(data)
          .eq('id', id)
          .eq('user_id', userId);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> markAllPurchased(String shoppingListId) async {
    try {
      final userId = SupabaseService.currentUserId;
      await _client
          .from(SupabaseTables.shoppingListItems)
          .update({'is_purchased': true})
          .eq('user_id', userId)
          .eq('shopping_list_id', shoppingListId);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// เพิ่มวัตถุดิบของเมนู 1 รายการลงในรายการซื้อของ
  /// หักจำนวนที่มีอยู่แล้วในคลังวัตถุดิบก่อน (เพิ่มเฉพาะส่วนที่ขาด)
  Future<int> addIngredientsFromMealItem({
    required String shoppingListId,
    required MealPlanItemModel mealItem,
  }) async {
    if (mealItem.mealTemplateId == null) return 0;
    try {
      final mealsRepo = MealsRepository();
      final ingredientsRepo = IngredientsRepository();
      final templateIngredients = await mealsRepo.fetchTemplateIngredients(mealItem.mealTemplateId!);
      final stock = await ingredientsRepo.fetchAll();

      int addedCount = 0;
      for (final ing in templateIngredients) {
        final matchingStock = stock.where(
          (s) => s.name.toLowerCase().trim() == ing.ingredientName.toLowerCase().trim(),
        );
        final haveQty = matchingStock.isEmpty ? 0.0 : matchingStock.first.quantity;
        final neededQty = (ing.quantity * mealItem.peopleCount) - haveQty;
        if (neededQty <= 0) continue;

        await addItem(
          shoppingListId: shoppingListId,
          productName: ing.ingredientName,
          quantity: neededQty,
          unit: ing.unit,
          linkedToMealPlan: true,
        );
        addedCount++;
      }
      return addedCount;
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// สร้างรายการซื้อของจากเมนูทั้งหมดในสัปดาห์ (รวมวัตถุดิบที่ซ้ำกันเป็นรายการเดียว)
  Future<int> generateFromWeeklyPlan({
    required String shoppingListId,
    required List<MealPlanItemModel> weekItems,
  }) async {
    try {
      final mealsRepo = MealsRepository();
      final ingredientsRepo = IngredientsRepository();
      final stock = await ingredientsRepo.fetchAll();

      final Map<String, double> neededByIngredient = {};
      final Map<String, String> unitByIngredient = {};
      final Map<String, String> displayNameByIngredient = {};

      for (final item in weekItems) {
        if (item.mealTemplateId == null) continue;
        final ingredients = await mealsRepo.fetchTemplateIngredients(item.mealTemplateId!);
        for (final ing in ingredients) {
          final key = '${ing.ingredientName.toLowerCase().trim()}|${ing.unit}';
          neededByIngredient[key] =
              (neededByIngredient[key] ?? 0) + (ing.quantity * item.peopleCount);
          unitByIngredient[key] = ing.unit;
          displayNameByIngredient[key] = ing.ingredientName;
        }
      }

      int addedCount = 0;
      for (final entry in neededByIngredient.entries) {
        final name = displayNameByIngredient[entry.key]!;
        final normalizedName = entry.key.split('|').first;
        final unit = unitByIngredient[entry.key]!;
        final matchingStock =
            stock.where((s) => s.name.toLowerCase().trim() == normalizedName && s.unit == unit);
        final haveQty = matchingStock.isEmpty ? 0.0 : matchingStock.first.quantity;
        final neededQty = entry.value - haveQty;
        if (neededQty <= 0) continue;

        await addItem(
          shoppingListId: shoppingListId,
          productName: name,
          quantity: neededQty,
          unit: unit,
          linkedToMealPlan: true,
        );
        addedCount++;
      }
      return addedCount;
    } catch (e) {
      throw AppException.from(e);
    }
  }
}
