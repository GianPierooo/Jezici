# Jezici — Plan de Construcción (Guía para Claude Code) v1.0

> El puente de la planeación a construir. Define el **primer slice vertical** (el camino mínimo de punta a punta que prueba el loop), el stack, el orden de construcción y cómo prompteárselo a Claude Code. Fase 1, **sin IA**.

---

## 0. Filosofía

No construir las 26 pantallas de golpe. Construir un **corte vertical delgado** que funcione de principio a fin, verlo correr, y recién expandir. Es lo que más aclara el resto.

---

## 1. El slice (alcance)

**Incluye:**
- **Onboarding corto:** idioma (es→en) + meta + compromiso diario → genera **"Tu plan"** (fecha estimada).
- **Mapa de la Unidad 1 (A1)** con nodos y sus estados (bloqueado/disponible/completado).
- **Una lección** con ejercicios (opción múltiple, banco de palabras, emparejar, traducción) + feedback ✅/❌ + vidas + combo.
- **Pantalla de fin:** XP, oro, racha, y progreso de habilidad ("+Reading").
- **Progreso persistido** + **niveles por habilidad (4 skills)** actualizándose.
- **Checkpoint de Unidad 1** (gating simple, umbral 80%).
- **Perfil básico:** panel de 4 habilidades + racha + plan.

**Fuera del slice (después):** Conversar, simulacros IELTS, motor Matix completo, paywall/premium, certificación completa, **speaking** (STT), otros idiomas, IA.

---

## 2. Stack recomendado

- **App:** Flutter (iOS/Android/Web) — un solo código.
- **Backend/Datos:** **Supabase** (Postgres + Auth + APIs + Realtime) como **vía rápida para 2 personas** — es Postgres, así que calza directo con el Modelo de Datos; trae auth y APIs listas, y realtime para el Conversar de Fase 2. *Alternativa:* backend propio (FastAPI/Node) + Postgres si quieres más control.
- **Sin IA** en Fase 1. El speaking se difiere (o STT vía API dedicada cuando toque).
- **Analítica** desde el día uno (retención).

---

## 3. Orden de construcción (pasos para Claude Code)

**A. Esquema de datos** — crear las tablas core del Modelo de Datos: `users, languages, courses, units, lessons, content_items, lesson_items, user_course_progress, user_lesson_progress, user_skill_levels, user_stats, streaks`. (Las demás se agregan después.)

**B. Seed de contenido** — cargar la **Unidad 1 del Currículo A1** (units, lessons, content_items con su `skill`).

**C. App shell** — navegación (5 tabs; activar **Aprender** + **Perfil** para el slice), el **sistema de diseño según los mockups**, y la **pantalla del mapa** (Unidad 1) con estados de nodo.

**D. Loop de lección** — pantalla de ejercicios (tipos: opción múltiple, banco de palabras, emparejar, traducción), feedback, vidas, combo, y pantalla de fin (XP/oro/racha + skill +1).

**E. Progreso + 4 skills** — actualizar `user_lesson_progress` y `user_skill_levels`; reflejar los estados en el mapa.

**F. Checkpoint** — examen de unidad simple (selección de ítems + scoring **por habilidad** + umbral 80%); pasa/no pasa.

**G. Onboarding lite + "Tu plan"** — preguntas clave + **motor de estimación de tiempo** (determinista) + crear el plan.

**H. Pulido** — racha + meta diaria + una notificación básica de racha.

---

## 4. Qué documento alimenta cada parte

| Parte | Documento |
|---|---|
| Esquema de datos | **Modelo de Datos** |
| Contenido del curso | **Currículo A1 (es→en)** |
| Checkpoint / scoring / 4 skills | **Banco de Ítems** |
| Pantallas, UI, identidad | **Estructura_App** §13–15 + los **mockups** |
| Gamificación y 4 skills | **Estructura_App** §8, §11 |
| Estimación de tiempo | **Estructura_App** §2 |

---

## 5. Cómo prompteárselo a Claude Code

- Pon **todos los `.md`** en el repo/proyecto para que Claude Code los tenga de contexto.
- Construye **incrementalmente, una pieza a la vez** (A→H), probando cada una antes de seguir.
- Para el **esquema**: dale el Modelo de Datos y pídele las migraciones.
- Para el **contenido**: dale el Currículo y pídele el seed.
- Para la **UI**: dale los **mockups (capturas)** + la dirección de diseño.
- Pídele **tests** para la lógica (scoring, estados de nodo, estimación de tiempo).
- **Prompt de arranque sugerido:**
  > "Lee los `.md` del proyecto Jezici. Vamos a construir el slice vertical descrito en `Plan_Construccion`. Empieza por (A): el esquema de datos en Supabase/Postgres a partir de `Modelo_Datos.md`. Genérame las migraciones y explícame la estructura."

---

## 6. Definición de "listo" del slice

Un usuario puede: pasar el onboarding y ver su plan → entrar a la Unidad 1 → completar una lección (ganando XP/oro/racha y subiendo habilidades) → pasar el checkpoint → ver su progreso y el panel de 4 skills en Perfil. **Todo persistido.** Cuando esto corre, expandimos al resto del currículo y de las pantallas.
