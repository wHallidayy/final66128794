import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:final66128794/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(MainApp());
    // Verify splash screen is shown
    expect(find.text('รายงานทุจริต\nเลือกตั้ง'), findsOneWidget);
  });
}
