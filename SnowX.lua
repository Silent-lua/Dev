local OpenHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/Styx-ui/Openhub/refs/heads/main/OpenHub.lua"))()

local Window = OpenHub:CreateWindow({
    Title = "SnowX",
    Subtitle = "By Fabnx1",
    Icon = "rbxassetid://75446855480940",
    Theme = "Light",
    Width = 600,
    Height = 320,
    Acrylic = 0.97,
    Glass = 0.97,
    Resizable = false,
    Intro = true
})

Window:SetBackground("https://raw.githubusercontent.com/Styx-ui/Openhub/refs/heads/main/SnowX.jpg", {
    Transparency = 0,
    ScaleType = "Crop"
})

local Tabs = {
    Movement = Window:CreateTab({Name = "Player", Icon = "rbxassetid://6034287594"}),
    Combat = Window:CreateTab({Name = "Aim assist", Icon = "rbxassetid://6034684930"}),
    Visual = Window:CreateTab({Name = "Esp", Icon = "rbxassetid://6034767608"}),
    Performance = Window:CreateTab({Name = "Extra", Icon = "rbxassetid://6026568198"}),
    Animaciones = Window:CreateTab({Name = "Animations", Icon = "rbxassetid://6034287594"}),
    Texturas = Window:CreateTab({Name = "Sky", Icon = "rbxassetid://6031075938"}),
    Settings = Window:CreateTab({Name = "Discord", Icon = "rbxassetid://3926305904"})
}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

_G.SpeedEnabled = false
_G.SpeedMultiplier = 0
_G.InfiniteJump = false
_G.FOVEnabled = false
_G.WallClimb = false

getgenv().FlyActive = false
local velocidadVuelo = 60
local flyConnection = nil
local InvisActive = false

local plr = LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    hum = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
    if getgenv().FlyActive then
        task.wait(0.2)
        iniciarVuelo()
    end
    if InvisFrame and InvisFrame.Visible then
        InvisActive = false
        if InvisBtn then
            InvisBtn.Text = "INVISIBLE"
            InvisBtn.TextColor3 = Color3.fromRGB(140, 50, 255)
        end
        if InvisStroke then
            InvisStroke.Color = Color3.fromRGB(140, 50, 255)
        end
    end
end)

Tabs.Movement:CreateSection("Player")

Tabs.Movement:CreateToggle({
    Name = "Activar Speed",
    CurrentValue = false,
    Callback = function(state) _G.SpeedEnabled = state end
})

Tabs.Movement:CreateSlider({
    Name = "Speed Slider",
    Min = 0,
    Max = 100,
    CurrentValue = 0,
    Callback = function(v) _G.SpeedMultiplier = v / 100 end
})

local function iniciarVuelo()
    if flyConnection then return end
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")
    local posAnclada = root.Position
    humanoid.PlatformStand = true
    flyConnection = RunService.RenderStepped:Connect(function()
        if not getgenv().FlyActive or not character.Parent or not root.Parent then
            humanoid.PlatformStand = false
            if flyConnection then
                flyConnection:Disconnect()
                flyConnection = nil
            end
            return
        end
        local lookVector = camera.CFrame.LookVector
        local rightVector = camera.CFrame.RightVector
        local moverDir = humanoid.MoveDirection
        local vertical = 0
        if moverDir.Magnitude > 0 then
            local flatLook = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
            local flatRight = Vector3.new(rightVector.X, 0, rightVector.Z).Unit
            local dotForward = moverDir:Dot(flatLook)
            if dotForward > 0.5 then
                vertical = lookVector.Y * moverDir.Magnitude
            elseif dotForward < -0.5 then
                vertical = -lookVector.Y * moverDir.Magnitude
            end
        end
        local vectorVelocidad = (moverDir * velocidadVuelo) + Vector3.new(0, vertical * velocidadVuelo, 0)
        posAnclada = posAnclada + (vectorVelocidad * task.wait())
        root.CFrame = CFrame.new(posAnclada, posAnclada + lookVector)
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end)
end

Tabs.Movement:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = function(state)
        getgenv().FlyActive = state
        if state then
            iniciarVuelo()
        else
            local character = LocalPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.PlatformStand = false end
            if flyConnection then
                flyConnection:Disconnect()
                flyConnection = nil
            end
        end
    end
})

Tabs.Movement:CreateSlider({
    Name = "Speed Fly",
    Min = 10,
    Max = 150,
    CurrentValue = 60,
    Callback = function(v) velocidadVuelo = v end
})

Tabs.Movement:CreateSection("Movimiento Tela")

local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local TelaConfig = {TurnSpeed = 45, SideThreshold = 0.35, InstantTurn = false}
local TelaStepName = "FreeFireTelaMovement"
local TelaEnabled = false

local function handleTelaMovement(dt)
    if not TelaEnabled then return end
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local camera = workspace.CurrentCamera
    
    if not humanoid or not rootPart or not camera or humanoid.Health <= 0 then return end
    
    local rightVector = camera.CFrame.RightVector
    local flatRight = Vector3.new(rightVector.X, 0, rightVector.Z)
    if flatRight.Magnitude < 0.001 then return end
    flatRight = flatRight.Unit
    
    local side = humanoid.MoveDirection:Dot(flatRight)
    if math.abs(side) < TelaConfig.SideThreshold then
        humanoid.AutoRotate = true
        return
    end
    
    humanoid.AutoRotate = false
    local currentPos = rootPart.Position
    local targetCFrame = CFrame.lookAt(currentPos, currentPos + (side > 0 and flatRight or -flatRight))
    
    if TelaConfig.InstantTurn then
        rootPart.CFrame = targetCFrame
    else
        rootPart.CFrame = rootPart.CFrame:Lerp(targetCFrame, 1 - math.exp(-TelaConfig.TurnSpeed * dt))
    end
end

Tabs.Movement:CreateToggle({
    Name = "Movimiento Tela",
    CurrentValue = false,
    Callback = function(state)
        TelaEnabled = state
        if state then
            RunService:UnbindFromRenderStep(TelaStepName)
            RunService:BindToRenderStep(TelaStepName, Enum.RenderPriority.Character.Value + 1, handleTelaMovement)
            Window:Notify({Title = "Player", Text = "Movimiento Tela Activado", Duration = 2})
        else
            RunService:UnbindFromRenderStep(TelaStepName)
            local character = LocalPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.AutoRotate = true
            end
            Window:Notify({Title = "Player", Text = "Movimiento Tela Desactivado", Duration = 2})
        end
    end
})

Tabs.Movement:CreateSlider({
    Name = "Velocidad de Giro Tela",
    Min = 10,
    Max = 100,
    CurrentValue = 45,
    Callback = function(value)
        TelaConfig.TurnSpeed = value
    end
})

local InvisGui = Instance.new("ScreenGui")
InvisGui.Name = "NexusInvisBtn"
InvisGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
InvisGui.IgnoreGuiInset = true
InvisGui.ResetOnSpawn = false

local InvisFrame = Instance.new("Frame")
InvisFrame.Parent = InvisGui
InvisFrame.Size = UDim2.new(0, 80, 0, 30)
InvisFrame.Position = UDim2.new(0.7, 0, 0.6, 0)
InvisFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
InvisFrame.BackgroundTransparency = 0.5
InvisFrame.BorderSizePixel = 0
InvisFrame.Visible = false

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = InvisFrame

local InvisStroke = Instance.new("UIStroke")
InvisStroke.Parent = InvisFrame
InvisStroke.Color = Color3.fromRGB(140, 50, 255)
InvisStroke.Thickness = 1.5

local InvisBtn = Instance.new("TextButton")
InvisBtn.Parent = InvisFrame
InvisBtn.Size = UDim2.new(1, 0, 1, 0)
InvisBtn.BackgroundTransparency = 1
InvisBtn.Text = "INVISIBLE"
InvisBtn.TextColor3 = Color3.fromRGB(140, 50, 255)
InvisBtn.Font = Enum.Font.GothamBlack
InvisBtn.TextSize = 11

local function SetInvisState(state)
    InvisFrame.Visible = state
    if not state then
        InvisActive = false
        InvisBtn.Text = "INVISIBLE"
        InvisBtn.TextColor3 = Color3.fromRGB(140, 50, 255)
        InvisStroke.Color = Color3.fromRGB(140, 50, 255)
        if LocalPlayer.Character then
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") and v.Transparency == 0.5 then
                    v.Transparency = 0
                end
            end
        end
    end
end

InvisBtn.MouseButton1Click:Connect(function()
    if not InvisFrame.Visible then return end
    InvisActive = not InvisActive
    if InvisActive then
        InvisBtn.Text = "ACTIVE"
        InvisBtn.TextColor3 = Color3.fromRGB(0, 255, 100)
        InvisStroke.Color = Color3.fromRGB(0, 255, 100)
        if LocalPlayer.Character then
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") and v.Transparency == 0 then
                    v.Transparency = 0.5
                end
            end
        end
    else
        InvisBtn.Text = "INVISIBLE"
        InvisBtn.TextColor3 = Color3.fromRGB(140, 50, 255)
        InvisStroke.Color = Color3.fromRGB(140, 50, 255)
        if LocalPlayer.Character then
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") and v.Transparency == 0.5 then
                    v.Transparency = 0
                end
            end
        end
    end
end)

Tabs.Movement:CreateToggle({
    Name = "Invisible",
    CurrentValue = false,
    Callback = function(Value) SetInvisState(Value) end
})

Tabs.Movement:CreateSection("Jump & FOV")

local superJumpConexion = nil
local fuerzaSalto = 95

Tabs.Movement:CreateToggle({
    Name = "Super Jump",
    CurrentValue = false,
    Callback = function(state)
        if state then
            if superJumpConexion then return end
            superJumpConexion = UserInputService.JumpRequest:Connect(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if root and hum and hum.FloorMaterial ~= Enum.Material.Air then
                    root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, fuerzaSalto, root.AssemblyLinearVelocity.Z)
                end
            end)
        else
            if superJumpConexion then
                superJumpConexion:Disconnect()
                superJumpConexion = nil
            end
        end
    end
})

Tabs.Movement:CreateSlider({
    Name = "Fuerza de Impulso",
    Min = 50,
    Max = 200,
    CurrentValue = 95,
    Callback = function(value) fuerzaSalto = value end
})

Tabs.Movement:CreateToggle({
    Name = "Infinite Leap",
    CurrentValue = false,
    Callback = function(state) _G.InfiniteJump = state end
})

Tabs.Movement:CreateToggle({
    Name = "FOV",
    CurrentValue = false,
    Callback = function(state)
        _G.FOVEnabled = state
        if not state then workspace.CurrentCamera.FieldOfView = 70 end
    end
})

Tabs.Movement:CreateSlider({
    Name = "Valor FOV",
    Min = 70,
    Max = 120,
    CurrentValue = 70,
    Callback = function(v)
        if _G.FOVEnabled then workspace.CurrentCamera.FieldOfView = v end
    end
})

Tabs.Movement:CreateToggle({
    Name = "Wall Climb",
    CurrentValue = false,
    Callback = function(state) _G.WallClimb = state end
})

Tabs.Movement:CreateSection("Farm")

local AutoFarmActivo = false
local autoFarmLoopRunning = false

Tabs.Movement:CreateToggle({
    Name = "Auto Farm",
    CurrentValue = false,
    Callback = function(state)
        AutoFarmActivo = state
        if AutoFarmActivo and not autoFarmLoopRunning then
            autoFarmLoopRunning = true
            task.spawn(function()
                local container = Workspace:FindFirstChild("SpawnablesClient") or Workspace:WaitForChild("SpawnablesClient", 5)
                if not container then
                    Window:Notify({Title = "Auto Farm", Text = "No se encontró SpawnablesClient", Duration = 3})
                    autoFarmLoopRunning = false
                    return
                end
                while AutoFarmActivo do
                    for _, obj in ipairs(container:GetChildren()) do
                        if not AutoFarmActivo then break end
                        local touchPart = obj:FindFirstChild("Touch")
                        local character = LocalPlayer.Character
                        if touchPart and character and character:FindFirstChild("HumanoidRootPart") then
                            pcall(function()
                                firetouchinterest(character.HumanoidRootPart, touchPart, 0)
                                firetouchinterest(character.HumanoidRootPart, touchPart, 1)
                            end)
                        end
                    end
                    task.wait(0.45)
                end
                autoFarmLoopRunning = false
            end)
        end
    end
})

RunService.RenderStepped:Connect(function()
    if _G.SpeedEnabled and _G.SpeedMultiplier > 0 then
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if rootPart and humanoid and humanoid.MoveDirection.Magnitude > 0 then
            rootPart.CFrame = rootPart.CFrame + (humanoid.MoveDirection * _G.SpeedMultiplier)
        end
    end
    if _G.WallClimb then
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if humanoid and rootPart and humanoid.MoveDirection.Magnitude > 0 then
            rootPart.Velocity = Vector3.new(rootPart.Velocity.X, 25, rootPart.Velocity.Z)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if InvisActive and InvisFrame.Visible then
        local Char = LocalPlayer.Character
        if Char then
            local Root = Char:FindFirstChild("HumanoidRootPart")
            local Hum = Char:FindFirstChild("Humanoid")
            if Root and Hum and Hum.Health > 0 then
                if Root.Position.Y > 200 then return end
                local oldCF = Root.CFrame
                local oldCamOffset = Hum.CameraOffset
                local invisCF = oldCF * CFrame.new(0, -50, 0)
                Root.CFrame = invisCF
                Hum.CameraOffset = invisCF:ToObjectSpace(CFrame.new(oldCF.Position)).Position
                RunService.RenderStepped:Wait()
                if Root and Root.Parent and Hum.Health > 0 then
                    Root.CFrame = oldCF
                    Hum.CameraOffset = oldCamOffset
                end
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if _G.InfiniteJump then
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)

task.spawn(function()
    while true do
        if InvisFrame and InvisFrame.Visible and not InvisActive then
            local t1 = TweenService:Create(InvisStroke, TweenInfo.new(1, Enum.EasingStyle.Sine), {Transparency = 0.4})
            t1:Play()
            t1.Completed:Wait()
            local t2 = TweenService:Create(InvisStroke, TweenInfo.new(1, Enum.EasingStyle.Sine), {Transparency = 0})
            t2:Play()
            t2.Completed:Wait()
        else
            task.wait(0.5)
        end
    end
end)

