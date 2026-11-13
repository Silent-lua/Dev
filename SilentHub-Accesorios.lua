local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local AvatarEditorService = game:GetService("AvatarEditorService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
if not localPlayer then
    error("Fallo")
end

local avatarBridge = ...
if type(avatarBridge) ~= "table" then avatarBridge = {} end
avatarBridge.version = 2
avatarBridge.skin = type(avatarBridge.skin) == "table" and avatarBridge.skin or {}
avatarBridge.accessory = type(avatarBridge.accessory) == "table" and avatarBridge.accessory or {}
avatarBridge.skin.revision = tonumber(avatarBridge.skin.revision) or 0
avatarBridge.accessory.revision = tonumber(avatarBridge.accessory.revision) or 0
avatarBridge.uiPanels = type(avatarBridge.uiPanels) == "table" and avatarBridge.uiPanels or {}
local accessoryBridgeToken = {}
local function isSkinRendererActive()
    return avatarBridge.skin.active == true or avatarBridge.skin.pending == true
end

local GUI_NAME = "SilentHub-Accesorios"
local HEADLESS_CLASSIC_HEAD_ID = 134082579
local HEADLESS_DYNAMIC_HEAD_ID = 15093053680
local KORBLOX_DEATHSPEAKER_RIGHT_LEG_ID = 139607718
local KORBLOX_DEATHWALKER_HEAD_ID = 16580493236

local COLORS = {
    Background = Color3.fromRGB(12, 12, 14),
    BackgroundAlt = Color3.fromRGB(18, 18, 22),
    Surface = Color3.fromRGB(26, 26, 32),
    SurfaceUp = Color3.fromRGB(36, 36, 44),
    Soft = Color3.fromRGB(190, 190, 198),
    Line = Color3.fromRGB(54, 54, 62),
    Border = Color3.fromRGB(74, 74, 84),
    Text = Color3.fromRGB(245, 245, 245),
    Muted = Color3.fromRGB(170, 170, 178),
    Good = Color3.fromRGB(160, 210, 175),
    Danger = Color3.fromRGB(230, 130, 130),
    DangerFill = Color3.fromRGB(95, 45, 45),
    AccentFill = Color3.fromRGB(42, 42, 48),
    ActiveFill = Color3.fromRGB(75, 75, 82),
}

local PRESETS = {
    {
        id = 215718515,
        name = "Fiery Horns of the Netherworld",
        description = "Cuernos Limited · accesorio original del catálogo.",
        aliases = { "fiery horns", "fiery", "cuernos de fuego", "netherworld horns" },
        accessoryType = Enum.AccessoryType.Hat,
        isLayered = false,
    },
    {
        id = 74891470,
        name = "Frozen Horns of the Frigid Planes",
        description = "Cuernos Limited · accesorio original del catálogo.",
        aliases = { "frozen horns", "frozen", "cuernos congelados", "frigid planes" },
        accessoryType = Enum.AccessoryType.Hat,
        isLayered = false,
    },
    {
        id = 1744060292,
        name = "Poisoned Horns of the Toxic Wasteland",
        description = "Cuernos Limited · accesorio original del catálogo.",
        aliases = { "poisoned horns", "poisoned", "toxic horns", "cuernos venenosos" },
        accessoryType = Enum.AccessoryType.Hat,
        isLayered = false,
    },
    {
        id = 76479271580913,
        name = "Stormbreak Horns of the Tempest Skies",
        description = "Cuernos eléctricos · accesorio original del catálogo.",
        aliases = { "stormbreak", "stormbreak horns", "electric horns", "cuernos electricos", "tempest skies" },
        accessoryType = Enum.AccessoryType.Hat,
        isLayered = false,
    },
    {
        id = 10159600649,
        name = "8-Bit Royal Crown",
        description = "Corona Limited · accesorio original del catálogo.",
        aliases = { "8-bit royal crown", "8 bit royal crown", "corona 8-bit", "corona 8 bit" },
        accessoryType = Enum.AccessoryType.Hat,
        isLayered = false,
    },
}

local BODY_PRESETS = {
    {
        key = "headless",
        name = "Headless Head",
        description = "Aplica la cabeza Headless actual mediante el sistema de avatar de Roblox.",
        aliases = { "headless", "headless head", "sin cabeza" },
        id = HEADLESS_DYNAMIC_HEAD_ID,
    },
    {
        key = "korbloxLeg",
        name = "Korblox Deathspeaker · pierna derecha",
        description = "Aplica la pieza corporal derecha usando HumanoidDescription.",
        aliases = { "korblox", "korblox leg", "korblox right leg", "korblox deathspeaker", "pierna korblox", "pierna derecha korblox" },
        id = KORBLOX_DEATHSPEAKER_RIGHT_LEG_ID,
    },
    {
        key = "deathwalkerEyes",
        name = "Korblox Deathwalker · ojos/efectos",
        description = "Head original de Roblox con sus ojos/llamas; sustituye la cabeza mientras esté activo.",
        aliases = { "deathwalker", "korblox deathwalker", "deathwalker eyes", "ojos deathwalker", "ojos korblox" },
        id = KORBLOX_DEATHWALKER_HEAD_ID,
    },
}

local ACCESSORY_TYPE_MAP = {
    Hat = "Hat",
    HairAccessory = "Hair",
    FaceAccessory = "Face",
    NeckAccessory = "Neck",
    ShoulderAccessory = "Shoulder",
    FrontAccessory = "Front",
    BackAccessory = "Back",
    WaistAccessory = "Waist",
    EyebrowAccessory = "Eyebrow",
    EyelashAccessory = "Eyelash",
    TShirtAccessory = "TShirt",
    ShirtAccessory = "Shirt",
    PantsAccessory = "Pants",
    JacketAccessory = "Jacket",
    SweaterAccessory = "Sweater",
    ShortsAccessory = "Shorts",
    LeftShoeAccessory = "LeftShoe",
    RightShoeAccessory = "RightShoe",
    DressSkirtAccessory = "DressSkirt",
}

local LAYERED_TYPES = {
    TShirt = true,
    Shirt = true,
    Pants = true,
    Jacket = true,
    Sweater = true,
    Shorts = true,
    LeftShoe = true,
    RightShoe = true,
    DressSkirt = true,
}

local state = {
    character = nil,
    humanoid = nil,
    baseDescription = nil,
    generation = 0,
    visualRevision = 0,
    visualTemplate = nil,
    visualTemplateKey = nil,
    baseDescriptionSignature = nil,
    characterConnections = {},
    bodyActive = { headless = false, korbloxLeg = false },
    deathwalkerEyesActive = false,
    accessoryOverrides = {},
    accessoryMeta = {},
    overlayModel = nil,
    overlayRoot = nil,
    overlayJointMap = nil,
    overlayOffsetY = 0,
    overlayFolder = nil,
    syncConnection = nil,
    cameraDescendantConnection = nil,
    cameraDescendantRemovingConnection = nil,
    hiddenCharacter = nil,
    hiddenStates = {},
    hiddenList = {},
    hiddenDescendantConnection = nil,
    hiddenDescendantRemovingConnection = nil,
    hiddenRenderStepName = "AvatarAccessoryVisibility_" .. tostring({}):gsub("[^%w]", ""),
    hiddenRenderStepBound = false,
    hiddenRenderConnection = nil,
    applying = false,
    busy = false,
    connections = {},
    uiConnections = {},
    dragConnections = {},
    resultConnections = {},
    gui = nil,
    main = nil,
    reopen = nil,
    statusLabel = nil,
    tabButtons = {},
    pages = {},
    presetButtons = {},
    bodyButtons = {},
    searchButtons = {},
    resultRows = {},
    searchHint = nil,
    searchInput = nil,
    searchResults = nil,
    canvasLayouts = {},
    favoriteItems = {},
    favoriteButtons = {},
    favoriteRows = {},
    favoriteConnections = {},
    equippedRows = {},
    equippedConnections = {},
    inventoryCache = { key = nil, items = {}, byId = {}, revision = 0 },
    actionButtons = {},
    refreshFavoriteButtons = nil,
    refreshFavoritesPage = nil,
    refreshEquipped = nil,
    showEquippedCompact = false,
}

local function addConnection(bucket, connection)
    table.insert(bucket, connection)
    return connection
end

local function disconnectBucket(bucket)
    for _, connection in ipairs(bucket) do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(bucket)
end

local function clearStatus()
    if state.statusLabel and state.statusLabel.Parent then
        state.statusLabel.Text = ""
    end
end

local function setStatus(message)
    if state.statusLabel and state.statusLabel.Parent then
        local status = (message == "Aplicado" or message == "Retirado" or message == "Fallo") and message or "Fallo"
        state.statusLabel.Text = status
        state.statusLabel.TextColor3 = status == "Fallo" and COLORS.Danger or COLORS.Good
    end
end

local function getCharacter()
    local character = state.character or localPlayer.Character
    if not character or not character.Parent then
        return nil, nil, nil
    end
    local humanoid = state.humanoid or character:FindFirstChildOfClass("Humanoid")
    local head = character:FindFirstChild("Head")
    return character, humanoid, head
end

local function isCharacterRigComplete(character, humanoid)
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

    for _, partName in ipairs(requiredParts) do
        local part = character:FindFirstChild(partName)
        if not (part and part:IsA("BasePart")) then
            return false
        end
    end
    return true
end

local function waitForCharacterRig(character, humanoid, timeout)
    if isCharacterRigComplete(character, humanoid) then
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
        if isCharacterRigComplete(character, humanoid) then
            finish()
        end
    end)

    if isCharacterRigComplete(character, humanoid) then
        finish()
    else
        task.delay(math.max(0.1, tonumber(timeout) or 2), finish)
        if not finished then
            signal.Event:Wait()
        end
    end

    if connection then connection:Disconnect() end
    signal:Destroy()
    return isCharacterRigComplete(character, humanoid)
end

local function enumName(value)
    if typeof(value) == "EnumItem" then
        return value.Name
    end
    local text = tostring(value or "")
    return text:match("%.([%w_]+)$") or text
end

local function normalizeText(value)
    value = tostring(value or ""):lower()
    value = value:gsub("á", "a"):gsub("é", "e"):gsub("í", "i"):gsub("ó", "o"):gsub("ú", "u")
    value = value:gsub("[^%w%s%-]", " "):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    return value
end

local function parseAssetId(value)
    local text = tostring(value or "")
    local digits = text:match("roblox%.com/catalog/(%d+)") or text:match("roblox%.com/bundles/(%d+)") or text:match("(%d+)")
    return digits and tonumber(digits) or nil
end

local function cloneAccessoryInfo(info)
    local output = {}
    for _, property in ipairs({ "AssetId", "AccessoryType", "IsLayered", "Order", "Puffiness", "Position", "Rotation", "Scale" }) do
        local ok, value = pcall(function() return info[property] end)
        if ok and value ~= nil then output[property] = value end
    end
    return output
end

local function getBaselineAccessoryData(description)
    local accessories = {}
    local ids = {}
    local maxOrder = 0
    local ok, result = pcall(function()
        return description:GetAccessories(true)
    end)
    if not ok or type(result) ~= "table" then
        return nil, nil, 0, "Roblox no devolvió los accesorios de HumanoidDescription."
    end

    for _, info in ipairs(result) do
        local copy = cloneAccessoryInfo(info)
        local id = tonumber(copy.AssetId)
        if id then
            ids[math.floor(id)] = true
            table.insert(accessories, copy)
            local order = tonumber(copy.Order)
            if order and order > maxOrder then maxOrder = order end
        end
    end
    return accessories, ids, maxOrder
end

local function mapAccessoryType(assetTypeValue)
    local assetTypeName = enumName(assetTypeValue)
    local accessoryTypeName = ACCESSORY_TYPE_MAP[assetTypeName]
    if not accessoryTypeName then return nil, false end

    local ok, accessoryType = pcall(function()
        return Enum.AccessoryType[accessoryTypeName]
    end)
    if not ok or not accessoryType then return nil, false end
    return accessoryType, LAYERED_TYPES[accessoryTypeName] == true
end

local function findFixedPresetByName(query)
    local normalized = normalizeText(query)
    if normalized == "" then return nil end

    for _, preset in ipairs(PRESETS) do
        if normalizeText(preset.name) == normalized then
            return { type = "accessory", id = preset.id, name = preset.name, accessoryType = preset.accessoryType, isLayered = false }
        end
        for _, alias in ipairs(preset.aliases or {}) do
            if normalizeText(alias) == normalized then
                return { type = "accessory", id = preset.id, name = preset.name, accessoryType = preset.accessoryType, isLayered = false }
            end
        end
    end

    for _, preset in ipairs(BODY_PRESETS) do
        if normalizeText(preset.name) == normalized or normalizeText(preset.key) == normalized then
            return { type = preset.key, id = preset.id, name = preset.name }
        end
        for _, alias in ipairs(preset.aliases or {}) do
            if normalizeText(alias) == normalized then
                return { type = preset.key, id = preset.id, name = preset.name }
            end
        end
    end
    return nil
end

local function findFixedPresetById(assetId)
    assetId = tonumber(assetId)
    if not assetId then return nil end
    for _, preset in ipairs(PRESETS) do
        if preset.id == assetId then
            return { type = "accessory", id = preset.id, name = preset.name, accessoryType = preset.accessoryType, isLayered = false }
        end
    end
    if assetId == HEADLESS_CLASSIC_HEAD_ID or assetId == HEADLESS_DYNAMIC_HEAD_ID then
        return { type = "headless", id = HEADLESS_DYNAMIC_HEAD_ID, name = "Headless Head" }
    end
    if assetId == KORBLOX_DEATHSPEAKER_RIGHT_LEG_ID then
        return { type = "korbloxLeg", id = KORBLOX_DEATHSPEAKER_RIGHT_LEG_ID, name = "Korblox Deathspeaker · pierna derecha" }
    end
    if assetId == KORBLOX_DEATHWALKER_HEAD_ID then
        return { type = "deathwalkerEyes", id = KORBLOX_DEATHWALKER_HEAD_ID, name = "Korblox Deathwalker · ojos/efectos" }
    end
    return nil
end

local function getCurrentBaseDescription(humanoid)
    if not humanoid or not humanoid.Parent then
        return nil, "No se encontró el Humanoid actual."
    end
    local ok, description = pcall(function()
        return humanoid:GetAppliedDescription()
    end)
    if ok and description then
        return description
    end

    local ok2, fallback = pcall(function()
        return Players:GetHumanoidDescriptionFromUserIdAsync(localPlayer.UserId)
    end)
    if ok2 and fallback then return fallback end
    return nil, "No se pudo obtener la apariencia base de Roblox. " .. tostring(description or fallback)
end

local DESCRIPTION_SIGNATURE_FIELDS = {
    "Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg", "Face",
    "Shirt", "Pants", "GraphicTShirt", "BodyTypeScale", "ProportionScale",
    "HeightScale", "WidthScale", "DepthScale", "HeadScale", "IdleAnimation",
    "WalkAnimation", "RunAnimation", "JumpAnimation", "FallAnimation",
    "ClimbAnimation", "SwimAnimation",
}

