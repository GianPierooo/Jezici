# Jezici — Plantillas de Notificación (Matix) v0.1

> Copys reales por **estilo × trigger × escalón × canal**, listos para sembrar en `notification_templates`. Estilos: Mano dura (MD) · Positivo (PO) · Rezago (RE) · Suave (SU). Respetan el techo y los horarios (ver `Motor_Matix`).

---

## Racha en riesgo (push) — con escalado

**Escalón 1 (suave recordatorio):**
- MD: "Tu racha está en juego. Una lección, ahora."
- PO: "¡No pierdas tu racha! Una lección rápida y sigues 🔥"
- RE: "Cuidado: tu racha de {dias} días está en riesgo."
- SU: "Cuando puedas, una lección corta mantiene tu racha 🙂"

**Escalón 2 (con dato):**
- MD: "{dias} días de racha. No los tires hoy. Entra ya."
- PO: "¡{dias} días imparable! No rompas la magia, vas genial 💪"
- RE: "Quedan horas para salvar tu racha de {dias} días."
- SU: "Tu racha de {dias} días sigue viva — una lección y listo."

**Escalón 3 (empujón final):**
- MD: "Última llamada. Pierdes tu racha si no entras ahora."
- PO: "¡Justo a tiempo! Salva tu racha y celébralo 🎉"
- RE: "Si no entras hoy, tu racha vuelve a cero."
- SU: "Si hoy no puedes, no pasa nada — mañana retomamos 🙂"

---

## Meta diaria sin cumplir (push)

- MD: "Te falta tu meta de hoy. Sin excusas."
- PO: "¡Casi! Te falta poquito para tu meta de hoy 💪"
- RE: "Vas {x}/{meta} XP. No te quedes corto hoy."
- SU: "Cuando tengas un rato, completa tu meta de hoy 🙂"

---

## Win-back (inactivo X días) (push)

**Escalón 1:** 
- MD: "{dias} días fuera. Tu inglés no avanza solo. Vuelve."
- PO: "¡Te extrañamos! Retomas justo donde lo dejaste 💜"
- RE: "{dias} días sin practicar = tu meta se aleja."
- SU: "Aquí seguimos cuando quieras. Una lección corta basta 🙂"

**Escalón 2 (más fuerte / oferta):**
- MD: "Llevas {dias} días. Decide hoy: ¿avanzas o lo dejas?"
- PO: "Vuelve hoy y recupera tu ritmo — ¡tú puedes! 🔥"
- RE: "Tu plan a {meta} se atrasó {dias} días. Recupéralo."
- SU: "Sin presión: una lección de 2 minutos y vuelves al ruedo 🙂"

---

## Cuenta regresiva a examen (push)

- MD: "Examen en {dias} días. Repasa hoy. Sin excusas."
- PO: "¡Examen en {dias} días! Un repaso y vas a brillar 💪"
- RE: "Examen en {dias} días y vas flojo en {skill}. No lo dejes."
- SU: "Tu examen es en {dias} días; un repaso tranquilo te deja listo."

---

## Atraso vs plan (push/correo)

- MD: "Vas atrás de tu plan. Sube el ritmo o no llegas."
- PO: "Un empujón y vuelves a tu ritmo hacia {meta} 💪"
- RE: "Vas {dias} días atrás de tu plan a {meta}."
- SU: "Si subes un poco el ritmo, llegas a tu meta a tiempo 🙂"

---

## Logro / liga (push) — siempre positivo

- Logro: "🏅 ¡Desbloqueaste {logro}! Sigue así."
- Subes de liga: "🏆 ¡Ascendiste a {liga}! A por la siguiente."
- Te pasaron en la liga: 
  - MD: "Te pasaron en la liga. ¿Lo vas a permitir?"
  - PO: "¡{n} te pasaron! Recupera tu lugar, tú puedes 💪"
  - RE: "{n} de tu liga te pasaron esta semana."
  - SU: "Alguien te pasó en la liga — cuando puedas, suma XP 🙂"

---

## Correo (ejemplo, resumen semanal)

Asunto por estilo:
- MD: "Tu semana: lo que hiciste y lo que falta"
- PO: "¡Mira tu progreso de la semana! 🎉"
- RE: "Tu avance vs tu meta esta semana"
- SU: "Un resumen tranquilo de tu semana 🙂"

Cuerpo (común, tono ajustado): saludo + barra de progreso de la semana + racha + avance al nivel meta + 1 llamado a la acción ("Sigue donde lo dejaste").

---

## Notas

- Variables: `{dias}`, `{meta}`, `{x}`, `{skill}`, `{liga}`, `{n}`, `{logro}`.
- Sembrar en `notification_templates` (coach_style, trigger, escalation_step, channel, copy).
- **Techo:** máx. 1 escalón por evento por día; pausa tras el escalón final. Respetar `quiet_hours`.
- (Fase 2) la IA puede reescribir estos copys hiperpersonalizados manteniendo reglas y techo.
