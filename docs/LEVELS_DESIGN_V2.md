# Jezici — Niveles v2 (migración 041): dominio rico + examen por-skill + refuerzo + rehacer

> Sucede a la mig 040 (modelo de dominio simple, `mastery=correct/16`, examen
> all-4-together). v2 implementa el spec detallado: dominio = cobertura ×
> precisión ponderada por dificultad; nivel PER-SKILL que sube al aprobar la
> SECCIÓN del examen de esa skill; refuerzo por usuario+ítem; rehacer con XP
> decreciente. Lógica núcleo → diseño validado por panel adversarial antes de
> implementar. Hay 3 usuarios reales en prod (grandfather).

## Datos que condicionan el diseño (verificados en vivo)
- `content_items.difficulty` POBLADO (A1≈0.15, A2≈0.32, B1≈0.61, B2≈0.81) — sube
  con el nivel. `irt_b` vacío → usamos `difficulty`.
- `jz_is_stub` = {speaking_read_aloud, dictation, guided_writing}. **Listening SÍ
  califica** (mig 027); **speaking NO** (0 ítems calificables → participación).
- Calificables por (skill, nivel A1/A2): reading 76/72, writing 68/72, listening
  24/24, **speaking 0/0**.
- Usuarios reales: gianpiero (A2×4, 0 item_attempts), britoleopoldo (B1×4, 0),
  natalia (A2×4, **84 item_attempts** — jugando el modelo nuevo).

## 1. DOMINIO (mastery_pct por usuario, skill, nivel)  ← fuente de las barras
Combina cobertura (breadth) y precisión ponderada por dificultad (depth). Se
calcula ON-DEMAND desde `user_item_attempts` ⋈ `content_items` (contenido pequeño).

Para una skill CALIFICABLE (reading/writing/listening) en un nivel L:
- `total_g` = nº de ítems calificables (no-stub) de (skill, L) en el banco.
- `attempted` = nº de ítems DISTINTOS de (skill, L) que el usuario intentó.
- `coverage = least(1, attempted / greatest(1, ceil(total_g * 0.60)))`
  → practicar el 60 % de los ítems satura la "amplitud" (no exige el 100 %).
- `w(item) = 0.5 + difficulty`  (rango ~0.6..1.15; los difíciles pesan más).
- `wacc = Σ(w · [last_correct]) / Σ(w)` sobre los ítems calificables intentados.
  Usa `last_correct` (el intento más reciente) → rehacer y acertar SÍ recupera.
- `mastery_pct = round(coverage * wacc, 4)`   (0..1).

Para SPEAKING (sin ítems calificables) = participación pura:
- `total_s` = nº de ítems de speaking de (skill, L).
- `attempted` = nº de ítems de speaking DISTINTOS practicados.
- `mastery_pct = least(1, attempted / greatest(1, ceil(total_s * 0.60)))`.
  (practicar el 60 % de los ítems de habla = dominio pleno de participación).

Nota: hay que registrar TODOS los ítems en `user_item_attempts` (también los
stubs de speaking, como participación) — hoy sólo se registran los calificables.

## 2. SALTO DE NIVEL POR EXAMEN (PER-SKILL, por sección)
**Semántica de nivel** (restricción del enum cefr_level A1..C2, sin "pre-A1"):
`user_skill_levels.cefr_level` = **nivel EN CURSO** de la skill (en el que acumula
dominio; arranca A1). "certificado en L" ≡ cefr_level de la skill > L. Esto cuadra
con la migración 040 (gianpiero working A2 ⇒ cert A1; britoleopoldo working B1 ⇒
certs A1+A2). Las skills pueden DIVERGIR (reading B1, speaking A1).

- **Desbloqueo (por skill)**: una skill está exam-ready cuando
  `mastery(skill, cefr_level) ≥ 0.80`. El examen está disponible si ≥1 skill lo está.
