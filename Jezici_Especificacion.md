# Jezici — Especificación de Producto y Técnica (v0.3)

> App de aprendizaje de idiomas que fusiona la **estructura** de Busuu, la **gamificación/retención** de Duolingo y la **conversación humana** de Tandem. Fase 1: clonar bien el núcleo Duolingo, **100% programado y sin IA**, con un sistema de exámenes intenso, certificados internos y un motor de notificaciones personalizado por test de personalidad. Fases siguientes: sumar lo novedoso de Tandem/Busuu y, mucho más adelante, IA.

---

## 1. Decisiones tomadas (base del proyecto)

| Decisión | Definición |
|---|---|
| Equipo | 2 personas |
| Par de idiomas inicial | Español → Inglés |
| Plataformas | iOS, Android y Web (un solo código Flutter) |
| Modelo de negocio | Freemium (columna) + publicidad + donaciones (apoyo) |
| Enfoque | Replicar primero el núcleo Duolingo; luego sumar Tandem/Busuu |
| **IA** | **Cero IA en Fase 1** — todo programado/determinista. IA mucho más adelante (ver §8) |
| Exámenes | Todos: ubicación, mini-quiz, gating de nivel, certificación, simulacros IELTS/Cambridge |
| Certificado | Interno desde ya + meta de acreditación oficial a futuro |
| Motivación | Test de personalidad define el estilo de notificaciones/correos por usuario |
| Evaluación por habilidad | Las 4 habilidades (reading, listening, writing, speaking) se nivelan por separado; el certificado exige el nivel meta en las 4 |
| Identidad | Concepto de mapa/viaje ascendente; mascota guacamayo escarlata; moneda = oro |

---

## 2. El concepto central: tres capas, un loop

Duolingo, Busuu y Tandem son tres productos distintos. Jezici los fusiona en **un solo círculo**:

1. **Capa de estructura (ADN Busuu)** — define *el camino*: árbol de aprendizaje por niveles CEFR, plan con meta y fecha.
2. **Capa de gamificación (ADN Duolingo)** — te trae *de vuelta cada día*: XP, racha, ligas, exámenes que escalan niveles.
3. **Capa de conversación (ADN Tandem)** — *el hito* (fase posterior).

Envueltas por el **motor de seguimiento (ADN Matix)**: notificaciones y correos personalizados según el test de personalidad.

---

## 3. El loop del usuario

```
ONBOARDING
  → Test de PERSONALIDAD (define estilo motivacional)
  → Test de UBICACIÓN adaptativo (define nivel CEFR de entrada)
  → Eliges meta + fecha → la app genera TU plan
        ↓
LOOP DIARIO (dentro de tu nivel actual)
  → Lecciones cortas con mini-quiz (XP + racha + liga)
  → Repaso espaciado intercalado (re-evalúa lo viejo)
  → Diagnóstico de debilidades → recalibra el plan
  → Checkpoint de unidad (gating: pasas para seguir)
        ↓
FIN DE NIVEL
  → EXAMEN DE NIVEL (certificación interna)
  → Si apruebas: CERTIFICADO + desbloqueas el siguiente nivel
        ↓
SIMULACROS (tipo IELTS/Cambridge, según nivel)
        ↓
SEGUIMIENTO PERMANENTE: barras de progreso + correos + notificaciones
(estilo definido por tu test de personalidad)
```

---

## 4. Sistema de evaluación y exámenes (núcleo del producto)

El sistema combina **6 tipos de evaluación**, cada uno con un propósito distinto. Juntos crean el flujo intenso de "ir escalando entre niveles".

### 4.1 Los 6 tipos de evaluación

**1. Test de ubicación (placement) — al inicio**
- Propósito: colocar al usuario en el nivel CEFR correcto (A1–C1) y arrancar el plan en el punto justo.
- **Adaptativo**: la dificultad sube o baja según las respuestas (cada acierto sube, cada error baja). Esto lo hace sentir "real" y eficiente — es el estándar de los exámenes serios.
- Cubre: gramática, vocabulario, comprensión lectora y auditiva.
- Salida: nivel CEFR + posición de arranque en el árbol.

**2. Mini-quiz por lección (formativo) — dentro de cada lección**
- Propósito: reforzar y verificar retención. Bajo riesgo, rápido, divertido.
- Es el "corazón" tipo Duolingo: cada lección es una serie de ejercicios.
- Da XP, alimenta racha y avanza la barra del plan.

**3. Checkpoint de unidad (gating) — al cerrar cada unidad**
- Propósito: **bloquear el avance** hasta aprobar. Esto crea la sensación de escalar.
- Más completo que un mini-quiz: cubre toda la unidad. Cronometrado.

