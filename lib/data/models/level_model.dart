import 'unit_model.dart';

/// Modelo de Nivel (A1 o A2) — contiene múltiples unidades
class LevelModel {
  final String id;
  final String title;
  final String description;
  final String color;
  final List<UnitModel> units;
  final int requiredXp;

  const LevelModel({
    required this.id,
    required this.title,
    required this.description,
    this.color = '#1E6BB8',
    this.units = const [],
    this.requiredXp = 0,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      color: json['color'] as String? ?? '#1E6BB8',
      units: (json['units'] as List<dynamic>?)
              ?.map((e) => UnitModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      requiredXp: json['requiredXp'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'color': color,
        'units': units.map((u) => u.toJson()).toList(),
        'requiredXp': requiredXp,
      };
}
