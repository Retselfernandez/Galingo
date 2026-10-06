import 'package:flutter_test/flutter_test.dart';
import 'package:galingo/presentation/widgets/speech/speech_exercise.dart';

void main() {
  group('textSimilarity', () {
    test('igualdad exacta ≈ 1.0', () {
      expect(textSimilarity('Ola, como estás?', 'Ola, como estás?'), closeTo(1.0, 0.01));
    });
    test('con tildes/mayúsculas/puntuación ignora diferencias menores', () {
      expect(textSimilarity('OLA como estas', 'Ola, como estás?'), greaterThan(0.9));
    });
    test('cadenas muy distintas dan score bajo', () {
      expect(textSimilarity('xyz abc', 'Ola, como estás?'), lessThan(0.4));
    });
    test('vacío devuelve 0', () {
      expect(textSimilarity('', 'Ola'), 0.0);
    });
  });
}
