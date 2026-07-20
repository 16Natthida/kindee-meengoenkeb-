import 'package:flutter_test/flutter_test.dart';
import 'package:kindee_meengoenkeb/features/settings/domain/settings_models.dart';

void main() {
  group('UserSettingsModel.fromMap', () {
    test('parses full row correctly', () {
      final settings = UserSettingsModel.fromMap({
        'id': 's1',
        'user_id': 'u1',
        'theme_mode': 'dark',
        'currency': 'THB',
        'notify_budget_low': false,
        'notify_expiry': true,
      });

      expect(settings.themeMode, 'dark');
      expect(settings.currency, 'THB');
      expect(settings.notifyBudgetLow, isFalse);
      expect(settings.notifyExpiry, isTrue);
    });

    test('falls back to safe defaults when fields are missing', () {
      final settings = UserSettingsModel.fromMap({
        'id': 's1',
        'user_id': 'u1',
      });

      expect(settings.themeMode, 'system');
      expect(settings.currency, 'THB');
      expect(settings.notifyBudgetLow, isTrue);
      expect(settings.notifyExpiry, isTrue);
    });
  });

  group('themeModeOptions / currencyOptions', () {
    test('theme mode options cover light/dark/system', () {
      final values = themeModeOptions.map((o) => o.$1).toList();
      expect(values, containsAll(['light', 'dark', 'system']));
    });

    test('currency options include THB', () {
      final values = currencyOptions.map((o) => o.$1).toList();
      expect(values, contains('THB'));
    });
  });
}
