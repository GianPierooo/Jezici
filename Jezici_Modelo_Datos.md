# Jezici — Modelo de Datos (v1.0)

> Esquema de base de datos para Claude Code. Pensado para **Postgres**. Convenciones: `snake_case`, claves primarias `id` (UUID), timestamps `created_at`/`updated_at`, y `jsonb` para estructuras flexibles (payloads de ejercicios, resultados por sección). Complementa a Estructura_App (v1.1) y Especificacion (v0.3).

---

## Mapa de dominios

1. Usuarios y cuenta
2. Idiomas y contenido del curso (compartido)
3. Plan del usuario
4. Progreso en el curso
5. **Sistema de 4 habilidades**
6. Vocabulario y repaso espaciado (SRS)
7. Exámenes y resultados
8. Certificados
9. Gamificación (XP, oro, vidas, racha, ligas, logros, cofres, apuestas)
10. Test de personalidad y notificaciones (Matix)
11. Social / Conversar
12. Suscripción

---

## 1. Usuarios y cuenta

**`users`**
- `id` uuid (PK)
- `email` text (único)
- `auth_provider` text (email | google | apple)
- `name` text · `display_name` text · `avatar_url` text
- `native_language_id` uuid (FK → languages)
- `created_at`, `updated_at` timestamptz

> Auth la gestiona un servicio externo; aquí guardamos el registro del usuario.

---

## 2. Idiomas y contenido del curso (compartido entre usuarios)

Patrón Duolingo: el contenido del curso es **estático y cacheado**; lo del usuario se calcula por request.

**`languages`** — `id`, `code` (en, es, pt), `name`.

**`courses`** — un par idioma-nativo → idioma-objetivo.
- `id` · `source_language_id` (FK) · `target_language_id` (FK) · `is_active` bool
- (lanzamiento: es→en primero.)

**`units`** — regiones temáticas del mapa, por nivel CEFR.
- `id` · `course_id` (FK) · `cefr_level` enum(A1,A2,B1,B2,C1,C2) · `order` int · `title` · `theme_color` · `icon`

**`lessons`** — nodos del mapa.
- `id` · `unit_id` (FK) · `order` int · `title` · `description`
- `type` enum(lesson | checkpoint | mission) · `xp_reward` int

**`content_items`** — el banco único de ejercicios/preguntas (sirve a lecciones y exámenes).
- `id` · `course_id` (FK) · `cefr_level` enum · `skill` enum(reading, listening, writing, speaking)
- `type` enum(multiple_choice, cloze, word_bank, reorder, match, translation, listening, dictation, speaking_read_aloud, guided_writing)
- `prompt` text · `payload` jsonb (opciones, audio_url, tiles, etc.) · `correct_answer` jsonb
- `difficulty` numeric · `irt_a`, `irt_b` numeric (params para adaptatividad, opcional)
- Índices: (`course_id`, `cefr_level`, `skill`, `difficulty`) para armar exámenes.

**`lesson_items`** — qué ítems componen cada lección (orden).
- `lesson_id` (FK) · `item_id` (FK) · `order` int

---

## 3. Plan del usuario

**`user_plans`**
- `id` · `user_id` (FK) · `course_id` (FK)
- `current_level` enum · `goal_level` enum
- `daily_minutes` int · `days_per_week` int · `motive` text · `deadline` date (nullable)
- `estimated_hours` int · `estimated_completion_date` date (recalculada)
- `created_at`, `updated_at`

> La fecha se recalcula con el ritmo real (ver Estructura_App §2). Fórmula determinista; horas-guía por nivel parametrizables en config.

---

## 4. Progreso en el curso

**`user_course_progress`** — `user_id`, `course_id`, `current_unit_id`, `current_lesson_id`, `xp_total`.

**`user_lesson_progress`** — estado de cada nodo del mapa.
- `user_id` (FK) · `lesson_id` (FK)
- `status` enum(locked, available, in_progress, completed, golden)
- `best_accuracy` numeric · `times_completed` int · `completed_at`
- (Los estados visuales del mapa derivan de aquí.)

---

## 5. Sistema de 4 habilidades (diferenciador)

