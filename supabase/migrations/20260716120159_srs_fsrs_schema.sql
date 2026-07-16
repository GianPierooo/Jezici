-- SRS F1 · ESQUEMA + MOTOR FSRS (aditivo: NO toca ningún RPC vivo).
-- Fuente de verdad: PRACTICAR_SRS_ANALISIS.md §3 (FSRS con parámetros por defecto,
-- server-side, SIN optimizador: hoy hay 0 usuarios = 0 historial que optimizar).
--
-- Se AMPLÍA user_vocab_srs (no se recrea). `ease` y `strength` quedan VESTIGIALES:
-- esta migración deja de necesitarlas, pero NO se borran (se borrarán en una
-- migración posterior, cuando nada las lea).

-- ── 1. user_vocab_srs += estado FSRS ────────────────────────────────────────
alter table public.user_vocab_srs
  add column if not exists stability      numeric,          -- S (días)
  add column if not exists difficulty     numeric,          -- D (1..10)
  add column if not exists state          text not null default 'new',
  add column if not exists reps           int  not null default 0,
  add column if not exists lapses         int  not null default 0,
  add column if not exists last_rating    int,              -- 1..4
  add column if not exists scheduled_days int  not null default 0;

do $$ begin
  alter table public.user_vocab_srs
    add constraint user_vocab_srs_state_ck
    check (state in ('new','learning','review','relearning'));
exception when duplicate_object then null; end $$;

-- La cola pide "vencidas del usuario" constantemente.
create index if not exists user_vocab_srs_due_idx
  on public.user_vocab_srs (user_id, due_at);

-- ── 2. srs_review_log (NUEVA) ───────────────────────────────────────────────
-- Requisito de PRACTICAR_SRS_ANALISIS.md §3: sin esto NO hay métrica de retención
-- (§2.6 del spec) ni optimizador futuro. Es lo caro de retrofitear → se hace ahora
-- que hay 0 usuarios.
create table if not exists public.srs_review_log (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null references public.users(id) on delete cascade,
  vocab_id       uuid not null references public.vocabulary(id) on delete cascade,
  rating         int  not null check (rating between 1 and 4),
  state          text not null,          -- estado ANTES de la review
  elapsed_days   int  not null default 0,
  scheduled_days int  not null default 0,
  stability      numeric,                -- S DESPUÉS (para reconstruir la curva)
  difficulty     numeric,                -- D DESPUÉS
  reviewed_at    timestamptz not null default now()
);
create index if not exists srs_review_log_user_idx
  on public.srs_review_log (user_id, reviewed_at desc);

alter table public.srs_review_log enable row level security;

do $$ begin
  create policy srs_review_log_select_own on public.srs_review_log
    for select using (user_id = auth.uid());
exception when duplicate_object then null; end $$;

-- Escritura SOLO por RPC SECURITY DEFINER (regla de la casa: nada de using(true)
-- ni writes directos del cliente).
revoke insert, update, delete on public.srs_review_log from anon, authenticated;

-- ── 3. Parámetros en jz_config (key + value_int) ────────────────────────────
-- srs_new_per_day = 10: el análisis (§8.3) señala que 15/día sobre un léxico de
-- ~480 palabras agota el mazo en ~32 días. Con 10/día dura ~48 días y sigue siendo
-- un ritmo real. Es config, no código: se sube cuando crezca el léxico.
insert into public.jz_config(key, value_int) values
  ('srs_new_per_day', 10),
  ('srs_target_retention_pct', 90),
  ('srs_max_per_session', 20),
  ('srs_mature_days', 21)          -- "madura" = intervalo >= 21d (convención Anki)
on conflict (key) do nothing;

-- ── 4. MOTOR FSRS (v4.5, pesos por defecto) ─────────────────────────────────
-- Aritmética pura (exp/power): no necesita nada que Postgres no tenga.
-- Los 17 pesos NO caben en jz_config (value_int es entero) → viven aquí, en una
-- función versionada por migración. Si algún día se optimizan, se sustituye esta
-- función (o se añade una tabla de params por usuario). Decisión documentada en
-- PRACTICAR_SRS_ANALISIS.md §3.
create or replace function public.jz_fsrs_w()
returns numeric[]
language sql
immutable
as $function$
  -- FSRS-4.5 default parameters (los que Anki envía de fábrica).
  select array[
    0.4872,  -- w0  S0(Again)
    1.4003,  -- w1  S0(Hard)
    3.7145,  -- w2  S0(Good)
    13.8206, -- w3  S0(Easy)
    5.1618,  -- w4  D0 base
    1.2298,  -- w5  D0 pendiente
    0.8975,  -- w6  D delta por rating
    0.031,   -- w7  mean reversion
    1.6474,  -- w8  factor de S en éxito
    0.1367,  -- w9  exponente de S
    1.0461,  -- w10 factor de (1-R)
    2.1072,  -- w11 S tras lapso
    0.0793,  -- w12 exponente D en lapso
    0.3246,  -- w13 exponente S en lapso
    1.587,   -- w14 factor (1-R) en lapso
    0.2272,  -- w15 penalización Hard
    2.8755   -- w16 bonus Easy
  ]::numeric[];
$function$;

