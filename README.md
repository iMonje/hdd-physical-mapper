><center>⚠️ <i><small>Disclaimer<br>Este script es mi bitácora personal de combate contra el caos de cables en el servidor Osiris. Si el código te sirve, genial; si hace que tu servidor cobre vida propia y pida pizza, recuerda que yo solo estaba intentando no sacar el disco equivocado en caso de fallo.😅</small></i></center>

### 📟 Hardware Utilizado
🛒 https://amzn.to/4tmSJwh

### ℹ️ Intro

La controladora PCIe SATA viene con unos LEDs que pueden identificar el disco, sin embargo, esto no me sirve de mucho, los LEDs están cerca del conector dificultando su visión y no puedes estar metiendo la cabeza dentro de la caja para ver cuál parpadea.

He preparado un pequeño script en Bash en el que identifico los puertos físicos de la tarjeta PCI y los mapeo con los cables conectados a los HDDs.

### 📋 Problema
En sistemas con muchos discos y controladoras PCIe SATA, los nombres de los dispositivos (`/dev/sdb`, `/dev/sdc`...) son dinámicos y pueden cambiar tras un reinicio o fallo.

Cuando un disco falla, identificar **físicamente** cuál de los cables SATA debes desconectar es tarea casi imposible.

### 💡 Posible Solución
Este script cruza la siguiente información:
1. **Mapeo de Cables:** Una traducción lógica que asigna cada puerto a una etiqueta física personalizada (ej: M1-P6). En mi caso, la controladora PCIe SATA tiene 16 puertos y tengo dos manojos de 8 cables
2. **Ruta Física (PCI/SATA Bus):** El ID del puerto que nunca cambia.
3. **Nombre dev** Nombre del dispositivo dinámico asignado por el sistema al HDD
4. **Serial Number:** El identificador único impreso en la pegatina del disco.
5. **Tamaño** Capacidad del HDD
6. **Estado SMART instantáneo:** Muestra si el disco está "PASSED" u "OK" en tiempo real.

### 🛠️ Instalación y Uso

1. **Requisitos:**
   Asegúrate de tener instalada la utilidad para leer el estado de salud de los discos:
   ```bash
   sudo apt update && sudo apt install smartmontools -y
2. **Clonar y configurar:**
    ```bash
    git clone https://github.com/iMonje/hdd-physical-mapper.git
    cd hdd-physical-mapper
    chmod +x hdd-map.sh
    Personalización: Edita la función **traducir_cable** dentro del script para que coincida con tu esquema de etiquetado físico.
3. **Ejecución:**
    ```bash
    sudo ./hdd-map.sh

    CABLE        ID FÍSICO           DISCO      SERIAL NUMBER      TAMAÑO    SMART
    ------------------------------------------------------------------------------------------------------
    PLACA-SATA2  00:1f.2-ata-2        /dev/sda   S21JXXXXXX         465,8G     PASSED
    M1-P1        01:00.0-ata-1        /dev/sdb   WD-WCXXXXXX        3,6T       PASSED
    M1-P2        01:00.0-ata-9        /dev/sdc   WD-WCXXXXXX        1,8T       PASSED
    M1-P3        01:00.0-ata-10       /dev/sdd   663XXXXXX          1,8T       PASSED
    M1-P4        01:00.0-ata-11       /dev/sde   WD-WCAXXXXXX       931,5G     PASSED
    M1-P5        01:00.0-ata-12       /dev/sdf   WD-WCCXXXXXX       931,5G     PASSED
    M1-P6        01:00.0-ata-2        /dev/sdg   WD-WMCXXXXXX       931,5G     PASSED
    M1-P7        01:00.0-ata-13       /dev/sdh   WD-WMCXXXXXX       931,5G     PASSED
    M1-P8        01:00.0-ata-14       /dev/sdi   WD-WCCXXXXXX       465,8G     PASSED
    ...
    ...