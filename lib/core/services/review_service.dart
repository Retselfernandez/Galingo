import 'package:galingo/data/datasources/mock/content_service.dart';
import 'package:galingo/data/models/exercise_model.dart';
import 'package:galingo/data/models/lesson_model.dart';
import 'package:galingo/data/models/user_progress_model.dart';

/// Ítem vencido (pendente de repaso).
class DueItem {
  final String wordId;
  final DateTime nextDue;
  final int overdueDays;

  const DueItem({
    required this.wordId,
    required this.nextDue,
    required this.overdueDays,
  });
}

/// Motor de repetición espaciada: calcula qué ítems están "vencidos" (según el
/// intervalo SM-2 almacenado por palabra) y construye una lección de repaso.
///
/// Esto garantiza que la persona usuaria vuelva a ver los ítems en días
/// sucesivos, generando la secuencia de repasos (s, f, t, p) que necesitan el
/// modelo HLR y la línea base SM-2 para poder evaluarse con datos reales.
class ReviewService {
  ReviewService._();
  static final ReviewService instance = ReviewService._();

  /// Días de intervalo por defecto cuando aún no hay estado SM-2.
  static const double _defaultIntervalDays = 1.0;

  /// Devuelve los ítems vencidos, ordenados por antigüedad (más atrasados primero).
  List<DueItem> dueItems(
    UserProgressModel progress, {
    DateTime? now,
    int max = 12,
  }) {
    final nowT = now ?? DateTime.now();
    final out = <DueItem>[];
    progress.wordRepetitionHistory.forEach((word, stats) {
      final last = stats['lastPracticed'];
      if (last == null) return;
      final lastD = DateTime.tryParse(last.toString());
      if (lastD == null) return;
      final intervalDays =
          (stats['sm2_interval'] as num?)?.toDouble() ?? _defaultIntervalDays;
      final nextDue =
          lastD.add(Duration(minutes: (intervalDays * 1440).round()));
      if (!nextDue.isAfter(nowT)) {
        out.add(DueItem(
          wordId: word,
          nextDue: nextDue,
          overdueDays: nowT.difference(nextDue).inDays,
        ));
      }
    });
    out.sort((a, b) => a.nextDue.compareTo(b.nextDue));
    return out.take(max).toList();
  }

  /// Número total de ítems vencidos.
  int dueCount(UserProgressModel progress, {DateTime? now}) =>
      dueItems(progress, now: now, max: 1 << 30).length;

  /// Construye una lección de repaso con un ejercicio por ítem vencido.
  Future<LessonModel?> buildReviewLesson(List<DueItem> due) async {
    final exercises = <ExerciseModel>[];
    final used = <String>{};
    for (final d in due) {
      final candidates =
          await ContentService.instance.exercisesForWord(d.wordId);
      if (candidates.isEmpty) continue;
      final chosen = candidates.first;
      if (used.add(chosen.id)) exercises.add(chosen);
    }
    if (exercises.isEmpty) return null;
    return LessonModel(
      id: 'review_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Repaso',
      description: 'Ítems que toca repasar hoxe',
      icon: '🔁',
      estimatedMinutes: (exercises.length * 0.3).ceil(),
      exercises: exercises,
    );
  }
}
