# Jezici · Esquema de datos (Supabase / Postgres)

Migraciones del **paso A** del slice vertical (`Jezici_Plan_Construccion_ClaudeCode.md` §3.A).
Crean las **12 tablas core** del Modelo de Datos. Las demás (planes, exámenes,
vocabulario/SRS, ligas, Matix, social, suscripción) se añaden en pasos posteriores.

## Tablas creadas en este paso

| Dominio | Tablas |
|---|---|
| Cuenta | `users` (1:1 con `auth.users`) |
| Contenido (compartido) | `languages`, `courses`, `units`, `lessons`, `content_items`, `lesson_items` |
| Progreso | `user_course_progress`, `user_lesson_progress` |
| 4 habilidades | `user_skill_levels` |
| Gamificación | `user_stats`, `streaks` |

## Migraciones (orden)

1. `…_001_init_extensions_and_enums.sql` — `pgcrypto` + tipos enum (`cefr_level`, `skill`, `lesson_type`, `content_item_type`, `lesson_progress_status`).
2. `…_002_content_schema.sql` — contenido del curso (estático/compartido) + índice de selección de ítems.
3. `…_003_user_schema.sql` — perfil y datos por usuario.
4. `…_004_functions_and_triggers.sql` — `updated_at` automático + alta de usuario (`handle_new_user`).
5. `…_005_rls_policies.sql` — Row-Level Security.

## Aplicar

Requiere la [Supabase CLI](https://supabase.com/docs/guides/cli). Estas migraciones
asumen un proyecto Supabase (existe el schema `auth`).

```bash
# 1. Si aún no existe config local, generarlo (crea supabase/config.toml):
supabase init            # responder "no" a sobreescribir si ya hay carpeta

# 2a. Local (Docker): levantar la pila y aplicar migraciones
supabase start
supabase db reset        # aplica todas las migraciones desde cero + seed

# 2b. Contra un proyecto remoto:
supabase link --project-ref <tu-ref>
supabase db push
```

> Si prefieres aplicarlas a mano, ejecuta los 5 `.sql` en orden con `psql`
> sobre un Postgres que tenga el schema `auth` de Supabase.

## Decisiones de diseño (resumen)

- **`order` → `order_index`**: `order` es palabra reservada; se renombra (mismo significado) en `units`, `lessons`, `lesson_items`.
- **Enums nativos** para dominios estables (CEFR, skills) → tipado fuerte y codegen limpio en Flutter. Ampliables con `ALTER TYPE … ADD VALUE`.
- **Auth de Supabase**: `users.id` referencia `auth.users(id)`; el perfil se crea solo vía trigger `handle_new_user` (siembra también `user_stats` con 5 vidas y `streaks`).
- **RLS**: contenido = lectura pública; datos de usuario = cada quien lee lo suyo. Las **escrituras de progreso/economía** se harán por RPC `SECURITY DEFINER` en los pasos D–G (el cliente nunca decide scoring ni economía — Arquitectura §4/§7).
- **`jsonb`** en `content_items.payload` / `correct_answer` para soportar los 11 tipos de ejercicio sin esquemas rígidos.

## Siguiente paso

**B. Seed de contenido** — cargar la Unidad 1 del Currículo A1 (`Jezici_Curriculo_A1_es-en.md`)
en `units` / `lessons` / `content_items` / `lesson_items`.
