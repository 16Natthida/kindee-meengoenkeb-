import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/extensions/formatting_extensions.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../domain/meal_models.dart';
import '../providers/meals_provider.dart';

class AddMealItemScreen extends ConsumerStatefulWidget {
  final String mealPlanId;
  final DateTime mealDate;
  final String mealType;

  const AddMealItemScreen({
    super.key,
    required this.mealPlanId,
    required this.mealDate,
    required this.mealType,
  });

  @override
  ConsumerState<AddMealItemScreen> createState() => _AddMealItemScreenState();
}

class _AddMealItemScreenState extends ConsumerState<AddMealItemScreen> {
  final _searchCtrl = TextEditingController();
  String? _categoryFilter;
  bool _isSaving = false;

  static const _templateCategories = [
    'อาหารเช้า', 'อาหารจานเดียว', 'กับข้าว', 'เมนูประหยัด',
    'เมนูใช้เวลาไม่เกิน 15 นาที', 'เมนูจากไข่', 'เมนูจากไก่', 'เมนูจากหมู',
    'เมนูผัก', 'เมนูที่ใช้ไมโครเวฟ', 'เมนูที่ใช้หม้อหุงข้าว',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _addFromTemplate(MealTemplateModel template) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final prefs = await ref.read(mealPreferencesProvider.future);
      final repo = ref.read(mealsRepositoryProvider);
      await repo.addItem(
        mealPlanId: widget.mealPlanId,
        mealTemplateId: template.id,
        mealDate: widget.mealDate,
        mealType: widget.mealType,
        name: template.name,
        isHomemade: true,
        peopleCount: prefs?.peopleCount ?? 1,
        estimatedPrice: template.estimatedPricePerServing * (prefs?.peopleCount ?? 1),
        prepMinutes: template.prepMinutes,
        difficulty: template.difficulty,
      );
      ref.invalidate(weeklyPlanItemsProvider);
      ref.invalidate(selectedDayItemsProvider);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppException.from(e).message)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _addCustomDialog() async {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    bool isHomemade = true;
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('เพิ่มเมนูเอง'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'ชื่อเมนู'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'กรุณากรอกชื่อเมนู' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'ราคาประมาณ (บาท)'),
                  validator: (v) {
                    final n = double.tryParse(v?.trim() ?? '');
                    if (n == null || n < 0) return 'ราคาไม่ถูกต้อง';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('ทำเอง (ปิด = ซื้อ)'),
                  value: isHomemade,
                  onChanged: (v) => setState(() => isHomemade = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ยกเลิก')),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(context, true);
              },
              child: const Text('เพิ่ม'),
            ),
          ],
        ),
      ),
    );

    if (result != true) return;
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final prefs = await ref.read(mealPreferencesProvider.future);
      final repo = ref.read(mealsRepositoryProvider);
      await repo.addItem(
        mealPlanId: widget.mealPlanId,
        mealDate: widget.mealDate,
        mealType: widget.mealType,
        name: nameCtrl.text.trim(),
        isHomemade: isHomemade,
        peopleCount: prefs?.peopleCount ?? 1,
        estimatedPrice: double.parse(priceCtrl.text.trim()),
      );
      ref.invalidate(weeklyPlanItemsProvider);
      ref.invalidate(selectedDayItemsProvider);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppException.from(e).message)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(mealTemplatesProvider(_categoryFilter));

    return Scaffold(
      appBar: AppBar(title: Text('เพิ่ม${mealTypeLabel(widget.mealType)}')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _addCustomDialog,
        icon: const Icon(Icons.edit_outlined),
        label: const Text('เพิ่มเมนูเอง'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'ค้นหาเมนู',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                ChoiceChip(
                  label: const Text('ทั้งหมด'),
                  selected: _categoryFilter == null,
                  onSelected: (_) => setState(() => _categoryFilter = null),
                ),
                const SizedBox(width: 8),
                ..._templateCategories.map((c) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(c),
                        selected: _categoryFilter == c,
                        onSelected: (_) => setState(() => _categoryFilter = c),
                      ),
                    )),
              ],
            ),
          ),
          Expanded(
            child: templatesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => ErrorStateView(
                message: AppException.from(e).message,
                onRetry: () => ref.invalidate(mealTemplatesProvider(_categoryFilter)),
              ),
              data: (templates) {
                final query = _searchCtrl.text.trim().toLowerCase();
                final filtered = query.isEmpty
                    ? templates
                    : templates.where((t) => t.name.toLowerCase().contains(query)).toList();

                if (filtered.isEmpty) {
                  return const EmptyStateView(message: 'ไม่พบเมนูที่ตรงกับเงื่อนไข');
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final t = filtered[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(t.name),
                        subtitle: Text('${t.category} • ${t.prepMinutes} นาที • ฿${t.estimatedPricePerServing.toBaht()}/คน'),
                        trailing: const Icon(Icons.add_circle_outline),
                        onTap: _isSaving ? null : () => _addFromTemplate(t),
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
