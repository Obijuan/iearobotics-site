#!/usr/bin/env bash

# Verificar que se ha pasado un argumento
if [ -z "$1" ]; then
  echo "Uso: $0 <nombre_del_fichero>" >&2
  exit 1
fi

ARCHIVO="$1"

# Detectar si el comando está instalado como 'fd' o 'fdfind' (común en Debian/Ubuntu)
if command -v fd &> /dev/null; then
  CMD="fd"
elif command -v fdfind &> /dev/null; then
  CMD="fdfind"
else
  echo "Error: 'fd' no está instalado en el sistema." >&2
  exit 1
fi

# Buscar coincidencias exactas (-g para usar glob en lugar de regex) de tipo archivo (-t f)
RESULTADO=$("$CMD" -t f -g "$ARCHIVO")

# Comprobar si hubo resultados
if [ -z "$RESULTADO" ]; then
  echo "No se encontró el fichero: $ARCHIVO" >&2
  exit 1
fi

# Devolver el resultado
echo "$RESULTADO"
