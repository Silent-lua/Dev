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

local tbl = {
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

local n = 590
local n2 = 274

local tbl2 = {
	idle = "IdleAnimation",
	walk = "WalkAnimation",
	run = "RunAnimation",
	jump = "JumpAnimation",
	fall = "FallAnimation",
	climb = "ClimbAnimation",
	swim = "SwimAnimation",
}

local tbl3 = {
	userId = nil,
	nombre = nil,
	usuario = nil,
	aplicado = nil,
	favoritos = {},
	rig = "R15",
	feMode = "ON",
	animationsEnabled = true,
}

local function fn()
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
				table.insert(tbl3.favoritos, {
					userId = tonumber(favorito.userId),
					nombre = tostring(favorito.nombre or favorito.userId),
					usuario = type(favorito.usuario) == "string" and favorito.usuario or nil,
				})
			end
		end
	end

	if tonumber(result2.userId) then
		tbl3.userId = tonumber(result2.userId)
		tbl3.nombre = tostring(result2.nombre or result2.userId)
		tbl3.usuario = type(result2.usuario) == "string" and result2.usuario or nil
	end

	if result2.rig == "R6" or result2.rig == "R15" then
		tbl3.rig = result2.rig
	end

	tbl3.feMode = "ON"
	if type(result2.animationsEnabled) == "boolean" then
		tbl3.animationsEnabled = result2.animationsEnabled
	end
end

local function fn2()
	if typeof(writefile) ~= "function" then
		return
	end

	pcall(function()
		if typeof(isfolder) == "function" and typeof(makefolder) == "function" and not isfolder("snowx") then
			makefolder("snowx")
		end
	end)

	pcall(writefile, CONFIG_PATH, HttpService:JSONEncode({
		userId = tbl3.userId,
		nombre = tbl3.nombre,
		usuario = tbl3.usuario,
		favoritos = tbl3.favoritos,
		rig = tbl3.rig,
		feMode = "ON",
		animationsEnabled = tbl3.animationsEnabled == true,
	}))
end

local function fn3(arg, arg2, parent, arg3)
	local instance = Instance.new(arg)

	for k, v in pairs(arg2) do
		instance[k] = v
	end

	if instance:IsA("TextButton") and arg2.Text and arg2.Text ~= "" then
		instance.TextStrokeColor3 = Color3.new(0, 0, 0)
		instance.TextStrokeTransparency = 0.75
	end

	if arg3 then
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0, arg3)
		uiCorner.Parent = instance
	end

	instance.Parent = parent
	return instance
end

local v = nil
local tbl4 = {}

local function fn4(arg, arg2)
	if not v then
		table.insert(tbl4, { arg, arg2 })
		return
	end
	local ok, result = pcall(v.GetAsset, arg2)

	if ok and result then
		arg.Image = result.Url
		arg.ImageRectOffset = result.ImageRectOffset
		arg.ImageRectSize = result.ImageRectSize
	end
end

task.spawn(function()
	local ok, result = pcall(function()
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/lucide-roblox-direct/refs/heads/main/source.lua"))()
	end)

	if ok and type(result) == "table" and result.GetAsset then
		v = result

		for _, v2 in ipairs(tbl4) do
			fn4(v2[1], v2[2])
		end

		table.clear(tbl4)
	end
end)

local function createImageLabel(parent, arg, arg2, imageColor3, position)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.BackgroundTransparency = 1
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.Position = position or UDim2.fromScale(0.5, 0.5)
	imageLabel.Size = UDim2.fromOffset(arg2, arg2)
	imageLabel.ImageColor3 = imageColor3
	imageLabel.Image = ""
	imageLabel.Active = false
	imageLabel.Parent = parent
	fn4(imageLabel, arg)
	return imageLabel
end

local function fn5()
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

local function fn6(arg, arg2, arg3)
    local rigType = arg3 == "R6" and Enum.HumanoidRigType.R6 or Enum.HumanoidRigType.R15
    if not arg2 or not arg2:IsA("HumanoidDescription") then
        return nil
    end

    local ok, result = pcall(function()
        return Players:CreateHumanoidModelFromDescriptionAsync(arg2, rigType)
    end)
    if not (ok and result) then
        ok, result = pcall(Players.CreateHumanoidModelFromDescription, Players, arg2, rigType)
    end

    if not (ok and result) then
        return nil
    end
    result.Parent = nil
    return result
end

local tbl5 = {}
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

local function fn7(arg)
	if tbl5[arg] then
		return tbl5[arg].nombre, tbl5[arg].usuario
	end
	local playerByUserId = Players:GetPlayerByUserId(arg)
	local displayName, name

	if playerByUserId then
		displayName = playerByUserId.DisplayName
		name = playerByUserId.Name
	else
		local ok, result = pcall(UserService.GetUserInfosByUserIdsAsync, UserService, { arg })
		ok = ok and type(result) == "table" and result[1]
		displayName = nil
		name = nil

		if ok then
			displayName = result[1].DisplayName
			name = result[1].Username
		end

		if not name then
			local ok2, result2 = pcall(Players.GetNameFromUserIdAsync, Players, arg)

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
		tbl5[arg] = { nombre = displayName or name, usuario = name }
	end

	return displayName, name
end

local tbl6 = {}

local function fn8(arg)
	if tbl6[arg] then
		return tbl6[arg]
	end
	local ok, result = pcall(Players.GetCharacterAppearanceInfoAsync, Players, arg)
	ok = ok and type(result) == "table" and result.playerAvatarType
	if ok == "R6" or ok == "R15" then
		tbl6[arg] = ok
		return ok
	end
	return nil
end

local tbl7 = {}

local function fn9(arg)
	if tbl7[arg] then
		return tbl7[arg]
	end
	local playerByUserId = Players:GetPlayerByUserId(arg)
	local humanoid = playerByUserId and playerByUserId.Character and playerByUserId.Character:FindFirstChildOfClass("Humanoid")
	local v2 = nil

	if humanoid then
		local ok, result = pcall(humanoid.GetAppliedDescription, humanoid)
		ok = ok and result
		v2 = nil

		if ok then
			v2 = result
		end
	end

	if not v2 then
		local ok, result = pcall(function()
			return Players:GetHumanoidDescriptionFromUserIdAsync(arg)
		end)

		if not (ok and result) then
			ok, result = pcall(Players.GetHumanoidDescriptionFromUserId, Players, arg)
		end

		if ok and result then
			v2 = result
		end
	end

	if v2 then
		tbl7[arg] = v2
	end

	return v2
end

local tbl8 = {}

local function fn10(arg)
	local str2 = tostring(arg)
	if tbl8[str2] ~= nil then
		return tbl8[str2] or nil
	end
	local ok, result = pcall(game.GetObjects, game, "rbxassetid://" .. str2)
	if not (ok and type(result) == "table") then
		tbl8[str2] = false
		return nil
	end

	for _, v2 in ipairs(result) do
		v2.Parent = nil
	end

	tbl8[str2] = result
	return result
end

local function fn11(arg)
	local n3 = 0

	for _, v2 in pairs(tbl2) do
		local v3 = arg[v2]

		if type(v3) == "number" and v3 > 0 and tbl8[tostring(v3)] == nil then
			n3 += 1

			task.spawn(function()
				fn10(v3)
				n3 -= 1
			end)
		end
	end

	local now = os.clock()

	while n3 > 0 and os.clock() - now < 15 do
		task.wait(0.05)
	end
end

local function fn12(arg)
	local tbl9 = {}
	fn11(arg)

	for k, v2 in pairs(tbl2) do
		local v3 = arg[v2]

		if type(v3) == "number" and v3 > 0 then
			local v4 = fn10(v3)
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

local function fn13(arg)
	local tbl9 = {}
	local ok, result = pcall(arg.GetEmotes, arg)
	if not (ok and type(result) == "table") then
		return tbl9
	end
	local tbl10 = {}
	local ok2, result2 = pcall(arg.GetEquippedEmotes, arg)

	if ok2 and type(result2) == "table" then
		for _, v2 in ipairs(result2) do
			tbl10[v2.Name] = v2.Slot
		end
	end

	for k, v2 in pairs(result) do
		local num = type(v2) == "table" and tonumber(v2[1]) or tonumber(v2)

		if num then
			table.insert(tbl9, { nombre = k, id = num, slot = tbl10[k] or 99 })
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

local obj = setmetatable({}, { __mode = "k" })

local function fn14(arg)
	if obj[arg] then
		return obj[arg]
	end
	local tbl9 = { anim = {} }
	local humanoid = arg:FindFirstChildOfClass("Humanoid")

	if humanoid then
		tbl9.hipHeight = humanoid.HipHeight
	end

	local animate = arg:FindFirstChild("Animate")

	if animate then
		for k in pairs(tbl2) do
			local v2 = animate:FindFirstChild(k)

			if v2 then
				tbl9.anim[k] = {}

				for _, child in ipairs(v2:GetChildren()) do
					if child:IsA("Animation") then
						local clone = child:Clone()
						clone.Parent = nil
						table.insert(tbl9.anim[k], clone)
					end
				end
			end
		end
	end

	obj[arg] = tbl9
	return tbl9
end

local function fn15(arg, arg2)

    return
end

local function fn16(arg)
	local animate = arg:FindFirstChild("Animate")
	local humanoid = arg:FindFirstChildOfClass("Humanoid")
	if not (animate and humanoid) then
		return
	end

	for _, v2 in ipairs(humanoid:GetPlayingAnimationTracks()) do
		if v2.Priority ~= Enum.AnimationPriority.Action then
			pcall(v2.Stop, v2, 0)
		end
	end

	animate.Disabled = true
	animate.Disabled = false
