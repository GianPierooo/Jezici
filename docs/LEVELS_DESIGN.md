# Jezici — Lógica de niveles, dominio y refuerzo (diseño · GA9·D)

> **✅ IMPLEMENTADO** en la migración `20260617130040_levels_mastery_exam_gated.sql`
> (tablas `user_skill_mastery` + `user_item_attempts`; RPCs `jz_record_mastery`,
> `jz_mastery_pct`, `jz_reinforce_score`, `get_skill_mastery`; `complete_lesson`/
> `submit_checkpoint`/`submit_practice` ahora suben DOMINIO (sin `jz_next_cefr`);
> `jz_level_status` con compuerta por dominio; `submit_level_exam` sube el nivel
> al aprobar; `start_practice('reinforce_unit', …)` para rehacer débiles). Datos
> migrados sin regresión (ver §Backfill al final). Verificado con `verify_chain.py`
> + `e2e_audit.py` en vivo. App: barras de dominio + compuerta + celebración de
> subida atada al examen + entrada "Reforzar".
>
> Diseño original (GA9·D), conservado como referencia: tocaba el CORAZÓN de la
> economía server-side ya verificada (la cadena A1→examen→cert→A2 de GA3).

## Estado actual (no romper)
- `complete_lesson`/`submit_checkpoint`: +12 por ítem correcto a `progress_points`;
  al llegar a 100 → `jz_next_cefr` sube el `cefr_level` de esa habilidad.
- `level_exam_status`: el examen de nivel N se desbloquea si **(a)** todos los
  checkpoints de N están hechos y **(b)** las 4 habilidades ya están en N.
- `submit_level_exam`: al aprobar emite el certificado (NO cambia el nivel).

## Cambio pedido (D6–D9)
1. **D6 · Dominio por habilidad**: por `(usuario, habilidad, nivel)` registrar
   `items_seen`, `items_correct`, `lessons_done` → `mastery_pct` (base de las barras).
2. **D7 · Salto de nivel por EXAMEN**: las lecciones suben DOMINIO; el `cefr_level`
   de cada habilidad SÓLO cambia al aprobar el examen. Mantener "certificas N solo
   si las 4 llegan a N".
3. **D8 · Refuerzo**: puntaje de necesidad por habilidad/ítem (sube con errores,
   decaimiento SRS, rezago entre habilidades). Alimenta Practicar y empujones de
   Matix; RECOMIENDA (no bloquea).
4. **D9 · Rehacer**: repetir cualquier lección (XP reducido, pero actualiza dominio
   + SRS) y modo "Reforzar" (re-evalúa sólo ítems débiles de la unidad/nivel).

## ⚠️ Riesgo clave (resuelto en el diseño)
Si las lecciones dejan de subir el nivel y el examen N exige "4 habilidades en N",
**se crea un deadlock** (el nivel sólo sube por examen, pero el examen exige el
nivel). **Fix:** cambiar la condición de desbloqueo del examen a **DOMINIO**, no nivel.

## Implementación (migración 040)
1. Tabla `user_skill_mastery(user_id, course_id, skill, cefr_level, items_seen,
   items_correct, lessons_done)` PK compuesta + RLS de lectura propia.
2. `jz_record_mastery(uid, course, skill, level, seen, correct)` (upsert/incrementa).
   `jz_mastery_pct(correct) = least(1, correct/16.0)` (16 aciertos ≈ dominado).
3. `complete_lesson`/`submit_checkpoint`: añadir `ci.cefr_level` al temp de
   calificación; agrupar por `(skill, cefr_level)` → `jz_record_mastery` con el
   nivel DEL ÍTEM (no del usuario). **Quitar** el `jz_next_cefr` (no más auto-nivel).
   XP de rehacer: si `times_completed>0` → `xp = round(xp*0.3)` (D9).
4. `jz_level_status`: `skills_ok` = promedio de `mastery_pct` de las 4 habilidades
   al nivel objetivo `>= 0.5` (en vez de "4 skills en N"). Sin deadlock: el dominio
   viene de las lecciones del nivel.
5. `submit_level_exam`: al aprobar, `update user_skill_levels set cefr_level = N`
   para las 4 (único punto donde sube el nivel) + certificado (igual).
6. **D8** `jz_reinforce_score(skill)`: combina (1−accuracy del nivel), ítems SRS
   vencidos y rezago vs la habilidad más fuerte. Expuesto en `get_skill_mastery()`;
   Practicar prioriza la habilidad de mayor score; Matix sugiere reforzar.
7. **D9** modo "Reforzar": `start_practice('weakness')` ya re-evalúa débiles; añadir
   `start_practice('reinforce_unit', p_unit)` que toma sólo ítems fallados de la
   unidad/nivel.

## App
- `get_skill_mastery()` → por habilidad: `certified_level`, `working_level`,
  `mastery_pct`, `reinforce_score`. Las barras de las 4 habilidades muestran
  `mastery_pct` del nivel en curso; el examen exige las 4.
- Celebración "subiste de nivel" sólo tras aprobar el examen.

## Verificación
Actualizar `tools/content/verify_chain.py`: en vez de fijar `user_skill_levels`,
sembrar `user_skill_mastery` (>= gate) para desbloquear el examen; confirmar que
aprobar el examen sube `cefr_level` de las 4. Re-correr toda la cadena
A1→examen A1→cert→A2→examen A2 antes de hacer commit.
