# Jezici · Pruebas y CI

## CI (GitHub Actions)
`.github/workflows/ci.yml` corre en cada push/PR a `main`:
`flutter pub get` → `flutter analyze` → `flutter test` → `flutter build web`.
El build crea un `.env` vacío (asset declarado, gitignored) y usa el fallback
público de Supabase, así que no necesita secretos para compilar.

## Suite de tests (Dart, en CI)
- `grader_test` — calificación determinista de todos los tipos (incl. listening).
- `estimation_test` — motor del plan (horas/semanas/fecha, palanca).
- `streak_meta_test`, `lesson_complete_celebration_test` — modelos y celebración.
- `lesson_flow_test` — el loop completo de una lección de inicio a fin.

## RPC críticas (verificación de integración)
Las RPC server-side (complete_lesson, submit_checkpoint, examen de nivel +
emisión de certificado, practica, ligas, logros, tienda, métricas) se verifican
contra la BD real vía la Management API / REST, simulando un usuario autenticado:
`set local role authenticated; set local "request.jwt.claims" = '{"sub":"<uid>"}'; select <rpc>(...)`.
La cadena de gating (U1→U6) y el examen→certificado se probaron así de punta a
punta. Para correrlas en CI se necesitarían como *secrets* del repo:
`SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY` (o un proyecto de prueba) — pendiente
de que los configures en GitHub → Settings → Secrets.