local MacroEnabled = false
local TargetBodyPart = "Cabeza"
local TorsoPartNames = {"UpperTorso", "Torso", "HumanoidRootPart"}
getgenv().CurrentTargetPart = nil
getgenv().AutoShootTarget = nil
getgenv().AutoEquipEnabled = false
getgenv().AutoEquipSecondary = false

local TouchStartPos = Vector2.new(0, 0)
local TouchStartTime = 0
local TOUCH_THRESHOLD = 20
local TouchStartPos2 = Vector2.new()
local TouchStartTime2 = 0
local TOUCH_THRESHOLD2 = 20

local AutoShootNormal = false
local AutoShootAggressive = false

local AutoShooter = {
    Cooldown = 0.2,
    HoldExtra = 0.05,
    LastFire = 0,
    Connection = nil,
    RaycastParams = nil,
}

local StandardPartNames = {"Head", "HumanoidRootPart", "UpperTorso", "Torso"}

local function GetScoreboard()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    local main = playerGui:FindFirstChild("Main")
    if not main then return nil end
    local frame = main:FindFirstChild("MainGameFrame")
    if not frame then return nil end
    return frame:FindFirstChild("IngameScore")
end

local function RefreshTeamData()
    local snapshot = {}
    local scoreboard = GetScoreboard()
    if scoreboard then
        local redFolder = scoreboard:FindFirstChild("TeamRed")
        local blueFolder = scoreboard:FindFirstChild("TeamBlue")
        if redFolder then
            for _, entry in ipairs(redFolder:GetChildren()) do
                snapshot[string.lower(entry.Name)] = "Red"
            end
        end
        if blueFolder then
            for _, entry in ipairs(blueFolder:GetChildren()) do
                snapshot[string.lower(entry.Name)] = "Blue"
            end
        end
    end
    return snapshot
end

local function GetPlayerTeam(targetPlayer)
    if not targetPlayer then return nil end
    local snapshot = RefreshTeamData()
    local team = snapshot[string.lower(targetPlayer.Name)]
    if not team and targetPlayer.DisplayName then
        team = snapshot[string.lower(targetPlayer.DisplayName)]
    end
    return team
end

local function IsEnemy(targetPlayer)
    if not targetPlayer or targetPlayer == LocalPlayer then return false end
    local myTeam = GetPlayerTeam(LocalPlayer)
    local theirTeam = GetPlayerTeam(targetPlayer)
    if not myTeam or not theirTeam then return false end
    return myTeam ~= theirTeam
end

local function IsInLobby()
    return false
end

local function FindWeapon()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") and item:FindFirstChild("fire") then
                return item
            end
        end
    end
    if character then
        for _, item in ipairs(character:GetChildren()) do
            if item:IsA("Tool") and item:FindFirstChild("fire") then
                return item
            end
        end
    end
    return nil
end

local function HasMeleeWeapon(character)
    local tool = character and character:FindFirstChildOfClass("Tool")
    return tool and (
        tool:FindFirstChild("Kill")
        or tool:FindFirstChild("ThrowKill")
        or tool:FindFirstChild("ActivateThrowing")
    ) ~= nil
end

local function CheckEnemiesForMacro()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and IsEnemy(p) then
            local pChar = p.Character
            if pChar and pChar:FindFirstChild("Humanoid") and pChar.Humanoid.Health > 0 then
                return true
            end
        end
    end
    return false
end

local function ExecuteMacroAction()
    if not CheckEnemiesForMacro() then return end
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then return end
    if HasMeleeWeapon(character) then return end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local weapon = FindWeapon()
    if weapon then
        task.spawn(function()
            character.Humanoid:EquipTool(weapon)
            task.wait(0.04)
            weapon:Activate()
            task.wait(0.1)
            if weapon.Parent == character and backpack then
                weapon.Parent = backpack
            end
        end)
    end
end

local function FindWeaponSecondary()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character
    if character then
        if HasMeleeWeapon(character) then return nil end
    end
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("fire") then
                return tool
            end
        end
    end
    if character then
        for _, tool in ipairs(character:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("fire") then
                return tool
            end
        end
    end
    return nil
end

local function CheckEnemiesSecondary()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and IsEnemy(p) then
            local c = p.Character
            if c and c:FindFirstChild("Humanoid") and c.Humanoid.Health > 0 then
                return true
            end
        end
    end
    return false
end

local function ExecuteSecondaryMacro()
    if not CheckEnemiesSecondary() then return end
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local weapon = FindWeaponSecondary()
    if weapon then
        task.spawn(function()
            humanoid:EquipTool(weapon)
            task.wait(0.04)
            weapon:Activate()
            task.wait(0.10)
            if backpack and weapon.Parent == character then
                weapon.Parent = backpack
            end
        end)
    end
end

local function HasLineOfSight(part, origin, params)
    local size = part.Size
    local offsets = {
        Vector3.zero,
        Vector3.new(size.X / 2.1, 0, 0),
        Vector3.new(-size.X / 2.1, 0, 0),
        Vector3.new(0, size.Y / 2.1, 0),
        Vector3.new(0, -size.Y / 2.1, 0),
    }
    for _, off in ipairs(offsets) do
        local targetPos = part.CFrame * off
        if not Workspace:Raycast(origin, targetPos - origin, params) then
            return true
        end
    end
    return false
end

local function GetEquippedFirearm()
    local character = LocalPlayer.Character
    if not character then return nil end
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            local fire = tool:FindFirstChild("fire")
            local beam = tool:FindFirstChild("showBeam")
            if (fire and fire:IsA("RemoteEvent")) or (beam and beam:IsA("RemoteEvent")) then
                return tool
            end
        end
    end
    return nil
end

local function FindOptimalTarget()
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not (character and hrp) then return nil end
    if not AutoShooter.RaycastParams then
        AutoShooter.RaycastParams = RaycastParams.new()
        AutoShooter.RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
        AutoShooter.RaycastParams.IgnoreWater = true
    end
    local best, bestDist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and IsEnemy(p) and p.Character then
            local enemyHum = p.Character:FindFirstChild("Humanoid")
            if enemyHum and enemyHum.Health > 0 then
                AutoShooter.RaycastParams.FilterDescendantsInstances = {character, p.Character}
                local function EvaluatePart(part)
                    local dist = (part.Position - hrp.Position).Magnitude
                    if dist < bestDist and HasLineOfSight(part, hrp.Position, AutoShooter.RaycastParams) then
                        best, bestDist = part, dist
                    end
                end
                if AutoShootAggressive then
                    for _, part in ipairs(p.Character:GetChildren()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            EvaluatePart(part)
                        end
                    end
                else
                    for _, name in ipairs(StandardPartNames) do
                        local part = p.Character:FindFirstChild(name)
                        if part and part:IsA("BasePart") then
                            EvaluatePart(part)
                        end
                    end
                end
            end
        end
    end
    return best
end

local function TriggerFire()
    local character = LocalPlayer.Character
    local hum = character and character:FindFirstChildOfClass("Humanoid")
    if not (character and hum and hum.Health > 0) then return end
    local firearm = GetEquippedFirearm()
    if not firearm then return end
    local target = FindOptimalTarget()
    if not (target and target.Parent) then
        getgenv().AutoShootTarget = nil
        return
    end
    getgenv().AutoShootTarget = target
    AutoShooter.LastFire = os.clock()
    pcall(function() firearm:Activate() end)
    task.delay(AutoShooter.HoldExtra, function()
        if firearm.Parent == character then
            pcall(function() firearm:Deactivate() end)
        end
    end)
end

local function StartAutoShooter()
    if AutoShooter.Connection then return end
    AutoShooter.LastFire = 0
    AutoShooter.Connection = RunService.Heartbeat:Connect(function()
        if not (AutoShootNormal or AutoShootAggressive) then
            getgenv().AutoShootTarget = nil
            return
        end
        local target = FindOptimalTarget()
        getgenv().AutoShootTarget = target
        if not target then return end
        local now = os.clock()
        if now - AutoShooter.LastFire < AutoShooter.Cooldown then return end
        AutoShooter.LastFire = now
        TriggerFire()
    end)
end

local function StopAutoShooter()
    if AutoShooter.Connection then
        AutoShooter.Connection:Disconnect()
        AutoShooter.Connection = nil
    end
    getgenv().AutoShootTarget = nil
end

Tabs.Combat:CreateSection("Macro")

Tabs.Combat:CreateToggle({
    Name = "Macro",
    CurrentValue = false,
    Callback = function(Value)
        MacroEnabled = Value
        getgenv().AutoEquipEnabled = Value
        if not Value then getgenv().CurrentTargetPart = nil end
    end
})

Tabs.Combat:CreateDropdown({
    Name = "Target: Parte del cuerpo",
    Options = {"Cabeza", "Torso", "Cuerpo Completo"},
    CurrentOption = "Cabeza",
    Callback = function(Value) TargetBodyPart = Value end
})

Tabs.Combat:CreateToggle({
    Name = "Macro legit",
    CurrentValue = false,
    Callback = function(Value) getgenv().AutoEquipSecondary = Value end
})

local weaponRainbowEnabled = false
local rainbowSpeed = 0.5
local originalTextures = {}

local function restaurarTexturas(weapon)
    if not weapon then return end
    for _, part in ipairs(weapon:GetDescendants()) do
        if originalTextures[part] then
            if part:IsA("MeshPart") then
                part.TextureID = originalTextures[part].TextureID
                part.Color = originalTextures[part].Color
            elseif part:IsA("SpecialMesh") then
                part.TextureId = originalTextures[part].TextureId
                part.VertexColor = originalTextures[part].VertexColor
            elseif part:IsA("BasePart") then
                part.Color = originalTextures[part].Color
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    if not weaponRainbowEnabled then return end
    local character = LocalPlayer.Character
    if not character then return end
    local weapon = character:FindFirstChildOfClass("Tool")
    if weapon then
        local hue = (tick() * rainbowSpeed) % 1
        local rainbowColor = Color3.fromHSV(hue, 1, 1)
        for _, part in ipairs(weapon:GetDescendants()) do
            if (part:IsA("MeshPart") or part:IsA("SpecialMesh") or part:IsA("BasePart")) and not originalTextures[part] then
                if part:IsA("MeshPart") then
                    originalTextures[part] = {TextureID = part.TextureID, Color = part.Color}
                elseif part:IsA("SpecialMesh") then
                    originalTextures[part] = {TextureId = part.TextureId, VertexColor = part.VertexColor}
                elseif part:IsA("BasePart") then
                    originalTextures[part] = {Color = part.Color}
                end
            end
            if part:IsA("MeshPart") then
                part.TextureID = ""
                part.Color = rainbowColor
            elseif part:IsA("SpecialMesh") then
                part.TextureId = ""
                part.VertexColor = Vector3.new(rainbowColor.R, rainbowColor.G, rainbowColor.B)
            elseif part:IsA("BasePart") then
                part.Color = rainbowColor
            end
        end
    end
end)

Tabs.Combat:CreateToggle({
    Name = "Arma Rainbow",
    CurrentValue = false,
    Callback = function(state)
        weaponRainbowEnabled = state
        if not state then
            local character = LocalPlayer.Character
            local weapon = character and character:FindFirstChildOfClass("Tool")
            if weapon then restaurarTexturas(weapon) end
        end
    end
})

Tabs.Combat:CreateSection("Auto Shoot")

Tabs.Combat:CreateToggle({
    Name = "Auto Shoot",
    CurrentValue = false,
    Callback = function(Value)
        AutoShootNormal = Value
        if Value then
            StartAutoShooter()
        else
            if not AutoShootAggressive then StopAutoShooter() end
            getgenv().AutoShootTarget = nil
        end
    end
})

Tabs.Combat:CreateToggle({
    Name = "Auto Shoot Agresivo",
    CurrentValue = false,
    Callback = function(Value)
        AutoShootAggressive = Value
        if Value then
            StartAutoShooter()
        else
            if not AutoShootNormal then StopAutoShooter() end
            getgenv().AutoShootTarget = nil
        end
    end
})

local AutoEquipFirearm = false
local LastEquipTime = 0

local function GetFirearmFromInventory()
    local character = LocalPlayer.Character
    if character then
        local toolInHand = character:FindFirstChildOfClass("Tool")
        if toolInHand and toolInHand.Name ~= "Knife" and toolInHand.Name ~= "Cuchillo" then
            if not toolInHand:FindFirstChild("Stab") then
                return toolInHand
            end
        end
    end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        local gun = backpack:FindFirstChild("Gun") or backpack:FindFirstChild("DefaultGun") or backpack:FindFirstChild("Revolver")
        if not gun then
            for _, item in ipairs(backpack:GetChildren()) do
                if item:IsA("Tool") then
                    local nameLower = string.lower(item.Name)
                    if not string.find(nameLower, "knife") and not string.find(nameLower, "cuchillo") then
                        if item:FindFirstChild("fire") or item:FindFirstChild("showBeam") or item:FindFirstChild("Shoot") then
                            gun = item
                            break
                        end
                    end
                end
            end
        end
        if gun and gun.Parent then return gun end
    end
    return nil
end

local FirearmLOSParams = RaycastParams.new()
FirearmLOSParams.FilterType = Enum.RaycastFilterType.Exclude
FirearmLOSParams.IgnoreWater = true

local function HasClearFirearmLOS(origin, enemyChar, localChar)
    FirearmLOSParams.FilterDescendantsInstances = {localChar, enemyChar}
    local enemyRoot = enemyChar:FindFirstChild("HumanoidRootPart")
    if not enemyRoot then return false end
    local enemyHead = enemyChar:FindFirstChild("Head")
    local targets = {
        enemyRoot.Position,
        enemyHead and enemyHead.Position or (enemyRoot.Position + Vector3.new(0, 2, 0)),
        enemyRoot.Position - Vector3.new(0, 2, 0)
    }
    local visiblePoints = 0
    for _, targetPos in ipairs(targets) do
        if not Workspace:Raycast(origin, targetPos - origin, FirearmLOSParams) then
            visiblePoints = visiblePoints + 1
        end
    end
    return visiblePoints >= 2
end

local function HasValidVisibleEnemy()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    local rootPart = character.HumanoidRootPart
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= LocalPlayer and IsEnemy(otherPlayer) then
            local enemyChar = otherPlayer.Character
            if enemyChar then
                local enemyRoot = enemyChar:FindFirstChild("HumanoidRootPart")
                local enemyHum = enemyChar:FindFirstChildOfClass("Humanoid")
                if enemyRoot and enemyHum and enemyHum.Health > 0 then
                    if HasClearFirearmLOS(rootPart.Position, enemyChar, character) then
                        return true
                    end
                end
            end
        end
    end
    return false
end

RunService.Heartbeat:Connect(function()
    if not AutoEquipFirearm or (tick() - LastEquipTime < 0.5) then return end
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if not humanoid or humanoid.Health <= 0 or not backpack or character:FindFirstChildOfClass("Tool") then return end
    if HasValidVisibleEnemy() then
        local gun = GetFirearmFromInventory()
        if gun and gun.Parent == backpack then
            pcall(function() humanoid:EquipTool(gun) end)
            LastEquipTime = tick()
        end
    end
end)

Tabs.Combat:CreateToggle({
    Name = "Auto Equipar",
    Description = "Usalo solo con el Autoshoot",
    CurrentValue = false,
    Callback = function(Value) AutoEquipFirearm = Value end
})

Tabs.Combat:CreateSection("Silent Aim")

local function IsMobileDevice()
    local ok, platform = pcall(function()
        return UserInputService:GetPlatform()
    end)
    if ok and ((platform == Enum.Platform.Android) or (platform == Enum.Platform.IOS)) then
        return true
    end
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local IS_MOBILE_DEVICE = IsMobileDevice()

local function GetAimPosition()
    if IS_MOBILE_DEVICE then
        local cam = workspace.CurrentCamera
        return (cam and (cam.ViewportSize / 2)) or Vector2.zero
    end
    return UserInputService:GetMouseLocation()
end

local function GetRootPart(player)
    local char = player and player.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return (hrp and hrp:IsA("BasePart") and hrp) or nil
end

local function IsPlayerAlive(player)
    local char = player and player.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and (hum.Health > 0)
end

local function IsValidTarget(player)
    if not player or (player == LocalPlayer) then return false end
    return IsEnemy(player) and IsPlayerAlive(player)
end

local function GetTargetPart(player)
    local char = player and player.Character
    if not char then return nil end
    if TargetBodyPart == "Cabeza" then
        return char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
    elseif TargetBodyPart == "Torso" then
        return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
    elseif TargetBodyPart == "Cuerpo Completo" then
        local parts = {"Head", "UpperTorso", "Torso", "LeftUpperArm", "RightUpperArm", "LeftLowerLeg", "RightLowerLeg"}
        for _, name in ipairs(parts) do
            local p = char:FindFirstChild(name)
            if p and p:IsA("BasePart") then return p end
        end
    end
    return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end

local function HasTargetLOS(target, targetPart)
    local myChar = LocalPlayer.Character
    local myHRP = GetRootPart(LocalPlayer)
    if not (myChar and myHRP and target and target.Character and targetPart) then return false end
    local dir = targetPart.Position - myHRP.Position
    if dir.Magnitude <= 0 then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {myChar}
    params.IgnoreWater = true
    local hit = workspace:Raycast(myHRP.Position, dir, params)
    return not hit or (hit.Instance and hit.Instance:IsDescendantOf(target.Character))
end

local SilentAimSystem = {
    _hookInstalled = false,
    _target = nil,
    _maxDistance = 5000,
    _minRayLength = 20,
    _running = false,
    _loopConnection = nil
}

SilentAimSystem.Set = function(self, target)
    self._target = target
end

SilentAimSystem.InstallHook = function(self)
    if self._hookInstalled then return true end
    if (type(getrawmetatable) ~= "function") or (type(setreadonly) ~= "function") or (type(getnamecallmethod) ~= "function") or (type(checkcaller) ~= "function") then
        return false
    end
    local selfRef = self
    local wrap = ((type(newcclosure) == "function") and newcclosure) or function(fn) return fn end
    local ok = pcall(function()
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        local newNamecall = wrap(function(obj, ...)
            local target = selfRef._target
            if (target and target.Parent and (obj == workspace) and not checkcaller()) then
                local method = getnamecallmethod()
                if (method == "Raycast") then
                    local origin, dir, params = ...
                    if ((typeof(dir) == "Vector3") and (dir.Magnitude > selfRef._minRayLength)) then
                        local newDir = (target.Position - origin).Unit * selfRef._maxDistance
                        return oldNamecall(obj, origin, newDir, params)
                    end
                elseif string.find(method, "FindPartOnRay") then
                    local ray, ignore, terr, mat = ...
                    if ((typeof(ray) == "Ray") and (ray.Direction.Magnitude > selfRef._minRayLength)) then
                        local newRay = Ray.new(ray.Origin, (target.Position - ray.Origin).Unit * selfRef._maxDistance)
                        return oldNamecall(obj, newRay, ignore, terr, mat)
                    end
                end
            end
            return oldNamecall(obj, ...)
        end)
        setreadonly(mt, false)
        mt.__namecall = newNamecall
        setreadonly(mt, true)
        selfRef._origNamecall = oldNamecall
        selfRef._hookWrapper = newNamecall
        selfRef._hookInstalled = true
    end)
    return ok and self._hookInstalled
end

SilentAimSystem.RemoveHook = function(self)
    if not self._hookInstalled then return end
    pcall(function()
        local mt = getrawmetatable(game)
        if (self._hookWrapper and self._origNamecall and rawequal(mt.__namecall, self._hookWrapper)) then
            setreadonly(mt, false)
            mt.__namecall = self._origNamecall
            setreadonly(mt, true)
        end
    end)
    self._hookInstalled = false
    self._origNamecall = nil
    self._hookWrapper = nil
end

SilentAimSystem.FindClosestToCursor = function(self)
    local myChar = LocalPlayer.Character
    local myHRP = GetRootPart(LocalPlayer)
    if not (myChar and myHRP) then return nil end
    local cursor = GetAimPosition()
    local bestPart, bestDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if IsValidTarget(player) then
            local part = GetTargetPart(player)
            if (part and HasTargetLOS(player, part)) then
                local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local d = (Vector2.new(screenPos.X, screenPos.Y) - cursor).Magnitude
                    if (d < bestDist) then
                        bestPart, bestDist = part, d
                    end
                end
            end
        end
    end
    return bestPart
end

SilentAimSystem.Start = function(self)
    if not self:InstallHook() then return end
    if self._running then return end
    self._running = true
    self._loopConnection = RunService.RenderStepped:Connect(function()
        if not self._running then return end
        self:Set(self:FindClosestToCursor())
    end)
end

SilentAimSystem.Stop = function(self)
    if not self._running then
        self:RemoveHook()
        return
    end
    self._running = false
    self._target = nil
    if self._loopConnection then
        pcall(function() self._loopConnection:Disconnect() end)
        self._loopConnection = nil
    end
    self:RemoveHook()
end

Tabs.Combat:CreateToggle({
    Name = "Silent Aim",
    CurrentValue = false,
    Callback = function(state)
        if state then SilentAimSystem:Start() else SilentAimSystem:Stop() end
    end
})

Tabs.Combat:CreateDropdown({
    Name = "Target: Parte del cuerpo",
    Options = {"Cabeza", "Torso", "Cuerpo Completo"},
    CurrentOption = "Cabeza",
    Callback = function(Value) TargetBodyPart = Value end
})

if hookmetamethod and checkcaller then
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local activeTarget = getgenv().CurrentTargetPart or getgenv().AutoShootTarget
        if not checkcaller() and activeTarget and activeTarget.Parent then
            if method == "Raycast" and self == Workspace then
                local origin, direction, p3 = ...
                if typeof(direction) == "Vector3" and direction.Magnitude > 15 then
                    local newDir = (activeTarget.Position - origin).Unit * 8000
                    return oldNamecall(self, origin, newDir, p3)
                end
            elseif string.find(method, "FindPartOnRay") and self == Workspace then
                local ray, p2, p3, p4 = ...
                if typeof(ray) == "Ray" and ray.Direction.Magnitude > 15 then
                    local newRay = Ray.new(ray.Origin, (activeTarget.Position - ray.Origin).Unit * 8000)
                    return oldNamecall(self, newRay, p2, p3, p4)
                end
            end
        end
        return oldNamecall(self, ...)
    end)
