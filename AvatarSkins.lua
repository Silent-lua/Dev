local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserService = game:GetService("UserService")
local CONFIG_PATH = "avatar-tools/skins.json"
local localPlayer = Players.LocalPlayer

local avatarBridge = ...
if type(avatarBridge) ~= "table" then avatarBridge = {} end
avatarBridge.version = 2
avatarBridge.skin = type(avatarBridge.skin) == "table" and avatarBridge.skin or {}
avatarBridge.accessory = type(avatarBridge.accessory) == "table" and avatarBridge.accessory or {}
avatarBridge.skin.revision = tonumber(avatarBridge.skin.revision) or 0
avatarBridge.accessory.revision = tonumber(avatarBridge.accessory.revision) or 0
avatarBridge.uiPanels = type(avatarBridge.uiPanels) == "table" and avatarBridge.uiPanels or {}
local skinBridgeToken = {}
local function isSkinRendererActive()
    return avatarBridge.skin.active == true or avatarBridge.skin.pending == true
end

local function bumpSkinRevision()
    avatarBridge.skin.revision = (tonumber(avatarBridge.skin.revision) or 0) + 1
end

local COLORS = {
    Background = Color3.fromRGB(12, 12, 14),
    BackgroundAlt = Color3.fromRGB(18, 18, 22),
    Surface = Color3.fromRGB(26, 26, 32),
    SurfaceUp = Color3.fromRGB(36, 36, 44),
    Soft = Color3.fromRGB(190, 190, 198),
    Line = Color3.fromRGB(54, 54, 62),
    Border = Color3.fromRGB(74, 74, 84),
    Text = Color3.fromRGB(245, 245, 245),
    Icon = Color3.fromRGB(190, 190, 198),
    Faint = Color3.fromRGB(170, 170, 178),
    On = Color3.fromRGB(255, 255, 255),
    OnFill = Color3.fromRGB(75, 75, 82),
    Accent = Color3.fromRGB(255, 255, 255),
    AccentFill = Color3.fromRGB(42, 42, 48),
    Danger = Color3.fromRGB(255, 255, 255),
    DangerFill = Color3.fromRGB(95, 45, 45),
}

local PANEL_WIDTH = 590
local PANEL_HEIGHT = 274

local animationScriptNames = {
    idle = "IdleAnimation",
    walk = "WalkAnimation",
    run = "RunAnimation",
    jump = "JumpAnimation",
    fall = "FallAnimation",
    climb = "ClimbAnimation",
    swim = "SwimAnimation",
}

local skinState = {
    userId = nil,
    nombre = nil,
    usuario = nil,
    aplicado = nil,
    favoritos = {},
    rig = "R15",
    feMode = "ON",
    animationsEnabled = true,
}

local function loadConfiguration()
    if typeof(readfile) ~= "function" or typeof(isfile) ~= "function" then
        return
    end

    local ok, result = pcall(function()
        if isfile(CONFIG_PATH) then
            return readfile(CONFIG_PATH)
        end
        return nil
    end)

    if not ok or type(result) ~= "string" then
        return
    end
    local ok2, result2 = pcall(HttpService.JSONDecode, HttpService, result)
    if not (ok2 and type(result2) == "table") then
        return
    end

    if type(result2.favoritos) == "table" then
        for _, favorito in ipairs(result2.favoritos) do
            if type(favorito) == "table" and tonumber(favorito.userId) then
                table.insert(skinState.favoritos, {
                    userId = tonumber(favorito.userId),
                    nombre = tostring(favorito.nombre or favorito.userId),
                    usuario = type(favorito.usuario) == "string" and favorito.usuario or nil,
                })
            end
        end
    end

    if tonumber(result2.userId) then
        skinState.userId = tonumber(result2.userId)
        skinState.nombre = tostring(result2.nombre or result2.userId)
        skinState.usuario = type(result2.usuario) == "string" and result2.usuario or nil
    end

    if result2.rig == "R6" or result2.rig == "R15" then
        skinState.rig = result2.rig
    end

    skinState.feMode = "ON"
    if type(result2.animationsEnabled) == "boolean" then
        skinState.animationsEnabled = result2.animationsEnabled
    end
end

local function saveConfiguration()
    if typeof(writefile) ~= "function" then
        return
    end

    pcall(function()
        if typeof(isfolder) == "function" and typeof(makefolder) == "function" and not isfolder("avatar-tools") then
            makefolder("avatar-tools")
        end
    end)

    pcall(writefile, CONFIG_PATH, HttpService:JSONEncode({
        userId = skinState.userId,
        nombre = skinState.nombre,
        usuario = skinState.usuario,
        favoritos = skinState.favoritos,
        rig = skinState.rig,
        feMode = "ON",
        animationsEnabled = skinState.animationsEnabled == true,
    }))
end

local function createGuiInstance(className, properties, parent, cornerRadius)
    local instance = Instance.new(className)

    for k, v in pairs(properties) do
        instance[k] = v
    end

    if instance:IsA("TextButton") and properties.Text and properties.Text ~= "" then
        instance.TextStrokeColor3 = Color3.new(0, 0, 0)
        instance.TextStrokeTransparency = 0.75
    end

    if cornerRadius then
        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(0, cornerRadius)
        uiCorner.Parent = instance
    end

    instance.Parent = parent
    return instance
end

local lucideLibrary = nil
local pendingIconRequests = {}

local function setLucideImage(imageLabel, iconName)
    if not lucideLibrary then
        table.insert(pendingIconRequests, { imageLabel, iconName })
        return
    end
    local ok, result = pcall(lucideLibrary.GetAsset, iconName)

    if ok and result then
        imageLabel.Image = result.Url
        imageLabel.ImageRectOffset = result.ImageRectOffset
        imageLabel.ImageRectSize = result.ImageRectSize
    end
end

task.spawn(function()
    local ok, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/lucide-roblox-direct/refs/heads/main/source.lua"))()
    end)

    if ok and type(result) == "table" and result.GetAsset then
        lucideLibrary = result

        for _, pendingIconRequest in ipairs(pendingIconRequests) do
            setLucideImage(pendingIconRequest[1], pendingIconRequest[2])
        end

        table.clear(pendingIconRequests)
    end
end)

local function createImageLabel(parent, iconName, iconSize, imageColor3, position)
    local imageLabel = Instance.new("ImageLabel")
    imageLabel.BackgroundTransparency = 1
    imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    imageLabel.Position = position or UDim2.fromScale(0.5, 0.5)
    imageLabel.Size = UDim2.fromOffset(iconSize, iconSize)
    imageLabel.ImageColor3 = imageColor3
    imageLabel.Image = ""
    imageLabel.Active = false
    imageLabel.Parent = parent
    setLucideImage(imageLabel, iconName)
    return imageLabel
end

local function getLocalCharacter()
    local character = localPlayer.Character
    if not character then
        return nil
    end

    if character.Name:find("d55076dde45f5d1c5267", 1, true) then
        return nil
    end
    return character
end

local function isCharacterRigComplete(character, humanoid, visualRigName)
    if not (character and humanoid and character.Parent and humanoid.Parent) then
        return false
    end

    local requiredParts
    if humanoid.RigType == Enum.HumanoidRigType.R6 then
        requiredParts = { "HumanoidRootPart", "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" }
    else
        requiredParts = {
            "HumanoidRootPart", "Head", "UpperTorso", "LowerTorso",
            "LeftUpperArm", "LeftLowerArm", "LeftHand",
            "RightUpperArm", "RightLowerArm", "RightHand",
            "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
            "RightUpperLeg", "RightLowerLeg", "RightFoot",
        }
    end

    local foundParts = {}
    local foundJoints = {}
    for _, descendant in ipairs(character:GetDescendants()) do
        if descendant:IsA("BasePart")
            and not descendant:FindFirstAncestorOfClass("Accessory")
            and not descendant:FindFirstAncestorOfClass("Tool") then
            foundParts[descendant.Name] = true
        elseif (descendant:IsA("Motor6D") or descendant:IsA("AnimationConstraint"))
            and not descendant:FindFirstAncestorOfClass("Accessory")
            and not descendant:FindFirstAncestorOfClass("Tool") then
            foundJoints[descendant.Name] = true
        end
    end

    for _, partName in ipairs(requiredParts) do
        if not foundParts[partName] then
            return false
        end
    end

    if humanoid.RigType == Enum.HumanoidRigType.R15 and visualRigName == "R6" then
        for _, jointName in ipairs({ "Root", "Waist", "Neck", "RightShoulder", "LeftShoulder", "RightHip", "LeftHip" }) do
            if not foundJoints[jointName] then
                return false
            end
        end
    end
    return true
end

local function waitForCharacterRig(character, humanoid, visualRigName, timeout)
    if isCharacterRigComplete(character, humanoid, visualRigName) then
        return true
    end

    local signal = Instance.new("BindableEvent")
    local finished = false
    local connection
    local function finish()
        if finished then return end
        finished = true
        signal:Fire()
    end

    connection = character.DescendantAdded:Connect(function()
        if isCharacterRigComplete(character, humanoid, visualRigName) then
            finish()
        end
    end)

    if isCharacterRigComplete(character, humanoid, visualRigName) then
        finish()
    else
        task.delay(math.max(0.1, tonumber(timeout) or 2.5), finish)
        if not finished then
            signal.Event:Wait()
        end
    end

    if connection then connection:Disconnect() end
    signal:Destroy()
    return isCharacterRigComplete(character, humanoid, visualRigName)
end

local function createHumanoidModel(_userId, humanoidDescription, rigName)
    local rigType = rigName == "R6" and Enum.HumanoidRigType.R6 or Enum.HumanoidRigType.R15
    if not humanoidDescription or not humanoidDescription:IsA("HumanoidDescription") then
        return nil
    end

    local ok, result = pcall(function()
        return Players:CreateHumanoidModelFromDescriptionAsync(humanoidDescription, rigType)
    end)
    if not (ok and result) then
        ok, result = pcall(Players.CreateHumanoidModelFromDescription, Players, humanoidDescription, rigType)
    end

    if not (ok and result) then
        return nil
    end
    result.Parent = nil
    return result
end

local userInfoCache = {}
local skinModelTemplates = {}
local skinModelTemplateOrder = {}
local MAX_SKIN_MODEL_TEMPLATES = 6

local function getSkinTemplateKey(userId, rigName)
    local accessoryRevision = 0
    if type(avatarBridge.accessory) == "table" then
        accessoryRevision = tonumber(avatarBridge.accessory.revision) or 0
    end
    return table.concat({ tostring(userId), tostring(rigName), tostring(accessoryRevision) }, "|")
end

local function cloneSkinTemplate(key)
    local template = skinModelTemplates[key]
    if not template then return nil end
    local ok, clone = pcall(function() return template:Clone() end)
    return ok and clone or nil
end

local function storeSkinTemplate(key, model)
    if not model then return end
    local ok, template = pcall(function() return model:Clone() end)
    if not ok or not template then return end

    template.Parent = nil
    if skinModelTemplates[key] then
        pcall(function() skinModelTemplates[key]:Destroy() end)
    else
        table.insert(skinModelTemplateOrder, key)
    end
    skinModelTemplates[key] = template

    while #skinModelTemplateOrder > MAX_SKIN_MODEL_TEMPLATES do
        local oldestKey = table.remove(skinModelTemplateOrder, 1)
        local oldest = skinModelTemplates[oldestKey]
        if oldest then pcall(function() oldest:Destroy() end) end
        skinModelTemplates[oldestKey] = nil
    end
end

local function getUserNames(userId)
    if userInfoCache[userId] then
        return userInfoCache[userId].nombre, userInfoCache[userId].usuario
    end
    local playerByUserId = Players:GetPlayerByUserId(userId)
    local displayName, name

    if playerByUserId then
        displayName = playerByUserId.DisplayName
        name = playerByUserId.Name
    else
        local ok, result = pcall(UserService.GetUserInfosByUserIdsAsync, UserService, { userId })
        ok = ok and type(result) == "table" and result[1]
        displayName = nil
        name = nil

        if ok then
            displayName = result[1].DisplayName
            name = result[1].Username
        end

        if not name then
            local ok2, result2 = pcall(Players.GetNameFromUserIdAsync, Players, userId)

            if ok2 and result2 then
                if displayName then
                    name = result2
                else
                    displayName = result2
                    name = result2
                end
            end
        end
    end

    if name then
        userInfoCache[userId] = { nombre = displayName or name, usuario = name }
    end

    return displayName, name
end

local avatarRigTypeCache = {}

local function getUserRigType(userId)
    if avatarRigTypeCache[userId] then
        return avatarRigTypeCache[userId]
    end
    local ok, result = pcall(Players.GetCharacterAppearanceInfoAsync, Players, userId)
    ok = ok and type(result) == "table" and result.playerAvatarType
    if ok == "R6" or ok == "R15" then
        avatarRigTypeCache[userId] = ok
        return ok
    end
    return nil
end

local humanoidDescriptionCache = {}

local function getUserHumanoidDescription(userId)
    if humanoidDescriptionCache[userId] then
        return humanoidDescriptionCache[userId]
    end
    local playerByUserId = Players:GetPlayerByUserId(userId)
    local humanoid = playerByUserId and playerByUserId.Character and playerByUserId.Character:FindFirstChildOfClass("Humanoid")
    local humanoidDescription = nil

    if humanoid then
        local ok, result = pcall(humanoid.GetAppliedDescription, humanoid)
        ok = ok and result
        humanoidDescription = nil

        if ok then
            humanoidDescription = result
        end
    end

    if not humanoidDescription then
        local ok, result = pcall(function()
            return Players:GetHumanoidDescriptionFromUserIdAsync(userId)
        end)

        if not (ok and result) then
            ok, result = pcall(Players.GetHumanoidDescriptionFromUserId, Players, userId)
        end

        if ok and result then
            humanoidDescription = result
        end
    end

    if humanoidDescription then
        humanoidDescriptionCache[userId] = humanoidDescription
    end

    return humanoidDescription
end

local loadedAssetObjectsCache = {}

local function loadAssetObjects(assetId)
    local assetIdString = tostring(assetId)
    if loadedAssetObjectsCache[assetIdString] ~= nil then
        return loadedAssetObjectsCache[assetIdString] or nil
    end
    local ok, result = pcall(game.GetObjects, game, "rbxassetid://" .. assetIdString)
    if not (ok and type(result) == "table") then
        loadedAssetObjectsCache[assetIdString] = false
        return nil
    end

    for _, assetObject in ipairs(result) do
        assetObject.Parent = nil
    end

    loadedAssetObjectsCache[assetIdString] = result
    return result
end

local function preloadAnimationAssets(humanoidDescription)
    local pendingAssetCount = 0

    for _, animationScriptName in pairs(animationScriptNames) do
        local animationAssetId = humanoidDescription[animationScriptName]

        if type(animationAssetId) == "number" and animationAssetId > 0 and loadedAssetObjectsCache[tostring(animationAssetId)] == nil then
            pendingAssetCount += 1

            task.spawn(function()
                loadAssetObjects(animationAssetId)
                pendingAssetCount -= 1
            end)
        end
    end

    local now = os.clock()

    while pendingAssetCount > 0 and os.clock() - now < 15 do
        task.wait(0.05)
    end
end

local function extractAnimationSets(humanoidDescription)
    local animationSets = {}
    preloadAnimationAssets(humanoidDescription)

    for stateName, animationScriptName in pairs(animationScriptNames) do
        local animationAssetId = humanoidDescription[animationScriptName]

        if type(animationAssetId) == "number" and animationAssetId > 0 then
            local assetObjects = loadAssetObjects(animationAssetId)

            for _, assetObject in ipairs(assetObjects or {}) do
                local function addAnimation(animation)
                    if animation and animation:IsA("Animation") then
                        animationSets[stateName] = animationSets[stateName] or {}
                        table.insert(animationSets[stateName], animation)
                    end
                end

                addAnimation(assetObject)

                for _, descendant in ipairs(assetObject:GetDescendants()) do
                    addAnimation(descendant)
                end
            end
        end
    end

    return animationSets
