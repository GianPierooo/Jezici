# AUDIO_PWA_ANALISIS.md — Audio/Speaking robusto + PWA instalable

> Análisis a fondo (2026-07-19). **Solo lectura: cero código en esta pasada.** Fuentes: código real
> (`app/lib/core/audio`, `core/speech`, `core/pwa`, `web/`), **verificación en vivo** sobre
> jezici.space (manifest/sw/iconos/headers de Storage con curl), y documentación actual (MDN Web
> Speech API, Chrome install criteria, autoplay policies, bugs conocidos de WebKit — enlaces al final).
> Contexto: Gian reporta (a) audio que no suena en algunos dispositivos y en PC, (b) fallos del
> speaking con transcripción en vivo. Decide Gian; plan priorizado al final de cada frente.

## 0 · Resumen ejecutivo (los 5 hallazgos que más importan)

1. **El path de reproducción de audio falla EN SILENCIO TOTAL y sin telemetría.** `AudioEngine` web
   tiene ~20 `catch (_) {}`; `playUrl` no tiene canal de error; si un MP3 no llega o no decodifica,
   el botón queda 12 s "sonando" y vuelve a play **sin ningún mensaje** — y **cero eventos a Sentry**
   (`audio_engine_web.dart:168-201`, `audio_play_button.dart:48-60`). Por eso "no suena en algunos
   dispositivos" es indiagnosticable hoy: no hay dato. **El fix #1 no es adivinar la causa: es
   instrumentar el fallo** (P0-A).
2. **`continuous=true` — el fix que arregló Android — es el sospechoso #1 del speaking roto en iOS.**
   Documentación y reportes actuales de WebKit: `continuous` es inestable/"inútil" en iOS
   (reconocimiento que se detiene solo, interim duplicados tras dejar de hablar, `isFinal` que nunca
   llega → proceso sin fin, throttling). La app lo fija incondicional (`speech_recognizer_web.dart:229`).
   El estándar estable en iOS es **push-to-talk por segmentos** (continuous=false + acumulación).
3. **TTS en vivo (speechSynthesis) depende 100% de las voces del SO** — en un PC/navegador sin voz
   del idioma meta, tiles/SRS/glosario/tips **no suenan y no avisan** (`word_tts_web.dart:87` traga
   todo). Es la explicación más probable del "no suena en PC" (ya se comprobó en sesión previa: un
   entorno con solo voces es-ES). El audio de LECCIONES (MP3 pregrabado) no depende de esto.
4. **Dos huecos concretos del reconocedor**: (a) tocar "Detener" durante el preflight `getUserMedia`
   es un no-op → mic arranca igual y el botón queda atascado (`speech_recognizer_web.dart:174,315`);
   (b) el timeout de 15 s solo se arma DESPUÉS de `sr.start()` → un `getUserMedia` colgado (WebView,
   mic ocupado) deja el botón en "Detener" para siempre (`:239`).
5. **La PWA YA cumple HOY todos los criterios de instalabilidad de Chrome** (verificado en vivo:
   manifest válido + iconos 192/512 any+maskable + sw.js con fetch handler + HTTPS; bridge
   `beforeinstallprompt` + tarjeta + sheet iOS ya construidos). El frente 2 es **pulido y
   distribución** (dónde/cuándo ofrecer instalar), no elegibilidad.

---

# FRENTE 1 — AUDIO + SPEAKING

## 1.1 · PASO 0: mapa del stack real

**Reproducción — DOS motores separados (por diseño, no se mezclan):**

| Motor | Qué reproduce | Cómo | Superficies |
|---|---|---|---|
| **`AudioEngine`** (Web Audio API: `AudioContext`+`decodeAudioData`+BufferSource; sin `<audio>` para no disparar el "now playing" de iOS) | MP3 pregrabados de Storage (listening, historias, placement, chat de voz, SFX, música) | `playUrl`/`playAsset`/`startLoop`, caché de buffers, ducking automático de música | `AudioPlayButton` (listening `listening_exercise.dart:26`, historias `story_reader_screen.dart:178`, placement `placement_test.dart:256`), `_VoiceBubble` chat (`friends.dart:1443`), SFX (`feedback_fx.dart`), música mapa (`music_service.dart`) |
| **`WordTts`** (Web Speech `speechSynthesis`, TTS EN VIVO) | Lo que NO tiene clip: tiles word_bank/reorder, match, SRS (oración/palabra tras revelar), glosario, tips, frase modelo de speaking | `speakWord` con el fix getVoices (diferir hasta `voiceschanged` + `warmUp()` en main + ranking de voces + jamás voz de otro idioma) | `SpeakableText`/`SpeakablePhrase` (`srs_review_screen.dart:372`, `speaking_widgets.dart:22`, glosario, tips) |

