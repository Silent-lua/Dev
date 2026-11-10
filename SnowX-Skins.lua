local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserService = game:GetService("UserService")
local CONFIG_PATH = "snowx/skins.json"
local localPlayer = Players.LocalPlayer

local avatarBridge = ...
if type(avatarBridge) ~= "table" then avatarBridge = {} end
avatarBridge.version = 2
avatarBridge.skin = type(avatarBridge.skin) == "table" and avatarBridge.skin or {}
avatarBridge.accessory = type(avatarBridge.accessory) == "table" and avatarBridge.accessory or {}
avatarBridge.skin.revision = tonumber(avatarBridge.skin.revision) or 0
avatarBridge.accessory.revision = tonumber(avatarBridge.accessory.revision) or 0
local skinBridgeToken = {}
local function isSkinRendererActive()
    return avatarBridge.skin.active == true or avatarBridge.skin.pending == true
end

local function bumpSkinRevision()
    avatarBridge.skin.revision = (tonumber(avatarBridge.skin.revision) or 0) + 1
end

local theme = {
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
		if typeof(isfolder) == "function" and typeof(makefolder) == "function" and not isfolder("snowx") then
			makefolder("snowx")
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

		for _, v2 in ipairs(pendingIconRequests) do
			setLucideImage(v2[1], v2[2])
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
	local currentEmoteTrack = nil

	if humanoid then
		local ok, result = pcall(humanoid.GetAppliedDescription, humanoid)
		ok = ok and result
		currentEmoteTrack = nil

		if ok then
			currentEmoteTrack = result
		end
	end

	if not currentEmoteTrack then
		local ok, result = pcall(function()
			return Players:GetHumanoidDescriptionFromUserIdAsync(userId)
		end)

		if not (ok and result) then
			ok, result = pcall(Players.GetHumanoidDescriptionFromUserId, Players, userId)
		end

		if ok and result then
			currentEmoteTrack = result
		end
	end

	if currentEmoteTrack then
		humanoidDescriptionCache[userId] = currentEmoteTrack
	end

	return currentEmoteTrack
end

local loadedAssetObjectsCache = {}

local function loadAssetObjects(assetId)
	local str2 = tostring(assetId)
	if loadedAssetObjectsCache[str2] ~= nil then
		return loadedAssetObjectsCache[str2] or nil
	end
	local ok, result = pcall(game.GetObjects, game, "rbxassetid://" .. str2)
	if not (ok and type(result) == "table") then
		loadedAssetObjectsCache[str2] = false
		return nil
	end

	for _, currentEmoteTrack in ipairs(result) do
		currentEmoteTrack.Parent = nil
	end

	loadedAssetObjectsCache[str2] = result
	return result
end

local function preloadAnimationAssets(humanoidDescription)
	local n3 = 0

	for _, currentEmoteTrack in pairs(animationScriptNames) do
		local v3 = humanoidDescription[currentEmoteTrack]

		if type(v3) == "number" and v3 > 0 and loadedAssetObjectsCache[tostring(v3)] == nil then
			n3 += 1

			task.spawn(function()
				loadAssetObjects(v3)
				n3 -= 1
			end)
		end
	end

	local now = os.clock()

	while n3 > 0 and os.clock() - now < 15 do
		task.wait(0.05)
	end
end

local function extractAnimationSets(humanoidDescription)
	local tbl9 = {}
	preloadAnimationAssets(humanoidDescription)

	for k, currentEmoteTrack in pairs(animationScriptNames) do
		local v3 = humanoidDescription[currentEmoteTrack]

		if type(v3) == "number" and v3 > 0 then
			local v4 = loadAssetObjects(v3)
			local v5 = ipairs
			local tbl10 = v4 or {}

			for _, v6 in v5(tbl10) do
				for _, descendant in ipairs(v6:GetDescendants()) do
					if descendant:IsA("Animation") and descendant.Parent and descendant.Parent ~= v6 then
						local name = descendant.Parent.Name
						tbl9[name] = tbl9[name] or {}
						table.insert(tbl9[name], descendant)
					elseif descendant:IsA("Animation") then
						tbl9[k] = tbl9[k] or {}
						table.insert(tbl9[k], descendant)
					end
				end
			end
		end
	end

	return tbl9
end

local function getDescriptionEmotes(humanoidDescription)
	local tbl9 = {}
	local ok, result = pcall(humanoidDescription.GetEmotes, humanoidDescription)
	if not (ok and type(result) == "table") then
		return tbl9
	end
	local r6ToR15JointMappings = {}
	local ok2, result2 = pcall(humanoidDescription.GetEquippedEmotes, humanoidDescription)

	if ok2 and type(result2) == "table" then
		for _, currentEmoteTrack in ipairs(result2) do
			r6ToR15JointMappings[currentEmoteTrack.Name] = currentEmoteTrack.Slot
		end
	end

	for k, currentEmoteTrack in pairs(result) do
		local num = type(currentEmoteTrack) == "table" and tonumber(currentEmoteTrack[1]) or tonumber(currentEmoteTrack)

		if num then
			table.insert(tbl9, { nombre = k, id = num, slot = r6ToR15JointMappings[k] or 99 })
		end
	end

	table.sort(tbl9, function(arg2, arg3)
		if arg2.slot ~= arg3.slot then
			return arg2.slot < arg3.slot
		end
		return arg2.nombre < arg3.nombre
	end)

	return tbl9
end

local originalCharacterStateCache = setmetatable({}, { __mode = "k" })

local function captureCharacterState(character)
	if originalCharacterStateCache[character] then
		return originalCharacterStateCache[character]
	end
	local tbl9 = { anim = {} }
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		tbl9.hipHeight = humanoid.HipHeight
	end

	local animate = character:FindFirstChild("Animate")

	if animate then
		for k in pairs(animationScriptNames) do
			local currentEmoteTrack = animate:FindFirstChild(k)

			if currentEmoteTrack then
				tbl9.anim[k] = {}

				for _, child in ipairs(currentEmoteTrack:GetChildren()) do
					if child:IsA("Animation") then
						local clone = child:Clone()
						clone.Parent = nil
						table.insert(tbl9.anim[k], clone)
					end
				end
			end
		end
	end

	originalCharacterStateCache[character] = tbl9
	return tbl9
end

local function noopCharacterStateHook(_character, _snapshot)

    return
end

local function restartCharacterAnimations(character)
	local animate = character:FindFirstChild("Animate")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not (animate and humanoid) then
		return
	end

	for _, currentEmoteTrack in ipairs(humanoid:GetPlayingAnimationTracks()) do
		if currentEmoteTrack.Priority ~= Enum.AnimationPriority.Action then
			pcall(currentEmoteTrack.Stop, currentEmoteTrack, 0)
		end
	end

	animate.Disabled = true
	animate.Disabled = false
end

local function applyAnimationSet(character, animationSet)
	local animate = character:FindFirstChild("Animate")
	if not animate then
		return 0
	end
	local n3 = 0

	for k, currentEmoteTrack in pairs(animationSet) do
		local v3 = animate:FindFirstChild(k)

		if v3 and #currentEmoteTrack > 0 then
			for _, child in ipairs(v3:GetChildren()) do
				if child:IsA("Animation") then
					child:Destroy()
				end
			end

			for _, v4 in ipairs(currentEmoteTrack) do
				v4:Clone().Parent = v3
				n3 += 1
			end
		end
	end

	if n3 > 0 then
		restartCharacterAnimations(character)
	end

	return n3
end

local function restoreAnimationSet(character, savedAnimationSet)
	local animate = character:FindFirstChild("Animate")
	if not (animate and savedAnimationSet and savedAnimationSet.anim) then
		return
	end
	local flag = false

	for k, currentEmoteTrack in pairs(savedAnimationSet.anim) do
		local v3 = animate:FindFirstChild(k)

		if v3 then
			for _, child in ipairs(v3:GetChildren()) do
				if child:IsA("Animation") then
					child:Destroy()
				end
			end

			for _, v4 in ipairs(currentEmoteTrack) do
				v4:Clone().Parent = v3
			end

			flag = true
		end
	end

	if flag then
		restartCharacterAnimations(character)
	end
end

local copiedSkinAnimationData = nil
local function applyCopiedSkinAnimations(character, enabled)
	if not character or not character.Parent then return false end
	local originalData = captureCharacterState(character)
	if enabled then
		if type(copiedSkinAnimationData) ~= "table" then return false end
		return applyAnimationSet(character, copiedSkinAnimationData) > 0
	end
	restoreAnimationSet(character, originalData)
	return true
end

local characterEmoteCache = setmetatable({}, { __mode = "k" })

local function getCharacterHumanoidDescription(character)
	character = character and character:FindFirstChildOfClass("Humanoid")
	return character and character:FindFirstChildOfClass("HumanoidDescription") or nil
end

local function applyEmotes(character, emotes)
	local currentEmoteTrack = getCharacterHumanoidDescription(character)
	if not currentEmoteTrack then
		return 0
	end

	if not characterEmoteCache[character] then
		local ok, result = pcall(currentEmoteTrack.GetEmotes, currentEmoteTrack)
		local ok2, result2 = pcall(currentEmoteTrack.GetEquippedEmotes, currentEmoteTrack)
		local tbl9 = {}
		local v3 = ipairs
		result2 = ok2 and result2 or {}

		for _, v4 in v3(result2) do
			tbl9[#tbl9 + 1] = v4.Name
		end

		characterEmoteCache[character] = { emotes = ok and result or {}, equipados = tbl9 }
	end

	local tbl9 = {}
	local r6ToR15JointMappings = {}

	for _, v3 in ipairs(emotes) do
		tbl9[v3.nombre] = { v3.id }

		if #r6ToR15JointMappings < 8 then
			r6ToR15JointMappings[#r6ToR15JointMappings + 1] = v3.nombre
		end
	end

	return pcall(function()
		currentEmoteTrack:SetEmotes(tbl9)
		currentEmoteTrack:SetEquippedEmotes(r6ToR15JointMappings)
	end) and #r6ToR15JointMappings or 0
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
	local r6ToR15JointMappings = {}

	for _, currentEmoteTrack in ipairs(result3) do
		r6ToR15JointMappings[#r6ToR15JointMappings + 1] = currentEmoteTrack.Name
	end

	localPlayerEmoteData = { emotes = result2, equipados = r6ToR15JointMappings }
	return localPlayerEmoteData
end

local function restoreCharacterEmotes(character)
	local currentEmoteTrack = getCharacterHumanoidDescription(character)
	if not currentEmoteTrack then
		return
	end
	local v3 = getLocalPlayerEmoteData() or characterEmoteCache[character]
	if not v3 then
		return
	end

	pcall(function()
		currentEmoteTrack:SetEmotes(v3.emotes)
		currentEmoteTrack:SetEquippedEmotes(v3.equipados)
	end)
end

local r6ToR15JointMappings = {}

local rootJointMapping = {
	p0 = "HumanoidRootPart",
	p1 = "Torso",
	m0 = "HumanoidRootPart",
	m1 = "UpperTorso",
	r15 = { "Root", "Waist" },
	c0 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0),
	c1 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0),
}

local neckJointMapping = {
	p0 = "Torso",
	p1 = "Head",
	m0 = "UpperTorso",
	m1 = "Head",
	r15 = { "Neck" },
	c0 = CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0),
	c1 = CFrame.new(0, -0.5, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0),
}

local rightShoulderMapping = {
	p0 = "Torso",
	p1 = "Right Arm",
	m0 = "UpperTorso",
	m1 = "RightUpperArm",
	r15 = { "RightShoulder" },
	c0 = CFrame.new(1, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0),
	c1 = CFrame.new(-0.5, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0),
}

local leftShoulderMapping = {
	p0 = "Torso",
	p1 = "Left Arm",
	m0 = "UpperTorso",
	m1 = "LeftUpperArm",
	r15 = { "LeftShoulder" },
	c0 = CFrame.new(-1, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
	c1 = CFrame.new(0.5, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
}

local rightHipMapping = {
	p0 = "Torso",
	p1 = "Right Leg",
	m0 = "UpperTorso",
	m1 = "RightUpperLeg",
	r15 = { "RightHip" },
	c0 = CFrame.new(1, -1, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0),
	c1 = CFrame.new(0.5, 1, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0),
}

local leftHipMapping = {
	p0 = "Torso",
	p1 = "Left Leg",
	m0 = "UpperTorso",
	m1 = "LeftUpperLeg",
	r15 = { "LeftHip" },
	c0 = CFrame.new(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
	c1 = CFrame.new(-0.5, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
}

r6ToR15JointMappings[1] = rootJointMapping
r6ToR15JointMappings[2] = neckJointMapping
r6ToR15JointMappings[3] = rightShoulderMapping
r6ToR15JointMappings[4] = leftShoulderMapping
r6ToR15JointMappings[5] = rightHipMapping
r6ToR15JointMappings[6] = leftHipMapping
local visualModelState = { modelo = nil, char = nil, cadena = {}, folder = nil, conn = nil, connFisica = nil, connCamera = nil, connCameraRemoving = nil, connDescendant = nil, connHideCharacter = nil, connHideCharacterRemoving = nil }

local function indexCharacterJoints(character)
	local tbl18 = {}

	for _, descendant in ipairs(character:GetDescendants()) do

		local insideAccessory = descendant:FindFirstAncestorOfClass("Accessory") ~= nil
		if not insideAccessory
			and (descendant:IsA("Motor6D") or descendant:IsA("AnimationConstraint"))
			and not tbl18[descendant.Name] then
			tbl18[descendant.Name] = descendant
		end
	end

	return tbl18
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
	local cframe = CFrame.identity
	local cframe2 = CFrame.identity

	if #sourceJoints > 0 then
		local currentEmoteTrack = getJointRotations(sourceJoints[1])
		local v3, v4 = getJointRotations(sourceJoints[#sourceJoints])
		cframe = sourceOffset.Rotation:Inverse() * currentEmoteTrack
		local rotation = targetOffset.Rotation
		cframe2 = v4:Inverse() * rotation
	end

	return { desde = sourcePart, hacia = targetPart, c0 = sourceOffset, c1 = targetOffset, srcs = sourceJoints, a = cframe, b = cframe2 }
end

local function buildJointMappings(character, targetModel, visualRootPart, targetRig)
	local currentEmoteTrack = indexCharacterJoints(character)
	local tbl18 = {}
	local tbl19 = {}

	for _, child in ipairs(targetModel:GetChildren()) do
		if child:IsA("BasePart") then
			table.insert(tbl19, child)
		end
	end

	if targetRig == "R6" then
		for _, v3 in ipairs(r6ToR15JointMappings) do
			local v4 = targetModel:FindFirstChild(v3.p0)
			local v5 = targetModel:FindFirstChild(v3.p1)

			if v4 and v5 then
				local tbl20 = {}

				for _, v6 in ipairs(v3.r15) do
					if currentEmoteTrack[v6] then
						table.insert(tbl20, currentEmoteTrack[v6])
					end
				end

				local v6 = createJointMapping(v4, v5, v3.c0, v3.c1, tbl20)
				local v7 = character:FindFirstChild(v3.m0)
				local v8 = character:FindFirstChild(v3.m1)
				v6.m0 = v7
				v6.m1 = v8
				table.insert(tbl18, v6)
			end
		end
	else
		local tbl20 = { [visualRootPart] = true }
		local tbl21 = { visualRootPart }

		while #tbl21 > 0 do
			local v3 = table.remove(tbl21, 1)

			for _, child in ipairs(v3:GetChildren()) do
				if child:IsA("Attachment") and child.Name:match("RigAttachment$") then
					for _, v4 in ipairs(tbl19) do
						if not tbl20[v4] then
							local v5 = v4:FindFirstChild(child.Name)

							if v5 and v5:IsA("Attachment") then
								tbl20[v4] = true
								local v6 = currentEmoteTrack[child.Name:gsub("RigAttachment$", "")]
								table.insert(tbl18, createJointMapping(v3, v4, child.CFrame, v5.CFrame, v6 and { v6 } or {}))
								table.insert(tbl21, v4)
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
						for _, bodyPart in ipairs(tbl19) do
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
				table.insert(tbl18, createJointMapping(
					matchedBodyPart,
					handle,
					matchedBodyAttachment.CFrame,
					matchedHandleAttachment.CFrame,
					{}
				))

				for _, accessoryPart in ipairs(child:GetDescendants()) do
					if accessoryPart:IsA("BasePart") and accessoryPart ~= handle then
						local relativeCFrame = handle.CFrame:ToObjectSpace(accessoryPart.CFrame)
						table.insert(tbl18, {
							desde = handle,
							hacia = accessoryPart,
							c0 = relativeCFrame,
							c1 = CFrame.identity,
							srcs = {},
							a = CFrame.identity,
							b = CFrame.identity,
						})
					end
				end
			end
		end
	end

	return tbl18
end

local function getSkinVisualFolder()
	local currentCamera = workspace.CurrentCamera
	if not currentCamera then
		return nil
	end
	local visualFolder = currentCamera:FindFirstChild("SnowX_SkinsVisuals")

	if not visualFolder then
		local folder = Instance.new("Folder")
		folder.Name = "SnowX_SkinsVisuals"
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
        local originalTransparency = descendant:GetAttribute("SnowXOriginalTransparency")
        if originalTransparency ~= nil then
            descendant.Transparency = originalTransparency
            descendant:SetAttribute("SnowXOriginalTransparency", nil)
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
        if descendant:GetAttribute("SnowXOriginalTransparency") == nil then
            descendant:SetAttribute("SnowXOriginalTransparency", descendant.Transparency)
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
        elseif descendant:GetAttribute("SnowXOriginalTransparency") ~= nil then
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
            if visualModelState.connHideCharacter then
                visualModelState.connHideCharacter:Disconnect()
                visualModelState.connHideCharacter = nil
            end
            if visualModelState.connHideCharacterRemoving then
                visualModelState.connHideCharacterRemoving:Disconnect()
                visualModelState.connHideCharacterRemoving = nil
            end
            visualModelState.connHideCharacter = character.DescendantAdded:Connect(trackHiddenCharacterInstance)
            visualModelState.connHideCharacterRemoving = character.DescendantRemoving:Connect(function()
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
    if visualModelState.connHideCharacter then
        visualModelState.connHideCharacter:Disconnect()
        visualModelState.connHideCharacter = nil
    end
    if visualModelState.connHideCharacterRemoving then
        visualModelState.connHideCharacterRemoving:Disconnect()
        visualModelState.connHideCharacterRemoving = nil
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
	if visualModelState.conn then
		visualModelState.conn:Disconnect()
		visualModelState.conn = nil
	end

	if visualModelState.connFisica then
		visualModelState.connFisica:Disconnect()
		visualModelState.connFisica = nil
	end

	if visualModelState.connCamera then
		visualModelState.connCamera:Disconnect()
		visualModelState.connCamera = nil
	end

	if visualModelState.connCameraRemoving then
		visualModelState.connCameraRemoving:Disconnect()
		visualModelState.connCameraRemoving = nil
	end

	if visualModelState.connDescendant then
		visualModelState.connDescendant:Disconnect()
		visualModelState.connDescendant = nil
	end

	if visualModelState.connHideCharacter then
		visualModelState.connHideCharacter:Disconnect()
		visualModelState.connHideCharacter = nil
	end

	if visualModelState.connHideCharacterRemoving then
		visualModelState.connHideCharacterRemoving:Disconnect()
		visualModelState.connHideCharacterRemoving = nil
	end

	if visualModelState.modelo then
		visualModelState.modelo:Destroy()
		visualModelState.modelo = nil
	end
	if visualModelState.folder and visualModelState.folder.Parent and #visualModelState.folder:GetChildren() == 0 then
		pcall(function() visualModelState.folder:Destroy() end)
	end
	visualModelState.folder = nil

	visualModelState.cadena = {}

	if visualModelState.char then
		setOriginalCharacterHidden(visualModelState.char, false)
		visualModelState.char = nil
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

	for _, currentEmoteTrack in ipairs(jointMappings) do
		if currentEmoteTrack.m0 and currentEmoteTrack.m1 then
			local rotation = currentEmoteTrack.m1.CFrame.Rotation
			local n3 = currentEmoteTrack.m0.CFrame.Rotation:Inverse() * rotation
			local c1 = currentEmoteTrack.c1
			currentEmoteTrack.hacia.CFrame = currentEmoteTrack.desde.CFrame * currentEmoteTrack.c0 * currentEmoteTrack.c0.Rotation:Inverse() * n3 * currentEmoteTrack.c1.Rotation * c1:Inverse()
		else
			local a = currentEmoteTrack.a

			for _, src in ipairs(currentEmoteTrack.srcs) do
				a *= src.Transform
			end

			currentEmoteTrack.hacia.CFrame = currentEmoteTrack.desde.CFrame * currentEmoteTrack.c0 * a * currentEmoteTrack.b * currentEmoteTrack.c1:Inverse()
		end
	end
end

local function buildR15SkinVisual(character, visualModel)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoidRootPart2 = visualModel:FindFirstChild("HumanoidRootPart")
	local currentEmoteTrack = getSkinVisualFolder()
	if not (humanoidRootPart and humanoidRootPart2 and currentEmoteTrack) then
		visualModel:Destroy()
		return false
	end
	local humanoid = visualModel:FindFirstChildOfClass("Humanoid")
	character:FindFirstChildOfClass("Humanoid")
	local cframe = CFrame.new(0, (humanoid and humanoid.HipHeight > 0 and humanoid.HipHeight + humanoidRootPart2.Size.Y / 2 or getModelFootOffset(visualModel, humanoidRootPart2)) - getModelFootOffset(character, humanoidRootPart), 0)
	local tbl18 = {}

	local function configureVisualPart(part)
		local insideAccessory = part:FindFirstAncestorOfClass("Accessory") ~= nil
		local insideTool = part:FindFirstAncestorOfClass("Tool") ~= nil
		part.Anchored = not insideAccessory and not insideTool and part == humanoidRootPart2
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Massless = true
		table.insert(tbl18, part)
	end

	for _, descendant in ipairs(visualModel:GetDescendants()) do
		if descendant:IsA("BaseScript") then
			descendant.Disabled = true
		elseif descendant:IsA("BasePart") then
			configureVisualPart(descendant)
		end
	end

	if humanoid then
		humanoid.PlatformStand = true
		humanoid.AutoRotate = false
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

		pcall(function()
			humanoid.EvaluateStateMachine = false
		end)

		local animator = humanoid:FindFirstChildOfClass("Animator")

		if animator then
			animator:Destroy()
		end
	end

	visualModel.Name = "SnowX_SkinsVisuals_R15"
	visualModel.PrimaryPart = humanoidRootPart2
	visualModel:PivotTo(humanoidRootPart.CFrame * cframe)
	visualModel.Parent = currentEmoteTrack

	local v3 = indexCharacterJoints(character)
	local cadena = {}

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

			local v4 = v3[joint.Name]

			if v4 then
				table.insert(cadena, { src = v4, tgt = joint })
			end
		end
	end

	for _, descendant in ipairs(visualModel:GetDescendants()) do
		configureVisualJoint(descendant)
	end

	if visualModelState.connDescendant then visualModelState.connDescendant:Disconnect() end
	visualModelState.connDescendant = visualModel.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("BasePart") then
			configureVisualPart(descendant)
		else
			configureVisualJoint(descendant)
		end
	end)

	local v4 = visualModelState
	local v5 = visualModelState
	visualModelState.visualModel = visualModel
	v4.character = character
	v5.cadena = cadena
	setOriginalCharacterHidden(character, true)

	local updateCameraTransparency, cameraDescendantConnection, cameraDescendantRemovingConnection =
		createNativeCameraTransparencyUpdater(character, visualModel)
	visualModelState.connCamera = cameraDescendantConnection
	visualModelState.connCameraRemoving = cameraDescendantRemovingConnection
	visualModelState.folder = currentEmoteTrack

	local function updateVisualPose()
		humanoidRootPart2.CFrame = humanoidRootPart.CFrame * cframe

		for _, v6 in ipairs(cadena) do
			if v6.src and v6.src.Parent and v6.tgt and v6.tgt.Parent then
				pcall(function() v6.tgt.Transform = v6.src.Transform end)
			end
		end
	end

	visualModelState.connFisica = RunService.Stepped:Connect(function()
		if visualModelState.visualModel ~= visualModel then
			return
		end
		for _, part in ipairs(tbl18) do
			if part.Parent then
				if part.CanCollide then part.CanCollide = false end
				if part.CanTouch then part.CanTouch = false end
			end
		end
		updateVisualPose()
	end)

	local n3 = 0

	visualModelState.conn = RunService.RenderStepped:Connect(function(deltaTime)
		if visualModelState.visualModel ~= visualModel then
			return
		end
        local currentCamera = workspace.CurrentCamera
        if not currentEmoteTrack or currentEmoteTrack.Parent ~= currentCamera then
            local previousFolder = currentEmoteTrack
            currentEmoteTrack = getSkinVisualFolder()
            if previousFolder and previousFolder ~= currentEmoteTrack and previousFolder.Parent
                and #previousFolder:GetChildren() == 0 then
                pcall(function() previousFolder:Destroy() end)
            end
            visualModelState.folder = currentEmoteTrack
        end
        if not currentCamera then return end
        if currentEmoteTrack and visualModel.Parent ~= currentEmoteTrack then visualModel.Parent = currentEmoteTrack end
        updateVisualPose()
        updateCameraTransparency()
		n3 += deltaTime

		if n3 >= 0.5 then
			n3 %= 0.5
			enforceHiddenCharacter()
		end
	end)

	return true
end

local function buildSkinVisual(character, visualModel)
	destroySkinVisuals()
	local humanoid = visualModel:FindFirstChildOfClass("Humanoid")
	humanoid = humanoid and humanoid.RigType == Enum.HumanoidRigType.R6 and "R6" or "R15"
	if humanoid ~= "R6" then
		return buildR15SkinVisual(character, visualModel)
	end
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoidRootPart2 = visualModel:FindFirstChild("HumanoidRootPart")
	local currentEmoteTrack = getSkinVisualFolder()
	if not (humanoidRootPart and humanoidRootPart2 and currentEmoteTrack) then
		visualModel:Destroy()
		return false
	end
	local humanoid2 = visualModel:FindFirstChildOfClass("Humanoid")
	character:FindFirstChildOfClass("Humanoid")
	local flag = humanoid == "R6" and getModelFootOffset(visualModel, humanoidRootPart2)
	local n3

	if flag then
		n3 = flag
	else
		n3 = (humanoid2 and humanoid2.HipHeight or 2) + humanoidRootPart2.Size.Y / 2
	end

	local cframe = CFrame.new(0, n3 - getModelFootOffset(character, humanoidRootPart), 0)
	local tbl18 = {}

	for _, descendant in ipairs(visualModel:GetDescendants()) do
		if descendant:IsA("BaseScript") then
			descendant.Disabled = true
		elseif descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
			descendant.Massless = true
			table.insert(tbl18, descendant)
		elseif (descendant:IsA("JointInstance") or descendant:IsA("Constraint"))
			and not descendant:FindFirstAncestorOfClass("Accessory")
			and not descendant:FindFirstAncestorOfClass("Tool") then
			descendant:Destroy()
		end
	end

	if humanoid2 then
		humanoid2.PlatformStand = true
		humanoid2.AutoRotate = false
		humanoid2.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

		pcall(function()
			humanoid2.EvaluateStateMachine = false
		end)

		local animator = humanoid2:FindFirstChildOfClass("Animator")

		if animator then
			animator:Destroy()
		end
	end

	visualModel.Name = "SnowX_SkinsVisuals_" .. humanoid
	visualModel.PrimaryPart = humanoidRootPart2
	local v3 = buildJointMappings(character, visualModel, humanoidRootPart2, humanoid)
	updateJointMappings(humanoidRootPart, humanoidRootPart2, v3, cframe)
	visualModel.Parent = currentEmoteTrack

	for _, descendant in ipairs(visualModel:GetDescendants()) do
		if (descendant:IsA("Constraint") or descendant:IsA("JointInstance"))
			and not descendant:FindFirstAncestorOfClass("Accessory")
			and not descendant:FindFirstAncestorOfClass("Tool") then
			descendant:Destroy()
		end
	end

	if visualModelState.connDescendant then visualModelState.connDescendant:Disconnect() end
	visualModelState.connDescendant = visualModel.DescendantAdded:Connect(function(descendant)
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
			table.insert(tbl18, descendant)
		end
	end)

	local v4 = visualModelState
	local v5 = visualModelState
	visualModelState.visualModel = visualModel
	v4.character = character
	v5.cadena = v3
	setOriginalCharacterHidden(character, true)
	local updateCameraTransparency, cameraDescendantConnection, cameraDescendantRemovingConnection =
		createNativeCameraTransparencyUpdater(character, visualModel)
	visualModelState.connCamera = cameraDescendantConnection
	visualModelState.connCameraRemoving = cameraDescendantRemovingConnection
	visualModelState.folder = currentEmoteTrack

	visualModelState.connFisica = RunService.Stepped:Connect(function()
		if visualModelState.visualModel ~= visualModel then return end
		for _, part in ipairs(tbl18) do
			if part.Parent then
				if part.CanCollide then part.CanCollide = false end
				if part.CanTouch then part.CanTouch = false end
			end
		end
	end)

	local n4 = 0

	visualModelState.conn = RunService.RenderStepped:Connect(function(deltaTime)
		if visualModelState.visualModel ~= visualModel then
			return
		end
        local currentCamera = workspace.CurrentCamera
        if not currentEmoteTrack or currentEmoteTrack.Parent ~= currentCamera then
            local previousFolder = currentEmoteTrack
            currentEmoteTrack = getSkinVisualFolder()
            if previousFolder and previousFolder ~= currentEmoteTrack and previousFolder.Parent
                and #previousFolder:GetChildren() == 0 then
                pcall(function() previousFolder:Destroy() end)
            end
            visualModelState.folder = currentEmoteTrack
        end
        if not currentCamera then return end
        if currentEmoteTrack and visualModel.Parent ~= currentEmoteTrack then visualModel.Parent = currentEmoteTrack end
        updateJointMappings(humanoidRootPart, humanoidRootPart2, v3, cframe)
        updateCameraTransparency()
		n4 += deltaTime

		if n4 >= 0.5 then
			n4 %= 0.5
			enforceHiddenCharacter()
		end
	end)

	return true
end

local function attachSkinVisual(character, visualModel, _unused, rigName)
	if not character then
		return 0
	end
	local currentEmoteTrack = captureCharacterState(character)
	noopCharacterStateHook(character, currentEmoteTrack)
	local v3 = visualModel and buildSkinVisual(character, visualModel, rigName)
	if visualModel and not v3 then
		return nil
	end
	local n3 = 0

	if v3 then
		n3 = 0 + #visualModelState.cadena + 1
	end

	return n3
end

local function restoreCharacterAppearance(character)
	if not character then
		return
	end
	destroySkinVisuals()
	local currentEmoteTrack = originalCharacterStateCache[character]
	if not currentEmoteTrack then
		return
	end
	noopCharacterStateHook(character, currentEmoteTrack)
	restoreAnimationSet(character, currentEmoteTrack)
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
	local v3 = loadAssetObjects(assetId)
	local v4 = ipairs
	local tbl20 = v3 or {}

	for _, v5 in v4(tbl20) do
		if v5:IsA("Animation") then
			return v5
		end

		for _, descendant in ipairs(v5:GetDescendants()) do
			if descendant:IsA("Animation") then
				return descendant
			end
		end
	end

	return nil
end

local function playEmote(emote)
	stopCurrentEmote()
	local v3 = getLocalCharacter()
	local humanoid = v3 and v3:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		return false
	end
	local v4 = getCharacterHumanoidDescription(v3)

	if v4 then
		local ok, result = pcall(v4.GetEmotes, v4)

		if ok and result[emote.nombre] then
			local ok2, result2 = pcall(humanoid.PlayEmote, humanoid, emote.nombre)
			if ok2 and result2 then
				return true
			end
		end
	end

	local v5 = findAnimationInAsset(emote.id)
	if not v5 then
		return false
	end
	local ok, result = pcall(animator.LoadAnimation, animator, v5)
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
		local flag = humanoid.MoveDirection.Magnitude > 0

		if not flag then
			local jumping = Enum.HumanoidStateType.Jumping
			flag = humanoid:GetState() == jumping
		end

		if not flag then
			local freefall = Enum.HumanoidStateType.Freefall
			flag = humanoid:GetState() == freefall
		end

		if flag then
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

removeOldGui(guiParent, "snowx-skins")
local playerGui = localPlayer:FindFirstChild("PlayerGui")
removeOldGui(playerGui, "snowx-skins")

loadConfiguration()
task.spawn(getLocalPlayerEmoteData)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "snowx-skins"
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
    local url = "https://raw.githubusercontent.com/Styx-ui/w/refs/heads/main/Slow2.jpg"
    local path = "avatar-visual/Slow2.jpg"
    pcall(function()
        if type(isfolder) == "function" and type(makefolder) == "function" and not isfolder("avatar-visual") then
            makefolder("avatar-visual")
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
	BackgroundColor3 = theme.Background,
	BorderSizePixel = 0,
	Active = true,
	ClipsDescendants = true,
}, screenGui, 16)

createGuiInstance("UIStroke", { Color = theme.Border, Thickness = 1, Transparency = 0.2 }, mainFrame)
local uiGradient = Instance.new("UIGradient")
uiGradient.Color = ColorSequence.new(theme.BackgroundAlt, theme.Background)
uiGradient.Rotation = 90
uiGradient.Parent = mainFrame

local backgroundImage = Instance.new("ImageLabel")
backgroundImage.Name = "ReferenceBackground"
backgroundImage.Size = UDim2.fromScale(1, 1)
backgroundImage.BackgroundTransparency = 1
backgroundImage.Image = bgAsset or ""
backgroundImage.ImageTransparency = bgAsset and 0.38 or 1
backgroundImage.ScaleType = Enum.ScaleType.Crop
backgroundImage.ZIndex = 1
backgroundImage.Parent = mainFrame
createGuiInstance("UICorner", { CornerRadius = UDim.new(0, 16) }, backgroundImage)
createGuiInstance("Frame", {
    Name = "ReferenceBackgroundOverlay",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = bgAsset and 0.58 or 1,
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

local function clampFrameCenter(position)
	local camera = Workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
	local halfSize = Vector2.new(mainFrame.AbsoluteSize.X * 0.5 + 2, mainFrame.AbsoluteSize.Y * 0.5 + 2)
	local maxX, maxY = viewport.X - halfSize.X, viewport.Y - halfSize.Y
	if maxX < halfSize.X or maxY < halfSize.Y then
		return Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
	end
	return Vector2.new(
		math.clamp(position.X, halfSize.X, maxX),
		math.clamp(position.Y, halfSize.Y, maxY)
	)
end

local function keepFrameInsideViewport()
	if not mainFrame.Parent then return end
	local absolute = mainFrame.AbsolutePosition
	local center = Vector2.new(
		absolute.X + mainFrame.AbsoluteSize.X * 0.5,
		absolute.Y + mainFrame.AbsoluteSize.Y * 0.5
	)
	local target = clampFrameCenter(center)
	mainFrame.Position = UDim2.fromOffset(target.X, target.Y)
end

local function updateUiScale()
	local currentCamera = workspace.CurrentCamera
	currentCamera = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)
	local n3 = 0.92
	local n4 = 0.94

	if flag then
		n3 = 0.78
		n4 = 0.9
	end

	uiScale.Scale = math.clamp(math.min(currentCamera.X * n4 / PANEL_WIDTH, currentCamera.Y * n3 / PANEL_HEIGHT), 0.01, 1)
	task.defer(keepFrameInsideViewport)
end

updateUiScale()
local windowHeader = createGuiInstance("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 52) }, mainFrame)

local titleLabel = createGuiInstance("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(18, 15),
	Size = UDim2.fromOffset(166, 22),
	Font = Enum.Font.GothamBold,
	Text = "SnowX",
	TextSize = 16,
	TextColor3 = theme.Text,
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
	Size = UDim2.fromOffset(150, 12),
	Font = Enum.Font.Gotham,
	Text = "By Fabnx1",
	TextSize = 9,
	TextColor3 = theme.Faint,
	TextXAlignment = Enum.TextXAlignment.Left,
}, mainFrame)

local minimizeButton = createGuiInstance("TextButton", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -44, 0, 13),
	Size = UDim2.fromOffset(26, 26),
	BackgroundColor3 = theme.Surface,
	BorderSizePixel = 0,
	AutoButtonColor = true,
	Font = Enum.Font.GothamBold,
	Text = "−",
	TextSize = 21,
	TextColor3 = theme.Icon,
}, mainFrame, 8)

local closeButton = createGuiInstance("TextButton", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -14, 0, 13),
	Size = UDim2.fromOffset(26, 26),
	BackgroundColor3 = theme.Surface,
	BorderSizePixel = 0,
	AutoButtonColor = true,
	Font = Enum.Font.GothamBold,
	Text = "×",
	TextSize = 16,
	TextColor3 = theme.Icon,
}, mainFrame, 8)

createGuiInstance("Frame", {
	Position = UDim2.fromOffset(0, 52),
	Size = UDim2.new(1, 0, 0, 1),
	BackgroundColor3 = theme.Line,
	BorderSizePixel = 0,
}, mainFrame)

createGuiInstance("Frame", {
	Position = UDim2.fromOffset(176, 52),
	Size = UDim2.new(0, 1, 1, -52),
	BackgroundColor3 = theme.Line,
	BorderSizePixel = 0,
}, mainFrame)

createGuiInstance("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(14, 60),
	Size = UDim2.fromOffset(152, 26),
	Font = Enum.Font.GothamBold,
	Text = "Jugadores",
	TextSize = 12,
	TextColor3 = theme.Faint,
	TextXAlignment = Enum.TextXAlignment.Left,
}, mainFrame)

local playerListContainer = createGuiInstance("ScrollingFrame", {
	Position = UDim2.fromOffset(8, 92),
	Size = UDim2.new(0, 164, 1, -100),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 3,
	ScrollBarImageColor3 = theme.Soft,
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, mainFrame)

createGuiInstance("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, playerListContainer)
createGuiInstance("UIPadding", { PaddingTop = UDim.new(0, 1), PaddingBottom = UDim.new(0, 4) }, playerListContainer)
local n3 = PANEL_WIDTH - 176 - 28 - 4

local playerSearchFrame = createGuiInstance("Frame", {
	Position = UDim2.fromOffset(194, 64),
	Size = UDim2.fromOffset(n3 - 44, 36),
	BackgroundColor3 = theme.Surface,
	BorderSizePixel = 0,
}, mainFrame, 8)

local playerSearchBox = createGuiInstance("TextBox", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(10, 0),
	Size = UDim2.new(1, -20, 1, 0),
	Font = Enum.Font.Gotham,
	PlaceholderText = "Usuario o ID",
	PlaceholderColor3 = theme.Faint,
	Text = "",
	TextSize = 13,
	TextColor3 = theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
	ClearTextOnFocus = false,
}, playerSearchFrame)

local searchButton = createGuiInstance("TextButton", {
	Position = UDim2.fromOffset(194 + n3 - 38, 64),
	Size = UDim2.fromOffset(38, 36),
	BackgroundColor3 = theme.Surface,
	BorderSizePixel = 0,
	AutoButtonColor = true,
	Font = Enum.Font.GothamBold,
	Text = "→",
	TextSize = 22,
	TextColor3 = theme.Faint,
}, mainFrame, 8)
local n4 = n3 - 166

local avatarPreviewCard = createGuiInstance("Frame", {
	Position = UDim2.fromOffset(194, 108),
	Size = UDim2.fromOffset(150, 150),
	BackgroundColor3 = theme.Surface,
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
	BackgroundColor3 = theme.Background,
	BackgroundTransparency = 0.25,
	BorderSizePixel = 0,
	AutoButtonColor = true,
	Font = Enum.Font.GothamBold,
	Text = "☆",
	TextSize = 19,
	TextColor3 = theme.Faint,
	ZIndex = 3,
}, avatarPreviewCard, 14)

local selectedPlayerNameLabel = createGuiInstance("TextLabel", {
	Position = UDim2.fromOffset(360, 110),
	Size = UDim2.fromOffset(n4, 22),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "Selecciona un jugador",
	TextSize = 15,
	TextColor3 = theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd,
}, mainFrame)

local selectedPlayerUsernameLabel = createGuiInstance("TextLabel", {
	Position = UDim2.fromOffset(360, 132),
	Size = UDim2.fromOffset(n4, 16),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	Text = "",
	TextSize = 10,
	TextColor3 = theme.Faint,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd,
}, mainFrame)

local skinStatusLabel = createGuiInstance("TextLabel", {
	Position = UDim2.fromOffset(360, 145),
	Size = UDim2.fromOffset(n4, 12),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	Text = "",
	TextSize = 9,
	TextColor3 = theme.Faint,
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
		skinStatusLabel.TextColor3 = status == "Fallo" and theme.Danger or theme.OnFill
	else
		skinStatusLabel.Text = ""
		skinStatusLabel.TextColor3 = theme.Faint
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

	local v5 = nil

	if iconName then
		createGuiInstance("UIPadding", { PaddingLeft = UDim.new(0, 18) }, createdButton)
		v5 = createImageLabel(createdButton, iconName, 14, textColor, UDim2.new(0, 2, 0.5, 0))
	end

	return createdButton, v5
end

local aplicar = createSkinActionButton(360, 158, 112, 30, "APLICAR", nil, theme.AccentFill, theme.On)
local quitar = createSkinActionButton(480, 158, n4 - 120, 30, "QUITAR", nil, theme.Surface, theme.Icon)
local animationToggleButton, animationToggleIcon = createSkinActionButton(360, 196, n4, 28, "Animaciones: On", nil, theme.Surface, theme.Faint)
v5.TextSize = 11
local r15 = createSkinActionButton(360, 232, 112, 26, "R15", nil, theme.Surface, theme.Faint)
local r6 = createSkinActionButton(480, 232, n4 - 120, 26, "R6", nil, theme.Surface, theme.Faint)

local function notifyAccessoryInventory()
    bumpSkinRevision()
	if type(avatarBridge.accessory.refreshInventory) == "function" then
		pcall(avatarBridge.accessory.refreshInventory)
	end
end

local function updateSkinControls()
	skinState.feMode = "ON"
	for k, v7 in pairs({ [r15] = skinState.rig == "R15", [r6] = skinState.rig == "R6" }) do
		k.BackgroundColor3 = v7 and theme.OnFill or theme.Surface
		v7 = v7 and theme.On or theme.Faint
		k.TextColor3 = v7
	end

	local skinEquipped = avatarBridge.skin.active == true and tonumber(skinState.aplicado) ~= nil
	local useRobloxAnimations = skinState.rig == "R6"
	local animationsEnabled = skinState.animationsEnabled == true
	animationToggleButton.Text = useRobloxAnimations and "Animaciones: Roblox"
		or (animationsEnabled and "Animaciones: On" or "Animaciones: Off")
	local animationControlEnabled = skinEquipped and not useRobloxAnimations
	animationToggleButton.BackgroundColor3 = not animationControlEnabled and theme.BackgroundAlt
		or (animationsEnabled and theme.AccentFill or theme.Surface)
	animationToggleButton.TextColor3 = animationControlEnabled and (animationsEnabled and theme.Accent or theme.Faint) or theme.Faint
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
	BackgroundColor3 = theme.BackgroundAlt,
	BackgroundTransparency = 0.05,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	Visible = false,
	ZIndex = 50,
}, screenGui, 12)

createGuiInstance("UIStroke", { Color = theme.Text, Thickness = 1.5, Transparency = 0.45 }, floatingButtonFrame)
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
    BackgroundColor3 = theme.Text,
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
    TextColor3 = theme.Text,
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

local function clampFloatingPosition(position)
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
    local halfSize = Vector2.new(
        floatingButtonFrame.AbsoluteSize.X * 0.5 + 1,
        floatingButtonFrame.AbsoluteSize.Y * 0.5 + 1
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

local function getFloatingCenter()
    local absolute = floatingButtonFrame.AbsolutePosition
    return Vector2.new(
        absolute.X + floatingButtonFrame.AbsoluteSize.X * 0.5,
        absolute.Y + floatingButtonFrame.AbsoluteSize.Y * 0.5
    )
end

local function setFloatingCenter(position)
    local target = clampFloatingPosition(position)
    floatingButtonFrame.Position = UDim2.fromOffset(target.X, target.Y)
end

local function setWindowMinimized(visible)
    isWindowMinimized = visible
    if visible and not floatingPositionInitialized then
        local absolutePosition = mainFrame.AbsolutePosition
        setFloatingCenter(Vector2.new(absolutePosition.X + 26, absolutePosition.Y + 26))
        floatingPositionInitialized = true
    end
    mainFrame.Visible = not visible
    floatingButtonFrame.Visible = visible
    task.defer(keepFrameInsideViewport)
    if visible and floatingPositionInitialized then
        task.defer(function() setFloatingCenter(getFloatingCenter()) end)
    end
end

minimizeButton.Activated:Connect(function()
	setWindowMinimized(true)
end)

local floatingButtonDragState = nil

openClick.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        floatingButtonDragState = {
            input = input,
            desde = Vector2.new(input.Position.X, input.Position.Y),
            origen = getFloatingCenter(),
            movio = false,
        }
    end
end)

local connection3 = UserInputService.InputChanged:Connect(function(input)
    local drag = floatingButtonDragState
    if not drag then return end
    local isMouseMove = drag.input.UserInputType == Enum.UserInputType.MouseButton1
        and input.UserInputType == Enum.UserInputType.MouseMovement
    if not isMouseMove and input ~= drag.input then return end
    local pointer = Vector2.new(input.Position.X, input.Position.Y)
    local delta = pointer - drag.desde
    if delta.Magnitude > 6 then drag.movio = true end
    if drag.movio then setFloatingCenter(drag.origen + delta) end
end)

local connection4 = UserInputService.InputEnded:Connect(function(input)
    local drag = floatingButtonDragState
    if not drag then return end
    local ended = input == drag.input
        or (drag.input.UserInputType == Enum.UserInputType.MouseButton1
            and input.UserInputType == Enum.UserInputType.MouseButton1)
    if not ended then return end
    floatingButtonDragState = nil
    if not drag.movio then setWindowMinimized(false) end
end)

local closeConfirmationOverlay = createGuiInstance("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = theme.Background,
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
	BackgroundColor3 = theme.Surface,
	BorderSizePixel = 0,
	ZIndex = 21,
}, closeConfirmationOverlay, 12)

createGuiInstance("UIStroke", { Color = theme.Line, Thickness = 1 }, closeConfirmationDialog)

createGuiInstance("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(16, 16),
	Size = UDim2.new(1, -32, 0, 22),
	Font = Enum.Font.GothamBold,
	Text = "¿Cerrar SnowX?",
	TextSize = 15,
	TextColor3 = theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 22,
}, closeConfirmationDialog)

createGuiInstance("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(16, 40),
	Size = UDim2.new(1, -32, 0, 32),
	Font = Enum.Font.Gotham,
	Text = "Se cerrará SnowX.",
	TextSize = 11,
	TextColor3 = theme.Faint,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextWrapped = true,
	ZIndex = 22,
}, closeConfirmationDialog)

