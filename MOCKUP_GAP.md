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
| 3 | SinVidas.dc.html | no_hearts_sheet | MUY DESVIADO | M |
| 4 | Checkpoint.dc.html | checkpoint intro/player/result | DESVIADO | M+M |
| 5 | Examen.dc.html | level_exam result + certificate | MUY DESVIADO | L+L |
| 6 | Simulacro.dc.html | simulacros_screen | MUY DESVIADO (placeholder) | L |
| 7 | Onboarding.dc.html | onboarding_screen + your_plan_view | DESVIADO | M/L |
| 8 | CoachTonos.dc.html | coach_styles + matix_banner | DESVIADO | M |
| 9 | Conversar.dc.html | conversar_screen | MUY DESVIADO (= Fase 2) | L |
| 10 | Cofre.dc.html | tienda_screen (fila cofre) | MUY DESVIADO | L |
| 11 | Paywall.dc.html | premium_screen | DESVIADO (beta sin pagos) | M |
| 12 | Practicar.dc.html | practice_screen | MUY DESVIADO | L |
| 13 | Ajustes.dc.html | settings_screen | DESVIADO | M |
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
2. **Gap sistémico #1 — MOTION/celebración:** los mockups animan todo
   (`jzBob/jzCheer/jzFall/jzGlow/jzTwinkle/jzSheen/jzDash/jzLive/jzWiggle`); la app casi no
   anima (excepciones: pulso del nodo, confetti en complete/checkpoint, contadores, banner
   Matix). Común a las 15 pantallas.
3. **Gap sistémico #2 — botón 3D "con labio"** (`0 Npx 0 <colorDark>` + hundido al presionar):
   `PrimaryButton` lo tiene, pero el CTA del loop (`_BigButton` COMPROBAR/CONTINUAR), los CTA
   dorados (cofre/checkpoint), y varios botones secundarios NO — inconsistencia interna.
4. **Gap sistémico #3 — mascota:** el guacamayo de los mockups es un SVG propio animado con
   globo de diálogo; la app usa el emoji 🦜 estático en todas las superficies.
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
  - [P1] Mascota: SVG guacamayo animado (jzBob) vs emoji 🦜.
  - [P1] ✅ **ARREGLADO (2026-07-08):** escenografía por región enriquecida (`scenery_painter.dart`): **cordillera lejana con cumbres nevadas + nubes** (cima), **costa con mar/playa/velero** (media), 5 capas de colinas + 5 pinos de 2 capas, y **ciudad/distrito laboral con ventanas** (base). Full-bleed; la columna de nodos sigue centrada (dx0).
  - [P2] Certificado de cima sin subtítulo "Fluidez · Avanzado", sin labio 3D `0 8px 0 #E7B23A`, sin halo animado.
  - [P2] Mastered sin sheen deslizante ni banderín coral; misión sin chispa ni tarjeta lateral "★ MISIÓN".
  - [P2] ✅ **ARREGLADO (2026-07-08):** el nodo disponible tiene **ANILLO DE PROGRESO** (pista blanca + arco coral = avance de la unidad, lecciones completadas/total). (Pendiente P2: flotación/cola del globo "EMPIEZA".)
  - [P2] Etiquetas bajo TODOS los nodos (mockup: solo disponible+checkpoint, con prefijo "Lección N ·").
  - [P2] Cielo 4 paradas vs 8; sendero 34/24px vs 40/30px; sin velo blanco sobre regiones bloqueadas ni pill compacta con candado.
  - [P2] Top bar sin blur; bandera 🇬🇧 hardcodeada (no refleja el curso activo de 6 y no es botón).
- No implementado del mockup: portal de examen, costa/ciudad/nubes, sheen+banderín, anillo de progreso, chispa+tarjeta de misión, velo de zona bloqueada, jzFloat/jzGlow/jzSway. (Extras de la app sin mockup: toggle música, campana, PlanProgressStrip, X/Y de meta.)