**Unlock/autoplay (ya construido):** gate global de un disparo — `_AudioUnlockGate` en `main.dart:99-125`
llama `ctx.resume()` **síncrono dentro del primer `PointerDown`** (la práctica recomendada); además
CADA `playAsset/playUrl/startLoop` hace `_resumeIfNeeded` (await resume) → el contexto re-suspendido al
volver de background se recupera solo al reproducir. `index.html` no tiene bridges de audio (todo vive
en Dart); el `visibilitychange` de index.html es solo para la pantalla negra de CanvasKit.

**Reconocimiento (SpeechRecognition) — `speech_recognizer_web.dart`:**
`init()` = detección de ctor (`SpeechRecognition`/`webkitSpeechRecognition`) + Permissions API sin
prompt (denied ya-conocido → mic ni se ofrece). `listen()` = `getUserMedia` explícito bajo el gesto
(pistas liberadas al instante; resuelve el prompt ANTES de arrancar — fix del 1er intento Android),
luego `SpeechRecognition` con `continuous=true`, `interimResults=true`, timeout 15 s, **rescate del
último interim en `onend`** (Android a veces termina sin final). Errores tipados (`denied`/`no-mic`/
`network`/`unsupported`) + mensajes por causa (`mic_messages.dart`). Superficies: lección
(`speaking_exercise.dart` — **stub: nunca gatea el avance**, salida "Ya lo leí ✓"), placement
(`placement_test.dart` — mic muerto → excluye la skill, "Saltar los ejercicios de hablar"), Conversar
(dicta al TextField, modo escribir siempre disponible). Transcripción en vivo pintada en las 3
(`LiveTranscript`). Matching: `speechMatchRatio` = max(word-overlap, char-ratio-Levenshtein) sobre
texto normalizado (apóstrofes, homófonos u→you/gonna…, números palabra↔dígito), umbral 0.6.

**Verificado en vivo (no asumido):** Storage responde `Access-Control-Allow-Origin: *`,
`Content-Type: audio/mpeg`, `Accept-Ranges` — **CORS/headers NO son el problema estructural**.
(Nota menor: `Cache-Control: no-cache` → cada sesión re-descarga los MP3; el buffer solo se cachea
en memoria. Y el SW ignora cross-origin → los MP3 jamás se cachean offline. Perf, no correctitud.)

## 1.2 · Matriz de soporte REAL por navegador/OS (2026)

| Capacidad | Chrome/Edge desktop | Chrome Android | Safari macOS | Safari iOS | Firefox | WebView in-app (IG/WhatsApp/FB) |
|---|---|---|---|---|---|---|
| **MP3 (Web Audio)** | ✅ | ✅ | ✅ (unlock estricto — ya cubierto) | ✅ (unlock estricto — ya cubierto) | ✅ | ✅ normalmente |
| **TTS `speechSynthesis`** | ✅ pero **depende de voces instaladas** (Windows sin voces del idioma → silencio) | ✅ vía Google TTS (casi siempre hay voces) | ✅ voces del SO | ✅ voces del SO | ⚠️ pocas/ninguna voz en muchos SO | ⚠️ variable |
| **STT `SpeechRecognition`** | ✅ Chrome/Edge (server-based, requiere red) · Brave lo DESHABILITA (`service-not-allowed`) | ✅ (server-based) | ⚠️ 14.1+ `webkit`-prefijo, razonable | ⚠️ 14.5+ `webkit`, **inestable**: `continuous` roto, interim duplicados, `isFinal` que no llega, 1er intento falla, se detiene solo | ❌ tras flag `dom.webspeech.recognition.enable` (OFF por defecto) | ❌ en la práctica: o no expone la API, o `getUserMedia`/servicio bloqueado → `not-allowed` inmediato |

