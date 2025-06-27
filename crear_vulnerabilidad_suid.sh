#!/bin/bash
# Script para crear una vulnerabilidad SUID en /usr/bin/find
# ADVERTENCIA: Ejecutar solo en un entorno de laboratorio controlado.

echo "Verificando la ubicación del comando 'find'..."
FIND_PATH=$(which find)

if [ -z "$FIND_PATH" ]; then
    echo "Error: No se encontró el comando 'find'. Abortando."
    exit 1
fi

echo "El comando 'find' se encuentra en: $FIND_PATH"
echo "Aplicando permiso SUID... (Se requerirá contraseña de sudo)"

# Asigna el bit SUID al comando 'find'
sudo chmod 4755 $FIND_PATH

echo ""
echo "¡Vulnerabilidad creada!"
echo "Verifica los permisos de 'find' con 'ls -l $FIND_PATH'."
echo "Deberías ver los permisos como '-rwsr-xr-x'."
echo ""
echo "El escenario está listo para la explotación."