- **Examen** = una sola sesión que arma ítems de CADA skill en SU cefr_level actual
  (multi-nivel). Calificación por sección/skill (ya existe per_skill).
- **Subida (por skill)**: para cada skill que (a) estaba exam-ready Y (b) aprueba su
  sección — calificable: accuracy de la sección ≥ 0.80; speaking: participó en su
  sección — su `cefr_level` += 1. Las demás se quedan. Reprobar conserva el dominio.
- **Eliminar** el auto-nivel por dominio (ya hecho en 040: sin jz_next_cefr).
- **Certificado de nivel N**: se emite cuando las 4 skills tienen cefr_level > N
  (todas pasaron el examen de N). El "nivel certificado" del usuario = min(cefr)−1.
  Mantiene "certificas N solo si las 4 llegan a N".

## 3. REFUERZO (por usuario+skill y por usuario+ítem)
- **Por ítem** `jz_item_reinforce(uid,item)`: sube con fallos (1−correct_ratio),
  con vencimiento SRS del vocab asociado (si aplica) y con la recencia (más viejo →
  más urgente). Acota 0..1. Alimenta el modo "Reforzar" (ordena por este score).
- **Por skill** `jz_reinforce_score(uid,skill)` (ya en 040, se mantiene/afina):
  (1−wacc del nivel) + rezago vs la skill de mayor cefr_level del usuario + SRS.
- RECOMIENDA, no bloquea. Practicar prioriza la skill de mayor score; Matix dispara
  un empujón "flojo en {skill}" para la skill más rezagada (cefr más bajo / score alto).