local function getDescriptionSignature(description)
    if not description or not description:IsA("HumanoidDescription") then
        return nil
    end

    local values = {}
    for _, propertyName in ipairs(DESCRIPTION_SIGNATURE_FIELDS) do
        local ok, value = pcall(function()
            return description[propertyName]
        end)
        if ok then
            values[#values + 1] = propertyName .. "=" .. tostring(value)
        end
    end

    for _, propertyName in ipairs({ "HeadColor", "TorsoColor", "LeftArmColor", "RightArmColor", "LeftLegColor", "RightLegColor" }) do
        local ok, color = pcall(function()
            return description[propertyName]
        end)
        if ok and typeof(color) == "Color3" then
            values[#values + 1] = propertyName .. string.format("=%.4f,%.4f,%.4f", color.R, color.G, color.B)
        end
    end

    local accessories = {}
    local okAccessories, resultAccessories = pcall(function()
        return description:GetAccessories(true)
    end)
    if okAccessories and type(resultAccessories) == "table" then
        for _, item in ipairs(resultAccessories) do
            local accessoryType = item.AccessoryType
            local typeName = typeof(accessoryType) == "EnumItem" and accessoryType.Name or tostring(accessoryType)
            accessories[#accessories + 1] = table.concat({
                tostring(item.AssetId or 0),
                typeName,
                tostring(item.IsLayered == true),
                tostring(item.Order or 0),
            }, ":")
        end
        table.sort(accessories)
    end

    return table.concat(values, "|") .. "|Accessories=" .. table.concat(accessories, ",")
end

local function clearVisualTemplate()
    if state.visualTemplate then
        pcall(function() state.visualTemplate:Destroy() end)
        state.visualTemplate = nil
    end
    state.visualTemplateKey = nil
end

local function bumpVisualRevision()
    state.visualRevision += 1
    if state.inventoryCache then
        state.inventoryCache.key = nil
    end
    if avatarBridge.accessory.owner == accessoryBridgeToken then
        avatarBridge.accessory.revision = state.visualRevision
        avatarBridge.accessory.inventoryRevision = (tonumber(avatarBridge.accessory.inventoryRevision) or 0) + 1
    end
end

local function getVisualTemplateKey(humanoid)
    local rigName = humanoid and humanoid.RigType and humanoid.RigType.Name or "Unknown"
    return table.concat({
        tostring(state.visualRevision),
        tostring(state.baseDescriptionSignature or "base-unavailable"),
        rigName,
    }, "|")
end

local function getActiveAppearanceBaseDescription()
    if isSkinRendererActive() and type(avatarBridge.skin.getBaseDescription) == "function" then
        local ok, description = pcall(avatarBridge.skin.getBaseDescription)
        if ok and description and description:IsA("HumanoidDescription") then
            return description
        end
    end
    return state.baseDescription
end

local function isAccessoryDesired(assetId, baselineDescription)
    assetId = math.floor(tonumber(assetId) or 0)
    local override = state.accessoryOverrides[assetId]
    if override ~= nil then return override end
    local sourceDescription = baselineDescription or getActiveAppearanceBaseDescription()
    if not sourceDescription then return false end
    local _, ids = getBaselineAccessoryData(sourceDescription)
    return ids and ids[assetId] == true or false
end

local function applyAccessoryOverridesToDescription(description, rigType)
    if not description or not description:IsA("HumanoidDescription") then
        return nil, "Descripción de avatar no válida."
    end

    if state.deathwalkerEyesActive then
        description.Head = KORBLOX_DEATHWALKER_HEAD_ID
        description.Face = 0
    elseif state.bodyActive.headless then
        local useClassicHead = rigType == "R6" or rigType == Enum.HumanoidRigType.R6
        if rigType == nil then
            local _, activeHumanoid = getCharacter()
            useClassicHead = activeHumanoid and activeHumanoid.RigType == Enum.HumanoidRigType.R6 or false
        end
        description.Head = useClassicHead and HEADLESS_CLASSIC_HEAD_ID or HEADLESS_DYNAMIC_HEAD_ID
        description.Face = 0
    end

    if state.bodyActive.korbloxLeg then
        description.RightLeg = KORBLOX_DEATHSPEAKER_RIGHT_LEG_ID
    end

    local baseAccessories, _, maxOrder, accessoryError = getBaselineAccessoryData(description)
    if not baseAccessories then
        return nil, accessoryError
    end

    local resultAccessories = {}
    local includedIds = {}

    for _, info in ipairs(baseAccessories) do
        local assetId = math.floor(tonumber(info.AssetId) or 0)
        local override = state.accessoryOverrides[assetId]
        if assetId > 0 and override ~= false then
            table.insert(resultAccessories, info)
            includedIds[assetId] = true
        end
    end

    for assetId, enabled in pairs(state.accessoryOverrides) do
        assetId = math.floor(tonumber(assetId) or 0)
        if enabled == true and assetId > 0 and not includedIds[assetId] then
            local meta = state.accessoryMeta[assetId]
            if not meta or not meta.accessoryType then
                return nil, "Falta verificar el tipo de accesorio para el ID " .. tostring(assetId) .. "."
            end

            local entry = {
                AssetId = assetId,
                AccessoryType = meta.accessoryType,
                IsLayered = meta.isLayered == true,
            }
            if meta.isLayered then
                maxOrder += 1
                entry.Order = maxOrder
            end
            table.insert(resultAccessories, entry)
            includedIds[assetId] = true
        end
    end

    local okSet, setError = pcall(function()
        description:SetAccessories(resultAccessories, true)
    end)
    if not okSet then
        return nil, "Roblox rechazó la lista de accesorios: " .. tostring(setError)
    end

    return description
end

local function buildDesiredDescription(baseDescription, rigType)
    local sourceDescription = baseDescription or state.baseDescription
    if not sourceDescription then
        return nil, "La apariencia base todavía no está lista."
    end

    local okClone, description = pcall(function()
        return sourceDescription:Clone()
    end)
    if not okClone or not description then
        return nil, "No se pudo clonar HumanoidDescription."
    end

    local composed, composeError = applyAccessoryOverridesToDescription(description, rigType)
    if not composed then
        pcall(function() description:Destroy() end)
        return nil, composeError
    end

    return description
end

local function hasVisualChanges()
    if state.bodyActive.headless or state.bodyActive.korbloxLeg or state.deathwalkerEyesActive then
        return true
    end
    for _, value in pairs(state.accessoryOverrides) do
        if value ~= nil then return true end
    end
    return false
end

local function isNativeEffect(instance)
    return instance:IsA("ParticleEmitter")
        or instance:IsA("Trail")
        or instance:IsA("Beam")
        or instance:IsA("Fire")
        or instance:IsA("Smoke")
        or instance:IsA("Sparkles")
        or instance:IsA("Light")
end

local function isToolDescendant(instance)
    local current = instance.Parent
    while current do
        if current:IsA("Tool") then return true end
        current = current.Parent
    end
    return false
end

local function getCameraFolder()
    local camera = Workspace.CurrentCamera
    if not camera then return nil end
    if state.overlayFolder and state.overlayFolder.Parent ~= camera then
        pcall(function() state.overlayFolder.Parent = camera end)
    end
    if not state.overlayFolder or not state.overlayFolder.Parent then
        local existing = camera:FindFirstChild("AvatarAccessoryVisuals")
        if existing and existing:IsA("Folder") then
            state.overlayFolder = existing
        else
            state.overlayFolder = Instance.new("Folder")
            state.overlayFolder.Name = "AvatarAccessoryVisuals"
            state.overlayFolder.Parent = camera
        end
    end
    return state.overlayFolder
end

local function isInsideAccessoryOrTool(instance)
    local ancestor = instance.Parent
    while ancestor do
        if ancestor:IsA("Accessory") or ancestor:IsA("Tool") then
            return true
        end
        ancestor = ancestor.Parent
    end
    return false
end

local function getJointEndpoints(joint)
    if joint:IsA("Motor6D") then
        if joint.Part0 and joint.Part1 then
            return joint.Part0, joint.Part1, joint.C0, joint.C1
        end
    elseif joint:IsA("AnimationConstraint") then
        local attachment0 = joint.Attachment0
        local attachment1 = joint.Attachment1
        if attachment0 and attachment1
            and attachment0.Parent and attachment0.Parent:IsA("BasePart")
            and attachment1.Parent and attachment1.Parent:IsA("BasePart") then
            return attachment0.Parent, attachment1.Parent, attachment0.CFrame, attachment1.CFrame
        end
    end
    return nil
end

local function jointKey(joint, part0, part1)
    return joint.Name .. "|" .. part0.Name .. "|" .. part1.Name
end

local function collectJointMap(model)
    local joints = { byKey = {}, byName = {} }
    for _, descendant in ipairs(model:GetDescendants()) do
        if (descendant:IsA("Motor6D") or descendant:IsA("AnimationConstraint"))
            and not isInsideAccessoryOrTool(descendant) then
            local part0, part1 = getJointEndpoints(descendant)
            if part0 and part1 then
                local key = jointKey(descendant, part0, part1)
                joints.byKey[key] = joints.byKey[key] or descendant
                joints.byName[descendant.Name] = joints.byName[descendant.Name] or descendant
            end
        end
    end
    return joints
end

local function getFootDepth(model, rootPart)
    local lowestY = 0
    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("BasePart") and descendant ~= rootPart
            and not descendant:FindFirstAncestorOfClass("Accessory")
            and not descendant:FindFirstAncestorOfClass("Tool") then
            local relative = rootPart.CFrame:ToObjectSpace(descendant.CFrame)
            local bottom = relative.Position.Y - descendant.Size.Y * 0.5
            if bottom < lowestY then lowestY = bottom end
        end
    end
    return -lowestY
end

local function createModelFromDescription(description, rigType)
    local ok, model = pcall(function()
        return Players:CreateHumanoidModelFromDescriptionAsync(description, rigType)
    end)
    if not (ok and model) then
        ok, model = pcall(function()
            return Players:CreateHumanoidModelFromDescription(description, rigType)
        end)
    end
    if not (ok and model) then
        return nil, tostring(model)
    end
    return model
end

local function buildAccessorySyncPlan(model, rootPart, bodyParts)
    local plan = {}
    for _, accessory in ipairs(model:GetChildren()) do
        if accessory:IsA("Accessory") then
            local handle = accessory:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then
                local matchedBodyPart, bodyAttachment, handleAttachment
                for _, item in ipairs(handle:GetDescendants()) do
                    if item:IsA("Attachment") then
                        for _, bodyPart in pairs(bodyParts) do
                            local candidate = bodyPart:FindFirstChild(item.Name)
                            if candidate and candidate:IsA("Attachment") then
                                matchedBodyPart = bodyPart
                                bodyAttachment = candidate
                                handleAttachment = item
                                break
                            end
                        end
                    end
                    if matchedBodyPart then break end
                end

                local entry = {
                    handle = handle,
                    bodyPart = matchedBodyPart,
                    bodyAttachmentCFrame = bodyAttachment and bodyAttachment.CFrame or nil,
                    handleAttachmentCFrame = handleAttachment and handleAttachment.CFrame or nil,
                    rootRelative = rootPart.CFrame:ToObjectSpace(handle.CFrame),
                    extraParts = {},
                }
                for _, part in ipairs(accessory:GetDescendants()) do
                    if part:IsA("BasePart") and part ~= handle then
                        table.insert(entry.extraParts, {
                            part = part,
                            relative = handle.CFrame:ToObjectSpace(part.CFrame),
                        })
                    end
                end
                table.insert(plan, entry)
            end
        end
    end
    return plan
end

local function buildRigSyncPlan(sourceCharacter, visualModel, rootPart)
    local sourceJoints = collectJointMap(sourceCharacter)
    local bodyParts = {}
    for _, child in ipairs(visualModel:GetChildren()) do
        if child:IsA("BasePart") then
            bodyParts[child.Name] = child
        end
    end

    local pending = {}
    for _, descendant in ipairs(visualModel:GetDescendants()) do
        if (descendant:IsA("Motor6D") or descendant:IsA("AnimationConstraint"))
            and not isInsideAccessoryOrTool(descendant) then
            local part0, part1, c0, c1 = getJointEndpoints(descendant)
            if part0 and part1 and c0 and c1 then
                local key = jointKey(descendant, part0, part1)
                local sourceJoint = sourceJoints.byKey[key] or sourceJoints.byName[descendant.Name]
                table.insert(pending, {
                    from = part0,
                    to = part1,
                    c0 = c0,
                    c1 = c1,
                    source = sourceJoint,
                    name = descendant.Name,
                })
            end
        end
    end

    local ordered = {}
    local reached = { [rootPart] = true }
    while #pending > 0 do
        local progressed = false
        for i = #pending, 1, -1 do
            local link = pending[i]
            if reached[link.from] then
                link.reverse = false
                table.insert(ordered, link)
                reached[link.to] = true
                table.remove(pending, i)
                progressed = true
            elseif reached[link.to] then
                link.reverse = true
                table.insert(ordered, link)
                reached[link.from] = true
                table.remove(pending, i)
                progressed = true
            end
        end
        if not progressed then break end
    end

    local fallbackParts = {}
    for _, descendant in ipairs(visualModel:GetDescendants()) do
        if descendant:IsA("BasePart")
            and descendant ~= rootPart
            and not isInsideAccessoryOrTool(descendant)
            and not reached[descendant] then
            table.insert(fallbackParts, {
                part = descendant,
                relative = rootPart.CFrame:ToObjectSpace(descendant.CFrame),
            })
        end
    end

    local accessoryPlan = buildAccessorySyncPlan(visualModel, rootPart, bodyParts)
    local allParts = {}
    for _, descendant in ipairs(visualModel:GetDescendants()) do
        if descendant:IsA("BasePart") then
            table.insert(allParts, descendant)
        end
    end

    for _, descendant in ipairs(visualModel:GetDescendants()) do
        if (descendant:IsA("JointInstance") or descendant:IsA("Constraint"))
            and not isInsideAccessoryOrTool(descendant) then
            pcall(function() descendant:Destroy() end)
        end
    end

    return {
        joints = ordered,
        accessories = accessoryPlan,
        fallbackParts = fallbackParts,
        allParts = allParts,
    }
end

local function prepareVisualModel(model, sourceCharacter)
    local rootPart = model:FindFirstChild("HumanoidRootPart")
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if not rootPart or not rootPart:IsA("BasePart") or not humanoid then
        model:Destroy()
        return nil, nil, "Roblox no generó un rig con HumanoidRootPart y Humanoid."
    end

    local syncPlan = buildRigSyncPlan(sourceCharacter, model, rootPart)

    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("BaseScript") then
            pcall(function() descendant.Disabled = true end)
        end
    end

    pcall(function() humanoid.PlatformStand = true end)
    pcall(function() humanoid.AutoRotate = false end)
    pcall(function() humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end)
    pcall(function() humanoid.EvaluateStateMachine = false end)
    pcall(function() humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false) end)
    pcall(function() humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false) end)
    pcall(function() humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false) end)
    pcall(function() humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false) end)
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if animator then pcall(function() animator:Destroy() end) end

    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("BasePart") then
            pcall(function()
                descendant.Anchored = true
                descendant.CanCollide = false
                descendant.CanTouch = false
                descendant.CanQuery = false
                descendant.Massless = true
                descendant.AssemblyLinearVelocity = Vector3.zero
                descendant.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end
    rootPart.Anchored = true
    pcall(function()
        rootPart.CanCollide = false
        rootPart.CanTouch = false
        rootPart.CanQuery = false
    end)

    if state.bodyActive.headless and not state.deathwalkerEyesActive then
        local head = model:FindFirstChild("Head")
        if head and head:IsA("BasePart") then
            pcall(function() head.LocalTransparencyModifier = 1 end)
            for _, visual in ipairs(head:GetDescendants()) do
                if visual:IsA("Decal") or visual:IsA("Texture") then
                    pcall(function() visual.Transparency = 1 end)
                end
            end
        end
    end

    model.PrimaryPart = rootPart
    model.Name = "AvatarAccessoryVisual"
    return rootPart, syncPlan
end

local function syncVisualPose(rootPart, syncPlan, sourceRoot, footOffset)
    if not (rootPart and rootPart.Parent and sourceRoot and sourceRoot.Parent) then return end

    for _, part in ipairs(syncPlan.allParts) do
        if part and part.Parent then
            pcall(function()
                if not part.Anchored then part.Anchored = true end
                if part.CanCollide then part.CanCollide = false end
                if part.CanTouch then part.CanTouch = false end
                if part.CanQuery then part.CanQuery = false end
            end)
        end
    end

    rootPart.CFrame = CFrame.new(0, footOffset, 0) * sourceRoot.CFrame

    for _, link in ipairs(syncPlan.joints) do
        if link.from and link.to and link.from.Parent and link.to.Parent then
            local transform = CFrame.identity
            if link.source and link.source.Parent then
                pcall(function() transform = link.source.Transform end)
            end
            pcall(function()
                if link.reverse then
                    link.from.CFrame = link.to.CFrame * link.c1 * transform:Inverse() * link.c0:Inverse()
                else
                    link.to.CFrame = link.from.CFrame * link.c0 * transform * link.c1:Inverse()
                end
            end)
        end
    end

    for _, accessory in ipairs(syncPlan.accessories) do
        local handle = accessory.handle
        if handle and handle.Parent then
            if accessory.bodyPart and accessory.bodyPart.Parent
                and accessory.bodyAttachmentCFrame and accessory.handleAttachmentCFrame then
                pcall(function()
                    handle.CFrame = accessory.bodyPart.CFrame
                        * accessory.bodyAttachmentCFrame
                        * accessory.handleAttachmentCFrame:Inverse()
                end)
            else
                pcall(function() handle.CFrame = rootPart.CFrame * accessory.rootRelative end)
            end
            for _, item in ipairs(accessory.extraParts) do
                if item.part and item.part.Parent then
                    pcall(function() item.part.CFrame = handle.CFrame * item.relative end)
                end
            end
        end
    end

    for _, item in ipairs(syncPlan.fallbackParts) do
        if item.part and item.part.Parent then
            pcall(function() item.part.CFrame = rootPart.CFrame * item.relative end)
        end
    end
end

local function restoreHiddenDescendant(instance)
    local saved = state.hiddenStates[instance]
    if saved then
        if instance then
            pcall(function()
                if saved.kind == "part" then
                    instance.LocalTransparencyModifier = saved.value
                elseif saved.kind == "texture" then
                    instance.Transparency = saved.value
                elseif saved.kind == "effect" then
                    instance.Enabled = saved.value
                end
            end)
        end
        state.hiddenStates[instance] = nil
    end
    for index = #state.hiddenList, 1, -1 do
        if state.hiddenList[index] == instance then
            table.remove(state.hiddenList, index)
            break
        end
    end
end

local function hideOriginalDescendant(character, descendant)
    if not descendant or not descendant.Parent or isToolDescendant(descendant) then return end
    if descendant:IsA("BasePart") then
        if descendant.Name == "HumanoidRootPart" then return end
        local saved = state.hiddenStates[descendant]
        if not saved then
            local ok, modifier = pcall(function() return descendant.LocalTransparencyModifier end)
            if ok then
                saved = { kind = "part", value = modifier }
                state.hiddenStates[descendant] = saved
                table.insert(state.hiddenList, descendant)
            end
        end
        pcall(function() descendant.LocalTransparencyModifier = 1 end)
    elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
        local saved = state.hiddenStates[descendant]
        if not saved then
            saved = { kind = "texture", value = descendant.Transparency }
            state.hiddenStates[descendant] = saved
            table.insert(state.hiddenList, descendant)
        end
        pcall(function() descendant.Transparency = 1 end)
    elseif isNativeEffect(descendant) or descendant:IsA("BillboardGui") or descendant:IsA("SurfaceGui") then
        local saved = state.hiddenStates[descendant]
        if not saved then
            local ok, enabled = pcall(function() return descendant.Enabled end)
            if ok then
                saved = { kind = "effect", value = enabled }
                state.hiddenStates[descendant] = saved
                table.insert(state.hiddenList, descendant)
            end
        end
        pcall(function() descendant.Enabled = false end)
        if descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") then
            pcall(function() descendant:Clear() end)
        end
    end
end

local function enforceOriginalCharacterHidden()
    local character = state.hiddenCharacter
    if not character or not character.Parent then return end
    for _, instance in ipairs(state.hiddenList) do
        local saved = state.hiddenStates[instance]
        if saved and instance.Parent then
            pcall(function()
                if saved.kind == "part" then
                    if instance.LocalTransparencyModifier < 1 then
                        instance.LocalTransparencyModifier = 1
                    end
                elseif saved.kind == "texture" then
                    if instance.Transparency < 1 then
                        instance.Transparency = 1
                    end
                elseif saved.kind == "effect" and instance.Enabled then
                    instance.Enabled = false
                end
            end)
        end
    end
end

local function bindOriginalCharacterVisibility()
    if state.hiddenRenderStepBound or state.hiddenRenderConnection then return end
    local ok = pcall(function()
        RunService:BindToRenderStep(
            state.hiddenRenderStepName,
            Enum.RenderPriority.Last.Value,
            enforceOriginalCharacterHidden
        )
    end)
    if ok then
        state.hiddenRenderStepBound = true
    else
        state.hiddenRenderConnection = RunService.RenderStepped:Connect(enforceOriginalCharacterHidden)
    end
end

local function restoreOriginalCharacter()
    if state.hiddenRenderStepBound then
        pcall(function() RunService:UnbindFromRenderStep(state.hiddenRenderStepName) end)
        state.hiddenRenderStepBound = false
    end
    if state.hiddenRenderConnection then
        pcall(function() state.hiddenRenderConnection:Disconnect() end)
        state.hiddenRenderConnection = nil
    end
    if state.hiddenDescendantConnection then
        pcall(function() state.hiddenDescendantConnection:Disconnect() end)
        state.hiddenDescendantConnection = nil
    end
    if state.hiddenDescendantRemovingConnection then
        pcall(function() state.hiddenDescendantRemovingConnection:Disconnect() end)
        state.hiddenDescendantRemovingConnection = nil
    end
    for index = #state.hiddenList, 1, -1 do
        restoreHiddenDescendant(state.hiddenList[index])
    end
    table.clear(state.hiddenList)
    state.hiddenCharacter = nil
end

local function hideOriginalCharacter(character)
    if state.hiddenCharacter ~= character then
        restoreOriginalCharacter()
        state.hiddenCharacter = character
        state.hiddenDescendantConnection = character.DescendantAdded:Connect(function(descendant)
            hideOriginalDescendant(character, descendant)
        end)
        state.hiddenDescendantRemovingConnection = character.DescendantRemoving:Connect(function()
            task.defer(function()
                if state.hiddenCharacter ~= character then return end
                for index = #state.hiddenList, 1, -1 do
                    local instance = state.hiddenList[index]
                    if not instance:IsDescendantOf(character) or isToolDescendant(instance) then
                        restoreHiddenDescendant(instance)
                    end
                end
            end)
        end)
        for _, descendant in ipairs(character:GetDescendants()) do
            hideOriginalDescendant(character, descendant)
        end
    end
    bindOriginalCharacterVisibility()
    enforceOriginalCharacterHidden()
end

local function createNativeCameraTransparencyUpdater(model, beforeTrack)
    local entries = {}
    local tracked = setmetatable({}, { __mode = "k" })
    local lastTransparency = nil
    local lastUpdate = os.clock()
    local lastPrune = lastUpdate
    local MAX_TWEEN_RATE = 2.8

    local function restoreEntry(entry)
        local instance = entry.instance
        pcall(function()
            if entry.kind == "modifier" then
                instance.LocalTransparencyModifier = entry.originalModifier or 0
            elseif entry.kind == "textureTransparency" then
                instance.Transparency = entry.originalTransparency or 0
            elseif entry.kind == "sequence" then
                instance.Transparency = entry.originalTransparency
                instance.Enabled = entry.originalEnabled
            elseif entry.kind == "enabled" then
                instance.Enabled = entry.originalEnabled
            end
        end)
    end

    local function untrack(instance)
        if not tracked[instance] then return end
        for index = #entries, 1, -1 do
            if entries[index].instance == instance then
                restoreEntry(entries[index])
                table.remove(entries, index)
                break
            end
        end
        tracked[instance] = nil
    end

    local function track(instance)
        if tracked[instance] or isToolDescendant(instance) then return end
        local entry = { instance = instance }
        if instance:IsA("BasePart") or instance:IsA("Decal") or instance:IsA("Texture") then
            local ok, originalModifier = pcall(function()
                return instance.LocalTransparencyModifier
            end)
            if ok then
                entry.kind = "modifier"
                entry.originalModifier = originalModifier
            elseif instance:IsA("Decal") or instance:IsA("Texture") then
                entry.kind = "textureTransparency"
                entry.originalTransparency = instance.Transparency
            else
                return
            end
        elseif instance:IsA("ParticleEmitter") or instance:IsA("Trail") or instance:IsA("Beam") then
            entry.kind = "sequence"
            entry.originalEnabled = instance.Enabled
            entry.originalTransparency = instance.Transparency
        elseif isNativeEffect(instance) or instance:IsA("BillboardGui") or instance:IsA("SurfaceGui") then
            local ok, enabled = pcall(function() return instance.Enabled end)
            if not ok then return end
            entry.kind = "enabled"
            entry.originalEnabled = enabled
        else
            return
        end
        tracked[instance] = true
        table.insert(entries, entry)
    end

    if type(beforeTrack) == "function" then
        pcall(beforeTrack)
    end
    for _, descendant in ipairs(model:GetDescendants()) do
        track(descendant)
    end

    local function getTargetTransparency()
        local camera = Workspace.CurrentCamera
        local target = 0
        if camera then
            if localPlayer.CameraMode == Enum.CameraMode.LockFirstPerson then
                target = 1
            else
                local distance = (camera.Focus.Position - camera.CFrame.Position).Magnitude
                if distance >= 2 then
                    local reference = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
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
                if distance < 2 then
                    target = 1 - (distance - 0.5) / 1.5
                end
                if target < 0.5 then target = 0 end
            end
        end

        target = math.clamp(target, 0, 1)
        local now = os.clock()
        local deltaTime = math.max(0, now - lastUpdate)
        lastUpdate = now

        if lastTransparency ~= nil and target < 1 and lastTransparency < 0.95 then
            local maxDelta = MAX_TWEEN_RATE * deltaTime
            local deltaTransparency = math.clamp(target - lastTransparency, -maxDelta, maxDelta)
            target = lastTransparency + deltaTransparency
        end

        target = math.clamp(math.floor(target * 100 + 0.5) / 100, 0, 1)
        lastTransparency = target
        return target
    end

    local function applyVisual(entry, transparency)
        local instance = entry.instance
        if not instance.Parent or not instance:IsDescendantOf(model) or isToolDescendant(instance) then
            return
        end

        local firstPerson = transparency >= 0.995
        if entry.kind == "modifier" then
            local desired = math.max(entry.originalModifier or 0, transparency)
            if entry.lastApplied ~= desired then
                local ok = pcall(function()
                    instance.LocalTransparencyModifier = desired
                end)
                if ok then entry.lastApplied = desired end
            end
        elseif entry.kind == "textureTransparency" then
            local originalTransparency = entry.originalTransparency or 0
            local desired = 1 - ((1 - originalTransparency) * (1 - transparency))
            if entry.lastApplied ~= desired then
                pcall(function() instance.Transparency = desired end)
                entry.lastApplied = desired
            end
        elseif entry.kind == "sequence" then
            if entry.hidden ~= firstPerson then
                if firstPerson then
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
                entry.hidden = firstPerson
            end
        elseif entry.kind == "enabled" then
            if entry.hidden ~= firstPerson then
                pcall(function()
                    if firstPerson then
                        instance.Enabled = false
                    else
                        instance.Enabled = entry.originalEnabled
                    end
                end)
                entry.hidden = firstPerson
            end
        end
    end

    local function update()
        if not model.Parent then return false end
        local transparency = getTargetTransparency()
        local firstPerson = transparency >= 0.995
        local now = os.clock()
        if now - lastPrune >= 2 then
            lastPrune = now
            for index = #entries, 1, -1 do
                local entry = entries[index]
                local instance = entry.instance
                if not instance:IsDescendantOf(model) or isToolDescendant(instance) then
                    restoreEntry(entry)
                    tracked[instance] = nil
                    table.remove(entries, index)
                end
            end
        end
        for _, entry in ipairs(entries) do
            applyVisual(entry, transparency)
        end
        return firstPerson
    end

    local descendantConnection = model.DescendantAdded:Connect(function(descendant)
        if type(beforeTrack) == "function" then
            pcall(beforeTrack, descendant)
        end
        track(descendant)
    end)
    local descendantRemovingConnection = model.DescendantRemoving:Connect(function(descendant)
        if not tracked[descendant] then return end
        task.defer(function()
            if tracked[descendant]
                and (not descendant:IsDescendantOf(model) or isToolDescendant(descendant)) then
                untrack(descendant)
            end
        end)
    end)

    update()
    return update, descendantConnection, descendantRemovingConnection
end

local function disposeVisualOverlay(restoreOriginal)
    if state.syncConnection then
        pcall(function() state.syncConnection:Disconnect() end)
        state.syncConnection = nil
    end
    if state.cameraDescendantConnection then
        pcall(function() state.cameraDescendantConnection:Disconnect() end)
        state.cameraDescendantConnection = nil
    end
    if state.cameraDescendantRemovingConnection then
        pcall(function() state.cameraDescendantRemovingConnection:Disconnect() end)
        state.cameraDescendantRemovingConnection = nil
    end
    if state.overlayModel then
        pcall(function() state.overlayModel:Destroy() end)
        state.overlayModel = nil
    end
    state.overlayRoot = nil
    state.overlayJointMap = nil
    if restoreOriginal then restoreOriginalCharacter() end
    if state.overlayFolder and state.overlayFolder.Parent then
        pcall(function() state.overlayFolder:Destroy() end)
    end
    state.overlayFolder = nil
end

local function isActivatableNativeEffect(instance)
    return instance:IsA("ParticleEmitter")
        or instance:IsA("Trail")
        or instance:IsA("Beam")
        or instance:IsA("Fire")
        or instance:IsA("Smoke")
        or instance:IsA("Sparkles")
        or instance:IsA("PointLight")
        or instance:IsA("SpotLight")
        or instance:IsA("SurfaceLight")
        or instance:IsA("BillboardGui")
        or instance:IsA("SurfaceGui")
end

local function enableNativeEffect(instance)
    if not instance or not instance.Parent or not isActivatableNativeEffect(instance)
        or isToolDescendant(instance) then
        return false
    end
    local ok, enabled = pcall(function() return instance.Enabled end)
    if not ok or enabled then return false end
    return pcall(function() instance.Enabled = true end)
end

local function enableNativeEffectsIn(container)
    if not container then return 0 end
    local activated = 0
    for _, descendant in ipairs(container:GetDescendants()) do
        if enableNativeEffect(descendant) then
            activated += 1
        end
    end
    return activated
end

local function activateSelectedNativeEffects(model)

    return enableNativeEffectsIn(model)
end

local function countNativeEffects(model)
    local counts = { particles = 0, trails = 0, beams = 0, lights = 0, other = 0, disabled = 0 }
    for _, item in ipairs(model:GetDescendants()) do
        if item:IsA("ParticleEmitter") then
            counts.particles += 1
        elseif item:IsA("Trail") then
            counts.trails += 1
        elseif item:IsA("Beam") then
            counts.beams += 1
        elseif item:IsA("Light") then
            counts.lights += 1
        elseif item:IsA("Fire") or item:IsA("Smoke") or item:IsA("Sparkles") then
            counts.other += 1
        end
        if isActivatableNativeEffect(item) then
            local ok, enabled = pcall(function() return item.Enabled end)
            if ok and not enabled then counts.disabled += 1 end
        end
    end
    return counts
end

local function applyCurrentAppearance()
    if state.applying then
        return false, "Ya hay una actualización de apariencia en curso."
    end
    local character, humanoid = getCharacter()
    if not character or not humanoid then
        return false, "No se encontró el personaje o Humanoid actual."
    end
    if isSkinRendererActive() then
        if state.overlayModel then
            disposeVisualOverlay(false)
        end
        local refreshSkin = avatarBridge.skin.refresh
        if type(refreshSkin) ~= "function" then
            state.applying = false
            return false, "No se pudo sincronizar la apariencia."
        end
        local refreshOk, refreshResult = pcall(refreshSkin)
        state.applying = false
        if not refreshOk or refreshResult == false then
            return false, "No se pudo sincronizar la apariencia."
        end
        return true, "Apariencia sincronizada."
    end

    if not hasVisualChanges() then
        disposeVisualOverlay(true)
        return true, "Apariencia original restaurada; no quedan modificaciones activas."
    end
    local generation = state.generation
    state.applying = true
    if not waitForCharacterRig(character, humanoid, 2.5)
        or generation ~= state.generation
        or character ~= localPlayer.Character then
        state.applying = false
        return false, "El rig cambió o todavía no está completo; se canceló la aplicación parcial."
    end
    if not state.baseDescription then
        local description, err = getCurrentBaseDescription(humanoid)
        if not description then
            state.applying = false
            return false, err
        end
        state.baseDescription = description
        state.baseDescriptionSignature = getDescriptionSignature(description)
    end

    local templateKey = getVisualTemplateKey(humanoid)

    local visualModel = nil
    if state.visualTemplate and state.visualTemplateKey == templateKey then
        local cloneOk, clonedModel = pcall(function()
            return state.visualTemplate:Clone()
        end)
        if cloneOk then visualModel = clonedModel end
    end

    if not visualModel then
        local description, buildError = buildDesiredDescription()
        if not description then
            state.applying = false
            return false, buildError
        end

        local modelError
        visualModel, modelError = createModelFromDescription(description, humanoid.RigType)
        pcall(function() description:Destroy() end)
        if not visualModel then
            state.applying = false
            return false, "Roblox no pudo generar el modelo visual: " .. tostring(modelError)
        end

        local templateOk, templateClone = pcall(function()
            return visualModel:Clone()
        end)
        if templateOk and templateClone then
            clearVisualTemplate()
            templateClone.Parent = nil
            state.visualTemplate = templateClone
            state.visualTemplateKey = templateKey
        end
    end
    if generation ~= state.generation or character ~= localPlayer.Character then
        visualModel:Destroy()
        state.applying = false
        return false, "El personaje cambió durante la carga; vuelve a aplicar el accesorio."
    end

    local visualRoot, visualJoints, prepareError = prepareVisualModel(visualModel, character)
    if not visualRoot then
        state.applying = false
        return false, prepareError or "No se pudo preparar el modelo visual."
    end
    local originalRoot = character:FindFirstChild("HumanoidRootPart")
    if not originalRoot or not originalRoot:IsA("BasePart") then
        visualModel:Destroy()
        state.applying = false
        return false, "No se encontró HumanoidRootPart en el personaje original."
    end
    local folder = getCameraFolder()
    if not folder then
        visualModel:Destroy()
        state.applying = false
        return false, "No se encontró CurrentCamera para mostrar el modelo visual."
    end

    local footOffset = getFootDepth(visualModel, visualRoot) - getFootDepth(character, originalRoot)
    syncVisualPose(visualRoot, visualJoints, originalRoot, footOffset)
    visualModel.Parent = folder
    local activatedNativeEffects = activateSelectedNativeEffects(visualModel)
    local cameraUpdate, cameraDescendantConnection, cameraDescendantRemovingConnection =
        createNativeCameraTransparencyUpdater(
            visualModel,
            function(descendant)
                enableNativeEffect(descendant)
            end
        )

    local oldModel = state.overlayModel
    if state.syncConnection then pcall(function() state.syncConnection:Disconnect() end) end
    if state.cameraDescendantConnection then pcall(function() state.cameraDescendantConnection:Disconnect() end) end
    if state.cameraDescendantRemovingConnection then
        pcall(function() state.cameraDescendantRemovingConnection:Disconnect() end)
    end

    state.overlayModel = visualModel
    state.overlayRoot = visualRoot
    state.overlayJointMap = visualJoints
    state.overlayOffsetY = footOffset
    state.cameraDescendantConnection = cameraDescendantConnection
    state.cameraDescendantRemovingConnection = cameraDescendantRemovingConnection
    hideOriginalCharacter(character)
    local currentOriginalRoot = originalRoot
    local cachedCamera = Workspace.CurrentCamera
    local cachedFolder = folder
    state.syncConnection = RunService.RenderStepped:Connect(function(deltaTime)
        if state.overlayModel ~= visualModel or not visualModel.Parent then return end
        if not character.Parent then return end
        if not currentOriginalRoot or not currentOriginalRoot.Parent then
            currentOriginalRoot = character:FindFirstChild("HumanoidRootPart")
        end
        if not currentOriginalRoot or not currentOriginalRoot.Parent then return end

        local currentCamera = Workspace.CurrentCamera
        if not currentCamera then return end
        if currentCamera ~= cachedCamera or not cachedFolder or cachedFolder.Parent ~= currentCamera then
            cachedCamera = currentCamera
            cachedFolder = getCameraFolder()
        end
        if cachedFolder and visualModel.Parent ~= cachedFolder then
            visualModel.Parent = cachedFolder
        end

        syncVisualPose(visualRoot, visualJoints, currentOriginalRoot, footOffset)
        cameraUpdate()
    end)

    if oldModel and oldModel ~= visualModel then pcall(function() oldModel:Destroy() end) end
    state.applying = false

    local effects = countNativeEffects(visualModel)
    local effectSummary = string.format("Instancias originales detectadas: %d ParticleEmitter, %d Trail, %d Beam, %d luces y %d efectos extra; %d efectos nativos activados.",
        effects.particles, effects.trails, effects.beams, effects.lights, effects.other, activatedNativeEffects)
    local hasEffectfulPreset = state.deathwalkerEyesActive
    for assetId, enabled in pairs(state.accessoryOverrides) do
        if enabled == true and (assetId == 215718515 or assetId == 74891470
            or assetId == 1744060292 or assetId == 76479271580913) then
            hasEffectfulPreset = true
            break
        end
    end
    local noEffectInstances = (effects.particles + effects.trails + effects.beams + effects.lights + effects.other) == 0
    if hasEffectfulPreset and noEffectInstances then
        effectSummary ..= " AVISO: Roblox no entregó instancias de efecto dentro del modelo generado. No se crearon partículas artificiales; el recurso puede depender de un efecto del motor o de comportamiento de Roblox no expuesto en el asset."
    elseif hasEffectfulPreset and effects.disabled > 0 and activatedNativeEffects == 0 then
        effectSummary ..= " Nota: quedan efectos originales desactivados que no pude vincular con seguridad al accesorio seleccionado; no se activaron a ciegas."
    end
    if state.deathwalkerEyesActive and humanoid.RigType == Enum.HumanoidRigType.R6 then
        effectSummary ..= " AVISO R6: hay un problema público conocido de Roblox con la cabeza/ojos de Korblox Deathwalker en R6; el recurso original no garantiza el efecto en este rig. Prueba R15 si no aparecen; no se sustituyen por efectos falsos."
    end
    return true, "Apariencia local sincronizada. " .. effectSummary
end

local function setAccessoryDesired(meta, desired)
    local assetId = math.floor(tonumber(meta and meta.id) or 0)
    if assetId <= 0 then return false, "ID de accesorio no válido." end
    if type(meta) ~= "table" or not meta.accessoryType then
        return false, "No se pudo determinar el tipo de accesorio. Busca de nuevo el ID para verificarlo."
    end
    desired = desired == true

    local baselineDescription = getActiveAppearanceBaseDescription()
    if not baselineDescription then
        local _, humanoid = getCharacter()
        local description, descriptionError = getCurrentBaseDescription(humanoid)
        if not description then return false, descriptionError or "No se pudo cargar la apariencia original." end
        state.baseDescription = description
        state.baseDescriptionSignature = getDescriptionSignature(description)
        baselineDescription = description
    end

    local _, baselineIds, _, baselineError = getBaselineAccessoryData(baselineDescription)
    if not baselineIds then
        return false, baselineError or "No se pudieron leer los accesorios originales."
    end

    local currentlyOn = isAccessoryDesired(assetId, baselineDescription)
    if currentlyOn == desired then
        return true, desired and "El accesorio ya está aplicado." or "El accesorio ya está retirado."
    end

    local oldOverride = state.accessoryOverrides[assetId]
    local oldMeta = state.accessoryMeta[assetId]
    state.accessoryMeta[assetId] = {
        id = assetId,
        name = tostring(meta.name or ("Asset " .. tostring(assetId))),
        accessoryType = meta.accessoryType,
        isLayered = meta.isLayered == true,
    }

    local baselineHas = baselineIds[assetId] == true
    if desired == baselineHas then
        state.accessoryOverrides[assetId] = nil
    else
        state.accessoryOverrides[assetId] = desired
    end
    bumpVisualRevision()

    local callOk, ok, message = pcall(applyCurrentAppearance)
    if not callOk then

        state.applying = false
        state.accessoryOverrides[assetId] = oldOverride
        state.accessoryMeta[assetId] = oldMeta
        bumpVisualRevision()
        local recovered = pcall(applyCurrentAppearance)
        if not recovered then state.applying = false end
        return false, "Falló la actualización del accesorio y se revirtió el cambio: " .. tostring(ok)
    end
    if not ok then
        state.accessoryOverrides[assetId] = oldOverride
        state.accessoryMeta[assetId] = oldMeta
        bumpVisualRevision()
        return false, message
    end

    return true, desired
        and (state.accessoryMeta[assetId].name .. " añadido mediante el sistema de avatar de Roblox.")
        or (state.accessoryMeta[assetId].name .. " quitado de la apariencia local.")
end

local function toggleBodyPart(key)
    if key ~= "headless" and key ~= "korbloxLeg" then
        return false, "Parte corporal no reconocida."
    end
    local oldValue = state.bodyActive[key]
    local oldDeathwalker = state.deathwalkerEyesActive
    state.bodyActive[key] = not oldValue
    bumpVisualRevision()

    if key == "headless" and state.bodyActive.headless then
        state.deathwalkerEyesActive = false
    end

    local ok, message = applyCurrentAppearance()
    if not ok then
        state.bodyActive[key] = oldValue
        state.deathwalkerEyesActive = oldDeathwalker
        bumpVisualRevision()
        return false, message
    end
    if state.bodyActive[key] then
        return true, key == "headless" and "Headless aplicado como Head asset nativo de Roblox." or "Korblox Deathspeaker aplicado a RightLeg mediante HumanoidDescription."
    end
    return true, key == "headless" and "Headless retirado; se restauró la cabeza original." or "Korblox retirado; se restauró la pierna original."
end

local function toggleDeathwalkerEyes()
    local oldValue = state.deathwalkerEyesActive
    local oldHeadless = state.bodyActive.headless
    state.deathwalkerEyesActive = not oldValue
    bumpVisualRevision()
    if state.deathwalkerEyesActive then
        state.bodyActive.headless = false
    end
    local ok, message = applyCurrentAppearance()
    if not ok then
        state.deathwalkerEyesActive = oldValue
        state.bodyActive.headless = oldHeadless
        bumpVisualRevision()
        return false, message
    end
    if state.deathwalkerEyesActive then
        return true, "Cabeza dinámica original de Korblox Deathwalker aplicada mediante Roblox. No se dibujan efectos falsos."
    end
    return true, "Cabeza de Deathwalker retirada; se restauró la cabeza original."
end

local function clearAllOverrides()
    local oldHeadless = state.bodyActive.headless
    local oldKorblox = state.bodyActive.korbloxLeg
    local oldOverrides = table.clone(state.accessoryOverrides)
    local oldDeathwalker = state.deathwalkerEyesActive

    state.bodyActive.headless = false
    state.bodyActive.korbloxLeg = false
    table.clear(state.accessoryOverrides)
    state.deathwalkerEyesActive = false
    bumpVisualRevision()

    local ok, message = applyCurrentAppearance()
    if not ok then
        state.bodyActive.headless = oldHeadless
        state.bodyActive.korbloxLeg = oldKorblox
        state.accessoryOverrides = oldOverrides
        state.deathwalkerEyesActive = oldDeathwalker
        bumpVisualRevision()
        return false, message
    end
    return true, "Se retiraron las modificaciones de apariencia y se restauró la descripción original."
end

avatarBridge.accessory.owner = accessoryBridgeToken
avatarBridge.accessory.revision = state.visualRevision
avatarBridge.accessory.hasChanges = hasVisualChanges
avatarBridge.accessory.composeDescription = function(description, rigType)
    if not hasVisualChanges() then return description end
    return applyAccessoryOverridesToDescription(description, rigType)
end
avatarBridge.accessory.suspend = function()
    if state.overlayModel then
        disposeVisualOverlay(false)
    end
    return true
end
avatarBridge.accessory.refresh = function()
    if isSkinRendererActive() then
        return true
    end
    if hasVisualChanges() then
        return applyCurrentAppearance()
    end
    disposeVisualOverlay(true)
    return true
end
avatarBridge.accessory.refreshInventory = function()
    if state.refreshFavoritesPage then
        pcall(state.refreshFavoritesPage)
    end
    return true
end

local function getItemMeta(assetId, providedName, providedAssetType)
    assetId = math.floor(tonumber(assetId) or 0)
    if assetId <= 0 then return nil, "ID no válido." end

    local fixed = findFixedPresetById(assetId)
    if fixed and fixed.type == "accessory" then
        return {
            id = fixed.id,
            name = providedName or fixed.name,
            accessoryType = fixed.accessoryType,
            isLayered = false,
        }
    elseif fixed then
        return fixed
    end

    local assetType = providedAssetType
    local catalogName = providedName
    if not assetType then
        local ok, details = pcall(function()
            return AvatarEditorService:GetItemDetailsAsync(assetId, Enum.AvatarItemType.Asset)
        end)
        if ok and type(details) == "table" then
            assetType = details.AssetType
            catalogName = catalogName or details.Name
        end
    end

    local accessoryType, isLayered = mapAccessoryType(assetType)

    if not accessoryType then
        local objects
        local loaded, result = pcall(function()
            return game:GetObjects("rbxassetid://" .. tostring(assetId))
        end)
        if loaded and type(result) == "table" then objects = result end
        if objects then
            local foundAccessory = nil
            local hatFound = false
            for _, root in ipairs(objects) do
                if root:IsA("Accessory") then
                    foundAccessory = root
                    break
                end
                for _, descendant in ipairs(root:GetDescendants()) do
                    if descendant:IsA("Accessory") then
                        foundAccessory = descendant
                        break
                    elseif descendant:IsA("Hat") then
                        hatFound = true
                    end
                end
                if foundAccessory then break end
                if root:IsA("Hat") then hatFound = true end
            end
            if foundAccessory then
                local okType, actualType = pcall(function() return foundAccessory.AccessoryType end)
                if okType and typeof(actualType) == "EnumItem" then
                    accessoryType = actualType
                    isLayered = LAYERED_TYPES[actualType.Name] == true
                    catalogName = catalogName or foundAccessory.Name
                end
            elseif hatFound then
                accessoryType = Enum.AccessoryType.Hat
                isLayered = false
            end
            for _, root in ipairs(objects) do
                pcall(function() root:Destroy() end)
            end
        end
    end

    if not accessoryType then
        return nil, "Roblox no confirmó que el ID sea un accesorio compatible. Usa una ID del catálogo de accesorios; no se asignará un tipo a ciegas."
    end
    return {
        id = assetId,
        name = catalogName or ("Accesorio " .. tostring(assetId)),
        accessoryType = accessoryType,
        isLayered = isLayered == true,
    }
end

local function create(className, properties, parent)
    local instance = Instance.new(className)
    for property, value in pairs(properties or {}) do
        pcall(function() instance[property] = value end)
    end
    instance.Parent = parent
    return instance
end

local function round(instance, radius)
    create("UICorner", { CornerRadius = UDim.new(0, radius or 10) }, instance)
end

local function stroke(instance, color, transparency)
    create("UIStroke", {
        Color = color or COLORS.Line,
        Transparency = transparency or 0,
        Thickness = 1,
    }, instance)
end

local FAVORITES_PATH = "avatar-tools/accessory-favorites.json"

local function favoriteKey(record)
    if type(record) ~= "table" then return nil end
    if record.kind == "body" or record.bodyKey then
        local key = tostring(record.bodyKey or "")
        if key == "headless" or key == "korbloxLeg" or key == "deathwalkerEyes" then
            return "body:" .. key
        end
        return nil
    end
    local id = math.floor(tonumber(record.id) or 0)
    return id > 0 and ("accessory:" .. tostring(id)) or nil
end

local function normalizeFavoriteRecord(record)
    if type(record) ~= "table" then return nil end
    if record.kind == "body" or record.bodyKey then
        local key = tostring(record.bodyKey or "")
        for _, preset in ipairs(BODY_PRESETS) do
            if preset.key == key then
                return {
                    kind = "body",
                    bodyKey = key,
                    id = preset.id,
                    name = tostring(record.name or preset.name),
                }
            end
        end
        return nil
    end

    local id = math.floor(tonumber(record.id) or 0)
    if id <= 0 then return nil end
    local accessoryType = nil
    if type(record.accessoryTypeName) == "string" then
        pcall(function() accessoryType = Enum.AccessoryType[record.accessoryTypeName] end)
    end
    local fixed = findFixedPresetById(id)
    if not accessoryType and fixed and fixed.type == "accessory" then
        accessoryType = fixed.accessoryType
    end
    if not accessoryType then return nil end
    return {
        kind = "accessory",
        id = id,
        name = tostring(record.name or (fixed and fixed.name) or ("Accesorio " .. id)),
        accessoryType = accessoryType,
        accessoryTypeName = enumName(accessoryType),
        isLayered = record.isLayered == true,
    }
end

local function loadFavoriteItems()
    table.clear(state.favoriteItems)
    if typeof(readfile) ~= "function" or typeof(isfile) ~= "function" then return end
    local content = nil
    local ok, result = pcall(function()
        if not isfile(FAVORITES_PATH) then return nil end
        return readfile(FAVORITES_PATH)
    end)
    if ok and type(result) == "string" and result ~= "" then
        content = result
    end
    if type(content) ~= "string" then return end
    local decodedOk, data = pcall(function() return HttpService:JSONDecode(content) end)
    if not decodedOk or type(data) ~= "table" or type(data.items) ~= "table" then return end
    for _, raw in ipairs(data.items) do
        local record = normalizeFavoriteRecord(raw)
        local key = record and favoriteKey(record)
        if key then state.favoriteItems[key] = record end
    end
end

local function saveFavoriteItems()
    if typeof(writefile) ~= "function" then return false end
    local items = {}
    for _, record in pairs(state.favoriteItems) do
        if record.kind == "body" then
            table.insert(items, {
                kind = "body", bodyKey = record.bodyKey, id = record.id, name = record.name,
            })
        else
            table.insert(items, {
                kind = "accessory", id = record.id, name = record.name,
                accessoryTypeName = record.accessoryTypeName or enumName(record.accessoryType),
                isLayered = record.isLayered == true,
            })
        end
    end
    table.sort(items, function(a, b)
        return tostring(a.name):lower() < tostring(b.name):lower()
    end)
    local encoded = HttpService:JSONEncode({ version = 1, items = items })
    pcall(function()
        if typeof(isfolder) == "function" and typeof(makefolder) == "function" and not isfolder("avatar-tools") then
            makefolder("avatar-tools")
        end
    end)
    return pcall(writefile, FAVORITES_PATH, encoded)
end

local function makeAccessoryFavorite(meta)
    if type(meta) ~= "table" or tonumber(meta.id) == nil then return nil end
    local fixed = findFixedPresetById(meta.id)
    local accessoryType = meta.accessoryType or (fixed and fixed.type == "accessory" and fixed.accessoryType)
    if not accessoryType then return nil end
    return {
        kind = "accessory",
        id = math.floor(tonumber(meta.id)),
        name = tostring(meta.name or (fixed and fixed.name) or ("Accesorio " .. tostring(meta.id))),
        accessoryType = accessoryType,
        accessoryTypeName = enumName(accessoryType),
        isLayered = meta.isLayered == true,
    }
end

local function makeBodyFavorite(preset)
    return {
        kind = "body",
        bodyKey = preset.key,
        id = preset.id,
        name = preset.name,
    }
end

local function toggleFavorite(record)
    clearStatus()
    local normalized = normalizeFavoriteRecord(record)
    local key = normalized and favoriteKey(normalized)
    if not key then
        setStatus("Fallo")
        return
    end
    if state.favoriteItems[key] then
        state.favoriteItems[key] = nil
        local saved = saveFavoriteItems()
        if state.refreshFavoriteButtons then state.refreshFavoriteButtons() end
        if state.refreshFavoritesPage then state.refreshFavoritesPage() end
        if not saved then
            setStatus("Fallo")
        end
    else
        state.favoriteItems[key] = normalized
        local saved = saveFavoriteItems()
        if state.refreshFavoriteButtons then state.refreshFavoriteButtons() end
        if state.refreshFavoritesPage then state.refreshFavoritesPage() end
        if not saved then
            setStatus("Fallo")
        end
    end
end

local function isFavorite(record)
    local key = favoriteKey(record)
    return key ~= nil and state.favoriteItems[key] ~= nil
end

local function isActionActive(kind, key)
    if kind == "accessory" then
        return isAccessoryDesired(key)
    elseif kind == "body" then
        return state.bodyActive[key] == true
    elseif kind == "deathwalkerEyes" then
        return state.deathwalkerEyesActive == true
    end
    return false
end

local function refreshButtons()
    for index = #state.actionButtons, 1, -1 do
        local entry = state.actionButtons[index]
        local button = entry and entry.button
        if not button or not button.Parent then
            table.remove(state.actionButtons, index)
        else
            local active = entry.kind and isActionActive(entry.kind, entry.key) or false
            if entry.mode == "apply" then
                if active then
                    button.Text = "APLICADO"
                    button.BackgroundColor3 = COLORS.ActiveFill
                else
                    button.Text = entry.kind == "accessory" and "AÑADIR" or "APLICAR"
                    button.BackgroundColor3 = COLORS.AccentFill
                end
                button.Active = not state.busy and not active
            elseif entry.mode == "remove" then
                button.Text = "QUITAR"
                button.BackgroundColor3 = active and COLORS.DangerFill or COLORS.Surface
                button.Active = not state.busy and active
            else
                if active then
                    button.Text = "QUITAR"
                    button.BackgroundColor3 = COLORS.DangerFill
                elseif entry.kind == "accessory" then
                    button.Text = "AÑADIR"
                    button.BackgroundColor3 = COLORS.AccentFill
                else
                    button.Text = "APLICAR"
                    button.BackgroundColor3 = COLORS.AccentFill
                end
                button.Active = not state.busy
            end
            button.AutoButtonColor = not state.busy
            button.TextTransparency = state.busy and 0.25 or 0
        end
    end
    if state.refreshFavoriteButtons then state.refreshFavoriteButtons() end
end
local function refreshDynamicViews()
    if state.refreshEquipped then state.refreshEquipped() end
    if state.refreshFavoritesPage then state.refreshFavoritesPage() end
    refreshButtons()
end

local function runAction(action, successStatus)
    if state.busy then return end
    clearStatus()
    state.busy = true
    refreshButtons()
    task.spawn(function()
        local callOk, actionOk = pcall(action)
        if not callOk or actionOk == false then
            setStatus("Fallo")
        else
            setStatus(successStatus or "Retirado")
        end
        state.busy = false
        refreshDynamicViews()
    end)
end

local function clearSearchResults()
    disconnectBucket(state.resultConnections)
    for _, row in ipairs(state.resultRows) do
        pcall(function() row:Destroy() end)
    end
    table.clear(state.resultRows)
    table.clear(state.searchButtons)
    refreshButtons()
end

local function collectCurrentItems(forceRefresh)
    local skinIsActive = isSkinRendererActive()
    local effectiveDescription = skinIsActive and getActiveAppearanceBaseDescription() or state.baseDescription
    local activeSkinUserId = tonumber(avatarBridge.skin.userId or avatarBridge.skin.requestedUserId)
    local baseSource = skinIsActive and activeSkinUserId ~= localPlayer.UserId and "SKIN" or "TU AVATAR"
    local cacheKey = table.concat({
        tostring(state.generation),
        tostring(state.visualRevision),
        tostring(avatarBridge.skin.revision or 0),
        tostring(skinIsActive),
        tostring(avatarBridge.skin.pending == true),
        tostring(activeSkinUserId or localPlayer.UserId),
        tostring(state.baseDescriptionSignature or ""),
    }, "|")

    local cache = state.inventoryCache
    if not forceRefresh and cache and cache.key == cacheKey then
        return cache.items
    end

    local items = {}
    local seen = {}
    if effectiveDescription then
        local accessories = getBaselineAccessoryData(effectiveDescription)
        if type(accessories) == "table" then
            for _, info in ipairs(accessories) do
                local assetId = math.floor(tonumber(info.AssetId) or 0)
                if assetId > 0 and state.accessoryOverrides[assetId] ~= false then
                    local fixed = findFixedPresetById(assetId)
                    local meta = state.accessoryMeta[assetId]
                    if not meta then
                        meta = {
                            id = assetId,
                            name = (fixed and fixed.type == "accessory" and fixed.name) or ("Accesorio " .. tostring(assetId)),
                            accessoryType = info.AccessoryType,
                            isLayered = info.IsLayered == true,
                        }
                        state.accessoryMeta[assetId] = meta
                    else
                        meta.accessoryType = meta.accessoryType or info.AccessoryType
                        if meta.isLayered == nil then meta.isLayered = info.IsLayered == true end
                        if (not meta.name or meta.name:match("^Accesorio%s+%d+$")) and fixed and fixed.type == "accessory" then
                            meta.name = fixed.name
                        end
                    end
                    if meta.accessoryType then
                        table.insert(items, {
                            kind = "accessory", id = assetId, name = meta.name,
                            meta = meta, source = baseSource, isOriginal = true,
                        })
                        seen[assetId] = true
                    end
                end
            end
        end
    end

    for rawId, enabled in pairs(state.accessoryOverrides) do
        local assetId = math.floor(tonumber(rawId) or 0)
        if enabled == true and assetId > 0 and not seen[assetId] then
            local meta = state.accessoryMeta[assetId]
            if meta and meta.accessoryType then
                table.insert(items, {
                    kind = "accessory", id = assetId, name = meta.name or ("Accesorio " .. assetId),
                    meta = meta, source = "ACCESSORY", isOriginal = false,
                })
                seen[assetId] = true
            end
        end
    end

    table.sort(items, function(a, b)
        if a.source ~= b.source then
            local order = { SKIN = 1, ["TU AVATAR"] = 1, ACCESSORY = 2 }
            return (order[a.source] or 9) < (order[b.source] or 9)
        end
        return tostring(a.name):lower() < tostring(b.name):lower()
    end)

    local byId = {}
    for _, item in ipairs(items) do
        byId[item.id] = item
    end
    cache.key = cacheKey
    cache.items = items
    cache.byId = byId
    cache.revision = (tonumber(cache.revision) or 0) + 1

    avatarBridge.accessory.inventorySnapshot = {
        revision = cache.revision,
        key = cacheKey,
        source = baseSource,
        items = items,
        byId = byId,
    }
    return items
end

avatarBridge.accessory.getEquippedSnapshot = function(forceRefresh)
    local items = collectCurrentItems(forceRefresh == true)
    local result = {}
    for _, item in ipairs(items) do
        table.insert(result, {
            kind = item.kind,
            id = item.id,
            name = item.name,
            source = item.source,
            accessoryType = item.meta and item.meta.accessoryType,
            isLayered = item.meta and item.meta.isLayered == true,
        })
    end
    return result, state.inventoryCache.revision
end

avatarBridge.accessory.refreshInventory = function()
    collectCurrentItems(true)
    if state.refreshFavoritesPage then
        pcall(state.refreshFavoritesPage)
    end
    return true
end

local cleanup
local function buildUI()

    pcall(function()
        local prior = CoreGui:FindFirstChild(GUI_NAME)
        if prior then prior:Destroy() end
    end)
    pcall(function()
        local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
        local prior = playerGui and playerGui:FindFirstChild(GUI_NAME)
        if prior then prior:Destroy() end
    end)

    disconnectBucket(state.uiConnections)
    disconnectBucket(state.resultConnections)
    disconnectBucket(state.favoriteConnections)
    disconnectBucket(state.equippedConnections)
    state.tabButtons = {}
    state.pages = {}
    state.actionButtons = {}
    state.favoriteButtons = {}
    state.presetButtons = {}
    state.bodyButtons = {}
    state.searchButtons = {}
    state.resultRows = {}
    state.favoriteRows = {}
    state.equippedRows = {}
    state.showEquippedCompact = false

    local guiRoot = nil
    if type(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok and typeof(result) == "Instance" then guiRoot = result end
    end
    guiRoot = guiRoot or CoreGui

    local screen = Instance.new("ScreenGui")
    screen.Name = GUI_NAME
    screen.ResetOnSpawn = false
    screen.IgnoreGuiInset = true
    screen.DisplayOrder = 2147483647
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local parentOk = pcall(function() screen.Parent = guiRoot end)
    if not parentOk or not screen.Parent then
        screen.Parent = localPlayer:WaitForChild("PlayerGui")
    end
    state.gui = screen

    local function loadBackgroundAsset()
        local url = "https://raw.githubusercontent.com/Silent-lua/Dev/main/assets/avatar-background.png"
        local path = "avatar-tools/avatar-visual.png"
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
    local baseWidth, baseHeight = 590, 274
    local main = create("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(baseWidth, baseHeight),
        BackgroundColor3 = COLORS.Background,
        BorderSizePixel = 0,
        Active = true,
        ClipsDescendants = true,
    }, screen)
    round(main, 16)
    stroke(main, COLORS.Border, 0.2)
    state.main = main

    local gradient = create("UIGradient", {
        Color = ColorSequence.new(COLORS.BackgroundAlt, COLORS.Background),
        Rotation = 90,
    }, main)

    local backgroundImage = create("ImageLabel", {
        Name = "ReferenceBackground",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Image = bgAsset or "",
        ImageTransparency = bgAsset and 0 or 1,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 1,
    }, main)
    round(backgroundImage, 16)
local backgroundTween
    local function animateBackground()
        if not bgAsset or not backgroundImage.Parent or not main.Visible then return end
        if backgroundTween then backgroundTween:Cancel() end
        backgroundImage.Position = UDim2.fromScale(-0.022, -0.018)
        backgroundImage.Size = UDim2.fromScale(1.044, 1.036)
        backgroundImage.Rotation = -0.55
        backgroundImage.ImageTransparency = 0.18
        backgroundTween = TweenService:Create(
            backgroundImage,
            TweenInfo.new(0.9, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            {
                Position = UDim2.fromScale(-0.004, -0.003),
                Size = UDim2.fromScale(1.008, 1.006),
                Rotation = 0,
                ImageTransparency = 0,
            }
        )
        backgroundTween.Completed:Connect(function(playbackState)
            if playbackState ~= Enum.PlaybackState.Completed or not backgroundImage.Parent or not main.Visible then return end
            backgroundTween = TweenService:Create(
                backgroundImage,
                TweenInfo.new(5.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
                {
                    Position = UDim2.fromScale(0.006, 0.005),
                    Size = UDim2.fromScale(1.022, 1.018),
                    Rotation = 0.38,
                    ImageTransparency = 0.06,
                }
            )
            backgroundTween:Play()
        end)
        backgroundTween:Play()
    end
    local mainBackgroundOverlay = create("Frame", {
        Name = "ReferenceBackgroundOverlay",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 1,
    }, main)
    round(mainBackgroundOverlay, 16)

    local uiScale = create("UIScale", {}, main)
    local isTouchOnly = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

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
    end

    local function clampMainCenter(position)
        return clampGuiCenter(main, position)
    end

    local mainCenter = getGuiCenter(main)

    local function setMainCenter(position)
        mainCenter = clampMainCenter(position)
        setGuiCenter(main, mainCenter)
    end

    local function keepMainInsideViewport()
        if not main.Parent or not main.Visible then return end
        setMainCenter(mainCenter)
    end

    local function updateScale()
        local camera = Workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
        local widthFactor = isTouchOnly and 0.90 or 0.94
        local heightFactor = isTouchOnly and 0.78 or 0.92
        uiScale.Scale = math.clamp(
            math.min(viewport.X * widthFactor / baseWidth, viewport.Y * heightFactor / baseHeight),
            0.01,
            1
        )
        task.defer(keepMainInsideViewport)
    end
    updateScale()

    create("TextButton", {
        Name = "InputSurface",
        Text = "",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        AutoButtonColor = false,
        Active = true,
        Selectable = false,
        ZIndex = 0,
    }, main)

    local header = create("Frame", {
        Name = "Header",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 52),
        Active = true,
    }, main)
    local titleLabel = create("TextLabel", {
        Position = UDim2.fromOffset(18, 15),
        Size = UDim2.fromOffset(166, 22),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "SilentHub",
        TextSize = 16,
        TextColor3 = COLORS.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, header)
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
    create("TextLabel", {
        Position = UDim2.fromOffset(19, 32),
        Size = UDim2.fromOffset(250, 12),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = "Accesorios",
        TextSize = 8,
        TextColor3 = COLORS.Muted,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, header)

    local minimize = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -44, 0, 13),
        Size = UDim2.fromOffset(26, 26),
        BackgroundColor3 = COLORS.Surface,
        BorderSizePixel = 0,
        AutoButtonColor = true,
        Font = Enum.Font.GothamBold,
        Text = "",
        TextSize = 12,
        TextColor3 = COLORS.Muted,
    }, header)
    round(minimize, 8)
    create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Font = Enum.Font.GothamBold,
        Text = "−",
        TextSize = 21,
        TextColor3 = COLORS.Muted,
    }, minimize)

    local closeButton = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -14, 0, 13),
        Size = UDim2.fromOffset(26, 26),
        BackgroundColor3 = COLORS.Surface,
        BorderSizePixel = 0,
        AutoButtonColor = true,
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextSize = 16,
        TextColor3 = COLORS.Muted,
    }, header)
    round(closeButton, 8)

    create("Frame", {
        Position = UDim2.fromOffset(0, 52),
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = COLORS.Line,
        BorderSizePixel = 0,
    }, main)
    create("Frame", {
        Position = UDim2.fromOffset(176, 52),
        Size = UDim2.new(0, 1, 1, -52),
        BackgroundColor3 = COLORS.Line,
        BorderSizePixel = 0,
    }, main)

    local sidebarHeader = create("TextLabel", {
        Position = UDim2.fromOffset(14, 60),
        Size = UDim2.fromOffset(152, 26),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "Recomendados",
        TextSize = 12,
        TextColor3 = COLORS.Muted,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, main)

    local sideList = create("ScrollingFrame", {
        Name = "RecommendedList",
        Position = UDim2.fromOffset(8, 92),
        Size = UDim2.new(0, 164, 1, -100),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = COLORS.Soft,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
    }, main)
    local sideLayout = create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, sideList)
    create("UIPadding", {
        PaddingTop = UDim.new(0, 1),
        PaddingBottom = UDim.new(0, 4),
    }, sideList)
    state.recommendedList = sideList

    local searchFrame = create("Frame", {
        Position = UDim2.fromOffset(194, 64),
        Size = UDim2.fromOffset(338, 36),
        BackgroundColor3 = COLORS.Surface,
        BorderSizePixel = 0,
    }, main)
    round(searchFrame, 8)
    local searchInput = create("TextBox", {
        Name = "CatalogInput",
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -20, 1, 0),
        BackgroundTransparency = 1,
        ClearTextOnFocus = false,
        Font = Enum.Font.Gotham,
        PlaceholderText = "nombre o ID del objeto",
        PlaceholderColor3 = COLORS.Muted,
        Text = "",
        TextColor3 = COLORS.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, searchFrame)
    state.searchInput = searchInput

    local searchButton = create("TextButton", {
        Position = UDim2.fromOffset(538, 64),
        Size = UDim2.fromOffset(38, 36),
        BackgroundColor3 = COLORS.Surface,
        BorderSizePixel = 0,
        AutoButtonColor = true,
        Font = Enum.Font.GothamBold,
        Text = "→",
        TextSize = 22,
        TextColor3 = COLORS.Muted,
    }, main)
    round(searchButton, 8)

    local preview = create("Frame", {
        Position = UDim2.fromOffset(194, 108),
        Size = UDim2.fromOffset(150, 150),
        BackgroundColor3 = COLORS.Surface,
        BorderSizePixel = 0,
    }, main)
    round(preview, 12)
    local previewCardGradient = create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 46, 82)),
            ColorSequenceKeypoint.new(0.5, COLORS.Surface),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 20, 40)),
        }),
        Rotation = 35,
    }, preview)
    local previewCardStroke = create("UIStroke", {
        Color = COLORS.Soft,
        Thickness = 1.5,
        Transparency = 0.08,
    }, preview)
    local previewStrokeGradient = create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(74, 148, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(184, 226, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(88, 104, 255)),
        }),
        Rotation = 0,
    }, previewCardStroke)
    local previewStrokeTween = TweenService:Create(
        previewStrokeGradient,
        TweenInfo.new(7, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
        { Rotation = 360 }
    )
    previewStrokeTween:Play()
    local previewBadge = create("TextLabel", {
        Name = "PreviewBadge",
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 9, 1, -8),
        Size = UDim2.fromOffset(66, 16),
        BackgroundColor3 = COLORS.Background,
        BackgroundTransparency = 0.14,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        Text = "✦ 3D LIVE",
        TextSize = 8,
        TextColor3 = COLORS.Text,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 4,
    }, preview)
    round(previewBadge, 6)
    create("UIStroke", {
        Color = COLORS.Soft,
        Thickness = 0.7,
        Transparency = 0.3,
    }, previewBadge)
    local previewImage = create("ImageLabel", {
        Name = "PreviewImage",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.new(1, -12, 1, -12),
        Image = "",
        ScaleType = Enum.ScaleType.Fit,
    }, preview)
    state.previewImage = previewImage

    local previewViewport = create("ViewportFrame", {
        Name = "ObjectPreview",
        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.new(1, -12, 1, -12),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
        Ambient = Color3.fromRGB(205, 215, 235),
        LightColor = Color3.fromRGB(255, 255, 255),
        LightDirection = Vector3.new(-1, -1, -1),
        ZIndex = 2,
    }, preview)
    local previewCamera = Instance.new("Camera")
    previewCamera.FieldOfView = 35
    previewCamera.Parent = previewViewport
    previewViewport.CurrentCamera = previewCamera
    local previewWorld = Instance.new("WorldModel")
    previewWorld.Parent = previewViewport
    state.previewViewport = previewViewport
    state.previewWorld = previewWorld

    local favoriteStar = create("TextButton", {
        Name = "FavoriteToggle",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -6, 0, 6),
        Size = UDim2.fromOffset(28, 28),
        BackgroundColor3 = COLORS.Background,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        AutoButtonColor = true,
        Text = "☆",
        TextSize = 19,
        Font = Enum.Font.GothamBold,
        TextColor3 = COLORS.Muted,
        ZIndex = 3,
    }, preview)
    round(favoriteStar, 14)
    state.favoriteButtons[1] = { button = favoriteStar, record = nil }

    local selectedName = create("TextLabel", {
        Name = "SelectedName",
        Position = UDim2.fromOffset(360, 110),
        Size = UDim2.fromOffset(216, 22),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "Selecciona un objeto",
        TextSize = 15,
        TextColor3 = COLORS.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, main)
    local selectedDetail = create("TextLabel", {
        Name = "SelectedDetail",
        Position = UDim2.fromOffset(360, 132),
        Size = UDim2.fromOffset(216, 16),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = "Accesorios y apariencia",
        TextSize = 10,
        TextColor3 = COLORS.Muted,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, main)
    state.statusLabel = create("TextLabel", {
        Name = "Status",
        Position = UDim2.fromOffset(360, 145),
        Size = UDim2.fromOffset(216, 12),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = "",
        TextSize = 9,
        TextColor3 = COLORS.Muted,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, main)

    local applyButton = create("TextButton", {
        Position = UDim2.fromOffset(360, 158),
        Size = UDim2.fromOffset(112, 30),
        BackgroundColor3 = COLORS.AccentFill,
        BorderSizePixel = 0,
        AutoButtonColor = true,
        Font = Enum.Font.GothamBold,
        Text = "AÑADIR",
        TextSize = 12,
        TextColor3 = Color3.new(1, 1, 1),
    }, main)
    round(applyButton, 8)
    local removeButton = create("TextButton", {
        Position = UDim2.fromOffset(480, 158),
        Size = UDim2.fromOffset(96, 30),
        BackgroundColor3 = COLORS.Surface,
        BorderSizePixel = 0,
        AutoButtonColor = true,
        Font = Enum.Font.GothamBold,
        Text = "QUITAR",
        TextSize = 12,
        TextColor3 = COLORS.Muted,
    }, main)
    round(removeButton, 8)
    table.insert(state.actionButtons, { button = applyButton, kind = nil, key = nil, mode = "apply" })
    table.insert(state.actionButtons, { button = removeButton, kind = nil, key = nil, mode = "remove" })

    local restoreButton = create("TextButton", {
        Position = UDim2.fromOffset(360, 196),
        Size = UDim2.fromOffset(216, 28),
        BackgroundColor3 = COLORS.Surface,
        BorderSizePixel = 0,
        AutoButtonColor = true,
        Font = Enum.Font.GothamBold,
        Text = "RESTAURAR AVATAR ORIGINAL",
        TextSize = 10,
        TextColor3 = COLORS.Muted,
    }, main)
    round(restoreButton, 8)

    local accessoriesFilter = create("TextButton", {
        Position = UDim2.fromOffset(360, 232),
        Size = UDim2.fromOffset(112, 26),
        BackgroundColor3 = COLORS.AccentFill,
        BorderSizePixel = 0,
        AutoButtonColor = true,
        Font = Enum.Font.GothamBold,
        Text = "ACCESORIOS",
        TextSize = 10,
        TextColor3 = COLORS.Text,
    }, main)
    round(accessoriesFilter, 8)
    local bodyFilter = create("TextButton", {
        Position = UDim2.fromOffset(480, 232),
        Size = UDim2.fromOffset(96, 26),
        BackgroundColor3 = COLORS.Surface,
        BorderSizePixel = 0,
        AutoButtonColor = true,
        Font = Enum.Font.GothamBold,
        Text = "CUERPO",
        TextSize = 10,
        TextColor3 = COLORS.Muted,
    }, main)
    round(bodyFilter, 8)

    local minimizedButton = create("Frame", {
        Name = "FloatingReopen",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset(75, 23),
        Size = UDim2.fromOffset(150, 46),
        BackgroundColor3 = COLORS.BackgroundAlt,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 50,
    }, screen)
    round(minimizedButton, 12)
    stroke(minimizedButton, COLORS.Text, 0.45)
    local reopenBackground = create("ImageLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Image = bgAsset or "",
        ImageTransparency = bgAsset and 0.5 or 1,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 50,
    }, minimizedButton)
    round(reopenBackground, 12)
    local reopenOverlay = create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = bgAsset and 0.55 or 0.82,
        BorderSizePixel = 0,
        ZIndex = 51,
    }, minimizedButton)
    round(reopenOverlay, 12)
    local reopenDot = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1, -12, 0, 10),
        Size = UDim2.fromOffset(8, 8),
        BackgroundColor3 = COLORS.Text,
        BorderSizePixel = 0,
        ZIndex = 53,
    }, minimizedButton)
    round(reopenDot, 4)
    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 0),
        Size = UDim2.new(1, -24, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "Open Accessories",
        TextSize = 13,
        TextColor3 = COLORS.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 53,
    }, minimizedButton)
    local minimizedClick = create("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        AutoButtonColor = false,
        Active = true,
        Selectable = false,
        Text = "",
        ZIndex = 54,
    }, minimizedButton)
    task.spawn(function()
        while reopenDot.Parent do
            reopenDot.BackgroundTransparency = 0.65
            task.wait(0.8)
            if not reopenDot.Parent then break end
            reopenDot.BackgroundTransparency = 0
            task.wait(0.8)
        end
    end)
    state.reopen = minimizedButton

    local closeOverlay = create("Frame", {
        Name = "CloseConfirmationOverlay",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = COLORS.Background,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 20,
        Active = true,
    }, main)
    round(closeOverlay, 16)
    local closeDialog = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(300, 132),
        BackgroundColor3 = COLORS.Surface,
        BorderSizePixel = 0,
        ZIndex = 21,
    }, closeOverlay)
    round(closeDialog, 12)
    stroke(closeDialog, COLORS.Line, 0)
    create("TextLabel", {
        Position = UDim2.fromOffset(16, 16),
        Size = UDim2.new(1, -32, 0, 22),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "¿Cerrar SilentHub?",
        TextSize = 15,
        TextColor3 = COLORS.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 22,
    }, closeDialog)
    create("TextLabel", {
        Position = UDim2.fromOffset(16, 40),
        Size = UDim2.new(1, -32, 0, 32),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = "Se cerrará SilentHub.",
        TextSize = 11,
        TextColor3 = COLORS.Muted,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 22,
    }, closeDialog)
    local confirmClose = create("TextButton", {
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -16, 1, -14),
        Size = UDim2.fromOffset(96, 30),
        BackgroundColor3 = COLORS.DangerFill,
        BorderSizePixel = 0,
        AutoButtonColor = true,
        Font = Enum.Font.GothamBold,
        Text = "Cerrar",
        TextSize = 12,
        TextColor3 = Color3.new(1, 1, 1),
        ZIndex = 22,
    }, closeDialog)
    round(confirmClose, 8)
    local cancelClose = create("TextButton", {
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -120, 1, -14),
        Size = UDim2.fromOffset(96, 30),
        BackgroundColor3 = COLORS.SurfaceUp,
        BorderSizePixel = 0,
        AutoButtonColor = true,
        Font = Enum.Font.GothamBold,
        Text = "Cancelar",
        TextSize = 12,
        TextColor3 = COLORS.Muted,
        ZIndex = 22,
    }, closeDialog)
    round(cancelClose, 8)

    local sideMode = "recommended"
    local sideCategory = "accessory"
    local searchResults = {}
    local selectedItem = nil
    state.selectedItem = nil
    local currentSideRows = {}
    local searching = false
    local activeStarRecord = nil
    local sidebarRenderGeneration = 0
    local previewGeneration = 0
    local previewSpinConnection = nil

    local function clearPreviewWorld()
        if previewSpinConnection then
            pcall(function() previewSpinConnection:Disconnect() end)
            previewSpinConnection = nil
        end
        for _, child in ipairs(previewWorld:GetChildren()) do
            pcall(function() child:Destroy() end)
        end
    end

    local function getPreviewBounds(root)
        local minimum = Vector3.new(math.huge, math.huge, math.huge)
        local maximum = Vector3.new(-math.huge, -math.huge, -math.huge)
        local partCount = 0
        local parts = {}
        if root:IsA("BasePart") then
            table.insert(parts, root)
        end
        for _, descendant in ipairs(root:GetDescendants()) do
            if descendant:IsA("BasePart") then
                table.insert(parts, descendant)
            end
        end
        for _, part in ipairs(parts) do
            partCount += 1
            local half = part.Size * 0.5
            for x = -1, 1, 2 do
                for y = -1, 1, 2 do
                    for z = -1, 1, 2 do
                        local corner = part.CFrame:PointToWorldSpace(Vector3.new(half.X * x, half.Y * y, half.Z * z))
                        minimum = Vector3.new(
                            math.min(minimum.X, corner.X),
                            math.min(minimum.Y, corner.Y),
                            math.min(minimum.Z, corner.Z)
                        )
                        maximum = Vector3.new(
                            math.max(maximum.X, corner.X),
                            math.max(maximum.Y, corner.Y),
                            math.max(maximum.Z, corner.Z)
                        )
                    end
                end
            end
        end
        if partCount == 0 then return nil, nil end
        return (minimum + maximum) * 0.5, maximum - minimum
    end

    local function preparePreviewInstance(instance)
        if instance:IsA("BasePart") then
            pcall(function()
                instance.Anchored = true
                instance.CanCollide = false
                instance.CanTouch = false
                instance.CanQuery = false
                instance.Massless = true
            end)
        elseif instance:IsA("ParticleEmitter")
            or instance:IsA("Trail")
            or instance:IsA("Beam")
            or instance:IsA("Fire")
            or instance:IsA("Smoke")
            or instance:IsA("Sparkles")
            or instance:IsA("Light") then
            pcall(function() instance.Enabled = true end)
        elseif instance:IsA("BaseScript") or instance:IsA("ModuleScript") then
            pcall(function() instance:Destroy() end)
        end
    end

    local function enablePreviewEffects(root)
        preparePreviewInstance(root)
        for _, descendant in ipairs(root:GetDescendants()) do
            preparePreviewInstance(descendant)
        end
    end

    local function createPreviewAvatar()
        local character = localPlayer.Character
        if not character or not character.Parent then return nil, nil end

        local oldArchivable = character.Archivable
        pcall(function() character.Archivable = true end)
        local cloned, avatar = pcall(function() return character:Clone() end)
        pcall(function() character.Archivable = oldArchivable end)
        if not cloned or not avatar then return nil, nil end

        avatar.Name = "AccessoryPreviewAvatar"
        for _, descendant in ipairs(avatar:GetDescendants()) do
            if descendant:IsA("BaseScript") or descendant:IsA("ModuleScript") then
                pcall(function() descendant:Destroy() end)
            end
        end
        for _, child in ipairs(avatar:GetChildren()) do
            if child:IsA("Accessory") or child:IsA("Tool") or child:IsA("ForceField") then
                pcall(function() child:Destroy() end)
            end
        end

        local humanoid = avatar:FindFirstChildOfClass("Humanoid")
        local rootPart = avatar:FindFirstChild("HumanoidRootPart")
        if not humanoid or not rootPart then
            avatar:Destroy()
            return nil, nil
        end

        pcall(function()
            humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            humanoid.PlatformStand = true
            humanoid.AutoRotate = false
            humanoid.EvaluateStateMachine = false
        end)
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if animator then pcall(function() animator:Destroy() end) end

        for _, descendant in ipairs(avatar:GetDescendants()) do
            if descendant:IsA("BasePart") then
                pcall(function()
                    descendant.Anchored = true
                    descendant.CanCollide = false
                    descendant.CanTouch = false
                    descendant.CanQuery = false
                    descendant.Massless = true
                    descendant.LocalTransparencyModifier = 0
                    descendant.AssemblyLinearVelocity = Vector3.zero
                    descendant.AssemblyAngularVelocity = Vector3.zero
                end)
            end
        end

        local pivot = avatar:GetPivot()
        avatar:PivotTo(CFrame.new(-rootPart.Position) * pivot.Rotation)
        return avatar, humanoid
    end

    local function attachPreviewAccessory(humanoid, accessory)
        local handle = accessory:FindFirstChild("Handle")
        local added = pcall(function() humanoid:AddAccessory(accessory) end)
        if added and handle then
            local weld = handle:FindFirstChild("AccessoryWeld") or handle:FindFirstChildWhichIsA("Weld") or handle:FindFirstChildWhichIsA("WeldConstraint")
            local wrapLayer = accessory:FindFirstChildWhichIsA("WrapLayer", true)
            if weld or wrapLayer then return true end
        end
        if not handle or not handle:IsA("BasePart") then return false end
        for _, handleAttachment in ipairs(handle:GetDescendants()) do
            if handleAttachment:IsA("Attachment") then
                for _, bodyPart in ipairs(humanoid.Parent:GetDescendants()) do
                    if bodyPart:IsA("BasePart") then
                        local bodyAttachment = bodyPart:FindFirstChild(handleAttachment.Name)
                        if bodyAttachment and bodyAttachment:IsA("Attachment") then
                            handle.CFrame = bodyPart.CFrame * bodyAttachment.CFrame * handleAttachment.CFrame:Inverse()
                            local weld = Instance.new("Weld")
                            weld.Name = "PreviewAccessoryWeld"
                            weld.Part0 = bodyPart
                            weld.Part1 = handle
                            weld.C0 = bodyAttachment.CFrame
                            weld.C1 = handleAttachment.CFrame
                            weld.Parent = handle
                            return true
                        end
                    end
                end
            end
        end
        return false
    end

    local function renderObjectPreview(item)
        previewGeneration += 1
        local requestGeneration = previewGeneration
        local assetId = math.floor(tonumber(item and item.id) or 0)
        previewViewport.Visible = false
        previewImage.Visible = true
        previewImage.Image = assetId > 0 and ("rbxthumb://type=Asset&id=%d&w=420&h=420"):format(assetId) or ""
        clearPreviewWorld()
        if assetId <= 0 then return end

        task.spawn(function()
            local loaded, roots = pcall(function()
                return game:GetObjects("rbxassetid://" .. tostring(assetId))
            end)
            if not loaded or type(roots) ~= "table" or #roots == 0 then return end

            if requestGeneration ~= previewGeneration or not previewViewport.Parent then
                for _, root in ipairs(roots) do pcall(function() root:Destroy() end) end
                return
            end

            local stage = Instance.new("Model")
            stage.Name = "ObjectPreviewStage"
            stage.Parent = previewWorld

            local accessory = nil
            local accessoryRoot = nil
            for _, root in ipairs(roots) do
                if root:IsA("Accessory") then
                    accessory = root
                    accessoryRoot = root
                    break
                end
                local found = root:FindFirstChildWhichIsA("Accessory", true)
                if found then
                    accessory = found
                    accessoryRoot = root
                    break
                end
            end

            local focusRoot = nil
            local previewAvatar = nil
            if accessory then

                if accessory.Parent then
                    pcall(function() accessory.Parent = nil end)
                end
                accessory.Parent = stage
                enablePreviewEffects(accessory)
                focusRoot = accessory
            end

            for _, root in ipairs(roots) do
                if root ~= accessory and root ~= accessoryRoot then
                    if root.Parent ~= nil then
                        pcall(function() root.Parent = stage end)
                    else
                        pcall(function() root.Parent = stage end)
                    end
                end
            end
            for _, root in ipairs(roots) do
                if root ~= accessory and root ~= accessoryRoot then
                    enablePreviewEffects(root)
                end
            end

            if accessoryRoot and accessoryRoot ~= accessory then
                pcall(function() accessoryRoot:Destroy() end)
            end

            if requestGeneration ~= previewGeneration or not previewViewport.Parent then
                stage:Destroy()
                return
            end

            if not focusRoot then
                focusRoot = stage
            end
            local center, boundsSize = getPreviewBounds(focusRoot)
            if not center or not boundsSize then
                stage:Destroy()
                return
            end

            local viewportSize = previewViewport.AbsoluteSize
            local aspect = viewportSize.Y > 0 and (viewportSize.X / viewportSize.Y) or 1
            local verticalFov = math.rad(previewCamera.FieldOfView)
            local horizontalFov = 2 * math.atan(math.tan(verticalFov * 0.5) * math.max(aspect, 0.1))
            local limitingHalfFov = math.min(verticalFov, horizontalFov) * 0.5
            local boundingRadius = math.max(boundsSize.Magnitude * 0.5, 0.12)

            local distance = math.max((boundingRadius / math.max(math.sin(limitingHalfFov), 0.05)) * 1.48, 0.45)
            local cameraSide = -1
            if previewAvatar then
                local previewRoot = previewAvatar:FindFirstChild("HumanoidRootPart")
                if previewRoot then
                    local localCenter = previewRoot.CFrame:PointToObjectSpace(center)
                    if localCenter.Z > 0.12 then cameraSide = 1 end
                end
            end
            local cameraOffset = Vector3.new(distance * 0.20, distance * 0.08, distance * cameraSide)
            previewCamera.CFrame = CFrame.lookAt(center + cameraOffset, center)
            previewCamera.Focus = CFrame.new(center)
            previewImage.Visible = false
            previewViewport.Visible = true

            local rotation = 0
            local stagePivot = stage:GetPivot()
            previewSpinConnection = RunService.RenderStepped:Connect(function(deltaTime)
                if requestGeneration ~= previewGeneration or not stage.Parent then
                    if previewSpinConnection then
                        previewSpinConnection:Disconnect()
                        previewSpinConnection = nil
                    end
                    return
                end
                rotation += deltaTime * 0.32
                local aroundCenter = CFrame.new(center)
                    * CFrame.Angles(0, rotation, 0)
                    * CFrame.new(-center)
                stage:PivotTo(aroundCenter * stagePivot)
            end)
        end)
    end

    local function itemActionKind(item)
        if not item then return nil, nil end
        if item.kind == "accessory" then return "accessory", item.id end
        if item.key == "deathwalkerEyes" then return "deathwalkerEyes", item.key end
        return "body", item.key
    end

    local function favoriteRecordForItem(item)
        if not item then return nil end
        if item.kind == "body" then
            return makeBodyFavorite({ key = item.key, id = item.id, name = item.name })
        end
        return makeAccessoryFavorite(item.meta)
    end

    local function itemFromBodyPreset(preset)
        return {
            kind = "body", key = preset.key, id = preset.id, name = preset.name,
            description = preset.description,
            favoriteRecord = makeBodyFavorite(preset),
            source = "RECOMENDADO",
        }
    end

    local function itemFromAccessoryPreset(preset)
        local meta = {
            id = preset.id, name = preset.name,
            accessoryType = preset.accessoryType, isLayered = preset.isLayered == true,
        }
        state.accessoryMeta[meta.id] = state.accessoryMeta[meta.id] or meta
        return {
            kind = "accessory", id = meta.id, name = meta.name, meta = state.accessoryMeta[meta.id],
            description = preset.description,
            favoriteRecord = makeAccessoryFavorite(meta),
            source = "RECOMENDADO",
        }
    end

    local function selectionFromFixed(fixed)
        if not fixed then return nil end
        if fixed.type == "accessory" then
            local meta = state.accessoryMeta[fixed.id]
            if not meta then
                meta = { id = fixed.id, name = fixed.name, accessoryType = fixed.accessoryType, isLayered = fixed.isLayered == true }
                state.accessoryMeta[fixed.id] = meta
            end
            return { kind = "accessory", id = fixed.id, name = meta.name or fixed.name, meta = meta, favoriteRecord = makeAccessoryFavorite(meta) }
        end
        local key = fixed.type
        for _, preset in ipairs(BODY_PRESETS) do
            if preset.key == key then return itemFromBodyPreset(preset) end
        end
        return nil
    end

    local function selectionFromFavorite(record)
        local normalized = normalizeFavoriteRecord(record)
        if not normalized then return nil end
        if normalized.kind == "body" then
            return {
                kind = "body", key = normalized.bodyKey, id = normalized.id, name = normalized.name,
                favoriteRecord = normalized, source = "FAVORITO",
            }
        end
        state.accessoryMeta[normalized.id] = state.accessoryMeta[normalized.id] or normalized
        return {
            kind = "accessory", id = normalized.id, name = normalized.name,
            meta = state.accessoryMeta[normalized.id], favoriteRecord = normalized, source = "FAVORITO",
        }
    end

    local function selectItem(item)
        if not item then return end
        selectedItem = item
        state.selectedItem = item
        local kind, key = itemActionKind(item)
        for _, entry in ipairs(state.actionButtons) do
            entry.kind = kind
            entry.key = key
        end
        activeStarRecord = favoriteRecordForItem(item)
        if #state.favoriteButtons > 0 then state.favoriteButtons[1].record = activeStarRecord end

        selectedName.Text = tostring(item.name or "Objeto")
        if item.kind == "body" then
            selectedDetail.Text = "PARTE CORPORAL  ·  ID " .. tostring(item.id)
        else
            selectedDetail.Text = tostring(enumName(item.meta and item.meta.accessoryType) or "ACCESORIO") .. "  ·  ID " .. tostring(item.id)
        end
        previewImage.ImageColor3 = Color3.new(1, 1, 1)
        renderObjectPreview(item)
        accessoriesFilter.BackgroundColor3 = sideCategory == "accessory" and COLORS.AccentFill or COLORS.Surface
        accessoriesFilter.TextColor3 = sideCategory == "accessory" and COLORS.Text or COLORS.Muted
        bodyFilter.BackgroundColor3 = sideCategory == "body" and COLORS.AccentFill or COLORS.Surface
        bodyFilter.TextColor3 = sideCategory == "body" and COLORS.Text or COLORS.Muted

        clearStatus()
        refreshButtons()
    end

    local refreshSidebar
    local setCurrentSelectionActive
    local function cleanSidebarRows()
        disconnectBucket(state.favoriteConnections)
        disconnectBucket(state.equippedConnections)
        for _, row in ipairs(currentSideRows) do pcall(function() row:Destroy() end) end
        table.clear(currentSideRows)
        table.clear(state.favoriteRows)
        table.clear(state.equippedRows)
    end

    local function addSidebarSection(text)
        local label = create("TextLabel", {
            Size = UDim2.new(1, -6, 0, 21),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Text = string.upper(text),
            TextColor3 = COLORS.Muted,
            TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = #currentSideRows + 1,
        }, sideList)
        label:SetAttribute("AvatarSidebarAnchor", "SECTION:" .. string.lower(text))
        table.insert(currentSideRows, label)
        if text == "Equipados" then
            table.insert(state.equippedRows, label)
        else
            table.insert(state.favoriteRows, label)
        end
    end

    local function sidebarItemKey(item)
        return favoriteKey(favoriteRecordForItem(item))
    end

    local function makeSidebarRow(item, sourceLabel)
        local active = selectedItem and sidebarItemKey(selectedItem) == sidebarItemKey(item)
        local record = favoriteRecordForItem(item)
        local saved = record and isFavorite(record) or false
        local subtitle
        if sourceLabel == "FAVORITO" then
            subtitle = "★ GUARDADO  ·  ID " .. tostring(item.id)
        elseif sourceLabel == "RESULTADO" then
            subtitle = (item.kind == "body" and "PARTE CORPORAL" or "ACCESORIO") .. "  ·  ID " .. tostring(item.id)
        elseif sourceLabel == "EQUIPADO" then
            subtitle = tostring(item.source or "EQUIPADO") .. "  ·  ID " .. tostring(item.id)
        elseif item.kind == "body" then
            subtitle = "RECOMENDADO  ·  PARTE CORPORAL"
        else
            subtitle = (saved and "RECOMENDADO  ·  ★" or "RECOMENDADO") .. "  ·  ID " .. tostring(item.id)
        end
        local row = create("TextButton", {
            Size = UDim2.new(1, -6, 0, 34),
            BackgroundColor3 = active and COLORS.ActiveFill or COLORS.Surface,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Font = Enum.Font.Gotham,
            Text = "",
            LayoutOrder = #currentSideRows + 1,
        }, sideList)
        round(row, 7)
        create("TextLabel", {
            Position = UDim2.fromOffset(9, 3),
            Size = UDim2.new(1, -18, 0, 15),
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = tostring(item.name or "Objeto"),
            TextSize = 10,
            TextColor3 = active and Color3.new(1, 1, 1) or COLORS.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }, row)
        create("TextLabel", {
            Position = UDim2.fromOffset(9, 18),
            Size = UDim2.new(1, -18, 0, 12),
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = subtitle,
            TextSize = 8,
            TextColor3 = active and COLORS.Text or COLORS.Muted,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }, row)
        local anchorKey = "ROW:" .. tostring(sourceLabel) .. ":" .. tostring(sidebarItemKey(item))
        row:SetAttribute("AvatarSidebarAnchor", anchorKey)
        local connectionBucket = sourceLabel == "EQUIPADO" and state.equippedConnections or state.favoriteConnections
        addConnection(connectionBucket, row.Activated:Connect(function()
            sideCategory = item.kind == "body" and "body" or "accessory"
            if item.source == "RESULTADO" then sideMode = "results" end
            selectItem(item)
            refreshSidebar()
        end))
        table.insert(currentSideRows, row)
        if sourceLabel == "EQUIPADO" then
            table.insert(state.equippedRows, row)
        else
            table.insert(state.favoriteRows, row)
        end
        return row
    end

    local function getRecommendedItems()
        local list = {}
        if sideCategory == "accessory" then
            for _, preset in ipairs(PRESETS) do table.insert(list, itemFromAccessoryPreset(preset)) end
        else
            for _, preset in ipairs(BODY_PRESETS) do table.insert(list, itemFromBodyPreset(preset)) end
        end
        return list
    end

    refreshSidebar = function()
        local previousCanvasY = sideList.CanvasPosition.Y
        local previousAnchorKey, previousAnchorOffset = nil, nil
        local viewportTop = sideList.AbsolutePosition.Y
        local viewportBottom = viewportTop + sideList.AbsoluteSize.Y
        local anchorTop = math.huge
        for _, row in ipairs(currentSideRows) do
            if row and row.Parent and row.Visible then
                local rowTop = row.AbsolutePosition.Y
                local rowBottom = rowTop + row.AbsoluteSize.Y
                if rowBottom > viewportTop and rowTop < viewportBottom and rowTop < anchorTop then
                    local candidate = row:GetAttribute("AvatarSidebarAnchor")
                    if candidate then
                        anchorTop = rowTop
                        previousAnchorKey = candidate
                        previousAnchorOffset = rowTop - viewportTop
                    end
                end
            end
        end
        sidebarRenderGeneration += 1
        local thisRender = sidebarRenderGeneration
        cleanSidebarRows()
        local seen = {}
        sidebarHeader.Text = sideCategory == "body" and "Cuerpo" or "Accesorios"

        local function belongsToCurrentCategory(item)
            return item and (
                (item.kind == "body" and sideCategory == "body")
                or (item.kind == "accessory" and sideCategory == "accessory")
            )
        end

        addSidebarSection("Favoritos")
        local favorites = {}
        for _, record in pairs(state.favoriteItems) do
            local item = selectionFromFavorite(record)
            if belongsToCurrentCategory(item) then
                local key = sidebarItemKey(item)
                if key and not seen[key] then
                    seen[key] = true
                    item.source = "FAVORITO"
                    table.insert(favorites, item)
                end
            end
        end
        table.sort(favorites, function(a, b)
            return tostring(a.name or ""):lower() < tostring(b.name or ""):lower()
        end)
        if #favorites > 0 then
            for _, item in ipairs(favorites) do
                makeSidebarRow(item, "FAVORITO")
            end
        else
            local emptyFavorites = create("TextLabel", {
                Size = UDim2.new(1, -8, 0, 31),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = "Sin favoritos",
                TextColor3 = COLORS.Muted,
                TextSize = 9,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = #currentSideRows + 1,
            }, sideList)
            emptyFavorites:SetAttribute("AvatarSidebarAnchor", "EMPTY:FAVORITES")
            table.insert(currentSideRows, emptyFavorites)
            table.insert(state.favoriteRows, emptyFavorites)
        end

        addSidebarSection("Recomendados")
        local recommendedCount = 0
        local recommendedSeen = {}
        for _, item in ipairs(getRecommendedItems()) do
            local key = sidebarItemKey(item)
            if key and not recommendedSeen[key] then
                recommendedSeen[key] = true
                makeSidebarRow(item, "RECOMENDADO")
                recommendedCount += 1
            end
        end
        if recommendedCount == 0 then
            local noRecommendations = create("TextLabel", {
                Size = UDim2.new(1, -8, 0, 28),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = "Sin recomendaciones disponibles",
                TextColor3 = COLORS.Muted,
                TextSize = 9,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = #currentSideRows + 1,
            }, sideList)
            noRecommendations:SetAttribute("AvatarSidebarAnchor", "EMPTY:RECOMMENDED")
            table.insert(currentSideRows, noRecommendations)
            table.insert(state.favoriteRows, noRecommendations)
        end

        if sideCategory == "accessory" then
            addSidebarSection("Equipados")
            local equippedItems = {}
            for _, item in ipairs(collectCurrentItems(false)) do
                if item.kind == "accessory" then
                    local key = sidebarItemKey(item)
                    if key then
                        table.insert(equippedItems, item)
                    end
                end
            end
            if #equippedItems > 0 then
                for _, item in ipairs(equippedItems) do
                    makeSidebarRow(item, "EQUIPADO")
                end
            else
                local emptyEquipped = create("TextLabel", {
                    Size = UDim2.new(1, -8, 0, 28),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    Text = "No hay accesorios equipados",
                    TextColor3 = COLORS.Muted,
                    TextSize = 9,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    LayoutOrder = #currentSideRows + 1,
                }, sideList)
                emptyEquipped:SetAttribute("AvatarSidebarAnchor", "EMPTY:EQUIPPED")
                table.insert(currentSideRows, emptyEquipped)
                table.insert(state.equippedRows, emptyEquipped)
            end
        end

        if sideMode == "results" then
            addSidebarSection("Resultados")
            local resultCount = 0
            for _, item in ipairs(searchResults) do
                item.source = "RESULTADO"
                local key = sidebarItemKey(item)
                if key and not seen[key] then
                    seen[key] = true
                    makeSidebarRow(item, "RESULTADO")
                    resultCount += 1
                end
            end
            if resultCount == 0 then
                local emptyResults = create("TextLabel", {
                    Size = UDim2.new(1, -8, 0, 32),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    Text = "Sin resultados",
                    TextColor3 = COLORS.Muted,
                    TextSize = 9,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    LayoutOrder = #currentSideRows + 1,
                }, sideList)
                table.insert(currentSideRows, emptyResults)
                table.insert(state.favoriteRows, emptyResults)
            end
        end

        task.spawn(function()
            RunService.Heartbeat:Wait()
            RunService.Heartbeat:Wait()
            if thisRender ~= sidebarRenderGeneration or not sideList.Parent then return end
            local targetCanvasY = previousCanvasY
            local anchorFound = false
            if previousAnchorKey then
                for _, row in ipairs(currentSideRows) do
                    if row and row.Parent and row:GetAttribute("AvatarSidebarAnchor") == previousAnchorKey then
                        local currentOffset = row.AbsolutePosition.Y - sideList.AbsolutePosition.Y
                        targetCanvasY = sideList.CanvasPosition.Y + currentOffset - (previousAnchorOffset or 0)
                        anchorFound = true
                        break
                    end
                end
                if not anchorFound then targetCanvasY = 0 end
            end
            local maxY = math.max(0, sideList.AbsoluteCanvasSize.Y - sideList.AbsoluteSize.Y)
            sideList.CanvasPosition = Vector2.new(0, math.clamp(targetCanvasY, 0, maxY))
        end)
    end

    setCurrentSelectionActive = function(item, desired)
        if not item then return false, "Selecciona un objeto primero." end
        if item.kind == "accessory" then
            return setAccessoryDesired(item.meta, desired)
        end
        if item.key == "deathwalkerEyes" then
            local active = state.deathwalkerEyesActive == true
            if active == desired then return true, desired and "Deathwalker ya está aplicado." or "Deathwalker ya está retirado." end
            return toggleDeathwalkerEyes()
        end
        local active = state.bodyActive[item.key] == true
        if active == desired then return true, desired and "La modificación ya está aplicada." or "La modificación ya está retirada." end
        return toggleBodyPart(item.key)
    end

    local function setSelectedFavorite()
        if not selectedItem then
            return
        end
        local record = favoriteRecordForItem(selectedItem)
        if record then toggleFavorite(record) end
    end

    state.refreshFavoriteButtons = function()
        for index = #state.favoriteButtons, 1, -1 do
            local entry = state.favoriteButtons[index]
            local button = entry and entry.button
            if not button or not button.Parent then
                table.remove(state.favoriteButtons, index)
            else
                local active = entry.record and isFavorite(entry.record) or false
                button.Text = active and "★" or "☆"
                button.TextColor3 = active and Color3.fromRGB(250, 204, 21) or COLORS.Muted
                button.BackgroundColor3 = active and Color3.fromRGB(49, 42, 25) or COLORS.Background
                button.Active = not state.busy and entry.record ~= nil
                button.AutoButtonColor = not state.busy
            end
        end
    end
    state.refreshFavoritesPage = function() refreshSidebar() end

    local function setSelectedItemAndRefresh(item)
        selectItem(item)
        refreshSidebar()
    end

    local defaultItem = itemFromAccessoryPreset(PRESETS[1])
    setSelectedItemAndRefresh(defaultItem)
    refreshSidebar()

    applyButton.Activated:Connect(function()
        local item = selectedItem
        if not item then return end
        runAction(function() return setCurrentSelectionActive(item, true) end, "Aplicado")
    end)
    removeButton.Activated:Connect(function()
        local item = selectedItem
        if not item then return end
        runAction(function() return setCurrentSelectionActive(item, false) end, "Retirado")
    end)
    favoriteStar.Activated:Connect(setSelectedFavorite)
    restoreButton.Activated:Connect(function() runAction(clearAllOverrides, "Retirado") end)

    accessoriesFilter.Activated:Connect(function()
        sideCategory = "accessory"
        sideMode = "recommended"
        accessoriesFilter.BackgroundColor3 = COLORS.AccentFill
        accessoriesFilter.TextColor3 = COLORS.Text
        bodyFilter.BackgroundColor3 = COLORS.Surface
        bodyFilter.TextColor3 = COLORS.Muted
        refreshSidebar()
    end)
    bodyFilter.Activated:Connect(function()
        sideCategory = "body"
        sideMode = "recommended"
        accessoriesFilter.BackgroundColor3 = COLORS.Surface
        accessoriesFilter.TextColor3 = COLORS.Muted
        bodyFilter.BackgroundColor3 = COLORS.AccentFill
        bodyFilter.TextColor3 = COLORS.Text
        refreshSidebar()
    end)

    local function search(query)
        query = tostring(query or ""):gsub("^%s+", ""):gsub("%s+$", "")
        if query == "" then
            setStatus("Fallo")
            return
        end
        if searching or state.busy then return end
        clearStatus()

        local fixed = findFixedPresetByName(query)
        if fixed then
            local item = selectionFromFixed(fixed)
            if item then
                sideCategory = item.kind == "body" and "body" or "accessory"
                sideMode = "recommended"
                accessoriesFilter.BackgroundColor3 = sideCategory == "accessory" and COLORS.AccentFill or COLORS.Surface
                accessoriesFilter.TextColor3 = sideCategory == "accessory" and COLORS.Text or COLORS.Muted
                bodyFilter.BackgroundColor3 = sideCategory == "body" and COLORS.AccentFill or COLORS.Surface
                bodyFilter.TextColor3 = sideCategory == "body" and COLORS.Text or COLORS.Muted
                setSelectedItemAndRefresh(item)
            end
            return
        end

        local isDirectId = query:match("^%d+$") ~= nil
            or query:match("roblox%.com/catalog/%d+") ~= nil
            or query:match("roblox%.com/bundles/%d+") ~= nil
        if isDirectId then
            local id = parseAssetId(query)
            local known = id and findFixedPresetById(id)
            if known then
                local item = selectionFromFixed(known)
                if item then
                    sideCategory = item.kind == "body" and "body" or "accessory"
                    sideMode = "recommended"
                    setSelectedItemAndRefresh(item)
                end
                return
            end
            searching = true

            task.spawn(function()
                local meta, err = getItemMeta(id, nil, nil)
                if meta and meta.type then
                    local item = selectionFromFixed(meta)
                    if item then
                        sideCategory = item.kind == "body" and "body" or "accessory"
                        sideMode = "recommended"
                        setSelectedItemAndRefresh(item)
                    else
                        setStatus("Fallo")
                    end
                elseif meta and meta.accessoryType then
                    state.accessoryMeta[meta.id] = meta
                    searchResults = {{ kind = "accessory", id = meta.id, name = meta.name, meta = meta, favoriteRecord = makeAccessoryFavorite(meta), source = "RESULTADO" }}
                    sideMode = "results"
                    sideCategory = "accessory"
                    refreshSidebar()
                    selectItem(searchResults[1])
                    refreshSidebar()

                else
                    setStatus("Fallo")
                end
                searching = false
            end)
            return
        end

        searching = true
        searchResults = {}
        sideMode = "results"
        refreshSidebar()

        task.spawn(function()
            local ok, err = pcall(function()
                local params = CatalogSearchParams.new()
                params.SearchKeyword = query
                params.Limit = 20
                params.IncludeOffSale = true
                local types = {}
                for _, assetType in ipairs(Enum.AvatarAssetType:GetEnumItems()) do
                    if assetType.Name == "Hat" or ACCESSORY_TYPE_MAP[assetType.Name] then
                        table.insert(types, assetType)
                    end
                end
                if #types > 0 then params.AssetTypes = types end
                local pages = AvatarEditorService:SearchCatalogAsync(params)
                for _, result in ipairs(pages:GetCurrentPage() or {}) do
                    local id = tonumber(result.Id)
                    if id and (result.ItemType == "Asset" or result.AssetType) then
                        local accessoryType, isLayered = mapAccessoryType(result.AssetType)
                        if accessoryType then
                            local meta = {
                                id = math.floor(id),
                                name = tostring(result.Name or ("Accesorio " .. tostring(id))),
                                accessoryType = accessoryType,
                                isLayered = isLayered == true,
                            }
                            state.accessoryMeta[meta.id] = meta
                            table.insert(searchResults, {
                                kind = "accessory", id = meta.id, name = meta.name, meta = meta,
                                favoriteRecord = makeAccessoryFavorite(meta), source = "RESULTADO",
                            })
                        end
                    end
                end
            end)
            searching = false
            refreshSidebar()
            if not ok then
                setStatus("Fallo")
            elseif #searchResults == 0 then
                setStatus("Fallo")
            else
                selectItem(searchResults[1])
                refreshSidebar()

            end
        end)
    end

    searchButton.Activated:Connect(function() search(searchInput.Text) end)
    searchInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then search(searchInput.Text) end
    end)

    state.refreshEquipped = nil

    local floatingPositionInitialized = false

    local function clampReopenPosition(position)
        local camera = Workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
        local halfSize = Vector2.new(
            minimizedButton.AbsoluteSize.X * 0.5 + 1,
            minimizedButton.AbsoluteSize.Y * 0.5 + 1
        )
        local maxX, maxY = viewport.X - halfSize.X, viewport.Y - halfSize.Y
        if maxX < halfSize.X or maxY < halfSize.Y then
            return Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
        end
        return Vector2.new(math.clamp(position.X, halfSize.X, maxX), math.clamp(position.Y, halfSize.Y, maxY))
    end

    local function getReopenCenter()
        return getGuiCenter(minimizedButton)
    end

    local function setReopenCenter(position)
        setGuiCenter(minimizedButton, clampReopenPosition(position))
    end

    local function initializeReopenPosition()
        if floatingPositionInitialized then return end
        local viewport = getViewportSize()
        local halfSize = minimizedButton.AbsoluteSize * 0.5
        setReopenCenter(Vector2.new(viewport.X - halfSize.X - 16, viewport.Y * 0.5 - 28))
        floatingPositionInitialized = true
    end

    local reopenDrag = nil
    local mainDrag = nil

    local function hideWindow()
        if backgroundTween then backgroundTween:Cancel(); backgroundTween = nil end
        keepMainInsideViewport()
        initializeReopenPosition()
        main.Visible = false
        minimizedButton.Visible = true
        if avatarBridge.uiPanels.activePanel == "accessories" then
            avatarBridge.uiPanels.activePanel = "none"
        end
    end

    local function closePanelForSwitch()
        if backgroundTween then backgroundTween:Cancel(); backgroundTween = nil end
        reopenDrag = nil
        mainDrag = nil
        main.Visible = false
        minimizedButton.Visible = true
        if avatarBridge.uiPanels.activePanel == "accessories" then
            avatarBridge.uiPanels.activePanel = "none"
        end
    end

    local function showWindow()
        local closeSkinsPanel = avatarBridge.uiPanels.closeSkinsPanel
        if type(closeSkinsPanel) == "function" then pcall(closeSkinsPanel) end
        avatarBridge.uiPanels.activePanel = "accessories"
        screen.Enabled = true
        main.Visible = true
        animateBackground()
        minimizedButton.Visible = false
        setMainCenter(mainCenter)
        if state.connectDragConnections then state.connectDragConnections() end
        updateScale()
    end

    state.showWindow = showWindow
    state.initializeReopenPosition = initializeReopenPosition
    state.closePanelForSwitch = closePanelForSwitch

    minimize.Activated:Connect(hideWindow)

    local function beginReopenDrag(input)
        local inputType = input.UserInputType
        if inputType ~= Enum.UserInputType.MouseButton1
            and inputType ~= Enum.UserInputType.Touch then return end
        reopenDrag = {
            input = input,
            inputType = inputType,
            start = Vector2.new(input.Position.X, input.Position.Y),
            origin = getReopenCenter(),
            moved = false,
        }
    end

    local function moveReopenDrag(input, isTouch)
        local drag = reopenDrag
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
        if drag.moved then setReopenCenter(drag.origin + delta) end
    end

    local function finishReopenDrag(input, isTouch)
        local drag = reopenDrag
        if not drag then return end
        local ended
        if isTouch then
            ended = drag.inputType == Enum.UserInputType.Touch and input == drag.input
        else
            ended = drag.inputType == Enum.UserInputType.MouseButton1
                and input.UserInputType == Enum.UserInputType.MouseButton1
        end
        if not ended then return end
        reopenDrag = nil
        if not drag.moved then showWindow() end
    end

    local function beginMainDrag(input)
        local inputType = input.UserInputType
        if inputType ~= Enum.UserInputType.MouseButton1
            and inputType ~= Enum.UserInputType.Touch then return end
        mainDrag = {
            input = input,
            inputType = inputType,
            start = Vector2.new(input.Position.X, input.Position.Y),
            origin = mainCenter,
        }
    end

    local function moveMainDrag(input, isTouch)
        local drag = mainDrag
        if not drag then return end
        if isTouch then
            if drag.inputType ~= Enum.UserInputType.Touch or input ~= drag.input then return end
        elseif drag.inputType ~= Enum.UserInputType.MouseButton1
            or input.UserInputType ~= Enum.UserInputType.MouseMovement then
            return
        end
        local pointer = Vector2.new(input.Position.X, input.Position.Y)
        setMainCenter(drag.origin + pointer - drag.start)
    end

    local function finishMainDrag(input, isTouch)
        local drag = mainDrag
        if not drag then return end
        local ended
        if isTouch then
            ended = drag.inputType == Enum.UserInputType.Touch and input == drag.input
        else
            ended = drag.inputType == Enum.UserInputType.MouseButton1
                and input.UserInputType == Enum.UserInputType.MouseButton1
        end
        if ended then mainDrag = nil end
    end

    local function disconnectDragConnections()
        reopenDrag = nil
        mainDrag = nil
        disconnectBucket(state.dragConnections)
    end

    local function connectDragConnections()
        if #state.dragConnections > 0 then return end
        addConnection(state.dragConnections, minimizedClick.InputBegan:Connect(beginReopenDrag))
        addConnection(state.dragConnections, UserInputService.InputChanged:Connect(function(input)
            moveReopenDrag(input, false)
            moveMainDrag(input, false)
        end))
        addConnection(state.dragConnections, UserInputService.TouchMoved:Connect(function(input)
            moveReopenDrag(input, true)
            moveMainDrag(input, true)
        end))
        addConnection(state.dragConnections, UserInputService.InputEnded:Connect(function(input)
            finishReopenDrag(input, false)
            finishMainDrag(input, false)
        end))
        addConnection(state.dragConnections, UserInputService.TouchEnded:Connect(function(input)
            finishReopenDrag(input, true)
            finishMainDrag(input, true)
        end))
        addConnection(state.dragConnections, header.InputBegan:Connect(beginMainDrag))
    end

    state.connectDragConnections = connectDragConnections
    state.disconnectDragConnections = disconnectDragConnections

    closeButton.Activated:Connect(function() closeOverlay.Visible = true end)
    cancelClose.Activated:Connect(function() closeOverlay.Visible = false end)
    confirmClose.Activated:Connect(function()
        closeOverlay.Visible = false
        if cleanup then
            pcall(cleanup)
        else
            screen:Destroy()
        end
    end)

    local viewportConnection = nil
    local function connectCurrentCamera()
        if viewportConnection then pcall(function() viewportConnection:Disconnect() end) end
        local camera = Workspace.CurrentCamera
        if camera then
            viewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
                updateScale()
                if minimizedButton.Visible and floatingPositionInitialized then
                    task.defer(function() setReopenCenter(getReopenCenter()) end)
                end
            end)
            addConnection(state.uiConnections, viewportConnection)
        end
        updateScale()
        if minimizedButton.Visible and floatingPositionInitialized then
            task.defer(function() setReopenCenter(getReopenCenter()) end)
        end
    end
    connectCurrentCamera()
    addConnection(state.uiConnections, Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(connectCurrentCamera))
    addConnection(state.uiConnections, UserInputService.InputBegan:Connect(function(input, processed)
        if processed or not screen.Enabled then return end
        if input.KeyCode == Enum.KeyCode.RightControl then
            if main.Visible then hideWindow() else showWindow() end
        end
    end))

    state.refreshFavoriteButtons()
    refreshButtons()
    refreshSidebar()

    return screen
