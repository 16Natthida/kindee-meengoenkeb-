import 'package:flutter/material.dart';

class CategoryEditResult {
  final String name;
  final String icon;
  CategoryEditResult({required this.name, required this.icon});
}

const _availableIcons = <String, IconData>{
  'category': Icons.category,
  'home': Icons.home,
  'restaurant': Icons.restaurant,
  'directions_car': Icons.directions_car,
  'credit_card': Icons.credit_card,
  'savings': Icons.savings,
  'health_and_safety': Icons.health_and_safety,
  'person': Icons.person,
  'school': Icons.school,
  'pets': Icons.pets,
  'sports_esports': Icons.sports_esports,
  'checkroom': Icons.checkroom,
};

Future<CategoryEditResult?> showCategoryEditDialog(
  BuildContext context, {
  String? initialName,
  String? initialIcon,
}) {
  final nameCtrl = TextEditingController(text: initialName ?? '');
  String selectedIcon = initialIcon ?? 'category';
  final formKey = GlobalKey<FormState>();

  return showDialog<CategoryEditResult>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(initialName == null ? 'เพิ่มหมวดใหม่' : 'แก้ไขหมวด'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'ชื่อหมวด'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'กรุณากรอกชื่อหมวด' : null,
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('เลือกไอคอน', style: Theme.of(context).textTheme.bodySmall),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableIcons.entries.map((e) {
                      final selected = e.key == selectedIcon;
                      return InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () => setState(() => selectedIcon = e.key),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: selected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: Icon(
                            e.value,
                            color: selected ? Colors.white : null,
                            size: 20,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ยกเลิก'),
              ),
              FilledButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  Navigator.pop(
                    context,
                    CategoryEditResult(name: nameCtrl.text.trim(), icon: selectedIcon),
                  );
                },
                child: const Text('บันทึก'),
              ),
            ],
          );
        },
      );
    },
  );
}

IconData iconFromName(String name) => _availableIcons[name] ?? Icons.category;
