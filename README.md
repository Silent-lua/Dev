# SnowX Armas Visual — By Fabnx1

Módulo independiente de Luau para explorar y aplicar visuales de armas y efectos disponibles en la experiencia de Roblox actual.

## Archivo

- `SnowX-Armas.lua` — interfaz y sistema visual de armas.

Este módulo se ejecuta de forma independiente y no depende de otros módulos del repositorio.

## Funciones

- Escaneo de los elementos disponibles en la experiencia actual.
- Clasificación en **Cuchillos**, **Pistolas** y **Efectos**.
- Búsqueda por nombre y selección de resultados.
- Vista previa visual, incluida vista 3D cuando el elemento permite construirla.
- Aplicar y retirar visuales de cuchillos y pistolas.
- Mover una entrada entre las categorías Cuchillos y Pistolas cuando la clasificación automática no corresponde.
- Seleccionar y retirar Kill Effects detectados por el escaneo.

La detección depende de los objetos, modelos, atributos y estructuras que exponga cada experiencia. Por ello, los resultados pueden variar entre juegos.

## Interfaz

La interfaz utiliza el formato visual de SnowX:

- Panel base de **590 × 274 px**, centrado al iniciar.
- Fondo compartido **Slow2.jpg**.
- Paleta oscura en grises, encabezado SnowX y bordes redondeados.
- Escala adaptable al tamaño de la pantalla.
- Botón flotante **Open Armas**, ubicado inicialmente en el lado derecho y visible también cuando el panel está abierto.
- Arrastre separado para mouse y pantalla táctil, con límites en los cuatro bordes.

## Uso

Ejecuta el siguiente código desde el cliente de Roblox mediante un entorno que permita descargar y ejecutar Luau:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Silent-lua/Dev/main/SnowX-Armas.lua"))()
```

## Controles

1. Selecciona **Cuchillos**, **Pistolas** o **Efectos**.
2. Selecciona una tarjeta de la lista. También puedes buscar por nombre.
3. Usa **Aplicar skin** para aplicar la entrada seleccionada.
4. Usa **Quitar skin** para retirar la apariencia aplicada o limpiar el Kill Effect activo.
5. En Cuchillos/Pistolas, el botón de cambio de categoría permite corregir una clasificación.

## Requisitos y compatibilidad

El script está diseñado para ejecutarse en el cliente local de Roblox. Necesita un entorno que permita `loadstring`, `game:HttpGet` y las operaciones de instancias utilizadas por el juego.

Algunas capacidades del executor son opcionales:

- `gethui` para ubicar la interfaz; existe fallback a CoreGui y PlayerGui.
- `getgenv` para conservar estado de categoría entre ejecuciones; existe fallback a `_G`.
- `isfolder`, `makefolder`, `isfile`, `writefile` y `getcustomasset` para descargar y cargar el fondo local. Sin ellas, la interfaz puede funcionar sin esa imagen.

La compatibilidad concreta depende del executor y de la estructura de cada experiencia. El soporte de controles táctiles está implementado, pero no se ha validado en ejecución dentro de Roblox o Android en esta entrega.

## Repositorio

https://github.com/Silent-lua/Dev
