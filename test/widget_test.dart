import 'package:flutter_test/flutter_test.dart';

import 'package:unitask_flutter/main.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const UniTaskApp());

    // Verify that the splash screen title appears
    expect(find.text('UniTask = )'), findsOneWidget);
    expect(find.text('A Task Management Application'), findsOneWidget);
  });
}
