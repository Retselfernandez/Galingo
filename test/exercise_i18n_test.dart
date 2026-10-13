import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:galingo/data/models/exercise_model.dart';

/// Verifica que los ejercicios del curso están traducidos a los 7 idiomas y que
/// las preguntas se localizan dejando el contenido gallego intacto.
void main() {
  final data =
      jsonDecode(File('assets/content/a1_course.json').readAsStringSync())
          as Map<String, dynamic>;
  final exercises = <ExerciseModel>[];
  for (final u in data['units'] as List) {
    for (final l in (u as Map)['lessons'] as List) {
      for (final e in (l as Map)['exercises'] as List) {
        exercises.add(ExerciseModel.fromJson(e as Map<String, dynamic>));
      }
    }
  }

  const locales = ['en', 'de', 'fr', 'pt', 'it', 'ro', 'zh'];

  test('a maioría dos exercicios teñen tradución nos 7 idiomas', () {
    for (final loc in locales) {
      final n = exercises.where((e) => e.i18n.containsKey(loc)).length;
      expect(n, greaterThanOrEqualTo(exercises.length - 5),
          reason: 'poucas traducións en "$loc": $n/${exercises.length}');
    }
  });

  test('a pregunta localízase e a resposta queda en galego', () {
    final mc = exercises.firstWhere((e) => e.id == '1V01');
    final en = mc.localize('en');
    expect(en.question.toLowerCase(), contains('galician'));
    expect(en.correctAnswer, 'Ola'); // resposta en galego

    final de = mc.localize('de');
    expect(de.question.toLowerCase(), contains('galizisch'));
  });

  test('a pasaxe de lectura mantense en galego', () {
    final rd = exercises.firstWhere((e) => e.id == '1L01');
    final en = rd.localize('en');
    expect(en.question, contains('Read:'));
    expect(en.question, contains('Chámome Ana')); // texto galego intacto
  });

  test('os enunciados fixos tradúcense', () {
    final speech = exercises.firstWhere((e) => e.type == ExerciseType.speech);
    expect(speech.localize('en').question, contains('aloud'));
    final match = exercises.firstWhere((e) => e.type == ExerciseType.matching);
    expect(match.localize('en').question, 'Match.');
  });
}
