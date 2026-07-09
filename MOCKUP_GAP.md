# MOCKUP_GAP.md — Auditoría de fidelidad mockups vs implementación

> **Fecha:** 2026-07-08 · **Método:** solo lectura (0 cambios de código). Los 15 mockups de
> Claude Design en `/mockups` (HTML, frame 390×844, Nunito) son la **fuente de verdad del
> diseño**; se compararon contra el código Dart real (pantallas + widgets + `app_colors.dart`
> + `app_es.arb`) con 5 auditores paralelos. Severidad: **P0** roto/muy distinto ·
> **P1** notorio · **P2** detalle. Esfuerzo: **S** <1h · **M** 1–4h · **L** >4h.

## Veredicto global

| # | Mockup | Pantalla(s) | Estado | Esfuerzo |
|---|--------|-------------|--------|----------|
| 1 | Aprender v2.dc.html | learn_map_screen + widgets | DESVIADO | L |
| 2 | Leccion.dc.html | lesson_player / complete / preview | DESVIADO (el más fiel) | M |
| 3 | SinVidas.dc.html | no_hearts_sheet | ✅ FIEL (2026-07-09) | M |
| 4 | Checkpoint.dc.html | checkpoint intro/player/result | DESVIADO | M+M |
| 5 | Examen.dc.html | level_exam result + certificate | MUY DESVIADO | L+L |
| 6 | Simulacro.dc.html | simulacros_screen | MUY DESVIADO (placeholder) | L |
| 7 | Onboarding.dc.html | onboarding_screen + your_plan_view | DESVIADO | M/L |
| 8 | CoachTonos.dc.html | coach_styles + matix_banner | DESVIADO | M |
| 9 | Conversar.dc.html | conversar_screen | MUY DESVIADO (= Fase 2) | L |
| 10 | Cofre.dc.html | tienda_screen (fila cofre) | MUY DESVIADO | L |
| 11 | Paywall.dc.html | premium_screen | DESVIADO (beta sin pagos) | M |
| 12 | Practicar.dc.html | practice_screen | MUY DESVIADO | L |
| 13 | Ajustes.dc.html | settings_screen | ✅ FIEL (2026-07-09) | M |
| 14 | Perfil.dc.html | profile_screen | DESVIADO | L |
| 15 | Ligas.dc.html | leagues_screen | MUY DESVIADO | L |

**Cobertura:** los 15 mockups mapean a superficies existentes (ninguno huérfano; el frame
"ReporteBanda" de Simulacro no tiene pantalla). **Pantallas de la app SIN mockup:** auth,
inmersión/historias (×2), misión, repaso de errores, cuaderno, referencia, racha, mi plan,
centro de notificaciones, métricas (admin), legal (hoy páginas web públicas), placeholder.

## Hallazgos transversales (verificados)

1. **Tokens y tipografía: FIELES.** `AppColors` calca la paleta del mockup casi 1:1
   (`#6C5CE7/#4B3FC9/#8A7BF6/#FF6B6B/#FFC93C/#2ECC71/#FF7A00/#FF4D6D/#1A1A2E/#EDEBFF`);
   Nunito real vía `GoogleFonts.nunitoTextTheme`. La deriva NO es de paleta sino de
   **composición, motion y componentes ricos**. Excepciones menores: `goldDark #E0980C` vs
   `#E09A00`, `textMuted #7A809B` vs `#9A9FB8`; hardcodeados fuera de tokens: `#ECEDF6`
   (sombra card), `#FFF4D6`, grises de tiles, gradiente bronce de Ligas. Faltan tokens del
   CTA dorado 3D (`#FFDD7A/#F4B400/#D69400`).
2. **Gap sistémico #1 — MOTION/celebración:** ✅ **CERRADO (2026-07-09).** Ya existían pulso del nodo,
   confetti (5 pantallas), contadores animados, mascota `ParrotMascot` (bob/cheer), banner Matix, halo
   del portal/emblema, wiggle del cofre, entrada del feedback bar + combo. Se añadió el motion que
   faltaba **con criterio** (rápido, sutil, reduce-motion-aware): **`JzSheen`** (destello diagonal del
   mockup jzSheen, ~700ms + pausa) sobre los DORADOS/premio — badge "EXAMEN SUPERADO", CTA "Ver
   certificado", tarjeta del certificado, badge "Plan gratis · Mejorar"; y **`JzGlowPulse`** (halo que
   respira, guía la atención) en los CTA de PREMIO — CONTINUAR de fin de lección, "Continúa" de
   checkpoint aprobado, "Empezar mi viaje" de Tu plan. Ambos helpers baratos (transform/opacity/shadow)
   y **calman con reduce-motion**. No se sobre-animó (ligas/cofre ya tenían movimiento propio). El motion
   es RÁPIDO — no entorpece el loop.
3. **Gap sistémico #2 — botón 3D "con labio"** (`0 Npx 0 <colorDark>` + hundido al presionar):
   `PrimaryButton` lo tiene, pero el CTA del loop (`_BigButton` COMPROBAR/CONTINUAR), los CTA
   dorados (cofre/checkpoint), y varios botones secundarios NO — inconsistencia interna.