local confirmCloseButton = createGuiInstance("TextButton", {
	AnchorPoint = Vector2.new(1, 1),
	Position = UDim2.new(1, -16, 1, -14),
	Size = UDim2.fromOffset(96, 30),
	BackgroundColor3 = theme.DangerFill,
	BorderSizePixel = 0,
	AutoButtonColor = true,
	Font = Enum.Font.GothamBold,
	Text = "Cerrar",
	TextSize = 12,
	TextColor3 = theme.Danger,
	ZIndex = 22,
}, closeConfirmationDialog, 8)

createGuiInstance("TextButton", {
	AnchorPoint = Vector2.new(1, 1),
	Position = UDim2.new(1, -120, 1, -14),
	Size = UDim2.fromOffset(96, 30),
	BackgroundColor3 = theme.SurfaceUp,
	BorderSizePixel = 0,
	AutoButtonColor = true,
	Font = Enum.Font.GothamBold,
	Text = "Cancelar",
	TextSize = 12,
	TextColor3 = theme.Icon,
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
		local v7 = getUserHumanoidDescription(userId)
		if skinState.userId ~= userId or not v7 then
			return
		end
		task.spawn(preloadAnimationAssets, v7)
	end)
end

local findFavoriteIndex = nil

local function updateFavoriteButton()
	local isFavorite = skinState.userId and findFavoriteIndex(skinState.userId) ~= nil or false
	favoriteButton.Visible = skinState.userId ~= nil
	favoriteButton.Text = isFavorite and "★" or "☆"
	favoriteButton.TextColor3 = isFavorite and Color3.fromRGB(250, 204, 21) or theme.Faint
	favoriteButton.BackgroundColor3 = isFavorite and Color3.fromRGB(49, 42, 25) or theme.Background
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
	local v7, v8 = getUserNames(userId)
	if not v8 then
		return false
	end
	local flag3 = false

	for _, favorito in ipairs(skinState.favoritos) do
		if favorito.userId == userId and (favorito.nombre ~= v7 or favorito.usuario ~= v8) then
			favorito.nombre = v7
			favorito.usuario = v8
			flag3 = true
		end
	end

	if skinState.userId == userId and (skinState.nombre ~= v7 or skinState.usuario ~= v8) then
		local v9 = skinState
		skinState.nombre = v7
		v9.usuario = v8
		flag3 = true
	end

	return flag3
end

local function selectPlayer(targetUserId)
	local userId = tonumber(targetUserId)
	local v7 = userInfoCache[userId]
	skinState.userId = userId
	skinState.nombre = v7 and v7.nombre or nil
	skinState.usuario = v7 and v7.usuario or nil

	for _, favorito in ipairs(skinState.favoritos) do
		if favorito.userId == userId and not v7 then
			local v8 = skinState
			local usuario = favorito.usuario
			skinState.nombre = favorito.nombre
			v8.usuario = usuario
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
		local v8 = getUserRigType(userId)

		if v8 and skinState.userId == userId and skinState.rig ~= v8 then
			skinState.rig = v8
			saveConfiguration()
			updateSkinControls()
		end
	end)
