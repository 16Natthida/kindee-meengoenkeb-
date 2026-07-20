import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/ingredients_repository.dart';
import '../../domain/ingredient_models.dart';

final ingredientsRepositoryProvider = Provider<IngredientsRepository>((ref) {
  return IngredientsRepository();
});

final ingredientFilterProvider = StateProvider<IngredientFilter>((ref) {
  return const IngredientFilter();
});

final ingredientsListProvider =
    FutureProvider.autoDispose<List<IngredientModel>>((ref) async {
  final filter = ref.watch(ingredientFilterProvider);
  final repo = ref.watch(ingredientsRepositoryProvider);
  return repo.fetchIngredients(filter: filter);
});

/// วัตถุดิบทั้งหมดของผู้ใช้ (ไม่กรอง) ใช้สำหรับแนะนำเมนู/ตรวจสอบสต็อกตอนสร้างรายการซื้อของ
final allIngredientsProvider = FutureProvider.autoDispose<List<IngredientModel>>((ref) async {
  final repo = ref.watch(ingredientsRepositoryProvider);
  return repo.fetchAll();
});

/// วัตถุดิบที่ใกล้หมดอายุหรือใกล้หมด (ใช้บน Dashboard และหน้าแผนอาหาร)
final expiringIngredientsProvider = FutureProvider.autoDispose<List<IngredientModel>>((ref) async {
  final all = await ref.watch(allIngredientsProvider.future);
  return all.where((i) {
    final s = i.computedStatus;
    return s == IngredientStatus.expiringSoon || s == IngredientStatus.expired;
  }).toList()
    ..sort((a, b) {
      if (a.expiryDate == null) return 1;
      if (b.expiryDate == null) return -1;
      return a.expiryDate!.compareTo(b.expiryDate!);
    });
});
