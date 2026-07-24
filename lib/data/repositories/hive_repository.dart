import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ml/hlr_engine.dart';
import '../../core/ml/sm2_engine.dart';
import '../../core/constants/app_constants.dart';
import '../models/settings_model.dart';
import '../models/user_progress_model.dart';
import 'memory_repository.dart';

/// Implementación de MemoryRepository con Hive
class HiveRepository implements MemoryRepository {
  HiveRepository._();
  static final HiveRepository instance = HiveRepository._();
  static const String _progressKey = 'user_progress';
  static const String _settingsKey = 'app_settings';

  // Clave de respaldo exclusiva para testeo sin almacenamiento seguro nativo
  static const List<int> _testKey = [
    0x3c, 0x1f, 0x9a, 0x82, 0xd4, 0x6e, 0xb7, 0x18,
    0xf0, 0x42, 0xa9, 0x51, 0x3d, 0x8c, 0xe5, 0x2b,
    0x74, 0x03, 0xbc, 0x96, 0xdf, 0x5a, 0xe1, 0x68,
    0x02, 0x27, 0x39, 0x7a, 0xb4, 0xf1, 0x88, 0xce
  ];

  static late Box _progressBox;
  static late Box _settingsBox;

  @override
  Future<void> initialize({String? testPath}) async {
    if (testPath != null) {
      Hive.init(testPath);
    } else {
      await Hive.initFlutter();
    }

    List<int> encryptionKey;

    if (testPath != null) {
      // Entorno de test unitario: usar clave síncrona de pruebas
      encryptionKey = _testKey;
    } else {
      // Entorno de ejecución real: usar Keychain / Keystore dinámico con fallback si no hay provisión
      try {
        const secureStorage = FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );
        final keyString = await secureStorage.read(key: 'galingo_aes_key');
        if (keyString != null) {
          encryptionKey = base64Url.decode(keyString);
        } else {
          final newKey = Hive.generateSecureKey();
          await secureStorage.write(
            key: 'galingo_aes_key',
            value: base64Url.encode(newKey),
          );
          encryptionKey = newKey;
        }
      } on PlatformException catch (e) {
        // Fallback en desarrollo/debug local sin firma de llavero de Apple (Error -34018)
        if (kDebugMode && (e.code == '-34018' || e.message?.contains('-34018') == true)) {
          encryptionKey = _testKey;
        } else {
          rethrow;
        }
      } catch (e) {
        rethrow;
      }
    }

