import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotify_with_flutter/common/widgets/media_mode_pill.dart';

void main() {
  testWidgets('media mode pill toggles between audio and video', (tester) async {
    var isVideoSelected = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return MediaModePill(
                isVideoSelected: isVideoSelected,
                onChanged: (value) {
                  setState(() {
                    isVideoSelected = value;
                  });
                },
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Áudio'), findsOneWidget);
    expect(find.text('Vídeo'), findsOneWidget);

    await tester.tap(find.text('Vídeo'));
    await tester.pumpAndSettle();
    expect(isVideoSelected, isTrue);

    await tester.tap(find.text('Áudio'));
    await tester.pumpAndSettle();
    expect(isVideoSelected, isFalse);
  });
}
