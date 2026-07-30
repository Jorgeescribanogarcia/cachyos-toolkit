# `cachyos-assistant` — referencia de funciones

[← Índice](README.md)

El asistente interactivo. Esta referencia documenta cada función, agrupada por
categoría. Ver [Arquitectura](arquitectura.md) para los sistemas de i18n y
navegación en los que se apoyan.

> **Datos del catálogo.** El catálogo de aplicaciones vive en arrays paralelas,
> no en funciones: para cada categoría `X` hay `X_NAMES` (nombres visibles),
> `X_PKGS` (paquetes, se permiten grupos separados por espacios) y `X_DESC_EN` /
> `X_DESC_ES` (descripciones), todas alineadas por índice. `PACKS` tiene además
> `PACKS_NAMES_EN` / `PACKS_NAMES_ES`. Para añadir una app, alinea las cuatro
> arrays por índice.

---

## i18n y ajustes

### `detect_system_lang`
- **Firma:** `detect_system_lang` — imprime `es`/`en` según el locale.

### `load_lang`
- **Firma:** `load_lang`
- **Qué hace:** resuelve `UI_LANG` (env `CACHYOS_LANG` → `~/.config/cachyos-toolkit/lang` → locale del sistema → `en`) y anota su origen en `LANG_SOURCE` (`env`/`file`/`default`).

### `save_lang`
- **Firma:** `save_lang` — persiste `UI_LANG` en el fichero `lang`.

### `load_nav`
- **Firma:** `load_nav`
- **Qué hace:** resuelve `NAV_MODE` (env `CACHYOS_NAV` → `~/.config/cachyos-toolkit/nav` → por defecto `arrows`) y anota `NAV_SOURCE`.

### `save_nav`
- **Firma:** `save_nav` — persiste `NAV_MODE` en el fichero `nav`.

### `t`
- **Firma:** `t <clave>` — devuelve la cadena localizada (`MSG_${UI_LANG^^}`, cayendo a `MSG_EN` y luego a la clave).

---

## Estilo y helpers

### `header`
- **Firma:** `header [subtítulo]`
- **Qué hace:** limpia la pantalla e imprime la caja de título cian (`app_title`
  en la primera línea, `subtítulo` en la segunda).

### `ok` / `warn` / `err`
- **Firma:** `ok|warn|err <mensaje>` — líneas de estado con color (`err` → stderr).

### `pause`
- **Firma:** `pause` — imprime "Pulsa Enter…" y espera una línea.

### `confirm`
- **Firma:** `confirm <pregunta>`
- **Devuelve:** `0` si la respuesta coincide con `[sSyY]`, distinto de cero si no.

---

## Navegación

### `menu_pick`
- **Firma:** `menu_pick <título> <array_claves> <array_etiquetas> [tecla_volver]`
- **Qué hace:** pinta un menú de elección única y guarda la clave elegida en el
  global **`MENU_RESULT`**. En modo `arrows`: ↑/↓ (o `k`/`j`) mueven, Enter elige
  la fila resaltada (`▸`), pulsar la tecla de una fila la selecciona directamente,
  `q`/Esc/← devuelven `tecla_volver` (por defecto `0`). En modo `numbers`: imprime
  la lista y lee una tecla/línea. Una línea de info opcional se muestra desde el
  global **`MENU_INFO`**.
- **Notas:** quien la llama pasa arrays paralelas `keys`/`labels` y luego hace
  `case` sobre `MENU_RESULT`, así el mismo `case` sirve para ambos modos.

### `menu_pick_multi`
- **Firma:** `menu_pick_multi <título> <array_etiquetas>`
- **Qué hace:** un menú de casillas (elección múltiple). Fija **`MULTI_ACTION`** a
  `ok` (≥1 marcada), `empty` (Enter sin nada marcado), `list` (`L`) o `cancel`
  (`q`/Esc/←/`0`), y **`MULTI_SEL`** con los índices seleccionados (base 0). Modo
  flechas: ↑/↓ mueven, Espacio (o un dígito) marca, `a` marca todo, Enter
  confirma; modo números: clásico "teclea 1 3 5", `a`=todo, `L`=lista, `0`=volver.

---

## Motor de instalación

