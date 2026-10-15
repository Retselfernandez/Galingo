import '../../core/ml/hlr_engine.dart';
import '../models/settings_model.dart';
import '../models/user_progress_model.dart';

/// Interface abstracto para todas as operacións de datos
abstract class MemoryRepository {
  UserProgressModel getProgress();
  Future<void> saveProgress(UserProgressModel progress);
  Future<UserProgressModel> completeLesson({
    required String lessonId,
    required String unitId,
    required int xpEarned,
    required List<String> allLessonIdsInUnit,
    List<HlrEvent>? sessionEvents,
  });
  /// Registra una sesión de repaso espaciado (actualiza historial, MAE y theta)
  /// sin marcar lecciones ni otorgar XP.
  Future<UserProgressModel> recordReviewSession({
    required List<HlrEvent> sessionEvents,
  });
  Future<void> resetProgress();

  SettingsModel getSettings();
  Future<void> saveSettings(SettingsModel settings);

  Future<void> initialize();
}
