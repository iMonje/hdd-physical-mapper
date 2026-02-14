# Changelog

## [1.2.0] - 2026-02-14
### Added
- **Columna de Montaje:** Nueva funcionalidad que detecta si el disco o alguna de sus particiones está montada en el sistema con indicadores de color (Verde/Rojo)
- **Formateo Dinámico:** Mejora visual de la tabla mediante el uso de `printf` para garantizar que las columnas no se solapen independientemente del tamaño del Serial Number.
- **Identificación Verde:** El estado "SI" en la columna MOUNT aparece en verde para una identificación rápida de discos activos.

## [1.1.0] - 2026-02-10
### Added
- **Expansión de Hardware:** Ampliación del mapeo manual para soportar hasta 16 discos (Manojo 1 y Manojo 2).
- **Mapeo de Puerto de Placa:** Soporte específico para el puerto SATA integrado de la placa base (`PLACA-SATA2`).

### Fixed
- **Duplicidad de líneas:** Corrección del filtro `grep` que causaba que se mostraran rutas genéricas del bus PCI como dispositivos independientes ("DESCONOCIDO").
- **Filtro de particiones:** Ahora el script ignora las particiones (sda1, sda2...) y se centra exclusivamente en el bloque físico del disco.

## [1.0.0] - 2026-02-10
### Added
- **Versión Inicial:** Script básico de mapeo entre `/dev/sdX` y rutas físicas `/dev/disk/by-path/`.
- **Integración SMART:** Lectura del estado de salud del disco mediante `smartmontools` con indicadores de color (Verde/Rojo).
- **Traducción Manual:** Función `traducir_cable` para convertir IDs de bus complejos en etiquetas físicas legibles (M1-P1...M1-P8).
- **README inicial:** Documentación del problema de los nombres dinámicos en Linux y el disclaimer de "bitácora personal".

---

> **Nota:** Este proyecto nació de la necesidad de no sacar el disco equivocado en un servidor con 16 bahías. Se mantiene como una bitácora personal de soluciones de almacenamiento.