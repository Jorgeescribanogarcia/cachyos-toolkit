# Arquitectura

[← Índice](README.md)

## Los tres scripts

| Script | Rol | Se ejecuta como |
|---|---|---|
| `bin/cachyos-assistant` | Interfaz interactiva por menús. Aquí viven todas las secciones, la navegación y los catálogos. | usuario normal (pide `sudo` cuando hace falta) |
| `bin/cachyos-fix` | «Motor de arreglos» no interactivo. Subcomandos sueltos (`keyboard`, `wifi`, `repair-boot`…). El asistente lo llama para los arreglos de sistema. | usuario normal (usa `sudo` internamente) |
| `install.sh` | Instalador de arranque independiente, publicado en GitHub Releases. Clona el repo y registra el comando + lanzador. | usuario normal |

El asistente localiza `cachyos-fix` junto a sí mismo (`SCRIPT_DIR`), cayendo al
`PATH` si no. Ambos se niegan a ejecutarse como root.

## i18n (bilingüe EN/ES)

Ambos scripts comparten el mismo diseño:

- Dos arrays asociativas, `MSG_EN` y `MSG_ES`, mapean una **clave** a una cadena.
- `t <clave>` devuelve la cadena del `UI_LANG` actual (cayendo a inglés, y luego
  a la propia clave).
- El idioma de la interfaz lo resuelve `load_lang` en este orden: la variable de
  entorno `CACHYOS_LANG` → el fichero guardado `~/.config/cachyos-toolkit/lang` →
  el locale del sistema (`detect_system_lang`) → inglés.
- El asistente pasa su idioma a `cachyos-fix` mediante `CACHYOS_LANG` (ver
  `run_fix`).

**Añadir una cadena de UI:** añade la clave a `MSG_EN` y a `MSG_ES`.

## Navegación (`menu_pick` / `menu_pick_multi`)

Los menús del asistente se pintan con dos selectores reutilizables:

- `menu_pick` — elección única. Guarda la clave elegida en el global
  `MENU_RESULT`; una línea de info opcional se muestra vía `MENU_INFO`.
- `menu_pick_multi` — elección múltiple (casillas), usada por los menús de
  instalación. Guarda el resultado en `MULTI_ACTION` (`ok`/`empty`/`list`/
  `cancel`) y los índices seleccionados en `MULTI_SEL`.

Ambos respetan el **modo de navegación** `NAV_MODE`:

- `arrows` — ↑/↓ (o `k`/`j`) mueven, Enter elige, la tecla de la fila la
  selecciona directamente, `q`/Esc/← vuelven; en el selector múltiple Espacio
  marca y `a` marca todo.
- `numbers` — el comportamiento clásico: se imprime la lista y se lee la
  tecla/línea tecleada. Sirve también de respaldo para terminales donde las
  flechas fallen.

`NAV_MODE` lo resuelve `load_nav` (env `CACHYOS_NAV` → fichero
`~/.config/cachyos-toolkit/nav` → por defecto `arrows`) y se cambia desde
*Configuración › Modo de navegación*.

## Almacenamiento de ajustes

Todo a nivel de usuario, bajo `${XDG_CONFIG_HOME:-~/.config}/cachyos-toolkit/`:

| Fichero | Contenido |
|---|---|
| `lang` | `en` o `es` |
| `nav`  | `arrows` o `numbers` |

## Arranque

`cachyos-assistant` ejecuta, en orden: `load_lang`, `load_nav`, un asistente de
configuración de primer arranque (pregunta idioma y luego modo de navegación
cuando ninguno está guardado aún), `run_update_check auto` (ofrece un `git pull`
si el clon está por detrás) y luego `main_menu`.

## Auto-instalación y actualizaciones

La pantalla *Instalar esta herramienta como app* (menú principal) y `install.sh`
registran un comando `cachyos-toolkit` y un lanzador `.desktop` que apuntan al
clon (no se hace copia), de forma que `git pull` mantiene todo al día. En cada
arranque el asistente comprueba el upstream de git y ofrece actualizar.
