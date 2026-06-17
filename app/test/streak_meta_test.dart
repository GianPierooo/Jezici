import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/data/models/progress_models.dart';

void main() {
  test('HomeStats.dailyGoalMet y dailyProgress', () {
    const a = HomeStats(
      xpTotal: 0, gold: 0, hearts: 5, playerLevel: 1,
      currentStreak: 3, longestStreak: 7, freezes: 1,
      dailyGoalXp: 15, dailyXpEarned: 10,
    );
    expect(a.dailyGoalMet, isFalse);
    expect(a.dailyProgress, closeTo(0.6667, 0.001));

    final met = HomeStats(
      xpTotal: 0, gold: 0, hearts: 5, playerLevel: 1,
      currentStreak: 3, longestStreak: 7, freezes: 1,
      dailyGoalXp: 15, dailyXpEarned: 20,
    );
    expect(met.dailyGoalMet, isTrue);
    expect(met.dailyProgress, 1.0); // clamp
  });

  test('LessonSummary parsea los campos de actividad (paso H)', () {
    final s = LessonSummary.fromJson(const {
      'xp_earned': 18,
      'gold_earned': 10,
      'accuracy': 1.0,
      'status': 'golden',
      'streak': 7,
      'streak_advanced': true,
      'goal_met': true,
      'daily_goal_xp': 15,
      'daily_xp_earned': 18,
      'milestone': 7,
      'skills': [
        {'skill': 'reading'},
      ],
    });
    expect(s.streak, 7);
    expect(s.streakAdvanced, isTrue);
    expect(s.goalMet, isTrue);
    expect(s.milestone, 7);
    expect(s.dailyGoalXp, 15);
    expect(s.skillsUp, ['reading']);
  });

  test('MatixResult.sent refleja el estado del motor', () {
    final sent = MatixResult.fromJson(const {
      'status': 'sent', 'reason': 'ok', 'copy': 'Sin excusas.',
      'coach_style': 'mano_dura', 'escalation_step': 1, 'trigger': 'goal_unmet',
    });
    expect(sent.sent, isTrue);
    expect(sent.copy, 'Sin excusas.');

    final capped = MatixResult.fromJson(const {
      'status': 'suppressed', 'reason': 'capped', 'copy': '',
      'coach_style': 'suave', 'escalation_step': 1, 'trigger': 'goal_unmet',
    });
    expect(capped.sent, isFalse);
    expect(capped.reason, 'capped');
  });

  test('UserSettings.fromJson normaliza quiet_hours a HH:MM', () {
    final s = UserSettings.fromJson(const {
      'coach_style': 'positivo',
      'intensity': 3,
      'quiet_hours_start': '22:00:00',
      'quiet_hours_end': '08:30:00',
      'push_enabled': true,
    });
    expect(s.coachStyle, 'positivo');
    expect(s.quietStart, '22:00');
    expect(s.quietEnd, '08:30');
  });
}