4. **Gap sistémico #3 — mascota:** ✅ **CERRADO (2026-07-09).** Matix es ahora un **guacamayo escarlata
   VECTOR propio** (`ParrotArt`, CustomPaint portando 1:1 el SVG de los mockups Ajustes/Leccion: cuerpo/
   cabeza escarlata, ala y cola dorado-naranja, cresta, cara crema, pico dorado; sin assets/paquetes,
   CSP-safe). `ParrotMascot` (animado idle/celebrate/encourage, reduce-motion-aware) lo usa con **globo
   de diálogo blanco** estilo mockup. Reemplazó el emoji 🦜 en TODAS las superficies de personaje (mapa,
   lección enunciado+fin, onboarding, práctica, error-review, checkpoint/examen/certificado, ligas,
   ajustes/Matix, notificaciones, cuaderno, splash). Quedan como texto los 🦜 decorativos dentro de la
   COPIA i18n (p.ej. "¡Correcto! 🦜") — son puntuación, no el personaje.
5. **Decisiones de producto (NO son gaps):** Conversar en vivo (salas/compañeros) = Fase 2;
   selector de planes del Paywall = pagos inactivos en beta; canal de CORREO del coach = sin
   SMTP; pregunta de intensidad del onboarding = eliminada a propósito (mig 124).

---

