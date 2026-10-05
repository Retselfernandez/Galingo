import 'dart:io';
import 'package:flutter/material.dart';
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

  testWidgets('GalingoApp no tiene overflow en ningún tamaño de pantalla',
      (WidgetTester tester) async {
    final errors = <String>[];
    final oldHandler = FlutterError.onError;
    FlutterError.onError = (d) {
      errors.add(d.exceptionAsString());
      oldHandler?.call(d);
    };

    for (final size in const [
      Size(360, 640),   // móvil pequeño
      Size(390, 844),   // móvil moderno
      Size(800, 360),   // móvil landscape
      Size(768, 1024),  // tablet
      Size(1366, 768),  // laptop
      Size(1920, 1080), // desktop
    ]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        const ProviderScope(child: GalingoApp()),
      );
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();
    }

    FlutterError.onError = oldHandler;
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();

    expect(errors, isEmpty, reason: errors.take(3).join('\n---\n'));
  });
}
