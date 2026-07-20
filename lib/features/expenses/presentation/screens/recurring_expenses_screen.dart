import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../data/expenses_repository.dart';
import '../providers/expenses_provider.dart';
import '../providers/recurring_expenses_provider.dart';

class RecurringExpensesScreen extends ConsumerWidget {
  const RecurringExpensesScreen({super.key});

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final title = TextEditingController();
    final amount = TextEditingController();
    var frequency = 'monthly';
    var nextDate = DateTime.now();
    final formKey = GlobalKey<FormState>();
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('เพิ่มรายจ่ายประจำ'),
          content: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(
                controller: title,
                decoration: const InputDecoration(labelText: 'ชื่อรายการ'),
                validator: (v) => v == null || v.trim().isEmpty ? 'กรุณากรอกชื่อรายการ' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: amount,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'จำนวนเงิน'),
                validator: (v) => double.tryParse(v?.trim() ?? '') == null ? 'กรุณากรอกจำนวนเงิน' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: frequency,
                decoration: const InputDecoration(labelText: 'ความถี่'),
                items: const [
                  DropdownMenuItem(value: 'monthly', child: Text('ทุกเดือน')),
                  DropdownMenuItem(value: 'weekly', child: Text('ทุกสัปดาห์')),
                ],
                onChanged: (v) => setState(() => frequency = v ?? 'monthly'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('เริ่มสร้างรายการวันที่'),
                subtitle: Text(_dateLabel(nextDate)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                    initialDate: nextDate,
                  );
                  if (picked != null) setState(() => nextDate = picked);
                },
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('ยกเลิก')),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                await ref.read(expensesRepositoryProvider).createRecurringExpense(
                      title: title.text.trim(),
                      amount: double.parse(amount.text.trim()),
                      paymentMethod: 'other',
                      frequency: frequency,
                      nextRunDate: nextDate,
                    );
                if (dialogContext.mounted) Navigator.pop(dialogContext, true);
              },
              child: const Text('บันทึก'),
            ),
          ],
        ),
      ),
    );
    title.dispose();
    amount.dispose();
    if (saved == true) ref.invalidate(recurringExpensesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recurring = ref.watch(recurringExpensesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('รายจ่ายประจำ')),
      floatingActionButton: FloatingActionButton(onPressed: () => _add(context, ref), child: const Icon(Icons.add)),
      body: recurring.when(
        loading: () => const DashboardSkeleton(),
        error: (e, _) => ErrorStateView(message: AppException.from(e).message, onRetry: () => ref.invalidate(recurringExpensesProvider)),
        data: (items) => items.isEmpty
            ? const EmptyStateView(message: 'ยังไม่มีรายจ่ายประจำ', icon: Icons.repeat)
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.repeat)),
                      title: Text(item.title),
                      subtitle: Text('${item.amount.toStringAsFixed(2)} บาท • ${item.frequency == 'monthly' ? 'ทุกเดือน' : 'ทุกสัปดาห์'}\nครั้งถัดไป ${_dateLabel(item.nextRunDate)}'),
                      isThreeLine: true,
                      trailing: Switch(
                        value: item.isActive,
                        onChanged: (active) async {
                          await ref.read(expensesRepositoryProvider).toggleRecurringExpense(id: item.id, active: active);
                          ref.invalidate(recurringExpensesProvider);
                        },
                      ),
                      onLongPress: () async {
                        await ref.read(expensesRepositoryProvider).deleteRecurringExpense(item.id);
                        ref.invalidate(recurringExpensesProvider);
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}

String _dateLabel(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
