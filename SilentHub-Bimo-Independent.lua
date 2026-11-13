if not game:IsLoaded() then
    game.Loaded:Wait()
end

if game.GameId ~= 9582119606 then
    game:GetService("Players").LocalPlayer:Kick(
        "SilentHub: this script is for Bimo only"
    )
    return
end

local SourceZones = {
    Core = {},
    Match = {},
    Player = { Lifecycle = {}, Movement = {} },
    Environment = { Skybox = {} },
    Shooting = { Weapons = {}, Macro = {}, Trigger = {} },
    Combat = { Targeting = {}, FOV = {} },
    ESP = { Validation = {}, Arrows = {}, Rendering = {}, Lifecycle = {} },
    Graphics = { Performance = {}, SmartRender = {} },
    Runtime = { IO = {}, Loader = {}, Library = {}, Avatar = {} },
    Configuration = { Persistence = {}, Controls = {} },
    UI = { Configuration = {}, Execution = {}, Builders = {} },
}

local AvatarIntegration = {
    Bridge = { version = 2, skin = {}, accessory = {}, uiPanels = {} },
    Skins = nil,
    Accessories = nil,
    SkinsEnabled = false,
    AccessoriesEnabled = false,
    SkinsLoading = false,
    AccessoriesLoading = false,
    SkinsControl = nil,
    AccessoriesControl = nil,
    Generation = 0,
}

AvatarIntegration.Cleanup = function()
    AvatarIntegration.Generation += 1
    AvatarIntegration.SkinsEnabled = false
    AvatarIntegration.AccessoriesEnabled = false
    AvatarIntegration.SkinsLoading = false
    AvatarIntegration.AccessoriesLoading = false
    AvatarIntegration.SkinsControl = nil
    AvatarIntegration.AccessoriesControl = nil

    local accessories = AvatarIntegration.Accessories
    AvatarIntegration.Accessories = nil
    if accessories and type(accessories.Cleanup) == "function" then
        pcall(accessories.Cleanup)
    end

    local skins = AvatarIntegration.Skins
    AvatarIntegration.Skins = nil
    if skins and type(skins.destroy) == "function" then
        pcall(skins.destroy)
    end

    AvatarIntegration.Bridge = { version = 2, skin = {}, accessory = {}, uiPanels = {} }
    if getgenv().SilentHubAvatarTools == AvatarIntegration then
        getgenv().SilentHubAvatarTools = nil
    end
end

local rconsoleprint = function() end
local rconsolewarn = function() end
local rconsoleinfo = function() end
local rconsoleerr = function() end
local setclipboard = function() end
local toclipboard = function() end

local hookfunction = hookfunction or hookfunc or getgenv().hookfunction

local ContainerManager = { ExternalReferences = {} }
local _CoreGui = game:GetService("CoreGui")
local ROOT_HASH = "6c665649dabe5153604d0f1d3e84d4cbdf09980da9ecc8b56df1fb9eb5968a58"

local generateExecutionHash
SourceZones.Core.generateExecutionHash = function()
    local hexChars = "0123456789abcdef"
    local hash = ""
    math.randomseed(os.clock() % 1 * 1e5 + math.random(1, 100000))
    for i = 1, 64 do
        local rand = math.random(1, 16)
        hash = hash .. string.sub(hexChars, rand, rand)
    end
    return hash
end
generateExecutionHash = SourceZones.Core.generateExecutionHash

local initializeContainers
SourceZones.Core.initializeContainers = function()
    local rootFolder = _CoreGui:FindFirstChild(ROOT_HASH)
    if not rootFolder then
        rootFolder = Instance.new("Folder")
        rootFolder.Name = ROOT_HASH
        pcall(function() rootFolder.Parent = _CoreGui end)
    end

    local executionHash = generateExecutionHash()
    local executionFolder = Instance.new("Folder")
    executionFolder.Name = executionHash
    executionFolder.Parent = rootFolder

    local subCategories = {
        "GUI", "ESP", "Runtime", "Pools", 
        "Drawings", "Cache", "Temporary", "Effects", 
        "Debug", "Notifications", "Resources", "Config"
    }
    local containers = {}
    for _, category in ipairs(subCategories) do
        local subFolder = Instance.new("Folder")
        subFolder.Name = category
        subFolder.Parent = executionFolder
        containers[category] = subFolder
    end
    return rootFolder, executionFolder, containers
end
initializeContainers = SourceZones.Core.initializeContainers

local Root, ExecutionFolder, SubContainers = initializeContainers()

function ContainerManager.new(className, category)
    local instance = Instance.new(className)
    if category and SubContainers[category] then
        instance.Parent = SubContainers[category]
    end
    return instance
end

function ContainerManager.RegisterExternal(instance)
    if instance then table.insert(ContainerManager.ExternalReferences, instance) end
    return instance
end

function ContainerManager.Cleanup()
    for _, instance in ipairs(ContainerManager.ExternalReferences) do
        if instance and instance.Parent then pcall(function() instance:Destroy() end) end
    end
    table.clear(ContainerManager.ExternalReferences)
    if ExecutionFolder and ExecutionFolder.Parent then pcall(function() ExecutionFolder:Destroy() end) end
end

if getgenv().SilentHubCleanup then
    pcall(getgenv().SilentHubCleanup)
    task.wait(0.1)
end

getgenv().SilentHubAvatarTools = AvatarIntegration

local Silent = {
    State = {
        MatchActive = false, IsPlaying = false,
        Macro = { Active = false, KnifeThrowActive = false, EquipDelay = 0.01, ShootDelay = 0.01, Busy = false, Generation = 0, TouchInputs = {} },
        Aim = { SilentAim = false, AutoShoot = false, TriggerBot = false, TriggerBotLegit = false, TriggerDetectionLevel = 2, TriggerDetectionInterval = 0.03, TriggerDetectionLastScanAt = 0, TriggerPistolBusy = false, TriggerPistolGeneration = 0, TriggerPistolRetryAt = 0, TriggerPistolWarnedReload = false, TriggerKnifeBusy = false, TriggerKnifeGeneration = 0, TriggerKnifeRetryAt = 0, TriggerLastKnifeTarget = nil, Mode = "FOV", TargetPart = "Cabeza", HitChance = 100, FovVisible = false, FovRadius = 100, ThrowMode = false },
        Vis = { HideName = false, ESP = false, Color = Color3.fromRGB(255, 0, 0), Glow = true, Name = false, Dist = false, Lines = false, Arrows = false },
        Gfx = { BoostFps = false, Low = false, SmartRender = false, RenderDist = 500 },
        UI = { ShowStats = false },
        Spoof = { Device = "PC" }
    },
    Config = {
        Colors = {
            Bg = Color3.fromHex("#0a0a10"),
            Stroke = Color3.fromHex("#2a2a3d"),
            Hover = Color3.fromHex("#1a1a24"),
            HoverStroke = Color3.fromHex("#0076ad"),
            Text = Color3.fromHex("#f8fafc")
        },
    },
    Resources = { Conns = {}, Insts = {}, Draws = {} },
    Events = { Listeners = {} },
    Controls = {},
    Scheduler = { Tasks = {}, Conn = nil },
    Pool = { Pools = {}, Factories = {} },
    Cache = { 
        Enemies = {},
        DuelTeams = {},
        DuelMatchId = nil,
        ValidCandidates = {},
        PlayerState = setmetatable({}, {__mode = "k"}),
        ESPState = setmetatable({}, {__mode = "k"}),
    }
}

getgenv().SilentSpoofProfiles = {
    ["Default"] =          { deviceKind = nil, inputMode = nil, hideTouch = false },
    ["Teclado y mouse"] =  { deviceKind = 1, inputMode = 1, hideTouch = true },
    ["Control"] =          { deviceKind = 3, inputMode = 3, hideTouch = true },
    ["Desconocido"] =      { deviceKind = 0, inputMode = 1, hideTouch = true },
}

getgenv().SilentRecordSpoofShot = function()
    if not getgenv().SilentHubRunning then return end
    local spoof = Silent.State and Silent.State.Spoof
    if not spoof or spoof.Device ~= "Default" then return end 

    local shots = getgenv().SilentSpoofShots
    if type(shots) ~= "table" then
        shots = {}
        getgenv().SilentSpoofShots = shots
    end

    local ok, now = pcall(function() return workspace:GetServerTimeNow() end)
    if not ok or type(now) ~= "number" then return end

    table.insert(shots, now)
    local cutoff = now - 20
    while #shots > 0 and type(shots[1]) == "number" and shots[1] < cutoff do
        table.remove(shots, 1)
    end
end

local SkyboxEngine

getgenv().SilentHubRunning = true 

function Silent.Resources:TrackConn(c) if c then table.insert(self.Conns, c) end return c end
function Silent.Resources:TrackInst(i) if i then table.insert(self.Insts, i) end return i end
function Silent.Resources:TrackDraw(d) if d then table.insert(self.Draws, d) end return d end

function Silent.Resources:CleanAll()
    for _, c in pairs(self.Conns) do
        if c and typeof(c) == "RBXScriptConnection" and c.Connected then
            pcall(function() c:Disconnect() end)
        end
    end
    for _, d in pairs(self.Draws) do
        pcall(function() d:Remove() end)
    end
    for _, i in pairs(self.Insts) do
        if i and typeof(i) == "Instance" then
            pcall(function() i:Destroy() end)
        end
    end
    table.clear(self.Conns)
    table.clear(self.Draws)
    table.clear(self.Insts)
end

function Silent.Events:Sub(event, id, cb) if not self.Listeners[event] then self.Listeners[event] = {} end self.Listeners[event][id] = cb end
function Silent.Events:Emit(event, ...) if not self.Listeners[event] then return end for _, cb in pairs(self.Listeners[event]) do task.spawn(cb, ...) end end

function Silent.Scheduler:Register(name, hz, cb, priority)
    priority = priority or 50
    self.Tasks[name] = { hz = hz, cb = cb, last = 0, paused = false, priority = priority, Running = false }
end

function Silent.Scheduler:Stop()
    for _, scheduledTask in pairs(self.Tasks) do
        scheduledTask.paused = true
    end
    table.clear(self.Tasks)
    local connection = self.Conn
    self.Conn = nil
    if connection then
        pcall(function() connection:Disconnect() end)
    end
end

function Silent.Scheduler:Start(RunService)
    if self.Conn and self.Conn.Connected then return end
    self.Conn = Silent.Resources:TrackConn(RunService.Heartbeat:Connect(function()
        if not getgenv().SilentHubRunning then return end
        local now = os.clock()
        for _, t in pairs(self.Tasks) do
            if not t.paused and not t.Running and (now - t.last) >= (1 / math.max(t.hz, 1)) then
                t.last = now
                t.Running = true
                task.spawn(function()
                    local success, err = xpcall(function()
                        if getgenv().SilentHubRunning then t.cb() end
                    end, debug.traceback)
                    t.Running = false
                    if not success and getgenv().SilentHubRunning then
                        warn("[SilentHub] scheduler task failed: " .. tostring(err))
                    end
                end)
            end
        end
    end))
end

function Silent.Pool:Register(t, f, r) self.Factories[t] = {f=f, r=r} self.Pools[t] = {} end
function Silent.Pool:Get(t) local p=self.Pools[t] if #p>0 then return table.remove(p) else return self.Factories[t].f() end end
function Silent.Pool:Release(t, o) pcall(function() self.Factories[t].r(o) table.insert(self.Pools[t], o) end) end


getgenv().SilentHubCleanup = function()
    getgenv().SilentProfileSpoofHooked = nil
    getgenv().SilentReplaySpoofHooked = nil
    getgenv().SilentHubRunning = false
    if type(getgenv().SilentReplaySpoofRestore) == "function" then
        pcall(getgenv().SilentReplaySpoofRestore)
    end
    getgenv().SilentReplaySpoofRestore = nil
    Silent.Events:Emit("UpdateHideName", true)
    pcall(function() if Silent.ESP and Silent.ESP.ClearDrawings then Silent.ESP.ClearDrawings() end end) 
    if SkyboxEngine and type(SkyboxEngine.Restore) == "function" then
        pcall(function() SkyboxEngine:Restore() end)
    end
    pcall(function()
        local macro = Silent.State and Silent.State.Macro
        if macro and type(macro.SetKnifeThrowEnabled) == "function" then
            macro.SetKnifeThrowEnabled(false)
        end
    end)

    pcall(function() Silent.Scheduler:Stop() end)
    if type(getgenv().SilentHubGraphicsRestore) == "function" then
        pcall(getgenv().SilentHubGraphicsRestore)
        getgenv().SilentHubGraphicsRestore = nil
    end
    Silent.Resources:CleanAll()
    for _, pool in pairs(Silent.Pool.Pools) do
        table.clear(pool)
    end
    pcall(AvatarIntegration.Cleanup)
    pcall(function() if getgenv().SilentHubWindow then getgenv().SilentHubWindow:Unload() end end)
    
    table.clear(Silent.Cache.ValidCandidates)
    table.clear(Silent.Cache.PlayerState)
    table.clear(Silent.Cache.ESPState)

    getgenv().SilentAimServiceHooked     = nil
    getgenv().SilentHookIndexIniciado    = nil
    getgenv().SilentHookIniciado         = nil
    getgenv().SilentKnifeThrowRedirectHooked = nil
    getgenv().SilentAutoSlashHooked      = nil
    getgenv().SilentAutoFireHooked       = nil

    if type(getgenv().SilentSpoofShots) == "table" then
        table.clear(getgenv().SilentSpoofShots)
    end
    getgenv().SilentSpoofProfiles = nil
    getgenv().SilentRecordSpoofShot = nil
    Silent.State.Spoof = nil

    ContainerManager.Cleanup()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local ContentProvider = game:GetService("ContentProvider")
local SoundService = game:GetService("SoundService")
local workspace = game:GetService("Workspace")
local TPS = game:GetService("TeleportService")
local Stats = game:GetService("Stats")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")

do
    local ok, saved = pcall(function()
        return Lighting:GetAttribute("OSv") == true
    end)
    if ok and saved then
        local map = {
            {"Brightness", "OB"},
            {"ColorShift_Bottom", "OCSB"},
            {"ColorShift_Top", "OCST"},
            {"OutdoorAmbient", "OOA"},
            {"ClockTime", "OTm"},
            {"FogColor", "OFC"},
            {"FogEnd", "OFE"},
            {"FogStart", "OFS"},
            {"ExposureCompensation", "OEx"},
            {"ShadowSoftness", "OSS"},
            {"Ambient", "OAm"},
        }
        for _, pair in ipairs(map) do
            pcall(function()
                local value = Lighting:GetAttribute(pair[2])
                if value ~= nil then Lighting[pair[1]] = value end
            end)
        end
        for _, attribute in ipairs({"OB", "OCSB", "OCST", "OOA", "OTm", "OFC", "OFE", "OFS", "OEx", "OSS", "OAm", "OSv"}) do
            pcall(function() Lighting:SetAttribute(attribute, nil) end)
        end
    end

    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        for _, child in ipairs(terrain:GetChildren()) do
            if child:IsA("Clouds") then
                local color = child.Color
                if color == Color3.fromRGB(50, 65, 95) or color == Color3.fromRGB(120, 20, 150) then
                    pcall(function() child:Destroy() end)
                end
            end
        end
    end
end

local player = Players.LocalPlayer
while not player do task.wait() player = Players.LocalPlayer end
local mouse = player:GetMouse()

local screenGui = ContainerManager.new("ScreenGui", "GUI")
screenGui.Name = "SilentHub_Overlays" 
screenGui.ResetOnSpawn = false 
screenGui.IgnoreGuiInset = true 
screenGui.DisplayOrder = 999 
Silent.Resources:TrackInst(screenGui)

local espFolder = ContainerManager.new("Folder", "ESP") 
espFolder.Name = "SilentESPFolder" 

Silent.Pool:Register("Highlight", 
    function() 
        local h = Instance.new("Highlight") 
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop 
        h.FillTransparency = 1 
        h.OutlineTransparency = 0 
        h.Parent = espFolder 
        return h 
    end,
    function(o) o.Adornee = nil o.Enabled = false end)

Silent.Pool:Register("BillboardGui", 
    function() 
        local b = Instance.new("BillboardGui") 
        b.Size = UDim2.new(0, 200, 0, 75) 
        b.StudsOffset = Vector3.new(0, 3.5, 0) 
        b.AlwaysOnTop = true 
        local t = Instance.new("TextLabel", b) 
        t.Name = "Text" 
        t.Size = UDim2.new(1, 0, 1, 0) 
        t.BackgroundTransparency = 1 
        t.TextStrokeTransparency = 1 
        t.RichText = true 
        t.Font = Enum.Font.SourceSansBold 
        t.TextSize = 14 
        t.TextYAlignment = Enum.TextYAlignment.Bottom 
        Instance.new("UIStroke", t).Thickness = 1.2 
        b.Parent = espFolder 
        return b 
    end,
    function(o) o.Adornee = nil o.Enabled = false end)

Silent.Pool:Register("DrawingLine", 
    function() 
        local line = Drawing.new("Line") 
        line.Thickness = 1.5 
        line.Transparency = 1 
        line.Visible = false 
        Silent.Resources:TrackDraw(line) 
        return line 
    end,
    function(o) o.Visible = false end)


getgenv().SilentTargetPart = nil 
getgenv().SilentTargetLock = nil 
getgenv().SilentLockExpiration = 0 
getgenv().SilentWeaponEquipped = false

local fpsFrames = 0
local lastStats = os.clock()

Silent.Resources:TrackConn(RunService.RenderStepped:Connect(function()
    if not getgenv().SilentHubRunning then return end
    fpsFrames = fpsFrames + 1 
    local now = os.clock()
    if now - lastStats >= 1 then
        local fps = fpsFrames 
        fpsFrames = 0 
        lastStats = now
        if Silent.State.UI.ShowStats then
            local ping = 0 
            pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            Silent.Events:Emit("UpdateStatsUI", fps, ping)
        end
    end
end))

local teamCheckEnabled = true
local TeamController

local loadTeamController
SourceZones.Match.loadTeamController = function()
    local modules = ReplicatedStorage:FindFirstChild("Modules")
    if not modules then
        return nil
    end

    local matchModules = modules:FindFirstChild("Match")
    local candidates = {}

    if matchModules then
        table.insert(candidates, matchModules:FindFirstChild("TeamController"))
    end
    table.insert(candidates, modules:FindFirstChild("TeamController"))

    for _, moduleScript in ipairs(candidates) do
        if moduleScript and moduleScript:IsA("ModuleScript") then
            local ok, result = pcall(require, moduleScript)
            if ok and type(result) == "table" then
                return result
            end
        end
    end

    return nil
end
loadTeamController = SourceZones.Match.loadTeamController

TeamController = loadTeamController()

task.spawn(function()
    for _ = 1, 8 do
        if TeamController then
            break
        end
        task.wait(0.75)
        TeamController = loadTeamController()
    end
end)

local isPlayerInActiveMatch
SourceZones.Match.isPlayerInActiveMatch = function(targetPlayer)
    if not Silent.State.MatchActive then return false end
    if not targetPlayer or targetPlayer == player then return false end
    if not targetPlayer.Character then return false end
    
    local h = targetPlayer.Character:FindFirstChild("Humanoid")
    if not h or h.Health <= 0 then return false end
    
    local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    return true
end
isPlayerInActiveMatch = SourceZones.Match.isPlayerInActiveMatch

local TEAMMATE_MARKER_NAME = "TeammateIconPart"

local computeEnemyRelation
SourceZones.Match.computeEnemyRelation = function(tP)

    if TeamController then
        local myTeam
        local theirTeam
        local gotMyTeam = false
        local gotTheirTeam = false

        if typeof(TeamController.GetLocalTeam) == "function" then
            local ok, value = pcall(TeamController.GetLocalTeam)
            if ok and value ~= nil then
                myTeam = value
                gotMyTeam = true
            end
        end

        if not gotMyTeam and typeof(TeamController.GetTeam) == "function" then
            local ok, value = pcall(TeamController.GetTeam, player)
            if ok and value ~= nil then
                myTeam = value
                gotMyTeam = true
            end
        end

        if typeof(TeamController.GetTeam) == "function" then
            local ok, value = pcall(TeamController.GetTeam, tP)
            if ok and value ~= nil then
                theirTeam = value
                gotTheirTeam = true
            end
        end

        if not gotTheirTeam and typeof(TeamController.GetTeamByUserId) == "function" then
            local ok, value = pcall(TeamController.GetTeamByUserId, tP.UserId)
            if ok and value ~= nil then
                theirTeam = value
                gotTheirTeam = true
            end
        end

        if gotMyTeam and gotTheirTeam then
            return myTeam ~= theirTeam
        end
    end

    local myGame   = player:GetAttribute("Game")
    local theirGame = tP:GetAttribute("Game")
    if myGame ~= nil and theirGame ~= nil then
        local myGS   = tostring(myGame)
        local theirGS = tostring(theirGame)
        if myGS ~= "" and theirGS ~= "" and myGS ~= theirGS then
            return false 
        end
    end

    local tChar = tP.Character
    local tHRP  = tChar and tChar:FindFirstChild("HumanoidRootPart")
    if tHRP and tHRP:FindFirstChild(TEAMMATE_MARKER_NAME) then
        return false
    end

    if player.Team ~= nil and tP.Team ~= nil then
        return player.Team ~= tP.Team
    end

    local pAttr = player:GetAttribute("Team") or player:GetAttribute("team")
    local tAttr = tP:GetAttribute("Team")     or tP:GetAttribute("team")
    if pAttr ~= nil and tAttr ~= nil then
        return pAttr ~= tAttr
    end

    local myColor    = player.TeamColor and player.TeamColor.Name or ""
    local theirColor = tP.TeamColor    and tP.TeamColor.Name    or ""
    local neutral    = { [""] = true, ["White"] = true, ["Medium stone grey"] = true }
    if not neutral[myColor] and not neutral[theirColor] then
        return player.TeamColor ~= tP.TeamColor
    end

    return true
end
computeEnemyRelation = SourceZones.Match.computeEnemyRelation

local isEnemy
SourceZones.Match.isEnemy = function(tP)
    if not teamCheckEnabled then return tP ~= player end
    if not tP or tP == player then return false end
    local cached = Silent.Cache.Enemies[tP]
    if cached ~= nil then return cached end
    local result = computeEnemyRelation(tP)
    Silent.Cache.Enemies[tP] = result
    return result
end
isEnemy = SourceZones.Match.isEnemy

local lastTeamCheckTime = 0
local teamCheckDebounce = 0.5

Silent.Resources:TrackConn(player:GetPropertyChangedSignal("Team"):Connect(function()
    table.clear(Silent.Cache.Enemies)
end))
Silent.Resources:TrackConn(player:GetPropertyChangedSignal("TeamColor"):Connect(function()
    table.clear(Silent.Cache.Enemies)
end))

Silent.Resources:TrackConn(player.AttributeChanged:Connect(function(attr)
    if attr == "Team" or attr == "team" or attr == "Game" then
        table.clear(Silent.Cache.Enemies)
    end
end))

Silent.Scheduler:Register("TeamCheck", 2, function()
    if not Silent.State.MatchActive then return end
    local now = os.clock()
    if now - lastTeamCheckTime < teamCheckDebounce then return end
    lastTeamCheckTime = now

    for _, tP in ipairs(Players:GetPlayers()) do
        if tP ~= player and isPlayerInActiveMatch(tP) then

            Silent.Cache.Enemies[tP] = nil
            isEnemy(tP) 
        elseif tP ~= player then

            Silent.Cache.Enemies[tP] = nil
        end
    end
end, 30)

local updateMatchState
SourceZones.Match.updateMatchState = function()
    local act = false
    local ply = false
    local gA = player:GetAttribute("Game") 
    local dA = player:GetAttribute("Died")
    
    if gA and type(gA) == "string" and gA ~= "" then
        act = true
        if not dA then
            local c = player.Character
            if c and c:FindFirstChild("Humanoid") and c.Humanoid.Health > 0 then
                if c:FindFirstChildOfClass("Tool") or (player:FindFirstChild("Backpack") and player.Backpack:FindFirstChildOfClass("Tool")) then 
                    ply = true 
                end
            end
        end
    end
    
    if Silent.State.MatchActive ~= act then 
        Silent.State.MatchActive = act 
        if not act then 
            table.clear(Silent.Cache.Enemies)
            table.clear(Silent.Cache.ValidCandidates)
            table.clear(Silent.Cache.PlayerState)
        end
    end
    Silent.State.IsPlaying = ply
end
updateMatchState = SourceZones.Match.updateMatchState

Silent.Scheduler:Register("MatchState", 1.5, updateMatchState, 40)
Silent.Resources:TrackConn(player:GetAttributeChangedSignal("Game"):Connect(updateMatchState))
Silent.Resources:TrackConn(player:GetAttributeChangedSignal("Died"):Connect(updateMatchState))

local setupCharacter
SourceZones.Player.Lifecycle.setupCharacter = function(c)

    Silent.State.IsPlaying = false
    getgenv().SilentTargetPart = nil
    getgenv().SilentTargetLock = nil
    getgenv().SilentLockExpiration = 0
    getgenv().SilentWeaponEquipped = false
    task.wait(0.5)
    updateMatchState()
    local h = c:WaitForChild("Humanoid", 5)
    if h then Silent.Resources:TrackConn(h.Died:Connect(updateMatchState)) end
end
setupCharacter = SourceZones.Player.Lifecycle.setupCharacter

if player.Character then task.spawn(setupCharacter, player.Character) end
Silent.Resources:TrackConn(player.CharacterAdded:Connect(setupCharacter))
Silent.Resources:TrackConn(Players.PlayerRemoving:Connect(function(p) 
    Silent.Cache.Enemies[p] = nil 
    Silent.Cache.PlayerState[p] = nil
    Silent.Cache.ESPState[p] = nil
    Silent.Events:Emit("PlayerRemoved", p) 
end))

local executorHttpGetText
SourceZones.Runtime.IO.executorHttpGetText = function(url)
    if type(url) ~= "string" or not string.match(url, "^https?://") or #url > 2048 then
        return nil, "URL invalida"
    end

    local candidates = {}
    local function addCandidate(fn, label)
        if type(fn) ~= "function" then return end
        for _, item in ipairs(candidates) do
            if item.fn == fn then return end
        end
        table.insert(candidates, {fn = fn, label = label})
    end

    addCandidate(request, "request")
    addCandidate(http_request, "http_request")
    if type(syn) == "table" then addCandidate(syn.request, "syn.request") end
    if type(http) == "table" then addCandidate(http.request, "http.request") end

    local errors = {}
    for _, candidate in ipairs(candidates) do
        local ok, response = pcall(function()
            return candidate.fn({Url = url, URL = url, Method = "GET"})
        end)
        if ok and type(response) == "table" then
            local body = response.Body or response.body or response.ResponseBody or response.responseBody
            local status = tonumber(response.StatusCode or response.Status or response.status_code or response.status)
            if type(body) == "string" and body ~= "" and (not status or (status >= 200 and status < 300)) then
                return body
            end
            table.insert(errors, candidate.label .. ": respuesta sin cuerpo valido")
        else
            table.insert(errors, candidate.label .. ": peticion fallida")
        end
    end

    local nativeOk, body = pcall(function() return game:HttpGet(url, true) end)
    if nativeOk and type(body) == "string" and body ~= "" then
        return body
    end

    if #errors > 0 then
        return nil, table.concat(errors, " | ") .. " | game:HttpGet fallo"
    end
    return nil, "No hay un metodo HTTP compatible"
end
executorHttpGetText = SourceZones.Runtime.IO.executorHttpGetText


local SKYBOX_FACE_ORDER = {"SkyboxBk", "SkyboxDn", "SkyboxFt", "SkyboxLf", "SkyboxRt", "SkyboxUp"}

