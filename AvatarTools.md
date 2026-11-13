# Avatar Tools

Conector independiente para módulos de skins y accesorios. No necesita el script principal ni modifica su interfaz.

## Carga conjunta

```lua
local AvatarTools = loadstring(game:HttpGet("https://raw.githubusercontent.com/Silent-lua/Dev/main/AvatarTools.lua"))()
```

Abre los paneles desde otro script:

```lua
AvatarTools.OpenSkins()
AvatarTools.OpenAccessories()
```

Oculta o vuelve a mostrar ambos paneles:

```lua
AvatarTools.SetEnabled(false)
AvatarTools.SetEnabled(true)
```

Limpia los módulos y sus conexiones:

```lua
AvatarTools.Cleanup()
```

## Animaciones de skins

- **On:** reproduce las animaciones de la skin en un rig visual local, dentro de la cámara del cliente. El `Animator` se crea en ese rig local y el módulo no reemplaza ni modifica el `Animate` del personaje real.
- **Off:** detiene las pistas locales y vuelve a seguir la pose producida por las animaciones originales del personaje.
- Los demás jugadores siguen viendo el personaje real con sus animaciones normales. El rig cosmético y las animaciones `On` solo se muestran en el cliente local.

La [documentación oficial de Roblox sobre `Animator`](https://create.roblox.com/docs/reference/engine/classes/Animator) indica que un `Animator` creado localmente no replica sus `AnimationTrack` al servidor. Este módulo utiliza ese comportamiento sobre un modelo visual separado del `Player.Character`.

## Fondo

El panel usa el PNG proporcionado, alojado en `assets/avatar-background.png`. Se descarga a `avatar-tools/avatar-background.png`; la imagen se muestra completa mediante `ScaleType.Fit`, sin recortar ni oscurecer, y tiene una transición sutil al abrir el panel.

## Carga individual

Los módulos también pueden cargarse por separado. La tabla compartida coordina la composición de skins y accesorios:

```lua
local bridge = {}
local Skins = loadstring(game:HttpGet("https://raw.githubusercontent.com/Silent-lua/Dev/main/AvatarSkins.lua"))(bridge)
local Accessories = loadstring(game:HttpGet("https://raw.githubusercontent.com/Silent-lua/Dev/main/AvatarAccessories.lua"))(bridge)
```

## Requisitos

La carga remota necesita `game:HttpGet` y `loadstring`. La interfaz intenta usar `gethui` y `getcustomasset`; si esas funciones no están disponibles, aplica los fallbacks implementados y puede mostrarse sin el fondo local.