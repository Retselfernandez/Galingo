import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galingo/presentation/screens/lesson/lesson_screen.dart';

void main() {
  group('InteractiveMatchingWidget Tests', () {
    final List<Map<String, String>> matchingPairs = [
      {'left': 'Ola', 'right': 'Hola'},
      {'left': 'Adeus', 'right': 'Adiós'},
    ];

    testWidgets('Renders all matching cards from columns', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveMatchingWidget(
              matchingPairs: matchingPairs,
              onCompleted: () {},
              isAnswered: false,
            ),
          ),
        ),
      );

      // Comprobar que se pintan las palabras de la izquierda (Gallego)
      expect(find.text('Ola'), findsOneWidget);
      expect(find.text('Adeus'), findsOneWidget);

      // Comprobar que se pintan las palabras de la derecha (Traducción)
      expect(find.text('Hola'), findsOneWidget);
      expect(find.text('Adiós'), findsOneWidget);
    });

    testWidgets('Selects item on tap and triggers callback when all paired', (WidgetTester tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveMatchingWidget(
              matchingPairs: matchingPairs,
              onCompleted: () {
                completed = true;
              },
              isAnswered: false,
            ),
          ),
        ),
      );

      // 1. Emparejamiento 1 incorrecto: 'Ola' (izquierda) con 'Adiós' (derecha)
      await tester.tap(find.text('Ola'));
      await tester.pump();
      await tester.tap(find.text('Adiós'));
      await tester.pump();

      // Al ser incorrecto, no debe marcarse como completado
      expect(completed, isFalse);

      // Esperar a que se limpie el estado de error (600ms)
      await tester.pump(const Duration(milliseconds: 650));

      // 2. Emparejamiento 1 correcto: 'Ola' con 'Hola'
      await tester.tap(find.text('Ola'));
      await tester.pump();
      await tester.tap(find.text('Hola'));
      await tester.pump();

      // Aún no está completado porque falta la otra pareja
      expect(completed, isFalse);

      // 3. Emparejamiento 2 correcto: 'Adeus' con 'Adiós'
      await tester.tap(find.text('Adeus'));
      await tester.pump();
      await tester.tap(find.text('Adiós'));
      await tester.pump();

      // Al emparejar todos, se debe disparar el callback
      expect(completed, isTrue);
    });
  });
}
