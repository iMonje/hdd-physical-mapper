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

VERDE=$'\e[32m'
ROJO=$'\e[31m'
RESET=$'\e[0m'

# Imprime una celda rellenando por caracteres visibles: así ni las tildes
# ni los códigos de color descuadran las columnas. Uso: celda TEXTO ANCHO [COLOR]
celda() {
    local relleno=$(( $2 - ${#1} ))
    [ "$relleno" -lt 0 ] && relleno=0
    printf '%s%s%s%*s ' "${3:-}" "$1" "${3:+$RESET}" "$relleno" ""
}

# Uso: fila CABLE PUERTO DISCO SERIAL TAMAÑO LIBRE SMART MOUNT [COLOR_SMART] [COLOR_MOUNT]
fila() {
    celda "$1" 12
    celda "$2" 19
    celda "$3" 10
    celda "$4" 18
    celda "$5" 9
    celda "$6" 9
    celda "$7" 10 "${9:-}"
    celda "$8" 8 "${10:-}"
    echo
}

# Devuelve el identificador del puerto físico de un disco (vacío si no tiene)
ruta_fisica() {
    local enlace
    for enlace in /dev/disk/by-path/*; do
        if [ "$enlace" -ef "/dev/$1" ]; then
            enlace="${enlace##*/}"
            echo "${enlace#pci-0000:}"
            return
        fi
    done
}

# Suma el espacio libre de todos los sistemas de archivos montados del disco
# (particiones y LVM incluidos). Devuelve "-" si no hay ninguno montado.
espacio_libre() {
    local bytes
    bytes=$(lsblk -bnro FSAVAIL "/dev/$1" | awk 'NF { total += $1; hay = 1 } END { if (hay) printf "%.0f", total }')
    if [ -z "$bytes" ]; then
        echo "-"
    else
        numfmt --to=iec --format=%.1f "$bytes"
    fi
}

fila "CABLE" "ID FÍSICO" "DISCO" "SERIAL NUMBER" "TAMAÑO" "LIBRE" "SMART" "MOUNT"
printf '%*s\n' 103 "" | tr ' ' '-'

# Iteramos solo sobre discos físicos. SERIAL va al final porque puede estar
# vacío y, en otra posición, desplazaría el resto de campos.
lsblk -dno NAME,SIZE,TYPE,SERIAL | while read -r dev size tipo serial; do
    [ "$tipo" = "disk" ] || continue

    port_display=$(ruta_fisica "$dev")
    if [ -z "$port_display" ]; then
        cable_id="N/A"
        port_display="INTERNO"
    else
        cable_id=$(traducir_cable "$port_display")
    fi

    # Comprobamos si el disco o alguna de sus particiones tiene un punto de montaje
    if lsblk "/dev/$dev" -no MOUNTPOINTS | grep -q .; then
        mount="SI"
        mount_color="$VERDE"
    else
        mount="NO"
        mount_color="$ROJO"
    fi

    # Estado SMART (ATA/NVMe: "test result"; SAS: "Health Status")
    health=$(sudo smartctl -H "/dev/$dev" 2>/dev/null | grep -E "test result|Health Status" | cut -d: -f2 | xargs)
    [ -z "$health" ] && health="N/A"

    if [ "$health" = "PASSED" ] || [ "$health" = "OK" ]; then
        health_color="$VERDE"
    else
        health_color="$ROJO"
    fi

    fila "$cable_id" "$port_display" "/dev/$dev" "${serial:--}" "$size" "$(espacio_libre "$dev")" "$health" "$mount" "$health_color" "$mount_color"
done
