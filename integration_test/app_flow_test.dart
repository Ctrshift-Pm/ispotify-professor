import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:spotify_with_flutter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('smoke flow reaches player and toggles audio video mode', (tester) async {
    final email = 'aluno.meteora.${DateTime.now().millisecondsSinceEpoch}@example.com';

    await app.main();
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Aproveite para ouvir música'), findsOneWidget);
    expect(find.text('Começar'), findsOneWidget);

    await tester.tap(find.text('Começar'));
    await tester.pumpAndSettle();

    expect(find.text('Escolha o tema'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Cadastrar'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);

    await tester.tap(find.text('Cadastrar'));
    await tester.pumpAndSettle();

    final signupFields = find.byType(TextFormField);
    expect(signupFields, findsNWidgets(3));

    await tester.enterText(signupFields.at(0), 'Aluno Meteora');
    await tester.enterText(signupFields.at(1), email);
    await tester.enterText(signupFields.at(2), '123456');
    await tester.tap(find.text('Criar conta'));
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();

    expect(find.text('Início'), findsOneWidget);
    expect(find.text('Biblioteca'), findsOneWidget);

    await tester.tap(find.text('Biblioteca'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Meteora 20').first);
    await tester.pumpAndSettle();

    expect(find.text('Detalhes do álbum'), findsOneWidget);
    expect(find.text('Foreword'), findsOneWidget);

    await tester.tap(find.text('Foreword'));
    await tester.pumpAndSettle();

    expect(find.text('Áudio'), findsOneWidget);
    expect(find.text('Vídeo'), findsOneWidget);

    await tester.tap(find.text('Vídeo'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Áudio'));
    await tester.pumpAndSettle();
  });
}
