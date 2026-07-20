import 'package:flutter_test/flutter_test.dart';
import 'package:kindee_meengoenkeb/features/ingredients/domain/ingredient_models.dart';
import 'package:kindee_meengoenkeb/features/meals/domain/meal_models.dart';

void main() {
  group('IngredientModel.computedStatus', () {
    IngredientModel build({
      double quantity = 5,
      double minimumQuantity = 1,
      DateTime? expiryDate,
    }) {
      return IngredientModel(
        id: '1',
        userId: 'u1',
        name: 'ไข่ไก่',
        category: 'egg',
        quantity: quantity,
        unit: 'ฟอง',
        minimumQuantity: minimumQuantity,
        storageLocation: 'fridge',
        expiryDate: expiryDate,
      );
    }

    test('quantity 0 -> outOfStock regardless of expiry', () {
      final i = build(quantity: 0);
      expect(i.computedStatus, IngredientStatus.outOfStock);
    });

    test('expired date -> expired', () {
      final i = build(expiryDate: DateTime.now().subtract(const Duration(days: 1)));
      expect(i.computedStatus, IngredientStatus.expired);
    });

    test('expiry within 3 days -> expiringSoon', () {
      final i = build(expiryDate: DateTime.now().add(const Duration(days: 2)));
      expect(i.computedStatus, IngredientStatus.expiringSoon);
    });

    test('quantity below minimum, no near expiry -> low', () {
      final i = build(quantity: 0.5, minimumQuantity: 1, expiryDate: DateTime.now().add(const Duration(days: 30)));
      expect(i.computedStatus, IngredientStatus.low);
    });

    test('healthy stock, far expiry -> available', () {
      final i = build(quantity: 10, minimumQuantity: 1, expiryDate: DateTime.now().add(const Duration(days: 30)));
      expect(i.computedStatus, IngredientStatus.available);
    });
  });

  group('mealTypeLabel', () {
    test('maps all 4 meal types to Thai labels', () {
      expect(mealTypeLabel('breakfast'), 'มื้อเช้า');
      expect(mealTypeLabel('lunch'), 'มื้อกลางวัน');
      expect(mealTypeLabel('dinner'), 'มื้อเย็น');
      expect(mealTypeLabel('snack'), 'ของว่าง');
    });
  });

  group('ingredientCategoryLabel / storageLocationLabel', () {
    test('known category value maps to Thai label', () {
      expect(ingredientCategoryLabel('vegetable'), 'ผัก');
      expect(storageLocationLabel('freezer'), 'ช่องแช่แข็ง');
    });

    test('unknown value falls back to อื่น ๆ', () {
      expect(ingredientCategoryLabel('unknown_xyz'), 'อื่น ๆ');
    });
  });
}
