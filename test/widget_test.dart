import 'package:flutter_test/flutter_test.dart';

import 'package:sol_app/main.dart';

void main() {
  testWidgets('Sol app boots into onboarding', (WidgetTester tester) async {
    await tester.pumpWidget(const SolApp());
    await tester.pump();

    expect(find.text('Get started'), findsOneWidget);
  });
}