### `detect_helper`
- **Firma:** `detect_helper` — imprime `paru`, `yay` o `pacman`.

### `ensure_base_devel`
- **Firma:** `ensure_base_devel`
- **Qué hace:** asegura el entorno de compilación de AUR (`base-devel` + `git`),
  instalando con pacman lo que falte.
- **Devuelve:** `0` si está listo, `1` si no pudo instalarlos.

### `install_paru`
- **Firma:** `install_paru`
- **Qué hace:** cuando no hay ayudante de AUR, ofrece instalar `paru` — primero de
  los repos de CachyOS, si no compilando `paru-bin` desde AUR (necesita
  `ensure_base_devel`).
- **Devuelve:** `0` si paru acaba instalado.

### `install_packages`
- **Firma:** `install_packages <paquete...>`
- **Qué hace:** instala paquetes. Si no hay ayudante de AUR ofrece `install_paru`
  primero; muestra lo que se instalará, pide `confirm`, y ejecuta
  `pacman -S --needed` (solo oficiales) o `<ayudante> -S --needed --skipreview`
  (tras `ensure_base_devel`). `--skipreview` evita el paginador de PKGBUILD que
  abortaba instalaciones (p. ej. VS Code).

### `uninstall_packages`
- **Firma:** `uninstall_packages <paquete...>`
- **Qué hace:** desinstala paquetes. Filtra la lista a los realmente instalados
  (`pacman -Qq`), avisa si ninguno lo está, confirma, y ejecuta
  `sudo pacman -Rns`. No necesita ayudante de AUR (los de AUR son paquetes
  normales una vez instalados).

---

## Lista de instalación

Arrays globales paralelas `LIST_NAMES` / `LIST_PKGS` guardan una selección
entre categorías.

### `list_add`
- **Firma:** `list_add <nombre> <paquetes>` — añade a la lista, saltando
  duplicados (por grupo de paquetes).

### `list_show`
- **Firma:** `list_show` — imprime las entradas en cola (nombre + paquetes).

### `list_install`
- **Firma:** `list_install` — aplana los grupos de paquetes y los instala todos
  (`install_packages`); vacía la lista si tiene éxito.

### `list_uninstall`
- **Firma:** `list_uninstall` — igual, pero `uninstall_packages`; vacía si tiene
  éxito.

### `list_menu`
- **Firma:** `list_menu`
- **Qué hace:** la pantalla de gestión de la lista (vía `menu_pick`): instalar
  TODO, desinstalar TODO, quitar un elemento (por número), vaciar. Muestra los
  elementos en cola como bloque de info. Lista vacía → una pista y vuelve.

---

## Sección de aplicaciones

### `category_menu`
- **Firma:** `category_menu <etiqueta> <array_nombres> <array_paquetes> <base_desc>`
  (la array de descripciones usada es `${base_desc}_${UI_LANG^^}`)
- **Qué hace:** el menú de instalación multi-selección de una categoría. Usa
  `menu_pick_multi` para marcar apps, y luego ofrece, vía `menu_pick`: instalar
  ahora, añadir a la lista o desinstalar las apps marcadas. `L` abre `list_menu`;
  volver retorna.

### `dev_individual_menu`
- **Firma:** `dev_individual_menu` — sub-navegación de Desarrollo › Individual
  (Editores, Lenguajes, Bases de datos, Herramientas), cada una abre un
  `category_menu`.

### `dev_section`
- **Firma:** `dev_section` — menú de Desarrollo: Packs (un `category_menu` sobre
  `PACKS_*`) o Individual (`dev_individual_menu`).

### `apps_section`
- **Firma:** `apps_section`
- **Qué hace:** el menú de nivel superior «Instalar aplicaciones»: las ocho
  categorías, más `L` para abrir la lista de instalación.

---

## Configuración y arreglos

### `has_cachyos_fix`
- **Firma:** `has_cachyos_fix` — devuelve `0` si `cachyos-fix` está disponible.

### `run_fix`
- **Firma:** `run_fix <args...>` — ejecuta `cachyos-fix` pasando el idioma de la
  interfaz por `CACHYOS_LANG`.

### `apply_fix`
- **Firma:** `apply_fix <subcomando> <descripción> [args extra...]`
- **Qué hace:** muestra la descripción, pide `confirm`, y con sí ejecuta
  `run_fix <subcomando> [args extra]`. Gestiona el "fix no encontrado".

