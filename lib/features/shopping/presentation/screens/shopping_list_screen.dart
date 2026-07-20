import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/extensions/formatting_extensions.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../budget/presentation/providers/budget_provider.dart';
import '../../../expenses/presentation/providers/expenses_provider.dart';
import '../../../ingredients/presentation/providers/ingredients_provider.dart';
import '../../domain/shopping_models.dart';
import '../providers/shopping_provider.dart';
import '../widgets/purchase_dialog.dart';
import '../widgets/shopping_item_tile.dart';

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  bool _isProcessing = false;
  final _searchController = TextEditingController();
  String _searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addOrEditItemDialog({ShoppingListItemModel? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.productName ?? '');
    final qtyCtrl = TextEditingController(text: existing != null ? _trimZero(existing.quantity) : '1');
    final unitCtrl = TextEditingController(text: existing?.unit ?? 'ชิ้น');
    final priceCtrl = TextEditingController(
      text: existing?.estimatedPrice != null ? _trimZero(existing!.estimatedPrice!) : '',
    );
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'เพิ่มรายการซื้อของ' : 'แก้ไขรายการ'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'ชื่อสินค้า'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'กรุณากรอกชื่อสินค้า' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: qtyCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'จำนวน'),
                        validator: (v) {
                          final n = double.tryParse(v?.trim() ?? '');
                          if (n == null || n <= 0) return 'จำนวนไม่ถูกต้อง';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: unitCtrl,
                        decoration: const InputDecoration(labelText: 'หน่วย'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'กรุณากรอกหน่วย' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'ราคาประมาณ (ไม่บังคับ)'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ยกเลิก')),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(context, true);
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );

    if (result != true) return;

    try {
      final repo = ref.read(shoppingRepositoryProvider);
      final list = await ref.read(activeShoppingListProvider.future);
      final price = priceCtrl.text.trim().isEmpty ? null : double.tryParse(priceCtrl.text.trim());

      if (existing == null) {
        await repo.addItem(
          shoppingListId: list.id,
          productName: nameCtrl.text.trim(),
          quantity: double.parse(qtyCtrl.text.trim()),
          unit: unitCtrl.text.trim(),
          estimatedPrice: price,
        );
      } else {
        await repo.updateItem(
          id: existing.id,
          productName: nameCtrl.text.trim(),
          quantity: double.parse(qtyCtrl.text.trim()),
          unit: unitCtrl.text.trim(),
          estimatedPrice: price,
        );
      }
      ref.invalidate(shoppingItemsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppException.from(e).message)),
        );
      }
    }
  }

  String _trimZero(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  Future<void> _handlePurchase(ShoppingListItemModel item) async {
    if (_isProcessing) return; // ป้องกันการสร้างรายจ่ายซ้ำเมื่อกดหลายครั้ง
    final confirmation = await showPurchaseDialog(context, estimatedPrice: item.estimatedPrice);
    if (confirmation == null) return;

    setState(() => _isProcessing = true);
    try {
      final shoppingRepo = ref.read(shoppingRepositoryProvider);
      await shoppingRepo.setPurchased(
        id: item.id,
        purchased: true,
        actualPrice: confirmation.actualPrice,
      );

      if (confirmation.addToIngredientStock) {
        final ingredientsRepo = ref.read(ingredientsRepositoryProvider);
        final stock = await ingredientsRepo.fetchAll();
        final existing = stock.where(
          (i) => i.name.toLowerCase().trim() == item.productName.toLowerCase().trim() && i.unit == item.unit,
        );
        if (existing.isNotEmpty) {
          await ingredientsRepo.adjustQuantity(id: existing.first.id, delta: item.quantity);
        } else {
          await ingredientsRepo.createIngredient(
            name: item.productName,
            category: 'other',
            quantity: item.quantity,
            unit: item.unit,
            storageLocation: 'kitchen',
            purchaseDate: DateTime.now(),
            purchasePrice: confirmation.actualPrice,
          );
        }
        ref.invalidate(allIngredientsProvider);
        ref.invalidate(ingredientsListProvider);
        ref.invalidate(expiringIngredientsProvider);
      }

      if (confirmation.saveAsExpense) {
        final categories = await ref.read(categoriesProvider.future);
        final foodCategory = categories.where((c) => c.name == 'ค่าอาหาร');
        final expensesRepo = ref.read(expensesRepositoryProvider);
        await expensesRepo.createExpense(
          title: item.productName,
          amount: confirmation.actualPrice,
          categoryId: foodCategory.isEmpty ? null : foodCategory.first.id,
          paymentMethod: 'cash',
          note: 'จากรายการซื้อของ',
          expenseDate: DateTime.now(),
        );
        ref.invalidate(expensesListControllerProvider);
        ref.invalidate(filteredExpenseTotalProvider);
      }

      ref.invalidate(shoppingItemsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppException.from(e).message)),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(shoppingItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ซื้อของ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'ทำเครื่องหมายซื้อแล้วทั้งหมด',
            onPressed: () async {
              final list = await ref.read(activeShoppingListProvider.future);
              await ref.read(shoppingRepositoryProvider).markAllPurchased(list.id);
              ref.invalidate(shoppingItemsProvider);
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value != 'delete_all') return;
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('ลบรายการทั้งหมด?'),
                  content: const Text('รายการซื้อของทั้งหมดจะถูกลบและไม่สามารถกู้คืนได้'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('ยกเลิก')),
                    FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('ลบทั้งหมด')),
                  ],
                ),
              );
              if (confirmed != true) return;
              final list = await ref.read(activeShoppingListProvider.future);
              await ref.read(shoppingRepositoryProvider).deleteAllItems(list.id);
              ref.invalidate(shoppingItemsProvider);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'delete_all', child: Text('ลบรายการทั้งหมด')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditItemDialog(),
        child: const Icon(Icons.add),
      ),
      body: itemsAsync.when(
        loading: () => const DashboardSkeleton(),
        error: (e, st) => ErrorStateView(
          message: AppException.from(e).message,
          onRetry: () => ref.invalidate(shoppingItemsProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyStateView(
              message: 'ยังไม่มีรายการซื้อของ\nเพิ่มเองหรือสร้างจากแผนอาหารได้',
              icon: Icons.shopping_cart_outlined,
            );
          }

          final notPurchased = items.where((i) => !i.isPurchased).length;
          final estimatedTotal = items.fold<double>(0, (sum, i) => sum + (i.estimatedPrice ?? 0));
          final actualTotal = items
              .where((i) => i.isPurchased)
              .fold<double>(0, (sum, i) => sum + (i.actualPrice ?? 0));

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(shoppingItemsProvider),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.pastelYellow.withValues(alpha: 0.85), AppColors.softPink],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.shopping_basket_rounded, color: AppColors.strawberry),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('รายการซื้อของวันนี้', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                            Text('เช็กของให้ครบ แล้วคุมงบได้ง่ายขึ้น', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'ค้นหารายการซื้อของ',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                    ),
                    onChanged: (value) => setState(() => _searchText = value.trim().toLowerCase()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 0,
                    color: AppColors.softPink.withValues(alpha: 0.34),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                      side: BorderSide(color: AppColors.softPink.withValues(alpha: 0.85)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatColumn(label: 'ยังไม่ได้ซื้อ', value: '$notPurchased รายการ'),
                          ),
                          Expanded(
                            child: _StatColumn(
                                label: 'งบประมาณ', value: '฿${estimatedTotal.toBaht()}'),
                          ),
                          Expanded(
                            child: _StatColumn(label: 'ซื้อจริงแล้ว', value: '฿${actualTotal.toBaht()}'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                    itemCount: items
                        .where((i) => i.productName.toLowerCase().contains(_searchText))
                        .length,
                    itemBuilder: (context, index) {
                      final filtered = items
                          .where((i) => i.productName.toLowerCase().contains(_searchText))
                          .toList();
                      final item = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ShoppingItemTile(
                          item: item,
                          onTogglePurchased: () {
                            if (item.isPurchased) {
                              ref.read(shoppingRepositoryProvider).setPurchased(id: item.id, purchased: false);
                              ref.invalidate(shoppingItemsProvider);
                            } else {
                              _handlePurchase(item);
                            }
                          },
                          onEdit: () => _addOrEditItemDialog(existing: item),
                          onDelete: () async {
                            await ref.read(shoppingRepositoryProvider).deleteItem(item.id);
                            ref.invalidate(shoppingItemsProvider);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700), textAlign: TextAlign.center),
      ],
    );
  }
}
