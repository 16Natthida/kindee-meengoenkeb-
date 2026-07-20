class RecurringExpenseModel {
  final String id;
  final String? categoryId;
  final String title;
  final double amount;
  final String paymentMethod;
  final String? note;
  final String frequency;
  final DateTime nextRunDate;
  final bool isActive;

  const RecurringExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.paymentMethod,
    required this.frequency,
    required this.nextRunDate,
    required this.isActive,
    this.categoryId,
    this.note,
  });

  factory RecurringExpenseModel.fromMap(Map<String, dynamic> map) {
    return RecurringExpenseModel(
      id: map['id'] as String,
      categoryId: map['category_id'] as String?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      paymentMethod: map['payment_method'] as String? ?? 'cash',
      note: map['note'] as String?,
      frequency: map['frequency'] as String? ?? 'monthly',
      nextRunDate: DateTime.parse(map['next_run_date'] as String),
      isActive: map['is_active'] as bool? ?? true,
    );
  }
}
