#!/bin/bash

# Función para traducir el puerto físico al cable real
traducir_cable() {
    case "$1" in
        "01:00.0-ata-1")  echo "M1-P1" ;;
        "01:00.0-ata-9")  echo "M1-P2" ;;
        "01:00.0-ata-10") echo "M1-P3" ;;
        "01:00.0-ata-11") echo "M1-P4" ;;
        "01:00.0-ata-12") echo "M1-P5" ;;
        "01:00.0-ata-2")  echo "M1-P6" ;;
        "01:00.0-ata-13") echo "M1-P7" ;;
        "01:00.0-ata-14") echo "M1-P8" ;;
        "00:1f.2-ata-2")  echo "PLACA-SATA2" ;;
        *) echo "DESCONOCIDO" ;;
    esac
}

# Cabecera ajustada
printf "%-12s %-20s %-10s %-18s %-10s %-10s\n" "CABLE" "ID FÍSICO" "DISCO" "SERIAL NUMBER" "TAMAÑO" "SMART"
echo "------------------------------------------------------------------------------------------------------"

# Iteramos solo sobre discos físicos (no particiones)
lsblk -dno NAME,SERIAL,SIZE | while read dev serial size; do

    # Buscamos la ruta que termina exactamente en el nombre del disco (ej. /sdb)
    # El grep -E asegura que no pillemos rutas genéricas
    full_path=$(ls -l /dev/disk/by-path/ | grep -E "/${dev}$" | sed 's/pci-0000://' | head -n 1 | awk '{print $9}')

    if [ -z "$full_path" ]; then
        cable_id="N/A"
        port_display="INTERNO"
    else
        cable_id=$(traducir_cable "$full_path")
        port_display="$full_path"
    fi

    # Estado SMART (silenciamos errores por si el disco no lo soporta)
    health=$(sudo smartctl -H /dev/$dev 2>/dev/null | grep "test result" | cut -d: -f2 | xargs)
    [ -z "$health" ] && health="N/A"

    # Colores
    if [ "$health" = "PASSED" ] || [ "$health" = "OK" ]; then
        health_fmt="\e[32m$health\e[0m"
    else
        health_fmt="\e[31m$health\e[0m"
    fi

    # Imprimimos la línea final limpia
    printf "%-12s %-20s %-10s %-18s %-10s %-10b\n" "$cable_id" "$port_display" "/dev/$dev" "$serial" "$size" "$health_fmt"
done