end

local function getDescriptionEmotes(humanoidDescription)
    local emotes = {}
    local ok, result = pcall(humanoidDescription.GetEmotes, humanoidDescription)
    if not (ok and type(result) == "table") then
        return emotes
    end
    local equippedSlotsByName = {}
    local ok2, result2 = pcall(humanoidDescription.GetEquippedEmotes, humanoidDescription)

    if ok2 and type(result2) == "table" then
        for _, emoteEntry in ipairs(result2) do
            equippedSlotsByName[emoteEntry.Name] = emoteEntry.Slot
        end
    end

    for k, emoteEntry in pairs(result) do
        local emoteAssetId = type(emoteEntry) == "table" and tonumber(emoteEntry[1]) or tonumber(emoteEntry)

        if emoteAssetId then
            table.insert(emotes, { nombre = k, id = emoteAssetId, slot = equippedSlotsByName[k] or 99 })
        end
    end

    table.sort(emotes, function(leftEmote, rightEmote)
        if leftEmote.slot ~= rightEmote.slot then
            return leftEmote.slot < rightEmote.slot
        end
        return leftEmote.nombre < rightEmote.nombre
    end)

    return emotes
end

local originalCharacterStateCache = setmetatable({}, { __mode = "k" })

local function captureCharacterState(character)
    if originalCharacterStateCache[character] then
        return originalCharacterStateCache[character]
    end

    local savedCharacterState = {}
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        savedCharacterState.hipHeight = humanoid.HipHeight
    end

    originalCharacterStateCache[character] = savedCharacterState
    return savedCharacterState
end

local function noopCharacterStateHook(_character, _snapshot)

    return
end

local copiedSkinAnimationData = nil

local characterEmoteCache = setmetatable({}, { __mode = "k" })

local function getCharacterHumanoidDescription(character)
    character = character and character:FindFirstChildOfClass("Humanoid")
    return character and character:FindFirstChildOfClass("HumanoidDescription") or nil
end

local function applyEmotes(character, emotes)
    local humanoidDescription = getCharacterHumanoidDescription(character)
    if not humanoidDescription then
        return 0
    end

    if not characterEmoteCache[character] then
        local ok, result = pcall(humanoidDescription.GetEmotes, humanoidDescription)
        local ok2, result2 = pcall(humanoidDescription.GetEquippedEmotes, humanoidDescription)
        local emoteMap = {}
        local iterateEquippedEmotes = ipairs
        result2 = ok2 and result2 or {}

        for _, equippedEmote in iterateEquippedEmotes(result2) do
            emoteMap[#emoteMap + 1] = equippedEmote.Name
        end

        characterEmoteCache[character] = { emotes = ok and result or {}, equipados = emoteMap }
    end

    local emoteMap = {}
    local equippedEmoteNames = {}

    for _, iterateEquippedEmotes in ipairs(emotes) do
        emoteMap[iterateEquippedEmotes.nombre] = { iterateEquippedEmotes.id }

        if #equippedEmoteNames < 8 then
            equippedEmoteNames[#equippedEmoteNames + 1] = iterateEquippedEmotes.nombre
        end
    end

    return pcall(function()
        humanoidDescription:SetEmotes(emoteMap)
        humanoidDescription:SetEquippedEmotes(equippedEmoteNames)
    end) and #equippedEmoteNames or 0
end

local localPlayerEmoteData = nil

local function getLocalPlayerEmoteData()
    if localPlayerEmoteData then
        return localPlayerEmoteData
    end
    local ok, result = pcall(Players.GetHumanoidDescriptionFromUserId, Players, localPlayer.UserId)
    if not (ok and result) then
        return nil
    end
    local ok2, result2 = pcall(result.GetEmotes, result)
    local ok3, result3 = pcall(result.GetEquippedEmotes, result)
    if not (ok2 and ok3) then
        return nil
    end
    local equippedEmoteNames = {}

    for _, equippedEmote in ipairs(result3) do
        equippedEmoteNames[#equippedEmoteNames + 1] = equippedEmote.Name
    end

    localPlayerEmoteData = { emotes = result2, equipados = equippedEmoteNames }
    return localPlayerEmoteData
end

local function restoreCharacterEmotes(character)
    local humanoidDescription = getCharacterHumanoidDescription(character)
    if not humanoidDescription then
        return
    end
    local emoteData = getLocalPlayerEmoteData() or characterEmoteCache[character]
    if not emoteData then
        return
    end

    pcall(function()
        humanoidDescription:SetEmotes(emoteData.emotes)
        humanoidDescription:SetEquippedEmotes(emoteData.equipados)
    end)
end

local r6ToR15JointMappings = {}

local rootJointMapping = {
    targetPart0Name = "HumanoidRootPart",
    targetPart1Name = "Torso",
    sourcePart0Name = "HumanoidRootPart",
    sourcePart1Name = "UpperTorso",
    sourceJointNames = { "Root", "Waist" },
    sourceOffset = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0),
    targetOffset = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0),
}

local neckJointMapping = {
    targetPart0Name = "Torso",
    targetPart1Name = "Head",
    sourcePart0Name = "UpperTorso",
    sourcePart1Name = "Head",
    sourceJointNames = { "Neck" },
    sourceOffset = CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0),
    targetOffset = CFrame.new(0, -0.5, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0),
}

local rightShoulderMapping = {
    targetPart0Name = "Torso",
    targetPart1Name = "Right Arm",
    sourcePart0Name = "UpperTorso",
    sourcePart1Name = "RightUpperArm",
    sourceJointNames = { "RightShoulder" },
    sourceOffset = CFrame.new(1, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0),
    targetOffset = CFrame.new(-0.5, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0),
}

