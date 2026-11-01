#!/usr/bin/env bash
# instalar.sh — copia el tema a .obsidian/themes/Lliphi de un vault
#
# Uso: instalar.sh <ruta-del-vault> [--aplicar]
#   sin --aplicar  simula: dice qué copiaría
#   --aplicar      copia theme.css y manifest.json
# Salida: 0 bien · 1 uso o entorno.
# No toca appearance.json: el tema se elige en Ajustes → Apariencia → Temas, y los otros temas instalados se quedan.
set -euo pipefail

AQUI="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
VAULT="${1:-}"
APLICAR=0
case "${2:-}" in
  --aplicar) APLICAR=1 ;;
  "") ;;
  *) echo "uso: instalar.sh <ruta-del-vault> [--aplicar]" >&2; exit 1 ;;
esac
[ -n "$VAULT" ] || { echo "uso: instalar.sh <ruta-del-vault> [--aplicar]" >&2; exit 1; }
[ -d "$VAULT/.obsidian" ] || { echo "instalar.sh: $VAULT no es un vault de Obsidian (falta .obsidian/)" >&2; exit 1; }

DESTINO="$VAULT/.obsidian/themes/Lliphi"
for f in theme.css manifest.json; do
  if cmp -s "$AQUI/$f" "$DESTINO/$f" 2>/dev/null; then
    echo "  = $f al día"
  elif [ "$APLICAR" = 1 ]; then
    mkdir -p "$DESTINO"
    cp "$AQUI/$f" "$DESTINO/$f"
    echo "  ✓ $f copiado"
  else
    echo "  · $f se copiaría a .obsidian/themes/Lliphi/ (--aplicar copia)"
  fi
done
