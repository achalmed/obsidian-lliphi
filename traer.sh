#!/usr/bin/env bash
# traer.sh — trae el theme.css que genera Lliphi (complementos/obsidian) y lo pone en este repo
#
# Uso: traer.sh [origen] [--aplicar]
#   origen      una copia de Lliphi (usa <origen>/generado/obsidian/theme.css), un theme.css o una URL;
#               por omisión, el de la rama main de github.com/achalmed/lliphi
#   sin --aplicar  simula: dice si cambiaría y cuántas líneas
#   --aplicar      reemplaza theme.css
# Salida: 0 bien · 1 uso, origen ilegible o archivo que no es el tema generado.
# Este repo no construye nada: el tema se edita en Lliphi (tokens/ y complementos/obsidian/) y aquí solo se trae.
set -euo pipefail

AQUI="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
URL="https://raw.githubusercontent.com/achalmed/lliphi/main/generado/obsidian/theme.css"
ORIGEN=""
APLICAR=0
for a in "$@"; do
  case "$a" in
    --aplicar) APLICAR=1 ;;
    -*) echo "uso: traer.sh [origen] [--aplicar]" >&2; exit 1 ;;
    *) ORIGEN="$a" ;;
  esac
done
ORIGEN="${ORIGEN:-$URL}"

NUEVO="$(mktemp)"
trap 'rm -f "$NUEVO"' EXIT
case "$ORIGEN" in
  http://*|https://*) curl -fsSL "$ORIGEN" -o "$NUEVO" || { echo "traer.sh: no se pudo descargar $ORIGEN" >&2; exit 1; } ;;
  *)
    [ -d "$ORIGEN" ] && ORIGEN="$ORIGEN/generado/obsidian/theme.css"
    [ -f "$ORIGEN" ] || { echo "traer.sh: no existe $ORIGEN" >&2; exit 1; }
    cp "$ORIGEN" "$NUEVO" ;;
esac
grep -q "GENERADO por herramientas/generar.py (complementos/obsidian" "$NUEVO" \
  || { echo "traer.sh: $ORIGEN no es el theme.css que genera Lliphi" >&2; exit 1; }

if cmp -s "$NUEVO" "$AQUI/theme.css"; then
  echo "  = theme.css al día ($(head -1 "$NUEVO" | sed 's#^/\* ##; s#:.*##'))"
  exit 0
fi
CAMBIOS="$(diff "$AQUI/theme.css" "$NUEVO" | grep -c '^[<>]' || true)"
if [ "$APLICAR" = 1 ]; then
  cp "$NUEVO" "$AQUI/theme.css"
  echo "  ✓ theme.css reemplazado ($CAMBIOS líneas): revisa con git diff y sube la versión en manifest.json"
else
  echo "  · theme.css cambiaría ($CAMBIOS líneas) desde $ORIGEN (--aplicar lo reemplaza)"
fi