local leftShoulderMapping = {
    targetPart0Name = "Torso",
    targetPart1Name = "Left Arm",
    sourcePart0Name = "UpperTorso",
    sourcePart1Name = "LeftUpperArm",
    sourceJointNames = { "LeftShoulder" },
    sourceOffset = CFrame.new(-1, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
    targetOffset = CFrame.new(0.5, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
}

local rightHipMapping = {
    targetPart0Name = "Torso",
    targetPart1Name = "Right Leg",
    sourcePart0Name = "UpperTorso",
    sourcePart1Name = "RightUpperLeg",
    sourceJointNames = { "RightHip" },
    sourceOffset = CFrame.new(1, -1, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0),
    targetOffset = CFrame.new(0.5, 1, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0),
}

local leftHipMapping = {
    targetPart0Name = "Torso",
    targetPart1Name = "Left Leg",
    sourcePart0Name = "UpperTorso",
    sourcePart1Name = "LeftUpperLeg",
    sourceJointNames = { "LeftHip" },
    sourceOffset = CFrame.new(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
    targetOffset = CFrame.new(-0.5, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
}

r6ToR15JointMappings[1] = rootJointMapping
r6ToR15JointMappings[2] = neckJointMapping
r6ToR15JointMappings[3] = rightShoulderMapping
r6ToR15JointMappings[4] = leftShoulderMapping
r6ToR15JointMappings[5] = rightHipMapping
r6ToR15JointMappings[6] = leftHipMapping
local visualModelState = {
    model = nil,
    character = nil,
    jointMappings = {},
    folder = nil,
    renderConnection = nil,
    physicsConnection = nil,
    cameraTransparencyConnection = nil,
    cameraTransparencyRemovingConnection = nil,
    descendantConnection = nil,
    hideCharacterAddedConnection = nil,
    hideCharacterRemovingConnection = nil,
    localAnimator = nil,
    localAnimationFolder = nil,
    localAnimationTracks = {},
    localCurrentAnimation = nil,
    localCurrentTrack = nil,
    localAnimationPlaying = false,
    localAnimationConnection = nil,
}

local localAnimationPriorities = {
    idle = Enum.AnimationPriority.Idle,
    walk = Enum.AnimationPriority.Movement,
    run = Enum.AnimationPriority.Movement,
    jump = Enum.AnimationPriority.Movement,
    fall = Enum.AnimationPriority.Movement,
    climb = Enum.AnimationPriority.Movement,
    swim = Enum.AnimationPriority.Movement,
}

local localAnimationFallbacks = {
    idle = { "idle" },
    walk = { "walk", "run" },
    run = { "run", "walk" },
    jump = { "jump", "fall" },
    fall = { "fall", "jump" },
    climb = { "climb", "walk" },
    swim = { "swim", "walk" },
}

local function stopLocalSkinAnimations()
    if visualModelState.localAnimationConnection then
        visualModelState.localAnimationConnection:Disconnect()
        visualModelState.localAnimationConnection = nil
    end

    for _, tracks in pairs(visualModelState.localAnimationTracks) do
        for _, track in ipairs(tracks) do
            pcall(function()
                track:Stop(0.12)
                track:Destroy()
            end)
        end
    end

    if visualModelState.localAnimationFolder then
        pcall(function()
            visualModelState.localAnimationFolder:Destroy()
        end)
    end

    visualModelState.localAnimationFolder = nil
    visualModelState.localAnimationTracks = {}
    visualModelState.localCurrentAnimation = nil
    visualModelState.localCurrentTrack = nil
    visualModelState.localAnimationPlaying = false
end

local function setLocalSkinAnimation(stateName)
    local requestedStates = localAnimationFallbacks[stateName]
    if not requestedStates then
        requestedStates = { stateName }
    end

    local selectedTrack = nil
    local selectedState = nil

    for _, candidateState in ipairs(requestedStates) do
        local tracks = visualModelState.localAnimationTracks[candidateState]
        if tracks and #tracks > 0 then
            selectedState = candidateState
            selectedTrack = tracks[math.random(1, #tracks)]
            break
        end
    end

    if not selectedTrack then
        if visualModelState.localCurrentTrack then
            pcall(function()
                visualModelState.localCurrentTrack:Stop(0.12)
            end)
        end
        visualModelState.localCurrentAnimation = nil
        visualModelState.localCurrentTrack = nil
        visualModelState.localAnimationPlaying = false
        return false
    end

    if visualModelState.localCurrentTrack == selectedTrack
        and visualModelState.localCurrentAnimation == selectedState
        and selectedTrack.IsPlaying then
        visualModelState.localAnimationPlaying = true
        return true
    end

    if visualModelState.localCurrentTrack then
        pcall(function()
            visualModelState.localCurrentTrack:Stop(0.12)
        end)
    end

    local ok = pcall(function()
        selectedTrack:Play(0.12, 1, 1)
    end)

    if not ok then
        visualModelState.localCurrentAnimation = nil
        visualModelState.localCurrentTrack = nil
        visualModelState.localAnimationPlaying = false
        return false
    end

    visualModelState.localCurrentAnimation = selectedState
    visualModelState.localCurrentTrack = selectedTrack
    visualModelState.localAnimationPlaying = true
    return true
end

local function getLocalSkinAnimationState()
    local character = visualModelState.character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")

    if not humanoid or humanoid.Health <= 0 then
        return nil
    end

    local state = humanoid:GetState()

    if state == Enum.HumanoidStateType.Swimming then
        return "swim"
    end

    if state == Enum.HumanoidStateType.Climbing then
        return "climb"
    end

    if state == Enum.HumanoidStateType.Jumping then
        return "jump"
    end

    if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.FallingDown then
        return "fall"
    end

    if state == Enum.HumanoidStateType.Seated
        or state == Enum.HumanoidStateType.PlatformStanding
        or state == Enum.HumanoidStateType.Dead then
        return nil
    end

    local velocity = rootPart and rootPart.AssemblyLinearVelocity or Vector3.zero
    local horizontalSpeed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
    local moving = humanoid.MoveDirection.Magnitude > 0.05 or horizontalSpeed > 0.8

    if humanoid.FloorMaterial == Enum.Material.Air then
        return velocity.Y < -1 and "fall" or "jump"
    end

    if moving then
        return horizontalSpeed >= 18 and "run" or "walk"
    end

    return "idle"
end

local function applyCopiedSkinAnimations(character, enabled)
    if not character or not character.Parent then
        return false
    end

    if not enabled then
        stopLocalSkinAnimations()
        return true
    end

    local visualModel = visualModelState.model
    local animator = visualModelState.localAnimator
    if not (visualModel and visualModel.Parent and animator and type(copiedSkinAnimationData) == "table") then
        return false
    end

    stopLocalSkinAnimations()

    local animationFolder = Instance.new("Folder")
    animationFolder.Name = "LocalSkinAnimations"
    animationFolder.Parent = visualModel
    visualModelState.localAnimationFolder = animationFolder

    local loadedTrackCount = 0

    for stateName, templates in pairs(copiedSkinAnimationData) do
        local normalizedState = string.lower(tostring(stateName))
        local priority = localAnimationPriorities[normalizedState]

        if priority and type(templates) == "table" then
            local stateTracks = {}

            for _, template in ipairs(templates) do
                if typeof(template) == "Instance" and template:IsA("Animation")
                    and template.AnimationId ~= "" then
                    local animation = template:Clone()
                    animation.Parent = animationFolder

                    local ok, track = pcall(function()
                        return animator:LoadAnimation(animation)
                    end)

                    if ok and track then
                        track.Priority = priority
                        track.Looped = normalizedState ~= "jump"
                        table.insert(stateTracks, track)
                        loadedTrackCount += 1
                    else
                        animation:Destroy()
                    end
                end
            end

            if #stateTracks > 0 then
                visualModelState.localAnimationTracks[normalizedState] = stateTracks
            end
        end
    end

    if loadedTrackCount == 0 then
        stopLocalSkinAnimations()
        return false
    end

    visualModelState.localAnimationConnection = RunService.Heartbeat:Connect(function()
        if visualModelState.model ~= visualModel or not visualModel.Parent then
            stopLocalSkinAnimations()
            return
        end

        local requestedState = getLocalSkinAnimationState()
        if requestedState then
            setLocalSkinAnimation(requestedState)
        else
            setLocalSkinAnimation(nil)
        end
    end)

    local initialState = getLocalSkinAnimationState()
    if initialState then
        setLocalSkinAnimation(initialState)
    end

    return true
end

local function indexCharacterJoints(character)
    local jointsByName = {}

    for _, descendant in ipairs(character:GetDescendants()) do

        local insideAccessory = descendant:FindFirstAncestorOfClass("Accessory") ~= nil
        if not insideAccessory
            and (descendant:IsA("Motor6D") or descendant:IsA("AnimationConstraint"))
            and not jointsByName[descendant.Name] then
            jointsByName[descendant.Name] = descendant
        end
    end

    return jointsByName
end

local function getJointRotations(joint)
    if joint:IsA("Motor6D") then
        return joint.C0.Rotation, joint.C1.Rotation
    end
    local attachment0 = joint.Attachment0
    local attachment1 = joint.Attachment1
    return attachment0 and attachment0.CFrame.Rotation or CFrame.identity, attachment1 and attachment1.CFrame.Rotation or CFrame.identity
end

local function createJointMapping(sourcePart, targetPart, sourceOffset, targetOffset, sourceJoints)
    local sourceRotationOffset = CFrame.identity
    local targetRotationOffset = CFrame.identity

    if #sourceJoints > 0 then
        local firstSourceJointRotation = getJointRotations(sourceJoints[1])
        local _unusedSourceRotation, lastSourceJointRotation = getJointRotations(sourceJoints[#sourceJoints])
        sourceRotationOffset = sourceOffset.Rotation:Inverse() * firstSourceJointRotation
        local targetPartRotation = targetOffset.Rotation
        targetRotationOffset = lastSourceJointRotation:Inverse() * targetPartRotation
    end

    return { sourcePart = sourcePart, targetPart = targetPart, sourceOffset = sourceOffset, targetOffset = targetOffset, sourceJoints = sourceJoints, sourceRotationOffset = sourceRotationOffset, targetRotationOffset = targetRotationOffset }
end

local function buildJointMappings(character, targetModel, visualRootPart, targetRig)
    local sourceJointMap = indexCharacterJoints(character)
    local jointMappings = {}
    local targetBodyParts = {}

    for _, child in ipairs(targetModel:GetChildren()) do
        if child:IsA("BasePart") then
            table.insert(targetBodyParts, child)
        end
    end

    if targetRig == "R6" then
        for _, jointDefinition in ipairs(r6ToR15JointMappings) do
            local targetPart0 = targetModel:FindFirstChild(jointDefinition.targetPart0Name)
            local targetPart1 = targetModel:FindFirstChild(jointDefinition.targetPart1Name)

            if targetPart0 and targetPart1 then
                local matchingSourceJoints = {}

                for _, sourceJointName in ipairs(jointDefinition.sourceJointNames) do
                    if sourceJointMap[sourceJointName] then
                        table.insert(matchingSourceJoints, sourceJointMap[sourceJointName])
                    end
                end

                local jointMapping = createJointMapping(targetPart0, targetPart1, jointDefinition.sourceOffset, jointDefinition.targetOffset, matchingSourceJoints)
                local sourcePart0 = character:FindFirstChild(jointDefinition.sourcePart0Name)
                local sourcePart1 = character:FindFirstChild(jointDefinition.sourcePart1Name)
                jointMapping.sourceBodyPart0 = sourcePart0
                jointMapping.sourceBodyPart1 = sourcePart1
                table.insert(jointMappings, jointMapping)
            end
        end
    else
        local visitedTargetParts = { [visualRootPart] = true }
        local pendingTargetParts = { visualRootPart }

        while #pendingTargetParts > 0 do
            local currentTargetPart = table.remove(pendingTargetParts, 1)

            for _, child in ipairs(currentTargetPart:GetChildren()) do
                if child:IsA("Attachment") and child.Name:match("RigAttachment$") then
                    for _, targetBodyPart in ipairs(targetBodyParts) do
                        if not visitedTargetParts[targetBodyPart] then
                            local matchingAttachment = targetBodyPart:FindFirstChild(child.Name)

                            if matchingAttachment and matchingAttachment:IsA("Attachment") then
                                visitedTargetParts[targetBodyPart] = true
                                local matchingSourceJoint = sourceJointMap[child.Name:gsub("RigAttachment$", "")]
                                table.insert(jointMappings, createJointMapping(currentTargetPart, targetBodyPart, child.CFrame, matchingAttachment.CFrame, matchingSourceJoint and { matchingSourceJoint } or {}))
                                table.insert(pendingTargetParts, targetBodyPart)
                            end
                        end
                    end
                end
            end
        end
    end

    for _, child in ipairs(targetModel:GetChildren()) do
        if child:IsA("Accessory") then
            local handle = child:FindFirstChild("Handle")
            local matchedHandleAttachment = nil
            local matchedBodyPart = nil
            local matchedBodyAttachment = nil

            if handle and handle:IsA("BasePart") then

                for _, attachment in ipairs(handle:GetChildren()) do
                    if attachment:IsA("Attachment") then
                        for _, bodyPart in ipairs(targetBodyParts) do
                            local bodyAttachment = bodyPart:FindFirstChild(attachment.Name)
                            if bodyAttachment and bodyAttachment:IsA("Attachment") then
                                matchedHandleAttachment = attachment
                                matchedBodyPart = bodyPart
                                matchedBodyAttachment = bodyAttachment
                                break
                            end
                        end
                    end
                    if matchedHandleAttachment then
                        break
                    end
                end
            end

            if matchedHandleAttachment and matchedBodyPart and matchedBodyAttachment then
                table.insert(jointMappings, createJointMapping(
                    matchedBodyPart,
                    handle,
                    matchedBodyAttachment.CFrame,
                    matchedHandleAttachment.CFrame,
                    {}
                ))

                for _, accessoryPart in ipairs(child:GetDescendants()) do
                    if accessoryPart:IsA("BasePart") and accessoryPart ~= handle then
                        local relativeCFrame = handle.CFrame:ToObjectSpace(accessoryPart.CFrame)
                        table.insert(jointMappings, {
                            sourcePart = handle,
                            targetPart = accessoryPart,
                            sourceOffset = relativeCFrame,
                            targetOffset = CFrame.identity,
                            sourceJoints = {},
                            sourceRotationOffset = CFrame.identity,
                            targetRotationOffset = CFrame.identity,
                        })
                    end
                end
            end
        end
    end

    return jointMappings
end

local function getSkinVisualFolder()
    local currentCamera = workspace.CurrentCamera
    if not currentCamera then
        return nil
    end
    local visualFolder = currentCamera:FindFirstChild("AvatarSkinVisuals")

    if not visualFolder then
        local folder = Instance.new("Folder")
        folder.Name = "AvatarSkinVisuals"
        folder.Parent = currentCamera
        visualFolder = folder
    end

    return visualFolder
end

local hiddenCharacterEffectStates = setmetatable({}, { __mode = "k" })

local function isNativeVisualEffect(instance)
    return instance:IsA("ParticleEmitter")
        or instance:IsA("Trail")
        or instance:IsA("Beam")
        or instance:IsA("Fire")
        or instance:IsA("Smoke")
        or instance:IsA("Sparkles")
        or instance:IsA("Light")
        or instance:IsA("BillboardGui")
        or instance:IsA("SurfaceGui")
end

local function enableCopiedAppearanceEffect(model, instance)
    if not (model and instance and instance.Parent and isNativeVisualEffect(instance)) then
        return false
    end
    if instance:FindFirstAncestorOfClass("Tool") then return false end
    local ok, enabled = pcall(function() return instance.Enabled end)
    if not ok or enabled then return false end
    return pcall(function() instance.Enabled = true end)
end


local hiddenCharacterModel = nil
local hiddenCharacterInstances = {}
local hiddenCharacterTracked = setmetatable({}, { __mode = "k" })

local function restoreHiddenCharacterInstance(descendant)
    if not descendant then return end
    pcall(function()
        local originalTransparency = descendant:GetAttribute("AvatarSkinOriginalTransparency")
        if originalTransparency ~= nil then
            descendant.Transparency = originalTransparency
            descendant:SetAttribute("AvatarSkinOriginalTransparency", nil)
        end
        local saved = hiddenCharacterEffectStates[descendant]
        if saved then
            descendant.Enabled = saved.enabled
            hiddenCharacterEffectStates[descendant] = nil
        end
    end)
    hiddenCharacterTracked[descendant] = nil
    for index = #hiddenCharacterInstances, 1, -1 do
        if hiddenCharacterInstances[index] == descendant then
            table.remove(hiddenCharacterInstances, index)
            break
        end
    end
end

local function trackHiddenCharacterInstance(descendant)
    if not descendant or not descendant.Parent or hiddenCharacterTracked[descendant]
        or descendant:FindFirstAncestorOfClass("Tool") then return end
    local isBodyVisual = (descendant:IsA("BasePart") and descendant.Name ~= "HumanoidRootPart")
        or descendant:IsA("Decal")
    local isEffect = isNativeVisualEffect(descendant)
    if not isBodyVisual and not isEffect then return end
    hiddenCharacterTracked[descendant] = true
    table.insert(hiddenCharacterInstances, descendant)
    if isBodyVisual then
        if descendant:GetAttribute("AvatarSkinOriginalTransparency") == nil then
            descendant:SetAttribute("AvatarSkinOriginalTransparency", descendant.Transparency)
        end
        if descendant.Transparency < 1 then descendant.Transparency = 1 end
    else
        if hiddenCharacterEffectStates[descendant] == nil then
            hiddenCharacterEffectStates[descendant] = { enabled = descendant.Enabled }
        end
        if descendant.Enabled then descendant.Enabled = false end
        if descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") then
            pcall(function() descendant:Clear() end)
        end
    end
end

local function enforceHiddenCharacter()
    local character = hiddenCharacterModel
    if not character then return end
    for index = #hiddenCharacterInstances, 1, -1 do
        local descendant = hiddenCharacterInstances[index]
        if not descendant.Parent or not descendant:IsDescendantOf(character)
            or descendant:FindFirstAncestorOfClass("Tool") then
            restoreHiddenCharacterInstance(descendant)
        elseif descendant:GetAttribute("AvatarSkinOriginalTransparency") ~= nil then
            if descendant.Transparency < 1 then descendant.Transparency = 1 end
        else
            local saved = hiddenCharacterEffectStates[descendant]
            if saved and descendant.Enabled then descendant.Enabled = false end
        end
    end
end

local function setOriginalCharacterHidden(character, shouldHide)
    if shouldHide then
        if hiddenCharacterModel ~= character then
            if hiddenCharacterModel then setOriginalCharacterHidden(hiddenCharacterModel, false) end
            hiddenCharacterModel = character
            table.clear(hiddenCharacterInstances)
            hiddenCharacterTracked = setmetatable({}, { __mode = "k" })
            for _, descendant in ipairs(character:GetDescendants()) do trackHiddenCharacterInstance(descendant) end
            if visualModelState.hideCharacterAddedConnection then
                visualModelState.hideCharacterAddedConnection:Disconnect()
                visualModelState.hideCharacterAddedConnection = nil
            end
            if visualModelState.hideCharacterRemovingConnection then
                visualModelState.hideCharacterRemovingConnection:Disconnect()
                visualModelState.hideCharacterRemovingConnection = nil
            end
            visualModelState.hideCharacterAddedConnection = character.DescendantAdded:Connect(trackHiddenCharacterInstance)
            visualModelState.hideCharacterRemovingConnection = character.DescendantRemoving:Connect(function()
                task.defer(function()
                    if hiddenCharacterModel ~= character then return end
                    for index = #hiddenCharacterInstances, 1, -1 do
                        local descendant = hiddenCharacterInstances[index]
                        if not descendant:IsDescendantOf(character)
                            or descendant:FindFirstAncestorOfClass("Tool") then
                            restoreHiddenCharacterInstance(descendant)
                        end
                    end
                end)
            end)
        end
        enforceHiddenCharacter()
        return
    end
    if hiddenCharacterModel ~= character then return end
    if visualModelState.hideCharacterAddedConnection then
        visualModelState.hideCharacterAddedConnection:Disconnect()
        visualModelState.hideCharacterAddedConnection = nil
    end
    if visualModelState.hideCharacterRemovingConnection then
        visualModelState.hideCharacterRemovingConnection:Disconnect()
        visualModelState.hideCharacterRemovingConnection = nil
    end
    for index = #hiddenCharacterInstances, 1, -1 do
        restoreHiddenCharacterInstance(hiddenCharacterInstances[index])
    end
    table.clear(hiddenCharacterInstances)
    hiddenCharacterModel = nil
end


local function createNativeCameraTransparencyUpdater(character, visualModel)
    local visualEntries = {}
    local trackedInstances = setmetatable({}, { __mode = "k" })
    local lastTransparency = nil
    local lastUpdate = os.clock()
    local lastPrune = lastUpdate
    local MAX_TWEEN_RATE = 2.8

    local function isInsideTool(instance)
        local ancestor = instance.Parent
        while ancestor and ancestor ~= visualModel do
            if ancestor:IsA("Tool") then return true end
            ancestor = ancestor.Parent
        end
        return false
    end

    local function restoreEntry(entry)
        local instance = entry.instance
        pcall(function()
            if entry.kind == "nativeModifier" then
                instance.LocalTransparencyModifier = entry.originalLocalTransparencyModifier or 0
            elseif entry.kind == "decalTransparency" then
                instance.Transparency = entry.originalTransparency or 0
            elseif entry.kind == "sequenceEffect" then
                instance.Transparency = entry.originalTransparency
                instance.Enabled = entry.originalEnabled
            elseif entry.kind == "enabledEffect" then
                instance.Enabled = entry.originalEnabled
            end
        end)
    end

    local function untrack(instance)
        if not trackedInstances[instance] then return end
        for index = #visualEntries, 1, -1 do
            if visualEntries[index].instance == instance then
                restoreEntry(visualEntries[index])
                table.remove(visualEntries, index)
                break
            end
        end
        trackedInstances[instance] = nil
    end

    local function trackVisual(instance)
        if trackedInstances[instance] or isInsideTool(instance) then return end
        enableCopiedAppearanceEffect(visualModel, instance)
        local entry = { instance = instance }
        if instance:IsA("BasePart") or instance:IsA("Decal") or instance:IsA("Texture") then
            local ok, originalModifier = pcall(function() return instance.LocalTransparencyModifier end)
            if ok then
                entry.kind = "nativeModifier"
                entry.originalLocalTransparencyModifier = originalModifier
            elseif instance:IsA("Decal") or instance:IsA("Texture") then
                entry.kind = "decalTransparency"
                entry.originalTransparency = instance.Transparency
            else
                return
            end
        elseif instance:IsA("ParticleEmitter") or instance:IsA("Trail") or instance:IsA("Beam") then
            entry.kind = "sequenceEffect"
            entry.originalEnabled = instance.Enabled
            entry.originalTransparency = instance.Transparency
        elseif instance:IsA("Fire") or instance:IsA("Smoke") or instance:IsA("Sparkles")
            or instance:IsA("Light") or instance:IsA("BillboardGui") or instance:IsA("SurfaceGui") then
            local ok, enabled = pcall(function() return instance.Enabled end)
            if not ok then return end
            entry.kind = "enabledEffect"
            entry.originalEnabled = enabled
        else
            return
        end
        trackedInstances[instance] = true
        table.insert(visualEntries, entry)
    end

    for _, descendant in ipairs(visualModel:GetDescendants()) do trackVisual(descendant) end

    local function getTargetTransparency()
        local camera = Workspace.CurrentCamera
        local targetTransparency = 0
        if camera then
            if localPlayer.CameraMode == Enum.CameraMode.LockFirstPerson then
                targetTransparency = 1
            else
                local distance = (camera.Focus.Position - camera.CFrame.Position).Magnitude
                if distance >= 2 then
                    local reference = visualModel:FindFirstChild("Head")
                        or character:FindFirstChild("Head")
                        or visualModel:FindFirstChild("HumanoidRootPart")
                    if reference and reference:IsA("BasePart") then
                        local lookVector = camera.CFrame.LookVector
                        local toReference = reference.Position - camera.CFrame.Position
                        local forwardDistance = toReference:Dot(lookVector)
                        local lateralDistance = (toReference - lookVector * forwardDistance).Magnitude
                        if forwardDistance > 0 and lateralDistance <= 2.5 then
                            distance = math.min(distance, forwardDistance)
                        end
                    end
                end
                if distance < 2 then targetTransparency = 1 - (distance - 0.5) / 1.5 end
                if targetTransparency < 0.5 then targetTransparency = 0 end
            end
        end
        targetTransparency = math.clamp(targetTransparency, 0, 1)
        local now = os.clock()
        local deltaTime = math.max(0, now - lastUpdate)
        lastUpdate = now
        if lastTransparency ~= nil and targetTransparency < 1 and lastTransparency < 0.95 then
            local maxDelta = MAX_TWEEN_RATE * deltaTime
            local deltaTransparency = math.clamp(
                targetTransparency - lastTransparency, -maxDelta, maxDelta
            )
            targetTransparency = lastTransparency + deltaTransparency
        end
        targetTransparency = math.clamp(math.floor(targetTransparency * 100 + 0.5) / 100, 0, 1)
        lastTransparency = targetTransparency
        return targetTransparency
    end

    local function applyVisual(entry, nativeTransparency)
        local instance = entry.instance
        if not instance.Parent or not instance:IsDescendantOf(visualModel) or isInsideTool(instance) then return end
        local fullyFirstPerson = nativeTransparency >= 0.995
        if entry.kind == "nativeModifier" then
            local desired = math.max(entry.originalLocalTransparencyModifier or 0, nativeTransparency)
            if entry.lastAppliedModifier ~= desired then
                local ok = pcall(function() instance.LocalTransparencyModifier = desired end)
                if ok then entry.lastAppliedModifier = desired end
            end
        elseif entry.kind == "decalTransparency" then
            local original = entry.originalTransparency or 0
            local desired = 1 - ((1 - original) * (1 - nativeTransparency))
            if entry.lastAppliedTransparency ~= desired then
                pcall(function() instance.Transparency = desired end)
                entry.lastAppliedTransparency = desired
            end
        elseif entry.kind == "sequenceEffect" then
            if entry.appliedHidden ~= fullyFirstPerson then
                if fullyFirstPerson then
                    pcall(function()
                        instance.Enabled = false
                        instance.Transparency = NumberSequence.new(1)
                    end)
                    if instance:IsA("ParticleEmitter") or instance:IsA("Trail") then
                        pcall(function() instance:Clear() end)
                    end
                else
                    pcall(function()
                        instance.Transparency = entry.originalTransparency
                        instance.Enabled = entry.originalEnabled
                    end)
                end
                entry.appliedHidden = fullyFirstPerson
            end
        elseif entry.kind == "enabledEffect" and entry.appliedHidden ~= fullyFirstPerson then
            pcall(function()
                if fullyFirstPerson then
                    instance.Enabled = false
                else
                    instance.Enabled = entry.originalEnabled
                end
            end)
            entry.appliedHidden = fullyFirstPerson
        end
    end

    local function update()
        if not (character.Parent and visualModel.Parent) then return false end
        local nativeTransparency = getTargetTransparency()
        local fullyFirstPerson = nativeTransparency >= 0.995
        local now = os.clock()
        if now - lastPrune >= 2 then
            lastPrune = now
            for index = #visualEntries, 1, -1 do
                local entry = visualEntries[index]
                local instance = entry.instance
                if not instance:IsDescendantOf(visualModel) or isInsideTool(instance) then
                    restoreEntry(entry)
                    trackedInstances[instance] = nil
                    table.remove(visualEntries, index)
                end
            end
        end
        for _, entry in ipairs(visualEntries) do applyVisual(entry, nativeTransparency) end
        return fullyFirstPerson
    end

    local descendantConnection = visualModel.DescendantAdded:Connect(trackVisual)
    local descendantRemovingConnection = visualModel.DescendantRemoving:Connect(function(descendant)
        if not trackedInstances[descendant] then return end
        task.defer(function()
            if trackedInstances[descendant]
                and (not descendant:IsDescendantOf(visualModel) or isInsideTool(descendant)) then
                untrack(descendant)
            end
        end)
    end)
    update()
    return update, descendantConnection, descendantRemovingConnection
end

local function destroySkinVisuals()
    stopLocalSkinAnimations()
    visualModelState.localAnimator = nil

    if visualModelState.renderConnection then
        visualModelState.renderConnection:Disconnect()
        visualModelState.renderConnection = nil
    end

    if visualModelState.physicsConnection then
        visualModelState.physicsConnection:Disconnect()
        visualModelState.physicsConnection = nil
    end

    if visualModelState.cameraTransparencyConnection then
        visualModelState.cameraTransparencyConnection:Disconnect()
        visualModelState.cameraTransparencyConnection = nil
    end

    if visualModelState.cameraTransparencyRemovingConnection then
        visualModelState.cameraTransparencyRemovingConnection:Disconnect()
        visualModelState.cameraTransparencyRemovingConnection = nil
    end

    if visualModelState.descendantConnection then
        visualModelState.descendantConnection:Disconnect()
        visualModelState.descendantConnection = nil
    end

    if visualModelState.hideCharacterAddedConnection then
        visualModelState.hideCharacterAddedConnection:Disconnect()
        visualModelState.hideCharacterAddedConnection = nil
    end

    if visualModelState.hideCharacterRemovingConnection then
        visualModelState.hideCharacterRemovingConnection:Disconnect()
        visualModelState.hideCharacterRemovingConnection = nil
    end

    if visualModelState.model then
        visualModelState.model:Destroy()
        visualModelState.model = nil
    end
    if visualModelState.folder and visualModelState.folder.Parent and #visualModelState.folder:GetChildren() == 0 then
        pcall(function() visualModelState.folder:Destroy() end)
    end
    visualModelState.folder = nil

    visualModelState.jointMappings = {}

    if visualModelState.character then
        setOriginalCharacterHidden(visualModelState.character, false)
        visualModelState.character = nil
    end
end

local function getModelFootOffset(model, rootPart)
    local y = rootPart.Position.Y

    for _, child in ipairs(model:GetChildren()) do
        if child:IsA("BasePart") and child ~= rootPart then
            y = math.min(y, child.Position.Y - child.Size.Y / 2)
        end
    end

    return rootPart.Position.Y - y
end

local function updateJointMappings(sourceRoot, targetRoot, jointMappings, rootOffset)
    targetRoot.CFrame = sourceRoot.CFrame * rootOffset

    for _, mapping in ipairs(jointMappings) do
        if mapping.sourceBodyPart0 and mapping.sourceBodyPart1 then
            local rotation = mapping.sourceBodyPart1.CFrame.Rotation
            local relativeRotation = mapping.sourceBodyPart0.CFrame.Rotation:Inverse() * rotation
            local targetOffsetInverse = mapping.targetOffset
            mapping.targetPart.CFrame = mapping.sourcePart.CFrame * mapping.sourceOffset * mapping.sourceOffset.Rotation:Inverse() * relativeRotation * mapping.targetOffset.Rotation * targetOffsetInverse:Inverse()
        else
            local accumulatedRotation = mapping.sourceRotationOffset

            for _, src in ipairs(mapping.sourceJoints) do
                accumulatedRotation *= src.Transform
            end

            mapping.targetPart.CFrame = mapping.sourcePart.CFrame * mapping.sourceOffset * accumulatedRotation * mapping.targetRotationOffset * mapping.targetOffset:Inverse()
        end
    end
end

local function buildR15SkinVisual(character, visualModel)
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoidRootPart2 = visualModel:FindFirstChild("HumanoidRootPart")
    local visualFolder = getSkinVisualFolder()
    if not (humanoidRootPart and humanoidRootPart2 and visualFolder) then
        visualModel:Destroy()
        return false
    end
    local visualHumanoid = visualModel:FindFirstChildOfClass("Humanoid")
    character:FindFirstChildOfClass("Humanoid")
    local cframe = CFrame.new(0, (visualHumanoid and visualHumanoid.HipHeight > 0 and visualHumanoid.HipHeight + humanoidRootPart2.Size.Y / 2 or getModelFootOffset(visualModel, humanoidRootPart2)) - getModelFootOffset(character, humanoidRootPart), 0)
    local visualParts = {}

    local function configureVisualPart(part)
        local insideAccessory = part:FindFirstAncestorOfClass("Accessory") ~= nil
        local insideTool = part:FindFirstAncestorOfClass("Tool") ~= nil
        part.Anchored = not insideAccessory and not insideTool and part == humanoidRootPart2
        part.CanCollide = false
        part.CanTouch = false
        part.CanQuery = false
        part.Massless = true
        table.insert(visualParts, part)
    end

    for _, descendant in ipairs(visualModel:GetDescendants()) do
        if descendant:IsA("BaseScript") then
            descendant.Disabled = true
        elseif descendant:IsA("BasePart") then
            configureVisualPart(descendant)
        end
    end

    if visualHumanoid then
        visualHumanoid.PlatformStand = true
        visualHumanoid.AutoRotate = false
        visualHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

        pcall(function()
            visualHumanoid.EvaluateStateMachine = false
        end)

        local animator = visualHumanoid:FindFirstChildOfClass("Animator")

        if animator then
            animator:Destroy()
        end
    end

    visualModel.Name = "AvatarSkinVisuals_R15"
    visualModel.PrimaryPart = humanoidRootPart2
    visualModel:PivotTo(humanoidRootPart.CFrame * cframe)
    visualModel.Parent = visualFolder

    if visualHumanoid then
        local localAnimator = Instance.new("Animator")
        localAnimator.Name = "LocalVisualAnimator"
        localAnimator.Parent = visualHumanoid
        visualModelState.localAnimator = localAnimator
    end

    local characterJointMap = indexCharacterJoints(character)
    local jointMappings = {}

    local function configureVisualJoint(joint)

        if joint:FindFirstAncestorOfClass("Accessory") then
            return
        end

        if joint:IsA("BallSocketConstraint") then
            joint.Enabled = false
        elseif joint:IsA("AnimationConstraint") or joint:IsA("Motor6D") then
            pcall(function()
                joint.IsKinematic = true
            end)

            local sourceJoint = characterJointMap[joint.Name]

            if sourceJoint then
                table.insert(jointMappings, { sourceJoint = sourceJoint, targetJoint = joint })
            end
        end
    end

    for _, descendant in ipairs(visualModel:GetDescendants()) do
        configureVisualJoint(descendant)
    end

    if visualModelState.descendantConnection then visualModelState.descendantConnection:Disconnect() end
    visualModelState.descendantConnection = visualModel.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("BasePart") then
            configureVisualPart(descendant)
        else
            configureVisualJoint(descendant)
        end
    end)

    local characterVisualStateRef = visualModelState
    local jointMappingsVisualStateRef = visualModelState
    visualModelState.model = visualModel
    characterVisualStateRef.character = character
    jointMappingsVisualStateRef.jointMappings = jointMappings
    setOriginalCharacterHidden(character, true)

    local updateCameraTransparency, cameraDescendantConnection, cameraDescendantRemovingConnection =
        createNativeCameraTransparencyUpdater(character, visualModel)
    visualModelState.cameraTransparencyConnection = cameraDescendantConnection
    visualModelState.cameraTransparencyRemovingConnection = cameraDescendantRemovingConnection
    visualModelState.folder = visualFolder

    local function updateVisualPose()
        humanoidRootPart2.CFrame = humanoidRootPart.CFrame * cframe

        if not visualModelState.localAnimationPlaying then
            for _, jointMapping in ipairs(jointMappings) do
                if jointMapping.sourceJoint and jointMapping.sourceJoint.Parent and jointMapping.targetJoint and jointMapping.targetJoint.Parent then
                    pcall(function() jointMapping.targetJoint.Transform = jointMapping.sourceJoint.Transform end)
                end
            end
        end
    end

    visualModelState.physicsConnection = RunService.Stepped:Connect(function()
        if visualModelState.model ~= visualModel then
            return
        end
        for _, part in ipairs(visualParts) do
            if part.Parent then
                if part.CanCollide then part.CanCollide = false end
                if part.CanTouch then part.CanTouch = false end
            end
        end
        updateVisualPose()
    end)

    local hiddenCharacterRefreshElapsed = 0

    visualModelState.renderConnection = RunService.RenderStepped:Connect(function(deltaTime)
        if visualModelState.model ~= visualModel then
            return
        end
        local currentCamera = workspace.CurrentCamera
        if not visualFolder or visualFolder.Parent ~= currentCamera then
            local previousFolder = visualFolder
            visualFolder = getSkinVisualFolder()
            if previousFolder and previousFolder ~= visualFolder and previousFolder.Parent
                and #previousFolder:GetChildren() == 0 then
                pcall(function() previousFolder:Destroy() end)
            end
            visualModelState.folder = visualFolder
        end
        if not currentCamera then return end
        if visualFolder and visualModel.Parent ~= visualFolder then visualModel.Parent = visualFolder end
        updateVisualPose()
        updateCameraTransparency()
        hiddenCharacterRefreshElapsed += deltaTime

        if hiddenCharacterRefreshElapsed >= 0.5 then
            hiddenCharacterRefreshElapsed %= 0.5
            enforceHiddenCharacter()
        end
    end)

    return true
end

local function buildSkinVisual(character, visualModel)
    destroySkinVisuals()
    local visualRigName = visualModel:FindFirstChildOfClass("Humanoid")
    visualRigName = visualRigName and visualRigName.RigType == Enum.HumanoidRigType.R6 and "R6" or "R15"
    if visualRigName ~= "R6" then
        return buildR15SkinVisual(character, visualModel)
    end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoidRootPart2 = visualModel:FindFirstChild("HumanoidRootPart")
    local visualFolder = getSkinVisualFolder()
    if not (humanoidRootPart and humanoidRootPart2 and visualFolder) then
        visualModel:Destroy()
        return false
    end
    local visualHumanoid = visualModel:FindFirstChildOfClass("Humanoid")
    character:FindFirstChildOfClass("Humanoid")
    local r6FootOffset = visualRigName == "R6" and getModelFootOffset(visualModel, humanoidRootPart2)
    local visualHeightOffset

    if r6FootOffset then
        visualHeightOffset = r6FootOffset
    else
        visualHeightOffset = (visualHumanoid and visualHumanoid.HipHeight or 2) + humanoidRootPart2.Size.Y / 2
    end

    local cframe = CFrame.new(0, visualHeightOffset - getModelFootOffset(character, humanoidRootPart), 0)
    local visualParts = {}

    for _, descendant in ipairs(visualModel:GetDescendants()) do
        if descendant:IsA("BaseScript") then
            descendant.Disabled = true
        elseif descendant:IsA("BasePart") then
            descendant.Anchored = true
            descendant.CanCollide = false
            descendant.CanTouch = false
            descendant.CanQuery = false
            descendant.Massless = true
            table.insert(visualParts, descendant)
        elseif (descendant:IsA("JointInstance") or descendant:IsA("Constraint"))
            and not descendant:FindFirstAncestorOfClass("Accessory")
            and not descendant:FindFirstAncestorOfClass("Tool") then
            descendant:Destroy()
        end
    end

    if visualHumanoid then
        visualHumanoid.PlatformStand = true
        visualHumanoid.AutoRotate = false
        visualHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

        pcall(function()
            visualHumanoid.EvaluateStateMachine = false
        end)

        local animator = visualHumanoid:FindFirstChildOfClass("Animator")

        if animator then
            animator:Destroy()
        end
    end

    visualModel.Name = "AvatarSkinVisuals_" .. visualRigName
    visualModel.PrimaryPart = humanoidRootPart2
    local jointMappings = buildJointMappings(character, visualModel, humanoidRootPart2, visualRigName)
    updateJointMappings(humanoidRootPart, humanoidRootPart2, jointMappings, cframe)
    visualModel.Parent = visualFolder

    for _, descendant in ipairs(visualModel:GetDescendants()) do
        if (descendant:IsA("Constraint") or descendant:IsA("JointInstance"))
            and not descendant:FindFirstAncestorOfClass("Accessory")
            and not descendant:FindFirstAncestorOfClass("Tool") then
            descendant:Destroy()
        end
    end

    if visualModelState.descendantConnection then visualModelState.descendantConnection:Disconnect() end
    visualModelState.descendantConnection = visualModel.DescendantAdded:Connect(function(descendant)
        if (descendant:IsA("Constraint") or descendant:IsA("JointInstance"))
            and not descendant:FindFirstAncestorOfClass("Accessory")
            and not descendant:FindFirstAncestorOfClass("Tool") then
            task.defer(function()
                if descendant.Parent
                    and not descendant:FindFirstAncestorOfClass("Accessory")
                    and not descendant:FindFirstAncestorOfClass("Tool") then
                    descendant:Destroy()
                end
            end)
        elseif descendant:IsA("BasePart") then
            descendant.Anchored = true
            descendant.CanCollide = false
            descendant.CanTouch = false
            descendant.CanQuery = false
            descendant.Massless = true
            table.insert(visualParts, descendant)
        end
    end)

    local characterVisualStateRef = visualModelState
    local jointMappingsVisualStateRef = visualModelState
    visualModelState.model = visualModel
    characterVisualStateRef.character = character
    jointMappingsVisualStateRef.jointMappings = jointMappings
    setOriginalCharacterHidden(character, true)
    local updateCameraTransparency, cameraDescendantConnection, cameraDescendantRemovingConnection =
        createNativeCameraTransparencyUpdater(character, visualModel)
    visualModelState.cameraTransparencyConnection = cameraDescendantConnection
    visualModelState.cameraTransparencyRemovingConnection = cameraDescendantRemovingConnection
    visualModelState.folder = visualFolder

    visualModelState.physicsConnection = RunService.Stepped:Connect(function()
        if visualModelState.model ~= visualModel then return end
        for _, part in ipairs(visualParts) do
            if part.Parent then
                if part.CanCollide then part.CanCollide = false end
                if part.CanTouch then part.CanTouch = false end
            end
        end
    end)

    local hiddenCharacterRefreshElapsed = 0

    visualModelState.renderConnection = RunService.RenderStepped:Connect(function(deltaTime)
        if visualModelState.model ~= visualModel then
            return
        end
        local currentCamera = workspace.CurrentCamera
        if not visualFolder or visualFolder.Parent ~= currentCamera then
            local previousFolder = visualFolder
            visualFolder = getSkinVisualFolder()
            if previousFolder and previousFolder ~= visualFolder and previousFolder.Parent
                and #previousFolder:GetChildren() == 0 then
                pcall(function() previousFolder:Destroy() end)
            end
            visualModelState.folder = visualFolder
        end
        if not currentCamera then return end
        if visualFolder and visualModel.Parent ~= visualFolder then visualModel.Parent = visualFolder end
        updateJointMappings(humanoidRootPart, humanoidRootPart2, jointMappings, cframe)
        updateCameraTransparency()
        hiddenCharacterRefreshElapsed += deltaTime

        if hiddenCharacterRefreshElapsed >= 0.5 then
            hiddenCharacterRefreshElapsed %= 0.5
            enforceHiddenCharacter()
        end
    end)

    return true
end

local function attachSkinVisual(character, visualModel, _unused, rigName)
    if not character then
        return 0
    end
    local savedCharacterState = captureCharacterState(character)
    noopCharacterStateHook(character, savedCharacterState)
    local visualModelAttached = visualModel and buildSkinVisual(character, visualModel, rigName)
    if visualModel and not visualModelAttached then
        return nil
    end
    local attachedJointCount = 0

    if visualModelAttached then
        attachedJointCount = 0 + #visualModelState.jointMappings + 1
    end

    return attachedJointCount
end

local function restoreCharacterAppearance(character)
    if not character then
        return
    end
    destroySkinVisuals()
    local savedCharacterState = originalCharacterStateCache[character]
    if not savedCharacterState then
        return
    end
    noopCharacterStateHook(character, savedCharacterState)
end

local currentEmoteTrack = nil
local emoteMonitorConnection = nil

local function stopCurrentEmote()
    if currentEmoteTrack then
        pcall(currentEmoteTrack.Stop, currentEmoteTrack, 0.2)
        currentEmoteTrack = nil
    end

    if emoteMonitorConnection then
        emoteMonitorConnection:Disconnect()
        emoteMonitorConnection = nil
    end
end

local function findAnimationInAsset(assetId)
    local assetObjects = loadAssetObjects(assetId)
    local iterateAssetObjects = ipairs
    local assetObjectList = assetObjects or {}

    for _, assetObject in iterateAssetObjects(assetObjectList) do
        if assetObject:IsA("Animation") then
            return assetObject
        end

        for _, descendant in ipairs(assetObject:GetDescendants()) do
            if descendant:IsA("Animation") then
                return descendant
            end
        end
    end

    return nil
end

local function playEmote(emote)
    stopCurrentEmote()
    local character = getLocalCharacter()
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        return false
    end
    local humanoidDescription = getCharacterHumanoidDescription(character)

    if humanoidDescription then
        local ok, result = pcall(humanoidDescription.GetEmotes, humanoidDescription)

        if ok and result[emote.nombre] then
            local ok2, result2 = pcall(humanoid.PlayEmote, humanoid, emote.nombre)
            if ok2 and result2 then
                return true
            end
        end
    end

    local animation = findAnimationInAsset(emote.id)
    if not animation then
        return false
    end
    local ok, result = pcall(animator.LoadAnimation, animator, animation)
    if not (ok and result) then
        return false
    end
    result.Priority = Enum.AnimationPriority.Action
    result.Looped = true
    result:Play(0.2)
    currentEmoteTrack = result

    emoteMonitorConnection = RunService.Heartbeat:Connect(function()
        if not (humanoid.Parent and currentEmoteTrack == result) then
            stopCurrentEmote()
            return
        end
        local isMoving = humanoid.MoveDirection.Magnitude > 0

        if not isMoving then
            local jumping = Enum.HumanoidStateType.Jumping
            isMoving = humanoid:GetState() == jumping
        end

        if not isMoving then
            local freefall = Enum.HumanoidStateType.Freefall
            isMoving = humanoid:GetState() == freefall
        end

        if isMoving then
            stopCurrentEmote()
        end
    end)

    return true
end

local guiParent = nil

if gethui then
    local ok, result = pcall(gethui)
    guiParent = ok and result or nil
end

guiParent = guiParent or CoreGui
local function removeOldGui(root, name)
    if root then
        local existing = root:FindFirstChild(name)
        if existing then
            existing:Destroy()
        end
    end
end

removeOldGui(guiParent, "avatar-skins")
local playerGui = localPlayer:FindFirstChild("PlayerGui")
removeOldGui(playerGui, "avatar-skins")

loadConfiguration()
task.spawn(getLocalPlayerEmoteData)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "avatar-skins"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 2147483647
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if not pcall(function()
    screenGui.Parent = guiParent
end) then
    screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
end

local function loadBackgroundAsset()
    local url = "https://raw.githubusercontent.com/Silent-lua/Dev/main/assets/avatar-background.png"
    local path = "avatar-tools/avatar-background.png"
    pcall(function()
        if type(isfolder) == "function" and type(makefolder) == "function" and not isfolder("avatar-tools") then
            makefolder("avatar-tools")
        end
    end)
    local exists = false
    pcall(function()
        if type(isfile) == "function" then exists = isfile(path) end
    end)
    if not exists and type(writefile) == "function" then
        local ok, data = pcall(function() return game:HttpGet(url) end)
        if ok and type(data) == "string" and #data > 0 then
            pcall(function() writefile(path, data) end)
        end
    end
    if type(getcustomasset) == "function" then
        local ok, asset = pcall(getcustomasset, path)
        if ok and type(asset) == "string" then return asset end
    end
    return nil
end

local bgAsset = loadBackgroundAsset()
local mainFrame = createGuiInstance("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(590, 274),
    BackgroundColor3 = COLORS.Background,
    BorderSizePixel = 0,
    Active = true,
    ClipsDescendants = true,
}, screenGui, 16)

createGuiInstance("UIStroke", { Color = COLORS.Border, Thickness = 1, Transparency = 0.2 }, mainFrame)
local uiGradient = Instance.new("UIGradient")
uiGradient.Color = ColorSequence.new(COLORS.BackgroundAlt, COLORS.Background)
uiGradient.Rotation = 90
uiGradient.Parent = mainFrame

local backgroundImage = Instance.new("ImageLabel")
backgroundImage.Name = "ReferenceBackground"
backgroundImage.Size = UDim2.fromScale(1, 1)
backgroundImage.BackgroundTransparency = 1
backgroundImage.Image = bgAsset or ""
backgroundImage.ImageTransparency = bgAsset and 0 or 1
backgroundImage.ScaleType = Enum.ScaleType.Fit
backgroundImage.ZIndex = 1
backgroundImage.Parent = mainFrame
createGuiInstance("UICorner", { CornerRadius = UDim.new(0, 16) }, backgroundImage)
local backgroundTween
local function animateBackground()
    if not bgAsset or not backgroundImage.Parent then return end
    if backgroundTween then backgroundTween:Cancel() end
    backgroundImage.Position = UDim2.fromScale(-0.018, -0.014)
    backgroundImage.Size = UDim2.fromScale(1.036, 1.028)
    backgroundImage.ImageTransparency = 0.18
    backgroundTween = TweenService:Create(
        backgroundImage,
        TweenInfo.new(0.95, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        {
            Position = UDim2.fromScale(-0.004, -0.003),
            Size = UDim2.fromScale(1.008, 1.006),
            ImageTransparency = 0,
        }
    )
    backgroundTween:Play()
end
createGuiInstance("Frame", {
    Name = "ReferenceBackgroundOverlay",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 1,
}, mainFrame)

createGuiInstance("TextButton", {
    Text = "",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    AutoButtonColor = false,
    Active = true,
    Selectable = false,
    ZIndex = 0,
}, mainFrame)

local uiScale = Instance.new("UIScale")
uiScale.Parent = mainFrame
local flag = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local function getViewportSize()
    local camera = Workspace.CurrentCamera
    return camera and camera.ViewportSize or Vector2.new(1280, 720)
end

local function getGuiCenter(guiObject)
    local viewport = getViewportSize()
    local position = guiObject.Position
    local anchorPoint = guiObject.AnchorPoint
    local size = guiObject.AbsoluteSize
    local anchorPosition = Vector2.new(
        position.X.Scale * viewport.X + position.X.Offset,
        position.Y.Scale * viewport.Y + position.Y.Offset
    )
    return anchorPosition + Vector2.new(
        (0.5 - anchorPoint.X) * size.X,
        (0.5 - anchorPoint.Y) * size.Y
    )
end

local function clampGuiCenter(guiObject, position)
    local viewport = getViewportSize()
    local halfSize = Vector2.new(
        guiObject.AbsoluteSize.X * 0.5 + 2,
        guiObject.AbsoluteSize.Y * 0.5 + 2
    )
    local maxX, maxY = viewport.X - halfSize.X, viewport.Y - halfSize.Y
    if maxX < halfSize.X or maxY < halfSize.Y then
        return Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
    end
    return Vector2.new(
        math.clamp(position.X, halfSize.X, maxX),
        math.clamp(position.Y, halfSize.Y, maxY)
    )
end

local function setGuiCenter(guiObject, position)
    local target = clampGuiCenter(guiObject, position)
    local anchorPoint = guiObject.AnchorPoint
    local size = guiObject.AbsoluteSize
    local anchorPosition = target - Vector2.new(
        (0.5 - anchorPoint.X) * size.X,
        (0.5 - anchorPoint.Y) * size.Y
    )
    guiObject.Position = UDim2.fromOffset(anchorPosition.X, anchorPosition.Y)
    return target
end

local mainFrameCenter = getGuiCenter(mainFrame)

local function setMainFrameCenter(position)
    mainFrameCenter = setGuiCenter(mainFrame, position)
    return mainFrameCenter
end

local function keepFrameInsideViewport()
    if not mainFrame.Parent or not mainFrame.Visible then return end
    setMainFrameCenter(mainFrameCenter)
end

local function updateUiScale()
    local currentCamera = workspace.CurrentCamera
    currentCamera = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)
    local widthScaleRatio = 0.92
    local heightScaleRatio = 0.94

    if flag then
        widthScaleRatio = 0.78
        heightScaleRatio = 0.9
    end

    uiScale.Scale = math.clamp(math.min(currentCamera.X * heightScaleRatio / PANEL_WIDTH, currentCamera.Y * widthScaleRatio / PANEL_HEIGHT), 0.01, 1)
    task.defer(keepFrameInsideViewport)
end

updateUiScale()
local windowHeader = createGuiInstance("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 52) }, mainFrame)

local titleLabel = createGuiInstance("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(18, 15),
    Size = UDim2.fromOffset(166, 22),
    Font = Enum.Font.GothamBold,
    Text = "SilentHub",
    TextSize = 16,
    TextColor3 = COLORS.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
}, mainFrame)
local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(145, 145, 145)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(210, 210, 210)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(135, 135, 135)),
})
titleGradient.Rotation = 90
titleGradient.Parent = titleLabel
task.spawn(function()
    local offset = 0
    while titleLabel.Parent do
        offset = (offset + task.wait(0.04) * 0.35) % 1
        titleGradient.Offset = Vector2.new(offset * 2 - 1, 0)
    end
end)
createGuiInstance("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(19, 32),
    Size = UDim2.fromOffset(250, 12),
    Font = Enum.Font.Gotham,
    Text = "𝑩𝒚𝑺𝒊𝒍𝒆𝒏𝒕 script: 𝔖𝔦𝔩𝔢𝔫𝔱ℌ𝔲𝔟",
    TextSize = 8,
    TextColor3 = COLORS.Faint,
    TextXAlignment = Enum.TextXAlignment.Left,
}, mainFrame)

local minimizeButton = createGuiInstance("TextButton", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -44, 0, 13),
    Size = UDim2.fromOffset(26, 26),
    BackgroundColor3 = COLORS.Surface,
    BorderSizePixel = 0,
    AutoButtonColor = true,
    Font = Enum.Font.GothamBold,
    Text = "−",
    TextSize = 21,
    TextColor3 = COLORS.Icon,
}, mainFrame, 8)