local skyboxData = {
    ["Twilight"] = {"264908339", "264907909", "264909420", "264909758", "264908886", "264907379"},
    ["Nebula"] = {"159454299", "159454296", "159454293", "159454286", "159454300", "159454288"},
    ["Vaporwave"] = {"1417494030", "1417494146", "1417494253", "1417494402", "1417494499", "1417494643"},
    ["Redshift"] = {"401664839", "401664862", "401664960", "401664881", "401664901", "401664936"},
    ["Blue Stars"] = {"149397684", "149397686", "149397688", "149397692", "149397697", "149397702"},
    ["Sakura Pink Sky"] = {"271042516", "271077243", "271042556", "271042310", "271042467", "271077958"},
    ["Desert"] = {"1013852", "1013853", "1013850", "1013851", "1013849", "1013854"},
    ["DaBaby"] = {"7245418472", "7245418472", "7245418472", "7245418472", "7245418472", "7245418472"},
    ["Minecraft"] = {"1876545003", "1876544331", "1876542941", "1876543392", "1876543764", "1876544642"},
    ["SpongeBob"] = {"7633178166", "7633178166", "7633178166", "7633178166", "7633178166", "7633178166"},
    ["Skibidi"] = {"14952256113", "14952256113", "14952256113", "14952256113", "14952256113", "14952256113"},
    ["Blaze"] = {"150939022", "150939038", "150939047", "150939056", "150939063", "150939082"},
    ["Pussy Cat"] = {"11154422902", "11154422902", "11154422902", "11154422902", "11154422902", "11154422902"},
    ["Among Us"] = {"5752463190", "5752463190", "5752463190", "5752463190", "5752463190", "5752463190"},
    ["Space Wave"] = {"16262356578", "16262358026", "16262360469", "16262362003", "16262363873", "16262366016"},
    ["Space Wave 2"] = {"1233158420", "1233158838", "1233157105", "1233157640", "1233157995", "1233159158"},
    ["Turquoise Wave"] = {"47974894", "47974690", "47974821", "47974776", "47974859", "47974909"},
    ["Dark Night"] = {"6285719338", "6285721078", "6285722964", "6285724682", "6285726335", "6285730635"},
    ["White Galaxy"] = {"5540798456", "5540799894", "5540801779", "5540801192", "5540799108", "5540800635"},
}

local skyboxFaceUrlMaps = {
    ["Hakari Hananozo"] = {
        SkyboxBk = "https://od.lk/d/NjNfOTg0NjEzMTVf/SkyBk.tex",
        SkyboxDn = "https://od.lk/d/NjNfOTg0NjEzMTZf/Skydn.tex",
        SkyboxFt = "https://od.lk/s/NjNfOTg0NjEzMTdf/SkyFt.tex",
        SkyboxLf = "https://od.lk/s/NjNfOTg0NjEzMThf/SkyIf.tex",
        SkyboxRt = "https://od.lk/d/NjNfOTg0NjEzMTlf/SkyRt.tex",
        SkyboxUp = "https://od.lk/d/NjNfOTg0NjEzMjBf/SkyUp.tex",
    },
    ["ItsukiNakano"] = {
        SkyboxBk = "https://raw.githubusercontent.com/StyearX/Custom-skybox/main/ItsukiNakano/ItsukiNakano_Bk.png",
        SkyboxDn = "https://raw.githubusercontent.com/StyearX/Custom-skybox/main/ItsukiNakano/ItsukiNakano_Dn.png",
        SkyboxFt = "https://raw.githubusercontent.com/StyearX/Custom-skybox/main/ItsukiNakano/ItsukiNakano_Ft.png",
        SkyboxLf = "https://raw.githubusercontent.com/StyearX/Custom-skybox/main/ItsukiNakano/ItsukiNakano_Lf.png",
        SkyboxRt = "https://raw.githubusercontent.com/StyearX/Custom-skybox/main/ItsukiNakano/ItsukiNakano_Rt.png",
        SkyboxUp = "https://raw.githubusercontent.com/StyearX/Custom-skybox/main/ItsukiNakano/ItsukiNakano_Up.png",
    },
    ["ItsukiNakano2"] = {
        SkyboxBk = "https://raw.githubusercontent.com/StyearX/Custom-skybox/main/ItsukiNakano2/ItsukiNakano2_Bk.png",
        SkyboxDn = "https://raw.githubusercontent.com/StyearX/Custom-skybox/main/ItsukiNakano2/ItsukiNakano2_Dn.png",
        SkyboxFt = "https://raw.githubusercontent.com/StyearX/Custom-skybox/main/ItsukiNakano2/ItsukiNakano2_Ft.png",
        SkyboxLf = "https://raw.githubusercontent.com/StyearX/Custom-skybox/main/ItsukiNakano2/ItsukiNakano2_Lf.png",
        SkyboxRt = "https://raw.githubusercontent.com/StyearX/Custom-skybox/main/ItsukiNakano2/ItsukiNakano2_Rt.png",
        SkyboxUp = "https://raw.githubusercontent.com/StyearX/Custom-skybox/main/ItsukiNakano2/ItsukiNakano2_Up.png",
    },
    ["MaiSakurajima"] = {
        SkyboxBk = "https://raw.githubusercontent.com/StyearX/Custom-skybox/main/MaiSakurajima/back.png",
        SkyboxDn = "https://raw.githubusercontent.com/StyearX/Custom-skybox/main/MaiSakurajima/down.png",
        SkyboxFt = "https://raw.githubusercontent.com/StyearX/Custom-skybox/main/MaiSakurajima/front.png",
        SkyboxLf = "https://raw.githubusercontent.com/StyearX/Custom-skybox/main/MaiSakurajima/left.png",
        SkyboxRt = "https://raw.githubusercontent.com/StyearX/Custom-skybox/main/MaiSakurajima/right.png",
        SkyboxUp = "https://raw.githubusercontent.com/StyearX/Custom-skybox/main/MaiSakurajima/top.png",
    },
    ["MikuNakano"] = {
        SkyboxBk = "https://raw.githubusercontent.com/StyearX/Custom-skybox/main/MikuNakano/MikuNakano_Bk.png",
        SkyboxDn = "https://raw.githubusercontent.com/StyearX/Custom-skybox/main/MikuNakano/MikuNakano_Dn.png",
        SkyboxFt = "https://raw.githubusercontent.com/StyearX/Custom-skybox/main/MikuNakano/MikuNakano_Ft.png",
        SkyboxLf = "https://raw.githubusercontent.com/StyearX/Custom-skybox/main/MikuNakano/MikuNakano_Lf.png",
        SkyboxRt = "https://raw.githubusercontent.com/StyearX/Custom-skybox/main/MikuNakano/MikuNakano_Rt.png",
        SkyboxUp = "https://raw.githubusercontent.com/StyearX/Custom-skybox/main/MikuNakano/MikuNakano_Up.png",
    },
    ["Nino Nakano"] = {
        SkyboxBk = "https://od.lk/d/NjNfOTg0NjQyODJf/left1.png",
        SkyboxDn = "https://od.lk/d/NjNfOTg0NjQyNzlf/down.png",
        SkyboxFt = "https://od.lk/d/NjNfOTg0NjQyODBf/front.png",
        SkyboxLf = "https://od.lk/d/NjNfOTg0NjQyNzhf/back.png",
        SkyboxRt = "https://od.lk/d/NjNfOTg0NjQyODNf/right1.png",
        SkyboxUp = "https://od.lk/d/NjNfOTg0NjQyODFf/up.png",
    },
    ["Nino Nakano 2"] = {
        SkyboxBk = "https://od.lk/d/NjNfOTg0NjQyNTNf/if.png",
        SkyboxDn = "https://od.lk/d/NjNfOTg0NjQyNTVf/dn.png",
        SkyboxFt = "https://od.lk/d/NjNfOTg0NjQyNTZf/bk.png",
        SkyboxLf = "https://od.lk/d/NjNfOTg0NjQyNTRf/ft.png",
        SkyboxRt = "https://od.lk/d/NjNfOTg0NjQyNTJf/rt.png",
        SkyboxUp = "https://od.lk/d/NjNfOTg0NjQyNTBf/up.png",
    },
    ["Rias Gremory"] = {
        SkyboxBk = "https://od.lk/d/NjNfOTg0NzkyOTNf/leftRias.png",
        SkyboxDn = "https://od.lk/d/NjNfOTg0NzkyOThf/downRias.png",
        SkyboxFt = "https://od.lk/d/NjNfOTg0NzkyOTVf/front%20Rias.png",
        SkyboxLf = "https://od.lk/d/NjNfOTg0NzkyOTRf/BackRias.png",
        SkyboxRt = "https://od.lk/d/NjNfOTg0NzkyOTFf/RightRias.png",
        SkyboxUp = "https://od.lk/d/NjNfOTg0NzkyOTJf/UpRias.png",
    },
    ["Saki Saki"] = {
        SkyboxBk = "https://od.lk/d/NjNfOTg0NjQyNjZf/back1.png",
        SkyboxDn = "https://od.lk/d/NjNfOTg0NjQyNjdf/down1.png",
        SkyboxFt = "https://od.lk/d/NjNfOTg0NjQyNjhf/front1.png",
        SkyboxLf = "https://od.lk/d/NjNfOTg0NjQyNzBf/left.png",
        SkyboxRt = "https://od.lk/d/NjNfOTg0NjQyNzNf/right.png",
        SkyboxUp = "https://od.lk/d/NjNfOTg0NjQyNjlf/Up1.png",
    },
    ["Waguri"] = {
        SkyboxBk = "https://raw.githubusercontent.com/StyearX/Custom-skybox/main/Waguri/waguri_ft.png",
        SkyboxDn = "https://raw.githubusercontent.com/StyearX/Custom-skybox/main/Waguri/waguri_dn.png",
        SkyboxFt = "https://raw.githubusercontent.com/StyearX/Custom-skybox/main/Waguri/waguri_bk.png",
        SkyboxLf = "https://raw.githubusercontent.com/StyearX/Custom-skybox/main/Waguri/waguri_rt.png",
        SkyboxRt = "https://raw.githubusercontent.com/StyearX/Custom-skybox/main/Waguri/waguri_lf.png",
        SkyboxUp = "https://raw.githubusercontent.com/StyearX/Custom-skybox/main/Waguri/waguri_up.png",
    },
    ["Xenovia Quarta"] = {
        SkyboxBk = "https://od.lk/d/NjNfOTg0NjM0ODlf/ft.png",
        SkyboxDn = "https://od.lk/d/NjNfOTg0NjM0OTBf/dn.png",
        SkyboxFt = "https://od.lk/d/NjNfOTg0NjM0OTFf/bk.png",
        SkyboxLf = "https://od.lk/d/NjNfOTg0NjM0ODhf/if.png",
        SkyboxRt = "https://od.lk/d/NjNfOTg0NjM0ODdf/rt.png",
        SkyboxUp = "https://od.lk/d/NjNfOTg0NjM0ODZf/up.png",
    },
    ["Yotsuba Nakano"] = {
        SkyboxBk = "https://od.lk/d/NjNfOTg0NzkzMzFf/YotsubaBk.png",
        SkyboxDn = "https://od.lk/d/NjNfOTg0NzkzMzNf/YotsubaDn.png",
        SkyboxFt = "https://od.lk/d/NjNfOTg0NzkzMzRf/YotsubaFt.png",
        SkyboxLf = "https://od.lk/d/NjNfOTg0NzkzMzZf/YotsubaLeft.png",
        SkyboxRt = "https://od.lk/d/NjNfOTg0NzkzMzdf/YotsubaRt.png",
        SkyboxUp = "https://od.lk/d/NjNfOTg0NzkzMzhf/YotsubaUp.png",
    },
    ["Alya"] = {
        SkyboxBk = "https://od.lk/d/NjNfOTg0NzkzMTFf/bk.png",
        SkyboxDn = "https://od.lk/d/NjNfOTg0NzkzMTJf/dn.png",
        SkyboxFt = "https://od.lk/d/NjNfOTg0NzkzMTNf/ft.png",
        SkyboxLf = "https://od.lk/d/NjNfOTg0NzkzMTRf/if.png",
        SkyboxRt = "https://od.lk/d/NjNfOTg0NzkzMTZf/Rt.png",
        SkyboxUp = "https://od.lk/d/NjNfOTg0NzkzMTVf/Up.png",
    },
    ["Alya 2"] = {
        SkyboxBk = "https://od.lk/d/NjNfOTg0NzkzMjBf/AlyaBk.png",
        SkyboxDn = "https://od.lk/d/NjNfOTg0NzkzMjFf/alyaDn.png",
        SkyboxFt = "https://od.lk/d/NjNfOTg0NzkzMjJf/AlyaFt.png",
        SkyboxLf = "https://od.lk/d/NjNfOTg0NzkzMjNf/AlyaLf.png",
        SkyboxRt = "https://od.lk/d/NjNfOTg0NzkzMjRf/AlyaRt.png",
        SkyboxUp = "https://od.lk/d/NjNfOTg0NzkzMjVf/AlyaUp.png",
    },
}

local skyboxNames = {"Original"}
for name in pairs(skyboxData) do table.insert(skyboxNames, name) end
for name in pairs(skyboxFaceUrlMaps) do table.insert(skyboxNames, name) end
table.sort(skyboxNames, function(a, b)
    if a == "Original" then return true end
    if b == "Original" then return false end
    return a < b
end)


SkyboxEngine = {
    OriginalSkies = {},
    SuspendedSkies = {},
    OwnedSky = nil,
    RequestId = 0,
    Applying = false,
    ActiveTempFiles = {},
}
for _, object in ipairs(Lighting:GetChildren()) do
    if object:IsA("Sky") then
        table.insert(SkyboxEngine.OriginalSkies, object)
        table.insert(SkyboxEngine.SuspendedSkies, object)
    end
end

local skyboxSafeFileName
SourceZones.Environment.Skybox.skyboxSafeFileName = function(name)
    return (tostring(name or "skybox"):gsub("[^%w%-_]+", "_"):gsub("_+", "_"):gsub("^_+", ""):gsub("_+$", ""))
end
skyboxSafeFileName = SourceZones.Environment.Skybox.skyboxSafeFileName

local skyboxTempSequence = 0
local skyboxDeleteTempFiles
SourceZones.Environment.Skybox.skyboxDeleteTempFiles = function(paths)
    paths = paths or {}
    if #paths == 0 then return true, {} end

    local removers = {}
    if type(delfile) == "function" then table.insert(removers, delfile) end
    if type(removefile) == "function" and removefile ~= delfile then table.insert(removers, removefile) end
    if #removers == 0 then
        local remaining = {}
        for _, path in ipairs(paths) do table.insert(remaining, path) end
        return false, remaining
    end

    local failedPaths = {}
    for _, path in ipairs(paths) do
        local removed = false
        if type(isfile) == "function" then
            local existsOk, exists = pcall(isfile, path)
            if existsOk and exists == false then removed = true end
        end
        if not removed then
            for _, remover in ipairs(removers) do
                local ok, result = pcall(remover, path)
                if ok and result ~= false then
                    removed = true
                    break
                end
            end
        end
        if not removed then table.insert(failedPaths, path) end
    end
    return #failedPaths == 0, failedPaths
end
skyboxDeleteTempFiles = SourceZones.Environment.Skybox.skyboxDeleteTempFiles

local skyboxRemember
SourceZones.Environment.Skybox.skyboxRemember = function(sky)
    if not sky or not sky:IsA("Sky") then return end
    for _, current in ipairs(SkyboxEngine.SuspendedSkies) do
        if current == sky then return end
    end
    table.insert(SkyboxEngine.SuspendedSkies, sky)
end
skyboxRemember = SourceZones.Environment.Skybox.skyboxRemember

local skyboxLightingConnection = Lighting.ChildAdded:Connect(function(object)
    if not object:IsA("Sky") or not SkyboxEngine.OwnedSky or object == SkyboxEngine.OwnedSky then
        return
    end
    skyboxRemember(object)
    task.defer(function()
        if SkyboxEngine.OwnedSky and object.Parent == Lighting then
            pcall(function() object.Parent = nil end)
        end
    end)
end)
Silent.Resources:TrackConn(skyboxLightingConnection)

function SkyboxEngine:Restore()
    self.RequestId = self.RequestId + 1
    self.Applying = false
    local owned = self.OwnedSky
    self.OwnedSky = nil
    if owned then pcall(function() owned:Destroy() end) end
    local filesDeleted, failedFiles = skyboxDeleteTempFiles(self.ActiveTempFiles)
    self.ActiveTempFiles = failedFiles
    if not filesDeleted and #failedFiles > 0 and getgenv().SilentHubRunning then
        Silent.Events:Emit("Toast", "Skybox: el executor no pudo eliminar todos los archivos temporales")
    end

    local retainedSkies = {}
    local seenSkies = {}
    for _, sky in ipairs(self.SuspendedSkies) do
        if sky and not seenSkies[sky] then
            local readable, parent = pcall(function() return sky.Parent end)
            if readable then
                if parent == nil then
                    pcall(function() sky.Parent = Lighting end)
                end
                local verifyOK, currentParent = pcall(function() return sky.Parent end)
                if verifyOK and currentParent == Lighting then
                    seenSkies[sky] = true
                    table.insert(retainedSkies, sky)
                end
            end
        end
    end
    self.SuspendedSkies = retainedSkies
end

function SkyboxEngine:_Build(name, requestId)
    if requestId ~= self.RequestId then return nil, "Solicitud de cielo cancelada" end
    local ids = skyboxData[name]
    local remoteFaces = skyboxFaceUrlMaps[name]
    if not ids and not remoteFaces then return nil, "Cielo desconocido: " .. tostring(name) end

    local sky = Instance.new("Sky")
    sky.Name = "CustomSkybox"
    sky.CelestialBodiesShown = false
    sky.StarCount = 0
    local temporaryFiles = {}

    local function failBuild(message)
        pcall(function() sky:Destroy() end)
        local failedFiles = {}
        if #temporaryFiles > 0 then
            local filesDeleted
            filesDeleted, failedFiles = skyboxDeleteTempFiles(temporaryFiles)
            if not filesDeleted then
                message = message .. "; el executor no confirmó la eliminación de todos los archivos temporales"
            end
        end
        return nil, message, failedFiles
    end

    if ids then
        for index, property in ipairs(SKYBOX_FACE_ORDER) do
            local id = ids[index]
            if type(id) ~= "string" or not string.match(id, "^%d+$") then
                return failBuild("ID de textura inválido en " .. name .. ": " .. property)
            end
            sky[property] = "rbxassetid://" .. id
        end
    else
        local removerAvailable = type(delfile) == "function" or type(removefile) == "function"
        local assetLoader
        if type(getcustomasset) == "function" then assetLoader = getcustomasset end
        if type(assetLoader) ~= "function" and type(getsynasset) == "function" then assetLoader = getsynasset end
        if type(assetLoader) ~= "function" and type(get_custom_asset) == "function" then assetLoader = get_custom_asset end
        if type(syn) == "table" then
            if type(assetLoader) ~= "function" and type(syn.getcustomasset) == "function" then assetLoader = syn.getcustomasset end
            if type(assetLoader) ~= "function" and type(syn.getsynasset) == "function" then assetLoader = syn.getsynasset end
        end
        if type(writefile) ~= "function" or not removerAvailable or type(assetLoader) ~= "function" then
            return failBuild("Este cielo requiere writefile, delfile/removefile y getcustomasset/getsynasset; no se creará una caché persistente")
        end

        local safe = skyboxSafeFileName(name)
        for _, property in ipairs(SKYBOX_FACE_ORDER) do
            if requestId ~= self.RequestId then
                return failBuild("Solicitud de cielo cancelada")
            end
            local faceUrl = remoteFaces[property]
            if type(faceUrl) ~= "string" or not string.match(faceUrl, "^https?://") then
                return failBuild("Falta una URL válida para " .. property .. " del cielo " .. name)
            end

            local body, fetchError = executorHttpGetText(faceUrl)
            if type(body) ~= "string" or #body < 32 then
                return failBuild("No se pudo descargar " .. property .. " para " .. name .. ": " .. tostring(fetchError))
            end

            skyboxTempSequence += 1
            local path = string.format("silent_sky_tmp_%d_%d_%s_%s.png", math.floor(os.clock() * 1000000), skyboxTempSequence, safe, property)
            local writeOk, writeResult = pcall(writefile, path, body)
            if not writeOk or writeResult == false then
                return failBuild("No se pudo crear la textura temporal " .. property .. " para " .. name)
            end
            table.insert(temporaryFiles, path)

            local assetOk, assetId = pcall(assetLoader, path)
            if not assetOk or type(assetId) ~= "string" or assetId == "" then
                return failBuild("No se pudo registrar la textura temporal " .. property .. " para " .. name)
            end
            sky[property] = assetId
        end
    end

    local preloadOk, preloadError = pcall(function() ContentProvider:PreloadAsync({sky}) end)
    if not preloadOk then
        return failBuild("No se pudieron precargar las texturas: " .. tostring(preloadError))
    end
    if requestId ~= self.RequestId then
        return failBuild("Solicitud de cielo cancelada")
    end
    return sky, nil, temporaryFiles
end

function SkyboxEngine:Request(name)
    name = tostring(name or "Original")
    if name == "Original" then
        self:Restore()
        Silent.Events:Emit("Toast", "Cielo original restaurado.")
        return
    end
    self.RequestId = self.RequestId + 1
    local requestId = self.RequestId
    self.Applying = true
    task.spawn(function()
        local buildCallOK, sky, err, temporaryFiles = pcall(function()
            return self:_Build(name, requestId)
        end)
        if not buildCallOK then
            err = tostring(sky)
            sky = nil
            temporaryFiles = nil
        end
        if requestId ~= self.RequestId then
            if sky then pcall(function() sky:Destroy() end) end
            local _, failedFiles = skyboxDeleteTempFiles(temporaryFiles)
            for _, path in ipairs(failedFiles) do table.insert(self.ActiveTempFiles, path) end
            if #failedFiles > 0 then
                Silent.Events:Emit("Toast", "Skybox: quedaron archivos temporales que el executor no pudo borrar")
            end
            return
        end
        if not sky then
            for _, path in ipairs(temporaryFiles or {}) do
                local present = false
                for _, existing in ipairs(self.ActiveTempFiles) do
                    if existing == path then present = true; break end
                end
                if not present then table.insert(self.ActiveTempFiles, path) end
            end
            self.Applying = false
            Silent.Events:Emit("Toast", "Skybox: " .. tostring(err or "no se pudo construir el cielo"))
            return
        end

        local previousTempFiles = self.ActiveTempFiles
        local applyOK, applyError = pcall(function()
            for _, object in ipairs(Lighting:GetChildren()) do
                if object:IsA("Sky") then
                    if object == self.OwnedSky then
                        local destroyed = pcall(function() object:Destroy() end)
                        if not destroyed then error("No se pudo retirar el skybox anterior") end
                    else
                        skyboxRemember(object)
                        object.Parent = nil
                        if object.Parent == Lighting then
                            error("No se pudo suspender un Sky existente")
                        end
                    end
                end
            end
            self.OwnedSky = sky
            sky.Parent = Lighting
            if sky.Parent ~= Lighting then error("El nuevo Sky no quedó asociado a Lighting") end
        end)
        if not applyOK then
            self.OwnedSky = nil
            pcall(function() sky:Destroy() end)
            self.ActiveTempFiles = previousTempFiles
            local restoredSkies = {}
            for _, suspended in ipairs(self.SuspendedSkies) do
                if suspended then
                    local okParent, parent = pcall(function() return suspended.Parent end)
                    if okParent and parent == nil then
                        pcall(function() suspended.Parent = Lighting end)
                    end
                    local stillReadable = pcall(function() local _ = suspended.ClassName end)
                    if stillReadable then table.insert(restoredSkies, suspended) end
                end
            end
            self.SuspendedSkies = restoredSkies
            local _, failedNewFiles = skyboxDeleteTempFiles(temporaryFiles)
            for _, path in ipairs(failedNewFiles) do table.insert(self.ActiveTempFiles, path) end
            self.Applying = false
            Silent.Events:Emit("Toast", "Skybox: no se pudo aplicar el cielo; se restauró el original. " .. tostring(applyError))
            return
        end

        self.ActiveTempFiles = temporaryFiles or {}
        local _, failedPreviousFiles = skyboxDeleteTempFiles(previousTempFiles)
        for _, path in ipairs(failedPreviousFiles) do table.insert(self.ActiveTempFiles, path) end
        if #failedPreviousFiles > 0 then
            Silent.Events:Emit("Toast", "Skybox: el executor no pudo eliminar algunos archivos temporales anteriores")
        end
        self.Applying = false
        Silent.Events:Emit("Toast", "Skybox aplicado: " .. name)
    end)
end


local esPistola
SourceZones.Shooting.Weapons.esPistola = function(item)
    if not item or not item:IsA("Tool") or item:FindFirstChild("Throw", true) or item:FindFirstChild("KnifeClient", true) or item:FindFirstChild("KnifeServer", true) then return false end
    local nom = string.lower(item.Name) 
    local ign = {"knife", "cuchillo", "dagger", "kunai", "sword"}
    for _, p in ipairs(ign) do if string.find(nom, p) then return false end end return true
end
esPistola = SourceZones.Shooting.Weapons.esPistola

local esCuchillo
SourceZones.Shooting.Weapons.esCuchillo = function(item)
    if not item or not item:IsA("Tool") then return false end
    if item:FindFirstChild("Throw", true) or item:FindFirstChild("KnifeClient", true) or item:FindFirstChild("KnifeServer", true) then return true end
    local nom = string.lower(item.Name) 
    local comp = {"knife", "cuchillo", "dagger", "kunai", "sword"}
    for _, p in ipairs(comp) do if string.find(nom, p) then return true end end return false
end
esCuchillo = SourceZones.Shooting.Weapons.esCuchillo

local getPistola
SourceZones.Shooting.Weapons.getPistola = function() 
    local c = player.Character
    local b = player:FindFirstChild("Backpack") 
    if c then for _, i in ipairs(c:GetChildren()) do if esPistola(i) then return i end end end 
    if b then for _, i in ipairs(b:GetChildren()) do if esPistola(i) then return i end end end 
    return nil 
end
getPistola = SourceZones.Shooting.Weapons.getPistola

local getCuchillo
SourceZones.Shooting.Weapons.getCuchillo = function() 
    local c = player.Character
    local b = player:FindFirstChild("Backpack") 
    if c then for _, i in ipairs(c:GetChildren()) do if esCuchillo(i) then return i end end end 
    if b then for _, i in ipairs(b:GetChildren()) do if esCuchillo(i) then return i end end end 
    return nil 
end
getCuchillo = SourceZones.Shooting.Weapons.getCuchillo

local isThrowModeActive
SourceZones.Shooting.Weapons.isThrowModeActive = function()
    local pG = player:FindFirstChild("PlayerGui")
    if pG then 
        local m = pG:FindFirstChild("Main") or (pG:FindFirstChild("OldStyle") and pG.OldStyle:FindFirstChild("Main")) 
        if m then 
            local mk = m:FindFirstChild("MobileKnifeGui") 
            if mk then 
                local t = mk:FindFirstChild("Throw") 
                local tm = mk:FindFirstChild("ThrowMode") or (t and t:FindFirstChild("ThrowMode")) 
                if tm and tm:IsA("BoolValue") then return tm.Value end 
            end 
        end 
    end 
    return false 
end
isThrowModeActive = SourceZones.Shooting.Weapons.isThrowModeActive


local shiftLockGui
SourceZones.Player.Movement.shiftLockGui = function()
    local playerGui = player:FindFirstChildOfClass("PlayerGui") or player:FindFirstChild("PlayerGui")
    local reticleGui = playerGui and playerGui:FindFirstChild("ShiftLockReticleGui")
    if not reticleGui then return nil, nil end

    local guiEnabled = false
    local enabledOK, enabledValue = pcall(function() return reticleGui.Enabled end)
    if enabledOK then guiEnabled = enabledValue == true end
    if not guiEnabled then return nil, nil end

    local crosshair = reticleGui:FindFirstChild("Crosshair", true)
    if not crosshair then return nil, nil end
    local visibleOK, isVisible = pcall(function() return crosshair.Visible end)
    if not visibleOK or isVisible ~= true then return nil, nil end
    return reticleGui, crosshair
end
shiftLockGui = SourceZones.Player.Movement.shiftLockGui

