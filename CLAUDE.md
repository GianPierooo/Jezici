# CLAUDE.md — Jezici (estado vivo)

> Contexto de arranque para cualquier sesión. **No** es copia de los 21 `.md` de
> diseño (eso es la carpeta raíz `Jezici_*.md` + `docs/`). Aquí va el ESTADO REAL,
> qué está verde, qué falta y cómo verificar. Mantener corto y al día.
> Última actualización: **2026-07-08**.

## Onboarding — NOMBRE + fidelidad al mockup ✅ (mig 132 · 2026-07-08)
Dos frentes de Onboarding.dc (fuente de diseño), sin tocar placement/create_plan.
**F1 · Correctitud: se PIDE el nombre (antes nunca).** Bug real: "Continuar con Google" (OAuth) crea
la cuenta saltándose el formulario de email → nunca se llamaba `set_profile(name)` → el perfil quedaba
en "Coloque seu nome" (`needs_name=true`). Fix en 2 capas: **(belt, mig 132)** `handle_new_user` siembra
`users.name/display_name` desde `raw_user_meta_data` (`full_name`/`name` que Google entrega) al INSERT —
solo afecta a altas NUEVAS (`on conflict do nothing`), 0 impacto en existentes. **(suspenders, cliente)**
paso de **nombre nuevo en el onboarding** (case 2, ANTES del examen), pre-rellenado desde el metadata de
OAuth (`ProgressRepository.authMetadataName`) y desde `get_profile` (alta por email ya lo fijó), persistido
con `set_profile` al continuar y de nuevo en `_finish` (idempotente, degrada offline). i18n es/en/pt.
**Verificado cliente real** (`verify_onboarding_name.py`): OAuth con `full_name` → `users.name` sembrado +
`get_profile` needs_name=false; email sin metadata → nace needs_name=true → `set_profile` del onboarding lo
persiste. **F2 · "Tu plan" fiel al mockup (FRAME B):** `your_plan_view` rehecho — **header de CELEBRACIÓN**
(gradiente violeta + confeti `jzFall` + halo `jzGlow` + guacamayo festejando `ParrotMascot.celebrate` +
kicker "PERSONALIZADO PARA TI"), **MAPA DE VIAJE** (colinas + camino punteado que asciende, `CustomPaint`
animado; pin "ESTÁS AQUÍ" = nivel actual → bandera "TU META" = meta efectiva, con milestone intermedio si
el salto ≥2 niveles), tarjeta de fecha viva (`AnimatedSwitcher`) con badge "⚡ ¡La mitad de tiempo!",
**palanca REVERSIBLE** (toggle base↔rápido que recalcula en vivo; antes solo subía por tiers), CTA coral
"Empezar mi viaje". **F2b · pasos de pregunta (FRAME A):** progreso **segmentado** + contador "n/total",
guacamayo animado con **globo blanco** ("¡Hagamos un plan a tu medida!"). Todo **reduce-motion aware**
(`MediaQuery.disableAnimations`) y responsive (`ResponsiveCenter` 480). **NO se tocó** placement anti-azar,
"empezar desde cero"→A1, elegir idioma meta, ni create_plan. Verde: **analyze 0 · test 96/96** (+widget test
"Tu plan" celebración + palanca reversible; onboarding_target camina el nuevo paso de nombre) · build web OK ·
`verify_placement_serious` re-verificado (azar→0% B2/C1, intacto). **Verificación manual pendiente de Gian**
(ver reporte): usuario nuevo Google/email → pide y guarda el nombre; "Tu plan" se ve como el mockup.

## Placement SERIO — anti-azar (bug real ARREGLADO) ✅ LIVE (mig 131 · 2026-07-08)
**Bug reproducido (no sintético):** un usuario NUEVO marcando AL AZAR salía B1/B2/**C1**. Los 3 "fixes"
previos pasaron con sims deterministas pero NO tocaron el camino real. **Causa raíz (3 factores):**
(1) **todos** los ítems de placement (incluidas las cloze) llevan `options` → la UI los presenta como
opción múltiple → **azar = 1/3 de acierto en CADA ítem**; las verificaciones previas respondían
100%/0%/persona-determinista, **nunca azar uniforme 1/3**. (2) Estimador débil: **fallback `acc≥0.5`**
(una moneda al aire promovía un nivel) + dominación con solo ~2 ítems/nivel. (3) El arranque "buen nivel"
sembraba la escalera en B1 → el azar rebotaba alto. **Evidencia ANTES** (`repro_placement_random.py`,
cliente real, 60 al azar): en/B1 **C1 5% · B2 10%** (15% inflado); pt/B1 B2 5%.
**Fix (mig 131, tuneado con `sim_placement_tune.py`, 4000 trials/caso):** (A) `jz_placement_level`
**guess-aware** — un nivel se acredita solo con evidencia SOSTENIDA (`asked≥3 & corr≥⌈0.72·asked⌉ &
corr≥3`), se toma el más alto, **se elimina el fallback laxo**, y **piso global** (acc total <0.5 → tope
A2, imposible B1+). (B) `placement_next` examen **más largo** (min 12 / max 22, reversals≥6 o pin≥4) +
**arranque CLAMPEADO a A2 máx** + skill_levels = nivel global (el split R/W sobre ~6 ítems era ruido y
subcreditaba). **Aplica a los 6 cursos** (lógica course-agnóstica). **Verificado DESPUÉS (cliente real,
`verify_placement_serious.py`, en+pt):** azar (peor caso B1) → **0% B2/C1** (en 16 A1/2 B1; pt 18 A1);
persona B1 real → B1 (10/12, 9/12); persona A2 → centro A1/A2 (nunca C1); aislamiento OK. Estimador
`verify_estimator.py` 8/8 (incl. casos anti-azar). analyze 0 · test 94/94. "Desde cero" declarado sigue
saltando el examen → A1 (`_skipPlacement`, cliente, sin cambios). El límite adyacente A2↔B1 tiene algo de
borrosidad (inherente a un CAT breve; el usuario tiene override "empezar desde el inicio").

## UI del login/auth MODERNIZADA ✅ (2026-07-08 · solo capa visual, sin tocar lógica)
`auth_screen.dart` no tenía mockup (una de las 13 sin mockup, ver MOCKUP_GAP.md) → rediseñada con el
LENGUAJE VISUAL de los mockups: **tarjeta de auth centrada** (`ResponsiveCenter` maxWidth 460 → móvil
llena, desktop centrada, no estirada) con **hero de gradiente violeta** (`#7A6BF0→#6C5CE7→#5B4ECF`) +
**guacamayo animado** (`ParrotMascot` idle bob, halo suave, respeta reduce-motion) + título/subtítulo
blancos, y **cuerpo blanco** con Google (sombra suave) + divisor «o» + toggle + campos con fill claro
(`#F6F7FB`) + **pills de error/aviso** (rojo suave / violeta, con icono) + `PrimaryButton` 3D. Fondo con
halo radial violeta. **Motion sutil:** entrada fade+sube (jzRise, 560ms, reduce-motion-aware). Fuente
Nunito + tokens de `AppColors`. **NO se tocó la lógica** (`signInWithGoogle`/`signUpEmail`/flujo OAuth
intactos); solo `build`+widgets. i18n es/en/pt (0 strings nuevos). Verificado: analyze 0, test 94/94,
build web OK, smoke visual (render limpio, 0 errores de consola). **Verificación manual pendiente de Gian:**
Android (teclado no tapa campos) + desktop (tarjeta centrada) + login Google/email de punta a punta.

## Registro sin fricción — Google Sign-In + email (beta) ✅ código LIVE (2026-07-07 · solo cliente)
Ingeniería pura, sin migración. Auth-first (GA4). **Frente 1 · "Continuar con Google" (PWA):**
`ProgressRepository.signInWithGoogle()` → `signInWithOAuth(OAuthProvider.google, redirectTo: Uri.base.origin)`
(deploy-agnóstico: prod jezici.vercel.app, previews su URL). PKCE + `detectSessionInUrl` (default) → la
sesión llega al volver y `onAuthStateChange` (main.dart) enruta. Botón en `auth_screen` **solo web** (`kIsWeb`)
+ divisor «o» + formulario email. **Degrada con gracia:** si el proveedor no está configurado, el retorno trae
`?error=`/`#error=` → `initState` lo detecta y muestra `authGoogleError` («No se pudo continuar con Google.
Intenta con tu email.»), formulario email 100% usable; `try/catch` en el tap. i18n es/en/pt. **Frente 2 · email
fluido:** `signUpEmail` ahora devuelve `bool hasSession` — con **confirm-email OFF** hay sesión inmediata
(autoconfirm, ya funcionaba); con confirm-email ON (sin sesión) muestra `authCheckEmail` («revisa tu correo»)
y NO intenta setProfile/acceptLegal (evita fallo RLS). Magic-link NO añadido (requiere SMTP; confirm-OFF ya da
alta trivial). Verificado: analyze 0, test 94/94, build web OK, **smoke visual** (botón renderiza; retorno
`?error=` muestra el aviso amable sin romper). **Sin CSP externa:** la «G» se dibuja con tipografía (sin imagen
de host externo). **NO toca el resto del onboarding.**

### ⚠️ Frente 3 · Pasos MANUALES para Gian (dashboards — solo él puede) para ACTIVAR Google:
El código ya está LIVE; el botón funciona en cuanto se complete esto (cero redeploy). Callback de Supabase =
`https://wiauinufpbkmjlbqlkxo.supabase.co/auth/v1/callback`.
1. **Google Cloud Console** (console.cloud.google.com): crea/elige un proyecto → **APIs & Services → OAuth
   consent screen**: User type **External**; app name «Jezici», support email, developer email; **scopes**
   básicos `openid`, `.../auth/userinfo.email`, `.../auth/userinfo.profile`; en **App privacy policy** pega
   `https://jezici.vercel.app/privacy` y en **Terms of service** `https://jezici.vercel.app/terms` (ya LIVE,
   públicas); **PUBLICA la app** (botón «Publish app» → estado «In production») para NO whitelistear 50 testers.
2. **Google Cloud → Credentials → Create credentials → OAuth client ID → Web application**: en **Authorized
   JavaScript origins** añade `https://jezici.vercel.app` (y `http://localhost` si pruebas local); en
   **Authorized redirect URIs** añade EXACTAMENTE `https://wiauinufpbkmjlbqlkxo.supabase.co/auth/v1/callback`.
   Copia el **Client ID** y **Client secret**.
3. **Supabase → Authentication → Providers → Google**: **Enable**, pega Client ID + Client secret, **Save**.
4. **Supabase → Authentication → URL Configuration**: **Site URL** = `https://jezici.vercel.app`; en **Redirect
   URLs** añade `https://jezici.vercel.app/**` (y la URL de preview si usas previews).
5. **Beta sin fricción de email** — **Supabase → Authentication → Providers → Email**: desactiva **«Confirm
   email»** (OFF) para que el alta por email dé sesión inmediata (o, si prefieres verificación, déjalo ON: el
   código ya muestra «revisa tu correo»). Con confirm OFF necesitas 0 SMTP.
6. Prueba: abre jezici.vercel.app → «Continuar con Google» → elige cuenta → vuelve logeado al onboarding.

## UX: TTS global + responsive ✅ (2026-07-06 · solo cliente, sin migración)
Ingeniería pura (cero IA), determinista. 2 frentes:
- **F1 · Voz al tocar cualquier palabra META.** Antes el TTS de tile (Web Speech) solo estaba en
  word_bank/reorder (`tile_arrange_exercise`). Nuevo widget reutilizable `SpeakableText`
  (`core/speech/speakable_text.dart`): tap → `WordTts.speak` (usa `SpeechLang.tts` = idioma del curso
  activo) + ícono de altavoz, disparado por TAP (sin problema de unlock iOS), interrumpible, degrada con
  gracia (no-op sin síntesis). Cableado en: **match** (columna META, speak-on-tap sin ícono), **historias**
  (glosario `story_reader`), **tips** (ejemplo en reference + lesson_complete + notebook). Excluido a
  propósito: listening/MC (no delatar la respuesta). Verificado: analyze 0, test 94/94.
- **F2 · Responsive real (móvil→desktop).** Nuevo `core/ui/responsive_center.dart` (`ResponsiveCenter`:
  `Align`+`ConstrainedBox(maxWidth)` → **no-op en móvil** cuando ancho ≤ maxWidth, así el target principal
  queda PIXEL-idéntico; solo centra/capa en ancho). Aplicado: **mapa** (fondo cielo+escenografía full-bleed
  + columna de nodos centrada vía `dx0` → sin franjas vacías; en móvil `dx0≈0` = idéntico), **loop de
  lección** (scroll + botones + feedback bar, 560), **checkpoint** (560), **onboarding/placement/resultado**
  (`OnboardingScaffold`, 480), **ligas/perfil/tienda/historias** (640). Barras/appbars/fondos siguen
  full-width; solo se centra el CONTENIDO. Verificado: analyze 0, test 94/94, build web OK, smoke visual
  móvil (auth 280px sin romper). Diferido: screenshot de viewport ancho (el preview local topa en 280px).

## Onboarding + mapa — CORRECTITUD (feedback real) ✅ (mig 124 · 2026-07-06)
5 frentes, causa real diagnosticada con cliente real antes de tocar:
- **F1 · Fuera la pregunta de intensidad.** El onboarding ya NO pregunta frecuencia/intensidad;
  se fija `intensity=3` (ALTA) por defecto para todos en `create_plan`→`user_personality`
  (`onboarding_data.dart`), la 5ª pregunta se quitó de `personality_test.dart` (quedan las 4 de
  estilo de coach). Ajustable luego en Ajustes (el control sigue ahí). NO se hace backfill de filas
  existentes (no pisar preferencias reales). Sin romper usuarios.
- **F2 · "Empezar desde cero" salta el examen.** Si en el paso de nivel de arranque elige "desde
  cero" (`startLevelHint==0`), el onboarding SALTA ubicación+resultado → plan directo A1/U1
  (`_skipPlacement` en `onboarding_screen.dart`, back coherente). El test solo corre si elige
  "sé algo"/"buen nivel"/default.
- **F3 · Override en el resultado.** `PlacementResultView` ofrece "Prefiero empezar desde el inicio"
  (botón secundario, i18n es/en/pt, con diálogo de confirmación) → fija A1 y continúa. La elección
  del usuario manda sobre el algoritmo. Solo se muestra si el resultado no fue A1.
- **F4 · Nodos bajo el nivel de entrada en DORADO.** DIAGNÓSTICO (cliente real, `diag_map_golden.py`):
  el puente de `create_plan` YA marca `completed` las 61 lecciones de U1–U12 al ubicar en B1 (61/61,
  llegan por RLS) → el mapa las pintaba **verde-completado accesible, NO candado**; el "candado" era
  de cuentas pre-puente (antes de mig 077) o del primer paint sin progreso. El intent "verse DORADO"
  se resuelve en el CLIENTE: `learn_map_screen._stateFor` sube `completed`→`mastered` (dorado) para
  unidades con nivel CEFR < nivel de entrada del plan. **NO se marca `golden` en BD**: dispararía el
  logro "impecable" (`achievements`, v_golden≥1) sin haberlo ganado (deshonesto). Verificado: U1–U12
  dorado 61/61, U13 available, resto locked.
- **F5 · Placement ágil (subir/bajar rápido).** `placement_next` (mig 124) añade parada por
  SATURACIÓN: los extremos (todo correcto/todo mal) no generan reversals y llegaban al máximo (14
  ítems); ahora paran cuando la banda se clava en un extremo (`pin≥3`) con evidencia mínima (n≥8).
  Verificado cliente real (`diag_placement_agile.py`): fuerte→C1/8, débil→A1/8, intermedio→B1/8
  (antes 14). Estimador `jz_placement_level` intacto (verify_estimator 7/7, sin sobreestimación).
- **Verde:** analyze 0 · test 94/94 · build web OK; verify_placement_wiring/multi/pt VERDES con la
  nueva RPC. Pendiente (## Cola): **TTS-global + responsive** (prompt aparte).

## C1 COMPLETO en los 6 cursos ✅ LIVE (es→de/nl mig 128/129 · es→pt mig 130 · 2026-07-06)
**es→pt C1 (mig 130) cierra el último idioma → en/pt/fr/it/de/nl TODOS A1→C1.** pt-BR norma culta:
regência culta (assistir a, preferir X a Y), conectivos (não obstante/conquanto+subj/porquanto/
outrossim/todavia≠«todavía»), clivagem+denotativas + **colocação pronominal (próclise/ênclise/
MESÓCLISE: far-se-á, dir-lhe-ia, conceder-se-á)**, idiomatismos/registro, **futuro do subjuntivo**
+ período hipotético (3 tipos) + modalização (estaria de rumor), nominalização/voz passiva
(vendem-se)/orações reduzidas/preposições cultas (mediante/perante)/e-mail formal. 6 autores nativos
pt-BR + 2 revisores adversariales C1 (fixes reales: U29 «Antes que perdermos»→«percamos» [antes que
exige subj. presente]; U27 prompt de cloze revelaba «me deram»→reformulado). Verificado cliente real
(`verify_c1_chain.py pt`): 96/96 + 96/96 distractores, camina A1→C1 30 U, U24→U25, 30/30 lecciones C1,
audio 42/42, techo honesto (6 checkpoint, 0 exam level). **NO queda ningún curso sin C1.**

## C1 es→de + es→nl ✅ LIVE (mig 128/129 · 2026-07-06)
Cerrados 2 idiomas C1 con el pipeline probado (fr/it): 6 unidades c/u (order 25-30, encadenan B2→C1;
U24 desbloquea U25), **114 ítems (R36/W36/L24/S18 → L=67% S=50%)**, audio TTS 42/42 (tl=de/nl). Currículo
C1 REAL de cada idioma: **de** — präzise Wortwahl/Kollokationen/Register, Konnektoren (dennoch/gleichwohl/
zumal/ungeachtet+Gen/mithin), Modal-/Fokuspartikeln + Spaltsatz + Vorfeld, Redewendungen, Konjunktiv II/
Vermutungsmodalverben/Konjunktiv I, Nominalstil/Passiv/**erweiterte Partizipialattribute**/formelle E-Mail;
**nl** — het juiste woord, connectoren (niettemin/nochtans/niettegenstaande+2e nv/derhalve), modale/focus-
partikels + cleft (die/dat) + vooropplaatsing, idioom/register, conditionalis/vermoeden/**aanvoegende wijs
(moge/ware)**/alsof, nominalisatie/lijdende vorm/**beknopte bijzin (gezien/gelet op)**/formele e-mail.
6 profesores nativos IA + 2 revisores adversariales nativos por idioma (fixes reales: de U26 «somit…dennoch»
incoherente→«gleichwohl», U28 «Gang» ambiguo→«Fuß»; nl U30 «aanmerking» ambiguo→«gebruik», U29 «moge» orden
verbo-final). Guard de colisión (MC/listening exacto — `jz_near_match` no aplica a MC/listening, solo cloze/
translation). **TECHO HONESTO** (igual que en/fr/it): C1 receptivo/guiado se autocalifica, writing/speaking =
proxies deterministas, **0 examen/cert de nivel C1** (solo 6 checkpoint/idioma, verificado). **Verificado
cliente real (`verify_c1_chain.py de|nl`):** determinista 96/96 + distractores 96/96 (42501); CAMINA A1→C1
las 30 unidades (U24→U25, 30/30 lecciones C1); 0 cruces entre los 6 cursos; default(en) sin fuga; audio 42/42.
CI de C1 SUCCESS. **alemán y neerlandés: es→de/nl A1→C1 completo.** Diferido (## Cola): **es→pt C1** (pt topa
en B2; andamiaje idéntico listo: STAMP `('pt','c1')=…130`, grupo audio `pt-c1`, `verify_c1_chain.py pt`).

