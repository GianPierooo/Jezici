# Jezici — Estructura Detallada de la App (v1.1)

> Documento de construcción: define cada apartado, pantalla y dinámica al máximo detalle. Complementa al documento de estrategia (Jezici_Especificacion). **v1.1 integra las decisiones de la fase de diseño:** concepto de mapa/viaje ascendente, mascota **guacamayo escarlata**, **oro** como moneda (antes gemas), navegación con **Conversar**, **sistema de 4 habilidades**, y dinámicas **co-op** y **apostar oro**.

---

## 0. Marco

- **Idiomas al lanzamiento:** Inglés, Español, Portugués. Prioridad de contenido: **español→inglés** primero (la ruta completa); luego portugués y las inversas. Cada par es su propio árbol de contenido.
- **UI localizada** en el idioma nativo. Build **Flutter** (iOS/Android/Web). Fase 1 **sin IA**, todo determinista.
- **Principios rectores:** muy gamificado · seguimiento intenso · nivel **creíble y verificado por examen** · las **4 habilidades equilibradas**.
- **Identidad:** concepto "**el viaje hacia la fluidez**" (mapa ascendente); mascota **guacamayo escarlata** (esbelto, rojo, colorido, de los que repiten); moneda = **oro**.

---

## 1. Arquitectura de navegación

**Barra inferior (5 pestañas, solo íconos, sin texto):**
1. **Aprender** — el mapa/camino (pantalla principal).
2. **Practicar** — repaso espaciado y refuerzo de debilidades.
3. **Conversar** — conocer y hablar con gente (social/conversación).
4. **Ligas** — competencia social semanal.
5. **Perfil** — progreso, panel de 4 habilidades, certificados, plan, ajustes.

> **Exámenes ya no es pestaña:** los checkpoints y el examen de nivel viven como **hitos en el mapa**; el certificado y el acceso a simulacros van en **Perfil**.

**Barra superior (en Aprender), minimal:** idioma activo (bandera) · racha 🔥 · **oro** 🪙 · vidas ❤️ · anillo pequeño de meta diaria. Las tarjetas grandes de **meta y avance del plan se muestran en Perfil**, no sobre el mapa.

---

## 2. Entrada y onboarding (flujo paso a paso) — AUTH-FIRST (GA4)

**Entrada AUTH-FIRST:** la app abre en **Crear cuenta / Iniciar sesión** (email/contraseña; Google/Apple "pronto"). Tras autenticarse, una *puerta* (`AppGate`) decide:
- **Sin onboarding** (`user_plans.onboarding_completed = false`) → onboarding completo **obligatorio** (todo usuario lo pasa sí o sí; no entra a la app sin terminarlo).
- **Con onboarding** → directo al **mapa**.

Al terminar el onboarding, `create_plan` persiste plan + personalidad y marca `onboarding_completed = true`.

**Onboarding (9 pasos, sin redundancia — cada paso cambia algo aguas abajo):**

1. **Bienvenida** ("Construyamos tu plan", ~2 min).
2. **Idioma de la app** (es/en/pt; UI — el idioma OBJETIVO del curso es inglés). Se persiste para la i18n.
3. **Motivo** (Trabajo / Viajes / Examen / Estudios / Mudanza / Placer) → **personaliza** escenarios, recomendaciones y el enfoque del plan.
4. **Meta** (A2/B1/B2/C1) + **fecha límite** opcional → arma el plan y la fecha.
5. **Compromiso (UNIFICADO)** — minutos/día **y** días/semana en **una sola pantalla** → meta diaria + fecha.
6. **Personalidad** (4 situaciones distintas + 1 de intensidad, §9) → estilo de coach (tono de Matix).
7. **Micro-arranque** ("¿desde cero / sé algo / buen nivel?") → **solo** fija la dificultad inicial del test de ubicación.
8. **Test de ubicación adaptativo** → nivel CEFR real + las 4 habilidades (reemplaza cualquier autoevaluación).
9. **"Tu plan" (momento mágico):** nivel actual → meta, fecha estimada, horas/ritmo, enfoque por motivo y la palanca "Quiero llegar más rápido". Botón **EMPEZAR MI PLAN** → persiste y entra al mapa.

