import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../domain/meal_models.dart';
import '../providers/meals_provider.dart';

class MealPreferencesScreen extends ConsumerStatefulWidget {
  const MealPreferencesScreen({super.key});

  @override
  ConsumerState<MealPreferencesScreen> createState() => _MealPreferencesScreenState();
}

class _MealPreferencesScreenState extends ConsumerState<MealPreferencesScreen> {
  final _peopleCtrl = TextEditingController(text: '1');
  final _mealsPerDayCtrl = TextEditingController(text: '3');
  final _dailyBudgetCtrl = TextEditingController();
  final _weeklyBudgetCtrl = TextEditingController();
  final _monthlyBudgetCtrl = TextEditingController();
  final _dislikedCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();

  String _cookingStyle = 'cook';
  String _difficulty = 'easy';
  final Set<String> _equipment = {};
  bool _isSaving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _peopleCtrl.dispose();
    _mealsPerDayCtrl.dispose();
    _dailyBudgetCtrl.dispose();
    _weeklyBudgetCtrl.dispose();
    _monthlyBudgetCtrl.dispose();
    _dislikedCtrl.dispose();
    _allergiesCtrl.dispose();
    super.dispose();
  }

  void _initFrom(MealPreferenceModel? p) {
    if (_initialized || p == null) return;
    _peopleCtrl.text = p.peopleCount.toString();
    _mealsPerDayCtrl.text = p.mealsPerDay.toString();
    if (p.dailyFoodBudget != null) _dailyBudgetCtrl.text = p.dailyFoodBudget!.toStringAsFixed(0);
    if (p.weeklyFoodBudget != null) _weeklyBudgetCtrl.text = p.weeklyFoodBudget!.toStringAsFixed(0);
    if (p.monthlyFoodBudget != null) _monthlyBudgetCtrl.text = p.monthlyFoodBudget!.toStringAsFixed(0);
    _dislikedCtrl.text = p.dislikedFoods.join(', ');
    _allergiesCtrl.text = p.allergies.join(', ');
    _cookingStyle = p.cookingStyle;
    _difficulty = p.preferredDifficulty;
    _equipment
      ..clear()
      ..addAll(p.availableEquipment);
    _initialized = true;
  }

  List<String> _parseCsv(String v) =>
      v.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  Future<void> _submit() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(mealsRepositoryProvider);
      await repo.savePreferences(
        peopleCount: int.tryParse(_peopleCtrl.text.trim()) ?? 1,
        mealsPerDay: int.tryParse(_mealsPerDayCtrl.text.trim()) ?? 3,
        dailyFoodBudget: double.tryParse(_dailyBudgetCtrl.text.trim()),
        weeklyFoodBudget: double.tryParse(_weeklyBudgetCtrl.text.trim()),
        monthlyFoodBudget: double.tryParse(_monthlyBudgetCtrl.text.trim()),
        cookingStyle: _cookingStyle,
        dislikedFoods: _parseCsv(_dislikedCtrl.text),
        allergies: _parseCsv(_allergiesCtrl.text),
        availableEquipment: _equipment.toList(),
        preferredDifficulty: _difficulty,
      );
      ref.invalidate(mealPreferencesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึกการตั้งค่าการกินสำเร็จ')),
        );
      }
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
    final prefsAsync = ref.watch(mealPreferencesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ตั้งค่าการกิน')),
      body: prefsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => ErrorStateView(
          message: AppException.from(e).message,
          onRetry: () => ref.invalidate(mealPreferencesProvider),
        ),
        data: (prefs) {
          _initFrom(prefs);
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _peopleCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'จำนวนคน'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _mealsPerDayCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'มื้อต่อวัน'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dailyBudgetCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'งบอาหารต่อวัน (บาท)'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _weeklyBudgetCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'งบต่อสัปดาห์'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _monthlyBudgetCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'งบต่อเดือน'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'cook', label: Text('ทำเอง')),
                      ButtonSegment(value: 'buy', label: Text('ซื้อ')),
                      ButtonSegment(value: 'mixed', label: Text('ผสม')),
                    ],
                    selected: {_cookingStyle},
                    onSelectionChanged: (s) => setState(() => _cookingStyle = s.first),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('อุปกรณ์ทำอาหารที่มี', style: Theme.of(context).textTheme.titleSmall),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: mealEquipmentOptions.map((e) {
                      final selected = _equipment.contains(e);
                      return FilterChip(
                        label: Text(e),
                        selected: selected,
                        onSelected: (v) => setState(() {
                          if (v) {
                            _equipment.add(e);
                          } else {
                            _equipment.remove(e);
                          }
                        }),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dislikedCtrl,
                    decoration: const InputDecoration(
                      labelText: 'อาหารที่ไม่กิน',
                      helperText: 'คั่นด้วยเครื่องหมายจุลภาค เช่น ผักชี, มะเขือ',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _allergiesCtrl,
                    decoration: const InputDecoration(
                      labelText: 'วัตถุดิบที่แพ้',
                      helperText: 'ระบบจะไม่แนะนำเมนูที่มีวัตถุดิบเหล่านี้',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _difficulty,
                    decoration: const InputDecoration(labelText: 'ระดับความยากที่ชอบ'),
                    items: const [
                      DropdownMenuItem(value: 'easy', child: Text('ง่าย')),
                      DropdownMenuItem(value: 'medium', child: Text('ปานกลาง')),
                      DropdownMenuItem(value: 'hard', child: Text('ยาก')),
                    ],
                    onChanged: (v) => setState(() => _difficulty = v ?? 'easy'),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isSaving ? null : _submit,
                    child: LoadingButtonContent(isLoading: _isSaving, label: 'บันทึก'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
