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
  String get tourSkip => 'Saltar';

  @override
  String get tourNext => 'Siguiente';

  @override
  String get tourBack => 'Atrás';

  @override
  String get tourStart => '¡Empezar!';

  @override
  String get tourWelcomeTitle => '¡Hola! Soy Jezi 🦜';

  @override
  String get tourWelcomeBody =>
      'Te acompaño en tu viaje. Te muestro la app en 20 segundos.';

  @override
  String get tourMapTitle => 'Tu camino';

  @override
  String get tourMapBody =>
      'Este es tu mapa. Empieza por tu primera lección, más abajo.';

  @override
  String get tourTopbarTitle => 'Tu progreso';

  @override
  String get tourTopbarBody =>
      'Aquí ves tus vidas ❤️, tu oro 🪙 y tu racha 🔥 diaria.';

  @override
  String get tourPracticeTitle => 'Practicar';

  @override
  String get tourPracticeBody =>
      'Cuando aprendas palabras, aquí las repasas para no olvidarlas.';

  @override
  String get tourConversarTitle => 'Conversar';

  @override
  String get tourConversarBody =>
      'Practica hablando y haz amigos que aprenden contigo.';

  @override
  String get tourLeaguesTitle => 'Ligas';

  @override
  String get tourLeaguesBody => 'Compite sumando XP cada semana.';

  @override
  String get tourProfileTitle => 'Perfil';

  @override
  String get tourProfileBody =>
      'Tu progreso, tus 4 habilidades y tus certificados.';

  @override
  String get tourDoneTitle => '¡Listo!';

  @override
  String get tourDoneBody =>
      'Empieza tu primera lección. Yo te aviso cuando toque practicar.';

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
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSecLanguage => 'IDIOMA';

  @override
  String get settingsSecNotifications => 'NOTIFICACIONES';

  @override
  String get settingsSecGoal => 'META Y RECORDATORIOS';

  @override
  String get settingsSecAccount => 'CUENTA';

  @override
  String get settingsSecOther => 'OTROS';

  @override
  String get settingsSecAdvanced => 'AVANZADO';

  @override
  String get settingsLearns => 'Aprendes';

  @override
  String settingsLearnsSub(String lang, String goal) {
    return '$lang · Objetivo $goal';
  }

  @override
  String get settingsChange => 'Cambiar';

  @override
  String get settingsAppLanguageRow => 'Idioma de la app';

  @override
  String get settingsChooseCourse => '¿Qué idioma quieres aprender?';

  @override
  String get settingsChooseAppLang => 'Idioma de la app';

  @override
  String get settingsCoachIntensity => 'Intensidad del coach';

  @override
  String get settingsCoachInsist => '¿Cuánto insiste Jezi?';

  @override
  String get settingsIntensityLow => 'Suave';

  @override
  String get settingsIntensityMid => 'Media';

  @override
  String get settingsIntensityHigh => 'Alta';

  @override
  String get settingsQuiet => 'No molestar';

  @override
  String get settingsQuietSub => 'Sin avisos en este horario';

  @override
  String get settingsQuietOff => 'Desactivado';

  @override
  String get settingsQuietEnable => 'Activar horario de silencio';

  @override
  String get settingsQuietFrom => 'Desde';

  @override
  String get settingsQuietTo => 'Hasta';

  @override
  String get settingsMeta => 'Meta diaria';

  @override
  String settingsMetaSub(int min, int xp) {
    return '$min min · $xp XP al día';
  }

  @override
  String settingsMetaXpDay(int xp) {
    return '≈ $xp XP/día (más minutos = meta más alta)';
  }

  @override
  String get settingsDailyReminder => 'Recordatorio diario';

  @override
  String get settingsDailyReminderSub => 'Todos los días a las 20:00';

  @override
  String get settingsStreakAlert => 'Aviso de racha en peligro';

  @override
  String get settingsStreakAlertSub => 'Si olvidas practicar';

  @override
  String get settingsReminderNote =>
      'Tu preferencia se guarda. Los recordatorios push llegan pronto.';

  @override
  String get settingsEditProfile => 'Editar perfil';

  @override
  String get settingsSubscription => 'Suscripción';

  @override
  String get settingsPlanFree => 'Plan gratis · Mejorar';

  @override
  String get settingsLogout => 'Cerrar sesión';

  @override
  String get settingsSounds => 'Sonidos';

  @override
  String get settingsMusic => 'Música del mapa';

  @override
  String get settingsMusicSub =>
      'Loop ambiente en Aprender. Baja sola con los sonidos.';

  @override
  String get settingsVibration => 'Vibración';

  @override
  String get settingsPrivacy => 'Privacidad y datos';

  @override
  String get settingsPrivacyPolicy => 'Política de Privacidad';

  @override
  String get settingsTerms => 'Términos y Condiciones';

  @override
  String get settingsTestMatix => 'Probar a Jezi';

  @override
  String get settingsMetrics => 'Ver métricas (interno)';

  @override
  String get settingsExport => 'Exportar mis datos';

  @override
  String get settingsDelete => 'Borrar mi cuenta';

  @override
  String get settingsSaveError => 'No se pudieron guardar los ajustes.';

  @override
  String get coachNameManoDura => 'Mano dura';

  @override
  String get coachNamePositivo => 'Positivo';

  @override
  String get coachNameRezago => 'Sin rezago';

  @override
  String get coachNameSuave => 'Suave';

  @override
  String get coachExManoDura => '«Sin excusas. Entra ya. 💪»';

  @override
  String get coachExPositivo => '«¡Vas genial, sigue así! 🎉»';

  @override
  String get coachExRezago => '«Llevas 2 días sin practicar… 👀»';

  @override
  String get coachExSuave => '«Sin prisa, ve a tu ritmo 🌱»';

  @override
  String get courseSwitchFailed => 'No se pudo cambiar el curso.';

  @override
  String get convTitle => 'Conversar';

  @override
  String get convSubtitle =>
      'Practica conversaciones reales. A tu ritmo, sin presión.';

  @override
  String get convLiveTitle => '🎙️  Conversación en vivo — próximamente';

  @override
  String get convLiveBody =>
      'Pronto podrás conversar con feedback en tiempo real. Lo lanzaremos con moderación y verificación de edad para que sea seguro. Mientras, practica abajo.';

  @override
  String get convPracticeKicker => 'PRÁCTICA EN SOLITARIO';

  @override
  String get convPracticeCta => 'Practicar';

  @override
  String get convYourSituation => 'TU SITUACIÓN';

  @override
  String get convPracticeHeader => 'Practica hablando o escribiendo';

  @override
  String get convPracticeSubtitle =>
      'Elige una situación, responde, y compárate con una respuesta modelo.';

  @override
  String get convInterestTitle => '¿Usarías la conversación en vivo?';

  @override
  String get convInterestYes => 'Sí, me encantaría';

  @override
  String get convInterestNo => 'No por ahora';

  @override
  String get convInterestHint => '¿Sobre qué temas? (opcional)';

  @override
  String get convSend => 'ENVIAR';

  @override
  String get convSending => 'ENVIANDO…';

  @override
  String get convInterestThanks =>
      '¡Gracias! Te avisaremos cuando la conversación en vivo esté lista.';

  @override
  String get convInterestFailed => 'No se pudo enviar. Inténtalo de nuevo.';

  @override
  String get convModeWrite => 'Escribir';

  @override
  String get convModeSpeak => 'Hablar';

  @override
  String get convHintWrite => 'Escribe tu respuesta…';

  @override
  String get convHintVoice => 'Tu transcripción aparecerá aquí (o edítala)';

  @override
  String get convSeeModel => 'VER RESPUESTA MODELO';

  @override
  String get convModelAnswer => 'Respuesta modelo';

  @override
  String get convKeyPhrases => 'Frases clave';

  @override
  String get convSelfEval => '¿Qué tan cerca estuviste del modelo?';

  @override
  String get convSaveFinish => 'GUARDAR Y TERMINAR';

  @override
  String get convSaving => 'GUARDANDO…';

  @override
  String get convSaved => '¡Guardado! Cada práctica suma. 🦜';

  @override
  String get convSaveFailed => 'No se pudo guardar. Inténtalo de nuevo.';

  @override
  String get convMicPreparing => 'Preparando micrófono…';

  @override
  String get convMicUnavailable =>
      'Tu navegador no permite el micrófono. Escribe tu respuesta 🙂';

  @override
  String get convListening => 'Escuchando…';

  @override
  String get convSpeakBtn => 'Hablar';

  @override
  String get convTopicCafeTitle => 'Pedir un café';

  @override
  String get convTopicCafeScenario =>
      'Estás en una cafetería. Pide un café y algo de comer, y pregunta el precio.';

  @override
  String get convTopicIntroTitle => 'Presentarte';

  @override
  String get convTopicIntroScenario =>
      'Conoces a alguien nuevo. Preséntate: nombre, de dónde eres y qué haces.';

  @override
  String get convTopicAirportTitle => 'En el aeropuerto';

  @override
  String get convTopicAirportScenario =>
      'Estás en el aeropuerto. Pregunta por tu puerta y la hora del vuelo.';

  @override
  String get convTopicWeekendTitle => 'Tu fin de semana';

  @override
  String get convTopicWeekendScenario =>
      'Cuenta qué hiciste el fin de semana pasado (pasado simple).';

  @override
  String get convTopicInterviewTitle => 'Una entrevista breve';

  @override
  String get convTopicInterviewScenario =>
      'Te preguntan por qué quieres el trabajo. Responde con 2 razones.';

  @override
  String get convTopicDirectionsTitle => 'Pedir indicaciones';

  @override
  String get convTopicDirectionsScenario =>
      'Pregunta cómo llegar a la estación de tren y si está lejos.';

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
  String onbFirstContactTitle(String course) {
    return '¿Es tu primer contacto con el $course?';
  }

  @override
  String get onbFirstContactSubtitle =>
      'Si empiezas de cero, te llevamos directo al inicio, sin examen.';

  @override
  String get onbFirstContactYes => 'Sí, empiezo desde cero';

  @override
  String get onbFirstContactNo => 'No, ya sé algo';

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
  String get placementSpeak => 'Hablar';

  @override
  String get placementListening => 'Escuchando…';

  @override
  String get placementSendAnswer => 'Enviar mi respuesta';

  @override
  String get placementSkipSpeaking => 'Saltar los ejercicios de hablar';

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
  String get authGoogleRetry =>
      'No se pudo continuar con Google. Vuelve a intentarlo.';

  @override
  String get authBetaGoogleOnly =>
      'En esta beta, el acceso es solo con Google. El registro por correo volverá en el lanzamiento.';

  @override
  String get authContinueLegalPrefix => 'Al continuar, aceptas los ';

  @override
  String get lessonSaveErrorTitle => 'No se pudo guardar tu progreso';

  @override
  String get lessonSaveErrorMsg => 'Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get lessonNoExercises => 'Esta lección aún no tiene ejercicios.';

  @override
  String get errNetwork =>
      'Sin conexión. Revisa tu internet e inténtalo de nuevo.';

  @override
  String get errAuth => 'Tu sesión expiró. Vuelve a iniciar sesión.';

  @override
  String get errDenied => 'No tienes acceso a esto.';

  @override
  String get errRateLimited =>
      'Vas muy rápido. Espera un momento e inténtalo de nuevo.';

  @override
  String get errConflict => 'Eso ya existe.';

  @override
  String get errNotFound => 'No se encontró.';

  @override
  String get errValidation => 'Revisa los datos e inténtalo de nuevo.';

  @override
  String get errServer => 'Algo salió mal de nuestro lado. Inténtalo de nuevo.';

  @override
  String get errUnknown => 'Ocurrió un error. Inténtalo de nuevo.';

  @override
  String get miplanTitle => 'Mi plan';

  @override
  String get miplanLoadError => 'No se pudo cargar tu plan.';

  @override
  String get miplanNoPlan => 'Aún no tienes un plan.';

  @override
  String get miplanProgressLabel => 'AVANCE DEL PLAN';

  @override
  String miplanPracticeDays(Object percent, Object met, Object total) {
    return '$percent% · $met/$total días de práctica';
  }

  @override
  String get miplanOnTrack => 'Justo en tu plan';

  @override
  String miplanAhead(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Vas $days días adelante 🎉',
      one: 'Vas 1 día adelante 🎉',
    );
    return '$_temp0';
  }

  @override
  String miplanBehind(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Vas $days días atrás',
      one: 'Vas 1 día atrás',
    );
    return '$_temp0';
  }

  @override
  String miplanMetDays(Object met, Object expected) {
    return 'Cumpliste $met de $expected días esperados a hoy.';
  }

  @override
  String get miplanProjectedArrival => 'Llegada proyectada';

  @override
  String get miplanEstimatedArrival => 'Llegada estimada';

  @override
  String miplanOriginalPlan(Object date) {
    return 'Plan original: $date';
  }

  @override
  String get miplanCurrentPace => 'Con tu ritmo actual';

  @override
  String get miplanEstimateHint =>
      'Practica unos días y ajustaremos la fecha a tu ritmo real.';

  @override
  String get miplanCalculating => 'Calculando…';

  @override
  String get miplanCalcHint =>
      'Completa tus primeras sesiones para estimar tu fecha.';

  @override
  String get miplanPerDay => 'al día';

  @override
  String get miplanPerWeek => 'por semana';

  @override
  String miplanDaysCount(Object days) {
    return '$days días';
  }

  @override
  String get miplanFasterCta => 'QUIERO LLEGAR MÁS RÁPIDO';

  @override
  String get miplanPaceSheetTitle => 'Sube tu ritmo diario';

  @override
  String get miplanPaceSheetSub =>
      'Más minutos al día = llegas antes. Recalculamos tu fecha.';

  @override
  String miplanPaceUpdated(Object min) {
    return '¡Listo! Ahora $min min/día. Fecha recalculada.';
  }

  @override
  String get miplanPaceError => 'No se pudo actualizar el ritmo.';

  @override
  String get nbTitle => 'Cuaderno de datos';

  @override
  String nbLearnedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count datos aprendidos',
      one: '$count dato aprendido',
    );
    return '$_temp0 🦜';
  }

  @override
  String get nbEmptyTitle => 'Tu cuaderno está vacío… por ahora';

  @override
  String get nbEmptyBody =>
      'Completa lecciones y Jezi te enseñará datos, trucos y errores comunes que se guardarán aquí.';

  @override
  String get matixTestGoalUnmet => 'Meta sin cumplir';

  @override
  String get matixTestStreakRisk => 'Racha en riesgo';

  @override
  String get matixTestAchievement => 'Logro desbloqueado';

  @override
  String get matixTestFireError => 'No se pudo disparar la notificación.';

  @override
  String get examStartError => 'No se pudo iniciar el examen.';

  @override
  String examLevelTitle(Object level) {
    return 'Examen de nivel $level';
  }

  @override
  String examCertifyLevel(Object level) {
    return 'Certifica tu nivel $level';
  }

  @override
  String get examIntroDescription =>
      'Un examen cronometrado que mezcla las 4 habilidades de todas las unidades. Apruébalo y recibes tu certificado con folio y código de verificación.';

  @override
  String get examBulletTime => '10 minutos · 20 preguntas';

  @override
  String get examBulletSkills => 'Lectura · Escucha · Escritura · Habla';

  @override
  String get examBulletPass => 'Necesitas 80% para aprobar';

  @override
  String examBulletCertificate(Object level) {
    return 'Al aprobar: certificado $level compartible';
  }

  @override
  String get examStart => 'EMPEZAR EXAMEN';

  @override
  String get examSubmitError =>
      'No se pudo enviar el examen. Intenta de nuevo.';

  @override
  String get examLeaveTitle => '¿Salir del examen?';

  @override
  String get examLeaveBody => 'Perderás el progreso de este intento.';

  @override
  String get examLeaveStay => 'Seguir';

  @override
  String get examLeaveConfirm => 'Salir';

  @override
  String get examNoItems => 'Examen sin ítems.';

  @override
  String get examFinish => 'TERMINAR';

  @override
  String get examNext => 'SIGUIENTE';

  @override
  String get notifTitle => 'Notificaciones';

  @override
  String get notifRefresh => 'Actualizar';

  @override
  String get notifTestJezi => 'Probar a Jezi';

  @override
  String get notifTestJeziHint =>
      'Simula un evento: Jezi elige el copy de tu estilo de coach y te lo manda.';

  @override
  String get notifReceived => 'Recibidas';

  @override
  String notifLoadError(Object error) {
    return 'No se pudieron cargar.\n$error';
  }

  @override
  String get notifEmpty => 'Sin notificaciones todavía';

  @override
  String get notifEmptyHint =>
      'Usa \"Probar a Jezi\" para ver cómo suena tu coach.';

  @override
  String get notifAgoNow => 'ahora';

  @override
  String notifAgoMinutes(Object minutes) {
    return 'hace $minutes min';
  }

  @override
  String notifAgoHours(Object hours) {
    return 'hace $hours h';
  }

  @override
  String notifAgoDays(Object days) {
    return 'hace $days d';
  }

  @override
  String get immTitle => 'Inmersión';

  @override
  String get immLoadError => 'No se pudieron cargar las historias. Reintenta.';

  @override
  String get immEmpty => 'Pronto habrá historias para tu curso. 📖';

  @override
  String get immSubtitle =>
      'Lee y escucha historias a tu nivel. Luego responde unas preguntas.';

  @override
  String immLevel(Object level) {
    return 'Nivel $level';
  }

  @override
  String get immStoryTitle => 'Historia';

  @override
  String get immStoryLoadError => 'No se pudo cargar la historia.';

  @override
  String get immSubmitError => 'No se pudo enviar. Reintenta.';

  @override
  String get immAnswerQuestions => 'Responder preguntas';

  @override
  String get immListen => 'Oír';

  @override
  String get immGlossary => 'Glosario';

  @override
  String immQuestionOf(Object current, Object total) {
    return 'Pregunta $current de $total';
  }

  @override
  String get immWriteWord => 'Escribe la palabra…';

  @override
  String get immNext => 'Siguiente';

  @override
  String get immSending => 'ENVIANDO…';

  @override
  String get immFinish => 'Terminar';

  @override
  String get immPerfect => '¡Comprensión perfecta!';

  @override
  String get immGoodReading => '¡Buena lectura!';

  @override
  String immScoreLine(Object pct, Object correct, Object total) {
    return '$pct% · $correct/$total correctas';
  }

  @override
  String get immDone => 'Listo';

  @override
  String immAnswerLabel(Object answer) {
    return 'Respuesta: $answer';
  }

  @override
  String get simTitle => 'Simulacros';

  @override
  String get simHeadline => 'Practica el examen real';

  @override
  String get simSubtitle =>
      'Simulacros con formato oficial y reporte de banda por sección.';

  @override
  String get simHowReadingDesc =>
      'Autocorregibles al 100% — puntaje inmediato.';

  @override
  String get simHowWritingDesc =>
      'Escribe y compara con una respuesta modelo + rúbrica.';

  @override
  String get simHowSpeakingDesc =>
      'Responde en voz alta con el modelo y una autoevaluación guiada.';

  @override
  String get simHowBandTitle => 'Reporte de banda';

  @override
  String get simHowBandDesc => 'Banda estimada por sección y global.';

  @override
  String get simAvailable => 'Disponibles';

  @override
  String get simIncludedPremium => 'Incluidos en Jezici Premium';

  @override
  String get simMockIeltsAcademic => '4 secciones · banda 0–9 · ~2 h 45 min';

  @override
  String get simMockIeltsGeneral => 'Migración y trabajo · banda 0–9';

  @override
  String get simMockCambridgeB2 => 'Nivel intermedio-alto · 4 destrezas';

  @override
  String get refTitle => 'Repaso';

  @override
  String get refNothingToReview => '¡Nada que reforzar ahora! Vas al día. 🎉';

  @override
  String get refStartError => 'No se pudo iniciar la práctica.';

  @override
  String get refLoadError => 'No se pudo cargar el repaso.';

  @override
  String get refEmptyConcepts => 'Aún no hay conceptos para este curso.';

  @override
  String get refIntro =>
      'Tus conceptos clave, por habilidad. Repasa y practica lo flojo.';

  @override
  String get refWeaknessTitle => 'Refuerzo de debilidades';

  @override
  String refSkillPracticeTitle(Object skill) {
    return 'Práctica de $skill';
  }

  @override
  String refWeakPoint(Object skill) {
    return 'Tu punto flojo: $skill';
  }

  @override
  String get refWeakSubtitle => 'Practica para subir tu dominio.';

  @override
  String get refPractice => 'Practicar';

  @override
  String refMasteryPct(Object pct) {
    return '$pct% dominio';
  }

  @override
  String get refSeen => 'visto';

  @override
  String get introKicker => 'APRENDE';

  @override
  String get introMascot => 'Antes de practicar, veamos lo nuevo.';

  @override
  String get introConceptChip => 'CONCEPTO';

  @override
  String get introVocabTitle => 'Palabras nuevas';

  @override
  String get introTapHint => 'Toca una palabra para oírla 🔊';

  @override
  String get introStart => 'EMPEZAR EJERCICIOS';

  @override
  String get introSkip => 'Saltar';

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
  String lessonCompleteSkillNext(String level) {
    return 'Sigue así para alcanzar $level y acercarte al certificado';
  }

  @override
  String get lessonCompleteSkillAdvanced => '▲ subió';

  @override
  String tipCardHeader(String type) {
    return 'Jezi te enseña · $type';
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
  String get speakingStop => 'Detener';

  @override
  String get speakingTapToHear => 'Toca para oírla';

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
      '¡Tranqui, le pasa a todos! Vuelven gratis en tu próxima lección, o sigue ahora 💪';

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
  String get noHeartsFreeNext => 'Vidas gratis en tu próxima lección';

  @override
  String get noHeartsFreeNextSub =>
      'Sin esperas: cada lección empieza con 5 ❤️';

  @override
  String get noHeartsWatchAd => 'Ver un anuncio';

  @override
  String get noHeartsWatchAdSub => 'Recupera 1 vida';

  @override
  String get noHeartsSoon => 'Pronto';

  @override
  String get noHeartsRefillAll => 'Recargar todas';

  @override
  String get noHeartsRefillAllSub => 'Rellena tus 5 vidas al instante';

  @override
  String get noHeartsUnlimited => 'Vidas ilimitadas';

  @override
  String get noHeartsUnlimitedSub => 'Nunca más esperes · con Premium';

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
  String get mapJumpToCurrent => 'Ir a mi lección';

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
  String get practiceWelcomeTitle => 'Aún no tienes palabras por repasar';

  @override
  String get practiceWelcomeBody =>
      'Completa tu primera lección y las palabras aparecerán aquí para que no se te olviden.';

  @override
  String get practiceGoToLesson => 'Ir a mi lección';

  @override
  String get practiceMeanwhileExplore => 'Mientras tanto, explora';

  @override
  String get practiceSrsTitle => 'Rescate de palabras';

  @override
  String get lessonNextCta => 'SIGUIENTE LECCIÓN';

  @override
  String get lessonBackToMap => 'Volver al mapa';

  @override
  String get blockedTitle => 'Usuarios bloqueados';

  @override
  String get blockedSubtitle =>
      'Ya no ven tu perfil ni pueden escribirte. Desbloquéalos cuando quieras.';

  @override
  String get blockedEmpty => 'No tienes usuarios bloqueados.';

  @override
  String get blockedUnblock => 'Desbloquear';

  @override
  String get blockedLoadError => 'No se pudo cargar la lista.';

  @override
  String get blockedUnblockError =>
      'No se pudo desbloquear. Inténtalo de nuevo.';

  @override
  String get settingsBlocked => 'Usuarios bloqueados';

  @override
  String get srsTitle => 'Repaso';

  @override
  String get srsNewWord => 'NUEVA';

  @override
  String get srsFillBlank => 'COMPLETA LA FRASE';

  @override
  String get srsHowDoYouSay => '¿CÓMO SE DICE?';

  @override
  String get srsTypeHint => 'Escribe tu respuesta';

  @override
  String get srsCheck => 'COMPROBAR';

  @override
  String get srsCorrect => '¡Correcto!';

  @override
  String get srsIncorrect => 'La respuesta era:';

  @override
  String get srsHowWasIt => '¿Qué tal te costó? Esto decide cuándo vuelve.';

  @override
  String get srsWillRepeat => 'La repetirás en esta misma sesión.';

  @override
  String get srsAgain => 'Otra vez';

  @override
  String get srsHard => 'Difícil';

  @override
  String get srsGood => 'Bien';

  @override
  String get srsEasy => 'Fácil';

  @override
  String get srsDoneTitle => '¡Repaso terminado!';

  @override
  String srsDoneSubtitle(int correct, int total) {
    return '$correct de $total a la primera.';
  }

  @override
  String get srsDoneCta => 'LISTO';

  @override
  String get srsSendError =>
      'No se pudo guardar el repaso. Inténtalo de nuevo.';

  @override
  String get srsNothingDue =>
      'Nada por repasar ahora. Vuelve más tarde o haz una lección.';

  @override
  String srsLeft(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n restantes',
      one: '1 restante',
    );
    return '$_temp0';
  }

  @override
  String get srsSaving => 'Guardando tu repaso…';

  @override
  String get srsAccuracy => 'Precisión';

  @override
  String get srsGoalMet => 'Meta del día cumplida';

  @override
  String get srsStreakUp => '¡Tu racha avanzó! 🔥';

  @override
  String get srsRetentionHint =>
      'De las palabras que ya maduraron, este % es lo que recuerdas cuando toca repasarlas.';

  @override
  String get srsRetention => 'Retención';

  @override
  String get srsRetentionEmpty => 'Aún sin datos';

  @override
  String get srsDueToday => 'Por repasar hoy';

  @override
  String get srsCardsTotal => 'En repaso';

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
  String profileMemberSince(String year) {
    return 'Miembro desde $year';
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

  @override
  String get micUnsupported =>
      'Tu navegador no soporta reconocimiento de voz. Prueba con Chrome o Edge.';

  @override
  String get micDenied =>
      'El permiso del micrófono está bloqueado. Actívalo en el candado 🔒 junto a la dirección (o en los ajustes del sitio) y reintenta.';

  @override
  String get micNoDevice =>
      'No se detectó ningún micrófono en este dispositivo.';

  @override
  String get micNetwork =>
      'El servicio de voz no respondió (revisa tu conexión). Vuelve a intentarlo.';

  @override
  String get micWebview =>
      'Este navegador dentro de otra app no permite el micrófono. Abre Jezici en Chrome o Safari para hablar.';

  @override
  String get audioPlayError => 'No se pudo reproducir · toca para reintentar';

  @override
  String ttsNoVoiceNotice(String lang) {
    return 'Tu dispositivo no tiene voz de $lang para leer las palabras al tocarlas. El audio de las lecciones sí funciona.';
  }

  @override
  String get metricsTitle => 'Métricas';

  @override
  String get metricsLoadError => 'No se pudieron cargar.';

  @override
  String get metricsSecUsers => 'Usuarios';

  @override
  String get metricsTotal => 'Total';

  @override
  String get metricsNew7d => 'Nuevos (7 días)';

  @override
  String get metricsSecActivity => 'Actividad';

  @override
  String get metricsStickiness => 'Stickiness (DAU/MAU)';

  @override
  String get metricsAvgStreak => 'Racha media';

  @override
  String get metricsLessonsPerActiveDay => 'Lecciones / día activo';

  @override
  String get metricsSecRetention => 'Retención';

  @override
  String get metricsSecLearning => 'Aprendizaje';

  @override
  String get metricsPassCheckpoint => '% aprueba checkpoint';

  @override
  String get metricsPassLevelExam => '% aprueba examen de nivel';

  @override
  String get metricsCertified => '% certifica';

  @override
  String get metricsSecBusiness => 'Negocio';

  @override
  String get metricsPremiumConversion => 'Conversión premium';

  @override
  String metricsGeneratedAt(String date) {
    return 'Generado: $date';
  }

  @override
  String get metricsOnbFunnel => 'Embudo de onboarding';

  @override
  String get metricsOnbSteps =>
      'Bienvenida|Idioma|Motivo|Meta|Compromiso|Personalidad|Arranque|Ubicación|Tu plan';

  @override
  String metricsCompletedOf(int completed, int started) {
    return 'Completaron $completed / $started';
  }

  @override
  String get metricsSectionUsage => 'Uso por sección (7 días)';

  @override
  String get metricsNoViews => 'Aún sin vistas registradas.';

  @override
  String get metricsLessonFunnel => 'Embudo de lección (30 días)';

  @override
  String get metricsLessonsStarted => 'Lecciones iniciadas';

  @override
  String get metricsLessonsCompleted => 'Completadas';

  @override
  String get metricsLessonsQuit => 'Abandonadas (salida)';

  @override
  String get metricsNoHeartsRow => 'Se quedaron sin vidas';

  @override
  String get metricsCompletionRate => 'Tasa de finalización';

  @override
  String get metricsFeedbackInterest => 'Feedback e interés';

  @override
  String get metricsNoFeedback => 'Aún sin feedback.';

  @override
  String get metricsLiveInterest => 'Interés conversación en vivo (sí/total)';

  @override
  String get metricsConvAttempts => 'Prácticas de conversación';

  @override
  String get metricsUserMessages => 'Mensajes de usuarios';

  @override
  String get metricsNoMessages => 'Aún sin mensajes.';

  @override
  String get metricsSentryTitle => 'Monitoreo de errores (Sentry)';

  @override
  String get metricsSentryOn => 'Activo (DSN configurado)';

  @override
  String get metricsSentryOff => 'Apagado (falta SENTRY_DSN)';

  @override
  String get metricsSentryHintOn =>
      'Envía un evento de prueba y búscalo en el dashboard de Sentry.';

  @override
  String get metricsSentryHintOff =>
      'Añade --dart-define=SENTRY_DSN=… al Build Command de Vercel para activarlo.';

  @override
  String get metricsSentrySend => 'Enviar evento de prueba';

  @override
  String metricsSentrySent(String id) {
    return 'Enviado a Sentry ✓  ($id)';
  }

  @override
  String get metricsSentryNotSent => 'No se envió (Sentry apagado o error).';

  @override
  String get onbAdultConfirm => 'Confirmo que soy mayor de edad';

  @override
  String get completeProfileTitle => 'Completa tu perfil';

  @override
  String get completeProfileSubtitle =>
      'Solo falta tu nombre y confirmar que eres mayor de edad. Lo demás es opcional y lo puedes editar en tu Perfil.';

  @override
  String get ageGateTitle => 'Un último paso';

  @override
  String get ageGateSubtitle =>
      'Para personalizar tu experiencia, dinos tu año de nacimiento. Queda privado.';

  @override
  String get ageGateYearHint => 'Año de nacimiento';

  @override
  String get convFriendsTitle => 'Amigos';

  @override
  String get convFriendsSubtitle => 'Practica con amigos por chat';

  @override
  String get convYourCode => 'Tu código';

  @override
  String get convAddFriend => 'Agregar';

  @override
  String get convEnterCode => 'Código de tu amigo';

  @override
  String get convRequestSent => 'Solicitud enviada';

  @override
  String get convCodeError => 'No se pudo agregar. Revisa el código.';

  @override
  String get convErrAlready => 'Ya son amigos.';

  @override
  String get convErrSelf => 'Ese es tu propio código 🙂';

  @override
  String get convErrRate => 'Enviaste muchas solicitudes hoy. Intenta mañana.';

  @override
  String get convErrUnavailable =>
      'No disponible. La cuenta debe poder usar lo social (mayor de edad).';

  @override
  String get convErrBlocked => 'No disponible.';

  @override
  String get convAddError => 'No se pudo enviar la solicitud.';

  @override
  String get convNowFriends => '¡Ya son amigos! 🎉';

  @override
  String get convCodeCopied => 'Código copiado';

  @override
  String get convContactFilterNote =>
      'Por tu seguridad, no compartas teléfonos ni enlaces.';

  @override
  String get convRequests => 'Solicitudes';

  @override
  String get convAccept => 'Aceptar';

  @override
  String get convReject => 'Rechazar';

  @override
  String get presenceOnline => 'En línea';

  @override
  String get presenceOffline => 'Desconectado';

  @override
  String presenceActiveMin(int n) {
    return 'Activo hace $n min';
  }

  @override
  String presenceActiveHours(int n) {
    return 'Activo hace $n h';
  }

  @override
  String presenceActiveDays(int n) {
    return 'Activo hace $n d';
  }

  @override
  String get convRequested => 'Enviada';

  @override
  String get convOnlineNow => 'En línea ahora';

  @override
  String get convShowPresence => 'Mostrar cuando estoy en línea';

  @override
  String get convShowPresenceSub => 'Tus amigos ven tu estado \"en línea\"';

  @override
  String get convNoFriends =>
      'Aún no tienes amigos. Búscalos por su @usuario para agregarlos.';

  @override
  String get convChatHint => 'Escribe un mensaje';

  @override
  String get convChatEmpty => 'Saluda 👋';

  @override
  String get convSendError => 'No se pudo enviar';

  @override
  String get convReport => 'Reportar';

  @override
  String get convBlock => 'Bloquear';

  @override
  String get convReported => 'Reportado. Gracias.';

  @override
  String get convCorrect => 'Corregir';

  @override
  String get convSendCorrection => 'Enviar corrección';

  @override
  String get convVoiceRecording => 'Grabando';

  @override
  String get convTapToChat => 'Toca para chatear';

  @override
  String get convCopyMyCode => 'Copiar mi código';

  @override
  String get convCorrectionLabel => 'Corrección';

  @override
  String get convCoopYou => 'Tú';

  @override
  String get convVoiceSend => 'Grabar nota de voz';

  @override
  String get convVoiceStop => 'Enviar';

  @override
  String get convVoiceCancel => 'Cancelar';

  @override
  String get convVoiceNote => 'Nota de voz';

  @override
  String get convVoiceMicDenied =>
      'Activa el micrófono para grabar notas de voz.';

  @override
  String get convVoiceMicUnsupported =>
      'Tu navegador no permite grabar audio. Usa Chrome o Edge.';

  @override
  String get convVoiceSendError => 'No se pudo enviar la nota de voz.';

  @override
  String get convVoicePlayError => 'No se pudo reproducir la nota.';

  @override
  String get convCoopTitle => 'Reto en pareja';

  @override
  String get convCoopSubtitle => 'Sumen XP juntos y ganen oro los dos.';

  @override
  String get convCoopStart => 'Crear reto';

  @override
  String get convCoopCreate => 'Invitar a un reto';

  @override
  String get convCoopInvitePending => 'Invitación enviada';

  @override
  String get convCoopInviteReceived => 'Te invitó a un reto';

  @override
  String get convCoopAccept => 'Aceptar reto';

  @override
  String get convCoopReject => 'Rechazar';

  @override
  String get convCoopActive => 'Reto activo';

  @override
  String get convCoopCompleted => '¡Reto completado!';

  @override
  String get convCoopExpired => 'Reto expirado';

  @override
  String convCoopProgress(int done, int target) {
    return '$done / $target XP';
  }

  @override
  String convCoopReward(int gold) {
    return '+$gold oro para ambos al completar';
  }

  @override
  String get convCoopPickGoal => 'Meta de XP en equipo';

  @override
  String get convCoopEmpty => 'Aún no hay retos. Elige un amigo y creen uno.';

  @override
  String get convCoopWith => '¿Con quién quieres el reto?';

  @override
  String get convCoopNoFriends => 'Agrega un amigo primero para crear un reto.';

  @override
  String get convCoopError => 'No se pudo crear el reto.';

  @override
  String get convCoopEntry => 'Retos en pareja';

  @override
  String get convCoopEntrySub => 'Sumen XP y ganen oro juntos';

  @override
  String get handleGatePendingHint =>
      'Tienes solicitudes de amistad esperando. Elige tu @usuario para verlas y aceptarlas.';

  @override
  String get handleGateTitle => 'Elige tu @usuario';

  @override
  String get handleGateSubtitle =>
      'Así te encuentran tus amigos. Tu nombre visible sigue siendo libre.';

  @override
  String get handleSetupSubtitle =>
      'Es tu identidad en Jezici: única y para siempre. Elígela para empezar.';

  @override
  String get handleGateHint => 'tu_usuario';

  @override
  String get handleGateRules => '3 a 20 letras, números o guion bajo (_).';

  @override
  String get handleGateSave => 'Confirmar @usuario';

  @override
  String get handleGateTaken => 'Ese @usuario ya está tomado. Prueba con otro.';

  @override
  String get handleGateInvalid => 'Usa 3 a 20 letras, números o guion bajo.';

  @override
  String get handleGateReserved => 'Ese @usuario está reservado.';

  @override
  String get handleGateRateLimit =>
      'Solo puedes cambiar tu @usuario cada 30 días.';

  @override
  String get handleGateError => 'No se pudo guardar. Intenta de nuevo.';

  @override
  String get convSearchTitle => 'Buscar amigos';

  @override
  String get convSearchHint => 'Nombre o @usuario';

  @override
  String convSearchNoResults(String q) {
    return 'Sin resultados para «$q»';
  }

  @override
  String get convSuggestionsTitle => 'Sugerencias para ti';

  @override
  String get convSuggestionsSub => 'Aprenden tu mismo idioma';

  @override
  String get convViewProfile => 'Ver perfil';

  @override
  String get convPendingSent => 'Pendiente';

  @override
  String get convDiscoverable => 'Aparecer en búsqueda';

  @override
  String get convDiscoverableSub =>
      'Otros pueden encontrarte por nombre o @usuario';

  @override
  String get profilePublicTitle => 'Perfil';

  @override
  String get profileAddFriend => 'Agregar amigo';

  @override
  String get profileRequestSent => 'Solicitud enviada';

  @override
  String get profileAcceptRequest => 'Aceptar solicitud';

  @override
  String get profileFriends => 'Ya son amigos';

  @override
  String get profileChat => 'Chatear';

  @override
  String get profileBadges => 'Logros';

  @override
  String get profileLanguages => 'Idiomas';

  @override
  String get profileNotFound => 'No se encontró este perfil.';

  @override
  String profileStreakDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días de racha',
      one: '1 día de racha',
      zero: 'Sin racha',
    );
    return '$_temp0';
  }

  @override
  String get convHandleChip => 'Tu @usuario';

  @override
  String get convAddByCode => 'o agrega por código';

  @override
  String get profileEditBirthday => 'Cumpleaños (día y mes)';

  @override
  String get profileEditDay => 'Día';

  @override
  String get profileEditMonth => 'Mes';

  @override
  String get profileEditGender => 'Género';

  @override
  String get genderFemale => 'Femenino';

  @override
  String get genderMale => 'Masculino';

  @override
  String get genderOther => 'Otro';

  @override
  String get genderPreferNot => 'Prefiero no decirlo';

  @override
  String get convKicker => 'COMUNIDAD JEZICI';

  @override
  String convSpeakingPill(String level) {
    return 'Tu Speaking: $level — súbelo hablando aquí';
  }

  @override
  String get checkpointWhatsIn => 'QUÉ ENTRA';

  @override
  String get certScreenTitle => 'Tu certificado';

  @override
  String certTitleOf(String language) {
    return 'Certificado de $language';
  }

  @override
  String get certLevelReached => 'por alcanzar el nivel';

  @override
  String get certMcer => 'Marco Común Europeo (MCER)';

  @override
  String get certRowFolio => 'Folio';

  @override
  String get certRowVerification => 'Código de verificación';

  @override
  String get certRowIssued => 'Emitido el';

  @override
  String get certShare => 'COPIAR DATOS';

  @override
  String get certShareCopied => 'Certificado copiado para compartir ✓';

  @override
  String get certVerifyNote => 'Guarda tu folio y código de verificación.';

  @override
  String get certSealVerified => 'VERIFICADO';

  @override
  String get matixNow => 'ahora';

  @override
  String get coachTagFirm => 'Firme';

  @override
  String get coachTagUpbeat => 'Animado';

  @override
  String get coachTagCompetitive => 'Competitivo';

  @override
  String get coachTagCalm => 'Tranquilo';

  @override
  String premiumHeroTitle(String language) {
    return 'Lleva tu $language más lejos';
  }

  @override
  String get premiumHeroSubtitle =>
      'Todo lo del plan gratis, y más para certificarte antes.';

  @override
  String get premiumFeatMocksTitle => 'Simulacros IELTS y Cambridge';

  @override
  String get premiumFeatMocksDesc => 'Exámenes de práctica con formato real';

  @override
  String get premiumFeatHeartsTitle => 'Vidas infinitas';

  @override
  String get premiumFeatHeartsDesc => 'Practica sin quedarte sin corazones';

  @override
  String get premiumFeatRetriesTitle => 'Reintentos ilimitados';

  @override
  String get premiumFeatRetriesDesc =>
      'Repite checkpoints y exámenes sin límite';

  @override
  String get premiumFeatNoAdsTitle => 'Sin anuncios';

  @override
  String get premiumFeatNoAdsDesc => 'Aprende sin interrupciones';

  @override
  String get premiumFeatReportsTitle => 'Informes avanzados';

  @override
  String get premiumFeatReportsDesc => 'Análisis profundo de tus 4 habilidades';

  @override
  String get premiumCtaSoon => 'HAZTE PREMIUM · PRÓXIMAMENTE';

  @override
  String get premiumCtaSnack =>
      'Los pagos llegan pronto. ¡Gracias por tu interés! 💜';

  @override
  String get premiumFreeNote =>
      'Estás en el plan Gratis. Todo el contenido A1 es gratuito.';

  @override
  String noHeartsRegenIn(String time) {
    return 'Próxima vida gratis en $time';
  }

  @override
  String get noHeartsRegenGeneric => 'Tus vidas se regeneran solas';

  @override
  String get noHeartsRegenSub => '1 vida cada 30 min, hasta 5 ❤️';

  @override
  String heartsPanelNextIn(String time) {
    return 'Próxima vida en $time · 1 cada 30 min';
  }

  @override
  String streakReviveTitle(int days) {
    return 'Revive tu racha de $days días';
  }

  @override
  String get streakReviveSubtitle =>
      'Rescate excepcional: recupera la racha que acabas de perder.';

  @override
  String get streakReviveCta => 'Revivir racha';

  @override
  String get streakReviveLimit =>
      'Solo 1 rescate cada 30 días, y dentro de los 7 días de perderla.';

  @override
  String streakRevived(int days) {
    return '🔥 ¡Racha revivida! Vas por $days días.';
  }

  @override
  String get streakReviveUnavailable => 'El rescate no está disponible ahora.';

  @override
  String get pushOptInTitle => 'Activa los avisos de Jezi';

  @override
  String get pushOptInBody =>
      'Recibe un empujón cuando tu racha esté en riesgo — incluso con la app cerrada. Tú decides.';

  @override
  String get pushOptInCta => 'Activar notificaciones';

  @override
  String get pushEnabledTitle => 'Notificaciones activadas';

  @override
  String get pushEnabledBody =>
      'Jezi te avisará por tu racha y tu meta. Puedes silenciarlo en Ajustes.';

  @override
  String get pushDeniedTitle => 'Notificaciones bloqueadas';

  @override
  String get pushDeniedBody =>
      'Las bloqueaste en el navegador. Actívalas en el candado 🔒 junto a la dirección.';

  @override
  String get pushIosInstallTitle => 'En iPhone, primero instala la app';

  @override
  String get pushIosInstallBody =>
      'iOS solo permite avisos si Jezici está en tu pantalla de inicio (iOS 16.4+). Instálala abajo y vuelve aquí.';

  @override
  String get installTitle => 'Instalar Jezici';

  @override
  String get installBody =>
      'Ábrela como app, a pantalla completa y con avisos.';

  @override
  String get installTile => 'Instalar la app';

  @override
  String get installValueTitle => 'Lleva Jezici a tu inicio';

  @override
  String get installValueBody =>
      'Ábrela como app, a pantalla completa y con un toque desde tu pantalla de inicio.';

  @override
  String get installValueCta => 'Instalar';

  @override
  String get installIosTitle => 'Añade Jezici a tu iPhone';

  @override
  String get installIosStep1 => 'Toca Compartir en la barra de Safari';

  @override
  String get installIosStep2 => 'Elige “Añadir a pantalla de inicio”';

  @override
  String get installIosStep3 => 'Abre Jezici desde tu pantalla de inicio';

  @override
  String get profileEditGenderError => 'Elige tu género para guardar.';

  @override
  String get profileEditBirthdayError =>
      'Elige el día y el mes de tu cumpleaños.';

  @override
  String get profileEditCountryHint => 'Elige tu país';

  @override
  String get profileEditCountrySearchHint => 'Buscar país…';

  @override
  String get settingsMyLanguages => 'Mis idiomas';

  @override
  String get settingsAddLanguage => 'Añadir idioma de aprendizaje';

  @override
  String get addLanguageSubtitle => 'Empieza un idioma nuevo';

  @override
  String get addLanguageAllStarted =>
      'Ya estás aprendiendo todos los idiomas disponibles.';

  @override
  String get donateTitle => 'Aporta un grano de arena';

  @override
  String get donateSubtitle =>
      'Jezici es gratis. Si te sirve, tu apoyo ayuda a que siga creciendo.';

  @override
  String get donateScanQr => 'Escanea el QR o usa el número';

  @override
  String get donateCopied => 'Número copiado';

  @override
  String get donatePlinSameNumber => 'mismo número que Yape';

  @override
  String get donateStripe => 'Tarjeta (Stripe)';

  @override
  String donatePayWith(String method) {
    return 'Donar con $method';
  }

  @override
  String get donateSoon => 'Pronto';

  @override
  String get donateVoluntaryNote =>
      'Es un apoyo voluntario. No es una compra y no desbloquea nada dentro de la app. ¡Gracias! 🦜';

  @override
  String lessonReviewCta(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Repasar $count palabras',
      one: 'Repasar 1 palabra',
    );
    return '$_temp0';
  }

  @override
  String get lessonWhatNext => '¿Qué quieres hacer ahora?';

  @override
  String get tipCardSeeGuide => 'Ver más conceptos en tu guía';

  @override
  String get practiceSrsAllDone => 'Repaso al día';

  @override
  String get introLoading => 'Preparando tu lección…';
}
