-- ============================================================================
-- Jezici · Migración 028 · Web Push — suscripciones (paso PWA + Push)
-- ----------------------------------------------------------------------------
-- Guarda las suscripciones Web Push del usuario para que la Edge Function
-- send-push (con VAPID) le envíe los disparadores de Matix. El SW (sw.js) ya
-- maneja el evento 'push' mostrando la notificación con el copy.
-- ============================================================================

create table if not exists push_subscriptions (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references users(id) on delete cascade,
  endpoint   text not null unique,
  p256dh     text not null,
  auth       text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists push_subscriptions_user_idx on push_subscriptions (user_id);

alter table push_subscriptions enable row level security;
drop policy if exists "push_own" on push_subscriptions;
create policy "push_own" on push_subscriptions for all to authenticated
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Guarda/actualiza la suscripción del navegador del usuario.
create or replace function save_push_subscription(p_endpoint text, p_p256dh text, p_auth text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare uid uuid := auth.uid();
begin
  if uid is null then raise exception 'auth required'; end if;
  insert into push_subscriptions (user_id, endpoint, p256dh, auth)
  values (uid, p_endpoint, p_p256dh, p_auth)
  on conflict (endpoint) do update
    set user_id = uid, p256dh = excluded.p256dh, auth = excluded.auth, updated_at = now();
end $$;

grant execute on function save_push_subscription(text, text, text) to authenticated;