end

local function fn17(arg, arg2)
	local animate = arg:FindFirstChild("Animate")
	if not animate then
		return 0
	end
	local n3 = 0

	for k, v2 in pairs(arg2) do
		local v3 = animate:FindFirstChild(k)

		if v3 and #v2 > 0 then
			for _, child in ipairs(v3:GetChildren()) do
				if child:IsA("Animation") then
					child:Destroy()
				end
			end

			for _, v4 in ipairs(v2) do
				v4:Clone().Parent = v3
				n3 += 1
			end
		end
	end

	if n3 > 0 then
		fn16(arg)
	end

	return n3
end

local function fn18(arg, arg2)
	local animate = arg:FindFirstChild("Animate")
	if not (animate and arg2 and arg2.anim) then
		return
	end
	local flag = false

	for k, v2 in pairs(arg2.anim) do
		local v3 = animate:FindFirstChild(k)

		if v3 then
			for _, child in ipairs(v3:GetChildren()) do
				if child:IsA("Animation") then
					child:Destroy()
				end
			end

			for _, v4 in ipairs(v2) do
				v4:Clone().Parent = v3
			end

			flag = true
		end
	end

	if flag then
		fn16(arg)
	end
end

local copiedSkinAnimationData = nil
local function applyCopiedSkinAnimations(character, enabled)
	if not character or not character.Parent then return false end
	local originalData = fn14(character)
	if enabled then
		if type(copiedSkinAnimationData) ~= "table" then return false end
		return fn17(character, copiedSkinAnimationData) > 0
	end
	fn18(character, originalData)
	return true
end

local obj2 = setmetatable({}, { __mode = "k" })

local function fn19(arg)
	arg = arg and arg:FindFirstChildOfClass("Humanoid")
	return arg and arg:FindFirstChildOfClass("HumanoidDescription") or nil
end

local function fn20(arg, arg2)
	local v2 = fn19(arg)
	if not v2 then
		return 0
	end

	if not obj2[arg] then
		local ok, result = pcall(v2.GetEmotes, v2)
		local ok2, result2 = pcall(v2.GetEquippedEmotes, v2)
		local tbl9 = {}
		local v3 = ipairs
		result2 = ok2 and result2 or {}

		for _, v4 in v3(result2) do
			tbl9[#tbl9 + 1] = v4.Name
		end

		obj2[arg] = { emotes = ok and result or {}, equipados = tbl9 }
	end

	local tbl9 = {}
	local tbl10 = {}

	for _, v3 in ipairs(arg2) do
		tbl9[v3.nombre] = { v3.id }

		if #tbl10 < 8 then
			tbl10[#tbl10 + 1] = v3.nombre
		end
	end

	return pcall(function()
		v2:SetEmotes(tbl9)
		v2:SetEquippedEmotes(tbl10)
	end) and #tbl10 or 0
end

local tbl9 = nil

local function fn21()
	if tbl9 then
		return tbl9
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
	local tbl10 = {}

	for _, v2 in ipairs(result3) do
		tbl10[#tbl10 + 1] = v2.Name
	end

	tbl9 = { emotes = result2, equipados = tbl10 }
	return tbl9
end

local function fn22(arg)
	local v2 = fn19(arg)
	if not v2 then
		return
	end
	local v3 = fn21() or obj2[arg]
	if not v3 then
		return
	end

	pcall(function()
		v2:SetEmotes(v3.emotes)
		v2:SetEquippedEmotes(v3.equipados)
	end)
end

local tbl10 = {}

local tbl11 = {
	p0 = "HumanoidRootPart",
	p1 = "Torso",
	m0 = "HumanoidRootPart",
	m1 = "UpperTorso",
	r15 = { "Root", "Waist" },
	c0 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0),
	c1 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0),
}

local tbl12 = {
	p0 = "Torso",
	p1 = "Head",
	m0 = "UpperTorso",
	m1 = "Head",
	r15 = { "Neck" },
	c0 = CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0),
	c1 = CFrame.new(0, -0.5, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0),
}

local tbl13 = {
	p0 = "Torso",
	p1 = "Right Arm",
	m0 = "UpperTorso",
	m1 = "RightUpperArm",
	r15 = { "RightShoulder" },
	c0 = CFrame.new(1, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0),
	c1 = CFrame.new(-0.5, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0),
}

