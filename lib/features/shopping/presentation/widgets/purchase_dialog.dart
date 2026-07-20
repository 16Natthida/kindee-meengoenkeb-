import 'package:flutter/material.dart';

import '../../domain/shopping_models.dart';

Future<PurchaseConfirmation?> showPurchaseDialog(
  BuildContext context, {
  required double? estimatedPrice,
}) {
  final priceCtrl = TextEditingController(
    text: estimatedPrice != null ? estimatedPrice.toStringAsFixed(0) : '',
  );
  bool addToStock = true;
  bool saveAsExpense = true;
  final formKey = GlobalKey<FormState>();

  return showDialog<PurchaseConfirmation>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('ซื้อแล้ว'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'ราคาจริง (บาท)'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'กรุณากรอกราคาจริง';
                      final n = double.tryParse(v.trim());
                      if (n == null || n < 0) return 'ราคาต้องไม่ติดลบ';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: addToStock,
                    title: const Text('เพิ่มเข้าคลังวัตถุดิบ'),
                    onChanged: (v) => setState(() => addToStock = v ?? false),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: saveAsExpense,
                    title: const Text('บันทึกเป็นรายจ่าย'),
                    onChanged: (v) => setState(() => saveAsExpense = v ?? false),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('ยกเลิก')),
              FilledButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  Navigator.pop(
                    context,
                    PurchaseConfirmation(
                      actualPrice: double.parse(priceCtrl.text.trim()),
                      addToIngredientStock: addToStock,
                      saveAsExpense: saveAsExpense,
                    ),
                  );
                },
                child: const Text('ยืนยัน'),
              ),
            ],
          );
        },
      );
    },
  );
}