local TriggerAim = {}
do
    local function getPreferredInput()
        local ok, preferredInput = pcall(function()
            return UserInputService.PreferredInput
        end)
        if ok then return preferredInput end
        return nil
    end

    function TriggerAim.IsTouchPreferredInput()
        local preferredInput = getPreferredInput()
        if preferredInput ~= nil then
            return tostring(preferredInput) == "Enum.PreferredInput.Touch"
        end
        -- Compatibility fallback for older clients without PreferredInput.
        return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    end

    -- Keep automatic knife activation Touch-only; PC aiming uses the native input path.

    function TriggerAim.IsAvailable()
        if TriggerAim.IsTouchPreferredInput() then
            -- Preserve the existing mobile requirement: the game's ShiftLock reticle must be active.
            return shiftLockGui() ~= nil
        end
        return workspace.CurrentCamera ~= nil
    end

    local function getTriggerAimRay()
        local camera = workspace.CurrentCamera
        if not camera then return nil end

        local preferredInput = getPreferredInput()
        local touchInput = TriggerAim.IsTouchPreferredInput()
        local preferredInputName = tostring(preferredInput)
        local centeredInput = preferredInputName == "Enum.PreferredInput.Gamepad"
            or preferredInputName == "Enum.PreferredInput.MicroGamepad"
        local shiftLockActive = shiftLockGui() ~= nil
            or UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter

        if touchInput then
            if not shiftLockActive then return nil end
            local viewport = camera.ViewportSize
            return camera:ViewportPointToRay(viewport.X * 0.5, viewport.Y * 0.5, 0)
        end

        if centeredInput or shiftLockActive then
            local viewport = camera.ViewportSize
            return camera:ViewportPointToRay(viewport.X * 0.5, viewport.Y * 0.5, 0)
        end

        local mousePosition = UserInputService:GetMouseLocation()
        if mousePosition.X ~= mousePosition.X or mousePosition.Y ~= mousePosition.Y
            or math.abs(mousePosition.X) > 10000 or math.abs(mousePosition.Y) > 10000 then
            return nil
        end

        -- GetMouseLocation is screen-relative; convert it to viewport coordinates
        -- before calling ViewportPointToRay so the Core UI inset is not applied twice.
        local insetOK, topLeftInset = pcall(function()
            return GuiService:GetGuiInset()
        end)
        if insetOK and typeof(topLeftInset) == "Vector2" then
            local viewportPosition = mousePosition - topLeftInset
            return camera:ViewportPointToRay(viewportPosition.X, viewportPosition.Y, 0)
        end

        -- Fallback retains correct screen/inset handling if GuiService is unavailable.
        return camera:ScreenPointToRay(mousePosition.X, mousePosition.Y, 0)
    end

    -- Ray A checks queryable geometry and non-collidable character hitboxes.
    local triggerRayParams = RaycastParams.new()
    triggerRayParams.FilterType = Enum.RaycastFilterType.Exclude
    triggerRayParams.IgnoreWater = true
    pcall(function()
        triggerRayParams.RespectCanCollide = false
    end)

    -- Ray B uses CanCollide instead of CanQuery, so collidable walls remain
    -- detectable even when CanQuery is disabled. The first ray still sees
    -- queryable non-collidable character hitboxes.
    local triggerCollisionRayParams = RaycastParams.new()
    triggerCollisionRayParams.FilterType = Enum.RaycastFilterType.Exclude
    triggerCollisionRayParams.IgnoreWater = true
    pcall(function()
        triggerCollisionRayParams.RespectCanCollide = true
    end)

    local triggerEnemyRelationCache = setmetatable({}, { __mode = "k" })
    local function isTriggerEnemy(targetPlayer)
        if not isPlayerInActiveMatch(targetPlayer) then return false end
        if not teamCheckEnabled then return targetPlayer ~= player end

        local now = os.clock()
        local cached = triggerEnemyRelationCache[targetPlayer]
        if cached and now - cached.At < 0.2 then
            return cached.IsEnemy
        end

        -- Recompute for the trigger path instead of trusting the slower shared team cache.
        local relationOK, enemy = pcall(computeEnemyRelation, targetPlayer)
        if not relationOK or type(enemy) ~= "boolean" then
            Silent.Cache.Enemies[targetPlayer] = nil
            enemy = isEnemy(targetPlayer)
        else
            Silent.Cache.Enemies[targetPlayer] = enemy
        end

        triggerEnemyRelationCache[targetPlayer] = { At = now, IsEnemy = enemy == true }
        return enemy == true
    end

    function TriggerAim.GetEnemyUnderAim()
        if not TriggerAim.IsAvailable() then return nil, nil end

        local character = player.Character
        local unitRay = getTriggerAimRay()
        if not character or not unitRay then return nil, nil end

        triggerRayParams.FilterDescendantsInstances = { character }
        triggerCollisionRayParams.FilterDescendantsInstances = { character }

        local rayDirection = unitRay.Direction * 1000
        local queryResult = workspace:Raycast(unitRay.Origin, rayDirection, triggerRayParams)
        local collisionResult = workspace:Raycast(unitRay.Origin, rayDirection, triggerCollisionRayParams)

        -- Use whichever result is physically closer. On near-ties prefer the
        -- collidable ray, conservatively treating an overlapping wall as an
        -- obstruction rather than firing through it.
        local result
        if queryResult and collisionResult then
            if collisionResult.Distance <= queryResult.Distance + 0.015 then
                result = collisionResult
            else
                result = queryResult
            end
        else
            result = queryResult or collisionResult
        end

        local hitPart = result and result.Instance
        if not hitPart or not hitPart:IsA("BasePart") then return nil, nil end

        -- Resolve a hit on any body part or accessory back to its owning Player.Character.
        local ancestor = hitPart
        while ancestor and ancestor ~= workspace do
            if ancestor:IsA("Model") then
                local targetPlayer = Players:GetPlayerFromCharacter(ancestor)
                if targetPlayer then
                    local targetCharacter = targetPlayer.Character
                    local targetHumanoid = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")
                    if targetCharacter == ancestor
                        and targetHumanoid and targetHumanoid.Health > 0
                        and isPlayerInActiveMatch(targetPlayer)
                        and isTriggerEnemy(targetPlayer) then
                        return hitPart, targetPlayer
                    end
                    return nil, nil
                end
            end
            ancestor = ancestor.Parent
        end

        return nil, nil
    end

end

local getNil
SourceZones.Combat.Targeting.getNil = function(name, class)
    if type(getnilinstances) ~= "function" then return nil end
    local ok, instances = pcall(getnilinstances)
    if not ok or type(instances) ~= "table" then return nil end
    for _, v in next, instances do
        if v and v.ClassName == class and v.Name == name then
            return v
        end
    end
    return nil
end
getNil = SourceZones.Combat.Targeting.getNil

local getReloadInstanceFromWeapon
SourceZones.Shooting.Trigger.getReloadInstanceFromWeapon = function(weapon)
    if not weapon then return nil end
    local handle = weapon:FindFirstChild("Handle")
    return handle and handle:FindFirstChild("Reload") or nil
end
getReloadInstanceFromWeapon = SourceZones.Shooting.Trigger.getReloadInstanceFromWeapon

local readReloadState
SourceZones.Shooting.Trigger.readReloadState = function(reload)
    if not reload then return nil end

    local playingOK, isPlaying = pcall(function()
        return reload.IsPlaying
    end)
    if playingOK and type(isPlaying) == "boolean" then
        return isPlaying
    end

    local valueOK, value = pcall(function()
        return reload.Value
    end)
    if valueOK and type(value) == "boolean" then
        return value
    end
    return nil
end
readReloadState = SourceZones.Shooting.Trigger.readReloadState

local resolveTriggerReload
SourceZones.Shooting.Trigger.resolveTriggerReload = function(pistol)
    local function readableReloadFromWeapon(weapon)
        local reload = getReloadInstanceFromWeapon(weapon)
        if reload and readReloadState(reload) ~= nil then
            return reload
        end
        return nil
    end

    -- Prefer the exact pistol currently owned by the local player.
    local reload = readableReloadFromWeapon(pistol)
    if reload then return reload end

    local localBackpack = player:FindFirstChildOfClass("Backpack") or player:FindFirstChild("Backpack")
    reload = readableReloadFromWeapon(localBackpack and localBackpack:FindFirstChild("DefaultGun"))
    if reload then return reload end

    -- Additional game paths supplied for Bimo's replicated weapon instances.
    local worldOwner = workspace:FindFirstChild("Joexcr79")
    reload = readableReloadFromWeapon(worldOwner and worldOwner:FindFirstChild("FlareGun"))
    if reload then return reload end

    local namedPlayer = Players:FindFirstChild("1Delta009")
    local namedBackpack = namedPlayer and (namedPlayer:FindFirstChildOfClass("Backpack") or namedPlayer:FindFirstChild("Backpack"))
    reload = readableReloadFromWeapon(namedBackpack and namedBackpack:FindFirstChild("DefaultGun"))
    if reload then return reload end

    local nilModel = getNil("nene_92630", "Model")
    return readableReloadFromWeapon(nilModel and nilModel:FindFirstChild("DefaultGun"))
end
resolveTriggerReload = SourceZones.Shooting.Trigger.resolveTriggerReload

local macroContextValid
SourceZones.Shooting.Macro.macroContextValid = function(token, character, humanoid)
    local macro = Silent.State.Macro
    if getgenv().SilentHubRunning ~= true
        or macro.Generation ~= token
        or macro.Active ~= true
        or Silent.State.MatchActive ~= true
        or Silent.State.IsPlaying ~= true
        or player.Character ~= character
        or not character or not character.Parent
        or not humanoid or humanoid.Parent ~= character
        or humanoid.Health <= 0 then
        return false
    end
    return true
end
macroContextValid = SourceZones.Shooting.Macro.macroContextValid

local execMacro
SourceZones.Shooting.Macro.execMacro = function(inputPosition)
    local macro = Silent.State.Macro
    local aim = Silent.State.Aim
    if macro.Busy or macro.KnifeThrowBusy or aim.TriggerPistolBusy or aim.TriggerKnifeBusy
        or not macro.Active or not Silent.State.IsPlaying or not Silent.State.MatchActive then return end

    local character = player.Character
    if not character or not character.Parent then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end

    local currentTool = character:FindFirstChildOfClass("Tool")
    if currentTool and not esPistola(currentTool) then return end
    local pistol = getPistola()
    if not pistol or not pistol:IsA("Tool") then return end
    local backpack = player:FindFirstChildOfClass("Backpack") or player:FindFirstChild("Backpack")
    if pistol.Parent ~= character and pistol.Parent ~= backpack then return end

    local pistolAlreadyEquipped = pistol.Parent == character
    if pistol.RequiresHandle and not pistol:FindFirstChild("Handle") then return end

    macro.Generation = (macro.Generation or 0) + 1
    local token = macro.Generation
    macro.Busy = true

    task.spawn(function()
        local operationOK, operationError = xpcall(function()
            if not macroContextValid(token, character, humanoid) then return end

            if pistol.Parent ~= character then
                if character:FindFirstChildOfClass("Tool") then return end
                task.wait(math.clamp(tonumber(macro.EquipDelay) or 0.01, 0, 0.5))
                if not macroContextValid(token, character, humanoid) then return end
                backpack = player:FindFirstChildOfClass("Backpack") or player:FindFirstChild("Backpack")
                if pistol.Parent ~= backpack then return end
                humanoid:EquipTool(pistol)

                local equipDeadline = os.clock() + 0.75
                while pistol.Parent ~= character and os.clock() < equipDeadline
                    and macroContextValid(token, character, humanoid) do
                    task.wait(0.025)
                end
                if pistol.Parent ~= character then return end
            end

            task.wait(0.03)
            if not macroContextValid(token, character, humanoid) or pistol.Parent ~= character then return end

            if not pistolAlreadyEquipped then
                pistol:Activate()
                if getgenv().SilentRecordSpoofShot then getgenv().SilentRecordSpoofShot() end
            else
                local manualOnlyOK, manualOnly = pcall(function() return pistol.ManualActivationOnly end)
                if manualOnlyOK and manualOnly == true then
                    pistol:Activate()
                    if getgenv().SilentRecordSpoofShot then getgenv().SilentRecordSpoofShot() end
                end
            end

            task.wait(math.clamp(tonumber(macro.ShootDelay) or 0.01, 0.01, 0.5))
            pcall(function() pistol:Deactivate() end)
        end, debug.traceback)

        pcall(function() pistol:Deactivate() end)
        if player.Character == character and character.Parent and humanoid.Parent == character
            and humanoid.Health > 0 and pistol.Parent == character then
            pcall(function() humanoid:UnequipTools() end)
        end

        if macro.Generation == token then macro.Busy = false end
        if not operationOK and getgenv().SilentHubRunning then
            warn("[SilentHub] Macro Pistol: " .. tostring(operationError))
        end
    end)
end
execMacro = SourceZones.Shooting.Macro.execMacro

local triggerContextValid
SourceZones.Shooting.Trigger.triggerContextValid = function(kind, token, character, humanoid)
    local aim = Silent.State.Aim
    local generationKey = "Trigger" .. kind .. "Generation"
    if getgenv().SilentHubRunning ~= true
        or aim.TriggerBot ~= true
        or aim[generationKey] ~= token
        or Silent.State.MatchActive ~= true
        or Silent.State.IsPlaying ~= true
        or not TriggerAim.IsAvailable()
        or player.Character ~= character
        or not character or not character.Parent
        or not humanoid or humanoid.Parent ~= character
        or humanoid.Health <= 0 then
        return false
    end
    return true
end
triggerContextValid = SourceZones.Shooting.Trigger.triggerContextValid

local beginTriggerOperation
SourceZones.Shooting.Trigger.beginTriggerOperation = function(kind)
    local aim = Silent.State.Aim
    local busyKey = "Trigger" .. kind .. "Busy"
    local generationKey = "Trigger" .. kind .. "Generation"
    if aim[busyKey] then return nil end
    aim[generationKey] = (aim[generationKey] or 0) + 1
    aim[busyKey] = true
    return aim[generationKey]
end
beginTriggerOperation = SourceZones.Shooting.Trigger.beginTriggerOperation

local finishTriggerOperation
SourceZones.Shooting.Trigger.finishTriggerOperation = function(kind, token)
    local aim = Silent.State.Aim
    local busyKey = "Trigger" .. kind .. "Busy"
    local generationKey = "Trigger" .. kind .. "Generation"

    aim[busyKey] = false
end
finishTriggerOperation = SourceZones.Shooting.Trigger.finishTriggerOperation

local waitForReloadIdle
SourceZones.Shooting.Trigger.waitForReloadIdle = function(reload, token, character, humanoid)
    local deadline = os.clock() + 15
    while triggerContextValid("Pistol", token, character, humanoid) and os.clock() < deadline do
        local isReloading = readReloadState(reload)
        if isReloading == nil then return false end
        if not isReloading then return true end
        task.wait(0.025)
    end
    return false
end
waitForReloadIdle = SourceZones.Shooting.Trigger.waitForReloadIdle

local waitForReloadCycle
SourceZones.Shooting.Trigger.waitForReloadCycle = function(reload, token, character, humanoid)
    local reloadStarted = false

    local startDeadline = os.clock() + 1
    while triggerContextValid("Pistol", token, character, humanoid) and os.clock() < startDeadline do
        local isReloading = readReloadState(reload)
        if isReloading == nil then return false end
        if isReloading then
            reloadStarted = true
            break
        end
        task.wait(0.02)
    end
    if not reloadStarted then return false end

    local finishDeadline = os.clock() + 15
    while triggerContextValid("Pistol", token, character, humanoid) and os.clock() < finishDeadline do
        local isReloading = readReloadState(reload)
        if isReloading == nil then return false end
        if not isReloading then return true end
        task.wait(0.025)
    end
    return false
end
waitForReloadCycle = SourceZones.Shooting.Trigger.waitForReloadCycle

local execPistolTriggerbot
SourceZones.Shooting.Trigger.execPistolTriggerbot = function(targetPart, targetPlayer)
    local aim = Silent.State.Aim
    if aim.TriggerPistolBusy or os.clock() < (aim.TriggerPistolRetryAt or 0) then return end
    if Silent.State.Macro.Busy or Silent.State.Macro.KnifeThrowBusy then return end

    local character = player.Character
    if not character or not character.Parent then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end

    local legitMode = aim.TriggerBotLegit == true
    local currentTool = character:FindFirstChildOfClass("Tool")
    local pistol
    local backpack = player:FindFirstChildOfClass("Backpack") or player:FindFirstChild("Backpack")

    if legitMode then
        -- Legit mode requires the player to equip the pistol manually.
        pistol = currentTool
        if not pistol or not esPistola(pistol) or pistol.Parent ~= character then return end
    else
        -- Automatic mode only replaces an empty hand or an already equipped pistol.
        if currentTool and not esPistola(currentTool) then return end
        pistol = currentTool or getPistola()
        if not pistol or not pistol:IsA("Tool") then return end
        if pistol.Parent ~= character and pistol.Parent ~= backpack then return end
    end

    if pistol.RequiresHandle and not pistol:FindFirstChild("Handle") then return end

    local triggerReload = resolveTriggerReload(pistol)
    local reloadTrackable = triggerReload ~= nil and readReloadState(triggerReload) ~= nil
    if not reloadTrackable and not aim.TriggerPistolWarnedReload then
        aim.TriggerPistolWarnedReload = true
        warn("[SilentHub] Triggerbot: Reload no legible; usando reintento seguro cada 2 segundos.")
    end

    local token = beginTriggerOperation("Pistol")
    if not token then return end

    task.spawn(function()
        local equippedByTrigger = false
        local shotFired = false
        local operationOK, operationError = xpcall(function()
            if not triggerContextValid("Pistol", token, character, humanoid) then return end
            if reloadTrackable and not waitForReloadIdle(triggerReload, token, character, humanoid) then
                if triggerContextValid("Pistol", token, character, humanoid) then
                    aim.TriggerPistolRetryAt = os.clock() + 2
                end
                return
            end
            if not triggerContextValid("Pistol", token, character, humanoid) then return end

            local freshPart, freshPlayer = TriggerAim.GetEnemyUnderAim()
            if not freshPart or freshPlayer ~= targetPlayer then return end

            currentTool = character:FindFirstChildOfClass("Tool")
            if currentTool and currentTool ~= pistol then return end
            if not legitMode and pistol.Parent ~= character then
                backpack = player:FindFirstChildOfClass("Backpack") or player:FindFirstChild("Backpack")
                if pistol.Parent ~= backpack or character:FindFirstChildOfClass("Tool") then return end
                humanoid:EquipTool(pistol)
                equippedByTrigger = true

                local equipDeadline = os.clock() + 0.75
                while pistol.Parent ~= character and os.clock() < equipDeadline
                    and triggerContextValid("Pistol", token, character, humanoid) do
                    task.wait(0.02)
                end
                if pistol.Parent ~= character then return end
            end

            if not triggerContextValid("Pistol", token, character, humanoid) or pistol.Parent ~= character then return end
            freshPart, freshPlayer = TriggerAim.GetEnemyUnderAim()
            if not freshPart or freshPlayer ~= targetPlayer then return end

            -- Keep AutoShoot/SilentAim target attribution synchronized with this shot.
            getgenv().SilentTargetLock = freshPart
            getgenv().SilentLockExpiration = os.clock() + 0.25
            local shotAt = os.clock()
            pistol:Activate()
            shotFired = true
            if getgenv().SilentRecordSpoofShot then getgenv().SilentRecordSpoofShot() end
            task.wait(0.05)
            pcall(function() pistol:Deactivate() end)

            -- Automatic mode returns the pistol to Backpack after each shot.
            if not legitMode and pistol.Parent == character then
                pcall(function() humanoid:UnequipTools() end)
            end

            if reloadTrackable then
                if not waitForReloadCycle(triggerReload, token, character, humanoid)
                    and triggerContextValid("Pistol", token, character, humanoid) then
                    -- Never retry sooner than two seconds after this shot. If
                    -- reload observation itself took longer, retry on next tick.
                    aim.TriggerPistolRetryAt = math.max(shotAt + 2, os.clock())
                end
            else
                -- When both Reload paths are unavailable/unreadable, keep shooting
                -- available but cap attempts to one shot every two seconds.
                aim.TriggerPistolRetryAt = shotAt + 2
            end
        end, debug.traceback)

        pcall(function() pistol:Deactivate() end)
        if not legitMode and (equippedByTrigger or shotFired) and player.Character == character
            and character.Parent and humanoid.Parent == character and humanoid.Health > 0
            and pistol.Parent == character then
            pcall(function() humanoid:UnequipTools() end)
        end
        finishTriggerOperation("Pistol", token)
        if not operationOK and getgenv().SilentHubRunning then
            warn("[SilentHub] Triggerbot/Pistol: " .. tostring(operationError))
        end
    end)
end
execPistolTriggerbot = SourceZones.Shooting.Trigger.execPistolTriggerbot

local execKnifeTriggerbot
SourceZones.Shooting.Trigger.execKnifeTriggerbot = function(knife, targetPart, targetPlayer)
    local aim = Silent.State.Aim
    if aim.TriggerKnifeBusy or os.clock() < (aim.TriggerKnifeRetryAt or 0) then return end

    local character = player.Character
    if not character or not character.Parent then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    if not knife or not knife:IsA("Tool") or not esCuchillo(knife) or knife.Parent ~= character then return end
    if character:FindFirstChildOfClass("Tool") ~= knife then return end

    local token = beginTriggerOperation("Knife")
    if not token then return end

    task.spawn(function()
        local activated = false
        local operationOK, operationError = xpcall(function()
            if not triggerContextValid("Knife", token, character, humanoid) or knife.Parent ~= character then return end
            local freshPart, freshPlayer = TriggerAim.GetEnemyUnderAim()
            if not freshPart or freshPlayer ~= targetPlayer then return end

            -- Preserve the shared target lock used by AutoShoot/SilentAim.
            getgenv().SilentTargetLock = freshPart
            getgenv().SilentLockExpiration = os.clock() + 0.25
            knife:Activate()
            activated = true
            if getgenv().SilentRecordSpoofShot then getgenv().SilentRecordSpoofShot() end
            task.wait(0.05)
        end, debug.traceback)

        if activated then
            pcall(function() knife:Deactivate() end)
            -- Do not equip or unequip the knife automatically. Its lifecycle stays manual.
            aim.TriggerKnifeRetryAt = os.clock() + 0.25
        end
        finishTriggerOperation("Knife", token)
        if not operationOK and getgenv().SilentHubRunning then
            warn("[SilentHub] Triggerbot/Knife: " .. tostring(operationError))
        end
    end)
end
execKnifeTriggerbot = SourceZones.Shooting.Trigger.execKnifeTriggerbot

local cancelTriggerbotOperations
SourceZones.Shooting.Trigger.cancelTriggerbotOperations = function()
    local aim = Silent.State.Aim
    aim.TriggerPistolGeneration = (aim.TriggerPistolGeneration or 0) + 1
    aim.TriggerKnifeGeneration = (aim.TriggerKnifeGeneration or 0) + 1
    -- Do not clear Busy here: each worker releases its own lock after cleanup.
    aim.TriggerLastKnifeTarget = nil
end
cancelTriggerbotOperations = SourceZones.Shooting.Trigger.cancelTriggerbotOperations

local macroTouchInputs = Silent.State.Macro.TouchInputs
local macroMouseDown = false

local cancelMacroOperation
SourceZones.Shooting.Macro.cancelMacroOperation = function()
    local macro = Silent.State.Macro
    macro.Generation = (macro.Generation or 0) + 1
    macro.Busy = false
    table.clear(macro.TouchInputs)
    macroMouseDown = false
end
cancelMacroOperation = SourceZones.Shooting.Macro.cancelMacroOperation

-- Only accept genuine, unprocessed gameplay clicks/taps. CoreGui controls such
-- as jump, movement and ShiftLock must never arm the pistol macro.
Silent.Resources:TrackConn(UserInputService.InputBegan:Connect(function(input, processed)
    local macro = Silent.State.Macro
    if processed or not macro.Active then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        macroMouseDown = true
    elseif input.UserInputType == Enum.UserInputType.Touch then
        macroTouchInputs[input] = { Position = input.Position, StartedAt = os.clock() }
    end
end))

Silent.Resources:TrackConn(UserInputService.InputEnded:Connect(function(input, processed)
    local macro = Silent.State.Macro
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if macroMouseDown then
            macroMouseDown = false
            if macro.Active then task.defer(execMacro, input.Position) end
        end
    elseif input.UserInputType == Enum.UserInputType.Touch then
        local touch = macroTouchInputs[input]
        macroTouchInputs[input] = nil
        if touch and macro.Active then
            local duration = os.clock() - touch.StartedAt
            local movement = (touch.Position - input.Position).Magnitude
            if movement < 10 and duration >= 0.03 and duration < 0.35 then
                task.defer(execMacro, input.Position)
            end
        end
    end
end))

local triggerbotScheduler
SourceZones.Shooting.Trigger.triggerbotScheduler = function()
    local aim = Silent.State.Aim
    if not aim.TriggerBot or Silent.State.Macro.Busy or Silent.State.Macro.KnifeThrowBusy
        or not Silent.State.IsPlaying or not TriggerAim.IsAvailable() then return end

    local now = os.clock()
    local detectionInterval = math.clamp(tonumber(aim.TriggerDetectionInterval) or 0.03, 0.01, 0.06)
    if now - (aim.TriggerDetectionLastScanAt or 0) < detectionInterval then return end
    aim.TriggerDetectionLastScanAt = now

    local targetPart, targetPlayer = TriggerAim.GetEnemyUnderAim()
    if not targetPart or not targetPlayer then
        aim.TriggerLastKnifeTarget = nil
        return
    end

    local character = player.Character
    if not character then return end
    local currentTool = character:FindFirstChildOfClass("Tool")

    -- After a knife strike, do not auto-equip the pistol against the same target.
    -- Manually equipping either weapon re-arms its own route.
    if not currentTool and aim.TriggerLastKnifeTarget then
        if aim.TriggerLastKnifeTarget == targetPlayer then return end
        aim.TriggerLastKnifeTarget = nil
    elseif currentTool then
        aim.TriggerLastKnifeTarget = nil
    end

    if currentTool and esCuchillo(currentTool) then
        if TriggerAim.IsTouchPreferredInput() then
            execKnifeTriggerbot(currentTool, targetPart, targetPlayer)
        end
    elseif currentTool and esPistola(currentTool) then
        execPistolTriggerbot(targetPart, targetPlayer)
    elseif not currentTool and not aim.TriggerBotLegit then
        execPistolTriggerbot(targetPart, targetPlayer)
    end
end
triggerbotScheduler = SourceZones.Shooting.Trigger.triggerbotScheduler

Silent.Scheduler:Register("TriggerbotPCMobile", 100, triggerbotScheduler)