> Cambios GA4 vs. v0.1: la cuenta ya **no** se crea al final (es lo primero); se eliminó la **autoevaluación de nivel** (redundante con la ubicación; queda una micro-pregunta solo para sembrar el placement); se **unificó** minutos/día + días/semana; la personalidad bajó de 6+1 a **4+1** preguntas distintas.

**Motor de estimación de tiempo (determinista):** horas guía por nivel CEFR (referenciales, ajustables): A1 ~90-100, A2 ~180-200, B1 ~350-400, B2 ~500-600, C1 ~700-800. `horas_necesarias = horas_acum(meta) − horas_acum(actual)`; `semanas = horas_necesarias / ((min_día × días_semana)/60)`. La fecha se recalcula con el ritmo real.

---

## 3. Aprender — el mapa (pantalla principal)

**Concepto "el viaje hacia la fluidez":** un **mapa ilustrado que se sube de ABAJO hacia ARRIBA**. Cada unidad/nivel es una **región temática** con su escenografía; arriba del todo, la **cima = nivel meta + certificado**. Sensación de aventura y ascenso, no una lista.

- **Recorrido serpenteante ascendente**; el nodo actual/disponible está abajo, los próximos suben.
- **Nodos = hitos del mapa** (no círculos planos), con estados: completado / dominado (dorado) / disponible (el actual, vivo) / bloqueado.
- **Nodos especiales:** misión **"100 palabras esenciales"**; **checkpoint/examen** de unidad (portal/cofre).
- **Mascota guacamayo escarlata** como compañero de viaje, reaccionando con ánimo.
- **Top bar minimal** (oro, racha, vidas, mini anillo de meta diaria).

---

## 4. La lección (el corazón gamificado)

**Anatomía (2–5 min):** intro opcional → serie de 8–15 ejercicios con feedback inmediato (✅/❌) → pantalla de fin con recompensa.

- **Etiqueta de habilidad** en cada ejercicio (Reading/Listening/Writing/Speaking) — conecta con el sistema de 4 niveles.
- **Vidas ❤️:** 5 por defecto; error resta; a 0 se interrumpe (esperar/oro/anuncio). Menos vidas en Modo Intenso.
- **Combo de aciertos** = bonus XP.
- **Pantalla de fin:** XP, precisión %, bonus, **oro** ganado, racha, y **progreso de habilidad ("Speaking +1")**. Mascota festejando + confeti.

**Tipos de ejercicio:** opción múltiple · cloze · banco de palabras · reordenar · emparejar · traducción (ambos sentidos) · comprensión auditiva · dictado · pronunciación (leer en voz alta verificado, sin IA generativa) · escritura guiada.

---

## 5. Practicar

- **Rescate de palabras (SRS):** reintroduce lo que estás por olvidar.
- **Refuerza tu habilidad más débil:** conecta con los 4 skills ("Tu Speaking va en A2 — súbelo").
- **Práctica por habilidad:** vocabulario / gramática / listening / speaking.
- **Práctica cronometrada:** contrarreloj por XP extra.
- Cada sesión da un poco menos de XP que una lección nueva (incentiva avanzar en el mapa).

---

## 6. Conversar (apartado social)

El lugar para **conocer y hablar con gente dentro de la app** y subir tu Speaking.

- **Reto de conversación del día:** tema asignado + **puntos por creatividad** (la idea original; evaluación con IA en Fase 2).
- **Salas en vivo:** audio grupal por tema y nivel ("Charla casual · B1", "De viaje · A2").
- **Retos en pareja (co-op):** dos usuarios reman hacia una meta compartida.
- **Compañeros para ti:** aprendices a tu nivel (perfil, intereses, **verificado**) — amigable y seguro, **NO estilo app de citas**.

> **Nota de fase:** la conversación humano-a-humano es **Fase 2** (emparejamiento, moderación, seguridad, y la evaluación por creatividad necesita IA). El apartado se diseña desde ya para que la app nazca pensada para esto.

---

## 7. Exámenes y sistema de niveles

**6 tipos de evaluación:** (1) ubicación adaptativo (onboarding); (2) mini-quiz por lección (formativo); (3) **checkpoint de unidad** (gating, vive como hito en el mapa); (4) **examen de nivel + certificación** (emite el certificado); (5) **simulacro IELTS/Cambridge** (premium, 4 secciones, reporte de banda); (6) repaso espaciado + diagnóstico (continuo).

