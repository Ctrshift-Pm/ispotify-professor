import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotify_with_flutter/core/routes/app_routes.dart';

void main() {
  testWidgets('Splash page moves to get started after delay', (
      WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
      ),
    );

    expect(find.text('Aproveite para ouvir música'), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Aproveite para ouvir música'), findsOneWidget);
    expect(find.text('Começar'), findsOneWidget);
  });
}
