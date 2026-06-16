# Jezici — Motor de Notificaciones (Matix) (v1.0)

> El motor de seguimiento que mantiene al usuario en el plan. Notificaciones y correos **personalizados por el test de personalidad**, con escalado controlado y respeto al usuario. Reutiliza la lógica de tu proyecto Matix. Se apoya en `user_personality`, `notification_templates` y `notifications` del Modelo de Datos.

---

## 1. Objetivo

Traer al usuario de vuelta y mantenerlo en ritmo hacia su meta, con un **tono adaptado a su personalidad**, sin volverse tóxico ni molesto.

---

## 2. Estilos de coach (del test de personalidad)

| Estilo | Tono | Ejemplo (racha en riesgo) |
|---|---|---|
| **Mano dura** | Exigente, directo | "Faltaste hoy. Eso no va. Vuelve ya." |
| **Motivación positiva** | Energético, celebratorio | "¡12 días imparable! No rompas la magia hoy 💪" |
| **Recordatorio de rezago** | Comparativo, urgente | "Vas 2 días atrás. 3 de tu liga te pasaron." |
| **Suave** | Amable, sin presión | "Cuando puedas, una lección rápida te mantiene en ritmo 🙂" |

**Principio no negociable:** la presión es sobre la **conducta y la meta** ("no entrenaste, retoma"), **nunca** sobre el valor de la persona. El insulto al usuario causa desinstalaciones; una racha rota debe **invitar a volver, no avergonzar**.

---

## 3. Disparadores (triggers)

- **Racha en riesgo** (no cumplió hoy, racha activa).
- **Meta diaria sin cumplir** (tarde en el día).
- **Atraso vs plan** (va más lento que el ritmo necesario).
- **Cuenta regresiva a examen** (checkpoint/examen en X días).
- **Win-back** (inactivo X días).
- **Logro desbloqueado** (positivo).
- **Liga** (subiste/bajaste, o alguien te pasó).

---

## 4. Escalera de escalado (con techo)

Para un mismo objetivo (ej. racha), escalar **sin pasarse**:

1. **Recordatorio suave** ("una lección rápida hoy").
2. **Recordatorio con dato** ("tu racha de 12 días está en riesgo").
3. **Empujón fuerte** (según estilo; en mano dura, directo).
4. **Pausa** — no insistir más ese día.

> El estilo solo cambia el **tono** de cada escalón, no rompe el techo.

---

## 5. Reglas

- **Horarios:** respetar ventana del usuario; **nunca de madrugada**. `quiet_hours` configurable.
- **Tope diario** de notificaciones por usuario.
- El usuario **recalibra la intensidad** en Ajustes (incluido "menos notificaciones").
- **Sincronizar canales:** no repetir lo mismo por push y correo al mismo tiempo.
- Toda comunicación empuja hacia **su** meta y refuerza las **barras de progreso** (eje visual).

---

## 6. Canales

- **Push:** FCM (Android/Web) + APNs (iOS) — recordatorios cortos.
- **Correo:** resúmenes y mensajes más largos (progreso semanal, "te falta poco para certificar").

---

## 7. Plantillas (estructura)

Cada plantilla = (`coach_style` × `trigger` × `escalation_step` × `channel`) → `copy`. Ejemplos por estilo para **win-back**:

- Mano dura: "Llevas 5 días fuera. Tu inglés no se aprende solo. Vuelve hoy."
- Positiva: "¡Te extrañamos! Retomas justo donde lo dejaste 💜"
- Rezago: "5 días fuera = tu meta de B2 se aleja. Recupérala hoy."
- Suave: "Cuando quieras, aquí seguimos. Una lección corta y listo 🙂"

Ejemplos para **cuenta regresiva a examen**:
- Mano dura: "Examen en 2 días. Sin excusas: repasa hoy."
- Positiva: "¡Examen en 2 días! Vas a brillar — un repaso y listo 💪"
- Rezago: "Examen en 2 días y vas flojo en listening. No lo dejes."
- Suave: "Tu examen es en 2 días; un repaso tranquilo te deja listo."

---

## 8. Conexión al modelo de datos

- `user_personality`: estilo + intensidad + `quiet_hours`.
- `notification_templates`: el banco de copys por estilo/trigger/escalón/canal.
- `notifications`: cola/registro (programada, enviada, suprimida por horario o techo).
- Un **scheduler** evalúa triggers, elige plantilla, respeta horarios y tope, y envía.

---

## 9. Bienestar (no negociable)

- Nunca atacar a la persona; presión solo sobre la acción.
- Permitir bajar intensidad fácilmente.
- No notificar en horas de descanso.
- El modo "mano dura" es **exigente, no cruel**.

---

## 10. Gancho IA (Fase 2)

- Copys **hiperpersonalizados**: la IA redacta el mensaje óptimo según personalidad + contexto (atraso, hora, última actividad) — manteniendo las mismas reglas y techo.
