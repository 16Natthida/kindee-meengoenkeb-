import 'package:flutter_test/flutter_test.dart';
import 'package:kindee_meengoenkeb/features/meals/domain/ai_suggestion_model.dart';

void main() {
  group('AiMealSuggestion.fromMap', () {
    test('parses a template-based suggestion correctly', () {
      final suggestion = AiMealSuggestion.fromMap({
        'source': 'template',
        'templateId': 'abc-123',
        'name': 'ข้าวผัดกะเพราหมู',
        'reason': 'ใช้หมูสับที่ใกล้หมดอายุในตู้เย็น',
        'estimatedPricePerServing': 35,
        'prepMinutes': 15,
        'difficulty': 'easy',
        'ingredients': [],
      });

      expect(suggestion.isFromTemplate, isTrue);
      expect(suggestion.templateId, 'abc-123');
      expect(suggestion.name, 'ข้าวผัดกะเพราหมู');
      expect(suggestion.estimatedPricePerServing, 35);
    });

    test('parses a custom suggestion with ingredients correctly', () {
      final suggestion = AiMealSuggestion.fromMap({
        'source': 'custom',
        'templateId': null,
        'name': 'ผัดผักรวมไข่เจียวเศษผัก',
        'reason': 'ใช้ผักที่เหลือให้หมดก่อนเสีย',
        'estimatedPricePerServing': 20,
        'prepMinutes': 10,
        'difficulty': 'easy',
        'ingredients': [
          {'name': 'ผักกาดขาว', 'quantity': 100, 'unit': 'g'},
          {'name': 'ไข่ไก่', 'quantity': 1, 'unit': 'ฟอง'},
        ],
      });

      expect(suggestion.isFromTemplate, isFalse);
      expect(suggestion.templateId, isNull);
      expect(suggestion.ingredients.length, 2);
      expect(suggestion.ingredients.first.name, 'ผักกาดขาว');
    });

    test('missing fields fall back to safe defaults without throwing', () {
      final suggestion = AiMealSuggestion.fromMap({});
      expect(suggestion.isFromTemplate, isFalse);
      expect(suggestion.name, isNotEmpty);
      expect(suggestion.difficulty, 'easy');
      expect(suggestion.ingredients, isEmpty);
    });
  });
}
