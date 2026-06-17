/// Estado acumulado durante el onboarding (GA4: auth-first, sin redundancia).
class OnboardingData {
  /// Idioma de la app (UI). El idioma OBJETIVO del curso es inglés (Fase 1).
  String uiLang = 'es'; // es | en | pt
  String motive = '';

  /// Compromiso (paso unificado): minutos/día + días/semana en una pantalla.
  int dailyMinutes = 10;
  int daysPerWeek = 5;

  String goalLevel = 'B1';
  DateTime? deadline;

  /// Micro-pregunta de arranque: SOLO fija la dificultad inicial del placement.
  /// 0 = desde cero (A1) · 1 = sé algo (A2) · 2 = tengo buen nivel (B1).
  int startLevelHint = 1;

  // Test de personalidad → estilo de coach (Matix).
  String coachStyle = 'suave';
  int intensity = 2;

  // Test de ubicación → nivel real + 4 habilidades.
  String placementLevel = 'A1';
  Map<String, String> skillLevels = {
    'reading': 'A1',
    'listening': 'A1',
    'writing': 'A1',
    'speaking': 'A1',
  };

  /// El nivel "actual" del plan es el del test de ubicación (no hay autoeval).
  String get currentLevel => placementLevel;
}
