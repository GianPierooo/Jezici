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
  String get learnLangEn => 'inglés';

  @override
  String get learnLangPt => 'portugués';

  @override
  String get learnLangFr => 'francés';

  @override
  String get learnLangIt => 'italiano';

  @override
  String get learnLangDe => 'alemán';

  @override
  String get learnLangNl => 'neerlandés';

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
  String get onbCoachBubble => '¡Hagamos un plan a tu medida! 🦜';

  @override
  String get onbLanguageTitle => '¿En qué idioma prefieres la app?';

  @override
  String get onbLanguageSubtitle =>
      'Elige el idioma de los menús y mensajes. No es el idioma que vas a aprender.';

  @override
  String get onbLanguageInfoEn =>
      'Esto solo cambia el idioma de los menús y textos, no lo que vas a aprender.';

  @override
  String get onbLanguageInfoPt =>
      'Vas a aprender portugués 🇧🇷. Esto solo cambia el idioma de la app.';

  @override
  String get onbNameTitle => '¿Cómo te llamas?';

  @override
  String get onbNameSubtitle =>
      'Así te saludamos y aparecerá en tu perfil y certificados.';

  @override
  String get onbNameHint => 'Tu nombre';

  @override
  String get onbTargetTitle => '¿Qué idioma quieres aprender?';

  @override
  String get onbTargetSubtitle =>
      'Tu curso. Esto define tu plan y el test de nivel. Podrás cambiarlo luego en Ajustes.';

  @override
  String onbMotiveTitle(String course) {
    return '¿Por qué aprendes $course?';
  }

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
  String onbStartLevelTitle(String course) {
    return '¿Cuánto $course sabes ya?';
  }

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
  String get placementResultStartFromZero => 'Prefiero empezar desde el inicio';

  @override
  String placementResultStartFromZeroConfirm(String level) {
    return 'Empezarás desde A1 (Unidad 1), no desde $level. Tú decides: avanzarás a tu ritmo. ¿Continuar?';
  }

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
  String get coursePlacementOfferTitle => '¿Hacer el test de ubicación?';

  @override
  String coursePlacementOfferBody(String course) {
    return 'Haz una prueba corta y empieza en tu nivel real de $course, en lugar de desde el principio.';
  }

  @override
  String get coursePlacementDoTest => 'Hacer el test';

  @override
  String get coursePlacementFromScratch => 'Empezar desde el principio';

  @override
  String coursePlacementDone(String level) {
    return '¡Listo! Te ubicamos en $level.';
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
  String get planReadyKicker => 'PERSONALIZADO PARA TI';

  @override
  String get planStartJourney => 'Empezar mi viaje';

  @override
  String get planJourneyHere => 'ESTÁS AQUÍ';

  @override
  String get planJourneyGoal => 'TU META';

  @override
  String get planHalfTime => '⚡ ¡La mitad de tiempo!';

  @override
  String planPaceLine(int minutes, String level) {
    return 'Con $minutes min/día llegas a $level el';
  }

  @override
  String get planLeverTitleOff => '¿Quieres llegar más rápido?';

  @override
  String get planLeverTitleOn => '🚀 ¡Vas a toda máquina!';

  @override
  String planLeverTextOff(int minutes) {
    return 'Sube a $minutes min/día y llegas en la mitad del tiempo 💪';
  }

  @override
  String planLeverTextOn(int minutes) {
    return 'Plan de $minutes min/día activado: llegas en la mitad del tiempo.';
  }

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
  String get authContinueGoogle => 'Continuar con Google';

  @override
  String get authOr => 'o';

  @override
  String get authGoogleError =>
      'No se pudo continuar con Google. Intenta con tu email.';

  @override
  String get authCheckEmail =>
      'Te enviamos un correo para confirmar tu cuenta. Ábrelo y vuelve para continuar.';

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
  String noHeartsRefillPriced(int gold) {
    return 'Recargar vidas · 🪙$gold';
  }

  @override
  String get noHeartsInsufficientGold =>
      'No tienes oro suficiente para recargar.';

  @override
  String get noHeartsRefilled => '¡Vidas recargadas! ❤️';

  @override
  String get noHeartsQuit => 'Salir de la lección';

  @override
  String get certHolderIntro => 'Se certifica que';

  @override
  String get heartsPanelTitle => 'Vidas';

  @override
  String get heartsPanelRegen =>
      'Se regeneran solas con el tiempo. Pierdes una vida por cada respuesta incorrecta.';

  @override
  String get heartsPanelFull => '¡Tienes todas tus vidas! ❤️';

  @override
  String get goldPanelTitle => 'Oro';

  @override
  String get goldPanelWhat =>
      'Ganas oro completando lecciones y retos. Sirve para recargar vidas y comprar en la tienda.';

  @override
  String get goldPanelOpenShop => 'Abrir tienda';

  @override
  String get dailyPanelTitle => 'Meta diaria';

  @override
  String get dailyPanelWhat =>
      'Cuenta el XP que ganas en lecciones y práctica. Cúmplela cada día para mantener tu racha.';

  @override
  String get dailyPanelDone =>
      '¡Meta de hoy cumplida! 🎉 Sigue así para tu racha.';

  @override
  String get dailyPanelClose => 'Seguir aprendiendo';

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

  @override
  String get mapLoading => 'Cargando tu mapa…';

  @override
  String mapLoadError(String error) {
    return 'No se pudo cargar el mapa.\n$error';
  }

  @override
  String get mapEmptyState => 'Aún no hay contenido sembrado.';

  @override
  String get mapNodeLockedNextUnit =>
      'Bloqueada · aprueba el checkpoint de la unidad anterior';

  @override
  String get mapNodeLockedNextLesson =>
      'Bloqueada · completa la lección anterior';

  @override
  String get mapMascotPeak => '¡A la cima! 💪';

  @override
  String get mapStartBubble => 'EMPIEZA';

  @override
  String get mapSummitCertLabel => 'TU META · CERTIFICADO';

  @override
  String get mapSummitPeak => '⛰ LA CIMA';

  @override
  String mapUnitBanner(int num, String level) {
    return 'UNIDAD $num · $level';
  }

  @override
  String mapUnitBannerLocked(int num, String level) {
    return 'UNIDAD $num · $level · 🔒 BLOQUEADA';
  }

  @override
  String mapExamUnit(int num) {
    return 'EXAMEN · UNIDAD $num';
  }

  @override
  String get topBarMusicOff => 'Apagar música del mapa';

  @override
  String get topBarMusicOn => 'Encender música del mapa';

  @override
  String get topBarNotifications => 'Notificaciones';

  @override
  String get practiceKicker => 'ENTRENAMIENTO';

  @override
  String get practiceTitle => 'Practicar';

  @override
  String get practiceHeaderSubtitle =>
      'Refuerza lo que ya viste y no lo olvides 🧠';

  @override
  String get practiceSrsBadge => 'REPASO ESPACIADO';

  @override
  String get practiceSrsTitle => 'Rescate de palabras';

  @override
  String get practiceSrsWords => 'palabras por repasar';

  @override
  String get practiceSrsSubtitle => 'Antes de que se te olviden';

  @override
  String get practiceSrsUpToDate => '¡Vas al día! Nada urgente por repasar';

  @override
  String get practiceSrsCta => 'Rescatar ahora 🪝';

  @override
  String get practiceWeakTitle => 'Refuerza tu punto débil';

  @override
  String get practiceWeakGeneric => 'Trabaja tu habilidad más floja';

  @override
  String get practicePracticeBtn => 'Practicar';

  @override
  String get practiceReinforceTitle => 'Reforzar lo que fallé';

  @override
  String get practiceReinforceSubtitle =>
      'Re-evalúa solo los ejercicios que erraste';

  @override
  String get practiceMoreTitle => 'Más práctica';

  @override
  String get practiceReadingHint => 'Comprensión';

  @override
  String get practiceWritingHint => 'Redacción';

  @override
  String get practiceRepasoTitle => 'Repaso';

  @override
  String get practiceRepasoSubtitle => 'Conceptos por habilidad';

  @override
  String get practiceImmersionTitle => 'Inmersión';

  @override
  String get practiceImmersionSubtitle => 'Historias con audio';

  @override
  String get practiceTimedTitle => 'Contrarreloj';

  @override
  String get practiceTimedBadge => '+XP EXTRA';

  @override
  String get practiceTimedSubtitle => 'Responde rápido y gana XP extra · 90 s';

  @override
  String get practiceTimedCta => 'Empezar contrarreloj';

  @override
  String get practiceXpNote =>
      'La práctica da un poco menos de XP que una lección nueva. Para ganar más, avanza en el mapa.';

  @override
  String get practiceNothingToReview =>
      '¡Nada que reforzar ahora! Vas al día. 🎉';

  @override
  String get practiceStartError => 'No se pudo iniciar la práctica.';

  @override
  String get profileHeaderKicker => 'MI PERFIL';

  @override
  String profileTravelerChip(int level) {
    return 'Nivel de viajero $level';
  }

  @override
  String profileTravelerNext(int level, int xp) {
    return 'Nivel $level · $xp XP';
  }

  @override
  String get profileActiveLangLabel => 'IDIOMA ACTIVO';

  @override
  String profileActiveLangValue(String language, String goal) {
    return '$language · Objetivo $goal';
  }

  @override
  String get profileActiveLangChange => 'Cambiar';

  @override
  String profileRadarGoalTag(String level) {
    return 'META $level';
  }

  @override
  String profileSkillsReadyChip(int ready, String level) {
    return '$ready / 4 en $level';
  }

  @override
  String get profileWeakAlertTitle => 'Tu punto débil es';

  @override
  String profileWeakAlertBody(String level) {
    return 'Súbelo a $level y certificarás tu nivel completo.';
  }

  @override
  String profileCertLockedNeed(String level) {
    return 'Necesitas $level en las 4 habilidades';
  }

  @override
  String profileCertReadyCount(int n) {
    return '$n de 4 habilidades listas';
  }

  @override
  String get profileCertVerifiedLine => 'Verificado · examen Jezici';

  @override
  String get profileStatsTitle => 'Estadísticas';

  @override
  String profileStreakLine(int n) {
    return '$n días de racha';
  }

  @override
  String profileStreakBest(int n) {
    return 'Mejor: $n';
  }

  @override
  String get profileStreakToday => 'HOY';

  @override
  String profileLeagueRank(int n) {
    return 'Puesto $n';
  }

  @override
  String get leagueCurrentDivision => 'DIVISIÓN ACTUAL';

  @override
  String get leagueEndsIn => 'Termina en';

  @override
  String get leagueXpThisWeek => 'XP esta semana';

  @override
  String leaguePromoteTo(String division) {
    return 'SUBEN A $division';
  }

  @override
  String leagueDemoteTo(String division) {
    return 'BAJAN A $division';
  }

  @override
  String get leagueTagUp => 'Sube';

  @override
  String get leagueTagRisk => 'En riesgo';

  @override
  String get leagueTagYou => '¡Mantente arriba!';

  @override
  String get leagueMascotCheer => '¡Sigue subiendo! 💪';

  @override
  String get checkpointMapDone => 'UNIDAD ✓';

  @override
  String get checkpointMapNext => 'SIGUIENTE REGIÓN';

  @override
  String checkpointFailCount(int n) {
    return '$n fallos';
  }

  @override
  String get examPassedBadge => 'EXAMEN SUPERADO';

  @override
  String get examFailedBadge => 'AÚN NO · ¡CASI!';

  @override
  String get examPassedVerdict => '¡Felicidades! Alcanzaste el';

  @override
  String get examFailedVerdict => 'Aún no alcanzas el';

  @override
  String examLevelWord(String level) {
    return 'nivel $level';
  }

  @override
  String get examVerifiedBy => 'Verificado por el examen Jezici';

  @override
  String examSkillsAtLevel(String level) {
    return 'Las 4 habilidades en $level';
  }

  @override
  String get examSkillsWhyCertified =>
      'Todas alcanzan la meta — por eso se certifica';

  @override
  String examSkillsGoalHint(int pct) {
    return 'Meta: $pct% por habilidad';
  }

  @override
  String examGoalTag(String level) {
    return 'META $level';
  }

  @override
  String get examGlobalScore => 'Puntaje global';

  @override
  String get examStrength => 'Fortaleza';

  @override
  String get examPolish => 'Pulir';

  @override
  String get examSeeCertificate => 'Ver certificado';

  @override
  String get examShareCopied => 'Resultado copiado para compartir ✓';

  @override
  String examRewards(int xp, int gold) {
    return '+$xp XP · +$gold oro por certificar';
  }

  @override
  String examNotYetCertified(String level) {
    return 'Aún no certificas $level';
  }

  @override
  String examRaiseSkill(String skill) {
    return 'sube tu $skill';
  }

  @override
  String examReinforceSkill(String skill) {
    return 'Reforzar $skill';
  }

  @override
  String get examRetry => 'REINTENTAR EXAMEN';

  @override
  String get chestTitleClosed => '¡Un cofre te espera!';

  @override
  String get chestSubClosed => 'Tócalo para descubrir tu premio';

  @override
  String get chestOpenCta => 'Abrir cofre';

  @override
  String chestTitleOpened(int reward) {
    return '¡+$reward de oro!';
  }

  @override
  String get chestSubOpened => 'Tu recompensa del día';

  @override
  String get chestGoldLabel => 'ORO';

  @override
  String get chestClaimCta => '¡Reclamar!';

  @override
  String get chestComeBack => 'Vuelve mañana por otro cofre 🎁';

  @override
  String get chestTitleTomorrow => 'Ya abriste tu cofre';

  @override
  String get chestSubTomorrow => 'Vuelve mañana por otro 🎁';

  @override
  String get chestCloseCta => 'Entendido';

  @override
  String get missionAppBarTitle => 'Misión';

  @override
  String get missionMainTitle => 'Las 100 palabras esenciales';

  @override
  String get missionMainDescription =>
      'Tu primer gran objetivo: dominar las 100 palabras y frases de más alta frecuencia del inglés. Las irás coleccionando al completar tus lecciones. Al juntarlas, ganas el badge \"100 esenciales\".';

  @override
  String missionWordsCount(int n) {
    return '$n palabras';
  }

  @override
  String get missionStartLoading => 'PREPARANDO…';

  @override
  String get missionStartCta => '¡EMPEZAR MI VIAJE! 🚀';

  @override
  String get missionCatGreetings => 'Saludos y cortesía';

  @override
  String get missionCatPronouns => 'Pronombres y \"to be\"';

  @override
  String get missionCatVerbs => 'Verbos frecuentes';

  @override
  String get missionCatNumbers => 'Números 1–20';

  @override
  String get missionCatFamily => 'Personas y familia';

  @override
  String get missionCatDaily => 'Cotidiano';

  @override
  String get missionCatQuestions => 'Preguntas y útiles';

  @override
  String get shopTitle => 'Tienda';

  @override
  String get shopChestCardTitle => 'Cofre diario';

  @override
  String get shopChestCardSubtitleAvailable =>
      'Ábrelo para una recompensa sorpresa';

  @override
  String get shopChestCardSubtitleUnavailable =>
      'Ya lo abriste hoy · vuelve mañana';

  @override
  String get shopChestCardActionOpen => 'ABRIR';

  @override
  String get shopChestCardActionTomorrow => 'MAÑANA';

  @override
  String get shopHeartsCardTitle => 'Recargar vidas';

  @override
  String shopHeartsCardSubtitle(int hearts) {
    return 'Vuelve a 5 corazones · tienes $hearts';
  }

  @override
  String get shopFreezeCardTitle => 'Congelador de racha';

  @override
  String shopFreezeCardSubtitle(int freezes) {
    return 'Protege tu racha un día · tienes $freezes';
  }

  @override
  String get streakTitle => 'Tu racha';

  @override
  String streakDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días de racha',
      one: '$count día de racha',
    );
    return '$_temp0';
  }

  @override
  String streakRecord(int longest) {
    return 'Récord: $longest · Cumple tu meta diaria para sumar';
  }

  @override
  String get streakMilestonesTitle => 'Hitos';

  @override
  String get streakMilestonesSubtitle =>
      'Cada hito desbloquea oro de recompensa.';

  @override
  String get streakMilestoneReached => '¡Conseguido!';

  @override
  String streakMilestoneNext(int current, int days) {
    return 'Próximo · vas $current/$days';
  }

  @override
  String get streakMilestoneLocked => 'Bloqueado';

  @override
  String get streakFreezeSubtitle =>
      'Protege tu racha un día que no puedas practicar.';

  @override
  String streakFreezeCount(int freezes) {
    return 'Tienes $freezes';
  }

  @override
  String streakFreezePrice(int cost) {
    return 'Cuesta $cost oro';
  }

  @override
  String get streakFreezeBuy => 'Comprar';

  @override
  String get leagueTabMyLeague => 'Mi liga';

  @override
  String get leagueTabTables => 'Tablas';

  @override
  String leagueTitle(String division) {
    return 'Liga $division';
  }

  @override
  String leagueWarmingUpSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jugadores · arrancando',
      one: '$count jugador · arrancando',
    );
    return '$_temp0';
  }

  @override
  String leagueRankActive(int rank, int promote) {
    return 'Vas #$rank esta semana · top $promote ascienden';
  }

  @override
  String leagueRankInactive(int rank) {
    return 'Vas #$rank esta semana';
  }

  @override
  String get leagueWarmingUpTitle => 'Tu liga está arrancando';

  @override
  String leagueWarmingUpMessage(int min) {
    return 'Cuando haya al menos $min jugadores activos, competiréis por ascender. Mientras, suma XP: tu progreso ya cuenta.';
  }

  @override
  String get leagueWeeklyRankingTitle => 'Clasificación de la semana';

  @override
  String get leagueWeeklyRankingHint =>
      'Suma XP (lecciones y práctica) para subir. Cierre cada lunes.';

  @override
  String get leaguePromotionZone => 'ZONA DE ASCENSO';

  @override
  String get leagueDemotionZone => 'ZONA DE DESCENSO';

  @override
  String get leagueDivisionBronce => 'Bronce';

  @override
  String get leagueDivisionPlata => 'Plata';

  @override
  String get leagueDivisionOro => 'Oro';

  @override
  String get leagueDivisionZafiro => 'Zafiro';

  @override
  String get leagueDivisionRubi => 'Rubí';

  @override
  String get leagueDivisionDiamante => 'Diamante';

  @override
  String get leaderboardMetricXp => 'XP';

  @override
  String get leaderboardMetricLessons => 'Lecciones';

  @override
  String get leaderboardMetricStreak => 'Racha';

  @override
  String get leaderboardMetricCertificates => 'Certificados';

  @override
  String get leaderboardUnitLessons => 'lecc.';

  @override
  String get leaderboardUnitDays => 'd';

  @override
  String get leaderboardUnitCertificates => 'cert.';

  @override
  String get leaderboardWindowWeekly => 'Semanal';

  @override
  String get leaderboardWindowMonthly => 'Mensual';

  @override
  String get leaderboardWindowYearly => 'Anual';

  @override
  String get leaderboardWindowAlltime => 'Histórico';

  @override
  String get leaderboardStreakHint => 'Racha más larga de todos los tiempos.';

  @override
  String get leaderboardScopeGlobal => 'Global';

  @override
  String get leaderboardScopeDivision => 'Mi división';

  @override
  String get leaderboardLoadError => 'No se pudo cargar la tabla.';

  @override
  String get leaderboardEmpty =>
      'Aún no hay datos para esta tabla. ¡Sé el primero en aparecer!';

  @override
  String leaderboardMyPosition(int rank, int total) {
    return 'Tu posición: #$rank de $total';
  }

  @override
  String get leaderboardNotRanked => 'Aún no estás en esta tabla';

  @override
  String leaderboardShowingTop(int shown, int total) {
    return 'Mostrando top $shown de $total';
  }

  @override
  String get leagueLoadError => 'No se pudo cargar la liga.';

  @override
  String get profilePracticeNoWeaknessToday =>
      '¡Nada que reforzar ahora! Vas al día. 🎉';

  @override
  String get profilePracticeWeaknessTitle => 'Refuerzo de debilidades';

  @override
  String get profilePracticeStartError => 'No se pudo iniciar la práctica.';

  @override
  String get profileSkillsTitle => 'Tus 4 habilidades';

  @override
  String get profileSkillsDescription =>
      'Las lecciones suben tu DOMINIO; el nivel sube al aprobar el examen.';

  @override
  String profileSkillImbalanceWarning(
    String skillA,
    int pct1,
    String skillB,
    int pct2,
  ) {
    return 'Tu $skillA va al $pct1% pero tu $skillB al $pct2% → refuerza $skillB.';
  }

  @override
  String get profileStatStreak => 'RACHA';

  @override
  String get profileStatXp => 'XP TOTAL';

  @override
  String get profileStatGold => 'ORO';

  @override
  String get profileNoPlan =>
      'Crea tu cuenta en el onboarding para ver tu plan.';

  @override
  String get profileCertificatesTitle => 'Certificados';

  @override
  String get profileAchievementsTitle => 'Logros';

  @override
  String get profileNoAchievements => 'Completa lecciones para ganar logros.';

  @override
  String profileExamCardTitle(String level) {
    return 'Examen de nivel $level';
  }

  @override
  String profileExamCardTitleLocked(String level) {
    return 'Examen de nivel $level (bloqueado)';
  }

  @override
  String get profileExamReady => '¡Listo para certificar! Toca para empezar.';

  @override
  String profileExamUnitsRequired(int done, int total) {
    return 'Completa las unidades: $done/$total checkpoints';
  }

  @override
  String get profileExamMasteryRequired =>
      'Lleva una habilidad al 80% de dominio para abrir su examen';

  @override
  String profileCertificateCardTitle(String level) {
    return 'Certificado $level';
  }

  @override
  String profileCertificateInfo(String folio, String code) {
    return 'Folio $folio · cód. $code';
  }

  @override
  String get profileForYouTitle => 'Para ti';

  @override
  String profileWeakestSkill(String skill, String level) {
    return 'Tu punto débil ahora: $skill ($level). Unos minutos lo equilibran.';
  }

  @override
  String profilePracticeWeaknessButton(String skill) {
    return 'PRACTICAR $skill';
  }

  @override
  String get profileSkillWeakestBadge => 'más débil';

  @override
  String get profileSkillExamReadyBadge => 'examen listo';

  @override
  String profileMasteryGateCertified(String level) {
    return 'Ya certificaste $level 🎓';
  }

  @override
  String profileMasteryGateUnlocked(String level, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count habilidades',
      one: '1 habilidad',
    );
    return 'Examen $level desbloqueado 🔓 ($_temp0)';
  }

  @override
  String profileMasteryGateLocked(String level, int pct) {
    return 'Dominio $level: lleva una habilidad al 80% para abrir su examen (vas $pct%)';
  }

  @override
  String get profilePlanTitle => 'Mi plan';

  @override
  String get profilePlanOnTrack => 'Justo en tu plan';

  @override
  String profilePlanAhead(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Vas $n días adelante 🎉',
      one: 'Vas 1 día adelante 🎉',
    );
    return '$_temp0';
  }

  @override
  String profilePlanBehind(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Vas $n días atrás',
      one: 'Vas 1 día atrás',
    );
    return '$_temp0';
  }

  @override
  String profilePlanProgress(String level) {
    return 'Avance a $level';
  }

  @override
  String profilePlanEstimatedCompletion(String date) {
    return 'Llegas aprox. el $date';
  }

  @override
  String profilePlanIntensity(int mins, int days) {
    return '$mins min/día · $days días/semana';
  }

  @override
  String get profileNamePlaceholder => 'Pon tu nombre';

  @override
  String profileMemberSince(String date) {
    return 'Miembro desde $date';
  }

  @override
  String get profileNotebookTitle => 'Cuaderno de datos';

  @override
  String get profileNotebookSubtitle => 'Tips y trucos que has aprendido';

  @override
  String get profileEditNameError => 'Escribe tu nombre.';

  @override
  String get profileEditSaveError => 'No se pudo guardar. Inténtalo de nuevo.';

  @override
  String get profileEditNameHint => '¿Cómo te llamas?';

  @override
  String get profileEditAvatarColor => 'Color de tu avatar';

  @override
  String get profileEditCountry => 'País';

  @override
  String get profileEditBio => 'Una meta o algo sobre ti (opcional)';

  @override
  String get profileEditBioHint => 'Ej.: Quiero viajar por Brasil este año';

  @override
  String get profileEditSave => 'GUARDAR';

  @override
  String get profileEditSaving => 'GUARDANDO…';

  @override
  String profileLevelPill(String level) {
    return 'Nivel $level';
  }
}
