#!/usr/bin/env bash

if [ -z "$1" ]; then
  echo "Uso: $0 <fichero.html>" >&2
  exit 1
fi

FICHERO_HTML="$1"

if [ ! -f "$FICHERO_HTML" ]; then
  echo "Error: El fichero '$FICHERO_HTML' no existe." >&2
  exit 1
fi

if command -v fdfind &> /dev/null; then
  FD_CMD="fdfind"
elif command -v fd &> /dev/null; then
  FD_CMD="fd"
else
  echo "Error: 'fdfind' (o 'fd') no está instalado." >&2
  exit 1
fi

# Busca cualquier enlace a Archivo:NOMBRE dentro de una etiqueta <a ... class="image" ...>
ARCHIVOS=$(grep -oP '<a\b[^>]*\bhref="https?://(?:www\.)?iearobotics\.com/wiki/index\.php\?title=Archivo:\K[^"]+(?="[^>]*\bclass="image")' "$FICHERO_HTML" | sort -u)

if [ -z "$ARCHIVOS" ]; then
  echo "No se encontraron enlaces para sustituir en '$FICHERO_HTML'."
  exit 0
fi

while IFS= read -r nombre_fich; do
  ruta_encontrada=$("$FD_CMD" -t f -g -1 "$nombre_fich")

  if [ -n "$ruta_encontrada" ]; then
    ruta_encontrada="${ruta_encontrada#./}"

    # Captura en $1 toda la apertura hasta href=" y conserva intacto el resto de atributos (class, title, etc.)
    NOMBRE="$nombre_fich" RUTA="$ruta_encontrada" perl -i -pe '
      s|(<a\b[^>]*\bhref=")https?://(?:www\.)?iearobotics\.com/wiki/index\.php\?title=Archivo:\Q$ENV{NOMBRE}\E("[^>]*\bclass="image")|$1$ENV{RUTA}$2|g
    ' "$FICHERO_HTML"

    echo "[OK] $nombre_fich -> $ruta_encontrada"
  else
    echo "[AVISO] No se encontró en subcarpetas: $nombre_fich" >&2
  fi
done <<< "$ARCHIVOS"
