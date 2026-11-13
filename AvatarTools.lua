local BASE_URL = "https://raw.githubusercontent.com/Silent-lua/Dev/main/"
local bridge = ...

if type(bridge) ~= "table" then
    bridge = {}
end

local function loadModule(fileName)
    local source = game:HttpGet(BASE_URL .. fileName)
    local chunk, compileError = loadstring(source)

    if type(chunk) ~= "function" then
        error(tostring(compileError or "No se pudo compilar el módulo " .. fileName), 0)
    end

    return chunk(bridge)
end

local skins
local accessories

local skinsOk, skinsResult = pcall(function()
    return loadModule("AvatarSkins.lua")
end)

if not skinsOk then
    error("No se pudo iniciar el módulo de apariencias: " .. tostring(skinsResult), 0)
end

skins = skinsResult

local accessoriesOk, accessoriesResult = pcall(function()
    return loadModule("AvatarAccessories.lua")
end)

if not accessoriesOk then
    if skins and type(skins.destroy) == "function" then
        pcall(skins.destroy)
    end
    error("No se pudo iniciar el módulo de accesorios: " .. tostring(accessoriesResult), 0)
end

accessories = accessoriesResult

if skins and type(skins.setEnabled) == "function" then
    skins.setEnabled(true)
end

if accessories and type(accessories.SetEnabled) == "function" then
    accessories.SetEnabled(true)
end

local connector = {
    Skins = skins,
    Accessories = accessories,
    Bridge = bridge,
}

function connector.OpenSkins()
    if not skins or type(skins.open) ~= "function" then
        return false
    end
    return skins.open()
end

function connector.OpenAccessories()
    if not accessories or type(accessories.Open) ~= "function" then
        return false
    end
    return accessories.Open()
end

function connector.SetEnabled(enabled)
    local skinsResult = true
    local accessoriesResult = true

    if skins and type(skins.setEnabled) == "function" then
        skinsResult = skins.setEnabled(enabled == true)
    end

    if accessories and type(accessories.SetEnabled) == "function" then
        accessoriesResult = accessories.SetEnabled(enabled == true)
    end

    return skinsResult == true and accessoriesResult == true
end

function connector.Cleanup()
    local success = true

    if skins and type(skins.destroy) == "function" then
        local ok = pcall(skins.destroy)
        success = success and ok
    end

    if accessories and type(accessories.Cleanup) == "function" then
        local ok = pcall(accessories.Cleanup)
        success = success and ok
    end

    return success
end

connector.Destroy = connector.Cleanup

return connector