end
local function onCharacterAdded(character)
    disposeVisualOverlay(true)
    disconnectBucket(state.characterConnections)
    state.generation += 1
    if state.inventoryCache then state.inventoryCache.key = nil end
    local generation = state.generation
    state.character = character
    state.humanoid = nil

    task.spawn(function()
        local humanoid = character:WaitForChild("Humanoid", 12)
        local rootPart = character:WaitForChild("HumanoidRootPart", 12)
        if not humanoid or not rootPart or generation ~= state.generation then return end
        if not (humanoid.Parent and rootPart.Parent and character == localPlayer.Character) then return end

        state.humanoid = humanoid
        local didDie = humanoid.Health <= 0
        addConnection(state.characterConnections, humanoid.Died:Connect(function()
            if generation == state.generation then
                didDie = true
                state.generation += 1
                state.applying = false
                disposeVisualOverlay(true)
            end
        end))
        addConnection(state.characterConnections, humanoid.HealthChanged:Connect(function(health)
            if not didDie or health <= 0
                or state.character ~= character
                or character ~= localPlayer.Character then
                return
            end
            didDie = false
            local reviveGeneration = state.generation
            task.defer(function()
                if reviveGeneration == state.generation
                    and state.character == character
                    and hasVisualChanges()
                    and not isSkinRendererActive() then
                    local applied = applyCurrentAppearance()
                    if not applied then setStatus("Fallo") end
                end
            end)
        end))

        local appearanceSignalOk, appearanceSignal = pcall(function()
            return humanoid.ApplyDescriptionFinished
        end)
        if appearanceSignalOk and appearanceSignal then
            addConnection(state.characterConnections, appearanceSignal:Connect(function(appliedDescription)
                if generation ~= state.generation or character ~= localPlayer.Character then return end
                if isSkinRendererActive() then
                    if state.refreshFavoritesPage then pcall(state.refreshFavoritesPage) end
                    return
                end

                local clonedDescription = nil
                if appliedDescription and appliedDescription:IsA("HumanoidDescription") then
                    local cloneOk, clone = pcall(function() return appliedDescription:Clone() end)
                    if cloneOk then clonedDescription = clone end
                end
                if clonedDescription then
                    local newSignature = getDescriptionSignature(clonedDescription)
                    if state.baseDescription and state.baseDescriptionSignature == newSignature then
                        pcall(function() clonedDescription:Destroy() end)
                    else
                        if state.baseDescription then
                            pcall(function() state.baseDescription:Destroy() end)
                        end
                        state.baseDescription = clonedDescription
                        state.baseDescriptionSignature = newSignature
                        if state.inventoryCache then state.inventoryCache.key = nil end
                        clearVisualTemplate()
                    end
                end

                task.defer(function()
                    while state.applying and generation == state.generation and character == localPlayer.Character do
                        RunService.Heartbeat:Wait()
                    end
                    if generation ~= state.generation or character ~= localPlayer.Character then return end
                    if hasVisualChanges() and humanoid.Health > 0 then
                        local applied = applyCurrentAppearance()
                        if not applied then setStatus("Fallo") end
                    end
                    if state.refreshFavoritesPage then pcall(state.refreshFavoritesPage) end
                end)
            end))
        end

        local description = nil
        local appliedOk, appliedDescription = pcall(function()
            return humanoid:GetAppliedDescription()
        end)
        if appliedOk and appliedDescription then
            description = appliedDescription
        elseif state.baseDescription then
            local cloneOk, cachedDescription = pcall(function()
                return state.baseDescription:Clone()
            end)
            if cloneOk then description = cachedDescription end
        else
            local descriptionError
            description, descriptionError = getCurrentBaseDescription(humanoid)
            if not description then
                setStatus("Fallo")
                return
            end
        end
        if generation ~= state.generation then
            pcall(function() description:Destroy() end)
            return
        end

        local signature = getDescriptionSignature(description)
        if state.baseDescription and state.baseDescriptionSignature == signature then
            pcall(function() description:Destroy() end)
        else
            if state.baseDescription then
                pcall(function() state.baseDescription:Destroy() end)
            end
            state.baseDescription = description
            state.baseDescriptionSignature = signature
            if state.inventoryCache then state.inventoryCache.key = nil end
            clearVisualTemplate()
        end

        while state.applying and generation == state.generation and character == localPlayer.Character do
            RunService.Heartbeat:Wait()
        end
        if generation ~= state.generation or character ~= localPlayer.Character then return end

        if hasVisualChanges() and not isSkinRendererActive() and humanoid.Health > 0 then
            local ok = applyCurrentAppearance()
            if not ok then setStatus("Fallo") end
        end
        refreshButtons()
        if state.refreshEquipped then state.refreshEquipped() end
        if state.refreshFavoritesPage then state.refreshFavoritesPage() end
        if avatarBridge.accessory.refreshInventory then
            pcall(avatarBridge.accessory.refreshInventory)
        end
    end)