local tbl14 = {
	p0 = "Torso",
	p1 = "Left Arm",
	m0 = "UpperTorso",
	m1 = "LeftUpperArm",
	r15 = { "LeftShoulder" },
	c0 = CFrame.new(-1, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
	c1 = CFrame.new(0.5, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
}

local tbl15 = {
	p0 = "Torso",
	p1 = "Right Leg",
	m0 = "UpperTorso",
	m1 = "RightUpperLeg",
	r15 = { "RightHip" },
	c0 = CFrame.new(1, -1, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0),
	c1 = CFrame.new(0.5, 1, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0),
}

local tbl16 = {
	p0 = "Torso",
	p1 = "Left Leg",
	m0 = "UpperTorso",
	m1 = "LeftUpperLeg",
	r15 = { "LeftHip" },
	c0 = CFrame.new(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
	c1 = CFrame.new(-0.5, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
}

tbl10[1] = tbl11
tbl10[2] = tbl12
tbl10[3] = tbl13
tbl10[4] = tbl14
tbl10[5] = tbl15
tbl10[6] = tbl16
local tbl17 = { modelo = nil, char = nil, cadena = {}, conn = nil, connFisica = nil, connCamera = nil, connDescendant = nil, connHideCharacter = nil }

local function fn23(arg)
	local tbl18 = {}

	for _, descendant in ipairs(arg:GetDescendants()) do

		local insideAccessory = descendant:FindFirstAncestorOfClass("Accessory") ~= nil
		if not insideAccessory
			and (descendant:IsA("Motor6D") or descendant:IsA("AnimationConstraint"))
			and not tbl18[descendant.Name] then
			tbl18[descendant.Name] = descendant
		end
	end

	return tbl18
end

local function fn24(arg)
	if arg:IsA("Motor6D") then
		return arg.C0.Rotation, arg.C1.Rotation
	end
	local attachment0 = arg.Attachment0
	local attachment1 = arg.Attachment1
	return attachment0 and attachment0.CFrame.Rotation or CFrame.identity, attachment1 and attachment1.CFrame.Rotation or CFrame.identity
end

local function fn25(arg, arg2, arg3, arg4, arg5)
	local cframe = CFrame.identity
	local cframe2 = CFrame.identity

	if #arg5 > 0 then
		local v2 = fn24(arg5[1])
		local v3, v4 = fn24(arg5[#arg5])
		cframe = arg3.Rotation:Inverse() * v2
		local rotation = arg4.Rotation
		cframe2 = v4:Inverse() * rotation
	end

	return { desde = arg, hacia = arg2, c0 = arg3, c1 = arg4, srcs = arg5, a = cframe, b = cframe2 }
end

local function fn26(arg, arg2, arg3, arg4)
	local v2 = fn23(arg)
	local tbl18 = {}
	local tbl19 = {}

	for _, child in ipairs(arg2:GetChildren()) do
		if child:IsA("BasePart") then
			table.insert(tbl19, child)
		end
	end

	if arg4 == "R6" then
		for _, v3 in ipairs(tbl10) do
			local v4 = arg2:FindFirstChild(v3.p0)
			local v5 = arg2:FindFirstChild(v3.p1)

			if v4 and v5 then
				local tbl20 = {}

				for _, v6 in ipairs(v3.r15) do
					if v2[v6] then
						table.insert(tbl20, v2[v6])
					end
				end

				local v6 = fn25(v4, v5, v3.c0, v3.c1, tbl20)
				local v7 = arg:FindFirstChild(v3.m0)
				local v8 = arg:FindFirstChild(v3.m1)
				v6.m0 = v7
				v6.m1 = v8
				table.insert(tbl18, v6)
			end
		end
	else
		local tbl20 = { [arg3] = true }
		local tbl21 = { arg3 }

		while #tbl21 > 0 do
			local v3 = table.remove(tbl21, 1)

			for _, child in ipairs(v3:GetChildren()) do
				if child:IsA("Attachment") and child.Name:match("RigAttachment$") then
					for _, v4 in ipairs(tbl19) do
						if not tbl20[v4] then
							local v5 = v4:FindFirstChild(child.Name)

							if v5 and v5:IsA("Attachment") then
								tbl20[v4] = true
								local v6 = v2[child.Name:gsub("RigAttachment$", "")]
								table.insert(tbl18, fn25(v3, v4, child.CFrame, v5.CFrame, v6 and { v6 } or {}))
								table.insert(tbl21, v4)
							end
						end
					end
				end
			end
		end
	end

	for _, child in ipairs(arg2:GetChildren()) do
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
				table.insert(tbl18, fn25(
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

local function fn27()
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
    if instance:FindFirstAncestorOfClass("Tool") then
        return false
    end


    local ok, enabled = pcall(function() return instance.Enabled end)
    if not ok or enabled then
        return false
    end
    return pcall(function() instance.Enabled = true end)
end

local hiddenCharacterModel = nil
local hiddenCharacterInstances = {}
local hiddenCharacterTracked = setmetatable({}, { __mode = "k" })

local function trackHiddenCharacterInstance(descendant)
    if not descendant or hiddenCharacterTracked[descendant]
        or descendant:FindFirstAncestorOfClass("Tool") then
        return
    end

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
        if descendant.Transparency < 1 then
            descendant.Transparency = 1
        end
    else
        if hiddenCharacterEffectStates[descendant] == nil then
            hiddenCharacterEffectStates[descendant] = { enabled = descendant.Enabled }
        end
        if descendant.Enabled then
            descendant.Enabled = false
        end
        if descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") then
            pcall(function() descendant:Clear() end)
        end
    end
end

local function enforceHiddenCharacter()
    for _, descendant in ipairs(hiddenCharacterInstances) do
        if descendant.Parent then
            if descendant:GetAttribute("SnowXOriginalTransparency") ~= nil
                and descendant.Transparency < 1 then
                descendant.Transparency = 1
            end
            local saved = hiddenCharacterEffectStates[descendant]
            if saved and descendant.Enabled then
                descendant.Enabled = false
            end
        end
    end
end

local function fn28(arg, arg2)
    if arg2 then
        if hiddenCharacterModel ~= arg then
            if hiddenCharacterModel then
                fn28(hiddenCharacterModel, false)
            end
            hiddenCharacterModel = arg
            table.clear(hiddenCharacterInstances)
            hiddenCharacterTracked = setmetatable({}, { __mode = "k" })
            for _, descendant in ipairs(arg:GetDescendants()) do
                trackHiddenCharacterInstance(descendant)
            end
            if tbl17.connHideCharacter then
                tbl17.connHideCharacter:Disconnect()
            end
            tbl17.connHideCharacter = arg.DescendantAdded:Connect(trackHiddenCharacterInstance)
        end
        enforceHiddenCharacter()
        return
    end

    if hiddenCharacterModel ~= arg then return end
    if tbl17.connHideCharacter then
        tbl17.connHideCharacter:Disconnect()
        tbl17.connHideCharacter = nil
    end

    for _, descendant in ipairs(hiddenCharacterInstances) do
        if descendant.Parent then
            pcall(function()
                local original = descendant:GetAttribute("SnowXOriginalTransparency")
                if original ~= nil then
                    descendant.Transparency = original
                    descendant:SetAttribute("SnowXOriginalTransparency", nil)
                end
                local saved = hiddenCharacterEffectStates[descendant]
                if saved then
                    descendant.Enabled = saved.enabled
                    hiddenCharacterEffectStates[descendant] = nil
                end
            end)
        end
        hiddenCharacterTracked[descendant] = nil
    end

    table.clear(hiddenCharacterInstances)
    hiddenCharacterModel = nil
end

local function createNativeCameraTransparencyUpdater(char, modelo)

	local visualEntries = {}
	local trackedInstances = setmetatable({}, { __mode = "k" })
	local lastTransparency = nil
	local lastUpdate = os.clock()
	local MAX_TWEEN_RATE = 2.8

	local function isInsideTool(instance)
		local ancestor = instance.Parent
		while ancestor and ancestor ~= modelo do
			if ancestor:IsA("Tool") then
				return true
			end
			ancestor = ancestor.Parent
		end
		return false
	end

	local function trackVisual(instance)
		if trackedInstances[instance] or isInsideTool(instance) then
			return
		end
        enableCopiedAppearanceEffect(modelo, instance)

		local entry = { instance = instance }
		if instance:IsA("BasePart") or instance:IsA("Decal") then
			local ok, originalModifier = pcall(function()
				return instance.LocalTransparencyModifier
			end)

			if ok then
				entry.kind = "nativeModifier"
				entry.originalLocalTransparencyModifier = originalModifier
			else

				entry.kind = "decalTransparency"
				entry.originalTransparency = instance.Transparency
			end
		elseif instance:IsA("ParticleEmitter") or instance:IsA("Trail") or instance:IsA("Beam") then
			entry.kind = "sequenceEffect"
			entry.originalEnabled = instance.Enabled
			entry.originalTransparency = instance.Transparency
		elseif instance:IsA("Fire") or instance:IsA("Smoke") or instance:IsA("Sparkles")
			or instance:IsA("Light")
			or instance:IsA("BillboardGui") or instance:IsA("SurfaceGui") then
			entry.kind = "enabledEffect"
			entry.originalEnabled = instance.Enabled
		else
			return
		end

		trackedInstances[instance] = true
		table.insert(visualEntries, entry)
	end

	local function getNativeTransparency()
		local camera = Workspace.CurrentCamera
		local targetTransparency = 0

		if localPlayer.CameraMode == Enum.CameraMode.LockFirstPerson then
			targetTransparency = 1
		elseif camera then
			local reference = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
			if reference and reference:IsA("BasePart") then
				local distance = (camera.CFrame.Position - reference.Position).Magnitude
				if distance < 1.55 then
					targetTransparency = math.clamp((1.55 - distance) / 1.05, 0, 1)
				end
			end
		end

		targetTransparency = math.clamp(targetTransparency, 0, 1)

		local now = os.clock()
		local deltaTime = math.max(0, now - lastUpdate)
		lastUpdate = now

		if lastTransparency ~= nil and targetTransparency < 1 and lastTransparency < 0.95 then
			local maxDelta = MAX_TWEEN_RATE * deltaTime
			local difference = targetTransparency - lastTransparency
			difference = math.clamp(difference, -maxDelta, maxDelta)
			targetTransparency = lastTransparency + difference
		end

		targetTransparency = math.clamp(math.floor(targetTransparency * 100 + 0.5) / 100, 0, 1)
		lastTransparency = targetTransparency
		return targetTransparency
	end

	local function applyVisual(entry, nativeTransparency)
		local instance = entry.instance
		if not instance.Parent then
			return
		end

		local fullyFirstPerson = nativeTransparency >= 0.995

		if entry.kind == "nativeModifier" then

			local original = entry.originalLocalTransparencyModifier or 0
			local desired = math.max(original, nativeTransparency)
			if entry.lastAppliedModifier ~= desired then
				local ok = pcall(function()
					instance.LocalTransparencyModifier = desired
				end)
				if ok then
					entry.lastAppliedModifier = desired
				end
			end
		elseif entry.kind == "decalTransparency" then
			local original = entry.originalTransparency or 0
			local desired = 1 - ((1 - original) * (1 - nativeTransparency))
			if entry.lastAppliedTransparency ~= desired then
				instance.Transparency = desired
				entry.lastAppliedTransparency = desired
			end
		elseif entry.kind == "sequenceEffect" then

			if entry.appliedHidden ~= fullyFirstPerson then
				if fullyFirstPerson then
					instance.Enabled = false
					instance.Transparency = NumberSequence.new(1)
					if instance:IsA("ParticleEmitter") then
						pcall(function()
							instance:Clear()
						end)
					end
				else
					instance.Transparency = entry.originalTransparency
					instance.Enabled = entry.originalEnabled
				end
				entry.appliedHidden = fullyFirstPerson
			end
		elseif entry.kind == "enabledEffect" then
			if entry.appliedHidden ~= fullyFirstPerson then
				if fullyFirstPerson then
					instance.Enabled = false
				else
					instance.Enabled = entry.originalEnabled
				end
				entry.appliedHidden = fullyFirstPerson
			end
		end
	end

	for _, descendant in ipairs(modelo:GetDescendants()) do
		trackVisual(descendant)
	end

	local function update()
		if not (char.Parent and modelo.Parent) then
			return
		end

		local nativeTransparency = getNativeTransparency()
		for _, entry in ipairs(visualEntries) do
			applyVisual(entry, nativeTransparency)
		end
        return nativeTransparency >= 0.995
	end

	local descendantConnection = modelo.DescendantAdded:Connect(function(descendant)
		trackVisual(descendant)
	end)

	update()
	return update, descendantConnection
end

local function fn29()
	if tbl17.conn then
		tbl17.conn:Disconnect()
		tbl17.conn = nil
	end

	if tbl17.connFisica then
		tbl17.connFisica:Disconnect()
		tbl17.connFisica = nil
	end

	if tbl17.connCamera then
		tbl17.connCamera:Disconnect()
		tbl17.connCamera = nil
	end

	if tbl17.connDescendant then
		tbl17.connDescendant:Disconnect()
		tbl17.connDescendant = nil
	end

	if tbl17.connHideCharacter then
		tbl17.connHideCharacter:Disconnect()
		tbl17.connHideCharacter = nil
	end

	if tbl17.modelo then
		tbl17.modelo:Destroy()
		tbl17.modelo = nil
	end

	tbl17.cadena = {}

	if tbl17.char then
		fn28(tbl17.char, false)
		tbl17.char = nil
	end
end

local function fn30(arg, arg2)
	local y = arg2.Position.Y

	for _, child in ipairs(arg:GetChildren()) do
		if child:IsA("BasePart") and child ~= arg2 then
			y = math.min(y, child.Position.Y - child.Size.Y / 2)
		end
	end

	return arg2.Position.Y - y
end

local function fn31(arg, arg2, arg3, arg4)
	arg2.CFrame = arg.CFrame * arg4

	for _, v2 in ipairs(arg3) do
		if v2.m0 and v2.m1 then
			local rotation = v2.m1.CFrame.Rotation
			local n3 = v2.m0.CFrame.Rotation:Inverse() * rotation
			local c1 = v2.c1
			v2.hacia.CFrame = v2.desde.CFrame * v2.c0 * v2.c0.Rotation:Inverse() * n3 * v2.c1.Rotation * c1:Inverse()
		else
			local a = v2.a

			for _, src in ipairs(v2.srcs) do
				a *= src.Transform
			end

			v2.hacia.CFrame = v2.desde.CFrame * v2.c0 * a * v2.b * v2.c1:Inverse()
		end
	end
end

local function fn32(char, modelo)
	local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")
	local humanoidRootPart2 = modelo:FindFirstChild("HumanoidRootPart")
	local v2 = fn27()
	if not (humanoidRootPart and humanoidRootPart2 and v2) then
		modelo:Destroy()
		return false
	end
	local humanoid = modelo:FindFirstChildOfClass("Humanoid")
	char:FindFirstChildOfClass("Humanoid")
	local cframe = CFrame.new(0, (humanoid and humanoid.HipHeight > 0 and humanoid.HipHeight + humanoidRootPart2.Size.Y / 2 or fn30(modelo, humanoidRootPart2)) - fn30(char, humanoidRootPart), 0)

	local function fn33(arg)
		local insideAccessory = arg:FindFirstAncestorOfClass("Accessory") ~= nil
		local insideTool = arg:FindFirstAncestorOfClass("Tool") ~= nil
		arg.Anchored = not insideAccessory and not insideTool and arg == humanoidRootPart2
		arg.CanCollide = false
		arg.CanTouch = false
		arg.CanQuery = false
		arg.Massless = true
	end

	for _, descendant in ipairs(modelo:GetDescendants()) do
		if descendant:IsA("BaseScript") then
			descendant.Disabled = true
		elseif descendant:IsA("BasePart") then
			fn33(descendant)
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

	modelo.Name = "SnowX_SkinsVisuals_R15"
	modelo.PrimaryPart = humanoidRootPart2
	modelo:PivotTo(humanoidRootPart.CFrame * cframe)
	modelo.Parent = v2

	local v3 = fn23(char)
	local cadena = {}

	local function fn34(arg)

		if arg:FindFirstAncestorOfClass("Accessory") then
			return
		end

		if arg:IsA("BallSocketConstraint") then
			arg.Enabled = false
		elseif arg:IsA("AnimationConstraint") or arg:IsA("Motor6D") then
			pcall(function()
				arg.IsKinematic = true
			end)

			local v4 = v3[arg.Name]

			if v4 then
				table.insert(cadena, { src = v4, tgt = arg })
			end
		end
	end

	for _, descendant in ipairs(modelo:GetDescendants()) do
		fn34(descendant)
	end

	if tbl17.connDescendant then tbl17.connDescendant:Disconnect() end
	tbl17.connDescendant = modelo.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("BasePart") then
			fn33(descendant)
		else
			fn34(descendant)
		end
	end)

	local v4 = tbl17
	local v5 = tbl17
	tbl17.modelo = modelo
	v4.char = char
	v5.cadena = cadena
	fn28(char, true)

	local updateCameraTransparency, cameraDescendantConnection = createNativeCameraTransparencyUpdater(char, modelo)
	tbl17.connCamera = cameraDescendantConnection

	local function fn35()
		humanoidRootPart2.CFrame = humanoidRootPart.CFrame * cframe

		for _, v6 in ipairs(cadena) do
			if v6.src and v6.src.Parent and v6.tgt and v6.tgt.Parent then
				pcall(function() v6.tgt.Transform = v6.src.Transform end)
			end
		end
	end

	local n3 = 0

	tbl17.conn = RunService.RenderStepped:Connect(function(deltaTime)
		if tbl17.modelo ~= modelo then
			return
		end
		local currentVisualFolder = fn27()
		if currentVisualFolder and modelo.Parent ~= currentVisualFolder then
			modelo.Parent = currentVisualFolder
		end
		fn35()
		updateCameraTransparency()
		n3 += deltaTime

		if n3 > 0.5 then
            n3 %= 0.5
            enforceHiddenCharacter()
        end
	end)

	return true
end

local function fn33(char, modelo)
	fn29()
	local humanoid = modelo:FindFirstChildOfClass("Humanoid")
	humanoid = humanoid and humanoid.RigType == Enum.HumanoidRigType.R6 and "R6" or "R15"
	if humanoid ~= "R6" then
		return fn32(char, modelo)
	end
	local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")
	local humanoidRootPart2 = modelo:FindFirstChild("HumanoidRootPart")
	local v2 = fn27()
	if not (humanoidRootPart and humanoidRootPart2 and v2) then
		modelo:Destroy()
		return false
	end
	local humanoid2 = modelo:FindFirstChildOfClass("Humanoid")
	char:FindFirstChildOfClass("Humanoid")
	local flag = humanoid == "R6" and fn30(modelo, humanoidRootPart2)
	local n3

	if flag then
		n3 = flag
	else
		n3 = (humanoid2 and humanoid2.HipHeight or 2) + humanoidRootPart2.Size.Y / 2
	end

	local cframe = CFrame.new(0, n3 - fn30(char, humanoidRootPart), 0)

	for _, descendant in ipairs(modelo:GetDescendants()) do
		if descendant:IsA("BaseScript") then
			descendant.Disabled = true
		elseif descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
			descendant.Massless = true
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

	modelo.Name = "SnowX_SkinsVisuals_" .. humanoid
	modelo.PrimaryPart = humanoidRootPart2
	local v3 = fn26(char, modelo, humanoidRootPart2, humanoid)
	fn31(humanoidRootPart, humanoidRootPart2, v3, cframe)
	modelo.Parent = v2

	for _, descendant in ipairs(modelo:GetDescendants()) do
		if (descendant:IsA("Constraint") or descendant:IsA("JointInstance"))
			and not descendant:FindFirstAncestorOfClass("Accessory")
			and not descendant:FindFirstAncestorOfClass("Tool") then
			descendant:Destroy()
		end
	end

	if tbl17.connDescendant then tbl17.connDescendant:Disconnect() end
	tbl17.connDescendant = modelo.DescendantAdded:Connect(function(descendant)
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
		end
	end)

	local v4 = tbl17
	local v5 = tbl17
	tbl17.modelo = modelo
	v4.char = char
	v5.cadena = v3
	fn28(char, true)
	local updateCameraTransparency, cameraDescendantConnection = createNativeCameraTransparencyUpdater(char, modelo)
	tbl17.connCamera = cameraDescendantConnection

	local n4 = 0

	tbl17.conn = RunService.RenderStepped:Connect(function(deltaTime)
		if tbl17.modelo ~= modelo then
			return
		end
		local currentVisualFolder = fn27()
		if currentVisualFolder and modelo.Parent ~= currentVisualFolder then
			modelo.Parent = currentVisualFolder
		end
		fn31(humanoidRootPart, humanoidRootPart2, v3, cframe)
        updateCameraTransparency()
		n4 += deltaTime

		if n4 > 0.5 then
            n4 %= 0.5
            enforceHiddenCharacter()
        end
	end)

	return true
end

local function fn34(arg, arg2, arg3, arg4)
	if not arg then
		return 0
	end
	local v2 = fn14(arg)
	fn15(arg, v2)
	local v3 = arg2 and fn33(arg, arg2, arg4)
	if arg2 and not v3 then
		return nil
	end
	local n3 = 0

	if v3 then
		n3 = 0 + #tbl17.cadena + 1
	end

	return n3
end

local function fn35(arg)
	if not arg then
		return
	end
	fn29()
	local v2 = obj[arg]
	if not v2 then
		return
	end
	fn15(arg, v2)
	fn18(arg, v2)
end

local v2 = nil
local connection2 = nil

local function fn41()
	if v2 then
		pcall(v2.Stop, v2, 0.2)
		v2 = nil
	end

	if connection2 then
		connection2:Disconnect()
		connection2 = nil
	end
end

local function fn42(arg)
	local v3 = fn10(arg)
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

local function fn43(arg)
	fn41()
	local v3 = fn5()
	local humanoid = v3 and v3:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		return false
	end
	local v4 = fn19(v3)

	if v4 then
		local ok, result = pcall(v4.GetEmotes, v4)

		if ok and result[arg.nombre] then
			local ok2, result2 = pcall(humanoid.PlayEmote, humanoid, arg.nombre)
			if ok2 and result2 then
				return true
			end
		end
	end

	local v5 = fn42(arg.id)
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
	v2 = result

	connection2 = RunService.Heartbeat:Connect(function()
		if not (humanoid.Parent and v2 == result) then
			fn41()
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
			fn41()
		end
	end)

	return true
end

local v3 = nil

if gethui then
	local ok, result = pcall(gethui)
	v3 = ok and result or nil
end

v3 = v3 or CoreGui
local function removeOldGui(root, name)
	if root then
		local existing = root:FindFirstChild(name)
		if existing then
			existing:Destroy()
		end
	end
end

removeOldGui(v3, "snowx-skins")
local playerGui = localPlayer:FindFirstChild("PlayerGui")
removeOldGui(playerGui, "snowx-skins")

fn()
task.spawn(fn21)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "snowx-skins"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 2147483647
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if not pcall(function()
	screenGui.Parent = v3
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
local Frame = fn3("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(590, 274),
	BackgroundColor3 = tbl.Background,
	BorderSizePixel = 0,
	Active = true,
	ClipsDescendants = true,
}, screenGui, 16)

fn3("UIStroke", { Color = tbl.Border, Thickness = 1, Transparency = 0.2 }, Frame)
local uiGradient = Instance.new("UIGradient")
uiGradient.Color = ColorSequence.new(tbl.BackgroundAlt, tbl.Background)
uiGradient.Rotation = 90
uiGradient.Parent = Frame

local backgroundImage = Instance.new("ImageLabel")
backgroundImage.Name = "ReferenceBackground"
backgroundImage.Size = UDim2.fromScale(1, 1)
backgroundImage.BackgroundTransparency = 1
backgroundImage.Image = bgAsset or ""
backgroundImage.ImageTransparency = bgAsset and 0.38 or 1
backgroundImage.ScaleType = Enum.ScaleType.Crop
backgroundImage.ZIndex = 1
backgroundImage.Parent = Frame
fn3("UICorner", { CornerRadius = UDim.new(0, 16) }, backgroundImage)
fn3("Frame", {
    Name = "ReferenceBackgroundOverlay",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = bgAsset and 0.58 or 1,
    BorderSizePixel = 0,
    ZIndex = 1,
}, Frame)

fn3("TextButton", {
	Text = "",
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	AutoButtonColor = false,
	Active = true,
	Selectable = false,
	ZIndex = 0,
}, Frame)

local uiScale = Instance.new("UIScale")
uiScale.Parent = Frame
local flag = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local function fn44()
	local currentCamera = workspace.CurrentCamera
	currentCamera = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)
	local n3 = 0.92
	local n4 = 0.94

	if flag then
		n3 = 0.78
		n4 = 0.9
	end

	uiScale.Scale = math.clamp(math.min(currentCamera.X * n4 / n, currentCamera.Y * n3 / n2), 0.4, 1)
end

fn44()
local Frame2 = fn3("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 52) }, Frame)

local titleLabel = fn3("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(18, 15),
	Size = UDim2.fromOffset(166, 22),
	Font = Enum.Font.GothamBold,
	Text = "SnowX",
	TextSize = 16,
	TextColor3 = tbl.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd,
}, Frame)
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
fn3("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(19, 32),
	Size = UDim2.fromOffset(150, 12),
	Font = Enum.Font.Gotham,
	Text = "By Fabnx1",
	TextSize = 9,
	TextColor3 = tbl.Faint,
	TextXAlignment = Enum.TextXAlignment.Left,
}, Frame)

local TextButton = fn3("TextButton", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -44, 0, 13),
	Size = UDim2.fromOffset(26, 26),
	BackgroundColor3 = tbl.Surface,
	BorderSizePixel = 0,
	AutoButtonColor = true,
	Font = Enum.Font.GothamBold,
	Text = "−",
	TextSize = 21,
	TextColor3 = tbl.Icon,
}, Frame, 8)

local TextButton2 = fn3("TextButton", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -14, 0, 13),
	Size = UDim2.fromOffset(26, 26),
	BackgroundColor3 = tbl.Surface,
	BorderSizePixel = 0,
	AutoButtonColor = true,
	Font = Enum.Font.GothamBold,
	Text = "×",
	TextSize = 16,
	TextColor3 = tbl.Icon,
}, Frame, 8)

fn3("Frame", {
	Position = UDim2.fromOffset(0, 52),
	Size = UDim2.new(1, 0, 0, 1),
	BackgroundColor3 = tbl.Line,
	BorderSizePixel = 0,
}, Frame)

fn3("Frame", {
	Position = UDim2.fromOffset(176, 52),
	Size = UDim2.new(0, 1, 1, -52),
	BackgroundColor3 = tbl.Line,
	BorderSizePixel = 0,
}, Frame)

fn3("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(14, 60),
	Size = UDim2.fromOffset(152, 26),
	Font = Enum.Font.GothamBold,
	Text = "Jugadores",
	TextSize = 12,
	TextColor3 = tbl.Faint,
	TextXAlignment = Enum.TextXAlignment.Left,
}, Frame)

