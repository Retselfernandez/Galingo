import 'package:flutter_test/flutter_test.dart';
import 'package:galingo/core/ml/hlr_engine.dart';

void main() {
  group('HLR Engine Mathematics & Formulations Tests', () {
    final theta = HlrEngine.defaultTheta;

    test('estimateHalfLife computes correct values based on features', () {
      // Caso 1: Estudiante nuevo (s=0, f=0, dificultad léxica baja d=0.1)
      final h1 = HlrEngine.estimateHalfLife(
        theta: theta,
        s: 0,
        f: 0,
        d: 0.1,
      );
      // h1 = 2^(0.5 + 0.35*1 - 0.45*1 - 0.25*0.1) = 2^0.375 ≈ 1.2968 días
      expect(h1, closeTo(1.297, 0.01));

      // Caso 2: Estudiante con fallos acumulados (s=0, f=3, d=0.5)
      final h2 = HlrEngine.estimateHalfLife(
        theta: theta,
        s: 0,
        f: 3,
        d: 0.5,
      );
      // h2 = 2^(0.5 + 0.35*1 - 0.45*2 - 0.25*0.5) = 2^(-0.175) ≈ 0.8857 días
      expect(h2, closeTo(0.886, 0.01));

      // Caso 3: Estudiante con aciertos (s=4, f=0, d=0.2)
      final h3 = HlrEngine.estimateHalfLife(
        theta: theta,
        s: 4,
        f: 0,
        d: 0.2,
      );
      // h3 = 2^(0.5 + 0.35*sqrt(5) - 0.45*1 - 0.25*0.2) = 2^(0.7826) ≈ 1.720 días
      expect(h3, closeTo(1.720, 0.01));
    });

    test('estimateRecallProbability behaves correctly over time', () {
      const halfLife = 2.0; // 2 días

      // Al momento del estudio (t=0), probabilidad de recuerdo es 1.0 (100%)
      final p0 = HlrEngine.estimateRecallProbability(halfLife: halfLife, t: 0.0);
      expect(p0, equals(1.0));

      // Transcurrida la mitad de la vida media (t=1), probabilidad es 2^-0.5 ≈ 0.707 (70.7%)
      final p1 = HlrEngine.estimateRecallProbability(halfLife: halfLife, t: 1.0);
      expect(p1, closeTo(0.707, 0.01));

      // Transcurrida exactamente la vida media (t=2), probabilidad es 2^-1 = 0.5 (50%)
      final p2 = HlrEngine.estimateRecallProbability(halfLife: halfLife, t: 2.0);
      expect(p2, equals(0.5));
    });

    test('trainLocalTheta gradient descent decreases the total loss', () {
      final initialTheta = List<double>.from(HlrEngine.defaultTheta);

      // Creamos un dataset de entrenamiento de un usuario:
      // Dos palabras, una fácil practicada con éxito y otra difícil con fallos
      final events = [
        const HlrEvent(wordId: 'w1', d: 0.1, s: 2, f: 0, t: 1.0, p: 1.0),
        const HlrEvent(wordId: 'w2', d: 0.7, s: 0, f: 2, t: 0.5, p: 0.0),
        const HlrEvent(wordId: 'w1', d: 0.1, s: 3, f: 0, t: 3.0, p: 1.0),
        const HlrEvent(wordId: 'w2', d: 0.7, s: 0, f: 3, t: 0.2, p: 0.0),
      ];

      // Calcular pérdida inicial de L2 con regularización
      double calculateLoss(List<double> th) {
        double sumErr = 0;
        for (final e in events) {
          final h = HlrEngine.estimateHalfLife(theta: th, s: e.s, f: e.f, d: e.d);
          final p = HlrEngine.estimateRecallProbability(halfLife: h, t: e.t);
          sumErr += (e.p - p) * (e.p - p);
        }
        double reg = 0;
        for (final w in th) {
          reg += w * w;
        }
        return sumErr + 0.01 * reg;
      }

      final initialLoss = calculateLoss(initialTheta);

      // Entrenar el modelo HLR on-device con gradiente descendente
      final trainedTheta = HlrEngine.trainLocalTheta(
        currentTheta: initialTheta,
        events: events,
        epochs: 50,
        learningRate: 0.05,
      );

      final finalLoss = calculateLoss(trainedTheta);

      // Comprobar que los pesos cambiaron y la pérdida total disminuyó
      print('Loss inicial: $initialLoss');
      print('Loss final: $finalLoss');
      print('Theta inicial: $initialTheta');
      print('Theta entrenado: $trainedTheta');

      expect(finalLoss, lessThan(initialLoss));
    });
  });
}
