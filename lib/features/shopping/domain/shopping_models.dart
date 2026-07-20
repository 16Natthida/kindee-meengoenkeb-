class ShoppingListModel {
  final String id;
  final String title;
  final String? mealPlanId;

  const ShoppingListModel({required this.id, required this.title, this.mealPlanId});

  factory ShoppingListModel.fromMap(Map<String, dynamic> map) {
    return ShoppingListModel(
      id: map['id'] as String,
      title: map['title'] as String? ?? 'รายการซื้อของ',
      mealPlanId: map['meal_plan_id'] as String?,
    );
  }
}

class ShoppingListItemModel {
  final String id;
  final String shoppingListId;
  final String productName;
  final double quantity;
  final String unit;
  final double? estimatedPrice;
  final double? actualPrice;
  final String? category;
  final String? storeName;
  final bool isPurchased;
  final DateTime? dueDate;
  final String? note;
  final bool linkedToMealPlan;

  const ShoppingListItemModel({
    required this.id,
    required this.shoppingListId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.isPurchased,
    required this.linkedToMealPlan,
    this.estimatedPrice,
    this.actualPrice,
    this.category,
    this.storeName,
    this.dueDate,
    this.note,
  });

  factory ShoppingListItemModel.fromMap(Map<String, dynamic> map) {
    return ShoppingListItemModel(
      id: map['id'] as String,
      shoppingListId: map['shopping_list_id'] as String,
      productName: map['product_name'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      unit: map['unit'] as String,
      estimatedPrice:
          map['estimated_price'] != null ? (map['estimated_price'] as num).toDouble() : null,
      actualPrice: map['actual_price'] != null ? (map['actual_price'] as num).toDouble() : null,
      category: map['category'] as String?,
      storeName: map['store_name'] as String?,
      isPurchased: map['is_purchased'] as bool? ?? false,
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date'] as String) : null,
      note: map['note'] as String?,
      linkedToMealPlan: map['linked_to_meal_plan'] as bool? ?? false,
    );
  }
}

/// ผลลัพธ์ของ Dialog "ซื้อแล้ว" — ให้ผู้ใช้เลือกว่าจะเพิ่มเข้าคลังวัตถุดิบ/บันทึกเป็นรายจ่ายหรือไม่
class PurchaseConfirmation {
  final double actualPrice;
  final bool addToIngredientStock;
  final bool saveAsExpense;

  const PurchaseConfirmation({
    required this.actualPrice,
    required this.addToIngredientStock,
    required this.saveAsExpense,
  });
}