local ScrollingFrame = fn3("ScrollingFrame", {
	Position = UDim2.fromOffset(8, 92),
	Size = UDim2.new(0, 164, 1, -100),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 3,
	ScrollBarImageColor3 = tbl.Soft,
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, Frame)

fn3("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, ScrollingFrame)
fn3("UIPadding", { PaddingTop = UDim.new(0, 1), PaddingBottom = UDim.new(0, 4) }, ScrollingFrame)
local n3 = n - 176 - 28 - 4

local Frame3 = fn3("Frame", {
	Position = UDim2.fromOffset(194, 64),
	Size = UDim2.fromOffset(n3 - 44, 36),
	BackgroundColor3 = tbl.Surface,
	BorderSizePixel = 0,
}, Frame, 8)

local TextBox = fn3("TextBox", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(10, 0),
	Size = UDim2.new(1, -20, 1, 0),
	Font = Enum.Font.Gotham,
	PlaceholderText = "Usuario o ID",
	PlaceholderColor3 = tbl.Faint,
	Text = "",
	TextSize = 13,
	TextColor3 = tbl.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
	ClearTextOnFocus = false,
}, Frame3)

local TextButton3 = fn3("TextButton", {
	Position = UDim2.fromOffset(194 + n3 - 38, 64),
	Size = UDim2.fromOffset(38, 36),
	BackgroundColor3 = tbl.Surface,
	BorderSizePixel = 0,
	AutoButtonColor = true,
	Font = Enum.Font.GothamBold,
	Text = "→",
	TextSize = 22,
	TextColor3 = tbl.Faint,
}, Frame, 8)
local n4 = n3 - 166

local Frame4 = fn3("Frame", {
	Position = UDim2.fromOffset(194, 108),
	Size = UDim2.fromOffset(150, 150),
	BackgroundColor3 = tbl.Surface,
	BorderSizePixel = 0,
}, Frame, 12)

local ImageLabel = fn3("ImageLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(6, 6),
	Size = UDim2.new(1, -12, 1, -12),
	Image = "",
	ScaleType = Enum.ScaleType.Fit,
}, Frame4)

