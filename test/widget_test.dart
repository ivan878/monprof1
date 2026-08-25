import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monprof/corps/widgets/app_bouton.dart';

void main() {
  testWidgets('the primary action button is usable', (tester) async {
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DefaultButton(
            text: 'Continuer',
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    expect(find.text('Continuer'), findsOneWidget);
    await tester.tap(find.text('Continuer'));
    expect(pressed, isTrue);
  });
}