end

local function createPlayerListItem(displayName, username, layoutOrder, onActivated, isSelected)
	local playerListItemButton = createGuiInstance("TextButton", {
		Size = UDim2.new(1, -6, 0, 34),
		BackgroundColor3 = isSelected and theme.OnFill or theme.Surface,
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
		TextColor3 = isSelected and theme.On or theme.Text,
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
			TextColor3 = isSelected and theme.Text or theme.Faint,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, playerListItemButton)
	end

	if onActivated then
		playerListItemButton.Activated:Connect(onActivated)
	end

	return playerListItemButton
end

findFavoriteIndex = function(arg)
	for i, favorito in ipairs(skinState.favoritos) do
		if favorito.userId == arg then
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
			TextColor3 = theme.Faint,
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
			TextColor3 = theme.Faint,
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
	local v7, v8 = createSkinModel(userId, rig)
	if not v7 or not v8 then
		if v8 then pcall(function() v8:Destroy() end) end
		return nil
	end

	if (requestGeneration and requestGeneration ~= applicationGeneration) or getLocalCharacter() ~= character then
		if v8 then v8:Destroy() end
		return nil
	end

    local sourceHumanoid = character:FindFirstChildOfClass("Humanoid")
    if not waitForCharacterRig(character, sourceHumanoid, rig, 2.5) then
        pcall(function() v8:Destroy() end)
        return nil
    end
    if (requestGeneration and requestGeneration ~= applicationGeneration) or getLocalCharacter() ~= character then
        pcall(function() v8:Destroy() end)
        return nil
    end

	captureCharacterState(character)
	stopCurrentEmote()
	restoreCharacterAppearance(character)
	restoreCharacterEmotes(character)

	local animationData
	if rig == "R15" then
		animationData = extractAnimationSets(v7)
	end

	applyEmotes(character, getDescriptionEmotes(v7))
    local result = attachSkinVisual(character, v8, nil, rig)
    if requestGeneration and requestGeneration ~= applicationGeneration then
        restoreCharacterAppearance(character)
        return nil
    end
    if not result then
        if v8 and v8.Parent then
            pcall(function() v8:Destroy() end)
        end
        return nil
    end
	copiedSkinAnimationData = animationData
	if rig == "R15" and skinState.animationsEnabled then
		applyCopiedSkinAnimations(character, true)
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
    local v7 = getLocalCharacter()

    if v7 then
        restoreCharacterAppearance(v7)
        restoreCharacterEmotes(v7)
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

aplicar.Activated:Connect(applySkin)
quitar.Activated:Connect(removeSkin)

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

r15.Activated:Connect(function()
	setRigType("R15")
end)

r6.Activated:Connect(function()
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
	local v7 = findFavoriteIndex(skinState.userId)

	if v7 then
		table.remove(skinState.favoritos, v7)
	else
		table.insert(skinState.favoritos, { userId = skinState.userId, nombre = skinState.nombre or tostring(skinState.userId), usuario = skinState.usuario })
	end

	saveConfiguration()
	updateFavoriteButton()
	refreshPlayerList()
end)

local function searchPlayer()
	local str2 = playerSearchBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
	if str2 == "" then
		return
	end
	local num = tonumber(str2)
	if num then
		selectPlayer(num)
		return
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if player.Name:lower() == str2:lower() or player.DisplayName:lower() == str2:lower() then
			selectPlayer(player.UserId)
			return
		end
	end

	task.spawn(function()
		local ok, result = pcall(Players.GetUserIdFromNameAsync, Players, str2)

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

local panelDrag = nil

windowHeader.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        local absolute = mainFrame.AbsolutePosition
        panelDrag = {
            input = input,
            start = Vector2.new(input.Position.X, input.Position.Y),
            origin = Vector2.new(
                absolute.X + mainFrame.AbsoluteSize.X * 0.5,
                absolute.Y + mainFrame.AbsoluteSize.Y * 0.5
            ),
        }
    end
end)

table.insert(lifecycleConnections, UserInputService.InputChanged:Connect(function(input)
    local drag = panelDrag
    if not drag then return end
    local isMouseMove = drag.input.UserInputType == Enum.UserInputType.MouseButton1
        and input.UserInputType == Enum.UserInputType.MouseMovement
    if not isMouseMove and input ~= drag.input then return end
    local pointer = Vector2.new(input.Position.X, input.Position.Y)
    local target = clampFrameCenter(drag.origin + pointer - drag.start)
    mainFrame.Position = UDim2.fromOffset(target.X, target.Y)
end))

table.insert(lifecycleConnections, UserInputService.InputEnded:Connect(function(input)
    local drag = panelDrag
    if not drag then return end
    local ended = input == drag.input
        or (drag.input.UserInputType == Enum.UserInputType.MouseButton1
            and input.UserInputType == Enum.UserInputType.MouseButton1)
    if ended then panelDrag = nil end
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
	if currentCamera and visualModelState.modelo then
		local visualFolder = getSkinVisualFolder()
		if visualFolder then
			local previousFolder = visualModelState.folder
			visualModelState.modelo.Parent = visualFolder
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
    disconnectCharacterLifecycleConnections()
	connection3:Disconnect()
	connection4:Disconnect()
    removeSkin()
    if avatarBridge.skin.owner == skinBridgeToken then
        avatarBridge.skin.owner = nil
        avatarBridge.skin.getBaseDescription = nil
        avatarBridge.skin.refresh = nil
    end

    for _, v9 in ipairs(lifecycleConnections) do
		pcall(function()
			v9:Disconnect()
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
            setWindowMinimized(true)
        else
            screenGui.Enabled = false
        end
        return true
    end,
	open = function()
		screenGui.Enabled = true
		mainFrame.Visible = true
		floatingButtonFrame.Visible = false
		return screenGui.Parent ~= nil
	end,
	aplicar = applySkin,
	quitar = removeSkin,
	elegir = selectPlayer,
	emote = playEmote,
	pararEmote = stopCurrentEmote,
	destroy = function()
		disconnectCharacterLifecycleConnections()
		pcall(function() connection3:Disconnect() end)
        pcall(function() connection4:Disconnect() end)
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
	local flag5 = false

	for _, favorito in ipairs(skinState.favoritos) do
		flag5 = updateCachedUserInfo(favorito.userId) or flag5
	end

	if skinState.userId then
		flag5 = updateCachedUserInfo(skinState.userId) or flag5
	end

	if flag5 then
		saveConfiguration()
		updateSelectedPlayerCard()
		refreshPlayerList()
	end
end)

return skinApi