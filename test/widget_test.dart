import 'package:flutter_test/flutter_test.dart';

import 'package:interactive_frontend_lab/app.dart';

void main() {
  testWidgets('App shows splash branding', (WidgetTester tester) async {
    await tester.pumpWidget(const FrontendLabApp());
    await tester.pump();

    expect(find.text('Frontend Lab'), findsOneWidget);
    expect(find.text('Learn • Practice • Interview'), findsOneWidget);
  });
}
