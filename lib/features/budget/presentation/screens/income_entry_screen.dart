import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../providers/budget_provider.dart';

class IncomeEntryScreen extends ConsumerStatefulWidget {
  const IncomeEntryScreen({super.key});

  @override
  ConsumerState<IncomeEntryScreen> createState() => _IncomeEntryScreenState();
}

class _IncomeEntryScreenState extends ConsumerState<IncomeEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _salaryCtrl = TextEditingController();
  final _extraCtrl = TextEditingController(text: '0');
  final _noteCtrl = TextEditingController();
  DateTime _incomeDate = DateTime.now();
  bool _isSaving = false;
  bool _initialized = false;

  static const _thaiMonths = [
    'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
    'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
  ];

  @override
  void dispose() {
    _salaryCtrl.dispose();
    _extraCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  String? _positiveNumberValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'กรุณากรอกจำนวนเงิน';
    final n = double.tryParse(v.trim());
    if (n == null) return 'กรุณากรอกตัวเลขที่ถูกต้อง';
    if (n < 0) return 'จำนวนเงินต้องไม่ติดลบ';
    return null;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _incomeDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _incomeDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final period = ref.read(budgetPeriodProvider);
      final repo = ref.read(budgetRepositoryProvider);
      await repo.saveIncome(
        month: period.month,
        year: period.year,
        salary: double.parse(_salaryCtrl.text.trim()),
        extraIncome: double.parse(_extraCtrl.text.trim().isEmpty ? '0' : _extraCtrl.text.trim()),
        incomeDate: _incomeDate,
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      );
      ref.invalidate(currentIncomeProvider);
      if (mounted) {
        context.push('/budget-allocation');
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
    final period = ref.watch(budgetPeriodProvider);
    final incomeAsync = ref.watch(currentIncomeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('กรอกเงินเดือน')),
      body: incomeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => ErrorStateView(
          message: AppException.from(e).message,
          onRetry: () => ref.invalidate(currentIncomeProvider),
        ),
        data: (income) {
          if (income != null && !_initialized) {
            _salaryCtrl.text = income.salary.toStringAsFixed(0);
            _extraCtrl.text = income.extraIncome.toStringAsFixed(0);
            _noteCtrl.text = income.note ?? '';
            if (income.incomeDate != null) _incomeDate = income.incomeDate!;
            _initialized = true;
          }
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.calendar_month),
                        title: Text('เดือน ${_thaiMonths[period.month - 1]} ${period.year + 543}'),
                        subtitle: const Text('เปลี่ยนเดือนได้จากหน้าหลัก'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _salaryCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'เงินเดือน (บาท)',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      validator: _positiveNumberValidator,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _extraCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'รายรับเพิ่มเติม (บาท)',
                        prefixIcon: Icon(Icons.add_card),
                      ),
                      validator: _positiveNumberValidator,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.event),
                      title: const Text('วันที่ได้รับเงินเดือน'),
                      subtitle: Text('${_incomeDate.day}/${_incomeDate.month}/${_incomeDate.year + 543}'),
                      trailing: TextButton(onPressed: _pickDate, child: const Text('เลือกวันที่')),
                    ),
                    TextFormField(
                      controller: _noteCtrl,
                      decoration: const InputDecoration(labelText: 'หมายเหตุ (ไม่บังคับ)'),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _isSaving ? null : _submit,
                      child: LoadingButtonContent(
                        isLoading: _isSaving,
                        label: 'บันทึกและไปแบ่งงบประมาณ',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