### `choose_layout`
- **Firma:** `choose_layout`
- **Qué hace:** selector de distribución de teclado (Español, EE.UU.,
  Latinoamérica, Francés…, más "teclear un código"). Imprime el código elegido
  por **stdout** (el menú va a stderr, para poder capturarlo como
  `lay=$(choose_layout)`); vacío = cancelar.

### `choose_numlock`
- **Firma:** `choose_numlock` — imprime `on`/`off`/`unchanged` (menú a stderr);
  vacío = cancelar.

### `choose_fnkeys`
- **Firma:** `choose_fnkeys` — imprime `fkeys`/`media`/`auto`; vacío = cancelar.

> Estas tres siguen usando prompts clásicos (se capturan con `$(…)`, lo que choca
> con el `menu_pick` basado en redibujado).

### `config_section`
- **Firma:** `config_section`
- **Qué hace:** el menú de Configuración (Red, Teclado, Mirrors, Navegador
  predeterminado, Actualizaciones y mantenimiento, Modo de navegación, Aplicar
  TODOS los arreglos).

### `fix_network_menu`
- **Firma:** `fix_network_menu` — ofrece el arreglo de WiFi (`apply_fix wifi`).

### `fix_keyboard_menu`
- **Firma:** `fix_keyboard_menu` — menú de Teclado: distribución (`choose_layout`
  → `apply_fix keyboard`), comportamiento de Bloq Num (`choose_numlock` →
  `apply_fix numlock`), comportamiento de Fn (`choose_fnkeys` → `apply_fix
  fnkeys`).

### `fix_mirrors_menu`
- **Firma:** `fix_mirrors_menu` — ofrece el refresco de mirrors
  (`apply_fix mirrors`).

### `fix_maintenance_menu`
- **Firma:** `fix_maintenance_menu` — Actualizaciones y mantenimiento: chequeo
  previo, actualización segura, reparar arranque, y ver/eliminar kernels
  obsoletos — cada uno un `apply_fix` del subcomando correspondiente de
  `cachyos-fix`.

---

## Navegador predeterminado

### `detect_browsers`
- **Firma:** `detect_browsers`
- **Qué hace:** escanea los ficheros `.desktop` (en los directorios de
  aplicaciones del sistema, del usuario y de Flatpak) e imprime
  `"<id-desktop>\t<Nombre>"` por cada entrada que registra el esquema de URL
  `http(s)` (excluyendo las ocultas/no-display).

### `browser_name`
- **Firma:** `browser_name <id-desktop>` — mapea un id a su Nombre bonito (cae al
  id si no).

### `config_browser_menu`
- **Firma:** `config_browser_menu`
- **Qué hace:** el selector de navegador predeterminado. Asegura `xdg-settings`
  (ofrece instalar `xdg-utils`), lista los navegadores detectados (vía
  `menu_pick`, mostrando el predeterminado actual) y aplica la elección con
  `xdg-settings set default-web-browser`.

---

## Auto-instalación y actualizaciones

Globales: `APP_SELF` (ruta real del asistente), `APP_BIN`
(`~/.local/bin/cachyos-toolkit`), `APP_DESKTOP` (el lanzador).

### `app_is_installed`
- **Firma:** `app_is_installed` — devuelve `0` si existe el symlink del comando o
  el `.desktop`.

### `install_app_do`
- **Firma:** `install_app_do`
- **Qué hace:** registra el toolkit como app — un symlink `cachyos-toolkit` en
  `~/.local/bin` → el asistente, y un lanzador `.desktop` (`Terminal=true`, `Exec`
  absoluto, `Categories=System;`) — y luego `update-desktop-database` y un aviso
  de PATH. Ambos apuntan al repo (sin copia), así `git pull` los mantiene al día.

### `install_app_undo`
- **Firma:** `install_app_undo` — quita el symlink y el `.desktop`
  (desinstalación limpia).

### `install_app_menu`
- **Firma:** `install_app_menu`
- **Qué hace:** la pantalla «Instalar esta herramienta como app». Cuando está
  instalada, «Instalar» sale atenuada y solo actúa «Desinstalar» (y viceversa).
  Ofrece además un **Buscar actualizaciones** manual (`run_update_check manual`).

