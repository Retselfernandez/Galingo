// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get tagline => 'Aprenda galego, passo a passo';

  @override
  String get pathTitle => 'O Camiño do Galego';

  @override
  String get pathSubtitle => 'Aprenda passo a passo • Nível A1';

  @override
  String get settings => 'Configurações';

  @override
  String get appearance => '🎨 Aparência';

  @override
  String get theme => 'Tema do aplicativo';

  @override
  String get typography => '✏️ Tipografia';

  @override
  String get textSize => 'Tamanho do texto';

  @override
  String get interfaceLanguage => '🌍 Idioma';

  @override
  String get information => 'ℹ️ Informações';

  @override
  String get reset => 'Redefinir';

  @override
  String get resetTitle => 'Redefinir configurações';

  @override
  String get resetConfirm =>
      'Isso restaurará todas as configurações aos valores padrão. Continuar?';

  @override
  String get lightTheme => 'Claro';

  @override
  String get darkTheme => 'Escuro';

  @override
  String get systemTheme => 'Sistema';

  @override
  String get preview => 'Visualização';

  @override
  String get yourName => 'Seu nome';

  @override
  String get nameHint => 'Escreva seu nome...';

  @override
  String get editName => '👤 Perfil';

  @override
  String get save => 'Salvar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get start => 'Começar';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get nameQuestion => 'Como você se chama?';

  @override
  String get nameSubtitle => 'Vou personalizar o Galingo para você';

  @override
  String greeting(String name) {
    return 'Olá, $name! 👋';
  }

  @override
  String get nextLessonMessage => 'Sua próxima lição espera por você!';

  @override
  String get gabiWelcome => 'Bem-vindo ao Galingo!\\nSerei seu guia. 🌟';

  @override
  String get startPath => 'Começar o Caminho →';

  @override
  String get completed => 'Concluído';

  @override
  String get locked => 'Bloqueado';

  @override
  String get errorLoading => 'Erro ao carregar o curso';

  @override
  String get version => 'Versão';

  @override
  String get levelCovered => 'Nível coberto';

  @override
  String get targetLanguage => 'Idioma de destino';

  @override
  String get developedBy => 'Desenvolvido por';

  @override
  String get technology => 'Tecnologia';

  @override
  String get application => 'Aplicativo';

  @override
  String get year => 'Ano';

  @override
  String get personalize => 'Personalize sua experiência';

  @override
  String get levelA1 => 'Nível A1 — Iniciação';

  @override
  String get levelA2 => 'Nível A2 — Intermediário';

  @override
  String get levelB1 => 'Nível B1 — Limiar';

  @override
  String get levelB2 => 'Nível B2 — Avançado';

  @override
  String get selectLevel => 'Selecione o seu nível de estudo:';

  @override
  String get levelA1Subtitle => 'Iniciação: Saudações, família, comida...';

  @override
  String get levelA2Subtitle => 'Intermediário: Viagens, compras, trabalho...';

  @override
  String get levelB1Subtitle =>
      'Limiar: Debates, opiniões, textos complexos...';

  @override
  String get levelB2Subtitle =>
      'Avançado: Fluidez técnica, literatura, modismos...';

  @override
  String get profile => 'Perfil';

  @override
  String get nameLabel => 'Nome';

  @override
  String get backToPath => 'Voltar ao Caminho';

  @override
  String lessonNotFound(String id) {
    return 'Lição não encontrada: $id';
  }

  @override
  String get backToHome => 'Voltar ao início';

  @override
  String get typeTranslation => 'Escreve a tua tradução aqui...';

  @override
  String get verifyTranslation => 'Verificar tradução';

  @override
  String get finishLessonTip => 'Concluir lição e guardar progresso';

  @override
  String get nextExerciseTip => 'Avançar para o exercício seguinte';

  @override
  String get finishLesson => 'Concluir lição 🎉';

  @override
  String get next => 'Seguir →';

  @override
  String get veryGood => 'Muito bem!';

  @override
  String get incorrect => 'Incorreto';

  @override
  String get lessonCompleted => 'Parabéns! Concluíste a lição! 🎊';

  @override
  String get continuePath => 'Continuar o Caminho →';

  @override
  String get speakExercise => 'Pronuncia esta frase';

  @override
  String get speakTarget =>
      'Toca no microfone para falar e toca novamente para parar';

  @override
  String get speakResult => 'A tua transcrição:';

  @override
  String get speakRetry => 'Tenta novamente';

  @override
  String get speakGreat => 'Muito bem pronunciado!';

  @override
  String get speakGood => 'Bem, mas podes melhorar';

  @override
  String get speakExcellent => 'Excelente!';

  @override
  String get speakAlmost => 'Quase…';

  @override
  String get speakKeepTrying => 'Continua a praticar';
}
