import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile_bodyguard/main.dart';

void main() {
  testWidgets('Home shows SOS', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: BodyguardApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('SOS'), findsOneWidget);
  });
}
