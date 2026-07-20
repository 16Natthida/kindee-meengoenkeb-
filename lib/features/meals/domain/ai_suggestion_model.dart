class AiSuggestedIngredient {
  final String name;
  final double quantity;
  final String unit;

  const AiSuggestedIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory AiSuggestedIngredient.fromMap(Map<String, dynamic> map) {
    return AiSuggestedIngredient(
      name: map['name'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 1,
      unit: map['unit'] as String? ?? 'หน่วย',
    );
  }
}

/// ผลลัพธ์จาก AI (Claude ผ่าน Supabase Edge Function `suggest-meal`)
class AiMealSuggestion {
  final bool isFromTemplate;
  final String? templateId;
  final String name;
  final String reason;
  final double estimatedPricePerServing;
  final int prepMinutes;
  final String difficulty;
  final List<AiSuggestedIngredient> ingredients;

  const AiMealSuggestion({
    required this.isFromTemplate,
    required this.name,
    required this.reason,
    required this.estimatedPricePerServing,
    required this.prepMinutes,
    required this.difficulty,
    required this.ingredients,
    this.templateId,
  });

  factory AiMealSuggestion.fromMap(Map<String, dynamic> map) {
    return AiMealSuggestion(
      isFromTemplate: map['source'] == 'template',
      templateId: map['templateId'] as String?,
      name: map['name'] as String? ?? 'เมนูแนะนำ',
      reason: map['reason'] as String? ?? '',
      estimatedPricePerServing: (map['estimatedPricePerServing'] as num?)?.toDouble() ?? 0,
      prepMinutes: (map['prepMinutes'] as num?)?.toInt() ?? 15,
      difficulty: map['difficulty'] as String? ?? 'easy',
      ingredients: ((map['ingredients'] as List?) ?? [])
          .map((i) => AiSuggestedIngredient.fromMap(i as Map<String, dynamic>))
          .toList(),
    );
  }
}