end

task.spawn(function()
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    while task.wait(0.12) do
        if not MacroEnabled and not AutoShootNormal and not AutoShootAggressive then
            if not getgenv().AutoShootTarget then
                getgenv().CurrentTargetPart = nil
            end
            continue
        end
        local character = LocalPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then continue end
        local closestTargetPart = nil
        local shortestDistance = math.huge
        local myPos = character.HumanoidRootPart.Position
        local head = character:FindFirstChild("Head")
        local headPos = head and head.Position or myPos
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and IsEnemy(p) and p.Character then
                local enemyHum = p.Character:FindFirstChild("Humanoid")
                if enemyHum and enemyHum.Health > 0 then
                    local partsToScan = {}
                    if TargetBodyPart == "Cabeza" then
                        local enemyHead = p.Character:FindFirstChild("Head")
                        if enemyHead then table.insert(partsToScan, enemyHead) end
                    elseif TargetBodyPart == "Torso" then
                        for _, partName in ipairs(TorsoPartNames) do
                            local part = p.Character:FindFirstChild(partName)
                            if part and part:IsA("BasePart") then table.insert(partsToScan, part) end
                        end
                    else
                        for _, part in ipairs(p.Character:GetChildren()) do
                            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                                table.insert(partsToScan, part)
                            end
                        end
                    end
                    params.FilterDescendantsInstances = {character, p.Character}
                    for _, part in ipairs(partsToScan) do
                        local physicalDist = (part.Position - myPos).Magnitude
                        if physicalDist < shortestDistance then
                            local raycastResult = Workspace:Raycast(headPos, part.Position - headPos, params)
                            if not raycastResult then
                                shortestDistance = physicalDist
                                closestTargetPart = part
                            end
                        end
                    end
                end
            end
        end
        getgenv().CurrentTargetPart = closestTargetPart
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not getgenv().AutoEquipEnabled or gameProcessed or IsInLobby() then return end
    local character = LocalPlayer.Character
    if HasMeleeWeapon(character) then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        ExecuteMacroAction()
    elseif input.UserInputType == Enum.UserInputType.Touch then
        TouchStartPos = input.Position
        TouchStartTime = tick()
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if not getgenv().AutoEquipEnabled or gameProcessed then return end
    local character = LocalPlayer.Character
    if HasMeleeWeapon(character) then return end
    if input.UserInputType ~= Enum.UserInputType.Touch then return end
    if (input.Position - TouchStartPos).Magnitude < TOUCH_THRESHOLD and (tick() - TouchStartTime) < 0.25 then
        ExecuteMacroAction()
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp or not getgenv().AutoEquipSecondary or IsInLobby() then return end
    local character = LocalPlayer.Character
    if character then
        local tool = character:FindFirstChildOfClass("Tool")
        if tool and (
            tool:FindFirstChild("Kill")
            or tool:FindFirstChild("ThrowKill")
            or tool:FindFirstChild("ActivateThrowing")
        ) then return end
    end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        ExecuteSecondaryMacro()
    elseif input.UserInputType == Enum.UserInputType.Touch then
        TouchStartPos2 = input.Position
        TouchStartTime2 = tick()
    end
end)

UserInputService.InputEnded:Connect(function(input, gp)
    if gp or not getgenv().AutoEquipSecondary or input.UserInputType ~= Enum.UserInputType.Touch then return end
    local character = LocalPlayer.Character
    if character then
        local tool = character:FindFirstChildOfClass("Tool")
        if tool and (
            tool:FindFirstChild("Kill")
            or tool:FindFirstChild("ThrowKill")
            or tool:FindFirstChild("ActivateThrowing")
        ) then return end
    end
    if (input.Position - TouchStartPos2).Magnitude < TOUCH_THRESHOLD2 and (tick() - TouchStartTime2) < 0.25 then
        ExecuteSecondaryMacro()
    end
end)

local hitboxEnabled = false
local hitboxInvisible = false
local hitboxSize = 3.5
local hitboxColor = Color3.fromRGB(255, 0, 0)

local function limpiarHitboxes()
    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        local character = targetPlayer.Character
        if character then
            local hitbox = character:FindFirstChild("GhostHitbox")
            if hitbox then hitbox:Destroy() end
        end
    end
end

task.spawn(function()
    while task.wait(0.2) do
        if not hitboxEnabled then continue end
        local tamanoObjetivo = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
        local transObjetivo = hitboxInvisible and 1 or 0.6
        for _, targetPlayer in ipairs(Players:GetPlayers()) do
            if targetPlayer ~= LocalPlayer and IsEnemy(targetPlayer) then
                local character = targetPlayer.Character
                if character then
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if rootPart and humanoid and humanoid.Health > 0 then
                        local hitbox = character:FindFirstChild("GhostHitbox")
                        if not hitbox then
                            hitbox = Instance.new("Part")
                            hitbox.Name = "GhostHitbox"
                            hitbox.Size = tamanoObjetivo
                            hitbox.Transparency = transObjetivo
                            hitbox.Color = hitboxColor
                            hitbox.CanCollide = false
                            hitbox.Massless = true
                            hitbox.CanQuery = true
                            hitbox.CFrame = rootPart.CFrame
                            hitbox.Parent = character
                            local weld = Instance.new("WeldConstraint")
                            weld.Part0 = rootPart
                            weld.Part1 = hitbox
                            weld.Parent = hitbox
                        else
                            if hitbox.Size ~= tamanoObjetivo then hitbox.Size = tamanoObjetivo end
                            if hitbox.Transparency ~= transObjetivo then hitbox.Transparency = transObjetivo end
                            if hitbox.Color ~= hitboxColor then hitbox.Color = hitboxColor end
                            if not hitbox.CanQuery then hitbox.CanQuery = true end
                        end
                    else
                        local hitbox = character:FindFirstChild("GhostHitbox")
                        if hitbox then hitbox:Destroy() end
                    end
                end
            else
                local char = targetPlayer.Character
                if char then
                    local hb = char:FindFirstChild("GhostHitbox")
                    if hb then hb:Destroy() end
                end
            end
        end
    end
end)

