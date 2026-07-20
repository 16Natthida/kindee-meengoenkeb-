import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/ai_suggestion_model.dart';
import '../domain/meal_models.dart';

/// Service เรียก AI (Claude) ผ่าน Supabase Edge Function `suggest-meal`
/// แยกออกจาก MealsRepository ตามที่สเปกกำหนดไว้ตั้งแต่ Part 1:
/// "ให้ออกแบบ Service แยกไว้สำหรับเพิ่ม AI Recommendation ในอนาคต"
///
/// Service นี้ไม่เก็บ API Key ใด ๆ ไว้ในแอป — Edge Function เป็นคนเรียก Claude API จริง
class AiMealSuggestionService {
  final SupabaseClient _client = SupabaseService.client;

  Future<AiMealSuggestion> suggestMeal({
    required String mealType,
    required int peopleCount,
    double? maxPrice,
    required List<String> allergies,
    required List<String> dislikedFoods,
    required List<String> availableEquipment,
    required String preferredDifficulty,
    required List<String> nearExpiryIngredients,
    required List<String> stockIngredients,
    required List<String> recentMealNames,
    required List<MealTemplateModel> candidateTemplates,
    required Map<String, List<String>> candidateTemplateIngredients,
  }) async {
    try {
      final payload = {
        'mealType': mealType,
        'peopleCount': peopleCount,
        'maxPrice': maxPrice,
        'allergies': allergies,
        'dislikedFoods': dislikedFoods,
        'availableEquipment': availableEquipment,
        'preferredDifficulty': preferredDifficulty,
        'nearExpiryIngredients': nearExpiryIngredients,
        'stockIngredients': stockIngredients,
        'recentMealNames': recentMealNames,
        'candidateTemplates': candidateTemplates
            .map((t) => {
                  'id': t.id,
                  'name': t.name,
                  'category': t.category,
                  'price': t.estimatedPricePerServing,
                  'prepMinutes': t.prepMinutes,
                  'difficulty': t.difficulty,
                  'requiredEquipment': t.requiredEquipment,
                  'ingredients': candidateTemplateIngredients[t.id] ?? const <String>[],
                })
            .toList(),
      };

      final response = await _client.functions.invoke('suggest-meal', body: payload);

      if (response.status != 200) {
        final errorMap = response.data is Map ? response.data as Map : {};
        throw AppException(
          (errorMap['error'] as String?) ?? 'AI แนะนำเมนูไม่สำเร็จ กรุณาลองใหม่อีกครั้ง',
        );
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const AppException('AI ตอบกลับข้อมูลไม่ถูกต้อง');
      }

      return AiMealSuggestion.fromMap(data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException.from(e);
    }
  }
}
