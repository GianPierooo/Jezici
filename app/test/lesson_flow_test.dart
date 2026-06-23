import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jezici/data/models/checkpoint_models.dart';
import 'package:jezici/data/models/content_item_model.dart';
import 'package:jezici/data/models/course_models.dart';
import 'package:jezici/data/models/profile_models.dart';
import 'package:jezici/data/models/tip_models.dart';
import 'package:jezici/data/models/achievement_models.dart';
import 'package:jezici/data/models/league_models.dart';
import 'package:jezici/data/models/lesson_model.dart';
import 'package:jezici/data/models/level_exam_models.dart';
import 'package:jezici/data/models/shop_models.dart';
import 'package:jezici/data/models/practice_models.dart';
import 'package:jezici/data/models/progress_models.dart';
import 'package:jezici/data/providers.dart';
import 'package:jezici/data/repositories/progress_repository.dart';
import 'package:jezici/features/lesson/grading/grader.dart' as grd;
import 'package:jezici/features/lesson/lesson_player_screen.dart';
import 'package:jezici/features/leagues/leagues_screen.dart';

/// Repo falso (implements, sin SupabaseClient → sin red ni timers).
class FakeProgressRepository implements ProgressRepository {
  FakeProgressRepository({this.gradeItems = const []});
  // Ítems para calificar localmente (simula grade_item del servidor, mig 055).
  final List<ContentItemModel> gradeItems;
  @override
  bool get isSignedIn => true;
  @override
  Future<void> ensureSignedIn() async {}
  @override
  Future<void> startCourse() async {}
  @override
  Future<void> completeMission(String lessonId) async {}
  @override
  Future<Map<String, String>> fetchLessonProgress() async => {};
  @override
  Future<HomeStats> fetchHomeStats() async => HomeStats.empty;
  @override
  Future<List<SkillLevel>> fetchSkills() async => const [];
  @override
  Future<({bool correct, bool graded, Map<String, dynamic> expected})> gradeItem(
      String itemId, Object? answer) async {
    ContentItemModel? item;
    for (final i in gradeItems) {
      if (i.id == itemId) {
        item = i;
        break;
      }
    }
    if (item == null) return (correct: true, graded: true, expected: const <String, dynamic>{});
    // El player envía el answer ya serializado (match: claves String, como al RPC).
    // El grader local usa claves int → las reconvertimos (el servidor jz_grade usa
    // claves String directamente).
    Object? a = answer;
    if (answer is Map) {
      a = {for (final e in answer.entries) (int.tryParse('${e.key}') ?? e.key): e.value};
    }
    final r = grd.gradeItem(item, a); // matcher local (espejo de jz_grade)
    return (correct: r.correct, graded: r.graded, expected: item.correctAnswer);
  }
  @override
  Future<List<CourseInfo>> fetchCourses() async => const [];
  @override
  Future<void> setActiveCourse(String courseId) async {}
  @override
  Future<TipModel?> getLessonTip(String lessonId) async => null;
  @override
  Future<List<TipModel>> getNotebook() async => const [];
  @override
  Future<ProfileInfo> fetchProfile() async => ProfileInfo.empty;
  @override
  Future<ProfileInfo> setProfile(
          {String? name, String? country, String? bio, String? avatarColor}) async =>
      ProfileInfo.empty;
  @override
  Future<void> signUpEmail(String email, String password) async {}
  @override
  Future<void> signInEmail(String email, String password) async {}
  @override
  Future<bool> isOnboardingComplete() async => true;
  @override
  Future<UserPlan?> fetchPlan() async => null;
  @override
  Future<PlanTracking> fetchPlanTracking() async => PlanTracking.empty;
  @override
  Future<Map<String, dynamic>> updatePlanPace(int dailyMinutes) async => {'ok': true};
  @override
  Future<Map<String, dynamic>> useStreakFreeze() async => {'ok': true, 'gold': 0};
  @override
  Future<ShopStatus> fetchShopStatus() async => ShopStatus.empty;
  @override
  Future<Map<String, dynamic>> openDailyChest() async => {'ok': true, 'reward': 20};
  @override
  Future<Map<String, dynamic>> buyHearts() async => {'ok': true, 'hearts': 5};
  @override
  Future<void> signOut() async {}
  @override
  Future<void> deleteAccount() async {}
  @override
  Future<Map<String, dynamic>> exportMyData() async => const {};
  @override
  Future<void> logEvent(String event, {Map<String, dynamic>? props}) async {}
  @override
  Future<Map<String, dynamic>> fetchMetrics() async => const {};
  @override
  Future<Map<String, dynamic>> fetchOnboardingFunnel() async => const {'steps': [], 'started': 0, 'completed': 0, 'completion_rate': 0};
  @override
  Future<Map<String, dynamic>> fetchEngagement() async => const {};
  @override
  Future<void> submitFeedback({required String screen, required String kind, required String message, String? appVersion, String? platform}) async {}
  @override
  Future<void> saveConversationAttempt({required String topic, required String mode, String? content, int? selfScore}) async {}
  @override
  Future<bool> logConversarInterest(bool wouldUse, String? topics) async => true;
  @override
  Future<UserSettings> fetchSettings() async => UserSettings.fallback;
  @override
  Future<void> updateSettings({
    required String coachStyle,
    required int intensity,
    String? quietStart,
    String? quietEnd,
    int? dailyMinutes,
    required bool pushEnabled,
  }) async {}
  @override
  Future<MatixResult> matixFire(String trigger) async => MatixResult.fromJson(const {});
  @override
  Future<List<NotificationItem>> fetchNotifications() async => const [];
  @override
  Future<PracticeSession> startPractice(String mode, {String? skill, String? unit}) async =>
      const PracticeSession(mode: 'srs', items: []);
  @override
  Future<SkillMasteryStatus> fetchSkillMastery() async => SkillMasteryStatus.empty;
  @override
  Future<PracticeSummary> submitPractice(String mode, List<Map<String, dynamic>> answers) async =>
      PracticeSummary.fromJson(const {});
  @override
  Future<PracticeStatus> fetchPracticeStatus() async => PracticeStatus.empty;
  @override
  Future<List<Achievement>> fetchAchievements() async => const [];
  @override
  Future<List<Certificate>> fetchCertificates() async => const [];
  @override
  Future<LeagueStanding> fetchLeague() async =>
      const LeagueStanding(division: 'bronce', myRank: 1, promote: 5, demote: 5, members: []);
  @override
  Future<LeaderboardResult> fetchLeaderboard({
    required String metric,
    required String window,
    required String scope,
    int limit = 50,
    int offset = 0,
  }) async =>
      LeaderboardResult(
          metric: metric, window: window, scope: scope, total: 0, myRank: null, myValue: 0, entries: const []);
  @override
  Future<LevelExamStatus> fetchLevelExamStatus() async => LevelExamStatus.empty;
  @override
  Future<CheckpointStartData> startLevelExam() async => const CheckpointStartData(
      examId: 'x', timeLimitSec: 600, passThreshold: 0.8, itemCount: 0, items: []);
  @override
  Future<LevelExamResult> submitLevelExam(
          List<Map<String, dynamic>> answers, int timeTakenSec) async =>
      LevelExamResult.fromJson(const {});
  @override
  Future<void> createPlan({
    required String coachStyle,
    required int intensity,
    required String currentLevel,
    required String goalLevel,
    required int dailyMinutes,
    required int daysPerWeek,
    required String motive,
    String? deadline,
    required int estimatedHours,
    required String estimatedCompletion,
    required Map<String, String> skillLevels,
  }) async {}
  @override
  Future<CheckpointStartData> startCheckpoint(String lessonId) async =>
      const CheckpointStartData(
          examId: 'x', timeLimitSec: 300, passThreshold: 0.8, itemCount: 0, items: []);
  @override
  Future<CheckpointResult> submitCheckpoint(
          String lessonId, List<Map<String, dynamic>> answers, int timeTakenSec) async =>
      const CheckpointResult(
          passed: true,
          scoreGlobal: 1.0,
          threshold: 0.8,
          attemptNumber: 1,
          graded: 6,
          correct: 6,
          xpEarned: 40,
          goldEarned: 30,
          perSkill: [],
          weaknesses: [],
          nextUnlocked: false);

