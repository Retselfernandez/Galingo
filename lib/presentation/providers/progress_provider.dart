import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ml/hlr_engine.dart';
import '../../core/services/audio_service.dart';
import '../../data/datasources/mock/content_service.dart';
import '../../data/models/unit_model.dart';
import '../../data/models/user_progress_model.dart';
import '../../data/repositories/hive_repository.dart';
import '../../data/repositories/memory_repository.dart';

// ─── Progress Provider ────────────────────────────────────────────────────────

/// Notifier para el progreso del usuario
class ProgressNotifier extends AsyncNotifier<UserProgressModel> {
  MemoryRepository get _repo => ref.read(repositoryProvider);

  @override
  Future<UserProgressModel> build() async {
    return Future.value(_repo.getProgress());
  }

  Future<void> completeLesson({
    required String lessonId,
    required String unitId,
    required int xpEarned,
    required List<String> allLessonIdsInUnit,
    List<HlrEvent>? sessionEvents,
  }) async {
    final current = state.valueOrNull;
    final updated = await _repo.completeLesson(
      lessonId: lessonId,
      unitId: unitId,
      xpEarned: xpEarned,
      allLessonIdsInUnit: allLessonIdsInUnit,
      sessionEvents: sessionEvents,
    );

    if (current != null) {
      if (updated.streakDays > current.streakDays) {
        AudioService.instance.play(SoundEffect.streakKept);
      }
      if (updated.completedUnitIds.length > current.completedUnitIds.length) {
        AudioService.instance.play(SoundEffect.unitUnlocked);
      }
    }

    state = AsyncData(updated);
  }

  Future<void> updateUserName(String name) async {
    final current = state.valueOrNull ?? UserProgressModel.initial();
    final updated = current.copyWith(userName: name);
    await _repo.saveProgress(updated);
    state = AsyncData(updated);
  }

  Future<void> updateCurrentLevel(String level) async {
    final current = state.valueOrNull ?? UserProgressModel.initial();
    final updated = current.copyWith(currentLevel: level);
    await _repo.saveProgress(updated);
    state = AsyncData(updated);
  }

  Future<void> resetProgress() async {
    await _repo.resetProgress();
    state = const AsyncData(UserProgressModel());
  }
}

/// Provider del progreso del usuario
final progressNotifierProvider =
    AsyncNotifierProvider<ProgressNotifier, UserProgressModel>(
  ProgressNotifier.new,
);

// ─── Units Provider ───────────────────────────────────────────────────────────

/// Provider de unidades con estado de desbloqueo
final unitsWithStatusProvider =
    FutureProvider<List<UnitWithStatus>>((ref) async {
  final progress = await ref.watch(progressNotifierProvider.future);
  final units = await ContentService.instance.loadUnitsForLevel(progress.currentLevel);
  final allUnitIds = units.map((u) => u.id).toList();

  return units.map((unit) {
    final isCompleted = progress.isUnitCompleted(unit.id);
    final isUnlocked = progress.isUnitUnlocked(unit.id, allUnitIds);
    return UnitWithStatus(
      unit: unit,
      isCompleted: isCompleted,
      isUnlocked: isUnlocked,
    );
  }).toList();
});

/// Modelo de vista: unidad + estado de progreso
class UnitWithStatus {
  final UnitModel unit;
  final bool isCompleted;
  final bool isUnlocked;

  const UnitWithStatus({
    required this.unit,
    required this.isCompleted,
    required this.isUnlocked,
  });
}
