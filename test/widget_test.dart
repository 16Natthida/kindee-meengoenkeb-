import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kindee_meengoenkeb/app/theme/app_theme.dart';

void main() {
  testWidgets('app theme renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: Text('กินดี มีเงินเก็บ'),
        ),
      ),
    );

    expect(find.text('กินดี มีเงินเก็บ'), findsOneWidget);
  });
}
