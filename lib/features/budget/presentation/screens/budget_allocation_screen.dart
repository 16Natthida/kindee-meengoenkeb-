import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/extensions/formatting_extensions.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../domain/budget_models.dart';
import '../providers/budget_provider.dart';
import '../widgets/budget_template_sheet.dart';
import '../widgets/category_edit_dialog.dart';

class BudgetAllocationScreen extends ConsumerStatefulWidget {
  const BudgetAllocationScreen({super.key});

  @override
  ConsumerState<BudgetAllocationScreen> createState() => _BudgetAllocationScreenState();
}

class _BudgetAllocationScreenState extends ConsumerState<BudgetAllocationScreen> {
  String _allocationType = 'percentage';
  List<BudgetDraftRow> _rows = [];
  final Map<String, TextEditingController> _controllers = {};
  bool _initialized = false;
  bool _isSaving = false;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(BudgetDraftRow row) {
    return _controllers.putIfAbsent(row.category.id, () {
      final initial = _allocationType == 'percentage' ? row.percentage : row.amount;
      return TextEditingController(text: initial == 0 ? '' : _trimZero(initial));
    });
  }

  String _trimZero(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toString();
  }

  void _initRows(List<dynamic> categories, List<dynamic> existingBudgets) {
    if (_initialized) return;
    final budgetByCategory = {
      for (final b in existingBudgets) (b.categoryId as String): b,
    };
    _rows = categories.map<BudgetDraftRow>((c) {
      final existing = budgetByCategory[c.id];
      return BudgetDraftRow(
        category: c,
        percentage: existing?.percentage ?? 0,
        amount: existing?.amount ?? 0,
      );
    }).toList();
    if (existingBudgets.isNotEmpty) {
      _allocationType = existingBudgets.first.allocationType as String;
    }
    _initialized = true;
  }

  double get _totalPercentage => _rows.fold(0.0, (sum, r) => sum + r.percentage);
  double get _totalFixedAmount => _rows.fold(0.0, (sum, r) => sum + r.amount);

  void _onValueChanged(BudgetDraftRow row, String value, double totalIncome) {
    final n = double.tryParse(value.trim()) ?? 0;
    setState(() {
      if (_allocationType == 'percentage') {
        row.percentage = n < 0 ? 0 : n;
        row.amount = totalIncome * row.percentage / 100;
      } else {
        row.amount = n < 0 ? 0 : n;
      }
    });
  }

  void _applyTemplate(BudgetTemplate template, double totalIncome) {
    final map = template.percentagesByCategoryName;
    setState(() {
      _allocationType = 'percentage';
      for (final row in _rows) {
        final pct = map[row.category.name] ?? 0;
        row.percentage = pct;
        row.amount = totalIncome * pct / 100;
        _controllers[row.category.id]?.text = pct == 0 ? '' : _trimZero(pct);
      }
    });
  }