## 2) Lección (loop + fin)
- Mockup: mockups/Leccion.dc.html · Implementación: `lesson_player_screen.dart`, `lesson_complete_screen.dart`, `lesson_preview_screen.dart`, `exercises/common.dart`
- Estado: **DESVIADO** (el más cercano de todos) · Esfuerzo: **M**
- Coincide: top bar (X, barra, corazón `#FF4D6D`, chip skill `#EDEBFF`) hex exactos; zona de construcción + placeholder copy y hex EXACTOS; `JzTile` prácticamente exacta (labio `0 4px 0 #D4D8E8`); COMPROBAR habilitado/deshabilitado exactos; feedback `#E5F8EE/#FFE9ED` exactos + animación de entrada fiel; Frame B: gradiente header EXACTO, tiles XP/PRECISIÓN/ORO exactos, combo y racha fieles, confetti.
- Desviaciones:
  - [P1] Fila del enunciado sin guacamayo+globo y sin BOTÓN ALTAVOZ junto a la frase origen (word_bank/reorder = texto plano).
  - [P1] `_BigButton` (COMPROBAR/CONTINUAR del loop) SIN labio 3D ni estado presionado — rompe el estilo firma en el CTA más usado; inconsistente con `PrimaryButton` que sí lo tiene.
  - [P2] Copy feedback: falta "+15 XP · combo x3 🔥" en la franja (el combo vive en el top bar); "Casi…" ≠ "No del todo 🦜" (la app además tiene estado near dorado que el mockup no contempla).
  - [P2] Zona de construcción sin líneas-guía; minHeight 96 vs 118.
  - [P2] Tarjeta de skills del fin sin barra de progreso, chip de nivel ni pie motivacional ("Sigue así para alcanzar B1…").
  - [P2] Chip racha "+1" verde vs "+1 hoy" blanco/naranja; CONTINUAR final sin gradiente; confetti ráfaga vs loop.
- No implementado del mockup: altavoz TTS en frase origen, loro SVG, barra+nivel+pie de skill, glow del header. (Extras app: estado near, hito racha, congelador, DailyGoalBar, TipCard, repaso de errores.)

## 3) SinVidas
- Mockup: mockups/SinVidas.dc.html · Implementación: `lesson/widgets/no_hearts_sheet.dart`
- Estado: **MUY DESVIADO** · Esfuerzo: **M** (timer+oro; ads/premium requieren infra)
- Coincide: sheet blanco r30 + asa exacta; 5 corazones vacíos `#E2E5F0` exactos; título "Te quedaste sin vidas ❤️" copy EXACTO; botón fantasma final.
- Desviaciones:
  - [P0] Faltan 3 de los 4 cuerpos del mockup: (1) TIMER "Próxima vida gratis en 28:14" con anillo + corazón pulsante + barra; (2) opción "Ver un anuncio · Recupera 1 vida"; (3) opción Premium "Vidas ilimitadas" con badge dorado.
  - [P0-coherencia] ✅ **ARREGLADO (2026-07-08):** el botón ya NO promete cobro sin ejecutarlo. Ahora la recarga **cobra oro de verdad server-side** (`buy_hearts()`, mig 026): muestra el precio real (🪙50, misma economía que la tienda — se eligió alinear al costo REAL existente en vez de hardcodear el 350 del mockup, que nada enforce), descuenta el oro y **si no hay suficiente NO recarga** (aviso inline). Verificado cliente real (`verify_p0_product.py`: con oro→recarga+descuenta 50; sin oro→no recarga, oro intacto). (Pendiente P0 estético: timer de regeneración + opción anuncio/Premium — requieren infra.)
  - [P1] Sin guacamayo asomado sobre la hoja ni backdrop especial (blur+tinte violeta).
  - [P2] 2ª mitad del subtítulo divergente; botón de recarga violeta genérico en vez de tarjeta blanca con moneda.
- No implementado del mockup: timer con countdown en vivo, opción anuncio, opción Premium, loro, jzPulseHeart/jzBob.

