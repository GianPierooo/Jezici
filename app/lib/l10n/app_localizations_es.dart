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
}