Tabs.Combat:CreateSection("Hitbox Expand")

Tabs.Combat:CreateToggle({
    Name = "Hitbox Neón",
    CurrentValue = false,
    Callback = function(Value)
        hitboxEnabled = Value
        if not Value then limpiarHitboxes() end
    end
})

Tabs.Combat:CreateToggle({
    Name = "Hitbox Invisible",
    CurrentValue = false,
    Callback = function(Value) hitboxInvisible = Value end
})

Tabs.Combat:CreateSlider({
    Name = "Tamaño de Hitbox",
    Min = 1.0,
    Max = 18.0,
    CurrentValue = 3.5,
    Callback = function(v) hitboxSize = v end
})

local espEnabled = false
local espColor = Color3.fromRGB(255, 255, 255)
local PlayerObjects = {}
local Running = true

local MatchState
pcall(function()
    MatchState = require(ReplicatedStorage.Client.Modules.MatchState)
end)

local espFolder = Instance.new("Folder")
espFolder.Name = "AlexxHubESP"
pcall(function() espFolder.Parent = CoreGui end)
if not espFolder.Parent then
    espFolder.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local function estaEnLobby()
    if MatchState then
        local ok, gameData = pcall(function()
            return MatchState.getGame(LocalPlayer)
        end)
        if ok and gameData ~= nil then
            if gameData.Phase == "Voting" then return true end
            return false
        end
    end
    local mapa = LocalPlayer:GetAttribute("Map")
    local partida = LocalPlayer:GetAttribute("Game")
    if mapa ~= nil and partida ~= nil then return false end
    return false
end

local function isDead(player)
    if not MatchState then return false end
    local ok, result = pcall(function()
        return MatchState.isDead(player)
    end)
    return ok and result or false
end

local function getTeamId(player)
    if not MatchState then return nil end
    local ok, result = pcall(function()
        return MatchState.getTeamId(player)
    end)
    return ok and result or nil
end

local function sameGame(a, b)
    if not MatchState then return true end
    local ok, result = pcall(function()
        return MatchState.sameGame(a, b)
    end)
    if not ok then return true end
    return result
end

local function isEnemy(target)
    if not target or target == LocalPlayer then return false end
    if isDead(target) then return false end
    if MatchState then
        if not sameGame(LocalPlayer, target) then return false end
        local myTeam = getTeamId(LocalPlayer)
        local theirTeam = getTeamId(target)
        if myTeam ~= nil and theirTeam ~= nil then
            return myTeam ~= theirTeam
        end
        return true
    end
    return true
end

local function GetPlayerModel(target)
    if not target then return nil end
    local char = target.Character
    if char and char:FindFirstChild("HumanoidRootPart") then return char end
    local model = Workspace:FindFirstChild(target.Name)
    if model and model:IsA("Model") then return model end
    return nil
end

local function destroyPlayerESP(target)
    local data = PlayerObjects[target]
    if not data then return end
    if data.Highlight then
        pcall(function() data.Highlight:Destroy() end)
    end
    PlayerObjects[target] = nil
end

local function createPlayerESP(target)
    destroyPlayerESP(target)
    if not target or target == LocalPlayer then return end
    local model = GetPlayerModel(target)
    if not model then return end
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    local root = model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("Torso")
        or model:FindFirstChild("UpperTorso")
    if not root then return end
    if humanoid and humanoid.Health <= 0 then return end
    local ok, highlight = pcall(function()
        local h = Instance.new("Highlight")
        h.Name = "AlexxHub_TeamESP"
        h.Adornee = model
        h.FillColor = espColor
        h.OutlineColor = espColor
        h.FillTransparency = 1
        h.OutlineTransparency = 0
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Enabled = false
        h.Parent = espFolder
        return h
    end)
    if ok and highlight then
        PlayerObjects[target] = { Highlight = highlight }
    end
end

local function ensurePlayerESP(target)
    if target == LocalPlayer then return end
    local model = GetPlayerModel(target)
    if not model then
        destroyPlayerESP(target)
        return
    end
    local data = PlayerObjects[target]
    if not data or not data.Highlight or not data.Highlight.Parent then
        createPlayerESP(target)
        data = PlayerObjects[target]
    end
    if not data or not data.Highlight then return end
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    local root = model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("Torso")
        or model:FindFirstChild("UpperTorso")
    if not root or isDead(target) then
        data.Highlight.Enabled = false
        return
    end
    if humanoid and humanoid.Health <= 0 then
        data.Highlight.Enabled = false
        return
    end
    local visible = espEnabled and not estaEnLobby() and isEnemy(target)
    data.Highlight.Enabled = visible
    if visible then
        data.Highlight.Adornee = model
        data.Highlight.FillColor = espColor
        data.Highlight.OutlineColor = espColor
        data.Highlight.FillTransparency = 1
        data.Highlight.OutlineTransparency = 0
    end
end

local function bindPlayer(target)
    if target == LocalPlayer then return end
    target.CharacterAdded:Connect(function()
        task.wait(0.25)
        if espEnabled then createPlayerESP(target) end
    end)
    target.CharacterRemoving:Connect(function()
        destroyPlayerESP(target)
    end)
    if target.Character then createPlayerESP(target) end
end

for _, p in ipairs(Players:GetPlayers()) do
    bindPlayer(p)
end
Players.PlayerAdded:Connect(bindPlayer)
Players.PlayerRemoving:Connect(function(p)
    destroyPlayerESP(p)
end)

RunService.RenderStepped:Connect(function()
    if not Running then return end
    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= LocalPlayer then
            pcall(ensurePlayerESP, target)
        end
    end
end)

Tabs.Visual:CreateSection("ESP")

Tabs.Visual:CreateToggle({
    Name = "Higlight",
    CurrentValue = false,
    Callback = function(Value) espEnabled = Value end
})

local CONFIG_ESP2 = {
    Skeleton = false,
    Box = false,
    MaxDistance = 500,
    SkeletonThickness = 2,
    BoxThickness = 1,
}

local drawGui = Instance.new("ScreenGui")
drawGui.Name = "PatataESPDraw"
drawGui.ResetOnSpawn = false
drawGui.IgnoreGuiInset = true
drawGui.DisplayOrder = 999998
pcall(function() drawGui.Parent = CoreGui end)
if not drawGui.Parent then
    drawGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local useDrawing = (typeof(Drawing) == "table" and Drawing.new) and true or false
local espData2 = {}

local function CreatePlayerESP2(player)
    if player == LocalPlayer then return end
    if espData2[player] then return end
    local data = { player = player, lines = {}, box = nil }
    if useDrawing then
        data.box = Drawing.new("Square")
        data.box.Visible = false
        data.box.Color = espColor
        data.box.Thickness = CONFIG_ESP2.BoxThickness
        data.box.Filled = false
        data.box.Transparency = 1
        for i = 1, 13 do
            local line = Drawing.new("Line")
            line.Visible = false
            line.Color = espColor
            line.Thickness = CONFIG_ESP2.SkeletonThickness
            line.Transparency = 1
            table.insert(data.lines, line)
        end
    else
        local box = Instance.new("Frame")
        box.BackgroundTransparency = 1
        box.BorderSizePixel = 0
        box.Visible = false
        box.Parent = drawGui
        local boxStroke = Instance.new("UIStroke")
        boxStroke.Color = espColor
        boxStroke.Thickness = CONFIG_ESP2.BoxThickness
        boxStroke.Parent = box
        data.box = box
        data.boxStroke = boxStroke
        for i = 1, 13 do
            local line = Instance.new("Frame")
            line.BackgroundColor3 = espColor
            line.BorderSizePixel = 0
            line.AnchorPoint = Vector2.new(0.5, 0.5)
            line.Visible = false
            line.Parent = drawGui
            table.insert(data.lines, line)
        end
    end
    espData2[player] = data
end

local function RemovePlayerESP2(player)
    local data = espData2[player]
    if not data then return end
    if data.box then
        pcall(function() data.box:Remove() end)
        if data.box.Destroy then pcall(function() data.box:Destroy() end) end
    end
    for _, line in ipairs(data.lines) do
        pcall(function() line:Remove() end)
        if line.Destroy then pcall(function() line:Destroy() end) end
    end
    espData2[player] = nil
end

local SKELETON_R6 = {
    {"Head", "Torso"},
    {"Torso", "Left Arm"},
    {"Torso", "Right Arm"},
    {"Torso", "Left Leg"},
    {"Torso", "Right Leg"},
}

local SKELETON_R15 = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
}

local function GetSkeletonPairs(char, hum)
    local pairs = {}
    local list = (hum.RigType == Enum.HumanoidRigType.R15) and SKELETON_R15 or SKELETON_R6
    for _, pair in ipairs(list) do
        local p1 = char:FindFirstChild(pair[1])
        local p2 = char:FindFirstChild(pair[2])
        if p1 and p2 then table.insert(pairs, {p1, p2}) end
    end
    return pairs
end

local function GetBoxFromCharacter(char)
    local cf, size = char:GetBoundingBox()
    local corners = {
        cf * Vector3.new(size.X/2, size.Y/2, size.Z/2),
        cf * Vector3.new(-size.X/2, size.Y/2, size.Z/2),
        cf * Vector3.new(size.X/2, -size.Y/2, size.Z/2),
        cf * Vector3.new(-size.X/2, -size.Y/2, size.Z/2),
        cf * Vector3.new(size.X/2, size.Y/2, -size.Z/2),
        cf * Vector3.new(-size.X/2, size.Y/2, -size.Z/2),
        cf * Vector3.new(size.X/2, -size.Y/2, -size.Z/2),
        cf * Vector3.new(-size.X/2, -size.Y/2, -size.Z/2),
    }
    local minX, maxX, minY, maxY = math.huge, -math.huge, math.huge, -math.huge
    local cam = workspace.CurrentCamera
    for _, c in ipairs(corners) do
        local sp, on = cam:WorldToViewportPoint(c)
        if on then
            minX = math.min(minX, sp.X)
            maxX = math.max(maxX, sp.X)
            minY = math.min(minY, sp.Y)
            maxY = math.max(maxY, sp.Y)
        end
    end
    if minX >= maxX or minY >= maxY then return nil end
    return minX, minY, maxX - minX, maxY - minY
end

RunService.RenderStepped:Connect(function()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    for player, data in pairs(espData2) do
        local model = GetPlayerModel(player)
        local hum = model and model:FindFirstChildOfClass("Humanoid")
        local root = model and (model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso"))
        local visible = not estaEnLobby() and isEnemy(player) and not isDead(player)
        if not visible or not model or not myRoot or not root then
            if data.box then data.box.Visible = false end
            for _, line in ipairs(data.lines) do line.Visible = false end
        else
            if useDrawing then
                if data.box then data.box.Color = espColor end
            else
                if data.boxStroke then data.boxStroke.Color = espColor end
            end
            if CONFIG_ESP2.Box then
                local bx, by, bw, bh = GetBoxFromCharacter(model)
                if bx then
                    if useDrawing then
                        data.box.Position = Vector2.new(bx, by)
                        data.box.Size = Vector2.new(bw, bh)
                        data.box.Visible = true
                    else
                        data.box.Position = UDim2.new(0, bx, 0, by)
                        data.box.Size = UDim2.new(0, bw, 0, bh)
                        data.box.Visible = true
                    end
                else
                    if data.box then data.box.Visible = false end
                end
            else
                if data.box then data.box.Visible = false end
            end
            if CONFIG_ESP2.Skeleton and hum then
                local pairs = GetSkeletonPairs(model, hum)
                local cam = workspace.CurrentCamera
                for i, line in ipairs(data.lines) do
                    local bonePair = pairs[i]
                    if bonePair then
                        local sp1, on1 = cam:WorldToViewportPoint(bonePair[1].Position)
                        local sp2, on2 = cam:WorldToViewportPoint(bonePair[2].Position)
                        if on1 and on2 and sp1.Z > 0 and sp2.Z > 0 then
                            if useDrawing then
                                line.From = Vector2.new(sp1.X, sp1.Y)
                                line.To = Vector2.new(sp2.X, sp2.Y)
                                line.Color = espColor
                                line.Visible = true
                            else
                                local v1 = Vector2.new(sp1.X, sp1.Y)
                                local v2 = Vector2.new(sp2.X, sp2.Y)
                                local delta = v2 - v1
                                local length = delta.Magnitude
                                local center = (v1 + v2) / 2
                                line.Position = UDim2.new(0, center.X, 0, center.Y)
                                line.Size = UDim2.new(0, length, 0, CONFIG_ESP2.SkeletonThickness)
                                line.Rotation = math.deg(math.atan2(delta.Y, delta.X))
                                line.BackgroundColor3 = espColor
                                line.Visible = true
                            end
                        else
                            line.Visible = false
                        end
                    else
                        line.Visible = false
                    end
                end
            else
                for _, line in ipairs(data.lines) do line.Visible = false end
            end
        end
    end
end)

for _, p in ipairs(Players:GetPlayers()) do
    CreatePlayerESP2(p)
end
Players.PlayerAdded:Connect(function(p)
    CreatePlayerESP2(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.3)
        if espData2[p] then RemovePlayerESP2(p) end
        CreatePlayerESP2(p)
    end)
end)
Players.PlayerRemoving:Connect(function(p)
    RemovePlayerESP2(p)
end)

Tabs.Visual:CreateToggle({
    Name = "ESP Esqueleto",
    CurrentValue = false,
    Callback = function(Value) CONFIG_ESP2.Skeleton = Value end
})

Tabs.Visual:CreateToggle({
    Name = "ESP Box",
    CurrentValue = false,
    Callback = function(Value) CONFIG_ESP2.Box = Value end
})

local tracerLines2 = {}
local tracersLimpios2 = true
local espLinesAccumulator2 = 0
local cachedViewportX2, cachedViewportY2 = -1, -1
local centroVector2 = Vector2.new(0, 0)
local tracerOrigin2 = Vector2.new(0, 0)
local espLinesEnabled = false