## 4) Checkpoint (intro + player + resultado)
- Mockup: mockups/Checkpoint.dc.html · Implementación: `checkpoint_intro_screen.dart` + `checkpoint_player_screen.dart` + `checkpoint_result_screen.dart`
- Estado: **DESVIADO** · Esfuerzo: **M + M** (player: FIEL — el mockup no lo diseña)
- Coincide (intro): gradiente escena, badge "⚑ CHECKPOINT", copy de la hoja y del hint EXACTOS; CTA con labio `0 6px 0 #D69400`; stat-cards con sombra exacta. (Resultado): header + confetti; tarjeta "NUEVA REGIÓN DESBLOQUEADA" hex y copy exactos; rewards; rama reprobado fiel en colores.
- Desviaciones:
  - [P1] Intro sin escenografía (estrellas jzTwinkle, montañas, portal SVG tallado) — portal geométrico simple; loro sin burbuja ("¡Demuestra lo que sabes!" como texto plano).
  - [P1] Intro sin chips "QUÉ ENTRA" (temas de la unidad).
  - [P1] Resultado sin mini-mapa SVG del desbloqueo (nodo check + siguiente unidad con glow) — el "momento wow".
  - [P1] Reprobado sin anillo de score ("64%") y con "REFUERZA ESTAS HABILIDADES" (skills) en vez de "REFUERZA ESTOS TEMAS" con conteo de fallos por tema.
  - [P2] Stats de intro hardcodeadas ("5 min / 10") vs datos reales del servidor; iconos monocolor; título sin nº de unidad; "SUPERADO"→"APROBADO"; borde dashed→sólido.
- No implementado del mockup: portal SVG + estrellas, burbuja del loro, chips de temas, mini-mapa, anillo de %, temas fallados, jzCheer/jzGlow. (Extra app: desglose por habilidad.)

## 5) Examen (resultado + certificado)
- Mockup: mockups/Examen.dc.html · Implementación: `level_exam_result_screen.dart` + `certificate_screen.dart` (intro/player: FIELES — sin frame de referencia)
- Estado: **MUY DESVIADO** · Esfuerzo: **L + L**
- Coincide: veredicto con nivel y umbral; desglose per-skill (concepto); CTA dorado; rama reprobado con reintento; certificado con doble marco, folio y verificación server-side reales.
- Desviaciones:
  - [P0] Resultado sin header de celebración (gradiente+confeti+loro graduado+badge "EXAMEN SUPERADO") — fondo plano con 🎓.
  - [P0] Sin card "Las 4 habilidades en B1" (barras con línea de META punteada, chip "4/4 ✓", escala CEFR, "por eso se certifica") — la app muestra % de aciertos, no niveles vs meta.
  - [P0] Sin card "Puntaje global" (anillo 87/100, "top 12%", fortaleza/pulir, grid de secciones).
  - [P0] ✅ **ARREGLADO (mig 133, 2026-07-08):** el certificado imprime el NOMBRE del titular ("Se certifica que <NOMBRE>"). Columna `holder_name` congelada al emitir (trigger desde users, misma fuente que get_profile) + backfill + `get_certificates` lo devuelve; `CertificateScreen` lo muestra (fallback a get_profile). Verificado cliente real (`verify_p0_product.py`).
  - [P1] Reprobado sin diagnóstico per-skill ("sube tu Speaking" + botón "Reforzar Speaking"); sin botón compartir cuadrado; sin línea "✓ Verificado por el examen Jezici".
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
  - [P1] Mascota emoji estática sin globo de diálogo ("¡Hagamos un plan a tu medida! 🦜").
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
  - [P0] El mockup es una PANTALLA DEDICADA de revelación full-screen (fondo violeta, cofre que wiggle → tap → premio con haz de luz y monedas); la app es una fila de lista con SnackBar.
  - [P1] Animaciones ausentes (jzWiggle/jzSpin/jzGlow/jzCheer/jzTwinkle/jzPop); CTA dorado 3D 62px que muta a verde "¡Reclamar!" vs ElevatedButton plano.
  - [P2] Copy y mascota.
