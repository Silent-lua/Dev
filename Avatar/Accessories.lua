



local MODULE_NAME = "accessories"
local MODULE_URL = "https://raw.githubusercontent.com/Silent-lua/Dev/2ed0e0a385af0790d5cd8d5ebb24f0ea659aa1c1/SilentHub-Accesorios.lua"

local function getRuntimeEnvironment()
    if type(getgenv) == "function" then
        local ok, environment = pcall(getgenv)
        if ok and type(environment) == "table" then
            return environment
        end
    end
    return _G
end

local runtimeEnvironment = getRuntimeEnvironment()



local bimoHost = runtimeEnvironment.AvatarTools
if bimoHost ~= nil then
    if type(bimoHost) ~= "table"
        or type(bimoHost.Bridge) ~= "table"
        or type(bimoHost.SetModuleEnabled) ~= "function" then
        error("[SilentHub] Bimo detectado, pero no expone el contrato de avatar compatible. Actualiza Bimo.", 0)
    end

    local callOk, enabled, loadError = pcall(
        bimoHost.SetModuleEnabled,
        MODULE_NAME,
        true
    )
    if not callOk or enabled ~= true then
        error("[SilentHub] Bimo no pudo activar " .. MODULE_NAME .. ": " .. tostring(loadError or enabled), 0)
    end
    return bimoHost
end


local bridge = runtimeEnvironment.UniversalAvatarBridge
if type(bridge) ~= "table" then
    bridge = {
        version = 2,
        skin = {},
        accessory = {},
        uiPanels = { activePanel = "none" },
        modules = {},
        loading = {},
    }
    runtimeEnvironment.UniversalAvatarBridge = bridge
end

bridge.version = 2
bridge.skin = type(bridge.skin) == "table" and bridge.skin or {}
bridge.accessory = type(bridge.accessory) == "table" and bridge.accessory or {}
bridge.uiPanels = type(bridge.uiPanels) == "table" and bridge.uiPanels or { activePanel = "none" }
bridge.modules = type(bridge.modules) == "table" and bridge.modules or {}
bridge.loading = type(bridge.loading) == "table" and bridge.loading or {}



if type(bridge.notify) ~= "function" then
    local StarterGui = game:GetService("StarterGui")
    bridge.notify = function(config)
        config = type(config) == "table" and config or { content = tostring(config or "") }
        local title = tostring(config.title or config.Title or "SilentHub")
        local content = tostring(config.subtitle or config.content or config.Text or "")
        local duration = math.clamp(tonumber(config.duration or config.Duration) or 4, 1, 15)

        task.spawn(function()
            for _ = 1, 5 do
                local notified = pcall(function()
                    StarterGui:SetCore("SendNotification", {
                        Title = title,
                        Text = content,
                        Duration = duration,
                    })
                end)
                if notified then return end
                task.wait(0.4)
            end
            warn("[SilentHub] No se pudo mostrar la notificación nativa.")
        end)
        return true
    end
end

if bridge.loading[MODULE_NAME] then
    error("[SilentHub] " .. MODULE_NAME .. " ya se está cargando.", 0)
end
bridge.loading[MODULE_NAME] = true
pcall(bridge.notify, {
    title = "SilentHub",
    content = "Cargando Accesorios...",
    duration = 3,
})

local api
local function cleanupApi(moduleApi)
    if type(moduleApi) ~= "table" then return true end
    local cleanup = moduleApi.Cleanup
    if type(cleanup) ~= "function" then
        return false, "Cleanup no disponible"
    end

    local ok, cleanupResult = pcall(cleanup)
    if not ok or cleanupResult == false then
        return false, tostring(cleanupResult)
    end
    return true
end

local runOk, runResult = pcall(function()
    
    local previousApi = bridge.modules[MODULE_NAME]
    if previousApi then
        local cleanupOk, cleanupError = cleanupApi(previousApi)
        if not cleanupOk then
            error("No se pudo limpiar la instancia anterior: " .. tostring(cleanupError), 0)
        end
        bridge.modules[MODULE_NAME] = nil
    end

    local httpOk, source = pcall(function()
        return game:HttpGet(MODULE_URL)
    end)
    if not httpOk or type(source) ~= "string" or source == "" then
        error("No se pudo descargar SilentHub-Accesorios.lua: " .. tostring(source), 0)
    end

    local compiler = loadstring
    if type(compiler) ~= "function" and type(runtimeEnvironment.loadstring) == "function" then
        compiler = runtimeEnvironment.loadstring
    end
    if type(compiler) ~= "function" then
        error("El executor no proporciona loadstring.", 0)
    end

    local compiled, compileError = compiler(source)
    if type(compiled) ~= "function" then
        error("No se pudo compilar SilentHub-Accesorios.lua: " .. tostring(compileError), 0)
    end

    local apiOk, moduleApi = pcall(compiled, bridge)
    if not apiOk or type(moduleApi) ~= "table" then
        error("No se pudo iniciar SilentHub-Accesorios.lua: " .. tostring(moduleApi), 0)
    end
    api = moduleApi

    local setter = api.SetEnabled
    if type(setter) ~= "function" then
        error("SilentHub-Accesorios.lua no expone SetEnabled.", 0)
    end

    local enableOk, enableResult = pcall(setter, true)
    if not enableOk or enableResult == false then
        error("No se pudo activar SilentHub-Accesorios.lua: " .. tostring(enableResult), 0)
    end

    bridge.modules[MODULE_NAME] = api
    return api
end)

bridge.loading[MODULE_NAME] = nil
if not runOk then
    pcall(bridge.notify, {
        title = "SilentHub · Error",
        content = tostring(runResult),
        duration = 6,
    })
    if api then
        local cleanupOk = cleanupApi(api)
        if cleanupOk then
            bridge.modules[MODULE_NAME] = nil
        else
            bridge.modules[MODULE_NAME] = api
        end
    end
    error("[SilentHub] " .. tostring(runResult), 0)
end

return runResult