**Qué hace HOY la app en cada caso:**
- Sin ctor (Firefox, WebViews sin API) → `unsupported` → "prueba con Chrome o Edge" + salida
  (Ya lo leí / Saltar / Escribir). ✅ correcto.
- Permiso ya denegado (o Brave) → `denied` → "actívalo en el candado 🔒". ✅ en navegador real;
  **⚠️ ENGAÑOSO en WebView in-app** (no hay candado ni ajustes de sitio — el usuario no puede seguir
  la instrucción).
- Safari iOS → la app trata iOS igual que Chrome (`continuous=true`) → **aquí es donde "falla el
  speaking"** con los bugs de WebKit de la tabla. El rescate del interim mitiga algo, pero interim
  duplicados y sesiones que no terminan no están manejados.
- TTS sin voz del idioma → **silencio sin ningún aviso** (degradación honesta pero invisible).

## 1.3 · Los errores reportados — hipótesis concretas por síntoma

**Síntoma A: "el audio no suena en algunos dispositivos / en PC"** (ordenadas por probabilidad):
- **A1 · TTS sin voz del idioma (PC).** En desktop (sobre todo Windows/Firefox, o Chrome sin los
  language packs) no hay voz en/fr/it/de/nl → todo lo que suena por `WordTts` (tiles, match, SRS,
  glosario, frase modelo de speaking) calla sin aviso. El audio de listening (MP3) sí suena → el
  usuario percibe "a veces suena, a veces no". Evidencia: ya reproducido en sesión previa (entorno
  con solo voces es-ES).
- **A2 · Fallo de red/decode del MP3, invisible.** `isUrlAvailable` es optimista (solo un 400 de
  Storage deshabilita el botón; 404/timeout/CORS del probe → `true`), y si el GET/decode real falla,
  `playUrl` retorna sin error → botón activo 12 s y de vuelta, sin mensaje NI evento Sentry
  (`audio_engine_web.dart:219-231`, `audio_play_button.dart:53-59`). En redes móviles flojas esto se
  percibe exactamente como "no suena".
- **A3 · Primer toque con voz por defecto (ventana de 350 ms).** Si `voiceschanged` tarda >350 ms,
  el fallback habla igual con la voz por defecto (acento incorrecto) — el bug de "dos voces" acotado
  al arranque lento (`word_tts_web.dart:73-84`).
- **A4 · Contexto suspendido, caso residual.** El gate + `_resumeIfNeeded` cubren casi todo; el gate
  es `PointerDown` (un usuario 100% teclado en desktop no lo dispara — marginal porque cada play
  también resume). Riesgo real bajo; no es la causa principal.
- **A5 · Chat de voz atascado.** `_VoiceBubble` no tiene failsafe: clip que no decodifica → burbuja
  "reproduciendo" para siempre (`friends.dart:1443-1473`).

**Síntoma B: "el speaking falla / la transcripción en vivo"**:
- **B1 · iOS WebKit + `continuous=true`** (la hipótesis fuerte, ver 1.2): sesiones que se cortan
  solas, interim duplicados que ensucian la transcripción en vivo, `isFinal` que nunca llega (el
  usuario ve el texto pero el ejercicio "no procesa" hasta el timeout de 15 s).
- **B2 · Doble-tap / preflight colgado**: "Detener" durante el preflight no cancela nada → botón
  atascado, mic que arranca "solo" (huecos 1-2 del §0). En dispositivos lentos el preflight dura
  cientos de ms → ventana real.
- **B3 · `no-speech` sin reintento**: un transitorio (empezó a hablar tarde) da "No te escuché" sin
  un reintento automático; y un corte de `network` **descarta los parciales ya reconocidos**
  (`_fatalErrored` suprime el final) — se pierde lo dicho.
- **B4 · Brave/WebView** → `denied` con mensaje que no aplica (el candado).
- **B5 · Ruido/acento** → matching <0.6. Esto es techo físico, no bug (ver 1.5); el 0.6 con
  max(word-overlap, char-ratio) ya es leniente y la normalización (homófonos, números) es sólida.

## 1.4 · Mejores prácticas actuales vs estado de la app