    _progressBox = await Hive.openBox(
      AppConstants.progressBoxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
    _settingsBox = await Hive.openBox(
      AppConstants.settingsBoxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }

  // ─── Progress ───────────────────────────────────────────────────────────────

  @override
  UserProgressModel getProgress() {
    final json = _progressBox.get(_progressKey);
    if (json == null) {
      return UserProgressModel.initial();
    }
    return UserProgressModel.fromJson(Map<String, dynamic>.from(json as Map));
  }

  @override
  Future<void> saveProgress(UserProgressModel progress) async {
    await _progressBox.put(_progressKey, progress.toJson());
  }

  @override
  Future<UserProgressModel> completeLesson({
    required String lessonId,
    required String unitId,
    required int xpEarned,
    required List<String> allLessonIdsInUnit,
    List<HlrEvent>? sessionEvents,
  }) async {
    final current = getProgress();

    final updatedLessons = [
      ...current.completedLessonIds,
      if (!current.completedLessonIds.contains(lessonId)) lessonId,
    ];

    final unitCompleted =
        allLessonIdsInUnit.every((id) => updatedLessons.contains(id));

    final updatedUnits = [
      ...current.completedUnitIds,
      if (unitCompleted && !current.completedUnitIds.contains(unitId)) unitId,
    ];

    // ─── Entrenamiento HLR e Historial de Repetición ───
    List<HlrEvent> updatedHlrEvents = List.from(current.hlrEvents);
    Map<String, Map<String, dynamic>> updatedHistory = Map.from(
      current.wordRepetitionHistory.map((k, v) => MapEntry(k, Map<String, dynamic>.from(v))),
    );
    List<double> updatedTheta = List.from(current.theta);

    double batchHlrErrorSum = 0.0;
    double batchSm2ErrorSum = 0.0;
    int batchTelemetryCount = 0;

    if (sessionEvents != null && sessionEvents.isNotEmpty) {
      final nowStr = DateTime.now().toIso8601String();

      _processTelemetryEvents(
        sessionEvents: sessionEvents,
        currentTheta: current.theta,
        updatedHistory: updatedHistory,
        nowStr: nowStr,
        onErrorAccumulated: (hlrErr, sm2Err) {
          batchHlrErrorSum += hlrErr;
          batchSm2ErrorSum += sm2Err;
          batchTelemetryCount++;
        },
      );

      // Acoplar nuevos eventos de estudio al historial del usuario
      updatedHlrEvents.addAll(sessionEvents);
      if (updatedHlrEvents.length > 200) {
        updatedHlrEvents = updatedHlrEvents.sublist(updatedHlrEvents.length - 200);
      }

      // H1: Reentrenamiento incremental/online — solo con los eventos nuevos de esta sesión,
      // no con el histórico completo. Esto reduce el coste computacional y evita
      // sobreajuste a sesiones antiguas que ya entrenaron el modelo.
      updatedTheta = HlrEngine.trainLocalTheta(
        currentTheta: current.theta,
        events: sessionEvents,
      );
    }

    // Calcular actualización robusta de racha de estudio (streakDays)
    final now = DateTime.now();
    final progressWithStreak = _updateStreakDays(current, now);

    final updated = progressWithStreak.copyWith(
      completedLessonIds: updatedLessons,
      completedUnitIds: updatedUnits,
      totalXp: current.totalXp + xpEarned,
      theta: updatedTheta,
      hlrEvents: updatedHlrEvents,
      wordRepetitionHistory: updatedHistory,
      hlrErrorSum: current.hlrErrorSum + batchHlrErrorSum,
      sm2ErrorSum: current.sm2ErrorSum + batchSm2ErrorSum,
      telemetryCount: current.telemetryCount + batchTelemetryCount,
    );

    await saveProgress(updated);
    return updated;
  }

  // ─── Métodos Auxiliares de Procesamiento (Refactor H2) ─────────────────────

  UserProgressModel _updateStreakDays(UserProgressModel current, DateTime now) {
    int updatedStreak = current.streakDays;
    String? updatedLastSession = current.lastSessionDate;

    if (current.lastSessionDate != null) {
      final lastSession = DateTime.parse(current.lastSessionDate!);
      final nowMidnight = DateTime(now.year, now.month, now.day);
      final lastMidnight = DateTime(lastSession.year, lastSession.month, lastSession.day);
      final differenceInDays = nowMidnight.difference(lastMidnight).inDays;

      if (differenceInDays == 1) {
        updatedStreak = current.streakDays + 1;
      } else if (differenceInDays > 1) {
        updatedStreak = 1; // Racha rota, recomenzar
      }
      updatedLastSession = now.toIso8601String();
    } else {
      updatedStreak = 1; // Primera lección
      updatedLastSession = now.toIso8601String();
    }

    return current.copyWith(
      streakDays: updatedStreak,
      lastSessionDate: updatedLastSession,
    );
  }

  void _processTelemetryEvents({
    required List<HlrEvent> sessionEvents,
    required List<double> currentTheta,
    required Map<String, Map<String, dynamic>> updatedHistory,
    required String nowStr,
    required void Function(double hlrError, double sm2Error) onErrorAccumulated,
  }) {
    for (final event in sessionEvents) {
      final wId = event.wordId;
      final isCorrect = event.p == 1.0;

      // 1. Obtener valores previos para HLR (s, f, t)
      int hlrS = 0;
      int hlrF = 0;
      double t = event.t;

      if (updatedHistory.containsKey(wId)) {
        final stats = updatedHistory[wId]!;
        hlrS = stats['s'] as int? ?? 0;
        hlrF = stats['f'] as int? ?? 0;
      }

      // 2. Estimar probabilidad con HLR
      final double hHatHlr = HlrEngine.estimateHalfLife(
        theta: currentTheta,
        s: hlrS,
        f: hlrF,
        d: event.d,
      );
      final double pHatHlr = HlrEngine.estimateRecallProbability(
        halfLife: hHatHlr,
        t: t,
      );
      final double hlrError = (event.p - pHatHlr).abs();

      // 3. Obtener valores previos para SM-2
      int sm2Rep = 0;
      int sm2Interval = 1;
      double sm2Ef = 2.5;

      if (updatedHistory.containsKey(wId)) {
        final stats = updatedHistory[wId]!;
        sm2Rep = stats['sm2_rep'] as int? ?? 0;
        sm2Interval = stats['sm2_interval'] as int? ?? 1;
        sm2Ef = (stats['sm2_ef'] as num?)?.toDouble() ?? 2.5;
      }

      // 4. Estimar probabilidad con SM-2 (vida media = intervalDays)
      final double pHatSm2 = HlrEngine.estimateRecallProbability(
        halfLife: sm2Interval.toDouble(),
        t: t,
      );
      final double sm2Error = (event.p - pHatSm2).abs();

      onErrorAccumulated(hlrError, sm2Error);

      // 5. Actualizar estado HLR en la caché de historia
      if (updatedHistory.containsKey(wId)) {
        final stats = updatedHistory[wId]!;
        stats['s'] = hlrS + (isCorrect ? 1 : 0);
        stats['f'] = hlrF + (!isCorrect ? 1 : 0);
        stats['lastPracticed'] = nowStr;
      } else {
        updatedHistory[wId] = {
          's': isCorrect ? 1 : 0,
          'f': !isCorrect ? 1 : 0,
          'lastPracticed': nowStr,
        };
      }

      // 6. Simular y actualizar estado SM-2 para la palabra
      final sm2Updates = Sm2Engine.updateSm2State(
        repetitions: sm2Rep,
        easinessFactor: sm2Ef,
        intervalDays: sm2Interval,
        p: event.p,
      );
      final stats = updatedHistory[wId]!;
      stats['sm2_rep'] = sm2Updates['repetitions'];
      stats['sm2_interval'] = sm2Updates['intervalDays'];
      stats['sm2_ef'] = sm2Updates['easinessFactor'];
    }
  }

  @override
  Future<void> resetProgress() async {
    await _progressBox.delete(_progressKey);
    await _settingsBox.delete(_settingsKey);
  }

  // ─── Settings ───────────────────────────────────────────────────────────────

  @override
  SettingsModel getSettings() {
    try {
      final raw = _settingsBox.get(_settingsKey);
      if (raw != null) {
        return SettingsModel.fromJson(Map<String, dynamic>.from(raw as Map));
      }
    } catch (_) {}
    return const SettingsModel();
  }

  @override
  Future<void> saveSettings(SettingsModel settings) async {
    await _settingsBox.put(_settingsKey, settings.toJson());
  }
}

// ─── Riverpod Provider ────────────────────────────────────────────────────────

/// Override de repositorio para tests — asignar antes de crear el ProviderScope.
/// En producción permanece null y se usa HiveRepository.instance.
/// Ejemplo de uso en tests:
///   repositoryOverrideForTest = MyMockRepository();
///   await tester.pumpWidget(ProviderScope(child: MyApp()));
MemoryRepository? repositoryOverrideForTest;

/// Provider global do repositorio de datos.
/// Permite inyección de dependencia en entornos de test (L8).
final repositoryProvider = Provider<MemoryRepository>(
  (ref) => repositoryOverrideForTest ?? HiveRepository.instance,
);