-- PC-only native E macro. Keep all helper locals inside this block to avoid
-- increasing the main chunk's active local-register count.
do
    local ContextActions = game:GetService("ContextActionService")
    local ThrowActionName = "SilentHubMacroKnifeThrowPC"

    local function keyboardPreferred()
        local ok, preferred = pcall(function()
            return UserInputService.PreferredInput
        end)
        if ok and preferred ~= nil then
            return preferred == Enum.PreferredInput.KeyboardAndMouse
        end
        return UserInputService.KeyboardEnabled and not UserInputService.TouchEnabled
    end

    local function sendNativeE()
        local manager
        local managerOK = pcall(function()
            manager = game:GetService("VirtualInputManager")
        end)
        if managerOK and manager then
            local pressOK = pcall(function()
                manager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            end)
            if pressOK then
                task.wait(0.055)
                local releaseOK = pcall(function()
                    manager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                end)
                if releaseOK then return true end
            end
        end

        -- Executor fallback used by desktop executors that expose keypress/keyrelease.
        if type(keypress) == "function" and type(keyrelease) == "function" then
            local pressOK = pcall(keypress, 0x45)
            if pressOK then
                task.wait(0.055)
                local releaseOK = pcall(keyrelease, 0x45)
                return releaseOK
            end
        end
        return false
    end

    local function throwContextValid(token, character, humanoid, knife)
        local macro = Silent.State.Macro
        return getgenv().SilentHubRunning == true
            and macro.KnifeThrowActive == true
            and macro.KnifeThrowGeneration == token
            and Silent.State.MatchActive == true
            and Silent.State.IsPlaying == true
            and player.Character == character
            and character ~= nil and character.Parent ~= nil
            and humanoid ~= nil and humanoid.Parent == character and humanoid.Health > 0
            and knife ~= nil and knife.Parent ~= nil
    end

    local function unbindThrowAction()
        pcall(function() ContextActions:UnbindAction(ThrowActionName) end)
    end

    local function runKnifeThrowMacro()
        local macro = Silent.State.Macro
        local aim = Silent.State.Aim
        if not macro.KnifeThrowActive or macro.KnifeThrowBusy or macro.Busy
            or aim.TriggerPistolBusy or aim.TriggerKnifeBusy
            or not Silent.State.MatchActive or not Silent.State.IsPlaying then
            return
        end

        local character = player.Character
        if not character or not character.Parent then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then return end
        local knife = getCuchillo()
        if not knife or not knife:IsA("Tool") or not esCuchillo(knife) then return end
        local backpack = player:FindFirstChildOfClass("Backpack") or player:FindFirstChild("Backpack")
        if knife.Parent ~= character and knife.Parent ~= backpack then return end

        macro.KnifeThrowGeneration = (macro.KnifeThrowGeneration or 0) + 1
        local token = macro.KnifeThrowGeneration
        local shouldUnequip = knife.Parent ~= character
        macro.KnifeThrowBusy = true

        task.spawn(function()
            local operationOK, operationError = xpcall(function()
                if not throwContextValid(token, character, humanoid, knife) then return end

                if knife.Parent ~= character then
                    backpack = player:FindFirstChildOfClass("Backpack") or player:FindFirstChild("Backpack")
                    if knife.Parent ~= backpack then return end
                    humanoid:EquipTool(knife)
                    local equipDeadline = os.clock() + 0.8
                    while knife.Parent ~= character and os.clock() < equipDeadline
                        and throwContextValid(token, character, humanoid, knife) do
                        task.wait(0.02)
                    end
                    if knife.Parent ~= character then return end
                end

                task.wait(0.06)
                if not throwContextValid(token, character, humanoid, knife) or knife.Parent ~= character then return end

                -- The physical E was sunk by ContextActionService. Temporarily
                -- unbind so this one synthetic E reaches the game's native handler.
                unbindThrowAction()
                local sent = sendNativeE()
                if sent then shouldUnequip = true end
                task.wait(0.09)
                if macro.KnifeThrowActive and keyboardPreferred() then
                    ContextActions:BindActionAtPriority(
                        ThrowActionName,
                        function(_, inputState)
                            if inputState == Enum.UserInputState.Begin then
                                if macro.KnifeThrowActive and Silent.State.MatchActive and Silent.State.IsPlaying then
                                    task.defer(runKnifeThrowMacro)
                                    return Enum.ContextActionResult.Sink
                                end
                            end
                            return Enum.ContextActionResult.Pass
                        end,
                        false,
                        Enum.ContextActionPriority.High.Value + 100,
                        Enum.KeyCode.E
                    )
                end
                if not sent then
                    error("Delta/executor no expone VirtualInputManager:SendKeyEvent ni keypress/keyrelease para E")
                end
            end, debug.traceback)

            if shouldUnequip and player.Character == character and character.Parent
                and humanoid.Parent == character and humanoid.Health > 0 and knife.Parent == character then
                pcall(function() humanoid:UnequipTools() end)
            end
            macro.KnifeThrowBusy = false
            if not operationOK and getgenv().SilentHubRunning then
                warn("[SilentHub] Macro KnifeThrow PC: " .. tostring(operationError))
            end
        end)
    end

    local function bindThrowAction()
        unbindThrowAction()
        if not Silent.State.Macro.KnifeThrowActive or not keyboardPreferred() then return end
        ContextActions:BindActionAtPriority(
            ThrowActionName,
            function(_, inputState)
                if inputState == Enum.UserInputState.Begin then
                    if Silent.State.Macro.KnifeThrowActive
                        and Silent.State.MatchActive and Silent.State.IsPlaying then
                        task.defer(runKnifeThrowMacro)
                        return Enum.ContextActionResult.Sink
                    end
                end
                return Enum.ContextActionResult.Pass
            end,
            false,
            Enum.ContextActionPriority.High.Value + 100,
            Enum.KeyCode.E
        )
    end

    Silent.State.Macro.SetKnifeThrowEnabled = function(enabled)
        local macro = Silent.State.Macro
        macro.KnifeThrowActive = enabled == true
        if not macro.KnifeThrowActive then
            macro.KnifeThrowGeneration = (macro.KnifeThrowGeneration or 0) + 1
            unbindThrowAction()
            return
        end
        bindThrowAction()
    end

    local preferredChangedOK, preferredChangedConnection = pcall(function()
        return UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
            if Silent.State.Macro.KnifeThrowActive then
                bindThrowAction()
            else
                unbindThrowAction()
            end
        end)
    end)
    if preferredChangedOK and preferredChangedConnection then
        Silent.Resources:TrackConn(preferredChangedConnection)
    end
end

local PatchVanillaBugAndLock
SourceZones.Player.Movement.PatchVanillaBugAndLock = function(tmv)
    if not tmv or not tmv:IsA("BoolValue") then return end
    task.spawn(function() task.wait(0.1) if tmv.Parent then tmv.Value = false task.wait(0.05) if tmv.Parent then tmv.Value = true end end end)
    Silent.Resources:TrackConn(tmv:GetPropertyChangedSignal("Value"):Connect(function() 
        if not tmv.Value then 
            task.defer(function() if tmv and tmv.Parent then tmv.Value = true end end) 
        end 
    end))
end
PatchVanillaBugAndLock = SourceZones.Player.Movement.PatchVanillaBugAndLock

local MonitorMKGui
SourceZones.Player.Movement.MonitorMKGui = function(mg)
    local function pc(c) 
        if c.Name == "MobileKnifeGui" then 
            local t = c:WaitForChild("Throw", 3) 
            local tm = c:WaitForChild("ThrowMode", 3) or (t and t:WaitForChild("ThrowMode", 3)) 
            if tm then PatchVanillaBugAndLock(tm) end 
        end 
    end
    local ex = mg:FindFirstChild("MobileKnifeGui") 
    if ex then task.spawn(pc, ex) end 
    Silent.Resources:TrackConn(mg.ChildAdded:Connect(pc))
end
MonitorMKGui = SourceZones.Player.Movement.MonitorMKGui

Silent.Events:Sub("ToggleThrowMode", "Aim", function(s)
    if s then 
        local pG = player:WaitForChild("PlayerGui", 10) 
        if not pG then return end 
        local m = (pG:FindFirstChild("OldStyle") and pG.OldStyle:FindFirstChild("Main")) or pG:FindFirstChild("Main") 
        if m then MonitorMKGui(m) end 
        Silent.Resources:TrackConn(pG.DescendantAdded:Connect(function(d) 
            if d.Name == "Main" and d:IsA("Frame") then task.defer(MonitorMKGui, d) end 
        end)) 
    end
end)

local hParamsAim = RaycastParams.new() 
hParamsAim.FilterType = Enum.RaycastFilterType.Exclude

local hParamsFilterArray = {nil, nil}
local lShoot = os.clock()

local CFrame_new = CFrame.new
local Vector2_new = Vector2.new
local Vector3_new = Vector3.new

local cachedOffsets = {
    CFrame_new(0,0,0),
    CFrame_new(1,0,0),
    CFrame_new(-1,0,0),
    CFrame_new(0,1,0),
    CFrame_new(0,-1,0)
}

local normalizeTargetPart
SourceZones.Combat.Targeting.normalizeTargetPart = function(value, currentValue)
    local val = type(value) == "table" and value[1] or value
    if val == "Cabeza" or val == "Torso" or val == "Legit" or val == "Cuerpo Completo" then
        return val
    end
    return currentValue or "Cabeza" 
end
normalizeTargetPart = SourceZones.Combat.Targeting.normalizeTargetPart