  @override
  Future<LessonSummary> completeLesson(
      String lessonId, List<Map<String, dynamic>> answers) async {
    return const LessonSummary(
      xpEarned: 23,
      goldEarned: 10,
      accuracy: 1.0,
      graded: 6,
      comboBonus: 8,
      maxCombo: 6,
      status: 'golden',
      streak: 1,
      skillsUp: ['reading', 'writing', 'listening', 'speaking'],
    );
  }
}

/// Captura los answers enviados a complete_lesson para verificar omisiones.
class CapturingFakeRepository extends FakeProgressRepository {
  CapturingFakeRepository({super.gradeItems});
  List<Map<String, dynamic>>? lastAnswers;
  @override
  Future<LessonSummary> completeLesson(
      String lessonId, List<Map<String, dynamic>> answers) async {
    lastAnswers = answers;
    return super.completeLesson(lessonId, answers);
  }
}

/// Fake con un leaderboard de muestra para la vista "Tablas".
class LeaderboardFakeRepository extends FakeProgressRepository {
  @override
  Future<LeaderboardResult> fetchLeaderboard({
    required String metric,
    required String window,
    required String scope,
    int limit = 50,
    int offset = 0,
  }) async =>
      LeaderboardResult(
        metric: metric,
        window: window,
        scope: scope,
        total: 3,
        myRank: 2,
        myValue: 120,
        entries: const [
          LeaderboardEntry(rank: 1, name: 'Sofía', value: 300, isMe: false),
          LeaderboardEntry(rank: 2, name: 'Tú', value: 120, isMe: true),
          LeaderboardEntry(rank: 3, name: 'Marco', value: 90, isMe: false),
        ],
      );
}

