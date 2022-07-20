# Linux - tmux

TAGS:

- [Linux](Linux.md)

SOURCES:

- [Tmux Cheat Sheet & Quick Reference](https://tmuxcheatsheet.com/)
- [tmux(1): terminal multiplexer](https://linux.die.net/man/1/tmux)
- [tmux](https://hpc.nmsu.edu/discovery/tutorials/tmux/)
- [How to Use tmux on Linux (and Why It's Better Than Screen)](https://www.howtogeek.com/671422/how-to-use-tmux-on-linux-and-why-its-better-than-screen/)

RELATED:

- [Linux - screen](Linux-screen.md)

---

## Sesión

### Iniciar sesión

Iniciar una sesión de tmux

```shell
tmux
```

Iniciar una sesión de tmux con nombre

```shell
tmux new -s session_name
```

### Desconectarse

Desconectarse de la sesión actual (detach)

`Ctrl+b` `d` Desconectarse de la sesión actual

o alternativamente

```shell
tmux detach
```

### Listar sesiones

Listar sesiones de tmux

`Ctrl+b` `$` Listar sesiones de tmux

o alternativamente

```shell
tmux ls
```

### Reconectarse

Conectarse a la sesión más recientemente utilizada (resume)

```shell
tmux a
tmux at
tmux attach
```

Conectarse a una sesión particular

```shell
tmux a -t session_name
tmux at -t session_name
tmux attach -t session_name
```

### Renombrar sesión

`Ctrl+b` `$` Renombrar la sesión actual

### Cambiar de sesión

- `Ctrl+b` `(` Cambiar a la sesión previa
- `Ctrl+b` `)` Cambiar a la sesión posterior

### Finalizar sesión

Finalizar una sesión de tmux puede hacerse cerrando cada shell iniciado estando dentro de la misma

`Ctrl+d` Salir del shell

o alternativamente

```shell
exit
```

Finalizar la sesión más recientemente utilizada (también finaliza la sesión actual estando dentro de la misma)

```shell
tmux kill-session
```

Finalizar una sesión de tmux con nombre

```shell
tmux kill-session -t session_name
```

Finalizar todas las sesiones excepto la más recientemente utilizada (sería la sesión actual estando dentro de la misma)

```shell
tmux kill-session -a
```

Finalizar todas las sesiones excepto la indicada

```shell
tmux kill-session -a -t session_name
```

## Ventana

Con el inicio de una sesión se crea una nueva ventana y se inicia un shell.

Para iniciar una sesión con nombre y una ventana con nombre

```shell
tmux new -s session_name -n window_name
```

Las ventanas se listan en la parte inferior, a la derecha de la sesión

- `Ctrl+b` `c` Crear una nueva ventana (con shell)
    - Se asigna un número según la disponibilidad, entre 0 y 9
- `Ctrl+b` `p` Cambiar a la ventana previa
- `Ctrl+b` `n` Cambiar a la ventana posterior
- `Ctrl+b` `0`..`9` Cambiar a la ventana indicada
- `Ctrl+b` `,` Renombrar la ventana actual
- `Ctrl+b` `&` Finalizar la ventana actual
    - `Ctrl+d` Salir del shell (cierra la ventana)

Comandos

- : `swap-window -s 2 -t 1` Mover la ventana 2(src) a 1(dst)
- : `swap-window -t -1` Mover la ventana actual una posición a la izquierda

## Panel

- `Ctrl+b` `%` Dividir (split) el panel actual horizontalmente
- `Ctrl+b` `"` Dividir el panel actual verticalmente

- `Ctrl+b` `;` Alternar el foco entre el panel actual y el más reciente
- Cambiar el foco al panel ubicado en esa dirección
    - `Ctrl+b` `↑`
    - `Ctrl+b` `↓`
    - `Ctrl+b` `←`
    - `Ctrl+b` `→` 
- `Ctrl+b` `o` Cambiar el foco al siguiente panel
- `Ctrl+b` `q` Mostrar el número de cada panel
- `Ctrl+b` `q` `0`..`9` Cambiar el foco al panel indicado
- `Ctrl+b` `z` Activar/Desactivar el zoom al panel actual

- `Ctrl+b` `!` Convertir el panel actual en una ventana

- `Ctrl+b` `{` Mover el panel actual a la izquierda
- `Ctrl+b` `}` Mover el panel actual a la derecha
- `Ctrl+b` `spacebar` Alternar entre distintos layouts de paneles

- Redimensionar el alto/ancho del panel actual en la dirección indicada
    - `Ctrl+b+↑` o `Ctrl+b` `Ctrl+↑`
    - `Ctrl+b+↓` o `Ctrl+b` `Ctrl+↓`
    - `Ctrl+b+←` o `Ctrl+b` `Ctrl+←`
    - `Ctrl+b+→` o `Ctrl+b` `Ctrl+→`

- `Ctrl+b` `x` Cerrar el panel actual

Comandos

- : `setw synchronize-panes` Activar/Desactivar la sincronización de paneles (el comando se envía a todos ellos)

## Modo comando

`Ctrl+b` `:` Acceder al modo comando

- : `set -g OPTION` Establecer OPTION para todas las sesiones
- : `setw -g OPTION` Establecer OPTION para todas las ventanas
- : `set mouse on` Establecer el modo mouse

## Tools

- [tmuxinator/tmuxinator: Manage complex tmux sessions easily](https://github.com/tmuxinator/tmuxinator)