local TextButton4 = fn3("TextButton", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -6, 0, 6),
	Size = UDim2.fromOffset(28, 28),
	BackgroundColor3 = tbl.Background,
	BackgroundTransparency = 0.25,
	BorderSizePixel = 0,
	AutoButtonColor = true,
	Font = Enum.Font.GothamBold,
	Text = "☆",
	TextSize = 19,
	TextColor3 = tbl.Faint,
	ZIndex = 3,
}, Frame4, 14)

local TextLabel2 = fn3("TextLabel", {
	Position = UDim2.fromOffset(360, 110),
	Size = UDim2.fromOffset(n4, 22),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "Selecciona un jugador",
	TextSize = 15,
	TextColor3 = tbl.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd,
}, Frame)

local TextLabel3 = fn3("TextLabel", {
	Position = UDim2.fromOffset(360, 132),
	Size = UDim2.fromOffset(n4, 16),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	Text = "",
	TextSize = 10,
	TextColor3 = tbl.Faint,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd,
}, Frame)

local StatusLabel = fn3("TextLabel", {
	Position = UDim2.fromOffset(360, 145),
	Size = UDim2.fromOffset(n4, 12),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	Text = "",
	TextSize = 9,
	TextColor3 = tbl.Faint,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd,
}, Frame)

local obj3 = setmetatable({}, { __newindex = function(_, key, value)
	if key ~= "Text" then
		return
	end
	local status = tostring(value or "")
	if status == "Aplicado" or status == "Retirado" or status == "Fallo" then
		StatusLabel.Text = status
		StatusLabel.TextColor3 = status == "Fallo" and tbl.Danger or tbl.OnFill
	else
		StatusLabel.Text = ""
		StatusLabel.TextColor3 = tbl.Faint
	end
end })

local function fn45(arg, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
	local TextButton5 = fn3("TextButton", {
		Position = UDim2.fromOffset(arg, arg2),
		Size = UDim2.fromOffset(arg3, arg4),
		BackgroundColor3 = arg7,
		BorderSizePixel = 0,
		AutoButtonColor = true,
		Font = Enum.Font.GothamBold,
		Text = arg5,
		TextSize = 12,
		TextColor3 = arg8,
	}, Frame, 8)

	local v5 = nil

	if arg6 then
		fn3("UIPadding", { PaddingLeft = UDim.new(0, 18) }, TextButton5)
		v5 = createImageLabel(TextButton5, arg6, 14, arg8, UDim2.new(0, 2, 0.5, 0))
	end

	return TextButton5, v5
end

local aplicar = fn45(360, 158, 112, 30, "APLICAR", nil, tbl.AccentFill, tbl.On)
local quitar = fn45(480, 158, n4 - 120, 30, "QUITAR", nil, tbl.Surface, tbl.Icon)
local v5, v6 = fn45(360, 196, n4, 28, "Animaciones: On", nil, tbl.Surface, tbl.Faint)
v5.TextSize = 11
local r15 = fn45(360, 232, 112, 26, "R15", nil, tbl.Surface, tbl.Faint)
local r6 = fn45(480, 232, n4 - 120, 26, "R6", nil, tbl.Surface, tbl.Faint)

local function notifyAccessoryInventory()
    bumpSkinRevision()
	if type(avatarBridge.accessory.refreshInventory) == "function" then
		pcall(avatarBridge.accessory.refreshInventory)
	end
end

local function fn46()
	tbl3.feMode = "ON"
	for k, v7 in pairs({ [r15] = tbl3.rig == "R15", [r6] = tbl3.rig == "R6" }) do
		k.BackgroundColor3 = v7 and tbl.OnFill or tbl.Surface
		v7 = v7 and tbl.On or tbl.Faint
		k.TextColor3 = v7
	end

	local skinEquipped = avatarBridge.skin.active == true and tonumber(tbl3.aplicado) ~= nil
	local animationsEnabled = tbl3.animationsEnabled == true
	v5.Text = animationsEnabled and "Animaciones: On" or "Animaciones: Off"
	v5.BackgroundColor3 = not skinEquipped and tbl.BackgroundAlt or (animationsEnabled and tbl.AccentFill or tbl.Surface)
	v5.TextColor3 = skinEquipped and (animationsEnabled and tbl.Accent or tbl.Faint) or tbl.Faint
	v5.TextTransparency = skinEquipped and 0 or 0.45
	v5.Active = skinEquipped
	v5.Selectable = skinEquipped
	v5.AutoButtonColor = skinEquipped
	if v6 then v6.ImageColor3 = v5.TextColor3 end
end

local flag2 = false

local TextButton5 = fn3("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Size = UDim2.fromOffset(150, 46),
	BackgroundColor3 = tbl.BackgroundAlt,
	BackgroundTransparency = 0.05,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	Visible = false,
	ZIndex = 50,
}, screenGui, 12)

