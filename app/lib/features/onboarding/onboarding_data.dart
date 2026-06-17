/// Estado acumulado durante el onboarding (paso G).
class OnboardingData {
  String targetLang = 'en';
  String nativeLang = 'es';
  String motive = '';
  String selfLevel = 'A1'; // autoevaluación rápida
  int dailyMinutes = 10;
  int daysPerWeek = 5;
  String goalLevel = 'B1';
  DateTime? deadline;

  // Test de personalidad.
  String coachStyle = 'suave';
  int intensity = 2;

  // Test de ubicación.
  String placementLevel = 'A1';
  Map<String, String> skillLevels = {
    'reading': 'A1',
    'listening': 'A1',
    'writing': 'A1',
    'speaking': 'A1',
  };

  /// El nivel "actual" del plan es el de la ubicación (confirma la autoeval).
  String get currentLevel => placementLevel;
}
