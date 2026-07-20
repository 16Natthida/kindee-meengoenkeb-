class UserSettingsModel {
  final String id;
  final String userId;
  final String themeMode; // 'light' | 'dark' | 'system'
  final String currency;
  final bool notifyBudgetLow;
  final bool notifyExpiry;

  const UserSettingsModel({
    required this.id,
    required this.userId,
    required this.themeMode,
    required this.currency,
    required this.notifyBudgetLow,
    required this.notifyExpiry,
  });

  factory UserSettingsModel.fromMap(Map<String, dynamic> map) {
    return UserSettingsModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      themeMode: map['theme_mode'] as String? ?? 'system',
      currency: map['currency'] as String? ?? 'THB',
      notifyBudgetLow: map['notify_budget_low'] as bool? ?? true,
      notifyExpiry: map['notify_expiry'] as bool? ?? true,
    );
  }
}

const themeModeOptions = [
  ('light', 'สว่าง'),
  ('dark', 'มืด'),
  ('system', 'ตามระบบ'),
];

const currencyOptions = [
  ('THB', 'บาท (฿)'),
];
