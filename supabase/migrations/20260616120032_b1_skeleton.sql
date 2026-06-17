-- ============================================================================
-- Jezici · Migración 032 · Esqueleto del currículo B1 (unidades + objetivos)
-- ----------------------------------------------------------------------------
-- Prepara las 6 regiones de B1 (order_index 13..18) con su objetivo y alcance
-- gramatical, SIN lecciones ni ítems todavía (se desarrollan después con el
-- mismo generador que A1/A2). Añade units.description para guardar el objetivo
-- (lo usará también el Panel de Admin / Content Ops). Como no tienen
-- checkpoints, NO entran en el examen de nivel ni rompen el gating: el mapa
-- (data-driven) sólo dibuja unidades con lecciones, así que B1 queda como
-- "próximamente" hasta que se siembre su contenido.
-- ============================================================================
begin;

-- Columna de objetivo/descr. de unidad (nullable, aditiva → no rompe nada).
alter table units add column if not exists description text;

-- Objetivos de las unidades A2 (para el panel de admin / mapa), idempotente.
update units set description = 'Hablar del pasado: was/were, pasado simple regular e irregular, y preguntas/negativos con did.' where order_index = 7  and description is null;
update units set description = 'Planes y futuro: going to, will, invitaciones (Let''s / Why don''t we) y expresiones de tiempo.' where order_index = 8  and description is null;
update units set description = 'Inglés de viaje: transporte, direcciones, hotel/aeropuerto y pedidos educados con can/could.' where order_index = 9  and description is null;
update units set description = 'Inglés transaccional: pedir en restaurantes, cantidades (some/any, much/many), compras y comparativos.' where order_index = 10 and description is null;
update units set description = 'Describir personas y lugares: apariencia, personalidad, presente continuo y superlativos.' where order_index = 11 and description is null;
update units set description = 'Salud y experiencias: el cuerpo, consejos con should, present perfect (ever/never) y narrar con ago/already.' where order_index = 12 and description is null;

-- ── B1 (Unidades 13–18) · sólo unidad + objetivo (esqueleto) ─────────────────
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon, description) values
 ('30000000-0000-0000-0000-000000000013','20000000-0000-0000-0000-000000000001','B1',13,$p$Rutinas, hábitos y experiencias$p$,'#2D98DA','event_repeat',
  $p$Objetivo: contar experiencias y hablar de lo que has hecho con naturalidad. Gramática: present perfect (for/since, just/already/yet), pasado simple vs present perfect, used to. Can-do: "He vivido aquí desde 2020", "¿Alguna vez has…?".$p$),
 ('30000000-0000-0000-0000-000000000014','20000000-0000-0000-0000-000000000001','B1',14,$p$Trabajo, estudios y planes$p$,'#3867D6','work',
  $p$Objetivo: hablar de tu trabajo/estudios y planes con condiciones. Gramática: primer condicional (if + presente, will), present perfect continuous (intro), be going to vs will. Can-do: "Si estudio, aprobaré", "Llevo dos años estudiando inglés".$p$),
 ('30000000-0000-0000-0000-000000000015','20000000-0000-0000-0000-000000000001','B1',15,$p$Opiniones y acuerdos$p$,'#8854D0','forum',
  $p$Objetivo: dar opiniones, acordar y discrepar con cortesía. Gramática: so/neither do I, estilo indirecto (intro: He said that…), verbos de opinión (think/believe/agree). Can-do: "Estoy de acuerdo", "Yo tampoco".$p$),
 ('30000000-0000-0000-0000-000000000016','20000000-0000-0000-0000-000000000001','B1',16,$p$Historias y viajes$p$,'#0FB9B1','explore',
  $p$Objetivo: narrar historias y viajes en el pasado con detalle. Gramática: pasado continuo vs pasado simple (while/when), cláusulas relativas (who/which/that). Can-do: "Mientras viajaba, conocí a…", "La ciudad que visité…".$p$),
 ('30000000-0000-0000-0000-000000000017','20000000-0000-0000-0000-000000000001','B1',17,$p$Problemas y soluciones$p$,'#FA8231','build',
  $p$Objetivo: describir problemas y proponer soluciones/obligaciones. Gramática: condicional cero y primero, modales de obligación (must/have to/should/can''t). Can-do: "Tienes que…", "Si no funciona, deberías…".$p$),
 ('30000000-0000-0000-0000-000000000018','20000000-0000-0000-0000-000000000001','B1',18,$p$Cultura, medios y futuro$p$,'#EB3B5A','public',
  $p$Objetivo: hablar de cultura/medios y sueños a futuro. Gramática: voz pasiva (intro: is made / was built), segundo condicional (intro: If I had…, I would…), comparativos avanzados (as…as, not as…as). Can-do: "Si pudiera, viajaría…", "Fue construido en…".$p$)
on conflict (course_id, order_index) do nothing;

commit;
