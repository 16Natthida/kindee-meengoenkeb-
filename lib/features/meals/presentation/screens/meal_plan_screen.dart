import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/extensions/formatting_extensions.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../ingredients/presentation/providers/ingredients_provider.dart';
import '../../../shopping/presentation/providers/shopping_provider.dart';
import '../../domain/meal_models.dart';
import '../providers/meals_provider.dart';
import '../widgets/meal_item_tile.dart';

class MealPlanScreen extends ConsumerStatefulWidget {
  const MealPlanScreen({super.key});

  @override
  ConsumerState<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends ConsumerState<MealPlanScreen> {
  bool _isBusy = false;

  static const _thaiWeekdays = ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'];

  /// ขอคำแนะนำเมนูจาก AI ก่อน ถ้าใช้งานไม่ได้ (เช่น ยังไม่ได้ Deploy Edge Function
  /// หรือไม่มีอินเทอร์เน็ต) จะ Fallback ไปใช้ระบบสุ่มจากฐานข้อมูลภายในแอปโดยอัตโนมัติ
  Future<void> _suggestMeal(String mealPlanId, DateTime date, String mealType) async {
    setState(() => _isBusy = true);
    try {
      final mealsRepo = ref.read(mealsRepositoryProvider);
      final prefs = await ref.read(mealPreferencesProvider.future);
      if (prefs == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('กรุณาตั้งค่าการกินก่อนใช้แนะนำเมนู')),
          );
        }
        return;
      }

      final maxPrice = prefs.dailyFoodBudget != null
          ? prefs.dailyFoodBudget! / prefs.mealsPerDay
          : null;

      // เตรียมบริบทให้ AI: เมนูที่ปลอดภัยแล้ว (กรองแพ้อาหาร/อุปกรณ์/งบ), วัตถุดิบใกล้หมดอายุ/ในสต็อก, เมนูล่าสุด
      final candidates = await mealsRepo.fetchSafeCandidates(
        preferences: prefs,
        maxPrice: maxPrice,
      );
      final candidateIngredients = <String, List<String>>{};
      for (final c in candidates) {
        final ings = await mealsRepo.fetchTemplateIngredients(c.id);
        candidateIngredients[c.id] = ings.map((i) => i.ingredientName).toList();
      }

      final allIngredients = await ref.read(allIngredientsProvider.future);
      final expiringIngredients = await ref.read(expiringIngredientsProvider.future);
      final recentMealNames = await mealsRepo.fetchRecentMealNames(
        mealPlanId: mealPlanId,
        beforeDate: date,
      );

      MealTemplateModel? chosenTemplate;
      String? customName;
      String? customReason;
      double customPrice = 0;
      int customPrepMinutes = 15;
      String customDifficulty = prefs.preferredDifficulty;
      List<String> customIngredientLines = const [];

      try {
        final aiService = ref.read(aiMealSuggestionServiceProvider);
        final suggestion = await aiService.suggestMeal(
          mealType: mealType,
          peopleCount: prefs.peopleCount,
          maxPrice: maxPrice,
          allergies: prefs.allergies,
          dislikedFoods: prefs.dislikedFoods,
          availableEquipment: prefs.availableEquipment,
          preferredDifficulty: prefs.preferredDifficulty,
          nearExpiryIngredients: expiringIngredients.map((i) => i.name).toList(),
          stockIngredients: allIngredients.map((i) => i.name).toList(),
          recentMealNames: recentMealNames,
          candidateTemplates: candidates,
          candidateTemplateIngredients: candidateIngredients,
        );

        // Defense-in-depth: ตรวจซ้ำฝั่งแอปว่าไม่มีวัตถุดิบที่แพ้หลุดมา แม้ Edge Function จะเช็กแล้วก็ตาม
        final hasAllergen = suggestion.ingredients.any((ing) => prefs.allergies
            .any((a) => ing.name.toLowerCase().contains(a.toLowerCase())));
        if (hasAllergen) {
          throw const AppException('AI แนะนำเมนูที่มีวัตถุดิบที่แพ้ ระบบจึงเปลี่ยนไปใช้ระบบสำรอง');
        }

        if (suggestion.isFromTemplate && suggestion.templateId != null) {
          chosenTemplate = candidates.where((c) => c.id == suggestion.templateId).firstOrNull;
        }

        if (chosenTemplate == null) {
          customName = suggestion.name;
          customPrice = suggestion.estimatedPricePerServing * prefs.peopleCount;
          customPrepMinutes = suggestion.prepMinutes;
          customDifficulty = suggestion.difficulty;
          customIngredientLines = suggestion.ingredients
              .map((i) => '${i.name} ${i.quantity == i.quantity.roundToDouble() ? i.quantity.toStringAsFixed(0) : i.quantity} ${i.unit}')
              .toList();
        }
        customReason = suggestion.reason;
      } catch (_) {
        // AI ใช้งานไม่ได้ (ยังไม่ได้ Deploy Edge Function / ไม่มีอินเทอร์เน็ต / ตอบผิดรูปแบบ)
        // ใช้ระบบสุ่มจากฐานข้อมูลภายในแอปแทนโดยอัตโนมัติ ไม่ให้ผู้ใช้ติดขัด
        if (candidates.isNotEmpty) {
          chosenTemplate = candidates[DateTime.now().millisecondsSinceEpoch % candidates.length];
        }
        customReason = null;
      }

