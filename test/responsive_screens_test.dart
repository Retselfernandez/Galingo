import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galingo/data/repositories/hive_repository.dart';
import 'package:galingo/presentation/screens/home/home_screen.dart';
import 'package:galingo/presentation/screens/settings/settings_screen.dart';
import 'package:galingo/presentation/screens/lesson/lesson_screen.dart';
import 'package:galingo/presentation/screens/onboarding/welcome_screen.dart';
import 'package:galingo/presentation/screens/onboarding/name_input_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:galingo/l10n/app_localizations.dart';

Future<void> _pumpAtSizes(
  WidgetTester tester,
  Widget child,
  List<String> errors,
) async {
  for (final size in const [
    Size(360, 640),
    Size(390, 844),
    Size(800, 360),
    Size(768, 1024),
    Size(1366, 768),
    Size(1920, 1080),
  ]) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: child,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 900));
  }
  tester.view.resetPhysicalSize();
  tester.view.resetDevicePixelRatio();
}

void main() {
  setUpAll(() async {
    final tempDir = Directory.systemTemp.createTempSync();
    await HiveRepository.instance.initialize(testPath: tempDir.path);
  });

  group('Responsividad por pantalla', () {
    late List<String> errors;
    setUp(() {
      errors = [];
      final old = FlutterError.onError;
      FlutterError.onError = (d) => errors.add(d.exceptionAsString());
      addTearDown(() => FlutterError.onError = old);
    });

    testWidgets('WelcomeScreen', (tester) async {
      await _pumpAtSizes(tester, const WelcomeScreen(), errors);
      expect(errors, isEmpty, reason: errors.take(2).join('\n---\n'));
    });

    testWidgets('NameInputScreen', (tester) async {
      await _pumpAtSizes(tester, const NameInputScreen(), errors);
      expect(errors, isEmpty, reason: errors.take(2).join('\n---\n'));
    });

    testWidgets('SettingsScreen', (tester) async {
      await _pumpAtSizes(tester, const SettingsScreen(), errors);
      expect(errors, isEmpty, reason: errors.take(2).join('\n---\n'));
    });

    testWidgets('HomeScreen', (tester) async {
      await _pumpAtSizes(tester, const HomeScreen(), errors);
      expect(errors, isEmpty, reason: errors.take(2).join('\n---\n'));
    });

    testWidgets('LessonScreen (lección simple)', (tester) async {
      await _pumpAtSizes(tester, const LessonScreen(lessonId: 'a1_u1_l1'), errors);
      expect(errors, isEmpty, reason: errors.take(2).join('\n---\n'));
    });
  });
}
