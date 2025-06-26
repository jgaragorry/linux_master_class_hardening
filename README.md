# Scripts de Gestión de Máquina Virtual en Azure

Este repositorio contiene un conjunto de scripts de Bash para crear, verificar y eliminar una máquina virtual (VM) con Linux Ubuntu 24.04 LTS en Azure. Los scripts están diseñados siguiendo buenas prácticas de FinOps (uso de los recursos más económicos) y de gestión (centralización y etiquetado).

## Requisitos Previos

Antes de ejecutar estos scripts, asegúrate de tener lo siguiente:

1.  **WSL con Ubuntu 24.04 LTS:** Los scripts están diseñados para ejecutarse en este entorno.
2.  **Azure CLI:** Debes tener `az cli` instalado y configurado. Puedes instalarlo siguiendo la [documentación oficial de Microsoft](https://learn.microsoft.com/es-es/cli/azure/install-azure-cli-linux?pivots=apt).
3.  **Cuenta de Azure:** Necesitas una suscripción activa de Azure.
4.  **jq:** El script de verificación usa `jq` para procesar la salida JSON. Instálalo con:
    ```bash
    sudo apt-get update && sudo apt-get install -y jq
    ```

## Estructura del Repositorio

-   `create_vm.sh`: Script para crear todos los recursos (Grupo de Recursos, VM, Disco, Red, IP Pública).
-   `verify_vm.sh`: Script para verificar el estado de la VM y obtener su dirección IP pública.
-   `delete_resources.sh`: Script para eliminar **todos** los recursos creados, borrando el grupo de recursos completo.
-   `README.md`: Este archivo.
-   `.gitignore`: Archivo para ignorar ficheros locales de Git.

## Cómo Usar los Scripts

Sigue estos pasos en orden desde tu terminal de WSL:

### Paso 1: Clonar y Preparar

Primero, clona este repositorio y dale permisos de ejecución a los scripts.

```bash
git clone <URL_DE_TU_REPOSITORIO>
cd <nombre-del-repositorio>
chmod +x *.sh