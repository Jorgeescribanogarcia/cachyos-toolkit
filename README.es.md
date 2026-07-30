# CachyOS Toolkit

[English](README.md) · **Español** · [Advanced docs](docs/en/) · [Documentación avanzada](docs/es/)

Herramientas de configuración para CachyOS. Portable: usa rutas relativas
(`$HOME`, `/etc`) y no depende de ninguna máquina concreta.

## Scripts (`bin/`)

### `cachyos-assistant`
Asistente interactivo por menús. Ejecútalo sin argumentos:

```bash
cachyos-assistant
```

Muévete con las **flechas del teclado** (↑/↓ mover, Enter elegir, Espacio marca
elementos en los menús de instalación multi-selección, `q`/Esc volver) — o
simplemente teclea el número/letra como atajo. En el primer arranque pregunta el
idioma y el modo de navegación; ambos se pueden cambiar luego (idioma y
*Configuración › Modo de navegación*). El modo *números* clásico sirve también de
respaldo para terminales donde las flechas fallen.

Secciones:
- **Instalar aplicaciones** — por categoría. Prefiere los paquetes
  **optimizados para CachyOS** (repos `x86-64-v3/v4`; para juegos usa
  `cachyos-gaming-meta`, `wine-cachyos`, `proton-cachyos`).
  - *Juegos* (completo).
  - *Desarrollo*: **Packs** completos por stack (Web, Java, Rust, Python, Go,
    C/C++, .NET, Contenedores, XAMPP) e **instalación individual** por tipo
    (Editores/IDEs, Lenguajes, Bases de datos, Herramientas/DevOps).
  - *Multimedia* (reproducción: VLC, MPV, Spotify, FFmpeg).
  - *Streaming y VTubing*: OBS Studio, el cliente de itch.io (para instalar
    veadotube-mini), Inochi Session/Creator, Chatterino, Streamlink.
  - *Edición* (vídeo, foto, audio): DaVinci Resolve, Kdenlive, Shotcut,
    OpenShot, Blender, GIMP, Krita, Inkscape, darktable, Audacity…
  - *Ofimática*, *Internet* y *Sistema y utilidades*.
  - Al seleccionar una app ofrece «Instalar ahora», «Desinstalar» o «Añadir a la lista».
  - **Lista de instalación**: acumula apps de varias categorías en una
    selección y luego **instala todo** o **desinstala todo** de una vez (con
    opciones de quitar un elemento o vaciarla).
- **Configuración** — arreglos y ajustes por categoría (Red, Teclado,
  Mirrors y paquetes), un selector de **navegador web predeterminado** (detecta
  los navegadores instalados y fija el predeterminado con `xdg-settings`), y
  **Actualizaciones y mantenimiento** (chequeo previo a actualizar, actualización
  segura, reparación de arranque/kernel y limpieza de kernels obsoletos). Usa
  `cachyos-fix` como motor de los arreglos.
- **Servicios** — un gestor de servicios/sesión construido **dinámicamente**
  desde systemd (nada cableado). Abarca tanto el gestor del **sistema** (las
  acciones usan `sudo`) como la **sesión de usuario** (`systemctl --user`, sin
  `sudo`), con filtros:
  - *apps* (por defecto) — las aplicaciones lanzadas en esta sesión (Discord,
    Steam, Brave…), con su nombre bonito; corren como unidades de usuario `app-*`.
  - *en marcha* / *autoarranque* / *con error* / *todos* — servicios del sistema.
  - *del sistema* — servicios de bajo nivel del SO (las unidades propias de
    systemd, `dbus`, `polkit`, unidades de plantilla…), ocultos en los otros filtros.

  Puedes encender/apagar entradas, reiniciarlas y configurar el arranque
  automático; cada una muestra su estado en vivo. También puedes escribir
  cualquier unidad por nombre. XAMPP es un caso especial: como puede correr fuera
  de systemd (con su propio script `/opt/lampp`), su estado se lee de los procesos
  reales y se enciende/apaga con ese script, mientras que el autoarranque se
  configura mediante una unidad de systemd generada.
- **Estado del sistema**.

Detecta automáticamente `paru`/`yay`/`pacman`.

### `cachyos-fix`
Motor de arreglos, idempotente. Uso directo:

```bash
cachyos-fix [all|keyboard|numlock|fnkeys|wifi|mirrors|preupdate|update|repair-boot|status]
```

