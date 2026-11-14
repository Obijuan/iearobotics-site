#!/usr/bin/env bash

# Script a ejecutar (puedes cambiarlo por "./test.sh" o la ruta completa si hace falta)
SCRIPT_OBJETIVO="./get_local_images.sh"

# Directorio objetivo (por defecto el actual '.', o el primer argumento recibido)
DIRECTORIO="${1:-.}"

# Comprobar que el directorio existe
if [ ! -d "$DIRECTORIO" ]; then
  echo "Error: El directorio '$DIRECTORIO' no existe." >&2
  exit 1
fi

# Comprobar que el script objetivo existe y tiene permisos de ejecución
if [ ! -x "$SCRIPT_OBJETIVO" ]; then
  echo "Error: '$SCRIPT_OBJETIVO' no existe o no tiene permisos de ejecución (usa chmod +x)." >&2
  exit 1
fi

# Recorrer todos los archivos .html del directorio (sin entrar en subcarpetas)
find "$DIRECTORIO" -maxdepth 1 -type f -name "*.html" | sort | while IFS= read -r archivo; do
  echo "=== Procesando: $archivo ==="
  "$SCRIPT_OBJETIVO" "$archivo"
done