| Práctica (investigada) | Estado | Gap |
|---|---|---|
| Unlock de audio en primer gesto + resume por reproducción | ✅ ya implementado (gate + `_resumeIfNeeded`) | — |
| Detección de capacidad ANTES de ofrecer el ejercicio | ✅ `init()` + Permissions API; placement excluye la skill; lección "Ya lo leí"; Conversar modo escribir | Falta detectar **WebView in-app** (UA sniffing: `Instagram`, `FBAN/FBAV`, `; wv)`, `Line/`) y dar SU mensaje ("ábrelo en Chrome/Safari" en vez del candado) |
| Push-to-talk estable en iOS (no `continuous`, no auto-restart) | ❌ `continuous=true` incondicional | En WebKit: `continuous=false` por segmento + acumulación manual (el patrón ya existe en Conversar con `_sttBase`) + dedup de interim |
| Interim results pintados en vivo | ✅ 3 superficies con `LiveTranscript` | Dedup para WebKit (interim repetidos) |
| Timeouts y reintentos | ⚠️ 15 s tras `start()` | Watchdog que cubra el **preflight**; cancel real del preflight en `stop()`; 1 reintento automático de `no-speech`; conservar parciales en `network` (mostrarlos con aviso, no tirarlos) |
| Feedback por causa ("no te escuché", permiso, sin mic, red) | ✅ tipado (`mic_messages.dart`) + "No te escuché" | "Hay mucho ruido" NO es detectable con la API (no expone SNR) → no prometerlo; sí se puede sugerir "habla más cerca" cuando llega interim pero el score final es bajo |
| Tolerancia de matching | ✅ normalización + homófonos + números + umbral 0.6 max(overlap, char-ratio) | Suficiente. Mejora menor: tabla de homófonos por idioma (hoy solo en); no urgente porque el 0.6 char-ratio ya perdona elisiones |
| **Canal de error + telemetría de reproducción** | ❌ inexistente (todo `catch (_){}`) | El gap más grande: sin esto no se puede diagnosticar NADA de lo que reporta Gian |
| Aviso de "sin voz TTS para el idioma" | ❌ silencio | Detectable: tras `voiceschanged`, si no hay voz del idioma base → avisar UNA vez (banner/nota), aclarando que las lecciones con audio no se afectan |

## 1.5 · El TECHO honesto (qué es alcanzable y qué no)

**No alcanzable (que nadie promete, ni Duolingo):**
- STT en **Firefox** (API tras flag) y en **WebViews in-app**: no existe camino. Lo correcto es
  detectarlo y degradar con explicación específica.
- **100% de acierto con ruido/acento**: el reconocedor es una caja negra del navegador (Chrome =
  servidor de Google; Safari = Siri). No controlamos el modelo. El matching leniente al 0.6 es el
  amortiguador correcto.
- **Transcripción en vivo fiel en iOS**: WebKit la degrada por diseño (throttling, duplicados). Lo
  honesto es push-to-talk por segmentos y no depender de interim para nada crítico.
- Detección de "mucho ruido": la API no expone señal; solo heurística indirecta.

**El estándar honesto alcanzable (la barra a la que apuntar):**
1. **Ningún fallo de audio/mic es invisible**: todo fallo produce (a) un mensaje inmediato y
   accionable al usuario, y (b) un evento etiquetado en Sentry (`jz_audio`/`jz_mic`). Hoy (b) es 0%.
2. **Ningún botón muerto ni espera >2-3 s sin feedback**: watchdogs en preflight y reproducción.
3. **El speaking JAMÁS bloquea el avance** (ya es así: stub + Ya-lo-leí + saltar + escribir) — se
   conserva como invariante.
4. **Cada plataforma recibe su mejor camino**: Chrome/Edge = continuous + interim; iOS = segmentos;
   Firefox/WebView = salida limpia con el mensaje CORRECTO para ese entorno.
5. **El TTS avisa una vez cuando el dispositivo no tiene voz del idioma** (y qué sí funcionará).

## 1.6 · Plan de implementación priorizado (F1)

