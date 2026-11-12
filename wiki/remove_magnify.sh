#!/usr/bin/env bash

# Directorio objetivo (por defecto el directorio actual, o el que se pase como argumento)
DIRECTORIO="${1:-.}"

if [ ! -d "$DIRECTORIO" ]; then
  echo "Error: '$DIRECTORIO' no es un directorio válido." >&2
  exit 1
fi

echo "Procesando archivos en: $DIRECTORIO"

# Recorrer únicamente los archivos del directorio (maxdepth 1 evita subcarpetas)
find "$DIRECTORIO" -maxdepth 1 -type f | while IFS= read -r archivo; do
  # Evitar que el script se modifique a sí mismo si está en el mismo directorio
  if [[ "$(basename "$archivo")" == "$(basename "$0")" ]]; then
    continue
  fi

  # Usar Perl en modo slurp (-0777) para buscar y eliminar bloques multilínea
  perl -i -0777 -pe 's|<div class="magnify">\s*<a href.*?</a></div>||gs' "$archivo"
  echo "Procesado: $archivo"
done

echo "Proceso completado."

