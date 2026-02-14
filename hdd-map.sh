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
        "01:00.0-ata-15") echo "M2-P1" ;;
        "01:00.0-ata-16") echo "M2-P2" ;;
        "01:00.0-ata-3")  echo "M2-P3" ;;
        "01:00.0-ata-17") echo "M2-P4" ;;
        "01:00.0-ata-18") echo "M2-P5" ;;
        "01:00.0-ata-19") echo "M2-P6" ;;
        "00:1f.2-ata-2")  echo "PLACA-SATA2" ;;
        *) echo "DESCONOCIDO" ;;
    esac
}

# Cabecera ajustada (Añadida columna MOUNT)
printf "%-12s %-20s %-10s %-18s %-10s %-10s %-8s\n" "CABLE" "ID FÍSICO" "DISCO" "SERIAL NUMBER" "TAMAÑO" "SMART" "MOUNT"
echo "----------------------------------------------------------------------------------------------------------------"

# Iteramos solo sobre discos físicos
lsblk -dno NAME,SERIAL,SIZE | while read dev serial size; do
    
    # Buscamos la ruta física
    full_path=$(ls -l /dev/disk/by-path/ | grep -E "/${dev}$" | sed 's/pci-0000://' | head -n 1 | awk '{print $9}')
    
    if [ -z "$full_path" ]; then
        cable_id="N/A"
        port_display="INTERNO"
    else
        cable_id=$(traducir_cable "$full_path")
        port_display="$full_path"
    fi
    
    # Comprobamos si el disco o alguna de sus particiones tiene un punto de montaje
    mounted_check=$(lsblk /dev/$dev -no MOUNTPOINTS | grep -v "^$" | wc -l)
    if [ "$mounted_check" -gt 0 ]; then
        mount_fmt="\e[32mSI\e[0m"
    else
        mount_fmt="\e[31mNO\e[0m"
    fi
    # -------------------------------

    # Estado SMART
    health=$(sudo smartctl -H /dev/$dev 2>/dev/null | grep "test result" | cut -d: -f2 | xargs)
    [ -z "$health" ] && health="N/A"
    
    # Colores SMART
    if [ "$health" = "PASSED" ] || [ "$health" = "OK" ]; then
        health_fmt="\e[32m$health\e[0m"
    else
        health_fmt="\e[31m$health\e[0m"
    fi

    # Imprimir línea con la nueva columna
    printf "%-12s %-19s %-10s %-18s %-9s %-20b %-8b\n" "$cable_id" "$port_display" "/dev/$dev" "$serial" "$size" "$health_fmt" "$mount_fmt"
done
