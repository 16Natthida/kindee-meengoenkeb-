class ExpenseModel {
  final String id;
  final String userId;
  final String? categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final String title;
  final double amount;
  final String paymentMethod;
  final String? note;
  final String? receiptImageUrl;
  final DateTime expenseDate;
  final String? expenseTime;

  const ExpenseModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.paymentMethod,
    required this.expenseDate,
    this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.note,
    this.receiptImageUrl,
    this.expenseTime,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    final categoryMap = map['budget_categories'] as Map<String, dynamic>?;
    return ExpenseModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      categoryId: map['category_id'] as String?,
      categoryName: categoryMap?['name'] as String?,
      categoryIcon: categoryMap?['icon'] as String?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      paymentMethod: map['payment_method'] as String? ?? 'cash',
      note: map['note'] as String?,
      receiptImageUrl: map['receipt_image_url'] as String?,
      expenseDate: DateTime.parse(map['expense_date'] as String),
      expenseTime: map['expense_time'] as String?,
    );
  }
}

class ExpenseFilter {
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? categoryId;
  final String? paymentMethod;
  final String searchText;
  final bool sortDescending;

  const ExpenseFilter({
    this.fromDate,
    this.toDate,
    this.categoryId,
    this.paymentMethod,
    this.searchText = '',
    this.sortDescending = true,
  });

  bool get isActive =>
      fromDate != null ||
      toDate != null ||
      categoryId != null ||
      paymentMethod != null ||
      searchText.isNotEmpty;

  ExpenseFilter copyWith({
    DateTime? fromDate,
    DateTime? toDate,
    String? categoryId,
    String? paymentMethod,
    String? searchText,
    bool? sortDescending,
    bool clearFromDate = false,
    bool clearToDate = false,
    bool clearCategory = false,
    bool clearPaymentMethod = false,
  }) {
    return ExpenseFilter(
      fromDate: clearFromDate ? null : (fromDate ?? this.fromDate),
      toDate: clearToDate ? null : (toDate ?? this.toDate),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      paymentMethod: clearPaymentMethod ? null : (paymentMethod ?? this.paymentMethod),
      searchText: searchText ?? this.searchText,
      sortDescending: sortDescending ?? this.sortDescending,
    );
  }
}
