<div align="center">
  <img src="https://placehold.co/600x200/1e293b/ffffff?text=Laboratorio+de+Hardening+SUID" alt="Banner del Laboratorio de Hardening SUID">
</div>

<h1 align="center">Laboratorio de Hardening: Explotación y Corrección de Vulnerabilidad SUID</h1>

Este repositorio contiene una guía práctica y un conjunto de scripts para demostrar una de las vulnerabilidades de escalada de privilegios más clásicas y críticas en sistemas Linux: el **abuso de permisos SUID**.

A través de un laboratorio práctico en **Azure**, seguirás el ciclo completo de un incidente de seguridad, desde el despliegue de una infraestructura vulnerable hasta su detección, explotación, corrección y limpieza.

---

## 📋 Tabla de Contenido

- [🎯 **Objetivo del Laboratorio**](#-objetivo-del-laboratorio)
- [🛠️ **Requisitos Previos**](#-requisitos-previos)
- [📂 **Contenido del Repositorio**](#-contenido-del-repositorio)
- [🚀 **Guía de Ejecución Paso a Paso**](#-guía-de-ejecución-paso-a-paso)
  - [Fase 1: Despliegue del Entorno](#fase-1-despliegue-del-entorno-de-laboratorio)
  - [Fase 2: Creación de la Vulnerabilidad](#fase-2-simulación-del-error-administrativo)
  - [Fase 3: Explotación y Escalada de Privilegios](#fase-3-explotación-de-la-vulnerabilidad)
  - [Fase 4: Detección y Corrección](#fase-4-detección-y-corrección)
  - [Fase 5: Verificación Final](#fase-5-verificación-final)
  - [Fase Final: Limpieza de Recursos](#fase-final-limpieza-del-entorno)
- [📜 **Código Completo de los Scripts**](#-código-completo-de-los-scripts)

---

## 🎯 Objetivo del Laboratorio

Este laboratorio está diseñado para que los profesionales de TI y ciberseguridad puedan:

- **Comprender** el riesgo real que representa un permiso SUID mal configurado.
- **Aprender** a identificar binarios con SUID en un sistema de archivos.
- **Ejecutar** una escalada de privilegios en un entorno controlado.
- **Aplicar** las medidas correctivas para neutralizar esta vulnerabilidad.

---

## 🛠️ Requisitos Previos

Antes de comenzar, asegúrate de tener lo siguiente en tu máquina local (ej. WSL):

| Herramienta | Comando de Verificación / Instalación | Propósito |
| :--- | :--- | :--- |
| **Azure CLI** | `az version` | Para interactuar con tu suscripción de Azure. |
| **Cliente SSH** | `ssh -V` | Para conectarse a la máquina virtual. |
| **`jq`** | `sudo apt install jq` | Para procesar la salida JSON de Azure CLI. |

> **Nota Importante:** Debes haber iniciado sesión en Azure CLI antes de ejecutar los scripts. Usa el comando `az login`.

---

## 📂 Contenido del Repositorio

| Script | Descripción |
| :--- | :--- |
| 📜 `create_vm.sh` | Despliega la VM Ubuntu 24.04 vulnerable en Azure. |
| 🔍 `verify_vm.sh` | Verifica el estado y obtiene los detalles de la VM. |
| ☢️ `crear_vulnerabilidad_suid.sh` | **(Se ejecuta en la VM)** Aplica el permiso SUID a `/usr/bin/find`. |
| 🛡️ `auditar_suid.sh` | **(Se ejecuta en la VM)** Escanea el sistema en busca de archivos SUID. |
| ✅ `corregir_suid.sh` | **(Se ejecuta en la VM)** Remueve el permiso SUID y verifica. |
| 🧹 `delete_resources.sh` | Elimina todos los recursos de Azure para evitar costos. |

---

## 🚀 Guía de Ejecución Paso a Paso

### **Fase 1: Despliegue del Entorno de Laboratorio**

**Ubicación:** Tu terminal local (WSL `gmt@MSI`).

1.  **Crear la VM:** Ejecuta el script para desplegar el servidor Ubuntu en Azure.
    ```bash
    ./create_vm.sh
    ```
2.  **Verificar y Obtener IP:** Una vez que termine, ejecuta el script de verificación para obtener la dirección IP pública. **Anota esta IP**, la necesitarás para todo lo demás.
    ```bash
    ./verify_vm.sh
    ```

### **Fase 2: Simulación del Error Administrativo**

**Ubicación:** DENTRO de la VM de Azure.

1.  **Conéctate a la VM:** Usa la IP del paso anterior para conectarte.
    ```bash
    ssh gmt@<TU_IP_PÚBLICA>
    ```
    *Usa la contraseña `Password1234!`.*

2.  **Sube el script de vulnerabilidad:** Abre una **segunda terminal local** (WSL `gmt@MSI`) y usa `scp` para enviar el script a la VM.
    ```bash
    scp ./crear_vulnerabilidad_suid.sh gmt@<TU_IP_PÚBLICA>:~/
    ```
3.  **Crea la vulnerabilidad:** Vuelve a la terminal donde estás conectado a la VM y ejecuta el script que acabas de subir.
    ```bash
    # Dentro de la VM (gmt@vm-gmt-ubuntu)
    chmod +x crear_vulnerabilidad_suid.sh
    ./crear_vulnerabilidad_suid.sh
    ```
    *Este script te pedirá la contraseña de `sudo` (`Password1234!`). Ahora el sistema es vulnerable.*

### **Fase 3: Explotación de la Vulnerabilidad**

**Ubicación:** DENTRO de la VM de Azure.

1.  **Conviértete en el atacante:** Simula ser un usuario de bajos privilegios.
    ```bash
    # Dentro de la VM (gmt@vm-gmt-ubuntu)
    sudo adduser atacante # Crea el usuario si no existe
    su - atacante
    ```
2.  **Ejecuta el exploit:** Este es el comando que escala privilegios.
    ```bash
    # Ahora como 'atacante@vm-gmt-ubuntu'
    find . -exec /bin/sh -p \; -quit
    ```
3.  **Verifica el resultado:** Tu prompt cambiará de `$` a `#`. Confirma tu nueva identidad.
    ```bash
    whoami
    ```
    > **Resultado Esperado:** `root`. ¡Has tomado el control!
4.  Sal de la shell de root para continuar: `exit`.

### **Fase 4: Detección y Corrección**

**Ubicación:** DENTRO de la VM de Azure (como usuario `gmt`).

1.  **Sube los scripts de auditoría y corrección:** Desde tu **terminal local**, envía los otros dos scripts a la VM.
    ```bash
    # En tu WSL local (gmt@MSI)
    scp ./auditar_suid.sh gmt@<TU_IP_PÚBLICA>:~/
    scp ./corregir_suid.sh gmt@<TU_IP_PÚBLICA>:~/
    ```
2.  **Audita el sistema:** Vuelve a la terminal de la VM (como `gmt`) y ejecuta el script de auditoría para encontrar la falla.
    ```bash
    # Dentro de la VM (gmt@vm-gmt-ubuntu)
    chmod +x auditar_suid.sh
    ./auditar_suid.sh
    ```
    > *Este script te mostrará que `/usr/bin/find` tiene el permiso SUID, confirmando la bandera roja.*

3.  **Corrige y verifica la solución:** Ejecuta el script de corrección.
    ```bash
    # Dentro de la VM (gmt@vm-gmt-ubuntu)
    chmod +x corregir_suid.sh
    ./corregir_suid.sh
    ```
    > *Este script eliminará el permiso vulnerable y te mostrará el antes y el después, confirmando el éxito de la operación.*

### **Fase 5: Verificación Final**

**Ubicación:** DENTRO de la VM de Azure.

1.  Vuelve a convertirte en el `atacante` e intenta el exploit de nuevo.
    ```bash
    su - atacante
    find . -exec /bin/sh -p \; -quit
    whoami
    ```
    > *Esta vez, el comando `whoami` debe devolver `atacante`. La vulnerabilidad ha sido cerrada.*

### **Fase Final: Limpieza del Entorno**

**Ubicación:** Tu terminal local (WSL `gmt@MSI`).

1.  Cuando hayas terminado el laboratorio, ejecuta este script para eliminar todos los recursos de Azure y evitar costos.
    ```bash
    ./delete_resources.sh
    ```

---

## 📜 Código Completo de los Scripts

### `create_vm.sh`
```bash
#!/bin/bash
RESOURCE_GROUP_NAME="rg-gmt-vm-lab"
VM_NAME="vm-gmt-ubuntu"
LOCATION="eastus"
ADMIN_USERNAME="gmt"
ADMIN_PASSWORD="Password1234!"
UBUNTU_IMAGE="Ubuntu2404"
TAG_ENVIRONMENT="Development"
TAG_PROJECT="LinuxLab"
TAG_OWNER="gmt"
echo "=================================================="
echo "Iniciando el despliegue de la VM en Azure..."
echo "=================================================="
if ! az account show > /dev/null 2>&1; then
    echo "ERROR: No has iniciado sesión en Azure CLI."
    echo "Por favor, ejecuta 'az login' e inténtalo de nuevo."
    exit 1
fi
echo "Paso 1: Creando el Grupo de Recursos '$RESOURCE_GROUP_NAME' en '$LOCATION'..."
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION --tags environment="$TAG_ENVIRONMENT" project="$TAG_PROJECT" owner="$TAG_OWNER"
if [ $? -ne 0 ]; then
    echo "ERROR: Falló la creación del Grupo de Recursos. Abortando."
    exit 1
fi
echo "Grupo de Recursos creado exitosamente."
echo ""
echo "Paso 2: Creando la Máquina Virtual '$VM_NAME'..."
az vm create \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $VM_NAME \
    --image $UBUNTU_IMAGE \
    --size "Standard_B1s" \
    --storage-sku "Standard_LRS" \
    --admin-username $ADMIN_USERNAME \
    --admin-password $ADMIN_PASSWORD \
    --location $LOCATION \
    --tags environment="$TAG_ENVIRONMENT" project="$TAG_PROJECT" owner="$TAG_OWNER" \
    --nsg-rule SSH
if [ $? -ne 0 ]; then
    echo "ERROR: Falló la creación de la Máquina Virtual. Abortando."
    exit 1
fi
echo ""
echo "=================================================="
echo "¡Despliegue completado exitosamente!"
echo "=================================================="
echo "Para verificar los detalles de la VM, ejecuta: ./verify_vm.sh"
verify_vm.sh#!/bin/bash
RESOURCE_GROUP_NAME="rg-gmt-vm-lab"
VM_NAME="vm-gmt-ubuntu"
echo "=================================================="
echo "Verificando los detalles de la VM '$VM_NAME'..."
echo "=================================================="
if ! az account show > /dev/null 2>&1; then
    echo "ERROR: No has iniciado sesión en Azure CLI."
    exit 1
fi
VM_DETAILS=$(az vm show --resource-group $RESOURCE_GROUP_NAME --name $VM_NAME --show-details --query "{name:name, powerState:powerState, publicIp:publicIps, provisioningState:provisioningState, location:location}" -o json)
if [ -z "$VM_DETAILS" ]; then
    echo "ERROR: No se pudo encontrar la VM '$VM_NAME'."
    exit 1
fi
PUBLIC_IP=$(echo $VM_DETAILS | jq -r .publicIp)
POWER_STATE=$(echo $VM_DETAILS | jq -r .powerState)
echo "Detalles de la VM:"
echo "--------------------------------------------------"
echo "  Nombre de la VM:      $VM_NAME"
echo "  Estado de Energía:    $POWER_STATE"
echo "  IP Pública:           $PUBLIC_IP"
echo "--------------------------------------------------"
echo ""
if [ -n "$PUBLIC_IP" ] && [ "$PUBLIC_IP" != "null" ]; then
    echo "Puedes conectarte a la VM usando el siguiente comando:"
    echo "ssh gmt@$PUBLIC_IP"
fi
echo "=================================================="
crear_vulnerabilidad_suid.sh#!/bin/bash
echo "Verificando la ubicación del comando 'find'..."
FIND_PATH=$(which find)
if [ -z "$FIND_PATH" ]; then
    echo "Error: No se encontró el comando 'find'. Abortando."
    exit 1
fi
echo "Aplicando permiso SUID..."
sudo chmod 4755 $FIND_PATH
echo "¡Vulnerabilidad creada!"
ls -l $FIND_PATH
auditar_suid.sh#!/bin/bash
echo "Iniciando auditoría de permisos SUID en todo el sistema..."
find / -type f -perm -4000 -ls 2>/dev/null
echo "Auditoría completada."
corregir_suid.sh#!/bin/bash
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
    echo "¡ÉXITO! La vulnerabilidad SUID ha sido eliminada."
fi
delete_resources.sh#!/bin/bash
RESOURCE_GROUP_NAME="rg-gmt-vm-lab"
echo "=================================================="
echo "¡ADVERTENCIA! Estás a punto de eliminar el grupo de recursos '$RESOURCE_GROUP_NAME'."
echo "=================================================="
read -p "¿Estás seguro de que quieres continuar? (escribe 'si' para confirmar): " CONFIRMATION
if [ "$CONFIRMATION" != "si" ]; then
    echo "Operación cancelada."
    exit 0
fi
echo ""
echo "Iniciando la eliminación del grupo de recursos..."
az group delete --name $RESOURCE_GROUP_NAME --yes
if [ $? -ne 0 ]; then
    echo "ERROR: Ocurrió un error durante la eliminación."
else
    echo ""
    echo "=================================================="
    echo "¡Grupo de recursos eliminado exitosamente!"
    echo "=================================================="
fi
