#!/usr/bin/env bash
# ============================================================================
# Jezici · Build de producción para Vercel (movido del buildCommand)
# ----------------------------------------------------------------------------
# POR QUÉ EXISTE: el "Build Command" de Vercel tiene un límite DURO de 256
# caracteres. El comando histórico (clone flutter + build web con los
# --dart-define de SUPABASE) ya estaba al tope → NO cabía añadir
# --dart-define=SENTRY_DSN. Solución: mover TODO el build a este script y dejar
# el Build Command del dashboard en `bash build.sh` (13 chars) → caben todos los
# --dart-define sin límite.
#
# COMPORTAMIENTO: IDÉNTICO al buildCommand histórico + SENTRY_DSN. Los valores
# vienen de variables de entorno que Vercel ya inyecta ($SUPABASE_URL,
# $SUPABASE_ANON_KEY) y de la nueva $SENTRY_DSN (que Gian crea en Vercel).
#
# SENTRY_DSN OPCIONAL: si $SENTRY_DSN está vacío/no seteado, el flag queda
# `--dart-define=SENTRY_DSN=` (cadena vacía) → el código lo lee como '' →
# Sentry NO-OP (la app arranca igual) y el BUILD NO FALLA. Respeta el diseño
# actual (String.fromEnvironment('SENTRY_DSN', defaultValue: '')).
#
# EJECUCIÓN: desde la RAÍZ del repo (igual que el buildCommand histórico), por
# eso el clone deja flutter/ junto a app/ y se llama ../flutter/bin/flutter.
#   Build Command (dashboard Vercel):  bash build.sh
#   Output Directory (sin cambios):    app/build/web
# ============================================================================
set -euo pipefail

# 1) Flutter stable junto a app/ (misma estructura que el clone histórico).
git clone https://github.com/flutter/flutter.git -b stable --depth 1

# 2) Build web con las MISMAS flags de siempre + los tres --dart-define.
#    ${VAR:-} = vacío si la var no está seteada (no rompe con `set -u`); mismo
#    resultado que el buildCommand histórico (que expandía $VAR sin default).
cd app
touch .env
if [ -n "${SENTRY_DSN:-}" ]; then
  echo "[build] SENTRY_DSN presente → Sentry se activará en el bundle"
else
  echo "[build] SENTRY_DSN vacío/no seteado → Sentry NO-OP (build OK igual)"
fi
../flutter/bin/flutter build web --release --pwa-strategy=none \
  --dart-define=SUPABASE_URL="${SUPABASE_URL:-}" \
  --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:-}" \
  --dart-define=SENTRY_DSN="${SENTRY_DSN:-}"