end

local accessoryApi = nil

cleanup = function()
    state.generation += 1
    state.applying = false
    if state.disconnectDragConnections then state.disconnectDragConnections() end
    if avatarBridge.uiPanels.closeAccessoriesPanel == state.closePanelForSwitch then
        avatarBridge.uiPanels.closeAccessoriesPanel = nil
    end
    if avatarBridge.uiPanels.activePanel == "accessories" then
        avatarBridge.uiPanels.activePanel = "none"
    end
    disconnectBucket(state.connections)
    disconnectBucket(state.characterConnections)
    disconnectBucket(state.uiConnections)
    disconnectBucket(state.resultConnections)
    disconnectBucket(state.favoriteConnections)
    disconnectBucket(state.equippedConnections)
    local skinActive = isSkinRendererActive()
    disposeVisualOverlay(true)
    clearVisualTemplate()
    if avatarBridge.accessory.owner == accessoryBridgeToken then
        avatarBridge.accessory.owner = nil
        avatarBridge.accessory.hasChanges = nil
        avatarBridge.accessory.revision = nil
        avatarBridge.accessory.composeDescription = nil
        avatarBridge.accessory.suspend = nil
        avatarBridge.accessory.refresh = nil
        avatarBridge.accessory.refreshInventory = nil
        avatarBridge.accessory.getEquippedSnapshot = nil
        avatarBridge.accessory.inventorySnapshot = nil
        avatarBridge.accessory.inventoryRevision = nil
    end
    if state.baseDescription then
        pcall(function() state.baseDescription:Destroy() end)
        state.baseDescription = nil
    end
    if state.gui then
        pcall(function() state.gui:Destroy() end)
        state.gui = nil
    end
    if skinActive and type(avatarBridge.skin.refresh) == "function" then
        task.defer(function()
            pcall(avatarBridge.skin.refresh)
        end)
    end