local closeButton = createGuiInstance("TextButton", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -14, 0, 13),
    Size = UDim2.fromOffset(26, 26),
    BackgroundColor3 = COLORS.Surface,
    BorderSizePixel = 0,
    AutoButtonColor = true,
    Font = Enum.Font.GothamBold,
    Text = "×",
    TextSize = 16,
    TextColor3 = COLORS.Icon,
}, mainFrame, 8)

createGuiInstance("Frame", {
    Position = UDim2.fromOffset(0, 52),
    Size = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = COLORS.Line,
    BorderSizePixel = 0,
}, mainFrame)

createGuiInstance("Frame", {
    Position = UDim2.fromOffset(176, 52),
    Size = UDim2.new(0, 1, 1, -52),
    BackgroundColor3 = COLORS.Line,
    BorderSizePixel = 0,
}, mainFrame)

createGuiInstance("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(14, 60),
    Size = UDim2.fromOffset(152, 26),
    Font = Enum.Font.GothamBold,
    Text = "Jugadores",
    TextSize = 12,
    TextColor3 = COLORS.Faint,
    TextXAlignment = Enum.TextXAlignment.Left,
}, mainFrame)

local playerListContainer = createGuiInstance("ScrollingFrame", {
    Position = UDim2.fromOffset(8, 92),
    Size = UDim2.new(0, 164, 1, -100),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = COLORS.Soft,
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, mainFrame)

createGuiInstance("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, playerListContainer)
createGuiInstance("UIPadding", { PaddingTop = UDim.new(0, 1), PaddingBottom = UDim.new(0, 4) }, playerListContainer)
local playerPanelWidth = PANEL_WIDTH - 176 - 28 - 4

local playerSearchFrame = createGuiInstance("Frame", {
    Position = UDim2.fromOffset(194, 64),
    Size = UDim2.fromOffset(playerPanelWidth - 44, 36),
    BackgroundColor3 = COLORS.Surface,
    BorderSizePixel = 0,
}, mainFrame, 8)

local playerSearchBox = createGuiInstance("TextBox", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(10, 0),
    Size = UDim2.new(1, -20, 1, 0),
    Font = Enum.Font.Gotham,
    PlaceholderText = "Usuario o ID",
    PlaceholderColor3 = COLORS.Faint,
    Text = "",
    TextSize = 13,
    TextColor3 = COLORS.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = false,
}, playerSearchFrame)

local searchButton = createGuiInstance("TextButton", {
    Position = UDim2.fromOffset(194 + playerPanelWidth - 38, 64),
    Size = UDim2.fromOffset(38, 36),
    BackgroundColor3 = COLORS.Surface,
    BorderSizePixel = 0,
    AutoButtonColor = true,
    Font = Enum.Font.GothamBold,
    Text = "→",
    TextSize = 22,
    TextColor3 = COLORS.Faint,
}, mainFrame, 8)
local detailsPanelWidth = playerPanelWidth - 166

local avatarPreviewCard = createGuiInstance("Frame", {
    Position = UDim2.fromOffset(194, 108),
    Size = UDim2.fromOffset(150, 150),
    BackgroundColor3 = COLORS.Surface,
    BorderSizePixel = 0,
}, mainFrame, 12)

local avatarPreviewImage = createGuiInstance("ImageLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(6, 6),
    Size = UDim2.new(1, -12, 1, -12),
    Image = "",
    ScaleType = Enum.ScaleType.Fit,
}, avatarPreviewCard)

