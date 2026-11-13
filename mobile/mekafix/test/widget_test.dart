// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mekafix/app.dart';
import 'package:mekafix/state/session.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('shows loading while session is not ready',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SessionState(),
        child: const MekaFixApp(),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
