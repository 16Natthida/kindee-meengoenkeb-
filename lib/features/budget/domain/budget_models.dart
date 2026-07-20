class BudgetCategoryModel {
  final String id;
  final String userId;
  final String name;
  final String icon;
  final bool isDefault;
  final bool isHidden;
  final int sortOrder;

  const BudgetCategoryModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.icon,
    required this.isDefault,
    required this.isHidden,
    required this.sortOrder,
  });

  factory BudgetCategoryModel.fromMap(Map<String, dynamic> map) {
    return BudgetCategoryModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      icon: map['icon'] as String? ?? 'category',
      isDefault: map['is_default'] as bool? ?? false,
      isHidden: map['is_hidden'] as bool? ?? false,
      sortOrder: map['sort_order'] as int? ?? 0,
    );
  }
}

class MonthlyIncomeModel {
  final String id;
  final String userId;
  final int month;
  final int year;
  final double salary;
  final double extraIncome;
  final DateTime? incomeDate;
  final String? note;

  const MonthlyIncomeModel({
    required this.id,
    required this.userId,
    required this.month,
    required this.year,
    required this.salary,
    required this.extraIncome,
    this.incomeDate,
    this.note,
  });

  double get total => salary + extraIncome;

  factory MonthlyIncomeModel.fromMap(Map<String, dynamic> map) {
    return MonthlyIncomeModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      month: map['month'] as int,
      year: map['year'] as int,
      salary: (map['salary'] as num).toDouble(),
      extraIncome: (map['extra_income'] as num).toDouble(),
      incomeDate: map['income_date'] != null
          ? DateTime.parse(map['income_date'] as String)
          : null,
      note: map['note'] as String?,
    );
  }
}

/// วิธีการแบ่งงบของเดือนนั้น ๆ (ผูกกับ 1 หมวด = 1 แถว monthly_budgets)
class MonthlyBudgetModel {
  final String id;
  final String incomeId;
  final String categoryId;
  final String allocationType; // 'percentage' | 'fixed'
  final double? percentage;
  final double amount;

  const MonthlyBudgetModel({
    required this.id,
    required this.incomeId,
    required this.categoryId,
    required this.allocationType,
    required this.amount,
    this.percentage,
  });

  factory MonthlyBudgetModel.fromMap(Map<String, dynamic> map) {
    return MonthlyBudgetModel(
      id: map['id'] as String,
      incomeId: map['income_id'] as String,
      categoryId: map['category_id'] as String,
      allocationType: map['allocation_type'] as String? ?? 'percentage',
      percentage: map['percentage'] != null ? (map['percentage'] as num).toDouble() : null,
      amount: (map['amount'] as num).toDouble(),
    );
  }
}

/// แถวที่ใช้แก้ไขบนหน้าจอ (ยังไม่บันทึก) — รวมข้อมูลหมวด + จำนวนเงิน/เปอร์เซ็นต์
class BudgetDraftRow {
  final BudgetCategoryModel category;
  double percentage;
  double amount;

  BudgetDraftRow({
    required this.category,
    this.percentage = 0,
    this.amount = 0,
  });
}

enum BudgetTemplate { fiftyThirtyTwenty, savingFocus, debtFocus, cheapFood, custom }

extension BudgetTemplateX on BudgetTemplate {
  String get label {
    switch (this) {
      case BudgetTemplate.fiftyThirtyTwenty:
        return 'สูตร 50/30/20';
      case BudgetTemplate.savingFocus:
        return 'สูตรเน้นเงินเก็บ';
      case BudgetTemplate.debtFocus:
        return 'สูตรสำหรับคนมีหนี้';
      case BudgetTemplate.cheapFood:
        return 'สูตรประหยัดค่าอาหาร';
      case BudgetTemplate.custom:
        return 'กำหนดเอง';
    }
  }

  /// เปอร์เซ็นต์ตามชื่อหมวดมาตรฐาน (ต้องตรงกับชื่อที่สร้างจาก Trigger on_auth_user_created)
  Map<String, double> get percentagesByCategoryName {
    switch (this) {
      case BudgetTemplate.fiftyThirtyTwenty:
        return {
          'ค่าใช้จ่ายจำเป็น': 50,
          'ค่าอาหาร': 15,
          'ค่าเดินทาง': 10,
          'ชำระหนี้': 0,
          'เงินเก็บ': 20,
          'เงินฉุกเฉิน': 0,
          'เงินใช้ส่วนตัว': 5,
          'อื่น ๆ': 0,
        };
      case BudgetTemplate.savingFocus:
        return {
          'ค่าใช้จ่ายจำเป็น': 35,
          'ค่าอาหาร': 15,
          'ค่าเดินทาง': 10,
          'ชำระหนี้': 0,
          'เงินเก็บ': 30,
          'เงินฉุกเฉิน': 5,
          'เงินใช้ส่วนตัว': 5,
          'อื่น ๆ': 0,
        };
      case BudgetTemplate.debtFocus:
        return {
          'ค่าใช้จ่ายจำเป็น': 35,
          'ค่าอาหาร': 15,
          'ค่าเดินทาง': 10,
          'ชำระหนี้': 30,
          'เงินเก็บ': 5,
          'เงินฉุกเฉิน': 0,
          'เงินใช้ส่วนตัว': 5,
          'อื่น ๆ': 0,
        };
      case BudgetTemplate.cheapFood:
        return {
          'ค่าใช้จ่ายจำเป็น': 40,
          'ค่าอาหาร': 10,
          'ค่าเดินทาง': 10,
          'ชำระหนี้': 0,
          'เงินเก็บ': 25,
          'เงินฉุกเฉิน': 10,
          'เงินใช้ส่วนตัว': 5,
          'อื่น ๆ': 0,
        };
      case BudgetTemplate.custom:
        return {};
    }
  }
}