Widget _wrap(Widget child, {List<ContentItemModel> items = const []}) => ProviderScope(
      overrides: [
        progressRepositoryProvider
            .overrideWithValue(FakeProgressRepository(gradeItems: items)),
      ],
      child: MaterialApp(home: child),
    );

Widget _wrapRepo(Widget child, ProgressRepository repo) => ProviderScope(
      overrides: [progressRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(home: child),
    );

List<ContentItemModel> _unit1Lesson1Items() => [
      ContentItemModel(
        id: 'e1',
        type: ContentItemType.match,
        skill: 'reading',
        cefrLevel: 'A1',
        prompt: 'Empareja cada palabra con su traducción.',
        payload: {
          'pairs': [
            {'en': 'hello', 'es': 'hola'},
            {'en': 'goodbye', 'es': 'adiós'},
            {'en': 'good morning', 'es': 'buenos días'},
          ]
        },
        correctAnswer: {
          'pairs': [
            ['hello', 'hola'],
            ['goodbye', 'adiós'],
            ['good morning', 'buenos días'],
          ]
        },
      ),
      ContentItemModel(
        id: 'e2',
        type: ContentItemType.multipleChoice,
        skill: 'reading',
        cefrLevel: 'A1',
        prompt: 'Como se dice hola',
        payload: {'options': ['hello', 'goodbye', 'please']},
        correctAnswer: {'value': 'hello'},
      ),
      ContentItemModel(
        id: 'e3',
        type: ContentItemType.multipleChoice,
        skill: 'reading',
        cefrLevel: 'A1',
        prompt: 'Good morning significa',
        payload: {'options': ['buenas noches', 'buenos dias', 'adios']},
        correctAnswer: {'value': 'buenos dias'},
      ),
      ContentItemModel(
        id: 'e4',
        type: ContentItemType.listening, // STUB
        skill: 'listening',
        cefrLevel: 'A1',
        prompt: 'Escucha y elige',
        payload: {'audio_url': 'a.mp3', 'options': ['Hello', 'Goodbye']},
        correctAnswer: {'value': 'Goodbye'},
      ),
      ContentItemModel(
        id: 'e5',
        type: ContentItemType.wordBank,
        skill: 'writing',
        cefrLevel: 'A1',
        prompt: 'Arma la frase',
        payload: {'tiles': ['Good', 'morning', 'night', 'evening']},
        correctAnswer: {'value': 'Good morning', 'sequence': ['Good', 'morning']},
      ),
      ContentItemModel(
        id: 'e6',
        type: ContentItemType.translation,
        skill: 'writing',
        cefrLevel: 'A1',
        prompt: 'Traduce',
        payload: {'source': 'Adios'},
        correctAnswer: {'value': 'Goodbye', 'accepted': ['goodbye', 'bye']},
      ),
      ContentItemModel(
        id: 'e7',
        type: ContentItemType.multipleChoice,
        skill: 'reading',
        cefrLevel: 'A1',
        prompt: 'Para despedirte de noche',
        payload: {'options': ['Good morning', 'Good night', 'Hello']},
        correctAnswer: {'value': 'Good night'},
      ),
      ContentItemModel(
        id: 'e8',
        type: ContentItemType.speakingReadAloud, // STUB
        skill: 'speaking',
        cefrLevel: 'A1',
        prompt: 'Lee en voz alta',
        payload: {'text': 'Hello! Good morning!'},
        correctAnswer: {'expected': 'Hello! Good morning!'},
      ),
    ];

void main() {
  const lesson = LessonModel(
    id: 'l1',
    unitId: 'u1',
    orderIndex: 1,
    title: 'Saludos básicos',
    type: LessonType.lesson,
    xpReward: 15,
  );

  testWidgets('Lección 1.1 se completa de inicio a fin (resumen del servidor)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(440, 950);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final items1 = _unit1Lesson1Items();
    await tester.pumpWidget(
      _wrap(LessonPlayerScreen(lesson: lesson, items: items1), items: items1),
    );
    await tester.pumpAndSettle();

    Future<void> tap(String text) async {
      await tester.tap(find.text(text).first);
      await tester.pumpAndSettle();
    }

    // E1 match.
    await tap('hello');
    await tap('hola');
    await tap('goodbye');
    await tap('adiós');
    await tap('good morning');
    await tap('buenos días');
    await tap('COMPROBAR');
    expect(find.text('¡Correcto! 🦜'), findsOneWidget);
    await tap('CONTINUAR');

    // E2.
    await tap('hello');
    await tap('COMPROBAR');
    await tap('CONTINUAR');

    // E3.
    await tap('buenos dias');
    await tap('COMPROBAR');
    await tap('CONTINUAR');

    // E4 listening → ahora jugable (audio real + opción correcta).
    await tap('Goodbye');
    await tap('COMPROBAR');
    await tap('CONTINUAR');

    // E5 word_bank.
    await tap('Good');
    await tap('morning');
    await tap('COMPROBAR');
    await tap('CONTINUAR');

    // E6 translation.
    await tester.enterText(find.byType(TextField), 'Goodbye');
    await tester.pumpAndSettle();
    await tap('COMPROBAR');
    await tap('CONTINUAR');

    // E7.
    await tap('Good night');
    await tap('COMPROBAR');
    await tap('CONTINUAR');

    // E8 speaking → STUB. Último ítem → llama complete_lesson (fake) y navega.
    await tester.tap(find.text('CONTINUAR').first);
    await tester.pump(); // diálogo de carga
    await tester.pump(const Duration(milliseconds: 120)); // resuelve el fake
    await tester.pump(); // navega a la pantalla de fin
    await tester.pump(const Duration(milliseconds: 400)); // sin settle: confeti infinito

    // Pantalla de fin con el resumen del servidor (perfecto → golden).
    expect(find.text('¡Impecable! 🌟'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets('Una respuesta incorrecta resta una vida y muestra la corrección',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(440, 950);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final items = [
      ContentItemModel(
        id: 'w1',
        type: ContentItemType.multipleChoice,
        skill: 'reading',
        cefrLevel: 'A1',
        prompt: 'Elige',
        payload: {'options': ['hello', 'goodbye']},
        correctAnswer: {'value': 'hello'},
      ),
    ];

    await tester.pumpWidget(_wrap(LessonPlayerScreen(lesson: lesson, items: items), items: items));
    await tester.pumpAndSettle();

    expect(find.text('5'), findsOneWidget);

    await tester.tap(find.text('goodbye'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('COMPROBAR'));
    await tester.pumpAndSettle();

    expect(find.text('Casi… 🦜'), findsOneWidget);
    expect(find.textContaining('Respuesta correcta'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('Listening sin audio se salta sin perder vidas y se omite del envío',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(440, 950);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final items = [
      ContentItemModel(
        id: 'm1',
        type: ContentItemType.multipleChoice,
        skill: 'reading',
        cefrLevel: 'B1',
        prompt: 'Elige',
        payload: {'options': ['hello', 'goodbye']},
        correctAnswer: {'value': 'hello'},
      ),
      ContentItemModel(
        id: 'lis-missing',
        type: ContentItemType.listening,
        skill: 'listening',
        cefrLevel: 'B1',
        prompt: 'Escucha y elige lo que oíste.',
        payload: {
          'audio_url': 'https://example.test/audio/items/lis-missing.mp3',
          'options': ['Have you ever met someone famous?', 'Did you meet someone famous?'],
        },
        correctAnswer: {'value': 'Have you ever met someone famous?'},
      ),
    ];

    final repo = CapturingFakeRepository(gradeItems: items);
    await tester.pumpWidget(
      _wrapRepo(
        LessonPlayerScreen(
          lesson: lesson,
          items: items,
          // Sonda inyectada: el audio del listening NO existe.
          audioProbe: (url) async => !url.contains('lis-missing'),
        ),
        repo,
      ),
    );
    await tester.pumpAndSettle();

    // E1 MC correcto.
    await tester.tap(find.text('hello'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('COMPROBAR'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CONTINUAR'));
    await tester.pumpAndSettle();

    // E2 listening: audio inexistente → aviso y NO se piden opciones a ciegas.
    expect(find.text('Audio no disponible'), findsOneWidget);
    expect(find.text('Have you ever met someone famous?'), findsNothing);
    expect(find.text('5'), findsOneWidget); // vidas intactas

    // Continuar (último ítem) → complete_lesson.
    await tester.tap(find.text('CONTINUAR').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // El listening sin audio se OMITE del envío (solo va el MC).
    expect(repo.lastAnswers, isNotNull);
    expect(repo.lastAnswers!.length, 1);
    expect(repo.lastAnswers!.single['item_id'], 'm1');
  });

  test('LeaderboardResult.fromJson parsea entries sin user_id', () {
    final r = LeaderboardResult.fromJson(const {
      'metric': 'xp', 'window': 'monthly', 'scope': 'global',
      'total': 2, 'my_rank': 1, 'my_value': 500,
      'entries': [
        {'rank': 1, 'name': 'Tú', 'value': 500, 'is_me': true},
        {'rank': 2, 'name': 'Ana', 'value': 200, 'is_me': false},
      ],
    });
    expect(r.metric, 'xp');
    expect(r.window, 'monthly');
    expect(r.myRank, 1);
    expect(r.entries.length, 2);
    expect(r.entries.first.isMe, true);
    expect(r.entries[1].name, 'Ana');
  });

  testWidgets('Tablas (leaderboards) renderiza ranking y tu posición',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(440, 950);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_wrapRepo(const LeaguesScreen(), LeaderboardFakeRepository()));
    await tester.pumpAndSettle();

    // Cambia al segmento "Tablas".
    await tester.tap(find.text('Tablas'));
    await tester.pumpAndSettle();

    // Filas del leaderboard + "tu posición".
    expect(find.text('Sofía'), findsOneWidget);
    expect(find.text('Marco'), findsOneWidget);
    expect(find.text('300 XP'), findsOneWidget);
    expect(find.textContaining('Tu posición: #2'), findsOneWidget);
  });
}