## 4. REHACER
- XP DECRECIENTE por repetición: `factor = greatest(0.1, 0.5^times_completed)`
  (1ª vez full; rehacer #1 ×0.5; #2 ×0.25; piso 0.1). Actualiza dominio + SRS pleno.
- Modo "Reforzar" (`start_practice('reinforce', skill?/unit?)`): arma la sesión con
  los ítems de MAYOR `jz_item_reinforce` de la unidad/skill/nivel (no sólo los
  fallados): re-evalúa lo que más lo necesita.

## 5. MIGRACIÓN DE DATOS (idempotente, grandfather)
- Conserva `cefr_level` por skill (nivel en curso = ya confirmado). Sin regresión.
- El dominio v2 se DERIVA de `user_item_attempts`; natalia ya tiene 84 → su dominio
  sale real. gianpiero/britoleopoldo (0 attempts) conservan su nivel y construyen
  dominio desde 0 hacia el siguiente — su nivel actual NO se pierde (su certificado
  de niveles inferiores ya fue minteado por 040).
- Hay que registrar participación de speaking retro NO es posible (sin histórico);
  aceptable: su dominio de speaking arranca por lo que practiquen desde ahora.
- `user_skill_mastery` (cache de 040, `items_correct/16`) queda OBSOLETA → el cálculo
  v2 ignora esa tabla (se puede dejar o limpiar; no se lee).

## 6. UI
- Barras de las 4 skills = `mastery_pct` v2 (por skill, su nivel en curso); radar igual.
- Estado "examen desbloqueado" por skill (≥80 %); tarjeta de examen lista las skills
  listas y las que faltan (con % y meta 80 %). Sin botón muerto.
- Celebración "¡Subió tu {skill} a {nivel}!" atada a aprobar la sección; "¡Certificaste
  {N}!" cuando las 4 cruzan N.
- Entradas a "Reforzar" en Practicar (por mayor necesidad) y por skill desde Perfil.
- Empujón Matix por skill rezagada.

## 8. AJUSTES DEL PANEL ADVERSARIAL (go-with-changes) — vinculantes

**Alcance Fase 1 (mig 041):** examen SINGLE-LEVEL (un nivel por sesión, id determinista
50000…<level> intacto) + **subida PER-SKILL**. El examen multi-nivel real (skills en
A1/B1 en una sesión, identidad de exam_id) se DIFIERE a una mig 042 — fuera de la
ventana caliente con 3 usuarios activos. Esto cumple "el nivel sube por la sección que
verifica la skill" sin rearquitecturar exam_id.

**Blockers a corregir (todos con fix acotado):**
1. wacc con guarda: `case when Σw>0 then Σ(w·cred)/Σ(w) else 0 end`; `mastery=coverage*coalesce(wacc,0)`. (0 attempts → 0, no NULL.)
2. RE-EMITIR `start_level_exam` en 041: gate por OR de skills exam-ready (≥1), single-level.
3. RE-EMITIR `submit_level_exam` per-skill: sube cefr_level+=1 SOLO en skills (a) exam-ready Y (b) sección aprobada (calificable ≥0.80; speaking participación verificable). Quita el gate avg single-level.
4. Speaking "participó" VERIFICABLE: la sección pasa sólo si p_answers trae los N ítems de speaking servidos con answer no vacío (length>0). No "≥1 item_id".
5. Stubs en user_item_attempts = participación (last_correct=true); EXCLUIR jz_is_stub en jz_item_reinforce y en todo el modo Reforzar.
6. `get_skill_mastery`, `jz_reinforce_score`, `jz_level_status` leen el nivel POR skill desde `user_skill_levels.cefr_level` (NO jz_resolve course-wide). Re-emitir las 3 en 041.
7. Per-skill gate ≥0.80 derivado de attempts; DROP `user_skill_mastery` (cache de 040) — que cualquier RPC olvidado falle ruidoso.
8. BACKWARD-COMPAT JSON: 041 conserva TODAS las claves que parsea level_exam_models.dart de 040 (working_level, exam.unlocked, exam.has_certificate, mastery_avg, certified_level, leveled_up, new_level, per_skill[]); claves nuevas (skills_ready[], raised_skills[]) sólo aditivas. `leveled_up`=true si ALGUNA skill subió.
9. ORDEN: BD (041) PRIMERO vía Management API; app DESPUÉS de confirmar 041 en prod (deploy Vercel no atómico, lag 20–45 min).
10. GATE de deploy: 3 tests en verde antes de prod — (a) contrato JSON, (b) snapshot pre/post no-regresión de los 3 usuarios, (c) E2E REST per-sección.

**Majors:** piso de mastery para gianpiero/britoleopoldo (0 attempts) → no mostrar 0% duro
donde 040 mostraba progreso (piso por checkpoints aprobados del nivel en curso);
speaking total_s=0 → mastery 0 (no auto-1.0) y clamp speaking.cefr ≤ min(cefr calificables)+1;
tope C2 (no `+1` sobre el enum: aprobar C2 = certificado C2, sin superar enum);
rollback probado = re-run 040 (idempotente); honestidad del cert: la UI distingue
"evaluado" (R/W/L) de "practicado" (S); UNIQUE(user_id,cefr_level) en certificates.

**Minor:** crédito por ítem anti-spam/retroceso = `greatest(0.4, correct_count/attempts)·[last_correct]`
(no last_correct crudo); aislar el registro de participación de speaking en su propia rama.

**Decisiones conservadas:** dominio=cobertura×precisión-ponderada on-demand; coverage satura
al 60%; nivel per-skill; cefr_level=nivel en curso; cert N cuando las 4 cruzan N; sin
auto-nivel; refuerzo recomienda + Matix rezago; rehacer XP decreciente.

## 7. VERIFICACIÓN (rigor GA10)
- Tests: cálculo de dominio (cobertura×wacc, speaking participación), compuerta 80 %
  por skill, subida per-sección (sólo la skill que aprueba sube), regla 4-skills→cert,
  XP de rehacer decreciente, refuerzo por ítem. Migración: estado antes/después de los
  3 usuarios reales.
- Pasada adversarial (multi-agente). E2E vs RPC reales. analyze 0, tests, build, deploy.
