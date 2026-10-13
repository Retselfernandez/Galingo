/// Tipos de ejercicios disponibles en Galingo
enum ExerciseType {
  multipleChoice,
  fillBlank,
  matching,
  audio,
  translation,
  speech,
  dictation,
  reading,
  ordering,
  image;

  /// Convierte desde string JSON
  static ExerciseType fromJson(String value) {
    return switch (value) {
      'multiple_choice' => ExerciseType.multipleChoice,
      'fill_blank' => ExerciseType.fillBlank,
      'matching' => ExerciseType.matching,
      'audio' => ExerciseType.audio,
      'translation' => ExerciseType.translation,
      'speech' => ExerciseType.speech,
      'dictation' => ExerciseType.dictation,
      'reading' => ExerciseType.reading,
      'ordering' => ExerciseType.ordering,
      'image' => ExerciseType.image,
      _ => ExerciseType.multipleChoice,
    };
  }

  String toJson() {
    return switch (this) {
      ExerciseType.multipleChoice => 'multiple_choice',
      ExerciseType.fillBlank => 'fill_blank',
      ExerciseType.matching => 'matching',
      ExerciseType.audio => 'audio',
      ExerciseType.translation => 'translation',
      ExerciseType.speech => 'speech',
      ExerciseType.dictation => 'dictation',
      ExerciseType.reading => 'reading',
      ExerciseType.ordering => 'ordering',
      ExerciseType.image => 'image',
    };
  }
}

/// Modelo de ejercicio individual
class ExerciseModel {
  final String id;
  final ExerciseType type;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final List<Map<String, String>> matchingPairs;
  final String? hint;
  final String? audioAsset;
  final String? explanation;
  final int xpReward;
  /// Traducciones de los textos de prompt por idioma: {locale: {question, hint, explanation}}
  final Map<String, Map<String, String>> i18n;

  const ExerciseModel({
    required this.id,
    required this.type,
    required this.question,
    this.options = const [],
    required this.correctAnswer,
    this.matchingPairs = const [],
    this.hint,
    this.audioAsset,
    this.explanation,
    this.xpReward = 5,
    this.i18n = const {},
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String,
      type: ExerciseType.fromJson(json['type'] as String),
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      correctAnswer: json['correctAnswer'] as String,
      matchingPairs: (json['matchingPairs'] as List<dynamic>?)
              ?.map((e) => Map<String, String>.from(e as Map))
              .toList() ??
          [],
      hint: json['hint'] as String?,
      audioAsset: json['audioAsset'] as String?,
      explanation: json['explanation'] as String?,
      xpReward: json['xpReward'] as int? ?? 5,
      i18n: (json['i18n'] as Map<String, dynamic>?)?.map(
            (locale, texts) => MapEntry(
              locale,
              (texts as Map<String, dynamic>).map(
                (k, v) => MapEntry(k, v as String),
              ),
            ),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toJson(),
        'question': question,
        'options': options,
        'correctAnswer': correctAnswer,
        'matchingPairs': matchingPairs,
        'hint': hint,
        'audioAsset': audioAsset,
        'explanation': explanation,
        'xpReward': xpReward,
      };

  ExerciseModel copyWith({
    String? id,
    ExerciseType? type,
    String? question,
    List<String>? options,
    String? correctAnswer,
    List<Map<String, String>>? matchingPairs,
    String? hint,
    String? audioAsset,
    String? explanation,
    int? xpReward,
    Map<String, Map<String, String>>? i18n,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      type: type ?? this.type,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      matchingPairs: matchingPairs ?? this.matchingPairs,
      hint: hint ?? this.hint,
      audioAsset: audioAsset ?? this.audioAsset,
      explanation: explanation ?? this.explanation,
      i18n: i18n ?? this.i18n,
      xpReward: xpReward ?? this.xpReward,
    );
  }


  // ─── Localizador de ejercicios (i18n pre-generado) ───────────────────────
  // Las traducciones de enunciados/explicaciones viven en `i18n[locale]`
  // (generadas con tool/i18n_exercises.py). El contenido gallego (respuestas,
  // opciones, pasajes, palabras citadas) se mantiene en gallego.

  static const String _optSep = '\u0001'; // separa opciones / izquierda·derecha
  static const String _pairSep = '\u0002'; // separa pares

  /// Devuelve el ejercicio con los textos traducidos al idioma indicado.
  /// options/correctAnswer/matchingPairs solo cambian si hay traducción
  /// explícita (p. ej. opciones de significado en castellano); por defecto,
  /// el contenido se conserva en gallego (lengua objetivo).
  ExerciseModel localize(String langCode) {
    final texts = i18n[langCode];
    if (texts == null) return this;

    final optionsStr = texts['options'];
    final answerStr = texts['correctAnswer'];
    final pairsStr = texts['pairs'];

    return copyWith(
      question: texts['question'] ?? question,
      explanation: texts['explanation'] ?? explanation,
      hint: texts['hint'] ?? hint,
      options: optionsStr != null ? optionsStr.split(_optSep) : options,
      correctAnswer: answerStr ?? correctAnswer,
      matchingPairs: pairsStr != null ? _parsePairs(pairsStr) : matchingPairs,
    );
  }

  List<Map<String, String>> _parsePairs(String s) {
    return s
        .split(_pairSep)
        .where((p) => p.isNotEmpty)
        .map((p) {
      final parts = p.split(_optSep);
      return {
        'left': parts.isNotEmpty ? parts[0] : '',
        'right': parts.length > 1 ? parts[1] : '',
      };
    }).toList();
  }
}
