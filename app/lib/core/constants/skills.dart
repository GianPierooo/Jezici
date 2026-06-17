/// Constantes compartidas de las 4 habilidades (GA4 · B4: evita duplicación
/// del mapa de etiquetas/orden en 5+ pantallas).
library;

const kSkillOrder = ['reading', 'listening', 'writing', 'speaking'];

const kSkillLabels = {
  'reading': 'Reading',
  'listening': 'Listening',
  'writing': 'Writing',
  'speaking': 'Speaking',
};

const kSkillEs = {
  'reading': 'Lectura',
  'listening': 'Escucha',
  'writing': 'Escritura',
  'speaking': 'Habla',
};

const kCefrRank = {'A1': 0, 'A2': 1, 'B1': 2, 'B2': 3, 'C1': 4, 'C2': 5};
const kCefrOrder = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

/// Puntaje continuo de una habilidad para comparar/graficar (rango ~0..6).
double skillScore(String cefr, num progressPoints) =>
    (kCefrRank[cefr] ?? 0) + (progressPoints.clamp(0, 100) / 100.0);