**`user_skill_levels`** — 4 filas por usuario/curso.
- `user_id` (FK) · `course_id` (FK)
- `skill` enum(reading, listening, writing, speaking)
- `cefr_level` enum · `progress_points` numeric (avance al siguiente nivel)
- `updated_at`
- Único: (`user_id`, `course_id`, `skill`).

> **Regla de certificación:** se certifica el nivel N solo si **las 4 filas** tienen `cefr_level >= N`. Cada `content_item` aporta a la habilidad de su campo `skill` al resolverse.

```sql
CREATE TABLE user_skill_levels (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id),
  course_id uuid NOT NULL REFERENCES courses(id),
  skill text NOT NULL CHECK (skill IN ('reading','listening','writing','speaking')),
  cefr_level text NOT NULL DEFAULT 'A1',
  progress_points numeric NOT NULL DEFAULT 0,
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, course_id, skill)
);
```

---

## 6. Vocabulario y repaso espaciado (SRS)

**`vocabulary`** — para las 100/300/1000 palabras y el rescate.
- `id` · `course_id` (FK) · `word` · `translation` · `frequency_rank` int · `part_of_speech`

**`user_vocab_srs`** — agenda de repaso por palabra.
- `user_id` (FK) · `vocab_id` (FK) · `strength` numeric · `ease` numeric · `interval_days` int · `due_at` timestamptz · `last_reviewed_at`
- Índice: (`user_id`, `due_at`) para traer "lo que está por olvidar".

---

## 7. Exámenes y resultados

**`exams`**
- `id` · `course_id` (FK) · `type` enum(placement, checkpoint, level, mock_ielts)
- `cefr_level` enum (nullable para placement) · `unit_id` (FK, para checkpoint)
- `time_limit_sec` int · `pass_threshold` numeric · `sections` jsonb (secciones y pesos)

**`exam_attempts`**
- `id` · `user_id` (FK) · `exam_id` (FK)
- `started_at`, `finished_at`
- `score_global` numeric · `per_section_scores` jsonb · `per_skill_results` jsonb (nivel logrado por skill)
- `passed` bool · `band_report` jsonb (para simulacros IELTS/Cambridge)

> El examen de nivel actualiza `user_skill_levels` y, si **las 4** llegan al nivel, dispara la emisión del certificado (§8).

---

## 8. Certificados

**`certificates`**
- `id` · `user_id` (FK) · `course_id` (FK) · `cefr_level` enum
- `issued_at` · `folio` text (único) · `verification_code` text (único) · `pdf_url`
- `exam_attempt_id` (FK) — el intento que lo emitió
- (PDF generado server-side con folio; página de verificación futura.)

---

## 9. Gamificación

**`user_stats`** — `user_id`, `xp_total`, `gold`, `hearts`, `hearts_updated_at`, `player_level`.

**`streaks`** — `user_id`, `current_streak`, `longest_streak`, `last_active_date`, `freezes_available`.

**`daily_goals`** — `user_id`, `date`, `goal_xp`, `xp_earned`.

**`gold_transactions`** — libro mayor del oro: `user_id`, `amount` (+/−), `reason` (lesson, challenge, freeze, heart_refill, retry, wager_win, wager_loss), `created_at`.

**`leagues`** — `id`, `division` enum(bronce..diamante), `week_start` date.
**`league_members`** — `league_id` (FK), `user_id` (FK), `weekly_xp` int, `rank` int. (Reset semanal: top asciende, fondo desciende.)

**`achievements`** — `id`, `code`, `name`, `description`, `criteria` jsonb.
**`user_achievements`** — `user_id`, `achievement_id`, `unlocked_at`.

**`chest_openings`** — recompensa variable: `user_id`, `reward_type`, `reward_amount`, `opened_at`.

**`wagers`** — dinámica "apostar oro" (opcional/suave).
- `id` · `user_id` (FK) · `type` enum(streak, weekly_goal)
- `stake_gold` int · `reward_gold` int · `start_date` · `end_date`
- `status` enum(active, won, lost)

---

## 10. Test de personalidad y notificaciones (Matix)

