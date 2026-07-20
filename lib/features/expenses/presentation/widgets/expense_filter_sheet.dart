import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../budget/presentation/providers/budget_provider.dart';
import '../../domain/expense_models.dart';

Future<ExpenseFilter?> showExpenseFilterSheet(
  BuildContext context, {
  required ExpenseFilter current,
}) {
  return showModalBottomSheet<ExpenseFilter>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _ExpenseFilterSheet(current: current),
  );
}

class _ExpenseFilterSheet extends ConsumerStatefulWidget {
  final ExpenseFilter current;
  const _ExpenseFilterSheet({required this.current});

  @override
  ConsumerState<_ExpenseFilterSheet> createState() => _ExpenseFilterSheetState();
}

class _ExpenseFilterSheetState extends ConsumerState<_ExpenseFilterSheet> {
  late DateTime? _from = widget.current.fromDate;
  late DateTime? _to = widget.current.toDate;
  late String? _categoryId = widget.current.categoryId;
  late String? _paymentMethod = widget.current.paymentMethod;
  late bool _descending = widget.current.sortDescending;

  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isFrom ? _from : _to) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _from = picked;
        } else {
          _to = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('ตัวกรอง', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickDate(isFrom: true),
                      child: Text(_from == null ? 'วันที่เริ่มต้น' : '${_from!.day}/${_from!.month}/${_from!.year + 543}'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickDate(isFrom: false),
                      child: Text(_to == null ? 'วันที่สิ้นสุด' : '${_to!.day}/${_to!.month}/${_to!.year + 543}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              categoriesAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
                data: (categories) {
                  return DropdownButtonFormField<String?>(
                    initialValue: _categoryId,
                    decoration: const InputDecoration(labelText: 'หมวดรายจ่าย'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('ทุกหมวด')),
                      ...categories.map(
                        (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                      ),
                    ],
                    onChanged: (v) => setState(() => _categoryId = v),
                  );
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                initialValue: _paymentMethod,
                decoration: const InputDecoration(labelText: 'วิธีชำระเงิน'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('ทุกวิธี')),
                  ...AppConstants.paymentMethods.map(
                    (m) => DropdownMenuItem(value: m, child: Text(AppConstants.paymentMethodLabel(m))),
                  ),
                ],
                onChanged: (v) => setState(() => _paymentMethod = v),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('เรียงวันที่ใหม่ไปเก่า'),
                value: _descending,
                onChanged: (v) => setState(() => _descending = v),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context, const ExpenseFilter());
                      },
                      child: const Text('ล้างตัวกรอง'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          ExpenseFilter(
                            fromDate: _from,
                            toDate: _to,
                            categoryId: _categoryId,
                            paymentMethod: _paymentMethod,
                            searchText: widget.current.searchText,
                            sortDescending: _descending,
                          ),
                        );
                      },
                      child: const Text('ใช้ตัวกรอง'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
