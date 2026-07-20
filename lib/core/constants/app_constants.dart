class AppConstants {
  AppConstants._();

  static const String appName = 'กินดี มีเงินเก็บ';

  // Storage buckets
  static const String receiptBucket = 'receipts';
  static const String ingredientBucket = 'ingredient-images';

  // Budget status thresholds
  static const double budgetNormalMax = 0.70;
  static const double budgetWarningMax = 0.90;
  static const double budgetDangerMax = 1.00;

  // Payment methods
  static const List<String> paymentMethods = [
    'cash',
    'transfer',
    'debit_card',
    'credit_card',
    'promptpay',
    'other',
  ];

  static String paymentMethodLabel(String value) {
    switch (value) {
      case 'cash':
        return 'เงินสด';
      case 'transfer':
        return 'โอนเงิน';
      case 'debit_card':
        return 'บัตรเดบิต';
      case 'credit_card':
        return 'บัตรเครดิต';
      case 'promptpay':
        return 'พร้อมเพย์';
      default:
        return 'อื่น ๆ';
    }
  }
}