**Cocina para que se sientan reales:** banco de ítems calibrado por nivel/dificultad y etiquetado por habilidad, aleatorización anti-trampa, cronómetro, adaptatividad (idealmente IRT), economía de reintentos.

> El **examen de nivel certifica solo si las 4 habilidades llegan al nivel** (ver §8 y §10).

---

## 8. Sistema de 4 habilidades (diferenciador clave)

- Cada habilidad — **Reading, Listening, Writing, Speaking** — tiene su **propio nivel CEFR** y **sube por separado**, según los ejercicios que la entrenan (cada ítem etiqueta su habilidad).
- **Certificar un nivel exige tenerlo en las 4.** No certificas B1 si tu Speaking está en A2. Esto hace el certificado **más creíble** (competencia equilibrada, no parcial).
- **Panel de habilidades en Perfil** (radar de 4 ejes): muestra el equilibrio y **resalta la más débil**.
- El sistema **empuja a nivelar la habilidad más floja** (en Practicar y vía notificaciones). Como el speaking suele rezagarse, **empuja naturalmente hacia Conversar**.
- **Salvedad sin IA:** Speaking y Writing en Fase 1 se nivelan con **proxies** (leer en voz alta verificado, escritura guiada). La evaluación rigurosa de esas dos —y por tanto el certificado de 4 skills 100% sólido— **madura en Fase 2** con IA / corrección comunitaria.

---

## 9. Test de personalidad → motor de motivación (Matix)

**El test (onboarding):** **5 preguntas** (4 situaciones de estilo distintas + 1 de intensidad, §Test_Personalidad) que clasifican al usuario en un estilo. Cada estilo cambia el **tono** de notificaciones, correos y mensajes.

| Estilo | Tono | Ejemplo |
|---|---|---|
| Mano dura | Exigente, directo | "Faltaste hoy. Eso no va. Vuelve ya." |
| Motivación positiva | Energético | "¡12 días imparable! Hoy te toca brillar 💪" |
| Recordatorio de rezago | Comparativo | "Vas 2 días atrás. 3 de tu liga te pasaron." |
| Suave | Amable | "Cuando puedas, una lección rápida te mantiene en ritmo 🙂" |

**Escalera con techo:** suave → con dato → empujón fuerte → pausa. **Reglas:** presión sobre la conducta/meta (nunca sobre el valor de la persona); respetar horarios; el usuario recalibra la intensidad. **Disparadores:** racha en riesgo · meta sin cumplir · atraso vs plan · cuenta regresiva a examen · win-back · logro · liga. **Canales:** push + correo, sincronizados; las barras de progreso son el eje visual.

---

## 10. Nivel y certificación (creíble)

- **Credibilidad:** el examen de nivel es robusto (secciones, banco amplio aleatorizado, cronometrado, adaptativo) **y exige las 4 habilidades** en el nivel.
- **Pantalla de Certificado:** formal y orgullosa (contrasta con lo lúdico). Contiene: marca Jezici, nombre, "Inglés — B1", fecha, **folio/código de verificación**, sello, y la leyenda **"Nivel verificado mediante el examen de certificación Jezici"**. Descargable en PDF y compartible.
- **Requisito visible:** "Para certificar B1 necesitas B1 en las 4 habilidades."
- **Honestidad de marca:** en Fase 1 es certificado **interno**; la acreditación oficial (modelo McGraw-Hill de Busuu) es meta de largo plazo y se comunica como "próximamente".

---

## 11. Gamificación transversal (valores por defecto, ajustables)

- **XP:** lección ~10–20 · práctica ~5–10 · combo bonus · meta diaria configurable.
- **Oro 🪙 (moneda, antes "gemas"):** se gana en lecciones/retos; se gasta en streak freeze, vidas, reintentos, ítems.
- **Racha 🔥:** con **streak freeze** (cuesta oro). Hitos 7/30/100/365.
- **Ligas 🏆:** Bronce→Plata→Oro→Zafiro→Rubí→Diamante; grupos de ~30; reset semanal por XP.
- **Vidas ❤️:** 5; recarga por tiempo/oro/anuncio. Premium: ilimitadas.
- **Cofres / recompensa variable**, **logros/badges**, **retos diarios/semanales**, **misiones**, **Modo Intenso (opt-in)**, **win-back**.

