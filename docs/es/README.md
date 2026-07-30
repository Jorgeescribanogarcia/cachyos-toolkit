# Documentación avanzada (Español)

[← Volver al README](../../README.es.md) · [English](../en/)

Referencia técnica función por función de CachyOS Toolkit. Documenta cada
función de los tres scripts, agrupada por categorías.

## Contenido

- **[Arquitectura](arquitectura.md)** — los tres scripts, cómo encajan, el
  sistema de i18n, el sistema de navegación (`menu_pick` / `menu_pick_multi`) y
  dónde se guardan los ajustes.
- **[`cachyos-assistant`](asistente.md)** — el asistente interactivo: cada
  función, por categoría (i18n, estilo/helpers, navegación, motor de
  instalación, catálogo de aplicaciones, sección de instalación,
  configuración y arreglos, gestor de servicios, mantenimiento, auto-instalación
  y actualización, menú principal y arranque).
- **[`cachyos-fix`](fix.md)** — el motor de arreglos: cada subcomando y helper.
- **[`install.sh`](instalador.md)** — el instalador independiente del Release.

## Convenciones

Cada función se documenta como:

- **Firma** — nombre y parámetros posicionales (`$1`, `$2`…).
- **Qué hace** — descripción breve.
- **Lee / escribe** — los globales, ficheros o estado del sistema que toca.
- **Devuelve / salida** — código de salida y/o lo que imprime (muchas funciones
  «selectoras» devuelven su valor a través de una variable global, indicado en
  cada una).
- **Notas** — casos límite y decisiones de diseño que conviene conocer.
