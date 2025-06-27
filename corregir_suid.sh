#!/bin/bash
# Script para remover el permiso SUID de /usr/bin/find y verificar la corrección.

FIND_PATH="/usr/bin/find"

echo "--- Iniciando proceso de corrección para $FIND_PATH ---"

echo "Permisos ACTUALES (vulnerables):"
ls -l $FIND_PATH

echo ""
echo "Removiendo el bit SUID..."
sudo chmod -s $FIND_PATH

echo ""
echo "Permisos RESTAURADOS (seguros):"
ls -l $FIND_PATH

echo ""
PERMS=$(stat -c "%A" $FIND_PATH)
if [[ $PERMS == *s* ]]; then
    echo "ERROR: La vulnerabilidad no se ha corregido."
else
    echo "¡ÉXITO! La vulnerabilidad SUID ha sido eliminada. Los permisos son seguros."
fi