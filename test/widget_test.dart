import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:galingo/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galingo/data/repositories/hive_repository.dart';

void main() {
  setUpAll(() async {
    // Inicializar Hive usando el wrapper seguro para tests en un directorio temporal
    final tempDir = Directory.systemTemp.createTempSync();
    await HiveRepository.instance.initialize(testPath: tempDir.path);
  });

  testWidgets('Galingo app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: GalingoApp(),
      ),
    );

    // Avanza el reloj virtual del test para consumir el Future.delayed(2.2s) del SplashScreen
    await tester.pump(const Duration(milliseconds: 2500));
    
    // Esperamos a que se asiente la navegación u otras transiciones
    await tester.pumpAndSettle();

    // Verifica que el widget raíz se renderiza correctamente
    expect(find.byType(GalingoApp), findsOneWidget);
  });
}