end

if isSkinRendererActive() and type(avatarBridge.skin.refresh) == "function" then
    task.defer(function()
        pcall(avatarBridge.skin.refresh)
    end)
end

addConnection(state.connections, localPlayer.CharacterAdded:Connect(onCharacterAdded))
addConnection(state.connections, localPlayer.CharacterRemoving:Connect(function(character)
    if state.character == character then
        state.generation += 1
        if state.inventoryCache then state.inventoryCache.key = nil end
        if avatarBridge.accessory.owner == accessoryBridgeToken then
            avatarBridge.accessory.inventorySnapshot = nil
            avatarBridge.accessory.inventoryRevision = (tonumber(avatarBridge.accessory.inventoryRevision) or 0) + 1
        end
        disposeVisualOverlay(true)
        state.character = nil
        state.humanoid = nil
    end
end))
if localPlayer.Character then
    onCharacterAdded(localPlayer.Character)
end

loadFavoriteItems()
buildUI()
avatarBridge.uiPanels.closeAccessoriesPanel = state.closePanelForSwitch
if state.gui then
    state.gui.Enabled = false
end

accessoryApi = {
    Name = "SilentHub",
    Description = "Accesorios",
    gui = state.gui,
    State = state,
    Presets = PRESETS,
    BodyPresets = BODY_PRESETS,
    Cleanup = cleanup,
    SetEnabled = function(enabled)
        if not state.gui then return false end
        if enabled == true then
            if state.initializeReopenPosition then state.initializeReopenPosition() end
            state.gui.Enabled = true
            if state.main then state.main.Visible = false end
            if state.reopen then state.reopen.Visible = true end
            if state.connectDragConnections then state.connectDragConnections() end
        else
            if backgroundTween then backgroundTween:Cancel(); backgroundTween = nil end
            if state.disconnectDragConnections then state.disconnectDragConnections() end
            state.gui.Enabled = false
            if state.main then state.main.Visible = false end
            if state.reopen then state.reopen.Visible = false end
            if avatarBridge.uiPanels.activePanel == "accessories" then
                avatarBridge.uiPanels.activePanel = "none"
            end
        end
        return true
    end,
    Open = function()
        if not state.gui then return false end
        if state.showWindow then
            state.showWindow()
        else
            state.gui.Enabled = true
            if state.main then state.main.Visible = true end
            if state.reopen then state.reopen.Visible = false end
        end
        return true
    end,
    ApplyAsset = function(assetId, desired)
        local meta, metaError = getItemMeta(assetId)
        if not meta then return false, metaError end
        if meta.type and meta.type ~= "accessory" then
            if meta.type == "headless" or meta.type == "korbloxLeg" then
                return toggleBodyPart(meta.type)
            elseif meta.type == "deathwalkerEyes" then
                return toggleDeathwalkerEyes()
            end
            return false, "El ID no corresponde a un accesorio compatible."
        end
        if desired == nil then
            desired = not isAccessoryDesired(meta.id, getActiveAppearanceBaseDescription())
        end
        return setAccessoryDesired(meta, desired == true)
    end,
    ToggleBodyPart = toggleBodyPart,
    ToggleDeathwalkerEyes = toggleDeathwalkerEyes,
    Clear = clearAllOverrides,
}
return accessoryApi