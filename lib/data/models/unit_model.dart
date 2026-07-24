import 'lesson_model.dart';

/// Modelo de Unidad — agrupa varias lecciones relacionadas
class UnitModel {
  final String id;
  final String title;
  final String level;
  final String description;
  final String icon;
  final String accentColor;
  final List<LessonModel> lessons;
  final int order;

  const UnitModel({
    required this.id,
    required this.title,
    required this.level,
    this.description = '',
    this.icon = '📚',
    this.accentColor = '#1E6BB8',
    this.lessons = const [],
    this.order = 0,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'] as String,
      title: json['title'] as String,
      level: json['level'] as String,
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? '📚',
      accentColor: json['accentColor'] as String? ?? '#1E6BB8',
      lessons: (json['lessons'] as List<dynamic>?)
              ?.map((e) => LessonModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'level': level,
        'description': description,
        'icon': icon,
        'accentColor': accentColor,
        'lessons': lessons.map((l) => l.toJson()).toList(),
        'order': order,
      };
}