local function hideTracersOnce2()
    if tracersLimpios2 then return end
    for _, tLine in pairs(tracerLines2) do
        if tLine.Visible then tLine.Visible = false end
    end
    tracersLimpios2 = true
end

RunService.RenderStepped:Connect(function()
    espLinesAccumulator2 = espLinesAccumulator2 + task.wait()
    if espLinesAccumulator2 < (1 / 30) then return end
    espLinesAccumulator2 = 0
    local visibleGlobal = espLinesEnabled and not estaEnLobby()
    if not visibleGlobal then
        hideTracersOnce2()
        return
    end
    local cam = workspace.CurrentCamera
    local viewport = cam.ViewportSize
    if viewport.X ~= cachedViewportX2 or viewport.Y ~= cachedViewportY2 then
        cachedViewportX2, cachedViewportY2 = viewport.X, viewport.Y
        centroVector2 = Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
        tracerOrigin2 = Vector2.new(centroVector2.X, viewport.Y - 2)
    end
    tracersLimpios2 = false
    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= LocalPlayer then
            local model = GetPlayerModel(targetPlayer)
            local root = model and (model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso"))
            local playerVisible = isEnemy(targetPlayer) and not isDead(targetPlayer) and root
            local tLine = tracerLines2[targetPlayer]
            if playerVisible then
                local rootScreen, onScreen = cam:WorldToViewportPoint(root.Position)
                if onScreen and rootScreen.Z > 0 then
                    if not tLine then
                        tLine = Drawing.new("Line")
                        tLine.Thickness = 1.35
                        tLine.Transparency = 0.92
                        tLine.Visible = false
                        tracerLines2[targetPlayer] = tLine
                    end
                    tLine.From = tracerOrigin2
                    tLine.To = Vector2.new(rootScreen.X, rootScreen.Y)
                    tLine.Color = espColor
                    tLine.Visible = true
                else
                    if tLine and tLine.Visible then tLine.Visible = false end
                end
            else
                if tLine and tLine.Visible then tLine.Visible = false end
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if tracerLines2[p] then
        pcall(function() tracerLines2[p]:Remove() end)
        if tracerLines2[p].Destroy then pcall(function() tracerLines2[p]:Destroy() end) end
        tracerLines2[p] = nil
    end
end)

Tabs.Visual:CreateToggle({
    Name = "ESP Líneas",
    CurrentValue = false,
    Callback = function(Value) espLinesEnabled = Value end
})

local function getEnvironment()
    if type(getgenv) == "function" then
        local ok, env = pcall(getgenv)
        if ok and type(env) == "table" then
            return env
        end
    end
    return _G
end

local environment = getEnvironment()
local moduleBaseUrl = "https://raw.githubusercontent.com/Silent-lua/Dev/main/"
local avatarBridge = {
    version = 2,
    skin = { revision = 0 },
    accessory = { revision = 0 },
}

local function loadModule(fileName)
    local ok, api = pcall(function()
        local source = game:HttpGet(moduleBaseUrl .. fileName)
        if type(source) ~= "string" or source == "" then
            error("GitHub devolvió un módulo vacío.")
        end

        local compiler = environment.loadstring or loadstring
        if type(compiler) ~= "function" then
            error("Este executor no tiene loadstring habilitado.")
        end

        local chunk, compileError = compiler(source)
        if type(chunk) ~= "function" then
            error(compileError or "No se pudo compilar el módulo.")
        end

        local result = chunk(avatarBridge)
        if type(result) ~= "table" then
            error("El módulo no devolvió su API local.")
        end
        return result
    end)

    if not ok then
        warn("[SnowX] Error cargando " .. fileName .. ": " .. tostring(api))
        Window:Notify({
            Title = "SnowX",
            Text = "No se pudo cargar " .. fileName .. ". Revisa tu conexión o executor.",
            Duration = 5,
        })
        return nil
    end

    return api
end

local accessoryApi = loadModule("SnowX-Accessories.lua")
local skinApi = loadModule("SnowX-Skins.lua")

local function getAccessoryApi()
    return type(accessoryApi) == "table" and accessoryApi or nil
end
local function openSnowXAccessory()
    local api = getAccessoryApi()
    if not api then
        Window:Notify({Title = "SnowX", Text = "Ejecuta SnowX-Accessories.lua para cargar el sistema de accesorios.", Duration = 4})
        return false
    end
    local ok, opened = pcall(function()
        return api.Open and api.Open()
    end)
    if not ok or opened == false then
        Window:Notify({Title = "SnowX", Text = "No se pudo abrir el panel de accesorios.", Duration = 3})
        return false
    end
    return true
end

local function applySnowXAsset(assetId, successText)
    local api = getAccessoryApi()
    if not api or type(api.ApplyAsset) ~= "function" then
        Window:Notify({Title = "Avatar", Text = "Ejecuta SnowX-Accessories.lua primero.", Duration = 4})
        return false
    end
    local callOk, applied, message = pcall(api.ApplyAsset, assetId)
    if not callOk or applied == false then
        Window:Notify({Title = "Avatar", Text = tostring(message or applied or "No se pudo aplicar el objeto."), Duration = 4})
        return false
    end
    Window:Notify({Title = "Avatar", Text = successText or tostring(message or "Apariencia actualizada."), Duration = 3})
    return true
end

local function applyHeadless()
    local api = getAccessoryApi()
    if not api or type(api.ToggleBodyPart) ~= "function" then
        Window:Notify({Title = "Avatar", Text = "Ejecuta SnowX-Accessories.lua primero.", Duration = 4})
        return
    end
    local ok, applied, message = pcall(api.ToggleBodyPart, "headless")
    Window:Notify({Title = "Avatar", Text = ok and applied ~= false and tostring(message or "Headless actualizado.") or tostring(message or applied or "Fallo al aplicar Headless."), Duration = 3})
end

local function applyKorblox()
    local api = getAccessoryApi()
    if not api or type(api.ToggleBodyPart) ~= "function" then
        Window:Notify({Title = "Avatar", Text = "Ejecuta SnowX-Accessories.lua primero.", Duration = 4})
        return
    end
    local ok, applied, message = pcall(api.ToggleBodyPart, "korbloxLeg")
    Window:Notify({Title = "Avatar", Text = ok and applied ~= false and tostring(message or "Korblox actualizado.") or tostring(message or applied or "Fallo al aplicar Korblox."), Duration = 3})
end

local function equipLocalAccessory(assetId)
    return applySnowXAsset(assetId)
end

Tabs.Performance:CreateSection("Avatar Modifiers")

Tabs.Performance:CreateButton({
    Name = "Accesorios",
    Callback = function()
        openSnowXAccessory()
    end
})

Tabs.Performance:CreateButton({
    Name = "Headless",
    Callback = function() applyHeadless() end
})

Tabs.Performance:CreateButton({
    Name = "Korblox",
    Callback = function() applyKorblox() end
})

Tabs.Performance:CreateButton({
    Name = "Eye Red",
    Callback = function()
        equipLocalAccessory("17826440571")
        Window:Notify({Title = "Extra", Text = "Ojos Ninja Activados", Duration = 2})
    end
})

Tabs.Performance:CreateButton({
    Name = "Fiery Horns",
    Callback = function()
        equipLocalAccessory("215718515")
        Window:Notify({Title = "Avatar", Text = "Cuernos Equipados", Duration = 2})
    end
})

Tabs.Performance:CreateButton({
    Name = "Rc Crown",
    Callback = function()
        equipLocalAccessory("10159600649")
        Window:Notify({Title = "Avatar", Text = "Corona Equipada", Duration = 2})
    end
})

Tabs.Performance:CreateButton({
    Name = "Orange Fairy",
    Callback = function()
        equipLocalAccessory("128217885")
        Window:Notify({Title = "Avatar", Text = "Orange Fairy Equipped", Duration = 2})
    end
})

Tabs.Performance:CreateButton({
    Name = "Silver Crown",
    Callback = function()
        equipLocalAccessory("12922571644")
        Window:Notify({Title = "Avatar", Text = "Silver Crown Equipped", Duration = 2})
    end
})

Tabs.Performance:CreateButton({
    Name = "8-Bit Heart Bar",
    Callback = function()
        equipLocalAccessory("10159610478")
        Window:Notify({Title = "Avatar", Text = "Heart Bar Equipped", Duration = 2})
    end
})

local originalTextsOrby = {}
local hideNameEnabled = false
local fakeNameEnabled = false
local creatorTagEnabled = false
local spoofNameText = "Player"

local function processOrbyText(v)
    local parentGui = v:FindFirstAncestorWhichIsA("ScreenGui")
    if parentGui and (string.find(parentGui.Name, "OpenHub") or string.find(parentGui.Name, "Orby")) then return end
    if v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("TextButton") then
        local myName = LocalPlayer.Name
        local myDisp = LocalPlayer.DisplayName
        if not originalTextsOrby[v] then
            if string.find(v.Text, myName) or string.find(v.Text, myDisp) then
                originalTextsOrby[v] = {
                    Text = v.Text,
                    Color = v.TextColor3,
                    Trans = v.TextTransparency
                }
            end
        end
        local data = originalTextsOrby[v]
        if data then
            if hideNameEnabled then
                v.Text = ""
                v.TextTransparency = 1
            elseif fakeNameEnabled or creatorTagEnabled then
                v.TextTransparency = data.Trans
                v.TextColor3 = data.Color
                local baseName = fakeNameEnabled and spoofNameText or myDisp
                local isOverhead = false
                if LocalPlayer.Character and v:IsDescendantOf(LocalPlayer.Character) then
                    isOverhead = true
                else
                    local bill = v:FindFirstAncestorWhichIsA("BillboardGui")
                    if bill and bill.Adornee and LocalPlayer.Character and bill.Adornee:IsDescendantOf(LocalPlayer.Character) then
                        isOverhead = true
                    end
                end
                if creatorTagEnabled and isOverhead then
                    v.RichText = true
                    v.Text = '<font color="#bee1e7">[Content Creator]</font> ' .. baseName
                else
                    v.Text = baseName
                end
            else
                v.Text = data.Text
                v.TextColor3 = data.Color
                v.TextTransparency = data.Trans
            end
        end
    end
end

local function linkTextInfection(gui)
    if not gui then return end
    gui.DescendantAdded:Connect(function(obj)
        if hideNameEnabled or fakeNameEnabled or creatorTagEnabled then
            processOrbyText(obj)
        end
    end)
end

task.spawn(function()
    local pGui = LocalPlayer:WaitForChild("PlayerGui", 10)
    if pGui then linkTextInfection(pGui) end
    Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function(char)
            linkTextInfection(char)
        end)
    end)
end)

Tabs.Performance:CreateSection("Tag")

Tabs.Performance:CreateToggle({
    Name = "Ocultar Nombre",
    CurrentValue = false,
    Callback = function(s)
        hideNameEnabled = s
        local pGui = LocalPlayer:FindFirstChild("PlayerGui")
        if pGui then for _, v in ipairs(pGui:GetDescendants()) do processOrbyText(v) end end
        if LocalPlayer.Character then for _, v in ipairs(LocalPlayer.Character:GetDescendants()) do processOrbyText(v) end end
    end
})

Tabs.Performance:CreateToggle({
    Name = "Nombre Falso",
    CurrentValue = false,
    Callback = function(s)
        fakeNameEnabled = s
        local pGui = LocalPlayer:FindFirstChild("PlayerGui")
        if pGui then for _, v in ipairs(pGui:GetDescendants()) do processOrbyText(v) end end
        if LocalPlayer.Character then for _, v in ipairs(LocalPlayer.Character:GetDescendants()) do processOrbyText(v) end end
    end
})

Tabs.Performance:CreateToggle({
    Name = "Tag [Content Creator]",
    CurrentValue = false,
    Callback = function(s)
        creatorTagEnabled = s
        local pGui = LocalPlayer:FindFirstChild("PlayerGui")
        if pGui then for _, v in ipairs(pGui:GetDescendants()) do processOrbyText(v) end end
        if LocalPlayer.Character then for _, v in ipairs(LocalPlayer.Character:GetDescendants()) do processOrbyText(v) end end
    end
})

Tabs.Performance:CreateInput({
    Name = "Nuevo Nombre",
    Placeholder = "Escribe tu nombre falso...",
    Callback = function(t)
        if t ~= "" then
            spoofNameText = t
            if fakeNameEnabled then
                local pGui = LocalPlayer:FindFirstChild("PlayerGui")
                if pGui then for _, v in ipairs(pGui:GetDescendants()) do processOrbyText(v) end end
            end
        end
    end
})

local packActualActivo = nil