### `run_update_check`
- **Firma:** `run_update_check [auto|manual]`
- **Qué hace:** si el toolkit es un clon git con upstream, hace fetch (con
  timeout, sin pedir nada) y compara con el remoto. Si está por detrás, ofrece
  `git pull --ff-only` y, si va bien, reinicia con `exec`. `auto` (arranque) es
  silencioso salvo que haya update y se salta con `CACHYOS_NO_UPDATE_CHECK`;
  `manual` siempre reporta el resultado (actualizado / sin conexión / no es un
  clon).

---

## Estado del sistema

### `status_section`
- **Firma:** `status_section` — ejecuta `cachyos-fix status` (o un respaldo mínimo
  si falta el motor).

---

## Gestor de servicios

### `svc_filter_scope`
- **Firma:** `svc_filter_scope <filtro>` — imprime `user` para los filtros
  `apps`/`user`, y `system` en el resto. Determina qué gestor de systemd (y si
  `sudo`) usan las acciones.

### `svc_known`
- **Firma:** `svc_known <scope> <unidad>` — devuelve `0` si la unidad es conocida
  por ese gestor (`systemctl [--user] cat`).

### `svc_list_units`
- **Firma:** `svc_list_units <filtro>`
- **Qué hace:** lista nombres de unidad para un filtro, ordenados
  case-insensitive — `apps` (unidades de usuario `app-*` en marcha),
  `running`/`failed` (sistema, `list-units`), `enabled`/`all`/`system` (sistema,
  `list-unit-files`).

### `svc_is_system`
- **Firma:** `svc_is_system <unidad>`
- **Qué hace:** clasificador heurístico — devuelve `0` para servicios de bajo
  nivel del SO (`systemd-*`, unidades de plantilla `*@*`, `dbus`, `polkit`,
  `udisks2`, `avahi`, gestores de sesión, `cachyos-*`…), que quedan ocultos en los
  filtros normales y solo salen bajo `system`.

### `svc_next_filter`
- **Firma:** `svc_next_filter <filtro>` — el ciclo
  apps → running → enabled → failed → all → system → apps.

### `svc_filter_name`
- **Firma:** `svc_filter_name <filtro>` — la etiqueta localizada del filtro.

### `svc_load_states`
- **Firma:** `svc_load_states <scope>`
- **Qué hace:** carga en bloque, en dos llamadas a `systemctl`, el estado activo
  (`SVC_ACTIVE`), el estado de autoarranque (`SVC_ENABLED`) y la descripción
  (`SVC_DESC`) de cada unidad del gestor, para que pintar una lista larga no
  necesite llamadas por unidad.

### `_svc_render_badges`
- **Firma:** `_svc_render_badges <estado-activo> <estado-enabled>` — pinta el
  badge con color "estado · autoarranque" a partir de estados crudos.

### `svc_badges`
- **Firma:** `svc_badges <scope> <unidad>` — badges en vivo de una unidad (usado
  en el menú de acción; consulta `systemctl` al momento).

### `svc_badges_row`
- **Firma:** `svc_badges_row <unidad>` — badges desde los mapas cacheados
  `SVC_ACTIVE`/`SVC_ENABLED` (para pintar la lista rápido).

### `svc_app_label`
- **Firma:** `svc_app_label <unidad> <descripción-cruda>`
- **Qué hace:** un nombre bonito para una unidad de usuario/app — la Description
  de systemd, o (si falta) un nombre derivado del id de la unidad
  (`app-org.kde.konsole-2123.scope` → `konsole`).

### `svc_isenabled`
- **Firma:** `svc_isenabled <scope> <unidad>` — el valor crudo de `is-enabled`.

### `svc_run`
- **Firma:** `svc_run <scope> <unidad> <acción>` — ejecuta la acción de systemctl
  (`sudo systemctl` para sistema, `systemctl --user` para usuario) y reporta el
  resultado.

### `svc_unmask_then`
- **Firma:** `svc_unmask_then <scope> <unidad> <acción>` — para una unidad
  enmascarada, ofrece `unmask` y luego ejecuta la acción.