      if (chosenTemplate == null && customName == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ไม่พบเมนูที่เหมาะสมตามเงื่อนไข')),
          );
        }
        return;
      }

      if (chosenTemplate != null) {
        await mealsRepo.addItem(
          mealPlanId: mealPlanId,
          mealTemplateId: chosenTemplate.id,
          mealDate: date,
          mealType: mealType,
          name: chosenTemplate.name,
          isHomemade: true,
          peopleCount: prefs.peopleCount,
          estimatedPrice: chosenTemplate.estimatedPricePerServing * prefs.peopleCount,
          prepMinutes: chosenTemplate.prepMinutes,
          difficulty: chosenTemplate.difficulty,
          note: customReason,
        );
      } else {
        await mealsRepo.addItem(
          mealPlanId: mealPlanId,
          mealDate: date,
          mealType: mealType,
          name: customName!,
          isHomemade: true,
          peopleCount: prefs.peopleCount,
          estimatedPrice: customPrice,
          prepMinutes: customPrepMinutes,
          difficulty: customDifficulty,
          note: [
            if (customReason != null && customReason.isNotEmpty) customReason,
            if (customIngredientLines.isNotEmpty) 'วัตถุดิบ: ${customIngredientLines.join(", ")}',
          ].join(' • '),
        );
      }

      ref.invalidate(weeklyPlanItemsProvider);
      if (mounted && customReason != null && customReason.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI แนะนำ: $customReason')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppException.from(e).message)),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _copyFromPreviousDay(String mealPlanId, DateTime date) async {
    setState(() => _isBusy = true);
    try {
      final mealsRepo = ref.read(mealsRepositoryProvider);
      final previousDay = date.subtract(const Duration(days: 1));
      await mealsRepo.copyDay(
        fromPlanId: mealPlanId,
        fromDate: previousDay,
        toPlanId: mealPlanId,
        toDate: date,
      );
      ref.invalidate(weeklyPlanItemsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('คัดลอกเมนูจากวันก่อนหน้าแล้ว')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppException.from(e).message)),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _clearDay(String mealPlanId, DateTime date) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ล้างแผนของวันนี้'),
        content: const Text('ต้องการลบเมนูทั้งหมดของวันนี้ใช่หรือไม่?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ยกเลิก')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ล้างแผน'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(mealsRepositoryProvider).clearDay(mealPlanId: mealPlanId, date: date);
      ref.invalidate(weeklyPlanItemsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppException.from(e).message)),
        );
      }
    }
  }

  Future<void> _generateWeeklyShoppingList(List<MealPlanItemModel> weekItems) async {
    if (weekItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ยังไม่มีเมนูในสัปดาห์นี้')),
      );
      return;
    }
    setState(() => _isBusy = true);
    try {
      final shoppingRepo = ref.read(shoppingRepositoryProvider);
      final list = await ref.read(activeShoppingListProvider.future);
      final count = await shoppingRepo.generateFromWeeklyPlan(
        shoppingListId: list.id,
        weekItems: weekItems,
      );
      ref.invalidate(shoppingItemsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เพิ่มวัตถุดิบลงรายการซื้อของแล้ว $count รายการ')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppException.from(e).message)),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedMealDateProvider);
    final planAsync = ref.watch(weeklyPlanProvider);
    final dayItemsAsync = ref.watch(selectedDayItemsProvider);
    final weekItemsAsync = ref.watch(weeklyPlanItemsProvider);
    final prefsAsync = ref.watch(mealPreferencesProvider);

    final monday = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    final weekDays = List.generate(7, (i) => monday.add(Duration(days: i)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('แผนอาหาร'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'ตั้งค่าการกิน',
            onPressed: () => context.push('/meal-preferences'),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_checkout),
            tooltip: 'สร้างรายการซื้อของทั้งสัปดาห์',
            onPressed: _isBusy
                ? null
                : () => weekItemsAsync.whenData((items) => _generateWeeklyShoppingList(items)),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.cardCream,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.softPink.withValues(alpha: 0.65)),
            ),
            child: SizedBox(
            height: 72,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: 7,
              itemBuilder: (context, index) {
                final day = weekDays[index];
                final selected = day.year == selectedDate.year &&
                    day.month == selectedDate.month &&
                    day.day == selectedDate.day;
                return GestureDetector(
                  onTap: () => ref.read(selectedMealDateProvider.notifier).state = day,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 54,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.strawberry
                          : AppColors.softPink.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: AppColors.strawberry.withValues(alpha: 0.22),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_thaiWeekdays[index],
                            style: TextStyle(
                                fontSize: 11, color: selected ? Colors.white70 : null)),
                        Text('${day.day}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: selected ? Colors.white : null,
                            )),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          ),
          const Divider(height: 1),
          Expanded(
            child: planAsync.when(
              loading: () => const DashboardSkeleton(),
              error: (e, st) => ErrorStateView(
                message: AppException.from(e).message,
                onRetry: () => ref.invalidate(weeklyPlanProvider),
              ),
              data: (plan) {
                return dayItemsAsync.when(
                  loading: () => const DashboardSkeleton(),
                  error: (e, st) => ErrorStateView(
                    message: AppException.from(e).message,
                    onRetry: () => ref.invalidate(selectedDayItemsProvider),
                  ),
                  data: (dayItems) {
                    final totalToday = dayItems.fold<double>(0, (s, i) => s + i.estimatedPrice);
                    final dailyBudget = prefsAsync.valueOrNull?.dailyFoodBudget;
                    final overBudget = dailyBudget != null && totalToday > dailyBudget;

                    return RefreshIndicator(
                      onRefresh: () async => ref.invalidate(weeklyPlanItemsProvider),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.softPink, AppColors.pastelYellow.withValues(alpha: 0.62)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                  child: const Icon(Icons.restaurant_menu_rounded, color: AppColors.strawberry),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('วันนี้กินอะไรดี?', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                                      Text('วางแผนมื้ออาหารให้อร่อยและไม่เกินงบ', style: Theme.of(context).textTheme.bodySmall),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                              side: BorderSide(
                                color: overBudget
                                    ? AppColors.dangerRed.withValues(alpha: 0.35)
                                    : AppColors.pastelYellow.withValues(alpha: 0.8),
                              ),
                            ),
                            color: overBudget
                                ? Theme.of(context).colorScheme.errorContainer
                                : AppColors.pastelYellow.withValues(alpha: 0.28),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Icon(overBudget ? Icons.warning_amber : Icons.restaurant,
                                      color: overBudget ? Theme.of(context).colorScheme.error : null),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      dailyBudget != null
                                          ? 'ค่าอาหารวันนี้ ≈ ฿${totalToday.toBaht()} จากงบ ฿${dailyBudget.toBaht()}'
                                          : 'ค่าอาหารวันนี้ ≈ ฿${totalToday.toBaht()}',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _isBusy ? null : () => _copyFromPreviousDay(plan.id, selectedDate),
                                  icon: const Icon(Icons.content_copy, size: 16),
                                  label: const Text('คัดลอกจากวันก่อน'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _isBusy ? null : () => _clearDay(plan.id, selectedDate),
                                  icon: const Icon(Icons.clear_all, size: 16),
                                  label: const Text('ล้างแผน'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...mealTypes.map((type) {
                            final items = dayItems.where((i) => i.mealType == type).toList();
                            return _MealTypeSection(
                              mealType: type,
                              items: items,
                              isBusy: _isBusy,
                              onAdd: () => context.push(
                                '/meals/add-item',
                                extra: {
                                  'mealPlanId': plan.id,
                                  'mealDate': selectedDate,
                                  'mealType': type,
                                },
                              ),
                              onSuggest: () => _suggestMeal(plan.id, selectedDate, type),
                              onToggleDone: (item) async {
                                await ref
                                    .read(mealsRepositoryProvider)
                                    .setItemStatus(itemId: item.id, done: !item.isDone);
                                ref.invalidate(weeklyPlanItemsProvider);
                              },
                              onDelete: (item) async {
                                await ref.read(mealsRepositoryProvider).deleteItem(item.id);
                                ref.invalidate(weeklyPlanItemsProvider);
                              },
                              onAddToShoppingList: (item) async {
                                final shoppingRepo = ref.read(shoppingRepositoryProvider);
                                final list = await ref.read(activeShoppingListProvider.future);
                                final count = await shoppingRepo.addIngredientsFromMealItem(
                                  shoppingListId: list.id,
                                  mealItem: item,
                                );
                                ref.invalidate(shoppingItemsProvider);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(count > 0
                                          ? 'เพิ่มวัตถุดิบลงรายการซื้อของแล้ว $count รายการ'
                                          : 'มีวัตถุดิบเพียงพอในคลังแล้ว หรือเมนูนี้ไม่มีสูตรวัตถุดิบในระบบ'),
                                    ),
                                  );
                                }
                              },
                            );
                          }),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

extension _FirstOrNullExt<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class _MealTypeSection extends StatelessWidget {
  final String mealType;
  final List<MealPlanItemModel> items;
  final bool isBusy;
  final VoidCallback onAdd;
  final VoidCallback onSuggest;
  final void Function(MealPlanItemModel) onToggleDone;
  final void Function(MealPlanItemModel) onDelete;
  final void Function(MealPlanItemModel) onAddToShoppingList;

  const _MealTypeSection({
    required this.mealType,
    required this.items,
    required this.isBusy,
    required this.onAdd,
    required this.onSuggest,
    required this.onToggleDone,
    required this.onDelete,
    required this.onAddToShoppingList,
  });

  @override
  Widget build(BuildContext context) {
    final accent = _mealTypeColor(mealType);
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: accent.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_mealTypeIcon(mealType), color: accent),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mealTypeLabel(mealType),
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        items.isEmpty ? 'ยังไม่มีเมนู' : '${items.length} เมนู',
                        style: textTheme.bodySmall?.copyWith(color: AppColors.textDark.withValues(alpha: 0.62)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.auto_awesome, size: 20, color: AppColors.strawberry),
                  tooltip: 'แนะนำเมนูด้วย AI',
                  onPressed: isBusy ? null : onSuggest,
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline, size: 21, color: accent),
                  tooltip: 'เพิ่มเมนู',
                  onPressed: isBusy ? null : onAdd,
                ),
              ],
            ),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: isBusy ? null : onAdd,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.softPink.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: accent.withValues(alpha: 0.28)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 18, color: accent),
                        const SizedBox(width: 6),
                        Text('เพิ่มเมนูสำหรับมื้อนี้', style: TextStyle(color: accent, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  children: items
                      .map(
                        (item) => MealItemTile(
                          item: item,
                          onToggleDone: () => onToggleDone(item),
                          onDelete: () => onDelete(item),
                          onAddToShoppingList: () => onAddToShoppingList(item),
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
    /*
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(mealTypeLabel(mealType), style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.auto_awesome, size: 20),
                tooltip: 'แนะนำเมนูด้วย AI',
                onPressed: isBusy ? null : onSuggest,
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                tooltip: 'เพิ่มเมนู',
                onPressed: isBusy ? null : onAdd,
              ),
            ],
          ),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('ยังไม่มีเมนู', style: Theme.of(context).textTheme.bodySmall),
            )
          else
            ...items.map((item) => MealItemTile(
                  item: item,
                  onToggleDone: () => onToggleDone(item),
                  onDelete: () => onDelete(item),
                  onAddToShoppingList: () => onAddToShoppingList(item),
                )),
        ],
      ),
    );
    */
  }
}

IconData _mealTypeIcon(String mealType) {
  switch (mealType) {
    case 'breakfast':
      return Icons.wb_sunny_outlined;
    case 'lunch':
      return Icons.lunch_dining_outlined;
    case 'dinner':
      return Icons.nightlight_outlined;
    default:
      return Icons.cookie_outlined;
  }
}

Color _mealTypeColor(String mealType) {
  switch (mealType) {
    case 'breakfast':
      return const Color(0xFFE3A900);
    case 'lunch':
      return AppColors.strawberry;
    case 'dinner':
      return const Color(0xFF8D5A9B);
    default:
      return const Color(0xFF4E8A78);
  }
}
