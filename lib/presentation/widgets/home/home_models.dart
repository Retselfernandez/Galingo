import '../../../data/models/unit_model.dart';

/// Datos de una parada del Camiño (una unidad) ya resueltos para la UI.
class HomeUnitData {
  final UnitModel unit;
  final int index; // 0-based en la lista de unidades del nivel
  final bool completed;
  final bool unlocked;
  final bool isCurrent;
  final int xp;
  final int minutes;

  const HomeUnitData({
    required this.unit,
    required this.index,
    required this.completed,
    required this.unlocked,
    required this.isCurrent,
    required this.xp,
    required this.minutes,
  });

  int get lessonCount => unit.lessons.length;

  /// XP total de la parada = suma de las recompensas de sus lecciones.
  static int xpOf(UnitModel u) =>
      u.lessons.fold(0, (s, l) => s + l.xpReward);

  /// Minutos estimados = suma de las duraciones de sus lecciones.
  static int minutesOf(UnitModel u) =>
      u.lessons.fold(0, (s, l) => s + l.estimatedMinutes);
}

/// Icono (emoji) por tema de unidad, para las cards del mapa y la lista.
String unitEmoji(int index) {
  const emojis = [
    '👋', '🔤', '🔢', '👨‍👩‍👧', '🎨', '🍽️',
    '🏠', '⏰', '🏙️', '🛍️', '🌦️', '🎭',
  ];
  return emojis[index % emojis.length];
}
