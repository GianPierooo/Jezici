# Jezici — Arquitectura Técnica (v1.0)

> Decisiones técnicas y estructura para construir en Claude Code. Fase 1 **sin IA**, todo determinista. Complementa Modelo_Datos y Plan_Construccion.

---

## 1. Stack

- **App:** Flutter (iOS / Android / Web) — un solo código.
- **Backend + Datos:** **Supabase** (Postgres + Auth + APIs autogeneradas + Realtime + Edge Functions) como **vía rápida para 2 personas**. Es Postgres → calza con el Modelo de Datos; trae auth, APIs y realtime listos.
  - *Alternativa:* backend propio **FastAPI (Python)** o **Node** + Postgres, si se quiere más control de la lógica (ej. motor de exámenes complejo).
- **Sin IA** en Fase 1. Voz/STT y modelos solo cuando entren speaking real / conversación (Fase 2).
- **Analítica** desde el día uno.

---

## 2. Arquitectura de alto nivel

```
Flutter (app)  ⇄  Supabase / API  ⇄  Postgres
                        │
              Edge Functions (lógica): exam engine, scheduler Matix
```

- **Contenido del curso = estático y cacheado** (patrón Duolingo): se sirve y cachea; cambia poco.
- **Datos del usuario** (progreso, skills, oro) por request, con auth.

---

## 3. Módulos / servicios (lógicos)

- **Auth** (gestionado por Supabase Auth).
- **Contenido:** entrega de cursos/unidades/lecciones/ítems (cacheado).
- **Progreso:** lecciones, estados de nodo, XP, racha.
- **4 habilidades:** actualizar `user_skill_levels` según ítems resueltos.
- **Motor de exámenes:** selección de ítems (criterios + aleatorización/adaptatividad), cronómetro, scoring por habilidad, regla de certificación, emisión de certificado (PDF con folio).
- **Gamificación:** oro (ledger), vidas, ligas (job semanal), cofres, logros, apuestas.
- **Plan / estimación:** motor determinista de fecha estimada + recálculo.
- **Notificaciones (Matix):** scheduler que evalúa triggers, elige plantilla, respeta horarios/techo, envía push+correo.
- **Social / Conversar (Fase 2):** salas (realtime), emparejamiento, moderación.
- **Analítica:** eventos de retención y de economía.

---

## 4. APIs / acceso a datos

- Con **Supabase:** tablas + **RPC functions** (Postgres) para lógica (ej. `submit_exercise`, `grade_exam`, `open_chest`, `resolve_wager`), con **Row-Level Security** para que cada usuario solo vea lo suyo. Realtime para salas (Fase 2).
- Con **backend propio:** endpoints REST por módulo (auth, content, progress, exams, gamification, plan, notifications).

> Lógica sensible (scoring, economía, certificación) **en el servidor / Edge Functions**, nunca solo en el cliente.

---

## 5. Estructura de carpetas (Flutter, sugerida)

```
lib/
├── core/            (tema, constantes, utils, config de economía)
├── data/            (modelos, repositorios, cliente Supabase/API)
├── features/
│   ├── onboarding/  (pasos + Tu plan)
│   ├── learn/       (mapa, lección, ejercicios)
│   ├── practice/
│   ├── exams/       (checkpoint, examen de nivel, certificado)
│   ├── conversar/   (Fase 2)
│   ├── leagues/
│   ├── profile/     (panel 4 skills, plan, ajustes)
│   └── gamification/(xp, oro, vidas, racha, cofres)
├── ui/              (componentes: PrimaryButton, MapNode, SkillRadar, RewardSheet, MascotView)
└── main.dart
```

---

## 6. Caching y rendimiento

- Cachear contenido del curso (estático) en cliente; invalidar por versión.
- Lo del usuario, en vivo. Optimizar el loop de lección para que sea instantáneo (feedback inmediato).

---

## 7. Seguridad

- **RLS** en Postgres / validación en servidor; el cliente nunca decide scoring ni economía.
- Auth gestionado; sin secretos en el cliente.
- Moderación/verificación y reportes para Conversar (Fase 2).

---

## 8. Despliegue

- App: Play Store + App Store + Web (Flutter web).
- Backend: Supabase gestionado (o el backend propio en un host).
- Analítica/experimentos integrados (A/B testing).

---

## 9. Ganchos para Fase 2

- **Voz:** LiveKit/Agora (audio) + STT (Deepgram/Whisper/ElevenLabs) para speaking y salas.
- **IA:** evaluación de writing/speaking abierto, conversación con creatividad, copys Matix.
- Guardar grabaciones/textos libres desde Fase 1 para evaluarlos luego sin rehacer.
