import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../domain/ingredient_models.dart';
import '../providers/ingredients_provider.dart';

class AddEditIngredientScreen extends ConsumerStatefulWidget {
  final String? ingredientId;

  const AddEditIngredientScreen({super.key, this.ingredientId});

  bool get isEditing => ingredientId != null;

  @override
  ConsumerState<AddEditIngredientScreen> createState() => _AddEditIngredientScreenState();
}

class _AddEditIngredientScreenState extends ConsumerState<AddEditIngredientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController(text: '1');
  final _unitCtrl = TextEditingController(text: 'ชิ้น');
  final _minQuantityCtrl = TextEditingController(text: '0');
  final _priceCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  String _category = 'other';
  String _storageLocation = 'fridge';
  DateTime? _purchaseDate;
  DateTime? _expiryDate;

  File? _newImageFile;
  String? _existingImageUrl;
  bool _removeExistingImage = false;

  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) _loadExisting();
  }

  Future<void> _loadExisting() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(ingredientsRepositoryProvider);
      final all = await repo.fetchAll();
      final ingredient = all.firstWhere((i) => i.id == widget.ingredientId);
      _nameCtrl.text = ingredient.name;
      _quantityCtrl.text = _trimZero(ingredient.quantity);
      _unitCtrl.text = ingredient.unit;
      _minQuantityCtrl.text = _trimZero(ingredient.minimumQuantity);
      _priceCtrl.text = ingredient.purchasePrice != null ? _trimZero(ingredient.purchasePrice!) : '';
      _noteCtrl.text = ingredient.note ?? '';
      _category = ingredient.category;
      _storageLocation = ingredient.storageLocation;
      _purchaseDate = ingredient.purchaseDate;
      _expiryDate = ingredient.expiryDate;
      _existingImageUrl = ingredient.imageUrl;
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

  String _trimZero(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _quantityCtrl.dispose();
    _unitCtrl.dispose();
    _minQuantityCtrl.dispose();
    _priceCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 1600, imageQuality: 75);
    if (picked != null) {
      setState(() {
        _newImageFile = File(picked.path);
        _removeExistingImage = false;
      });
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
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

  Future<void> _pickPurchaseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _purchaseDate = picked);
  }

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? (_purchaseDate ?? DateTime.now()),
      firstDate: _purchaseDate ?? DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _expiryDate = picked);
  }

  String? _requiredValidator(String? v) =>
      (v == null || v.trim().isEmpty) ? 'กรุณากรอกข้อมูล' : null;

  String? _nonNegativeValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'กรุณากรอกจำนวน';
    final n = double.tryParse(v.trim());
    if (n == null) return 'กรุณากรอกตัวเลขที่ถูกต้อง';
    if (n < 0) return 'ต้องไม่ติดลบ';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // วันหมดอายุต้องไม่ก่อนวันซื้อ (เตือนแต่ไม่บล็อกตามสเปก)
    if (_purchaseDate != null && _expiryDate != null && _expiryDate!.isBefore(_purchaseDate!)) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('วันหมดอายุก่อนวันที่ซื้อ'),
          content: const Text('วันหมดอายุที่กรอกอยู่ก่อนวันที่ซื้อ ต้องการบันทึกต่อหรือไม่?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ยกเลิก')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('บันทึกต่อ')),
          ],
        ),
      );
      if (proceed != true) return;
    }

    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(ingredientsRepositoryProvider);
      String? uploadedUrl;

      if (_newImageFile != null) {
        final bytes = await _newImageFile!.readAsBytes();
        uploadedUrl = await repo.uploadIngredientImage(bytes);
        if (widget.isEditing && _existingImageUrl != null) {
          await repo.deleteIngredientImageByUrl(_existingImageUrl!);
        }
      } else if (_removeExistingImage && _existingImageUrl != null) {
        await repo.deleteIngredientImageByUrl(_existingImageUrl!);
      }

      final price = _priceCtrl.text.trim().isEmpty ? null : double.tryParse(_priceCtrl.text.trim());

      if (widget.isEditing) {
        await repo.updateIngredient(
          id: widget.ingredientId!,
          name: _nameCtrl.text.trim(),
          category: _category,
          quantity: double.parse(_quantityCtrl.text.trim()),
          unit: _unitCtrl.text.trim(),
          minimumQuantity: double.parse(_minQuantityCtrl.text.trim().isEmpty ? '0' : _minQuantityCtrl.text.trim()),
          purchaseDate: _purchaseDate,
          expiryDate: _expiryDate,
          purchasePrice: price,
          storageLocation: _storageLocation,
          imageUrl: uploadedUrl,
          clearImage: _removeExistingImage && uploadedUrl == null,
          note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        );
      } else {
        await repo.createIngredient(
          name: _nameCtrl.text.trim(),
          category: _category,
          quantity: double.parse(_quantityCtrl.text.trim()),
          unit: _unitCtrl.text.trim(),
          minimumQuantity: double.parse(_minQuantityCtrl.text.trim().isEmpty ? '0' : _minQuantityCtrl.text.trim()),
          purchaseDate: _purchaseDate,
          expiryDate: _expiryDate,
          purchasePrice: price,
          storageLocation: _storageLocation,
          imageUrl: uploadedUrl,
          note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        );
      }

      ref.invalidate(ingredientsListProvider);
      ref.invalidate(allIngredientsProvider);
      ref.invalidate(expiringIngredientsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.isEditing ? 'แก้ไขวัตถุดิบสำเร็จ' : 'เพิ่มวัตถุดิบสำเร็จ')),
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
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'แก้ไขวัตถุดิบ' : 'เพิ่มวัตถุดิบ')),
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
                      _buildImagePicker(),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(labelText: 'ชื่อวัตถุดิบ'),
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _category,
                        decoration: const InputDecoration(labelText: 'ประเภท'),
                        items: ingredientCategoryOptions
                            .map((c) => DropdownMenuItem(value: c.value, child: Text(c.label)))
                            .toList(),
                        onChanged: (v) => setState(() => _category = v ?? 'other'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _quantityCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'จำนวน'),
                              validator: _nonNegativeValidator,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _unitCtrl,
                              decoration: const InputDecoration(labelText: 'หน่วย'),
                              validator: _requiredValidator,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _minQuantityCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'จำนวนขั้นต่ำที่ควรมี',
                          helperText: 'ระบบจะแจ้งเตือน "ใกล้หมด" เมื่อต่ำกว่าค่านี้',
                        ),
                        validator: _nonNegativeValidator,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _storageLocation,
                        decoration: const InputDecoration(labelText: 'สถานที่จัดเก็บ'),
                        items: storageLocationOptions
                            .map((c) => DropdownMenuItem(value: c.value, child: Text(c.label)))
                            .toList(),
                        onChanged: (v) => setState(() => _storageLocation = v ?? 'fridge'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickPurchaseDate,
                              icon: const Icon(Icons.event),
                              label: Text(_purchaseDate == null
                                  ? 'วันที่ซื้อ'
                                  : '${_purchaseDate!.day}/${_purchaseDate!.month}/${_purchaseDate!.year + 543}'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickExpiryDate,
                              icon: const Icon(Icons.event_busy),
                              label: Text(_expiryDate == null
                                  ? 'วันหมดอายุ'
                                  : '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year + 543}'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _priceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'ราคาที่ซื้อ (ไม่บังคับ)'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          final n = double.tryParse(v.trim());
                          if (n == null || n < 0) return 'ราคาต้องไม่ติดลบ';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _noteCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'หมายเหตุ (ไม่บังคับ)'),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _isSaving ? null : _submit,
                        child: LoadingButtonContent(
                          isLoading: _isSaving,
                          label: widget.isEditing ? 'บันทึกการแก้ไข' : 'เพิ่มวัตถุดิบ',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildImagePicker() {
    final hasImage = _newImageFile != null || (_existingImageUrl != null && !_removeExistingImage);
    return InkWell(
      onTap: _showImageSourceSheet,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.antiAlias,
        child: hasImage
            ? (_newImageFile != null
                ? Image.file(_newImageFile!, fit: BoxFit.cover, width: double.infinity)
                : Image.network(_existingImageUrl!, fit: BoxFit.cover, width: double.infinity))
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_a_photo_outlined, color: Theme.of(context).colorScheme.outline),
                    const SizedBox(height: 6),
                    Text('ถ่ายรูปวัตถุดิบ (ไม่บังคับ)', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
      ),
    );
  }
}