local partResolutionCache = {}
local resolveTargetParts
SourceZones.Combat.Targeting.resolveTargetParts = function(character, targetMode)
    if not character then return {} end
    
    local cacheKey = character
    if partResolutionCache[cacheKey] and partResolutionCache[cacheKey].mode == targetMode then
        return partResolutionCache[cacheKey].parts
    end

    local resolvedParts = {}
    if targetMode == "Cabeza" then
        local head = character:FindFirstChild("Head")
        if head and head:IsA("BasePart") then
            table.insert(resolvedParts, head)
        end
        
    elseif targetMode == "Torso" then
        local torso = character:FindFirstChild("Torso")
        local upperTorso = character:FindFirstChild("UpperTorso")
        local lowerTorso = character:FindFirstChild("LowerTorso")
        
        if torso and torso:IsA("BasePart") then
            table.insert(resolvedParts, torso) 
        elseif upperTorso and upperTorso:IsA("BasePart") then
            table.insert(resolvedParts, upperTorso) 
        elseif lowerTorso and lowerTorso:IsA("BasePart") then
            table.insert(resolvedParts, lowerTorso) 
        end

    elseif targetMode == "Legit" then
        local legitPriority = {"Head", "UpperTorso", "LowerTorso", "Torso"}
        for _, partName in ipairs(legitPriority) do
            local part = character:FindFirstChild(partName)
            if part and part:IsA("BasePart") then
                table.insert(resolvedParts, part)
            end
        end
        
    elseif targetMode == "Cuerpo Completo" then
        for _, part in ipairs(character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and not part:IsA("Accessory") then
                table.insert(resolvedParts, part)
            end
        end
    end

    partResolutionCache[cacheKey] = { parts = resolvedParts, mode = targetMode }
    return resolvedParts
end
resolveTargetParts = SourceZones.Combat.Targeting.resolveTargetParts

Silent.Resources:TrackConn(Players.PlayerRemoving:Connect(function(p)
    local character = p and p.Character
    if character then
        partResolutionCache[character] = nil
    end

    for cachedCharacter in pairs(partResolutionCache) do
        if not cachedCharacter or not cachedCharacter.Parent then
            partResolutionCache[cachedCharacter] = nil
        end
    end
end))

Silent.Resources:TrackConn(player.CharacterAdded:Connect(function()
    for k in pairs(partResolutionCache) do
        if not k.Parent then partResolutionCache[k] = nil end
    end
end))

local getFOVScreenPoint
SourceZones.Combat.FOV.getFOVScreenPoint = function(camera, worldPosition)
    if not camera then return nil, false end

    local point, visible = camera:WorldToViewportPoint(worldPosition)
    return Vector2_new(point.X, point.Y), visible
end
getFOVScreenPoint = SourceZones.Combat.FOV.getFOVScreenPoint

local normalizeAimMode
SourceZones.Combat.FOV.normalizeAimMode = function(value, currentValue)
    local selected = type(value) == "table" and value[1] or value
    if selected == "FOV" or selected == "Screen" or selected == "360" then
        return selected
    end
    return currentValue or "FOV"
end
normalizeAimMode = SourceZones.Combat.FOV.normalizeAimMode

local isAimPointAllowed
SourceZones.Combat.Targeting.isAimPointAllowed = function(camera, worldPosition)
    local mode = normalizeAimMode(Silent.State.Aim.Mode, "FOV")
    if mode == "360" then return true end
    if not camera then return false end

    local point, visible = camera:WorldToViewportPoint(worldPosition)
    local viewport = camera.ViewportSize
    local insideScreen = visible and point.Z > 0
        and point.X >= 0 and point.Y >= 0
        and point.X <= viewport.X and point.Y <= viewport.Y

    if mode == "Screen" then
        return insideScreen
    end
    if not insideScreen then return false end

    local center = Vector2_new(
        math.floor(viewport.X * 0.5 + 0.5),
        math.floor(viewport.Y * 0.5 + 0.5)
    )
    local distanceFromCenter = (Vector2_new(point.X, point.Y) - center).Magnitude
    return distanceFromCenter <= math.max(0, tonumber(Silent.State.Aim.FovRadius) or 0)
end
isAimPointAllowed = SourceZones.Combat.Targeting.isAimPointAllowed

local getFOVCenter
SourceZones.Combat.FOV.getFOVCenter = function(camera)
    if not camera then return Vector2_new(0, 0) end

    local viewport = camera.ViewportSize
    return Vector2_new(
        math.floor(viewport.X * 0.5 + 0.5),
        math.floor(viewport.Y * 0.5 + 0.5)
    )
end
getFOVCenter = SourceZones.Combat.FOV.getFOVCenter

local MAX_ESP_TARGETS = 5

local isValidForESP
SourceZones.ESP.Validation.isValidForESP = function(targetPlayer)
    if not isPlayerInActiveMatch(targetPlayer) then return false end
    if not isEnemy(targetPlayer) then return false end
    
    local c = targetPlayer.Character
    if not c then return false end
    
    local h = c:FindFirstChild("Humanoid")
    if not h or h.Health <= 0 then return false end
    
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local localPos = player.Character and player.Character.PrimaryPart and player.Character.PrimaryPart.Position or Vector3_new(0, 0, 0)
    local dist = (hrp.Position - localPos).Magnitude
    
    if Silent.State.Gfx.SmartRender and dist > Silent.State.Gfx.RenderDist then return false end
    
    return true
end
isValidForESP = SourceZones.ESP.Validation.isValidForESP

Silent.Scheduler:Register("AimbotUpdate", 25, function()
    local nowClock = os.clock()
    if getgenv().SilentTargetLock and nowClock >= getgenv().SilentLockExpiration then getgenv().SilentTargetLock = nil end
    local isA = Silent.State.Aim.SilentAim or Silent.State.Aim.AutoShoot
    if not Silent.State.IsPlaying or not isA then getgenv().SilentTargetPart = nil getgenv().SilentWeaponEquipped = false return end
    
    local c = player.Character if not c or not c:FindFirstChild("HumanoidRootPart") then return end
    local aM = c:FindFirstChildOfClass("Tool") 
    local iG = esPistola(aM)
    local iK = esCuchillo(aM)
    
    local weaponInInventory = getPistola() or getCuchillo()
    getgenv().SilentWeaponEquipped = (iG or iK or (weaponInInventory ~= nil and (Silent.State.Macro.Active or Silent.State.Aim.SilentAim or Silent.State.Aim.AutoShoot)))
    
    if not getgenv().SilentWeaponEquipped then getgenv().SilentTargetPart = nil return end

    local cP = nil
    local bestDist = math.huge
    
    local mP = c.HumanoidRootPart.Position
    local currentCam = workspace.CurrentCamera
    local shotOrigin = mP
    if Silent.State.Aim.AutoShoot and not Silent.State.Aim.SilentAim and currentCam then
        shotOrigin = currentCam.CFrame.Position
    end
    local mPos = getFOVCenter(currentCam)

    hParamsFilterArray[1] = c
    
    for _, p in ipairs(Players:GetPlayers()) do
        if not isPlayerInActiveMatch(p) or not isEnemy(p) then continue end
        
        local eH = p.Character:FindFirstChild("Humanoid")
        local eHrp = p.Character:FindFirstChild("HumanoidRootPart")
        if not (eH and eH.Health > 0 and eHrp) then continue end
        
        local eDist3D = (eHrp.Position - mP).Magnitude
        if Silent.State.Gfx.SmartRender and eDist3D > Silent.State.Gfx.RenderDist then continue end
        
        local partsToCheck = resolveTargetParts(p.Character, Silent.State.Aim.TargetPart)
        
        for _, pt in ipairs(partsToCheck) do 
            if not (pt and pt:IsA("BasePart") and pt.Name ~= "HumanoidRootPart" and not pt:IsA("Accessory")) then continue end
            
            local df = (pt.Position - mP).Magnitude
            if df >= bestDist then continue end
            
            if not isAimPointAllowed(currentCam, pt.Position) then continue end
            
            hParamsFilterArray[1] = c
            hParamsFilterArray[2] = p.Character
            hParamsAim.FilterDescendantsInstances = hParamsFilterArray
            
            local sX, sY, cf = pt.Size.X / 0.0, pt.Size.Y / 0.0, pt.CFrame
            
            local function checkRay(offsetCF)
                local targetPoint = (cf * offsetCF).Position
                local direction = targetPoint - shotOrigin
                if direction.Magnitude <= 0.001 then
                    return true
                end

                local guardVisCheck = Silent.State.Aim.AutoShoot and not Silent.State.Aim.SilentAim
                if guardVisCheck then getgenv().SilentVisCheckActive = true end
                local ok, hit = pcall(function()
                    return workspace:Raycast(shotOrigin, direction, hParamsAim)
                end)
                if guardVisCheck then getgenv().SilentVisCheckActive = false end
                if not ok then return false end
                return hit == nil
            end
            
            local isV = false
            for i = 1, 5 do
                if checkRay(cachedOffsets[i]) then isV = true break end
            end
            
            if isV then 
                bestDist = df 
                cP = pt 
            end
        end
    end

    local hitChance = math.clamp(tonumber(Silent.State.Aim.HitChance) or 100, 0, 100)
    if cP and math.random(1, 100) > hitChance then
        cP = nil
    end

    getgenv().SilentTargetPart = cP
    
    if cP then
        if Silent.State.Aim.AutoShoot and aM and aM:FindFirstChild("Handle") and (nowClock - lShoot > 0.15) then
            if iG or iK then
                local dpr = true 
                if iK and not isThrowModeActive() and (cP.Position - mP).Magnitude > 10 then dpr = false end
                if dpr then 
                    lShoot = nowClock 
                    getgenv().SilentTargetLock = cP 
                    getgenv().SilentLockExpiration = nowClock + 0.5 
                    pcall(function()
                        aM:Activate()
                        if getgenv().SilentRecordSpoofShot then getgenv().SilentRecordSpoofShot() end
                        task.delay(0.05, function() if aM.Parent == c then aM:Deactivate() end end)
                    end) 
                end
            end
        end
        
    end
end, 90)

local math_random = math.random
local Vector3_new = Vector3.new
local os_clock = os.clock
local workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local getAimPoint
SourceZones.Combat.Targeting.getAimPoint = function(target)
    if typeof(target) ~= "Instance" or not target.Parent then return nil end
    local ok, position = pcall(function() return target.Position end)
    return ok and typeof(position) == "Vector3" and position or nil
end
getAimPoint = SourceZones.Combat.Targeting.getAimPoint

local getValidatedHookTarget
SourceZones.Combat.Targeting.getValidatedHookTarget = function()
    local nowClock = os_clock()

    if getgenv().SilentTargetLock then
        if nowClock < (getgenv().SilentLockExpiration or 0) then
            local lock = getgenv().SilentTargetLock

            if typeof(lock) == "Instance" and lock.Parent then
                return lock
            end

            getgenv().SilentTargetLock = nil
        else

            getgenv().SilentTargetLock = nil
        end
    end

    local part = getgenv().SilentTargetPart
    if not part then return nil end

    if typeof(part) ~= "Instance" then
        getgenv().SilentTargetPart = nil
        return nil
    end

    if not part.Parent then
        getgenv().SilentTargetPart = nil
        return nil
    end

    local model = part:FindFirstAncestorWhichIsA("Model")
    if not model or not model.Parent then
        getgenv().SilentTargetPart = nil
        return nil
    end

    return part
end
getValidatedHookTarget = SourceZones.Combat.Targeting.getValidatedHookTarget

if not getgenv().SilentAimServiceHooked then
    task.spawn(function()
        local AimService
        local modulePaths = {
            { "Modules", "Input", "AimService" },
            { "Modules", "AimService" },
        }

        local function findAimServiceModule()
            for _, path in ipairs(modulePaths) do
                local node = ReplicatedStorage
                for _, childName in ipairs(path) do
                    node = node and node:FindFirstChild(childName)
                end
                if node and node:IsA("ModuleScript") then
                    local ok, result = pcall(require, node)
                    if ok and type(result) == "table" then
                        return result
                    end
                end
            end
            return nil
        end

        for attempt = 1, 20 do
            if not getgenv().SilentHubRunning then return end
            AimService = findAimServiceModule()
            if AimService then break end
            task.wait(0.25)
        end

        if type(AimService) ~= "table" then
            warn("No se encontró AimService")
            return
        end
        if type(hookfunction) ~= "function" or type(newcclosure) ~= "function" then
            warn("El executor no contiene hookfunction/newcclosure")
            return
        end

        local function redirectActive()
            return getgenv().SilentHubRunning == true
                and (Silent.State.Aim.SilentAim == true or Silent.State.Aim.AutoShoot == true)
        end

        local function resolveTargetPosition(target)
            local ok, position = pcall(function()
                if type(getAimPoint) == "function" then
                    return getAimPoint(target) or target.Position
                end
                return target.Position
            end)
            if ok and typeof(position) == "Vector3" then return position end
            return target.Position
        end

        local aimRayParams = RaycastParams.new()
        aimRayParams.FilterType = Enum.RaycastFilterType.Exclude
        aimRayParams.IgnoreWater = true

        local function findVisibleAimPoint(targetPart, cameraOrigin, origin)
            if not targetPart or not targetPart.Parent then return nil end
            local targetChar = targetPart:FindFirstAncestorWhichIsA("Model")
            if not targetChar then return nil end

            local playerChar = player.Character
            local excludeList = {}
            if playerChar then table.insert(excludeList, playerChar) end
            local cam = workspace.CurrentCamera
            if cam then table.insert(excludeList, cam) end
            aimRayParams.FilterDescendantsInstances = excludeList

            local basePos = targetPart.Position
            local size = targetPart:IsA("BasePart") and targetPart.Size or Vector3.new(1, 1, 1)
            local hx = math.max(0.12, size.X * 0.25)
            local hy = math.max(0.12, size.Y * 0.25)

            local offsets = {
                Vector3.new(0, 0, 0),
                Vector3.new(hx, 0, 0),   Vector3.new(-hx, 0, 0),
                Vector3.new(0, hy, 0),   Vector3.new(0, -hy, 0),
                Vector3.new(hx, hy, 0),  Vector3.new(-hx, hy, 0),
                Vector3.new(hx, -hy, 0), Vector3.new(-hx, -hy, 0),
            }

            local fallbackSurface = nil
            for _, offset in ipairs(offsets) do
                local candidate = basePos + offset
                local camDelta = candidate - cameraOrigin
                if camDelta.Magnitude >= 0.5 then
                    local camHit = workspace:Raycast(cameraOrigin, camDelta, aimRayParams)
                    if camHit and camHit.Instance:IsDescendantOf(targetChar) then
                        local hitPos = camHit.Position
                        if not fallbackSurface then fallbackSurface = hitPos end

                        local origDelta = hitPos - origin
                        if origDelta.Magnitude >= 0.5 then
                            local origHit = workspace:Raycast(origin, origDelta, aimRayParams)
                            if not origHit or origHit.Instance:IsDescendantOf(targetChar) then
                                return hitPos
                            end
                        end
                    end
                end
            end

            return fallbackSurface or basePos
        end

        local installed = 0

        if type(AimService.GetAimContext) == "function" then
            local original
            local ok, hooked = pcall(hookfunction, AimService.GetAimContext, newcclosure(function(...)
                local native = original(...)
                if not redirectActive() or type(native) ~= "table" then return native end

                local target = getValidatedHookTarget()
                if not target then return native end
                local camera = workspace.CurrentCamera
                if not camera then return native end

                local origin       = typeof(native.originPos)       == "Vector3" and native.originPos       or camera.CFrame.Position
                local cameraOrigin = typeof(native.cameraRayOrigin) == "Vector3" and native.cameraRayOrigin or camera.CFrame.Position

                local worldHit = findVisibleAimPoint(target, cameraOrigin, origin)
                if not worldHit then
                    worldHit = resolveTargetPosition(target)
                end

                local targetChar = target:FindFirstAncestorWhichIsA("Model")
                local targetHRP  = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
                if targetHRP then
                    local okOff, offsetCF = pcall(function()
                        return CFrame.new(targetHRP.CFrame:PointToObjectSpace(worldHit))
                    end)
                    if okOff and offsetCF then
                        getgenv().SilentLastHitOffset = offsetCF
                    end
                end

                local directionDelta = worldHit - origin
                local cameraDelta    = worldHit - cameraOrigin
                if directionDelta.Magnitude <= 0.001 or cameraDelta.Magnitude <= 0.001 then
                    return native
                end

                local redirected = {}
                for key, value in pairs(native) do redirected[key] = value end

                redirected.worldHit        = worldHit
                redirected.direction       = directionDelta.Unit
                redirected.cameraRayOrigin = cameraOrigin
                redirected.cameraRayDir    = cameraDelta.Unit

                local upVector = typeof(native.camCFrame) == "CFrame"
                    and native.camCFrame.UpVector
                    or camera.CFrame.UpVector
                if math.abs(upVector:Dot(cameraDelta.Unit)) > 0.99 then
                    upVector = Vector3.xAxis
                end

                local camOK, redirectedCamera = pcall(CFrame.lookAt, cameraOrigin, worldHit, upVector)
                if camOK and redirectedCamera then
                    redirected.camCFrame = redirectedCamera

                    local viewport = camera.ViewportSize
                    local centerX  = math.floor(viewport.X * 0.5 + 0.5)
                    local centerY  = math.floor(viewport.Y * 0.5 + 0.5)
                    redirected.screenAim    = Vector2.new(centerX, centerY)
                    redirected.rawScreenPos = Vector3.new(centerX, centerY, 0)
                    redirected.inputPos     = Vector3.new(centerX, centerY, 0)
                else

                    local screenPoint = camera:WorldToViewportPoint(worldHit)
                    if screenPoint.Z > 0 then
                        redirected.screenAim    = Vector2.new(screenPoint.X, screenPoint.Y)
                        redirected.rawScreenPos = Vector3.new(screenPoint.X, screenPoint.Y, 0)
                        redirected.inputPos     = Vector3.new(screenPoint.X, screenPoint.Y, 0)
                    end
                end

                return redirected
            end))
            if ok and type(hooked) == "function" then
                original = hooked
                installed += 1
            end
        end

        if type(AimService.GetWorldAim) == "function" then
            local original
            local ok, hooked = pcall(hookfunction, AimService.GetWorldAim, newcclosure(function(...)
                if redirectActive() then
                    local target = getValidatedHookTarget()
                    if target then return resolveTargetPosition(target) end
                end
                return original(...)
            end))
            if ok and type(hooked) == "function" then
                original = hooked
                installed += 1
            end
        end

        if type(AimService.GetScreenAimPos) == "function" then
            local original
            local ok, hooked = pcall(hookfunction, AimService.GetScreenAimPos, newcclosure(function(...)
                if redirectActive() then
                    local target = getValidatedHookTarget()
                    local camera = workspace.CurrentCamera
                    if target and camera then
                        local viewport = camera.ViewportSize
                        return Vector2.new(
                            math.floor(viewport.X * 0.5 + 0.5),
                            math.floor(viewport.Y * 0.5 + 0.5)
                        )
                    end
                end
                return original(...)
            end))
            if ok and type(hooked) == "function" then
                original = hooked
                installed += 1
            end
        end

        if installed > 0 then
            getgenv().SilentAimServiceHooked = true
            getgenv().SilentAimServiceHookVersion = 3
        else
            getgenv().SilentAimServiceHooked = nil
            warn("Se encontró AimService, pero no se pudo conectar")
        end
    end)
end

if not getgenv().SilentReplaySpoofHooked then
    getgenv().SilentReplaySpoofHooked = true

    task.spawn(function()
        local UserInputService = game:GetService("UserInputService")
        local ViewRecorder, ViewCodec
        
        pcall(function()
            ViewRecorder = require(game:GetService("ReplicatedStorage").Client.DeathReplay.ViewRecorder)
            ViewCodec = require(game:GetService("ReplicatedStorage").Modules.Replay.ViewCodec)
        end)
        
        if not ViewRecorder or not ViewCodec then return end

        local function installReplayFunctionOverride(target, key, original, replacement)
            if type(original) ~= "function" or type(replacement) ~= "function" then
                return false, original
            end

            if type(hookfunction) == "function" then
                local hookOk, hookedOriginal = pcall(hookfunction, original, replacement)
                if hookOk and type(hookedOriginal) == "function" then
                    return true, hookedOriginal
                end
            end

            local runtimeEnvironment
            local setReadonlyFunction
            local isReadonlyFunction
            pcall(function() setReadonlyFunction = setreadonly end)
            pcall(function() isReadonlyFunction = isreadonly end)
            if type(setReadonlyFunction) ~= "function" then
                pcall(function()
                    runtimeEnvironment = getgenv()
                    if type(runtimeEnvironment) == "table" then
                        setReadonlyFunction = runtimeEnvironment.setreadonly
                        isReadonlyFunction = isReadonlyFunction or runtimeEnvironment.isreadonly
                    end
                end)
            end

            if type(setReadonlyFunction) == "function" and type(isReadonlyFunction) == "function" then
                local readonlyOk, wasReadonly = pcall(isReadonlyFunction, target)
                if readonlyOk and wasReadonly == true then
                    pcall(setReadonlyFunction, target, false)
                    local assignOk = pcall(function() target[key] = replacement end)
                    pcall(setReadonlyFunction, target, true)
                    if assignOk then
                        return true, original
                    end
                    return false, original
                end
            end

            local assignOk = pcall(function() target[key] = replacement end)
            return assignOk, original
        end

        local old_BuildView = ViewRecorder.BuildView
        local function new_BuildView(self, subjectUserId, fromTime, toTime)
            local result = old_BuildView(self, subjectUserId, fromTime, toTime)
            if not getgenv().SilentHubRunning then return result end
            if type(result) ~= "table" or type(result.frames) ~= "table" or #result.frames == 0 then return result end

            local resultCloneOk, resultCopy = pcall(table.clone, result)
            if not resultCloneOk or type(resultCopy) ~= "table" then return result end
            result = resultCopy

            local writableFrames = {}
            local frameCopies = {}
            for index, frame in ipairs(result.frames) do
                if type(frame) == "table" then
                    local frameCloneOk, frameCopy = pcall(table.clone, frame)
                    if frameCloneOk and type(frameCopy) == "table" then
                        frameCopies[index] = frameCopy
                        writableFrames[frameCopy] = true
                    else
                        frameCopies[index] = frame
                    end
                else
                    frameCopies[index] = frame
                end
            end
            result.frames = frameCopies

            if type(result.touches) == "table" then
                local touchesCloneOk, touchesCopy = pcall(table.clone, result.touches)
                result.touches = touchesCloneOk and type(touchesCopy) == "table" and touchesCopy or {}
            else
                result.touches = {}
            end

            local deviceKey = (Silent.State.Spoof and Silent.State.Spoof.Device) or "Default"
            local profile = getgenv().SilentSpoofProfiles[deviceKey]

            if profile and deviceKey ~= "Default" then
                result.deviceKind = profile.deviceKind
                for _, frame in ipairs(result.frames) do
                    if type(frame) == "table" and writableFrames[frame] then
                        frame.inputMode = profile.inputMode
                    end
                end
                if profile.hideTouch then
                    result.touches = {}
                    result.touchesTruncated = false
                end
            end

            if deviceKey == "Default" and (result.deviceKind == 2 or not result.deviceKind) then
                local shotTimes = getgenv().SilentSpoofShots or {}
                if #shotTimes > 0 then
                    local vpW = tonumber(result.viewportW) or 0
                    local vpH = tonumber(result.viewportH) or 0
                    local endTime = tonumber(toTime) or (result.frames[#result.frames] and tonumber(result.frames[#result.frames].t)) or 0

                    if vpW > 0 and vpH > 0 then
                        local nextTapId = 2
                        for _, shotTime in ipairs(shotTimes) do
                            if type(shotTime) == "number" and shotTime >= (result.frames[1].t or 0) - 0.1 and shotTime <= endTime + 0.1 then
                                local nx, ny
                                if Silent.State.Aim.AutoShoot and not Silent.State.Aim.TriggerBot then

                                    local nearest, bestDelta = nil, math.huge
                                    for _, frame in ipairs(result.frames) do
                                        local ft = tonumber(frame.t)
                                        if ft then
                                            local d = math.abs(ft - shotTime)
                                            if d < bestDelta then bestDelta, nearest = d, frame end
                                        end
                                    end
                                    if nearest then
                                        nx = math.clamp((tonumber(nearest.sx) or 0) / vpW, 0, 1)
                                        ny = math.clamp((tonumber(nearest.sy) or 0) / vpH, 0, 1)
                                    end
                                else

                                    nx = 0.75
                                    ny = 0.5
                                end
                                
                                if nx and ny then

                                    table.insert(result.touches, { t = shotTime - 0.05, id = nextTapId, x = nx, y = ny, phase = 0 })
                                    table.insert(result.touches, { t = shotTime + 0.05, id = nextTapId, x = nx, y = ny, phase = 2 })
                                    nextTapId = nextTapId + 1
                                    if nextTapId > 4 then nextTapId = 2 end
                                end
                            end
                        end
                        table.sort(result.touches, function(a, b) return (a.t or 0) < (b.t or 0) end)
                    end
                end
            end

            return result
        end

        if type(newcclosure) == "function" then new_BuildView = newcclosure(new_BuildView) end
        local buildViewInstalled, originalBuildView = installReplayFunctionOverride(
            ViewRecorder,
            "BuildView",
            old_BuildView,
            new_BuildView
        )
        if buildViewInstalled and type(originalBuildView) == "function" then
            old_BuildView = originalBuildView
        end

        if type(ViewCodec.Encode) == "function" then
            local old_Encode = ViewCodec.Encode
            local function new_Encode(payload)
                if type(payload) == "table" and getgenv().SilentHubRunning then
                    local cloneOk, payloadCopy = pcall(table.clone, payload)
                    if not cloneOk or type(payloadCopy) ~= "table" then
                        return old_Encode(payload)
                    end
                    payload = payloadCopy

                    local deviceKey = (Silent.State.Spoof and Silent.State.Spoof.Device) or "Default"
                    local profile = getgenv().SilentSpoofProfiles[deviceKey]

                    if profile and deviceKey ~= "Default" then
                        payload.deviceKind = profile.deviceKind
                        payload.inputMode = profile.inputMode
                        if profile.hideTouch then
                            payload.touches = {}
                            payload.touchesTruncated = false
                        end
                    end
                end
                return old_Encode(payload)
            end
            if type(newcclosure) == "function" then new_Encode = newcclosure(new_Encode) end
            local encodeInstalled, originalEncode = installReplayFunctionOverride(
                ViewCodec,
                "Encode",
                old_Encode,
                new_Encode
            )
            if encodeInstalled and type(originalEncode) == "function" then
                old_Encode = originalEncode
            end
        end
    end)
end

if not getgenv().SilentHookIndexIniciado then
    getgenv().SilentHookIndexIniciado = true
    local oldI
    oldI = hookmetamethod(game, "__index", function(t, k)
        if getgenv().SilentHubRunning and not checkcaller() and t == mouse and getgenv().SilentWeaponEquipped then
            local aT = getValidatedHookTarget()
            if aT then
                if k == "Hit" or k == "hit" then
                    local aimPos = getAimPoint(aT) or aT.Position
                    return aT.CFrame + (aimPos - aT.Position)
                elseif k == "Target" or k == "target" then
                    return aT
                end
            end
        end
        return oldI(t, k)
    end)
end

if not getgenv().SilentHookIniciado then
    getgenv().SilentHookIniciado = true
    local oldNC
    oldNC = hookmetamethod(game, "__namecall", function(self, ...)
        if getgenv().SilentHubRunning and not checkcaller() and not getgenv().SilentVisCheckActive and self == workspace and getgenv().SilentWeaponEquipped then
            local m = getnamecallmethod()
            if m == "Raycast" or m == "FindPartOnRay" or m == "FindPartOnRayWithIgnoreList" or m == "FindPartOnRayWithWhitelist" then

                local aT = getValidatedHookTarget()
                if aT then
                    local cO   = workspace.CurrentCamera.CFrame.Position
                    local args = {...}
                    if m == "Raycast" then
                        local o, d = args[1], args[2]
                        if (o - cO).Magnitude >= 0.5 and d.Magnitude > 1.0 then
                            return oldNC(self, o, (aT.Position - o).Unit * 1000, args[3])
                        end
                    else
                        local r = args[1]
                        if (r.Origin - cO).Magnitude >= 0.5 and r.Direction.Magnitude > 1.0 then
                            return oldNC(self, Ray.new(r.Origin, (aT.Position - r.Origin).Unit * 1000), args[2], args[3], args[4])
                        end
                    end
                end
            end
        end
        return oldNC(self, ...)
    end)
end

local aESPs = {}
local aTracers = {}

local aArrows = setmetatable({}, {__mode = "k"})

local cleanArrow
SourceZones.ESP.Arrows.cleanArrow = function(targetPlayer, destroy)
    local arrow = aArrows[targetPlayer]
    if not arrow then return end
    pcall(function() arrow.Visible = false end)
    if destroy then
        aArrows[targetPlayer] = nil
        pcall(function() arrow:Destroy() end)
    end
end
cleanArrow = SourceZones.ESP.Arrows.cleanArrow

local drawOffscreenArrow
SourceZones.ESP.Arrows.drawOffscreenArrow = function(targetPlayer, screenPosition, viewportSize)
    local center = viewportSize / 2
    local direction = Vector2_new(screenPosition.X, screenPosition.Y) - center
    if screenPosition.Z < 0 then
        direction = -direction
    end
    if direction.Magnitude < 1 then
        cleanArrow(targetPlayer)
        return
    end

    local unit = direction.Unit
    local radius = math.min(viewportSize.X, viewportSize.Y) / 2 - 40
    local position = center + unit * radius

    local arrow = aArrows[targetPlayer]
    if not arrow or not arrow.Parent then
        arrow = Instance.new("TextLabel")
        arrow.Name = "SilentHubOffscreenArrow"
        arrow.BackgroundTransparency = 1
        arrow.AnchorPoint = Vector2_new(0.5, 0.5)
        arrow.Size = UDim2.fromOffset(20, 20)
        arrow.Font = Enum.Font.GothamBold
        arrow.Text = "▲"
        arrow.TextColor3 = Color3.new(1, 1, 1)
        arrow.TextStrokeTransparency = 0.35
        arrow.Visible = false
        arrow.Parent = screenGui
        aArrows[targetPlayer] = arrow
    end

    arrow.Position = UDim2.fromOffset(position.X, position.Y)
    arrow.Rotation = math.deg(math.atan2(unit.Y, unit.X)) + 90
    arrow.TextColor3 = Silent.State.Vis.Color
    arrow.TextSize = 18
    arrow.Visible = true
end
drawOffscreenArrow = SourceZones.ESP.Arrows.drawOffscreenArrow

local espPlayerLifecycleConnections = {}

local cleanESP
SourceZones.ESP.Rendering.cleanESP = function(targetPlayer)
    local entry = aESPs[targetPlayer]
    if not entry then return end
    aESPs[targetPlayer] = nil

    if entry.H then
        pcall(function()
            entry.H.Adornee = nil
            entry.H.Enabled = false
        end)
        Silent.Pool:Release("Highlight", entry.H)
    end

    if entry.B then
        pcall(function()
            entry.B.Adornee = nil
            entry.B.Enabled = false
            local label = entry.B:FindFirstChild("Text")
            if label and label:IsA("TextLabel") then label.Text = "" end
        end)
        Silent.Pool:Release("BillboardGui", entry.B)
    end
end
cleanESP = SourceZones.ESP.Rendering.cleanESP

local cleanTracer
SourceZones.ESP.Rendering.cleanTracer = function(targetPlayer)
    local tracer = aTracers[targetPlayer]
    if not tracer then return end
    aTracers[targetPlayer] = nil
    pcall(function() tracer.Visible = false end)
    Silent.Pool:Release("DrawingLine", tracer)
end
cleanTracer = SourceZones.ESP.Rendering.cleanTracer

local cleanAllESPDrawings
SourceZones.ESP.Rendering.cleanAllESPDrawings = function()
    for targetPlayer in pairs(aESPs) do cleanESP(targetPlayer) end
    for targetPlayer in pairs(aTracers) do cleanTracer(targetPlayer) end
    for targetPlayer in pairs(aArrows) do cleanArrow(targetPlayer) end
end
cleanAllESPDrawings = SourceZones.ESP.Rendering.cleanAllESPDrawings

Silent.ESP = Silent.ESP or {}
Silent.ESP.ClearDrawings = cleanAllESPDrawings

local disconnectESPPlayerLifecycle
SourceZones.ESP.Lifecycle.disconnectESPPlayerLifecycle = function(targetPlayer)
    local connections = espPlayerLifecycleConnections[targetPlayer]
    espPlayerLifecycleConnections[targetPlayer] = nil
    if not connections then return end
    for _, connection in ipairs(connections) do
        if connection then pcall(function() connection:Disconnect() end) end
    end
end
disconnectESPPlayerLifecycle = SourceZones.ESP.Lifecycle.disconnectESPPlayerLifecycle

local cleanupESPPlayer
SourceZones.ESP.Rendering.cleanupESPPlayer = function(targetPlayer)
    cleanESP(targetPlayer)
    cleanTracer(targetPlayer)
    cleanArrow(targetPlayer, true)
    disconnectESPPlayerLifecycle(targetPlayer)
end
cleanupESPPlayer = SourceZones.ESP.Rendering.cleanupESPPlayer

local bindESPPlayerLifecycle
SourceZones.ESP.Lifecycle.bindESPPlayerLifecycle = function(targetPlayer)
    if not targetPlayer or targetPlayer == player or espPlayerLifecycleConnections[targetPlayer] then return end

    local connections = {}
    espPlayerLifecycleConnections[targetPlayer] = connections
    table.insert(connections, Silent.Resources:TrackConn(targetPlayer.CharacterRemoving:Connect(function()
        cleanESP(targetPlayer)
        cleanTracer(targetPlayer)
        cleanArrow(targetPlayer)
    end)))
    table.insert(connections, Silent.Resources:TrackConn(targetPlayer.CharacterAdded:Connect(function()
        cleanESP(targetPlayer)
        cleanTracer(targetPlayer)
        cleanArrow(targetPlayer)
    end)))
end
bindESPPlayerLifecycle = SourceZones.ESP.Lifecycle.bindESPPlayerLifecycle

for _, targetPlayer in ipairs(Players:GetPlayers()) do
    bindESPPlayerLifecycle(targetPlayer)
end

Silent.Resources:TrackConn(Players.PlayerAdded:Connect(bindESPPlayerLifecycle))
Silent.Resources:TrackConn(Players.PlayerRemoving:Connect(cleanupESPPlayer))

Silent.Scheduler:Register("ESPUpdate", 15, function()
    for targetPlayer in pairs(aESPs) do
        if targetPlayer.Parent ~= Players then
            cleanESP(targetPlayer)
            cleanArrow(targetPlayer, true)
        end
    end
    for targetPlayer in pairs(aTracers) do
        if targetPlayer.Parent ~= Players then cleanTracer(targetPlayer) end
    end
    for targetPlayer in pairs(aArrows) do
        if targetPlayer.Parent ~= Players then cleanArrow(targetPlayer) end
    end

    if not getgenv().SilentHubRunning or not Silent.State.Vis.ESP or not Silent.State.MatchActive then
        cleanAllESPDrawings()
        return
    end

    local espCount = 0
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p == player then continue end
        
        if not isValidForESP(p) then
            cleanESP(p)
            cleanTracer(p)
            cleanArrow(p)
            continue
        end
        
        espCount = espCount + 1
        if espCount > MAX_ESP_TARGETS then
            cleanESP(p)
            cleanTracer(p)
            cleanArrow(p)
            continue
        end
        
        local c = p.Character
        local h = c:FindFirstChild("Humanoid")
        local hrp = c.PrimaryPart
        
        if not aESPs[p] then
            aESPs[p] = { H = Silent.Pool:Get("Highlight"), B = Silent.Pool:Get("BillboardGui"), LastDist = -1 }
        end
        
        local e = aESPs[p]
        if e.H then
            if e.H.Adornee ~= c then e.H.Adornee = c end
            if e.H.OutlineColor ~= Silent.State.Vis.Color then e.H.OutlineColor = Silent.State.Vis.Color end
            local glowEnabled = Silent.State.Vis.Glow == true
            if e.H.Enabled ~= glowEnabled then e.H.Enabled = glowEnabled end
        end
        
        if e.B and hrp then
            if e.B.Adornee ~= hrp then e.B.Adornee = hrp end
            local localPos = player.Character and player.Character.PrimaryPart and player.Character.PrimaryPart.Position or Vector3_new(0, 0, 0)
            local dist = (hrp.Position - localPos).Magnitude
            
            local txt = ""
            if Silent.State.Vis.Name then txt = string.format('<font color="#%02X%02X%02X">%s</font>', Silent.State.Vis.Color.R*255, Silent.State.Vis.Color.G*255, Silent.State.Vis.Color.B*255, p.Name) end
            if Silent.State.Vis.Dist and e.LastDist ~= dist then txt = txt .. (txt=="" and "" or "\n") .. string.format('<font size="11" color="#bdc3c7">%dm</font>', math.floor(dist)) e.LastDist = dist end
            if txt ~= "" then if not e.B.Enabled then e.B.Enabled = true end if e.B.Text.Text ~= txt then e.B.Text.Text = txt end else if e.B.Enabled then e.B.Enabled = false end end
        end
    end
end, 60)

local FOVCircle = nil 
pcall(function() FOVCircle = Drawing.new("Circle") FOVCircle.Filled = false FOVCircle.Visible = false FOVCircle.Thickness = 1 Silent.Resources:TrackDraw(FOVCircle) end)

local lastESPRender = 0
Silent.Resources:TrackConn(RunService.RenderStepped:Connect(function()
    if not getgenv().SilentHubRunning then return end
    local aAim = Silent.State.Aim.SilentAim or Silent.State.Aim.AutoShoot
    local nowESP = os.clock()
    if nowESP - lastESPRender < (1 / 30) then return end
    lastESPRender = nowESP
    local aT = (getgenv().SilentTargetLock and os.clock() < (getgenv().SilentLockExpiration or 0)) and getgenv().SilentTargetLock or getgenv().SilentTargetPart
    local currentCam = workspace.CurrentCamera
    if not currentCam then
        cleanAllESPDrawings()
        if FOVCircle then pcall(function() FOVCircle.Visible = false end) end
        return
    end

    if FOVCircle and Silent.State.Aim.FovVisible and Silent.State.IsPlaying and aAim and Silent.State.Aim.Mode == "FOV" then
        FOVCircle.Position = getFOVCenter(currentCam)
        FOVCircle.Radius = Silent.State.Aim.FovRadius
        FOVCircle.Visible = true
        FOVCircle.Color = aT and Color3.fromRGB(255,0,0) or Color3.fromRGB(255,255,255)
    else if FOVCircle and FOVCircle.Visible then FOVCircle.Visible = false end end

    if not getgenv().SilentHubRunning or not Silent.State.Vis.ESP or not Silent.State.MatchActive then
        cleanAllESPDrawings()
        return
    end

    local localCharacter = player.Character
    local localRoot = localCharacter and localCharacter.PrimaryPart
    local localPosition = localRoot and localRoot.Position or currentCam.CFrame.Position
    local centerX = currentCam.ViewportSize.X / 2
    local viewportSize = currentCam.ViewportSize

    for targetPlayer in pairs(aTracers) do
        if targetPlayer.Parent ~= Players or not Silent.State.Vis.Lines then
            cleanTracer(targetPlayer)
        end
    end
    for targetPlayer in pairs(aArrows) do
        if targetPlayer.Parent ~= Players or not Silent.State.Vis.Arrows then
            cleanArrow(targetPlayer)
        end
    end

    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer == player then continue end

        local character = targetPlayer.Character
        local root = character and character.PrimaryPart
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local valid = root and humanoid and humanoid.Health > 0
            and isPlayerInActiveMatch(targetPlayer) and isEnemy(targetPlayer)

        if not valid then
            cleanTracer(targetPlayer)
            cleanArrow(targetPlayer)
            continue
        end

        local distance = (localPosition - root.Position).Magnitude
        if Silent.State.Gfx.SmartRender and distance > Silent.State.Gfx.RenderDist then
            cleanTracer(targetPlayer)
            cleanArrow(targetPlayer)
            continue
        end

        local screenPosition, onScreen = currentCam:WorldToViewportPoint(root.Position)
        local offscreen = not onScreen or screenPosition.Z <= 0
            or screenPosition.X < 0 or screenPosition.Y < 0
            or screenPosition.X > viewportSize.X or screenPosition.Y > viewportSize.Y

        if Silent.State.Vis.Lines and not offscreen then
            local tracer = aTracers[targetPlayer]
            if not tracer then
                tracer = Silent.Pool:Get("DrawingLine")
                if tracer then aTracers[targetPlayer] = tracer end
            end
            if tracer then
                pcall(function()
                    tracer.From = Vector2_new(centerX, 0)
                    tracer.To = Vector2_new(screenPosition.X, screenPosition.Y)
                    tracer.Color = Silent.State.Vis.Color
                    tracer.Visible = true
                end)
            end
        else
            cleanTracer(targetPlayer)
        end

        if Silent.State.Vis.Arrows and offscreen then
            drawOffscreenArrow(targetPlayer, screenPosition, viewportSize)
        else
            cleanArrow(targetPlayer)
        end
    end
end))

local isNHLooping = false 
local nOrig = setmetatable({}, {__mode = "k"})
local nConns = {}

local procTxt
SourceZones.Graphics.Performance.procTxt = function(v, mN, mD)
    local pG = v:FindFirstAncestorWhichIsA("ScreenGui") if pG and string.find(pG.Name, "Silent") then return end
    if v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("TextButton") then
        local t = v.Text local has = false if t and t ~= "" then if string.find(t, mN, 1, true) or string.find(t, mD, 1, true) then has = true end end
        if has and not nOrig[v] then nOrig[v] = {T=t, TT=v.TextTransparency, ST=v.TextStrokeTransparency, Str={}} for _,o in ipairs(v:GetChildren()) do if o:IsA("UIStroke") then nOrig[v].Str[o] = {E=o.Enabled} end end end
        if nOrig[v] then
            if Silent.State.Vis.HideName then v.Text = " " v.TextTransparency = 1 v.TextStrokeTransparency = 1 for _,o in pairs(v:GetChildren()) do if o:IsA("UIStroke") then o.Enabled = false end end
            else v.Text = nOrig[v].T v.TextTransparency = nOrig[v].TT v.TextStrokeTransparency = nOrig[v].ST for _,o in pairs(v:GetChildren()) do if o:IsA("UIStroke") and nOrig[v].Str[o] then o.Enabled = nOrig[v].Str[o].E end end end
        end
    end
end
procTxt = SourceZones.Graphics.Performance.procTxt

Silent.Events:Sub("UpdateHideName", "Vis", function(isCleanup)
    if isCleanup then Silent.State.Vis.HideName = false end
    local mN, mD = player.Name, player.DisplayName
    task.spawn(function() for _,p in ipairs(Players:GetPlayers()) do if p.Character then for _,v in pairs(p.Character:GetDescendants()) do procTxt(v, mN, mD) end end end local pG = player:FindFirstChild("PlayerGui") if pG then for _,v in pairs(pG:GetDescendants()) do procTxt(v, mN, mD) end end end)
    if Silent.State.Vis.HideName then
        if not isNHLooping then
            isNHLooping = true
            local function inf(v) local pG = v:FindFirstAncestorWhichIsA("ScreenGui") if pG and string.find(pG.Name, "Silent") then return end if v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("TextButton") then procTxt(v, mN, mD) if not v:GetAttribute("SI") then v:SetAttribute("SI", true) table.insert(nConns, Silent.Resources:TrackConn(v:GetPropertyChangedSignal("Text"):Connect(function() if isNHLooping and v.Text ~= " " then nOrig[v] = nil procTxt(v, mN, mD) end end))) end end end
            local pG = player:FindFirstChild("PlayerGui") if pG then table.insert(nConns, Silent.Resources:TrackConn(pG.DescendantAdded:Connect(function(n) if isNHLooping and (n:IsA("TextLabel") or n:IsA("TextBox") or n:IsA("TextButton")) then task.spawn(function() inf(n) end) end end))) end
        end
    else
        isNHLooping = false for _,c in ipairs(nConns) do pcall(function() c:Disconnect() end) end nConns = {}
        for v, d in pairs(nOrig) do if v and v.Parent then v.Text = d.T v.TextTransparency = d.TT v.TextStrokeTransparency = d.ST for str, sD in pairs(d.Str) do if str and str.Parent then str.Enabled = sD.E end end end end
    end
end)

local GraphicsEngine = {
    Low = { Active = false, Objects = setmetatable({}, { __mode = "k" }) },
    Boost = { Active = false, Objects = setmetatable({}, { __mode = "k" }) },
    ProtectedRoots = setmetatable({}, { __mode = "k" }),
    ScanRunning = false,
    Scan = {
        Running = false,
        Generation = 0,
        NeedsFullScan = false,
        Queue = {},
        Head = 1,
        Tail = 0,
        Queued = setmetatable({}, { __mode = "k" }),
        Seen = setmetatable({}, { __mode = "k" }),
    },
}

local graphicsSkipNames = {
    dualwieldguncopies = true,
    gunparts = true,
    gunpartsfolder = true,
    vfx = true,
    bullets = true,
    effects = true,
}

local graphicsAnyActive
SourceZones.Graphics.SmartRender.graphicsAnyActive = function()
    return GraphicsEngine.Low.Active or GraphicsEngine.Boost.Active
end
graphicsAnyActive = SourceZones.Graphics.SmartRender.graphicsAnyActive

local graphicsNameIsIgnored
SourceZones.Graphics.SmartRender.graphicsNameIsIgnored = function(name)
    local lower = string.lower(tostring(name or ""))
    if graphicsSkipNames[lower] then return true end
    return string.find(lower, "beam", 1, true) ~= nil
        or string.find(lower, "vfx", 1, true) ~= nil
        or string.find(lower, "bullet", 1, true) ~= nil
        or string.find(lower, "effect", 1, true) ~= nil
        or string.find(lower, "gunparts", 1, true) ~= nil
end
graphicsNameIsIgnored = SourceZones.Graphics.SmartRender.graphicsNameIsIgnored

local graphicsRestoreStoreObject
SourceZones.Graphics.SmartRender.graphicsRestoreStoreObject = function(store, instance)
    local saved = store[instance]
    if not saved then return end
    if instance and instance.Parent then
        for propertyName, record in pairs(saved) do
            pcall(function()
                if instance[propertyName] == record.Applied then
                    instance[propertyName] = record.Original
                end
            end)
        end
    end
    store[instance] = nil
end
graphicsRestoreStoreObject = SourceZones.Graphics.SmartRender.graphicsRestoreStoreObject

local graphicsRestoreCharacterTree
SourceZones.Graphics.SmartRender.graphicsRestoreCharacterTree = function(characterModel)
    if not characterModel then return end
    for _, store in ipairs({ GraphicsEngine.Low.Objects, GraphicsEngine.Boost.Objects }) do
        local matches = {}
        for instance in pairs(store) do
            local inside = false
            pcall(function()
                inside = instance == characterModel or instance:IsDescendantOf(characterModel)
            end)
            if inside then matches[#matches + 1] = instance end
        end
        for _, instance in ipairs(matches) do
            graphicsRestoreStoreObject(store, instance)
        end
    end
end
graphicsRestoreCharacterTree = SourceZones.Graphics.SmartRender.graphicsRestoreCharacterTree

local graphicsProtectCharacter
SourceZones.Graphics.SmartRender.graphicsProtectCharacter = function(characterModel)
    if not characterModel or GraphicsEngine.ProtectedRoots[characterModel] then return end
    GraphicsEngine.ProtectedRoots[characterModel] = true
    graphicsRestoreCharacterTree(characterModel)
end
graphicsProtectCharacter = SourceZones.Graphics.SmartRender.graphicsProtectCharacter

local graphicsFindCharacterRoot
SourceZones.Graphics.SmartRender.graphicsFindCharacterRoot = function(instance)
    if not instance then return nil end
    local okHumanoid, isHumanoid = pcall(function() return instance:IsA("Humanoid") end)
    if okHumanoid and isHumanoid then
        local parent = instance.Parent
        if parent and parent:IsA("Model") then return parent end
    end

    local current = instance
    while current and current ~= game do
        if GraphicsEngine.ProtectedRoots[current] then return current end
        local isModel = false
        pcall(function() isModel = current:IsA("Model") end)
        if isModel then
            local isCharacter = false
            pcall(function()
                isCharacter = Players:GetPlayerFromCharacter(current) ~= nil
                    or current:FindFirstChildOfClass("Humanoid") ~= nil
            end)
            if isCharacter then return current end
        end
        current = current.Parent
    end
    return nil
end
graphicsFindCharacterRoot = SourceZones.Graphics.SmartRender.graphicsFindCharacterRoot

local graphicsCheckNewCharacterPart
SourceZones.Graphics.SmartRender.graphicsCheckNewCharacterPart = function(instance)
    local characterModel = graphicsFindCharacterRoot(instance)
    if characterModel then graphicsProtectCharacter(characterModel) end
end
graphicsCheckNewCharacterPart = SourceZones.Graphics.SmartRender.graphicsCheckNewCharacterPart

local graphicsShouldPruneBranch
SourceZones.Graphics.SmartRender.graphicsShouldPruneBranch = function(instance)
    if instance == workspace or instance == Lighting then return false end
    local ok, className, name = pcall(function() return instance.ClassName, instance.Name end)
    if not ok then return true end
    if className == "Humanoid" then
        local parent = instance.Parent
        if parent and parent:IsA("Model") then graphicsProtectCharacter(parent) end
        return true
    end
    if className == "Tool" then return true end
    if className == "Model" then
        local characterModel = graphicsFindCharacterRoot(instance)
        if characterModel == instance then
            graphicsProtectCharacter(instance)
            return true
        end
    end
    return graphicsNameIsIgnored(name)
end
graphicsShouldPruneBranch = SourceZones.Graphics.SmartRender.graphicsShouldPruneBranch

local graphicsShouldIgnore
SourceZones.Graphics.SmartRender.graphicsShouldIgnore = function(instance)
    if not instance then return true end
    local characterModel = graphicsFindCharacterRoot(instance)
    if characterModel then
        graphicsProtectCharacter(characterModel)
        return true
    end
    if graphicsNameIsIgnored(instance.Name) then return true end

    local current = instance.Parent
    while current and current ~= game do
        if GraphicsEngine.ProtectedRoots[current] then return true end
        if graphicsNameIsIgnored(current.Name) then return true end
        current = current.Parent
    end
    return false
end
graphicsShouldIgnore = SourceZones.Graphics.SmartRender.graphicsShouldIgnore

local graphicsApplyStore
SourceZones.Graphics.SmartRender.graphicsApplyStore = function(store, instance, desired)
    local saved = store[instance]
    if not saved and next(desired) == nil then return end
    if not saved then
        saved = {}
        store[instance] = saved
    end

    for propertyName, record in pairs(saved) do
        if desired[propertyName] == nil then
            pcall(function()
                if instance[propertyName] == record.Applied then
                    instance[propertyName] = record.Original
                end
            end)
            saved[propertyName] = nil
        end
    end

    for propertyName, targetValue in pairs(desired) do
        local record = saved[propertyName]
        if not record then
            local readOK, original = pcall(function() return instance[propertyName] end)
            if readOK and original ~= targetValue then
                record = { Original = original, Applied = targetValue }
                saved[propertyName] = record
            end
        else
            record.Applied = targetValue
        end

        if record then
            pcall(function()
                if instance[propertyName] ~= targetValue then
                    instance[propertyName] = targetValue
                end
            end)
        end
    end

    if next(saved) == nil then store[instance] = nil end
end
graphicsApplyStore = SourceZones.Graphics.SmartRender.graphicsApplyStore

local graphicsApplyObject
SourceZones.Graphics.SmartRender.graphicsApplyObject = function(instance)
    if not instance or (instance ~= workspace and instance ~= Lighting and not instance.Parent) then return end
    if instance ~= workspace and instance ~= Lighting and graphicsShouldIgnore(instance) then return end

    local lowDesired = {}
    if GraphicsEngine.Low.Active then
        pcall(function()
            if instance:IsA("MeshPart") then
                lowDesired.TextureID = ""
            elseif instance:IsA("SpecialMesh") then
                lowDesired.TextureId = ""
            elseif instance:IsA("Decal") or instance:IsA("Texture") then
                lowDesired.Transparency = 1
            end
        end)
    end
    graphicsApplyStore(GraphicsEngine.Low.Objects, instance, lowDesired)

    local boostDesired = {}
    if GraphicsEngine.Boost.Active then
        pcall(function()
            if instance == Lighting then
                boostDesired.GlobalShadows = false
            elseif instance:IsA("BasePart") then
                boostDesired.Material = Enum.Material.SmoothPlastic
                boostDesired.Reflectance = 0
                boostDesired.CastShadow = false
            elseif instance:IsA("ParticleEmitter") or instance:IsA("Trail") or instance:IsA("Beam")
                or instance:IsA("Fire") or instance:IsA("Smoke") or instance:IsA("Sparkles")
                or instance:IsA("Light") or instance:IsA("PostEffect") then
                if not instance:IsA("PostEffect") or instance.Parent == Lighting or instance.Parent == workspace.CurrentCamera then
                    boostDesired.Enabled = false
                end
            end
        end)
    end
    graphicsApplyStore(GraphicsEngine.Boost.Objects, instance, boostDesired)
end
graphicsApplyObject = SourceZones.Graphics.SmartRender.graphicsApplyObject

local graphicsCanContainChildren
SourceZones.Graphics.SmartRender.graphicsCanContainChildren = function(instance)
    return instance == workspace or instance == Lighting
        or instance:IsA("Folder") or instance:IsA("Model") or instance:IsA("BasePart")
        or instance:IsA("Attachment") or instance:IsA("Accessory") or instance:IsA("Tool")
        or instance:IsA("Camera") or instance:IsA("Terrain") or instance:IsA("WorldModel")
end
graphicsCanContainChildren = SourceZones.Graphics.SmartRender.graphicsCanContainChildren

local graphicsScanTree
SourceZones.Graphics.SmartRender.graphicsScanTree = function(root, generation)
    local scan = GraphicsEngine.Scan
    local stack = { root }
    local batchCount = 0
    local batchStarted = os.clock()
    local mobile = false
    pcall(function() mobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled end)
    local batchLimit = mobile and 64 or 192
    local timeBudget = mobile and 0.0015 or 0.0025

    while #stack > 0 do
        if generation ~= scan.Generation or not graphicsAnyActive() or not getgenv().SilentHubRunning then
            return false
        end

        local instance = table.remove(stack)
        if instance and not scan.Seen[instance] then
            scan.Seen[instance] = true
            if not graphicsShouldPruneBranch(instance) then
                graphicsApplyObject(instance)
                if graphicsCanContainChildren(instance) then
                    local childrenOK, children = pcall(function() return instance:GetChildren() end)
                    if childrenOK then
                        for index = #children, 1, -1 do
                            stack[#stack + 1] = children[index]
                        end
                    end
                end
            end
        end

        batchCount += 1
        if batchCount >= batchLimit or (batchCount >= 8 and os.clock() - batchStarted >= timeBudget) then
            local frameTime = RunService.Heartbeat:Wait()
            if frameTime > 0.045 then
                batchLimit = math.max(24, math.floor(batchLimit * 0.5))
                timeBudget = math.max(0.0008, timeBudget * 0.65)
            elseif frameTime < 0.022 then
                batchLimit = math.min(mobile and 96 or 320, math.floor(batchLimit * 1.2))
                timeBudget = math.min(mobile and 0.002 or 0.004, timeBudget * 1.1)
            end
            batchCount = 0
            batchStarted = os.clock()
        end
    end
    return generation == scan.Generation and graphicsAnyActive()
end
graphicsScanTree = SourceZones.Graphics.SmartRender.graphicsScanTree

local graphicsStartWorker
local graphicsPopDynamic
SourceZones.Graphics.SmartRender.graphicsPopDynamic = function()
    local scan = GraphicsEngine.Scan
    if scan.Head > scan.Tail then return nil end
    local instance = scan.Queue[scan.Head]
    scan.Queue[scan.Head] = nil
    scan.Head += 1
    if instance then scan.Queued[instance] = nil end
    if scan.Head > scan.Tail then
        scan.Queue = {}
        scan.Head, scan.Tail = 1, 0
    end
    return instance
end
graphicsPopDynamic = SourceZones.Graphics.SmartRender.graphicsPopDynamic

graphicsStartWorker = function()
    local scan = GraphicsEngine.Scan
    if not GraphicsEngine.ScanRunning then
        GraphicsEngine.ScanRunning = true
    else
        return
    end
    scan.Running = true

    task.spawn(function()
        local ok, err = xpcall(function()
            while getgenv().SilentHubRunning and graphicsAnyActive()
                and (scan.NeedsFullScan or scan.Head <= scan.Tail) do
                if scan.NeedsFullScan then
                    scan.NeedsFullScan = false
                    local generation = scan.Generation
                    scan.Seen = setmetatable({}, { __mode = "k" })
                    local complete = graphicsScanTree(workspace, generation)
                    if complete and generation == scan.Generation then
                        complete = graphicsScanTree(Lighting, generation)
                    end
                    if not complete and generation ~= scan.Generation and graphicsAnyActive() then
                        scan.NeedsFullScan = true
                    end
                else
                    local instance = graphicsPopDynamic()
                    if instance and not scan.Seen[instance] then
                        local generation = scan.Generation
                        local complete = graphicsScanTree(instance, generation)
                        if not complete and generation ~= scan.Generation and graphicsAnyActive() then
                            scan.NeedsFullScan = true
                        end
                    end
                end
            end
        end, debug.traceback)

        scan.Running = false
        GraphicsEngine.ScanRunning = false
        if not ok and getgenv().SilentHubRunning then
            warn("[SilentHub] graphics worker failed: " .. tostring(err))
        end
        if getgenv().SilentHubRunning and graphicsAnyActive()
            and (scan.NeedsFullScan or scan.Head <= scan.Tail) then
            graphicsStartWorker()
        end
    end)
end

local graphicsQueueDynamic
SourceZones.Graphics.SmartRender.graphicsQueueDynamic = function(instance)
    local scan = GraphicsEngine.Scan
    if not graphicsAnyActive() or not instance or not instance.Parent
        or scan.Queued[instance] or scan.Seen[instance] or graphicsShouldIgnore(instance) then
        return
    end

    if scan.Tail - scan.Head >= 4096 then
        scan.Queue = {}
        scan.Head, scan.Tail = 1, 0
        scan.Generation += 1
        scan.NeedsFullScan = true
    else
        scan.Tail += 1
        scan.Queue[scan.Tail] = instance
        scan.Queued[instance] = true
    end
    graphicsStartWorker()
end
graphicsQueueDynamic = SourceZones.Graphics.SmartRender.graphicsQueueDynamic

local graphicsRestoreAll
SourceZones.Graphics.SmartRender.graphicsRestoreAll = function(force)
    local scanGeneration = GraphicsEngine.Scan.Generation
    task.spawn(function()
        local restored = 0
        for _, store in ipairs({ GraphicsEngine.Low.Objects, GraphicsEngine.Boost.Objects }) do
            local instances = {}
            for instance in pairs(store) do instances[#instances + 1] = instance end
            for _, instance in ipairs(instances) do
                if not force and (scanGeneration ~= GraphicsEngine.Scan.Generation or graphicsAnyActive()) then return end
                graphicsRestoreStoreObject(store, instance)
                restored += 1
                if restored % 64 == 0 then RunService.Heartbeat:Wait() end
            end
        end
    end)
end
graphicsRestoreAll = SourceZones.Graphics.SmartRender.graphicsRestoreAll

local graphicsSetMode
SourceZones.Graphics.SmartRender.graphicsSetMode = function(mode, enabled)
    local setting = GraphicsEngine[mode]
    if not setting then return end
    enabled = enabled == true
    if setting.Active == enabled then return end
    setting.Active = enabled

    local scan = GraphicsEngine.Scan
    scan.Generation += 1
    if graphicsAnyActive() then
        scan.NeedsFullScan = true
        graphicsStartWorker()
    else
        scan.NeedsFullScan = false
        scan.Queue = {}
        scan.Head, scan.Tail = 1, 0
        scan.Queued = setmetatable({}, { __mode = "k" })
        graphicsRestoreAll(false)
    end
end
graphicsSetMode = SourceZones.Graphics.SmartRender.graphicsSetMode

local graphicsBindPlayerCharacter
SourceZones.Graphics.SmartRender.graphicsBindPlayerCharacter = function(targetPlayer)
    if targetPlayer.Character then graphicsProtectCharacter(targetPlayer.Character) end
    Silent.Resources:TrackConn(targetPlayer.CharacterAdded:Connect(function(character)
        graphicsProtectCharacter(character)
    end))
end
graphicsBindPlayerCharacter = SourceZones.Graphics.SmartRender.graphicsBindPlayerCharacter

for _, targetPlayer in ipairs(Players:GetPlayers()) do graphicsBindPlayerCharacter(targetPlayer) end
Silent.Resources:TrackConn(Players.PlayerAdded:Connect(graphicsBindPlayerCharacter))

local graphicsOnDescendantAdded
SourceZones.Graphics.SmartRender.graphicsOnDescendantAdded = function(instance)
    if not graphicsAnyActive() then return end
    graphicsCheckNewCharacterPart(instance)
    graphicsQueueDynamic(instance)
end
graphicsOnDescendantAdded = SourceZones.Graphics.SmartRender.graphicsOnDescendantAdded

Silent.Resources:TrackConn(workspace.DescendantAdded:Connect(graphicsOnDescendantAdded))
Silent.Resources:TrackConn(Lighting.DescendantAdded:Connect(graphicsOnDescendantAdded))

getgenv().SilentHubGraphicsRestore = function()
    GraphicsEngine.Low.Active = false
    GraphicsEngine.Boost.Active = false
    GraphicsEngine.Scan.Generation += 1
    GraphicsEngine.Scan.NeedsFullScan = false
    graphicsRestoreAll(true)
end

Silent.Events:Sub("ToggleLowGfx", "GFX", function(enabled)
    Silent.Events:Emit("Toast", enabled and "Activando: LowGraphics" or "Desactivando: LowGraphics")
    graphicsSetMode("Low", enabled)
end)

Silent.Events:Sub("ToggleBoostFps", "GFX", function(enabled)
    Silent.Events:Emit("Toast", enabled and "Activando: BoostFps" or "Desactivando: BoostFps")
    graphicsSetMode("Boost", enabled)
end)

Silent.Events:Sub("ToggleSmartRender", "GFX", function(enabled)
    Silent.State.Gfx.SmartRender = enabled == true
    Silent.Events:Emit("Toast", enabled and "SmartRender activado: límite de distancia ESP activo" or "SmartRender desactivado")
end)


local statsC = ContainerManager.new("Frame", "GUI")
statsC.Name = "StatsPanel"
statsC.Size = UDim2.new(0, 120, 0, 38)

statsC.AnchorPoint = Vector2.new(0, 0)
do
    local ok, inset = pcall(function() return GuiService:GetGuiInset() end)
    local topInset = (ok and inset and inset.Y or 0)
    statsC.Position = UDim2.new(0, 10, 0, math.max(42, topInset + 6))
end
statsC.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
statsC.BackgroundTransparency = 0.5
statsC.Visible = false
statsC.ZIndex = 100
statsC.Parent = screenGui
Instance.new("UICorner", statsC).CornerRadius = UDim.new(0, 8)

local statsText = Instance.new("TextLabel", statsC)
statsText.Size = UDim2.new(1, 0, 1, 0)
statsText.BackgroundTransparency = 1
statsText.TextColor3 = Color3.fromRGB(0, 255, 0)
statsText.Font = Enum.Font.Code
statsText.TextSize = 12
statsText.Text = "FPS: 0 | Ping: 0"

Silent.Events:Sub("UpdateStatsUI", "UI", function(fps, ping)
    statsText.Text = "FPS: " .. tostring(fps) .. " | Ping: " .. tostring(ping)
end)


local Window
local WindUI
local windUILoadError

do

local version = "1.6.66"
local uiFile = "WindUI_Cache_v" .. version .. ".txt"
local timeFile = "WindUI_Cache_v" .. version .. "_Time.txt"
local libraryUrl = "https://github.com/Footagesus/WindUI/releases/download/"
    .. version .. "/main.lua"
local WINDUI_CACHE_TTL = 86400

local resolveRuntimeFunction
SourceZones.Runtime.Loader.resolveRuntimeFunction = function(name)
    local value
    pcall(function()
        value = rawget(_G, name)
    end)
    if type(value) == "function" then
        return value
    end
    pcall(function()
        if type(getgenv) == "function" then
            local runtimeEnv = getgenv()
            if type(runtimeEnv) == "table" then
                value = runtimeEnv[name]
            end
        end
    end)
    if type(value) == "function" then
        return value
    end
    return nil
end
resolveRuntimeFunction = SourceZones.Runtime.Loader.resolveRuntimeFunction

local safeReadText
SourceZones.Runtime.IO.safeReadText = function(path)
    local readFileFn = resolveRuntimeFunction("readfile")
    if type(readFileFn) ~= "function" then
        return nil
    end

    local isFileFn = resolveRuntimeFunction("isfile")
    if type(isFileFn) == "function" then
        local checkOk, exists = pcall(isFileFn, path)
        if not checkOk or exists ~= true then
            return nil
        end
    end

    local readOk, contents = pcall(readFileFn, path)
    if readOk and type(contents) == "string" then
        return contents
    end
    return nil
end
safeReadText = SourceZones.Runtime.IO.safeReadText

local safeDeleteFile
SourceZones.Runtime.IO.safeDeleteFile = function(path)
    local deleteFileFn = resolveRuntimeFunction("delfile")
    if type(deleteFileFn) == "function" then
        pcall(deleteFileFn, path)
    end
end
safeDeleteFile = SourceZones.Runtime.IO.safeDeleteFile

local compileWindUI
SourceZones.Runtime.Library.compileWindUI = function(source)
    if type(source) ~= "string" or source:match("^%s*$") then
        return nil, "La fuente de WindUI está vacía"
    end

    local compiler = resolveRuntimeFunction("loadstring")
    if type(compiler) ~= "function" then
        return nil, "El executor no dispone de loadstring"
    end

    local compileOk, chunk, compileError = pcall(compiler, source)
    if not compileOk then
        return nil, "No se pudo compilar WindUI: " .. tostring(chunk)
    end
    if type(chunk) ~= "function" then
        return nil, "La compilación falló: " .. tostring(compileError)
    end

    local runOk, windUI = pcall(chunk)
    if not runOk then
        return nil, "No se pudo inicializar WindUI: " .. tostring(windUI)
    end
    if type(windUI) ~= "table"
        or type(windUI.CreateWindow) ~= "function"
        or type(windUI.Notify) ~= "function" then
        return nil, "La biblioteca cargada no expone CreateWindow y Notify"
    end

    return windUI
end
compileWindUI = SourceZones.Runtime.Library.compileWindUI

local downloadWindUISource
SourceZones.Runtime.Library.downloadWindUISource = function(skipGameHttpGet)
    if not skipGameHttpGet then
        local getOk, body = pcall(function()
            return game:HttpGet(libraryUrl)
        end)
        if getOk and type(body) == "string" and not body:match("^%s*$") then
            return body
        end
    end

    local requestCandidates = {}
    local seenRequestFunctions = {}
    local function addRequestCandidate(fn)
        if type(fn) == "function" and not seenRequestFunctions[fn] then
            seenRequestFunctions[fn] = true
            table.insert(requestCandidates, fn)
        end
    end

    addRequestCandidate(resolveRuntimeFunction("request"))
    addRequestCandidate(resolveRuntimeFunction("http_request"))
    addRequestCandidate(resolveRuntimeFunction("httprequest"))

    pcall(function()
        if type(syn) == "table" then addRequestCandidate(syn.request) end
        if type(http) == "table" then addRequestCandidate(http.request) end
        if type(fluxus) == "table" then addRequestCandidate(fluxus.request) end
        if type(krnl) == "table" then addRequestCandidate(krnl.request) end
    end)

    for _, requestFn in ipairs(requestCandidates) do
        local requestOk, response = pcall(function()
            return requestFn({
                Url = libraryUrl,
                Method = "GET",
                Headers = { ["Cache-Control"] = "no-cache" },
            })
        end)

        if requestOk then
            local responseBody
            local statusCode
            if type(response) == "string" then
                responseBody = response
            elseif type(response) == "table" then
                responseBody = response.Body or response.body
                statusCode = tonumber(response.StatusCode or response.Status or response.status_code)
            end

            local statusAccepted = statusCode == nil or (statusCode >= 200 and statusCode < 300)
            if statusAccepted and type(responseBody) == "string" and not responseBody:match("^%s*$") then
                return responseBody
            end
        end
    end

    return nil, "No se pudo descargar el release fijado de WindUI v" .. version
end
downloadWindUISource = SourceZones.Runtime.Library.downloadWindUISource

local writeWindUICache
SourceZones.Runtime.Library.writeWindUICache = function(source)
    local writeFileFn = resolveRuntimeFunction("writefile")
    local isFileFn = resolveRuntimeFunction("isfile")
    local readFileFn = resolveRuntimeFunction("readfile")
    if type(writeFileFn) ~= "function" or type(isFileFn) ~= "function" or type(readFileFn) ~= "function" then
        return false, "Las funciones de archivo necesarias para la caché no están disponibles"
    end

    local previousSource = safeReadText(uiFile)
    local previousTimestamp = safeReadText(timeFile)
    local temporaryCache = uiFile .. ".tmp"
    local temporaryTime = timeFile .. ".tmp"
    local stamp = tostring(os.time())

    local tempCacheCallOk, tempCacheResult = pcall(writeFileFn, temporaryCache, source)
    local tempTimeCallOk, tempTimeResult = pcall(writeFileFn, temporaryTime, stamp)
    local tempCacheOk = tempCacheCallOk and tempCacheResult ~= false
    local tempTimeOk = tempTimeCallOk and tempTimeResult ~= false
    if not tempCacheOk or not tempTimeOk then
        safeDeleteFile(temporaryCache)
        safeDeleteFile(temporaryTime)
        return false, "No se pudieron preparar los archivos temporales de caché"
    end

    local finalCacheCallOk, finalCacheResult = pcall(writeFileFn, uiFile, source)
    local finalCacheOk = finalCacheCallOk and finalCacheResult ~= false
    if not finalCacheOk then
        safeDeleteFile(temporaryCache)
        safeDeleteFile(temporaryTime)
        return false, "No se pudo escribir la caché"
    end

    local finalTimeCallOk, finalTimeResult = pcall(writeFileFn, timeFile, stamp)
    local finalTimeOk = finalTimeCallOk and finalTimeResult ~= false
    if not finalTimeOk then

        if type(previousSource) == "string" then
            pcall(writeFileFn, uiFile, previousSource)
        else
            local clearOk = pcall(writeFileFn, uiFile, "")
            if not clearOk then safeDeleteFile(uiFile) end
        end
        safeDeleteFile(temporaryCache)
        safeDeleteFile(temporaryTime)
        return false, "No se pudo actualizar la marca temporal; se conservó la caché anterior"
    end

    safeDeleteFile(temporaryCache)
    safeDeleteFile(temporaryTime)
    return true
end
writeWindUICache = SourceZones.Runtime.Library.writeWindUICache

local loadWindUI
SourceZones.Runtime.Library.loadWindUI = function()
    local currentTime = os.time()
    local cacheIsFileFn = resolveRuntimeFunction("isfile")
    local cacheReadFileFn = resolveRuntimeFunction("readfile")
    local cacheFunctionsAvailable = type(cacheIsFileFn) == "function"
        and type(cacheReadFileFn) == "function"
    local cachedSource = cacheFunctionsAvailable and safeReadText(uiFile) or nil
    local cachedStamp = cacheFunctionsAvailable and tonumber(safeReadText(timeFile) or "") or nil
    local cacheDateValid = cachedStamp ~= nil
        and cachedStamp > 0
        and currentTime >= cachedStamp
        and (currentTime - cachedStamp) < WINDUI_CACHE_TTL

    if type(cachedSource) == "string" and not cachedSource:match("^%s*$") and cacheDateValid then
        local cachedLibrary, cachedError = compileWindUI(cachedSource)
        if cachedLibrary then
            return cachedLibrary, true
        end

    end

    local downloadedSource, downloadError = downloadWindUISource()
    if not downloadedSource then
        return nil, false, downloadError
    end

    local downloadedLibrary, loadError = compileWindUI(downloadedSource)
    if not downloadedLibrary then
        local alternateSource, alternateDownloadError = downloadWindUISource(true)
        if type(alternateSource) == "string" and alternateSource ~= downloadedSource then
            local alternateLibrary, alternateLoadError = compileWindUI(alternateSource)
            if alternateLibrary then
                downloadedSource = alternateSource
                downloadedLibrary = alternateLibrary
            else
                return nil, false, tostring(loadError or downloadError)
                    .. " | segundo intento: " .. tostring(alternateLoadError or alternateDownloadError)
            end
        else
            return nil, false, tostring(loadError or downloadError)
                .. " | segundo intento de descarga: " .. tostring(alternateDownloadError)
        end
    end

    writeWindUICache(downloadedSource)
    return downloadedLibrary, false
end
loadWindUI = SourceZones.Runtime.Library.loadWindUI

local loadedWindUI, windUILoadedFromCache, loadedWindUIError = loadWindUI()
WindUI = loadedWindUI
windUILoadError = loadedWindUIError
end

if not WindUI then
    if type(getgenv().SilentHubCleanup) == "function" then
        pcall(getgenv().SilentHubCleanup)
    end
    error("SilentHub/WindUI " .. tostring(windUILoadError or "No se pudo cargar la biblioteca"), 0)
end

do

local WINDUI_CONFIG_FILE = "Silent-Bimo.json"
local configValues = {}
local configSaveQueued = false
local registeredConfigFlags = {}

local resolveRuntimeFunction
SourceZones.Runtime.Loader.resolveRuntimeFunction = function(name)
    local value
    pcall(function() value = rawget(_G, name) end)
    if type(value) == "function" then return value end
    if type(getgenv) == "function" then
        pcall(function()
            local runtimeEnv = getgenv()
            if type(runtimeEnv) == "table" and type(runtimeEnv[name]) == "function" then
                value = runtimeEnv[name]
            end
        end)
    end
    if type(value) == "function" then return value end
    return nil
end
resolveRuntimeFunction = SourceZones.Runtime.Loader.resolveRuntimeFunction

local cloneValue
SourceZones.Configuration.Persistence.cloneValue = function(value)
    if type(value) ~= "table" then
        return value
    end
    local result = {}
    for key, item in pairs(value) do
        result[key] = cloneValue(item)
    end
    return result
end
cloneValue = SourceZones.Configuration.Persistence.cloneValue

local valuesEqual
SourceZones.Configuration.Persistence.valuesEqual = function(a, b)
    if a == b then
        return true
    end
    if typeof(a) == "Color3" and typeof(b) == "Color3" then
        return a.R == b.R and a.G == b.G and a.B == b.B
    end
    if type(a) ~= "table" or type(b) ~= "table" then
        return false
    end
    for key, value in pairs(a) do
        if not valuesEqual(value, b[key]) then return false end
    end
    for key in pairs(b) do
        if a[key] == nil then return false end
    end
    return true
end
valuesEqual = SourceZones.Configuration.Persistence.valuesEqual

local encodeConfigValue
SourceZones.Configuration.Persistence.encodeConfigValue = function(value)
    if typeof(value) == "Color3" then
        return {
            __windui_type = "Color3",
            r = value.R,
            g = value.G,
            b = value.B,
        }
    end
    if type(value) == "table" then
        local result = {}
        for key, item in pairs(value) do
            if type(item) ~= "function" and item ~= nil then
                result[key] = encodeConfigValue(item)
            end
        end
        return result
    end
    if type(value) == "string" or type(value) == "number" or type(value) == "boolean" then
        return value
    end
    return nil
end
encodeConfigValue = SourceZones.Configuration.Persistence.encodeConfigValue

local decodeConfigValue
SourceZones.Configuration.Persistence.decodeConfigValue = function(value)
    if type(value) ~= "table" then
        return value
    end

    if value.__windui_type == "Color3"
        and type(value.r) == "number"
        and type(value.g) == "number"
        and type(value.b) == "number" then
        return Color3.new(
            math.clamp(value.r, 0, 1),
            math.clamp(value.g, 0, 1),
            math.clamp(value.b, 0, 1)
        )
    end

    local result = {}
    for key, item in pairs(value) do
        result[key] = decodeConfigValue(item)
    end
    return result
end
decodeConfigValue = SourceZones.Configuration.Persistence.decodeConfigValue

local readJsonConfig
SourceZones.Configuration.Persistence.readJsonConfig = function(path)
    local readFileFn = resolveRuntimeFunction("readfile")
    local isFileFn = resolveRuntimeFunction("isfile")
    if type(readFileFn) ~= "function" then return nil end

    if type(isFileFn) == "function" then
        local existsOk, exists = pcall(isFileFn, path)
        if not existsOk or exists ~= true then return nil end
    end

    local readOk, text = pcall(readFileFn, path)
    if not readOk or type(text) ~= "string" or text:match("^%s*$") then
        return nil
    end

    local decodeOk, decoded = pcall(function()
        return HttpService:JSONDecode(text)
    end)
    if decodeOk and type(decoded) == "table" then return decoded end
    return nil
end
readJsonConfig = SourceZones.Configuration.Persistence.readJsonConfig

local loadConfigValues
SourceZones.Configuration.Persistence.loadConfigValues = function()

    local currentConfig = readJsonConfig(WINDUI_CONFIG_FILE)
    if type(currentConfig) ~= "table" then
        return
    end

    for flag, value in pairs(currentConfig) do
        if type(flag) == "string" then
            configValues[flag] = decodeConfigValue(value)
        end
    end
end
loadConfigValues = SourceZones.Configuration.Persistence.loadConfigValues

loadConfigValues()

local flushConfigSave
SourceZones.Configuration.Persistence.flushConfigSave = function()
    configSaveQueued = false
    local writeFileFn = resolveRuntimeFunction("writefile")
    if type(writeFileFn) ~= "function" then
        return false
    end

    local serializable = {}
    for flag, value in pairs(configValues) do
        local encoded = encodeConfigValue(value)
        if encoded ~= nil then serializable[flag] = encoded end
    end

    local encodeOk, json = pcall(function()
        return HttpService:JSONEncode(serializable)
    end)
    if not encodeOk or type(json) ~= "string" then
        return false
    end

    local writeOk = pcall(writeFileFn, WINDUI_CONFIG_FILE, json)
    return writeOk
end
flushConfigSave = SourceZones.Configuration.Persistence.flushConfigSave

local queueConfigSave
SourceZones.Configuration.Persistence.queueConfigSave = function()
    if configSaveQueued then return end
    configSaveQueued = true
    task.delay(0.35, flushConfigSave)
end
queueConfigSave = SourceZones.Configuration.Persistence.queueConfigSave

local setPersistedValue
SourceZones.Configuration.Persistence.setPersistedValue = function(flag, value)
    if not flag then return end
    configValues[flag] = cloneValue(value)
    queueConfigSave()
end
setPersistedValue = SourceZones.Configuration.Persistence.setPersistedValue

local getConfigValue
SourceZones.Configuration.Persistence.getConfigValue = function(config, lowerName, upperName, fallback)
    if type(config) ~= "table" then
        return fallback
    end
    if config[lowerName] ~= nil then
        return config[lowerName]
    end
    if config[upperName] ~= nil then
        return config[upperName]
    end
    return fallback
end
getConfigValue = SourceZones.Configuration.Persistence.getConfigValue

local getFlag
SourceZones.Configuration.Persistence.getFlag = function(config)
    return getConfigValue(config, "flag", "Flag", nil)
end
getFlag = SourceZones.Configuration.Persistence.getFlag

local getPersistedValue
SourceZones.Configuration.Persistence.getPersistedValue = function(config, fallback)
    local flag = getFlag(config)
    if flag and configValues[flag] ~= nil then
        return cloneValue(configValues[flag]), true
    end
    return cloneValue(fallback), false
end
getPersistedValue = SourceZones.Configuration.Persistence.getPersistedValue

local sectionTitleFromConfig
SourceZones.Configuration.Controls.sectionTitleFromConfig = function(sectionConfig)
    if type(sectionConfig) == "table" then
        return sectionConfig.name or sectionConfig.Name or sectionConfig.title or sectionConfig.Title
    end
    return sectionConfig
end
sectionTitleFromConfig = SourceZones.Configuration.Controls.sectionTitleFromConfig

local sectionContainsValue
SourceZones.Configuration.Controls.sectionContainsValue = function(values, wanted)
    for _, item in ipairs(values or {}) do
        local candidate = type(item) == "table" and (item.Value or item.Title or item.Name) or item
        if candidate == wanted then
            return true
        end
    end
    return false
end
sectionContainsValue = SourceZones.Configuration.Controls.sectionContainsValue

local dropdownScalar
SourceZones.Configuration.Controls.dropdownScalar = function(value)
    if type(value) == "table" then
        return value[1]
    end
    return value
end
dropdownScalar = SourceZones.Configuration.Controls.dropdownScalar

local makeControlAdapter
SourceZones.Configuration.Controls.makeControlAdapter = function(config, initialValue, nativeFactory, options)
    options = options or {}
    local flag = getFlag(config)
    if type(flag) ~= "string" or flag:match("^%s*$") then
        error("La opción '" .. tostring(getConfigValue(config, "name", "Name", "Control")) .. "' requiere una Flag de WindUI", 0)
    end
    if registeredConfigFlags[flag] then
        error("La Flag de WindUI '" .. flag .. "' está asignada a más de una opción", 0)
    end
    registeredConfigFlags[flag] = true
    local callback = getConfigValue(config, "callback", "Callback", nil)
    local adapter = {
        _value = cloneValue(initialValue),
        _native = nil,
        _callbackCount = 0,
        _nativeCallback = nil,
        _suspendNativeCallback = false,
        _options = nil,
    }

    local function valueFromNative(nativeValue)
        if type(options.fromNative) == "function" then
            return options.fromNative(nativeValue)
        end
        return cloneValue(nativeValue)
    end

    local function valueFromSetter(value)
        if type(options.fromSetter) == "function" then
            return options.fromSetter(value)
        end
        return cloneValue(value)
    end

    local function valueToNative(value)
        if type(options.toNative) == "function" then
            return options.toNative(value)
        end
        return cloneValue(value)
    end

    function adapter:_onNativeChanged(nativeValue)
        local nextValue = valueFromNative(nativeValue)
        self._value = cloneValue(nextValue)
        self._callbackCount = self._callbackCount + 1
        setPersistedValue(flag, nextValue)
        if type(callback) == "function" then
            callback(cloneValue(nextValue))
        end
    end

    adapter._nativeCallback = function(value)
        if adapter._suspendNativeCallback then
            return
        end
        return adapter:_onNativeChanged(value)
    end

    local nativeOk, nativeControl = pcall(nativeFactory, adapter._nativeCallback, valueToNative(adapter._value))
    if not nativeOk or nativeControl == nil then
        error("No se pudo crear el control '" ..
            tostring(getConfigValue(config, "name", "Name", "Control")) .. "': " .. tostring(nativeControl), 0)
    end
    adapter._native = nativeControl

    function adapter:Get()
        return cloneValue(self._value)
    end

    function adapter:Set(value)
        local targetValue = valueFromSetter(value)
        local nativeValue = valueToNative(targetValue)
        local beforeCallbackCount = self._callbackCount
        local nativeObject = self._native

        if not nativeObject then
            return false, "El control nativo ya no existe"
        end

        local setOk, setError
        if type(options.setNative) == "function" then
            setOk, setError = pcall(options.setNative, nativeObject, nativeValue)
        else
            local setterName = options.setterName or "Set"
            local setter = nativeObject[setterName]
            if type(setter) ~= "function" then
                return false, "WindUI no expone el método nativo " .. tostring(setterName)
            end
            setOk, setError = pcall(setter, nativeObject, nativeValue)
        end

        if not setOk then
            return false, tostring(setError)
        end

        if self._callbackCount == beforeCallbackCount then
            local changed = not valuesEqual(self._value, targetValue)
            self._value = cloneValue(targetValue)
            setPersistedValue(flag, targetValue)
            if changed and type(callback) == "function" then
                self._callbackCount = self._callbackCount + 1
                callback(cloneValue(targetValue))
            end
        end
        return true
    end

    function adapter:_SyncInitialCallback(shouldSync)
        if shouldSync and self._callbackCount == 0 and type(callback) == "function" then
            self._callbackCount = self._callbackCount + 1
            setPersistedValue(flag, self._value)
            callback(cloneValue(self._value))
        end
    end

    return adapter
end
makeControlAdapter = SourceZones.Configuration.Controls.makeControlAdapter

local viewport = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize) or Vector2.new(800, 600)
local isMobileInput = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local windowWidth = math.clamp(math.floor(viewport.X - 28), 320, 650)
local windowHeight = math.clamp(math.floor(viewport.Y - (isMobileInput and 100 or 120)), 340, 560)
if isMobileInput then
    windowWidth = math.max(300, math.min(windowWidth, math.floor(viewport.X - 20)))
    windowHeight = math.max(320, math.min(windowHeight, math.floor(viewport.Y * 0.78)))
end

local themeName = "Midnight"

local themeRegistered = pcall(function()
    WindUI:AddTheme({
        Name = "Aurum Noir",

        Accent = Color3.fromHex("#B99655"),
        Background = Color3.fromHex("#050505"),
        Outline = Color3.fromHex("#302719"),
        Text = Color3.fromHex("#F4EFE5"),
        Placeholder = Color3.fromHex("#9C927F"),
        Button = Color3.fromHex("#14110C"),
        Icon = Color3.fromHex("#D3B16A"),

        Toggle = Color3.fromHex("#B99655"),
        Slider = Color3.fromHex("#D3B16A"),
        Checkbox = Color3.fromHex("#B99655"),

        ElementBackground = Color3.fromHex("#0E0D0A"),
        ElementBackgroundTransparency = 0.04,
        ElementTitle = Color3.fromHex("#F4EFE5"),
        ElementDesc = Color3.fromHex("#B8AC96"),
        ElementIcon = Color3.fromHex("#D3B16A"),
    })
end)

if themeRegistered then
    local setThemeOk = pcall(function()
        WindUI:SetTheme("Aurum Noir")
    end)

    if setThemeOk then
        themeName = "Aurum Noir"
    else
        pcall(function()
            WindUI:SetTheme("Midnight")
        end)
    end
else
    pcall(function()
        WindUI:SetTheme("Midnight")
    end)
end

local successWindow, NativeWindow = pcall(function()
    return WindUI:CreateWindow({
        Title = "SilentHub | BimoDuels",
        Author = "Every version surpasses the last",
        Icon = "layers",
        Folder = "SilentHub-Bimo",
        Theme = themeName,
        Size = UDim2.fromOffset(windowWidth, windowHeight),
        MinSize = Vector2.new(300, 320),
        MaxSize = Vector2.new(780, 620),
        Resizable = true,
        SideBarWidth = 180,
        ToggleKey = Enum.KeyCode.M,
        HideSearchBar = true,
        ScrollBarEnabled = true,
        Transparent = false,
        OpenButton = {
            Enabled = true,
            Draggable = true,
            OnlyMobile = false,
            Scale = 0.55,
            Title = "SilentHub Bimo",
            CornerRadius = UDim.new(1, 0),
            Color = ColorSequence.new(Color3.fromHex("#08CFF8"), Color3.fromHex("#2563EB")),
        },
    })
end)

if not successWindow or type(NativeWindow) ~= "table" or type(NativeWindow.Tab) ~= "function" then
    if type(NativeWindow) == "table" and type(NativeWindow.Destroy) == "function" then
        pcall(function() NativeWindow:Destroy() end)
    end
    if type(getgenv().SilentHubCleanup) == "function" then
        pcall(getgenv().SilentHubCleanup)
    end
    error("No se pudo crear la ventana: " .. tostring(NativeWindow), 0)
end

Window = { Tabs = {}, _native = NativeWindow, _unloaded = false }

function Window:Toast(config)
    config = type(config) == "table" and config or { content = tostring(config or "") }
    local title = config.title or config.Title or "SilentHub"
    local content = config.subtitle or config.content or config.Content or config.Text or ""
    local duration = tonumber(config.duration or config.Duration) or 2
    local combined = string.lower(tostring(title) .. " " .. tostring(content))
    local iconName = "info"
    if combined:find("error", 1, true)
        or combined:find("no se pudo", 1, true)
        or combined:find("inválido", 1, true)
        or combined:find("invalido", 1, true) then
        iconName = "circle-x"
    elseif combined:find("activado", 1, true)
        or combined:find("aplicado", 1, true)
        or combined:find("restaurado", 1, true)
        or combined:find("borrado", 1, true)
        or combined:find("éxito", 1, true) then
        iconName = "circle-check"
    end

    return WindUI:Notify({
        Title = tostring(title),
        Content = tostring(content),
        Duration = math.clamp(duration, 1, 15),
        Icon = iconName,
    })
end

function Window:Unload()
    if self._unloaded then return end
    self._unloaded = true
    if configSaveQueued then
        pcall(flushConfigSave)
    end
    pcall(AvatarIntegration.Cleanup)
    if self._native and type(self._native.Destroy) == "function" then
        local destroyOk, destroyError = pcall(function()
            self._native:Destroy()
        end)
        if not destroyOk then
            error("No se pudo destruir la ventana: " .. tostring(destroyError), 0)
        end
    end
end

function Window:CreateTab(config)
    config = type(config) == "table" and config or { name = tostring(config or "Tab") }
    local tabName = getConfigValue(config, "name", "Name",
        getConfigValue(config, "title", "Title", "Tab"))
    local defaultTabIcons = {
        Home = "house",
        Combat = "crosshair",
        ["Combat "] = "crosshair",
        Visuals = "eye",
        Extras = "sliders-horizontal",
        Configuration = "settings",
    }
    local tabIcon = getConfigValue(config, "icon", "Icon", defaultTabIcons[tostring(tabName)])
    local nativeTab = NativeWindow:Tab({
        Title = tostring(tabName),
        Icon = tabIcon,
        Border = true,
    })

    if type(nativeTab) == "table"
        and type(nativeTab.CreateKeybind) ~= "function"
        and type(nativeTab.Keybind) == "function" then
        nativeTab.CreateKeybind = function(self, config)
            return self:Keybind(config)
        end
    end

    local Tab = { _native = nativeTab, _section = nil, _sectionTitle = nil }

    function Tab:_getSection()
        if not self._section then
            self._sectionTitle = "General"
            self._section = self._native:Section({
                Title = self._sectionTitle,
                Box = true,
                Opened = true,
            })
            if type(self._section) == "table"
                and type(self._section.CreateKeybind) ~= "function"
                and type(self._section.Keybind) == "function" then
                self._section.CreateKeybind = function(section, config)
                    return section:Keybind(config)
                end
            end
        end
        return self._section
    end

    function Tab:CreateSection(sectionConfig)
        local sectionName = sectionTitleFromConfig(sectionConfig)
        self._sectionTitle = tostring(sectionName or "General")
        self._section = self._native:Section({
            Title = self._sectionTitle,
            Box = true,
            Opened = true,
        })
        if type(self._section) == "table"
            and type(self._section.CreateKeybind) ~= "function"
            and type(self._section.Keybind) == "function" then
            self._section.CreateKeybind = function(section, config)
                return section:Keybind(config)
            end
        end
        return self._section
    end

    function Tab:CreateStat(config)
        config = type(config) == "table" and config or {}
        local name = getConfigValue(config, "name", "Name", "Stat")
        local value = getConfigValue(config, "value", "Value", "")
        return self._native:Paragraph({
            Title = tostring(name),
            Desc = tostring(value),
            Icon = "user-round",
        })
    end

    function Tab:CreateToggle(config)
        config = type(config) == "table" and config or {}
        local rawDefault = getConfigValue(config, "value", "Value",
            getConfigValue(config, "default", "Default", false))
        local storedValue, hasStoredValue = getPersistedValue(config, rawDefault)
        local defaultValue = type(storedValue) == "boolean" and storedValue or false
        local normalizedDeclaredDefault = type(rawDefault) == "boolean" and rawDefault or false
        local adapter = makeControlAdapter(config, defaultValue, function(onChanged, value)
            return self:_getSection():Toggle({
                Title = tostring(getConfigValue(config, "name", "Name", "Toggle")),
                Desc = getConfigValue(config, "description", "Description", nil),
                Flag = getFlag(config),
                Value = value == true,
                Callback = onChanged,
            })
        end, {
            setterName = "Set",
            fromNative = function(value) return value == true end,
            fromSetter = function(value) return value == true end,
            toNative = function(value) return value == true end,
        })
        adapter:_SyncInitialCallback(hasStoredValue and not valuesEqual(defaultValue, normalizedDeclaredDefault))
        return adapter
    end

    function Tab:CreateButton(config)
        config = type(config) == "table" and config or {}
        local callback = getConfigValue(config, "callback", "Callback", function() end)
        return self:_getSection():Button({
            Title = tostring(getConfigValue(config, "name", "Name", "Button")),
            Desc = getConfigValue(config, "description", "Description", nil),
            Callback = callback,
        })
    end

    function Tab:CreateKeybind(config)
        config = type(config) == "table" and config or {}
        local callback = getConfigValue(config, "callback", "Callback", function() end)
        local defaultKey = tostring(getConfigValue(config, "value", "Value", "F"))
        return self:_getSection():Keybind({
            Title = tostring(getConfigValue(config, "name", "Name", "Keybind")),
            Desc = getConfigValue(config, "description", "Description", nil),
            Value = defaultKey,
            Blacklist = getConfigValue(config, "blacklist", "Blacklist", {}),
            Callback = callback,
        })
    end

    function Tab:CreateSlider(config)
        config = type(config) == "table" and config or {}
        local range = getConfigValue(config, "range", "Range", { 0, 100 })
        local minValue = tonumber(range[1]) or 0
        local maxValue = tonumber(range[2]) or 100
        if maxValue < minValue then minValue, maxValue = maxValue, minValue end
        local step = tonumber(getConfigValue(config, "increment", "Increment", nil))
        local rawDefault = tonumber(getConfigValue(config, "value", "Value", minValue)) or minValue
        local storedValue, hasStoredValue = getPersistedValue(config, rawDefault)

        local function normalizeSlider(value)
            local numeric = tonumber(value)
            if not numeric then numeric = rawDefault end
            numeric = math.clamp(numeric, minValue, maxValue)
            if step and step > 0 then
                numeric = minValue + math.floor(((numeric - minValue) / step) + 0.5) * step
                numeric = math.clamp(numeric, minValue, maxValue)
                local stepText = tostring(step)
                local decimalPart = string.match(stepText, "%..+")
                local decimals = decimalPart and (#decimalPart - 1) or 0
                local scale = 10 ^ math.clamp(decimals, 0, 6)
                numeric = math.floor(numeric * scale + 0.5) / scale
            end
            return numeric
        end

        local defaultValue = normalizeSlider(storedValue)
        local declaredDefault = normalizeSlider(rawDefault)
        local adapter = makeControlAdapter(config, defaultValue, function(onChanged, value)
            return self:_getSection():Slider({
                Title = tostring(getConfigValue(config, "name", "Name", "Slider")),
                Desc = getConfigValue(config, "description", "Description", nil),
                Flag = getFlag(config),
                Step = step or 1,
                Value = {
                    Min = minValue,
                    Max = maxValue,
                    Default = normalizeSlider(value),
                },
                Callback = onChanged,
            })
        end, {
            setterName = "Set",
            fromNative = normalizeSlider,
            fromSetter = normalizeSlider,
            toNative = normalizeSlider,
        })
        adapter:_SyncInitialCallback(hasStoredValue and not valuesEqual(defaultValue, declaredDefault))
        return adapter
    end

    function Tab:CreateDropdown(config)
        config = type(config) == "table" and config or {}
        local optionsValues = cloneValue(getConfigValue(config, "options", "Options", {}))
        local multiple = getConfigValue(config, "multipleOptions", "MultipleOptions", false) == true
        local rawDeclaredDefault = getConfigValue(config, "currentOption", "CurrentOption",
            getConfigValue(config, "value", "Value", nil))
        local callbackShapeTable = not multiple and type(rawDeclaredDefault) == "table"
        local rawDefault = multiple and (type(rawDeclaredDefault) == "table" and rawDeclaredDefault or {}) or dropdownScalar(rawDeclaredDefault)
        local storedValue, hasStoredValue = getPersistedValue(config, rawDefault)

        local function scalarOrTable(value)
            if multiple then
                if type(value) == "table" then return cloneValue(value) end
                if value == nil then return {} end
                return { value }
            end
            local scalar = dropdownScalar(value)
            if callbackShapeTable then return scalar ~= nil and { scalar } or {} end
            return scalar
        end

        local function valueToNative(value)
            if multiple then
                return type(value) == "table" and cloneValue(value) or {}
            end
            return dropdownScalar(value)
        end

        local function normalizeStoredDropdown(value, fallback)
            if multiple then
                local candidates = type(value) == "table" and value or { value }
                local selected = {}
                for _, candidate in ipairs(candidates) do
                    if sectionContainsValue(optionsValues, candidate) and not table.find(selected, candidate) then
                        table.insert(selected, candidate)
                    end
                end
                if #selected == 0 and type(fallback) == "table" then
                    for _, candidate in ipairs(fallback) do
                        if sectionContainsValue(optionsValues, candidate) then
                            table.insert(selected, candidate)
                        end
                    end
                end
                return selected
            end

            local candidate = dropdownScalar(value)
            if not sectionContainsValue(optionsValues, candidate) then
                candidate = dropdownScalar(fallback)
            end
            if not sectionContainsValue(optionsValues, candidate) then
                candidate = optionsValues[1]
                if type(candidate) == "table" then
                    candidate = candidate.Value or candidate.Title or candidate.Name
                end
            end
            return scalarOrTable(candidate)
        end

        local defaultValue = normalizeStoredDropdown(storedValue, rawDefault)
        local declaredDefault = normalizeStoredDropdown(rawDefault, rawDefault)

        local function buildNativeDropdown(onChanged, value)
            return self:_getSection():Dropdown({
                Title = tostring(getConfigValue(config, "name", "Name", "Dropdown")),
                Desc = getConfigValue(config, "description", "Description", nil),
                Values = cloneValue(optionsValues),
                Value = valueToNative(value),
                Multi = multiple,
                AllowNone = false,
                SearchBarEnabled = #optionsValues > 8,
                Flag = getFlag(config),
                Callback = onChanged,
            })
        end

        local adapter = makeControlAdapter(config, defaultValue, function(onChanged, value)
            return buildNativeDropdown(onChanged, value)
        end, {
            setterName = "Select",
            fromNative = scalarOrTable,
            fromSetter = function(value)
                return normalizeStoredDropdown(value, defaultValue)
            end,
            toNative = valueToNative,
        })
        adapter._options = cloneValue(optionsValues)
        adapter._nativeFactory = buildNativeDropdown

        function adapter:Refresh(newOptions)
            if type(newOptions) ~= "table" then
                return false, "Las opciones del desplegable deben ser una tabla"
            end

            local normalizedOptions = cloneValue(newOptions)
            local currentBeforeRefresh = cloneValue(self._value)
            local currentScalar = multiple and nil or dropdownScalar(currentBeforeRefresh)
            local selectedStillExists = multiple and true or sectionContainsValue(normalizedOptions, currentScalar)
            local fallbackValue

            if multiple then
                fallbackValue = {}
                for _, candidate in ipairs(type(currentBeforeRefresh) == "table" and currentBeforeRefresh or {}) do
                    if sectionContainsValue(normalizedOptions, candidate) then
                        table.insert(fallbackValue, candidate)
                    end
                end
            elseif selectedStillExists then
                fallbackValue = scalarOrTable(currentScalar)
            else
                local first = normalizedOptions[1]
                if type(first) == "table" then first = first.Value or first.Title or first.Name end
                fallbackValue = scalarOrTable(first)
            end

            optionsValues = normalizedOptions
            self._options = cloneValue(normalizedOptions)

            local refreshSucceeded = false
            self._suspendNativeCallback = true
            if self._native and type(self._native.Refresh) == "function" then
                local refreshOk = pcall(function()
                    self._native:Refresh(cloneValue(normalizedOptions))
                end)
                refreshSucceeded = refreshOk
            end

            if not refreshSucceeded then
                local oldNative = self._native
                self._native = nil
                if oldNative and type(oldNative.Destroy) == "function" then
                    pcall(function() oldNative:Destroy() end)
                end
                local createOk, replacement = pcall(function()
                    return self._nativeFactory(self._nativeCallback, fallbackValue)
                end)
                if not createOk or replacement == nil then
                    self._suspendNativeCallback = false
                    return false, "No se pudo reconstruir el desplegable con las opciones nuevas: " .. tostring(replacement)
                end
                self._native = replacement
            end
            self._suspendNativeCallback = false

            local setOk, setError = self:Set(fallbackValue)
            if not setOk then
                return false, setError
            end
            return true
        end

        adapter:_SyncInitialCallback(hasStoredValue and not valuesEqual(defaultValue, declaredDefault))
        return adapter
    end

    function Tab:CreateInput(config)
        config = type(config) == "table" and config or {}
        local rawDefault = getConfigValue(config, "default", "Default",
            getConfigValue(config, "value", "Value", ""))
        if type(rawDefault) ~= "string" then rawDefault = tostring(rawDefault or "") end
        local storedValue = getPersistedValue(config, rawDefault)
        if type(storedValue) ~= "string" then storedValue = rawDefault end

        return makeControlAdapter(config, storedValue, function(onChanged, value)
            return self:_getSection():Input({
                Title = tostring(getConfigValue(config, "name", "Name", "Input")),
                Desc = getConfigValue(config, "description", "Description", nil),
                Placeholder = tostring(getConfigValue(config, "placeholder", "Placeholder", "")),
                Value = value,
                Type = "Input",
                Flag = getFlag(config),
                Callback = onChanged,
            })
        end, {
            setterName = "Set",
            fromNative = function(value) return tostring(value or "") end,
            fromSetter = function(value) return tostring(value or "") end,
            toNative = function(value) return tostring(value or "") end,
        })
    end

    function Tab:CreateColorPicker(config)
        config = type(config) == "table" and config or {}
        local rawDefault = getConfigValue(config, "color", "Color", Color3.fromRGB(220, 40, 40))
        local storedValue, hasStoredValue = getPersistedValue(config, rawDefault)
        local defaultColor = typeof(storedValue) == "Color3" and storedValue or rawDefault
        if typeof(defaultColor) ~= "Color3" then defaultColor = Color3.fromRGB(220, 40, 40) end

        local adapter = makeControlAdapter(config, defaultColor, function(onChanged, value)
            return self:_getSection():Colorpicker({
                Title = tostring(getConfigValue(config, "name", "Name", "Color")),
                Desc = getConfigValue(config, "description", "Description", nil),
                Default = value,
                Transparency = 0,
                Flag = getFlag(config),
                Callback = function(color)
                    onChanged(color)
                end,
            })
        end, {
            setNative = function(nativeControl, color)
                if type(nativeControl.Update) ~= "function" then
                    error("Colorpicker no expone Update")
                end
                nativeControl:Update(color, 0)
            end,
            fromNative = function(value)
                if typeof(value) == "Color3" then return value end
                return defaultColor
            end,
            fromSetter = function(value)
                if typeof(value) == "Color3" then return value end
                return defaultColor
            end,
            toNative = function(value) return value end,
        })
        adapter:_SyncInitialCallback(hasStoredValue and not valuesEqual(defaultColor, rawDefault))
        return adapter
    end

    self.Tabs[tostring(tabName)] = Tab
    return Tab
end
end 

local uiBuildOk, uiBuildError = xpcall(function()
getgenv().SilentHubWindow = Window
Silent.Events:Sub("Toast", "UI", function(msg)
    if not Window then return end
    pcall(function()
        Window:Toast({
            title = "SilentHub",
            subtitle = tostring(msg),
            duration = 2,
        })
    end)
end)

local tH = Window:CreateTab({name="Home"})
local tA = Window:CreateTab({name="Combat "})
local tV = Window:CreateTab({name="Visuals"})
local tG = Window:CreateTab({name="Extras"})
local tC = Window:CreateTab({name="Configuration"})

local AVATAR_MODULE_BASE_URL = "https://raw.githubusercontent.com/Silent-lua/Dev/c0f26ed59145c8b2953e5e7671b3821fca5ef766/"

local function resolveAvatarCompiler()
    local compiler
    pcall(function() compiler = loadstring end)
    if type(compiler) == "function" then
        return compiler
    end

    pcall(function()
        if type(getgenv) == "function" then
            local runtimeEnvironment = getgenv()
            if type(runtimeEnvironment) == "table" then
                compiler = runtimeEnvironment.loadstring
            end
        end
    end)
    if type(compiler) == "function" then
        return compiler
    end

    pcall(function() compiler = rawget(_G, "loadstring") end)
    if type(compiler) == "function" then
        return compiler
    end
    return nil
end

local function compileAvatarModule(fileName, bridge)
    local requestOk, source = pcall(function()
        return game:HttpGet(AVATAR_MODULE_BASE_URL .. fileName)
    end)
    if not requestOk or type(source) ~= "string" or source:match("^%s*$") then
        return nil, "No se pudo descargar " .. fileName .. ": " .. tostring(source)
    end

    local compiler = resolveAvatarCompiler()
    if type(compiler) ~= "function" then
        return nil, "El executor no expone loadstring en su entorno global"
    end

    local compileOk, chunk, compileError = pcall(compiler, source)
    if not compileOk or type(chunk) ~= "function" then
        return nil, "No se pudo compilar " .. fileName .. ": " .. tostring(compileError or chunk)
    end

    local runOk, api = pcall(chunk, bridge)
    if not runOk or type(api) ~= "table" then
        return nil, "No se pudo iniciar " .. fileName .. ": " .. tostring(api)
    end
    return api
end

local AVATAR_MODULES = {
    skins = {
        fileName = "SilentHub-Skins.lua",
        apiKey = "Skins",
        enabledKey = "SkinsEnabled",
        loadingKey = "SkinsLoading",
        controlKey = "SkinsControl",
        setterKey = "setEnabled",
        cleanupKey = "destroy",
    },
    accessories = {
        fileName = "SilentHub-Accesorios.lua",
        apiKey = "Accessories",
        enabledKey = "AccessoriesEnabled",
        loadingKey = "AccessoriesLoading",
        controlKey = "AccessoriesControl",
        setterKey = "SetEnabled",
        cleanupKey = "Cleanup",
    },
}

local function ensureAvatarModule(moduleName, generation)
    local definition = AVATAR_MODULES[moduleName]
    if not definition then
        return false, "Módulo de avatar desconocido: " .. tostring(moduleName)
    end

    if AvatarIntegration[definition.apiKey] then
        return true
    end

    local api, loadError = compileAvatarModule(definition.fileName, AvatarIntegration.Bridge)
    if not api then
        return false, loadError
    end

    if generation ~= AvatarIntegration.Generation then
        local cleanup = api[definition.cleanupKey]
        if type(cleanup) == "function" then pcall(cleanup) end
        return false, "La carga se canceló"
    end

    local setter = api[definition.setterKey]
    if type(setter) ~= "function" then
        local cleanup = api[definition.cleanupKey]
        if type(cleanup) == "function" then pcall(cleanup) end
        return false, definition.fileName .. " no expone " .. definition.setterKey
    end

    local disableOk, disableResult = pcall(setter, false)
    if not disableOk or disableResult == false then
        local cleanup = api[definition.cleanupKey]
        if type(cleanup) == "function" then pcall(cleanup) end
        return false, "No se pudo inicializar " .. definition.fileName .. ": " .. tostring(disableResult)
    end

    AvatarIntegration[definition.apiKey] = api
    return true
end

local function resetAvatarModuleToggle(moduleName)
    local definition = AVATAR_MODULES[moduleName]
    if not definition then return end
    task.defer(function()
        local control = AvatarIntegration[definition.controlKey]
        if control and type(control.Set) == "function" then
            pcall(control.Set, control, false)
        end
    end)
end

local function setAvatarModuleEnabled(moduleName, enabled)
    local definition = AVATAR_MODULES[moduleName]
    if not definition then
        return false, "Módulo de avatar desconocido: " .. tostring(moduleName)
    end

    enabled = enabled == true
    AvatarIntegration[definition.enabledKey] = enabled

    local api = AvatarIntegration[definition.apiKey]
    if not enabled then
        if api then
            local setter = api[definition.setterKey]
            if type(setter) == "function" then
                local ok, result = pcall(setter, false)
                if not ok or result == false then
                    return false, tostring(result)
                end
            end
        end
        return true
    end

    if api then
        local setter = api[definition.setterKey]
        if type(setter) ~= "function" then
            AvatarIntegration[definition.enabledKey] = false
            resetAvatarModuleToggle(moduleName)
            return false, definition.fileName .. " no expone " .. definition.setterKey
        end
        local ok, result = pcall(setter, true)
        if not ok or result == false then
            AvatarIntegration[definition.enabledKey] = false
            pcall(setter, false)
            resetAvatarModuleToggle(moduleName)
            return false, tostring(result)
        end
        return true
    end

    if AvatarIntegration[definition.loadingKey] then
        return true
    end

    AvatarIntegration[definition.loadingKey] = true
    local generation = AvatarIntegration.Generation
    Window:Toast({ title = "Avatar", subtitle = "Cargando " .. definition.fileName .. "...", duration = 3 })

    task.spawn(function()
        local callOk, loaded, loadError = pcall(ensureAvatarModule, moduleName, generation)
        if generation ~= AvatarIntegration.Generation then return end
        AvatarIntegration[definition.loadingKey] = false

        if not callOk or loaded ~= true then
            AvatarIntegration[definition.enabledKey] = false
            resetAvatarModuleToggle(moduleName)
            Window:Toast({
                title = "Avatar",
                subtitle = "No se pudo cargar " .. definition.fileName .. ": " .. tostring(loadError or loaded),
                duration = 7,
            })
            return
        end

        if not AvatarIntegration[definition.enabledKey] then
            return
        end

        local loadedApi = AvatarIntegration[definition.apiKey]
        local setter = loadedApi and loadedApi[definition.setterKey]
        local enableOk, enableResult = false, "API no disponible"
        if type(setter) == "function" then
            enableOk, enableResult = pcall(setter, true)
        end

        if not enableOk or enableResult == false then
            AvatarIntegration[definition.enabledKey] = false
            if type(setter) == "function" then pcall(setter, false) end
            resetAvatarModuleToggle(moduleName)
            Window:Toast({
                title = "Avatar",
                subtitle = "No se pudo activar " .. definition.fileName .. ": " .. tostring(enableResult),
                duration = 7,
            })
        end
    end)

    return true
end

local SilentHubUIZones = {
    Layout = {}, Stats = {}, Toggles = {}, Dropdowns = {}, Sliders = {},
    ColorPickers = {}, Buttons = {}, Inputs = {}, Keybinds = {},
}
local runSilentHubUIZones
SourceZones.UI.Execution.runSilentHubUIZones = function(zones, sequence)
    for index = 1, #sequence do
        local step = sequence[index]
        local zone = zones[step[1]]
        local build = zone and zone[step[2]]
        if type(build) ~= "function" then
            error("SilentHub UI zone missing: " .. tostring(step[1]) .. "." .. tostring(step[2]))
        end
        build()
    end
end
runSilentHubUIZones = SourceZones.UI.Execution.runSilentHubUIZones

local BuildHomeUI
SourceZones.UI.Builders.BuildHomeUI = function()
    local zones = SilentHubUIZones
    zones.Layout.Home_Profile = function() tH:CreateSection({name="Perfil del Jugador"}) end
    zones.Stats.Home_CurrentUser = function() tH:CreateStat({name="Current User", value=player.DisplayName.."｜@"..player.Name.." "}) end
    zones.Stats.Home_Identity = function() tH:CreateStat({name="Identity", value="ID: "..player.UserId.." | Edad: "..player.AccountAge.." días"}) end
    zones.Stats.Home_Executor = function() tH:CreateStat({name="Executor", value=tostring(identifyexecutor and identifyexecutor() or "Desconocido")}) end
    local sequence = {
        { "Layout", "Home_Profile" },
        { "Stats", "Home_CurrentUser" },
        { "Stats", "Home_Identity" },
        { "Stats", "Home_Executor" }
    }
    runSilentHubUIZones(zones, sequence)
end
BuildHomeUI = SourceZones.UI.Builders.BuildHomeUI

local BuildConfigurationUI
SourceZones.UI.Builders.BuildConfigurationUI = function()
    local suggestionDraft = ""
    local suggestionBusy = false
    local suggestionField

    local function submitSuggestion()
        if suggestionBusy then
            Window:Toast({title="Sugerencias", subtitle="Ya hay una sugerencia en proceso de envío", duration=3})
            return
        end

        local suggestionText = tostring(suggestionDraft or "")
        suggestionText = suggestionText:gsub("^%s+", ""):gsub("%s+$", "")
        if suggestionText == "" then
            Window:Toast({title="Sugerencias", subtitle="Escribe tu sugerencia antes de enviarla", duration=3})
            return
        end
        if #suggestionText > 1500 then
            Window:Toast({title="Sugerencias", subtitle="La sugerencia supera el límite de 1500 caracteres", duration=4})
            return
        end

        local webhookUrl = tostring(getgenv().SilentHubSuggestionsWebhook or "https://discord.com/api/webhooks/1563792294820319262/9u21xZaStxMcZQBPR9hV7eoXJ1LgMEKRppI1iogNNS-jS-i63tBGhYHlpAgB8XH8D7ld")
        if webhookUrl == "" then
            Window:Toast({title="Webhook pendiente", subtitle="Configura getgenv().SilentHubSuggestionsWebhook con tu webhook de Discord", duration=5})
            return
        end
        if not webhookUrl:match("^https://discord%.com/api/webhooks/")
            and not webhookUrl:match("^https://discordapp%.com/api/webhooks/") then
            Window:Toast({title="Webhook inválida", subtitle="Usa una URL HTTPS de webhook de Discord", duration=4})
            return
        end

        suggestionBusy = true
        Window:Toast({title="Sugerencias", subtitle="Enviando tu sugerencia a Discord...", duration=3})

        task.spawn(function()
            local gameName = "Experiencia de Roblox"
            pcall(function()
                local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
                if type(info) == "table" and type(info.Name) == "string" and info.Name ~= "" then
                    gameName = info.Name
                end
            end)

            local payload = {
                username = "SilentHub • Sugerencias",
                allowed_mentions = {parse = {}},
                embeds = {{
                    title = "Nueva sugerencia",
                    description = suggestionText,
                    color = 0x8B5CF6,
                    author = {name = ""},
                    fields = {
                        {name = "👤 Usuario", value = (tostring(player.DisplayName) .. " (@" .. tostring(player.Name) .. ")"):sub(1, 1024), inline = true},
                        {name = "🎮 Experiencia", value = tostring(gameName):sub(1, 1024), inline = true},
                        {name = "🆔 Place ID", value = tostring(game.PlaceId), inline = true},
                    },
                    footer = {text = "SilentHub Bimo • sugerencia"},
                    timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                }},
            }

            local encodeOk, bodyData = pcall(function()
                return HttpService:JSONEncode(payload)
            end)
            if not encodeOk then
                suggestionBusy = false
                Window:Toast({title="Error de envío", subtitle="No se pudo preparar el mensaje de Discord", duration=4})
                return
            end

            local requesters = {}
            local function addRequester(fn)
                if type(fn) ~= "function" then return end
                for _, existing in ipairs(requesters) do
                    if existing == fn then return end
                end
                table.insert(requesters, fn)
            end
            addRequester(request)
            addRequester(http_request)
            if type(syn) == "table" then addRequester(syn.request) end
            if type(http) == "table" then addRequester(http.request) end
            if type(fluxus) == "table" then addRequester(fluxus.request) end
            if type(krnl) == "table" then addRequester(krnl.request) end

            if #requesters == 0 then
                suggestionBusy = false
                Window:Toast({title="HTTP no disponible", subtitle="Este executor no expone una función de solicitudes HTTP compatible", duration=5})
                return
            end

            local sent = false
            local sendError = "No se pudo completar la solicitud"
            for _, requestFn in ipairs(requesters) do
                local callOk, response = pcall(function()
                    return requestFn({
                        Url = webhookUrl,
                        Method = "POST",
                        Headers = {["Content-Type"] = "application/json"},
                        Body = bodyData,
                    })
                end)

                if callOk then
                    local statusCode
                    if type(response) == "table" then
                        statusCode = tonumber(response.StatusCode or response.Statuscode or response.status_code or response.status)
                    end
                    if statusCode and (statusCode < 200 or statusCode >= 300) then
                        sendError = "Discord respondió con HTTP " .. tostring(statusCode) .. "."
                        break
                    elseif type(response) == "boolean" and response == false then
                        sendError = "El executor rechazó la solicitud HTTP"
                    else
                        sent = true
                        break
                    end
                else
                    sendError = tostring(response)
                end
            end

            suggestionBusy = false
            if sent then
                suggestionDraft = ""
                pcall(function()
                    if suggestionField and type(suggestionField.Set) == "function" then
                        suggestionField:Set("")
                    end
                end)
                Window:Toast({title="¡Sugerencia enviada!", subtitle="Tu mensaje llegó a Discord correctamente", duration=2})
            else
                Window:Toast({title="No se pudo enviar", subtitle=sendError, duration=5})
            end
        end)
    end

    local zones = SilentHubUIZones
    zones.Layout.Configuration_Settings = function() tC:CreateSection({name="Configuración"}) end
    zones.Toggles.Configuration_ShowStats = function() tC:CreateToggle({name="Mostrar Fps/Ping", flag="Silent_ShowStats", value=false, callback=function(v) Silent.State.UI.ShowStats=v statsC.Visible=v statsC.BackgroundTransparency=v and 0.5 or 1 end}) end
    zones.Layout.Configuration_ClientServer = function() tC:CreateSection({name="Client Server"}) end
    zones.Buttons.Configuration_ChangeServer = function() tC:CreateButton({name="Cambiar de Servidor", callback=function() Silent.Events:Emit("Toast", "Buscando servidor...") local a="https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100" task.spawn(function() local s,e=pcall(function() local r=request or http_request or (syn and syn.request) if r then local res=r({Url=a, Method="GET"}) if res.StatusCode==200 then local d=HttpService:JSONDecode(res.Body) local sv={} if d and d.data then for _,v in pairs(d.data) do if v.playing<v.maxPlayers and v.id~=game.JobId then table.insert(sv,v.id) end end end if #sv>0 then local rs=sv[math.random(1,#sv)] Silent.Events:Emit("Toast", "¡Servidor encontrado!") TPS:TeleportToPlaceInstance(game.PlaceId,rs,player) else Silent.Events:Emit("Toast", "No hay servidores disponibles.") end end end end) end) end}) end
    zones.Buttons.Configuration_Rejoin = function() tC:CreateButton({name="Volver a unirse", callback=function() Silent.Events:Emit("Toast", "Reconectando al servidor...") task.wait(0.5) if #Players:GetPlayers()<=1 then TPS:Teleport(game.PlaceId,player) else TPS:TeleportToPlaceInstance(game.PlaceId,game.JobId,player) end end}) end
    zones.Layout.Configuration_Suggestions = function() tC:CreateSection({name="Sugerencias"}) end
    zones.Inputs.Configuration_Suggestion = function()
        suggestionField = tC:CreateInput({
            name = "Tu sugerencia",
            description = "Comparte una idea, mejora o error que quieras reportar",
            placeholder = "Escribe tu sugerencia aquí...",
            default = "",
            flag = "SilentHub_SuggestionDraft_Bimo",
            callback = function(value)
                suggestionDraft = tostring(value or "")
            end,
        })
    end
    zones.Buttons.Configuration_SubmitSuggestion = function()
        tC:CreateButton({
            name = "Enviar sugerencia",
            description = "Envía tu mensaje a discord",
            callback = submitSuggestion,
        })
    end
    local sequence = {
        { "Layout", "Configuration_Settings" },
        { "Toggles", "Configuration_ShowStats" },
        { "Layout", "Configuration_ClientServer" },
        { "Buttons", "Configuration_ChangeServer" },
        { "Buttons", "Configuration_Rejoin" },
        { "Layout", "Configuration_Suggestions" },
        { "Inputs", "Configuration_Suggestion" },
        { "Buttons", "Configuration_SubmitSuggestion" }
    }
    runSilentHubUIZones(zones, sequence)
end
BuildConfigurationUI = SourceZones.UI.Builders.BuildConfigurationUI

local BuildCombatUI
SourceZones.UI.Builders.BuildCombatUI = function()
    local tgMac
    local zones = SilentHubUIZones
    zones.Layout.Combat_Macro = function() tA:CreateSection({name="Zone Macro"}) end
    zones.Toggles.Combat_MacroPistol = function()
        tgMac=tA:CreateToggle({name="Macro Pistol",flag="Silent_MacroToggle",value=false,callback=function(v)
            Silent.State.Macro.Active = v == true
            if not Silent.State.Macro.Active then
                cancelMacroOperation()
            end
        end})
    end
    zones.Sliders.Combat_MacroDelay = function() tA:CreateSlider({name="Delay de Disparo",range={0.05,0.50},increment=0.05,value=0.05,flag="Silent_MacroShDelay",callback=function(v) Silent.State.Macro.ShootDelay=v end}) end
    zones.Layout.Combat_AimSystem = function() tA:CreateSection({name="AimSystem"}) end
    zones.Toggles.Combat_TriggerBot = function()
        Silent.Controls.TriggerBot = tA:CreateToggle({name="Triggerbot",description="",flag="Silent_TriggerBotShiftLock",value=false,callback=function(v)
            Silent.State.Aim.TriggerBot = v == true
            if not v then cancelTriggerbotOperations() end
        end})
    end
    zones.Toggles.Combat_TriggerBotLegit = function()
        tA:CreateToggle({name="Tiggerbot Legit",description="Equipar Manualmente",flag="Silent_TriggerBotLegit",value=false,callback=function(v)
            Silent.State.Aim.TriggerBotLegit = v == true
        end})
    end
    
    zones.Layout.Combat_AimConfig = function() tA:CreateSection({name="Configuración"}) end
    zones.Sliders.Combat_EnemyDetectionLevel = function()
        tA:CreateSlider({
            name="Enemy Detection",
            description="1 Lento - 3 Rápido",
            range={1,3},
            increment=1,
            value=2,
            flag="Silent_EnemyDetectionLevel",
            callback=function(v)
                local level = math.clamp(math.floor((tonumber(v) or 2) + 0.5), 1, 3)
                local intervals = { [1] = 0.06, [2] = 0.03, [3] = 0.01 }
                Silent.State.Aim.TriggerDetectionLevel = level
                Silent.State.Aim.TriggerDetectionInterval = intervals[level]
                Silent.State.Aim.TriggerDetectionLastScanAt = 0
            end
        })
    end
    zones.Toggles.Combat_ThrowMode = function() tA:CreateToggle({name="Lock Throw Mode (Movil)",flag="Silent_ThrowMode",value=false,callback=function(v) Silent.State.Aim.ThrowMode=v Silent.Events:Emit("ToggleThrowMode",v) end}) end
    zones.Toggles.Combat_KnifeThrowMacro = function()
        tA:CreateToggle({name="Macro KnifeThrow (PC)",flag="Silent_MacroKnifeThrowPC",value=false,callback=function(v)
            if Silent.State.Macro.SetKnifeThrowEnabled then
                Silent.State.Macro.SetKnifeThrowEnabled(v)
            else
                Silent.State.Macro.KnifeThrowActive = v == true
            end
        end})
    end
    zones.Keybinds.Combat_TriggerBotKeybind = function()
        tA:CreateKeybind({name="Triggerbot KeyBind",description="Tecla para desactivar Triggerbot",value="F",blacklist={Enum.KeyCode.E},callback=function()
            if Silent.Controls.TriggerBot and type(Silent.Controls.TriggerBot.Set) == "function" then
                Silent.Controls.TriggerBot:Set(false)
            else
                Silent.State.Aim.TriggerBot = false
                cancelTriggerbotOperations()
            end
        end})
    end
    local sequence = {
        { "Layout", "Combat_Macro" },
        { "Toggles", "Combat_MacroPistol" },
        { "Sliders", "Combat_MacroDelay" },
        { "Layout", "Combat_AimSystem" },
        { "Layout", "Combat_AimConfig" },
        { "Sliders", "Combat_EnemyDetectionLevel" },
        { "Toggles", "Combat_TriggerBot" },
        { "Toggles", "Combat_TriggerBotLegit" },
        { "Toggles", "Combat_ThrowMode" },
        { "Toggles", "Combat_KnifeThrowMacro" },
        { "Keybinds", "Combat_TriggerBotKeybind" }
    }
    runSilentHubUIZones(zones, sequence)
end
BuildCombatUI = SourceZones.UI.Builders.BuildCombatUI

local BuildVisualsUI
SourceZones.UI.Builders.BuildVisualsUI = function()
    local zones = SilentHubUIZones
    zones.Layout.Visuals_PlayerOptions = function() tV:CreateSection({name="Opciones Visuales"}) end
    zones.Toggles.Visuals_HideName = function() tV:CreateToggle({name="Ocultar mi Nombre", flag="Silent_HideName", value=false, callback=function(v) Silent.State.Vis.HideName=v Silent.Events:Emit("UpdateHideName") end}) end
    zones.Layout.Visuals_EspOptions = function() tV:CreateSection({name="Configuración de ESP"}) end
    zones.Toggles.Visuals_EspPlayers = function() tV:CreateToggle({name="ESP Jugadores", flag="Silent_ESPPlayers", value=false, callback=function(v) Silent.State.Vis.ESP=v if not v then cleanAllESPDrawings() end end}) end
    zones.Toggles.Visuals_EspGlow = function() tV:CreateToggle({name="Mostrar Brillo", flag="Silent_ESPGlow", value=true, callback=function(v) Silent.State.Vis.Glow=v end}) end
    zones.Toggles.Visuals_EspName = function() tV:CreateToggle({name="Mostrar Nombre", flag="Silent_ESPName", value=false, callback=function(v) Silent.State.Vis.Name=v end}) end
    zones.Toggles.Visuals_EspDistance = function() tV:CreateToggle({name="Mostrar Distancia", flag="Silent_ESPDist", value=false, callback=function(v) Silent.State.Vis.Dist=v end}) end
    zones.Toggles.Visuals_EspTracers = function() tV:CreateToggle({name="Tracers / Líneas", flag="Silent_ESPLines", value=false, callback=function(v) Silent.State.Vis.Lines=v if not v then for p in pairs(aTracers) do cleanTracer(p) end end end}) end
    zones.Toggles.Visuals_EspArrows = function() tV:CreateToggle({name="Off-screen arrows", flag="Silent_ESPArrows", value=false, callback=function(v) Silent.State.Vis.Arrows=v if not v then for p in pairs(aArrows) do cleanArrow(p) end end end}) end
    zones.ColorPickers.Visuals_EspColor = function() tV:CreateColorPicker({name="Color de ESP", flag="Silent_ESPColor", color=Color3.fromRGB(255, 0, 0), callback=function(v) Silent.State.Vis.Color=v end}) end

    zones.Layout.Visuals_AvatarVisualSection = function()
        tV:CreateSection({name="Avatar Visuals"})
    end
    zones.Toggles.Visuals_AvatarSkins = function()
        AvatarIntegration.SkinsControl = tV:CreateToggle({
            name = "Skins",
            description = "Mostrar u ocultar el botón flotante",
            flag = "Silent_AvatarSkins",
            value = false,
            callback = function(value)
                local ok, toggleError = setAvatarModuleEnabled("skins", value)
                if not ok then
                    AvatarIntegration.SkinsEnabled = false
                    resetAvatarModuleToggle("skins")
                    Window:Toast({
                        title = "Avatar",
                        subtitle = "No se pudo cambiar Skin: " .. tostring(toggleError),
                        duration = 6,
                    })
                end
            end,
        })
    end
    zones.Toggles.Visuals_AvatarAccessories = function()
        AvatarIntegration.AccessoriesControl = tV:CreateToggle({
            name = "Accessorios",
            description = "Mostrar u ocultar el botón flotante",
            flag = "Silent_AvatarAccessories",
            value = false,
            callback = function(value)
                local ok, toggleError = setAvatarModuleEnabled("accessories", value)
                if not ok then
                    AvatarIntegration.AccessoriesEnabled = false
                    resetAvatarModuleToggle("accessories")
                    Window:Toast({
                        title = "Avatar",
                        subtitle = "No se pudo cambiar Accessorio: " .. tostring(toggleError),
                        duration = 6,
                    })
                end
            end,
        })
    end

    local sequence = {
        { "Layout", "Visuals_PlayerOptions" },
        { "Toggles", "Visuals_HideName" },
        { "Layout", "Visuals_EspOptions" },
        { "Toggles", "Visuals_EspPlayers" },
        { "Toggles", "Visuals_EspGlow" },
        { "Toggles", "Visuals_EspName" },
        { "Toggles", "Visuals_EspDistance" },
        { "Toggles", "Visuals_EspTracers" },
        { "Toggles", "Visuals_EspArrows" },
        { "ColorPickers", "Visuals_EspColor" },
        { "Layout", "Visuals_AvatarVisualSection" },
        { "Toggles", "Visuals_AvatarSkins" },
        { "Toggles", "Visuals_AvatarAccessories" }
    }
    runSilentHubUIZones(zones, sequence)
end
BuildVisualsUI = SourceZones.UI.Builders.BuildVisualsUI

local BuildExtrasPerformanceUI
SourceZones.UI.Builders.BuildExtrasPerformanceUI = function()
    local zones = SilentHubUIZones
    zones.Layout.ExtrasPerformance_Performance = function() tG:CreateSection({name="Optimización de FPS"}) end
    zones.Toggles.ExtrasPerformance_LowGraphics = function() tG:CreateToggle({name="LowGraphics Mode",flag="Silent_LowGfx",value=false,callback=function(v) Silent.State.Gfx.Low=v Silent.Events:Emit("ToggleLowGfx",v) end}) end
    zones.Toggles.ExtrasPerformance_BoostFps = function() tG:CreateToggle({name="BoostFps Mode",flag="Silent_BoostFps",value=false,callback=function(v) Silent.State.Gfx.BoostFps=v Silent.Events:Emit("ToggleBoostFps",v) end}) end
    zones.Toggles.ExtrasPerformance_SmartRender = function() tG:CreateToggle({name="Smart Render",flag="Silent_SmartRender",value=false,callback=function(v) Silent.State.Gfx.SmartRender=v Silent.Events:Emit("ToggleSmartRender",v) end}) end
    zones.Sliders.ExtrasPerformance_RenderDistance = function() tG:CreateSlider({name="Distancia de Renderizado",range={50,2000},increment=25,value=500,flag="Silent_RenderDist",callback=function(v) Silent.State.Gfx.RenderDist=v end}) end
    local sequence = {
        { "Layout", "ExtrasPerformance_Performance" },
        { "Toggles", "ExtrasPerformance_LowGraphics" },
        { "Toggles", "ExtrasPerformance_BoostFps" },
        { "Toggles", "ExtrasPerformance_SmartRender" },
        { "Sliders", "ExtrasPerformance_RenderDistance" }
    }
    runSilentHubUIZones(zones, sequence)
end
BuildExtrasPerformanceUI = SourceZones.UI.Builders.BuildExtrasPerformanceUI

local BuildExtrasUI
SourceZones.UI.Builders.BuildExtrasUI = function()
    local skyboxDropdown

    local zones = SilentHubUIZones
    zones.Layout.Extras_Skybox = function() tG:CreateSection({name="Skybox / Cielos"}) end
    zones.Dropdowns.Extras_SkyboxSelect = function()
        skyboxDropdown = tG:CreateDropdown({ name="Seleccionar cielo", flag="Silent_Skybox", options=skyboxNames, currentOption={"Original"}, multipleOptions=false, callback=function(name) if type(name) == "table" then name = name[1] end SkyboxEngine:Request(name or "Original") end })
        local initialSkyboxName
        pcall(function() initialSkyboxName = skyboxDropdown:Get() end)
        if type(initialSkyboxName) == "table" then initialSkyboxName = initialSkyboxName[1] end
        if type(initialSkyboxName) == "string" and initialSkyboxName ~= "" and initialSkyboxName ~= "Original" then
            if table.find(skyboxNames, initialSkyboxName) then
                SkyboxEngine:Request(initialSkyboxName)
            end
        end
    end
    zones.Buttons.Extras_RestoreSkybox = function() tG:CreateButton({ name="Restaurar cielo original", callback=function() SkyboxEngine:Restore() Silent.Events:Emit("Toast", "Cielo original restaurado") end }) end
    zones.Layout.Extras_Spoof = function()
        tG:CreateSection({name="Replay Spoof"})
    end
    zones.Dropdowns.Extras_SpoofDevice = function()
        local spoofDropdown
        spoofDropdown = tG:CreateDropdown({
            name = "Dispositivo Original\nFake control",
            flag = "Silent_SpoofDevice",
            options = {
                "Default",
                "Teclado y mouse",
                "Control",
                "Desconocido",
            },
            currentOption = { "Default" },
            multipleOptions = false,
            callback = function(value)
                if type(value) == "table" then value = value[1] end
                local UserInputService = game:GetService("UserInputService")
                local isRealPC = UserInputService.KeyboardEnabled and not UserInputService.TouchEnabled

                if isRealPC and value == "Teclado y mouse" then
                    Silent.Events:Emit("Toast", "Ya estás en PC. Usando Default.")
                    Silent.State.Spoof.Device = "Default"
                    pcall(function() 
                        if spoofDropdown and type(spoofDropdown.Set) == "function" then
                            spoofDropdown:Set("Default") 
                        end
                    end)
                else
                    Silent.State.Spoof.Device = value or "Default"
                    Silent.Events:Emit("Toast", "Dispositivo: " .. tostring(Silent.State.Spoof.Device))
                end
            end,
        })
    end
    local sequence = {
        { "Layout", "Extras_Skybox" },
        { "Dropdowns", "Extras_SkyboxSelect" },
        { "Buttons", "Extras_RestoreSkybox" },
        { "Layout", "Extras_Spoof" },
        { "Dropdowns", "Extras_SpoofDevice" }
    }
    runSilentHubUIZones(zones, sequence)
end
BuildExtrasUI = SourceZones.UI.Builders.BuildExtrasUI

BuildHomeUI()
BuildConfigurationUI()
BuildCombatUI()
BuildVisualsUI()
BuildExtrasPerformanceUI()
BuildExtrasUI()

Silent.Scheduler:Start(RunService)
end, debug.traceback)

if not uiBuildOk then
    if type(getgenv().SilentHubCleanup) == "function" then
        pcall(getgenv().SilentHubCleanup)
    elseif Window then
        pcall(function() Window:Unload() end)
    end
    error("Falló la inicialización de controles: " .. tostring(uiBuildError), 0)
end