| Prio | Qué | Por qué primero | Esfuerzo |
|---|---|---|---|
| **P0-A** | **Canal de error + telemetría de reproducción**: `playUrl/playAsset` con `onError`; `AudioPlayButton` muestra estado de error (icono + "No se pudo reproducir · reintentar") en vez del failsafe mudo de 12 s; failsafe + error en `_VoiceBubble`; `reportError(rpc:'jz_audio_play')` con tags (url-host, superficie, ctx.state). | Convierte "no suena en algunos dispositivos" de misterio en dato; arregla la UX del fallo a la vez | ~1 día |
| **P0-B** | **Reconocedor robusto**: watchdog del preflight (~4 s); `stop()` cancela el preflight (flag `_cancelled` chequeado tras el await); **rama iOS/WebKit: `continuous=false` + acumulación por segmentos + dedup de interim**; telemetría `jz_mic` de errores del reconocedor. | Ataca directamente el síntoma B (iOS + botón atascado) | ~1-1.5 días |
| **P1** | Detección de WebView in-app (UA) → mensaje propio "ábrelo en Chrome/Safari" (no el candado); 1 reintento automático de `no-speech`; en `network` conservar y mostrar los parciales con aviso; aviso único de "sin voz TTS para {idioma}" tras `voiceschanged`. | Cierra los mensajes engañosos y las pérdidas de texto | ~1 día |
| **P2** | Fallback de 350 ms → esperar `voiceschanged` hasta ~1.5 s solo en la 1ª locución; cache-control/precarga de MP3 frecuentes (SW runtime cache same-session); unlock también en primer evento de teclado. | Pulido | ~0.5 día |

---

# FRENTE 2 — PWA INSTALABLE

## 2.1 · PASO 0: estado actual (verificado EN VIVO sobre jezici.space)

**Veredicto: la PWA cumple HOY los 4 criterios duros de instalabilidad de Chrome.** Verificado con
curl sobre producción (no solo el repo):

| Criterio Chrome | Estado en vivo |
|---|---|
| HTTPS | ✅ |
| Manifest válido (name/short_name/start_url/display standalone/theme/background) | ✅ 200 `application/json` con todos los campos |
| Iconos 192 + 512 (y maskable) | ✅ 4 iconos 200 (192/512 × any/maskable, `?v=5`) |
| SW registrado **con fetch handler** | ✅ `sw.js` v5 custom (network-first shell + SWR estáticos + push); `--pwa-strategy=none` (sin SW de Flutter) |

**Y el flujo de instalación ya está construido:** `beforeinstallprompt` capturado en index.html
(`jzDeferredPrompt` + `jzShowInstall()` → prompt nativo), tarjeta **"Instalar Jezici"**
(`push_install_cards.dart:164`) en el centro de notificaciones, **sheet iOS con los 3 pasos manuales**
(Compartir → Añadir a pantalla de inicio → abrir desde ahí), y detección de standalone
(`display-mode: standalone` + `navigator.standalone`) que oculta la tarjeta una vez instalada.
apple-touch-icon 180 ✓, meta `apple-mobile-web-app-*` ✓, theme-color ✓.

**Hallazgos/huecos (ninguno bloquea la instalación):**
1. **Apex redirect**: `jezici.space` → 308 → `www.jezici.space`. La instalación queda anclada a
   `www` (correcto y consistente); solo cuidar que TODO lo compartido (OG, enlaces) use el mismo host
   canónico para no duplicar historia/permisos por host. El `og:url` aún dice `https://jezici.space`.
2. **`id` y `scope` ausentes en el manifest.** Sin `id`, la identidad de la app instalada queda atada
   al `start_url` — declarar `"id"` estable es la práctica recomendada actual; `"scope"` explícito
   evita ambigüedad. Trivial de añadir.
3. **Descubribilidad baja del instalador**: la tarjeta vive SOLO en el centro de notificaciones (la
   campana). Un usuario que nunca abre la campana jamás ve "Instalar".
4. **Iconos con `?v=5` en el manifest pero precache del SW sin query** (`sw.js:10`) → el precache no
   cubre las URLs exactas del manifest (funciona por SWR; solo incoherencia).
5. **`vercel.json` sin bloque `headers`**: Vercel infiere content-types (bien), pero no hay
   `Cache-Control: no-cache` explícito para `sw.js` (riesgo menor de SW pegado en CDN; mitigado por
   skipWaiting + network-first).
6. **Sin splash screens iOS** (`apple-touch-startup-image`): la PWA instalada en iOS abre con fondo
   plano antes del splash DOM propio. Cosmético.
