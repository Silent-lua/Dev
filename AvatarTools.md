# Avatar Tools

Conector independiente para los módulos de apariencias de jugadores y accesorios. No necesita el script principal ni modifica su interfaz.

## Carga conjunta

```lua
local AvatarTools = loadstring(game:HttpGet("https://raw.githubusercontent.com/Silent-lua/Dev/main/AvatarTools.lua"))()
```

La carga crea ambos paneles y muestra sus botones flotantes. Para abrirlos desde otro script:

```lua
AvatarTools.OpenSkins()
AvatarTools.OpenAccessories()
```

Para ocultar o volver a mostrar los dos paneles:

```lua
AvatarTools.SetEnabled(false)
AvatarTools.SetEnabled(true)
```

Para retirar los módulos y sus conexiones:

```lua
AvatarTools.Cleanup()
```

## Carga individual

Los módulos también pueden cargarse por separado. Cada uno devuelve su propia API y acepta opcionalmente una tabla compartida para coordinarse con el otro módulo.

```lua
local bridge = {}
local Skins = loadstring(game:HttpGet("https://raw.githubusercontent.com/Silent-lua/Dev/main/AvatarSkins.lua"))(bridge)
local Accessories = loadstring(game:HttpGet("https://raw.githubusercontent.com/Silent-lua/Dev/main/AvatarAccessories.lua"))(bridge)
```

## Requisitos

La carga remota necesita `game:HttpGet` y `loadstring`. La interfaz intenta usar `gethui` y `getcustomasset`; si no están disponibles, utiliza las alternativas implementadas en cada módulo y puede mostrarse sin la imagen de fondo.

El fondo se descarga desde `assets/avatar-background.jpg` del mismo repositorio y se guarda en `avatar-tools/avatar-background.jpg` cuando `writefile` está disponible.