fn3("UIStroke", { Color = tbl.Text, Thickness = 1.5, Transparency = 0.45 }, TextButton5)
local reopenBackground = Instance.new("ImageLabel")
reopenBackground.Size = UDim2.fromScale(1, 1)
reopenBackground.BackgroundTransparency = 1
reopenBackground.Image = bgAsset or ""
reopenBackground.ImageTransparency = bgAsset and 0.5 or 1
reopenBackground.ScaleType = Enum.ScaleType.Crop
reopenBackground.ZIndex = 50
reopenBackground.Parent = TextButton5
fn3("UICorner", { CornerRadius = UDim.new(0, 12) }, reopenBackground)
local reopenOverlay = fn3("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = bgAsset and 0.55 or 0.82,
    BorderSizePixel = 0,
    ZIndex = 51,
}, TextButton5)
fn3("UICorner", { CornerRadius = UDim.new(0, 12) }, reopenOverlay)
local reopenDot = fn3("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(1, -12, 0, 10),
    Size = UDim2.fromOffset(8, 8),
    BackgroundColor3 = tbl.Text,
    BorderSizePixel = 0,
    ZIndex = 53,
}, TextButton5, 4)
fn3("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(14, 0),
    Size = UDim2.new(1, -24, 1, 0),
    Font = Enum.Font.GothamBold,
    Text = "Open Skins",
    TextSize = 13,
    TextColor3 = tbl.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 53,
}, TextButton5)
local openClick = fn3("TextButton", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    AutoButtonColor = false,
    Active = true,
    Selectable = false,
    Text = "",
    ZIndex = 54,
}, TextButton5)
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
    local halfSize = Vector2.new(75, 23)
    local x = math.clamp(position.X, halfSize.X, math.max(halfSize.X, viewport.X - halfSize.X))
    local y = math.clamp(position.Y, halfSize.Y, math.max(halfSize.Y, viewport.Y - halfSize.Y))
    return Vector2.new(x, y)
end

local function fn47(visible)
	flag2 = visible
	if visible and not floatingPositionInitialized then
		local absolutePosition = Frame.AbsolutePosition
        local target = clampFloatingPosition(Vector2.new(absolutePosition.X + 26, absolutePosition.Y + 26))
		TextButton5.Position = UDim2.fromOffset(target.X, target.Y)
        floatingPositionInitialized = true
	end
	Frame.Visible = not visible
	TextButton5.Visible = visible
end

TextButton.Activated:Connect(function()
	fn47(true)
end)

local tbl20 = nil

openClick.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        tbl20 = {
            input = input,
            desde = Vector2.new(input.Position.X, input.Position.Y),
            origen = Vector2.new(TextButton5.Position.X.Offset, TextButton5.Position.Y.Offset),
            movio = false,
        }
	end
end)

local connection3 = UserInputService.InputChanged:Connect(function(input)
	local drag = tbl20
	if not drag then return end
    local isMouseMove = drag.input.UserInputType == Enum.UserInputType.MouseButton1
        and input.UserInputType == Enum.UserInputType.MouseMovement
    if not isMouseMove and input ~= drag.input then return end
    local pointer = Vector2.new(input.Position.X, input.Position.Y)
    local delta = pointer - drag.desde
	if delta.Magnitude > 6 then drag.movio = true end
	if drag.movio then
        local target = clampFloatingPosition(drag.origen + delta)
		TextButton5.Position = UDim2.fromOffset(target.X, target.Y)
	end
end)

local connection4 = UserInputService.InputEnded:Connect(function(input)
    local drag = tbl20
    if not drag then return end
    local ended = input == drag.input
        or (drag.input.UserInputType == Enum.UserInputType.MouseButton1
            and input.UserInputType == Enum.UserInputType.MouseButton1)
    if not ended then return end
    tbl20 = nil
    if not drag.movio then fn47(false) end
end)

local Frame5 = fn3("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = tbl.Background,
	BackgroundTransparency = 0.3,
	BorderSizePixel = 0,
	Visible = false,
	ZIndex = 20,
	Active = true,
}, Frame, 16)

fn3("TextButton", {
	Text = "",
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	AutoButtonColor = false,
	ZIndex = 20,
}, Frame5)

local Frame6 = fn3("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(300, 132),
	BackgroundColor3 = tbl.Surface,
	BorderSizePixel = 0,
	ZIndex = 21,
}, Frame5, 12)

fn3("UIStroke", { Color = tbl.Line, Thickness = 1 }, Frame6)

fn3("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(16, 16),
	Size = UDim2.new(1, -32, 0, 22),
	Font = Enum.Font.GothamBold,
	Text = "¿Cerrar SnowX?",
	TextSize = 15,
	TextColor3 = tbl.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 22,
}, Frame6)

fn3("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(16, 40),
	Size = UDim2.new(1, -32, 0, 32),
	Font = Enum.Font.Gotham,
	Text = "Se cerrará SnowX.",
	TextSize = 11,
	TextColor3 = tbl.Faint,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextWrapped = true,
	ZIndex = 22,
}, Frame6)

local TextButton6 = fn3("TextButton", {
	AnchorPoint = Vector2.new(1, 1),
	Position = UDim2.new(1, -16, 1, -14),
	Size = UDim2.fromOffset(96, 30),
	BackgroundColor3 = tbl.DangerFill,
	BorderSizePixel = 0,
	AutoButtonColor = true,
	Font = Enum.Font.GothamBold,
	Text = "Cerrar",
	TextSize = 12,
	TextColor3 = tbl.Danger,
	ZIndex = 22,
}, Frame6, 8)

fn3("TextButton", {
	AnchorPoint = Vector2.new(1, 1),
	Position = UDim2.new(1, -120, 1, -14),
	Size = UDim2.fromOffset(96, 30),
	BackgroundColor3 = tbl.SurfaceUp,
	BorderSizePixel = 0,
	AutoButtonColor = true,
	Font = Enum.Font.GothamBold,
	Text = "Cancelar",
	TextSize = 12,
	TextColor3 = tbl.Icon,
	ZIndex = 22,
}, Frame6, 8).Activated:Connect(function()
	Frame5.Visible = false
end)

local function fn48()
	if not tbl3.userId then
		return
	end
	local userId = tbl3.userId

	task.spawn(function()
		local v7 = fn9(userId)
		if tbl3.userId ~= userId or not v7 then
			return
		end
		task.spawn(fn11, v7)
	end)
end

local fn49 = nil

local function fn50()
	local isFavorite = tbl3.userId and fn49(tbl3.userId) ~= nil or false
	TextButton4.Visible = tbl3.userId ~= nil
	TextButton4.Text = isFavorite and "★" or "☆"
	TextButton4.TextColor3 = isFavorite and Color3.fromRGB(250, 204, 21) or tbl.Faint
	TextButton4.BackgroundColor3 = isFavorite and Color3.fromRGB(49, 42, 25) or tbl.Background
end

local function fn51()
	fn50()

	if not tbl3.userId then
		TextLabel2.Text = "Selecciona un jugador"
		TextLabel3.Text = "Apariencias de jugadores"
		StatusLabel.Text = ""
		ImageLabel.Image = ""
		return
	end

	TextLabel2.Text = tbl3.nombre or "..."
	TextLabel3.Text = tbl3.usuario and "@" .. tbl3.usuario or ("ID " .. tostring(tbl3.userId))
	StatusLabel.Text = ""
	ImageLabel.Image = ("rbxthumb://type=Avatar&id=%d&w=352&h=352"):format(tbl3.userId)
	fn48()
end

local fn52 = nil

local function fn53(arg)
	local v7, v8 = fn7(arg)
	if not v8 then
		return false
	end
	local flag3 = false

	for _, favorito in ipairs(tbl3.favoritos) do
		if favorito.userId == arg and (favorito.nombre ~= v7 or favorito.usuario ~= v8) then
			favorito.nombre = v7
			favorito.usuario = v8
			flag3 = true
		end
	end

	if tbl3.userId == arg and (tbl3.nombre ~= v7 or tbl3.usuario ~= v8) then
		local v9 = tbl3
		tbl3.nombre = v7
		v9.usuario = v8
		flag3 = true
	end

	return flag3
end

local function fn54(arg)
	local userId = tonumber(arg)
	local v7 = tbl5[userId]
	tbl3.userId = userId
	tbl3.nombre = v7 and v7.nombre or nil
	tbl3.usuario = v7 and v7.usuario or nil

	for _, favorito in ipairs(tbl3.favoritos) do
		if favorito.userId == userId and not v7 then
			local v8 = tbl3
			local usuario = favorito.usuario
			tbl3.nombre = favorito.nombre
			v8.usuario = usuario
		end
	end

	fn51()
	obj3.Text = ""
	fn2()
	fn52()

	task.spawn(function()
		if fn53(userId) and tbl3.userId == userId then
			fn51()
			fn2()
			fn52()
		end
	end)

	task.spawn(function()
		local v8 = fn8(userId)

		if v8 and tbl3.userId == userId and tbl3.rig ~= v8 then
			tbl3.rig = v8
			fn2()
			fn46()
		end
	end)