7. **Sin `screenshots` en el manifest**: Chrome moderno los usa para la "richer install UI" (diálogo
   grande con capturas). Opcional, sube la conversión del prompt.

## 2.2 · Plan del frente 2

**Manifest afinado (P1, trivial):** añadir `"id": "/"` (o `"/?source=pwa"` estable), `"scope": "/"`;
opcional `screenshots` (2 capturas móvil, p.ej. mapa + lección) para la richer install UI; alinear el
precache del SW con las URLs `?v=5`. Actualizar `og:url` a `https://www.jezici.space` (host canónico).

**Estrategia del prompt (P1 — el cambio de mayor impacto del frente):** ofrecer instalar en un
**momento de valor**, no en frío:
- Gatillo propuesto: al **completar la 1ª lección** (pantalla de celebración) o en la **2ª sesión**
  — una tarjeta/botón "Lleva Jezici a tu pantalla de inicio" que llame `jzShowInstall()` (Android/
  desktop) o abra el sheet iOS.
- Respetar el rechazo: si el usuario lo cierra, no volver a ofrecer por N días (pref local), y dejar
  siempre el acceso pasivo en Ajustes + centro de notificaciones (hoy solo campana → añadir fila en
  Ajustes "Instalar la app").
- Nunca interrumpir un ejercicio; nunca más de un recordatorio por sesión.

**iOS (documentar y no prometer):** no existe `beforeinstallprompt` → el sheet manual actual es el
camino correcto (mantener). Límites a comunicar con honestidad: **push web en iOS SOLO con la PWA
instalada y iOS 16.4+** (la tarjeta de push ya lo dice ✓); sin instalación automática; en la UE,
iOS 17.4+ tiene restricciones adicionales de PWA según región/versión — no construir nada que dependa
de push iOS como canal garantizado.

**Qué NO prometer (techo honesto del frente 2):** prompt automático en iOS (no existe); push iOS sin
instalar (imposible); badging/background-sync fiables multiplataforma (soporte parcial); "funciona
offline" completo (la app es API-driven — el SW da shell offline, no lecciones offline; no venderlo
como app offline).

**Prioridad relativa:** el frente 1 (P0-A/P0-B) va ANTES que todo el frente 2 — los criterios de
instalación ya se cumplen; el audio/speaking es lo que duele a usuarios reales hoy.

## Fuentes
- [SpeechRecognition — MDN](https://developer.mozilla.org/en-US/docs/Web/API/SpeechRecognition) · [Web Speech API — MDN](https://developer.mozilla.org/en-US/docs/Web/API/Web_Speech_API) · [caniuse speech-recognition](https://caniuse.com/speech-recognition)
- Bugs WebKit/iOS: [interimResults en Safari iOS (WebKit/Documentation #120)](https://github.com/WebKit/Documentation/issues/120) · [Taming the Web Speech API (continuous inútil en iOS)](https://webreflection.medium.com/taming-the-web-speech-api-ef64f5a245e1) · [Estabilizar WebSpeech en iOS (push-to-talk)](https://lilting.ch/en/articles/ios-webspeech-api-tips) · [Apple Dev Forums: bugs iOS 15+](https://developer.apple.com/forums/thread/694847)
- Autoplay: [Autoplay policy in Chrome](https://developer.chrome.com/blog/autoplay) · [Autoplay guide — MDN](https://developer.mozilla.org/en-US/docs/Web/Media/Guides/Autoplay) · [Unlock Web Audio in Safari](https://www.mattmontag.com/web/unlock-web-audio-in-safari-for-ios-and-macos) · [Web Audio best practices — MDN](https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API/Best_practices)
- PWA: [Install criteria — web.dev](https://web.dev/articles/install-criteria) · [Installable manifest — Chrome](https://developer.chrome.com/docs/lighthouse/pwa/installable-manifest) · [Making PWAs installable — MDN](https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps/Guides/Making_PWAs_installable) · [Chrome install criteria update](https://developer.chrome.com/blog/update-install-criteria)
- iOS PWA: [PWA iOS limitations 2026 (MagicBell)](https://www.magicbell.com/blog/pwa-ios-limitations-safari-support-complete-guide) · [PWAs on iOS 2026 (MobiLoud)](https://www.mobiloud.com/blog/progressive-web-apps-ios)
