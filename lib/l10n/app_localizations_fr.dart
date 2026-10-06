// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get tagline => 'Apprenez le galicien, étape par étape';

  @override
  String get pathTitle => 'O Camiño do Galego';

  @override
  String get pathSubtitle => 'Apprenez étape par étape • Niveau A1';

  @override
  String get settings => 'Paramètres';

  @override
  String get appearance => '🎨 Apparence';

  @override
  String get theme => 'Thème de l\'application';

  @override
  String get typography => '✏️ Typographie';

  @override
  String get textSize => 'Taille du texte';

  @override
  String get interfaceLanguage => '🌍 Langue';

  @override
  String get information => 'ℹ️ Informations';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get resetTitle => 'Réinitialiser les paramètres';

  @override
  String get resetConfirm =>
      'Cela rétablira tous les paramètres aux valeurs par défaut. Continuer?';

  @override
  String get lightTheme => 'Clair';

  @override
  String get darkTheme => 'Sombre';

  @override
  String get systemTheme => 'Système';

  @override
  String get preview => 'Aperçu';

  @override
  String get yourName => 'Votre nom';

  @override
  String get nameHint => 'Écrivez votre nom...';

  @override
  String get editName => '👤 Profil';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get retry => 'Réessayer';

  @override
  String get start => 'Commencer';

  @override
  String get continueLabel => 'Continuer';

  @override
  String get nameQuestion => 'Comment vous appelez-vous?';

  @override
  String get nameSubtitle => 'Je vais personnaliser Galingo pour vous';

  @override
  String greeting(String name) {
    return 'Bonjour, $name! 👋';
  }

  @override
  String get nextLessonMessage => 'Votre prochaine leçon vous attend!';

  @override
  String get gabiWelcome => 'Bienvenue sur Galingo!\\nJe serai votre guide. 🌟';

  @override
  String get startPath => 'Commencer le parcours →';

  @override
  String get completed => 'Terminé';

  @override
  String get locked => 'Verrouillé';

  @override
  String get errorLoading => 'Erreur lors du chargement du cours';

  @override
  String get version => 'Version';

  @override
  String get levelCovered => 'Niveau couvert';

  @override
  String get targetLanguage => 'Langue cible';

  @override
  String get developedBy => 'Développé par';

  @override
  String get technology => 'Technologie';

  @override
  String get application => 'Application';

  @override
  String get year => 'Année';

  @override
  String get personalize => 'Personnalisez votre expérience';

  @override
  String get levelA1 => 'Niveau A1 — Débutant';

  @override
  String get levelA2 => 'Niveau A2 — Intermédiaire';

  @override
  String get levelB1 => 'Niveau B1 — Seuil';

  @override
  String get levelB2 => 'Niveau B2 — Avancé';

  @override
  String get selectLevel => 'Sélectionnez votre niveau d\'études :';

  @override
  String get levelA1Subtitle =>
      'Débutant : Salutations, famille, nourriture...';

  @override
  String get levelA2Subtitle => 'Intermédiaire : Voyages, shopping, travail...';

  @override
  String get levelB1Subtitle => 'Seuil : Débats, opinions, textes complexes...';

  @override
  String get levelB2Subtitle =>
      'Avancé : Fluidité technique, littérature, idiomes...';

  @override
  String get profile => 'Profil';

  @override
  String get nameLabel => 'Nom';

  @override
  String get backToPath => 'Retour au Chemin';

  @override
  String lessonNotFound(String id) {
    return 'Leçon introuvable : $id';
  }

  @override
  String get backToHome => 'Retour au début';

  @override
  String get typeTranslation => 'Écris ta traduction ici...';

  @override
  String get verifyTranslation => 'Vérifier la traduction';

  @override
  String get finishLessonTip => 'Terminer la leçon et sauvegarder';

  @override
  String get nextExerciseTip => 'Passer à l\'exercice suivant';

  @override
  String get finishLesson => 'Terminer la leçon 🎉';

  @override
  String get next => 'Suivant →';

  @override
  String get veryGood => 'Très bien !';

  @override
  String get incorrect => 'Incorrect';

  @override
  String get lessonCompleted => 'Félicitations ! Leçon terminée ! 🎊';

  @override
  String get continuePath => 'Continuer le Chemin →';

  @override
  String get speakExercise => 'Prononce cette phrase';

  @override
  String get speakTarget => 'Maintiens le micro et parle';

  @override
  String get speakResult => 'Ta transcription :';

  @override
  String get speakRetry => 'Réessaie';

  @override
  String get speakGreat => 'Très bonne prononciation !';

  @override
  String get speakGood => 'Bien, mais tu peux mieux faire';
}
