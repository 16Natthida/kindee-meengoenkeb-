import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/shopping_repository.dart';
import '../../domain/shopping_models.dart';

final shoppingRepositoryProvider = Provider<ShoppingRepository>((ref) {
  return ShoppingRepository();
});

final activeShoppingListProvider = FutureProvider.autoDispose<ShoppingListModel>((ref) async {
  final repo = ref.watch(shoppingRepositoryProvider);
  return repo.fetchOrCreateActiveList();
});

final shoppingItemsProvider =
    FutureProvider.autoDispose<List<ShoppingListItemModel>>((ref) async {
  final list = await ref.watch(activeShoppingListProvider.future);
  final repo = ref.watch(shoppingRepositoryProvider);
  return repo.fetchItems(list.id);
});
