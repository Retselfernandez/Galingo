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

  // Voz / ASR (speech_to_text)
  /// Similitud mínima (Levenshtein) para aprobar un ejercicio de voz.
  /// No es 1.0 porque el ASR puede no tener gallego y transcribir con ruido.
  static const double speechPassThreshold = 0.7;
  /// Umbral para el mensaje intermedio ("case").
  static const double speechAlmostThreshold = 0.5;

  // Niveles
  static const String levelA1 = 'A1';
  static const String levelA2 = 'A2';

  /// Niveles habilitados actualmente en el desarrollo.
  /// A2/B1/B2 están desactivados temporalmente (contenido en pausa);
  /// sus JSON se conservan pero no se muestran en la UI.
  static const List<String> enabledLevels = <String>[levelA1];

  /// ¿Hay más de un nivel disponible para cambiar desde la UI?
  static bool get hasMultipleLevels => enabledLevels.length > 1;

  // Timing
  static const Duration exerciseTransitionDuration = Duration(milliseconds: 400);
  static const Duration gabiBounceDuration = Duration(milliseconds: 1800);

  // Diseño - breakpoints para macOS desktop
  static const double maxContentWidth = 800.0;
  static const double sidebarWidth = 300.0;
  static const double minWindowWidth = 500.0;
  static const double minWindowHeight = 700.0;
}
