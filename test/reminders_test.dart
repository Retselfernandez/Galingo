import 'package:flutter_test/flutter_test.dart';
import 'package:galingo/data/models/refran.dart';
import 'package:galingo/data/models/user_progress_model.dart';

void main() {
  group('Refráns', () {
    test('refranForDate é determinista dentro do mesmo día', () {
      final a = refranForDate(DateTime(2026, 10, 23));
      final b = refranForDate(DateTime(2026, 10, 23, 18, 45));
      expect(a.gl, b.gl);
    });

    test('un ciclo completo non repite refráns', () {
      final seen = <String>{};
      final start = DateTime(2026, 1, 1);
      for (var i = 0; i < kRefrans.length; i++) {
        seen.add(refranForDate(start.add(Duration(days: i))).gl);
      }
      expect(seen.length, kRefrans.length);
    });

    test('días consecutivos dan refráns distintos', () {
      expect(
        refranForDate(DateTime(2026, 3, 1)).gl,
        isNot(refranForDate(DateTime(2026, 3, 2)).gl),
      );
    });

    test('todos os refráns teñen tradución', () {
      for (final r in kRefrans) {
        expect(r.gl.trim(), isNotEmpty);
        expect(r.es.trim(), isNotEmpty);
      }
    });
  });

  group('lastLessonDate', () {
    test('gárdase e recupérase do JSON', () {
      final p = const UserProgressModel().copyWith(lastLessonDate: '2026-10-23');
      expect(p.toJson()['lastLessonDate'], '2026-10-23');
      final back = UserProgressModel.fromJson(p.toJson());
      expect(back.lastLessonDate, '2026-10-23');
    });

    test('por defecto é nulo', () {
      expect(const UserProgressModel().lastLessonDate, isNull);
    });
  });
}
