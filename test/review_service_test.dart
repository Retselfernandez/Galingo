import 'package:flutter_test/flutter_test.dart';
import 'package:galingo/core/services/review_service.dart';
import 'package:galingo/data/models/user_progress_model.dart';

void main() {
  UserProgressModel progressWith(Map<String, Map<String, dynamic>> history) =>
      UserProgressModel.initial().copyWith(wordRepetitionHistory: history);

  group('ReviewService.dueItems', () {
    test('un ítem practicado hace 3 días con intervalo 1 está vencido', () {
      final now = DateTime(2026, 10, 15, 12);
      final last = now.subtract(const Duration(days: 3)).toIso8601String();
      final p = progressWith({
        'Ola': {'s': 2, 'f': 0, 'lastPracticed': last, 'sm2_interval': 1},
      });
      final due = ReviewService.instance.dueItems(p, now: now);
      expect(due.length, 1);
      expect(due.first.wordId, 'Ola');
      expect(due.first.overdueDays, greaterThanOrEqualTo(2));
    });

    test('un ítem con intervalo largo no está vencido', () {
      final now = DateTime(2026, 10, 15, 12);
      final last = now.subtract(const Duration(days: 3)).toIso8601String();
      final p = progressWith({
        'Bos días': {'s': 4, 'f': 0, 'lastPracticed': last, 'sm2_interval': 30},
      });
      expect(ReviewService.instance.dueCount(p, now: now), 0);
    });

    test('ordena por antigüedad (más atrasados primero)', () {
      final now = DateTime(2026, 10, 15, 12);
      String ago(int d) => now.subtract(Duration(days: d)).toIso8601String();
      final p = progressWith({
        'A': {'s': 1, 'f': 0, 'lastPracticed': ago(2), 'sm2_interval': 1},
        'B': {'s': 1, 'f': 0, 'lastPracticed': ago(9), 'sm2_interval': 1},
      });
      final due = ReviewService.instance.dueItems(p, now: now);
      expect(due.map((e) => e.wordId).toList(), ['B', 'A']);
    });

    test('historial vacío no genera repasos', () {
      expect(ReviewService.instance.dueCount(UserProgressModel.initial()), 0);
    });
  });
}