**4. Examen de nivel / certificación interna — al completar un nivel**
- Propósito: el examen "grande" que, al aprobarse, **emite el certificado interno** (A2, B1, B2, C1...).
- Formato serio: secciones, tiempo límite, banco de preguntas amplio y aleatorizado.
- Es el gran hito motivacional del usuario.

**5. Simulacro tipo IELTS/Cambridge — disponible según nivel (premium)**
- Propósito: preparar para certificación real + dar el "feel" de examen oficial.
- Completo y cronometrado, con las 4 secciones: **Listening, Reading, Writing, Speaking**.
- Reporte detallado de "banda" por sección.

**6. Repaso espaciado + diagnóstico de debilidades — continuo**
- Propósito: combatir el olvido (clave para *realmente* llegar a un nivel, no solo aprobar una vez).
- El sistema reintroduce material viejo en intervalos crecientes (SRS) y arma un perfil de debilidades que recalibra el plan ("flojo en pasado simple", "flojo en listening").

### 4.2 Tipos de ejercicio (los bloques de todos los exámenes)

Opción múltiple · Rellenar el espacio (cloze) · Banco de palabras / armar la oración · Reordenar palabras · Emparejar · Comprensión auditiva (audio → respuesta) · Traducción (en ambos sentidos) · Dictado · Verdadero/falso con justificación.

### 4.3 Reto importante sin IA: Speaking y Writing

Casi todos los ejercicios se corrigen de forma **100% programada** (respuesta esperada vs respuesta del usuario). Las dos excepciones reales son **hablar libre** y **escribir libre (ensayos)**: evaluarlos bien sin un modelo de lenguaje es muy difícil. Soluciones para Fase 1:

- **Speaking**: ejercicios de *leer en voz alta / repetir*, verificados por reconocimiento de voz que compara contra el texto esperado (no evalúa creatividad, solo si dijiste lo correcto). *Nota técnica:* la corrección de pronunciación usa modelos de ML especializados — si el "cero IA" es estricto, esto entra recién con la fase de IA o vía API dedicada.
- **Writing**: en Fase 1, escritura *guiada y estructurada* (rellenar, reordenar, completar con patrones verificables). La escritura libre con feedback de calidad espera a la fase de IA, o se resuelve con **corrección comunitaria** (modelo Busuu: nativos corrigen) — con verificación del corrector para no repetir el error de Busuu (cualquiera dice ser nativo).
- En los **simulacros IELTS/Cambridge**: Listening y Reading se autocorrigen perfecto sin IA; Writing y Speaking se entregan con **respuestas modelo + autoevaluación guiada por rúbrica** en Fase 1, y pasan a corrección automática cuando entre la IA.

### 4.4 La "cocina" de exámenes que se sienten reales

Para que un examen no se sienta de juguete:
- **Banco de ítems calibrado** por nivel CEFR y por dificultad, con etiquetas de habilidad.
- **Aleatorización**: cada intento mezcla preguntas distintas (anti-trampa, rejugable).
- **Cronómetro** y condiciones de examen (sin pistas, sin volver atrás en algunas secciones).
- **Adaptatividad** en ubicación y certificación (idealmente con teoría de respuesta al ítem / IRT — el método de los exámenes profesionales).
- **Economía de reintentos**: reintentos gratis limitados + espera o premium para más (esto crea tensión real y valor del aprobado).

---

## 5. Flujo de exámenes intenso (end-to-end)

```
DÍA 0   Test de personalidad → Test de ubicación → meta + plan
SEMANA  Lecciones + mini-quiz diario (XP, racha)
        Repaso espaciado intercalado
        "Examen de unidad en 3 días" → cuenta regresiva + prep reminders
        CHECKPOINT DE UNIDAD (gating) → si pasas, avanzas; si no, plan de refuerzo
...repite por todas las unidades del nivel...
FIN DE NIVEL
        Simulacro de calentamiento (opcional)
        EXAMEN DE NIVEL (boss del nivel) → cronometrado, secciones
        ├─ Aprueba → 🏆 CERTIFICADO interno + desbloquea siguiente nivel + celebración
        └─ No aprueba → reporte de debilidades + plan de refuerzo dirigido + reintento
EN CUALQUIER MOMENTO (según nivel, premium)
        SIMULACRO IELTS/Cambridge completo → reporte de banda por sección
SIEMPRE
        Barras de progreso (a la próxima prueba, al certificado, a la meta)
        Correos + notificaciones según personalidad ("vas atrás", "te falta poco", etc.)
```

**Mecánicas de intensidad** integradas al flujo: cuenta regresiva a cada examen con recordatorios que escalan; framing de "boss battle" para el examen de nivel; reporte post-examen con remediación dirigida; reintentos con stakes; certificado compartible; y la presión permanente de "estás quedando atrás de tu plan".

