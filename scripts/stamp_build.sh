#!/usr/bin/env bash
# ============================================================================
# Jezici · Sello de build deploy-safe (cierra el P0.5)
# ----------------------------------------------------------------------------
# Inyecta el SHA del commit desplegado en app/build/web/index.html como
#   <script>window.JZ_BUILD="<sha7>";</script>
# La app lo lee en RUNTIME (core/app_info.dart → app_info_stamp_web.dart) y lo
# muestra en el pie de Ajustes ("Jezici 1.0.0 · <sha7>").
#
# POR QUÉ ES DEPLOY-SAFE: el SHA se obtiene AQUÍ desde $VERCEL_GIT_COMMIT_SHA
# (variable de entorno disponible en el build de Vercel), DENTRO de este script.
# NUNCA se mete $VAR/$() del SHA en el `buildCommand` de vercel.json — eso causaba
# ERROR instantáneo pre-build (rompió el deploy varios días). El buildCommand solo
# llama a este script (cadena sin $ del SHA). index.html se sirve no-store (sw v4),
# así que el sello refleja el bundle realmente cargado.
#
# Uso (post-build, cwd = app/): bash ../scripts/stamp_build.sh
# Local/CI: si no hay $VERCEL_GIT_COMMIT_SHA, no inyecta nada → la app cae a 'dev'.
# ============================================================================
set -eu

SHA="${VERCEL_GIT_COMMIT_SHA:-}"
IDX="build/web/index.html"

if [ -z "$SHA" ]; then
  echo "[stamp] sin VERCEL_GIT_COMMIT_SHA (local/CI) → no inyecto sello (la app usa 'dev')"
  exit 0
fi
if [ ! -f "$IDX" ]; then
  echo "[stamp] $IDX no encontrado (cwd=$(pwd)) → omito"
  exit 0
fi

SHORT="${SHA:0:7}"
# Idempotente y seguro: borra SOLO una línea de sello previa (no la de <head>) e
# inserta el script en su PROPIA línea justo después de <head>.
sed -i '\#<script>window\.JZ_BUILD=#d' "$IDX"
sed -i "s#<head>#<head>\n  <script>window.JZ_BUILD=\"${SHORT}\";</script>#" "$IDX"
echo "[stamp] JZ_BUILD=${SHORT} inyectado en ${IDX}"
