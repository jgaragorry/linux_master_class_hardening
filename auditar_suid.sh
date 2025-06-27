#!/bin/bash
# Script para auditar y encontrar todos los archivos con el bit SUID activado.

echo "Iniciando auditoría de permisos SUID en todo el sistema..."
echo "--------------------------------------------------------"
find / -type f -perm -4000 -ls 2>/dev/null
echo "--------------------------------------------------------"
echo "Auditoría completada."
echo "Analiza la lista en busca de anomalías. Un SUID en '/usr/bin/find' es una bandera roja."