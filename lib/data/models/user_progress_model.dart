import '../../core/ml/hlr_engine.dart';

/// Modelo de progreso del usuario — persistido localmente con Hive
class UserProgressModel {
  final List<String> completedLessonIds;
  final List<String> completedUnitIds;
  final int totalXp;
  final String currentLevel;
  final int streakDays;
  final String? lastSessionDate;
  final String userName;
  
  // Parámetros matemáticos del algoritmo adaptativo HLR
  final List<double> theta;
  final List<HlrEvent> hlrEvents;
  // Registro histórico de cada palabra: { wordId: { 's': aciertos, 'f': fallos, 'lastPracticed': ISOString } }
  final Map<String, Map<String, dynamic>> wordRepetitionHistory;

  // Datos históricos para telemetría comparativa MAE (Mean Absolute Error)
  final double hlrErrorSum;
  final double sm2ErrorSum;
  final int telemetryCount;

  const UserProgressModel({
    this.completedLessonIds = const [],
    this.completedUnitIds = const [],
    this.totalXp = 0,
    this.currentLevel = 'A1',
    this.streakDays = 0,
    this.lastSessionDate,
    this.userName = 'Estudante',
    this.theta = HlrEngine.defaultTheta,
    this.hlrEvents = const [],
    this.wordRepetitionHistory = const {},
    this.hlrErrorSum = 0.0,
    this.sm2ErrorSum = 0.0,
    this.telemetryCount = 0,
  });

  /// Progreso inicial para un usuario nuevo
  factory UserProgressModel.initial() => const UserProgressModel(
        currentLevel: 'A1',
        totalXp: 0,
        streakDays: 0,
        theta: HlrEngine.defaultTheta,
        hlrEvents: [],
        wordRepetitionHistory: {},
        hlrErrorSum: 0.0,
        sm2ErrorSum: 0.0,
        telemetryCount: 0,
      );

  factory UserProgressModel.fromJson(Map<String, dynamic> json) {
    // Parsear theta
    final rawTheta = json['theta'] as List<dynamic>?;
    final List<double> parsedTheta = rawTheta != null
        ? rawTheta.map((e) => (e as num).toDouble()).toList()
        : HlrEngine.defaultTheta;

    // Parsear hlrEvents
    final rawEvents = json['hlrEvents'] as List<dynamic>?;
    final List<HlrEvent> parsedEvents = rawEvents != null
        ? rawEvents.map((e) => HlrEvent.fromJson(Map<String, dynamic>.from(e as Map))).toList()
        : [];

    // Parsear wordRepetitionHistory
    final rawHistory = json['wordRepetitionHistory'] as Map<dynamic, dynamic>?;
    final Map<String, Map<String, dynamic>> parsedHistory = rawHistory != null
        ? rawHistory.map((k, v) => MapEntry(k.toString(), Map<String, dynamic>.from(v as Map)))
        : {};

    return UserProgressModel(
      completedLessonIds: (json['completedLessonIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      completedUnitIds: (json['completedUnitIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      totalXp: json['totalXp'] as int? ?? 0,
      currentLevel: json['currentLevel'] as String? ?? 'A1',
      streakDays: json['streakDays'] as int? ?? 0,
      lastSessionDate: json['lastSessionDate'] as String?,
      userName: json['userName'] as String? ?? 'Estudante',
      theta: parsedTheta,
      hlrEvents: parsedEvents,
      wordRepetitionHistory: parsedHistory,
      hlrErrorSum: (json['hlrErrorSum'] as num?)?.toDouble() ?? 0.0,
      sm2ErrorSum: (json['sm2ErrorSum'] as num?)?.toDouble() ?? 0.0,
      telemetryCount: json['telemetryCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'completedLessonIds': completedLessonIds,
        'completedUnitIds': completedUnitIds,
        'totalXp': totalXp,
        'currentLevel': currentLevel,
        'streakDays': streakDays,
        'lastSessionDate': lastSessionDate,
        'userName': userName,
        'theta': theta,
        'hlrEvents': hlrEvents.map((e) => e.toJson()).toList(),
        'wordRepetitionHistory': wordRepetitionHistory,
        'hlrErrorSum': hlrErrorSum,
        'sm2ErrorSum': sm2ErrorSum,
        'telemetryCount': telemetryCount,
      };

  UserProgressModel copyWith({
    List<String>? completedLessonIds,
    List<String>? completedUnitIds,
    int? totalXp,
    String? currentLevel,
    int? streakDays,
    String? lastSessionDate,
    String? userName,
    List<double>? theta,
    List<HlrEvent>? hlrEvents,
    Map<String, Map<String, dynamic>>? wordRepetitionHistory,
    double? hlrErrorSum,
    double? sm2ErrorSum,
    int? telemetryCount,
  }) {
    return UserProgressModel(
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
      completedUnitIds: completedUnitIds ?? this.completedUnitIds,
      totalXp: totalXp ?? this.totalXp,
      currentLevel: currentLevel ?? this.currentLevel,
      streakDays: streakDays ?? this.streakDays,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
      userName: userName ?? this.userName,
      theta: theta ?? this.theta,
      hlrEvents: hlrEvents ?? this.hlrEvents,
      wordRepetitionHistory: wordRepetitionHistory ?? this.wordRepetitionHistory,
      hlrErrorSum: hlrErrorSum ?? this.hlrErrorSum,
      sm2ErrorSum: sm2ErrorSum ?? this.sm2ErrorSum,
      telemetryCount: telemetryCount ?? this.telemetryCount,
    );
  }

  // ─── Métodos de utilidad ──────────────────────────────────────────────────

  bool isLessonCompleted(String lessonId) =>
      completedLessonIds.contains(lessonId);

  bool isUnitCompleted(String unitId) => completedUnitIds.contains(unitId);

  // L5: O(1) Set lookup en lugar de indexOf O(n)
  bool isUnitUnlocked(String unitId, List<String> allUnitIds) {
    final index = allUnitIds.indexOf(unitId);
    if (index <= 0) return true;
    final prevUnitId = allUnitIds[index - 1];
    final completedSet = completedUnitIds.toSet();
    return completedSet.contains(prevUnitId);
  }

  /// Calcula el MAE de HLR
  double get hlrMae => telemetryCount == 0 ? 0.0 : hlrErrorSum / telemetryCount;

  /// Calcula el MAE de SM-2
  double get sm2Mae => telemetryCount == 0 ? 0.0 : sm2ErrorSum / telemetryCount;

  /// Calcula la mejora porcentual de precisión preditiva de HLR frente a SM-2 clásico
  double get maeImprovementPercent {
    if (telemetryCount == 0 || sm2Mae == 0.0) return 0.0;
    // Si HLR tiene menos error, la mejora es positiva
    final diff = sm2Mae - hlrMae;
    return (diff / sm2Mae) * 100.0;
  }
}
