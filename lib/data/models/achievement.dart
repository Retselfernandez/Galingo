import 'user_progress_model.dart';

/// Logro/insignia desbloqueable segundo o progreso do usuario.
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool Function(UserProgressModel) isUnlocked;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
  });
}

final List<Achievement> appAchievements = [
  Achievement(
    id: 'first_step',
    title: 'Primeiro Paso',
    description: 'Completa a túa primeira lección en Galingo.',
    icon: '👋',
    isUnlocked: (p) => p.completedLessonIds.isNotEmpty,
  ),
  Achievement(
    id: 'streak_3',
    title: 'Racha Inicial',
    description: 'Mantén unha racha de estudo de polo menos 3 días.',
    icon: '🔥',
    isUnlocked: (p) => p.streakDays >= 3,
  ),
  Achievement(
    id: 'xp_100',
    title: 'Superestrela',
    description: 'Consigue un total de 100 puntos de experiencia (XP).',
    icon: '⭐',
    isUnlocked: (p) => p.totalXp >= 100,
  ),
  Achievement(
    id: 'xp_500',
    title: 'Sabio do Galego',
    description: 'Consigue un total de 500 puntos de experiencia (XP).',
    icon: '🧠',
    isUnlocked: (p) => p.totalXp >= 500,
  ),
  // Desactivado temporalmente: A2/B1/B2 no están disponibles en la UI.
  // Achievement(
  //   id: 'polyglot',
  //   title: 'Políglota A2',
  //   description: 'Comeza o camiño de nivel intermedio A2.',
  //   icon: '🎓',
  //   isUnlocked: (p) => p.currentLevel == 'A2' ||
  //       p.currentLevel == 'B1' ||
  //       p.currentLevel == 'B2',
  // ),
];
