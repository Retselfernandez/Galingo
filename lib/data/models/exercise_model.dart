/// Tipos de ejercicios disponibles en Galingo
enum ExerciseType {
  multipleChoice,
  fillBlank,
  matching,
  audio,
  translation;

  /// Convierte desde string JSON
  static ExerciseType fromJson(String value) {
    return switch (value) {
      'multiple_choice' => ExerciseType.multipleChoice,
      'fill_blank' => ExerciseType.fillBlank,
      'matching' => ExerciseType.matching,
      'audio' => ExerciseType.audio,
      'translation' => ExerciseType.translation,
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

  // ─── Localizador Dinámico de Ejercicios (Run-time Localization) ──────────


  /// Devuelve el ejercicio con los textos de prompt traducidos.
  /// options/correctAnswer/matchingPairs permanecen en gallego (lengua objetivo).
  ExerciseModel localize(String langCode) {
    final texts = i18n[langCode] ?? i18n['es'];
    if (texts == null) return this;
    return copyWith(
      question: texts['question'] ?? question,
      hint: texts['hint'] ?? hint,
      explanation: texts['explanation'] ?? explanation,
    );
  }

}