-- Recuperabilidad: R(t,S) = (1 + FACTOR·t/S)^DECAY  con DECAY=-0.5, FACTOR=19/81.
create or replace function public.jz_fsrs_r(p_elapsed_days numeric, p_stability numeric)
returns numeric
language sql
immutable
as $function$
  select case
    when p_stability is null or p_stability <= 0 then 1.0::numeric
    else power(1 + (19.0/81.0) * greatest(p_elapsed_days, 0) / p_stability, -0.5)
  end;
$function$;

-- Intervalo para la retención deseada: I = (S·81/19)·(R_d^(-2) - 1).
-- Con R_d=0.9 → I ≈ S (propiedad conocida de FSRS).
create or replace function public.jz_fsrs_interval(p_stability numeric, p_retention numeric)
returns int
language sql
immutable
as $function$
  select greatest(1, least(36500,
    round((p_stability * 81.0/19.0) * (power(p_retention, -2.0) - 1))
  ))::int;
$function$;

-- Dificultad inicial: D0(G) = w4 - (G-3)·w5, clamp [1,10]  (FSRS v4/4.5, lineal).
create or replace function public.jz_fsrs_d0(p_rating int)
returns numeric
language sql
immutable
as $function$
  select greatest(1, least(10,
    (jz_fsrs_w())[5] - (p_rating - 3) * (jz_fsrs_w())[6]
  ));
$function$;

-- Paso del scheduler. Devuelve el estado NUEVO de la tarjeta.
--   p_state: new|learning|review|relearning (ANTES)
--   p_rating: 1=Otra vez · 2=Difícil · 3=Bien · 4=Fácil
-- Nota: los arrays de plpgsql son 1-based → w[i+1] es el "wi" del paper.
create or replace function public.jz_fsrs_next(
  p_state text, p_stability numeric, p_difficulty numeric,
  p_elapsed_days numeric, p_rating int, p_retention numeric
) returns jsonb
language plpgsql
immutable
as $function$
declare
  w numeric[] := jz_fsrs_w();
  v_s numeric; v_d numeric; v_r numeric; v_state text; v_int int; v_lapse boolean := false;
begin
  if p_state = 'new' or p_stability is null then
    -- Primera exposición: S0(G) = w[G-1] (paper) → w[p_rating] (1-based).
    v_s := w[p_rating];
    v_d := jz_fsrs_d0(p_rating);
  else
    v_r := jz_fsrs_r(p_elapsed_days, p_stability);
    -- Dificultad: delta por rating + mean reversion hacia D0(Easy).
    v_d := p_difficulty - w[7] * (p_rating - 3);
    v_d := w[8] * jz_fsrs_d0(4) + (1 - w[8]) * v_d;
    v_d := greatest(1, least(10, v_d));

    if p_rating = 1 then
      -- Lapso: S'f = w11·D^(-w12)·((S+1)^w13 - 1)·e^(w14·(1-R)), acotado a S.
      v_s := w[12] * power(v_d, -w[13]) * (power(p_stability + 1, w[14]) - 1)
             * exp(w[15] * (1 - v_r));
      v_s := least(v_s, p_stability);
      v_lapse := true;
    else
      -- Éxito: S'r = S·(1 + e^w8·(11-D)·S^(-w9)·(e^(w10·(1-R))-1)·hard·easy)
      v_s := p_stability * (1 +
               exp(w[9]) * (11 - v_d) * power(p_stability, -w[10])
               * (exp(w[11] * (1 - v_r)) - 1)
               * (case when p_rating = 2 then w[16] else 1 end)   -- penalización Hard
               * (case when p_rating = 4 then w[17] else 1 end)); -- bonus Easy
    end if;
  end if;

  v_s := greatest(v_s, 0.01);

  -- Máquina de estados. Sin pasos sub-día: la unidad de agenda es el DÍA y las
  -- falladas reaparecen DENTRO de la sesión (due=now), como pide el spec §2.1.
  if p_rating = 1 then
    v_state := case when p_state in ('new','learning') then 'learning' else 'relearning' end;
    v_int := 0;                       -- vuelve en la misma sesión
  else
    v_state := 'review';
    v_int := jz_fsrs_interval(v_s, p_retention);
  end if;

  return jsonb_build_object(
    'stability', round(v_s, 4), 'difficulty', round(v_d, 4),
    'state', v_state, 'interval_days', v_int, 'lapse', v_lapse
  );
end $function$;

-- Helper: leer un entero de jz_config con default.
create or replace function public.jz_cfg(p_key text, p_default int)
returns int
language sql
stable
as $function$
  select coalesce((select value_int from jz_config where key = p_key), p_default);
$function$;

-- Los helpers internos no se exponen al cliente (regla de la casa).
revoke all on function public.jz_fsrs_w() from anon, authenticated;
revoke all on function public.jz_fsrs_r(numeric, numeric) from anon, authenticated;
revoke all on function public.jz_fsrs_interval(numeric, numeric) from anon, authenticated;
revoke all on function public.jz_fsrs_d0(int) from anon, authenticated;
revoke all on function public.jz_fsrs_next(text, numeric, numeric, numeric, int, numeric) from anon, authenticated;
revoke all on function public.jz_cfg(text, int) from anon, authenticated;