local favoriteButton = createGuiInstance("TextButton", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -6, 0, 6),
    Size = UDim2.fromOffset(28, 28),
    BackgroundColor3 = COLORS.Background,
    BackgroundTransparency = 0.25,
    BorderSizePixel = 0,
    AutoButtonColor = true,
    Font = Enum.Font.GothamBold,
    Text = "☆",
    TextSize = 19,
    TextColor3 = COLORS.Faint,
    ZIndex = 3,
}, avatarPreviewCard, 14)

local selectedPlayerNameLabel = createGuiInstance("TextLabel", {
    Position = UDim2.fromOffset(360, 110),
    Size = UDim2.fromOffset(detailsPanelWidth, 22),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Text = "Selecciona un jugador",
    TextSize = 15,
    TextColor3 = COLORS.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
}, mainFrame)

local selectedPlayerUsernameLabel = createGuiInstance("TextLabel", {
    Position = UDim2.fromOffset(360, 132),
    Size = UDim2.fromOffset(detailsPanelWidth, 16),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = "",
    TextSize = 10,
    TextColor3 = COLORS.Faint,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
}, mainFrame)

local skinStatusLabel = createGuiInstance("TextLabel", {
    Position = UDim2.fromOffset(360, 145),
    Size = UDim2.fromOffset(detailsPanelWidth, 12),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = "",
    TextSize = 9,
    TextColor3 = COLORS.Faint,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
}, mainFrame)