(Los alias en español siguen valiendo: `teclado`, `estado`, `mirror`.)

- **keyboard** — fuerza la distribución `es` en apps X11/Xwayland (producía `@`
  con Mayús+2 al caer en `us`). Acepta un código de distribución
  (`cachyos-fix keyboard fr`). Autostart en `~/.config/autostart/`.
- **numlock** `[on|off|unchanged]` — fija el comportamiento del teclado numérico
  al iniciar sesión (KDE) y lo aplica en caliente con `numlockx`. `on` (por
  defecto) lo mantiene encendido, `off` apagado, `unchanged` lo deja al
  firmware/último estado.
- **fnkeys** `[fkeys|media|auto]` — fija el comportamiento de la fila Fn / F1–F12
  mediante el `fnmode` de `hid_apple` (persistente + en caliente). Solo aplica a
  teclados que usan ese driver (Apple/«Magic» y algunos otros); en la mayoría de
  portátiles el Fn lo controla la BIOS/firmware, y el arreglo lo avisa en vez de
  cambiar nada.
- **wifi** — desactiva el ahorro de energía en el driver `rtw88` (RTL8822BE),
  causa de las desconexiones (BEACON-LOSS). Escribe en `/etc/…`, regenera el
  initramfs y recarga el driver solo cuando hace falta.
- **mirrors** — reordena la lista de mirrors (`cachyos-rate-mirrors`, con
  `rate-mirrors`/`reflector` como respaldo) y fuerza `pacman -Syy`. Soluciona los
  errores 404 al actualizar cuando los mirrors están desincronizados.
- **preupdate** — chequeo de seguridad previo a actualizar: asegura que `/boot`
  esté montado (lo monta si `fstab` lo espera, si no aborta) y limpia un `db.lck`
  obsoleto (solo si no hay `pacman` en ejecución). Evita el desfase kernel/módulos
  y errores de bloqueo.
- **update** — actualización segura: ejecuta `preupdate` y, si pasa, `pacman -Syu`.
- **repair-boot** — repara un arranque roto tras un lío de kernels: elimina las
  carpetas huérfanas `/usr/lib/modules/<ver>` de kernels ya no instalados (el
  kernel en uso queda protegido; la propiedad se comprueba con `pacman -Ql`, no
  con el `pacman -Qo` que canonicaliza rutas), y luego ejecuta `depmod`,
  `dkms autoinstall` y `mkinitcpio -P`.
- **clean-kernels** — limpieza ligera: lista las carpetas obsoletas de
  `/usr/lib/modules` (con su tamaño) y las elimina todas (kernel en uso
  protegido), refrescando solo `depmod`. No recompila DKMS/initramfs.

## Instalación

Descarga el instalador de la [última release](../../releases/latest) y ejecútalo
(un menú pequeño con **Instalar** / **Desinstalar**):

```bash
curl -fsSL https://github.com/Jorgeescribanogarcia/cachyos-toolkit/releases/latest/download/install.sh -o install.sh
bash install.sh
```

**Instalar** descarga el toolkit en `~/.local/share/cachyos-toolkit` (un clon
git), y registra un comando `cachyos-toolkit` en `~/.local/bin` más un lanzador
de aplicación, para que aparezca en el menú de aplicaciones / KRunner
(Alt+Espacio) como **CachyOS Toolkit** y se abra en una terminal. Todo a nivel de
usuario (sin root). **Desinstalar** lo quita todo, incluida la carpeta descargada.

Como la instalación es un clon git, en cada arranque el asistente comprueba en
silencio si hay una versión nueva y ofrece actualizar (`git pull`) — manteniendo
el comando y el lanzador al día. También hay un *Buscar actualizaciones* manual
en la pantalla *Instalar esta herramienta como app* del menú principal. Define
`CACHYOS_NO_UPDATE_CHECK=1` para saltarte la comprobación automática.

### Manual / desde un clon

También puedes clonar y ejecutar, y luego usar **Instalar esta herramienta como
app** desde el menú principal para registrar el clon actual:

```bash
git clone https://github.com/Jorgeescribanogarcia/cachyos-toolkit.git
./cachyos-toolkit/bin/cachyos-assistant
```

Ninguno de los scripts debe ejecutarse como root; piden `sudo` cuando lo necesitan.