## 1) Aprender (Mapa)
- Mockup: mockups/Aprender v2.dc.html · Implementación: `app/lib/features/learn/learn_map_screen.dart` + `widgets/` (map_node, learn_top_bar, scenery_painter, trail_painter, parrot_mascot)
- Estado: **DESVIADO** · Esfuerzo: **L**
- Coincide: estructura full-bleed + sendero serpenteante + cima; 4 estados de nodo con hex casi exactos (mastered `#FFDD7A→#FFC02E` exacto); pulso coral del disponible fiel (+ fallback reduce-motion, mejora); globo "EMPIEZA" y copy exactos; colores del sendero y colinas exactos.
- Desviaciones:
  - [P1] ✅ **ARREGLADO (2026-07-08):** el checkpoint es ahora un **PORTAL de examen** (`checkpoint_portal.dart`: pilares violeta + reflejo, arco, interior dorado con gradiente, estrella-llave, halo pulsante reduce-motion-aware) + pill "EXAMEN · UNIDAD N"; estado bloqueado = gris apagado + candado. Respeta el gating (≥80% dominio) sin tocar la lógica.
  - [P1] ✅ **ARREGLADO (2026-07-09):** mascota = guacamayo escarlata **SVG vector** propio (`ParrotArt`/`ParrotMascot`) animado (jzBob), ya no el emoji 🦜 (gap sistémico #3 cerrado, ver arriba).
  - [P1] ✅ **FONDO REHECHO — v2 (2026-07-09):** la escenografía se veía como **franjas verticales moradas/verdes/coral** en Android. **v1** ya había cambiado a **anclaje absoluto** (escenografía lejana arriba / primer plano abajo) + **degradado vertical de 8 paradas** (morado→cian→crema) + velo superior + full-bleed, pero **v2** encontró la causa real renderizando el PIE de un mapa alto (los mapas son MUY altos: `_flatten` = todas las lecciones → contentHeight 5.000–23.000px): al inicio del viaje se veía la **CIUDAD = edificios VERTICALES morados/coral sobre el verde** — ESO eran las "franjas verticales". **Fix v2:** se **ELIMINÓ la ciudad** (`_city`; el mockup lista velero/pinos/nubes/montañas como lo bueno, NO la ciudad) → en su lugar, **pinos más densos** en el pie + **verdes de pasos suaves** (colinas que se funden). Resultado: paisaje **limpio y cohesivo** (cima+montañas+sol, costa+velero, cielo degradado, colinas+pinos), **cero barras verticales**, sendero limpio. Verificado con golden del pie y del full. El globo "EXAMEN · UNIDAD N" en el hueco bajo el portal (c.dy+62).
  - [P2] Certificado de cima sin subtítulo "Fluidez · Avanzado", sin labio 3D `0 8px 0 #E7B23A`, sin halo animado.
  - [P2] Mastered sin sheen deslizante ni banderín coral; misión sin chispa ni tarjeta lateral "★ MISIÓN".
  - [P2] ✅ **ARREGLADO (2026-07-08):** el nodo disponible tiene **ANILLO DE PROGRESO** (pista blanca + arco coral = avance de la unidad, lecciones completadas/total). (Pendiente P2: flotación/cola del globo "EMPIEZA".)
  - [P2] Etiquetas bajo TODOS los nodos (mockup: solo disponible+checkpoint, con prefijo "Lección N ·").
  - [P2] Cielo 4 paradas vs 8; sendero 34/24px vs 40/30px; sin velo blanco sobre regiones bloqueadas ni pill compacta con candado.
  - [P2] Top bar sin blur; bandera 🇬🇧 hardcodeada (no refleja el curso activo de 6 y no es botón).
- No implementado del mockup: portal de examen, costa/ciudad/nubes, sheen+banderín, anillo de progreso, chispa+tarjeta de misión, velo de zona bloqueada, jzFloat/jzGlow/jzSway. (Extras de la app sin mockup: toggle música, campana, PlanProgressStrip, X/Y de meta.)

## 2) Lección (loop + fin)
- Mockup: mockups/Leccion.dc.html · Implementación: `lesson_player_screen.dart`, `lesson_complete_screen.dart`, `lesson_preview_screen.dart`, `exercises/common.dart`
- Estado: ✅ **FIEL (2026-07-09)** (el más cercano de todos) · Esfuerzo: **M**
- Coincide: top bar (X, barra, corazón `#FF4D6D`, chip skill `#EDEBFF`) hex exactos; zona de construcción + placeholder copy y hex EXACTOS; `JzTile` prácticamente exacta (labio `0 4px 0 #D4D8E8`); COMPROBAR habilitado/deshabilitado exactos; feedback `#E5F8EE/#FFE9ED` exactos + animación de entrada fiel; Frame B: gradiente header EXACTO, tiles XP/PRECISIÓN/ORO exactos, combo y racha fieles, confetti.
- ✅ **ARREGLADO (2026-07-09 · solo cliente, NO toca grading/loop/scoring):**
  - **[P1] Labio 3D en `_BigButton`** (COMPROBAR/CONTINUAR): sombra dura `0 6px 0 <depthColor>` + hundido al
    presionar (translateY 4), idéntico a `PrimaryButton`/mockup. Reduce-motion-aware. Los 3 call-sites pasan
    el `depthColor` real (primary/success/coral/gold/deshabilitado).
  - **[P1] Botón ALTAVOZ en la frase origen** (word_bank/reorder): `_PromptText` pinta un tile altavoz junto
    al enunciado entrecomillado. **Voz española** (`WordTts.speakSource`, `es-ES`): la frase origen es siempre
    español (es→X; mig 068 anti-reveal) → leer la traducción META revelaría la respuesta y la voz meta
    destrozaría el español. Sin comillas → sin altavoz. Complementa el TTS de tile (voz META por palabra).
  - **[P2] Tarjeta de skills del fin** con **barra de progreso + chip CEFR + pie motivacional** ("Sigue así
    para alcanzar B1…"), todo dato real de `user_skill_levels` (`skillsProvider` invalidado al entrar → fresco);
    degrada a chip simple si aún no cargó.
- Desviaciones restantes (P2, no bloqueantes):
  - Copy feedback: "+15 XP · combo x3 🔥" en la franja (el combo vive en el top bar); estado near dorado (extra app).
  - Zona de construcción sin líneas-guía; minHeight 96 vs 118.
  - Guacamayo+globo en la fila del enunciado: la mascota ya es **SVG vector** (gap #3 cerrado); asomarla en la fila del enunciado del loop queda como pulido menor.
  - Chip racha "+1" verde vs "+1 hoy" naranja; CONTINUAR final sin gradiente; confetti ráfaga vs loop; glow del header.
- Extras app (más allá del mockup): estado near, hito racha, congelador, DailyGoalBar, TipCard, repaso de errores.

## 3) SinVidas
- Mockup: mockups/SinVidas.dc.html · Implementación: `lesson/widgets/no_hearts_sheet.dart`
- Estado: ✅ **FIEL (2026-07-09)** (con honestidad; ver timer) · Esfuerzo: **M**
- Coincide: sheet blanco r30 + asa; 5 corazones vacíos `#E2E5F0`; título "Te quedaste sin vidas ❤️" copy EXACTO; botón fantasma final.
- ✅ **REHECHO (2026-07-09 · solo cliente visual; NO toca la economía de vidas/oro):**
  - **Guacamayo asomado** sobre la hoja (`ParrotMascot` bob, reduce-motion-aware) + **backdrop violeta** (`barrierColor` tintado) del mockup.
  - Las **3 opciones** del mockup como tarjetas fieles (icon-tile + título/subtítulo + trailing): **"Ver un anuncio"** en estado HONESTO **"Pronto"** (ads = Fase 2, sin infra → deshabilitado y etiquetado, NO botón muerto); **"Recargar todas · 🪙50"** (cobro REAL `buy_hearts`, el P0); **"Vidas ilimitadas · PREMIUM"** (card violeta con labio 3D → enlaza a `PremiumScreen` real).
  - **TIMER — decisión honesta (paso 0, verificado en BD/código):** NO existe regeneración de vidas por tiempo (`hearts_updated_at` nunca se lee para sumar vidas; no hay cron; en la lección las vidas son LOCALES y empiezan en 5 cada lección). Un contador "próxima vida gratis en MM:SS" sería una **promesa falsa** (prohibido) → se reemplaza por una tarjeta HONESTA con el **corazón coral pulsante** (jzPulseHeart, en un anillo) + la verdad: **"Vidas gratis en tu próxima lección · cada lección empieza con 5 ❤️"**. La recarga de pago sirve para seguir ESTA lección ahora. Se corrigió también el copy `noHeartsMsg` (antes decía "se regeneran con el tiempo", falso).
  - Motion del mockup (jzBob del loro, jzPulseHeart) reduce-motion-aware; sheet **scrollable** (isScrollControlled) → no desborda en pantallas cortas. i18n es/en/pt (10 claves). Verde: analyze 0 · test 130/130 (+no_hearts_sheet: copy honesto + opciones) · build web OK.
- Diferido honesto: TIMER real de countdown (requiere implementar regen por tiempo server-side = tocar la economía, fuera de alcance); infra de ADS real; pose de celebración alterna del loro (Frame B). Verificado visualmente con golden temporal (loro + backdrop + tarjeta honesta + opciones).

## 4) Checkpoint (intro + player + resultado)
- Mockup: mockups/Checkpoint.dc.html · Implementación: `checkpoint_intro_screen.dart` + `checkpoint_player_screen.dart` + `checkpoint_result_screen.dart`
- Estado: **DESVIADO** · Esfuerzo: **M + M** (player: FIEL — el mockup no lo diseña)
- Coincide (intro): gradiente escena, badge "⚑ CHECKPOINT", copy de la hoja y del hint EXACTOS; CTA con labio `0 6px 0 #D69400`; stat-cards con sombra exacta. (Resultado): header + confetti; tarjeta "NUEVA REGIÓN DESBLOQUEADA" hex y copy exactos; rewards; rama reprobado fiel en colores.
- Desviaciones:
  - [P1] Intro sin escenografía (estrellas jzTwinkle, montañas, portal SVG tallado) — portal geométrico simple; loro sin burbuja ("¡Demuestra lo que sabes!" como texto plano).
  - [P1] Intro sin chips "QUÉ ENTRA" (temas de la unidad).
  - [P1] ✅ **ARREGLADO (2026-07-09):** el resultado aprobado tiene **mini-mapa SVG del desbloqueo** (portal superado con ✓ → camino punteado violeta→verde → siguiente región con glow) dentro de "NUEVA REGIÓN DESBLOQUEADA" — el "momento wow". + Guacamayo animado (celebrate/encourage) y halo dorado en el header.
  - [P1] ✅ **ARREGLADO:** reprobado con **anillo de score real** ("64%") + filas de refuerzo **con conteo de fallos reales** ("N fallos", formato del mockup). Degradación honesta: el servidor no expone fallos por TEMA → se usan los fallos reales POR HABILIDAD (`perSkill.graded - correct`).
  - [P2] Stats de intro hardcodeadas ("5 min / 10") vs datos reales del servidor; iconos monocolor; título sin nº de unidad; "SUPERADO"→"APROBADO"; borde dashed→sólido.
- No implementado del mockup: portal SVG + estrellas, burbuja del loro, chips de temas, mini-mapa, anillo de %, temas fallados, jzCheer/jzGlow. (Extra app: desglose por habilidad.)

## 5) Examen (resultado + certificado)
- Mockup: mockups/Examen.dc.html · Implementación: `level_exam_result_screen.dart` + `certificate_screen.dart` (intro/player: FIELES — sin frame de referencia)
- Estado: **MUY DESVIADO** · Esfuerzo: **L + L**
- Coincide: veredicto con nivel y umbral; desglose per-skill (concepto); CTA dorado; rama reprobado con reintento; certificado con doble marco, folio y verificación server-side reales.
- Desviaciones:
  - [P0] ✅ **ARREGLADO (2026-07-09):** header de celebración (gradiente violeta + confeti + guacamayo + halo + badge dorado "EXAMEN SUPERADO"; reprobado = gradiente apagado + "AÚN NO · ¡CASI!").
  - [P0] ✅ **ARREGLADO:** card "Las 4 habilidades en \<nivel\>" con barras (accuracy real por skill) vs **línea de META punteada al umbral real** + tag "META X" + chip "N/4 ✓" + escala 0/umbral/100 + "Todas alcanzan la meta — por eso se certifica" (la regla REAL de certificación per-skill ≥80%).
  - [P0] ✅ **ARREGLADO:** card "Puntaje global" (anillo N/100 con `score_global` real + chips Fortaleza/Pulir por mejor/peor skill + grid de skills). **Degradación honesta:** el percentil "top 12%" del mockup NO existe en el servidor → se omite.
  - [P0] ✅ **ARREGLADO (mig 133, 2026-07-08):** el certificado imprime el NOMBRE del titular ("Se certifica que <NOMBRE>"). Columna `holder_name` congelada al emitir (trigger desde users, misma fuente que get_profile) + backfill + `get_certificates` lo devuelve; `CertificateScreen` lo muestra (fallback a get_profile). Verificado cliente real (`verify_p0_product.py`).
  - [P1] ✅ **ARREGLADO:** reprobado con **diagnóstico per-skill** (barra de la skill más floja + "Aún no certificas X: sube tu \<skill\>" + botón "Reforzar \<skill\>" → práctica real por skill/debilidad); **botón compartir cuadrado** (copia folio+verificación); línea "✓ Verificado por el examen Jezici" en aprobado. Todo i18n es/en/pt (antes la pantalla estaba hardcodeada en español).
  - [P1] Certificado: sin ambiente oscuro (papel crema sobre `#1C1B2E`), sin marco ornamental dorado (violeta en su lugar), sin serif ceremonial (Playfair), sin sello "VERIFICADO" ni marca de agua; acciones sin "Descargar PDF" ni share LinkedIn.
  - [P2] Metadatos fuera de la tarjeta; sin URL pública de verificación; "Certificado de Inglés" hardcodeado (no course-aware).
- No implementado del mockup: celebración, META por skill, puntaje global/percentil, nombre del titular, sello/serif/oscuro, PDF, URL de verificación.

## 6) Simulacro
- Mockup: mockups/Simulacro.dc.html (Frame A hub · Frame B informe de banda) · Implementación: `simulacros_screen.dart`
- Estado: **MUY DESVIADO** (la app es un catálogo-placeholder con paywall) · Esfuerzo: **L**
- Coincide: concepto 4 secciones L/R/W/S y su mecánica; gating premium; menciones banda 0–9/IELTS/duración; lenguaje visual de tarjetas.
- Desviaciones:
  - [P0] Hub por simulacro inexistente: header navy `#2B2456→#4B3FA8→#6C5CE7` + chip PREMIUM, 4 section-cards con icono coloreado/duración/estado, contador "0 de 4", CTA "Iniciar simulacro", "se guarda tu progreso".
  - [P0] Frame "ReporteBanda" SIN pantalla: informe con banda global 6.5 (anillo dorado), "Equivale a MCER B2", 4 barras por sección, disclaimer "No sustituye un examen oficial IELTS™", feedback + descarga.
- No implementado del mockup: todo salvo el catálogo.

## 7) Onboarding (pregunta + tu plan)
- Mockup: mockups/Onboarding.dc.html · Implementación: `onboarding_screen.dart` + `widgets/onboarding_scaffold.dart` + `your_plan_view.dart`
- Estado: **DESVIADO** · Esfuerzo: **M** (pregunta) / **L** (tu plan)
- Coincide: fondo/tokens/Nunito; botón atrás casi idéntico; `PrimaryButton` con labio 3D EXACTO al mockup; opción seleccionada violeta+check; 6 opciones de minutos; "¡Tu plan está listo! 🎉" + fecha viva (AnimatedSwitcher) + palanca que recalcula.
- Desviaciones:
  - [P1] Barra de progreso continua vs 9 segmentos + contador "5/9".
  - [P1] ✅ **ARREGLADO (2026-07-09):** mascota = guacamayo escarlata **SVG vector** animado con globo de diálogo blanco (`ParrotMascot`), ya no el emoji (gap sistémico #3 cerrado).
  - [P1] Opciones de minutos como chips compactos sin badges (Relajado/Recomendado/Experto…) ni iconos (la app fusiona minutos+días en un paso — decisión razonable, visual distinta).
  - [P1] "Tu plan" sin header de celebración (confeti jzFall + glow + loro jzCheer + kicker "PERSONALIZADO PARA TI").
  - [P1] Sin MAPA DE VIAJE A2→B2 (colinas SVG, camino punteado animado, pin "ESTÁS AQUÍ", bandera "TU META") — solo 2 badges estáticos.
  - [P1] Palanca de ritmo NO reversible (mockup: toggle 15↔30 min con tarjeta que muta; app: solo sube por tiers).
  - [P2] CTA final violeta vs coral "Empezar mi viaje"; sin badge "⚡ ¡La mitad de tiempo!"; jerarquía de la tarjeta de fecha distinta.
- No implementado del mockup: confeti/glow/loro celebrando, mapa de viaje animado, toggle, badges por opción, contador de paso. (Nota: la pregunta de intensidad del mockup fue ELIMINADA a propósito — decisión de producto, no gap.)

## 8) CoachTonos (Matix)
- Mockup: mockups/CoachTonos.dc.html · Implementación: `notifications/coach_styles.dart` + `matix_banner.dart` (+ personality_test.dart)
- Estado: **DESVIADO** · Esfuerzo: **M** (correo = L, fuera de beta)
- Coincide: los 4 estilos con las MISMAS keys (mano_dura/positivo/rezago/suave) y el test de personalidad como selector; banner in-app estilo push (avatar, "Matix", autocierre); los 4 acentos del mockup YA existen como tokens (hearts/primary/streak/success).
- Desviaciones:
  - [P1] SIN acento por tono: el banner es idéntico (blanco+violeta) para los 4 estilos; el mockup colorea dot/tag/barra/CTA por estilo.
  - [P1] Sin bloque de progreso contextual (label+barra+% "Racha de 11 días · 88%") ni CTA por tono ("Recuperar mi racha", "Seguir brillando"…).
  - [P2] Nombres/samples divergen levemente; tags (Firme/Animado/Competitivo/Tranquilo) no existen.
- No implementado del mockup: canal de CORREO completo (sin SMTP = decisión beta); barra+CTA del push; acentos por tono.

## 9) Conversar
- Mockup: mockups/Conversar.dc.html · Implementación: `conversar_screen.dart`
- Estado: **MUY DESVIADO** (= distancia de FASE de producto, no descuido) · Esfuerzo: **L**
- Coincide: título/paleta/sombras; tarjeta gradiente violeta ("en vivo — próximamente"); 6 topics con práctica hablada/escrita multi-idioma; waitlist honesto.
- Desviaciones:
  - [P0] El mockup es un hub SOCIAL EN VIVO (salas, "320 en línea", compañeros verificados, "Crear sala") y la app es práctica en solitario — Fase 2 documentada.
  - [P1] Sin header con kicker "COMUNIDAD JEZICI" + pill "Tu Speaking: A2" + contador live.
  - [P1] Sin "Reto de conversación · HOY" (consigna gramatical + oro por creatividad).
- No implementado del mockup: salas en vivo, reto en pareja, "Compañeros para ti", nota de seguridad, jzLive — todo Fase 2.

## 10) Cofre
- Mockup: mockups/Cofre.dc.html · Implementación: `shop/tienda_screen.dart` (fila `_ShopCard` 🎁)
- Estado: **MUY DESVIADO** · Esfuerzo: **L**
- Coincide: estados disponible/abierto/mañana; confetti al abrir; tokens correctos; recompensa real del servidor.
- Desviaciones:
  - [P0] ✅ **ARREGLADO (2026-07-09):** PANTALLA DEDICADA de revelación full-screen (`chest_reveal_screen.dart`): fondo violeta, guacamayo festejando, sparkles, cofre que hace **wiggle** → tap/CTA lo abre (recompensa REAL de `open_daily_chest`) → **reveal con haz de luz + monedas + medalla + "+N ORO"** (jzPop) + confeti. La tienda ya no da SnackBar: el card navega a esta pantalla y refresca el saldo al volver.
  - [P1] ✅ **ARREGLADO:** animaciones (wiggle/rayos giratorios/glow/cheer/sparkles/pop del premio) reduce-motion-aware (sin animación revela directo); **CTA dorado 3D 62px** (token `goldCtaTop/Bottom/Depth` adoptado en AppColors) que **muta a verde "¡Reclamar!"** al abrir.
  - Estados disponible / abierto / **mañana** respetados (cofre gris + candado, sin RPC). i18n es/en/pt.
- (Todo el cofre del mockup implementado; la recompensa sigue siendo la real del servidor.)

## 11) Paywall
- Mockup: mockups/Paywall.dc.html · Implementación: `premium_screen.dart`
- Estado: **DESVIADO** · Esfuerzo: **M**
- Coincide: estructura header→beneficios→CTA→nota gratis; 5 beneficios conceptualmente iguales; sombras/tokens; Nunito.
- Desviaciones:
  - [P0 — justificado por beta] Selector de 3 PLANES con precios (Mensual 9,99 € · Anual 49,99 € "MEJOR VALOR · ahorras 58%" · Familiar 89,99 €) ausente — pagos inactivos.
  - [P1] Beneficios sin chip de color POR ítem (rojo/rosa/violeta/ámbar/verde) ni check verde — semántica invertida (app: candado "bloqueado" vs mockup: check "incluido").
  - [P1] CTA sin labio 3D dorado ni subtexto de trial; copy hero distinto y "inglés" hardcodeado (hay 6 cursos).
  - [P2] Header card con 👑 estático vs banner full-bleed con loro coronado animado; sin "Restaurar compra"/"Seguir gratis".
- No implementado del mockup: planes+precios (beta), trial, restaurar compra, loro animado.

## 12) Practicar
- Mockup: mockups/Practicar.dc.html · Implementación: `practice_screen.dart` (+ player/summary sin mockup)
- Estado: **MUY DESVIADO** (el hub) · Esfuerzo: **L**
- Coincide: título y los 4 conceptos núcleo (Rescate de palabras — mismo nombre —, punto débil, contrarreloj, por habilidad); contador de palabras pendientes; nota de XP; tokens.
- Desviaciones:
  - [P0] ✅ **ARREGLADO (2026-07-09):** jerarquía del hub reconstruida fiel al mockup — **header violeta** (kicker/título/subtítulo + guacamayo) + **HERO "Rescate de palabras"** (SRS) + fila del **punto débil** + fila "reforzar fallos" + **grid 2×2** + **banner de contrarreloj**. Se acabaron las 7 cards idénticas.
  - [P0] ✅ **ARREGLADO:** el HERO tiene cabecera durazno (`#FFE9D6→#FFE0E0`), pill "REPASO ESPACIADO", **contador coral con glow** (dato REAL `status.dueWords`) + copy + CTA coral "Rescatar ahora 🪝". **Degradación honesta:** la barra "Memoria media 58%" y los chips de palabras **NO se pintan** porque el provider no expone ni el % de memoria ni la lista de palabras (no se inventan datos).
  - [P1] ✅ **ARREGLADO:** el punto débil muestra **mini-barra + badge CEFR reales** (`SkillLevel.levelProgress`/`cefrLevel` de la skill débil); **contrarreloj alineado a 90 s** (antes 60) + badge "+XP EXTRA". La práctica por habilidad son tiles directos (Lectura/Escritura, las gradables en Fase 1) dentro del grid, sin bottom sheet.
  - [P2] ✅ Los modos extra (Repaso/Inmersión/Reforzar fallos) **integrados con criterio** en la jerarquía (Repaso+Inmersión en el grid 2×2, "Reforzar fallos" como fila compacta) — no se pierde ninguno. Motion sutil (glow del contador, botones 3D con hundido, guacamayo idle, reduce-motion-aware).
  - **i18n:** ✅ **toda la copia va por localización (es/en/pt)** — corregido el bug de que la pantalla salía en ESPAÑOL con la app en portugués/inglés (títulos, subtítulos, snackbars y nombres de skill).
- No implementado (P2 estético): chips de palabras y barra de memoria (dato no expuesto por el provider — Fase 2).

## 13) Ajustes
- Mockup: mockups/Ajustes.dc.html · Implementación: `settings_screen.dart`
- Estado: ✅ **FIEL (2026-07-09)** · Esfuerzo: **M**
- Coincide: título/top bar; cards blancas con sombra dura; selector de coach 4 opciones con preview; quiet hours 22:00–8:00; idiomas; cerrar sesión coral; sello de versión.
- ✅ **ARREGLADO (2026-07-09 · solo cliente, capa visual+estructura, NO toca lógica de settings/personalidad/economía):**
  - Reestructurado en **5 secciones con micro-headers MAYÚSCULOS** (IDIOMA/NOTIFICACIONES/META Y RECORDATORIOS/CUENTA/OTROS) + **AVANZADO** para interno/GDPR, cada fila con **icon-tile 36×36 coloreado + divisores 1.5px** (`_Group`/`_tile`).
  - **Loro Matix animado (`ParrotMascot` idle bob, reduce-motion-aware) + burbuja de preview del tono** seleccionado (`#F4F2FF`, texto violeta, con cola) que muestra el ejemplo del coach elegido.
  - **Toggle verde custom `#2ECC71`** (`_GreenToggle`, pista 48×28 + perilla 22 animada, reduce-motion-aware) en lugar de los `SwitchListTile` Material violetas; **guardado IMPLÍCITO** (cualquier cambio server-backed llama a `_save()` en silencio; se quitó el botón "GUARDAR AJUSTES").
  - **Toggles "Recordatorio diario" y "Aviso de racha en peligro"** — persistidos localmente (`notify_prefs.dart`, patrón `SoundController`), **no muertos**: el maestro real `push_enabled` se DERIVA de ambos al guardar (si apagas los dos, Matix deja de empujar). El scheduler de push es Fase 2 (nota honesta bajo la card).
  - **Fila "Aprendes / \<curso real\> · Objetivo \<meta\> · Cambiar"** course-aware (bandera + `targetName` + `goalLevel` reales → picker de curso que reusa `_switchCourse`).
  - **Badge "Plan gratis · Mejorar"** (gradiente dorado) en la fila Suscripción → `PremiumScreen`.
  - **"Vibración"** ahora existe y es real: `vibrationEnabledProvider` sincroniza `FeedbackFx.hapticsEnabled` → apagarlo silencia TODO el háptico de la app.
  - i18n es/en/pt (56 claves) + `ResponsiveCenter` 480. Verde: analyze 0 · test 115/115 (+settings_screen) · build web OK.
- Diferido (P2): sello JZ_BUILD sigue "dev" (bloqueado en vercel.json, limitación conocida); mascota SVG vs emoji (global).

## 14) Perfil
- Mockup: mockups/Perfil.dc.html · Implementación: `profile_screen.dart` + `widgets/skill_radar.dart`
- Estado: **DESVIADO** · Esfuerzo: **L**
- Coincide: orden macro (hero→4 habilidades+radar→plan→stats→certs/logros); copy exacto en títulos; radar real de 4 ejes violeta; filas de skill con barra+badge CEFR; badge "MÁS DÉBIL"; CTA practicar debilidad.
- Desviaciones:
  - [P1] ✅ **ARREGLADO (2026-07-09):** banner full-bleed "MI PERFIL" (gradiente violeta) + chip **"IDIOMA ACTIVO · \<curso real\> · Objetivo \<meta\> · Cambiar"** course-aware (bandera + `learnLangName`, tap → Ajustes) — no más "Inglés" hardcodeado.
  - [P1] ✅ **ARREGLADO:** anillo de XP en el avatar + badge de **nivel de viajero** + barra al siguiente. El sistema no existía (`users.player_level` nunca se actualiza) → implementado simple y honesto client-side desde `xp_total` (`traveler_level.dart`, progresión triangular T(n)=50·(n−1)·n, determinista, con test).
  - [P1] ✅ **ARREGLADO:** radar con **anillo de META punteado + tag "META \<nivel\>"**, **vértices coloreados** (coral = bajo la meta) y **labels localizados** (fix i18n: antes salían en español vía kSkillEs).
  - [P1] ✅ **ARREGLADO:** alerta de punto débil con **mascota + botón coral "Practicar"**; filas de skill **coloreadas por estado** (débil/bajo meta = coral, con "X → Y · %").
  - [P1] ✅ **ARREGLADO:** certificados con **card BLOQUEADA con requisitos** ("Necesitas \<nivel\> en las 4" + 4 mini-barras verde/coral por examReady real + "N de 4 listas", tap → examen si está desbloqueado) + **medalla** con check para los obtenidos.
  - [P1] ✅ **ARREGLADO:** stats con **calendario semanal de racha** (días activos derivados de la racha real, "Mejor: N", HOY 🔥) + **tiles Liga** (división+puesto reales) **y Logros**.
  - [P2] Meta diaria como barra arriba vs anillo dentro de "Mi plan"; sin sheen deslizante en la medalla (glow estático).
- Diferido P2: sheen animado de la medalla, meta diaria dentro de "Mi plan".

## 15) Ligas
- Mockup: mockups/Ligas.dc.html · Implementación: `leagues_screen.dart`
- Estado: **MUY DESVIADO** · Esfuerzo: **L**
- Coincide: ranking semanal con fila-usuario resaltada, top-3, zonas verde/coral; estados extra bien resueltos que el mockup no contempla (skeleton, error, beta <13).
- Desviaciones:
  - [P0] ✅ **ARREGLADO (2026-07-08):** el header ya NO es bronce hardcodeado — refleja la división REAL (`DivisionTheme.of(lg.division)`: gradiente+emblema por bronce/plata/oro/zafiro/rubi/diamante, colores de Ligas.dc). Verificado cliente real 2 divisiones (`verify_p0_product.py`: get_league oro→oro, diamante→diamante) + test unitario. (Pendiente P1: emblema-medalla 128px con laureles/halo animado — mejora estética, no bug.)
  - [P0] ✅ **ARREGLADO (2026-07-09):** banner violeta con **emblema-medalla** (CustomPaint: medalla con gradiente de la división + estrella + cintas + laureles + halo pulsante reduce-motion-aware) + **fila de las 6 divisiones** (actual destacada con anillo blanco y más grande, futuras a 50%).
  - [P1] ✅ **ARREGLADO:** **countdown "Termina en Xd Yh"** (weekStart real + 7 días, `jz_close_weeks`); separadores **con división destino** ("SUBEN A ZAFIRO"/"BAJAN A PLATA", espejo de jz_div_up/down); filas **con tinte por zona + tags** ("Sube"/"En riesgo"/"¡Mantente arriba!"); **avatares coloreados** por persona; **top-3 con círculos-medalla** rellenos.
  - [P1] ✅ **ARREGLADO:** **mascota animadora** con globo "¡Sigue subiendo! 💪" flotando sobre el ranking.
  - [P2] ✅ Rótulo "XP esta semana" añadido. (El segmented "Mi liga/Tablas" se mantiene — extra de la app.)
- Estados buenos conservados: skeleton, error, beta <13 (aviso + sin zonas engañosas).

---

## Orden sugerido de implementación (por impacto ÷ esfuerzo)

**Tanda 1 — quick wins de alto impacto (S/M):**
1. **Labio 3D en `_BigButton`** del loop (COMPROBAR/CONTINUAR) — el CTA más pulsado, tokens ya existen (Lección, S).
2. **Acentos por tono en Matix** + CTA/barra en el banner — tokens ya existen (CoachTonos, S–M).
3. **Nombre del titular en el certificado** (P0 de producto, no solo visual) + "Verificado por el examen Jezici" (Examen, S–M).
4. **Ligas: emblema/gradiente por división REAL** (hoy bronce hardcodeado) + countdown de cierre + pills "SUBEN A X" (M).
5. **SinVidas: cobrar el oro que el copy promete** (o corregir el copy) + timer de regeneración (M).
6. **Checkpoint intro: datos reales** (min/preguntas del servidor) + chips "QUÉ ENTRA" (S–M).

**Tanda 2 — momentos "wow" (M/L):**
7. Onboarding "Tu plan": header de celebración + mapa de viaje + toggle reversible (L).
8. Cofre: pantalla de revelación dedicada (cerrado→abierto) (L).
9. Checkpoint resultado: mini-mapa de desbloqueo + anillo de % en reprobado (M).
10. Examen resultado: header celebración + card "4 habilidades vs META" (L).
11. Practicar: jerarquía del hub (hero SRS + grid) + contrarreloj 90 s + badge XP (L).

**Tanda 3 — sistema y pulido (L, transversal):**
12. Mascota SVG única (sustituir 🦜 emoji en mapa/lección/perfil/ligas/ajustes) + jzBob (L).
13. Mapa: portal de examen + escenografía costa/ciudad + anillo de progreso del nodo (L).
14. Perfil: radar con META + cert bloqueado con requisitos + calendario de racha (L).
15. Ajustes: icon-tiles + secciones + toggles de recordatorio (M).
16. Tokens que faltan: CTA dorado 3D (`#FFDD7A/#F4B400/#D69400`) + adoptar `AppSpacing/AppRadius` (S por pantalla, deuda de UX_AUDIT).

**Fase 2 / bloqueado (NO abordar ahora):** Conversar social en vivo; planes+precios del
Paywall; canal de correo del coach; hub+informe de banda de Simulacros (requiere el motor de
simulacros); ads/premium de SinVidas.
