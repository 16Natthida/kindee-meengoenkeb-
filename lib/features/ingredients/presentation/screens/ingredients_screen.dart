import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../domain/ingredient_models.dart';
import '../providers/ingredients_provider.dart';
import '../widgets/ingredient_tile.dart';

class IngredientsScreen extends ConsumerStatefulWidget {
  const IngredientsScreen({super.key});

  @override
  ConsumerState<IngredientsScreen> createState() => _IngredientsScreenState();
}

class _IngredientsScreenState extends ConsumerState<IngredientsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilter(IngredientFilter Function(IngredientFilter) update) {
    final current = ref.read(ingredientFilterProvider);
    ref.read(ingredientFilterProvider.notifier).state = update(current);
  }

  @override
  Widget build(BuildContext context) {
    final ingredientsAsync = ref.watch(ingredientsListProvider);
    final filter = ref.watch(ingredientFilterProvider);
    final repo = ref.watch(ingredientsRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('วัตถุดิบ'),
        actions: [
          IconButton(
            icon: Icon(filter.sortByExpiry ? Icons.sort : Icons.sort_outlined),
            tooltip: 'เรียงตามวันหมดอายุ',
            onPressed: () => _updateFilter((f) => f.copyWith(sortByExpiry: !f.sortByExpiry)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/ingredients/add'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'ค้นหาวัตถุดิบ',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (v) => _updateFilter((f) => f.copyWith(searchText: v)),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _FilterChip(
                  label: 'ทั้งหมด',
                  selected: filter.category == null,
                  onTap: () => _updateFilter((f) => f.copyWith(clearCategory: true)),
                ),
                ...ingredientCategoryOptions.map((c) => _FilterChip(
                      label: c.label,
                      selected: filter.category == c.value,
                      onTap: () => _updateFilter((f) => f.copyWith(category: c.value)),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ingredientsAsync.when(
              loading: () => const DashboardSkeleton(),
              error: (e, st) => ErrorStateView(
                message: AppException.from(e).message,
                onRetry: () => ref.invalidate(ingredientsListProvider),
              ),
              data: (ingredients) {
                if (ingredients.isEmpty) {
                  return const EmptyStateView(
                    message: 'ยังไม่มีวัตถุดิบในคลัง',
                    icon: Icons.kitchen_outlined,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(ingredientsListProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                    itemCount: ingredients.length,
                    itemBuilder: (context, index) {
                      final ingredient = ingredients[index];
                      return IngredientTile(
                        ingredient: ingredient,
                        onTap: () => context.push('/ingredients/edit/${ingredient.id}'),
                        onDelete: () async {
                          try {
                            await repo.deleteIngredient(ingredient.id);
                            ref.invalidate(ingredientsListProvider);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppException.from(e).message)),
                              );
                            }
                          }
                        },
                        onIncrement: () async {
                          await repo.adjustQuantity(id: ingredient.id, delta: 1);
                          ref.invalidate(ingredientsListProvider);
                        },
                        onDecrement: () async {
                          await repo.adjustQuantity(id: ingredient.id, delta: -1);
                          ref.invalidate(ingredientsListProvider);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