local packsAnimaciones = {
    Ninja = { walk = "rbxassetid://10921162768", run = "rbxassetid://10921157929", jump = "rbxassetid://10921160088", fall = "rbxassetid://10921159222", climb = "rbxassetid://10921154678", idle = "rbxassetid://10921155160", ninjapose = "rbxassetid://10921156883", toolnone = "rbxassetid://507768375", toollunge = "rbxassetid://522638767", toolslash = "rbxassetid://522635514", swim = "rbxassetid://10922757002", sit = "rbxassetid://2506281703", cheer = "rbxassetid://507770677", laugh = "rbxassetid://507770818", wave = "rbxassetid://507770239", point = "rbxassetid://507770453" },
    Zombie = { Walk = "rbxassetid://10921355261", run = "rbxassetid://616163682", jump = "rbxassetid://10921351278", fall = "rbxassetid://10921350320", swimIdle = "rbxassetid://10921353442", swim = "rbxassetid://10921352344", idle = "rbxassetid://10921344533", idle2 = "rbxassetid://10921345304", climb = "rbxassetid://10921343576" },
    Stylish = { walk = "rbxassetid://109168724482748", run = "rbxassetid://81024476153754", jump = "rbxassetid://116936326516985", fall = "rbxassetid://92294537340807", climb = "rbxassetid://119377220967554", idle = "rbxassetid://133806214992291", stylishpose = "rbxassetid://87105332133518", toolnone = "rbxassetid://507768375", toollunge = "rbxassetid://522638767", toolslash = "rbxassetid://522635514", swim = "rbxassetid://134591743181628", swimidle = "rbxassetid://98854111361360", sit = "rbxassetid://2506281703", cheer = "rbxassetid://507770677", laugh = "rbxassetid://507770818", wave = "rbxassetid://507770239", point = "rbxassetid://507770453" },
    Ghost = { walk = "rbxassetid://122150855457006", run = "rbxassetid://82598234841035", jump = "rbxassetid://75290611992385", fall = "rbxassetid://98600215928904", climb = "rbxassetid://88763136693023", idle = "rbxassetid://122257458498464", stylishpose = "rbxassetid://89262795687364", toolnone = "rbxassetid://507768375", toollunge = "rbxassetid://522638767", toolslash = "rbxassetid://522635514", swim = "rbxassetid://133308483266208", swimidle = "rbxassetid://109346520324160", sit = "rbxassetid://2506281703", cheer = "rbxassetid://507770677", laugh = "rbxassetid://507770818", wave = "rbxassetid://507770239", point = "rbxassetid://507770453" },
    Mage = { walk = "rbxassetid://84782014405060", run = "rbxassetid://85232146719894", jump = "rbxassetid://140300561900880", fall = "rbxassetid://129591520941189", climb = "rbxassetid://94364927317793", idle = "rbxassetid://133226513780673", toolnone = "rbxassetid://507768375", toollunge = "rbxassetid://522638767", toolslash = "rbxassetid://522635514", swim = "rbxassetid://117741052845105", swimidle = "rbxassetid://133871172755161", sit = "rbxassetid://2506281703", cheer = "rbxassetid://507770677", laugh = "rbxassetid://507770818", wave = "rbxassetid://507770239", point = "rbxassetid://507770453" },
    Levitation = { walk = "rbxassetid://83842218823011", run = "rbxassetid://118320322718866", jump = "rbxassetid://109996626521204", fall = "rbxassetid://95603166884636", climb = "rbxassetid://97824616490448", idle = "rbxassetid://110211186840347", stylishpose = "rbxassetid://99129837931148", toolnone = "rbxassetid://507768375", toollunge = "rbxassetid://522638767", toolslash = "rbxassetid://522635514", swim = "rbxassetid://134530128383903", swimidle = "rbxassetid://94922130551805", sit = "rbxassetid://2506281703", cheer = "rbxassetid://507770677", laugh = "rbxassetid://507770818", wave = "rbxassetid://507770239", point = "rbxassetid://507770453" },
    Elder = { walk = "rbxassetid://10921111375", run = "rbxassetid://10921104374", jump = "rbxassetid://10921107367", fall = "rbxassetid://10921105765", climb = "rbxassetid://10921100400", idle = "rbxassetid://10921101664", elderpose = "rbxassetid://10921103538", toolnone = "rbxassetid://507768375", toollunge = "rbxassetid://522638767", toolslash = "rbxassetid://522635514", swim = "rbxassetid://10921108971", swimidle = "rbxassetid://1092110146", sit = "rbxassetid://2506281703", cheer = "rbxassetid://507770677", laugh = "rbxassetid://507770818", wave = "rbxassetid://507770239", point = "rbxassetid://507770453" },
    Bicicleta = { walk = "rbxassetid://98707881660541", run = "rbxassetid://102775737211919", jump = "rbxassetid://129144847881258", fall = "rbxassetid://110684787086498", climb = "rbxassetid://88267082364595", idle = "rbxassetid://126390120399173", idle2 = "rbxassetid://136791517336633", idle3 = "rbxassetid://14366558676", swim = "rbxassetid://116700888013068", swimidle = "rbxassetid://87621024705272", toolnone = "rbxassetid://507768375", toollunge = "rbxassetid://522638767", toolslash = "rbxassetid://522635514", sit = "rbxassetid://2506281703", cheer = "rbxassetid://507770677", laugh = "rbxassetid://507770818", wave = "rbxassetid://507770239", point = "rbxassetid://507770453" },
    Bubbly = { walk = "rbxassetid://90478085024465", run = "rbxassetid://134824450619865", jump = "rbxassetid://121454505477205", fall = "rbxassetid://94788218468396", climb = "rbxassetid://12114583950231", idle = "rbxassetid://98281136301627", swim = "rbxassetid://105962919001086", swimidle = "rbxassetid://129126268464847", stylishpose = "rbxassetid://133117300343405", toolnone = "rbxassetid://507768375", toollunge = "rbxassetid://522638767", toolslash = "rbxassetid://522635514", sit = "rbxassetid://2506281703", cheer = "rbxassetid://507770677", laugh = "rbxassetid://507770818", wave = "rbxassetid://507770239", point = "rbxassetid://507770453" }
}

local function getAnim(folderName, animName)
    local char = LocalPlayer.Character
    local animate = char and char:FindFirstChild("Animate")
    if animate then
        local folder = animate:FindFirstChild(folderName)
        if folder then
            local anim = folder:FindFirstChild(animName)
            if anim and anim:IsA("Animation") then
                return anim.AnimationId
            end
        end
    end
    return nil
end

local misAnimacionesOriginales = {
    Idle = getAnim("idle", "Animation1") or 507766666,
    Idle2 = getAnim("idle", "Animation2") or 507766951,
    Walk = getAnim("walk", "WalkAnim") or 507777826,
    Run = getAnim("run", "RunAnim") or 507767714,
    Jump = getAnim("jump", "JumpAnim") or 507765000,
    Climb = getAnim("climb", "ClimbAnim") or 507765644,
    Fall = getAnim("fall", "FallAnim") or 507767968,
    Swim = getAnim("swim", "Swim") or 507784897,
    SwimIdle = getAnim("swimidle", "SwimIdle") or 507785072
}

local function aplicarPackAnimaciones(idsPack)
    task.spawn(function()
        local character = plr.Character or plr.CharacterAdded:Wait()
        local animateScript = character:WaitForChild("Animate", 5)
        if not animateScript then return end
        animateScript.Disabled = true
        for nombre, id in pairs(idsPack) do
            local carpeta = animateScript:FindFirstChild(nombre)
                or animateScript:FindFirstChild(nombre:gsub("^%l", string.upper) .. "Anim")
                or animateScript:FindFirstChild(nombre:upper())
            if carpeta then
                local nombreAnim = "Animation1"
                if nombre == "idle2" then nombreAnim = "Animation2"
                elseif nombre == "idle3" then nombreAnim = "Animation3"
                elseif nombre == "swimidle" then nombreAnim = "SwimIdle"
                elseif nombre == "walk" then nombreAnim = "WalkAnim"
                elseif nombre == "run" then nombreAnim = "RunAnim"
                elseif nombre == "jump" then nombreAnim = "JumpAnim"
                elseif nombre == "fall" then nombreAnim = "FallAnim"
                elseif nombre == "climb" then nombreAnim = "ClimbAnim"
                elseif nombre == "toolnone" then nombreAnim = "ToolNoneAnim"
                elseif nombre == "toolslash" then nombreAnim = "ToolSlashAnim"
                elseif nombre == "toollunge" then nombreAnim = "ToolLungeAnim"
                elseif nombre == "sit" then nombreAnim = "SitAnim"
                elseif nombre == "wave" then nombreAnim = "WaveAnim"
                elseif nombre == "point" then nombreAnim = "PointAnim"
                elseif nombre == "cheer" then nombreAnim = "CheerAnim"
                elseif nombre == "laugh" then nombreAnim = "LaughAnim"
                elseif nombre == "stylishpose" then nombreAnim = "StylishPose"
                elseif nombre == "ninjapose" then nombreAnim = "NinjaPose"
                elseif nombre == "elderpose" then nombreAnim = "ElderPose" end
                local anim = carpeta:FindFirstChild(nombreAnim)
                if anim and anim:IsA("Animation") then
                    anim.AnimationId = id
                end
            end
        end
        local function limpiarPose(nombreCarpeta, nombreAnim)
            local carpeta = animateScript:FindFirstChild(nombreCarpeta)
            if carpeta then
                local anim = carpeta:FindFirstChild(nombreAnim)
                if anim and anim:IsA("Animation") then anim.AnimationId = "" end
            end
        end
        limpiarPose("stylishpose", "StylishPose")
        limpiarPose("ninjapose", "NinjaPose")
        limpiarPose("elderpose", "ElderPose")
        task.wait()
        animateScript.Disabled = false
    end)
end

plr.CharacterAdded:Connect(function(newChar)
    if packActualActivo then
        task.wait(0.5)
        aplicarPackAnimaciones(packActualActivo)
    end
end)

Tabs.Animaciones:CreateSection("Animaciónes")

Tabs.Animaciones:CreateDropdown({
    Name = "Seleccionar Animación",
    Options = {"Ninja", "Zombie", "Stylish", "Ghost", "Mage", "Levitation", "Elder", "Bicicleta", "Bubbly"},
    CurrentOption = "Ninja",
    Callback = function(Value)
        local packSeleccionado = packsAnimaciones[Value]
        if packSeleccionado then
            packActualActivo = packSeleccionado
            aplicarPackAnimaciones(packActualActivo)
            Window:Notify({Title = "Animaciones", Text = "Estilo " .. Value .. " Activado", Duration = 2})
        end
    end
})

Tabs.Animaciones:CreateButton({
    Name = "Restaurar Default",
    Callback = function()
        task.spawn(function()
            local defaultAnims = {
                idle = misAnimacionesOriginales.Idle,
                idle2 = misAnimacionesOriginales.Idle2,
                walk = misAnimacionesOriginales.Walk,
                run = misAnimacionesOriginales.Run,
                jump = misAnimacionesOriginales.Jump,
                climb = misAnimacionesOriginales.Climb,
                fall = misAnimacionesOriginales.Fall,
                swim = misAnimacionesOriginales.Swim,
                swimidle = misAnimacionesOriginales.SwimIdle
            }
            packActualActivo = nil
            aplicarPackAnimaciones(defaultAnims)
            Window:Notify({Title = "Animaciones", Text = "restaurado", Duration = 2})
        end)
    end
})

Tabs.Animaciones:CreateSection("Mezclador Avanzado de Animaciones")

local mixSeleccionado = {idle = "Ninja", walk = "Ninja", run = "Ninja", jump = "Ninja", fall = "Ninja", climb = "Ninja"}
local opcionesMix = {"Ninja", "Zombie", "Stylish", "Ghost", "Mage", "Levitation", "Elder", "Bicicleta", "Bubbly"}

Tabs.Animaciones:CreateDropdown({
    Name = "Idle",
    Options = opcionesMix,
    CurrentOption = "Ninja",
    Callback = function(Value) mixSeleccionado.idle = Value end
})

Tabs.Animaciones:CreateDropdown({
    Name = "Walk",
    Options = opcionesMix,
    CurrentOption = "Ninja",
    Callback = function(Value) mixSeleccionado.walk = Value end
})

Tabs.Animaciones:CreateDropdown({
    Name = "Run",
    Options = opcionesMix,
    CurrentOption = "Ninja",
    Callback = function(Value) mixSeleccionado.run = Value end
})

Tabs.Animaciones:CreateDropdown({
    Name = "Jump",
    Options = opcionesMix,
    CurrentOption = "Ninja",
    Callback = function(Value) mixSeleccionado.jump = Value end
})

Tabs.Animaciones:CreateDropdown({
    Name = "Fall",
    Options = opcionesMix,
    CurrentOption = "Ninja",
    Callback = function(Value) mixSeleccionado.fall = Value end
})

Tabs.Animaciones:CreateDropdown({
    Name = "Climb",
    Options = opcionesMix,
    CurrentOption = "Ninja",
    Callback = function(Value) mixSeleccionado.climb = Value end
})

Tabs.Animaciones:CreateButton({
    Name = "Combinar y Aplicar Animación",
    Callback = function()
        task.spawn(function()
            local mezclaFinal = {
                idle = packsAnimaciones[mixSeleccionado.idle].idle or packsAnimaciones[mixSeleccionado.idle].Walk,
                idle2 = packsAnimaciones[mixSeleccionado.idle].idle2,
                walk = packsAnimaciones[mixSeleccionado.walk].walk or packsAnimaciones[mixSeleccionado.walk].Walk,
                run = packsAnimaciones[mixSeleccionado.run].run or packsAnimaciones[mixSeleccionado.run].Walk,
                jump = packsAnimaciones[mixSeleccionado.jump].jump or packsAnimaciones[mixSeleccionado.jump].Walk,
                fall = packsAnimaciones[mixSeleccionado.fall].fall or packsAnimaciones[mixSeleccionado.fall].Walk,
                climb = packsAnimaciones[mixSeleccionado.climb].climb or packsAnimaciones[mixSeleccionado.climb].Walk
            }
            packActualActivo = mezclaFinal
            aplicarPackAnimaciones(mezclaFinal)
            Window:Notify({Title = "Mezclador", Text = "Animación combinada", Duration = 2})
        end)
    end
})

local EmoteTrack = nil
local EmotesListaOrby = {
    ["Ninguno"] = "0",
    ["YB Jump"] = "15609995579",
    ["Dance"] = "10714340543",
    ["Bubly"] = "93120341268524",
    ["Baile"] = "114774556469581",
    ["Baile2"] = "88050523705839",
    ["mediohueva"] = "92747295139963",
    ["Baile3"] = "104748118296461",
    ["Elmejordetodos"] = "74430100028293",
    ["Emote1"] = "82238508652742"
}

local function StopEmoteOrby()
    if EmoteTrack then
        EmoteTrack:Stop()
        EmoteTrack:Destroy()
        EmoteTrack = nil
    end
end

local function PlayEmoteOrby(AnimationId)
    StopEmoteOrby()
    if AnimationId == "0" then return end
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:WaitForChild("Humanoid", 5)
    if not Humanoid then return end
    local Animator = Humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", Humanoid)
    local Animation = Instance.new("Animation")
    Animation.AnimationId = "rbxassetid://" .. AnimationId
    pcall(function()
        EmoteTrack = Animator:LoadAnimation(Animation)
        EmoteTrack.Priority = Enum.AnimationPriority.Action
        EmoteTrack.Looped = true
        EmoteTrack:Play()
    end)
end

