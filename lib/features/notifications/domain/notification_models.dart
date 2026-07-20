enum NotificationType {
  budgetLow,
  overBudget,
  foodBudgetLow,
  ingredientExpiring,
  ingredientExpired,
  ingredientLow,
  noMealPlan,
  shoppingIncomplete,
  expenseAboveAverage,
}

extension NotificationTypeX on NotificationType {
  String get dbValue {
    switch (this) {
      case NotificationType.budgetLow:
        return 'budget_low';
      case NotificationType.overBudget:
        return 'over_budget';
      case NotificationType.foodBudgetLow:
        return 'food_budget_low';
      case NotificationType.ingredientExpiring:
        return 'ingredient_expiring';
      case NotificationType.ingredientExpired:
        return 'ingredient_expired';
      case NotificationType.ingredientLow:
        return 'ingredient_low';
      case NotificationType.noMealPlan:
        return 'no_meal_plan';
      case NotificationType.shoppingIncomplete:
        return 'shopping_incomplete';
      case NotificationType.expenseAboveAverage:
        return 'expense_above_average';
    }
  }

  static NotificationType fromDb(String value) {
    return NotificationType.values.firstWhere(
      (t) => t.dbValue == value,
      orElse: () => NotificationType.budgetLow,
    );
  }

  String get icon {
    switch (this) {
      case NotificationType.budgetLow:
      case NotificationType.overBudget:
      case NotificationType.foodBudgetLow:
        return 'account_balance_wallet';
      case NotificationType.ingredientExpiring:
      case NotificationType.ingredientExpired:
      case NotificationType.ingredientLow:
        return 'kitchen';
      case NotificationType.noMealPlan:
        return 'restaurant_menu';
      case NotificationType.shoppingIncomplete:
        return 'shopping_cart';
      case NotificationType.expenseAboveAverage:
        return 'trending_up';
    }
  }

  /// เส้นทางที่ควรเปิดเมื่อผู้ใช้กดการแจ้งเตือนนี้
  String get targetRoute {
    switch (this) {
      case NotificationType.budgetLow:
      case NotificationType.overBudget:
        return '/home';
      case NotificationType.foodBudgetLow:
        return '/meals';
      case NotificationType.ingredientExpiring:
      case NotificationType.ingredientExpired:
      case NotificationType.ingredientLow:
        return '/ingredients';
      case NotificationType.noMealPlan:
        return '/meals';
      case NotificationType.shoppingIncomplete:
        return '/shopping';
      case NotificationType.expenseAboveAverage:
        return '/expenses';
    }
  }
}

class AppNotificationModel {
  final String id;
  final String title;
  final String detail;
  final NotificationType type;
  final bool isRead;
  final String? referenceId;
  final DateTime createdAt;

  const AppNotificationModel({
    required this.id,
    required this.title,
    required this.detail,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.referenceId,
  });

  factory AppNotificationModel.fromMap(Map<String, dynamic> map) {
    return AppNotificationModel(
      id: map['id'] as String,
      title: map['title'] as String,
      detail: map['detail'] as String,
      type: NotificationTypeX.fromDb(map['type'] as String),
      isRead: map['is_read'] as bool? ?? false,
      referenceId: map['reference_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