local statusTextProxy = setmetatable({}, { __newindex = function(_, key, value)
    if key ~= "Text" then
        return
    end
    local status = tostring(value or "")
    if status == "Aplicado" or status == "Retirado" or status == "Fallo" then
        skinStatusLabel.Text = status
        skinStatusLabel.TextColor3 = status == "Fallo" and COLORS.Danger or COLORS.OnFill
    else
        skinStatusLabel.Text = ""
        skinStatusLabel.TextColor3 = COLORS.Faint
    end
end })

local function createSkinActionButton(x, y, width, height, label, iconName, backgroundColor, textColor)
    local createdButton = createGuiInstance("TextButton", {
        Position = UDim2.fromOffset(x, y),
        Size = UDim2.fromOffset(width, height),
        BackgroundColor3 = backgroundColor,
        BorderSizePixel = 0,
        AutoButtonColor = true,
        Font = Enum.Font.GothamBold,
        Text = label,
        TextSize = 12,
        TextColor3 = textColor,
    }, mainFrame, 8)

    local iconImage = nil

    if iconName then
        createGuiInstance("UIPadding", { PaddingLeft = UDim.new(0, 18) }, createdButton)
        iconImage = createImageLabel(createdButton, iconName, 14, textColor, UDim2.new(0, 2, 0.5, 0))
    end

    return createdButton, iconImage
end

local applySkinButton = createSkinActionButton(360, 158, 112, 30, "APLICAR", nil, COLORS.AccentFill, COLORS.On)
local removeSkinButton = createSkinActionButton(480, 158, detailsPanelWidth - 120, 30, "QUITAR", nil, COLORS.Surface, COLORS.Icon)
local animationToggleButton, animationToggleIcon = createSkinActionButton(360, 196, detailsPanelWidth, 28, "Animaciones: On", nil, COLORS.Surface, COLORS.Faint)
animationToggleButton.TextSize = 11
local r15Button = createSkinActionButton(360, 232, 112, 26, "R15", nil, COLORS.Surface, COLORS.Faint)
local r6Button = createSkinActionButton(480, 232, detailsPanelWidth - 120, 26, "R6", nil, COLORS.Surface, COLORS.Faint)

local function notifyAccessoryInventory()
    bumpSkinRevision()
    if type(avatarBridge.accessory.refreshInventory) == "function" then
        pcall(avatarBridge.accessory.refreshInventory)
    end
end

local function updateSkinControls()
    skinState.feMode = "ON"
    for rigButton, isRigSelected in pairs({ [r15Button] = skinState.rig == "R15", [r6Button] = skinState.rig == "R6" }) do
        rigButton.BackgroundColor3 = isRigSelected and COLORS.OnFill or COLORS.Surface
        isRigSelected = isRigSelected and COLORS.On or COLORS.Faint
        rigButton.TextColor3 = isRigSelected
    end

    local skinEquipped = avatarBridge.skin.active == true and tonumber(skinState.aplicado) ~= nil
    local useRobloxAnimations = skinState.rig == "R6"
    local animationsEnabled = skinState.animationsEnabled == true
    animationToggleButton.Text = useRobloxAnimations and "Animaciones: Roblox"
        or (animationsEnabled and "Animaciones: On" or "Animaciones: Off")
    local animationControlEnabled = skinEquipped and not useRobloxAnimations
    animationToggleButton.BackgroundColor3 = not animationControlEnabled and COLORS.BackgroundAlt
        or (animationsEnabled and COLORS.AccentFill or COLORS.Surface)
    animationToggleButton.TextColor3 = animationControlEnabled and (animationsEnabled and COLORS.Accent or COLORS.Faint) or COLORS.Faint
    animationToggleButton.TextTransparency = animationControlEnabled and 0 or 0.35
    animationToggleButton.Active = animationControlEnabled
    animationToggleButton.Selectable = animationControlEnabled
    animationToggleButton.AutoButtonColor = animationControlEnabled
    if animationToggleIcon then animationToggleIcon.ImageColor3 = animationToggleButton.TextColor3 end
end

local isWindowMinimized = false

local floatingButtonFrame = createGuiInstance("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Size = UDim2.fromOffset(150, 46),
    BackgroundColor3 = COLORS.BackgroundAlt,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Visible = false,
    ZIndex = 50,
}, screenGui, 12)

createGuiInstance("UIStroke", { Color = COLORS.Text, Thickness = 1.5, Transparency = 0.45 }, floatingButtonFrame)
local reopenBackground = Instance.new("ImageLabel")
reopenBackground.Size = UDim2.fromScale(1, 1)
reopenBackground.BackgroundTransparency = 1
reopenBackground.Image = bgAsset or ""
reopenBackground.ImageTransparency = bgAsset and 0.5 or 1
reopenBackground.ScaleType = Enum.ScaleType.Crop
reopenBackground.ZIndex = 50
reopenBackground.Parent = floatingButtonFrame
createGuiInstance("UICorner", { CornerRadius = UDim.new(0, 12) }, reopenBackground)
local reopenOverlay = createGuiInstance("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = bgAsset and 0.55 or 0.82,
    BorderSizePixel = 0,
    ZIndex = 51,
}, floatingButtonFrame)
createGuiInstance("UICorner", { CornerRadius = UDim.new(0, 12) }, reopenOverlay)
local reopenDot = createGuiInstance("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(1, -12, 0, 10),
    Size = UDim2.fromOffset(8, 8),
    BackgroundColor3 = COLORS.Text,
    BorderSizePixel = 0,
    ZIndex = 53,
}, floatingButtonFrame, 4)
createGuiInstance("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(14, 0),
    Size = UDim2.new(1, -24, 1, 0),
    Font = Enum.Font.GothamBold,
    Text = "Open Skins",
    TextSize = 13,
    TextColor3 = COLORS.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 53,
}, floatingButtonFrame)
local openClick = createGuiInstance("TextButton", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    AutoButtonColor = false,
    Active = true,
    Selectable = false,
    Text = "",
    ZIndex = 54,
}, floatingButtonFrame)
task.spawn(function()
    while reopenDot.Parent do
        reopenDot.BackgroundTransparency = 0.65
        task.wait(0.8)
        if not reopenDot.Parent then break end
        reopenDot.BackgroundTransparency = 0
        task.wait(0.8)
    end
end)

local floatingPositionInitialized = false
local floatingButtonDragState = nil
local mainWindowDragState = nil
local dragConnections = {}
local connectDragConnections = nil
local disconnectDragConnections = nil

local function clampFloatingPosition(position)
    return clampGuiCenter(floatingButtonFrame, position)
end

local function getFloatingCenter()
    return getGuiCenter(floatingButtonFrame)
end

local function setFloatingCenter(position)
    return setGuiCenter(floatingButtonFrame, clampFloatingPosition(position))
end

local function initializeFloatingPosition()
    if floatingPositionInitialized then return end
    local viewport = getViewportSize()
    local halfSize = floatingButtonFrame.AbsoluteSize * 0.5
    setFloatingCenter(Vector2.new(viewport.X - halfSize.X - 16, viewport.Y * 0.5 + 28))
    floatingPositionInitialized = true
end

local function hideWindow()
    keepFrameInsideViewport()
    initializeFloatingPosition()
    isWindowMinimized = true
    mainFrame.Visible = false
    floatingButtonFrame.Visible = true
    if avatarBridge.uiPanels.activePanel == "skins" then
        avatarBridge.uiPanels.activePanel = "none"
    end
end

local function showWindow()
    local closeAccessoriesPanel = avatarBridge.uiPanels.closeAccessoriesPanel
    if type(closeAccessoriesPanel) == "function" then pcall(closeAccessoriesPanel) end
    avatarBridge.uiPanels.activePanel = "skins"
    screenGui.Enabled = true
    isWindowMinimized = false
    mainFrame.Visible = true
    animateBackground()
    floatingButtonFrame.Visible = true
    setMainFrameCenter(mainFrameCenter)
    if connectDragConnections then connectDragConnections() end
    updateUiScale()
end

local function setWindowMinimized(visible)
    if visible then hideWindow() else showWindow() end
end

local function closePanelForSwitch()
    floatingButtonDragState = nil
    mainWindowDragState = nil
    mainFrame.Visible = false
    floatingButtonFrame.Visible = true
    isWindowMinimized = true
    if avatarBridge.uiPanels.activePanel == "skins" then
        avatarBridge.uiPanels.activePanel = "none"
    end
end

avatarBridge.uiPanels.closeSkinsPanel = closePanelForSwitch

minimizeButton.Activated:Connect(hideWindow)

local function trackDragConnection(connection)
    table.insert(dragConnections, connection)
    return connection
end

local function beginFloatingDrag(input)
    local inputType = input.UserInputType
    if inputType ~= Enum.UserInputType.MouseButton1
        and inputType ~= Enum.UserInputType.Touch then return end
    floatingButtonDragState = {
        input = input,
        inputType = inputType,
        start = Vector2.new(input.Position.X, input.Position.Y),
        origin = getFloatingCenter(),
        moved = false,
    }
end

local function moveFloatingDrag(input, isTouch)
    local drag = floatingButtonDragState
    if not drag then return end
    if isTouch then
        if drag.inputType ~= Enum.UserInputType.Touch or input ~= drag.input then return end
    elseif drag.inputType ~= Enum.UserInputType.MouseButton1
        or input.UserInputType ~= Enum.UserInputType.MouseMovement then
        return
    end
    local pointer = Vector2.new(input.Position.X, input.Position.Y)
    local delta = pointer - drag.start
    if delta.Magnitude > 6 then drag.moved = true end
    if drag.moved then setFloatingCenter(drag.origin + delta) end
end

local function finishFloatingDrag(input, isTouch)
    local drag = floatingButtonDragState
    if not drag then return end
    local ended
    if isTouch then
        ended = drag.inputType == Enum.UserInputType.Touch and input == drag.input
    else
        ended = drag.inputType == Enum.UserInputType.MouseButton1
            and input.UserInputType == Enum.UserInputType.MouseButton1
    end
    if not ended then return end
    floatingButtonDragState = nil
    if not drag.moved then showWindow() end
end

local function beginMainWindowDrag(input)
    local inputType = input.UserInputType
    if inputType ~= Enum.UserInputType.MouseButton1
        and inputType ~= Enum.UserInputType.Touch then return end
    mainWindowDragState = {
        input = input,
        inputType = inputType,
        start = Vector2.new(input.Position.X, input.Position.Y),
        origin = mainFrameCenter,
    }
end

local function moveMainWindowDrag(input, isTouch)
    local drag = mainWindowDragState
    if not drag then return end
    if isTouch then
        if drag.inputType ~= Enum.UserInputType.Touch or input ~= drag.input then return end
    elseif drag.inputType ~= Enum.UserInputType.MouseButton1
        or input.UserInputType ~= Enum.UserInputType.MouseMovement then
        return
    end
    local pointer = Vector2.new(input.Position.X, input.Position.Y)
    setMainFrameCenter(drag.origin + pointer - drag.start)
end

local function finishMainWindowDrag(input, isTouch)
    local drag = mainWindowDragState
    if not drag then return end
    local ended
    if isTouch then
        ended = drag.inputType == Enum.UserInputType.Touch and input == drag.input
    else
        ended = drag.inputType == Enum.UserInputType.MouseButton1
            and input.UserInputType == Enum.UserInputType.MouseButton1
    end
    if ended then mainWindowDragState = nil end
end

disconnectDragConnections = function()
    floatingButtonDragState = nil
    mainWindowDragState = nil
    for _, connection in ipairs(dragConnections) do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(dragConnections)
end

connectDragConnections = function()
    if #dragConnections > 0 then return end
    trackDragConnection(openClick.InputBegan:Connect(beginFloatingDrag))
    trackDragConnection(UserInputService.InputChanged:Connect(function(input)
        moveFloatingDrag(input, false)
        moveMainWindowDrag(input, false)
    end))
    trackDragConnection(UserInputService.TouchMoved:Connect(function(input)
        moveFloatingDrag(input, true)
        moveMainWindowDrag(input, true)
    end))
    trackDragConnection(UserInputService.InputEnded:Connect(function(input)
        finishFloatingDrag(input, false)
        finishMainWindowDrag(input, false)
    end))
    trackDragConnection(UserInputService.TouchEnded:Connect(function(input)
        finishFloatingDrag(input, true)
        finishMainWindowDrag(input, true)
    end))
    trackDragConnection(windowHeader.InputBegan:Connect(beginMainWindowDrag))
end

local closeConfirmationOverlay = createGuiInstance("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = COLORS.Background,
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 20,
    Active = true,
}, mainFrame, 16)

createGuiInstance("TextButton", {
    Text = "",
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    AutoButtonColor = false,
    ZIndex = 20,
}, closeConfirmationOverlay)

local closeConfirmationDialog = createGuiInstance("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(300, 132),
    BackgroundColor3 = COLORS.Surface,
    BorderSizePixel = 0,
    ZIndex = 21,
}, closeConfirmationOverlay, 12)

createGuiInstance("UIStroke", { Color = COLORS.Line, Thickness = 1 }, closeConfirmationDialog)

createGuiInstance("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(16, 16),
    Size = UDim2.new(1, -32, 0, 22),
    Font = Enum.Font.GothamBold,
    Text = "¿Cerrar SilentHub?",
    TextSize = 15,
    TextColor3 = COLORS.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 22,
}, closeConfirmationDialog)

createGuiInstance("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(16, 40),
    Size = UDim2.new(1, -32, 0, 32),
    Font = Enum.Font.Gotham,
    Text = "Se cerrará SilentHub.",
    TextSize = 11,
    TextColor3 = COLORS.Faint,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextWrapped = true,
    ZIndex = 22,
}, closeConfirmationDialog)