end

local function fn55(arg, arg2, arg3, arg4, arg5)
	local TextButton7 = fn3("TextButton", {
		Size = UDim2.new(1, -6, 0, 34),
		BackgroundColor3 = arg5 and tbl.OnFill or tbl.Surface,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.Gotham,
		Text = "",
		LayoutOrder = arg3,
	}, ScrollingFrame, 7)

	fn3("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(9, 3),
		Size = UDim2.new(1, -18, 0, 15),
		Font = Enum.Font.Gotham,
		Text = tostring(arg or "Jugador"),
		TextSize = 10,
		TextColor3 = arg5 and tbl.On or tbl.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, TextButton7)

	if arg2 and arg2 ~= "" then
		fn3("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(9, 18),
			Size = UDim2.new(1, -18, 0, 12),
			Font = Enum.Font.Gotham,
			Text = arg2,
			TextSize = 8,
			TextColor3 = arg5 and tbl.Text or tbl.Faint,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, TextButton7)
	end

	if arg4 then
		TextButton7.Activated:Connect(arg4)
	end

	return TextButton7
end

fn49 = function(arg)
	for i, favorito in ipairs(tbl3.favoritos) do
		if favorito.userId == arg then
			return i
		end
	end

	return nil
end

fn52 = function()
	for _, child in ipairs(ScrollingFrame:GetChildren()) do
		if not child:IsA("UIListLayout") then
			child:Destroy()
		end
	end

	local order = 0
	local seen = {}
	local function addSection(title)
		order += 1
		fn3("TextLabel", {
			Size = UDim2.new(1, -6, 0, 21),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Text = string.upper(title),
			TextColor3 = tbl.Faint,
			TextSize = 9,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = order,
		}, ScrollingFrame)
	end

	local function addEmpty(text)
		order += 1
		fn3("TextLabel", {
			Size = UDim2.new(1, -8, 0, 28),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = text,
			TextColor3 = tbl.Faint,
			TextSize = 9,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = order,
		}, ScrollingFrame)
	end

	addSection("Favoritos")
	local favoriteCount = 0
	for _, favorito in ipairs(tbl3.favoritos) do
		local userId = tonumber(favorito.userId)
		if userId and not seen[userId] then
			seen[userId] = true
			favoriteCount += 1
			order += 1
			fn55(favorito.nombre, favorito.usuario and "@" .. favorito.usuario or ("ID " .. tostring(userId)), order, function()
				fn54(userId)
			end, tbl3.userId == userId)
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
			fn55(displayName, "@" .. username, order, function()
				fn54(userId)
			end, tbl3.userId == userId)
		end
	end
	if playerCount == 0 then
		addEmpty("Sin jugadores")
	end
end

local flag3 = false
local pendingApply = false
local applicationGeneration = 0
local queuedSkinUserId = nil
local queuedSkinRig = nil
local refreshAccessoryWhenIdle = false
local characterRebuildPending = false
local characterRebuildGeneration = 0

local function fn56(arg, arg2)
    local rigName = arg2 == "R6" and "R6" or "R15"
    local templateKey = getSkinTemplateKey(arg, rigName)
    local baseDescription = fn9(arg)
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

    fn11(modelDescription)
    local model = fn6(arg, modelDescription, rigName)
    pcall(function() modelDescription:Destroy() end)
    if model then
        storeSkinTemplate(templateKey, model)
    end
    return baseDescription, model
end

local function getRigAnimationSet(model)
	local animate = model and model:FindFirstChild("Animate")
	if not animate then return nil end
	local animationSet = {}
	for key in pairs(tbl2) do
		local folder = animate:FindFirstChild(key)
		if folder then
			local animations = {}
			for _, child in ipairs(folder:GetChildren()) do
				if child:IsA("Animation") then
					local clone = child:Clone()
					clone.Parent = nil
					table.insert(animations, clone)
				end
			end
			if #animations > 0 then
				animationSet[key] = animations
			end
		end
	end
	return next(animationSet) and animationSet or nil
end

local function fn57(arg, arg2, requestedRig, requestGeneration)
	local rig = requestedRig or tbl3.rig
	local v7, v8 = fn56(arg2, rig)
	if not v7 or not v8 then
		if v8 then pcall(function() v8:Destroy() end) end
		return nil
	end

	if (requestGeneration and requestGeneration ~= applicationGeneration) or fn5() ~= arg then
		if v8 then v8:Destroy() end
		return nil
	end

    local sourceHumanoid = arg:FindFirstChildOfClass("Humanoid")
    if not waitForCharacterRig(arg, sourceHumanoid, rig, 2.5) then
        pcall(function() v8:Destroy() end)
        return nil
    end
    if (requestGeneration and requestGeneration ~= applicationGeneration) or fn5() ~= arg then
        pcall(function() v8:Destroy() end)
        return nil
    end

	fn14(arg)
	fn41()
	fn35(arg)
	fn22(arg)

	local animationData
	if rig == "R15" then
		animationData = fn12(v7)
	else
		animationData = getRigAnimationSet(v8)
	end

	fn20(arg, fn13(v7))
    local result = fn34(arg, v8, nil, rig)
    if requestGeneration and requestGeneration ~= applicationGeneration then
        fn35(arg)
        return nil
    end
    if not result then
        if v8 and v8.Parent then
            pcall(function() v8:Destroy() end)
        end
        return nil
    end
	copiedSkinAnimationData = animationData
	if tbl3.animationsEnabled then
		applyCopiedSkinAnimations(arg, true)
	else
		applyCopiedSkinAnimations(arg, false)
	end
    if type(avatarBridge.accessory.suspend) == "function" then
        pcall(avatarBridge.accessory.suspend)
    end
    return result
end

local function fn58(targetUserId, targetRig, fromRespawn)
    local userId = tonumber(targetUserId) or tonumber(tbl3.userId)
    local rig = (targetRig == "R6" or targetRig == "R15") and targetRig or tbl3.rig
    if not userId then return false end
    if rig ~= "R6" and rig ~= "R15" then rig = tbl3.rig end

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

    if flag3 then
        pendingApply = true
        return true
    end
    flag3 = true

    task.spawn(function()
        local shouldRefreshAccessory = false
        repeat
            pendingApply = false
            local requestGeneration = applicationGeneration
            local currentUserId = queuedSkinUserId
            local currentRig = queuedSkinRig or tbl3.rig
            avatarBridge.skin.requestedUserId = currentUserId
            avatarBridge.skin.requestedRig = currentRig
            local character = fn5()
            local result = nil

            if character and currentUserId then
                result = fn57(character, currentUserId, currentRig, requestGeneration)
            end

            if requestGeneration == applicationGeneration then
                if result then
                    tbl3.aplicado = currentUserId
                    avatarBridge.skin.active = true
                    bumpSkinRevision()
                    avatarBridge.skin.userId = currentUserId
                    avatarBridge.skin.rig = currentRig
                    avatarBridge.skin.requestedUserId = nil
                    avatarBridge.skin.requestedRig = nil
                    shouldRefreshAccessory = false
                    fn2()
                    fn46()
                    notifyAccessoryInventory()
                    obj3.Text = "Aplicado"
                else
                    local liveCharacter = fn5()
                    if liveCharacter then
                        fn35(liveCharacter)
                        fn22(liveCharacter)
                    end
                    tbl3.aplicado = nil
                    avatarBridge.skin.active = false
                    bumpSkinRevision()
                    avatarBridge.skin.userId = nil
                    avatarBridge.skin.requestedUserId = nil
                    avatarBridge.skin.requestedRig = nil
                    shouldRefreshAccessory = true
                    copiedSkinAnimationData = nil
                    fn46()
                    notifyAccessoryInventory()
                    obj3.Text = "Fallo"
                    fn2()
                end
            end
        until not pendingApply

        flag3 = false
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

local function fn59()
    applicationGeneration += 1
    characterRebuildGeneration += 1
    characterRebuildPending = false
    pendingApply = false
    queuedSkinUserId = nil
    queuedSkinRig = nil
    tbl3.aplicado = nil
    avatarBridge.skin.active = false
    bumpSkinRevision()
    avatarBridge.skin.userId = nil
    avatarBridge.skin.requestedUserId = nil
    avatarBridge.skin.requestedRig = nil
    copiedSkinAnimationData = nil
    avatarBridge.skin.releasing = flag3
    avatarBridge.skin.pending = flag3
    refreshAccessoryWhenIdle = flag3
    fn2()
    fn41()
    fn29()
    copiedSkinAnimationData = nil
    local v7 = fn5()

    if v7 then
        fn35(v7)
        fn22(v7)
    end

    obj3.Text = "Retirado"
    fn46()
    notifyAccessoryInventory()
    if not flag3 then
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
        userId = avatarBridge.skin.userId or tbl3.aplicado
    else
        userId = tbl3.aplicado
    end
    if not tonumber(userId) then return nil end
    return fn9(tonumber(userId))
end
avatarBridge.skin.refresh = function()
    if avatarBridge.skin.releasing then return false end
    if characterRebuildPending then return true end
    local userId = avatarBridge.skin.pending and avatarBridge.skin.requestedUserId
        or (avatarBridge.skin.active and avatarBridge.skin.userId)
        or tbl3.aplicado
    local rig = avatarBridge.skin.pending and avatarBridge.skin.requestedRig
        or (avatarBridge.skin.active and avatarBridge.skin.rig)
        or tbl3.rig
    if not tonumber(userId) then return false end
    return fn58(tonumber(userId), rig)
end

aplicar.Activated:Connect(fn58)
quitar.Activated:Connect(fn59)

local function fn60(rig)
	if tbl3.rig == rig then
		return
	end
	tbl3.rig = rig
	fn2()
	fn46()

	if (tbl3.aplicado or flag3) and fn5() then
		tbl3.userId = tbl3.userId or tbl3.aplicado
		fn58()
	end
end

r15.Activated:Connect(function()
	fn60("R15")
end)

r6.Activated:Connect(function()
	fn60("R6")
end)

v5.Activated:Connect(function()

	if avatarBridge.skin.active ~= true or not tonumber(tbl3.aplicado) then
		fn46()
		return
	end
	local character = fn5()
	if not character then return end
	tbl3.animationsEnabled = not (tbl3.animationsEnabled == true)
	local applied = applyCopiedSkinAnimations(character, tbl3.animationsEnabled)
	if not applied and tbl3.animationsEnabled then
		tbl3.animationsEnabled = false
		applyCopiedSkinAnimations(character, false)
		obj3.Text = "La skin no tiene animaciones compatibles"
	else
		obj3.Text = tbl3.animationsEnabled and "Aplicado" or "Retirado"
	end
	fn2()
	fn46()
end)

TextButton4.Activated:Connect(function()
	if not tbl3.userId then
		return
	end
	local v7 = fn49(tbl3.userId)

	if v7 then
		table.remove(tbl3.favoritos, v7)
	else
		table.insert(tbl3.favoritos, { userId = tbl3.userId, nombre = tbl3.nombre or tostring(tbl3.userId), usuario = tbl3.usuario })
	end

	fn2()
	fn50()
	fn52()
end)

local function fn61()
	local str2 = TextBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
	if str2 == "" then
		return
	end
	local num = tonumber(str2)
	if num then
		fn54(num)
		return
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if player.Name:lower() == str2:lower() or player.DisplayName:lower() == str2:lower() then
			fn54(player.UserId)
			return
		end
	end

	task.spawn(function()
		local ok, result = pcall(Players.GetUserIdFromNameAsync, Players, str2)

		if ok and result then
			fn54(result)
		else
			obj3.Text = "Fallo"
		end
	end)
end

TextButton3.Activated:Connect(fn61)

TextBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		fn61()
	end
end)