**`user_personality`** — del test; recalibrable en Ajustes.
- `user_id` (FK) · `coach_style` enum(mano_dura, positivo, rezago, suave) · `intensity` int
- `quiet_hours_start` time · `quiet_hours_end` time · `push_enabled` bool · `email_enabled` bool

**`notification_templates`** — plantillas por estilo y escalón.
- `id` · `coach_style` enum · `trigger` enum · `escalation_step` int · `channel` enum(push, email) · `copy` text

**`notifications`** — cola/registro de envíos.
- `id` · `user_id` (FK) · `channel` enum · `trigger` enum(streak_risk, goal_unmet, behind_plan, exam_countdown, winback, achievement, league)
- `template_id` (FK) · `escalation_step` int · `scheduled_at` · `sent_at` · `status` enum(scheduled, sent, suppressed)
- (Respetar `quiet_hours`; tope de escalado por día.)

---

## 11. Social / Conversar

**`social_profiles`** — para encontrar compañeros.
- `user_id` (FK) · `interests` text[] · `is_verified` bool · `online_status` enum(online, offline) · `last_seen_at`

**`connections`** — compañeros de idioma / amigos.
- `user_a_id` (FK) · `user_b_id` (FK) · `status` enum(pending, accepted, blocked)

**`conversation_rooms`** — salas de audio en vivo.
- `id` · `topic` · `cefr_level` enum · `host_user_id` (FK) · `status` enum(open, live, closed) · `created_at`
**`room_participants`** — `room_id` (FK), `user_id` (FK), `joined_at`, `left_at`.

**`coop_challenges`** — retos en pareja.
- `id` · `user_a_id` (FK) · `user_b_id` (FK) · `goal` jsonb · `progress` numeric · `status` enum(active, completed, expired)

**`conversation_challenges`** — reto de conversación del día (puntos por creatividad).
- `id` · `user_id` (FK) · `topic` · `prompt` · `status` enum(assigned, recorded, scored)
- `recording_url` · `transcript` text · `score` numeric · `creativity_points` int
- (Fase 1: se **guarda la grabación** aunque no se evalúe; la puntuación entra con IA en Fase 2.)

**`reports`** — seguridad: `id`, `reporter_id` (FK), `reported_id` (FK), `reason`, `created_at`.

---

## 12. Suscripción

**`subscriptions`**
- `user_id` (FK) · `plan` enum(free, premium_monthly, premium_annual, family) · `status` enum(active, canceled, past_due)
- `started_at` · `renews_at`

---

## Lógica clave a respetar

- **Certificación:** al cerrar un `exam` de tipo `level`, actualizar `user_skill_levels`; emitir `certificate` **solo si las 4 habilidades** alcanzan el nivel. Si falta una, devolver "te falta subir X".
- **Estados del mapa:** derivar de `user_lesson_progress` + dependencias (un nodo se desbloquea al completar el anterior / pasar el checkpoint).
- **SRS:** traer ítems/vocabulario con `due_at <= now()` ordenados por urgencia para "Rescate de palabras".
- **Ligas:** job semanal que arma grupos (~30 por actividad), calcula `rank`, asciende/desciende y resetea `weekly_xp`.
- **Oro:** toda variación pasa por `gold_transactions` (auditable). Las apuestas (`wagers`) se resuelven en su `end_date`.
- **Matix:** seleccionar plantilla por (`coach_style`, `trigger`, `escalation_step`), respetar `quiet_hours` y el tope diario de escalado.
- **Ganchos para IA (Fase 2):** `conversation_challenges.recording_url`/`transcript` y los textos libres se guardan desde Fase 1 para evaluar luego.

---

## Decisiones de implementación

- **Postgres** (relacional + `jsonb` para payloads flexibles de ejercicios y resultados).
- Contenido del curso **cacheado** (estático); progreso del usuario por request.
- IDs **UUID**; enums como tipos Postgres o `CHECK`.
- Índices clave: `content_items(course_id, cefr_level, skill, difficulty)`, `user_vocab_srs(user_id, due_at)`, `league_members(league_id, weekly_xp)`, `user_lesson_progress(user_id, status)`.