---

## 6. Test de personalidad → estilo de motivación (motor Matix)

Al inicio, un **test de personalidad** clasifica al usuario en un *estilo motivacional*, y todo el sistema de notificaciones/correos se adapta a él. Ejemplos de estilos:

- **Mano dura / estricto**: "Faltaste hoy. Eso no va. Vuelve ya." Exigente, directo, sin concesiones.
- **Motivación positiva intensa**: "¡Llevas 12 días imparable! Hoy te toca brillar 💪".
- **Recordatorio de rezago**: "Vas 2 días atrás de tu plan. 3 personas de tu liga te pasaron."
- **Suave / amigable**: "Cuando puedas, una lección rápida te mantiene en ritmo 🙂".

**Principio de diseño (no negociable):** el modo estricto exige sobre la *conducta y la meta* ("no entrenaste, retoma"), nunca ataca el valor de la persona. La presión sobre la acción motiva; el insulto al usuario causa desinstalaciones. Además: respetar horarios (sin notificar de madrugada), permitir al usuario recalibrar la intensidad, y que toda comunicación empuje hacia *su* meta.

**Canales**: push (FCM/APNs) + correo, sincronizados. Las barras de progreso son el eje visual que estos mensajes refuerzan.

---

## 7. Catálogo de dinámicas (lo innovador y fuerte)

**Núcleo Duolingo (Fase 1):** racha + streak freeze · XP como moneda compartida · ligas semanales con emparejamiento por actividad · logros/badges · economía de oro/monedas · vidas/energía · cofres de recompensa variable.

**Diferenciadores fuertes de Jezici:**
- **Coaches con personalidad** según el test (la motivación se siente hecha para ti).
- **Boss-battle de fin de nivel** con certificado como recompensa.
- **Modo Intenso (opt-in)**: más lecciones/día, sin freeze, mayor presión — para quienes quieren mano dura.
- **Retos y misiones** diarias/semanales con recompensas.
- **Repaso como juego**: "rescata las palabras que estás por olvidar".
- **Barras de progreso por todos lados**: a la próxima prueba, al certificado, a la fecha meta.
- **Motor de insistencia** (correo + push) que nunca te deja perder el hilo.
- **Mecánicas de regreso (win-back)** para usuarios que se fueron — clave para retención.
- **Nivelación de las 4 habilidades**: reading, listening, writing y speaking suben por separado; certificar exige el nivel meta en las 4 (certificado más creíble y equilibrado).
- **Retos en pareja (co-op)**: dos usuarios reman juntos hacia una meta compartida. *(En vez de duelos competitivos, que encajan mal en idiomas: premian al que ya sabe, se prestan a dejarse ganar y la presión sube el estrés. La competencia se queda en Ligas, basada en esfuerzo.)*
- **Apostar oro en tu meta**: mecánica de compromiso opcional y suave (apuestas oro a cumplir tu racha/meta); nunca un castigo que hunda a quien batalla.

**Fases posteriores (Tandem/Busuu):**
- **Salas de conversación** en vivo con otros usuarios (audio grupal).
- **Misiones de conversación por tema** (la idea original: te dan el tema y ganas puntos por creatividad — requiere IA).
- **Corrección comunitaria** verificada (escritura/habla corregida por nativos validados).
- **Rachas con amigos** y compañeros de responsabilidad.
- **Misiones del mundo real** (usar el idioma en tareas reales).

---

## 8. Roadmap de IA — dónde puede entrar más adelante

(Fase 1 es cero IA. Estos son los puntos donde, a futuro, la IA da el mayor salto:)

1. **Evaluar Speaking abierto**: pronunciación + fluidez + contenido.
2. **Evaluar Writing libre (ensayos)** con feedback alineado a CEFR — esto desbloquea las secciones Writing/Speaking de los simulacros sin depender de humanos.
3. **La conversación con puntos por creatividad** (tu diferenciador original): tema asignado → transcripción → evaluación de relevancia, gramática, vocabulario y creatividad.
4. **Plan adaptativo inteligente**: predecir qué enseñar a continuación según el desempeño real.
5. **Feedback personalizado**: explicar *por qué* una respuesta está mal, adaptado al usuario.
6. **Generar ejercicios/contenido extra** a demanda y expandir el banco de ítems (con revisión humana).
7. **Compañero de práctica conversacional** (roleplay tipo chatbot).
8. **Copys de notificación hiper-personalizados**: el motor Matix redacta el mensaje perfecto según personalidad + contexto.
9. **Detección de usuarios en riesgo de abandono** e intervención automática.

> Conviene diseñar la Fase 1 con "ganchos" donde la IA se enchufa después (ej. guardar todas las grabaciones y textos libres aunque aún no se evalúen, para entrenar/evaluar luego).