local confirmCloseButton = createGuiInstance("TextButton", {
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -16, 1, -14),
    Size = UDim2.fromOffset(96, 30),
    BackgroundColor3 = COLORS.DangerFill,
    BorderSizePixel = 0,
    AutoButtonColor = true,
    Font = Enum.Font.GothamBold,
    Text = "Cerrar",
    TextSize = 12,
    TextColor3 = COLORS.Danger,
    ZIndex = 22,
}, closeConfirmationDialog, 8)

createGuiInstance("TextButton", {
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -120, 1, -14),
    Size = UDim2.fromOffset(96, 30),
    BackgroundColor3 = COLORS.SurfaceUp,
    BorderSizePixel = 0,
    AutoButtonColor = true,
    Font = Enum.Font.GothamBold,
    Text = "Cancelar",
    TextSize = 12,
    TextColor3 = COLORS.Icon,
    ZIndex = 22,
}, closeConfirmationDialog, 8).Activated:Connect(function()
    closeConfirmationOverlay.Visible = false
end)

local function preloadSelectedPlayerAnimations()
    if not skinState.userId then
        return
    end
    local userId = skinState.userId

    task.spawn(function()
        local humanoidDescription = getUserHumanoidDescription(userId)
        if skinState.userId ~= userId or not humanoidDescription then
            return
        end
        task.spawn(preloadAnimationAssets, humanoidDescription)
    end)
end

local findFavoriteIndex = nil

local function updateFavoriteButton()
    local isFavorite = skinState.userId and findFavoriteIndex(skinState.userId) ~= nil or false
    favoriteButton.Visible = skinState.userId ~= nil
    favoriteButton.Text = isFavorite and "★" or "☆"
    favoriteButton.TextColor3 = isFavorite and Color3.fromRGB(250, 204, 21) or COLORS.Faint
    favoriteButton.BackgroundColor3 = isFavorite and Color3.fromRGB(49, 42, 25) or COLORS.Background
end

local function updateSelectedPlayerCard()
    updateFavoriteButton()

    if not skinState.userId then
        selectedPlayerNameLabel.Text = "Selecciona un jugador"
        selectedPlayerUsernameLabel.Text = "Apariencias de jugadores"
        skinStatusLabel.Text = ""
        avatarPreviewImage.Image = ""
        return
    end

    selectedPlayerNameLabel.Text = skinState.nombre or "..."
    selectedPlayerUsernameLabel.Text = skinState.usuario and "@" .. skinState.usuario or ("ID " .. tostring(skinState.userId))
    skinStatusLabel.Text = ""
    avatarPreviewImage.Image = ("rbxthumb://type=Avatar&id=%d&w=352&h=352"):format(skinState.userId)
    preloadSelectedPlayerAnimations()
end

local refreshPlayerList = nil

local function updateCachedUserInfo(userId)
    local displayName, username = getUserNames(userId)
    if not username then
        return false
    end
    local hasChanged = false

    for _, favorito in ipairs(skinState.favoritos) do
        if favorito.userId == userId and (favorito.nombre ~= displayName or favorito.usuario ~= username) then
            favorito.nombre = displayName
            favorito.usuario = username
            hasChanged = true
        end
    end

    if skinState.userId == userId and (skinState.nombre ~= displayName or skinState.usuario ~= username) then
        local selectedSkinState = skinState
        skinState.nombre = displayName
        selectedSkinState.usuario = username
        hasChanged = true
    end

    return hasChanged
end

local function selectPlayer(targetUserId)
    local userId = tonumber(targetUserId)
    local cachedUserInfo = userInfoCache[userId]
    skinState.userId = userId
    skinState.nombre = cachedUserInfo and cachedUserInfo.nombre or nil
    skinState.usuario = cachedUserInfo and cachedUserInfo.usuario or nil

    for _, favorito in ipairs(skinState.favoritos) do
        if favorito.userId == userId and not cachedUserInfo then
            local selectedSkinState = skinState
            local usuario = favorito.usuario
            skinState.nombre = favorito.nombre
            selectedSkinState.usuario = usuario
        end
    end

    updateSelectedPlayerCard()
    statusTextProxy.Text = ""
    saveConfiguration()
    refreshPlayerList()

    task.spawn(function()
        if updateCachedUserInfo(userId) and skinState.userId == userId then
            updateSelectedPlayerCard()
            saveConfiguration()
            refreshPlayerList()
        end
    end)

    task.spawn(function()
        local detectedRigType = getUserRigType(userId)

        if detectedRigType and skinState.userId == userId and skinState.rig ~= detectedRigType then
            skinState.rig = detectedRigType
            saveConfiguration()
            updateSkinControls()
        end
    end)
end

local function createPlayerListItem(displayName, username, layoutOrder, onActivated, isSelected)
    local playerListItemButton = createGuiInstance("TextButton", {
        Size = UDim2.new(1, -6, 0, 34),
        BackgroundColor3 = isSelected and COLORS.OnFill or COLORS.Surface,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Enum.Font.Gotham,
        Text = "",
        LayoutOrder = layoutOrder,
    }, playerListContainer, 7)

    createGuiInstance("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(9, 3),
        Size = UDim2.new(1, -18, 0, 15),
        Font = Enum.Font.Gotham,
        Text = tostring(displayName or "Jugador"),
        TextSize = 10,
        TextColor3 = isSelected and COLORS.On or COLORS.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, playerListItemButton)

    if username and username ~= "" then
        createGuiInstance("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(9, 18),
            Size = UDim2.new(1, -18, 0, 12),
            Font = Enum.Font.Gotham,
            Text = username,
            TextSize = 8,
            TextColor3 = isSelected and COLORS.Text or COLORS.Faint,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }, playerListItemButton)
    end

    if onActivated then
        playerListItemButton.Activated:Connect(onActivated)
    end

    return playerListItemButton
end

findFavoriteIndex = function(userId)
    for i, favorito in ipairs(skinState.favoritos) do
        if favorito.userId == userId then
            return i
        end
    end

    return nil
end

refreshPlayerList = function()
    for _, child in ipairs(playerListContainer:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end

    local order = 0
    local seen = {}
    local function addSection(title)
        order += 1
        createGuiInstance("TextLabel", {
            Size = UDim2.new(1, -6, 0, 21),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Text = string.upper(title),
            TextColor3 = COLORS.Faint,
            TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = order,
        }, playerListContainer)
    end

    local function addEmpty(text)
        order += 1
        createGuiInstance("TextLabel", {
            Size = UDim2.new(1, -8, 0, 28),
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = text,
            TextColor3 = COLORS.Faint,
            TextSize = 9,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = order,
        }, playerListContainer)
    end

    addSection("Favoritos")
    local favoriteCount = 0
    for _, favorito in ipairs(skinState.favoritos) do
        local userId = tonumber(favorito.userId)
        if userId and not seen[userId] then
            seen[userId] = true
            favoriteCount += 1
            order += 1
            createPlayerListItem(favorito.nombre, favorito.usuario and "@" .. favorito.usuario or ("ID " .. tostring(userId)), order, function()
                selectPlayer(userId)
            end, skinState.userId == userId)
        end
    end
    if favoriteCount == 0 then
        addEmpty("Sin favoritos")
    end

    addSection("Jugadores")
    local onlinePlayers = Players:GetPlayers()
    table.sort(onlinePlayers, function(a, b)
        return tostring(a.DisplayName):lower() < tostring(b.DisplayName):lower()
    end)
    local playerCount = 0
    for _, player in ipairs(onlinePlayers) do
        local userId = player.UserId
        if userId ~= localPlayer.UserId and not seen[userId] then
            seen[userId] = true
            playerCount += 1
            order += 1
            local displayName = player.DisplayName
            local username = player.Name
            createPlayerListItem(displayName, "@" .. username, order, function()
                selectPlayer(userId)
            end, skinState.userId == userId)
        end
    end
    if playerCount == 0 then
        addEmpty("Sin jugadores")
    end
end

local isApplyingSkin = false
local pendingApply = false
local applicationGeneration = 0
local queuedSkinUserId = nil
local queuedSkinRig = nil
local refreshAccessoryWhenIdle = false
local characterRebuildPending = false
local characterRebuildGeneration = 0

local function createSkinModel(userId, rigName)
    local rigName = rigName == "R6" and "R6" or "R15"
    local templateKey = getSkinTemplateKey(userId, rigName)
    local baseDescription = getUserHumanoidDescription(userId)
    if not baseDescription then
        return nil, nil
    end

    local cachedModel = cloneSkinTemplate(templateKey)
    if cachedModel then
        return baseDescription, cachedModel
    end

    local modelDescription = nil
    local okClone, cloned = pcall(function()
        return baseDescription:Clone()
    end)
    if not okClone or not cloned then
        return baseDescription, nil
    end
    modelDescription = cloned

    if type(avatarBridge.accessory.composeDescription) == "function" then
        local composeOk, composed, composeError = pcall(
            avatarBridge.accessory.composeDescription,
            modelDescription,
            rigName
        )
        if not composeOk or not composed then
            pcall(function() modelDescription:Destroy() end)
            return baseDescription, nil
        end
        modelDescription = composed
    end

    preloadAnimationAssets(modelDescription)
    local model = createHumanoidModel(userId, modelDescription, rigName)
    pcall(function() modelDescription:Destroy() end)
    if model then
        storeSkinTemplate(templateKey, model)
    end
    return baseDescription, model
end

local function applySkinVisualModel(character, userId, requestedRig, requestGeneration)
    local rig = requestedRig or skinState.rig
    local baseDescription, visualModel = createSkinModel(userId, rig)
    if not baseDescription or not visualModel then
        if visualModel then pcall(function() visualModel:Destroy() end) end
        return nil
    end

    if (requestGeneration and requestGeneration ~= applicationGeneration) or getLocalCharacter() ~= character then
        if visualModel then visualModel:Destroy() end
        return nil
    end

    local sourceHumanoid = character:FindFirstChildOfClass("Humanoid")
    if not waitForCharacterRig(character, sourceHumanoid, rig, 2.5) then
        pcall(function() visualModel:Destroy() end)
        return nil
    end
    if (requestGeneration and requestGeneration ~= applicationGeneration) or getLocalCharacter() ~= character then
        pcall(function() visualModel:Destroy() end)
        return nil
    end

    captureCharacterState(character)
    stopCurrentEmote()
    restoreCharacterAppearance(character)
    restoreCharacterEmotes(character)

    local animationData
    if rig == "R15" then
        animationData = extractAnimationSets(baseDescription)
    end

    applyEmotes(character, getDescriptionEmotes(baseDescription))
    local result = attachSkinVisual(character, visualModel, nil, rig)
    if requestGeneration and requestGeneration ~= applicationGeneration then
        restoreCharacterAppearance(character)
        return nil
    end
    if not result then
        if visualModel and visualModel.Parent then
            pcall(function() visualModel:Destroy() end)
        end
        return nil
    end
    copiedSkinAnimationData = animationData
    if rig == "R15" and skinState.animationsEnabled then
        if not applyCopiedSkinAnimations(character, true) then
            skinState.animationsEnabled = false
            applyCopiedSkinAnimations(character, false)
        end
    else
        applyCopiedSkinAnimations(character, false)
    end
    if type(avatarBridge.accessory.suspend) == "function" then
        pcall(avatarBridge.accessory.suspend)
    end
    return result
end

local function applySkin(targetUserId, targetRig, fromRespawn)
    local userId = tonumber(targetUserId) or tonumber(skinState.userId)
    local rig = (targetRig == "R6" or targetRig == "R15") and targetRig or skinState.rig
    if not userId then return false end
    if rig ~= "R6" and rig ~= "R15" then rig = skinState.rig end

    applicationGeneration += 1
    if not fromRespawn then
        characterRebuildGeneration += 1
    end
    characterRebuildPending = false
    queuedSkinUserId = userId
    queuedSkinRig = rig
    refreshAccessoryWhenIdle = false
    avatarBridge.skin.releasing = false
    avatarBridge.skin.pending = true
    bumpSkinRevision()
    avatarBridge.skin.requestedUserId = userId
    avatarBridge.skin.requestedRig = rig

    if isApplyingSkin then
        pendingApply = true
        return true
    end
    isApplyingSkin = true

    task.spawn(function()
        local shouldRefreshAccessory = false
        repeat
            pendingApply = false
            local requestGeneration = applicationGeneration
            local currentUserId = queuedSkinUserId
            local currentRig = queuedSkinRig or skinState.rig
            avatarBridge.skin.requestedUserId = currentUserId
            avatarBridge.skin.requestedRig = currentRig
            local character = getLocalCharacter()
            local result = nil

            if character and currentUserId then
                result = applySkinVisualModel(character, currentUserId, currentRig, requestGeneration)
            end

            if requestGeneration == applicationGeneration then
                if result then
                    skinState.aplicado = currentUserId
                    avatarBridge.skin.active = true
                    bumpSkinRevision()
                    avatarBridge.skin.userId = currentUserId
                    avatarBridge.skin.rig = currentRig
                    avatarBridge.skin.requestedUserId = nil
                    avatarBridge.skin.requestedRig = nil
                    shouldRefreshAccessory = false
                    saveConfiguration()
                    updateSkinControls()
                    notifyAccessoryInventory()
                    statusTextProxy.Text = "Aplicado"
                else
                    local liveCharacter = getLocalCharacter()
                    if liveCharacter then
                        restoreCharacterAppearance(liveCharacter)
                        restoreCharacterEmotes(liveCharacter)
                    end
                    skinState.aplicado = nil
                    avatarBridge.skin.active = false
                    bumpSkinRevision()
                    avatarBridge.skin.userId = nil
                    avatarBridge.skin.requestedUserId = nil
                    avatarBridge.skin.requestedRig = nil
                    shouldRefreshAccessory = true
                    copiedSkinAnimationData = nil
                    updateSkinControls()
                    notifyAccessoryInventory()
                    statusTextProxy.Text = "Fallo"
                    saveConfiguration()
                end
            end
        until not pendingApply

        isApplyingSkin = false
        avatarBridge.skin.pending = characterRebuildPending
        avatarBridge.skin.releasing = false
        avatarBridge.skin.requestedUserId = nil
        avatarBridge.skin.requestedRig = nil
        queuedSkinUserId = nil
        queuedSkinRig = nil

        if shouldRefreshAccessory or refreshAccessoryWhenIdle then
            refreshAccessoryWhenIdle = false
            if type(avatarBridge.accessory.refresh) == "function" then
                task.defer(function()
                    pcall(avatarBridge.accessory.refresh)
                end)
            end
        end
    end)
    return true
end

local function removeSkin()
    applicationGeneration += 1
    characterRebuildGeneration += 1
    characterRebuildPending = false
    pendingApply = false
    queuedSkinUserId = nil
    queuedSkinRig = nil
    skinState.aplicado = nil
    avatarBridge.skin.active = false
    bumpSkinRevision()
    avatarBridge.skin.userId = nil
    avatarBridge.skin.requestedUserId = nil
    avatarBridge.skin.requestedRig = nil
    copiedSkinAnimationData = nil
    avatarBridge.skin.releasing = isApplyingSkin
    avatarBridge.skin.pending = isApplyingSkin
    refreshAccessoryWhenIdle = isApplyingSkin
    saveConfiguration()
    stopCurrentEmote()
    destroySkinVisuals()
    copiedSkinAnimationData = nil
    local character = getLocalCharacter()

    if character then
        restoreCharacterAppearance(character)
        restoreCharacterEmotes(character)
    end

    statusTextProxy.Text = "Retirado"
    updateSkinControls()
    notifyAccessoryInventory()
    if not isApplyingSkin then
        avatarBridge.skin.pending = false
        avatarBridge.skin.releasing = false
        if type(avatarBridge.accessory.refresh) == "function" then
            task.defer(function()
                pcall(avatarBridge.accessory.refresh)
            end)
        end
    end
end

avatarBridge.skin.owner = skinBridgeToken
avatarBridge.skin.getBaseDescription = function()
    local userId
    if avatarBridge.skin.pending and avatarBridge.skin.requestedUserId then
        userId = avatarBridge.skin.requestedUserId
    elseif avatarBridge.skin.active then
        userId = avatarBridge.skin.userId or skinState.aplicado
    else
        userId = skinState.aplicado
    end
    if not tonumber(userId) then return nil end
    return getUserHumanoidDescription(tonumber(userId))
end
avatarBridge.skin.refresh = function()
    if avatarBridge.skin.releasing then return false end
    if characterRebuildPending then return true end
    local userId = avatarBridge.skin.pending and avatarBridge.skin.requestedUserId
        or (avatarBridge.skin.active and avatarBridge.skin.userId)
        or skinState.aplicado
    local rig = avatarBridge.skin.pending and avatarBridge.skin.requestedRig
        or (avatarBridge.skin.active and avatarBridge.skin.rig)
        or skinState.rig
    if not tonumber(userId) then return false end
    return applySkin(tonumber(userId), rig)
end

applySkinButton.Activated:Connect(applySkin)
removeSkinButton.Activated:Connect(removeSkin)

local function setRigType(rig)
    if skinState.rig == rig then
        return
    end
    skinState.rig = rig
    saveConfiguration()
    updateSkinControls()

    if (skinState.aplicado or isApplyingSkin) and getLocalCharacter() then
        skinState.userId = skinState.userId or skinState.aplicado
        applySkin()
    end
end

r15Button.Activated:Connect(function()
    setRigType("R15")
end)

r6Button.Activated:Connect(function()
    setRigType("R6")
end)

animationToggleButton.Activated:Connect(function()
    if skinState.rig == "R6" then
        updateSkinControls()
        return
    end

    if avatarBridge.skin.active ~= true or not tonumber(skinState.aplicado) then
        updateSkinControls()
        return
    end
    local character = getLocalCharacter()
    if not character then return end
    skinState.animationsEnabled = not (skinState.animationsEnabled == true)
    local applied = applyCopiedSkinAnimations(character, skinState.animationsEnabled)
    if not applied and skinState.animationsEnabled then
        skinState.animationsEnabled = false
        applyCopiedSkinAnimations(character, false)
        statusTextProxy.Text = "La skin no tiene animaciones compatibles"
    else
        statusTextProxy.Text = skinState.animationsEnabled and "Aplicado" or "Retirado"
    end
    saveConfiguration()
    updateSkinControls()
end)

favoriteButton.Activated:Connect(function()
    if not skinState.userId then
        return
    end
    local favoriteIndex = findFavoriteIndex(skinState.userId)

    if favoriteIndex then
        table.remove(skinState.favoritos, favoriteIndex)
    else
        table.insert(skinState.favoritos, { userId = skinState.userId, nombre = skinState.nombre or tostring(skinState.userId), usuario = skinState.usuario })
    end

    saveConfiguration()
    updateFavoriteButton()
    refreshPlayerList()
end)

local function searchPlayer()
    local searchText = playerSearchBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
    if searchText == "" then
        return
    end
    local targetUserId = tonumber(searchText)
    if targetUserId then
        selectPlayer(targetUserId)
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower() == searchText:lower() or player.DisplayName:lower() == searchText:lower() then
            selectPlayer(player.UserId)
            return
        end
    end

    task.spawn(function()
        local ok, result = pcall(Players.GetUserIdFromNameAsync, Players, searchText)

        if ok and result then
            selectPlayer(result)
        else
            statusTextProxy.Text = "Fallo"
        end
    end)
end

searchButton.Activated:Connect(searchPlayer)

playerSearchBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        searchPlayer()
    end
end)

