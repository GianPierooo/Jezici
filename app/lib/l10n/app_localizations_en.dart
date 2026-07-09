// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Jezici';

  @override
  String get commonContinue => 'CONTINUE';

  @override
  String get commonStart => 'START';

  @override
  String get commonCheck => 'CHECK';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonBack => 'Back';

  @override
  String get commonExit => 'Exit';

  @override
  String get commonClose => 'Close';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonNext => 'Next';

  @override
  String get commonDone => 'Done';

  @override
  String get splashLoadError => 'We couldn\'t load your session.';

  @override
  String get settingsLanguageTitle => 'App language';

  @override
  String get settingsLanguageSubtitle =>
      'The language of the menus and instructions. It doesn\'t change the language you\'re learning.';

  @override
  String get langEs => 'Español';

  @override
  String get langEn => 'English';

  @override
  String get langPt => 'Português';

  @override
  String get learnLangEn => 'English';

  @override
  String get learnLangPt => 'Portuguese';

  @override
  String get learnLangFr => 'French';

  @override
  String get learnLangIt => 'Italian';

  @override
  String get learnLangDe => 'German';

  @override
  String get learnLangNl => 'Dutch';

  @override
  String get skillReading => 'Reading';

  @override
  String get skillWriting => 'Writing';

  @override
  String get skillListening => 'Listening';

  @override
  String get skillSpeaking => 'Speaking';

  @override
  String get onbWelcomeTitle => 'Let\'s build your plan';

  @override
  String get onbWelcomeSubtitle =>
      'A few quick questions and a placement test to build your plan with a real target date. Every answer personalizes your path.';

  @override
  String get onbWelcomeNote => 'Takes ~2 minutes.';

  @override
  String get onbCoachBubble => 'Let\'s build a plan just for you! 🦜';

  @override
  String get onbLanguageTitle => 'Which language do you prefer for the app?';

  @override
  String get onbLanguageSubtitle =>
      'Choose the language for menus and messages. It\'s not the language you\'ll be learning.';

  @override
  String get onbLanguageInfoEn =>
      'This only changes the language of the menus and text, not what you\'ll learn.';

  @override
  String get onbLanguageInfoPt =>
      'You\'ll be learning Portuguese 🇧🇷. This only changes the app\'s language.';

  @override
  String get onbNameTitle => 'What\'s your name?';

  @override
  String get onbNameSubtitle =>
      'That\'s how we\'ll greet you, and it appears on your profile and certificates.';

  @override
  String get onbNameHint => 'Your name';

  @override
  String get onbTargetTitle => 'Which language do you want to learn?';

  @override
  String get onbTargetSubtitle =>
      'Your course. This defines your plan and placement test. You can change it later in Settings.';

  @override
  String onbMotiveTitle(String course) {
    return 'Why are you learning $course?';
  }

  @override
  String get onbMotiveSubtitle =>
      'Personalizes your plan, the scenarios and your coach\'s messages.';

  @override
  String get onbMotiveWork => 'Work';

  @override
  String get onbMotiveTravel => 'Travel';

  @override
  String get onbMotiveExam => 'Official exam';

  @override
  String get onbMotiveStudies => 'Studies';

  @override
  String get onbMotiveRelocation => 'Relocation';

  @override
  String get onbMotivePleasure => 'For fun';

  @override
  String get onbGoalTitle => 'Where do you want to get to?';

  @override
  String get onbGoalSubtitle => 'Your goal. The top of the map.';

  @override
  String get onbGoalA2 => 'A2 · I get by';

  @override
  String get onbGoalB1 => 'B1 · Independent';

  @override
  String get onbGoalB2 => 'B2 · Fluent conversation';

  @override
  String get onbGoalC1 => 'C1 · Advanced';

  @override
  String get onbDeadlineEmpty => 'Deadline (optional)';

  @override
  String onbDeadlineFilled(int day, int month, int year) {
    return 'Goal: $month/$day/$year';
  }

  @override
  String get onbCommitmentTitle => 'How much time can you give?';

  @override
  String get onbCommitmentSubtitle =>
      'This sets your daily goal and your arrival date.';

  @override
  String get onbCommitmentMinutesLabel => 'Minutes a day';

  @override
  String get onbCommitmentDaysLabel => 'Days a week';

  @override
  String get onbFrequencyRelaxed => 'Relaxed';

  @override
  String get onbFrequencyConstant => 'Steady';

  @override
  String get onbFrequencyIntense => 'Intense';

  @override
  String onbStartLevelTitle(String course) {
    return 'How much $course do you already know?';
  }

  @override
  String get onbStartLevelSubtitle =>
      'So we start the placement test at the right point.';

  @override
  String get onbStartLevelZero => 'From scratch';

  @override
  String get onbStartLevelBasic => 'I know the basics';

  @override
  String get onbStartLevelGood => 'I have a good level';

  @override
  String onbMinutesShort(int m) {
    return '$m min';
  }

  @override
  String onbDaysShort(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '$days day',
    );
    return '$_temp0';
  }

  @override
  String get planDurationLessThanWeek => 'less than a week';

  @override
  String planDurationWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '≈ $count weeks',
      one: '≈ 1 week',
    );
    return '$_temp0';
  }

  @override
  String planDurationMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '≈ $count months',
    );
    return '$_temp0';
  }

  @override
  String planDurationYears(String years) {
    return '≈ $years years';
  }

  @override
  String get onbSaveError => 'We couldn\'t save your plan. Try again.';

  @override
  String get onbPersonalityTitle => 'Your ideal coach';

  @override
  String onbPersonalityStep(int q, int total) {
    return 'Question $q of $total';
  }

  @override
  String get onbPersonalityQ1 =>
      'If you miss your daily goal, what would you rather hear?';

  @override
  String get onbPersonalityQ1Opt1 => '\"No excuses. Get back to it now.\"';

  @override
  String get onbPersonalityQ1Opt2 =>
      '\"Tomorrow you\'ll crush it, you\'ve got this! 💪\"';

  @override
  String get onbPersonalityQ1Opt3 =>
      '\"You\'re falling behind your plan, catch up.\"';

  @override
  String get onbPersonalityQ1Opt4 =>
      '\"No worries, we\'ll continue when you can 🙂\"';

  @override
  String get onbPersonalityQ2 => 'How do you like to be motivated to practice?';

  @override
  String get onbPersonalityQ2Opt1 => 'Firm and direct';

  @override
  String get onbPersonalityQ2Opt2 => 'With energy and celebration';

  @override
  String get onbPersonalityQ2Opt3 => 'By reminding me of my goals and progress';

  @override
  String get onbPersonalityQ2Opt4 => 'Gentle, no pressure';

  @override
  String get onbPersonalityQ3 =>
      'Someone passes you in the league. What fires you up?';

  @override
  String get onbPersonalityQ3Opt1 => 'Challenge me to bounce back';

  @override
  String get onbPersonalityQ3Opt2 => 'Encouragement to climb the ranks';

  @override
  String get onbPersonalityQ3Opt3 => 'Seeing how far I am from catching up';

  @override
  String get onbPersonalityQ3Opt4 => 'Nothing, I go at my own pace';

  @override
  String get onbPersonalityQ4 =>
      'When you achieve something, which message do you enjoy most?';

  @override
  String get onbPersonalityQ4Opt1 => '\"Good. Now the next challenge.\"';

  @override
  String get onbPersonalityQ4Opt2 => '\"Amazing, you\'re unstoppable! 🎉\"';

  @override
  String get onbPersonalityQ4Opt3 => '\"You\'re ahead of your plan.\"';

  @override
  String get onbPersonalityQ4Opt4 => '\"Nice, keep going at your pace 🙂\"';

  @override
  String get onbIntensityQ => 'How often do you want us to remind you?';

  @override
  String get onbIntensityOpt1 => 'A lot, don\'t let me slack';

  @override
  String get onbIntensityOpt2 => 'Just right';

  @override
  String get onbIntensityOpt3 => 'A little';

  @override
  String get placementTitle => 'Placement test';

  @override
  String placementSubtitle(int asked, int max) {
    return 'No hints · question $asked of $max';
  }

  @override
  String placementResultTitle(String level) {
    return 'Your level: $level';
  }

  @override
  String get placementResultSubtitle =>
      'This isn\'t a pass-or-fail exam: it\'s your starting point.';

  @override
  String get placementResultViewPlan => 'SEE MY PLAN';

  @override
  String get placementResultStartFromZero =>
      'I\'d rather start from the beginning';

  @override
  String placementResultStartFromZeroConfirm(String level) {
    return 'You\'ll start from A1 (Unit 1), not $level. It\'s your call: you\'ll progress at your own pace. Continue?';
  }

  @override
  String get placementResultHero => 'WE PLACED YOU AT';

  @override
  String get placementResultSkillsTitle => 'By skill';

  @override
  String placementResultEntryUnit(int unitNum, String unitName, String level) {
    return 'You\'ll start at Unit $unitNum — $unitName ($level). Everything before stays available to review.';
  }

  @override
  String placementResultEstimateReached(
    String goalLevel,
    String humanDuration,
    String formattedDate,
  ) {
    return 'You\'ve already reached your goal. If you keep going to $goalLevel: $humanDuration (approx. $formattedDate).';
  }

  @override
  String placementResultEstimateGoal(
    String goalLevel,
    String humanDuration,
    String formattedDate,
  ) {
    return 'If you stick to your plan, you\'ll reach $goalLevel in $humanDuration (approx. $formattedDate).';
  }

  @override
  String get coursePlacementOfferTitle => 'Take the placement test?';

  @override
  String coursePlacementOfferBody(String course) {
    return 'Take a short test and start at your real $course level instead of from the beginning.';
  }

  @override
  String get coursePlacementDoTest => 'Take the test';

  @override
  String get coursePlacementFromScratch => 'Start from the beginning';

  @override
  String coursePlacementDone(String level) {
    return 'Done! We placed you at $level.';
  }

  @override
  String get planFocusWork => 'Work focus: meetings, emails and interviews.';

  @override
  String get planFocusTravel =>
      'Travel focus: airport, hotel, directions and restaurants.';

  @override
  String get planFocusExam =>
      'Exam focus: IELTS/Cambridge mock tests and the 4 skills.';

  @override
  String get planFocusStudies =>
      'Study focus: comprehension, writing and academic vocabulary.';

  @override
  String get planFocusRelocation =>
      'Relocation focus: paperwork, housing and daily life.';

  @override
  String get planFocusCulture =>
      'Culture focus: series, music and everyday conversation.';

  @override
  String get planReadyTitle => '🎉 Your plan is ready';

  @override
  String get planReadySubtitle =>
      'Stick to your plan and you\'ll get there. Here\'s what it will take.';

  @override
  String get planPreparing => 'PREPARING YOUR MAP…';

  @override
  String get planStartMyPlan => 'START MY PLAN';

  @override
  String get planCompletionLabel => 'YOU\'LL ARRIVE AROUND';

  @override
  String planStatsHours(int hours) {
    return '$hours h';
  }

  @override
  String get planStatsTotalLabel => 'total';

  @override
  String planStatsFrequency(int days) {
    return '× $days days/wk';
  }

  @override
  String get planMaxPace => 'You\'re at top pace! 🔥';

  @override
  String planFasterCta(int minutes) {
    return 'I want to get there faster (up to $minutes min/day)';
  }

  @override
  String planStartUnit(int unitNum, String unitName, String level) {
    return 'You start at Unit $unitNum — $unitName ($level).';
  }

  @override
  String get planBadgeNow => 'NOW';

  @override
  String get planBadgeGoal => 'GOAL';

  @override
  String get planReadyKicker => 'PERSONALIZED FOR YOU';

  @override
  String get planStartJourney => 'Start my journey';

  @override
  String get planJourneyHere => 'YOU\'RE HERE';

  @override
  String get planJourneyGoal => 'YOUR GOAL';

  @override
  String get planHalfTime => '⚡ Half the time!';

  @override
  String planPaceLine(int minutes, String level) {
    return 'With $minutes min/day you reach $level by';
  }

  @override
  String get planLeverTitleOff => 'Want to get there faster?';

  @override
  String get planLeverTitleOn => '🚀 Full speed ahead!';

  @override
  String planLeverTextOff(int minutes) {
    return 'Bump to $minutes min/day and get there in half the time 💪';
  }

  @override
  String planLeverTextOn(int minutes) {
    return '$minutes min/day plan on: you get there in half the time.';
  }

  @override
  String get authTitleSignUp => 'Create your account';

  @override
  String get authTitleSignIn => 'Welcome back';

  @override
  String get authSubtitleSignUp =>
      'A plan with a real date, an exam across the 4 skills, and a coach that brings you back.';

  @override
  String get authSubtitleSignIn => 'Pick up where you left off.';

  @override
  String get authFieldName => 'Your name';

  @override
  String get authFieldEmail => 'Email';

  @override
  String get authFieldPassword => 'Password';

  @override
  String get authSegCreateAccount => 'Sign up';

  @override
  String get authSegSignIn => 'Log in';

  @override
  String get authCtaCreating => 'CREATING…';

  @override
  String get authCtaLoggingIn => 'LOGGING IN…';

  @override
  String get authCtaSignUp => 'SIGN UP';

  @override
  String get authCtaSignIn => 'LOG IN';

  @override
  String get authLegalPrefix => 'I have read and accept the ';

  @override
  String get authLegalTerms => 'Terms';

  @override
  String get authLegalAnd => ' and the ';

  @override
  String get authLegalPrivacy => 'Privacy Policy';

  @override
  String get authLegalSuffix => '.';

  @override
  String get authErrorNameRequired =>
      'Tell us your name to personalize your journey.';

  @override
  String get authErrorEmailPassword =>
      'Enter a valid email and a password of 6+ characters.';

  @override
  String get authErrorTermsRequired =>
      'To create your account, accept the Terms and Privacy Policy.';

  @override
  String get authErrorGeneral => 'Something went wrong. Try again.';

  @override
  String get authErrorDuplicate => 'That email already has an account. Log in.';

  @override
  String get authErrorInvalid => 'Wrong email or password.';

  @override
  String get authErrorPasswordLength => 'The password must be 6+ characters.';

  @override
  String get authErrorFallback => 'We couldn\'t continue. Check your details.';

  @override
  String get authContinueGoogle => 'Continue with Google';

  @override
  String get authOr => 'or';

  @override
  String get authGoogleError =>
      'Couldn\'t continue with Google. Try with your email.';

  @override
  String get authCheckEmail =>
      'We sent you an email to confirm your account. Open it and come back to continue.';

  @override
  String get lessonSaveErrorTitle => 'We couldn\'t save your progress';

  @override
  String get lessonSaveErrorMsg => 'Check your connection and try again.';

  @override
  String get lessonNoExercises => 'This lesson doesn\'t have exercises yet.';

  @override
  String get lessonFeedbackNear => 'Close! 🦜';

  @override
  String get lessonFeedbackCorrect => 'Correct! 🦜';

  @override
  String get lessonFeedbackWrong => 'Not quite 🦜';

  @override
  String lessonFeedbackCorrectForm(String form) {
    return 'The correct form is: $form';
  }

  @override
  String get lessonFeedbackWellDone => 'Well done, keep it up!';

  @override
  String lessonFeedbackRightAnswer(String answer) {
    return 'Correct answer: $answer';
  }

  @override
  String get lessonAudioUnavailableTitle => 'Audio unavailable';

  @override
  String get lessonAudioUnavailableMsg =>
      'This exercise doesn\'t have its audio yet. We\'ll skip it: it won\'t affect your hearts or your score.';

  @override
  String get lessonCompletePerfectTitle => 'PERFECT LESSON';

  @override
  String get lessonCompleteTitle => 'LESSON COMPLETE';

  @override
  String get lessonCompletePerfectMsg => 'Flawless! 🌟';

  @override
  String get lessonCompleteMsg => 'You did it! 🎉';

  @override
  String get lessonCompleteXpLabel => 'XP EARNED';

  @override
  String get lessonCompleteAccuracyLabel => 'ACCURACY';

  @override
  String get lessonCompleteGoldLabel => 'GOLD';

  @override
  String get lessonCompleteComboBonusLabel => 'Combo bonus';

  @override
  String lessonCompleteComboDetail(int bonus, int combo) {
    return '+$bonus XP · x$combo in a row';
  }

  @override
  String lessonCompleteMilestone(int days) {
    return '$days-day milestone! Gold reward unlocked';
  }

  @override
  String lessonCompleteStreakDays(int streak) {
    String _temp0 = intl.Intl.pluralLogic(
      streak,
      locale: localeName,
      other: '🔥 $streak-day streak',
      one: '🔥 $streak-day streak',
    );
    return '$_temp0';
  }

  @override
  String get lessonCompleteStreakAdvanced =>
      '+1 today! You met your daily goal';

  @override
  String get lessonCompleteGoalMet => 'Daily goal met';

  @override
  String get lessonCompleteGoalPending => 'Keep going to meet today\'s goal';

  @override
  String get lessonCompleteFreezeSingle =>
      'Your streak freeze saved your streak';

  @override
  String get lessonCompleteFreezeMulti =>
      'Your streak freezes saved your streak';

  @override
  String get lessonCompleteSkillsUp => 'Skills that leveled up';

  @override
  String tipCardHeader(String type) {
    return 'Matix teaches you · $type';
  }

  @override
  String tipCardPersonalized(String skill) {
    return 'I\'m giving you this because your $skill needs a boost. 🦜';
  }

  @override
  String get errorReviewWhyTranslation =>
      'Watch the exact English form — the full meaning matters.';

  @override
  String get errorReviewWhyCloze =>
      'Review the word that was missing in the sentence.';

  @override
  String get errorReviewWhyWordOrder =>
      'Mind the word ORDER: English is more fixed than Spanish.';

  @override
  String get errorReviewWhyMatch => 'Match each word with its correct pair.';

  @override
  String get errorReviewWhyListening =>
      'Listen again calmly; the sound gives you the clue.';

  @override
  String get errorReviewWhyDefault =>
      'Review it: you\'ll see it again soon in your practice.';

  @override
  String get errorReviewTitle => 'Review what you missed';

  @override
  String errorReviewSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises to reinforce. You\'re almost there!',
      one: '1 exercise to reinforce. You\'re almost there!',
    );
    return '$_temp0';
  }

  @override
  String get errorReviewPracticeCta => 'Practice the ones you missed';

  @override
  String get tileArrangePlaceholder => 'Tap the words to build the sentence…';

  @override
  String get tileArrangeAllPlaced => 'All placed — tap CHECK';

  @override
  String get translationHint => 'Write the translation…';

  @override
  String get clozeHint => 'Type your answer…';

  @override
  String get listeningTapToListen => 'Tap to listen';

  @override
  String get speakingPreparingMic => 'Preparing microphone…';

  @override
  String get speakingNoMic =>
      'Your browser or device doesn\'t allow the microphone.';

  @override
  String get speakingIReadIt => 'I read it ✓';

  @override
  String get speakingManualDone => 'Nice! Keep practicing out loud. 🦜';

  @override
  String get speakingListening => 'Listening…';

  @override
  String get speakingTalk => 'Speak';

  @override
  String get speakingGood => 'Well pronounced! 🦜';

  @override
  String get speakingNoSound => 'I didn\'t hear you — get closer and try again';

  @override
  String get speakingOk => 'You\'re doing well. Read it again if you want';

  @override
  String speakingHeard(String heard) {
    return 'I heard: \"$heard\"';
  }

  @override
  String get speakingVolumeHint =>
      'Turn up the mic volume, or tap \"I read it ✓\" to continue.';

  @override
  String speakingRetryHint(String heard) {
    return 'I heard: \"$heard\". You can try again or tap \"I read it ✓\".';
  }

  @override
  String get speakingHearModel => 'Hear the model';

  @override
  String get audioPlayDefault => 'Listen';

  @override
  String get stubTagPronunciation => 'PRONUNCIATION';

  @override
  String get stubNotePronunciation =>
      'Voice recognition is coming soon. For now, practice it out loud and continue.';

  @override
  String get stubTagListening => 'LISTENING';

  @override
  String get stubNoteListening =>
      'The audio for this exercise is being recorded soon. For now, continue.';

  @override
  String get stubTagDictation => 'DICTATION';

  @override
  String get stubNoteDictation =>
      'Dictation needs audio (recorded soon). For now, continue.';

  @override
  String get stubTagGuidedWriting => 'GUIDED WRITING';

  @override
  String get stubNoteGuidedWriting =>
      'Guided writing with feedback is coming soon. For now, continue.';

  @override
  String get stubTagComingSoon => 'COMING SOON';

  @override
  String get stubNoteComingSoon =>
      'This exercise type is coming soon. For now, continue.';

  @override
  String get noHeartsTitle => 'You\'re out of hearts ❤️';

  @override
  String get noHeartsMsg =>
      'No worries, it happens to everyone! Hearts regenerate over time; if you want to keep going now, refill them with gold.';

  @override
  String get noHeartsRefill => 'Refill hearts and continue';

  @override
  String noHeartsRefillPriced(int gold) {
    return 'Refill lives · 🪙$gold';
  }

  @override
  String get noHeartsInsufficientGold =>
      'You don\'t have enough gold to refill.';

  @override
  String get noHeartsRefilled => 'Lives refilled! ❤️';

  @override
  String get noHeartsQuit => 'Leave the lesson';

  @override
  String get certHolderIntro => 'This certifies that';

  @override
  String get heartsPanelTitle => 'Lives';

  @override
  String get heartsPanelRegen =>
      'They refill on their own over time. You lose a life for each wrong answer.';

  @override
  String get heartsPanelFull => 'You have all your lives! ❤️';

  @override
  String get goldPanelTitle => 'Gold';

  @override
  String get goldPanelWhat =>
      'Earn gold by completing lessons and challenges. Use it to refill lives and buy in the shop.';

  @override
  String get goldPanelOpenShop => 'Open shop';

  @override
  String get dailyPanelTitle => 'Daily goal';

  @override
  String get dailyPanelWhat =>
      'It counts the XP you earn in lessons and practice. Hit it every day to keep your streak.';

  @override
  String get dailyPanelDone =>
      'Today\'s goal done! 🎉 Keep it up for your streak.';

  @override
  String get dailyPanelClose => 'Keep learning';

  @override
  String get checkpointStartError => 'We couldn\'t start the exam. Try again.';

  @override
  String get checkpointPortalTitle => 'The unit portal';

  @override
  String get checkpointCoachMsg => '🦜  Show what you know!';

  @override
  String get checkpointIntroMsg =>
      'Beat the portal to open the next region of the map.';

  @override
  String get checkpointStatTimed => 'timed';

  @override
  String get checkpointStatPass => 'to pass';

  @override
  String get checkpointStatQuestions => 'questions';

  @override
  String get checkpointStartCta => 'START CHECKPOINT';

  @override
  String get checkpointNoCost =>
      'No hearts cost · you can retry whenever you want';

  @override
  String get checkpointSkillsBreakdown => 'Breakdown by skill';

  @override
  String get checkpointPassedLabel => '✓ CHECKPOINT PASSED';

  @override
  String get checkpointFailedLabel => 'CHECKPOINT NOT PASSED';

  @override
  String get checkpointPassedMsg => 'Unit cleared!';

  @override
  String get checkpointFailedMsg => 'You haven\'t beaten the portal yet';

  @override
  String checkpointPassedScore(int pct) {
    return '$pct% correct';
  }

  @override
  String checkpointFailedScore(int pct) {
    return '$pct% · you need 80%';
  }

  @override
  String get checkpointSkillSoon => 'soon';

  @override
  String get checkpointRegionUnlockedLabel => '✦ NEW REGION UNLOCKED';

  @override
  String get checkpointCompleteLabel => '✓ UNIT COMPLETE';

  @override
  String checkpointRegionUnlockedMsg(String unit) {
    return '$unit complete! The next region is unlocked.';
  }

  @override
  String checkpointCompleteSoonMsg(String unit) {
    return '$unit complete! The next region is coming soon.';
  }

  @override
  String get checkpointContinueJourney => 'CONTINUE THE JOURNEY';

  @override
  String get checkpointRetry => 'RETRY';

  @override
  String get checkpointBackToMap => 'Back to the map';

  @override
  String checkpointMissingPoints(int missing, int pct) {
    return 'You were $missing points short of $pct%. So close!';
  }

  @override
  String get checkpointReinforceTitle => 'REINFORCE THESE SKILLS';

  @override
  String get checkpointReinforceEmpty => 'Review the unit and try again.';

  @override
  String get checkpointSubmitError =>
      'We couldn\'t submit the exam. Try again.';

  @override
  String get checkpointExitTitle => 'Leave the exam?';

  @override
  String get checkpointExitMsg => 'You\'ll lose this attempt\'s progress.';

  @override
  String get checkpointExitStay => 'Keep going';

  @override
  String get checkpointLoadErrorTitle => 'We couldn\'t load the exam';

  @override
  String get checkpointLoadErrorMsg =>
      'Go back to the map and try again in a moment.';

  @override
  String get checkpointBackToMapCta => 'BACK TO THE MAP';

  @override
  String get checkpointFinish => 'FINISH';

  @override
  String get checkpointNext => 'NEXT';

  @override
  String lessonPreviewLoadError(String error) {
    return 'We couldn\'t load the lesson.\n$error';
  }

  @override
  String lessonPreviewExerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises',
      one: '1 exercise',
    );
    return '$_temp0';
  }

  @override
  String get dailyGoalTitle => 'Today\'s goal';

  @override
  String dailyGoalXpOf(int earned, int goal) {
    return '$earned/$goal XP';
  }

  @override
  String get dailyGoalMet => 'Goal met! Your streak advances today 🔥';

  @override
  String dailyGoalRemaining(int n) {
    return '$n XP to go today';
  }

  @override
  String dailyGoalSemantics(int earned, int goal) {
    return 'Daily goal: $earned of $goal XP';
  }

  @override
  String get missionWelcomeTitle => 'Your journey has begun!';

  @override
  String get missionWelcomeBody =>
      'Collect the 100 essential words as you go. Let\'s do it!';

  @override
  String missionRewardBanner(int xp, int gold) {
    return '+$xp XP · +$gold gold welcome bonus';
  }

  @override
  String get missionStartError => 'We couldn\'t start. Try again.';

  @override
  String comboLabel(int combo) {
    return 'x$combo';
  }

  @override
  String shopChestWon(int reward, int total) {
    return '🎁 You won $reward gold! You now have $total.';
  }

  @override
  String get shopChestAlready =>
      'You already opened today\'s chest. Come back tomorrow 🙂';

  @override
  String shopHeartsRefilled(int gold) {
    return '❤️ Hearts refilled. You spent 50 gold, $gold left.';
  }

  @override
  String shopFreezeBought(int gold) {
    return '🧊 Streak freeze bought. You spent 50 gold, $gold left.';
  }

  @override
  String shopNotEnoughGold(int cost) {
    return 'You don\'t have enough gold (costs $cost).';
  }

  @override
  String get leagueNoMovementNote =>
      'In beta there are no promotions or demotions yet: play to earn XP and climb the table.';

  @override
  String get mapLoading => 'Loading your map…';

  @override
  String mapLoadError(String error) {
    return 'We couldn\'t load the map.\n$error';
  }

  @override
  String get mapEmptyState => 'No content seeded yet.';

  @override
  String get mapNodeLockedNextUnit =>
      'Locked · pass the previous unit\'s checkpoint';

  @override
  String get mapNodeLockedNextLesson => 'Locked · complete the previous lesson';

  @override
  String get mapMascotPeak => 'To the summit! 💪';

  @override
  String get mapStartBubble => 'START';

  @override
  String get mapSummitCertLabel => 'YOUR GOAL · CERTIFICATE';

  @override
  String get mapSummitPeak => '⛰ THE SUMMIT';

  @override
  String mapUnitBanner(int num, String level) {
    return 'UNIT $num · $level';
  }

  @override
  String mapUnitBannerLocked(int num, String level) {
    return 'UNIT $num · $level · 🔒 LOCKED';
  }

  @override
  String get topBarMusicOff => 'Turn off map music';

  @override
  String get topBarMusicOn => 'Turn on map music';

  @override
  String get topBarNotifications => 'Notifications';

  @override
  String get missionAppBarTitle => 'Mission';

  @override
  String get missionMainTitle => 'The 100 essential words';

  @override
  String get missionMainDescription =>
      'Your first big goal: master the 100 most frequent words and phrases in English. You\'ll collect them as you complete your lessons. Gather them all to earn the \"100 essentials\" badge.';

  @override
  String missionWordsCount(int n) {
    return '$n words';
  }

  @override
  String get missionStartLoading => 'PREPARING…';

  @override
  String get missionStartCta => 'START MY JOURNEY! 🚀';

  @override
  String get missionCatGreetings => 'Greetings and courtesy';

  @override
  String get missionCatPronouns => 'Pronouns and \"to be\"';

  @override
  String get missionCatVerbs => 'Frequent verbs';

  @override
  String get missionCatNumbers => 'Numbers 1–20';

  @override
  String get missionCatFamily => 'People and family';

  @override
  String get missionCatDaily => 'Everyday';

  @override
  String get missionCatQuestions => 'Questions and essentials';

  @override
  String get shopTitle => 'Shop';

  @override
  String get shopChestCardTitle => 'Daily chest';

  @override
  String get shopChestCardSubtitleAvailable => 'Open it for a surprise reward';

  @override
  String get shopChestCardSubtitleUnavailable =>
      'Already opened today · come back tomorrow';

  @override
  String get shopChestCardActionOpen => 'OPEN';

  @override
  String get shopChestCardActionTomorrow => 'TOMORROW';

  @override
  String get shopHeartsCardTitle => 'Refill hearts';

  @override
  String shopHeartsCardSubtitle(int hearts) {
    return 'Back to 5 hearts · you have $hearts';
  }

  @override
  String get shopFreezeCardTitle => 'Streak freeze';

  @override
  String shopFreezeCardSubtitle(int freezes) {
    return 'Protect your streak for a day · you have $freezes';
  }

  @override
  String get streakTitle => 'Your streak';

  @override
  String streakDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-day streak',
      one: '$count-day streak',
    );
    return '$_temp0';
  }

  @override
  String streakRecord(int longest) {
    return 'Record: $longest · Meet your daily goal to add to it';
  }

  @override
  String get streakMilestonesTitle => 'Milestones';

  @override
  String get streakMilestonesSubtitle =>
      'Each milestone unlocks a gold reward.';

  @override
  String get streakMilestoneReached => 'Reached!';

  @override
  String streakMilestoneNext(int current, int days) {
    return 'Next · you\'re at $current/$days';
  }

  @override
  String get streakMilestoneLocked => 'Locked';

  @override
  String get streakFreezeSubtitle =>
      'Protects your streak on a day you can\'t practice.';

  @override
  String streakFreezeCount(int freezes) {
    return 'You have $freezes';
  }

  @override
  String streakFreezePrice(int cost) {
    return 'Costs $cost gold';
  }

  @override
  String get streakFreezeBuy => 'Buy';

  @override
  String get leagueTabMyLeague => 'My league';

  @override
  String get leagueTabTables => 'Tables';

  @override
  String leagueTitle(String division) {
    return '$division League';
  }

  @override
  String leagueWarmingUpSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count players · warming up',
      one: '$count player · warming up',
    );
    return '$_temp0';
  }

  @override
  String leagueRankActive(int rank, int promote) {
    return 'You\'re #$rank this week · top $promote promote';
  }

  @override
  String leagueRankInactive(int rank) {
    return 'You\'re #$rank this week';
  }

  @override
  String get leagueWarmingUpTitle => 'Your league is warming up';

  @override
  String leagueWarmingUpMessage(int min) {
    return 'Once there are at least $min active players, you\'ll compete to move up. Meanwhile, earn XP: your progress already counts.';
  }

  @override
  String get leagueWeeklyRankingTitle => 'This week\'s ranking';

  @override
  String get leagueWeeklyRankingHint =>
      'Earn XP (lessons and practice) to climb. Closes every Monday.';

  @override
  String get leaguePromotionZone => 'PROMOTION ZONE';

  @override
  String get leagueDemotionZone => 'DEMOTION ZONE';

  @override
  String get leagueDivisionBronce => 'Bronze';

  @override
  String get leagueDivisionPlata => 'Silver';

  @override
  String get leagueDivisionOro => 'Gold';

  @override
  String get leagueDivisionZafiro => 'Sapphire';

  @override
  String get leagueDivisionRubi => 'Ruby';

  @override
  String get leagueDivisionDiamante => 'Diamond';

  @override
  String get leaderboardMetricXp => 'XP';

  @override
  String get leaderboardMetricLessons => 'Lessons';

  @override
  String get leaderboardMetricStreak => 'Streak';

  @override
  String get leaderboardMetricCertificates => 'Certificates';

  @override
  String get leaderboardUnitLessons => 'less.';

  @override
  String get leaderboardUnitDays => 'd';

  @override
  String get leaderboardUnitCertificates => 'cert.';

  @override
  String get leaderboardWindowWeekly => 'Weekly';

  @override
  String get leaderboardWindowMonthly => 'Monthly';

  @override
  String get leaderboardWindowYearly => 'Yearly';

  @override
  String get leaderboardWindowAlltime => 'All-time';

  @override
  String get leaderboardStreakHint => 'Longest streak of all time.';

  @override
  String get leaderboardScopeGlobal => 'Global';

  @override
  String get leaderboardScopeDivision => 'My division';

  @override
  String get leaderboardLoadError => 'We couldn\'t load the table.';

  @override
  String get leaderboardEmpty =>
      'No data for this table yet. Be the first to show up!';

  @override
  String leaderboardMyPosition(int rank, int total) {
    return 'Your position: #$rank of $total';
  }

  @override
  String get leaderboardNotRanked => 'You\'re not on this table yet';

  @override
  String leaderboardShowingTop(int shown, int total) {
    return 'Showing top $shown of $total';
  }

  @override
  String get leagueLoadError => 'We couldn\'t load the league.';

  @override
  String get profilePracticeNoWeaknessToday =>
      'Nothing to reinforce right now! You\'re up to date. 🎉';

  @override
  String get profilePracticeWeaknessTitle => 'Weakness practice';

  @override
  String get profilePracticeStartError => 'We couldn\'t start practice.';

  @override
  String get profileSkillsTitle => 'Your 4 skills';

  @override
  String get profileSkillsDescription =>
      'Lessons raise your MASTERY; your level goes up when you pass the exam.';

  @override
  String profileSkillImbalanceWarning(
    String skillA,
    int pct1,
    String skillB,
    int pct2,
  ) {
    return 'Your $skillA is at $pct1% but your $skillB at $pct2% → reinforce $skillB.';
  }

  @override
  String get profileStatStreak => 'STREAK';

  @override
  String get profileStatXp => 'TOTAL XP';

  @override
  String get profileStatGold => 'GOLD';

  @override
  String get profileNoPlan =>
      'Create your account in onboarding to see your plan.';

  @override
  String get profileCertificatesTitle => 'Certificates';

  @override
  String get profileAchievementsTitle => 'Achievements';

  @override
  String get profileNoAchievements => 'Complete lessons to earn achievements.';

  @override
  String profileExamCardTitle(String level) {
    return '$level level exam';
  }

  @override
  String profileExamCardTitleLocked(String level) {
    return '$level level exam (locked)';
  }

  @override
  String get profileExamReady => 'Ready to certify! Tap to start.';

  @override
  String profileExamUnitsRequired(int done, int total) {
    return 'Complete the units: $done/$total checkpoints';
  }

  @override
  String get profileExamMasteryRequired =>
      'Take one skill to 80% mastery to open its exam';

  @override
  String profileCertificateCardTitle(String level) {
    return '$level Certificate';
  }

  @override
  String profileCertificateInfo(String folio, String code) {
    return 'Folio $folio · code $code';
  }

  @override
  String get profileForYouTitle => 'For you';

  @override
  String profileWeakestSkill(String skill, String level) {
    return 'Your weak spot right now: $skill ($level). A few minutes will balance it.';
  }

  @override
  String profilePracticeWeaknessButton(String skill) {
    return 'PRACTICE $skill';
  }

  @override
  String get profileSkillWeakestBadge => 'weakest';

  @override
  String get profileSkillExamReadyBadge => 'exam ready';

  @override
  String profileMasteryGateCertified(String level) {
    return 'You already certified $level 🎓';
  }

  @override
  String profileMasteryGateUnlocked(String level, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count skills',
      one: '1 skill',
    );
    return '$level exam unlocked 🔓 ($_temp0)';
  }

  @override
  String profileMasteryGateLocked(String level, int pct) {
    return '$level mastery: take one skill to 80% to open its exam (you\'re at $pct%)';
  }

  @override
  String get profilePlanTitle => 'My plan';

  @override
  String get profilePlanOnTrack => 'Right on your plan';

  @override
  String profilePlanAhead(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'You\'re $n days ahead 🎉',
      one: 'You\'re 1 day ahead 🎉',
    );
    return '$_temp0';
  }

  @override
  String profilePlanBehind(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'You\'re $n days behind',
      one: 'You\'re 1 day behind',
    );
    return '$_temp0';
  }

  @override
  String profilePlanProgress(String level) {
    return 'Progress to $level';
  }

  @override
  String profilePlanEstimatedCompletion(String date) {
    return 'You\'ll arrive around $date';
  }

  @override
  String profilePlanIntensity(int mins, int days) {
    return '$mins min/day · $days days/week';
  }

  @override
  String get profileNamePlaceholder => 'Set your name';

  @override
  String profileMemberSince(String date) {
    return 'Member since $date';
  }

  @override
  String get profileNotebookTitle => 'Notebook';

  @override
  String get profileNotebookSubtitle => 'Tips and tricks you\'ve learned';

  @override
  String get profileEditNameError => 'Enter your name.';

  @override
  String get profileEditSaveError => 'We couldn\'t save. Try again.';

  @override
  String get profileEditNameHint => 'What\'s your name?';

  @override
  String get profileEditAvatarColor => 'Your avatar color';

  @override
  String get profileEditCountry => 'Country';

  @override
  String get profileEditBio => 'A goal or something about you (optional)';

  @override
  String get profileEditBioHint =>
      'e.g. I want to travel around Brazil this year';

  @override
  String get profileEditSave => 'SAVE';

  @override
  String get profileEditSaving => 'SAVING…';

  @override
  String profileLevelPill(String level) {
    return 'Level $level';
  }
}