local tbl21 = {}
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

table.insert(tbl21, Players.PlayerAdded:Connect(function()
	task.defer(fn52)
end))
table.insert(tbl21, Players.PlayerRemoving:Connect(function()
	task.defer(fn52)
end))

table.insert(tbl21, localPlayer.CharacterRemoving:Connect(function(character)
    disconnectCharacterLifecycleConnections()
    applicationGeneration += 1
    characterRebuildGeneration += 1
    pendingApply = false
    fn41()
    fn29()
    local hasSavedSkin = tonumber(tbl3.aplicado) ~= nil
    characterRebuildPending = hasSavedSkin
    avatarBridge.skin.active = false
    avatarBridge.skin.pending = hasSavedSkin
    bumpSkinRevision()
    avatarBridge.skin.releasing = false
    avatarBridge.skin.userId = nil
    copiedSkinAnimationData = nil
    fn46()
    notifyAccessoryInventory()
end))

table.insert(tbl21, localPlayer.CharacterAdded:Connect(function(character)
    disconnectCharacterLifecycleConnections()
    fn41()
    fn29()
    applicationGeneration += 1
    characterRebuildGeneration += 1
    local respawnGeneration = characterRebuildGeneration
    pendingApply = false

    local appliedUserId = tonumber(tbl3.aplicado)
    if not appliedUserId then
        characterRebuildPending = false
        avatarBridge.skin.active = false
        avatarBridge.skin.pending = false
        avatarBridge.skin.releasing = false
        avatarBridge.skin.userId = nil
        avatarBridge.skin.requestedUserId = nil
        avatarBridge.skin.requestedRig = nil
        copiedSkinAnimationData = nil
        fn46()
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
    avatarBridge.skin.requestedRig = tbl3.rig

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
            fn41()
            fn29()
            copiedSkinAnimationData = nil
            local savedUserId = tonumber(tbl3.aplicado)
            characterRebuildPending = savedUserId ~= nil
            avatarBridge.skin.active = false
            avatarBridge.skin.pending = characterRebuildPending
            bumpSkinRevision()
            avatarBridge.skin.releasing = false
            avatarBridge.skin.userId = nil
            avatarBridge.skin.requestedUserId = savedUserId
            avatarBridge.skin.requestedRig = savedUserId and tbl3.rig or nil
        end)
        characterHealthConnection = humanoid.HealthChanged:Connect(function(health)
            if not didDie or health <= 0 or character ~= localPlayer.Character then
                return
            end
            local savedUserId = tonumber(tbl3.aplicado)
            if not savedUserId then
                didDie = false
                return
            end
            didDie = false
            characterRebuildPending = false
            fn58(savedUserId, tbl3.rig, true)
        end)

        local appearanceSignalOk, appearanceSignal = pcall(function()
            return humanoid.ApplyDescriptionFinished
        end)
        if appearanceSignalOk and appearanceSignal then
            characterAppearanceConnection = appearanceSignal:Connect(function()
                local savedUserId = tonumber(tbl3.aplicado)
                if not savedUserId or character ~= localPlayer.Character or appearanceRefreshQueued then
                    return
                end
                appearanceRefreshQueued = true
                task.defer(function()
                    while character == localPlayer.Character
                        and (flag3 or avatarBridge.skin.pending == true or characterRebuildPending) do
                        RunService.Heartbeat:Wait()
                    end
                    appearanceRefreshQueued = false
                    if character == localPlayer.Character and tonumber(tbl3.aplicado) == savedUserId
                        and not flag3 and not avatarBridge.skin.pending then
                        fn58(savedUserId, tbl3.rig, true)
                    end
                end)
            end)
        end

        if tbl3.aplicado and fn5() == character and humanoid.Health > 0 then
            fn58(appliedUserId, tbl3.rig, true)
        elseif tbl3.aplicado then
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

local flag4 = false
local v7 = nil
local v8 = nil

Frame2.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local position = input.Position
		local position2 = Frame.Position
		flag4 = true
		v7 = position
		v8 = position2
	end
end)

Frame2.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		flag4 = false
	end
end)

table.insert(tbl21, UserInputService.InputChanged:Connect(function(input)
	if not (flag4 and v7 and v8) then
		return
	end

	if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	local n5 = input.Position - v7
	Frame.Position = UDim2.new(v8.X.Scale, v8.X.Offset + n5.X, v8.Y.Scale, v8.Y.Offset + n5.Y)
end))

local currentCamera = Workspace.CurrentCamera

if currentCamera then
	table.insert(tbl21, currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fn44))
end

table.insert(tbl21, Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	task.defer(function()
		local savedUserId = tonumber(tbl3.aplicado)
		if savedUserId and avatarBridge.skin.active == true and not flag3 then
			fn58(savedUserId, tbl3.rig, true)
		end
	end)
end))

TextButton2.Activated:Connect(function()
	if flag2 then
		fn47(false)
	end

	Frame5.Visible = true
end)

TextButton6.Activated:Connect(function()
	Frame5.Visible = false
    disconnectCharacterLifecycleConnections()
	connection3:Disconnect()
	connection4:Disconnect()
    fn59()
    if avatarBridge.skin.owner == skinBridgeToken then
        avatarBridge.skin.owner = nil
        avatarBridge.skin.getBaseDescription = nil
        avatarBridge.skin.refresh = nil
    end

    for _, v9 in ipairs(tbl21) do
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
            fn47(true)
        else
            screenGui.Enabled = false
        end
        return true
    end,
	open = function()
		screenGui.Enabled = true
		Frame.Visible = true
		TextButton5.Visible = false
		return screenGui.Parent ~= nil
	end,
	aplicar = fn58,
	quitar = fn59,
	elegir = fn54,
	emote = fn43,
	pararEmote = fn41,
	destroy = function()
		disconnectCharacterLifecycleConnections()
		pcall(function() connection3:Disconnect() end)
        pcall(function() connection4:Disconnect() end)
		fn59()
		if avatarBridge.skin.owner == skinBridgeToken then
			avatarBridge.skin.owner = nil
			avatarBridge.skin.getBaseDescription = nil
			avatarBridge.skin.refresh = nil
		end
		for _, connection in ipairs(tbl21) do pcall(function() connection:Disconnect() end) end
		for _, template in pairs(skinModelTemplates) do pcall(function() template:Destroy() end) end
		table.clear(skinModelTemplates)
		table.clear(skinModelTemplateOrder)
			if screenGui.Parent then screenGui:Destroy() end
	end,

	setFEMode = function(mode)
		tbl3.feMode = "ON"
		fn2()
		fn46()
		return mode == "ON"
	end,
	setAnimations = function(enabled)
		if avatarBridge.skin.active ~= true or not tonumber(tbl3.aplicado) then return false end
		local character = fn5()
		if not character then return false end
		local requested = enabled == true
		local applied = applyCopiedSkinAnimations(character, requested)
		if requested and not applied then return false end
		tbl3.animationsEnabled = requested
		fn2()
		fn46()
		return true
	end,
}
fn46()
fn51()
fn52()

task.spawn(function()
	local flag5 = false

	for _, favorito in ipairs(tbl3.favoritos) do
		flag5 = fn53(favorito.userId) or flag5
	end

	if tbl3.userId then
		flag5 = fn53(tbl3.userId) or flag5
	end

	if flag5 then
		fn2()
		fn51()
		fn52()
	end
end)

return skinApi