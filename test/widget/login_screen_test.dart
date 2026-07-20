import 'package:flutter_test/flutter_test.dart';
import 'package:kindee_meengoenkeb/features/auth/presentation/widgets/auth_validators.dart';

void main() {
  group('AuthValidators', () {
    test('email rejects invalid format', () {
      expect(AuthValidators.email('not-an-email'), isNotNull);
      expect(AuthValidators.email('test@example.com'), isNull);
    });

    test('password requires at least 6 characters', () {
      expect(AuthValidators.password('123'), isNotNull);
      expect(AuthValidators.password('123456'), isNull);
    });

    test('username rejects empty value', () {
      expect(AuthValidators.username(''), isNotNull);
      expect(AuthValidators.username('  '), isNotNull);
      expect(AuthValidators.username('สมชาย'), isNull);
    });
  });
}