**Dinámicas nuevas (confirmadas):**
- **Equilibrar tus 4 skills:** reto/recompensa por subir la habilidad más débil.
- **Retos en pareja (co-op):** meta compartida con otro usuario. *(Reemplaza los duelos competitivos, que encajan mal en idiomas: premian al que ya sabe, se prestan a dejarse ganar, y la presión sube el estrés. La competencia se queda en Ligas, basada en esfuerzo.)*
- **Apostar oro en tu meta:** compromiso **opcional y suave** (apuestas oro a cumplir tu racha/meta semanal). Nunca un castigo que hunda a quien batalla.

---

## 12. Perfil

- **Cabecera:** avatar, nombre, **nivel de jugador** (XP, distinto del nivel de idioma), idioma, ajustes.
- **Panel de las 4 habilidades** (radar) — el diferenciador; resalta la más débil y la línea de meta.
- **Certificados:** obtenidos (medallas) + el siguiente bloqueado con su requisito ("B1 en las 4 habilidades").
- **Mi plan** (movido aquí desde el inicio): avance al nivel meta + fecha estimada + meta diaria.
- **Estadísticas:** racha (mini-calendario), XP total, oro, liga, nº de logros.

---

## 13. Inventario de pantallas (26) — prompts de Claude Design ✅ generados

1. Splash/Bienvenida · 2. Onboarding (selección) · 3. Test de personalidad · 4. Test de ubicación · 5. "Tu plan" · 6. Crear cuenta/Login · 7. Aprender (mapa) · 8. Tarjeta de lección · 9. Lección (ejercicios) · 10. Lección (recompensa) · 11. Sin vidas · 12. Practicar (menú) · 13. Practicar (sesión) · 14. **Conversar** (hub) · 15. Checkpoint de unidad · 16. Examen de nivel · 17. Examen (resultados + veredicto) · 18. Certificado · 19. Simulacro IELTS/Cambridge · 20. Ligas · 21. Perfil (panel 4 skills) · 22. Logros/Misiones/Retos · 23. Cofre · 24. Ajustes · 25. Paywall/Premium · 26. Notificación push + correo (por estilo).

---

## 14. Diferenciadores de Jezici

1. **Plan con fecha real** (recalculable).
2. **Certificación creíble por examen.**
3. **4 habilidades equilibradas:** certificas solo si tienes el nivel en las 4 (certificado más serio).
4. **Coaches con personalidad** (incluido mano dura).
5. **Motor de insistencia** (correo + push).
6. **Conversar:** conocer y hablar con gente adentro (social real), con retos en pareja.
7. **Modo Intenso** y seguimiento con barras por todos lados.
8. (Fase 2) **Conversación con puntos por creatividad.**

---

## 15. Dirección de diseño (para Claude Design)

- **Concepto "mapa/viaje ascendente"** — original, NO Duolingo (nada de camino vertical de círculos planos).
- **Mascota guacamayo escarlata:** esbelto, rojo, colorido, de los que repiten — compañero de viaje que reacciona.
- **Paleta:** violeta eléctrico #6C5CE7 · coral #FF6B6B · **dorado #FFC93C (oro)** · verde #2ECC71 (acierto) · rojo #FF4D6D (vidas) · fondo claro #F5F6FB.
- **Tipografía:** redondeada (Nunito/Poppins), títulos extrabold.
- **Estilo:** ilustrado, con profundidad/relieve, animaciones jugosas. **Navegación solo íconos.**
- **Certificado:** formal y premium, contrasta con lo lúdico (transmite logro real).

---

## 16. Próximos pasos

1. ✅ **Prompts de Claude Design generados** para las 26 pantallas.
2. Iterar los diseños en Claude Design y consolidar el **sistema de diseño** a partir de lo entregado.
3. **Currículo / árbol** del primer nivel (es→en): unidades → lecciones → ejercicios.
4. **Modelo de datos** (usuario, progreso, ítems con etiqueta de habilidad, niveles por habilidad, resultados, certificados, racha, oro) para Claude Code.
5. **Banco de ítems** + lógica adaptativa.
6. Construir en **Claude Code**.