local lifecycleConnections = {}
local characterDeathConnection = nil
local characterHealthConnection = nil
local characterAppearanceConnection = nil

local function disconnectCharacterLifecycleConnections()
    if characterDeathConnection then
        pcall(function() characterDeathConnection:Disconnect() end)
        characterDeathConnection = nil
    end
    if characterHealthConnection then
        pcall(function() characterHealthConnection:Disconnect() end)
        characterHealthConnection = nil
    end
    if characterAppearanceConnection then
        pcall(function() characterAppearanceConnection:Disconnect() end)
        characterAppearanceConnection = nil
    end
end

table.insert(lifecycleConnections, Players.PlayerAdded:Connect(function()
    task.defer(refreshPlayerList)
end))
table.insert(lifecycleConnections, Players.PlayerRemoving:Connect(function()
    task.defer(refreshPlayerList)
end))

table.insert(lifecycleConnections, localPlayer.CharacterRemoving:Connect(function(character)
    disconnectCharacterLifecycleConnections()
    applicationGeneration += 1
    characterRebuildGeneration += 1
    pendingApply = false
    stopCurrentEmote()
    destroySkinVisuals()
    local hasSavedSkin = tonumber(skinState.aplicado) ~= nil
    characterRebuildPending = hasSavedSkin
    avatarBridge.skin.active = false
    avatarBridge.skin.pending = hasSavedSkin
    bumpSkinRevision()
    avatarBridge.skin.releasing = false
    avatarBridge.skin.userId = nil
    copiedSkinAnimationData = nil
    updateSkinControls()
    notifyAccessoryInventory()
end))

table.insert(lifecycleConnections, localPlayer.CharacterAdded:Connect(function(character)
    disconnectCharacterLifecycleConnections()
    stopCurrentEmote()
    destroySkinVisuals()
    applicationGeneration += 1
    characterRebuildGeneration += 1
    local respawnGeneration = characterRebuildGeneration
    pendingApply = false

    local appliedUserId = tonumber(skinState.aplicado)
    if not appliedUserId then
        characterRebuildPending = false
        avatarBridge.skin.active = false
        avatarBridge.skin.pending = false
        avatarBridge.skin.releasing = false
        avatarBridge.skin.userId = nil
        avatarBridge.skin.requestedUserId = nil
        avatarBridge.skin.requestedRig = nil
        copiedSkinAnimationData = nil
        updateSkinControls()
        notifyAccessoryInventory()
        return
    end

    characterRebuildPending = true
    avatarBridge.skin.active = false
    avatarBridge.skin.pending = true
    bumpSkinRevision()
    avatarBridge.skin.releasing = false
    avatarBridge.skin.userId = nil
    avatarBridge.skin.requestedUserId = appliedUserId
    avatarBridge.skin.requestedRig = skinState.rig

    task.spawn(function()
        local humanoid = character:WaitForChild("Humanoid", 10)
        local rootPart = character:WaitForChild("HumanoidRootPart", 10)
        if respawnGeneration ~= characterRebuildGeneration then return end
        if not humanoid or not rootPart then
            characterRebuildPending = false
            avatarBridge.skin.pending = false
            avatarBridge.skin.requestedUserId = nil
            avatarBridge.skin.requestedRig = nil
            if type(avatarBridge.accessory.refresh) == "function" then
                task.defer(function() pcall(avatarBridge.accessory.refresh) end)
            end
            return
        end

        if respawnGeneration ~= characterRebuildGeneration then return end

        local didDie = humanoid.Health <= 0
        local appearanceRefreshQueued = false
        characterDeathConnection = humanoid.Died:Connect(function()
            if character ~= localPlayer.Character then return end
            didDie = true
            applicationGeneration += 1
            pendingApply = false
            stopCurrentEmote()
            destroySkinVisuals()
            copiedSkinAnimationData = nil
            local savedUserId = tonumber(skinState.aplicado)
            characterRebuildPending = savedUserId ~= nil
            avatarBridge.skin.active = false
            avatarBridge.skin.pending = characterRebuildPending
            bumpSkinRevision()
            avatarBridge.skin.releasing = false
            avatarBridge.skin.userId = nil
            avatarBridge.skin.requestedUserId = savedUserId
            avatarBridge.skin.requestedRig = savedUserId and skinState.rig or nil
        end)
        characterHealthConnection = humanoid.HealthChanged:Connect(function(health)
            if not didDie or health <= 0 or character ~= localPlayer.Character then
                return
            end
            local savedUserId = tonumber(skinState.aplicado)
            if not savedUserId then
                didDie = false
                return
            end
            didDie = false
            characterRebuildPending = false
            applySkin(savedUserId, skinState.rig, true)
        end)

        local appearanceSignalOk, appearanceSignal = pcall(function()
            return humanoid.ApplyDescriptionFinished
        end)
        if appearanceSignalOk and appearanceSignal then
            characterAppearanceConnection = appearanceSignal:Connect(function()
                local savedUserId = tonumber(skinState.aplicado)
                if not savedUserId or character ~= localPlayer.Character or appearanceRefreshQueued then
                    return
                end
                appearanceRefreshQueued = true
                task.defer(function()
                    while character == localPlayer.Character
                        and (isApplyingSkin or avatarBridge.skin.pending == true or characterRebuildPending) do
                        RunService.Heartbeat:Wait()
                    end
                    appearanceRefreshQueued = false
                    if character == localPlayer.Character and tonumber(skinState.aplicado) == savedUserId
                        and not isApplyingSkin and not avatarBridge.skin.pending then
                        applySkin(savedUserId, skinState.rig, true)
                    end
                end)
            end)
        end

        if skinState.aplicado and getLocalCharacter() == character and humanoid.Health > 0 then
            applySkin(appliedUserId, skinState.rig, true)
        elseif skinState.aplicado then
            characterRebuildPending = true
            avatarBridge.skin.pending = true
        else
            characterRebuildPending = false
            avatarBridge.skin.pending = false
            avatarBridge.skin.requestedUserId = nil
            avatarBridge.skin.requestedRig = nil
            if type(avatarBridge.accessory.refresh) == "function" then
                task.defer(function() pcall(avatarBridge.accessory.refresh) end)
            end
        end
    end)
end))



local currentCameraViewportConnection = nil

local function connectCurrentCameraViewport()
    if currentCameraViewportConnection then
        currentCameraViewportConnection:Disconnect()
        for index = #lifecycleConnections, 1, -1 do
            if lifecycleConnections[index] == currentCameraViewportConnection then
                table.remove(lifecycleConnections, index)
                break
            end
        end
        currentCameraViewportConnection = nil
    end

    local currentCamera = Workspace.CurrentCamera
    if currentCamera then
        currentCameraViewportConnection = currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            updateUiScale()
            task.defer(keepFrameInsideViewport)
            if floatingButtonFrame.Visible and floatingPositionInitialized then
                task.defer(function() setFloatingCenter(getFloatingCenter()) end)
            end
        end)
        table.insert(lifecycleConnections, currentCameraViewportConnection)
    end
    updateUiScale()
    task.defer(keepFrameInsideViewport)
    if floatingButtonFrame.Visible and floatingPositionInitialized then
        task.defer(function() setFloatingCenter(getFloatingCenter()) end)
    end
end

connectCurrentCameraViewport()
table.insert(lifecycleConnections, Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    connectCurrentCameraViewport()
    local currentCamera = Workspace.CurrentCamera
    if currentCamera and visualModelState.model then
        local visualFolder = getSkinVisualFolder()
        if visualFolder then
            local previousFolder = visualModelState.folder
            visualModelState.model.Parent = visualFolder
            visualModelState.folder = visualFolder
            if previousFolder and previousFolder ~= visualFolder and previousFolder.Parent
                and #previousFolder:GetChildren() == 0 then
                pcall(function() previousFolder:Destroy() end)
            end
        end
    end
end))

closeButton.Activated:Connect(function()
    if isWindowMinimized then
        setWindowMinimized(false)
    end

    closeConfirmationOverlay.Visible = true
end)

confirmCloseButton.Activated:Connect(function()
    closeConfirmationOverlay.Visible = false
    if disconnectDragConnections then disconnectDragConnections() end
    if avatarBridge.uiPanels.closeSkinsPanel == closePanelForSwitch then
        avatarBridge.uiPanels.closeSkinsPanel = nil
    end
    if avatarBridge.uiPanels.activePanel == "skins" then
        avatarBridge.uiPanels.activePanel = "none"
    end
    disconnectCharacterLifecycleConnections()
    removeSkin()
    if avatarBridge.skin.owner == skinBridgeToken then
        avatarBridge.skin.owner = nil
        avatarBridge.skin.getBaseDescription = nil
        avatarBridge.skin.refresh = nil
    end

    for _, connection in ipairs(lifecycleConnections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    for _, template in pairs(skinModelTemplates) do
        pcall(function() template:Destroy() end)
    end
    table.clear(skinModelTemplates)
    table.clear(skinModelTemplateOrder)

    screenGui:Destroy()
end)

screenGui.Enabled = false

local skinApi = {
    gui = screenGui,
    setEnabled = function(enabled)
        if not screenGui.Parent then return false end
        if enabled == true then
            screenGui.Enabled = true
            initializeFloatingPosition()
            isWindowMinimized = true
            mainFrame.Visible = false
            floatingButtonFrame.Visible = true
            if connectDragConnections then connectDragConnections() end
        else
            if disconnectDragConnections then disconnectDragConnections() end
            screenGui.Enabled = false
            mainFrame.Visible = false
            floatingButtonFrame.Visible = false
            isWindowMinimized = true
            if avatarBridge.uiPanels.activePanel == "skins" then
                avatarBridge.uiPanels.activePanel = "none"
            end
        end
        return true
    end,
    open = function()
        if not screenGui.Parent then return false end
        showWindow()
        return true
    end,
    aplicar = applySkin,
    quitar = removeSkin,
    elegir = selectPlayer,
    emote = playEmote,
    pararEmote = stopCurrentEmote,
    destroy = function()
        if disconnectDragConnections then disconnectDragConnections() end
        if avatarBridge.uiPanels.closeSkinsPanel == closePanelForSwitch then
            avatarBridge.uiPanels.closeSkinsPanel = nil
        end
        if avatarBridge.uiPanels.activePanel == "skins" then
            avatarBridge.uiPanels.activePanel = "none"
        end
        disconnectCharacterLifecycleConnections()
        removeSkin()
        if avatarBridge.skin.owner == skinBridgeToken then
            avatarBridge.skin.owner = nil
            avatarBridge.skin.getBaseDescription = nil
            avatarBridge.skin.refresh = nil
        end
        for _, connection in ipairs(lifecycleConnections) do pcall(function() connection:Disconnect() end) end
        for _, template in pairs(skinModelTemplates) do pcall(function() template:Destroy() end) end
        table.clear(skinModelTemplates)
        table.clear(skinModelTemplateOrder)
            if screenGui.Parent then screenGui:Destroy() end
    end,

    setFEMode = function(mode)
        skinState.feMode = "ON"
        saveConfiguration()
        updateSkinControls()
        return mode == "ON"
    end,
    setAnimations = function(enabled)
        if skinState.rig == "R6" then
            updateSkinControls()
            return false
        end
        if avatarBridge.skin.active ~= true or not tonumber(skinState.aplicado) then return false end
        local character = getLocalCharacter()
        if not character then return false end
        local requested = enabled == true
        local applied = applyCopiedSkinAnimations(character, requested)
        if requested and not applied then return false end
        skinState.animationsEnabled = requested
        saveConfiguration()
        updateSkinControls()
        return true
    end,
}
updateSkinControls()
updateSelectedPlayerCard()
refreshPlayerList()

task.spawn(function()
    local favoriteInfoChanged = false

    for _, favorito in ipairs(skinState.favoritos) do
        favoriteInfoChanged = updateCachedUserInfo(favorito.userId) or favoriteInfoChanged
    end

    if skinState.userId then
        favoriteInfoChanged = updateCachedUserInfo(skinState.userId) or favoriteInfoChanged
    end

    if favoriteInfoChanged then
        saveConfiguration()
        updateSelectedPlayerCard()
        refreshPlayerList()
    end
end)

return skinApi