local function ConectarCaminataOrby(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if humanoid then
        humanoid.Running:Connect(function(speed)
            if speed > 0.1 then StopEmoteOrby() end
        end)
    end
end

if LocalPlayer.Character then
    ConectarCaminataOrby(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(ConectarCaminataOrby)

Tabs.Animaciones:CreateSection("Emotes Especiales")

Tabs.Animaciones:CreateDropdown({
    Name = "Seleccionar Emote",
    Options = {"Ninguno", "YB Jump", "Dance", "Bubly", "Baile", "Baile2", "mediohueva", "Baile3", "Elmejordetodos", "Emote1"},
    CurrentOption = "Ninguno",
    Callback = function(Value)
        local IdObtenida = EmotesListaOrby[Value]
        if IdObtenida then PlayEmoteOrby(IdObtenida) end
    end
})

local cieloOriginal = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    ColorShift_Top = Lighting.ColorShift_Top,
    ColorShift_Bottom = Lighting.ColorShift_Bottom,
    EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
    EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
    ExposureCompensation = Lighting.ExposureCompensation,
    FogColor = Lighting.FogColor,
    FogEnd = Lighting.FogEnd,
    Objetos = {}
}

for _, obj in pairs(Lighting:GetChildren()) do
    if obj:IsA("Sky") or obj:IsA("Atmosphere") or obj:IsA("Clouds") or obj:IsA("ColorCorrectionEffect") or obj:IsA("BloomEffect") or obj:IsA("SunRaysEffect") then
        table.insert(cieloOriginal.Objetos, obj:Clone())
    end
end

Tabs.Texturas:CreateSection("Cielos")

local skyboxDataExtra = {
    Twilight = {"264908339", "264907909", "264909420", "264909758", "264908886", "264907379"},
    Nebula = {"159454299", "159454296", "159454293", "159454286", "159454300", "159454288"},
    Vaporwave = {"1417494030", "1417494146", "1417494253", "1417494402", "1417494499", "1417494643"},
    Redshift = {"401664839", "401664862", "401664960", "401664881", "401664901", "401664936"},
    ["Blue Stars"] = {"149397684", "149397686", "149397688", "149397692", "149397697", "149397702"},
    ["Sakura Pink Sky"] = {"271042516", "271077243", "271042556", "271042310", "271042467", "271077958"},
    Default = {"591058823", "591059876", "591058104", "591057861", "591057625", "591059642"},
    Desert = {"1013852", "1013853", "1013850", "1013851", "1013849", "1013854"},
    DaBaby = {"7245418472", "7245418472", "7245418472", "7245418472", "7245418472", "7245418472"},
    Minecraft = {"1876545003", "1876544331", "1876542941", "1876543392", "1876543764", "1876544642"},
    SpongeBob = {"7633178166", "7633178166", "7633178166", "7633178166", "7633178166", "7633178166"},
    Skibidi = {"14952256113", "14952256113", "14952256113", "14952256113", "14952256113", "14952256113"},
    Blaze = {"150939022", "150939038", "150939047", "150939056", "150939063", "150939082"},
    ["Pussy Cat"] = {"11154422902", "11154422902", "11154422902", "11154422902", "11154422902", "11154422902"},
    ["Among Us"] = {"5752463190", "5752463190", "5752463190", "5752463190", "5752463190", "5752463190"},
    ["Space Wave"] = {"16262356578", "16262358026", "16262360469", "16262362003", "16262363873", "16262366016"},
    ["Space Wave 2"] = {"1233158420", "1233158838", "1233157105", "1233157640", "1233157995", "1233159158"},
    ["Turquoise Wave"] = {"47974894", "47974690", "47974821", "47974776", "47974859", "47974909"},
    ["Dark Night"] = {"6285719338", "6285721078", "6285722964", "6285724682", "6285726335", "6285730635"},
    ["White Galaxy"] = {"5540798456", "5540799894", "5540801779", "5540801192", "5540799108", "5540800635"}
}

local function aplicarCieloExtra(t)
    for _, obj in pairs(Lighting:GetChildren()) do
        if obj:IsA("Sky") then obj:Destroy() end
    end
    local nuevoSky = Instance.new("Sky")
    nuevoSky.Name = "SnowXCustomSky"
    nuevoSky.SkyboxBk = "rbxassetid://" .. t[1]
    nuevoSky.SkyboxDn = "rbxassetid://" .. t[2]
    nuevoSky.SkyboxFt = "rbxassetid://" .. t[3]
    nuevoSky.SkyboxLf = "rbxassetid://" .. t[4]
    nuevoSky.SkyboxRt = "rbxassetid://" .. t[5]
    nuevoSky.SkyboxUp = "rbxassetid://" .. t[6]
    nuevoSky.Parent = Lighting
end

local listaNombresCielos = {}
for name in pairs(skyboxDataExtra) do
    table.insert(listaNombresCielos, name)
end
table.sort(listaNombresCielos)

Tabs.Texturas:CreateDropdown({
    Name = "Seleccionar Cielo",
    Options = listaNombresCielos,
    CurrentOption = "Default",
    Callback = function(selection)
        local ids = skyboxDataExtra[selection]
        if ids then
            aplicarCieloExtra(ids)
            Window:Notify({Title = "Cielo Aplicado", Text = "Textura: " .. selection, Duration = 2})
        end
    end
})

Tabs.Texturas:CreateSection("climate")

Tabs.Texturas:CreateButton({
    Name = "Climate Gris Nube",
    Callback = function()
        local Workspace_Terrain = workspace.Terrain
        for _, v in pairs(Lighting:GetChildren()) do if not v:IsA("Atmosphere") then v:Destroy() end end
        for _, v in pairs(Workspace_Terrain:GetChildren()) do if v:IsA("Clouds") then v:Destroy() end end
        Lighting.Ambient = Color3.fromRGB(0, 0, 0)
        Lighting.Brightness = 3.13
        Lighting.ClockTime = 14.5
        Lighting.ColorShift_Top = Color3.fromRGB(188, 141, 1)
        Lighting.EnvironmentDiffuseScale = 0.583
        Lighting.EnvironmentSpecularScale = 1
        Lighting.GlobalShadows = true
        Lighting.OutdoorAmbient = Color3.fromRGB(145, 128, 95)
        pcall(function()
            local fenv = getfenv()
            fenv.sethiddenproperty(Lighting, "Technology", Enum.Technology.ShadowMap)
            fenv.sethiddenproperty(Workspace_Terrain, "Decoration", true)
        end)
        local Sky = Instance.new("Sky", Lighting)
        Sky.SkyboxBk = "rbxassetid://6444884337"
        Sky.SkyboxDn = "rbxassetid://6444884785"
        Sky.SkyboxFt = "rbxassetid://6444884337"
        Sky.SkyboxLf = "rbxassetid://6444884337"
        Sky.SkyboxRt = "rbxassetid://6444884337"
        Sky.SkyboxUp = "rbxassetid://6412503613"
        local Bloom = Instance.new("BloomEffect", Lighting)
        Bloom.Intensity = 1
        Bloom.Size = 90
        Bloom.Threshold = 2
        local CC = Instance.new("ColorCorrectionEffect", Lighting)
        CC.Brightness = 0.04
        CC.Contrast = 0.19
        CC.Saturation = 0.12
        Window:Notify({Title = "Cielo", Text = "Cielo Gris Nube Activado", Duration = 2})
    end
})

Tabs.Texturas:CreateButton({
    Name = "Climate Azul Claro",
    Callback = function()
        local Workspace_Terrain = workspace.Terrain
        for _, v in pairs(Lighting:GetChildren()) do if not v:IsA("Atmosphere") then v:Destroy() end end
        for _, v in pairs(Workspace_Terrain:GetChildren()) do if v:IsA("Clouds") then v:Destroy() end end
        Lighting.Ambient = Color3.fromRGB(172, 172, 172)
        Lighting.Brightness = 3.8
        Lighting.ClockTime = 7.1
        Lighting.ColorShift_Top = Color3.fromRGB(255, 174, 43)
        Lighting.EnvironmentDiffuseScale = 0.3
        Lighting.EnvironmentSpecularScale = 0.06
        Lighting.ExposureCompensation = -0.24
        pcall(function()
            local fenv = getfenv()
            fenv.sethiddenproperty(Lighting, "Technology", Enum.Technology.Future)
        end)
        local Sky = Instance.new("Sky", Lighting)
        Sky.SkyboxBk = "rbxassetid://1009082031"
        Sky.SkyboxDn = "rbxassetid://1009082487"
        Sky.SkyboxFt = "rbxassetid://1009082252"
        Sky.SkyboxLf = "rbxassetid://1009082137"
        Sky.SkyboxRt = "rbxassetid://1009081946"
        Sky.SkyboxUp = "rbxassetid://1009082428"
        local SunRays = Instance.new("SunRaysEffect", Lighting)
        SunRays.Intensity = 0.18
        SunRays.Spread = 0.12
        local Atmosphere = Instance.new("Atmosphere", Lighting)
        Atmosphere.Color = Color3.fromRGB(199, 170, 107)
        Atmosphere.Density = 0.42
        Window:Notify({Title = "Cielo", Text = "Cielo Azul Claro Activado", Duration = 2})
    end
})

Tabs.Texturas:CreateButton({
    Name = "Climate Noche Rosa",
    Callback = function()
        local Workspace_Terrain = workspace.Terrain
        for _, v in pairs(Lighting:GetChildren()) do if not v:IsA("Atmosphere") then v:Destroy() end end
        for _, v in pairs(Workspace_Terrain:GetChildren()) do if v:IsA("Clouds") then v:Destroy() end end
        Lighting.Ambient = Color3.fromRGB(30, 10, 20)
        Lighting.Brightness = 1.5
        Lighting.ClockTime = 20.5
        Lighting.ColorShift_Top = Color3.fromRGB(255, 100, 150)
        Lighting.EnvironmentDiffuseScale = 0.4
        Lighting.EnvironmentSpecularScale = 0.5
        pcall(function()
            local fenv = getfenv()
            fenv.sethiddenproperty(Lighting, "Technology", Enum.Technology.Future)
        end)
        local Sky = Instance.new("Sky", Lighting)
        Sky.SkyboxBk = "rbxassetid://88585370973398"
        Sky.SkyboxDn = "rbxassetid://128014535205529"
        Sky.SkyboxFt = "rbxassetid://85323615042244"
        Sky.SkyboxLf = "rbxassetid://77415797450913"
        Sky.SkyboxRt = "rbxassetid://127566931602371"
        Sky.SkyboxUp = "rbxassetid://102320981098060"
        local Bloom = Instance.new("BloomEffect", Lighting)
        Bloom.Intensity = 0.6
        Bloom.Size = 40
        Bloom.Threshold = 0.8
        local CC = Instance.new("ColorCorrectionEffect", Lighting)
        CC.TintColor = Color3.fromRGB(255, 220, 230)
        CC.Saturation = 0.25
        Window:Notify({Title = "Cielo", Text = "Noche Rosa Activada", Duration = 2})
    end
})

Tabs.Texturas:CreateButton({
    Name = "Climate Noche Realista",
    Callback = function()
        local Workspace_Terrain = workspace.Terrain
        for _, v in pairs(Lighting:GetChildren()) do if not v:IsA("Atmosphere") then v:Destroy() end end
        for _, v in pairs(Workspace_Terrain:GetChildren()) do if v:IsA("Clouds") then v:Destroy() end end
        Lighting.Ambient = Color3.fromRGB(0, 0, 0)
        Lighting.Brightness = 1.0
        Lighting.ClockTime = 0
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        pcall(function()
            local fenv = getfenv()
            fenv.sethiddenproperty(Lighting, "Technology", Enum.Technology.Future)
        end)
        local Atmosphere = Instance.new("Atmosphere", Lighting)
        Atmosphere.Color = Color3.fromRGB(5, 5, 10)
        Atmosphere.Density = 0.65
        Window:Notify({Title = "Cielo", Text = "Noche Realista Activada", Duration = 2})
    end
})

Tabs.Texturas:CreateButton({
    Name = "Climate Pink Hour",
    Callback = function()
        local Workspace_Terrain = workspace.Terrain
        for _, v in pairs(Lighting:GetChildren()) do
            if not v:IsA("Atmosphere") then v:Destroy() end
        end
        for _, v in pairs(Workspace_Terrain:GetChildren()) do
            if v:IsA("Clouds") then v:Destroy() end
        end
        Lighting.Ambient = Color3.fromRGB(70, 20, 90)
        Lighting.OutdoorAmbient = Color3.fromRGB(130, 0, 160)
        Lighting.ColorShift_Top = Color3.fromRGB(255, 100, 200)
        Lighting.ColorShift_Bottom = Color3.fromRGB(100, 0, 130)
        Lighting.Brightness = 2.0
        Lighting.ClockTime = 6.7
        Lighting.ExposureCompensation = -0.05
        Lighting.FogColor = Color3.fromRGB(120, 20, 150)
        Lighting.FogEnd = 1200
        pcall(function()
            local fenv = getfenv()
            fenv.sethiddenproperty(Lighting, "Technology", Enum.Technology.Future)
        end)
        local Sky = Instance.new("Sky", Lighting)
        Sky.Name = "AstraPinkSky"
        Sky.SkyboxUp = "rbxassetid://323493360"
        Sky.SkyboxLf = "rbxassetid://323494252"
        Sky.SkyboxBk = "rbxassetid://323494035"
        Sky.SkyboxFt = "rbxassetid://323494130"
        Sky.SkyboxDn = "rbxassetid://323494368"
        Sky.SkyboxRt = "rbxassetid://323494067"
        Sky.SunAngularSize = 14
        Sky.StarCount = 3000
        local cc = Instance.new("ColorCorrectionEffect", Lighting)
        cc.TintColor = Color3.fromRGB(255, 200, 240)
        cc.Saturation = 0.35
        cc.Contrast = 0.15
        local bloom = Instance.new("BloomEffect", Lighting)
        bloom.Size = 25
        bloom.Intensity = 0.5
        bloom.Threshold = 0.85
        local sunRays = Instance.new("SunRaysEffect", Lighting)
        sunRays.Intensity = 0.08
        sunRays.Spread = 0.8
        Window:Notify({Title = "Cielo", Text = "Pink Hour Activado", Duration = 2})
    end
})

Tabs.Texturas:CreateButton({
    Name = "Climate Radiactivo",
    Callback = function()
        local Workspace_Terrain = workspace.Terrain
        for _, v in pairs(Lighting:GetChildren()) do
            if not v:IsA("Atmosphere") then v:Destroy() end
        end
        for _, v in pairs(Workspace_Terrain:GetChildren()) do
            if v:IsA("Clouds") then v:Destroy() end
        end
        local color = Instance.new("ColorCorrectionEffect", Lighting)
        color.Name = "RadioactiveGreen"
        color.TintColor = Color3.fromRGB(60, 255, 80)
        color.Brightness = 0.05
        color.Contrast = 0.35
        color.Saturation = 0.2
        Lighting.Ambient = Color3.fromRGB(20, 180, 30)
        Lighting.OutdoorAmbient = Color3.fromRGB(40, 220, 50)
        Lighting.Brightness = 2
        Lighting.ClockTime = 12
        local clouds = Instance.new("Clouds", Workspace_Terrain)
        clouds.Cover = 1
        clouds.Density = 1
        clouds.Color = Color3.fromRGB(30, 120, 35)
        Window:Notify({Title = "Cielo", Text = "Ambiente Radiactivo", Duration = 2})
    end
})

Tabs.Texturas:CreateButton({
    Name = "Climate Apocalíptico",
    Callback = function()
        local Workspace_Terrain = workspace.Terrain
        for _, v in pairs(Lighting:GetChildren()) do
            if not v:IsA("Atmosphere") then v:Destroy() end
        end
        for _, v in pairs(Workspace_Terrain:GetChildren()) do
            if v:IsA("Clouds") then v:Destroy() end
        end
        local color = Instance.new("ColorCorrectionEffect", Lighting)
        color.Name = "RedSkyColor"
        color.TintColor = Color3.fromRGB(255, 40, 40)
        color.Brightness = -0.05
        color.Contrast = 0.25
        color.Saturation = 0.1
        local clouds = Instance.new("Clouds", Workspace_Terrain)
        clouds.Cover = 0.85
        clouds.Density = 0.9
        clouds.Color = Color3.fromRGB(70, 0, 0)
        Lighting.Ambient = Color3.fromRGB(120, 0, 0)
        Lighting.OutdoorAmbient = Color3.fromRGB(180, 0, 0)
        Lighting.Brightness = 2
        Lighting.ClockTime = 18
        Window:Notify({Title = "Cielo", Text = "Ambiente Apocalíptico", Duration = 2})
    end
})

Tabs.Texturas:CreateButton({
    Name = "Remover Climate",
    Callback = function()
        local Workspace_Terrain = workspace.Terrain
        for _, obj in pairs(Lighting:GetChildren()) do
            if obj:IsA("Sky") or obj:IsA("ColorCorrectionEffect") or obj:IsA("BloomEffect") or obj:IsA("SunRaysEffect") or obj:IsA("Atmosphere") then
                obj:Destroy()
            end
        end
        for _, obj in pairs(Workspace_Terrain:GetChildren()) do
            if obj:IsA("Clouds") then obj:Destroy() end
        end
        Lighting.Ambient = cieloOriginal.Ambient
        Lighting.OutdoorAmbient = cieloOriginal.OutdoorAmbient
        Lighting.Brightness = cieloOriginal.Brightness
        Lighting.ClockTime = cieloOriginal.ClockTime
        Lighting.ColorShift_Top = cieloOriginal.ColorShift_Top
        Lighting.ColorShift_Bottom = cieloOriginal.ColorShift_Bottom
        Lighting.EnvironmentDiffuseScale = cieloOriginal.EnvironmentDiffuseScale
        Lighting.EnvironmentSpecularScale = cieloOriginal.EnvironmentSpecularScale
        Lighting.ExposureCompensation = cieloOriginal.ExposureCompensation
        Lighting.FogColor = cieloOriginal.FogColor
        Lighting.FogEnd = cieloOriginal.FogEnd
        for _, objClonado in pairs(cieloOriginal.Objetos) do
            pcall(function()
                local nuevoObj = objClonado:Clone()
                if nuevoObj:IsA("Clouds") then
                    nuevoObj.Parent = Workspace_Terrain
                else
                    nuevoObj.Parent = Lighting
                end
            end)
        end
        Window:Notify({Title = "Cielo", Text = "restaurado", Duration = 2})
    end
})

local TabTools = Window:CreateTab({
    Name = "Tools", 
    Icon = "rbxassetid://6035174005"
})

local Codes = {
    "1BVISITS",
    "HOTEL",
    "FREE",
    "BACK",
    "GAME",
    "EGGHUNT"
}

local Selected = Codes[1]
local Busy = false
local Remote = game:GetService("ReplicatedStorage").Packages.Networking["RF/Codes/Code"]

TabTools:CreateSection("Canjeador de Códigos")

local CodeDropdown = TabTools:CreateDropdown({
    Name = "Seleccionar Código",
    Options = Codes,
    CurrentOption = Selected,
    Callback = function(Value)
        Selected = Value
    end
})

TabTools:CreateButton({
    Name = "Reclamar código",
    Callback = function()
        if Busy then return end
        Busy = true
        
        Window:Notify({Title = "Codes", Text = "Reclamando código...", Duration = 2})

        local Ok, Result = pcall(function()
            return Remote:InvokeServer(Selected)
        end)

        if Ok then
            Window:Notify({Title = "Codes", Text = "CodigoEnviado: " .. Selected, Duration = 3})
        else
            Window:Notify({Title = "Codes", Text = "Nosepudoreclamar", Duration = 3})
            warn(Result)
        end

        Busy = false
    end
})


TabTools:CreateSection("Avatar")

local function getSkinApi()
    return type(skinApi) == "table" and skinApi or nil
end

local function openAvatar()
    local api = getSkinApi()
    if not api then
        Window:Notify({Title = "SnowX", Text = "Ejecuta SnowX-Skins.lua para cargar el sistema de skins.", Duration = 4})
        return false
    end
    local ok, opened = pcall(function()
        if type(api.open) == "function" then
            return api.open()
        elseif api.gui then
            api.gui.Enabled = true
            return true
        end
        return false
    end)
    if not ok or opened == false then
        Window:Notify({Title = "SnowX", Text = "No se pudo abrir el panel de skins.", Duration = 3})
        return false
    end
    return true
end

local function closeAvatar()
    local api = getSkinApi()
    if api and api.gui then
        pcall(function() api.gui.Enabled = false end)
    end
end

TabTools:CreateToggle({
    Name = "Avatar",
    CurrentValue = false,
    Flag = "AvatarToggle",
    Callback = function(state)
        if state then
            openAvatar()
        else
            closeAvatar()
        end
    end,
})

TabTools:CreateButton({
    Name = "Accesorios",
    Callback = function()
        openSnowXAccessory()
    end,
})



local KillSounds = {
    {Name="Onichaaan", Id="114361503583259"},
    {Name="Omagaaa", Id="4496966777"},
    {Name="korummm", Id="119896940405402"},
    {Name="FAAAH XD", Id="92076037937225"},
    {Name="Nuevo KillSound", Id="109302722677792"},
    {Name="Sword Hit", Id="140462043853173"},
    {Name="TF2", Id="2866718318"},
    {Name="SpongeBob Laugh", Id="271580013"},
    {Name="Monster Kill", Id="74959901252990"},
    {Name="Insta Kill", Id="131961137"},
    {Name="Fortnite Death", Id="70982573243341"},
    {Name="Ez", Id="8922169253"},
    {Name="Among Us", Id="130456049552264"},
    {Name="SONICXD", Id="132307272475720"}
}

local ShootSounds = {
    {Name="Revolver", Id="680140087"},
    {Name="Magia de Anime", Id="109296938403067"},
    {Name="Láser", Id="4400449399"}
}

local ReloadSounds = {
    {Name="Revolver", Id="138084889"},
    {Name="Láser", Id="129456040607483"}
}

local KillId = KillSounds[1].Id
local ShootId = ShootSounds[1].Id
local ReloadId = ReloadSounds[1].Id

local KillEnabled = true
local ShootEnabled = true
local ReloadEnabled = true

local SoundData = setmetatable({}, {__mode="k"})

local function GetSoundAsset(id)
    id = tostring(id or ""):gsub("%D","")
    if id == "" then return nil end
    return "rbxassetid://"..id
end

local function IsMySound(s)
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    local rendered = workspace:FindFirstChild("RenderedObjects")
    local knife = rendered and rendered:FindFirstChild("LocalThrowingKnife")
    local throwing = workspace:FindFirstChild("ThrowingLocalKnife")

    return (char and s:IsDescendantOf(char))
        or (backpack and s:IsDescendantOf(backpack))
        or (knife and s:IsDescendantOf(knife))
        or (throwing and s:IsDescendantOf(throwing))
end

local function UpdateSound(s)
    if not s:IsA("Sound") then return end

    if not SoundData[s] then
        SoundData[s] = {
            Id = s.SoundId,
            Volume = s.Volume
        }
    end

    local saved = SoundData[s]
    local name = s.Name:lower()

    if name == "died" then
        local model = s:FindFirstAncestorOfClass("Model")
        local humanoid = model and model:FindFirstChildOfClass("Humanoid")

        if not humanoid then return end

        if model == LocalPlayer.Character then
            s.Volume = 0
            s:Stop()
        elseif KillEnabled then
            local id = GetSoundAsset(KillId)
            if id then
                s.SoundId = id
                s.Volume = saved.Volume
            end
        else
            s.SoundId = saved.Id
            s.Volume = saved.Volume
        end
        return
    end

    if not IsMySound(s) then return end

    if name == "kill" or name == "throwkill"
        or name == "gunkill" or name == "killsound"
        or name == "kill sound" then

        local id = GetSoundAsset(KillId)
        s.SoundId = (KillEnabled and id) or saved.Id

    elseif name == "gunshot" then
        local id = GetSoundAsset(ShootId)
        s.SoundId = (ShootEnabled and id) or saved.Id

    elseif name == "reload" then
        local id = GetSoundAsset(ReloadId)
        s.SoundId = (ReloadEnabled and id) or saved.Id
    end
end

local function RefreshSounds()
    for _,v in ipairs(game:GetDescendants()) do
        UpdateSound(v)
    end
end

game.DescendantAdded:Connect(function(v)
    task.defer(function()
        UpdateSound(v)
    end)
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    RefreshSounds()
end)

local killNames = {} for _, v in ipairs(KillSounds) do table.insert(killNames, v.Name) end
local shootNames = {} for _, v in ipairs(ShootSounds) do table.insert(shootNames, v.Name) end
local reloadNames = {} for _, v in ipairs(ReloadSounds) do table.insert(reloadNames, v.Name) end


TabTools:CreateSection("Sound Changer - Killsound")

TabTools:CreateToggle({
    Name = "Activar Killsound",
    CurrentValue = true,
    Callback = function(state)
        KillEnabled = state
        RefreshSounds()
    end
})

local KillDropdown = TabTools:CreateDropdown({
    Name = "Seleccionar Killsound",
    Options = killNames,
    CurrentOption = KillSounds[1].Name,
    Callback = function(Value)
        for _, v in ipairs(KillSounds) do
            if v.Name == Value then
                KillId = v.Id
                RefreshSounds()
                break
            end
        end
    end
})

TabTools:CreateInput({
    Name = "Custom Killsound ID",
    Placeholder = "Escribe un ID de Roblox...",
    Callback = function(text)
        if text ~= "" then
            local id = GetSoundAsset(text)
            if id then
                KillId = id:gsub("rbxassetid://","")
                RefreshSounds()
                Window:Notify({Title = "Sounds", Text = "Killsound ID Aplicado", Duration = 2})
            end
        end
    end
})

TabTools:CreateSection("Sound Changer - Disparo")

TabTools:CreateToggle({
    Name = "Activar Sonido Disparo",
    CurrentValue = true,
    Callback = function(state)
        ShootEnabled = state
        RefreshSounds()
    end
})

local ShootDropdown = TabTools:CreateDropdown({
    Name = "Seleccionar Disparo",
    Options = shootNames,
    CurrentOption = ShootSounds[1].Name,
    Callback = function(Value)
        for _, v in ipairs(ShootSounds) do
            if v.Name == Value then
                ShootId = v.Id
                RefreshSounds()
                break
            end
        end
    end
})

TabTools:CreateInput({
    Name = "Custom Disparo ID",
    Placeholder = "Escribe un ID de Roblox...",
    Callback = function(text)
        if text ~= "" then
            local id = GetSoundAsset(text)
            if id then
                ShootId = id:gsub("rbxassetid://","")
                RefreshSounds()
                Window:Notify({Title = "Sounds", Text = "Disparo ID Aplicado", Duration = 2})
            end
        end
    end
})

TabTools:CreateSection("Sound Changer - Recarga")

TabTools:CreateToggle({
    Name = " Sonido Recarga",
    CurrentValue = true,
    Callback = function(state)
        ReloadEnabled = state
        RefreshSounds()
    end
})

local ReloadDropdown = TabTools:CreateDropdown({
    Name = "Seleccionar Recarga",
    Options = reloadNames,
    CurrentOption = ReloadSounds[1].Name,
    Callback = function(Value)
        for _, v in ipairs(ReloadSounds) do
            if v.Name == Value then
                ReloadId = v.Id
                RefreshSounds()
                break
            end
        end
    end
})

TabTools:CreateInput({
    Name = "Custom Recarga ID",
    Placeholder = "Escribe un ID de Roblox...",
    Callback = function(text)
        if text ~= "" then
            local id = GetSoundAsset(text)
            if id then
                ReloadId = id:gsub("rbxassetid://","")
                RefreshSounds()
                Window:Notify({Title = "Sounds", Text = "Recarga ID Aplicado", Duration = 2})
            end
        end
    end
})

RefreshSounds()


Tabs.Settings:CreateSection("Community")

Tabs.Settings:CreateParagraph({
    Title = "Únete a nuestro Discord",
    Content = "hola gracias por usar el script espero disfrutes tu experiencia, únete a nuestro Discord"
})

Tabs.Settings:CreateButton({
    Name = "Copy Discord",
    Callback = function()
        setclipboard("https://discord.gg/7X3n3G9dyX")
        Window:Notify({Title = "Discord", Text = "Copiado", Duration = 2})
    end
})

Window:Notify({
    Title = "SnowX",
    Text = "Cargado",
    Duration = 3
})