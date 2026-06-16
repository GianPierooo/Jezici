# Jezici — Análisis de Competencia (v1.0)

> Cómo funcionan y están hechas Duolingo, Busuu y Tandem, y qué toma Jezici de cada una. Resumen del análisis que fundamenta el producto.

---

## 1. Duolingo — motor de retención que enseña idiomas

**Qué hace bien:** todo gira en torno a la **retención** (lo difícil no es la gramática, es que la gente deje de aparecer). Mecánicas: **rachas** (aversión a la pérdida; el streak freeze reduce mucho el abandono), **XP como moneda compartida** (una lección alimenta racha + liga + logros a la vez), **ligas** semanales con emparejamiento por actividad, **diseño por capas** (cada mecánica sirve a un segmento/momento distinto). Métrica reina: **CURR** (probabilidad de volver mañana) — moverla unos puntos compone el crecimiento.

**Cómo está construido:** empezó en Python; migró el core a **Scala** al escalar. Contenido del curso **estático y cacheado** (archivos en almacenamiento); datos del usuario por request. Microservicios; **300+ experimentos** a la vez.

**Debilidad:** producción oral real / conversación humana.

**Jezici toma:** todo el **núcleo de gamificación y retención** + el patrón técnico de contenido cacheado + la cultura de medir retención desde el día uno.

---

## 2. Busuu — estructura curricular + correcciones de comunidad

**Qué hace bien:** cursos **estructurados por CEFR** (A1–B2), lecciones cortas por tema, **plan de estudio con metas y tiempos estimados** a cada nivel, **certificados** (vía McGraw-Hill), y **correcciones de comunidad** (envías tu escritura/habla y nativos la corrigen; tú corriges a otros).

**Debilidad:** la corrección entre usuarios **no es confiable** (cualquiera dice ser nativo) — degrada lo que podría ser su mejor feature.

**Jezici toma:** la **estructura CEFR** y el **plan con fecha** (núcleo de tu diferenciador), la idea de **certificación**, y la **corrección comunitaria** — pero con **verificación del corrector** para no repetir su error.

---

## 3. Tandem — intercambio humano real

**Qué hace bien:** conecta aprendices con **nativos** que quieren aprender tu idioma; practican por texto, notas de voz y **videollamadas**, con correcciones; emparejamiento por idioma/intereses/nivel; salas grupales ("Parties").

**Lo difícil:** **moderación y seguridad** (al ser social, hay riesgo; "se siente como app de citas") y **no sirve para principiantes solos** (no hay materiales; todo es cara a cara).

**Jezici toma:** la **conversación humana** y el emparejamiento — pero **sobre una base estructurada** (que es lo que Tandem no tiene), con **moderación/verificación** desde el diseño, y arrancando la conversación **con IA** (Fase 2) para resolver liquidez y seguridad.

---

## 4. La fusión de Jezici

| Capa | De dónde | En Jezici |
|---|---|---|
| Estructura (el camino) | Busuu | Plan CEFR con fecha real, mapa/viaje |
| Gamificación (volver cada día) | Duolingo | XP, racha, ligas, oro, Modo Intenso |
| Conversación (el hito) | Tandem | Conversar: salas, co-op, retos por tema (Fase 2) |
| Seguimiento | (Matix) | Notificaciones por personalidad |

**Diferenciadores propios:** plan con fecha real · certificación creíble que exige **4 habilidades equilibradas** · coaches con personalidad · conversación con **puntos por creatividad** (Fase 2).

---

## 5. Lecciones clave

1. **Premiar el esfuerzo**, no "ser bueno" (por eso Ligas por XP, no duelos).
2. **Medir por lo que el usuario puede hacer**, no por lecciones completadas (el examen).
3. **La producción/conversación es el hueco** del mercado → la Fase 2 es donde está el oro.
4. **Verificar a los correctores** (no repetir el error de Busuu).
5. **Moderación/seguridad** no es opcional cuando hay personas reales (lección de Tandem).
