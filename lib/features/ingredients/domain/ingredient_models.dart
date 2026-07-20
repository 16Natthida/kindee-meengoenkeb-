enum IngredientStatus { available, low, expiringSoon, expired, outOfStock }

extension IngredientStatusX on IngredientStatus {
  String get label {
    switch (this) {
      case IngredientStatus.available:
        return 'ยังใช้ได้';
      case IngredientStatus.low:
        return 'ใกล้หมด';
      case IngredientStatus.expiringSoon:
        return 'ใกล้หมดอายุ';
      case IngredientStatus.expired:
        return 'หมดอายุแล้ว';
      case IngredientStatus.outOfStock:
        return 'หมดแล้ว';
    }
  }
}

class IngredientModel {
  final String id;
  final String userId;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final double minimumQuantity;
  final DateTime? purchaseDate;
  final DateTime? expiryDate;
  final double? purchasePrice;
  final String storageLocation;
  final String? imageUrl;
  final String? note;

  const IngredientModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.minimumQuantity,
    required this.storageLocation,
    this.purchaseDate,
    this.expiryDate,
    this.purchasePrice,
    this.imageUrl,
    this.note,
  });

  /// คำนวณสถานะแบบสดจากข้อมูลปัจจุบัน (ไม่พึ่งค่า status ที่บันทึกไว้เก่า)
  IngredientStatus get computedStatus {
    if (quantity <= 0) return IngredientStatus.outOfStock;
    if (expiryDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final expiry = DateTime(expiryDate!.year, expiryDate!.month, expiryDate!.day);
      if (expiry.isBefore(today)) return IngredientStatus.expired;
      if (expiry.difference(today).inDays <= 3) return IngredientStatus.expiringSoon;
    }
    if (quantity <= minimumQuantity) return IngredientStatus.low;
    return IngredientStatus.available;
  }

  factory IngredientModel.fromMap(Map<String, dynamic> map) {
    return IngredientModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      category: map['category'] as String? ?? 'other',
      quantity: (map['quantity'] as num).toDouble(),
      unit: map['unit'] as String,
      minimumQuantity: (map['minimum_quantity'] as num?)?.toDouble() ?? 0,
      storageLocation: map['storage_location'] as String? ?? 'fridge',
      purchaseDate: map['purchase_date'] != null
          ? DateTime.parse(map['purchase_date'] as String)
          : null,
      expiryDate:
          map['expiry_date'] != null ? DateTime.parse(map['expiry_date'] as String) : null,
      purchasePrice:
          map['purchase_price'] != null ? (map['purchase_price'] as num).toDouble() : null,
      imageUrl: map['image_url'] as String?,
      note: map['note'] as String?,
    );
  }
}

class IngredientCategoryOption {
  final String value;
  final String label;
  const IngredientCategoryOption(this.value, this.label);
}

const ingredientCategoryOptions = [
  IngredientCategoryOption('meat', 'เนื้อสัตว์'),
  IngredientCategoryOption('egg', 'ไข่'),
  IngredientCategoryOption('vegetable', 'ผัก'),
  IngredientCategoryOption('fruit', 'ผลไม้'),
  IngredientCategoryOption('seasoning', 'เครื่องปรุง'),
  IngredientCategoryOption('dry_food', 'อาหารแห้ง'),
  IngredientCategoryOption('frozen_food', 'อาหารแช่แข็ง'),
  IngredientCategoryOption('beverage', 'เครื่องดื่ม'),
  IngredientCategoryOption('other', 'อื่น ๆ'),
];

String ingredientCategoryLabel(String value) {
  return ingredientCategoryOptions
      .firstWhere((o) => o.value == value, orElse: () => const IngredientCategoryOption('other', 'อื่น ๆ'))
      .label;
}

const storageLocationOptions = [
  IngredientCategoryOption('fridge', 'ตู้เย็น'),
  IngredientCategoryOption('freezer', 'ช่องแช่แข็ง'),
  IngredientCategoryOption('shelf', 'ชั้นวางของ'),
  IngredientCategoryOption('kitchen', 'ห้องครัว'),
  IngredientCategoryOption('other', 'อื่น ๆ'),
];

String storageLocationLabel(String value) {
  return storageLocationOptions
      .firstWhere((o) => o.value == value, orElse: () => const IngredientCategoryOption('other', 'อื่น ๆ'))
      .label;
}

class IngredientFilter {
  final String? category;
  final IngredientStatus? status;
  final String searchText;
  final bool sortByExpiry;

  const IngredientFilter({
    this.category,
    this.status,
    this.searchText = '',
    this.sortByExpiry = false,
  });

  IngredientFilter copyWith({
    String? category,
    IngredientStatus? status,
    String? searchText,
    bool? sortByExpiry,
    bool clearCategory = false,
    bool clearStatus = false,
  }) {
    return IngredientFilter(
      category: clearCategory ? null : (category ?? this.category),
      status: clearStatus ? null : (status ?? this.status),
      searchText: searchText ?? this.searchText,
      sortByExpiry: sortByExpiry ?? this.sortByExpiry,
    );
  }
}
