class MealTemplateModel {
  final String id;
  final String name;
  final String category;
  final double estimatedPricePerServing;
  final int prepMinutes;
  final String difficulty;
  final List<String> requiredEquipment;
  final String steps;
  final int servingCount;

  const MealTemplateModel({
    required this.id,
    required this.name,
    required this.category,
    required this.estimatedPricePerServing,
    required this.prepMinutes,
    required this.difficulty,
    required this.requiredEquipment,
    required this.steps,
    required this.servingCount,
  });

  factory MealTemplateModel.fromMap(Map<String, dynamic> map) {
    return MealTemplateModel(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      estimatedPricePerServing: (map['estimated_price_per_serving'] as num).toDouble(),
      prepMinutes: map['prep_minutes'] as int? ?? 15,
      difficulty: map['difficulty'] as String? ?? 'easy',
      requiredEquipment: (map['required_equipment'] as List?)?.cast<String>() ?? const [],
      steps: map['steps'] as String? ?? '',
      servingCount: map['serving_count'] as int? ?? 1,
    );
  }
}

class MealTemplateIngredientModel {
  final String id;
  final String mealTemplateId;
  final String ingredientName;
  final double quantity;
  final String unit;

  const MealTemplateIngredientModel({
    required this.id,
    required this.mealTemplateId,
    required this.ingredientName,
    required this.quantity,
    required this.unit,
  });

  factory MealTemplateIngredientModel.fromMap(Map<String, dynamic> map) {
    return MealTemplateIngredientModel(
      id: map['id'] as String,
      mealTemplateId: map['meal_template_id'] as String,
      ingredientName: map['ingredient_name'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      unit: map['unit'] as String,
    );
  }
}

class MealPreferenceModel {
  final String id;
  final int peopleCount;
  final int mealsPerDay;
  final double? dailyFoodBudget;
  final double? weeklyFoodBudget;
  final double? monthlyFoodBudget;
  final String cookingStyle;
  final List<String> dislikedFoods;
  final List<String> allergies;
  final List<String> availableEquipment;
  final int? availableCookMinutes;
  final String preferredDifficulty;

  const MealPreferenceModel({
    required this.id,
    required this.peopleCount,
    required this.mealsPerDay,
    required this.cookingStyle,
    required this.dislikedFoods,
    required this.allergies,
    required this.availableEquipment,
    required this.preferredDifficulty,
    this.dailyFoodBudget,
    this.weeklyFoodBudget,
    this.monthlyFoodBudget,
    this.availableCookMinutes,
  });

  factory MealPreferenceModel.fromMap(Map<String, dynamic> map) {
    return MealPreferenceModel(
      id: map['id'] as String,
      peopleCount: map['people_count'] as int? ?? 1,
      mealsPerDay: map['meals_per_day'] as int? ?? 3,
      dailyFoodBudget:
          map['daily_food_budget'] != null ? (map['daily_food_budget'] as num).toDouble() : null,
      weeklyFoodBudget: map['weekly_food_budget'] != null
          ? (map['weekly_food_budget'] as num).toDouble()
          : null,
      monthlyFoodBudget: map['monthly_food_budget'] != null
          ? (map['monthly_food_budget'] as num).toDouble()
          : null,
      cookingStyle: map['cooking_style'] as String? ?? 'cook',
      dislikedFoods: (map['disliked_foods'] as List?)?.cast<String>() ?? const [],
      allergies: (map['allergies'] as List?)?.cast<String>() ?? const [],
      availableEquipment: (map['available_equipment'] as List?)?.cast<String>() ?? const [],
      availableCookMinutes: map['available_cook_minutes'] as int?,
      preferredDifficulty: map['preferred_difficulty'] as String? ?? 'easy',
    );
  }
}

const mealEquipmentOptions = [
  'เตาไฟฟ้า', 'เตาแก๊ส', 'หม้อหุงข้าว', 'ไมโครเวฟ', 'หม้อทอดไร้น้ำมัน', 'ตู้เย็น', 'เครื่องปั่น',
];

const mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];

String mealTypeLabel(String value) {
  switch (value) {
    case 'breakfast':
      return 'มื้อเช้า';
    case 'lunch':
      return 'มื้อกลางวัน';
    case 'dinner':
      return 'มื้อเย็น';
    default:
      return 'ของว่าง';
  }
}

class MealPlanModel {
  final String id;
  final String planType;
  final DateTime startDate;
  final DateTime endDate;

  const MealPlanModel({
    required this.id,
    required this.planType,
    required this.startDate,
    required this.endDate,
  });

  factory MealPlanModel.fromMap(Map<String, dynamic> map) {
    return MealPlanModel(
      id: map['id'] as String,
      planType: map['plan_type'] as String? ?? 'weekly',
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
    );
  }
}

class MealPlanItemModel {
  final String id;
  final String mealPlanId;
  final String? mealTemplateId;
  final DateTime mealDate;
  final String mealType;
  final String name; // custom_name หรือชื่อเมนูจาก template
  final bool isHomemade;
  final int peopleCount;
  final double estimatedPrice;
  final int? prepMinutes;
  final String? difficulty;
  final String status; // pending | done
  final String? note;

  const MealPlanItemModel({
    required this.id,
    required this.mealPlanId,
    required this.mealDate,
    required this.mealType,
    required this.name,
    required this.isHomemade,
    required this.peopleCount,
    required this.estimatedPrice,
    required this.status,
    this.mealTemplateId,
    this.prepMinutes,
    this.difficulty,
    this.note,
  });

  bool get isDone => status == 'done';

  factory MealPlanItemModel.fromMap(Map<String, dynamic> map) {
    return MealPlanItemModel(
      id: map['id'] as String,
      mealPlanId: map['meal_plan_id'] as String,
      mealTemplateId: map['meal_template_id'] as String?,
      mealDate: DateTime.parse(map['meal_date'] as String),
      mealType: map['meal_type'] as String,
      name: (map['custom_name'] as String?) ?? '',
      isHomemade: map['is_homemade'] as bool? ?? true,
      peopleCount: map['people_count'] as int? ?? 1,
      estimatedPrice: (map['estimated_price'] as num?)?.toDouble() ?? 0,
      prepMinutes: map['prep_minutes'] as int?,
      difficulty: map['difficulty'] as String?,
      status: map['status'] as String? ?? 'pending',
      note: map['note'] as String?,
    );
  }
}
