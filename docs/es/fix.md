# `cachyos-fix` — referencia de funciones

[← Índice](README.md)

El motor de arreglos idempotente. Resuelve el idioma (`CACHYOS_LANG` → fichero
guardado → locale), se niega a ejecutarse como root, y luego despacha según el
primer argumento:

```
cachyos-fix [all|keyboard|numlock|fnkeys|wifi|mirrors|preupdate|update|repair-boot|clean-kernels|status]
```

Los alias en español siguen valiendo (`teclado`, `estado`, `mirror`, `espejos`,
`bloqnum`…). `all` ejecuta `keyboard`, `numlock`, `wifi` y `status`; `mirrors`,
`preupdate`, `update`, `repair-boot` y `clean-kernels` **no** están en `all` (son
más pesados / interactivos y opt-in).

---

## i18n y helpers de salida

### `detect_system_lang`
- **Firma:** `detect_system_lang`
- **Qué hace:** deduce el idioma de la interfaz a partir de
  `LC_ALL`/`LC_MESSAGES`/`LANG`.
- **Salida:** imprime `es` para locales en español, y `en` en el resto.

### `t`
- **Firma:** `t <clave>`
- **Qué hace:** traduce una clave de mensaje usando la array asociativa
  `MSG_${UI_LANG^^}`.
- **Salida:** la cadena localizada; cae a `MSG_EN[clave]`, y luego a la clave.

### `log` / `ok` / `warn` / `err`
- **Firma:** `log|ok|warn|err <mensaje>`
- **Qué hacen:** líneas de estado con color — `log` un paso azul `==>`, `ok` un
  `✔` verde, `warn` un `!` amarillo, `err` un `✗` rojo (a **stderr**).

### `write_root_file`
- **Firma:** `write_root_file <ruta> <contenido>`
- **Qué hace:** escribe `contenido` en una `ruta` propiedad de root mediante
  `sudo tee`, pero **solo si difiere** del contenido actual (comparado con
  `sudo cmp`).
- **Devuelve:** `0` si escribió/cambió el fichero, `1` si ya era idéntico.
- **Notas:** permite a quien la llama saber si hubo cambio (p. ej. si hace falta
  regenerar el initramfs).

---

## Arreglo: teclado

### `fix_keyboard`
- **Firma:** `fix_keyboard [distribución]` (por defecto `es`)
- **Qué hace:** fuerza la distribución de teclado en apps X11/Xwayland, en tres
  capas: (1) por defecto del sistema con `sudo localectl set-x11-keymap`; (2) un
  autostart de respaldo `~/.config/autostart/fix-keyboard-layout.desktop` que
  ejecuta `setxkbmap` (en KDE Wayland, KWin puede si no ignorar la distribución
  del sistema para Xwayland); (3) aplicación en caliente en la sesión actual con
  `setxkbmap`.
- **Escribe:** `/etc/X11/xorg.conf.d` (vía localectl), el fichero autostart;
  elimina el antiguo `fix-keyboard-es.desktop`.
- **Notas:** resuelve que apps como VS Code caigan en `us` (Mayús+2 → `@`).

---

## Arreglo: Bloq Num

### `fix_numlock`
- **Firma:** `fix_numlock [on|off|unchanged]` (por defecto `on`, retrocompatible)
- **Qué hace:** fija el comportamiento del teclado numérico al iniciar sesión y
  lo aplica en caliente. Mapea el modo al valor `[Keyboard] NumLock` de
  `kcminputrc` de KDE (`on`→0, `off`→1, `unchanged`→2) vía
  `kwriteconfig6`/`kwriteconfig5`. Para `on`/`off` lo aplica además en caliente
  con `numlockx` (instalándolo de los repos oficiales si falta); `unchanged` no
  hace cambio en vivo.
- **Escribe:** `kcminputrc`; puede instalar `numlockx`.

---

## Arreglo: teclas Fn

### `fix_fnkeys`
- **Firma:** `fix_fnkeys [fkeys|media|auto]` (por defecto `fkeys`)
- **Qué hace:** fija el comportamiento de la fila Fn a través del `fnmode` del
  driver `hid_apple` (`fkeys`→2, `media`→1, `auto`→3). Lo persiste en
  `/etc/modprobe.d/hid_apple.conf` y lo aplica en caliente escribiendo
  `/sys/module/hid_apple/parameters/fnmode`.
- **Notas:** **defensivo** — si `/sys/module/hid_apple` no existe (la mayoría de
  portátiles, donde el Fn lo controla la BIOS/firmware) avisa y no toca nada.

---

## Arreglo: WiFi

### `detect_wifi`
- **Firma:** `detect_wifi`
- **Qué hace:** encuentra la primera interfaz inalámbrica y su driver recorriendo
  `/sys/class/net/*/wireless`.
- **Salida/Devuelve:** imprime `"<iface> <driver>"` y devuelve `0`; devuelve `1`
  si no hay interfaz WiFi.

