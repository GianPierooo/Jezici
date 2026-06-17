# Jezici · Simulacros de examen (premium)

## Hecho
- Pantalla **Simulacros** (entrada desde Practicar, con badge Premium) que
  presenta la oferta (IELTS Academic/General, Cambridge B1/B2), explica las 4
  secciones y el reporte de banda, y **gatea por premium**: tocar un simulacro
  abre el paywall (PremiumScreen).
- Estructura/diseño Fase 1 definido: Reading + Listening autocorregibles;
  Writing + Speaking con respuesta modelo + rúbrica de autoevaluación.

## Pendiente (motor + contenido del simulacro)
- Seed de los ítems de cada simulacro (Listening con audio, Reading con textos,
  prompts de Writing con respuesta modelo, prompts de Speaking con modelo).
- RPC `start_mock` / `submit_mock` (reusan jz_grade para Reading/Listening) +
  cálculo de **banda por sección** (mapa puntaje→banda) y banda global.
- UI de Writing (editor + "ver modelo" + rúbrica con checklist autoevaluable) y
  Speaking (grabar con Web Speech + modelo + rúbrica).
- Desbloqueo real al activar premium (hoy el flag premium es siempre falso; no
  hay pagos — ver Modelo_Negocio).

Decisión: no se incluye contenido IELTS/Cambridge "oficial" fabricado; los
simulacros se construirán con material propio con formato equivalente.
