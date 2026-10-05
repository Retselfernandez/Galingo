import 'package:flutter_test/flutter_test.dart';
import 'package:galingo/core/ml/sm2_engine.dart';
import 'package:galingo/data/models/user_progress_model.dart';

void main() {
  group('Sm2Engine & Telemetry Tests', () {
    test('updateSm2State correct response adjusts intervals correctly', () {
      // Primera repetición (n = 0)
      final state1 = Sm2Engine.updateSm2State(
        repetitions: 0,
        easinessFactor: 2.5,
        intervalDays: 1,
        p: 1.0,
      );
      expect(state1['repetitions'], 1);
      expect(state1['intervalDays'], 1);
      expect(state1['easinessFactor'], greaterThanOrEqualTo(2.5));

      // Segunda repetición (n = 1)
      final state2 = Sm2Engine.updateSm2State(
        repetitions: 1,
        easinessFactor: 2.5,
        intervalDays: 1,
        p: 1.0,
      );
      expect(state2['repetitions'], 2);
      expect(state2['intervalDays'], 6);

      // Tercera repetición (n = 2) con factor de facilidad
      final state3 = Sm2Engine.updateSm2State(
        repetitions: 2,
        easinessFactor: 2.5,
        intervalDays: 6,
        p: 1.0,
      );
      expect(state3['repetitions'], 3);
      expect(state3['intervalDays'], 15); // 6 * 2.5 = 15
    });

    test('updateSm2State incorrect response resets repetitions and interval', () {
      final state = Sm2Engine.updateSm2State(
        repetitions: 5,
        easinessFactor: 2.5,
        intervalDays: 30,
        p: 0.0,
      );
      expect(state['repetitions'], 0);
      expect(state['intervalDays'], 1);
      expect(state['easinessFactor'], lessThan(2.5)); // Baja el E-Factor
    });

    test('UserProgressModel telemetry calculations work correctly', () {
      const progress = UserProgressModel(
        hlrErrorSum: 2.0,
        sm2ErrorSum: 4.0,
        telemetryCount: 10,
      );

      // MAE = errorSum / count
      expect(progress.hlrMae, 0.2); // 2 / 10
      expect(progress.sm2Mae, 0.4); // 4 / 10

      // Mejora: ((0.4 - 0.2) / 0.4) * 100 = 50%
      expect(progress.maeImprovementPercent, 50.0);
    });

    test('UserProgressModel handles zero telemetry cases gracefully', () {
      const progress = UserProgressModel(
        hlrErrorSum: 0.0,
        sm2ErrorSum: 0.0,
        telemetryCount: 0,
      );

      expect(progress.hlrMae, 0.0);
      expect(progress.sm2Mae, 0.0);
      expect(progress.maeImprovementPercent, 0.0);
    });
  });
  sm2EdgeCases();
}

void sm2EdgeCases() {
  group('SM-2 Edge Cases', () {
    test('fallo reinicia repeticiones y fuerza intervalo 1', () {
      final st = Sm2Engine.updateSm2State(
        repetitions: 5, easinessFactor: 2.5, intervalDays: 30, p: 0.0,
      );
      expect(st['repetitions'], 0);
      expect(st['intervalDays'], 1);
    });

    test('el factor de facilidad nunca baja de 1.3', () {
      double ef = 1.3;
      for (var i = 0; i < 10; i++) {
        ef = Sm2Engine.updateSm2State(
          repetitions: 0, easinessFactor: ef, intervalDays: 1, p: 0.0,
        )['easinessFactor'] as double;
        expect(ef, greaterThanOrEqualTo(1.3));
      }
    });

    test('acierto mantiene EF >= anterior con q=4', () {
      final st = Sm2Engine.updateSm2State(
        repetitions: 3, easinessFactor: 2.5, intervalDays: 10, p: 1.0,
      );
      expect(st['easinessFactor'] as double, greaterThanOrEqualTo(2.5));
      expect(st['intervalDays'] as int, greaterThanOrEqualTo(10));
    });
  });
}