---

## 9. Arquitectura técnica

| Componente | Recomendación | Por qué |
|---|---|---|
| **Frontend** | Flutter (iOS/Android/Web) | Un código, 3 plataformas; render propio ideal para gamificación; tu equipo ya domina Flutter |
| **Backend** | Python (FastAPI) o Node | Lógica de plan, exámenes, scoring determinista, notificaciones |
| **Motor de exámenes** | Banco de ítems + lógica adaptativa (IRT) | Exámenes que se sienten reales, rejugables, anti-trampa |
| **Base de datos** | Postgres | Usuarios, progreso, ítems, resultados, certificados |
| **Datos de curso** | Pre-procesados y cacheados (patrón Duolingo: estáticos + caché; lo del usuario por request) | Eficiencia y escala |
| **Auth** | Auth gestionado | Estándar |
| **Notificaciones** | FCM (Android/Web) + APNs (iOS) + servicio de correo | Motor Matix |
| **Generación de certificados** | PDF generado server-side (con folio/verificación) | Certificado interno con identidad |
| **Analítica/experimentos** | Desde el día uno | Sin métricas de retención vuelas a ciegas |
| **Voz (cuando aplique)** | LiveKit/Agora + STT | Solo cuando entren Speaking real / conversación |

---

## 10. Monetización y gating

| Gratis | Premium |
|---|---|
| Plan + seguimiento + lecciones | Simulacros IELTS/Cambridge completos |
| Mini-quiz, checkpoints, examen de nivel | Reintentos extra de examen |
| Certificado interno | Reportes detallados de banda |
| Racha, ligas, XP | Sin anuncios |
| Anuncios entre lecciones | (Fase 2: conversación humana, IA) |

> Freemium es la columna. Ads pagan poco hasta gran escala; donaciones son apoyo. Los simulacros y reintentos son buenos ganchos de pago porque tienen valor percibido alto.

---

## 11. Roadmap por fases

**Fase 0 — Validación**: prototipo del loop con 1 unidad + mini-quiz + 1 checkpoint + test de personalidad básico. Probar con usuarios reales (ES→EN) si el flujo engancha.

**Fase 1 — MVP (núcleo Duolingo, sin IA)**: test de personalidad + ubicación adaptativo + plan + ~1 nivel CEFR de lecciones + los 6 tipos de evaluación (con Speaking/Writing en su forma de Fase 1) + examen de nivel + certificado interno + motor Matix + freemium. Lanzamiento en 3 plataformas.

**Fase 2 — Profundidad + IA**: evaluación de Writing/Speaking con IA, conversación humano-a-humano (con moderación/verificación/reporte), simulacros con corrección automática, más niveles, salas de conversación, corrección comunitaria.

**Fase 3 — Escala**: más idiomas, acreditación oficial del certificado, contenido generado, optimización de costos, A/B testing a gran escala.

---

## 12. Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| Alcance (2 personas) | Un loop, no 3 apps. Fase 0 antes de todo. Cortar lo que no sea núcleo. |
| Validez de exámenes "reales" | Banco de ítems calibrado + adaptatividad; empezar simple e ir mejorando. |
| Speaking/Writing sin IA | Formas de Fase 1 (lectura en voz alta, escritura guiada, rúbricas) + corrección comunitaria verificada. |
| Notificaciones tóxicas | Presión sobre la conducta, no la persona; techo; horarios; control del usuario. |
| Certificado "oficial" | Empezar interno; acreditación es acuerdo de largo plazo (modelo McGraw-Hill de Busuu). |
| Promesa de nivel | "Si cumples el plan, llegas" (no garantía literal). |

---

## 13. Métricas que importan (lección de Duolingo)

Retención D1/D7/D30 y una métrica reina tipo **CURR** (probabilidad de volver mañana) · DAU/MAU · racha promedio · lecciones/día · % que aprueba cada examen · % que obtiene certificado · % en ritmo vs atrasado · conversión a premium · win-back de usuarios perdidos.

---

## 14. Próximos pasos concretos

1. Diseñar el **test de personalidad** (preguntas + cómo mapean a estilos motivacionales).
2. Diseñar la **estructura del banco de ítems** y el motor adaptativo del test de ubicación.
3. Detallar el **árbol de aprendizaje** del primer nivel (unidades, lecciones, ejercicios).
4. Definir las **reglas del motor Matix** (escalado + techo + horarios + plantillas por estilo).
5. Especificar el **examen de nivel + emisión del certificado** (formato, secciones, folio).

> Sugiero empezar por (1) el test de personalidad o (3) el árbol del primer nivel — son la base sobre la que se monta todo lo demás.
