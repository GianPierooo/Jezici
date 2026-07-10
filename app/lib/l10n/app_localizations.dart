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

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// No description provided for @settingsSecLanguage.
  ///
  /// In es, this message translates to:
  /// **'IDIOMA'**
  String get settingsSecLanguage;

  /// No description provided for @settingsSecNotifications.
  ///
  /// In es, this message translates to:
  /// **'NOTIFICACIONES'**
  String get settingsSecNotifications;

  /// No description provided for @settingsSecGoal.
  ///
  /// In es, this message translates to:
  /// **'META Y RECORDATORIOS'**
  String get settingsSecGoal;

  /// No description provided for @settingsSecAccount.
  ///
  /// In es, this message translates to:
  /// **'CUENTA'**
  String get settingsSecAccount;

  /// No description provided for @settingsSecOther.
  ///
  /// In es, this message translates to:
  /// **'OTROS'**
  String get settingsSecOther;

  /// No description provided for @settingsSecAdvanced.
  ///
  /// In es, this message translates to:
  /// **'AVANZADO'**
  String get settingsSecAdvanced;

  /// No description provided for @settingsLearns.
  ///
  /// In es, this message translates to:
  /// **'Aprendes'**
  String get settingsLearns;

  /// No description provided for @settingsLearnsSub.
  ///
  /// In es, this message translates to:
  /// **'{lang} · Objetivo {goal}'**
  String settingsLearnsSub(String lang, String goal);

  /// No description provided for @settingsChange.
  ///
  /// In es, this message translates to:
  /// **'Cambiar'**
  String get settingsChange;

  /// No description provided for @settingsAppLanguageRow.
  ///
  /// In es, this message translates to:
  /// **'Idioma de la app'**
  String get settingsAppLanguageRow;

  /// No description provided for @settingsChooseCourse.
  ///
  /// In es, this message translates to:
  /// **'¿Qué idioma quieres aprender?'**
  String get settingsChooseCourse;

  /// No description provided for @settingsChooseAppLang.
  ///
  /// In es, this message translates to:
  /// **'Idioma de la app'**
  String get settingsChooseAppLang;

  /// No description provided for @settingsCoachIntensity.
  ///
  /// In es, this message translates to:
  /// **'Intensidad del coach'**
  String get settingsCoachIntensity;

  /// No description provided for @settingsCoachInsist.
  ///
  /// In es, this message translates to:
  /// **'¿Cuánto insiste Matix?'**
  String get settingsCoachInsist;

  /// No description provided for @settingsIntensityLow.
  ///
  /// In es, this message translates to:
  /// **'Suave'**
  String get settingsIntensityLow;

  /// No description provided for @settingsIntensityMid.
  ///
  /// In es, this message translates to:
  /// **'Media'**
  String get settingsIntensityMid;

  /// No description provided for @settingsIntensityHigh.
  ///
  /// In es, this message translates to:
  /// **'Alta'**
  String get settingsIntensityHigh;

  /// No description provided for @settingsQuiet.
  ///
  /// In es, this message translates to:
  /// **'No molestar'**
  String get settingsQuiet;

  /// No description provided for @settingsQuietSub.
  ///
  /// In es, this message translates to:
  /// **'Sin avisos en este horario'**
  String get settingsQuietSub;

  /// No description provided for @settingsQuietOff.
  ///
  /// In es, this message translates to:
  /// **'Desactivado'**
  String get settingsQuietOff;

  /// No description provided for @settingsQuietEnable.
  ///
  /// In es, this message translates to:
  /// **'Activar horario de silencio'**
  String get settingsQuietEnable;

  /// No description provided for @settingsQuietFrom.
  ///
  /// In es, this message translates to:
  /// **'Desde'**
  String get settingsQuietFrom;

  /// No description provided for @settingsQuietTo.
  ///
  /// In es, this message translates to:
  /// **'Hasta'**
  String get settingsQuietTo;

  /// No description provided for @settingsMeta.
  ///
  /// In es, this message translates to:
  /// **'Meta diaria'**
  String get settingsMeta;

  /// No description provided for @settingsMetaSub.
  ///
  /// In es, this message translates to:
  /// **'{min} min · {xp} XP al día'**
  String settingsMetaSub(int min, int xp);

  /// No description provided for @settingsMetaXpDay.
  ///
  /// In es, this message translates to:
  /// **'≈ {xp} XP/día (más minutos = meta más alta)'**
  String settingsMetaXpDay(int xp);

  /// No description provided for @settingsDailyReminder.
  ///
  /// In es, this message translates to:
  /// **'Recordatorio diario'**
  String get settingsDailyReminder;

  /// No description provided for @settingsDailyReminderSub.
  ///
  /// In es, this message translates to:
  /// **'Todos los días a las 20:00'**
  String get settingsDailyReminderSub;

  /// No description provided for @settingsStreakAlert.
  ///
  /// In es, this message translates to:
  /// **'Aviso de racha en peligro'**
  String get settingsStreakAlert;

  /// No description provided for @settingsStreakAlertSub.
  ///
  /// In es, this message translates to:
  /// **'Si olvidas practicar'**
  String get settingsStreakAlertSub;

  /// No description provided for @settingsReminderNote.
  ///
  /// In es, this message translates to:
  /// **'Tu preferencia se guarda. Los recordatorios push llegan pronto.'**
  String get settingsReminderNote;

  /// No description provided for @settingsEditProfile.
  ///
  /// In es, this message translates to:
  /// **'Editar perfil'**
  String get settingsEditProfile;

  /// No description provided for @settingsSubscription.
  ///
  /// In es, this message translates to:
  /// **'Suscripción'**
  String get settingsSubscription;

  /// No description provided for @settingsPlanFree.
  ///
  /// In es, this message translates to:
  /// **'Plan gratis · Mejorar'**
  String get settingsPlanFree;

  /// No description provided for @settingsLogout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get settingsLogout;

  /// No description provided for @settingsSounds.
  ///
  /// In es, this message translates to:
  /// **'Sonidos'**
  String get settingsSounds;

  /// No description provided for @settingsMusic.
  ///
  /// In es, this message translates to:
  /// **'Música del mapa'**
  String get settingsMusic;

  /// No description provided for @settingsMusicSub.
  ///
  /// In es, this message translates to:
  /// **'Loop ambiente en Aprender. Baja sola con los sonidos.'**
  String get settingsMusicSub;

  /// No description provided for @settingsVibration.
  ///
  /// In es, this message translates to:
  /// **'Vibración'**
  String get settingsVibration;

  /// No description provided for @settingsPrivacy.
  ///
  /// In es, this message translates to:
  /// **'Privacidad y datos'**
  String get settingsPrivacy;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In es, this message translates to:
  /// **'Política de Privacidad'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsTerms.
  ///
  /// In es, this message translates to:
  /// **'Términos y Condiciones'**
  String get settingsTerms;

  /// No description provided for @settingsTestMatix.
  ///
  /// In es, this message translates to:
  /// **'Probar a Matix'**
  String get settingsTestMatix;

  /// No description provided for @settingsMetrics.
  ///
  /// In es, this message translates to:
  /// **'Ver métricas (interno)'**
  String get settingsMetrics;

  /// No description provided for @settingsExport.
  ///
  /// In es, this message translates to:
  /// **'Exportar mis datos'**
  String get settingsExport;

  /// No description provided for @settingsDelete.
  ///
  /// In es, this message translates to:
  /// **'Borrar mi cuenta'**
  String get settingsDelete;

  /// No description provided for @settingsSaveError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron guardar los ajustes.'**
  String get settingsSaveError;

  /// No description provided for @coachNameManoDura.
  ///
  /// In es, this message translates to:
  /// **'Mano dura'**
  String get coachNameManoDura;

  /// No description provided for @coachNamePositivo.
  ///
  /// In es, this message translates to:
  /// **'Positivo'**
  String get coachNamePositivo;

  /// No description provided for @coachNameRezago.
  ///
  /// In es, this message translates to:
  /// **'Sin rezago'**
  String get coachNameRezago;

  /// No description provided for @coachNameSuave.
  ///
  /// In es, this message translates to:
  /// **'Suave'**
  String get coachNameSuave;

  /// No description provided for @coachExManoDura.
  ///
  /// In es, this message translates to:
  /// **'«Sin excusas. Entra ya. 💪»'**
  String get coachExManoDura;

  /// No description provided for @coachExPositivo.
  ///
  /// In es, this message translates to:
  /// **'«¡Vas genial, sigue así! 🎉»'**
  String get coachExPositivo;

  /// No description provided for @coachExRezago.
  ///
  /// In es, this message translates to:
  /// **'«Llevas 2 días sin practicar… 👀»'**
  String get coachExRezago;

  /// No description provided for @coachExSuave.
  ///
  /// In es, this message translates to:
  /// **'«Sin prisa, ve a tu ritmo 🌱»'**
  String get coachExSuave;

  /// No description provided for @courseSwitchFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cambiar el curso.'**
  String get courseSwitchFailed;

  /// No description provided for @convTitle.
  ///
  /// In es, this message translates to:
  /// **'Conversar'**
  String get convTitle;

  /// No description provided for @convSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Practica conversaciones reales. A tu ritmo, sin presión.'**
  String get convSubtitle;

  /// No description provided for @convLiveTitle.
  ///
  /// In es, this message translates to:
  /// **'🎙️  Conversación en vivo — próximamente'**
  String get convLiveTitle;

  /// No description provided for @convLiveBody.
  ///
  /// In es, this message translates to:
  /// **'Pronto podrás conversar con feedback en tiempo real. Lo lanzaremos con moderación y verificación de edad para que sea seguro. Mientras, practica abajo.'**
  String get convLiveBody;

  /// No description provided for @convPracticeHeader.
  ///
  /// In es, this message translates to:
  /// **'Practica hablando o escribiendo'**
  String get convPracticeHeader;

  /// No description provided for @convPracticeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elige una situación, responde, y compárate con una respuesta modelo.'**
  String get convPracticeSubtitle;

  /// No description provided for @convInterestTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Usarías la conversación en vivo?'**
  String get convInterestTitle;

  /// No description provided for @convInterestYes.
  ///
  /// In es, this message translates to:
  /// **'Sí, me encantaría'**
  String get convInterestYes;

  /// No description provided for @convInterestNo.
  ///
  /// In es, this message translates to:
  /// **'No por ahora'**
  String get convInterestNo;

  /// No description provided for @convInterestHint.
  ///
  /// In es, this message translates to:
  /// **'¿Sobre qué temas? (opcional)'**
  String get convInterestHint;

  /// No description provided for @convSend.
  ///
  /// In es, this message translates to:
  /// **'ENVIAR'**
  String get convSend;

  /// No description provided for @convSending.
  ///
  /// In es, this message translates to:
  /// **'ENVIANDO…'**
  String get convSending;

  /// No description provided for @convInterestThanks.
  ///
  /// In es, this message translates to:
  /// **'¡Gracias! Te avisaremos cuando la conversación en vivo esté lista.'**
  String get convInterestThanks;

  /// No description provided for @convInterestFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo enviar. Inténtalo de nuevo.'**
  String get convInterestFailed;

  /// No description provided for @convModeWrite.
  ///
  /// In es, this message translates to:
  /// **'Escribir'**
  String get convModeWrite;

  /// No description provided for @convModeSpeak.
  ///
  /// In es, this message translates to:
  /// **'Hablar'**
  String get convModeSpeak;

  /// No description provided for @convHintWrite.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu respuesta…'**
  String get convHintWrite;

  /// No description provided for @convHintVoice.
  ///
  /// In es, this message translates to:
  /// **'Tu transcripción aparecerá aquí (o edítala)'**
  String get convHintVoice;

  /// No description provided for @convSeeModel.
  ///
  /// In es, this message translates to:
  /// **'VER RESPUESTA MODELO'**
  String get convSeeModel;

  /// No description provided for @convModelAnswer.
  ///
  /// In es, this message translates to:
  /// **'Respuesta modelo'**
  String get convModelAnswer;

  /// No description provided for @convKeyPhrases.
  ///
  /// In es, this message translates to:
  /// **'Frases clave'**
  String get convKeyPhrases;

  /// No description provided for @convSelfEval.
  ///
  /// In es, this message translates to:
  /// **'¿Qué tan cerca estuviste del modelo?'**
  String get convSelfEval;

  /// No description provided for @convSaveFinish.
  ///
  /// In es, this message translates to:
  /// **'GUARDAR Y TERMINAR'**
  String get convSaveFinish;

  /// No description provided for @convSaving.
  ///
  /// In es, this message translates to:
  /// **'GUARDANDO…'**
  String get convSaving;

  /// No description provided for @convSaved.
  ///
  /// In es, this message translates to:
  /// **'¡Guardado! Cada práctica suma. 🦜'**
  String get convSaved;

  /// No description provided for @convSaveFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar. Inténtalo de nuevo.'**
  String get convSaveFailed;

  /// No description provided for @convMicPreparing.
  ///
  /// In es, this message translates to:
  /// **'Preparando micrófono…'**
  String get convMicPreparing;

  /// No description provided for @convMicUnavailable.
  ///
  /// In es, this message translates to:
  /// **'Tu navegador no permite el micrófono. Escribe tu respuesta 🙂'**
  String get convMicUnavailable;

  /// No description provided for @convListening.
  ///
  /// In es, this message translates to:
  /// **'Escuchando…'**
  String get convListening;

  /// No description provided for @convSpeakBtn.
  ///
  /// In es, this message translates to:
  /// **'Hablar'**
  String get convSpeakBtn;

  /// No description provided for @convTopicCafeTitle.
  ///
  /// In es, this message translates to:
  /// **'Pedir un café'**
  String get convTopicCafeTitle;

  /// No description provided for @convTopicCafeScenario.
  ///
  /// In es, this message translates to:
  /// **'Estás en una cafetería. Pide un café y algo de comer, y pregunta el precio.'**
  String get convTopicCafeScenario;

  /// No description provided for @convTopicIntroTitle.
  ///
  /// In es, this message translates to:
  /// **'Presentarte'**
  String get convTopicIntroTitle;

  /// No description provided for @convTopicIntroScenario.
  ///
  /// In es, this message translates to:
  /// **'Conoces a alguien nuevo. Preséntate: nombre, de dónde eres y qué haces.'**
  String get convTopicIntroScenario;

  /// No description provided for @convTopicAirportTitle.
  ///
  /// In es, this message translates to:
  /// **'En el aeropuerto'**
  String get convTopicAirportTitle;

  /// No description provided for @convTopicAirportScenario.
  ///
  /// In es, this message translates to:
  /// **'Estás en el aeropuerto. Pregunta por tu puerta y la hora del vuelo.'**
  String get convTopicAirportScenario;

  /// No description provided for @convTopicWeekendTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu fin de semana'**
  String get convTopicWeekendTitle;

  /// No description provided for @convTopicWeekendScenario.
  ///
  /// In es, this message translates to:
  /// **'Cuenta qué hiciste el fin de semana pasado (pasado simple).'**
  String get convTopicWeekendScenario;

  /// No description provided for @convTopicInterviewTitle.
  ///
  /// In es, this message translates to:
  /// **'Una entrevista breve'**
  String get convTopicInterviewTitle;

  /// No description provided for @convTopicInterviewScenario.
  ///
  /// In es, this message translates to:
  /// **'Te preguntan por qué quieres el trabajo. Responde con 2 razones.'**
  String get convTopicInterviewScenario;

  /// No description provided for @convTopicDirectionsTitle.
  ///
  /// In es, this message translates to:
  /// **'Pedir indicaciones'**
  String get convTopicDirectionsTitle;

  /// No description provided for @convTopicDirectionsScenario.
  ///
  /// In es, this message translates to:
  /// **'Pregunta cómo llegar a la estación de tren y si está lejos.'**
  String get convTopicDirectionsScenario;

  /// No description provided for @learnLangEn.
  ///
  /// In es, this message translates to:
  /// **'inglés'**
  String get learnLangEn;

  /// No description provided for @learnLangPt.
  ///
  /// In es, this message translates to:
  /// **'portugués'**
  String get learnLangPt;

  /// No description provided for @learnLangFr.
  ///
  /// In es, this message translates to:
  /// **'francés'**
  String get learnLangFr;

  /// No description provided for @learnLangIt.
  ///
  /// In es, this message translates to:
  /// **'italiano'**
  String get learnLangIt;

  /// No description provided for @learnLangDe.
  ///
  /// In es, this message translates to:
  /// **'alemán'**
  String get learnLangDe;

  /// No description provided for @learnLangNl.
  ///
  /// In es, this message translates to:
  /// **'neerlandés'**
  String get learnLangNl;

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

  /// No description provided for @onbCoachBubble.
  ///
  /// In es, this message translates to:
  /// **'¡Hagamos un plan a tu medida! 🦜'**
  String get onbCoachBubble;

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
  /// **'Esto solo cambia el idioma de los menús y textos, no lo que vas a aprender.'**
  String get onbLanguageInfoEn;

  /// No description provided for @onbLanguageInfoPt.
  ///
  /// In es, this message translates to:
  /// **'Vas a aprender portugués 🇧🇷. Esto solo cambia el idioma de la app.'**
  String get onbLanguageInfoPt;

  /// No description provided for @onbNameTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo te llamas?'**
  String get onbNameTitle;

  /// No description provided for @onbNameSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Así te saludamos y aparecerá en tu perfil y certificados.'**
  String get onbNameSubtitle;

  /// No description provided for @onbNameHint.
  ///
  /// In es, this message translates to:
  /// **'Tu nombre'**
  String get onbNameHint;

  /// No description provided for @onbTargetTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Qué idioma quieres aprender?'**
  String get onbTargetTitle;

  /// No description provided for @onbTargetSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tu curso. Esto define tu plan y el test de nivel. Podrás cambiarlo luego en Ajustes.'**
  String get onbTargetSubtitle;

  /// No description provided for @onbMotiveTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Por qué aprendes {course}?'**
  String onbMotiveTitle(String course);

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
  /// **'¿Cuánto {course} sabes ya?'**
  String onbStartLevelTitle(String course);

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

  /// No description provided for @placementSpeak.
  ///
  /// In es, this message translates to:
  /// **'Hablar'**
  String get placementSpeak;

  /// No description provided for @placementListening.
  ///
  /// In es, this message translates to:
  /// **'Escuchando…'**
  String get placementListening;

  /// No description provided for @placementSendAnswer.
  ///
  /// In es, this message translates to:
  /// **'Enviar mi respuesta'**
  String get placementSendAnswer;

  /// No description provided for @placementSkipSpeaking.
  ///
  /// In es, this message translates to:
  /// **'Saltar los ejercicios de hablar'**
  String get placementSkipSpeaking;

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

  /// No description provided for @placementResultStartFromZero.
  ///
  /// In es, this message translates to:
  /// **'Prefiero empezar desde el inicio'**
  String get placementResultStartFromZero;

  /// No description provided for @placementResultStartFromZeroConfirm.
  ///
  /// In es, this message translates to:
  /// **'Empezarás desde A1 (Unidad 1), no desde {level}. Tú decides: avanzarás a tu ritmo. ¿Continuar?'**
  String placementResultStartFromZeroConfirm(String level);

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

  /// No description provided for @coursePlacementOfferTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Hacer el test de ubicación?'**
  String get coursePlacementOfferTitle;

  /// No description provided for @coursePlacementOfferBody.
  ///
  /// In es, this message translates to:
  /// **'Haz una prueba corta y empieza en tu nivel real de {course}, en lugar de desde el principio.'**
  String coursePlacementOfferBody(String course);

  /// No description provided for @coursePlacementDoTest.
  ///
  /// In es, this message translates to:
  /// **'Hacer el test'**
  String get coursePlacementDoTest;

  /// No description provided for @coursePlacementFromScratch.
  ///
  /// In es, this message translates to:
  /// **'Empezar desde el principio'**
  String get coursePlacementFromScratch;

  /// No description provided for @coursePlacementDone.
  ///
  /// In es, this message translates to:
  /// **'¡Listo! Te ubicamos en {level}.'**
  String coursePlacementDone(String level);

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

  /// No description provided for @planReadyKicker.
  ///
  /// In es, this message translates to:
  /// **'PERSONALIZADO PARA TI'**
  String get planReadyKicker;

  /// No description provided for @planStartJourney.
  ///
  /// In es, this message translates to:
  /// **'Empezar mi viaje'**
  String get planStartJourney;

  /// No description provided for @planJourneyHere.
  ///
  /// In es, this message translates to:
  /// **'ESTÁS AQUÍ'**
  String get planJourneyHere;

  /// No description provided for @planJourneyGoal.
  ///
  /// In es, this message translates to:
  /// **'TU META'**
  String get planJourneyGoal;

  /// No description provided for @planHalfTime.
  ///
  /// In es, this message translates to:
  /// **'⚡ ¡La mitad de tiempo!'**
  String get planHalfTime;

  /// No description provided for @planPaceLine.
  ///
  /// In es, this message translates to:
  /// **'Con {minutes} min/día llegas a {level} el'**
  String planPaceLine(int minutes, String level);

  /// No description provided for @planLeverTitleOff.
  ///
  /// In es, this message translates to:
  /// **'¿Quieres llegar más rápido?'**
  String get planLeverTitleOff;

  /// No description provided for @planLeverTitleOn.
  ///
  /// In es, this message translates to:
  /// **'🚀 ¡Vas a toda máquina!'**
  String get planLeverTitleOn;

  /// No description provided for @planLeverTextOff.
  ///
  /// In es, this message translates to:
  /// **'Sube a {minutes} min/día y llegas en la mitad del tiempo 💪'**
  String planLeverTextOff(int minutes);

  /// No description provided for @planLeverTextOn.
  ///
  /// In es, this message translates to:
  /// **'Plan de {minutes} min/día activado: llegas en la mitad del tiempo.'**
  String planLeverTextOn(int minutes);

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

  /// No description provided for @authContinueGoogle.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get authContinueGoogle;

  /// No description provided for @authOr.
  ///
  /// In es, this message translates to:
  /// **'o'**
  String get authOr;

  /// No description provided for @authGoogleError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo continuar con Google. Intenta con tu email.'**
  String get authGoogleError;

  /// No description provided for @authCheckEmail.
  ///
  /// In es, this message translates to:
  /// **'Te enviamos un correo para confirmar tu cuenta. Ábrelo y vuelve para continuar.'**
  String get authCheckEmail;

  /// No description provided for @lessonSaveErrorTitle.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar tu progreso'**
  String get lessonSaveErrorTitle;

  /// No description provided for @lessonSaveErrorMsg.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu conexión e inténtalo de nuevo.'**
  String get lessonSaveErrorMsg;

  /// No description provided for @lessonNoExercises.
  ///
  /// In es, this message translates to:
  /// **'Esta lección aún no tiene ejercicios.'**
  String get lessonNoExercises;

  /// No description provided for @lessonFeedbackNear.
  ///
  /// In es, this message translates to:
  /// **'¡Casi! 🦜'**
  String get lessonFeedbackNear;

  /// No description provided for @lessonFeedbackCorrect.
  ///
  /// In es, this message translates to:
  /// **'¡Correcto! 🦜'**
  String get lessonFeedbackCorrect;

  /// No description provided for @lessonFeedbackWrong.
  ///
  /// In es, this message translates to:
  /// **'No del todo 🦜'**
  String get lessonFeedbackWrong;

  /// No description provided for @lessonFeedbackCorrectForm.
  ///
  /// In es, this message translates to:
  /// **'La forma correcta es: {form}'**
  String lessonFeedbackCorrectForm(String form);

  /// No description provided for @lessonFeedbackWellDone.
  ///
  /// In es, this message translates to:
  /// **'¡Bien hecho, sigue así!'**
  String get lessonFeedbackWellDone;

  /// No description provided for @lessonFeedbackRightAnswer.
  ///
  /// In es, this message translates to:
  /// **'Respuesta correcta: {answer}'**
  String lessonFeedbackRightAnswer(String answer);

  /// No description provided for @lessonAudioUnavailableTitle.
  ///
  /// In es, this message translates to:
  /// **'Audio no disponible'**
  String get lessonAudioUnavailableTitle;

  /// No description provided for @lessonAudioUnavailableMsg.
  ///
  /// In es, this message translates to:
  /// **'Este ejercicio aún no tiene su audio. Lo saltamos: no afecta tus vidas ni tu puntaje.'**
  String get lessonAudioUnavailableMsg;

  /// No description provided for @lessonCompletePerfectTitle.
  ///
  /// In es, this message translates to:
  /// **'LECCIÓN PERFECTA'**
  String get lessonCompletePerfectTitle;

  /// No description provided for @lessonCompleteTitle.
  ///
  /// In es, this message translates to:
  /// **'LECCIÓN COMPLETADA'**
  String get lessonCompleteTitle;

  /// No description provided for @lessonCompletePerfectMsg.
  ///
  /// In es, this message translates to:
  /// **'¡Impecable! 🌟'**
  String get lessonCompletePerfectMsg;

  /// No description provided for @lessonCompleteMsg.
  ///
  /// In es, this message translates to:
  /// **'¡Lo lograste! 🎉'**
  String get lessonCompleteMsg;

  /// No description provided for @lessonCompleteXpLabel.
  ///
  /// In es, this message translates to:
  /// **'XP GANADO'**
  String get lessonCompleteXpLabel;

  /// No description provided for @lessonCompleteAccuracyLabel.
  ///
  /// In es, this message translates to:
  /// **'PRECISIÓN'**
  String get lessonCompleteAccuracyLabel;

  /// No description provided for @lessonCompleteGoldLabel.
  ///
  /// In es, this message translates to:
  /// **'ORO'**
  String get lessonCompleteGoldLabel;

  /// No description provided for @lessonCompleteComboBonusLabel.
  ///
  /// In es, this message translates to:
  /// **'Bonus de combo'**
  String get lessonCompleteComboBonusLabel;

  /// No description provided for @lessonCompleteComboDetail.
  ///
  /// In es, this message translates to:
  /// **'+{bonus} XP · x{combo} seguidas'**
  String lessonCompleteComboDetail(int bonus, int combo);

  /// No description provided for @lessonCompleteMilestone.
  ///
  /// In es, this message translates to:
  /// **'¡Hito de {days} días! Recompensa de oro desbloqueada'**
  String lessonCompleteMilestone(int days);

  /// No description provided for @lessonCompleteStreakDays.
  ///
  /// In es, this message translates to:
  /// **'{streak, plural, =1{🔥 {streak} día de racha} other{🔥 {streak} días de racha}}'**
  String lessonCompleteStreakDays(int streak);

  /// No description provided for @lessonCompleteStreakAdvanced.
  ///
  /// In es, this message translates to:
  /// **'¡+1 hoy! Cumpliste tu meta diaria'**
  String get lessonCompleteStreakAdvanced;

  /// No description provided for @lessonCompleteGoalMet.
  ///
  /// In es, this message translates to:
  /// **'Meta diaria cumplida'**
  String get lessonCompleteGoalMet;

  /// No description provided for @lessonCompleteGoalPending.
  ///
  /// In es, this message translates to:
  /// **'Sigue para cumplir tu meta de hoy'**
  String get lessonCompleteGoalPending;

  /// No description provided for @lessonCompleteFreezeSingle.
  ///
  /// In es, this message translates to:
  /// **'Tu congelador salvó tu racha'**
  String get lessonCompleteFreezeSingle;

  /// No description provided for @lessonCompleteFreezeMulti.
  ///
  /// In es, this message translates to:
  /// **'Tus congeladores salvaron tu racha'**
  String get lessonCompleteFreezeMulti;

  /// No description provided for @lessonCompleteSkillsUp.
  ///
  /// In es, this message translates to:
  /// **'Habilidades que subieron'**
  String get lessonCompleteSkillsUp;

  /// No description provided for @lessonCompleteSkillNext.
  ///
  /// In es, this message translates to:
  /// **'Sigue así para alcanzar {level} y acercarte al certificado'**
  String lessonCompleteSkillNext(String level);

  /// No description provided for @lessonCompleteSkillAdvanced.
  ///
  /// In es, this message translates to:
  /// **'▲ subió'**
  String get lessonCompleteSkillAdvanced;

  /// No description provided for @tipCardHeader.
  ///
  /// In es, this message translates to:
  /// **'Matix te enseña · {type}'**
  String tipCardHeader(String type);

  /// No description provided for @tipCardPersonalized.
  ///
  /// In es, this message translates to:
  /// **'Te lo doy porque tu {skill} necesita un empujón. 🦜'**
  String tipCardPersonalized(String skill);

  /// No description provided for @errorReviewWhyTranslation.
  ///
  /// In es, this message translates to:
  /// **'Fíjate en la forma exacta en inglés — el sentido completo importa.'**
  String get errorReviewWhyTranslation;

  /// No description provided for @errorReviewWhyCloze.
  ///
  /// In es, this message translates to:
  /// **'Repasa la palabra que faltaba en la frase.'**
  String get errorReviewWhyCloze;

  /// No description provided for @errorReviewWhyWordOrder.
  ///
  /// In es, this message translates to:
  /// **'Cuida el ORDEN de las palabras: el inglés es más fijo que el español.'**
  String get errorReviewWhyWordOrder;

  /// No description provided for @errorReviewWhyMatch.
  ///
  /// In es, this message translates to:
  /// **'Asocia cada palabra con su pareja correcta.'**
  String get errorReviewWhyMatch;

  /// No description provided for @errorReviewWhyListening.
  ///
  /// In es, this message translates to:
  /// **'Vuelve a escuchar con calma; el sonido te da la pista.'**
  String get errorReviewWhyListening;

  /// No description provided for @errorReviewWhyDefault.
  ///
  /// In es, this message translates to:
  /// **'Repásalo: lo verás de nuevo pronto en tu repaso.'**
  String get errorReviewWhyDefault;

  /// No description provided for @errorReviewTitle.
  ///
  /// In es, this message translates to:
  /// **'Repasa lo que fallaste'**
  String get errorReviewTitle;

  /// No description provided for @errorReviewSubtitle.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 ejercicio para reforzar. ¡Ya casi lo tienes!} other{{count} ejercicios para reforzar. ¡Ya casi los tienes!}}'**
  String errorReviewSubtitle(int count);

  /// No description provided for @errorReviewPracticeCta.
  ///
  /// In es, this message translates to:
  /// **'Practicar los fallados'**
  String get errorReviewPracticeCta;

  /// No description provided for @tileArrangePlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Toca las palabras para formar la frase…'**
  String get tileArrangePlaceholder;

  /// No description provided for @tileArrangeAllPlaced.
  ///
  /// In es, this message translates to:
  /// **'Todas colocadas — pulsa COMPROBAR'**
  String get tileArrangeAllPlaced;

  /// No description provided for @translationHint.
  ///
  /// In es, this message translates to:
  /// **'Escribe la traducción…'**
  String get translationHint;

  /// No description provided for @clozeHint.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu respuesta…'**
  String get clozeHint;

  /// No description provided for @listeningTapToListen.
  ///
  /// In es, this message translates to:
  /// **'Toca para escuchar'**
  String get listeningTapToListen;

  /// No description provided for @speakingPreparingMic.
  ///
  /// In es, this message translates to:
  /// **'Preparando micrófono…'**
  String get speakingPreparingMic;

  /// No description provided for @speakingNoMic.
  ///
  /// In es, this message translates to:
  /// **'Tu navegador o dispositivo no permite el micrófono.'**
  String get speakingNoMic;

  /// No description provided for @speakingIReadIt.
  ///
  /// In es, this message translates to:
  /// **'Ya lo leí ✓'**
  String get speakingIReadIt;

  /// No description provided for @speakingManualDone.
  ///
  /// In es, this message translates to:
  /// **'¡Bien! Sigue practicando en voz alta. 🦜'**
  String get speakingManualDone;

  /// No description provided for @speakingListening.
  ///
  /// In es, this message translates to:
  /// **'Escuchando…'**
  String get speakingListening;

  /// No description provided for @speakingTalk.
  ///
  /// In es, this message translates to:
  /// **'Hablar'**
  String get speakingTalk;

  /// No description provided for @speakingGood.
  ///
  /// In es, this message translates to:
  /// **'¡Bien pronunciado! 🦜'**
  String get speakingGood;

  /// No description provided for @speakingNoSound.
  ///
  /// In es, this message translates to:
  /// **'No te escuché — acércate e inténtalo'**
  String get speakingNoSound;

  /// No description provided for @speakingOk.
  ///
  /// In es, this message translates to:
  /// **'Vas bien. Léelo otra vez si quieres'**
  String get speakingOk;

  /// No description provided for @speakingHeard.
  ///
  /// In es, this message translates to:
  /// **'Escuché: \"{heard}\"'**
  String speakingHeard(String heard);

  /// No description provided for @speakingVolumeHint.
  ///
  /// In es, this message translates to:
  /// **'Sube el volumen del micro, o toca \"Ya lo leí ✓\" para continuar.'**
  String get speakingVolumeHint;

  /// No description provided for @speakingRetryHint.
  ///
  /// In es, this message translates to:
  /// **'Escuché: \"{heard}\". Puedes reintentar o tocar \"Ya lo leí ✓\".'**
  String speakingRetryHint(String heard);

  /// No description provided for @speakingHearModel.
  ///
  /// In es, this message translates to:
  /// **'Oír el modelo'**
  String get speakingHearModel;

  /// No description provided for @audioPlayDefault.
  ///
  /// In es, this message translates to:
  /// **'Escuchar'**
  String get audioPlayDefault;

  /// No description provided for @stubTagPronunciation.
  ///
  /// In es, this message translates to:
  /// **'PRONUNCIACIÓN'**
  String get stubTagPronunciation;

  /// No description provided for @stubNotePronunciation.
  ///
  /// In es, this message translates to:
  /// **'El reconocimiento de voz llega pronto. Por ahora, practícalo en voz alta y continúa.'**
  String get stubNotePronunciation;

  /// No description provided for @stubTagListening.
  ///
  /// In es, this message translates to:
  /// **'COMPRENSIÓN AUDITIVA'**
  String get stubTagListening;

  /// No description provided for @stubNoteListening.
  ///
  /// In es, this message translates to:
  /// **'El audio de este ejercicio se graba pronto. Por ahora, continúa.'**
  String get stubNoteListening;

  /// No description provided for @stubTagDictation.
  ///
  /// In es, this message translates to:
  /// **'DICTADO'**
  String get stubTagDictation;

  /// No description provided for @stubNoteDictation.
  ///
  /// In es, this message translates to:
  /// **'El dictado necesita audio (se graba pronto). Por ahora, continúa.'**
  String get stubNoteDictation;

  /// No description provided for @stubTagGuidedWriting.
  ///
  /// In es, this message translates to:
  /// **'ESCRITURA GUIADA'**
  String get stubTagGuidedWriting;

  /// No description provided for @stubNoteGuidedWriting.
  ///
  /// In es, this message translates to:
  /// **'La escritura guiada con corrección llega pronto. Por ahora, continúa.'**
  String get stubNoteGuidedWriting;

  /// No description provided for @stubTagComingSoon.
  ///
  /// In es, this message translates to:
  /// **'PRÓXIMAMENTE'**
  String get stubTagComingSoon;

  /// No description provided for @stubNoteComingSoon.
  ///
  /// In es, this message translates to:
  /// **'Este tipo de ejercicio llega pronto. Por ahora, continúa.'**
  String get stubNoteComingSoon;

  /// No description provided for @noHeartsTitle.
  ///
  /// In es, this message translates to:
  /// **'Te quedaste sin vidas ❤️'**
  String get noHeartsTitle;

  /// No description provided for @noHeartsMsg.
  ///
  /// In es, this message translates to:
  /// **'¡Tranqui, le pasa a todos! Vuelven gratis en tu próxima lección, o sigue ahora 💪'**
  String get noHeartsMsg;

  /// No description provided for @noHeartsRefill.
  ///
  /// In es, this message translates to:
  /// **'Recargar vidas y seguir'**
  String get noHeartsRefill;

  /// No description provided for @noHeartsRefillPriced.
  ///
  /// In es, this message translates to:
  /// **'Recargar vidas · 🪙{gold}'**
  String noHeartsRefillPriced(int gold);

  /// No description provided for @noHeartsInsufficientGold.
  ///
  /// In es, this message translates to:
  /// **'No tienes oro suficiente para recargar.'**
  String get noHeartsInsufficientGold;

  /// No description provided for @noHeartsRefilled.
  ///
  /// In es, this message translates to:
  /// **'¡Vidas recargadas! ❤️'**
  String get noHeartsRefilled;

  /// No description provided for @noHeartsQuit.
  ///
  /// In es, this message translates to:
  /// **'Salir de la lección'**
  String get noHeartsQuit;

  /// No description provided for @noHeartsFreeNext.
  ///
  /// In es, this message translates to:
  /// **'Vidas gratis en tu próxima lección'**
  String get noHeartsFreeNext;

  /// No description provided for @noHeartsFreeNextSub.
  ///
  /// In es, this message translates to:
  /// **'Sin esperas: cada lección empieza con 5 ❤️'**
  String get noHeartsFreeNextSub;

  /// No description provided for @noHeartsWatchAd.
  ///
  /// In es, this message translates to:
  /// **'Ver un anuncio'**
  String get noHeartsWatchAd;

  /// No description provided for @noHeartsWatchAdSub.
  ///
  /// In es, this message translates to:
  /// **'Recupera 1 vida'**
  String get noHeartsWatchAdSub;

  /// No description provided for @noHeartsSoon.
  ///
  /// In es, this message translates to:
  /// **'Pronto'**
  String get noHeartsSoon;

  /// No description provided for @noHeartsRefillAll.
  ///
  /// In es, this message translates to:
  /// **'Recargar todas'**
  String get noHeartsRefillAll;

  /// No description provided for @noHeartsRefillAllSub.
  ///
  /// In es, this message translates to:
  /// **'Rellena tus 5 vidas al instante'**
  String get noHeartsRefillAllSub;

  /// No description provided for @noHeartsUnlimited.
  ///
  /// In es, this message translates to:
  /// **'Vidas ilimitadas'**
  String get noHeartsUnlimited;

  /// No description provided for @noHeartsUnlimitedSub.
  ///
  /// In es, this message translates to:
  /// **'Nunca más esperes · con Premium'**
  String get noHeartsUnlimitedSub;

  /// No description provided for @certHolderIntro.
  ///
  /// In es, this message translates to:
  /// **'Se certifica que'**
  String get certHolderIntro;

  /// No description provided for @heartsPanelTitle.
  ///
  /// In es, this message translates to:
  /// **'Vidas'**
  String get heartsPanelTitle;

  /// No description provided for @heartsPanelRegen.
  ///
  /// In es, this message translates to:
  /// **'Se regeneran solas con el tiempo. Pierdes una vida por cada respuesta incorrecta.'**
  String get heartsPanelRegen;

  /// No description provided for @heartsPanelFull.
  ///
  /// In es, this message translates to:
  /// **'¡Tienes todas tus vidas! ❤️'**
  String get heartsPanelFull;

  /// No description provided for @goldPanelTitle.
  ///
  /// In es, this message translates to:
  /// **'Oro'**
  String get goldPanelTitle;

  /// No description provided for @goldPanelWhat.
  ///
  /// In es, this message translates to:
  /// **'Ganas oro completando lecciones y retos. Sirve para recargar vidas y comprar en la tienda.'**
  String get goldPanelWhat;

  /// No description provided for @goldPanelOpenShop.
  ///
  /// In es, this message translates to:
  /// **'Abrir tienda'**
  String get goldPanelOpenShop;

  /// No description provided for @dailyPanelTitle.
  ///
  /// In es, this message translates to:
  /// **'Meta diaria'**
  String get dailyPanelTitle;

  /// No description provided for @dailyPanelWhat.
  ///
  /// In es, this message translates to:
  /// **'Cuenta el XP que ganas en lecciones y práctica. Cúmplela cada día para mantener tu racha.'**
  String get dailyPanelWhat;

  /// No description provided for @dailyPanelDone.
  ///
  /// In es, this message translates to:
  /// **'¡Meta de hoy cumplida! 🎉 Sigue así para tu racha.'**
  String get dailyPanelDone;

  /// No description provided for @dailyPanelClose.
  ///
  /// In es, this message translates to:
  /// **'Seguir aprendiendo'**
  String get dailyPanelClose;

  /// No description provided for @checkpointStartError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo iniciar el examen. Intenta de nuevo.'**
  String get checkpointStartError;

  /// No description provided for @checkpointPortalTitle.
  ///
  /// In es, this message translates to:
  /// **'El portal de la unidad'**
  String get checkpointPortalTitle;

  /// No description provided for @checkpointCoachMsg.
  ///
  /// In es, this message translates to:
  /// **'🦜  ¡Demuestra lo que sabes!'**
  String get checkpointCoachMsg;

  /// No description provided for @checkpointIntroMsg.
  ///
  /// In es, this message translates to:
  /// **'Supera el portal para abrir la siguiente región del mapa.'**
  String get checkpointIntroMsg;

  /// No description provided for @checkpointStatTimed.
  ///
  /// In es, this message translates to:
  /// **'cronometrado'**
  String get checkpointStatTimed;

  /// No description provided for @checkpointStatPass.
  ///
  /// In es, this message translates to:
  /// **'para pasar'**
  String get checkpointStatPass;

  /// No description provided for @checkpointStatQuestions.
  ///
  /// In es, this message translates to:
  /// **'preguntas'**
  String get checkpointStatQuestions;

  /// No description provided for @checkpointStartCta.
  ///
  /// In es, this message translates to:
  /// **'EMPEZAR CHECKPOINT'**
  String get checkpointStartCta;

  /// No description provided for @checkpointNoCost.
  ///
  /// In es, this message translates to:
  /// **'No cuesta vidas · puedes reintentarlo cuando quieras'**
  String get checkpointNoCost;

  /// No description provided for @checkpointSkillsBreakdown.
  ///
  /// In es, this message translates to:
  /// **'Desglose por habilidad'**
  String get checkpointSkillsBreakdown;

  /// No description provided for @checkpointPassedLabel.
  ///
  /// In es, this message translates to:
  /// **'✓ CHECKPOINT APROBADO'**
  String get checkpointPassedLabel;

  /// No description provided for @checkpointFailedLabel.
  ///
  /// In es, this message translates to:
  /// **'CHECKPOINT NO APROBADO'**
  String get checkpointFailedLabel;

  /// No description provided for @checkpointPassedMsg.
  ///
  /// In es, this message translates to:
  /// **'¡Unidad superada!'**
  String get checkpointPassedMsg;

  /// No description provided for @checkpointFailedMsg.
  ///
  /// In es, this message translates to:
  /// **'Aún no superas el portal'**
  String get checkpointFailedMsg;

  /// No description provided for @checkpointPassedScore.
  ///
  /// In es, this message translates to:
  /// **'{pct}% de aciertos'**
  String checkpointPassedScore(int pct);

  /// No description provided for @checkpointFailedScore.
  ///
  /// In es, this message translates to:
  /// **'{pct}% · necesitas 80%'**
  String checkpointFailedScore(int pct);

  /// No description provided for @checkpointSkillSoon.
  ///
  /// In es, this message translates to:
  /// **'pronto'**
  String get checkpointSkillSoon;

  /// No description provided for @checkpointRegionUnlockedLabel.
  ///
  /// In es, this message translates to:
  /// **'✦ NUEVA REGIÓN DESBLOQUEADA'**
  String get checkpointRegionUnlockedLabel;

  /// No description provided for @checkpointCompleteLabel.
  ///
  /// In es, this message translates to:
  /// **'✓ UNIDAD COMPLETA'**
  String get checkpointCompleteLabel;

  /// No description provided for @checkpointRegionUnlockedMsg.
  ///
  /// In es, this message translates to:
  /// **'¡{unit} completa! Se desbloqueó la siguiente región.'**
  String checkpointRegionUnlockedMsg(String unit);

  /// No description provided for @checkpointCompleteSoonMsg.
  ///
  /// In es, this message translates to:
  /// **'¡{unit} completa! La siguiente región llega pronto.'**
  String checkpointCompleteSoonMsg(String unit);

  /// No description provided for @checkpointContinueJourney.
  ///
  /// In es, this message translates to:
  /// **'CONTINUAR EL VIAJE'**
  String get checkpointContinueJourney;

  /// No description provided for @checkpointRetry.
  ///
  /// In es, this message translates to:
  /// **'REINTENTAR'**
  String get checkpointRetry;

  /// No description provided for @checkpointBackToMap.
  ///
  /// In es, this message translates to:
  /// **'Volver al mapa'**
  String get checkpointBackToMap;

  /// No description provided for @checkpointMissingPoints.
  ///
  /// In es, this message translates to:
  /// **'Te faltaron {missing} puntos para el {pct}%. ¡Casi!'**
  String checkpointMissingPoints(int missing, int pct);

  /// No description provided for @checkpointReinforceTitle.
  ///
  /// In es, this message translates to:
  /// **'REFUERZA ESTAS HABILIDADES'**
  String get checkpointReinforceTitle;

  /// No description provided for @checkpointReinforceEmpty.
  ///
  /// In es, this message translates to:
  /// **'Repasa la unidad y reintenta.'**
  String get checkpointReinforceEmpty;

  /// No description provided for @checkpointSubmitError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo enviar el examen. Intenta de nuevo.'**
  String get checkpointSubmitError;

  /// No description provided for @checkpointExitTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Salir del examen?'**
  String get checkpointExitTitle;

  /// No description provided for @checkpointExitMsg.
  ///
  /// In es, this message translates to:
  /// **'Perderás el progreso de este intento.'**
  String get checkpointExitMsg;

  /// No description provided for @checkpointExitStay.
  ///
  /// In es, this message translates to:
  /// **'Seguir'**
  String get checkpointExitStay;

  /// No description provided for @checkpointLoadErrorTitle.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar el examen'**
  String get checkpointLoadErrorTitle;

  /// No description provided for @checkpointLoadErrorMsg.
  ///
  /// In es, this message translates to:
  /// **'Vuelve al mapa e inténtalo de nuevo en un momento.'**
  String get checkpointLoadErrorMsg;

  /// No description provided for @checkpointBackToMapCta.
  ///
  /// In es, this message translates to:
  /// **'VOLVER AL MAPA'**
  String get checkpointBackToMapCta;

  /// No description provided for @checkpointFinish.
  ///
  /// In es, this message translates to:
  /// **'TERMINAR'**
  String get checkpointFinish;

  /// No description provided for @checkpointNext.
  ///
  /// In es, this message translates to:
  /// **'SIGUIENTE'**
  String get checkpointNext;

  /// No description provided for @lessonPreviewLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar la lección.\n{error}'**
  String lessonPreviewLoadError(String error);

  /// No description provided for @lessonPreviewExerciseCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 ejercicio} other{{count} ejercicios}}'**
  String lessonPreviewExerciseCount(int count);

  /// No description provided for @dailyGoalTitle.
  ///
  /// In es, this message translates to:
  /// **'Meta de hoy'**
  String get dailyGoalTitle;

  /// No description provided for @dailyGoalXpOf.
  ///
  /// In es, this message translates to:
  /// **'{earned}/{goal} XP'**
  String dailyGoalXpOf(int earned, int goal);

  /// No description provided for @dailyGoalMet.
  ///
  /// In es, this message translates to:
  /// **'¡Meta cumplida! Tu racha avanza hoy 🔥'**
  String get dailyGoalMet;

  /// No description provided for @dailyGoalRemaining.
  ///
  /// In es, this message translates to:
  /// **'Te faltan {n} XP para cumplir hoy'**
  String dailyGoalRemaining(int n);

  /// No description provided for @dailyGoalSemantics.
  ///
  /// In es, this message translates to:
  /// **'Meta diaria: {earned} de {goal} XP'**
  String dailyGoalSemantics(int earned, int goal);

  /// No description provided for @missionWelcomeTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Tu viaje ha comenzado!'**
  String get missionWelcomeTitle;

  /// No description provided for @missionWelcomeBody.
  ///
  /// In es, this message translates to:
  /// **'Colecciona las 100 palabras esenciales al avanzar. ¡Vamos!'**
  String get missionWelcomeBody;

  /// No description provided for @missionRewardBanner.
  ///
  /// In es, this message translates to:
  /// **'+{xp} XP · +{gold} oro de bienvenida'**
  String missionRewardBanner(int xp, int gold);

  /// No description provided for @missionStartError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo empezar. Inténtalo de nuevo.'**
  String get missionStartError;

  /// No description provided for @comboLabel.
  ///
  /// In es, this message translates to:
  /// **'x{combo}'**
  String comboLabel(int combo);

  /// No description provided for @shopChestWon.
  ///
  /// In es, this message translates to:
  /// **'🎁 ¡Ganaste {reward} de oro! Ahora tienes {total}.'**
  String shopChestWon(int reward, int total);

  /// No description provided for @shopChestAlready.
  ///
  /// In es, this message translates to:
  /// **'Ya abriste el cofre hoy. Vuelve mañana 🙂'**
  String get shopChestAlready;

  /// No description provided for @shopHeartsRefilled.
  ///
  /// In es, this message translates to:
  /// **'❤️ Vidas recargadas. Gastaste 50 oro, te quedan {gold}.'**
  String shopHeartsRefilled(int gold);

  /// No description provided for @shopFreezeBought.
  ///
  /// In es, this message translates to:
  /// **'🧊 Congelador comprado. Gastaste 50 oro, te quedan {gold}.'**
  String shopFreezeBought(int gold);

  /// No description provided for @shopNotEnoughGold.
  ///
  /// In es, this message translates to:
  /// **'No tienes suficiente oro (cuesta {cost}).'**
  String shopNotEnoughGold(int cost);

  /// No description provided for @leagueNoMovementNote.
  ///
  /// In es, this message translates to:
  /// **'En beta aún no hay ascensos ni descensos: juega para ganar XP y subir en la tabla.'**
  String get leagueNoMovementNote;

  /// No description provided for @mapLoading.
  ///
  /// In es, this message translates to:
  /// **'Cargando tu mapa…'**
  String get mapLoading;

  /// No description provided for @mapLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar el mapa.\n{error}'**
  String mapLoadError(String error);

  /// No description provided for @mapEmptyState.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay contenido sembrado.'**
  String get mapEmptyState;

  /// No description provided for @mapNodeLockedNextUnit.
  ///
  /// In es, this message translates to:
  /// **'Bloqueada · aprueba el checkpoint de la unidad anterior'**
  String get mapNodeLockedNextUnit;

  /// No description provided for @mapNodeLockedNextLesson.
  ///
  /// In es, this message translates to:
  /// **'Bloqueada · completa la lección anterior'**
  String get mapNodeLockedNextLesson;

  /// No description provided for @mapMascotPeak.
  ///
  /// In es, this message translates to:
  /// **'¡A la cima! 💪'**
  String get mapMascotPeak;

  /// No description provided for @mapStartBubble.
  ///
  /// In es, this message translates to:
  /// **'EMPIEZA'**
  String get mapStartBubble;

  /// No description provided for @mapSummitCertLabel.
  ///
  /// In es, this message translates to:
  /// **'TU META · CERTIFICADO'**
  String get mapSummitCertLabel;

  /// No description provided for @mapSummitPeak.
  ///
  /// In es, this message translates to:
  /// **'⛰ LA CIMA'**
  String get mapSummitPeak;

  /// No description provided for @mapUnitBanner.
  ///
  /// In es, this message translates to:
  /// **'UNIDAD {num} · {level}'**
  String mapUnitBanner(int num, String level);

  /// No description provided for @mapUnitBannerLocked.
  ///
  /// In es, this message translates to:
  /// **'UNIDAD {num} · {level} · 🔒 BLOQUEADA'**
  String mapUnitBannerLocked(int num, String level);

  /// No description provided for @mapExamUnit.
  ///
  /// In es, this message translates to:
  /// **'EXAMEN · UNIDAD {num}'**
  String mapExamUnit(int num);

  /// No description provided for @topBarMusicOff.
  ///
  /// In es, this message translates to:
  /// **'Apagar música del mapa'**
  String get topBarMusicOff;

  /// No description provided for @topBarMusicOn.
  ///
  /// In es, this message translates to:
  /// **'Encender música del mapa'**
  String get topBarMusicOn;

  /// No description provided for @topBarNotifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get topBarNotifications;

  /// No description provided for @practiceKicker.
  ///
  /// In es, this message translates to:
  /// **'ENTRENAMIENTO'**
  String get practiceKicker;

  /// No description provided for @practiceTitle.
  ///
  /// In es, this message translates to:
  /// **'Practicar'**
  String get practiceTitle;

  /// No description provided for @practiceHeaderSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Refuerza lo que ya viste y no lo olvides 🧠'**
  String get practiceHeaderSubtitle;

  /// No description provided for @practiceSrsBadge.
  ///
  /// In es, this message translates to:
  /// **'REPASO ESPACIADO'**
  String get practiceSrsBadge;

  /// No description provided for @practiceSrsTitle.
  ///
  /// In es, this message translates to:
  /// **'Rescate de palabras'**
  String get practiceSrsTitle;

  /// No description provided for @practiceSrsWords.
  ///
  /// In es, this message translates to:
  /// **'palabras por repasar'**
  String get practiceSrsWords;

  /// No description provided for @practiceSrsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Antes de que se te olviden'**
  String get practiceSrsSubtitle;

  /// No description provided for @practiceSrsUpToDate.
  ///
  /// In es, this message translates to:
  /// **'¡Vas al día! Nada urgente por repasar'**
  String get practiceSrsUpToDate;

  /// No description provided for @practiceSrsCta.
  ///
  /// In es, this message translates to:
  /// **'Rescatar ahora 🪝'**
  String get practiceSrsCta;

  /// No description provided for @practiceWeakTitle.
  ///
  /// In es, this message translates to:
  /// **'Refuerza tu punto débil'**
  String get practiceWeakTitle;

  /// No description provided for @practiceWeakGeneric.
  ///
  /// In es, this message translates to:
  /// **'Trabaja tu habilidad más floja'**
  String get practiceWeakGeneric;

  /// No description provided for @practicePracticeBtn.
  ///
  /// In es, this message translates to:
  /// **'Practicar'**
  String get practicePracticeBtn;

  /// No description provided for @practiceReinforceTitle.
  ///
  /// In es, this message translates to:
  /// **'Reforzar lo que fallé'**
  String get practiceReinforceTitle;

  /// No description provided for @practiceReinforceSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Re-evalúa solo los ejercicios que erraste'**
  String get practiceReinforceSubtitle;

  /// No description provided for @practiceMoreTitle.
  ///
  /// In es, this message translates to:
  /// **'Más práctica'**
  String get practiceMoreTitle;

  /// No description provided for @practiceReadingHint.
  ///
  /// In es, this message translates to:
  /// **'Comprensión'**
  String get practiceReadingHint;

  /// No description provided for @practiceWritingHint.
  ///
  /// In es, this message translates to:
  /// **'Redacción'**
  String get practiceWritingHint;

  /// No description provided for @practiceRepasoTitle.
  ///
  /// In es, this message translates to:
  /// **'Repaso'**
  String get practiceRepasoTitle;

  /// No description provided for @practiceRepasoSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Conceptos por habilidad'**
  String get practiceRepasoSubtitle;

  /// No description provided for @practiceImmersionTitle.
  ///
  /// In es, this message translates to:
  /// **'Inmersión'**
  String get practiceImmersionTitle;

  /// No description provided for @practiceImmersionSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Historias con audio'**
  String get practiceImmersionSubtitle;

  /// No description provided for @practiceTimedTitle.
  ///
  /// In es, this message translates to:
  /// **'Contrarreloj'**
  String get practiceTimedTitle;

  /// No description provided for @practiceTimedBadge.
  ///
  /// In es, this message translates to:
  /// **'+XP EXTRA'**
  String get practiceTimedBadge;

  /// No description provided for @practiceTimedSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Responde rápido y gana XP extra · 90 s'**
  String get practiceTimedSubtitle;

  /// No description provided for @practiceTimedCta.
  ///
  /// In es, this message translates to:
  /// **'Empezar contrarreloj'**
  String get practiceTimedCta;

  /// No description provided for @practiceXpNote.
  ///
  /// In es, this message translates to:
  /// **'La práctica da un poco menos de XP que una lección nueva. Para ganar más, avanza en el mapa.'**
  String get practiceXpNote;

  /// No description provided for @practiceNothingToReview.
  ///
  /// In es, this message translates to:
  /// **'¡Nada que reforzar ahora! Vas al día. 🎉'**
  String get practiceNothingToReview;

  /// No description provided for @practiceStartError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo iniciar la práctica.'**
  String get practiceStartError;

  /// No description provided for @profileHeaderKicker.
  ///
  /// In es, this message translates to:
  /// **'MI PERFIL'**
  String get profileHeaderKicker;

  /// No description provided for @profileTravelerChip.
  ///
  /// In es, this message translates to:
  /// **'Nivel de viajero {level}'**
  String profileTravelerChip(int level);

  /// No description provided for @profileTravelerNext.
  ///
  /// In es, this message translates to:
  /// **'Nivel {level} · {xp} XP'**
  String profileTravelerNext(int level, int xp);

  /// No description provided for @profileActiveLangLabel.
  ///
  /// In es, this message translates to:
  /// **'IDIOMA ACTIVO'**
  String get profileActiveLangLabel;

  /// No description provided for @profileActiveLangValue.
  ///
  /// In es, this message translates to:
  /// **'{language} · Objetivo {goal}'**
  String profileActiveLangValue(String language, String goal);

  /// No description provided for @profileActiveLangChange.
  ///
  /// In es, this message translates to:
  /// **'Cambiar'**
  String get profileActiveLangChange;

  /// No description provided for @profileRadarGoalTag.
  ///
  /// In es, this message translates to:
  /// **'META {level}'**
  String profileRadarGoalTag(String level);

  /// No description provided for @profileSkillsReadyChip.
  ///
  /// In es, this message translates to:
  /// **'{ready} / 4 en {level}'**
  String profileSkillsReadyChip(int ready, String level);

  /// No description provided for @profileWeakAlertTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu punto débil es'**
  String get profileWeakAlertTitle;

  /// No description provided for @profileWeakAlertBody.
  ///
  /// In es, this message translates to:
  /// **'Súbelo a {level} y certificarás tu nivel completo.'**
  String profileWeakAlertBody(String level);

  /// No description provided for @profileCertLockedNeed.
  ///
  /// In es, this message translates to:
  /// **'Necesitas {level} en las 4 habilidades'**
  String profileCertLockedNeed(String level);

  /// No description provided for @profileCertReadyCount.
  ///
  /// In es, this message translates to:
  /// **'{n} de 4 habilidades listas'**
  String profileCertReadyCount(int n);

  /// No description provided for @profileCertVerifiedLine.
  ///
  /// In es, this message translates to:
  /// **'Verificado · examen Jezici'**
  String get profileCertVerifiedLine;

  /// No description provided for @profileStatsTitle.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas'**
  String get profileStatsTitle;

  /// No description provided for @profileStreakLine.
  ///
  /// In es, this message translates to:
  /// **'{n} días de racha'**
  String profileStreakLine(int n);

  /// No description provided for @profileStreakBest.
  ///
  /// In es, this message translates to:
  /// **'Mejor: {n}'**
  String profileStreakBest(int n);

  /// No description provided for @profileStreakToday.
  ///
  /// In es, this message translates to:
  /// **'HOY'**
  String get profileStreakToday;

  /// No description provided for @profileLeagueRank.
  ///
  /// In es, this message translates to:
  /// **'Puesto {n}'**
  String profileLeagueRank(int n);

  /// No description provided for @leagueCurrentDivision.
  ///
  /// In es, this message translates to:
  /// **'DIVISIÓN ACTUAL'**
  String get leagueCurrentDivision;

  /// No description provided for @leagueEndsIn.
  ///
  /// In es, this message translates to:
  /// **'Termina en'**
  String get leagueEndsIn;

  /// No description provided for @leagueXpThisWeek.
  ///
  /// In es, this message translates to:
  /// **'XP esta semana'**
  String get leagueXpThisWeek;

  /// No description provided for @leaguePromoteTo.
  ///
  /// In es, this message translates to:
  /// **'SUBEN A {division}'**
  String leaguePromoteTo(String division);

  /// No description provided for @leagueDemoteTo.
  ///
  /// In es, this message translates to:
  /// **'BAJAN A {division}'**
  String leagueDemoteTo(String division);

  /// No description provided for @leagueTagUp.
  ///
  /// In es, this message translates to:
  /// **'Sube'**
  String get leagueTagUp;

  /// No description provided for @leagueTagRisk.
  ///
  /// In es, this message translates to:
  /// **'En riesgo'**
  String get leagueTagRisk;

  /// No description provided for @leagueTagYou.
  ///
  /// In es, this message translates to:
  /// **'¡Mantente arriba!'**
  String get leagueTagYou;

  /// No description provided for @leagueMascotCheer.
  ///
  /// In es, this message translates to:
  /// **'¡Sigue subiendo! 💪'**
  String get leagueMascotCheer;

  /// No description provided for @checkpointMapDone.
  ///
  /// In es, this message translates to:
  /// **'UNIDAD ✓'**
  String get checkpointMapDone;

  /// No description provided for @checkpointMapNext.
  ///
  /// In es, this message translates to:
  /// **'SIGUIENTE REGIÓN'**
  String get checkpointMapNext;

  /// No description provided for @checkpointFailCount.
  ///
  /// In es, this message translates to:
  /// **'{n} fallos'**
  String checkpointFailCount(int n);

  /// No description provided for @examPassedBadge.
  ///
  /// In es, this message translates to:
  /// **'EXAMEN SUPERADO'**
  String get examPassedBadge;

  /// No description provided for @examFailedBadge.
  ///
  /// In es, this message translates to:
  /// **'AÚN NO · ¡CASI!'**
  String get examFailedBadge;

  /// No description provided for @examPassedVerdict.
  ///
  /// In es, this message translates to:
  /// **'¡Felicidades! Alcanzaste el'**
  String get examPassedVerdict;

  /// No description provided for @examFailedVerdict.
  ///
  /// In es, this message translates to:
  /// **'Aún no alcanzas el'**
  String get examFailedVerdict;

  /// No description provided for @examLevelWord.
  ///
  /// In es, this message translates to:
  /// **'nivel {level}'**
  String examLevelWord(String level);

  /// No description provided for @examVerifiedBy.
  ///
  /// In es, this message translates to:
  /// **'Verificado por el examen Jezici'**
  String get examVerifiedBy;

  /// No description provided for @examSkillsAtLevel.
  ///
  /// In es, this message translates to:
  /// **'Las 4 habilidades en {level}'**
  String examSkillsAtLevel(String level);

  /// No description provided for @examSkillsWhyCertified.
  ///
  /// In es, this message translates to:
  /// **'Todas alcanzan la meta — por eso se certifica'**
  String get examSkillsWhyCertified;

  /// No description provided for @examSkillsGoalHint.
  ///
  /// In es, this message translates to:
  /// **'Meta: {pct}% por habilidad'**
  String examSkillsGoalHint(int pct);

  /// No description provided for @examGoalTag.
  ///
  /// In es, this message translates to:
  /// **'META {level}'**
  String examGoalTag(String level);

  /// No description provided for @examGlobalScore.
  ///
  /// In es, this message translates to:
  /// **'Puntaje global'**
  String get examGlobalScore;

  /// No description provided for @examStrength.
  ///
  /// In es, this message translates to:
  /// **'Fortaleza'**
  String get examStrength;

  /// No description provided for @examPolish.
  ///
  /// In es, this message translates to:
  /// **'Pulir'**
  String get examPolish;

  /// No description provided for @examSeeCertificate.
  ///
  /// In es, this message translates to:
  /// **'Ver certificado'**
  String get examSeeCertificate;

  /// No description provided for @examShareCopied.
  ///
  /// In es, this message translates to:
  /// **'Resultado copiado para compartir ✓'**
  String get examShareCopied;

  /// No description provided for @examRewards.
  ///
  /// In es, this message translates to:
  /// **'+{xp} XP · +{gold} oro por certificar'**
  String examRewards(int xp, int gold);

  /// No description provided for @examNotYetCertified.
  ///
  /// In es, this message translates to:
  /// **'Aún no certificas {level}'**
  String examNotYetCertified(String level);

  /// No description provided for @examRaiseSkill.
  ///
  /// In es, this message translates to:
  /// **'sube tu {skill}'**
  String examRaiseSkill(String skill);

  /// No description provided for @examReinforceSkill.
  ///
  /// In es, this message translates to:
  /// **'Reforzar {skill}'**
  String examReinforceSkill(String skill);

  /// No description provided for @examRetry.
  ///
  /// In es, this message translates to:
  /// **'REINTENTAR EXAMEN'**
  String get examRetry;

  /// No description provided for @chestTitleClosed.
  ///
  /// In es, this message translates to:
  /// **'¡Un cofre te espera!'**
  String get chestTitleClosed;

  /// No description provided for @chestSubClosed.
  ///
  /// In es, this message translates to:
  /// **'Tócalo para descubrir tu premio'**
  String get chestSubClosed;

  /// No description provided for @chestOpenCta.
  ///
  /// In es, this message translates to:
  /// **'Abrir cofre'**
  String get chestOpenCta;

  /// No description provided for @chestTitleOpened.
  ///
  /// In es, this message translates to:
  /// **'¡+{reward} de oro!'**
  String chestTitleOpened(int reward);

  /// No description provided for @chestSubOpened.
  ///
  /// In es, this message translates to:
  /// **'Tu recompensa del día'**
  String get chestSubOpened;

  /// No description provided for @chestGoldLabel.
  ///
  /// In es, this message translates to:
  /// **'ORO'**
  String get chestGoldLabel;

  /// No description provided for @chestClaimCta.
  ///
  /// In es, this message translates to:
  /// **'¡Reclamar!'**
  String get chestClaimCta;

  /// No description provided for @chestComeBack.
  ///
  /// In es, this message translates to:
  /// **'Vuelve mañana por otro cofre 🎁'**
  String get chestComeBack;

  /// No description provided for @chestTitleTomorrow.
  ///
  /// In es, this message translates to:
  /// **'Ya abriste tu cofre'**
  String get chestTitleTomorrow;

  /// No description provided for @chestSubTomorrow.
  ///
  /// In es, this message translates to:
  /// **'Vuelve mañana por otro 🎁'**
  String get chestSubTomorrow;

  /// No description provided for @chestCloseCta.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get chestCloseCta;

  /// No description provided for @missionAppBarTitle.
  ///
  /// In es, this message translates to:
  /// **'Misión'**
  String get missionAppBarTitle;

  /// No description provided for @missionMainTitle.
  ///
  /// In es, this message translates to:
  /// **'Las 100 palabras esenciales'**
  String get missionMainTitle;

  /// No description provided for @missionMainDescription.
  ///
  /// In es, this message translates to:
  /// **'Tu primer gran objetivo: dominar las 100 palabras y frases de más alta frecuencia del inglés. Las irás coleccionando al completar tus lecciones. Al juntarlas, ganas el badge \"100 esenciales\".'**
  String get missionMainDescription;

  /// No description provided for @missionWordsCount.
  ///
  /// In es, this message translates to:
  /// **'{n} palabras'**
  String missionWordsCount(int n);

  /// No description provided for @missionStartLoading.
  ///
  /// In es, this message translates to:
  /// **'PREPARANDO…'**
  String get missionStartLoading;

  /// No description provided for @missionStartCta.
  ///
  /// In es, this message translates to:
  /// **'¡EMPEZAR MI VIAJE! 🚀'**
  String get missionStartCta;

  /// No description provided for @missionCatGreetings.
  ///
  /// In es, this message translates to:
  /// **'Saludos y cortesía'**
  String get missionCatGreetings;

  /// No description provided for @missionCatPronouns.
  ///
  /// In es, this message translates to:
  /// **'Pronombres y \"to be\"'**
  String get missionCatPronouns;

  /// No description provided for @missionCatVerbs.
  ///
  /// In es, this message translates to:
  /// **'Verbos frecuentes'**
  String get missionCatVerbs;

  /// No description provided for @missionCatNumbers.
  ///
  /// In es, this message translates to:
  /// **'Números 1–20'**
  String get missionCatNumbers;

  /// No description provided for @missionCatFamily.
  ///
  /// In es, this message translates to:
  /// **'Personas y familia'**
  String get missionCatFamily;

  /// No description provided for @missionCatDaily.
  ///
  /// In es, this message translates to:
  /// **'Cotidiano'**
  String get missionCatDaily;

  /// No description provided for @missionCatQuestions.
  ///
  /// In es, this message translates to:
  /// **'Preguntas y útiles'**
  String get missionCatQuestions;

  /// No description provided for @shopTitle.
  ///
  /// In es, this message translates to:
  /// **'Tienda'**
  String get shopTitle;

  /// No description provided for @shopChestCardTitle.
  ///
  /// In es, this message translates to:
  /// **'Cofre diario'**
  String get shopChestCardTitle;

  /// No description provided for @shopChestCardSubtitleAvailable.
  ///
  /// In es, this message translates to:
  /// **'Ábrelo para una recompensa sorpresa'**
  String get shopChestCardSubtitleAvailable;

  /// No description provided for @shopChestCardSubtitleUnavailable.
  ///
  /// In es, this message translates to:
  /// **'Ya lo abriste hoy · vuelve mañana'**
  String get shopChestCardSubtitleUnavailable;

  /// No description provided for @shopChestCardActionOpen.
  ///
  /// In es, this message translates to:
  /// **'ABRIR'**
  String get shopChestCardActionOpen;

  /// No description provided for @shopChestCardActionTomorrow.
  ///
  /// In es, this message translates to:
  /// **'MAÑANA'**
  String get shopChestCardActionTomorrow;

  /// No description provided for @shopHeartsCardTitle.
  ///
  /// In es, this message translates to:
  /// **'Recargar vidas'**
  String get shopHeartsCardTitle;

  /// No description provided for @shopHeartsCardSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Vuelve a 5 corazones · tienes {hearts}'**
  String shopHeartsCardSubtitle(int hearts);

  /// No description provided for @shopFreezeCardTitle.
  ///
  /// In es, this message translates to:
  /// **'Congelador de racha'**
  String get shopFreezeCardTitle;

  /// No description provided for @shopFreezeCardSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Protege tu racha un día · tienes {freezes}'**
  String shopFreezeCardSubtitle(int freezes);

  /// No description provided for @streakTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu racha'**
  String get streakTitle;

  /// No description provided for @streakDaysCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{{count} día de racha} other{{count} días de racha}}'**
  String streakDaysCount(int count);

  /// No description provided for @streakRecord.
  ///
  /// In es, this message translates to:
  /// **'Récord: {longest} · Cumple tu meta diaria para sumar'**
  String streakRecord(int longest);

  /// No description provided for @streakMilestonesTitle.
  ///
  /// In es, this message translates to:
  /// **'Hitos'**
  String get streakMilestonesTitle;

  /// No description provided for @streakMilestonesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Cada hito desbloquea oro de recompensa.'**
  String get streakMilestonesSubtitle;

  /// No description provided for @streakMilestoneReached.
  ///
  /// In es, this message translates to:
  /// **'¡Conseguido!'**
  String get streakMilestoneReached;

  /// No description provided for @streakMilestoneNext.
  ///
  /// In es, this message translates to:
  /// **'Próximo · vas {current}/{days}'**
  String streakMilestoneNext(int current, int days);

  /// No description provided for @streakMilestoneLocked.
  ///
  /// In es, this message translates to:
  /// **'Bloqueado'**
  String get streakMilestoneLocked;

  /// No description provided for @streakFreezeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Protege tu racha un día que no puedas practicar.'**
  String get streakFreezeSubtitle;

  /// No description provided for @streakFreezeCount.
  ///
  /// In es, this message translates to:
  /// **'Tienes {freezes}'**
  String streakFreezeCount(int freezes);

  /// No description provided for @streakFreezePrice.
  ///
  /// In es, this message translates to:
  /// **'Cuesta {cost} oro'**
  String streakFreezePrice(int cost);

  /// No description provided for @streakFreezeBuy.
  ///
  /// In es, this message translates to:
  /// **'Comprar'**
  String get streakFreezeBuy;

  /// No description provided for @leagueTabMyLeague.
  ///
  /// In es, this message translates to:
  /// **'Mi liga'**
  String get leagueTabMyLeague;

  /// No description provided for @leagueTabTables.
  ///
  /// In es, this message translates to:
  /// **'Tablas'**
  String get leagueTabTables;

  /// No description provided for @leagueTitle.
  ///
  /// In es, this message translates to:
  /// **'Liga {division}'**
  String leagueTitle(String division);

  /// No description provided for @leagueWarmingUpSubtitle.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{{count} jugador · arrancando} other{{count} jugadores · arrancando}}'**
  String leagueWarmingUpSubtitle(int count);

  /// No description provided for @leagueRankActive.
  ///
  /// In es, this message translates to:
  /// **'Vas #{rank} esta semana · top {promote} ascienden'**
  String leagueRankActive(int rank, int promote);

  /// No description provided for @leagueRankInactive.
  ///
  /// In es, this message translates to:
  /// **'Vas #{rank} esta semana'**
  String leagueRankInactive(int rank);

  /// No description provided for @leagueWarmingUpTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu liga está arrancando'**
  String get leagueWarmingUpTitle;

  /// No description provided for @leagueWarmingUpMessage.
  ///
  /// In es, this message translates to:
  /// **'Cuando haya al menos {min} jugadores activos, competiréis por ascender. Mientras, suma XP: tu progreso ya cuenta.'**
  String leagueWarmingUpMessage(int min);

  /// No description provided for @leagueWeeklyRankingTitle.
  ///
  /// In es, this message translates to:
  /// **'Clasificación de la semana'**
  String get leagueWeeklyRankingTitle;

  /// No description provided for @leagueWeeklyRankingHint.
  ///
  /// In es, this message translates to:
  /// **'Suma XP (lecciones y práctica) para subir. Cierre cada lunes.'**
  String get leagueWeeklyRankingHint;

  /// No description provided for @leaguePromotionZone.
  ///
  /// In es, this message translates to:
  /// **'ZONA DE ASCENSO'**
  String get leaguePromotionZone;

  /// No description provided for @leagueDemotionZone.
  ///
  /// In es, this message translates to:
  /// **'ZONA DE DESCENSO'**
  String get leagueDemotionZone;

  /// No description provided for @leagueDivisionBronce.
  ///
  /// In es, this message translates to:
  /// **'Bronce'**
  String get leagueDivisionBronce;

  /// No description provided for @leagueDivisionPlata.
  ///
  /// In es, this message translates to:
  /// **'Plata'**
  String get leagueDivisionPlata;

  /// No description provided for @leagueDivisionOro.
  ///
  /// In es, this message translates to:
  /// **'Oro'**
  String get leagueDivisionOro;

  /// No description provided for @leagueDivisionZafiro.
  ///
  /// In es, this message translates to:
  /// **'Zafiro'**
  String get leagueDivisionZafiro;

  /// No description provided for @leagueDivisionRubi.
  ///
  /// In es, this message translates to:
  /// **'Rubí'**
  String get leagueDivisionRubi;

  /// No description provided for @leagueDivisionDiamante.
  ///
  /// In es, this message translates to:
  /// **'Diamante'**
  String get leagueDivisionDiamante;

  /// No description provided for @leaderboardMetricXp.
  ///
  /// In es, this message translates to:
  /// **'XP'**
  String get leaderboardMetricXp;

  /// No description provided for @leaderboardMetricLessons.
  ///
  /// In es, this message translates to:
  /// **'Lecciones'**
  String get leaderboardMetricLessons;

  /// No description provided for @leaderboardMetricStreak.
  ///
  /// In es, this message translates to:
  /// **'Racha'**
  String get leaderboardMetricStreak;

  /// No description provided for @leaderboardMetricCertificates.
  ///
  /// In es, this message translates to:
  /// **'Certificados'**
  String get leaderboardMetricCertificates;

  /// No description provided for @leaderboardUnitLessons.
  ///
  /// In es, this message translates to:
  /// **'lecc.'**
  String get leaderboardUnitLessons;

  /// No description provided for @leaderboardUnitDays.
  ///
  /// In es, this message translates to:
  /// **'d'**
  String get leaderboardUnitDays;

  /// No description provided for @leaderboardUnitCertificates.
  ///
  /// In es, this message translates to:
  /// **'cert.'**
  String get leaderboardUnitCertificates;

  /// No description provided for @leaderboardWindowWeekly.
  ///
  /// In es, this message translates to:
  /// **'Semanal'**
  String get leaderboardWindowWeekly;

  /// No description provided for @leaderboardWindowMonthly.
  ///
  /// In es, this message translates to:
  /// **'Mensual'**
  String get leaderboardWindowMonthly;

  /// No description provided for @leaderboardWindowYearly.
  ///
  /// In es, this message translates to:
  /// **'Anual'**
  String get leaderboardWindowYearly;

  /// No description provided for @leaderboardWindowAlltime.
  ///
  /// In es, this message translates to:
  /// **'Histórico'**
  String get leaderboardWindowAlltime;

  /// No description provided for @leaderboardStreakHint.
  ///
  /// In es, this message translates to:
  /// **'Racha más larga de todos los tiempos.'**
  String get leaderboardStreakHint;

  /// No description provided for @leaderboardScopeGlobal.
  ///
  /// In es, this message translates to:
  /// **'Global'**
  String get leaderboardScopeGlobal;

  /// No description provided for @leaderboardScopeDivision.
  ///
  /// In es, this message translates to:
  /// **'Mi división'**
  String get leaderboardScopeDivision;

  /// No description provided for @leaderboardLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar la tabla.'**
  String get leaderboardLoadError;

  /// No description provided for @leaderboardEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay datos para esta tabla. ¡Sé el primero en aparecer!'**
  String get leaderboardEmpty;

  /// No description provided for @leaderboardMyPosition.
  ///
  /// In es, this message translates to:
  /// **'Tu posición: #{rank} de {total}'**
  String leaderboardMyPosition(int rank, int total);

  /// No description provided for @leaderboardNotRanked.
  ///
  /// In es, this message translates to:
  /// **'Aún no estás en esta tabla'**
  String get leaderboardNotRanked;

  /// No description provided for @leaderboardShowingTop.
  ///
  /// In es, this message translates to:
  /// **'Mostrando top {shown} de {total}'**
  String leaderboardShowingTop(int shown, int total);

  /// No description provided for @leagueLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar la liga.'**
  String get leagueLoadError;

  /// No description provided for @profilePracticeNoWeaknessToday.
  ///
  /// In es, this message translates to:
  /// **'¡Nada que reforzar ahora! Vas al día. 🎉'**
  String get profilePracticeNoWeaknessToday;

  /// No description provided for @profilePracticeWeaknessTitle.
  ///
  /// In es, this message translates to:
  /// **'Refuerzo de debilidades'**
  String get profilePracticeWeaknessTitle;

  /// No description provided for @profilePracticeStartError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo iniciar la práctica.'**
  String get profilePracticeStartError;

  /// No description provided for @profileSkillsTitle.
  ///
  /// In es, this message translates to:
  /// **'Tus 4 habilidades'**
  String get profileSkillsTitle;

  /// No description provided for @profileSkillsDescription.
  ///
  /// In es, this message translates to:
  /// **'Las lecciones suben tu DOMINIO; el nivel sube al aprobar el examen.'**
  String get profileSkillsDescription;

  /// No description provided for @profileSkillImbalanceWarning.
  ///
  /// In es, this message translates to:
  /// **'Tu {skillA} va al {pct1}% pero tu {skillB} al {pct2}% → refuerza {skillB}.'**
  String profileSkillImbalanceWarning(
    String skillA,
    int pct1,
    String skillB,
    int pct2,
  );

  /// No description provided for @profileStatStreak.
  ///
  /// In es, this message translates to:
  /// **'RACHA'**
  String get profileStatStreak;

  /// No description provided for @profileStatXp.
  ///
  /// In es, this message translates to:
  /// **'XP TOTAL'**
  String get profileStatXp;

  /// No description provided for @profileStatGold.
  ///
  /// In es, this message translates to:
  /// **'ORO'**
  String get profileStatGold;

  /// No description provided for @profileNoPlan.
  ///
  /// In es, this message translates to:
  /// **'Crea tu cuenta en el onboarding para ver tu plan.'**
  String get profileNoPlan;

  /// No description provided for @profileCertificatesTitle.
  ///
  /// In es, this message translates to:
  /// **'Certificados'**
  String get profileCertificatesTitle;

  /// No description provided for @profileAchievementsTitle.
  ///
  /// In es, this message translates to:
  /// **'Logros'**
  String get profileAchievementsTitle;

  /// No description provided for @profileNoAchievements.
  ///
  /// In es, this message translates to:
  /// **'Completa lecciones para ganar logros.'**
  String get profileNoAchievements;

  /// No description provided for @profileExamCardTitle.
  ///
  /// In es, this message translates to:
  /// **'Examen de nivel {level}'**
  String profileExamCardTitle(String level);

  /// No description provided for @profileExamCardTitleLocked.
  ///
  /// In es, this message translates to:
  /// **'Examen de nivel {level} (bloqueado)'**
  String profileExamCardTitleLocked(String level);

  /// No description provided for @profileExamReady.
  ///
  /// In es, this message translates to:
  /// **'¡Listo para certificar! Toca para empezar.'**
  String get profileExamReady;

  /// No description provided for @profileExamUnitsRequired.
  ///
  /// In es, this message translates to:
  /// **'Completa las unidades: {done}/{total} checkpoints'**
  String profileExamUnitsRequired(int done, int total);

  /// No description provided for @profileExamMasteryRequired.
  ///
  /// In es, this message translates to:
  /// **'Lleva una habilidad al 80% de dominio para abrir su examen'**
  String get profileExamMasteryRequired;

  /// No description provided for @profileCertificateCardTitle.
  ///
  /// In es, this message translates to:
  /// **'Certificado {level}'**
  String profileCertificateCardTitle(String level);

  /// No description provided for @profileCertificateInfo.
  ///
  /// In es, this message translates to:
  /// **'Folio {folio} · cód. {code}'**
  String profileCertificateInfo(String folio, String code);

  /// No description provided for @profileForYouTitle.
  ///
  /// In es, this message translates to:
  /// **'Para ti'**
  String get profileForYouTitle;

  /// No description provided for @profileWeakestSkill.
  ///
  /// In es, this message translates to:
  /// **'Tu punto débil ahora: {skill} ({level}). Unos minutos lo equilibran.'**
  String profileWeakestSkill(String skill, String level);

  /// No description provided for @profilePracticeWeaknessButton.
  ///
  /// In es, this message translates to:
  /// **'PRACTICAR {skill}'**
  String profilePracticeWeaknessButton(String skill);

  /// No description provided for @profileSkillWeakestBadge.
  ///
  /// In es, this message translates to:
  /// **'más débil'**
  String get profileSkillWeakestBadge;

  /// No description provided for @profileSkillExamReadyBadge.
  ///
  /// In es, this message translates to:
  /// **'examen listo'**
  String get profileSkillExamReadyBadge;

  /// No description provided for @profileMasteryGateCertified.
  ///
  /// In es, this message translates to:
  /// **'Ya certificaste {level} 🎓'**
  String profileMasteryGateCertified(String level);

  /// No description provided for @profileMasteryGateUnlocked.
  ///
  /// In es, this message translates to:
  /// **'Examen {level} desbloqueado 🔓 ({count, plural, =1{1 habilidad} other{{count} habilidades}})'**
  String profileMasteryGateUnlocked(String level, int count);

  /// No description provided for @profileMasteryGateLocked.
  ///
  /// In es, this message translates to:
  /// **'Dominio {level}: lleva una habilidad al 80% para abrir su examen (vas {pct}%)'**
  String profileMasteryGateLocked(String level, int pct);

  /// No description provided for @profilePlanTitle.
  ///
  /// In es, this message translates to:
  /// **'Mi plan'**
  String get profilePlanTitle;

  /// No description provided for @profilePlanOnTrack.
  ///
  /// In es, this message translates to:
  /// **'Justo en tu plan'**
  String get profilePlanOnTrack;

  /// No description provided for @profilePlanAhead.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{Vas 1 día adelante 🎉} other{Vas {n} días adelante 🎉}}'**
  String profilePlanAhead(int n);

  /// No description provided for @profilePlanBehind.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{Vas 1 día atrás} other{Vas {n} días atrás}}'**
  String profilePlanBehind(int n);

  /// No description provided for @profilePlanProgress.
  ///
  /// In es, this message translates to:
  /// **'Avance a {level}'**
  String profilePlanProgress(String level);

  /// No description provided for @profilePlanEstimatedCompletion.
  ///
  /// In es, this message translates to:
  /// **'Llegas aprox. el {date}'**
  String profilePlanEstimatedCompletion(String date);

  /// No description provided for @profilePlanIntensity.
  ///
  /// In es, this message translates to:
  /// **'{mins} min/día · {days} días/semana'**
  String profilePlanIntensity(int mins, int days);

  /// No description provided for @profileNamePlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Pon tu nombre'**
  String get profileNamePlaceholder;

  /// No description provided for @profileMemberSince.
  ///
  /// In es, this message translates to:
  /// **'Miembro desde {date}'**
  String profileMemberSince(String date);

  /// No description provided for @profileNotebookTitle.
  ///
  /// In es, this message translates to:
  /// **'Cuaderno de datos'**
  String get profileNotebookTitle;

  /// No description provided for @profileNotebookSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tips y trucos que has aprendido'**
  String get profileNotebookSubtitle;

  /// No description provided for @profileEditNameError.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu nombre.'**
  String get profileEditNameError;

  /// No description provided for @profileEditSaveError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar. Inténtalo de nuevo.'**
  String get profileEditSaveError;

  /// No description provided for @profileEditNameHint.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo te llamas?'**
  String get profileEditNameHint;

  /// No description provided for @profileEditAvatarColor.
  ///
  /// In es, this message translates to:
  /// **'Color de tu avatar'**
  String get profileEditAvatarColor;

  /// No description provided for @profileEditCountry.
  ///
  /// In es, this message translates to:
  /// **'País'**
  String get profileEditCountry;

  /// No description provided for @profileEditBio.
  ///
  /// In es, this message translates to:
  /// **'Una meta o algo sobre ti (opcional)'**
  String get profileEditBio;

  /// No description provided for @profileEditBioHint.
  ///
  /// In es, this message translates to:
  /// **'Ej.: Quiero viajar por Brasil este año'**
  String get profileEditBioHint;

  /// No description provided for @profileEditSave.
  ///
  /// In es, this message translates to:
  /// **'GUARDAR'**
  String get profileEditSave;

  /// No description provided for @profileEditSaving.
  ///
  /// In es, this message translates to:
  /// **'GUARDANDO…'**
  String get profileEditSaving;

  /// No description provided for @profileLevelPill.
  ///
  /// In es, this message translates to:
  /// **'Nivel {level}'**
  String profileLevelPill(String level);

  /// No description provided for @micUnsupported.
  ///
  /// In es, this message translates to:
  /// **'Tu navegador no soporta reconocimiento de voz. Prueba con Chrome o Edge.'**
  String get micUnsupported;

  /// No description provided for @micDenied.
  ///
  /// In es, this message translates to:
  /// **'El permiso del micrófono está bloqueado. Actívalo en el candado 🔒 junto a la dirección (o en los ajustes del sitio) y reintenta.'**
  String get micDenied;

  /// No description provided for @micNoDevice.
  ///
  /// In es, this message translates to:
  /// **'No se detectó ningún micrófono en este dispositivo.'**
  String get micNoDevice;

  /// No description provided for @micNetwork.
  ///
  /// In es, this message translates to:
  /// **'El servicio de voz no respondió (revisa tu conexión). Vuelve a intentarlo.'**
  String get micNetwork;

  /// No description provided for @onbAdultConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmo que soy mayor de edad'**
  String get onbAdultConfirm;

  /// No description provided for @completeProfileTitle.
  ///
  /// In es, this message translates to:
  /// **'Completa tu perfil'**
  String get completeProfileTitle;

  /// No description provided for @completeProfileSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Solo falta tu nombre y confirmar que eres mayor de edad. Lo demás es opcional y lo puedes editar en tu Perfil.'**
  String get completeProfileSubtitle;

  /// No description provided for @profileEditBirthday.
  ///
  /// In es, this message translates to:
  /// **'Cumpleaños (día y mes, opcional)'**
  String get profileEditBirthday;

  /// No description provided for @profileEditDay.
  ///
  /// In es, this message translates to:
  /// **'Día'**
  String get profileEditDay;

  /// No description provided for @profileEditMonth.
  ///
  /// In es, this message translates to:
  /// **'Mes'**
  String get profileEditMonth;

  /// No description provided for @profileEditGender.
  ///
  /// In es, this message translates to:
  /// **'Género (opcional)'**
  String get profileEditGender;

  /// No description provided for @genderFemale.
  ///
  /// In es, this message translates to:
  /// **'Femenino'**
  String get genderFemale;

  /// No description provided for @genderMale.
  ///
  /// In es, this message translates to:
  /// **'Masculino'**
  String get genderMale;

  /// No description provided for @genderOther.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get genderOther;

  /// No description provided for @genderPreferNot.
  ///
  /// In es, this message translates to:
  /// **'Prefiero no decirlo'**
  String get genderPreferNot;

  /// No description provided for @convKicker.
  ///
  /// In es, this message translates to:
  /// **'COMUNIDAD JEZICI'**
  String get convKicker;

  /// No description provided for @convSpeakingPill.
  ///
  /// In es, this message translates to:
  /// **'Tu Speaking: {level} — súbelo hablando aquí'**
  String convSpeakingPill(String level);
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