- No implementado del mockup: la escena de revelación completa.

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
- Estado: **DESVIADO** · Esfuerzo: **M**
- Coincide: título/top bar; cards blancas con sombra dura; selector de coach 4 opciones con preview; quiet hours 22:00–8:00; idiomas; cerrar sesión coral; sello de versión.
- Desviaciones:
  - [P1] Sin micro-headers MAYÚSCULOS con icon-tiles por fila ni divisores — estructura de secciones distinta.
  - [P1] Sin loro Matix animado con burbuja de preview del tono.
  - [P1] Toggles Material violetas vs switch custom verde `#2ECC71`; guardado con botón "GUARDAR AJUSTES" vs guardado implícito.
  - [P1] Sin toggles "Recordatorio diario"/"Aviso de racha en peligro" (solo un toggle genérico); fila "Aprendes / Inglés · Objetivo B2 · Cambiar" ausente (lista inline de 6 cursos sin objetivo).
  - [P2] Sin badge "Plan gratis · Mejorar"; "Vibración" no existe; meta diaria como chips (más rica, distinta); pie "Jezici dev" (sello JZ_BUILD bloqueado — limitación conocida).
- No implementado del mockup: loro con burbuja, toggles de recordatorio/racha, vibración, badge de plan, icon-tiles.

## 14) Perfil
- Mockup: mockups/Perfil.dc.html · Implementación: `profile_screen.dart` + `widgets/skill_radar.dart`
- Estado: **DESVIADO** · Esfuerzo: **L**
- Coincide: orden macro (hero→4 habilidades+radar→plan→stats→certs/logros); copy exacto en títulos; radar real de 4 ejes violeta; filas de skill con barra+badge CEFR; badge "MÁS DÉBIL"; CTA practicar debilidad.
- Desviaciones:
  - [P1] Header card vs banner full-bleed con "MI PERFIL" + chip "IDIOMA ACTIVO · Inglés · Objetivo B2 · Cambiar".
  - [P1] Sin anillo de XP en el avatar ni "nivel de viajero" (badge 14, barra a Nivel 15) — sistema inexistente.
  - [P1] Radar sin anillo de META punteado + tag "META B1", sin vértices coloreados por débil/fuerte, labels no-i18n (`kSkillEs`).
  - [P1] Alerta de punto débil sin loro ni botón coral; filas de skill sin color por estado (débil no se distingue salvo el badge).
  - [P1] Certificados sin la card BLOQUEADA con requisitos ("Necesitas B1 en las 4" + 4 mini-barras + "2 de 4 listas") ni medalla animada.
  - [P1] Stats sin calendario semanal de racha ("Mejor: 28") ni tiles Liga/Logros.
  - [P2] Meta diaria como barra arriba vs anillo dentro de "Mi plan"; sin animaciones sheen/glow.
- No implementado del mockup: nivel de viajero, chip idioma activo, cert bloqueado con requisitos, calendario de racha, tiles Liga/Logros, mascota.

## 15) Ligas
- Mockup: mockups/Ligas.dc.html · Implementación: `leagues_screen.dart`
- Estado: **MUY DESVIADO** · Esfuerzo: **L**
- Coincide: ranking semanal con fila-usuario resaltada, top-3, zonas verde/coral; estados extra bien resueltos que el mockup no contempla (skeleton, error, beta <13).
- Desviaciones:
  - [P0] ✅ **ARREGLADO (2026-07-08):** el header ya NO es bronce hardcodeado — refleja la división REAL (`DivisionTheme.of(lg.division)`: gradiente+emblema por bronce/plata/oro/zafiro/rubi/diamante, colores de Ligas.dc). Verificado cliente real 2 divisiones (`verify_p0_product.py`: get_league oro→oro, diamante→diamante) + test unitario. (Pendiente P1: emblema-medalla 128px con laureles/halo animado — mejora estética, no bug.)
  - [P0] Falta la fila de las 6 divisiones (Bronce→Diamante, actual destacada, futuras a 50%).
  - [P1] Sin countdown "Termina en 2d 14h"; separadores sin división destino ("SUBEN A ZAFIRO"); filas sin tinte por zona ni tags ("Sube"/"En riesgo"); avatares grises uniformes vs coloreados por persona; top-3 emoji vs círculos rellenos.
  - [P1] Sin loro animador con globo "¡Sigue subiendo! 💪".
  - [P2] Sin rótulo "XP esta semana"; el segmented "Mi liga/Tablas" es añadido de la app.
- No implementado del mockup: emblema por división, carrusel de divisiones, countdown, pills con destino, tags/tintes por fila, avatares coloreados, mascota.

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
