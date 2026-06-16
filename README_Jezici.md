# Jezici — Índice del Proyecto (README / Manifiesto)

> Mapa maestro del proyecto. **Documentación completa.** Próximo paso: construir en Claude Code (ver `Plan_Construccion`). **Formato:** Markdown en la carpeta; mockups (PNG) en `mockups/`.

---

## Resumen del producto

Jezici es una app de idiomas (lanzamiento: inglés, español, portugués; prioridad **español→inglés**) que fusiona la estructura de Busuu, la gamificación de Duolingo y la conversación de Tandem en un solo loop. **Diferenciadores:** plan con fecha real, **certificación creíble por examen que exige las 4 habilidades equilibradas**, coaches con personalidad (Matix), seguimiento intenso, y un apartado social (**Conversar**). **Identidad:** mapa/viaje ascendente, mascota **guacamayo escarlata**, moneda **oro**. Fase 1: **100% programado, sin IA**.

---

## Estructura de la carpeta

```
jezici/
├── README_Jezici.md                        (este manifiesto)
├── Jezici_Especificacion.md                (v0.3)
├── Jezici_Estructura_App.md                (v1.1)
├── Jezici_Metodologia.md                   (v1.0)
├── Jezici_Modelo_Datos.md                  (v1.0)
├── Jezici_Curriculo_A1_es-en.md            (v0.1)
├── Jezici_Banco_Items_Examenes.md          (v0.1)
├── Jezici_Sistema_Diseno.md                (v1.0)
├── Jezici_Diseno_Gamificacion.md           (v1.0)
├── Jezici_Motor_Matix.md                   (v1.0)
├── Jezici_Test_Personalidad.md             (v0.1)
├── Jezici_Modelo_Negocio.md                (v1.0)
├── Jezici_Arquitectura_Tecnica.md          (v1.0)
├── Jezici_Eficacia.md                      (v1.0)
├── Jezici_Analisis_Competencia.md          (v1.0)
├── Jezici_Glosario.md                      (v1.0)
├── Jezici_Plan_Construccion_ClaudeCode.md  (v1.0)
└── mockups/                                (15 pantallas de Claude Design)
```

---

## Documentos (17) — todos ✅

| Documento | Qué contiene |
|---|---|
| **Especificacion** | Estrategia: visión, 3 capas, exámenes, dinámicas, arquitectura, monetización, fases, riesgos, métricas |
| **Estructura_App** | Navegación, 26 pantallas, onboarding + estimación, lección, mapa, 4 habilidades, exámenes, certificación, gamificación, diseño |
| **Metodologia** | Mejores prácticas como tareas: 100 palabras, escalera a conversación, las 4 habilidades |
| **Modelo_Datos** | Esquema Postgres: 12 dominios |
| **Curriculo_A1_es-en** | Primer tramo A1: misión 100 palabras + 3 unidades |
| **Banco_Items_Examenes** | Ítems, calibración, adaptatividad, scoring por habilidad, regla de 4 skills |
| **Sistema_Diseno** | Identidad, paleta, tipografía, componentes, tokens para Flutter |
| **Diseno_Gamificacion** | Valores y reglas: XP, oro, vidas, racha, ligas, co-op, apostar oro |
| **Motor_Matix** | Notificaciones: estilos, triggers, escalado, plantillas, reglas |
| **Test_Personalidad** | Las 7 preguntas del onboarding + scoring a estilos |
| **Modelo_Negocio** | Ingresos, gating, precios, certificación como producto, proyección |
| **Arquitectura_Tecnica** | Stack (Supabase/Flutter), servicios, APIs, carpetas, seguridad |
| **Eficacia** | 3 pilares + respaldo de investigación + cómo se mide |
| **Analisis_Competencia** | Duolingo, Busuu, Tandem: cómo son y qué tomar |
| **Glosario** | Niveles CEFR + términos del proyecto |
| **Plan_Construccion_ClaudeCode** | El primer slice vertical, stack, orden y cómo prompteárselo a Claude Code |

---

## Mockups (Claude Design) — 15 ✅

Aprender (mapa) · Perfil · Lección · Conversar · Onboarding/Tu plan · Ligas · Examen+Certificado · Practicar · Checkpoint · Simulacro · Paywall · Ajustes · Sin vidas · Cofre · Notificaciones (CoachTonos).

> **Secundarias opcionales** (a diseñar durante el build si hacen falta): splash, login, preview de lección, pantallas de los tests, sesión de práctica, logros, estados de nodo, menú de exámenes.

---

## Contenido (seed) ✅

- **Contenido_Unidad1** — ejercicios reales de la Unidad 1 (es→en) para sembrar en `content_items`.
- **Test_Ubicacion_Items** — banco inicial del test de ubicación (A1–B2).
- **Matix_Plantillas** — copys de notificación por estilo/trigger/escalón para `notification_templates`.

---

## Orden de lectura

README → Especificacion → Metodologia → Estructura_App → Modelo_Datos → Curriculo_A1 → Banco_Items → Sistema_Diseno → (resto) → **Plan_Construccion**.

---

## Próximo paso

**Construir el primer slice vertical en Claude Code** (ver `Plan_Construccion`): subir todos los `.md` + los mockups al proyecto, y arrancar por el esquema de datos en Supabase/Postgres. La documentación de fundamento está completa.
