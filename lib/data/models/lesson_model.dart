import 'exercise_model.dart';

/// Modelo de lección — contiene una lista de ejercicios
class LessonModel {
  final String id;
  final String title;
  final String description;
  final int xpReward;
  final List<ExerciseModel> exercises;
  final String icon;
  final int estimatedMinutes;

  const LessonModel({
    required this.id,
    required this.title,
    this.description = '',
    this.xpReward = 10,
    this.exercises = const [],
    this.icon = '📖',
    this.estimatedMinutes = 5,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      xpReward: json['xpReward'] as int? ?? 10,
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      icon: json['icon'] as String? ?? '📖',
      estimatedMinutes: json['estimatedMinutes'] as int? ?? 5,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'xpReward': xpReward,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'icon': icon,
        'estimatedMinutes': estimatedMinutes,
      };

  LessonModel copyWith({
    String? id,
    String? title,
    String? description,
    int? xpReward,
    List<ExerciseModel>? exercises,
    String? icon,
    int? estimatedMinutes,
  }) {
    return LessonModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      xpReward: xpReward ?? this.xpReward,
      exercises: exercises ?? this.exercises,
      icon: icon ?? this.icon,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
    );
  }
}
