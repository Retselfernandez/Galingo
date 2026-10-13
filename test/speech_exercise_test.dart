import 'package:flutter_test/flutter_test.dart';
import 'package:galingo/core/services/asr_service.dart';

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
    test('tolerante a díxitos e fonética galego/portugués (ASR on-device)', () {
      expect(
          textSimilarity('A casa ten tres cuartos.', 'Acá saten 3/4.'),
          greaterThanOrEqualTo(0.65));
      expect(textSimilarity('Levántome ás sete.', 'Levanto má 7.'),
          greaterThanOrEqualTo(0.65));
      expect(textSimilarity('A miña nai', 'Aminha na.'),
          greaterThanOrEqualTo(0.65));
    });
    test('frase distinta non aproba', () {
      expect(textSimilarity('Fai sol.', 'Vivo nun piso.'), lessThan(0.65));
      expect(textSimilarity('Teño fame.', 'Quero unha camiseta azul.'),
          lessThan(0.65));
    });
  });
}
