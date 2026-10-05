// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tagline => 'Learn Galician, step by step';

  @override
  String get pathTitle => 'O Camiño do Galego';

  @override
  String get pathSubtitle => 'Learn step by step • Level A1';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => '🎨 Appearance';

  @override
  String get theme => 'App theme';

  @override
  String get typography => '✏️ Typography';

  @override
  String get textSize => 'Text size';

  @override
  String get interfaceLanguage => '🌍 Language';

  @override
  String get information => 'ℹ️ Information';

  @override
  String get reset => 'Reset';

  @override
  String get resetTitle => 'Reset settings';

  @override
  String get resetConfirm =>
      'This will restore all settings to default values. Continue?';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get systemTheme => 'System';

  @override
  String get preview => 'Preview';

  @override
  String get yourName => 'Your name';

  @override
  String get nameHint => 'Type your name...';

  @override
  String get editName => '👤 Profile';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get retry => 'Retry';

  @override
  String get start => 'Start';

  @override
  String get continueLabel => 'Continue';

  @override
  String get nameQuestion => 'What is your name?';

  @override
  String get nameSubtitle => 'I will personalize Galingo for you';

  @override
  String greeting(String name) {
    return 'Hello, $name! 👋';
  }

  @override
  String get nextLessonMessage => 'Your next lesson is waiting!';

  @override
  String get gabiWelcome => 'Welcome to Galingo!\\nI will be your guide. 🌟';

  @override
  String get startPath => 'Start learning →';

  @override
  String get completed => 'Completed';

  @override
  String get locked => 'Locked';

  @override
  String get errorLoading => 'Error loading course';

  @override
  String get version => 'Version';

  @override
  String get levelCovered => 'Level covered';

  @override
  String get targetLanguage => 'Target language';

  @override
  String get developedBy => 'Developed by';

  @override
  String get technology => 'Technology';

  @override
  String get application => 'Application';

  @override
  String get year => 'Year';

  @override
  String get personalize => 'Personalize your experience';

  @override
  String get levelA1 => 'Level A1 — Beginner';

  @override
  String get levelA2 => 'Level A2 — Intermediate';

  @override
  String get levelB1 => 'Level B1 — Threshold';

  @override
  String get levelB2 => 'Level B2 — Advanced';

  @override
  String get selectLevel => 'Select your study level:';

  @override
  String get levelA1Subtitle => 'Beginner: Greetings, family, food...';

  @override
  String get levelA2Subtitle => 'Intermediate: Travel, shopping, work...';

  @override
  String get levelB1Subtitle =>
      'Threshold: Debates, opinions, complex texts...';

  @override
  String get levelB2Subtitle =>
      'Advanced: Technical fluency, literature, idioms...';

  @override
  String get profile => 'Profile';

  @override
  String get nameLabel => 'Name';

  @override
  String get backToPath => 'Back to the Path';

  @override
  String lessonNotFound(String id) {
    return 'Lesson not found: $id';
  }

  @override
  String get backToHome => 'Back to start';

  @override
  String get typeTranslation => 'Type your translation here...';

  @override
  String get verifyTranslation => 'Check translation';

  @override
  String get finishLessonTip => 'Finish lesson and save progress';

  @override
  String get nextExerciseTip => 'Go to the next exercise';

  @override
  String get finishLesson => 'Finish lesson 🎉';

  @override
  String get next => 'Next →';

  @override
  String get veryGood => 'Well done!';

  @override
  String get incorrect => 'Incorrect';

  @override
  String get lessonCompleted => 'Congrats! You completed the lesson! 🎊';

  @override
  String get continuePath => 'Continue the Path →';
}