## Reglas del agente (siempre)
- Fuente de verdad = repo + BD + cliente real, NO los docs. Paso 0 de toda misión:
  ground truth (git log + introspección de BD) y corrige discrepancias en docs.
- "Verde" = gh run list SUCCESS en GitHub Actions real (reproduce el CI en local con
  .env vacío antes de declarar). Prohibido falso verde.
- NUNCA edites el buildCommand de vercel.json (cualquier edición rompe el deploy pre-build).
- Cliente REAL (anon Y authenticated, JWT real, nunca service_role). correct_answer = 42501.
- Aislamiento multicurso (en/pt/fr/it/de/nl): toda inserción confirma con cliente real que
  cada curso recibe lo suyo, 0 cruces; jz_active_course rutea.
- MC/listening: ningún distractor puede colisionar con el correcto bajo jz_normalize
  (minúsculas/tildes/umlaut) ni jz_near_match (dist-1). Guard obligatorio.
- Profundidad > amplitud: 1 frente impecable > varios a medias. Al tope de sesión, para,
  deja lo hecho perfecto, y escribe el retome EXACTO en la sección "## Cola" de CLAUDE.md.
- Contenido nuevo: calidad de profesor nativo, 4 habilidades (listening ~65% de R/W,
  speaking ~50%), audio tl correcto text-matched, instrucciones en español, checkpoints
  frescos, gate adversarial nativo.
- Al terminar: actualiza CLAUDE.md (estado + "## Cola"), FINDINGS.md, EFICACIA_CONTENIDO.md.
  Cierre: analyze 0, tests verdes, gh run list SUCCESS, deploy READY. Reporta en 1 línea.