  Future<void> _addCategory() async {
    final result = await showCategoryEditDialog(context);
    if (result == null) return;
    try {
      final repo = ref.read(budgetRepositoryProvider);
      final newCategory = await repo.createCategory(name: result.name, icon: result.icon);
      setState(() {
        _rows.add(BudgetDraftRow(category: newCategory));
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppException.from(e).message)),
        );
      }
    }
  }

  Future<void> _editCategory(BudgetDraftRow row) async {
    final result = await showCategoryEditDialog(
      context,
      initialName: row.category.name,
      initialIcon: row.category.icon,
    );
    if (result == null) return;
    try {
      final repo = ref.read(budgetRepositoryProvider);
      await repo.updateCategory(
        categoryId: row.category.id,
        name: result.name,
        icon: result.icon,
      );
      ref.invalidate(categoriesProvider);
      setState(() => _initialized = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppException.from(e).message)),
        );
      }
    }
  }

  Future<void> _hideCategory(BudgetDraftRow row) async {
    try {
      final repo = ref.read(budgetRepositoryProvider);
      await repo.updateCategory(categoryId: row.category.id, isHidden: true);
      ref.invalidate(categoriesProvider);
      setState(() {
        _rows.removeWhere((r) => r.category.id == row.category.id);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppException.from(e).message)),
        );
      }
    }
  }

  Future<void> _copyFromPreviousMonth() async {
    final period = ref.read(budgetPeriodProvider);
    final repo = ref.read(budgetRepositoryProvider);
    try {
      final prevBudgets = await repo.fetchPreviousMonthBudgets(
        month: period.month,
        year: period.year,
      );
      if (prevBudgets.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ไม่พบแผนงบของเดือนก่อนหน้า')),
          );
        }
        return;
      }
      final byCategory = {for (final b in prevBudgets) b.categoryId: b};
      final income = await ref.read(currentIncomeProvider.future);
      final totalIncome = income?.total ?? 0;
      setState(() {
        _allocationType = prevBudgets.first.allocationType;
        for (final row in _rows) {
          final prev = byCategory[row.category.id];
          if (prev == null) continue;
          row.percentage = prev.percentage ?? 0;
          row.amount = _allocationType == 'percentage'
              ? totalIncome * row.percentage / 100
              : prev.amount;
          final display = _allocationType == 'percentage' ? row.percentage : row.amount;
          _controllers[row.category.id]?.text = display == 0 ? '' : _trimZero(display);
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppException.from(e).message)),
        );
      }
    }
  }

  Future<void> _save() async {
    final income = await ref.read(currentIncomeProvider.future);
    if (income == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกเงินเดือนก่อนแบ่งงบประมาณ')),
      );
      return;
    }

    if (_allocationType == 'percentage' && (_totalPercentage - 100).abs() > 0.01) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เปอร์เซ็นต์รวมต้องเท่ากับ 100% (ตอนนี้ ${_totalPercentage.toStringAsFixed(2)}%)')),
      );
      return;
    }

    if (_allocationType == 'fixed' && _totalFixedAmount > income.total) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('ยอดแบ่งเกินรายรับ'),
          content: Text(
            'ยอดที่แบ่งไว้ (฿${_totalFixedAmount.toBaht()}) มากกว่ารายรับ (฿${income.total.toBaht()})\nต้องการบันทึกต่อหรือไม่?',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ยกเลิก')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('บันทึกต่อ')),
          ],
        ),
      );
      if (proceed != true) return;
    }

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(budgetRepositoryProvider);
      await repo.saveBudgetAllocation(
        incomeId: income.id,
        rows: _rows,
        allocationType: _allocationType,
      );
      ref.invalidate(currentBudgetsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึกแผนงบประมาณสำเร็จ')),
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
    final categoriesAsync = ref.watch(categoriesProvider);
    final incomeAsync = ref.watch(currentIncomeProvider);
    final budgetsAsync = ref.watch(currentBudgetsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('แบ่งเงินเดือน'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome_outlined),
            tooltip: 'สูตรสำเร็จรูป',
            onPressed: incomeAsync.value == null
                ? null
                : () async {
                    final t = await showBudgetTemplateSheet(context);
                    if (t != null && t != BudgetTemplate.custom) {
                      _applyTemplate(t, incomeAsync.value!.total);
                    }
                  },
          ),
          IconButton(
            icon: const Icon(Icons.content_copy_outlined),
            tooltip: 'คัดลอกจากเดือนก่อน',
            onPressed: _copyFromPreviousMonth,
          ),
        ],
      ),
      body: incomeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => ErrorStateView(
          message: AppException.from(e).message,
          onRetry: () => ref.invalidate(currentIncomeProvider),
        ),
        data: (income) {
          if (income == null) {
            return const EmptyStateView(
              message: 'กรุณากรอกเงินเดือนของเดือนนี้ก่อนแบ่งงบประมาณ',
              icon: Icons.info_outline,
            );
          }

          return categoriesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => ErrorStateView(
              message: AppException.from(e).message,
              onRetry: () => ref.invalidate(categoriesProvider),
            ),
            data: (categories) {
              return budgetsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => ErrorStateView(
                  message: AppException.from(e).message,
                  onRetry: () => ref.invalidate(currentBudgetsProvider),
                ),
                data: (budgets) {
                  _initRows(categories, budgets);

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(value: 'percentage', label: Text('แบบเปอร์เซ็นต์')),
                                ButtonSegment(value: 'fixed', label: Text('กำหนดจำนวนเงินเอง')),
                              ],
                              selected: {_allocationType},
                              onSelectionChanged: (s) {
                                setState(() => _allocationType = s.first);
                              },
                            ),
                            const SizedBox(height: 12),
                            _SummaryBar(
                              allocationType: _allocationType,
                              totalIncome: income.total,
                              totalPercentage: _totalPercentage,
                              totalAmount: _totalFixedAmount,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _rows.length,
                          itemBuilder: (context, index) {
                            final row = _rows[index];
                            final ctrl = _controllerFor(row);
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: CircleAvatar(child: Icon(iconFromName(row.category.icon))),
                                title: Text(row.category.name),
                                subtitle: Text('≈ ฿${row.amount.toBaht()}'),
                                trailing: SizedBox(
                                  width: 110,
                                  child: TextFormField(
                                    controller: ctrl,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(decimal: true),
                                    textAlign: TextAlign.right,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      suffixText: _allocationType == 'percentage' ? '%' : '฿',
                                    ),
                                    onChanged: (v) => _onValueChanged(row, v, income.total),
                                  ),
                                ),
                                onLongPress: () => _editCategory(row),
                                subtitleTextStyle: null,
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _addCategory,
                                icon: const Icon(Icons.add),
                                label: const Text('เพิ่มหมวด'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: _isSaving ? null : _save,
                                child: LoadingButtonContent(
                                  isLoading: _isSaving,
                                  label: 'บันทึกแผนงบ',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  final String allocationType;
  final double totalIncome;
  final double totalPercentage;
  final double totalAmount;

  const _SummaryBar({
    required this.allocationType,
    required this.totalIncome,
    required this.totalPercentage,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (allocationType == 'percentage') {
      final ok = (totalPercentage - 100).abs() <= 0.01;
      return Row(
        children: [
          Icon(ok ? Icons.check_circle : Icons.error_outline,
              color: ok ? Colors.green : theme.colorScheme.error, size: 18),
          const SizedBox(width: 6),
          Text('รวม ${totalPercentage.toStringAsFixed(2)}% จาก 100%'),
        ],
      );
    }
    final unallocated = totalIncome - totalAmount;
    return Text(
      'แบ่งแล้ว ฿${totalAmount.toBaht()} • ยังไม่ได้แบ่ง ฿${unallocated.toBaht()}',
      style: theme.textTheme.bodyMedium,
    );
  }
}
