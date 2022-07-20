# Linux - screen

TAGS:

- [Linux](Linux.md)

SOURCES:

- [How To Use Linux ScreenLinuxize](https://linuxize.com/post/how-to-use-linux-screen/)
- [How to Use Linux's screen Command](https://www.howtogeek.com/662422/how-to-use-linuxs-screen-command/)

RELATED:

- [Linux - tmux](Linux-tmux.md)


---

## Sesión

### Iniciar sesión

Iniciar una sesión de screen

```shell
screen
```

Iniciar una sesión de screen con nombre

```shell
screen -S session_name
```

Iniciar una sesión de screen `-m` (forced) y `-d` (detached)

```shell
screen -d -m
screen -d -m -S session_name
```

### Desconectarse

Desconectarse de la sesión actual (detach)

`Ctrl+a` `d` Desconectarse de la sesión actual

o alternativamente

```shell
screen -d
```

### Listar sesiones

Listar sesiones de screen

```shell
screen -ls
```

### Reconectarse

Conectarse a la sesión más recientemente utilizada (resume)

```shell
screen -r
```

Conectarse a una sesión particular

```shell
screen -r session_name
```

Compartir una sesión de screen: conectarse a una sesión particular con `-x` (multiscreen mode)

```shell
screen -x session_name
```

### Finalizar sesión

Finalizar una sesión de screen requiere cerrar cada shell iniciado dentro de la misma

`Ctrl+d` Salir del shell

o alternativamente

```shell
exit
```

## Ventana

Con el inicio de una sesión se crea una nueva ventana y se inicia un shell.

- `Ctrl+a` `c` Crear una nueva ventana (con shell)
    - Se asigna un número según la disponibilidad, entre 0 y 9
- `Ctrl+a` `Ctrl+a` Alternar entre la ventana actual y la más reciente
- `Ctrl+a` `0`..`9` Cambiar a la ventana indicada
- `Ctrl+a` `A` Renombrar la ventana actual
- `Ctrl+a` `K` Finalizar la ventana actual
- `Ctrl+a` `"` Listar ventanas

## Región

Al crearse una ventana, se establece una región

- `Ctrl+a` `S` Dividir (split) la región actual horizontalmente
- `Ctrl+a` `|` Dividir la región actual verticalmente
- `Ctrl+a` `tab` Cambiar el foco a la siguiente región
- `Ctrl+a` `Q` Cerrar todas las regiones a excepción de la actual
- `Ctrl+a` `X` Cerrar la región actual
