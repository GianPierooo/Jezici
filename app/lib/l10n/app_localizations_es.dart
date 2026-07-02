// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Jezici';

  @override
  String get commonContinue => 'CONTINUAR';

  @override
  String get commonStart => 'EMPEZAR';

  @override
  String get commonCheck => 'COMPROBAR';

  @override
  String get commonSkip => 'Saltar';

  @override
  String get commonBack => 'Volver';

  @override
  String get commonExit => 'Salir';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonNext => 'Siguiente';

  @override
  String get commonDone => 'Listo';

  @override
  String get splashLoadError => 'No se pudo cargar tu sesión.';

  @override
  String get settingsLanguageTitle => 'Idioma de la app';

  @override
  String get settingsLanguageSubtitle =>
      'El idioma de los menús y las instrucciones. No cambia el idioma que estás aprendiendo.';

  @override
  String get langEs => 'Español';

  @override
  String get langEn => 'English';

  @override
  String get langPt => 'Português';

  @override
  String get skillReading => 'Lectura';

  @override
  String get skillWriting => 'Escritura';

  @override
  String get skillListening => 'Comprensión auditiva';

  @override
  String get skillSpeaking => 'Expresión oral';

  @override
  String get onbWelcomeTitle => 'Construyamos tu plan';

  @override
  String get onbWelcomeSubtitle =>
      'Unas preguntas rápidas y un test de nivel para armar tu plan con fecha real. Cada respuesta personaliza tu camino.';

  @override
  String get onbWelcomeNote => 'Toma ~2 minutos.';

  @override
  String get onbLanguageTitle => '¿En qué idioma prefieres la app?';

  @override
  String get onbLanguageSubtitle =>
      'Elige el idioma de los menús y mensajes. No es el idioma que vas a aprender.';

  @override
  String get onbLanguageInfoEn =>
      'Vas a aprender inglés 🇬🇧. Esto solo cambia el idioma de la app.';

  @override
  String get onbLanguageInfoPt =>
      'Vas a aprender portugués 🇧🇷. Esto solo cambia el idioma de la app.';

  @override
  String get onbMotiveTitle => '¿Por qué aprendes inglés?';

  @override
  String get onbMotiveSubtitle =>
      'Personaliza tu plan, los escenarios y los mensajes de tu coach.';

  @override
  String get onbMotiveWork => 'Trabajo';

  @override
  String get onbMotiveTravel => 'Viajes';

  @override
  String get onbMotiveExam => 'Examen oficial';

  @override
  String get onbMotiveStudies => 'Estudios';

  @override
  String get onbMotiveRelocation => 'Mudanza';

  @override
  String get onbMotivePleasure => 'Por placer';

  @override
  String get onbGoalTitle => '¿A dónde quieres llegar?';

  @override
  String get onbGoalSubtitle => 'Tu meta. La cima del mapa.';

  @override
  String get onbGoalA2 => 'A2 · Me defiendo';

  @override
  String get onbGoalB1 => 'B1 · Independiente';

  @override
  String get onbGoalB2 => 'B2 · Conversador fluido';

  @override
  String get onbGoalC1 => 'C1 · Avanzado';

  @override
  String get onbDeadlineEmpty => 'Fecha límite (opcional)';

  @override
  String onbDeadlineFilled(int day, int month, int year) {
    return 'Meta: $day/$month/$year';
  }

  @override
  String get onbCommitmentTitle => '¿Cuánto puedes dedicar?';

  @override
  String get onbCommitmentSubtitle =>
      'Esto fija tu meta diaria y la fecha de llegada.';

  @override
  String get onbCommitmentMinutesLabel => 'Minutos al día';

  @override
  String get onbCommitmentDaysLabel => 'Días por semana';

  @override
  String get onbFrequencyRelaxed => 'Relajado';

  @override
  String get onbFrequencyConstant => 'Constante';

  @override
  String get onbFrequencyIntense => 'Intenso';

  @override
  String get onbStartLevelTitle => '¿Cuánto inglés sabes ya?';

  @override
  String get onbStartLevelSubtitle =>
      'Para empezar el test de nivel en el punto justo.';

  @override
  String get onbStartLevelZero => 'Desde cero';

  @override
  String get onbStartLevelBasic => 'Sé lo básico';

  @override
  String get onbStartLevelGood => 'Tengo buen nivel';

  @override
  String onbMinutesShort(int m) {
    return '$m min';
  }

  @override
  String onbDaysShort(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días',
      one: '$days día',
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
    return '≈ $years años';
  }

  @override
  String get onbSaveError => 'No se pudo guardar tu plan. Reinténtalo.';

  @override
  String get onbPersonalityTitle => 'Tu coach ideal';

  @override
  String onbPersonalityStep(int q, int total) {
    return 'Pregunta $q de $total';
  }

  @override
  String get onbPersonalityQ1 =>
      'Si fallas tu meta del día, ¿qué prefieres oír?';

  @override
  String get onbPersonalityQ1Opt1 => '\"Sin excusas. Retómalo ya.\"';

  @override
  String get onbPersonalityQ1Opt2 => '\"¡Mañana lo das todo, tú puedes! 💪\"';

  @override
  String get onbPersonalityQ1Opt3 =>
      '\"Vas quedando atrás de tu plan, recupéralo.\"';

  @override
  String get onbPersonalityQ1Opt4 => '\"Tranqui, cuando puedas seguimos 🙂\"';

  @override
  String get onbPersonalityQ2 => '¿Cómo te gusta que te motivemos a practicar?';

  @override
  String get onbPersonalityQ2Opt1 => 'Firme y directo';

  @override
  String get onbPersonalityQ2Opt2 => 'Con energía y celebración';

  @override
  String get onbPersonalityQ2Opt3 => 'Recordándome mis metas y mi avance';

  @override
  String get onbPersonalityQ2Opt4 => 'Suave, sin presión';

  @override
  String get onbPersonalityQ3 =>
      'En la liga alguien te supera. ¿Qué te activa?';

  @override
  String get onbPersonalityQ3Opt1 => 'Que me reten a recuperarme';

  @override
  String get onbPersonalityQ3Opt2 => 'Ánimo para subir posiciones';

  @override
  String get onbPersonalityQ3Opt3 => 'Ver cuánto me falta para alcanzarlo';

  @override
  String get onbPersonalityQ3Opt4 => 'Nada, voy a mi ritmo';

  @override
  String get onbPersonalityQ4 =>
      'Cuando logras algo, ¿qué mensaje disfrutas más?';

  @override
  String get onbPersonalityQ4Opt1 => '\"Bien. Ahora el siguiente reto.\"';

  @override
  String get onbPersonalityQ4Opt2 => '\"¡Increíble, eres imparable! 🎉\"';

  @override
  String get onbPersonalityQ4Opt3 => '\"Vas adelantado a tu plan.\"';

  @override
  String get onbPersonalityQ4Opt4 => '\"Qué bien, sigue a tu ritmo 🙂\"';

  @override
  String get onbIntensityQ => '¿Qué tan seguido quieres que te recordemos?';

  @override
  String get onbIntensityOpt1 => 'Mucho, no me dejes aflojar';

  @override
  String get onbIntensityOpt2 => 'Lo justo';

  @override
  String get onbIntensityOpt3 => 'Poco';

  @override
  String get placementTitle => 'Test de ubicación';

  @override
  String placementSubtitle(int asked, int max) {
    return 'Sin pistas · pregunta $asked de $max';
  }

  @override
  String placementResultTitle(String level) {
    return 'Tu nivel: $level';
  }

  @override
  String get placementResultSubtitle =>
      'Esto no es un examen que se aprueba o se reprueba: es tu punto de partida.';

  @override
  String get placementResultViewPlan => 'VER MI PLAN';

  @override
  String get placementResultHero => 'TE UBICAMOS EN';

  @override
  String get placementResultSkillsTitle => 'Por habilidad';

  @override
  String placementResultEntryUnit(int unitNum, String unitName, String level) {
    return 'Empezarás en la Unidad $unitNum — $unitName ($level). Lo anterior queda accesible para repasar.';
  }

  @override
  String placementResultEstimateReached(
    String goalLevel,
    String humanDuration,
    String formattedDate,
  ) {
    return 'Ya alcanzas tu meta. Si sigues hasta $goalLevel: $humanDuration (aprox. $formattedDate).';
  }

  @override
  String placementResultEstimateGoal(
    String goalLevel,
    String humanDuration,
    String formattedDate,
  ) {
    return 'Si cumples tu plan, llegas a $goalLevel en $humanDuration (aprox. $formattedDate).';
  }

  @override
  String get planFocusWork =>
      'Enfoque laboral: reuniones, correos y entrevistas.';

  @override
  String get planFocusTravel =>
      'Enfoque viajes: aeropuerto, hotel, direcciones y restaurantes.';

  @override
  String get planFocusExam =>
      'Enfoque examen: simulacros IELTS/Cambridge y las 4 habilidades.';

  @override
  String get planFocusStudies =>
      'Enfoque estudios: comprensión, escritura y vocabulario académico.';

  @override
  String get planFocusRelocation =>
      'Enfoque mudanza: trámites, vivienda y vida diaria.';

  @override
  String get planFocusCulture =>
      'Enfoque cultura: series, música y conversación cotidiana.';

  @override
  String get planReadyTitle => '🎉 Tu plan está listo';

  @override
  String get planReadySubtitle =>
      'Si cumples tu plan, llegas. Esto es lo que te tomará.';

  @override
  String get planPreparing => 'PREPARANDO TU MAPA…';

  @override
  String get planStartMyPlan => 'EMPEZAR MI PLAN';

  @override
  String get planCompletionLabel => 'LLEGARÁS APROX. EL';

  @override
  String planStatsHours(int hours) {
    return '$hours h';
  }

  @override
  String get planStatsTotalLabel => 'totales';

  @override
  String planStatsFrequency(int days) {
    return '× $days días/sem';
  }

  @override
  String get planMaxPace => '¡Vas al máximo ritmo! 🔥';

  @override
  String planFasterCta(int minutes) {
    return 'Quiero llegar más rápido (sube a $minutes min/día)';
  }

  @override
  String planStartUnit(int unitNum, String unitName, String level) {
    return 'Empiezas en la Unidad $unitNum — $unitName ($level).';
  }

  @override
  String get planBadgeNow => 'AHORA';

  @override
  String get planBadgeGoal => 'META';

  @override
  String get authTitleSignUp => 'Crea tu cuenta';

  @override
  String get authTitleSignIn => 'Bienvenido de vuelta';

  @override
  String get authSubtitleSignUp =>
      'Un plan con fecha real, examen de las 4 habilidades y un coach que te trae de vuelta.';

  @override
  String get authSubtitleSignIn => 'Sigue donde lo dejaste.';

  @override
  String get authFieldName => 'Tu nombre';

  @override
  String get authFieldEmail => 'Email';

  @override
  String get authFieldPassword => 'Contraseña';

  @override
  String get authSegCreateAccount => 'Crear cuenta';

  @override
  String get authSegSignIn => 'Iniciar sesión';

  @override
  String get authCtaCreating => 'CREANDO…';

  @override
  String get authCtaLoggingIn => 'ENTRANDO…';

  @override
  String get authCtaSignUp => 'CREAR CUENTA';

  @override
  String get authCtaSignIn => 'INICIAR SESIÓN';

  @override
  String get authLegalPrefix => 'He leído y acepto los ';

  @override
  String get authLegalTerms => 'Términos';

  @override
  String get authLegalAnd => ' y la ';

  @override
  String get authLegalPrivacy => 'Política de Privacidad';

  @override
  String get authLegalSuffix => '.';

  @override
  String get authErrorNameRequired =>
      'Dinos tu nombre para personalizar tu viaje.';

  @override
  String get authErrorEmailPassword =>
      'Pon un email válido y una contraseña de 6+ caracteres.';

  @override
  String get authErrorTermsRequired =>
      'Para crear tu cuenta, acepta los Términos y la Privacidad.';

  @override
  String get authErrorGeneral => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get authErrorDuplicate => 'Ese email ya tiene cuenta. Inicia sesión.';

  @override
  String get authErrorInvalid => 'Email o contraseña incorrectos.';

  @override
  String get authErrorPasswordLength =>
      'La contraseña debe tener 6+ caracteres.';

  @override
  String get authErrorFallback => 'No se pudo continuar. Revisa tus datos.';

  @override
  String get lessonSaveErrorTitle => 'No se pudo guardar tu progreso';

  @override
  String get lessonSaveErrorMsg => 'Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get lessonNoExercises => 'Esta lección aún no tiene ejercicios.';

  @override
  String get lessonFeedbackNear => '¡Casi! 🦜';

  @override
  String get lessonFeedbackCorrect => '¡Correcto! 🦜';

  @override
  String get lessonFeedbackWrong => 'No del todo 🦜';

  @override
  String lessonFeedbackCorrectForm(String form) {
    return 'La forma correcta es: $form';
  }

  @override
  String get lessonFeedbackWellDone => '¡Bien hecho, sigue así!';

  @override
  String lessonFeedbackRightAnswer(String answer) {
    return 'Respuesta correcta: $answer';
  }

  @override
  String get lessonAudioUnavailableTitle => 'Audio no disponible';

  @override
  String get lessonAudioUnavailableMsg =>
      'Este ejercicio aún no tiene su audio. Lo saltamos: no afecta tus vidas ni tu puntaje.';

  @override
  String get lessonCompletePerfectTitle => 'LECCIÓN PERFECTA';

  @override
  String get lessonCompleteTitle => 'LECCIÓN COMPLETADA';

  @override
  String get lessonCompletePerfectMsg => '¡Impecable! 🌟';

  @override
  String get lessonCompleteMsg => '¡Lo lograste! 🎉';

  @override
  String get lessonCompleteXpLabel => 'XP GANADO';

  @override
  String get lessonCompleteAccuracyLabel => 'PRECISIÓN';

  @override
  String get lessonCompleteGoldLabel => 'ORO';

  @override
  String get lessonCompleteComboBonusLabel => 'Bonus de combo';

  @override
  String lessonCompleteComboDetail(int bonus, int combo) {
    return '+$bonus XP · x$combo seguidas';
  }

  @override
  String lessonCompleteMilestone(int days) {
    return '¡Hito de $days días! Recompensa de oro desbloqueada';
  }

  @override
  String lessonCompleteStreakDays(int streak) {
    String _temp0 = intl.Intl.pluralLogic(
      streak,
      locale: localeName,
      other: '🔥 $streak días de racha',
      one: '🔥 $streak día de racha',
    );
    return '$_temp0';
  }

  @override
  String get lessonCompleteStreakAdvanced =>
      '¡+1 hoy! Cumpliste tu meta diaria';

  @override
  String get lessonCompleteGoalMet => 'Meta diaria cumplida';

  @override
  String get lessonCompleteGoalPending => 'Sigue para cumplir tu meta de hoy';

  @override
  String get lessonCompleteFreezeSingle => 'Tu congelador salvó tu racha';

  @override
  String get lessonCompleteFreezeMulti => 'Tus congeladores salvaron tu racha';

  @override
  String get lessonCompleteSkillsUp => 'Habilidades que subieron';

  @override
  String tipCardHeader(String type) {
    return 'Matix te enseña · $type';
  }

  @override
  String tipCardPersonalized(String skill) {
    return 'Te lo doy porque tu $skill necesita un empujón. 🦜';
  }

  @override
  String get errorReviewWhyTranslation =>
      'Fíjate en la forma exacta en inglés — el sentido completo importa.';

  @override
  String get errorReviewWhyCloze =>
      'Repasa la palabra que faltaba en la frase.';

  @override
  String get errorReviewWhyWordOrder =>
      'Cuida el ORDEN de las palabras: el inglés es más fijo que el español.';

  @override
  String get errorReviewWhyMatch =>
      'Asocia cada palabra con su pareja correcta.';

  @override
  String get errorReviewWhyListening =>
      'Vuelve a escuchar con calma; el sonido te da la pista.';

  @override
  String get errorReviewWhyDefault =>
      'Repásalo: lo verás de nuevo pronto en tu repaso.';

  @override
  String get errorReviewTitle => 'Repasa lo que fallaste';

  @override
  String errorReviewSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ejercicios para reforzar. ¡Ya casi los tienes!',
      one: '1 ejercicio para reforzar. ¡Ya casi lo tienes!',
    );
    return '$_temp0';
  }

  @override
  String get errorReviewPracticeCta => 'Practicar los fallados';

  @override
  String get tileArrangePlaceholder =>
      'Toca las palabras para formar la frase…';

  @override
  String get tileArrangeAllPlaced => 'Todas colocadas — pulsa COMPROBAR';

  @override
  String get translationHint => 'Escribe la traducción…';

  @override
  String get clozeHint => 'Escribe tu respuesta…';

  @override
  String get listeningTapToListen => 'Toca para escuchar';

  @override
  String get speakingPreparingMic => 'Preparando micrófono…';

  @override
  String get speakingNoMic =>
      'Tu navegador o dispositivo no permite el micrófono.';

  @override
  String get speakingIReadIt => 'Ya lo leí ✓';

  @override
  String get speakingManualDone => '¡Bien! Sigue practicando en voz alta. 🦜';

  @override
  String get speakingListening => 'Escuchando…';

  @override
  String get speakingTalk => 'Hablar';

  @override
  String get speakingGood => '¡Bien pronunciado! 🦜';

  @override
  String get speakingNoSound => 'No te escuché — acércate e inténtalo';

  @override
  String get speakingOk => 'Vas bien. Léelo otra vez si quieres';

  @override
  String speakingHeard(String heard) {
    return 'Escuché: \"$heard\"';
  }

  @override
  String get speakingVolumeHint =>
      'Sube el volumen del micro, o toca \"Ya lo leí ✓\" para continuar.';

  @override
  String speakingRetryHint(String heard) {
    return 'Escuché: \"$heard\". Puedes reintentar o tocar \"Ya lo leí ✓\".';
  }

  @override
  String get speakingHearModel => 'Oír el modelo';

  @override
  String get audioPlayDefault => 'Escuchar';

  @override
  String get stubTagPronunciation => 'PRONUNCIACIÓN';

  @override
  String get stubNotePronunciation =>
      'El reconocimiento de voz llega pronto. Por ahora, practícalo en voz alta y continúa.';

  @override
  String get stubTagListening => 'COMPRENSIÓN AUDITIVA';

  @override
  String get stubNoteListening =>
      'El audio de este ejercicio se graba pronto. Por ahora, continúa.';

  @override
  String get stubTagDictation => 'DICTADO';

  @override
  String get stubNoteDictation =>
      'El dictado necesita audio (se graba pronto). Por ahora, continúa.';

  @override
  String get stubTagGuidedWriting => 'ESCRITURA GUIADA';

  @override
  String get stubNoteGuidedWriting =>
      'La escritura guiada con corrección llega pronto. Por ahora, continúa.';

  @override
  String get stubTagComingSoon => 'PRÓXIMAMENTE';

  @override
  String get stubNoteComingSoon =>
      'Este tipo de ejercicio llega pronto. Por ahora, continúa.';

  @override
  String get noHeartsTitle => 'Te quedaste sin vidas ❤️';

  @override
  String get noHeartsMsg =>
      '¡Tranqui, le pasa a todos! Las vidas se regeneran con el tiempo; si quieres seguir ahora, recárgalas con oro.';

  @override
  String get noHeartsRefill => 'Recargar vidas y seguir';

  @override
  String get noHeartsQuit => 'Salir de la lección';

  @override
  String get checkpointStartError =>
      'No se pudo iniciar el examen. Intenta de nuevo.';

  @override
  String get checkpointPortalTitle => 'El portal de la unidad';

  @override
  String get checkpointCoachMsg => '🦜  ¡Demuestra lo que sabes!';

  @override
  String get checkpointIntroMsg =>
      'Supera el portal para abrir la siguiente región del mapa.';

  @override
  String get checkpointStatTimed => 'cronometrado';

  @override
  String get checkpointStatPass => 'para pasar';

  @override
  String get checkpointStatQuestions => 'preguntas';

  @override
  String get checkpointStartCta => 'EMPEZAR CHECKPOINT';

  @override
  String get checkpointNoCost =>
      'No cuesta vidas · puedes reintentarlo cuando quieras';

  @override
  String get checkpointSkillsBreakdown => 'Desglose por habilidad';

  @override
  String get checkpointPassedLabel => '✓ CHECKPOINT APROBADO';

  @override
  String get checkpointFailedLabel => 'CHECKPOINT NO APROBADO';

  @override
  String get checkpointPassedMsg => '¡Unidad superada!';

  @override
  String get checkpointFailedMsg => 'Aún no superas el portal';

  @override
  String checkpointPassedScore(int pct) {
    return '$pct% de aciertos';
  }

  @override
  String checkpointFailedScore(int pct) {
    return '$pct% · necesitas 80%';
  }

  @override
  String get checkpointSkillSoon => 'pronto';

  @override
  String get checkpointRegionUnlockedLabel => '✦ NUEVA REGIÓN DESBLOQUEADA';

  @override
  String get checkpointCompleteLabel => '✓ UNIDAD COMPLETA';

  @override
  String checkpointRegionUnlockedMsg(String unit) {
    return '¡$unit completa! Se desbloqueó la siguiente región.';
  }

  @override
  String checkpointCompleteSoonMsg(String unit) {
    return '¡$unit completa! La siguiente región llega pronto.';
  }

  @override
  String get checkpointContinueJourney => 'CONTINUAR EL VIAJE';

  @override
  String get checkpointRetry => 'REINTENTAR';

  @override
  String get checkpointBackToMap => 'Volver al mapa';

  @override
  String checkpointMissingPoints(int missing, int pct) {
    return 'Te faltaron $missing puntos para el $pct%. ¡Casi!';
  }

  @override
  String get checkpointReinforceTitle => 'REFUERZA ESTAS HABILIDADES';

  @override
  String get checkpointReinforceEmpty => 'Repasa la unidad y reintenta.';

  @override
  String get checkpointSubmitError =>
      'No se pudo enviar el examen. Intenta de nuevo.';

  @override
  String get checkpointExitTitle => '¿Salir del examen?';

  @override
  String get checkpointExitMsg => 'Perderás el progreso de este intento.';

  @override
  String get checkpointExitStay => 'Seguir';

  @override
  String get checkpointLoadErrorTitle => 'No pudimos cargar el examen';

  @override
  String get checkpointLoadErrorMsg =>
      'Vuelve al mapa e inténtalo de nuevo en un momento.';

  @override
  String get checkpointBackToMapCta => 'VOLVER AL MAPA';

  @override
  String get checkpointFinish => 'TERMINAR';

  @override
  String get checkpointNext => 'SIGUIENTE';

  @override
  String lessonPreviewLoadError(String error) {
    return 'No se pudo cargar la lección.\n$error';
  }

  @override
  String lessonPreviewExerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ejercicios',
      one: '1 ejercicio',
    );
    return '$_temp0';
  }

  @override
  String get dailyGoalTitle => 'Meta de hoy';

  @override
  String dailyGoalXpOf(int earned, int goal) {
    return '$earned/$goal XP';
  }

  @override
  String get dailyGoalMet => '¡Meta cumplida! Tu racha avanza hoy 🔥';

  @override
  String dailyGoalRemaining(int n) {
    return 'Te faltan $n XP para cumplir hoy';
  }

  @override
  String dailyGoalSemantics(int earned, int goal) {
    return 'Meta diaria: $earned de $goal XP';
  }

  @override
  String get missionWelcomeTitle => '¡Tu viaje ha comenzado!';

  @override
  String get missionWelcomeBody =>
      'Colecciona las 100 palabras esenciales al avanzar. ¡Vamos!';

  @override
  String missionRewardBanner(int xp, int gold) {
    return '+$xp XP · +$gold oro de bienvenida';
  }

  @override
  String get missionStartError => 'No se pudo empezar. Inténtalo de nuevo.';

  @override
  String comboLabel(int combo) {
    return 'x$combo';
  }

  @override
  String shopChestWon(int reward, int total) {
    return '🎁 ¡Ganaste $reward de oro! Ahora tienes $total.';
  }

  @override
  String get shopChestAlready => 'Ya abriste el cofre hoy. Vuelve mañana 🙂';

  @override
  String shopHeartsRefilled(int gold) {
    return '❤️ Vidas recargadas. Gastaste 50 oro, te quedan $gold.';
  }

  @override
  String shopFreezeBought(int gold) {
    return '🧊 Congelador comprado. Gastaste 50 oro, te quedan $gold.';
  }

  @override
  String shopNotEnoughGold(int cost) {
    return 'No tienes suficiente oro (cuesta $cost).';
  }

  @override
  String get leagueNoMovementNote =>
      'En beta aún no hay ascensos ni descensos: juega para ganar XP y subir en la tabla.';
}
