import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../budget/presentation/providers/budget_provider.dart';
import '../../domain/expense_models.dart';
import '../providers/expenses_provider.dart';

class AddEditExpenseScreen extends ConsumerStatefulWidget {
  final String? expenseId;

  const AddEditExpenseScreen({super.key, this.expenseId});

  bool get isEditing => expenseId != null;

  @override
  ConsumerState<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends ConsumerState<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  String? _categoryId;
  String _paymentMethod = 'cash';
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();

  File? _newImageFile;
  String? _existingImageUrl;
  bool _removeExistingImage = false;

  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadExisting();
    }
  }

  Future<void> _loadExisting() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(expensesRepositoryProvider);
      final expense = await repo.fetchById(widget.expenseId!);
      _titleCtrl.text = expense.title;
      _amountCtrl.text = expense.amount.toStringAsFixed(2);
      _noteCtrl.text = expense.note ?? '';
      _categoryId = expense.categoryId;
      _paymentMethod = expense.paymentMethod;
      _date = expense.expenseDate;
      _existingImageUrl = expense.receiptImageUrl;
      if (expense.expenseTime != null) {
        final parts = expense.expenseTime!.split(':');
        if (parts.length >= 2) {
          _time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppException.from(e).message)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 75, // บีบอัดรูปก่อนอัปโหลด
    );
    if (picked != null) {
      setState(() {
        _newImageFile = File(picked.path);
        _removeExistingImage = false;
      });
    }
  }

  Future<void> _scanReceipt() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() {
      _newImageFile = File(picked.path);
      _removeExistingImage = false;
    });

    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await recognizer.processImage(InputImage.fromFilePath(picked.path));
      final text = result.text;
      final amount = _extractReceiptAmount(text);
      if (amount != null) _amountCtrl.text = amount.toStringAsFixed(2);
      if (_titleCtrl.text.trim().isEmpty) {
        final firstLine = text
            .split('\n')
            .map((line) => line.trim())
            .firstWhere((line) => line.isNotEmpty, orElse: () => '');
        if (firstLine.isNotEmpty) _titleCtrl.text = firstLine;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(amount == null ? 'สแกนแล้ว กรุณาตรวจสอบยอดเงิน' : 'สแกนยอดเงินให้แล้ว กรุณาตรวจสอบอีกครั้ง')),
        );
      }
    } finally {
      await recognizer.close();
    }
  }

  double? _extractReceiptAmount(String text) {
    final totalLine = text.split('\n').where((line) => RegExp(r'total|รวม|ยอดสุทธิ', caseSensitive: false).hasMatch(line));
    final source = totalLine.isEmpty ? text : totalLine.join(' ');
    final matches = RegExp(r'(?<!\d)(\d{1,7}(?:[.,]\d{2})?)(?!\d)').allMatches(source);
    final values = matches
        .map((m) => double.tryParse(m.group(1)!.replaceAll(',', '.')))
        .whereType<double>()
        .where((value) => value > 0 && value < 1000000)
        .toList();
    if (values.isEmpty) return null;
    return values.last;
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.document_scanner_outlined),
              title: const Text('สแกนข้อมูลจากใบเสร็จ'),
              subtitle: const Text('ถ่ายรูปแล้วช่วยกรอกชื่อและยอดเงิน'),
              onTap: () {
                Navigator.pop(context);
                _scanReceipt();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('ถ่ายรูป'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('เลือกจากคลังภาพ'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_newImageFile != null || (_existingImageUrl != null && !_removeExistingImage))
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('ลบรูป', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _newImageFile = null;
                    _removeExistingImage = true;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  String? _amountValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'กรุณากรอกจำนวนเงิน';
    final n = double.tryParse(v.trim());
    if (n == null) return 'กรุณากรอกตัวเลขที่ถูกต้อง';
    if (n <= 0) return 'จำนวนเงินต้องมากกว่าศูนย์';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final repo = ref.read(expensesRepositoryProvider);
      String? uploadedImageUrl;

      if (_newImageFile != null) {
        final bytes = await _newImageFile!.readAsBytes();
        uploadedImageUrl = await repo.uploadReceiptImage(bytes);
        // ลบรูปเดิมทิ้งถ้ามีการเปลี่ยนรูปตอนแก้ไข
        if (widget.isEditing && _existingImageUrl != null) {
          await repo.deleteReceiptImageByUrl(_existingImageUrl!);
        }
      } else if (_removeExistingImage && _existingImageUrl != null) {
        await repo.deleteReceiptImageByUrl(_existingImageUrl!);
      }

      final timeStr =
          '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}:00';

      if (widget.isEditing) {
        await repo.updateExpense(
          id: widget.expenseId!,
          title: _titleCtrl.text.trim(),
          amount: double.parse(_amountCtrl.text.trim()),
          categoryId: _categoryId,
          paymentMethod: _paymentMethod,
          note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
          receiptImageUrl: uploadedImageUrl,
          clearReceiptImage: _removeExistingImage && uploadedImageUrl == null,
          expenseDate: _date,
          expenseTime: timeStr,
        );
      } else {
        await repo.createExpense(
          title: _titleCtrl.text.trim(),
          amount: double.parse(_amountCtrl.text.trim()),
          categoryId: _categoryId,
          paymentMethod: _paymentMethod,
          note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
          receiptImageUrl: uploadedImageUrl,
          expenseDate: _date,
          expenseTime: timeStr,
        );
      }

      ref.invalidate(expensesListControllerProvider);
      ref.invalidate(filteredExpenseTotalProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.isEditing ? 'แก้ไขรายจ่ายสำเร็จ' : 'บันทึกรายจ่ายสำเร็จ')),
        );
        context.pop();
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

    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'แก้ไขรายจ่าย' : 'เพิ่มรายจ่าย')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.strawberry, AppColors.strawberry.withValues(alpha: 0.78)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.strawberry.withValues(alpha: 0.22),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.receipt_long_rounded, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.isEditing ? 'แก้ไขรายจ่าย' : 'เพิ่มรายจ่าย',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'บันทึกทุกบาท ให้จัดการเงินง่ายขึ้น',
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.88)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _titleCtrl,
                        decoration: const InputDecoration(labelText: 'ชื่อรายการ'),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'กรุณากรอกชื่อรายการ' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'จำนวนเงิน (บาท)',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        validator: _amountValidator,
                      ),
                      const SizedBox(height: 16),
                      categoriesAsync.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (e, st) => Text(AppException.from(e).message),
                        data: (categories) {
                          return DropdownButtonFormField<String?>(
                            initialValue: _categoryId,
                            decoration: const InputDecoration(labelText: 'หมวดรายจ่าย'),
                            items: categories
                                .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                                .toList(),
                            onChanged: (v) => setState(() => _categoryId = v),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _paymentMethod,
                        decoration: const InputDecoration(labelText: 'วิธีชำระเงิน'),
                        items: AppConstants.paymentMethods
                            .map((m) => DropdownMenuItem(
                                value: m, child: Text(AppConstants.paymentMethodLabel(m))))
                            .toList(),
                        onChanged: (v) => setState(() => _paymentMethod = v ?? 'cash'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickDate,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.strawberry,
                                side: BorderSide(color: AppColors.strawberry.withValues(alpha: 0.45)),
                              ),
                              icon: const Icon(Icons.event),
                              label: Text('${_date.day}/${_date.month}/${_date.year + 543}'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickTime,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.strawberry,
                                side: BorderSide(color: AppColors.strawberry.withValues(alpha: 0.45)),
                              ),
                              icon: const Icon(Icons.access_time),
                              label: Text(_time.format(context)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _noteCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'หมายเหตุ (ไม่บังคับ)'),
                      ),
                      const SizedBox(height: 16),
                      _buildReceiptPicker(),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _isSaving ? null : _submit,
                        child: LoadingButtonContent(
                          isLoading: _isSaving,
                          label: widget.isEditing ? 'บันทึกการแก้ไข' : 'บันทึกรายจ่าย',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildReceiptPicker() {
    final hasImage = _newImageFile != null ||
        (_existingImageUrl != null && !_removeExistingImage);

    return InkWell(
      onTap: _showImageSourceSheet,
      borderRadius: BorderRadius.circular(14),
      child: Container(
      height: 140,
      decoration: BoxDecoration(
          color: AppColors.softPink.withValues(alpha: 0.42),
          border: Border.all(color: AppColors.strawberry.withValues(alpha: 0.58), width: 1.3),
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: hasImage
            ? Stack(
                fit: StackFit.expand,
                children: [
                  _newImageFile != null
                      ? Image.file(_newImageFile!, fit: BoxFit.cover)
                      : Image.network(_existingImageUrl!, fit: BoxFit.cover),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      radius: 14,
                      child: IconButton(
                        icon: const Icon(Icons.edit, size: 14, color: Colors.white),
                        onPressed: _showImageSourceSheet,
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_a_photo_outlined, color: AppColors.strawberry, size: 30),
                    const SizedBox(height: 8),
                    Text('แนบรูปใบเสร็จ (ไม่บังคับ)',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
      ),
    );
  }
}
