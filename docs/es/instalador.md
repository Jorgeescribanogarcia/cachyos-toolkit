# `install.sh` — referencia de funciones

[← Índice](README.md)

El instalador de arranque independiente publicado en GitHub Releases. Clona el
toolkit en `~/.local/share/cachyos-toolkit` y registra un comando
`cachyos-toolkit` más un lanzador `.desktop`. Es bilingüe (EN/ES, según el
locale), se niega a ejecutarse como root, y presenta un menú pequeño de
**Instalar / Desinstalar**.

### Rutas clave

| Variable | Valor |
|---|---|
| `INSTALL_DIR` | `${XDG_DATA_HOME:-~/.local/share}/cachyos-toolkit` (el clon git) |
| `ASSISTANT`   | `$INSTALL_DIR/bin/cachyos-assistant` |
| `BIN_LINK`    | `~/.local/bin/cachyos-toolkit` (symlink → `$ASSISTANT`) |
| `DESKTOP`     | `…/applications/cachyos-toolkit.desktop` |

---

### `t`
- **Firma:** `t <clave>`
- **Qué hace:** devuelve la cadena localizada de las arrays asociativas `EN`/`ES`
  según el locale detectado.

### `log` / `ok` / `warn` / `err`
- **Firma:** `log|ok|warn|err <mensaje>`
- **Qué hacen:** líneas de estado con color (misma convención que los otros
  scripts; `err` va a stderr).

### `confirm`
- **Firma:** `confirm <pregunta>`
- **Qué hace:** pregunta con un sufijo `[s/N]` (`[y/N]`).
- **Devuelve:** `0` si la respuesta es sí (`s`/`y`), distinto de cero si no.

### `is_installed`
- **Firma:** `is_installed`
- **Qué hace:** informa de si el toolkit está instalado.
- **Devuelve:** `0` si existe el symlink del comando, el `.desktop` **o** la
  carpeta del clon.

### `do_install`
- **Firma:** `do_install`
- **Qué hace:** (1) asegura que `git` esté disponible (ofrece
  `sudo pacman -S git`); (2) clona el repo en `INSTALL_DIR` con
  `git clone --depth 1`, o `git pull` si ya está; (3) crea el symlink
  `cachyos-toolkit` en `~/.local/bin`; (4) escribe el lanzador `.desktop`
  (`Terminal=true`, `Exec=$ASSISTANT`, `Categories=System;`); (5) ejecuta
  `update-desktop-database`; (6) avisa si `~/.local/bin` no está en el `PATH`.
- **Devuelve:** distinto de cero si falla el paso de git/clon.

### `do_uninstall`
- **Firma:** `do_uninstall`
- **Qué hace:** si está instalado, pide confirmación y elimina el symlink del
  comando, el `.desktop`, y toda la carpeta del clon `INSTALL_DIR`, y luego
  refresca la base de datos de aplicaciones.
- **Notas:** protege el borrado (`INSTALL_DIR` no vacío y que sea un directorio).

### Bucle del menú
- El cuerpo del script es un bucle `while` que redibuja el menú **Instalar /
  Desinstalar / Salir** (con el estado de instalación actual) y despacha a
  `do_install` / `do_uninstall`.
