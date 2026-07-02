// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Jezici';

  @override
  String get commonContinue => 'CONTINUAR';

  @override
  String get commonStart => 'COMEÇAR';

  @override
  String get commonCheck => 'VERIFICAR';

  @override
  String get commonSkip => 'Pular';

  @override
  String get commonBack => 'Voltar';

  @override
  String get commonExit => 'Sair';

  @override
  String get commonClose => 'Fechar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonRetry => 'Tentar de novo';

  @override
  String get commonNext => 'Próximo';

  @override
  String get commonDone => 'Pronto';

  @override
  String get splashLoadError => 'Não foi possível carregar sua sessão.';

  @override
  String get settingsLanguageTitle => 'Idioma do app';

  @override
  String get settingsLanguageSubtitle =>
      'O idioma dos menus e instruções. Não muda o idioma que você está aprendendo.';

  @override
  String get langEs => 'Español';

  @override
  String get langEn => 'English';

  @override
  String get langPt => 'Português';

  @override
  String get skillReading => 'Leitura';

  @override
  String get skillWriting => 'Escrita';

  @override
  String get skillListening => 'Compreensão auditiva';

  @override
  String get skillSpeaking => 'Expressão oral';

  @override
  String get onbWelcomeTitle => 'Vamos montar seu plano';

  @override
  String get onbWelcomeSubtitle =>
      'Algumas perguntas rápidas e um teste de nível para montar seu plano com data real. Cada resposta personaliza seu caminho.';

  @override
  String get onbWelcomeNote => 'Leva ~2 minutos.';

  @override
  String get onbLanguageTitle => 'Em qual idioma você prefere o app?';

  @override
  String get onbLanguageSubtitle =>
      'Escolha o idioma dos menus e mensagens. Não é o idioma que você vai aprender.';

  @override
  String get onbLanguageInfoEn =>
      'Você vai aprender inglês 🇬🇧. Isso só muda o idioma do app.';

  @override
  String get onbLanguageInfoPt =>
      'Você vai aprender português 🇧🇷. Isso só muda o idioma do app.';

  @override
  String get onbMotiveTitle => 'Por que você está aprendendo inglês?';

  @override
  String get onbMotiveSubtitle =>
      'Personaliza seu plano, os cenários e as mensagens do seu coach.';

  @override
  String get onbMotiveWork => 'Trabalho';

  @override
  String get onbMotiveTravel => 'Viagens';

  @override
  String get onbMotiveExam => 'Exame oficial';

  @override
  String get onbMotiveStudies => 'Estudos';

  @override
  String get onbMotiveRelocation => 'Mudança';

  @override
  String get onbMotivePleasure => 'Por prazer';

  @override
  String get onbGoalTitle => 'Aonde você quer chegar?';

  @override
  String get onbGoalSubtitle => 'Sua meta. O topo do mapa.';

  @override
  String get onbGoalA2 => 'A2 · Me viro';

  @override
  String get onbGoalB1 => 'B1 · Independente';

  @override
  String get onbGoalB2 => 'B2 · Conversa fluente';

  @override
  String get onbGoalC1 => 'C1 · Avançado';

  @override
  String get onbDeadlineEmpty => 'Prazo (opcional)';

  @override
  String onbDeadlineFilled(int day, int month, int year) {
    return 'Meta: $day/$month/$year';
  }

  @override
  String get onbCommitmentTitle => 'Quanto tempo você pode dedicar?';

  @override
  String get onbCommitmentSubtitle =>
      'Isso define sua meta diária e a data de chegada.';

  @override
  String get onbCommitmentMinutesLabel => 'Minutos por dia';

  @override
  String get onbCommitmentDaysLabel => 'Dias por semana';

  @override
  String get onbFrequencyRelaxed => 'Tranquilo';

  @override
  String get onbFrequencyConstant => 'Constante';

  @override
  String get onbFrequencyIntense => 'Intenso';

  @override
  String get onbStartLevelTitle => 'Quanto inglês você já sabe?';

  @override
  String get onbStartLevelSubtitle =>
      'Para começar o teste de nível no ponto certo.';

  @override
  String get onbStartLevelZero => 'Do zero';

  @override
  String get onbStartLevelBasic => 'Sei o básico';

  @override
  String get onbStartLevelGood => 'Tenho um bom nível';

  @override
  String onbMinutesShort(int m) {
    return '$m min';
  }

  @override
  String onbDaysShort(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dias',
      one: '$days dia',
    );
    return '$_temp0';
  }

  @override
  String get planDurationLessThanWeek => 'menos de 1 semana';

  @override
  String planDurationWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '≈ $count semanas',
      one: '≈ 1 semana',
    );
    return '$_temp0';
  }

  @override
  String planDurationMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '≈ $count meses',
    );
    return '$_temp0';
  }

  @override
  String planDurationYears(String years) {
    return '≈ $years anos';
  }

  @override
  String get onbSaveError =>
      'Não foi possível salvar seu plano. Tente de novo.';

  @override
  String get onbPersonalityTitle => 'Seu coach ideal';

  @override
  String onbPersonalityStep(int q, int total) {
    return 'Pergunta $q de $total';
  }

  @override
  String get onbPersonalityQ1 =>
      'Se você não bater sua meta do dia, o que prefere ouvir?';

  @override
  String get onbPersonalityQ1Opt1 => '\"Sem desculpas. Volte agora.\"';

  @override
  String get onbPersonalityQ1Opt2 =>
      '\"Amanhã você arrasa, você consegue! 💪\"';

  @override
  String get onbPersonalityQ1Opt3 =>
      '\"Você está ficando para trás no plano, recupere.\"';

  @override
  String get onbPersonalityQ1Opt4 =>
      '\"Relaxa, quando você puder a gente segue 🙂\"';

  @override
  String get onbPersonalityQ2 => 'Como você gosta de ser motivado a praticar?';

  @override
  String get onbPersonalityQ2Opt1 => 'Firme e direto';

  @override
  String get onbPersonalityQ2Opt2 => 'Com energia e celebração';

  @override
  String get onbPersonalityQ2Opt3 => 'Lembrando minhas metas e meu progresso';

  @override
  String get onbPersonalityQ2Opt4 => 'Suave, sem pressão';

  @override
  String get onbPersonalityQ3 =>
      'Alguém te ultrapassa na liga. O que te ativa?';

  @override
  String get onbPersonalityQ3Opt1 => 'Que me desafiem a reagir';

  @override
  String get onbPersonalityQ3Opt2 => 'Incentivo para subir posições';

  @override
  String get onbPersonalityQ3Opt3 => 'Ver o quanto falta para alcançá-lo';

  @override
  String get onbPersonalityQ3Opt4 => 'Nada, vou no meu ritmo';

  @override
  String get onbPersonalityQ4 =>
      'Quando você conquista algo, qual mensagem curte mais?';

  @override
  String get onbPersonalityQ4Opt1 => '\"Bom. Agora o próximo desafio.\"';

  @override
  String get onbPersonalityQ4Opt2 => '\"Incrível, você é imparável! 🎉\"';

  @override
  String get onbPersonalityQ4Opt3 => '\"Você está adiantado no seu plano.\"';

  @override
  String get onbPersonalityQ4Opt4 => '\"Que bom, siga no seu ritmo 🙂\"';

  @override
  String get onbIntensityQ =>
      'Com que frequência você quer que a gente lembre você?';

  @override
  String get onbIntensityOpt1 => 'Bastante, não me deixe afrouxar';

  @override
  String get onbIntensityOpt2 => 'Na medida certa';

  @override
  String get onbIntensityOpt3 => 'Pouco';

  @override
  String get placementTitle => 'Teste de nível';

  @override
  String placementSubtitle(int asked, int max) {
    return 'Sem dicas · pergunta $asked de $max';
  }

  @override
  String placementResultTitle(String level) {
    return 'Seu nível: $level';
  }

  @override
  String get placementResultSubtitle =>
      'Isto não é uma prova de passar ou reprovar: é seu ponto de partida.';

  @override
  String get placementResultViewPlan => 'VER MEU PLANO';

  @override
  String get placementResultHero => 'COLOCAMOS VOCÊ EM';

  @override
  String get placementResultSkillsTitle => 'Por habilidade';

  @override
  String placementResultEntryUnit(int unitNum, String unitName, String level) {
    return 'Você vai começar na Unidade $unitNum — $unitName ($level). O anterior fica acessível para revisar.';
  }

  @override
  String placementResultEstimateReached(
    String goalLevel,
    String humanDuration,
    String formattedDate,
  ) {
    return 'Você já alcançou sua meta. Se continuar até $goalLevel: $humanDuration (aprox. $formattedDate).';
  }

  @override
  String placementResultEstimateGoal(
    String goalLevel,
    String humanDuration,
    String formattedDate,
  ) {
    return 'Se você cumprir seu plano, chega a $goalLevel em $humanDuration (aprox. $formattedDate).';
  }

  @override
  String get planFocusWork =>
      'Foco no trabalho: reuniões, e-mails e entrevistas.';

  @override
  String get planFocusTravel =>
      'Foco em viagens: aeroporto, hotel, direções e restaurantes.';

  @override
  String get planFocusExam =>
      'Foco em exame: simulados IELTS/Cambridge e as 4 habilidades.';

  @override
  String get planFocusStudies =>
      'Foco em estudos: compreensão, escrita e vocabulário acadêmico.';

  @override
  String get planFocusRelocation =>
      'Foco em mudança: burocracia, moradia e vida diária.';

  @override
  String get planFocusCulture =>
      'Foco em cultura: séries, música e conversa do dia a dia.';

  @override
  String get planReadyTitle => '🎉 Seu plano está pronto';

  @override
  String get planReadySubtitle =>
      'Se você cumprir seu plano, chega lá. Isto é o que vai levar.';

  @override
  String get planPreparing => 'PREPARANDO SEU MAPA…';

  @override
  String get planStartMyPlan => 'COMEÇAR MEU PLANO';

  @override
  String get planCompletionLabel => 'VOCÊ CHEGARÁ POR VOLTA DE';

  @override
  String planStatsHours(int hours) {
    return '$hours h';
  }

  @override
  String get planStatsTotalLabel => 'no total';

  @override
  String planStatsFrequency(int days) {
    return '× $days dias/sem';
  }

  @override
  String get planMaxPace => 'Você está no ritmo máximo! 🔥';

  @override
  String planFasterCta(int minutes) {
    return 'Quero chegar mais rápido (sobe para $minutes min/dia)';
  }

  @override
  String planStartUnit(int unitNum, String unitName, String level) {
    return 'Você começa na Unidade $unitNum — $unitName ($level).';
  }

  @override
  String get planBadgeNow => 'AGORA';

  @override
  String get planBadgeGoal => 'META';

  @override
  String get authTitleSignUp => 'Crie sua conta';

  @override
  String get authTitleSignIn => 'Bem-vindo de volta';

  @override
  String get authSubtitleSignUp =>
      'Um plano com data real, um exame das 4 habilidades e um coach que traz você de volta.';

  @override
  String get authSubtitleSignIn => 'Continue de onde parou.';

  @override
  String get authFieldName => 'Seu nome';

  @override
  String get authFieldEmail => 'Email';

  @override
  String get authFieldPassword => 'Senha';

  @override
  String get authSegCreateAccount => 'Criar conta';

  @override
  String get authSegSignIn => 'Entrar';

  @override
  String get authCtaCreating => 'CRIANDO…';

  @override
  String get authCtaLoggingIn => 'ENTRANDO…';

  @override
  String get authCtaSignUp => 'CRIAR CONTA';

  @override
  String get authCtaSignIn => 'ENTRAR';

  @override
  String get authLegalPrefix => 'Li e aceito os ';

  @override
  String get authLegalTerms => 'Termos';

  @override
  String get authLegalAnd => ' e a ';

  @override
  String get authLegalPrivacy => 'Política de Privacidade';

  @override
  String get authLegalSuffix => '.';

  @override
  String get authErrorNameRequired =>
      'Diga seu nome para personalizar sua jornada.';

  @override
  String get authErrorEmailPassword =>
      'Coloque um email válido e uma senha de 6+ caracteres.';

  @override
  String get authErrorTermsRequired =>
      'Para criar sua conta, aceite os Termos e a Privacidade.';

  @override
  String get authErrorGeneral => 'Algo deu errado. Tente de novo.';

  @override
  String get authErrorDuplicate => 'Esse email já tem conta. Faça login.';

  @override
  String get authErrorInvalid => 'Email ou senha incorretos.';

  @override
  String get authErrorPasswordLength => 'A senha deve ter 6+ caracteres.';

  @override
  String get authErrorFallback =>
      'Não foi possível continuar. Verifique seus dados.';

  @override
  String get lessonSaveErrorTitle => 'Não foi possível salvar seu progresso';

  @override
  String get lessonSaveErrorMsg => 'Verifique sua conexão e tente de novo.';

  @override
  String get lessonNoExercises => 'Esta lição ainda não tem exercícios.';

  @override
  String get lessonFeedbackNear => 'Quase! 🦜';

  @override
  String get lessonFeedbackCorrect => 'Correto! 🦜';

  @override
  String get lessonFeedbackWrong => 'Não é bem isso 🦜';

  @override
  String lessonFeedbackCorrectForm(String form) {
    return 'A forma correta é: $form';
  }

  @override
  String get lessonFeedbackWellDone => 'Muito bem, continue assim!';

  @override
  String lessonFeedbackRightAnswer(String answer) {
    return 'Resposta correta: $answer';
  }

  @override
  String get lessonAudioUnavailableTitle => 'Áudio indisponível';

  @override
  String get lessonAudioUnavailableMsg =>
      'Este exercício ainda não tem o áudio. Vamos pular: não afeta suas vidas nem sua pontuação.';

  @override
  String get lessonCompletePerfectTitle => 'LIÇÃO PERFEITA';

  @override
  String get lessonCompleteTitle => 'LIÇÃO CONCLUÍDA';

  @override
  String get lessonCompletePerfectMsg => 'Impecável! 🌟';

  @override
  String get lessonCompleteMsg => 'Você conseguiu! 🎉';

  @override
  String get lessonCompleteXpLabel => 'XP GANHO';

  @override
  String get lessonCompleteAccuracyLabel => 'PRECISÃO';

  @override
  String get lessonCompleteGoldLabel => 'OURO';

  @override
  String get lessonCompleteComboBonusLabel => 'Bônus de combo';

  @override
  String lessonCompleteComboDetail(int bonus, int combo) {
    return '+$bonus XP · x$combo seguidas';
  }

  @override
  String lessonCompleteMilestone(int days) {
    return 'Marco de $days dias! Recompensa de ouro desbloqueada';
  }

  @override
  String lessonCompleteStreakDays(int streak) {
    String _temp0 = intl.Intl.pluralLogic(
      streak,
      locale: localeName,
      other: '🔥 $streak dias de ofensiva',
      one: '🔥 $streak dia de ofensiva',
    );
    return '$_temp0';
  }

  @override
  String get lessonCompleteStreakAdvanced =>
      '+1 hoje! Você bateu sua meta diária';

  @override
  String get lessonCompleteGoalMet => 'Meta diária cumprida';

  @override
  String get lessonCompleteGoalPending =>
      'Continue para bater sua meta de hoje';

  @override
  String get lessonCompleteFreezeSingle => 'Seu congelador salvou sua ofensiva';

  @override
  String get lessonCompleteFreezeMulti =>
      'Seus congeladores salvaram sua ofensiva';

  @override
  String get lessonCompleteSkillsUp => 'Habilidades que subiram';

  @override
  String tipCardHeader(String type) {
    return 'Matix ensina você · $type';
  }

  @override
  String tipCardPersonalized(String skill) {
    return 'Estou te dando isto porque sua $skill precisa de um empurrão. 🦜';
  }

  @override
  String get errorReviewWhyTranslation =>
      'Repare na forma exata em inglês — o sentido completo importa.';

  @override
  String get errorReviewWhyCloze => 'Revise a palavra que faltava na frase.';

  @override
  String get errorReviewWhyWordOrder =>
      'Cuide da ORDEM das palavras: o inglês é mais fixo que o espanhol.';

  @override
  String get errorReviewWhyMatch => 'Associe cada palavra ao seu par correto.';

  @override
  String get errorReviewWhyListening =>
      'Ouça de novo com calma; o som te dá a dica.';

  @override
  String get errorReviewWhyDefault =>
      'Revise: você verá de novo em breve na sua prática.';

  @override
  String get errorReviewTitle => 'Revise o que você errou';

  @override
  String errorReviewSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercícios para reforçar. Você está quase lá!',
      one: '1 exercício para reforçar. Você está quase lá!',
    );
    return '$_temp0';
  }

  @override
  String get errorReviewPracticeCta => 'Praticar os que você errou';

  @override
  String get tileArrangePlaceholder =>
      'Toque nas palavras para formar a frase…';

  @override
  String get tileArrangeAllPlaced => 'Tudo colocado — toque em VERIFICAR';

  @override
  String get translationHint => 'Escreva a tradução…';

  @override
  String get clozeHint => 'Escreva sua resposta…';

  @override
  String get listeningTapToListen => 'Toque para ouvir';

  @override
  String get speakingPreparingMic => 'Preparando o microfone…';

  @override
  String get speakingNoMic =>
      'Seu navegador ou dispositivo não permite o microfone.';

  @override
  String get speakingIReadIt => 'Já li ✓';

  @override
  String get speakingManualDone => 'Boa! Continue praticando em voz alta. 🦜';

  @override
  String get speakingListening => 'Ouvindo…';

  @override
  String get speakingTalk => 'Falar';

  @override
  String get speakingGood => 'Bem pronunciado! 🦜';

  @override
  String get speakingNoSound => 'Não te ouvi — chegue perto e tente de novo';

  @override
  String get speakingOk => 'Você vai bem. Leia de novo se quiser';

  @override
  String speakingHeard(String heard) {
    return 'Ouvi: \"$heard\"';
  }

  @override
  String get speakingVolumeHint =>
      'Aumente o volume do microfone, ou toque em \"Já li ✓\" para continuar.';

  @override
  String speakingRetryHint(String heard) {
    return 'Ouvi: \"$heard\". Você pode tentar de novo ou tocar em \"Já li ✓\".';
  }

  @override
  String get speakingHearModel => 'Ouvir o modelo';

  @override
  String get audioPlayDefault => 'Ouvir';

  @override
  String get stubTagPronunciation => 'PRONÚNCIA';

  @override
  String get stubNotePronunciation =>
      'O reconhecimento de voz chega em breve. Por ora, pratique em voz alta e continue.';

  @override
  String get stubTagListening => 'COMPREENSÃO AUDITIVA';

  @override
  String get stubNoteListening =>
      'O áudio deste exercício será gravado em breve. Por ora, continue.';

  @override
  String get stubTagDictation => 'DITADO';

  @override
  String get stubNoteDictation =>
      'O ditado precisa de áudio (gravado em breve). Por ora, continue.';

  @override
  String get stubTagGuidedWriting => 'ESCRITA GUIADA';

  @override
  String get stubNoteGuidedWriting =>
      'A escrita guiada com correção chega em breve. Por ora, continue.';

  @override
  String get stubTagComingSoon => 'EM BREVE';

  @override
  String get stubNoteComingSoon =>
      'Este tipo de exercício chega em breve. Por ora, continue.';

  @override
  String get noHeartsTitle => 'Você ficou sem vidas ❤️';

  @override
  String get noHeartsMsg =>
      'Relaxa, acontece com todo mundo! As vidas se regeneram com o tempo; se quiser seguir agora, recarregue com ouro.';

  @override
  String get noHeartsRefill => 'Recarregar vidas e seguir';

  @override
  String get noHeartsQuit => 'Sair da lição';

  @override
  String get checkpointStartError =>
      'Não foi possível iniciar o exame. Tente de novo.';

  @override
  String get checkpointPortalTitle => 'O portal da unidade';

  @override
  String get checkpointCoachMsg => '🦜  Mostre o que você sabe!';

  @override
  String get checkpointIntroMsg =>
      'Vença o portal para abrir a próxima região do mapa.';

  @override
  String get checkpointStatTimed => 'cronometrado';

  @override
  String get checkpointStatPass => 'para passar';

  @override
  String get checkpointStatQuestions => 'perguntas';

  @override
  String get checkpointStartCta => 'COMEÇAR CHECKPOINT';

  @override
  String get checkpointNoCost =>
      'Não custa vidas · você pode repetir quando quiser';

  @override
  String get checkpointSkillsBreakdown => 'Detalhamento por habilidade';

  @override
  String get checkpointPassedLabel => '✓ CHECKPOINT APROVADO';

  @override
  String get checkpointFailedLabel => 'CHECKPOINT NÃO APROVADO';

  @override
  String get checkpointPassedMsg => 'Unidade concluída!';

  @override
  String get checkpointFailedMsg => 'Você ainda não venceu o portal';

  @override
  String checkpointPassedScore(int pct) {
    return '$pct% de acertos';
  }

  @override
  String checkpointFailedScore(int pct) {
    return '$pct% · você precisa de 80%';
  }

  @override
  String get checkpointSkillSoon => 'em breve';

  @override
  String get checkpointRegionUnlockedLabel => '✦ NOVA REGIÃO DESBLOQUEADA';

  @override
  String get checkpointCompleteLabel => '✓ UNIDADE COMPLETA';

  @override
  String checkpointRegionUnlockedMsg(String unit) {
    return '$unit concluída! A próxima região foi desbloqueada.';
  }

  @override
  String checkpointCompleteSoonMsg(String unit) {
    return '$unit concluída! A próxima região chega em breve.';
  }

  @override
  String get checkpointContinueJourney => 'CONTINUAR A JORNADA';

  @override
  String get checkpointRetry => 'TENTAR DE NOVO';

  @override
  String get checkpointBackToMap => 'Voltar ao mapa';

  @override
  String checkpointMissingPoints(int missing, int pct) {
    return 'Faltaram $missing pontos para os $pct%. Quase!';
  }

  @override
  String get checkpointReinforceTitle => 'REFORCE ESTAS HABILIDADES';

  @override
  String get checkpointReinforceEmpty => 'Revise a unidade e tente de novo.';

  @override
  String get checkpointSubmitError =>
      'Não foi possível enviar o exame. Tente de novo.';

  @override
  String get checkpointExitTitle => 'Sair do exame?';

  @override
  String get checkpointExitMsg =>
      'Você vai perder o progresso desta tentativa.';

  @override
  String get checkpointExitStay => 'Continuar';

  @override
  String get checkpointLoadErrorTitle => 'Não foi possível carregar o exame';

  @override
  String get checkpointLoadErrorMsg =>
      'Volte ao mapa e tente de novo em um instante.';

  @override
  String get checkpointBackToMapCta => 'VOLTAR AO MAPA';

  @override
  String get checkpointFinish => 'TERMINAR';

  @override
  String get checkpointNext => 'PRÓXIMO';

  @override
  String lessonPreviewLoadError(String error) {
    return 'Não foi possível carregar a lição.\n$error';
  }

  @override
  String lessonPreviewExerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercícios',
      one: '1 exercício',
    );
    return '$_temp0';
  }

  @override
  String get dailyGoalTitle => 'Meta de hoje';

  @override
  String dailyGoalXpOf(int earned, int goal) {
    return '$earned/$goal XP';
  }

  @override
  String get dailyGoalMet => 'Meta cumprida! Sua ofensiva avança hoje 🔥';

  @override
  String dailyGoalRemaining(int n) {
    return 'Faltam $n XP para cumprir hoje';
  }

  @override
  String dailyGoalSemantics(int earned, int goal) {
    return 'Meta diária: $earned de $goal XP';
  }

  @override
  String get missionWelcomeTitle => 'Sua jornada começou!';

  @override
  String get missionWelcomeBody =>
      'Colecione as 100 palavras essenciais ao avançar. Vamos!';

  @override
  String missionRewardBanner(int xp, int gold) {
    return '+$xp XP · +$gold de ouro de boas-vindas';
  }

  @override
  String get missionStartError => 'Não foi possível começar. Tente de novo.';

  @override
  String comboLabel(int combo) {
    return 'x$combo';
  }

  @override
  String shopChestWon(int reward, int total) {
    return '🎁 Você ganhou $reward de ouro! Agora você tem $total.';
  }

  @override
  String get shopChestAlready => 'Você já abriu o baú de hoje. Volte amanhã 🙂';

  @override
  String shopHeartsRefilled(int gold) {
    return '❤️ Vidas recarregadas. Você gastou 50 de ouro, restam $gold.';
  }

  @override
  String shopFreezeBought(int gold) {
    return '🧊 Congelador comprado. Você gastou 50 de ouro, restam $gold.';
  }

  @override
  String shopNotEnoughGold(int cost) {
    return 'Você não tem ouro suficiente (custa $cost).';
  }

  @override
  String get leagueNoMovementNote =>
      'No beta ainda não há promoções nem rebaixamentos: jogue para ganhar XP e subir na tabela.';
}