### `fix_wifi`
- **Firma:** `fix_wifi`
- **Qué hace:** arregla las desconexiones de rtw88 (BEACON-LOSS). Desactiva el
  ahorro de energía en NetworkManager (genérico, `wifi-powersave-off.conf`); para
  la familia rtw88 escribe además `/etc/modprobe.d/rtw88.conf`
  (`disable_aspm=1`, `disable_lps_deep=1`), regenera el initramfs
  (`mkinitcpio -P`) solo si ese fichero cambió, y recarga el driver solo si los
  parámetros no están ya aplicados (para no cortar la conexión sin necesidad).
- **Escribe:** los dos ficheros `.conf`; puede regenerar el initramfs y recargar
  el módulo. Usa `detect_wifi`.

---

## Arreglo: mirrors

### `fix_mirrors`
- **Firma:** `fix_mirrors`
- **Qué hace:** reordena la lista de mirrors de pacman para quedarse con los más
  rápidos/actualizados, y luego fuerza `pacman -Syy`. Prefiere
  `cachyos-rate-mirrors`, luego `rate-mirrors`, luego `reflector`; si no hay
  ninguno instalado ofrece instalar la recomendada `cachyos-rate-mirrors`.
- **Notas:** soluciona los errores 404 al actualizar por mirrors desincronizados.

---

## Helpers de arranque / kernel

### `boot_in_fstab`
- **Firma:** `boot_in_fstab`
- **Qué hace:** comprueba si `/etc/fstab` declara una partición `/boot` aparte
  (una línea no comentada cuyo punto de montaje, campo 2, es `/boot`).
- **Devuelve:** `0` si está declarada, `1` si no.

### `check_boot`
- **Firma:** `check_boot`
- **Qué hace:** asegura que `/boot` sea usable. Si ya está montado → OK. Si
  `boot_in_fstab` dice que debería estarlo y no lo está → intenta
  `sudo mount /boot`. Si no hay `/boot` aparte (está en la raíz) → OK.
- **Devuelve:** `0` si está montado o en la raíz, `1` si debería estar montado y
  no se pudo. Imprime el estado.

### `orphan_modules`
- **Firma:** `orphan_modules`
- **Qué hace:** imprime, una por línea, las carpetas `/usr/lib/modules/<ver>`
  sobrantes de kernels que ya no están instalados. El **kernel en uso**
  (`uname -r`) nunca se incluye.
- **Cómo lo decide:** lee el marcador `pkgbase` de cada carpeta (el paquete que
  la creó) y confirma con `pacman -Ql <paquete>` que esa versión exacta está en
  la lista de ficheros del paquete; si no, es huérfana.
- **Notas:** deliberadamente **no** usa `pacman -Qo`, que canonicaliza rutas y
  reportaría *otra* versión instalada como dueña de una carpeta sobrante —
  ocultando huérfanos reales, justo el fallo que esto detecta.

---

## Arreglo: chequeo previo y actualización

### `fix_preupdate`
- **Firma:** `fix_preupdate`
- **Qué hace:** el chequeo de seguridad previo a actualizar. Ejecuta
  `check_boot` y luego inspecciona `/var/lib/pacman/db.lck`: si hay un proceso
  `pacman` en marcha el bloqueo es legítimo (avisa y marca el sistema como no
  seguro); si es un bloqueo obsoleto ofrece quitarlo.
- **Devuelve:** `0` si es seguro actualizar, `1` si no.

### `fix_update`
- **Firma:** `fix_update`
- **Qué hace:** la actualización segura — ejecuta `fix_preupdate` y, solo si
  pasa, ofrece ejecutar `sudo pacman -Syu`.

---

## Arreglo: reparar arranque y limpiar kernels

### `fix_repair_boot`
- **Firma:** `fix_repair_boot`
- **Qué hace:** repara un arranque roto tras un lío de kernels. Requiere `/boot`
  montado (`check_boot`), lista los huérfanos (`orphan_modules`) y — tras
  confirmar — elimina cada `/usr/lib/modules/<ver>` (protegiendo el kernel en
  uso), y luego ejecuta `depmod` por cada kernel restante, `dkms autoinstall` (si
  DKMS está presente) y `mkinitcpio -P`.
- **Notas:** borrado protegido (`${moddir:?}` más una re-comprobación de que la
  versión no es la del kernel en uso).

### `fix_clean_kernels`
- **Firma:** `fix_clean_kernels`
- **Qué hace:** la limpieza ligera. Lista las carpetas de módulos huérfanas con
  su tamaño (`du -sh`) y — con confirmación por defecto **No** — las elimina
  todas (kernel en uso protegido), y luego refresca `depmod` del kernel en uso.
  **No** recompila DKMS ni initramfs (eso es cosa de `repair-boot`).

---

## Estado

### `status`
- **Firma:** `status`
- **Qué hace:** imprime el estado actual sin cambiar nada: distribución de
  teclado (sistema + Xwayland), Bloq Num (KDE), teclas Fn (si `hid_apple` está
  presente), WiFi (interfaz, driver, power-save y — para rtw88 — los parámetros
  del módulo), si `/boot` está montado, y el número de carpetas de módulos de
  kernel huérfanas.
