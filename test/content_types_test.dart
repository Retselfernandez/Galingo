import 'package:flutter_test/flutter_test.dart';
import 'package:galingo/data/datasources/mock/content_service.dart';
import 'package:galingo/data/models/exercise_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('A1: los tipos reading/ordering/image se reconocen y son respondibles',
      () async {
    ContentService.instance.clearCache();
    final level = await ContentService.instance.loadLevel('A1');
    final all = [
      for (final u in level.units)
        for (final l in u.lessons) ...l.exercises,
    ];

    // Los tipos especiales deben existir (no degradarse a multipleChoice).
    expect(all.where((e) => e.type == ExerciseType.reading), isNotEmpty);
    expect(all.where((e) => e.type == ExerciseType.ordering), isNotEmpty);
    expect(all.where((e) => e.type == ExerciseType.image), isNotEmpty);

    // Ordenar e imaxe necesitan opciones para poder mostrarse.
    for (final e in all.where((e) => e.type == ExerciseType.ordering)) {
      expect(e.options, isNotEmpty, reason: 'ordering ${e.id} sin palabras');
    }
    for (final e in all.where((e) => e.type == ExerciseType.image)) {
      expect(e.options, isNotEmpty, reason: 'image ${e.id} sin opciones');
    }

    // Ningún ejercicio debe quedar sin forma de responderse:
    // o tiene opciones, o es de un tipo con UI propia.
    for (final e in all) {
      final hasUi = e.options.isNotEmpty ||
          e.type == ExerciseType.translation ||
          e.type == ExerciseType.reading ||
          e.type == ExerciseType.speech ||
          e.type == ExerciseType.matching ||
          e.type == ExerciseType.ordering ||
          (e.type == ExerciseType.fillBlank && e.options.isEmpty);
      expect(hasUi, isTrue, reason: 'ejercicio ${e.id} (${e.type}) sin UI');
    }

    // Los ejercicios de audio (categoría E) deben tener su mp3 asociado.
    final withAudio = all.where((e) => e.audioAsset != null).toList();
    expect(withAudio.length, greaterThanOrEqualTo(81),
        reason: 'faltan audios de ejercicios');
    for (final e in all.where((e) => e.type == ExerciseType.speech)) {
      expect(e.audioAsset, isNotNull, reason: 'dictado ${e.id} sin audio');
    }
  });
}
