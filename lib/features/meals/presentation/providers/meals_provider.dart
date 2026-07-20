import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/ai_meal_suggestion_service.dart';
import '../../data/meals_repository.dart';
import '../../domain/meal_models.dart';

final mealsRepositoryProvider = Provider<MealsRepository>((ref) {
  return MealsRepository();
});

/// Service แยกต่างหากสำหรับคำแนะนำเมนูด้วย AI (ดู ai_meal_suggestion_service.dart)
final aiMealSuggestionServiceProvider = Provider<AiMealSuggestionService>((ref) {
  return AiMealSuggestionService();
});

/// วันที่กำลังเลือกดูอยู่บนหน้าแผนอาหาร (ค่าเริ่มต้น = วันนี้)
final selectedMealDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final mealPreferencesProvider =
    FutureProvider.autoDispose<MealPreferenceModel?>((ref) async {
  final repo = ref.watch(mealsRepositoryProvider);
  return repo.fetchPreferences();
});

final weeklyPlanProvider = FutureProvider.autoDispose<MealPlanModel>((ref) async {
  final selectedDate = ref.watch(selectedMealDateProvider);
  final repo = ref.watch(mealsRepositoryProvider);
  return repo.fetchOrCreateWeeklyPlan(selectedDate);
});

final weeklyPlanItemsProvider =
    FutureProvider.autoDispose<List<MealPlanItemModel>>((ref) async {
  final plan = await ref.watch(weeklyPlanProvider.future);
  final repo = ref.watch(mealsRepositoryProvider);
  return repo.fetchPlanItems(plan.id);
});

/// รายการเมนูเฉพาะวันที่เลือก (กรองจากรายการทั้งสัปดาห์)
final selectedDayItemsProvider =
    FutureProvider.autoDispose<List<MealPlanItemModel>>((ref) async {
  final selectedDate = ref.watch(selectedMealDateProvider);
  final items = await ref.watch(weeklyPlanItemsProvider.future);
  return items
      .where((i) =>
          i.mealDate.year == selectedDate.year &&
          i.mealDate.month == selectedDate.month &&
          i.mealDate.day == selectedDate.day)
      .toList();
});

final mealTemplatesProvider =
    FutureProvider.autoDispose.family<List<MealTemplateModel>, String?>((ref, category) async {
  final repo = ref.watch(mealsRepositoryProvider);
  return repo.fetchTemplates(category: category);
});