## Cola (retome exacto — orden sugerido)
> Estado de niveles hoy (verificado en BD): **en/pt/fr/it/de/nl TODOS A1–C1** (los 6 cursos a C1;
> C2 no sembrado en ninguno). Andamiaje probado 15× (…de C1, nl C1, pt C1): generador
> `gen_course.py <code> <a1|a2|b1|b2|c1>` (soporta pt/fr/it/de/nl; DIFF c1=0.84), audio `gen_audio_missing.py <code>-<lvl>`
> (grupos `<code>-c1` listos), verificadores `verify_b1_chain.py`/`verify_b2_chain.py`/**`verify_c1_chain.py`** `<code>`. STAMPS c1 en `gen_course.py`.
1. **C1 en los 6 cursos ✅ COMPLETADO (mig 126/127 fr/it · 128/129 de/nl · 130 pt).** Ya NO queda ningún
   idioma sin C1. Pipeline (por si se reusa para C2): 6 autores nativos por idioma + 2 revisores adversariales →
   `gen_course.py <code> c1` → apply → `gen_audio_missing.py <code>-c1` → `verify_c1_chain.py <code>`.
   **TECHO HONESTO (NO violar):** C1 = R/L/gramática/vocab se autocalifican; writing/speaking = proxies
   deterministas. **NO examen ni certificado de nivel C1** (Fase 2). Los cursos escalera no tienen exams `level`
   → el techo es automático (verificado los 6: solo 6 checkpoint C1, 0 exam level). Siguiente techo real = **C2**
   (no sembrado en ninguno; requeriría evaluación de producción libre = Fase 2 con IA).
5. **Pulidos onboarding/placement** (código): cap de la meta al tope real del curso ✅ (mig 118). **Placement a nivel
   REAL ✅ (mig 122/123, 2026-07-05):** bancos fr/it/de/nl ampliados a B1+B2 y pt a B2 (7R MC + 7W cloze/nivel);
   `placement_next` (course-scoped) ya sube el techo → un B1/B2 sale B1/B2 (no A2). Verificado cliente real
   (`verify_placement_multi.py`/`verify_placement_pt.py`): personas A1→A1…B2→B2, avanzado→B2, aislamiento, 56/56
   determinista. **Placement SERIO anti-azar ✅ (mig 131, 2026-07-08):** el azar (1/3 por MC) ya NO infla —
   estimador guess-aware + arranque clampeado a A2 + examen más largo; azar→A1 (0% B2/C1), persona→su nivel.
   Verificado con el FLUJO REAL (`verify_placement_serious.py`/`repro_placement_random.py`, cliente JWT). Pendiente:
   nombre real de la unidad de entrada por curso en `PlacementResultView` (hoy rótulo es→en); L/S en placement
   (audio). **Barrido de colisiones MC/listening ✅ (mig 117).**
6. **Diferidos menores:** historias B2 por idioma (B1 ✅ mig 125); imágenes referenciales
   fr/it/de/nl (hoy solo es→en A1/A2); copy en-first fuera del onboarding (`missionMainDescription` «100 palabras del
   inglés», `errorReviewWhy*`); cert de nivel por curso (fr/it/de/nl sin examen/cert de nivel aún); C1/C2; cron de
   cierre de ligas; Sentry DSN + sello JZ_BUILD (requieren a Gian, ver secciones abajo).

## Qué es
App de aprendizaje de idiomas (estilo Duolingo). **Flutter (web PWA)** + **Supabase**
(Postgres + RLS + RPCs SECURITY DEFINER) + **Vercel** (deploy del web). Repo
`github.com/GianPierooo/Jezici`, deploy `jezici.vercel.app`.
- 6 cursos: **es→en** (A1–C1), **es→pt** (A1–B2), **es→fr** (A1–C1), **es→it** (A1–C1),
  **es→de** (A1–B2) y **es→nl** (A1–B2). Curso activo por usuario
  (`jz_active_course`). Selector en Ajustes.
- Loop: lección → ejercicios (9 tipos) → grading **server-side** → XP/oro/vidas →
  checkpoints (≥80%) → exámenes de nivel + certificados. Práctica/SRS, logros, ligas
  semanales, racha, Matix (notificaciones), onboarding con placement.
- **Grading 100% server-side** (`grade_item`, mig 055): el cliente nunca recibe la
  respuesta antes de responder. `correct_answer` revocado (lectura directa → `42501`).

## Pilotos es→fr + es→it (A1 + A2) — ✅ LIVE (mig 094–098 · 2026-07-02)
- **2 cursos NUEVOS, A1 Y A2 sembrados y verdes:** **es→fr** (course `…0003`, lang `fr`/Français) y
  **es→it** (course `…0004`, lang `it`/Italiano), ambos `is_active`. **A1 (mig 094/095) + A2 (mig
  097/098) completos** con el molde validado es→pt: 6 unidades por nivel (A1 order 1-6, A2 order
  **7-12** → encadenan; `submit_checkpoint` desbloquea la unidad con order mayor del MISMO curso →
  **gating A1→A2 automático y course-scoped**), 4 lecciones + checkpoint fresco + examen por unidad.
  **115 ítems por nivel** (460 fr+it), 4 habilidades balanceadas (A1 fr R38/W36/L23/S18 L=62%/S=49%;
  A2 fr/it R36/W36/L25/S18 L=69%/S=50%). Temas A2: passé composé/passato prossimo (avoir/avere→être/
  essere+concordancia), futur/futuro, viaje, comer-fuera/comparativos, imparfait/imperfetto+pronombres
  COD/diretti, salud/consejos («avoir mal à»/«avere mal di»). Autorado por profesores nativos IA
  (fr/it, NO traducción mecánica) + **validación adversarial nativa por nivel**: A1 fr 1 error real
  (`midi et demie`→`midi et demi`), it 0; **A2 fr 0 errores + 2 pulidos, it 0 errores + 2 pulidos**
  (todos aplicados). **Audio TTS** (`gen_audio_missing.py` tl=fr/it): fr A1 41 + A2 43, it A1 43 +
  A2 43 = **170/170** en Storage, texto-emparejado. Generador reutilizable **PARAMETRIZADO POR NIVEL**
  `tools/content/gen_course.py <code> <a1|a2>` (lee `<code>_<level>_u*.json`, ordena por `unit.order`,
  ids uuid5 sin colisión entre niveles/cursos; corrigió también el título it A1 «Unité»→«Unità»).
  Selector de Ajustes los muestra (banderas 🇫🇷/🇮🇹; `label`/nombre desde DB).
- **AISLAMIENTO multicurso (el riesgo #1, ya roto una vez con pt mig 064→072) — VERIFICADO con
  cliente real** (`verify_new_course.py fr|it`, JWT real, nunca service_role): **0 `lesson_items`
  cruzan los 4 cursos**; determinista fr 97/97 + it 97/97 correctos aceptados y 97/97 distractores
  rechazados (`correct_answer` 42501); `set_active_course`→`create_plan`/`start_practice` sirven
  SOLO el curso activo; usuario default(en) NO recibe fr/it; cadena lección(100%)+checkpoint(≥80%)
  por curso; audio HEAD 200. **A2 (`verify_a2_chain.py fr|it`): CAMINA las 12 unidades EN ORDEN con
  cliente real** (complete_lesson×lección + submit_checkpoint×checkpoint) → prueba el gating A1→A2
  end-to-end (U6 desbloquea U7), 30/30 lecciones A2 completadas, determinista A2 97/97, audio A2 43/43.
  **Cursos existentes INTACTOS:** `verify_chain` (es→en A1→B2) y `verify_pt_chain` (es→pt A1→B1
  multicurso) verdes tras cada tanda. analyze 0 · test 89/89.
- **Fix de fondo `create_plan` (mig 096):** `create_plan` **hardcodeaba** el curso más-antiguo-activo
  (`courses where is_active order by created_at limit 1` = es→en) IGNORANDO el curso activo → con
  >1 curso sembraba el plan/progreso/unidad-de-entrada en el curso EQUIVOCADO. Ahora usa
  `jz_active_course()`. **Cero regresión en es→en** (usuario nuevo sin fila `user_active_course` →
  fallback al mismo más-antiguo-activo=en). El onboarding actual NO llama `set_active_course` (elige
  curso en Ajustes vía `start_course`), así que no afloraba en la app, pero el fix es correcto y
  future-proof. `placement_next` ya era course-aware (recibe `p_course`); **banco de placement
  fr/it/de/nl ✅ (mig 110, 2026-07-03)** → ya ubica en su nivel real (ver fila **Test de ubicación**).
- **B1 es→fr ✅ LIVE (mig 113, 2026-07-03):** 6 unidades (order 13-18, encadenan A2→B1; U12 desbloquea
  U13), **114 ítems (R36/W36/L24/S18 → L=67% S=50%)**, audio TTS tl=fr **42/42**. Currículo B1 REAL:
  **subjonctif présent** (Il faut que/bien que…), **futur & conditionnel** (-ai vs -ais, si+imparfait),
  **pronoms relatifs** (qui/que/dont/où), **accord du participe passé** (être/avoir+COD antepuesto/
  pronominales), **discours indirect** (que/si/ce que + concordancia de tiempos), **pronoms compléments**
  (le/lui/y/en + doble pronombre). 6 profesores nativos IA + **rebalanceo/revisión adversarial nativa**
  (fixes reales: «pour qu'elle» élision, `accepted` que aceptaba «ou» por «où» removido, «s'il»,
  distractores audibles prise/mise para accord, «si j'aurais» como distractor correcto). **Verificado
  cliente real (`verify_b1_chain.py fr`):** determinista 96/96 + 96/96 distractores (42501); **CAMINA
  A1→B1 las 18 unidades** (U12→U13, 30/30 lecciones B1); **0 lesson_items cruzan los 6 cursos**;
  default(en) sin fuga; audio 42/42. **es→de B1 ✅ (mig 111).**
- **B1 es→it ✅ LIVE (mig 114, 2026-07-05):** 6 unidades (order 13-18, encadenan A2→B1; U12 desbloquea
  U13), **114 ítems (R36/W36/L24/S18 → L=67% S=50%)**, audio TTS tl=it **42/42**. Currículo B1 REAL:
  **congiuntivo presente** (parli/prenda/finisca + irregulares sia/abbia/faccia/vada/venga; Penso/È importante/
  benché/a meno che, contraste indicativo/congiuntivo), **futuro semplice + condizionale + periodo ipotetico I**
  (parlerò/sarò/vorrei/dovresti; Se piove resto), **pronomi relativi** (che/cui + prep. a-di-in-con-per/il quale/
  il cui/chi/dove), **concordanza del participio** (essere→sujeto è andata/sono uscite; avere+lo/la/li/le antepuesto
  l'ho vista/li ho comprati), **discorso indiretto** (dice/ha detto che + concordanza imperfetto/trapassato/
  condizionale composto; chiedere se; dire di+inf; deícticos), **pronomi combinati, ci e ne** (ci/ne partitivo;
  me lo/te lo/ce lo/glielo/gliene; ce n'è). 6 profesores nativos IA + **revisión adversarial nativa** (fixes reales:
  U13 listening casi-homófono finisca/finisce reescrito, U17 «tornare il giorno prima»→«il giorno dopo», U18
  «me lo presto»→«te lo presto» lógico + near-homófonos me lo/te lo/ce lo y reorder ambiguo rehechos). **Verificado
  cliente real (`verify_b1_chain.py it`):** determinista 96/96 + 96/96 distractores (42501); **CAMINA A1→B1 las 18
  unidades** (U12→U13, 30/30 lecciones B1); **0 lesson_items cruzan los 6 cursos**; default(en) sin fuga; audio 42/42.
- **B2 es→fr ✅ LIVE (mig 20260705120119, 2026-07-05):** 6 unidades (order 19-24, encadenan B1→B2; U18 desbloquea
  U19), **114 ítems (R36/W36/L24/S18 → L=67% S=50%)**, audio TTS tl=fr **42/42**. Currículo B2 REAL: **subjonctif passé**
  (que j'aie fini/qu'elle soit venue; regret/antériorité), **conditionnel passé + irréel du passé** (j'aurais dû;
  Si+plus-que-parfait→conditionnel passé) **& concordance des temps**, **discours indirect au passé avancé**
  (présent→imparfait, passé→plus-que-parfait, futur→conditionnel; ce que/ce qui/si; impératif→de+inf; la veille/le
  lendemain), **participe présent, gérondif & adjectif verbal** (parlant invariable vs fatigant/fatiguant; en+ant),
  **connecteurs B2** (bien que/pour que/à condition que+subj vs alors que/tandis que+ind; cependant/par conséquent/
  en revanche), **voix passive avancée + mise en relief** (on/se faire/pronominale de sens passif; c'est…qui/ce que…
  c'est). 6 profesores nativos IA + **revisión adversarial nativa** (fixes reales: subjonctif con sujeto idéntico→
  infinitivo «d'avoir fini», élision «ce qu'» ante je removida, 2 word_bank/reorder triviales barajados). **Verificado
  cliente real (`verify_b2_chain.py fr`):** determinista 96/96 + 96/96 distractores (42501); **CAMINA A1→B2 las 24
  unidades** (U18→U19, 30/30 lecciones B2); **0 lesson_items cruzan los 6 cursos**; default(en) sin fuga; audio 42/42.
- **B2 es→it ✅ LIVE (mig 20260705120120, 2026-07-05):** 6 unidades (order 19-24, encadenan B1→B2; U18 desbloquea
  U19), **114 ítems (R36/W36/L24/S18 → L=67% S=50%)**, audio TTS tl=it **42/42**. Currículo B2 REAL: **congiuntivo
  imperfetto/trapassato** (fossi/avessi/facessi; avesse+participio; concordanza «Pensavo che fosse»), **periodo
  ipotetico II/III + condizionale passato** (Se avessi tempo verrei; Se avessi studiato avrei superato; regret/
  futuro nel passato/notizia non confermata), **forma passiva** (essere+participio+accord/venire tiempos simples/
  andare=dovere essere/si passivante), **discorso indiretto avanzado** (concordanza completa presente→imperfetto,
  passato→trapassato, futuro→condizionale composto; domande indirette+congiuntivo; di+inf; deícticos), **connettivi
  B2** (benché/sebbene/purché/a meno che+congiuntivo vs anche se/mentre/siccome+indicativo; tuttavia/quindi/di
  conseguenza/inoltre), **nominalizzazione + relativi avanzati + frasi scisse** (infinito sostantivato, -zione/-mento;
  il quale/i cui/ciò che/chi; È…che/È…a; registro cortés). 6 profesores nativos IA + **revisión adversarial nativa**
  (fixes reales: reorder run-on «di conseguenza» reescrito con punto y coma, colisión cloze «i cui»/«il cui» dist-1
  → convertido a word_bank, 2 accepted femeninos «ricca»/«partita», 1 trivial reorder barajado). **Verificado cliente
  real (`verify_b2_chain.py it`):** determinista 96/96 + 96/96 distractores (42501); **CAMINA A1→B2 las 24 unidades**
  (U18→U19, 30/30 lecciones B2); **0 lesson_items cruzan los 6 cursos**; default(en) sin fuga; audio 42/42.
  **italiano es→it: A1→B2 completo.**
- **C1 es→fr ✅ LIVE (mig 126) + C1 es→it ✅ LIVE (mig 127), 2026-07-05:** 6 unidades c/u (order 25-30, encadenan
  B2→C1; U24 desbloquea U25), **114 ítems (R36/W36/L24/S18 → L=67% S=50%)**, audio TTS 42/42. Currículo C1 REAL:
  precisión y matiz léxico (le mot juste / il termine esatto, registros, colocaciones), argumentar y persuadir
  (connecteurs: néanmoins/quand bien même/dans la mesure où · nondimeno/per quanto+cong/dal momento che), énfasis y
  mise en relief (c'est…que/ce dont…c'est · frasi scisse è…che/è…a, inversion/anteposizione, litote), modismos y
  registro (tomber dans les pommes/tirer son épingle du jeu · in bocca al lupo/tirare a campare; soutenu/familier),
  hipótesis y modalidad avanzada (à supposer que/pour peu que+subj, conditionnel journalistique · qualora/purché+cong,
  condizionale giornalistico, congiuntivo in relative), lengua académica/profesional (nominalisation, il convient de/
  il ressort de · si ritiene che/va rilevato che, voz pasiva, conectores académicos, email formal). 6 profesores nativos IA
  + 2 revisores adversariales por idioma (fixes reales: fr accepted «a»/«qu'» agramaticales + rebalanceo U29 + hueco cloze U30;
  it mezcla de idiomas U25 + congiuntivo `dobbiamo`→`debba` U29). **Verificado cliente real (`verify_c1_chain.py fr|it`):**
  determinista 96/96 + 96/96 distractores (42501); **CAMINA A1→C1 las 30 unidades** (U24→U25, 30/30 lecciones C1);
  0 cruces entre los 6 cursos; default(en) sin fuga; audio 42/42. **TECHO HONESTO** (igual que en): C1 receptivo/guiado
  se autocalifica (writing/speaking = proxies deterministas), **sin examen ni certificado de nivel C1** (Fase 2) →
  verificado: fr/it C1 solo 6 checkpoint, 0 exam `level`, 0 certificates. **fr y it: es→fr/it A1→C1 completo.**
- **Diferido (retome del piloto):** C1 es→de/nl/pt (andamiaje listo; ver "## Cola" ítem 1); cablear onboarding fr/it-específico (el onboarding ya deja elegir curso META,
  el placement corre por curso); imágenes fr/it; cert de nivel; C1 fr/it.

## Pilotos es→de + es→nl (A1 + A2) — ✅ LIVE (mig 100/101/104/105 · 2026-07-03)
- **2 cursos NUEVOS (5º y 6º), A1 Y A2 completos:** **es→de** (course `…0005`, lang `de`/Deutsch) y
  **es→nl** (course `…0006`, lang `nl`/Nederlands), ambos `is_active`. Molde validado es→fr/it:
  6 unidades por nivel (A1 order 1-6, A2 order 7-12 → encadenan; gating A1→A2 automático), 4
  lecciones + checkpoint fresco + examen por unidad. **115 ítems por nivel** (460 de+nl · R36/W36/L25/S18 →
  L=69% S=50%). Autorados por **workflow ultracode** (profesores nativos IA + revisores adversariales
  nativos por nivel). **Audio TTS** tl=de/nl: A1 43 + A2 43 = **86/86 cada idioma** en Storage.
  Temas A2 (mig 104/105): Perfekt/Perfectum (haben/hebben→sein/zijn+concordancia), futuro (Präsens+werden /
  gaan+zullen), viaje, comer fuera/comparativo (als/dan, größer/groter), Präteritum/imperfectum
  (war-hatte / was-had)+descripción, cuerpo+salud (wehtun dativo / hoofdpijn compuesto, consejos sollen/moeten).
  **Revisión adversarial A2: de 0 ❌ + 1 pulido (variante de orden TeKaMoLo en accepted); nl 0 ❌ + 0 ⚠️.**
- **Gramática real por idioma:** de — género der/die/das, **edad con SEIN** («Ich bin 20 Jahre
  alt», NO haben), sustantivos con mayúscula, acusativo ein→einen, du/Sie, ß/ä/ö/ü (tolerancia
  ss/ae/oe/ue en `accepted`); nl — **de/het** (het water/brood/station…), **edad con ZIJN** («Ik
  ben 20 jaar oud»), diminutivos -je, orden V2. Revisión adversarial: de 2 ❌ menores (distractores
  de word_bank), nl 3 reales (calco «Ik ben goed»→«Het gaat goed»; «Ik hou van…» no enseñado;
  distractor ambiguo) — **todos corregidos**.
- **AISLAMIENTO de los 6 cursos (el riesgo #1) — VERIFICADO cliente real** (`verify_new_course.py
  de|nl` A1 + `verify_a2_chain.py de|nl` A2, JWT): **0 `lesson_items` cruzan los 6 cursos**
  (en/pt/fr/it/de/nl); determinista A1 y A2 de/nl 97/97 correctos + 97/97 distractores (42501);
  `set_active_course`→`create_plan`/`start_practice` sirven SOLO el curso activo; default(en) NO
  recibe de/nl; **A2: CAMINA las 12 unidades en orden (U6 desbloquea U7, 30/30 lecciones A2), gating
  A1→A2 end-to-end**; audio HEAD 200. **Cursos existentes INTACTOS** (verify_chain en · verify_pt_chain pt).
  Banderas 🇩🇪/🇳🇱 + `SpeechLang` de-DE/nl-NL (TTS/reconocedor). analyze 0 · test 91/91.
- **B1 es→de ✅ LIVE (mig 111, 2026-07-03):** 6 unidades (order 13-18, encadenan A2→B1; U12 desbloquea
  U13), **114 ítems (R36/W36/L24/S18 → L=67% S=50%)**, audio TTS tl=de **42/42**. Currículo B1 REAL:
  **Konjunktiv II** (würde/hätte/wäre, cortesía/deseos/consejos), **Nebensätze & Konnektoren**
  (weil/dass/obwohl + deshalb/trotzdem, orden verbo-final), **Relativsätze** (der/die/das/den/dem),
  **Passiv** (werden + Partizip II, wurde), **Verben mit Präposition + Genitiv** (warten auf, Angst vor,
  des Buches), **Konjunktiv II der Vergangenheit** (hätte/wäre + Partizip, condicional irreal). Autorado
  por 6 profesores nativos IA + **rebalanceo/revisión adversarial nativa** (distractores de par-mínimo,
  tolerancia ss↔ß/ae-oe-ue↔umlaut, haben/sein en Konjunktiv II, Genitiv -s). `gen_course.py de b1`
  (STAMPS/DIFF b1) + robustez `topic` faltante. **Verificado cliente real (`verify_b1_chain.py de`):**
  determinista 96/96 correctos + 96/96 distractores (42501); **CAMINA A1→B1 las 18 unidades** (U12→U13,
  30/30 lecciones B1); **0 lesson_items cruzan los 6 cursos**; default(en) sin fuga; audio HEAD 42/42.
- **B2 es→de ✅ LIVE (mig 115, 2026-07-03):** 6 unidades (order 19-24, encadenan B1→B2; U18 desbloquea
  U19), **114 ítems (R36/W36/L24/S18 → L=67% S=50%)**, audio TTS tl=de **42/42**. Currículo B2 REAL:
  **Konjunktiv I** (indirekte Rede formal: er habe/sei/werde), **Passiv erweitert** (mit Modalverben,
  Zustandspassiv, sich lassen/sein+zu+Inf), **Partizip als Adjektiv** (Partizip I/II attributiv +
  declinación), **Konnektoren B2** (je…desto, sowohl…als auch, weder…noch, nicht nur…sondern auch),
  **Nominalisierung + Funktionsverbgefüge** (das Lesen; Entscheidung treffen, in Frage stellen),
  **Genitiv-Präpositionen + Präpositionaladverbien** (wegen/trotz/während + darauf/worüber). 6 profesores
  nativos IA + **rebalanceo/revisión adversarial nativa** (Konjunktiv I audible, «Ein reparierter Auto»→
  «repariertes» [neutro] en accepted, FVG treffen≠machen, Genitiv -s, distractores audibles). **Verificado
  cliente real (`verify_b2_chain.py de`):** determinista 96/96 + 96/96 distractores (42501); **CAMINA A1→B2
  las 24 unidades** (U18→U19, 30/30 lecciones B2); **0 lesson_items cruzan los 6 cursos**; default(en) sin
  fuga; audio HEAD 42/42. **Fix de colisión:** MC «Das Lesen»/«Das lesen» difería solo en mayúscula y
  `jz_grade` pasa a minúsculas (near-match NO aplica a MC, sí el lowercase) → aceptaba el distractor;
  corregido (Lesen/Lesung/Leser) + guard norm-exacto en TODOS los B2 (0 colisiones, 92/92 distractores
  rechazados) + `gen_course.py` robusto ante `prompt` faltante. **alemán es→de: A1→B2 completo.**
- **B1 es→nl ✅ LIVE (mig 112, 2026-07-03):** 6 unidades (order 13-18, encadenan A2→B1; U12 desbloquea
  U13), **114 ítems (R36/W36/L24/S18 → L=67% S=50%)**, audio TTS tl=nl **42/42**. Currículo B1 REAL:
  **conditionalis** (zou + inf: cortesía/deseos/hipótesis), **bijzinnen & voegwoorden** (omdat/dat/hoewel/
  als + daarom/dus, werkwoord achteraan), **relatieve bijzinnen** (die/dat/wie/waar), **lijdende vorm**
  (worden/werd + voltooid deelwoord, door), **vaste voorzetsels + «om…te»** (wachten op, denken aan,
  houden van), **voltooid verleden + conditionalis verleden** (had/was + deelwoord; zou hebben/zijn +
  deelwoord). 6 profesores nativos IA + **rebalanceo/revisión adversarial nativa** (als=voegwoord no
  voornaamwoord, «maar toch», gereisd por 't kofschip, distractor «kok»→«koken» dist-2, listening de
  «om…te» con distractores audibles, guard de colisión MC). **Verificado cliente real (`verify_b1_chain.py
  nl`):** determinista 96/96 + 96/96 distractores (42501); **CAMINA A1→B1 las 18 unidades** (U12→U13,
  30/30 lecciones B1); **0 lesson_items cruzan los 6 cursos**; default(en) sin fuga; audio 42/42.
- **B2 es→nl ✅ LIVE (mig 116, 2026-07-05):** 6 unidades (order 19-24, encadenan B1→B2; U18 desbloquea
  U19), **114 ítems (R36/W36/L24/S18 → L=67% S=50%)**, audio TTS tl=nl **42/42**. Currículo B2 REAL:
  **indirecte rede** (tijdsverschuiving was/had/zou, dat/of), **lijdende vorm gevorderd** (met modalen,
  onpersoonlijk «er wordt/werd», perfectum «is/zijn + deelwoord» sin «geworden», agente «door»),
  **deelwoord als bijvoeglijk naamwoord** (tegenwoordig -end/-ende vs voltooid ge-…-d/-t/-en + verbuiging
  -e/-Ø según de/het/een), **complexe voegwoorden** (niettemin/desondanks/daarentegen + inversie;
  zowel…als/noch…noch; hoewel/ofschoon werkwoord achteraan), **nominalisatie** (het+infinitief; werkwoord→
  zelfstandig naamwoord met -ing/-heid), **«zou hebben/zijn + deelwoord»** (irrealis del pasado) + register
  u/je. 6 profesores nativos IA + **rebalanceo/revisión adversarial nativa** (colisiones norm-exactas
  corregidas: «moest»/«moet» → «moest/wilde/kon»; «Hoewel het regende»→«hard regende»; listening casi-
  homófonos rediseñados «bleef zij»→«werd zij boos», «koken»/«koker»→«wonen»; 2 cloze sin hueco corregidos;
  verbuiging het/een verificada). **Verificado cliente real (`verify_b2_chain.py nl`):** determinista 96/96 +
  96/96 distractores (42501); **CAMINA A1→B2 las 24 unidades** (U18→U19, 30/30 lecciones B2); **0 lesson_items
  cruzan los 6 cursos**; default(en) sin fuga; audio HEAD 42/42. **neerlandés es→nl: A1→B2 completo.**
- **Diferido:** imágenes; onboarding de/nl-específico; C1+ de/nl.

## Stack / mecánica clave
- **Contenido es DB-driven**: los seeds/fixes son migraciones → quedan LIVE al aplicar,
  sin deploy de la app. Audio en Supabase Storage (`audio/items/<id>.mp3`), independiente de Vercel.
- **Migraciones**: `tools/content/apply_sql.py <archivo.sql>` (Management API, registra en
  `schema_migrations`). Secretos desde `../../.env` (gitignored) — **nunca** hardcodear
  `service_role`/`sbp_` (push protection de GitHub rechaza).
- **Deploy**: push a `main` → Vercel reconstruye (clona Flutter, `flutter build web`).
  Config en `vercel.json` (dart-defines SUPABASE_URL/ANON_KEY + JZ_BUILD=commit sha).

## Deploy de Vercel — RESUELTO ✅ (2026-06-23, fix `68266d3`)
- **El "bloqueo" NO era billing: era una regresión de `vercel.json`.** El commit
  `25f49c9` (19-jun) añadió `--dart-define=JZ_BUILD=$VERCEL_GIT_COMMIT_SHA` al
  `buildCommand`. Desde ahí TODOS los deploys daban **ERROR instantáneo pre-build, sin
  logs** (`buildingAt==ready`). **Confirmado por aislamiento:** revertir el
  `buildCommand` a la config **byte-idéntica a 7e26824** (sin ese `--dart-define`) →
  deploy **READY en ~152 s**. Cualquier variante con el flag JZ_BUILD (incluida
  `$(git rev-parse …)`) era rechazada pre-build → **no reintroducir el sello en el
  buildCommand**. Producción de nuevo LIVE con TODO el código nuevo (audio + seguridad).
- **Sello `JZ_BUILD` — lado-app LISTO, inyección BLOQUEADA en vercel.json (sigue `dev`).**
  ⚠️ **Re-confirmado 2026-06-24:** **CUALQUIER** edición del `buildCommand` de vercel.json (incluso
  añadir `&& bash ../scripts/stamp_build.sh`, SIN `$`) → deploy **ERROR instantáneo pre-build, 0 logs**
  (commit 0389b1a). El buildCommand debe quedar **byte-idéntico** al string vivo. No basta con evitar
  `$VAR`/`$()`: NO TOCAR el buildCommand, punto.
  - **Lo que SÍ está hecho y es CI-verde (commit 0389b1a):** `core/app_info.dart` `appBuild()` lee
    `window.JZ_BUILD` en runtime (`app_info_stamp_web.dart`, js_interop; stub `_io`), lo muestra en
    el pie de Ajustes y Sentry lo usa de `release`. `scripts/stamp_build.sh` inyecta
    `<script>window.JZ_BUILD="<sha7>"</script>` en `build/web/index.html` (idempotente; sin SHA cae a
    `dev`). index.html va no-store (sw v4) → reflejaría el bundle real. Falla con gracia: sin inyector,
    `appBuild()`='dev' (sin regresión).
  - **Para ACTIVARLO (única vía deploy-safe, requiere a Gian):** añadir el paso post-build en el
    **Build Command del DASHBOARD de Vercel** (Project Settings → Build & Development), NO en vercel.json:
    `… --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY && bash ../scripts/stamp_build.sh`. Si el
    dashboard también lo rechaza, el sello queda diferido (limitación de plataforma de este proyecto).
- Mecánica normal restaurada: push a `main` → Vercel reconstruye → deploy. Migraciones
  (Supabase) siguen teniendo efecto YA, independientes del deploy.
- **2 bugs de Android PWA arreglados (2026-06-24):** (1) **pantalla negra al volver de
  background** — no había manejo de resume; fix en `app/web/index.html` (visibilitychange/
  pageshow → `resize` sintético + webglcontextlost/restored), deploy-safe, NO toca buildCommand.
  (2) **checkpoint "se corta"** — safe-area inferior faltante; `MediaQuery.paddingOf().bottom` en
  checkpoint_intro/result + certificate. Verificación manual del dueño en FINDINGS.md.
- **Smoke post-deploy 2026-06-23 (prod `b34b568`) ✅ TODO VERDE** (cliente real, sin
  service_role): loop core (`correct_answer` 403/sin col, `grade_item` OK), seguridad
  mig 058 (ligas 403, gate admin, export 24 secc.), ligas/leaderboards mig 059 (32
  combinaciones sin UUID_LEAK, paginación, rollover idempotente), **audio 312/312**,
  PWA `sw v4`+no-store+aviso de update (sello `JZ_BUILD`=`dev`, conocido). Suites:
  analyze 0 · test 42/42 · verify_chain es→en · verify_pt_chain · e2e_audit PASS.
  Detalle + **checklist manual para Gian (iPhone/Android)** en FINDINGS.md.

## Estado por área
| Área | Estado |
|---|---|
| **i18n (idioma de la UI es/en/pt)** | ✅ **REAL y live (commits `c1654d0`+`3f8f7f8`).** Antes el selector era **cosmético** (no había infra l10n; nada consumía `localeProvider` → elegir English/Português no cambiaba nada = el "idioma raro" del feedback). Ahora: `flutter_localizations`+`intl`+**gen-l10n** (ARB `es`/`en`/`pt` en `app/lib/l10n`, salida a fuente, `l10n.yaml`); `MaterialApp` consume `Locale` de `localeProvider` (persistido) → cambiar idioma re-renderiza la UI **al instante**. Selector NUEVO en **Ajustes** ("Idioma de la app") + cambio en vivo en el paso de idioma del onboarding. **Traducido 100%** (es/en/pt, ~260 claves): **onboarding + auth** (superficie del feedback; copy "idioma de la app vs objetivo" aclarado) y **loop de lección completo** (player, complete, preview, checkpoint intro/player/result, no_hearts, error_review, 6 ejercicios). Fecha del plan localizada (`MaterialLocalizations.formatMediumDate`), duración (`duration_format.dart`) y nombres de habilidad (`skill_names.dart`) por idioma. **Distinción clave:** i18n = chrome de la UI; el **CURSO** (es→en/es→pt = lo que se aprende) es contenido de la DB, NO se toca. Test `i18n_test.dart` (el locale cambia el texto; plurales/placeholders). **Cobertura extendida (2026-07-02, ~200 claves más):** **home/mapa** (learn_map, top bar a11y, misión), **ligas + leaderboards** (segmentos, zonas, métricas/ventanas/alcance, división localizada vía `division_names.dart`), **tienda + racha** (tarjetas, hitos, congelador), **perfil** (4 habilidades, plan, stats, certificados, examen/gate de dominio, "Para ti", editar perfil) — fechas por `MaterialLocalizations.formatMediumDate/formatMonthYear`, plurales (racha/jugadores/días/habilidades), reutilización de `skillName()`/`planFocus*`. **Diferido (en español, punto de retome):** Ajustes (cuerpo), práctica (SRS/débil/timed), notificaciones/Matix, inmersión/historias, level_exam, premium, legal (texto sustantivo), reference, notebook. |
| **Test de ubicación + arranque** | ✅ **preciso y live (server-driven, mig 075/076/077).** Antes: test 100% cliente con 20 ítems hardcoded en Dart + nivel = **MEDIA** de las preguntas (subestimaba → un B2 salía A1/B1) **y** `create_plan` **ignoraba** el nivel (siempre Unidad 1). Ahora: **`placement_next`** (RPC stateless, **calificado en servidor** con `jz_grade`, `correct_answer` 42501) con selección **escalera 1-up/1-down** + estimador **TECHO** (ubica en el nivel más alto manejado consistentemente) + per-skill reading/writing. Banco real **48 ítems A1→C1** (5+5/nivel, validados adversarialmente), tag `placement` (excluido de pools). **Puente**: `create_plan` mapea `current_level`→**unidad de entrada** (A1=1·A2=7·B1=13·B2=19·C1=25), marca lo inferior `completed` (accesible, sin XP), entrada `available`. Avance del mapa es por cadena → seguro (examen/cert siguen gateados por dominio). **Verificado cliente real:** personas A1/A2/B1/B2/C1 → su nivel EXACTO (B2 incluso con hint malo); B2→arranca en U19, A1→U1. Cliente = **relay** (sin banco ni estimador local). **Robustez + resultado (mig 089):** el techo ingenuo SOBREESTIMABA (un acierto suelto en alto promovía); ahora **"techo con evidencia"** — un nivel se domina solo con `asked≥2 & correct≥2 & acc≥2/3`; el más alto dominado (no promueve por azar/suelto). +5 ítems C1 (banco C1 7R+6W), `placement_next` junta más evidencia (min 8/max 14, reversals≥4). **Fecha realista (estimation.dart):** el "2 semanas a C1" venía de la sobreestimación + `needed` negativo; ahora la **meta efectiva siempre > nivel actual** (si placement ≥ meta, apunta al siguiente nivel) y la duración se muestra humana (semanas/meses/**años**, no "789 semanas"); horas-guía reales (C1≈750h). **Pantalla de RESULTADO** (`PlacementResultView`, paso nuevo del onboarding): "Tu nivel: X" + desglose 4 habilidades + unidad de entrada + fecha realista (ubicación, no aprobar/reprobar). Verificado: `verify_estimator.py` 7/7 (incl. acierto-suelto NO salta), personas A1–C1 exacto, +6 tests Dart. **Banco es→pt ✅ (mig 093, 2026-07-02):** 42 ítems (A1/A2/B1 × 7R+7W) pt-BR, curso `…0002`, tag `placement`; validación adversarial (profesor pt-BR: 39/42 impecables, 1 fix de regência "assistir a", 2 distractores endurecidos) + guardas anti-colisión (cloze sin distractor a distancia-1 del correcto, ya que `jz_near_match` perdona insert/borrado; MC = exacto). **Verificado cliente real** (`verify_placement_pt.py`): determinista 42/42 (correctos aceptados, distractores rechazados sin near-match), personas A1→A1/A2→A2/B1→B1/avanzado→B1 (techo honesto: pt tope B1), **multicurso: todo curso pt, `placement_next(en)` sin fuga**. **Bancos fr/it/de/nl ✅ (mig 110, 2026-07-03):** 112 ítems (28/curso = A1+A2 × 7 reading MC + 7 writing cloze) — cubren SOLO los niveles que existen en esos cursos (A1-A2) → **techo honesto A2** (análogo al techo B1 de pt), no ofrecen ubicar donde no hay contenido. **Cableado = el propio banco** (placement_next(p_course) ya es course-scoped; NO se tocó el RPC). Autorados por profesores nativos IA (fr/it/de/nl) + **validación adversarial nativa por idioma** (fr 1 fix: «aussi…que»→«beaucoup»; nl 1 fix: «hebben» ambiguo por «zij»→«waren»; it 0, de 0) + **guarda anti-colisión AUTOMÁTICA** en `gen_placement_multi.py` (asevera que ningún distractor de cloze es perdonable por `jz_near_match` — indel dist-1 palabra única, cualquier edición dist-1 multi-palabra). **Verificado cliente real (`verify_placement_multi.py`, JWT):** determinista 28/28 correctos + 28/28 distractores por idioma (correct_answer 42501); personas **A1→A1, A2→A2, avanzado→A2** (techo honesto) en los 4; **aislamiento: placement_next(fr/it/de/nl) sirve SOLO su curso, placement_next(en) sin fuga** → 0 cruces entre los 6 cursos; en/pt INTACTOS. **Re-placement por-idioma CABLEADO ✅ (2026-07-03):** al cambiar de curso en **Ajustes**, un diálogo ofrece «¿Hacer el test de ubicación de <idioma>?» → corre `placement_next(<curso>)` con SU banco → `PlacementResultView` reutilizada (localizada) → aplica nivel→unidad de entrada con `create_plan` (course-scoped). Antes: cambiar de curso = caer en A1. `placementNext` ahora acepta `courseId` (null = onboarding en); `fetchPlan`/`userPlanProvider` course-aware (evita romperse con planes multi-curso). **Verificado end-to-end cliente real** (`verify_placement_wiring.py`): cambiar a de/nl/fr/it + responder A2 → ubica A2 + entra en **U7** (no A1); principiante → A1/U1; **EN intacto** (U13/B1) tras re-ubicar; aislamiento; 42501. `placement_flow_test` propaga courseId. **Idioma META en el ONBOARDING ✅ (2026-07-03):** paso nuevo «¿Qué idioma quieres aprender?» (los 6 cursos activos, distinto del "idioma de la app") → `set_active_course` al elegir → el placement del onboarding corre sobre el BANCO del curso elegido (`placement_next(courseId)`) → `create_plan` siembra ESE curso. Copy course-aware (motive/nivel-inicial dicen el idioma elegido vía `learnLangName`, i18n es/en/pt; la nota del idioma-de-app ya no afirma "aprenderás inglés"). Un usuario nuevo ya NO cae siempre en inglés. **Verificado end-to-end cliente real** (`verify_onboarding_target.py`): nuevo→alemán A2 → **A2 alemán/U7** (no inglés, SIN progreso en en); nuevo principiante→nl A1/U1; nuevo→inglés B1 sin cambio; aislamiento; 42501. +widget test del paso (`onboarding_target_test`). **Diferido:** L/S en placement (audio) + nombre real de la unidad de entrada por curso (rótulo es→en, la unidad real es correcta) + cap de la meta al tope del curso (fr/it/de/nl topan A2). |
| Loop lección + grading server-side | ✅ verde y live. **Grading apóstrofes/contracciones (mig 067):** `jz_normalize` equipara I'm↔I am, don't↔do not, '↔'↔'' y limpió 15 ítems con `''` corrupto del seed. **word_bank/reorder no revelan la respuesta (mig 068, 20 ítems):** enunciado en español. **Typo-tolerance "casi correcto" (mig 073):** `grade_item` perdona typo menor (distancia 1: inserción/borrado, o sustitución SOLO en multi-palabra) y artículo a/an/the faltante/sobrante → `correct=true` + **`near=true`** (no resta vida, muestra "La forma correcta es…"). Guard de homógrafos: live/life, house/horse, cat/cut, this/these NUNCA se perdonan. `jz_grade = jz_grade_exact OR jz_near_match` (loop, summary y examen coherentes). Espejo cliente en `grader.dart` (`nearMatch`) + tests (`grader_typo_tolerance_test.dart`, 17). **Repaso de errores (mig 074 + `ErrorReviewScreen`):** al terminar, si hubo fallos → pantalla "Repasa lo que fallaste" (cada errado + respuesta correcta + porqué) ANTES de la recompensa; "Practicar los fallados" opcional. Los fallados entran al SRS con prioridad (`srs_prioritize_failed` → `user_vocab_srs` due=now). **TTS de tile (Web Speech):** tocar una ficha en word_bank/reorder pronuncia la palabra (cero archivos, interrumpible, degradación con gracia; disparado por TAP → sin desbloqueo iOS). **Idioma del HABLA = curso activo (fix 2026-07-02b):** antes el TTS de tile (`word_tts_web`) y el reconocedor de speaking (`speaking_exercise`) estaban **hardcodeados a inglés** → en pt/fr/it la VOZ no correspondía al idioma (bug real del feedback). Ahora `SpeechLang` (estático, fijado en `HomeShell` desde `activeCourseTargetProvider`) los pone en en-US/pt-BR/fr-FR/it-IT según el curso. El audio pre-generado (MP3) ya era correcto (tl por idioma). `correct_answer` sigue revocado (42501). |
| **Música ambiente del mapa** | ✅ **es→en/pt (live).** Loop ambient **original (obra propia → CC0**, sin terceros, `gen_music_loop.py` síntesis procedural; ciclos enteros → sin clic; 12s/384KB en Storage `audio/ambient/map_loop.wav`, carga diferida → bundle +5.6KB solo código). **Default APAGADA (opt-in)** — pisar el audio del usuario = desinstalan. Toggle en **Ajustes** + **toggle rápido** en la top bar del mapa (persistido, `MusicController`/`music_enabled`). **Solo en el mapa**: `HomeShell` coordina por tab (==0) + lifecycle (pausa al backgroundear) + `setSuppressed` en lección/checkpoint/examen (nunca durante el ejercicio). **Ducking automático** en el `AudioEngine` (la música baja sola con cualquier SFX/TTS vía rampa de GainNode, se recupera después). **MediaSession NO reactivada**: el loop vive en el MISMO AudioContext (Web Audio API, sin `<audio>`) → sin reproductor en pantalla de bloqueo (riesgo conocido, mantenido a raya). Pendiente: variar/alargar el loop, presets de volumen. |
| Dinamismo/UX (loop) | ✅ 1ª tanda LIVE (deploy-pending): recompensa con contadores+entrada escalonada, feedback ✅/❌ animado, transiciones `jzRoute`, skeletons en Ligas. Pendiente: tokens de espaciado, mascota en más pantallas, radar animado. Ver UX_AUDIT.md |
| Capa "enseña" (tips/cuaderno/referencia/**inmersión**) | ✅ tip post-lección **relevante al tema real de la lección** (mig 069: `content_tips.topic` + match contra los tags de la lección; ya no sale el tip de EDAD en una lección de PAÍSES) + anti-repetición (no visto > menos reciente) + personalización por skill flojo + cuaderno + **Referencia/Repaso** (mig 060) + **Inmersión/Historias** (mig 065/066: 6 historias es→en A1/A2, audio 46/46). **Tips A1 multi-idioma (mig 102, 2026-07-03):** además de los 72 es→en, **24 tips A1 para es→fr/it/de/nl** (6/curso, 1 por unidad = punto gramatical clave: edad con avoir/avere/sein/zijn, partitivo/acusativo, hora/falsos-amigos «halb vier»/«midi et demi», contracciones/prep. articuladas, de-vs-het, mein/meine). Course-scoped por `get_lesson_tip` (WHERE course_id=jz_active_course) → **verificado cliente real: cada curso ve su tip, sin cruce** (en→inglés, fr→fr, it→it, de→de, nl→nl). **Completado a 6/6 cursos (mig 103, 2026-07-03):** +6 tips **es→pt A1** (keyed por unit_order: você+3ª pers., meu/minha por género, gostar DE, queria/Quanto custa, ficar, segunda-feira) + **12 tips A2 fr/it** (units 7-12: passé composé/passato prossimo, futurs, accord/concordanza con être/essere, comparativos, imparfait/imperfetto, avoir mal à/mal di). Verificado cliente real (pt U2→tip pt, fr U9→A2 fr, it U12→A2 it, en control). Total **54 tips** en 6 cursos; **+12 tips A2 de/nl (mig 106)** → tips A1+A2 completos en los 4 pilotos (fr/it/de/nl). **Tips B1/B2 de niveles altos ✅ (mig 124, 2026-07-05):** +54 tips = fr/it/de/nl B1+B2 (units 13-24) + pt B2 (19-24), 1 punto gramatical clave/unidad, autorados por profesores nativos; `gen_tips_multi.py` batch `hi` + cefr por unit_order extendido a B2. Verificado cliente real (set_active_course + get_lesson_tip por curso en lección B1/B2): cada curso su tip, 0 cruce. **Ahora tips A1-B2 en en/pt/fr/it/de/nl.** **+12 tips es→pt A2/B1 (mig 108, 2026-07-03):** units 7-12 (pretérito perfeito, futuro «vou»+inf, pegar o ônibus, a conta/garçom, ser/estar, «estou com dor») + units 13-18 (imperfeito «era/brincava», condicional «gostaria», subjuntivo «que venha», relativos que/quem/onde, «deu problema/tem jeito», comparativos maior/melhor) → **pt tips A1+A2+B1 completos** (18). `gen_tips_multi.py` ahora deriva cefr A1/A2/**B1** por unit_order. Verificado cliente real (pt U7-18→su tip; con fr activo **0 cruces**). `gen_tips_multi.py <batch>`. **Historias/inmersión multi-idioma (mig 107+109, 2026-07-03):** además de las 6 es→en, **1 historia A1 por piloto** — fr «Le café de Léa», it «Un caffè al bar», **pt «A padaria da Ana», de «Beim Bäcker», nl «De koffie van Sanne»** → **los 6 cursos con ≥1 historia**. Cada una 7 segmentos (texto meta + es + **audio tl correcto** — fr/it 14/14 + pt/de/nl 21/21 = 35/35 HEAD 200) + glosario + 5 preguntas MC. Autoradas por profesores nativos IA + **validación adversarial nativa** (pt/de/nl: 0 errores reales, 1 pulido pt «quentinho» aplicado). Pipeline `gen_stories.py` + `gen_story_audio_multi.py`. **Verificado cliente real (`verify_stories_multi.py`):** `get_stories`/`get_story`/`submit_story` course-scoped en los 6 cursos (**0 cruces** en/pt/fr/it/de/nl); get_story NO expone `correct_answer`; submit_story califica server-side (correctas 1.0 / erróneas 0.0, 42501); `stories.questions` revocada al cliente; audio HEAD 200. **Historias B1 ✅ (mig 125, 2026-07-05):** 2ª historia por idioma, nivel B1, para fr/it/de/nl/pt («L'appartement de Karim», «Il colloquio di Giulia», «Die Wohnungsbesichtigung», «De trein die niet reed», «A entrevista de Rafael») — 7 segmentos con gramática B1 real (passé composé/subjonctif/Konjunktiv II/conditionalis/subjuntivo, relativos, passiva), glosario + 5 MC + audio tl 35/35. `gen_story_audio_multi.py` con **chunking** (translate_tts limita ~200 chars; segmentos B1 largos se parten en trozos ≤190 y se concatenan). Verificado cliente real (`verify_stories_multi.py`): get_stories 2/curso course-scoped (0 cruces), get_story sin fuga, submit 5/5→1.0 y 0/5→0.0 (42501), audio HEAD 35/35. Pendiente: historias B2. |
| Contenido es→en A1–B2, **es→pt A1–B2** | ✅ sembrado y live (pt B1 = mig 053; **pt B2 = mig 20260705120121, 2026-07-05** — ver fila abajo). Cadena A1→B2 + certs verificada. |
| **B2 es→pt ✅ LIVE (mig 20260705120121)** | 6 unidades (order 19-24, encadenan B1→B2; U18 desbloquea U19), **114 ítems (R36/W36/L24/S18 → L=67% S=50%)**, audio TTS **tl=pt 42/42**. Currículo B2 pt-BR REAL: **presente do subjuntivo** (seja/tenha/faça + embora/para que/caso/a menos que), **futuro do subjuntivo** (quando eu tiver/for/fizer — rasgo clave pt, no presente) **+ imperfeito do subjuntivo** (se eu tivesse/fosse), **período hipotético** (3 tipos: se tiver→vou / se tivesse→…ria / se tivesse tido→teria+part) **+ futuro do pretérito**, **voz passiva** (ser+part+concordância; sintética «vendem-se casas»; estar vs ser; particípios duplos aceito/pago/entregue/ganho), **discurso indireto + colocação pronominal** (concordância dos tempos; próclise por atração/ênclise inicial), **conectores B2 + regência verbal** (embora/caso/contanto que+subj vs à medida que/porque+ind; assistir a/obedecer a/gostar de). **`gen_course.py` extendido a pt** (COURSES/STAMPS/UNIT_WORD='Unidade'; sin unique constraint en vocab/content_items → sin colisión con pt A1-B1). 6 professores nativos pt-BR IA + **revisión adversarial nativa** (fixes reales: «quiseria» inexistente→«gostaria», word_bank que revelaba respuesta, 4 colisiones near-match dist-1 en cloze de subjuntivo/regência/crase → reescritas a multi-palabra/single-word bloqueada). **Verificado cliente real (`verify_b2_chain.py pt`):** determinista 96/96 + 96/96 distractores (42501); **CAMINA A1→B2 las 24 unidades** (U18→U19, 30/30 lecciones B2); **0 lesson_items cruzan los 6 cursos**; default(en) sin fuga; audio HEAD 42/42. `get_courses.max_level` pt→B2 (cap de meta ofrece B2). **português es→pt: A1→B2 completo → los 6 cursos llegan a B2.** |
| **Audio** (listening/speaking TTS) | ✅ es→en + es→pt A1/A2 (312) + **es→pt B1 (68)** = 380 + **rebalanceo L/S es→en A1/A2 (96, mig 078/079)** en Storage = **476/476** + degradación/unlock iOS LIVE. Ver FINDINGS.md §2 |
| **Balance de 4 habilidades (L/S)** | ✅ **es→en A1–C1 rebalanceado (mig 078–082, live).** Audit EFICACIA halló sesgo **~3:1** (R/W vs L/S). Subido con criterio (NO 1:1): **listening ~65% de R/W**, **speaking ~50%** (proxy read-aloud, participación, no evalúa fluidez). **A1/A2** (mig 078/079): +5L/+3S por unidad (96 ítems). **B1/B2/C1** (mig 080/081/082): +4L/+2S por unidad → resultante B1 L/R=62% S/R=50%, B2 61%/49%, C1 69%/51% + **34 huecos** de cobertura de alto impacto rellenados (auditoría confirmó cobertura gramatical SÓLIDA en los 3; sin huecos estructurales). **+204 ítems** L/S totales (todos con audio TTS regenerable, `payload.say`/`text` guardado), autorados por panel IA + validación adversarial por unidad, cableados a lecciones 1–4 + tag `unidadN` (pool del examen → menos sesgo R/W). **es→pt A1/A2/B1** (mig 083/084/085): +4L/+2S por unidad → pt A1 L/R=61% S/R=49%, A2 62%/50%, B1 72%/57% + 34 huecos; audio **tl=pt** (108/108). **Verificado cliente real** por nivel (en+pt): L/S resueltos suben su dominio (listening precisión, speaking participación); verify_chain A1→B2 PASS; **verify_pt_chain A1→B1 PASS (multicurso: contenido pt→curso pt, 0 fuga)**. **Techo C1 honesto:** receptivas sí a C1; producción libre (W/S) requiere Fase 2 → sin cert C1 por diseño. **Sesgo L/S 3:1 resuelto en AMBOS cursos.** Pendiente: es→pt B2/C1 no existen aún (curso pt llega a B1). |
| **Imágenes referenciales (doble codificación)** | ✅ **es→en A1/A2 (mig 086/087, live).** Fuente **Twemoji (CC-BY 4.0)** alojado en Storage (`audio/vocab/<concept>.png`), carga **diferida** (`Image.network`, cero deps/assets nuevos → bundle igual). **39 iconos** de vocab concreto (comida, familia, lugares, tiempo, viaje, compras) + registro de **proveniencia/licencia** en `vocab_images` (RLS sin policy → no se filtra al cliente). **21 ítems** `multiple_choice` "¿Qué es esto?" (imagen=estímulo → NO revela por texto; opciones=palabras de la misma categoría; `correct_answer` 42501). UI: `ConceptImage` en `buildExerciseWidget` → se ve en las 4 superficies (lección/checkpoint/examen/práctica), altura fija (sin jank), **degradación con gracia** (si no carga, colapsa y el ejercicio sigue con texto). Verificado cliente real: HEAD 21/21, grading server-side, image_url por `content_items_public`. **"Describe la imagen" determinista (mig 088):** 16 ítems **word_bank/writing** que reusan las imágenes — el usuario ARMA con fichas la frase ("This is a house") → secuencia verificable (jz_grade word_bank), produce lenguaje (mueve **writing**), distractor de ficha enseña el artículo (a/an/the/incontable). Cero UI nueva (reusa ConceptImage+TileArrange). Degradación: 1 solo sustantivo/frase → resoluble desde fichas aunque la imagen no cargue. **Descripción ABIERTA evaluada = Fase 2** (techo determinista). **Carga (2026-06-27):** barrido HEAD de TODO (audio 759/759, imágenes 37+39, historias 46, música) = **0 recursos 404** (`sweep_resources.py`); el "no cargan bien" era lentitud percibida → **precarga de imágenes** en el lesson_player (como el audio) + failsafe en `ConceptImage` (colapsa a los 10s, no spinner eterno). **Copy onboarding** aclarado (idioma de la APP vs lo que aprende; sin anglicismos). Pendiente: match imagen↔palabra, es→pt, B1+. |
| **Seguridad** (4 hallazgos) | ✅ **cerrados** en DB (mig 058) + botón export en Ajustes **LIVE** (deploy 68266d3). Ver abajo |
| Ligas + Leaderboards | ✅ rollover real (mig 059): cierre semanal idempotente/lazy + ascensos (top 7)/descensos (fondo 5) Bronce↔Diamante + snapshots. `get_leaderboard` (XP/Racha/Lecciones/Certificados × Semanal/Mensual/Anual/Histórico × Global/División, SIN user_id). UI con segmentos (Mi liga / Tablas) **LIVE** (deploy-pending hasta push). Falta: **cron** que dispare el cierre (hoy es lazy-on-read; ver abajo) |
| **C1 es→en** | ✅ **sembrado y live** (mig 063): 6 unidades (25–30), **252 ítems** (192 lección + 60 checkpoint fresco), 4 habilidades, audio **67/67**. **Sin examen/cert C1** por diseño (techo determinista — writing/speaking a C1 no son evaluables sin IA; mig 064 tope el examen en B2 + blinda C1). Progresión intra-C1 por checkpoints (≥80%). Placement C1 ahora con banco real (8 ítems) + arranque en U25 (mig 075/076/077). Ver `docs/LEVELS_C1_DESIGN.md` y fila **Test de ubicación** |
| C2 | ❌ documentado, no sembrado (otra pasada) |
| Conversar | ✅ **VISIBLE + MULTI-IDIOMA los 6 cursos (fix 2026-07-02c + de/nl 2026-07-05)** (pestaña 2 del nav, GA7): práctica en solitario/asíncrona (tema → escribe/habla → respuesta modelo + autoevaluación) + captura de interés para la conversación EN VIVO (Fase 2). Antes los 6 topics tenían **model+tips hardcodeados en inglés**. Ahora `ConvTopic.models` es un **mapa por idioma META** con los **6 idiomas (en/pt/fr/it/de/nl)**; `ConversarScreen` resuelve el idioma con `activeCourseTargetProvider` y `modelFor(lang)` (fallback a en). **de/nl añadidos 2026-07-05** (los 2 cursos más nuevos que aún veían el fallback inglés): de con Sie formal + Perfekt, nl con V2 + «Mag ik…/alstublieft» + voltooid tegenwoordige tijd, autorados por profesores nativos. `SpeechLang` ya mapea de-DE/nl-NL (TTS + reconocedor). Verificado: unit test (6 topics × **6 idiomas** × 3 tips + fallback) + `flutter analyze 0 · test 94/94`. Conversación EN VIVO sigue siendo Fase 2. |

### Ligas — automatización del cierre (pendiente del dueño)
El rollover (`jz_close_weeks()`) es **idempotente + lazy**: se ejecuta al leer
(`get_league`/`get_leaderboard`), así que las semanas vencidas se cierran solas
cuando alguien abre Ligas — no se pierde nada aunque no haya cron. Para garantizar
el cierre puntual (lunes 00:00 UTC) aunque nadie entre, automatizar con UNA opción:
**(a)** `pg_cron` (Supabase Pro): `select cron.schedule('jz-rollover','5 0 * * 1','select jz_close_weeks();')`;
**(b)** Edge Function + cron externo (GitHub Actions/cron-job.org) que llame a un RPC.
Movimiento real solo en ligas ≥13 (top 7 suben / fondo 5 bajan); en beta (<13) nadie
se mueve, por diseño.

## Seguridad — 4 hallazgos (todos CERRADOS en DB, mig 058 · 2026-06-23)
1. ✅ `league_members`/`leagues` SELECT directo **revocado** (daba UUIDs de auth ajenos).
   El ranking se sirve SOLO por `get_league` (DEFINER, sin user_id). `get_metrics` etc. siguen.
2. ✅ Gate de admin en `get_metrics`/`get_engagement`/`get_onboarding_funnel`: tabla `admins`
   + `jz_is_admin()`. Dueño (Gian, `7b4a8e40-…`) sembrado. No-admin → `admin only`.
3. ✅ `log_event`: allowlist de 8 eventos (`app_open, client_error, conversar_attempt,
   lesson_complete, mission_started, onboarding_completed, onboarding_step, screen_view`),
   props truncadas (>2KB → `{_truncated}`), rate-limit 120/usuario/min. Evento desconocido = descarte silencioso.
4. ✅ `export_my_data()` (GDPR): RPC DEFINER acotada a `auth.uid()` (24 secciones). Botón
   "Exportar mis datos" en Ajustes (**LIVE** desde deploy 68266d3).
- Previo: `correct_answer` ya estaba cerrado (mig 055), `jz_*` helpers revocados (mig 049).
- Admin allowlist NO se gestiona por SQL roles → es la tabla `admins` (agregar/quitar user_id).

## Legal — PÁGINAS PÚBLICAS + in-app (Privacidad + Términos) · ⚠️ BORRADOR (falta abogado)
- **PÁGINAS PÚBLICAS ✅ LIVE (2026-07-07):** `app/web/privacy.html` + `app/web/terms.html` (HTML
  autocontenido, responsive, banner beta, tema claro/oscuro) → Flutter los copia a `build/web/` y
  **Vercel los sirve sin login**. `vercel.json` **rewrites** (buildCommand INTACTO): `/privacy`→
  `/privacy.html`, `/terms`→`/terms.html`, antes del catch-all SPA. **URLs estables para Google OAuth /
  Search Console:** `https://jezici.vercel.app/privacy` y `https://jezici.vercel.app/terms` (200 público,
  verificado). Contenido HONESTO derivado de introspección real: cuenta+Google OAuth (email/nombre/foto,
  scopes básicos), progreso/skills/stats, analítica (allowlist de eventos, ids opacos), feedback in-app,
  monitoreo de errores, Supabase+RLS+Vercel, retención, y **derechos que YA existen** (export_my_data /
  delete_account desde Ajustes). **Fuente única:** el HTML es canónico; la app **enlaza** (no duplica).
- **Enlace in-app:** `features/legal/legal_screen.dart` ahora es un módulo de enlaces (`kLegalVersion`
  = `'2026-07-draft'`, `kPrivacyPath`/`kTermsPath`, `openLegalPage()` con import condicional web
  `legal_open_web.dart`/`_io.dart` → `window.open('${Uri.base.origin}/privacy','_blank')`, no-op fuera de
  web, degrada con gracia). **Ajustes** (2 links) **y el registro** (checkbox + links) abren la página
  pública en pestaña nueva. Se eliminó el widget de texto in-app (evita duplicar el texto).
- **Aceptación (mig 062):** en "Crear cuenta", checkbox **requerido** "He leído y acepto
  Términos + Privacidad" (botón deshabilitado sin marcar). Tras el alta → `accept_legal(version)`
  persiste `legal_consents(user_id, doc_version, accepted_at)` (RLS self; escritura solo por RPC).
  `my_legal_version()` devuelve la última versión aceptada (base para re-consentir).
- **Versionar/re-consentir:** subir `kLegalVersion` cuando el texto cambie (revisión de abogado).
  La detección está lista (comparar `my_legal_version()` vs `kLegalVersion`); el **gate de
  re-consentimiento para usuarios existentes está DIFERIDO** (se añade al llegar la versión revisada).
- ⚠️ **Es un BORRADOR**: NO está revisado por abogado. No afirmar acreditación oficial.

## Analítica de la beta (KPIs sin SQL) — mig 061
- **Cómo lo ve Gian:** Ajustes → "Ver métricas (interno)" (admin-only; Gian ya en `admins`).
  Pantalla `MetricsScreen` lee `get_metrics`/`get_engagement`/`get_onboarding_funnel` (todas
  admin-gated). KPIs: usuarios, DAU/WAU/MAU + **stickiness DAU/MAU (CURR)**, retención
  D1/D7/D30, lecciones/día, % aprueba checkpoint/examen, % certifica, **embudo de onboarding**
  (paso a paso + dónde abandonan) y **embudo de lección 30d** (iniciadas/completadas/
  abandonadas/sin-vidas + tasa de finalización).
- **FEEDBACK DE USUARIOS — dónde lo ve Gian (mig 099, 2026-07-02):** el feedback in-app
  (`FeedbackFab` app-wide → `submit_feedback` → tabla `feedback`) se capturaba pero era
  **ILEGIBLE** (la tabla tiene RLS solo-INSERT y `get_engagement` daba solo el CONTEO por tipo,
  no el texto). Nuevo **`get_feedback(limit)`** (admin-gated, SIN PII: user_id recortado a 8
  chars) devuelve los MENSAJES reales; **MetricsScreen los muestra en la sección "Mensajes de
  usuarios"** (texto + tipo + pantalla + fecha). Gian: Ajustes → Ver métricas → baja a "Mensajes
  de usuarios". **Query directa (admin):** `select created_at, kind, screen, message from feedback
  order by created_at desc;`. Verificado cliente real (no-admin → "admin only"; admin → mensajes).
- **Eventos (allowlist `log_event`, mig 058+061):** `app_open, client_error, conversar_attempt,
  lesson_complete, mission_started, onboarding_completed, onboarding_step, screen_view` +
  **`lesson_start, lesson_quit, no_hearts`** (mig 061). ⚠️ Evento fuera del allowlist = descarte
  silencioso → si agregas uno, AGRÉGALO al allowlist o nunca entra. Sin PII (solo conteos + ids opacos).
- Nota: `lesson_funnel.completion_rate` solo es fiable para sesiones DESPUÉS de este deploy
  (antes había `lesson_complete` sin `lesson_start`). Diferido: retención por cohorte semanal
  visual, abandono por ítem específico, analítica de práctica.

## Monitoreo de errores (Sentry) — cableado, falta el DSN
- **Client-side LIVE-ready** (`core/monitoring/sentry_config.dart`): `runWithSentry`
  envuelve `runApp` (captura Flutter + nativo iOS/Android + zona; en web errores JS de la
  app). Sin DSN → **NO-OP** (la app arranca igual, sin coste). Config beta: env `beta`,
  release `jezici@<JZ_BUILD>` (fallback `dev`), `tracesSampleRate 0.1`, `sendDefaultPii=false`
  (GDPR), `beforeSend` filtra ruido (timeouts/cancelaciones), uid OPACO sin PII. Convive con
  `installCrashReporting` (analytics_events), sinks distintos.
- **Cómo lo activa Gian (el DSN NO es secreto):** pega el DSN como `--dart-define` con
  **VALOR LITERAL** (NO `$VAR` ni `$(...)` → eso rompe el deploy pre-build).
  - **Prod (Vercel):** en `vercel.json`, al final del `buildCommand`, añade literal:
    `... --dart-define=SENTRY_DSN=https://<key>@<org>.ingest.sentry.io/<project>` (y opcional
    `--dart-define=SENTRY_ENV=production`). Push → deploy. **Tras el push, confirmar deploy READY** (no instant-ERROR).
  - **Local:** `flutter run --dart-define=SENTRY_DSN=https://…`
- **Prueba de captura (con DSN):** temporal `Sentry.captureMessage('jezici test')` o un throw,
  ver que llega al dashboard, y quitarlo.
- **Diferido:** source maps/símbolos (stack traces legibles en web/nativo) y Sentry server-side
  (Edge Functions) — fuera de alcance de esta tanda.

## CI (GitHub Actions) — VERDE ✅ desde 2026-06-24 (run #57, commit 151062f)
- Pipeline completo en verde por primera vez: `Prepare .env` → analyze → **test 43/43** →
  **build web** (antes test/build quedaban *skipped* porque analyze abortaba). Deploy de Vercel
  de ese commit = **READY** (prod). Las rojas históricas #47–#56 son inmutables (corrieron con el
  workflow roto; re-correrlas reusaría ese workflow). Detalle del fix abajo.

## CI (GitHub Actions) = FUENTE DE VERDAD — no el local
- **El verde del CI manda, no `flutter analyze` local.** Workflow `.github/workflows/ci.yml`
  (job `flutter`: analyze → test → build web, Flutter **pinneado 3.44.3**). Verde real =
  `gh run list`/API muestran SUCCESS. Un verde local que el CI no refleje **no cuenta**.
- **Por qué el local daba falso verde (lección 2026-06-24, runs #47–#56 todas rojas):** `.env`
  es un asset DECLARADO en `pubspec.yaml` pero **gitignored**. En local existe → analyze pasa.
  En CI no existe → `flutter analyze` falla con `asset_does_not_exist` y aborta el job (test/build
  quedan *skipped*). El step de build creaba `.env` con `touch`, pero **corre DESPUÉS de analyze**.
  Fix de raíz: step **`Prepare .env`** (touch) **antes** de analyze + versión pinneada. El `.env`
  vacío basta (Supabase usa fallback público embebido en `supabase_config.dart`).
- **Reproducir el CI en local:** `mv app/.env app/.env.bak && cd app && flutter analyze` → debe dar
  el mismo `asset_does_not_exist`. Restaurar después. (Antes de declarar "verde", correr el comando
  EXACTO del workflow, no asumir.)

## Comandos de verificación
```bash
# Toolchain (desde app/) — el CI corre estos MISMOS con .env presente (touch) y Flutter 3.44.3
flutter analyze              # esperado: No issues found
flutter test                 # esperado: All tests passed (89/89)
flutter build web --release  # esperado: Built build/web (wasm dry-run warning de ua_client_hints es OK)

# Audio: cobertura real en Storage (HEAD a payload.audio_url) — es→en/pt = 692/692 (incl. 312 L/S mig 078–085)
#   + es→fr A1 41 + A2 43 + es→it A1 43 + A2 43 = 170/170 (pilotos A1+A2, mig 094/095/097/098, tl=fr/it)
#   + es→de A1 43 + A2 43 + es→nl A1 43 + A2 43 = 172/172 (pilotos A1+A2, mig 100/101/104/105, tl=de/nl)
#   query content_items_public?type=eq.listening|speaking_read_aloud, HEAD cada audio_url
# Curso nuevo A1 (fr/it): tools/content/verify_new_course.py <code> — determinista + aislamiento (4 cursos) + cadena + audio
# Nivel A2 (fr/it): tools/content/verify_a2_chain.py <code> — determinista A2 + aislamiento + CAMINATA 12 unidades (gating A1→A2) + audio

# Cliente REAL (NUNCA service_role para chequeos de seguridad):
#   anon key + JWT autenticado real (signup vía /auth/v1/signup, limpiar con delete_account).
#   Ejemplos verificados (mig 058): league_members directo → 403; get_league → 200 sin user_id;
#   get_metrics no-admin → "admin only"; export_my_data → 200; log_event bogus → 0 filas.

# DB (introspección/seed admin): tools/content/apply_sql.py vía Management API (.env).
```
- **Verificación de cliente desplegado**: `git show 7e26824:app/lib/...` para ver qué consulta
  el build que usan los usuarios HOY (no asumir que `main` == producción).

## Reportes de diagnóstico (raíz)
- **QA_AUDIT.md** (2026-06-27, solo lectura) — QA exhaustivo end-to-end + veredicto de flujo (cliente real).
  **P0 ✅ ARREGLADO (mig 090, 2026-07-02):** el congelador de racha ahora SÍ protege — `jz_register_activity`
  consume `freezes_available` al haber un hueco y preserva la racha (verify_streak_freeze.py 7/7, cliente real);
  antes solo se incrementaba. **P1 (idioma) ✅ ARREGLADO:** i18n real es/en/pt (ver fila **i18n**); el selector ya
  cambia la UI. **P1-3 misión ✅ ARREGLADO (mig 091):** bono de bienvenida one-time (25 XP+25 oro) + diálogo de
  confirmación. **P2 retención/sensación ✅ (2026-07-02):** meta diaria "X/Y XP" visible en el mapa (pastilla con
  número), combo "🔥 x{n}" en vivo en la lección, feedback de oro enriquecido (ganaste/gastaste, te quedan Y),
  race del cofre (guard), zonas de liga en beta (mig 092: promote/demote=0 hasta 13 jugadores == gate del
  rollover; UI con `movementActive` + nota beta). **Ver §0.1 de QA_AUDIT.md** para el estado ítem por ítem.
  **Diferido:** a11y amplia (device), precios hardcodeados, colores, infra bots, deuda leaderboards. **Verificado
  en vivo TODO lo core** (grading 42501, leaderboards sin fuga de user_id, placement/fecha, loop, 0 recursos 404,
  analyze 0/test 88/build OK).
- **EFICACIA_CONTENIDO.md** (2026-06-24) — auditoría de EFICACIA de currículo por nivel (¿lleva a CEFR-X?).
  Veredicto es→en A1/A2: "sí con reservas"; huecos de cobertura rellenados (mig 071, 29 ítems sin audio:
  presente continuo, 3ª persona -s, plurales, these/those, conectores, present perfect 'yet', adverbios -ly).
  **Hallazgo sistémico:** L/S subservidos ~3:1 vs R/W en TODOS los niveles + techo determinista de producción
  (speaking proxy). Destapó y arregló una **regresión P0** (mig 072): exámenes de pt rotos por mig 064 (mono-curso).
  **L/S YA equilibrado en AMBOS cursos**: es→en A1–C1 (mig 078–082) + es→pt A1–B1 (mig 083–085) = +312 ítems L/S +
  68 huecos + audio. **Auditoría de eficacia HECHA**: es→en A1–C1 y **es→pt A1–B1** (cobertura sólida; verify_pt_chain
  multicurso PASS). **es→pt B2 ✅ sembrado (mig 121, 2026-07-05):** L/S ya balanceado de origen (L=67% S=50%); pendiente
  auditoría pedagógica a fondo del B2 pt (perfil estructural hecho + doble revisión nativa aplicada). Pendiente: es→pt C1 (no sembrado).
- **CONTENT_QA.md** (2026-06-24) — auditoría pedagógica profesor-IA de **es→en A1/A2 (384 ítems)**:
  **0 P0**, clase sistémica = tolerancia insuficiente (corregida en mig 070, +20 ítems con variantes
  naturales en `accepted` + 2 pulidos). Rechazos/diferidos documentados. Pendiente: B1/B2/C1 + es→pt.
- **FINDINGS.md** — auditoría funcional/seguridad completa (audio, progresión, ligas, seguridad)
  + smoke post-deploy + checklist manual para Gian.
- **PERF_AUDIT.md** (2026-06-23, solo lectura) — rendimiento priorizado: renderer CanvasKit,
  caché de contenido estático, invalidaciones en cascada, rebuilds/cómputo en `build()`, jank del
  mapa, skeletons. Con método de perfilado en vivo (DevTools).
- **UX_AUDIT.md** (2026-06-23, solo lectura) — UX/estética/**dinamismo** por pantalla: deriva del
  sistema de diseño (212 colores hardcodeados, AppSpacing/Radius casi sin usar), motion faltante
  (feedback ✅/❌, háptica, transiciones, contadores de recompensa), + top-10 cambios por impacto.
- **MOCKUP_GAP.md** (2026-07-08, solo lectura) — fidelidad de los 15 mockups de Claude Design
  (`/mockups`, fuente de verdad del diseño) vs implementación, pantalla por pantalla con severidad
  P0/P1/P2 + esfuerzo + orden de implementación en 3 tandas. Veredicto: **tokens/Nunito FIELES**
  (paleta 1:1); los gaps sistémicos son **motion/celebración** (jzBob/jzCheer/jzFall… casi sin
  replicar), **labio 3D ausente en el CTA del loop** (`_BigButton`), y **mascota emoji vs SVG**.
  P0 de producto destacados: el certificado NO imprime el nombre del titular; Ligas muestra
  gradiente BRONCE hardcodeado sea cual sea la división; SinVidas promete cobrar oro que el código
  no cobra; Cofre/Simulacro/Practicar muy desviados. Fase 2 (no gaps): Conversar en vivo, planes
  del Paywall, correo del coach, informe de banda de simulacros.

## Memoria del proyecto
`~/.claude/projects/.../memory/` (cargada cada sesión vía MEMORY.md). Incluye: deploy mechanics,
método de verificación, pipeline de contenido, estado de producción, multi-curso, y la
auditoría 2026-06-22 (`jezici-audit-2026-06-22`).
```
