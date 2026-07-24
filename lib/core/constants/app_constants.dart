/// Constantes globales de la aplicación Galingo
class AppConstants {
  AppConstants._();

  static const String appName = 'Galingo';
  static const String appTagline = 'Aprende galego, paso a paso';

  // Hive Box Names
  static const String progressBoxName = 'galingo_progress';
  static const String userBoxName = 'galingo_user';
  static const String settingsBoxName = 'galingo_settings';

  // Asset Paths
  static const String gabiHappyImage = 'assets/images/gabi_happy.png';
  static const String a1CourseJson = 'assets/content/a1_course.json';

  // XP & Gamification
  static const int xpPerLesson = 10;
  static const int xpPerPerfectLesson = 15;
  static const int streakBonusXp = 5;

  // Niveles
  static const String levelA1 = 'A1';
  static const String levelA2 = 'A2';

  // Timing
  static const Duration exerciseTransitionDuration = Duration(milliseconds: 400);
  static const Duration gabiBounceDuration = Duration(milliseconds: 1800);

  // Diseño - breakpoints para macOS desktop
  static const double maxContentWidth = 800.0;
  static const double sidebarWidth = 300.0;
  static const double minWindowWidth = 500.0;
  static const double minWindowHeight = 700.0;
}
