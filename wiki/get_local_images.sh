#!/usr/bin/env bash

# Verificar que se ha pasado el fichero como argumento
if [ -z "$1" ]; then
  echo "Uso: $0 <fichero.html>" >&2
  exit 1
fi

FICHERO_HTML="$1"

if [ ! -f "$FICHERO_HTML" ]; then
  echo "Error: El fichero '$FICHERO_HTML' no existe." >&2
  exit 1
fi

# Detectar comando fd o fdfind
if command -v fdfind &> /dev/null; then
  FD_CMD="fdfind"
elif command -v fd &> /dev/null; then
  FD_CMD="fd"
else
  echo "Error: 'fdfind' (o 'fd') no está instalado." >&2
  exit 1
fi

# Extraer todos los NOMBRE_FICH.EXT únicos que coincidan con el patrón
# 'https?' y '(?:www\.)?' permiten coincidencias con o sin 'www.' y con http o https
# Busca cualquier enlace a Archivo:NOMBRE dentro de una etiqueta <a ... class="image" ...>
ARCHIVOS=$(grep -oP '<a\b[^>]*\bhref="https?://(?:www\.)?iearobotics\.com/wiki/index\.php\?title=Archivo:\K[^"]+(?="[^>]*\bclass="image")' "$FICHERO_HTML" | sort -u)
if [ -z "$ARCHIVOS" ]; then
  echo "No se encontraron enlaces para sustituir en '$FICHERO_HTML'."
  echo "Archivos: '$ARCHIVOS'"
  exit 0
fi

# Iterar sobre cada nombre de fichero encontrado
while IFS= read -r nombre_fich; do
  # Buscar el fichero en subcarpetas (-t f: solo archivos, -g: coincidencia exacta, -1: detenerse en el primero)
  ruta_encontrada=$("$FD_CMD" -t f -g -1 "$nombre_fich")

  if [ -n "$ruta_encontrada" ]; then
    # Limpiar posible prefijo './' si lo hubiera
    ruta_encontrada="${ruta_encontrada#./}"

    # Exportar variables de entorno para que Perl las use de forma segura sin problemas de escape
    NOMBRE="$nombre_fich" RUTA="$ruta_encontrada" perl -i -pe '
      s|<a href="https://www\.iearobotics\.com/wiki/index\.php\?title=Archivo:\Q$ENV{NOMBRE}\E" class="image">|<a href="$ENV{RUTA}" class="image">|g
    ' "$FICHERO_HTML"

    echo "[OK] $nombre_fich -> $ruta_encontrada"
  else
    echo "[AVISO] No se encontró en subcarpetas: $nombre_fich" >&2
  fi
done <<< "$ARCHIVOS"