### `svc_start_generic` / `svc_enable_generic` / `svc_disable_generic`
- **Firma:** `<fn> <scope> <unidad>`
- **Qué hacen:** la red de seguridad alrededor de start/enable/disable — detectan
  `masked` (ofrecen desenmascarar) y
  `static`/`indirect`/`generated`/`alias`/`transient` (explican en vez de fallar
  crípticamente) antes de llamar a `svc_run`.

### `service_actions`
- **Firma:** `service_actions <scope> <unidad> <etiqueta>`
- **Qué hace:** el menú de acciones por servicio (encender, apagar, reiniciar,
  activar, desactivar, ver estado detallado, refrescar), mostrando el badge en
  vivo de la unidad como línea de info.

### `services_section`
- **Firma:** `services_section`
- **Qué hace:** la pantalla de Servicios. Construye la lista dinámicamente para el
  filtro actual (por defecto `apps`), con XAMPP al principio en scope de sistema,
  badges desde los mapas en bloque, `f` para ciclar filtros, `r` para refrescar,
  `n` para gestionar cualquier unidad por nombre, y un número/fila para abrir
  `service_actions` (o `xampp_actions`).

---

## XAMPP (caso especial)

XAMPP puede correr fuera de systemd (con su propio script `/opt/lampp`), así que
tiene una ruta dedicada en vez de la genérica.

### `xampp_present`
- **Firma:** `xampp_present` — devuelve `0` si `/opt/lampp/lampp` es ejecutable.

### `xampp_running`
- **Firma:** `xampp_running` — devuelve `0` si los daemons de XAMPP están arriba
  (`pgrep` de su `httpd`/`mysqld`), es decir, el estado real, no el de systemd.

### `xampp_can_autostart`
- **Firma:** `xampp_can_autostart` — devuelve `0` si la unidad `xampp` se puede
  activar (su `is-enabled` es `enabled`/`disabled`, o sea tiene `[Install]`).

### `xampp_badges`
- **Firma:** `xampp_badges` — el badge usando el estado real de ejecución y el de
  autoarranque.

### `xampp_setup_unit`
- **Firma:** `xampp_setup_unit`
- **Qué hace:** escribe `/etc/systemd/system/xampp.service` (un envoltorio
  `Type=oneshot`/`RemainAfterExit` alrededor de `/opt/lampp/lampp start|stop` con
  una sección `[Install]`) que sombrea la unidad estática que trae XAMPP, y luego
  hace `daemon-reload` — para que el autoarranque se pueda activar de verdad.

### `svc_run_xampp`
- **Firma:** `svc_run_xampp <acción-lampp>` — ejecuta `sudo /opt/lampp/lampp
  <acción>` (start/stop/restart/…) y reporta el resultado.

### `xampp_enable`
- **Firma:** `xampp_enable` — asegura una unidad activable (`xampp_setup_unit` si
  hace falta), y luego `systemctl enable xampp`.

### `xampp_actions`
- **Firma:** `xampp_actions <etiqueta>`
- **Qué hace:** el menú de acciones de XAMPP — encender/apagar/reiniciar por el
  script lampp, autoarranque por systemd, estado detallado por `lampp status`.

---

## Menú principal, idioma, navegación y arranque

### `choose_language`
- **Firma:** `choose_language` — el selector de idioma (Inglés / Español), lo
  guarda, usado en el primer arranque y desde el menú principal.

### `choose_nav_firstrun`
- **Firma:** `choose_nav_firstrun` — selector de modo de navegación de primer
  arranque (prompt clásico, porque el modo aún no está fijado); lo guarda.

### `choose_nav`
- **Firma:** `choose_nav` — el ajuste de modo de navegación desde Configuración
  (Flechas / Números), guardado.

### `main_menu`
- **Firma:** `main_menu`
- **Qué hace:** el bucle del menú de nivel superior (Instalar aplicaciones,
  Configuración, Servicios, Estado del sistema, Instalar esta herramienta como
  app, Idioma). La cabecera muestra el gestor de paquetes detectado.

> **Arranque** (al final del script): `load_lang`, `load_nav`, el asistente de
> primer arranque (`choose_language` y luego `choose_nav_firstrun` si no están
> fijados), `run_update_check auto`, y luego `main_menu`.
