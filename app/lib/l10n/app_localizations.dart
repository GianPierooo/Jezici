import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// Nombre de la app (marca; normalmente no se traduce)
  ///
  /// In es, this message translates to:
  /// **'Jezici'**
  String get appTitle;

  /// No description provided for @commonContinue.
  ///
  /// In es, this message translates to:
  /// **'CONTINUAR'**
  String get commonContinue;

  /// No description provided for @commonStart.
  ///
  /// In es, this message translates to:
  /// **'EMPEZAR'**
  String get commonStart;

  /// No description provided for @commonCheck.
  ///
  /// In es, this message translates to:
  /// **'COMPROBAR'**
  String get commonCheck;

  /// No description provided for @commonSkip.
  ///
  /// In es, this message translates to:
  /// **'Saltar'**
  String get commonSkip;

  /// No description provided for @commonBack.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get commonBack;

  /// No description provided for @commonExit.
  ///
  /// In es, this message translates to:
  /// **'Salir'**
  String get commonExit;

  /// No description provided for @commonClose.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get commonClose;

  /// No description provided for @commonCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get commonCancel;

  /// No description provided for @commonRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get commonRetry;

  /// No description provided for @commonNext.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get commonNext;

  /// No description provided for @commonDone.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get commonDone;

  /// No description provided for @splashLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar tu sesión.'**
  String get splashLoadError;

  /// Selector del idioma de la interfaz (no del curso)
  ///
  /// In es, this message translates to:
  /// **'Idioma de la app'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In es, this message translates to:
  /// **'El idioma de los menús y las instrucciones. No cambia el idioma que estás aprendiendo.'**
  String get settingsLanguageSubtitle;

  /// No description provided for @langEs.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get langEs;

  /// No description provided for @langEn.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get langEn;

  /// No description provided for @langPt.
  ///
  /// In es, this message translates to:
  /// **'Português'**
  String get langPt;

  /// No description provided for @skillReading.
  ///
  /// In es, this message translates to:
  /// **'Lectura'**
  String get skillReading;

  /// No description provided for @skillWriting.
  ///
  /// In es, this message translates to:
  /// **'Escritura'**
  String get skillWriting;

  /// No description provided for @skillListening.
  ///
  /// In es, this message translates to:
  /// **'Comprensión auditiva'**
  String get skillListening;

  /// No description provided for @skillSpeaking.
  ///
  /// In es, this message translates to:
  /// **'Expresión oral'**
  String get skillSpeaking;

  /// No description provided for @onbWelcomeTitle.
  ///
  /// In es, this message translates to:
  /// **'Construyamos tu plan'**
  String get onbWelcomeTitle;

  /// No description provided for @onbWelcomeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Unas preguntas rápidas y un test de nivel para armar tu plan con fecha real. Cada respuesta personaliza tu camino.'**
  String get onbWelcomeSubtitle;

  /// No description provided for @onbWelcomeNote.
  ///
  /// In es, this message translates to:
  /// **'Toma ~2 minutos.'**
  String get onbWelcomeNote;

  /// No description provided for @onbLanguageTitle.
  ///
  /// In es, this message translates to:
  /// **'¿En qué idioma prefieres la app?'**
  String get onbLanguageTitle;

  /// No description provided for @onbLanguageSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elige el idioma de los menús y mensajes. No es el idioma que vas a aprender.'**
  String get onbLanguageSubtitle;

  /// No description provided for @onbLanguageInfoEn.
  ///
  /// In es, this message translates to:
  /// **'Vas a aprender inglés 🇬🇧. Esto solo cambia el idioma de la app.'**
  String get onbLanguageInfoEn;

  /// No description provided for @onbLanguageInfoPt.
  ///
  /// In es, this message translates to:
  /// **'Vas a aprender portugués 🇧🇷. Esto solo cambia el idioma de la app.'**
  String get onbLanguageInfoPt;

  /// No description provided for @onbMotiveTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Por qué aprendes inglés?'**
  String get onbMotiveTitle;

  /// No description provided for @onbMotiveSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Personaliza tu plan, los escenarios y los mensajes de tu coach.'**
  String get onbMotiveSubtitle;

  /// No description provided for @onbMotiveWork.
  ///
  /// In es, this message translates to:
  /// **'Trabajo'**
  String get onbMotiveWork;

  /// No description provided for @onbMotiveTravel.
  ///
  /// In es, this message translates to:
  /// **'Viajes'**
  String get onbMotiveTravel;

  /// No description provided for @onbMotiveExam.
  ///
  /// In es, this message translates to:
  /// **'Examen oficial'**
  String get onbMotiveExam;

  /// No description provided for @onbMotiveStudies.
  ///
  /// In es, this message translates to:
  /// **'Estudios'**
  String get onbMotiveStudies;

  /// No description provided for @onbMotiveRelocation.
  ///
  /// In es, this message translates to:
  /// **'Mudanza'**
  String get onbMotiveRelocation;

  /// No description provided for @onbMotivePleasure.
  ///
  /// In es, this message translates to:
  /// **'Por placer'**
  String get onbMotivePleasure;

  /// No description provided for @onbGoalTitle.
  ///
  /// In es, this message translates to:
  /// **'¿A dónde quieres llegar?'**
  String get onbGoalTitle;

  /// No description provided for @onbGoalSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tu meta. La cima del mapa.'**
  String get onbGoalSubtitle;

  /// No description provided for @onbGoalA2.
  ///
  /// In es, this message translates to:
  /// **'A2 · Me defiendo'**
  String get onbGoalA2;

  /// No description provided for @onbGoalB1.
  ///
  /// In es, this message translates to:
  /// **'B1 · Independiente'**
  String get onbGoalB1;

  /// No description provided for @onbGoalB2.
  ///
  /// In es, this message translates to:
  /// **'B2 · Conversador fluido'**
  String get onbGoalB2;

  /// No description provided for @onbGoalC1.
  ///
  /// In es, this message translates to:
  /// **'C1 · Avanzado'**
  String get onbGoalC1;

  /// No description provided for @onbDeadlineEmpty.
  ///
  /// In es, this message translates to:
  /// **'Fecha límite (opcional)'**
  String get onbDeadlineEmpty;

  /// No description provided for @onbDeadlineFilled.
  ///
  /// In es, this message translates to:
  /// **'Meta: {day}/{month}/{year}'**
  String onbDeadlineFilled(int day, int month, int year);

  /// No description provided for @onbCommitmentTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cuánto puedes dedicar?'**
  String get onbCommitmentTitle;

  /// No description provided for @onbCommitmentSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Esto fija tu meta diaria y la fecha de llegada.'**
  String get onbCommitmentSubtitle;

  /// No description provided for @onbCommitmentMinutesLabel.
  ///
  /// In es, this message translates to:
  /// **'Minutos al día'**
  String get onbCommitmentMinutesLabel;

  /// No description provided for @onbCommitmentDaysLabel.
  ///
  /// In es, this message translates to:
  /// **'Días por semana'**
  String get onbCommitmentDaysLabel;

  /// No description provided for @onbFrequencyRelaxed.
  ///
  /// In es, this message translates to:
  /// **'Relajado'**
  String get onbFrequencyRelaxed;

  /// No description provided for @onbFrequencyConstant.
  ///
  /// In es, this message translates to:
  /// **'Constante'**
  String get onbFrequencyConstant;

  /// No description provided for @onbFrequencyIntense.
  ///
  /// In es, this message translates to:
  /// **'Intenso'**
  String get onbFrequencyIntense;

  /// No description provided for @onbStartLevelTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cuánto inglés sabes ya?'**
  String get onbStartLevelTitle;

  /// No description provided for @onbStartLevelSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Para empezar el test de nivel en el punto justo.'**
  String get onbStartLevelSubtitle;

  /// No description provided for @onbStartLevelZero.
  ///
  /// In es, this message translates to:
  /// **'Desde cero'**
  String get onbStartLevelZero;

  /// No description provided for @onbStartLevelBasic.
  ///
  /// In es, this message translates to:
  /// **'Sé lo básico'**
  String get onbStartLevelBasic;

  /// No description provided for @onbStartLevelGood.
  ///
  /// In es, this message translates to:
  /// **'Tengo buen nivel'**
  String get onbStartLevelGood;

  /// No description provided for @onbMinutesShort.
  ///
  /// In es, this message translates to:
  /// **'{m} min'**
  String onbMinutesShort(int m);

  /// No description provided for @onbDaysShort.
  ///
  /// In es, this message translates to:
  /// **'{days, plural, =1{{days} día} other{{days} días}}'**
  String onbDaysShort(int days);

  /// No description provided for @planDurationLessThanWeek.
  ///
  /// In es, this message translates to:
  /// **'menos de 1 semana'**
  String get planDurationLessThanWeek;

  /// No description provided for @planDurationWeeks.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{≈ 1 semana} other{≈ {count} semanas}}'**
  String planDurationWeeks(int count);

  /// No description provided for @planDurationMonths.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, other{≈ {count} meses}}'**
  String planDurationMonths(int count);

  /// No description provided for @planDurationYears.
  ///
  /// In es, this message translates to:
  /// **'≈ {years} años'**
  String planDurationYears(String years);

  /// No description provided for @onbSaveError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar tu plan. Reinténtalo.'**
  String get onbSaveError;

  /// No description provided for @onbPersonalityTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu coach ideal'**
  String get onbPersonalityTitle;

  /// No description provided for @onbPersonalityStep.
  ///
  /// In es, this message translates to:
  /// **'Pregunta {q} de {total}'**
  String onbPersonalityStep(int q, int total);

  /// No description provided for @onbPersonalityQ1.
  ///
  /// In es, this message translates to:
  /// **'Si fallas tu meta del día, ¿qué prefieres oír?'**
  String get onbPersonalityQ1;

  /// No description provided for @onbPersonalityQ1Opt1.
  ///
  /// In es, this message translates to:
  /// **'\"Sin excusas. Retómalo ya.\"'**
  String get onbPersonalityQ1Opt1;

  /// No description provided for @onbPersonalityQ1Opt2.
  ///
  /// In es, this message translates to:
  /// **'\"¡Mañana lo das todo, tú puedes! 💪\"'**
  String get onbPersonalityQ1Opt2;

  /// No description provided for @onbPersonalityQ1Opt3.
  ///
  /// In es, this message translates to:
  /// **'\"Vas quedando atrás de tu plan, recupéralo.\"'**
  String get onbPersonalityQ1Opt3;

  /// No description provided for @onbPersonalityQ1Opt4.
  ///
  /// In es, this message translates to:
  /// **'\"Tranqui, cuando puedas seguimos 🙂\"'**
  String get onbPersonalityQ1Opt4;

  /// No description provided for @onbPersonalityQ2.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo te gusta que te motivemos a practicar?'**
  String get onbPersonalityQ2;

  /// No description provided for @onbPersonalityQ2Opt1.
  ///
  /// In es, this message translates to:
  /// **'Firme y directo'**
  String get onbPersonalityQ2Opt1;

  /// No description provided for @onbPersonalityQ2Opt2.
  ///
  /// In es, this message translates to:
  /// **'Con energía y celebración'**
  String get onbPersonalityQ2Opt2;

  /// No description provided for @onbPersonalityQ2Opt3.
  ///
  /// In es, this message translates to:
  /// **'Recordándome mis metas y mi avance'**
  String get onbPersonalityQ2Opt3;

  /// No description provided for @onbPersonalityQ2Opt4.
  ///
  /// In es, this message translates to:
  /// **'Suave, sin presión'**
  String get onbPersonalityQ2Opt4;

  /// No description provided for @onbPersonalityQ3.
  ///
  /// In es, this message translates to:
  /// **'En la liga alguien te supera. ¿Qué te activa?'**
  String get onbPersonalityQ3;

  /// No description provided for @onbPersonalityQ3Opt1.
  ///
  /// In es, this message translates to:
  /// **'Que me reten a recuperarme'**
  String get onbPersonalityQ3Opt1;

  /// No description provided for @onbPersonalityQ3Opt2.
  ///
  /// In es, this message translates to:
  /// **'Ánimo para subir posiciones'**
  String get onbPersonalityQ3Opt2;

  /// No description provided for @onbPersonalityQ3Opt3.
  ///
  /// In es, this message translates to:
  /// **'Ver cuánto me falta para alcanzarlo'**
  String get onbPersonalityQ3Opt3;

  /// No description provided for @onbPersonalityQ3Opt4.
  ///
  /// In es, this message translates to:
  /// **'Nada, voy a mi ritmo'**
  String get onbPersonalityQ3Opt4;

  /// No description provided for @onbPersonalityQ4.
  ///
  /// In es, this message translates to:
  /// **'Cuando logras algo, ¿qué mensaje disfrutas más?'**
  String get onbPersonalityQ4;

  /// No description provided for @onbPersonalityQ4Opt1.
  ///
  /// In es, this message translates to:
  /// **'\"Bien. Ahora el siguiente reto.\"'**
  String get onbPersonalityQ4Opt1;

  /// No description provided for @onbPersonalityQ4Opt2.
  ///
  /// In es, this message translates to:
  /// **'\"¡Increíble, eres imparable! 🎉\"'**
  String get onbPersonalityQ4Opt2;

  /// No description provided for @onbPersonalityQ4Opt3.
  ///
  /// In es, this message translates to:
  /// **'\"Vas adelantado a tu plan.\"'**
  String get onbPersonalityQ4Opt3;

  /// No description provided for @onbPersonalityQ4Opt4.
  ///
  /// In es, this message translates to:
  /// **'\"Qué bien, sigue a tu ritmo 🙂\"'**
  String get onbPersonalityQ4Opt4;

  /// No description provided for @onbIntensityQ.
  ///
  /// In es, this message translates to:
  /// **'¿Qué tan seguido quieres que te recordemos?'**
  String get onbIntensityQ;

  /// No description provided for @onbIntensityOpt1.
  ///
  /// In es, this message translates to:
  /// **'Mucho, no me dejes aflojar'**
  String get onbIntensityOpt1;

  /// No description provided for @onbIntensityOpt2.
  ///
  /// In es, this message translates to:
  /// **'Lo justo'**
  String get onbIntensityOpt2;

  /// No description provided for @onbIntensityOpt3.
  ///
  /// In es, this message translates to:
  /// **'Poco'**
  String get onbIntensityOpt3;

  /// No description provided for @placementTitle.
  ///
  /// In es, this message translates to:
  /// **'Test de ubicación'**
  String get placementTitle;

  /// No description provided for @placementSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Sin pistas · pregunta {asked} de {max}'**
  String placementSubtitle(int asked, int max);

  /// No description provided for @placementResultTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu nivel: {level}'**
  String placementResultTitle(String level);

  /// No description provided for @placementResultSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Esto no es un examen que se aprueba o se reprueba: es tu punto de partida.'**
  String get placementResultSubtitle;

  /// No description provided for @placementResultViewPlan.
  ///
  /// In es, this message translates to:
  /// **'VER MI PLAN'**
  String get placementResultViewPlan;

  /// No description provided for @placementResultHero.
  ///
  /// In es, this message translates to:
  /// **'TE UBICAMOS EN'**
  String get placementResultHero;

  /// No description provided for @placementResultSkillsTitle.
  ///
  /// In es, this message translates to:
  /// **'Por habilidad'**
  String get placementResultSkillsTitle;

  /// No description provided for @placementResultEntryUnit.
  ///
  /// In es, this message translates to:
  /// **'Empezarás en la Unidad {unitNum} — {unitName} ({level}). Lo anterior queda accesible para repasar.'**
  String placementResultEntryUnit(int unitNum, String unitName, String level);

  /// No description provided for @placementResultEstimateReached.
  ///
  /// In es, this message translates to:
  /// **'Ya alcanzas tu meta. Si sigues hasta {goalLevel}: {humanDuration} (aprox. {formattedDate}).'**
  String placementResultEstimateReached(
    String goalLevel,
    String humanDuration,
    String formattedDate,
  );

  /// No description provided for @placementResultEstimateGoal.
  ///
  /// In es, this message translates to:
  /// **'Si cumples tu plan, llegas a {goalLevel} en {humanDuration} (aprox. {formattedDate}).'**
  String placementResultEstimateGoal(
    String goalLevel,
    String humanDuration,
    String formattedDate,
  );

  /// No description provided for @planFocusWork.
  ///
  /// In es, this message translates to:
  /// **'Enfoque laboral: reuniones, correos y entrevistas.'**
  String get planFocusWork;

  /// No description provided for @planFocusTravel.
  ///
  /// In es, this message translates to:
  /// **'Enfoque viajes: aeropuerto, hotel, direcciones y restaurantes.'**
  String get planFocusTravel;

  /// No description provided for @planFocusExam.
  ///
  /// In es, this message translates to:
  /// **'Enfoque examen: simulacros IELTS/Cambridge y las 4 habilidades.'**
  String get planFocusExam;

  /// No description provided for @planFocusStudies.
  ///
  /// In es, this message translates to:
  /// **'Enfoque estudios: comprensión, escritura y vocabulario académico.'**
  String get planFocusStudies;

  /// No description provided for @planFocusRelocation.
  ///
  /// In es, this message translates to:
  /// **'Enfoque mudanza: trámites, vivienda y vida diaria.'**
  String get planFocusRelocation;

  /// No description provided for @planFocusCulture.
  ///
  /// In es, this message translates to:
  /// **'Enfoque cultura: series, música y conversación cotidiana.'**
  String get planFocusCulture;

  /// No description provided for @planReadyTitle.
  ///
  /// In es, this message translates to:
  /// **'🎉 Tu plan está listo'**
  String get planReadyTitle;

  /// No description provided for @planReadySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Si cumples tu plan, llegas. Esto es lo que te tomará.'**
  String get planReadySubtitle;

  /// No description provided for @planPreparing.
  ///
  /// In es, this message translates to:
  /// **'PREPARANDO TU MAPA…'**
  String get planPreparing;

  /// No description provided for @planStartMyPlan.
  ///
  /// In es, this message translates to:
  /// **'EMPEZAR MI PLAN'**
  String get planStartMyPlan;

  /// No description provided for @planCompletionLabel.
  ///
  /// In es, this message translates to:
  /// **'LLEGARÁS APROX. EL'**
  String get planCompletionLabel;

  /// No description provided for @planStatsHours.
  ///
  /// In es, this message translates to:
  /// **'{hours} h'**
  String planStatsHours(int hours);

  /// No description provided for @planStatsTotalLabel.
  ///
  /// In es, this message translates to:
  /// **'totales'**
  String get planStatsTotalLabel;

  /// No description provided for @planStatsFrequency.
  ///
  /// In es, this message translates to:
  /// **'× {days} días/sem'**
  String planStatsFrequency(int days);

  /// No description provided for @planMaxPace.
  ///
  /// In es, this message translates to:
  /// **'¡Vas al máximo ritmo! 🔥'**
  String get planMaxPace;

  /// No description provided for @planFasterCta.
  ///
  /// In es, this message translates to:
  /// **'Quiero llegar más rápido (sube a {minutes} min/día)'**
  String planFasterCta(int minutes);

  /// No description provided for @planStartUnit.
  ///
  /// In es, this message translates to:
  /// **'Empiezas en la Unidad {unitNum} — {unitName} ({level}).'**
  String planStartUnit(int unitNum, String unitName, String level);

  /// No description provided for @planBadgeNow.
  ///
  /// In es, this message translates to:
  /// **'AHORA'**
  String get planBadgeNow;

  /// No description provided for @planBadgeGoal.
  ///
  /// In es, this message translates to:
  /// **'META'**
  String get planBadgeGoal;

  /// No description provided for @authTitleSignUp.
  ///
  /// In es, this message translates to:
  /// **'Crea tu cuenta'**
  String get authTitleSignUp;

  /// No description provided for @authTitleSignIn.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido de vuelta'**
  String get authTitleSignIn;

  /// No description provided for @authSubtitleSignUp.
  ///
  /// In es, this message translates to:
  /// **'Un plan con fecha real, examen de las 4 habilidades y un coach que te trae de vuelta.'**
  String get authSubtitleSignUp;

  /// No description provided for @authSubtitleSignIn.
  ///
  /// In es, this message translates to:
  /// **'Sigue donde lo dejaste.'**
  String get authSubtitleSignIn;

  /// No description provided for @authFieldName.
  ///
  /// In es, this message translates to:
  /// **'Tu nombre'**
  String get authFieldName;

  /// No description provided for @authFieldEmail.
  ///
  /// In es, this message translates to:
  /// **'Email'**
  String get authFieldEmail;

  /// No description provided for @authFieldPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get authFieldPassword;

  /// No description provided for @authSegCreateAccount.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get authSegCreateAccount;

  /// No description provided for @authSegSignIn.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get authSegSignIn;

  /// No description provided for @authCtaCreating.
  ///
  /// In es, this message translates to:
  /// **'CREANDO…'**
  String get authCtaCreating;

  /// No description provided for @authCtaLoggingIn.
  ///
  /// In es, this message translates to:
  /// **'ENTRANDO…'**
  String get authCtaLoggingIn;

  /// No description provided for @authCtaSignUp.
  ///
  /// In es, this message translates to:
  /// **'CREAR CUENTA'**
  String get authCtaSignUp;

  /// No description provided for @authCtaSignIn.
  ///
  /// In es, this message translates to:
  /// **'INICIAR SESIÓN'**
  String get authCtaSignIn;

  /// No description provided for @authLegalPrefix.
  ///
  /// In es, this message translates to:
  /// **'He leído y acepto los '**
  String get authLegalPrefix;

  /// No description provided for @authLegalTerms.
  ///
  /// In es, this message translates to:
  /// **'Términos'**
  String get authLegalTerms;

  /// No description provided for @authLegalAnd.
  ///
  /// In es, this message translates to:
  /// **' y la '**
  String get authLegalAnd;

  /// No description provided for @authLegalPrivacy.
  ///
  /// In es, this message translates to:
  /// **'Política de Privacidad'**
  String get authLegalPrivacy;

  /// No description provided for @authLegalSuffix.
  ///
  /// In es, this message translates to:
  /// **'.'**
  String get authLegalSuffix;

  /// No description provided for @authErrorNameRequired.
  ///
  /// In es, this message translates to:
  /// **'Dinos tu nombre para personalizar tu viaje.'**
  String get authErrorNameRequired;

  /// No description provided for @authErrorEmailPassword.
  ///
  /// In es, this message translates to:
  /// **'Pon un email válido y una contraseña de 6+ caracteres.'**
  String get authErrorEmailPassword;

  /// No description provided for @authErrorTermsRequired.
  ///
  /// In es, this message translates to:
  /// **'Para crear tu cuenta, acepta los Términos y la Privacidad.'**
  String get authErrorTermsRequired;

  /// No description provided for @authErrorGeneral.
  ///
  /// In es, this message translates to:
  /// **'Algo salió mal. Inténtalo de nuevo.'**
  String get authErrorGeneral;

  /// No description provided for @authErrorDuplicate.
  ///
  /// In es, this message translates to:
  /// **'Ese email ya tiene cuenta. Inicia sesión.'**
  String get authErrorDuplicate;

  /// No description provided for @authErrorInvalid.
  ///
  /// In es, this message translates to:
  /// **'Email o contraseña incorrectos.'**
  String get authErrorInvalid;

  /// No description provided for @authErrorPasswordLength.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener 6+ caracteres.'**
  String get authErrorPasswordLength;

  /// No description provided for @authErrorFallback.
  ///
  /// In es, this message translates to:
  /// **'No se pudo continuar. Revisa tus datos.'**
  String get authErrorFallback;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
