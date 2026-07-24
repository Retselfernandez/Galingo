import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/level_model.dart';
import '../../models/unit_model.dart';
import '../../../core/constants/app_constants.dart';

/// Servicio de contenido mockeado — carga el curso A1 desde assets JSON
class ContentService {
  ContentService._();
  static final ContentService instance = ContentService._();

  final Map<String, LevelModel> _cachedLevels = {};
  final Map<String, dynamic> _lessonCache = {};

  /// Carga el nivel (A1, A2, B1, B2) desde su archivo JSON local correspondiente
  Future<LevelModel> loadLevel(String levelId) async {
    final cleanId = levelId.toUpperCase();
    if (_cachedLevels.containsKey(cleanId)) {
      return _cachedLevels[cleanId]!;
    }

    final String path;
    if (cleanId == 'A2') {
      path = 'assets/content/a2_course.json';
    } else if (cleanId == 'B1') {
      path = 'assets/content/b1_course.json';
    } else if (cleanId == 'B2') {
      path = 'assets/content/b2_course.json';
    } else {
      path = AppConstants.a1CourseJson;
    }

    final jsonString = await rootBundle.loadString(path);
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    final level = LevelModel.fromJson(jsonMap);
    
    // Indexar lecciones en caché para búsquedas O(1)
    for (final unit in level.units) {
      for (final lesson in unit.lessons) {
        _lessonCache[lesson.id] = lesson;
      }
    }

    _cachedLevels[cleanId] = level;
    return level;
  }

  /// Carga todas las unidades de un nivel específico
  Future<List<UnitModel>> loadUnitsForLevel(String levelId) async {
    final level = await loadLevel(levelId);
    return level.units;
  }

  // Deprecado en favor de loadUnitsForLevel, mantenido por compatibilidad
  Future<List<UnitModel>> loadA1Units() async {
    return loadUnitsForLevel('A1');
  }

  /// Encuentra una lección por ID a través del mapa indexado en O(1)
  Future<dynamic> findLessonById(String lessonId) async {
    if (_lessonCache.containsKey(lessonId)) {
      return _lessonCache[lessonId];
    }

    // Pre-cargar todos los niveles conocidos para poblar la caché indexada
    final levels = ['A1', 'A2', 'B1', 'B2'];
    for (final lvlId in levels) {
      try {
        await loadLevel(lvlId);
      } catch (_) {}
    }

    return _lessonCache[lessonId];
  }

  /// Encuentra la unidad padre que contiene una lección determinada (L4)
  Future<UnitModel?> findUnitForLesson(String lessonId) async {
    // Asegurar que todos los niveles están cargados
    final levels = ['A1', 'A2', 'B1', 'B2'];
    for (final lvlId in levels) {
      try {
        await loadLevel(lvlId);
      } catch (_) {}
    }
    for (final level in _cachedLevels.values) {
      for (final unit in level.units) {
        if (unit.lessons.any((l) => l.id == lessonId)) {
          return unit;
        }
      }
    }
    return null;
  }

  /// Invalida la caché (útil para tests)
  void clearCache() {
    _cachedLevels.clear();
    _lessonCache.clear();
  }
}
