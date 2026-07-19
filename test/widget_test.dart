import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aura/app.dart';

void main() {
  testWidgets('AuraApp builds and renders a MaterialApp', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: AuraApp()));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
