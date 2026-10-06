import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pt'),
    Locale('ro'),
    Locale('zh')
  ];

  /// No description provided for @tagline.
  ///
  /// In es, this message translates to:
  /// **'Aprende gallego, paso a paso'**
  String get tagline;

  /// No description provided for @pathTitle.
  ///
  /// In es, this message translates to:
  /// **'O Camiño do Galego'**
  String get pathTitle;

  /// No description provided for @pathSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Aprende paso a paso • Nivel A1'**
  String get pathSubtitle;

  /// No description provided for @settings.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In es, this message translates to:
  /// **'🎨 Apariencia'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In es, this message translates to:
  /// **'Tema de la aplicación'**
  String get theme;

  /// No description provided for @typography.
  ///
  /// In es, this message translates to:
  /// **'✏️ Tipografía'**
  String get typography;

  /// No description provided for @textSize.
  ///
  /// In es, this message translates to:
  /// **'Tamaño del texto'**
  String get textSize;

  /// No description provided for @interfaceLanguage.
  ///
  /// In es, this message translates to:
  /// **'🌍 Idioma'**
  String get interfaceLanguage;

  /// No description provided for @information.
  ///
  /// In es, this message translates to:
  /// **'ℹ️ Información'**
  String get information;

  /// No description provided for @reset.
  ///
  /// In es, this message translates to:
  /// **'Restablecer'**
  String get reset;

  /// No description provided for @resetTitle.
  ///
  /// In es, this message translates to:
  /// **'Restablecer configuración'**
  String get resetTitle;

  /// No description provided for @resetConfirm.
  ///
  /// In es, this message translates to:
  /// **'Esto restaurará todos los ajustes a los valores predeterminados. ¿Continuar?'**
  String get resetConfirm;

  /// No description provided for @lightTheme.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get darkTheme;

  /// No description provided for @systemTheme.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get systemTheme;

  /// No description provided for @preview.
  ///
  /// In es, this message translates to:
  /// **'Vista previa'**
  String get preview;

  /// No description provided for @yourName.
  ///
  /// In es, this message translates to:
  /// **'Tu nombre'**
  String get yourName;

  /// No description provided for @nameHint.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu nombre...'**
  String get nameHint;

  /// No description provided for @editName.
  ///
  /// In es, this message translates to:
  /// **'👤 Perfil'**
  String get editName;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @start.
  ///
  /// In es, this message translates to:
  /// **'Comenzar'**
  String get start;

  /// No description provided for @continueLabel.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get continueLabel;

  /// No description provided for @nameQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo te llamas?'**
  String get nameQuestion;

  /// No description provided for @nameSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Personalización de la experiencia'**
  String get nameSubtitle;

  /// No description provided for @greeting.
  ///
  /// In es, this message translates to:
  /// **'¡Ola, {name}! 👋'**
  String greeting(String name);

  /// No description provided for @nextLessonMessage.
  ///
  /// In es, this message translates to:
  /// **'¡Tu próxima lección te espera!'**
  String get nextLessonMessage;

  /// No description provided for @gabiWelcome.
  ///
  /// In es, this message translates to:
  /// **'¡Bienvenido/a a Galingo!\\nSeré tu guía. 🌟'**
  String get gabiWelcome;

  /// No description provided for @startPath.
  ///
  /// In es, this message translates to:
  /// **'Comenzar el Camino →'**
  String get startPath;

  /// No description provided for @completed.
  ///
  /// In es, this message translates to:
  /// **'Completado'**
  String get completed;

  /// No description provided for @locked.
  ///
  /// In es, this message translates to:
  /// **'Bloqueado'**
  String get locked;

  /// No description provided for @errorLoading.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar el curso'**
  String get errorLoading;

  /// No description provided for @version.
  ///
  /// In es, this message translates to:
  /// **'Versión'**
  String get version;

  /// No description provided for @levelCovered.
  ///
  /// In es, this message translates to:
  /// **'Nivel cubierto'**
  String get levelCovered;

  /// No description provided for @targetLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma objetivo'**
  String get targetLanguage;

  /// No description provided for @developedBy.
  ///
  /// In es, this message translates to:
  /// **'Desarrollado por'**
  String get developedBy;

  /// No description provided for @technology.
  ///
  /// In es, this message translates to:
  /// **'Tecnología'**
  String get technology;

  /// No description provided for @application.
  ///
  /// In es, this message translates to:
  /// **'Aplicación'**
  String get application;

  /// No description provided for @year.
  ///
  /// In es, this message translates to:
  /// **'Año'**
  String get year;

  /// No description provided for @personalize.
  ///
  /// In es, this message translates to:
  /// **'Personaliza tu experiencia'**
  String get personalize;

  /// No description provided for @levelA1.
  ///
  /// In es, this message translates to:
  /// **'Nivel A1 — Iniciación'**
  String get levelA1;

  /// No description provided for @levelA2.
  ///
  /// In es, this message translates to:
  /// **'Nivel A2 — Intermedio'**
  String get levelA2;

  /// No description provided for @levelB1.
  ///
  /// In es, this message translates to:
  /// **'Nivel B1 — Umbral'**
  String get levelB1;

  /// No description provided for @levelB2.
  ///
  /// In es, this message translates to:
  /// **'Nivel B2 — Avanzado'**
  String get levelB2;

  /// No description provided for @selectLevel.
  ///
  /// In es, this message translates to:
  /// **'Selecciona tu nivel de estudio:'**
  String get selectLevel;

  /// No description provided for @levelA1Subtitle.
  ///
  /// In es, this message translates to:
  /// **'Iniciación: Saludos, familia, comidas...'**
  String get levelA1Subtitle;

  /// No description provided for @levelA2Subtitle.
  ///
  /// In es, this message translates to:
  /// **'Intermedio: Viajes, compras, trabajo...'**
  String get levelA2Subtitle;

  /// No description provided for @levelB1Subtitle.
  ///
  /// In es, this message translates to:
  /// **'Umbral: Debates, opiniones, textos complejos...'**
  String get levelB1Subtitle;

  /// No description provided for @levelB2Subtitle.
  ///
  /// In es, this message translates to:
  /// **'Avanzado: Fluidez técnica, literatura, modismos...'**
  String get levelB2Subtitle;

  /// No description provided for @profile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get profile;

  /// No description provided for @nameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get nameLabel;

  /// No description provided for @backToPath.
  ///
  /// In es, this message translates to:
  /// **'Volver al Camino'**
  String get backToPath;

  /// No description provided for @lessonNotFound.
  ///
  /// In es, this message translates to:
  /// **'Lección no encontrada: {id}'**
  String lessonNotFound(String id);

  /// No description provided for @backToHome.
  ///
  /// In es, this message translates to:
  /// **'Volver al inicio'**
  String get backToHome;

  /// No description provided for @typeTranslation.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu traducción aquí...'**
  String get typeTranslation;

  /// No description provided for @verifyTranslation.
  ///
  /// In es, this message translates to:
  /// **'Verificar traducción'**
  String get verifyTranslation;

  /// No description provided for @finishLessonTip.
  ///
  /// In es, this message translates to:
  /// **'Finalizar lección y guardar progreso'**
  String get finishLessonTip;

  /// No description provided for @nextExerciseTip.
  ///
  /// In es, this message translates to:
  /// **'Avanzar al siguiente ejercicio'**
  String get nextExerciseTip;

  /// No description provided for @finishLesson.
  ///
  /// In es, this message translates to:
  /// **'Finalizar lección 🎉'**
  String get finishLesson;

  /// No description provided for @next.
  ///
  /// In es, this message translates to:
  /// **'Seguir →'**
  String get next;

  /// No description provided for @veryGood.
  ///
  /// In es, this message translates to:
  /// **'¡Muy bien!'**
  String get veryGood;

  /// No description provided for @incorrect.
  ///
  /// In es, this message translates to:
  /// **'Incorrecto'**
  String get incorrect;

  /// No description provided for @lessonCompleted.
  ///
  /// In es, this message translates to:
  /// **'¡Enhorabuena! ¡Completaste la lección! 🎊'**
  String get lessonCompleted;

  /// No description provided for @continuePath.
  ///
  /// In es, this message translates to:
  /// **'Continuar el Camino →'**
  String get continuePath;

  /// No description provided for @speakExercise.
  ///
  /// In es, this message translates to:
  /// **'Pronuncia esta frase'**
  String get speakExercise;

  /// No description provided for @speakTarget.
  ///
  /// In es, this message translates to:
  /// **'Mantén pulsado el micrófono y habla'**
  String get speakTarget;

  /// No description provided for @speakResult.
  ///
  /// In es, this message translates to:
  /// **'Tu transcripción:'**
  String get speakResult;

  /// No description provided for @speakRetry.
  ///
  /// In es, this message translates to:
  /// **'Inténtalo de nuevo'**
  String get speakRetry;

  /// No description provided for @speakGreat.
  ///
  /// In es, this message translates to:
  /// **'¡Muy bien pronunciado!'**
  String get speakGreat;

  /// No description provided for @speakGood.
  ///
  /// In es, this message translates to:
  /// **'Bien, pero puedes mejorar'**
  String get speakGood;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'de',
        'en',
        'es',
        'fr',
        'it',
        'pt',
        'ro',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'pt':
      return AppLocalizationsPt();
    case 'ro':
      return AppLocalizationsRo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
