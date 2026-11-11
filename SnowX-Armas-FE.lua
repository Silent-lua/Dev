local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ContentProvider = game:GetService("ContentProvider")
if not game:IsLoaded() then game.Loaded:Wait() end
local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait()
    LocalPlayer = Players.LocalPlayer
end
local GUI_NAME = "snowx-arms-visual"
local env = (getgenv and getgenv()) or _G
env.NexvyrCatOverride = env.NexvyrCatOverride or {}
-- Session cache: exact cloned Instances survive source removal and script re-execution
-- inside the same executor environment. A client/game restart clears this in-memory cache.
-- V6 intentionally starts empty: do not migrate old V4/V5 templates.
-- Exact cloned templates are retained for the current executor session.
local ASSET_CACHE_KEY = "SnowXArmasAssetCacheV6"
local AssetCache = env[ASSET_CACHE_KEY]
if type(AssetCache) ~= "table" or AssetCache.version ~= 6 then
    AssetCache = {
        version = 6,
        knives = {},
        guns = {},
        effects = {},
        stats = { knifeAdds = 0, gunAdds = 0, effectAdds = 0 },
    }
    env[ASSET_CACHE_KEY] = AssetCache
else
    AssetCache.knives = type(AssetCache.knives) == "table" and AssetCache.knives or {}
    AssetCache.guns = type(AssetCache.guns) == "table" and AssetCache.guns or {}
    AssetCache.effects = type(AssetCache.effects) == "table" and AssetCache.effects or {}
    AssetCache.stats = type(AssetCache.stats) == "table" and AssetCache.stats or {}
end
AssetCache.stats.knifeAdds = tonumber(AssetCache.stats.knifeAdds) or 0
AssetCache.stats.gunAdds = tonumber(AssetCache.stats.gunAdds) or 0
AssetCache.stats.effectAdds = tonumber(AssetCache.stats.effectAdds) or 0
AssetCache.sessionSchema = "knives/guns/effects-v2"
env.SnowXArmasAssetCacheV5 = nil
env.SnowXArmasAssetCacheV4 = nil
if env.SnowXArmasVisualCleanup then
    pcall(env.SnowXArmasVisualCleanup)
elseif env.NexvyrToolsVisualCleanup then
    pcall(env.NexvyrToolsVisualCleanup)
end
local conns = {}
local function track(c)
    conns[#conns + 1] = c
    return c
end
local function textureFromAsset(direct)
    local ok, obj = pcall(function() return game:GetObjects(direct)[1] end)
    if not (ok and obj) then return nil end
    local tex
    if obj:IsA("Decal") or obj:IsA("Texture") then
        tex = obj.Texture
    else
        local d = obj:FindFirstChildWhichIsA("Decal", true)
        if d then tex = d.Texture end
    end
    pcall(function() obj:Destroy() end)
    if tex and tex ~= "" then return tex end
    return nil
end
local function loadBackgroundAsset()
    local url = "https://raw.githubusercontent.com/Styx-ui/w/refs/heads/main/Slow2.jpg"
    local assetPath = "avatar-visual/Slow2.jpg"
    pcall(function()
        if type(isfolder) == "function" and type(makefolder) == "function" and not isfolder("avatar-visual") then
            makefolder("avatar-visual")
        end
    end)
    local exists = false
    pcall(function()
        if type(isfile) == "function" then exists = isfile(assetPath) end
    end)
    if not exists and type(writefile) == "function" then
        local ok, data = pcall(function() return game:HttpGet(url) end)
        if ok and type(data) == "string" and #data > 0 then
            pcall(function() writefile(assetPath, data) end)
        end
    end
    if type(getcustomasset) == "function" then
        local ok, asset = pcall(getcustomasset, assetPath)
        if ok and type(asset) == "string" then return asset end
    end
    return nil
end

local function getParent()
    local ok, ui = pcall(function() return gethui and gethui() end)
    if ok and ui then return ui end
    ok, ui = pcall(function() return game:GetService("CoreGui") end)
    if ok and ui then
        local t = Instance.new("Folder")
        local good = pcall(function() t.Parent = ui end)
        t:Destroy()
        if good then return ui end
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end
local parent = getParent()
local old = parent:FindFirstChild(GUI_NAME)
if old then old:Destroy() end
local WHITE = Color3.new(1, 1, 1)
local BLACK = Color3.new(0, 0, 0)
local IC = {
    title = Color3.fromRGB(245, 245, 245),
    titleLow = Color3.fromRGB(190, 190, 198),
    gold = Color3.fromRGB(74, 74, 84),
    goldLight = Color3.fromRGB(210, 210, 218),
    soft = Color3.fromRGB(170, 170, 178),
    btnText = Color3.fromRGB(245, 245, 245),
    btnBg = Color3.fromRGB(12, 12, 14),
    btnBgMain = Color3.fromRGB(42, 42, 48),
    btnLine = Color3.fromRGB(54, 54, 62),
}
local T = {
    text = IC.title,
    sub = IC.soft,
    line = IC.btnLine,
    gold = IC.gold,
    red = Color3.fromRGB(230, 130, 130),
    green = Color3.fromRGB(160, 210, 175),
    warn = Color3.fromRGB(230, 180, 110),
}
local STYLES = {
    main = { bg = IC.btnBgMain, bgT = 0.12, stroke = Color3.fromRGB(74, 74, 84), strokeT = 0.2, text = WHITE },
    dark = { bg = Color3.fromRGB(26, 26, 32), bgT = 0.08, stroke = IC.btnLine, strokeT = 0.35, text = IC.btnText },
    danger = { bg = Color3.fromRGB(95, 45, 45), bgT = 0.12, stroke = T.red, strokeT = 0.3, text = Color3.fromRGB(255, 220, 220) },
    green = { bg = Color3.fromRGB(42, 64, 50), bgT = 0.1, stroke = T.green, strokeT = 0.25, text = WHITE },
}
local UI = {}
local touchOnly = UIS.TouchEnabled and not UIS.KeyboardEnabled
function UI.new(class, props)
    local o = Instance.new(class)
    local p
    for k, v in pairs(props) do
        if k == "Parent" then p = v else o[k] = v end
    end
    if p then o.Parent = p end
    return o
end
local new = UI.new
function UI.corner(o, r)
    return new("UICorner", { Parent = o, CornerRadius = UDim.new(0, r) })
end
local corner = UI.corner
function UI.stroke(o, color, thick, trans)
    return new("UIStroke", {
        Parent = o, Color = color, Thickness = thick or 1,
        Transparency = trans or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end
local stroke = UI.stroke
function UI.grad(o, c1, c2, rot)
    return new("UIGradient", { Parent = o, Color = ColorSequence.new(c1, c2), Rotation = rot or 90 })
end
local grad = UI.grad
function UI.tween(o, info, props)
    local t = TweenService:Create(o, info, props)
    t:Play()
    return t
end
local tween = UI.tween
local gui = new("ScreenGui", {
    Name = GUI_NAME, ResetOnSpawn = false, IgnoreGuiInset = true,
    DisplayOrder = 2147483647, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = parent,
})
function UI.viewport()
    local size = gui.AbsoluteSize
    if size.X < 10 or size.Y < 10 then
        local camera = Workspace.CurrentCamera
        if camera then return camera.ViewportSize end
        return Vector2.new(1280, 720)
    end
    return size
end
function UI.background(host, overlayT, backgroundAsset)
    local img = new("ImageLabel", {
        Parent = host,
        Name = "ReferenceBackground",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ScaleType = Enum.ScaleType.Crop,
        Image = backgroundAsset or "",
        ImageTransparency = backgroundAsset and 0.38 or 1,
        BorderSizePixel = 0,
        ZIndex = 1,
    })
    corner(img, 16)
    local sc = new("UIScale", { Parent = img, Scale = 1.14 })
    local overlay = new("Frame", {
        Parent = host, Name = "ReferenceBackgroundOverlay", Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = BLACK, BackgroundTransparency = backgroundAsset and 0.58 or 1,
        BorderSizePixel = 0, ZIndex = 1,
    })
    return sc, img, overlay
end
function UI.icon(kind, parent_, color, size)
    size = size or 16
    local root = new("Frame", {
        Parent = parent_, Size = UDim2.fromOffset(size, size), BackgroundTransparency = 1,
    })
    local inner = new("Frame", {
        Parent = root, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(16, 16), BackgroundTransparency = 1,
    })
    new("UIScale", { Parent = inner, Scale = size / 16 })
    local fills, strokes = {}, {}
    local function bar(cx, cy, w, h, rot)
        local f = new("Frame", {
            Parent = inner, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(cx, cy),
            Size = UDim2.fromOffset(w, h), Rotation = rot or 0, BackgroundColor3 = color, BorderSizePixel = 0,
        })
        corner(f, math.min(w, h) / 2)
        fills[#fills + 1] = f
    end
    local function line(x1, y1, x2, y2, th)
        local dx, dy = x2 - x1, y2 - y1
        local len = math.sqrt(dx * dx + dy * dy)
        bar((x1 + x2) / 2, (y1 + y2) / 2, len, th or 1.8, math.deg(math.atan2(dy, dx)))
    end
    local function box(cx, cy, w, h, r, th)
        local f = new("Frame", {
            Parent = inner, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(cx, cy),
            Size = UDim2.fromOffset(w, h), BackgroundTransparency = 1, BorderSizePixel = 0,
        })
        corner(f, r)
        strokes[#strokes + 1] = new("UIStroke", {
            Parent = f, Color = color, Thickness = th, ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        })
    end
    if kind == "close" then
        line(3.8, 3.8, 12.2, 12.2, 2)
        line(12.2, 3.8, 3.8, 12.2, 2)
    elseif kind == "min" then
        bar(8, 11, 10, 2)
    elseif kind == "plus" then
        bar(8, 8, 11, 2)
        bar(8, 8, 2, 11)
    elseif kind == "search" then
        box(7, 7, 10, 10, 5, 1.6)
        line(10.8, 10.8, 14.2, 14.2, 2)
    elseif kind == "trash" then
        box(8, 2.9, 4.6, 3.2, 1.4, 1.4)
        bar(8, 4.9, 12.5, 1.8)
        box(8, 10.6, 9, 8.6, 2, 1.5)
        bar(6.2, 10.8, 1.3, 4.6)
        bar(9.8, 10.8, 1.3, 4.6)
    end
    local icon = { root = root }
    function icon.set(c)
        for _, f in ipairs(fills) do f.BackgroundColor3 = c end
        for _, s in ipairs(strokes) do s.Color = c end
    end
    return icon
end
function UI.button(o)
    local S = STYLES[o.style or "dark"]
    local b = new("TextButton", {
        Parent = o.parent, Size = o.size, BackgroundColor3 = S.bg, BackgroundTransparency = S.bgT,
        AutoButtonColor = false, Text = "", BorderSizePixel = 0, LayoutOrder = o.order or 0,
    })
    if o.pos then b.Position = o.pos end
    if o.anchor then b.AnchorPoint = o.anchor end
    corner(b, o.radius or 4)
    local st = stroke(b, S.stroke, 1, S.strokeT)
    local sc = new("UIScale", { Parent = b, Scale = 1 })
    local row = new("Frame", { Parent = b, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 })
    new("UIListLayout", {
        Parent = row, FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder,
    })
    local tc = o.textColor or S.text
    local icColor = o.iconColor or tc
    local ic, lbl
    if o.icon then
        ic = UI.icon(o.icon, row, icColor, o.iconSize or 14)
        ic.root.LayoutOrder = 1
    end
    if o.text then
        lbl = new("TextLabel", {
            Parent = row, BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.fromOffset(0, 16), Text = o.text, Font = Enum.Font.GothamMedium,
            TextSize = o.textSize or 12, TextColor3 = tc, LayoutOrder = 2,
        })
    end
    local info = TweenInfo.new(0.15, Enum.EasingStyle.Quad)
    local pinfo = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local rinfo = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local function paint(mode)
        local bgT, stT, bgC
        if mode == "hover" then
            bgT, stT = math.max(0, S.bgT - 0.18), math.max(0, S.strokeT - 0.3)
            bgC = S.bg:Lerp(S.stroke, 0.18)
        elseif mode == "press" then
            bgT, stT = math.max(0, S.bgT - 0.3), math.max(0, S.strokeT - 0.4)
            bgC = S.bg:Lerp(S.stroke, 0.3)
        else
            bgT, stT, bgC = S.bgT, S.strokeT, S.bg
        end
        tween(b, info, { BackgroundTransparency = bgT, BackgroundColor3 = bgC })
        tween(st, info, { Transparency = stT })
    end
    b.MouseEnter:Connect(function()
        if touchOnly then return end
        paint("hover")
        if ic and o.iconHover then ic.set(o.iconHover) end
    end)
    b.MouseLeave:Connect(function()
        paint("idle")
        tween(sc, rinfo, { Scale = 1 })
        if ic and o.iconHover then ic.set(icColor) end
    end)
    b.MouseButton1Down:Connect(function()
        paint("press")
        tween(sc, pinfo, { Scale = 0.95 })
        if ic and o.iconHover then ic.set(o.iconHover) end
    end)
    b.MouseButton1Up:Connect(function()
        tween(sc, rinfo, { Scale = 1 })
        if touchOnly then
            paint("idle")
            if ic and o.iconHover then ic.set(icColor) end
        else
            paint("hover")
        end
    end)
    local h = { btn = b, label = lbl, icon = ic, stroke = st }
    function h.setStyle(name)
        S = STYLES[name] or S
        local c = o.textColor or S.text
        if lbl then lbl.TextColor3 = c end
        if ic and not o.iconColor then ic.set(c) end
        tween(st, info, { Color = S.stroke })
        paint("idle")
    end
    return h
end
local makeButton = UI.button
function UI.winButton(parent_, kind, xOff, accent)
    local b = new("TextButton", {
        Parent = parent_, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, xOff, 0.5, 0),
        Size = UDim2.fromOffset(28, 28), BackgroundColor3 = IC.btnBg, BackgroundTransparency = 0.45,
        AutoButtonColor = false, Text = "", BorderSizePixel = 0,
    })
    corner(b, 4)
    local st = stroke(b, IC.btnLine, 1, 0.65)
    local sc = new("UIScale", { Parent = b, Scale = 1 })
    local ic = UI.icon(kind, b, IC.soft, 14)
    ic.root.AnchorPoint = Vector2.new(0.5, 0.5)
    ic.root.Position = UDim2.fromScale(0.5, 0.5)
    local info = TweenInfo.new(0.14, Enum.EasingStyle.Quad)
    local pinfo = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local rinfo = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local function state(bgColor, bgT, strokeColor, strokeT, iconColor)
        tween(b, info, { BackgroundColor3 = bgColor, BackgroundTransparency = bgT })
        tween(st, info, { Color = strokeColor, Transparency = strokeT })
        ic.set(iconColor)
    end
    local function idle() state(IC.btnBg, 0.45, IC.btnLine, 0.65, IC.soft) end
    local function over() state(accent:Lerp(BLACK, 0.7), 0.15, accent, 0.2, WHITE) end
    b.MouseEnter:Connect(function()
        if touchOnly then return end
        over()
        if kind == "close" then
            tween(ic.root, rinfo, { Rotation = 90 })
        end
    end)
    b.MouseLeave:Connect(function()
        idle()
        tween(sc, rinfo, { Scale = 1 })
        tween(ic.root, rinfo, { Rotation = 0 })
    end)
    b.MouseButton1Down:Connect(function()
        over()
        tween(sc, pinfo, { Scale = 0.88 })
    end)
    b.MouseButton1Up:Connect(function()
        tween(sc, rinfo, { Scale = 1 })
        if touchOnly then
            idle()
        else
            over()
        end
    end)
    return b
end
function UI.modal(host)
    local overlay = new("Frame", {
        Parent = host, Size = UDim2.fromScale(1, 1), BackgroundColor3 = BLACK,
        BackgroundTransparency = 1, BorderSizePixel = 0, Active = true, Visible = false, ZIndex = 100,
    })
    local box = new("Frame", {
        Parent = overlay, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(300, 142), BackgroundColor3 = IC.btnBg, BackgroundTransparency = 0.08,
        BorderSizePixel = 0, ZIndex = 101,
    })
    corner(box, 6)
    local boxStroke = stroke(box, WHITE, 1.2, 0.2)
    grad(boxStroke, IC.gold, IC.btnLine, 60)
    local scale = new("UIScale", { Parent = box, Scale = 0.9 })
    local title = new("TextLabel", {
        Parent = box, Position = UDim2.fromOffset(14, 12), Size = UDim2.new(1, -28, 0, 26),
        BackgroundTransparency = 1, Text = "", Font = Enum.Font.Garamond,
        TextSize = 22, TextColor3 = IC.title, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 102,
    })
    local text = new("TextLabel", {
        Parent = box, Position = UDim2.fromOffset(14, 42), Size = UDim2.new(1, -28, 0, 34),
        BackgroundTransparency = 1, Text = "", Font = Enum.Font.Gotham, TextSize = 12,
        TextColor3 = IC.soft, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 102,
    })
    local left = makeButton({
        parent = box, text = "Volver", size = UDim2.fromOffset(129, 34),
        pos = UDim2.fromOffset(14, 94), style = "dark", textSize = 13,
    })
    local right = makeButton({
        parent = box, text = "Aceptar", size = UDim2.fromOffset(129, 34),
        pos = UDim2.fromOffset(157, 94), style = "danger", textSize = 13,
    })
    for _, d in ipairs(box:GetDescendants()) do
        if d:IsA("GuiObject") and d.ZIndex < 102 then d.ZIndex = 102 end
    end
    local m = {}
    local cbLeft, cbRight
    local showToken = 0
    function m.show(o)
        showToken = showToken + 1
        title.Text = o.title or ""
        text.Text = o.text or ""
        left.label.Text = o.leftText or "Volver"
        right.label.Text = o.rightText or "Aceptar"
        left.setStyle(o.leftStyle or "dark")
        right.setStyle(o.rightStyle or "danger")
        cbLeft, cbRight = o.onLeft, o.onRight
        overlay.Visible = true
        tween(overlay, TweenInfo.new(0.2), { BackgroundTransparency = 0.45 })
        scale.Scale = 0.9
        tween(scale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
    end
    function m.hide()
        showToken = showToken + 1
        local my = showToken
        tween(scale, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0.9 })
        local t = tween(overlay, TweenInfo.new(0.18), { BackgroundTransparency = 1 })
        t.Completed:Connect(function()
            if showToken == my then overlay.Visible = false end
        end)
    end
    left.btn.MouseButton1Click:Connect(function()
        m.hide()
        if cbLeft then cbLeft() end
    end)
    right.btn.MouseButton1Click:Connect(function()
        m.hide()
        if cbRight then cbRight() end
    end)
    return m
end
local W, H = 590, 274
local vp0 = UI.viewport()
local function calculateBaseScale(viewport)
    local widthFactor = touchOnly and 0.90 or 0.94
    local heightFactor = touchOnly and 0.78 or 0.92
    return math.clamp(math.min(viewport.X * heightFactor / W, viewport.Y * widthFactor / H), 0.01, 1)
end
local BASE = calculateBaseScale(vp0)
local Root = new("Frame", {
    Parent = gui,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.fromScale(1, 1),
    Position = UDim2.fromScale(0, 0),
    Visible = true,
})
local Window = new("CanvasGroup", {
    Parent = Root,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromOffset(vp0.X * 0.5, vp0.Y * 0.5),
    Size = UDim2.fromOffset(W, H),
    BackgroundColor3 = Color3.fromRGB(12, 12, 14),
    BorderSizePixel = 0,
    Active = true,
    ClipsDescendants = true,
    Visible = false,
    GroupTransparency = 0,
})
corner(Window, 16)
local winStroke = stroke(Window, Color3.fromRGB(74, 74, 84), 1, 0.2)
local winScale = new("UIScale", { Parent = Window, Scale = BASE })
local bgScale, bgImage, bgOverlay = UI.background(Window, 0.58, nil)
local bgAsset = nil
local floatingBackground, floatingOverlay
-- The visual panel must not wait for an external image request.
task.defer(function()
    local asset = loadBackgroundAsset()
    if not asset then return end
    bgAsset = asset
    if bgImage and bgImage.Parent then
        bgImage.Image = asset
        bgImage.ImageTransparency = 0.38
        if bgOverlay and bgOverlay.Parent then bgOverlay.BackgroundTransparency = 0.58 end
    end
    if floatingBackground and floatingBackground.Parent then
        floatingBackground.Image = asset
        floatingBackground.ImageTransparency = 0.5
    end
    if floatingOverlay and floatingOverlay.Parent then
        floatingOverlay.BackgroundTransparency = 0.55
    end
end)

local mainCenter = Vector2.new(vp0.X * 0.5, vp0.Y * 0.5)
local function clampWindowCenter(position)
    local viewport = UI.viewport()
    local halfSize = Vector2.new(W * BASE * 0.5 + 2, H * BASE * 0.5 + 2)
    local maxX, maxY = viewport.X - halfSize.X, viewport.Y - halfSize.Y
    if maxX < halfSize.X or maxY < halfSize.Y then
        return Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
    end
    return Vector2.new(
        math.clamp(position.X, halfSize.X, maxX),
        math.clamp(position.Y, halfSize.Y, maxY)
    )
end
local function setMainCenter(position)
    mainCenter = clampWindowCenter(position)
    Window.Position = UDim2.fromOffset(mainCenter.X, mainCenter.Y)
    return mainCenter
end
local function keepMainInsideViewport()
    if Window.Visible then setMainCenter(mainCenter) end
end

local TopBar = new("Frame", {
    Parent = Window, Size = UDim2.new(1, 0, 0, 52), BackgroundTransparency = 1,
})
local headLine = new("Frame", {
    Parent = Window, Position = UDim2.fromOffset(0, 52),
    Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = Color3.fromRGB(54, 54, 62), BorderSizePixel = 0,
})
new("UIGradient", {
    Parent = headLine,
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.7),
        NumberSequenceKeypoint.new(0.5, 0.1),
        NumberSequenceKeypoint.new(1, 0.7),
    }),
})
local dragArea = new("Frame", {
    Parent = TopBar, Size = UDim2.new(1, -86, 1, 0), BackgroundTransparency = 1, Active = true,
})
local titleMain = new("TextLabel", {
    Parent = TopBar, Position = UDim2.fromOffset(18, 7), Size = UDim2.fromOffset(166, 22),
    BackgroundTransparency = 1, Text = "SnowX", Font = Enum.Font.GothamBold,
    TextSize = 16, TextColor3 = IC.title, TextXAlignment = Enum.TextXAlignment.Left,
    TextStrokeTransparency = 0.88, TextStrokeColor3 = BLACK,
})
grad(titleMain, IC.titleLow, IC.title, 90)
new("TextLabel", {
    Parent = TopBar, Position = UDim2.fromOffset(19, 25), Size = UDim2.fromOffset(150, 12),
    BackgroundTransparency = 1, Text = "By Fabnx1", Font = Enum.Font.Gotham,
    TextSize = 9, TextColor3 = IC.soft, TextXAlignment = Enum.TextXAlignment.Left,
})
local btnMin = UI.winButton(TopBar, "min", -44, IC.gold)
local btnClose = UI.winButton(TopBar, "close", -10, T.red)

new("Frame", {
    Parent = Window, Position = UDim2.fromOffset(176, 52),
    Size = UDim2.new(0, 1, 1, -52), BackgroundColor3 = Color3.fromRGB(54, 54, 62), BorderSizePixel = 0,
})

local Left = new("Frame", {
    Parent = Window, Position = UDim2.fromOffset(8, 60), Size = UDim2.fromOffset(160, 206),
    BackgroundTransparency = 1, BorderSizePixel = 0,
})
local previewHolder = new("Frame", {
    Parent = Left, Position = UDim2.fromOffset(4, 0), Size = UDim2.fromOffset(150, 112),
    BackgroundColor3 = Color3.fromRGB(26, 26, 32), BackgroundTransparency = 0.15, BorderSizePixel = 0,
    ClipsDescendants = true,
})
corner(previewHolder, 10)
local prevStroke = stroke(previewHolder, Color3.fromRGB(74, 74, 84), 1, 0.25)
local previewContent = new("Frame", {
    Parent = previewHolder, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
})
local previewHint = new("TextLabel", {
    Parent = previewHolder, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
    Text = "Sin selección", Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = IC.soft,
})
local nameLabel = new("TextLabel", {
    Parent = Left, Position = UDim2.fromOffset(4, 116), Size = UDim2.fromOffset(150, 18),
    BackgroundTransparency = 1, Text = "-", Font = Enum.Font.GothamBold, TextSize = 12,
    TextColor3 = IC.title, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
})
local idChip = new("Frame", {
    Parent = Left, Position = UDim2.fromOffset(4, 137), Size = UDim2.fromOffset(0, 16),
    AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = Color3.fromRGB(26, 26, 32),
    BackgroundTransparency = 0.15, BorderSizePixel = 0,
})
corner(idChip, 5)
new("UIPadding", { Parent = idChip, PaddingLeft = UDim.new(0, 7), PaddingRight = UDim.new(0, 7) })
local idLabel = new("TextLabel", {
    Parent = idChip, Size = UDim2.fromOffset(0, 16), AutomaticSize = Enum.AutomaticSize.X,
    BackgroundTransparency = 1, Text = "-", Font = Enum.Font.GothamMedium, TextSize = 9,
    TextColor3 = IC.titleLow,
})
local btnMove = makeButton({
    parent = Left, text = "> Pistolas", size = UDim2.fromOffset(76, 18),
    pos = UDim2.fromOffset(78, 136), style = "dark", textSize = 9,
})
btnMove.btn.Visible = false
local statusDot = new("Frame", {
    Parent = Left, Position = UDim2.fromOffset(6, 169), Size = UDim2.fromOffset(6, 6),
    BackgroundColor3 = IC.soft, BorderSizePixel = 0,
})
corner(statusDot, 3)
local statusLabel = new("TextLabel", {
    Parent = Left, Position = UDim2.fromOffset(18, 162), Size = UDim2.fromOffset(140, 25),
    BackgroundTransparency = 1, Text = "Iniciando...", Font = Enum.Font.Gotham,
    TextSize = 10, TextColor3 = IC.soft, TextWrapped = true, TextTruncate = Enum.TextTruncate.AtEnd,
    TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
})
local progressTrack = new("Frame", {
    Parent = Left, Position = UDim2.fromOffset(4, 199), Size = UDim2.fromOffset(150, 3),
    BackgroundColor3 = Color3.fromRGB(54, 54, 62), BackgroundTransparency = 0.1, BorderSizePixel = 0,
    ClipsDescendants = true,
})
corner(progressTrack, 2)
local progressFill = new("Frame", {
    Parent = progressTrack, Size = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = IC.title, BorderSizePixel = 0,
})
corner(progressFill, 2)
local function setStatus(text, color)
    statusLabel.Text = text
    statusLabel.TextColor3 = color or IC.soft
    statusDot.BackgroundColor3 = color or IC.soft
end
local function setProgress(p)
    tween(progressFill, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
        Size = UDim2.new(math.clamp(p, 0, 1), 0, 1, 0),
    })
end

local Right = new("Frame", {
    Parent = Window, Position = UDim2.fromOffset(194, 60), Size = UDim2.fromOffset(382, 206),
    BackgroundTransparency = 1, BorderSizePixel = 0,
})
local inputBox = new("Frame", {
    Parent = Right, Position = UDim2.fromOffset(0, 0), Size = UDim2.fromOffset(290, 32),
    BackgroundColor3 = Color3.fromRGB(26, 26, 32), BackgroundTransparency = 0.12, BorderSizePixel = 0,
})
corner(inputBox, 8)
local inputStroke = stroke(inputBox, Color3.fromRGB(54, 54, 62), 1, 0.35)
local searchIcon = UI.icon("search", inputBox, IC.soft, 15)
searchIcon.root.Position = UDim2.fromOffset(10, 8)
local input = new("TextBox", {
    Parent = inputBox, Position = UDim2.fromOffset(32, 0), Size = UDim2.new(1, -42, 1, 0),
    BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", PlaceholderText = "Buscar cuchillo",
    PlaceholderColor3 = IC.soft, TextColor3 = IC.title, Font = Enum.Font.Gotham,
    TextSize = 12, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
    ClipsDescendants = true,
})
input.Focused:Connect(function()
    tween(inputStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(74, 74, 84), Transparency = 0.15 })
    searchIcon.set(IC.title)
end)
input.FocusLost:Connect(function()
    tween(inputStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(54, 54, 62), Transparency = 0.35 })
    searchIcon.set(IC.soft)
end)
local btnSearch = makeButton({
    parent = Right, text = "Buscar", size = UDim2.fromOffset(84, 32),
    pos = UDim2.fromOffset(298, 0), style = "main", textSize = 11,
})
local btnApply = makeButton({
    parent = Right, text = "Aplicar skin", icon = "plus", size = UDim2.fromOffset(188, 30),
    pos = UDim2.fromOffset(0, 40), style = "main", textSize = 11,
})
local btnRemove = makeButton({
    parent = Right, text = "Quitar skin", icon = "trash", size = UDim2.fromOffset(188, 30),
    pos = UDim2.fromOffset(194, 40), style = "danger", textSize = 11,
})
local tabBar = new("Frame", {
    Parent = Right, Position = UDim2.fromOffset(0, 78), Size = UDim2.fromOffset(220, 28),
    BackgroundColor3 = Color3.fromRGB(26, 26, 32), BackgroundTransparency = 0.12, BorderSizePixel = 0,
})
corner(tabBar, 8)
stroke(tabBar, Color3.fromRGB(54, 54, 62), 1, 0.35)
local tabStrokes = {}
local function makeTab(text, x, key)
    local t = new("TextButton", {
        Parent = tabBar, Position = UDim2.fromOffset(x, 3), Size = UDim2.fromOffset(70, 22),
        BackgroundColor3 = Color3.fromRGB(42, 42, 48), BackgroundTransparency = 1, AutoButtonColor = false,
        Text = text, Font = Enum.Font.GothamMedium, TextSize = 10, TextColor3 = IC.soft, BorderSizePixel = 0,
    })
    corner(t, 5)
    tabStrokes[key] = stroke(t, Color3.fromRGB(74, 74, 84), 1, 1)
    return t
end
local tabButtons = {
    knives = makeTab("Cuchillos", 3, "knives"),
    guns = makeTab("Pistolas", 75, "guns"),
    effects = makeTab("Efectos", 147, "effects"),
}
local countLabel = new("TextLabel", {
    Parent = Right, Position = UDim2.fromOffset(226, 78), Size = UDim2.fromOffset(156, 28),
    BackgroundTransparency = 1, Text = "", Font = Enum.Font.GothamMedium, TextSize = 10,
    TextColor3 = IC.soft, TextXAlignment = Enum.TextXAlignment.Right,
})
local listFrame = new("ScrollingFrame", {
    Parent = Right, Position = UDim2.fromOffset(0, 112), Size = UDim2.fromOffset(382, 94),
    BackgroundColor3 = Color3.fromRGB(26, 26, 32), BackgroundTransparency = 0.12, BorderSizePixel = 0,
    ScrollBarThickness = 3, ScrollBarImageColor3 = IC.titleLow, CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y,
    ClipsDescendants = true,
})
corner(listFrame, 8)
stroke(listFrame, Color3.fromRGB(54, 54, 62), 1, 0.35)
new("UIPadding", {
    Parent = listFrame, PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6),
    PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6),
})
new("UIListLayout", {
    Parent = listFrame, Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center,
})
local emptyLabel = new("TextLabel", {
    Parent = Right, Position = UDim2.fromOffset(0, 112), Size = UDim2.fromOffset(382, 94),
    BackgroundTransparency = 1, Text = "", Font = Enum.Font.GothamMedium, TextSize = 11,
    TextColor3 = IC.soft, Visible = false, ZIndex = 5,
})
local Modal = UI.modal(Window)
local PAGE = 18
local Data = { knives = {}, guns = {}, effects = {} }
local Scan = { running = false, done = false }
local Selected = { knives = nil, guns = nil, effects = nil }
local activeTab = "knives"
local busy = false
local Spin = { views = setmetatable({}, { __mode = "k" }), last = 0, cardLast = 0 }
local paintCards
local TAB_INFO = {
    knives = {
        apply = "Aplicar cuchillo", remove = "Borrar cuchillo", ph = "Buscar cuchillo",
        plural = " cuchillos", empty = "No se encontraron cuchillos.", cat = "melee",
    },
    guns = {
        apply = "Aplicar pistola", remove = "Borrar pistola", ph = "Buscar pistola",
        plural = " pistolas", empty = "No se encontraron pistolas.", cat = "gun",
    },
    effects = {
        apply = "Aplicar efecto", remove = "Borrar efecto", ph = "Buscar kill effect",
        plural = " kill effects", empty = "No se encontraron kill effects.",
    },
}

local M = (function()
    local M = {}
    local wIndex = {}
    local guiMap, guiCat, iconMap = {}, {}, {}
    local assetIndex
    local activeScanInstances = nil
    local descendantCache = setmetatable({}, { __mode = "k" })
    local partsCache = setmetatable({}, { __mode = "k" })
    local meshSigCache = setmetatable({}, { __mode = "k" })
    local killContentCache = setmetatable({}, { __mode = "k" })
    local weaponTreeCache = setmetatable({}, { __mode = "k" })
    local function descendantsOf(inst)
        local cached = descendantCache[inst]
        if cached then return cached end
        local list = inst:GetDescendants()
        descendantCache[inst] = list
        return list
    end
    local function norm(s)
        s = tostring(s):gsub("(%l)(%u)", "%1 %2")
        s = s:gsub("[_%-%.]+", " ")
        return s:lower()
    end
    local function squash(s)
        local r = tostring(s):lower():gsub("[^%w]", "")
        return r
    end
    local function hasAny(n, list)
        for _, k in ipairs(list) do
            if n:find(k, 1, true) then return true end
        end
        return false
    end
    local function hasWordKW(n, list)
        local p = " " .. n .. " "
        for _, k in ipairs(list) do
            if p:find("[^%w]" .. k .. "s?[^%w]") then return true end
        end
        return false
    end
    local function hasWord(n, list)
        for _, b in ipairs(list) do
            if n:find("%f[%a]" .. b .. "%f[%A]") then return true end
        end
        return false
    end
    local PRIORITY = { "hipotermia", "hypothermia", "hipothermia", "hypotermia" }
    local ALIAS = { hipotermia = "hypothermia", hypothermia = "hipotermia" }
    local function isPriority(name)
        local n = squash(name)
        for _, k in ipairs(PRIORITY) do
            if n:find(k, 1, true) then return true end
        end
        return false
    end
    local function nameKeys(name)
        local k = squash(name)
        local list = { k }
        for a, b in pairs(ALIAS) do
            if k:find(a, 1, true) then
                list[#list + 1] = (k:gsub(a, b))
            end
        end
        return list
    end
    local BLADE_SUB = {
        "blade", "knife", "knives", "cuchillo", "dagger", "daga", "sword", "espada", "katana",
        "sabre", "saber", "machete", "scythe", "guadana", "hatchet", "hacha", "kunai", "karambit",
        "cleaver", "melee", "stiletto", "rapier", "scimitar", "cutlass", "kukri", "wakizashi",
        "nodachi", "bayonet", "bayoneta", "navaja", "pickaxe",
    }
    local BLADE_WORD = { "axe", "tanto", "shank", "pico", "katar", "machette" }
    local GUN_SUB = {
        "pistol", "pistola", "handgun", "revolver", "rifle", "shotgun", "escopeta", "sniper",
        "francotirador", "blaster", "launcher", "lanzador", "bazooka", "minigun", "firearm",
        "carbine", "carabina", "musket", "mosquete", "flintlock", "derringer", "uzi", "glock",
        "deagle", "desert eagle", "thompson", "winchester", "remington", "barrett", "machinegun",
        "arma de fuego",
    }
    local GUN_WORD = {
        "gun", "smg", "ak47", "ak 47", "ak", "m4", "m16", "ar15", "ar 15", "ar", "rpg", "mg42",
        "mac10", "mac 10", "mp5", "p90", "aug", "famas", "galil", "tommy", "bren", "sten",
        "welrod", "luger", "colt", "awp", "scar", "vector",
    }
    local GUN_HINT = { "muzzle", "ammo", "reload", "bullet", "shoot", "recoil", "magazine", "fire rate", "firerate", "barrel" }
    local MELEE_HINT = { "slash", "stab", "swing", "lunge", "backstab", "throw" }
    local CAT_META_KEYS = {
        "category", "weaponcategory", "weaponclass", "class", "slot", "itemtype", "weapontype", "type",
    }
    -- Static catalog extracted from the user's Shared.Item dump.
    -- It is authoritative for membership and thumbnails; runtime scanning only resolves 3D sources.
    local STATIC_CATALOG = {
        guns = {
            { key = "DefaultGun", name = "Default Gun", image = "http://www.roblox.com/asset/?id=197518111", rarity = "Common", offset = nil, angles = nil },
            { key = "PumpkinPopper", name = "Pumpkin Popper", image = "http://www.roblox.com/asset/?id=124709578186118", rarity = "Rare", offset = nil, angles = nil },
            { key = "PhantomGreen", name = "Phantom Green", image = "http://www.roblox.com/asset/?id=87783288813248", rarity = "Legendary", offset = nil, angles = nil },
            { key = "WindSpirits", name = "Wind Spirits", image = "http://www.roblox.com/asset/?id=134896947058014", rarity = "Uncommon", offset = nil, angles = nil },
            { key = "NightWeaver", name = "Night Weaver", image = "http://www.roblox.com/asset/?id=121362564666545", rarity = "Legendary", offset = nil, angles = nil },
            { key = "Ghoulfire", name = "Ghoulfire", image = "http://www.roblox.com/asset/?id=91749811015033", rarity = "Mythic", offset = { X = 1.26, Y = -1.5, Z = 0.2 }, angles = { X = 1.74532925199433, Y = 0, Z = 0 } },
            { key = "ArachnidArbalest", name = "Arachnid Arbalest", image = "http://www.roblox.com/asset/?id=97393679828956", rarity = "Ancient", offset = nil, angles = nil },
            { key = "IceSniper", name = "Ice Sniper", image = "http://www.roblox.com/asset/?id=122594000417695", rarity = "Mythic", offset = { X = 1.26, Y = -1.5, Z = 0.2 }, angles = { X = 1.74532925199433, Y = 0, Z = 0 } },
            { key = "ConfettiShotgun", name = "Confetti Shotgun", image = "http://www.roblox.com/asset/?id=105772287901266", rarity = "Mythic", offset = { X = 1.26, Y = -1.5, Z = 0.2 }, angles = { X = 1.74532925199433, Y = 0, Z = 0 } },
            { key = "FireworkPistol", name = "Firework Pistol", image = "http://www.roblox.com/asset/?id=93390265037267", rarity = "Mythic", offset = { X = 1.26, Y = -1.5, Z = 0.2 }, angles = { X = 1.74532925199433, Y = 0, Z = 0 } },
            { key = "SkyForgeCrossbow", name = "Sky Forge Crossbow", image = "http://www.roblox.com/asset/?id=114793453194576", rarity = "Mythic", offset = { X = 1.26, Y = -1.5, Z = 0.2 }, angles = { X = 1.74532925199433, Y = 0, Z = 0 } },
            { key = "ChristmasBall", name = "Christmas Ball", image = "http://www.roblox.com/asset/?id=92645458910978", rarity = "Rare", offset = nil, angles = nil },
            { key = "Whool", name = "Whool", image = "http://www.roblox.com/asset/?id=78455343539382", rarity = "Rare", offset = nil, angles = nil },
            { key = "GiftWrap", name = "Gift Wrap", image = "http://www.roblox.com/asset/?id=129737816883047", rarity = "Rare", offset = nil, angles = nil },
            { key = "GoldNight", name = "Gold Night", image = "http://www.roblox.com/asset/?id=123043138972493", rarity = "Rare", offset = nil, angles = nil },
            { key = "MidnightBlue", name = "Midnight Blue", image = "http://www.roblox.com/asset/?id=128624423716304", rarity = "Rare", offset = nil, angles = nil },
            { key = "SugarRush", name = "Sugar Rush", image = "http://www.roblox.com/asset/?id=129188226906521", rarity = "Rare", offset = nil, angles = nil },
            { key = "TreeWrap", name = "Tree Wrap", image = "http://www.roblox.com/asset/?id=125437563977165", rarity = "Rare", offset = nil, angles = nil },
            { key = "SnowGlobe", name = "Snow Globe", image = "http://www.roblox.com/asset/?id=139754109285232", rarity = "Mythic", offset = nil, angles = nil },
            { key = "PineGun", name = "Pine Gun", image = "http://www.roblox.com/asset/?id=126806712694003", rarity = "Ancient", offset = nil, angles = nil },
            { key = "FlatLine", name = "Flat Line", image = "http://www.roblox.com/asset/?id=129141431469754", rarity = "Legendary", offset = nil, angles = nil },
            { key = "4MyValentine", name = "4 My Valentine", image = "http://www.roblox.com/asset/?id=133925974783265", rarity = "Rare", offset = nil, angles = nil },
            { key = "Sweetheart", name = "Sweetheart", image = "http://www.roblox.com/asset/?id=78117826469703", rarity = "Uncommon", offset = nil, angles = nil },
            { key = "LoveBazooka", name = "Love Bazooka", image = "http://www.roblox.com/asset/?id=123854980565743", rarity = "Ancient", offset = nil, angles = nil },
            { key = "EternalBow", name = "Eternal Bow", image = "http://www.roblox.com/asset/?id=131803758926944", rarity = "Ancient", offset = nil, angles = nil },
            { key = "MadLove", name = "Mad Love", image = "http://www.roblox.com/asset/?id=114235536155189", rarity = "Ancient", offset = nil, angles = nil },
            { key = "GoldenEagle", name = "Golden Eagle", image = "http://www.roblox.com/asset/?id=88951725007954", rarity = "Ancient", offset = nil, angles = nil },
            { key = "CloverLeaf", name = "Clover Leaf", image = "http://www.roblox.com/asset/?id=110114259438794", rarity = "Uncommon", offset = nil, angles = nil },
            { key = "LuckyCharm", name = "Lucky Charm", image = "http://www.roblox.com/asset/?id=94781261823547", rarity = "Rare", offset = nil, angles = nil },
            { key = "Rainbowness", name = "Rainbowness", image = "http://www.roblox.com/asset/?id=133150088999327", rarity = "Legendary", offset = nil, angles = nil },
            { key = "LuckyShot", name = "Lucky Shot", image = "http://www.roblox.com/asset/?id=119606329474445", rarity = "Mythic", offset = nil, angles = nil },
            { key = "SpiritCrossbow", name = "Spirit Crossbow", image = "http://www.roblox.com/asset/?id=133335050487575", rarity = "Mythic", offset = nil, angles = nil },
            { key = "SpiritGun", name = "Spirit Gun", image = "http://www.roblox.com/asset/?id=110544912846992", rarity = "Mythic", offset = nil, angles = nil },
            { key = "WavySquiggle", name = "Wavy Squiggle", image = "http://www.roblox.com/asset/?id=137553594680771", rarity = "Uncommon", offset = nil, angles = nil },
            { key = "SpringStripes", name = "Spring Stripes", image = "http://www.roblox.com/asset/?id=140308995358080", rarity = "Rare", offset = nil, angles = nil },
            { key = "Eggpop", name = "Eggpop", image = "http://www.roblox.com/asset/?id=105255411342569", rarity = "Legendary", offset = nil, angles = nil },
            { key = "EggLauncher", name = "Egg Launcher", image = "http://www.roblox.com/asset/?id=75983381747834", rarity = "Mythic", offset = nil, angles = nil },
            { key = "DivineEmberlock", name = "Divine Emberlock", image = "http://www.roblox.com/asset/?id=104227305219622", rarity = "Ancient", offset = nil, angles = nil },
            { key = "DivineArcbow", name = "Divine Arcbow", image = "http://www.roblox.com/asset/?id=140574146294122", rarity = "Ancient", offset = nil, angles = nil },
            { key = "IceStorm", name = "Ice Storm", image = "http://www.roblox.com/asset/?id=112426367634294", rarity = "Uncommon", offset = nil, angles = nil },
            { key = "Zebra", name = "Zebra", image = "http://www.roblox.com/asset/?id=110712811785567", rarity = "Uncommon", offset = nil, angles = nil },
            { key = "Runes", name = "Runes", image = "http://www.roblox.com/asset/?id=117351744258318", rarity = "Uncommon", offset = nil, angles = nil },
            { key = "Beat", name = "Beat", image = "http://www.roblox.com/asset/?id=86191979281613", rarity = "Uncommon", offset = nil, angles = nil },
            { key = "Dot", name = "Dot", image = "http://www.roblox.com/asset/?id=91950296229536", rarity = "Uncommon", offset = nil, angles = nil },
            { key = "Cheesy", name = "Cheesy", image = "http://www.roblox.com/asset/?id=115976259178712", rarity = "Uncommon", offset = nil, angles = nil },
            { key = "Wavelink", name = "Wavelink", image = "http://www.roblox.com/asset/?id=96317709670412", rarity = "Uncommon", offset = nil, angles = nil },
            { key = "Diagonal", name = "Diagonal", image = "http://www.roblox.com/asset/?id=78580477711990", rarity = "Uncommon", offset = nil, angles = nil },
            { key = "Bubblegum", name = "Bubblegum", image = "http://www.roblox.com/asset/?id=132303758768349", rarity = "Common", offset = nil, angles = nil },
            { key = "Gradient", name = "Gradient", image = "http://www.roblox.com/asset/?id=85978300573020", rarity = "Uncommon", offset = nil, angles = nil },
            { key = "GreenGrass", name = "Green Grass", image = "http://www.roblox.com/asset/?id=101148978036092", rarity = "Rare", offset = nil, angles = nil },
            { key = "VivaMexico", name = "Viva Mexico", image = "http://www.roblox.com/asset/?id=117660601000431", rarity = "Legendary", offset = nil, angles = nil },
            { key = "SuperX", name = "Super X", image = "http://www.roblox.com/asset/?id=118057706776870", rarity = "Uncommon", offset = nil, angles = nil },
            { key = "DesertCamo", name = "Desert Camo", image = "http://www.roblox.com/asset/?id=72947629023810", rarity = "Common", offset = nil, angles = nil },
            { key = "EnergyCharged", name = "Energy Charged", image = "http://www.roblox.com/asset/?id=124240220889820", rarity = "Rare", offset = nil, angles = nil },
            { key = "Cow", name = "Cow", image = "http://www.roblox.com/asset/?id=109039963807839", rarity = "Legendary", offset = nil, angles = nil },
            { key = "OctoBow", name = "OctoBow", image = "http://www.roblox.com/asset/?id=116623833330679", rarity = "Mythic", offset = nil, angles = nil },
            { key = "DeathRose", name = "Death Rose", image = "http://www.roblox.com/asset/?id=103304281972714", rarity = "Mythic", offset = nil, angles = nil },
            { key = "ToxicAnchor", name = "Toxic Anchor", image = "http://www.roblox.com/asset/?id=133398063084400", rarity = "Mythic", offset = nil, angles = nil },
            { key = "Kaboom", name = "Kaboom", image = "http://www.roblox.com/asset/?id=132537078409097", rarity = "Mythic", offset = nil, angles = nil },
            { key = "Phoenix", name = "Phoenix", image = "http://www.roblox.com/asset/?id=104012256911404", rarity = "Uncommon", offset = nil, angles = nil },
            { key = "CakeBlower", name = "Cake Blower", image = "http://www.roblox.com/asset/?id=130601625685069", rarity = "Uncommon", offset = nil, angles = nil },
            { key = "PhaseGun", name = "Phase Gun", image = "http://www.roblox.com/asset/?id=110373231162388", rarity = "Uncommon", offset = nil, angles = nil },
            { key = "Voltage", name = "Voltage", image = "http://www.roblox.com/asset/?id=83571077048733", rarity = "Uncommon", offset = nil, angles = nil },
            { key = "ObsidianStrike", name = "Obsidian Strike", image = "http://www.roblox.com/asset/?id=127629961615454", rarity = "Uncommon", offset = nil, angles = nil },
            { key = "HexaGun", name = "Hexa Gun", image = "http://www.roblox.com/asset/?id=114363865509349", rarity = "Ancient", offset = nil, angles = nil },
            { key = "HexaSniper", name = "Hexa Sniper", image = "http://www.roblox.com/asset/?id=138864997076800", rarity = "Ancient", offset = nil, angles = nil },
            { key = "LovestruckGun", name = "Lovestruck Gun", image = "http://www.roblox.com/asset/?id=85585532755629", rarity = "Ancient", offset = { X = 1.2, Y = -1.6, Z = 0 }, angles = { X = 0, Y = -1.5707963267949, Z = -0.523598775598299 } },
            { key = "HeartseekerSniper", name = "Heartseeker Sniper", image = "http://www.roblox.com/asset/?id=127691168597163", rarity = "Ancient", offset = { X = 1.2, Y = -1.6, Z = 0 }, angles = { X = -1.0471975511966, Y = 0, Z = 3.14159265358979 } },
            { key = "DarkwingIron", name = "Darkwing Iron", image = "http://www.roblox.com/asset/?id=72185417315183", rarity = "Ancient", offset = { X = 1.2, Y = -1.6, Z = -0.2 }, angles = { X = 0, Y = 1.5707963267949, Z = 0.523598775598299 } },
            { key = "EverlightCannon", name = "Everlight Cannon", image = "http://www.roblox.com/asset/?id=103096237859344", rarity = "Ancient", offset = { X = 1.2, Y = -1.6, Z = -0.2 }, angles = { X = 0, Y = 1.5707963267949, Z = 0.523598775598299 } },
            { key = "ValkyrieSniper", name = "Valkyrie Sniper", image = "http://www.roblox.com/asset/?id=93816706114556", rarity = "Ancient", offset = { X = 1.2, Y = -1.6, Z = 0 }, angles = { X = -1.0471975511966, Y = 0, Z = 3.14159265358979 } },
            { key = "LimeJellyUzi", name = "Lime Jelly Uzi", image = "http://www.roblox.com/asset/?id=83126199023669", rarity = "Ancient", offset = { X = 1.2, Y = -1.6, Z = -0.2 }, angles = { X = -1.0471975511966, Y = 0, Z = 3.14159265358979 } },
            { key = "StrawberryJellyUzi", name = "Strawberry Jelly Uzi", image = "http://www.roblox.com/asset/?id=130976849830279", rarity = "Ancient", offset = { X = 1.2, Y = -1.6, Z = -0.2 }, angles = { X = -1.0471975511966, Y = 0, Z = 3.14159265358979 } },
            { key = "BlueberryJellyUzi", name = "Blueberry Jelly Uzi", image = "http://www.roblox.com/asset/?id=133580133263996", rarity = "Ancient", offset = { X = 1.2, Y = -1.6, Z = -0.2 }, angles = { X = -1.0471975511966, Y = 0, Z = 3.14159265358979 } },
            { key = "GrapeJellyUzi", name = "Grape Jelly Uzi", image = "http://www.roblox.com/asset/?id=119431765124547", rarity = "Ancient", offset = { X = 1.2, Y = -1.6, Z = -0.2 }, angles = { X = -1.0471975511966, Y = 0, Z = 3.14159265358979 } },
            { key = "PineappleGun", name = "Pineapple Gun", image = "http://www.roblox.com/asset/?id=117791197736557", rarity = "Rare", offset = { X = 1.2, Y = -1.7, Z = 1.5 }, angles = { X = -1.0471975511966, Y = 0, Z = 3.14159265358979 } },
            { key = "ShovelLauncher", name = "Shovel Launcher", image = "http://www.roblox.com/asset/?id=70388843566409", rarity = "Common", offset = { X = 1.2, Y = -1.8, Z = 1.6 }, angles = { X = -1.0471975511966, Y = 0, Z = 3.14159265358979 } },
            { key = "SharkLauncher", name = "Shark Launcher", image = "http://www.roblox.com/asset/?id=104862118287727", rarity = "Mythic", offset = { X = 1.2, Y = -2.1, Z = 1 }, angles = { X = -1.0471975511966, Y = 0, Z = 3.14159265358979 } },
            { key = "SealordRevolver", name = "Sea Lord Revolver", image = "http://www.roblox.com/asset/?id=71955967686945", rarity = "Ancient", offset = { X = 1.2, Y = -1.7, Z = 1.3 }, angles = { X = 2.0943951023932, Y = 0, Z = -1.5707963267949 } },
            { key = "DragonpetalSniper", name = "Dragonpetal Sniper", image = "http://www.roblox.com/asset/?id=85490568828292", rarity = "Ancient", offset = { X = 1.2, Y = -2.8, Z = 3.5 }, angles = { X = 0.436332312998582, Y = 1.5707963267949, Z = 0 } },
            { key = "DragonpetalOutlaw", name = "Dragonpetal Outlaw", image = "http://www.roblox.com/asset/?id=127151496114330", rarity = "Ancient", offset = { X = 1.2, Y = -2, Z = 1.75 }, angles = { X = 2.0943951023932, Y = 0, Z = -1.5707963267949 } },
            { key = "DuskveilIron", name = "Duskveil Iron", image = "http://www.roblox.com/asset/?id=83680220720049", rarity = "Ancient", offset = { X = 1.1, Y = -1.5, Z = 0.65 }, angles = { X = 2.0943951023932, Y = 3.14159265358979, Z = 0 } },
            { key = "BlingUzi", name = "Bling Uzi", image = "http://www.roblox.com/asset/?id=93431123525874", rarity = "Mythic", offset = { X = 1.2, Y = -1.8, Z = -0.7 }, angles = { X = 2.0943951023932, Y = 0, Z = -1.5707963267949 } },
            { key = "MatchaBobaGun", name = "Matcha Boba Blaster", image = "http://www.roblox.com/asset/?id=118621723100643", rarity = "Ancient", offset = { X = 1.2, Y = -1.6, Z = -0.2 }, angles = { X = 2.0943951023932, Y = 0, Z = -1.5707963267949 } },
            { key = "LightningStriker", name = "Lightning Striker", image = "http://www.roblox.com/asset/?id=75484886845346", rarity = "Ancient", offset = { X = 1.2, Y = -1.8, Z = 0 }, angles = { X = 2.26892802759263, Y = 0, Z = 1.5707963267949 } },
            { key = "BuzzsawShotty", name = "BuzzsawShotty", image = "http://www.roblox.com/asset/?id=138581019029295", rarity = "Common", offset = { X = 1.2, Y = -2.5, Z = 1.4 }, angles = { X = 2.44346095279206, Y = 3.14159265358979, Z = 0 } },
            { key = "ViridianWrath", name = "Viridian Wrath", image = "http://www.roblox.com/asset/?id=91806484387245", rarity = "Rare", offset = { X = 1.2, Y = -2.1, Z = 0.85 }, angles = { X = 2.44346095279206, Y = 3.14159265358979, Z = 0 } },
            { key = "AzuriteCrown", name = "Azurite Crown", image = "http://www.roblox.com/asset/?id=121671207611221", rarity = "Legendary", offset = { X = 1.2, Y = -2, Z = 1.1 }, angles = { X = 0.698131700797732, Y = 1.5707963267949, Z = 0 } },
            { key = "AetherisProtector", name = "Aetheris Protector", image = "http://www.roblox.com/asset/?id=73914336486869", rarity = "Ancient", offset = { X = 1.2, Y = -2, Z = 1.6 }, angles = { X = 2.0943951023932, Y = 3.14159265358979, Z = 0 } },
            { key = "DuskRoseArrow", name = "Dusk Rose Arrow", image = "http://www.roblox.com/asset/?id=115720298915709", rarity = "Ancient", offset = { X = 1.2, Y = -1.4, Z = -0.2 }, angles = { X = 0.698131700797732, Y = 0, Z = 0 } },
            { key = "RainbowPiercer", name = "Rainbow Piercer", image = "http://www.roblox.com/asset/?id=136560140309952", rarity = "Ancient", offset = { X = 1.2, Y = -1.9, Z = 1.2 }, angles = { X = 2.0943951023932, Y = 3.14159265358979, Z = 0 } },
            { key = "Lumenspark", name = "Lumenspark", image = "http://www.roblox.com/asset/?id=89526628141865", rarity = "Ancient", offset = { X = 1.2, Y = -1.9, Z = 1 }, angles = { X = 2.0943951023932, Y = 3.14159265358979, Z = 0 } },
            { key = "StardustPulse", name = "Stardust Pulse", image = "http://www.roblox.com/asset/?id=86280578742761", rarity = "Ancient", offset = { X = 1.2, Y = -1.8, Z = 1.45 }, angles = { X = 2.0943951023932, Y = 3.14159265358979, Z = 0 } },
            { key = "StardustEclipse", name = "Stardust Eclipse", image = "http://www.roblox.com/asset/?id=90520981518461", rarity = "Ancient", offset = { X = 1.2, Y = -3.25, Z = 4.25 }, angles = { X = 2.0943951023932, Y = 3.14159265358979, Z = 0 } },
            { key = "TideBreaker", name = "Tide Breaker", image = "http://www.roblox.com/asset/?id=72738790906842", rarity = "Ancient", offset = { X = 1.2, Y = -1.9, Z = 1 }, angles = { X = 2.0943951023932, Y = 3.14159265358979, Z = 0 } },
            { key = "KrakensGold", name = "Kraken's Gold", image = "http://www.roblox.com/asset/?id=79566910034868", rarity = "Legendary", offset = { X = 1.2, Y = -1.9, Z = 1 }, angles = { X = 0.698131700797732, Y = 0, Z = 0 } },
            { key = "CocoCannon", name = "Coco Cannon", image = "http://www.roblox.com/asset/?id=132302828170712", rarity = "Common", offset = { X = 1.2, Y = -2, Z = 1 }, angles = { X = 0.698131700797732, Y = 0, Z = 0 } },
            { key = "Hydroblaster", name = "Hydroblaster", image = "http://www.roblox.com/asset/?id=95834226445618", rarity = "Rare", offset = { X = 1.2, Y = -1.9, Z = 1 }, angles = { X = 2.0943951023932, Y = 3.14159265358979, Z = 0 } },
            { key = "Depthcharge", name = "Depthcharge ", image = "http://www.roblox.com/asset/?id=119287932276357", rarity = "Rare", offset = { X = 1.2, Y = -1.9, Z = 1 }, angles = { X = 2.0943951023932, Y = 3.14159265358979, Z = 0 } },
            { key = "Driftwood", name = "Driftwood", image = "http://www.roblox.com/asset/?id=114187829508339", rarity = "Common", offset = { X = 1.2, Y = -1.9, Z = 1 }, angles = { X = 2.0943951023932, Y = 3.14159265358979, Z = 0 } },
            { key = "DualWieldTemplate", name = "Dual Wield Template", image = "http://www.roblox.com/asset/?id=197518111", rarity = "Common", offset = nil, angles = nil },
            { key = "OctopusBow", name = "Octopus Bow", image = "http://www.roblox.com/asset/?id=106481261312617", rarity = "Mythic", offset = { X = 1.2, Y = -0.5, Z = 0.25 }, angles = { X = 0.349065850398866, Y = 3.14159265358979, Z = -1.5707963267949 } },
            { key = "GhostbringerCannon", name = "Ghostbringer Cannon", image = "http://www.roblox.com/asset/?id=131667888637162", rarity = "Ancient", offset = { X = 1.2, Y = -1.9, Z = 1.5 }, angles = { X = 2.0943951023932, Y = 3.14159265358979, Z = 0 } },
            { key = "SlimeGun", name = "Slime Gun", image = "http://www.roblox.com/asset/?id=88580129131116", rarity = "Common", offset = { X = 1.2, Y = -1.6, Z = 1 }, angles = { X = 2.0943951023932, Y = 1.5707963267949, Z = 0 } },
            { key = "IceSkullGun", name = "Ice Skull Gun", image = "http://www.roblox.com/asset/?id=120872900711730", rarity = "Mythic", offset = { X = 1.2, Y = -1.6, Z = 1.6 }, angles = { X = 2.0943951023932, Y = 0, Z = -1.5707963267949 } },
            { key = "DreamwalkerNova", name = "Dreamwalker Nova", image = "http://www.roblox.com/asset/?id=77383467227480", rarity = "Ancient", offset = { X = 1.2, Y = -1.5, Z = 1.1 }, angles = { X = 3.49065850398866, Y = 0, Z = -1.5707963267949 } },
            { key = "SpiderSting", name = "Spider Sting", image = "http://www.roblox.com/asset/?id=124652316265803", rarity = "Ancient", offset = { X = 1.2, Y = -2, Z = 1.1 }, angles = { X = -1.0471975511966, Y = 0, Z = 3.14159265358979 } },
        },
        knives = {
            { key = "DefaultKnife", name = "Default Knife", image = "http://www.roblox.com/asset/?id=584555920", rarity = "Common", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "1BKnife", name = "1B Knife", image = "http://www.roblox.com/asset/?id=97476443826895", rarity = "Legendary", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "AmethystEdge", name = "Amethyst Edge", image = "http://www.roblox.com/asset/?id=120950636773668", rarity = "Ancient", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "DemonspireSword", name = "Demonspire", image = "http://www.roblox.com/asset/?id=100496566959603", rarity = "Ancient", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "Ghoulshard", name = "Ghoulshard", image = "http://www.roblox.com/asset/?id=118682692173545", rarity = "Mythic", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "IceAxe", name = "Ice Axe", image = "http://www.roblox.com/asset/?id=104368213505092", rarity = "Mythic", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "IceSword", name = "Ice Sword", image = "http://www.roblox.com/asset/?id=90960994928459", rarity = "Mythic", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "EagleEyes", name = "EagleEyes", image = "http://www.roblox.com/asset/?id=77126614690645", rarity = "Ancient", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "MidnightKatana", name = "Midnight Katana", image = "http://www.roblox.com/asset/?id=116693692581695", rarity = "Mythic", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "DarkScythe", name = "Dark Scythe", image = "http://www.roblox.com/asset/?id=133209644537171", rarity = "Mythic", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "CortexCandy", name = "Cortex Candy", image = "http://www.roblox.com/asset/?id=133280740712331", rarity = "Common", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "BooBreaker", name = "Boo Breaker", image = "http://www.roblox.com/asset/?id=131866595747706", rarity = "Common", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "CobwebCutter", name = "Cobweb Cutter", image = "http://www.roblox.com/asset/?id=119557918954664", rarity = "Common", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "RestInPieces", name = "Rest in Pieces", image = "http://www.roblox.com/asset/?id=103760443268322", rarity = "Ancient", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "BlueSnow", name = "Blue Snow", image = "http://www.roblox.com/asset/?id=94870478096869", rarity = "Uncommon", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "ChristmasTree", name = "Christmas Tree", image = "http://www.roblox.com/asset/?id=132681435524687", rarity = "Uncommon", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "CubicSweater", name = "Cubic Sweater", image = "http://www.roblox.com/asset/?id=86893657177979", rarity = "Uncommon", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "Sweater", name = "Cubic Sweater", image = "http://www.roblox.com/asset/?id=86893657177979", rarity = "Uncommon", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "Navidad", name = "Navidad", image = "http://www.roblox.com/asset/?id=79938333610553", rarity = "Legendary", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "Ornament", name = "Ornament", image = "http://www.roblox.com/asset/?id=73541946127182", rarity = "Uncommon", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "RedDot", name = "Red Dot", image = "http://www.roblox.com/asset/?id=138989564725200", rarity = "Uncommon", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "ShootingStar", name = "Shooting Star", image = "http://www.roblox.com/asset/?id=119147010387101", rarity = "Uncommon", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "SweetMadness", name = "Sweet Madness", image = "http://www.roblox.com/asset/?id=140588907821860", rarity = "Mythic", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "ChristmasEdge", name = "Christmas Edge", image = "http://www.roblox.com/asset/?id=81293593588445", rarity = "Mythic", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "SantasBlade", name = "Santa's Blade", image = "http://www.roblox.com/asset/?id=132055906814369", rarity = "Ancient", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "RosesAreRed", name = "Roses Are Red", image = "http://www.roblox.com/asset/?id=80509197077748", rarity = "Legendary", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "LoveLetter", name = "Love Letter", image = "http://www.roblox.com/asset/?id=118920726604773", rarity = "Mythic", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "DevotedPassion", name = "Devoted Passion", image = "http://www.roblox.com/asset/?id=70935009190165", rarity = "Uncommon", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "BrokenHeart", name = "Broken Heart", image = "http://www.roblox.com/asset/?id=122891894979116", rarity = "Ancient", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "CupidKarambit", name = "Cupid Karambit", image = "http://www.roblox.com/asset/?id=136535085232296", rarity = "Ancient", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "TheFallen", name = "The Fallen", image = "http://www.roblox.com/asset/?id=127421118873088", rarity = "Mythic", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "OceanBane", name = "Ocean Bane", image = "http://www.roblox.com/asset/?id=127638297236837", rarity = "Ancient", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "NeonClover", name = "Neon Clover", image = "http://www.roblox.com/asset/?id=103071601087798", rarity = "Rare", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "GreenLine", name = "Green Line", image = "http://www.roblox.com/asset/?id=114873695421413", rarity = "Uncommon", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "GoldenLuck", name = "Golden Luck", image = "http://www.roblox.com/asset/?id=122271385174679", rarity = "Legendary", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "LuckySword", name = "Lucky Sword", image = "http://www.roblox.com/asset/?id=90487477596941", rarity = "Mythic", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "LuckyScythe", name = "Lucky Scythe", image = "http://www.roblox.com/asset/?id=89243071465707", rarity = "Ancient", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "SpiritSword", name = "Spirit Sword", image = "http://www.roblox.com/asset/?id=93327101855508", rarity = "Mythic", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "ThePurrinator", name = "The Purrinator", image = "http://www.roblox.com/asset/?id=140458890829421", rarity = "Mythic", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "PolkaDots", name = "Polka Dots", image = "http://www.roblox.com/asset/?id=134892697796823", rarity = "Uncommon", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "Eggies", name = "Eggies", image = "http://www.roblox.com/asset/?id=139925475567086", rarity = "Rare", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "Bunnies", name = "Bunnies", image = "http://www.roblox.com/asset/?id=90237760574710", rarity = "Legendary", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "LordEgg", name = "Lord Egg", image = "http://www.roblox.com/asset/?id=130777294949009", rarity = "Mythic", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "BunnyBasher", name = "Bunny Basher", image = "http://www.roblox.com/asset/?id=132152023202618", rarity = "Ancient", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "DivineBlade", name = "Divine Blade", image = "http://www.roblox.com/asset/?id=117828637308876", rarity = "Ancient", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "Frogus", name = "Frogus", image = "http://www.roblox.com/asset/?id=87817527111908", rarity = "Mythic", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "SnowNight", name = "Snow Night", image = "http://www.roblox.com/asset/?id=123459635578606", rarity = "Legendary", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "TitaniumTiger", name = "Titanium Tiger", image = "http://www.roblox.com/asset/?id=126486173199079", rarity = "Legendary", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "ImpactGlitch", name = "Impact Glitch", image = "http://www.roblox.com/asset/?id=125327101764779", rarity = "Legendary", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "RedDiamond", name = "Red Diamond", image = "http://www.roblox.com/asset/?id=87260294707665", rarity = "Legendary", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "BlueKatana", name = "Blue Katana", image = "http://www.roblox.com/asset/?id=101861427336340", rarity = "Legendary", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "Flowery", name = "Flowery", image = "http://www.roblox.com/asset/?id=85504769430906", rarity = "Legendary", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "TreasureMap", name = "Treasure Map", image = "http://www.roblox.com/asset/?id=81756638609345", rarity = "Legendary", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "NeonSparkle", name = "Neon Sparkle", image = "http://www.roblox.com/asset/?id=111899404557799", rarity = "Legendary", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "SunsetChecker", name = "Sunset Checker", image = "http://www.roblox.com/asset/?id=129186636952119", rarity = "Common", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "NightFade", name = "Night Fade", image = "http://www.roblox.com/asset/?id=102094892871516", rarity = "Uncommon", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "LibertyLine", name = "Liberty Line", image = "http://www.roblox.com/asset/?id=94232147351542", rarity = "Rare", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "CincoDeMayo", name = "Cinco De Mayo", image = "http://www.roblox.com/asset/?id=108958791838984", rarity = "Legendary", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "Spicy", name = "Spicy", image = "http://www.roblox.com/asset/?id=102649623266371", rarity = "Rare", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "Carrot", name = "Carrot", image = "http://www.roblox.com/asset/?id=116199899163543", rarity = "Legendary", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "SummerWave", name = "Summer Wave", image = "http://www.roblox.com/asset/?id=126085241530018", rarity = "Common", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "Tartan", name = "Tartan", image = "http://www.roblox.com/asset/?id=75808376343768", rarity = "Uncommon", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "GearPunk", name = "GearPunk", image = "http://www.roblox.com/asset/?id=81693040226287", rarity = "Legendary", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "SilentRegret", name = "SilentRegret", image = "http://www.roblox.com/asset/?id=93152090262217", rarity = "Legendary", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "PharaohEdge", name = "PharaohEdge", image = "http://www.roblox.com/asset/?id=70875090507674", rarity = "Legendary", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "AtomicSlicer", name = "AtomicSlicer", image = "http://www.roblox.com/asset/?id=100205403285327", rarity = "Legendary", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "StoneBreaker", name = "StoneBreaker", image = "http://www.roblox.com/asset/?id=130227827749169", rarity = "Mythic", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "DarkEye", name = "DarkEye", image = "http://www.roblox.com/asset/?id=115180246750247", rarity = "Ancient", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "JusticeEdge", name = "JusticeEdge", image = "http://www.roblox.com/asset/?id=84462767722337", rarity = "Mythic", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "TrustScythe", name = "TrustScythe", image = "http://www.roblox.com/asset/?id=83968983707748", rarity = "Ancient", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "HexaAxe", name = "Hexa Axe", image = "http://www.roblox.com/asset/?id=131673377199603", rarity = "Ancient", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "LovestruckKnife", name = "Lovestruck Knife", image = "http://www.roblox.com/asset/?id=126818723316588", rarity = "Ancient", offset = { X = -1.2, Y = -1.4, Z = 0.2 }, angles = { X = -1.13446401379631, Y = -1.5707963267949, Z = -3.14159265358979 } },
            { key = "HeartseekerBlade", name = "Heartseeker Blade", image = "http://www.roblox.com/asset/?id=108325010455056", rarity = "Ancient", offset = { X = -1.2, Y = -1.4, Z = 0.2 }, angles = { X = -1.13446401379631, Y = -1.5707963267949, Z = -3.14159265358979 } },
            { key = "DarkwingDagger", name = "Darkwing Dagger", image = "http://www.roblox.com/asset/?id=74831984998275", rarity = "Ancient", offset = { X = -1.2, Y = -1.4, Z = 0.2 }, angles = { X = -1.13446401379631, Y = -1.5707963267949, Z = -3.14159265358979 } },
            { key = "EverlightEdge", name = "Everlight Edge", image = "http://www.roblox.com/asset/?id=91964057821150", rarity = "Ancient", offset = { X = -1.2, Y = -1.4, Z = 0.2 }, angles = { X = -1.13446401379631, Y = -1.5707963267949, Z = -3.14159265358979 } },
            { key = "ValkyrieKnife", name = "Valkyrie Knife", image = "http://www.roblox.com/asset/?id=125087837812163", rarity = "Ancient", offset = { X = -1.2, Y = -1.4, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "LimeJellyAxe", name = "Lime Jelly Axe", image = "http://www.roblox.com/asset/?id=102843095220382", rarity = "Ancient", offset = { X = -1.2, Y = -1.4, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "StrawberryJellyAxe", name = "Strawberry Jelly Axe", image = "http://www.roblox.com/asset/?id=131279450152560", rarity = "Ancient", offset = { X = -1.2, Y = -1.4, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "BlueberryJellyAxe", name = "Blueberry Jelly Axe", image = "http://www.roblox.com/asset/?id=83249223554860", rarity = "Ancient", offset = { X = -1.2, Y = -1.4, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "GrapeJellyAxe", name = "Grape Jelly Axe", image = "http://www.roblox.com/asset/?id=113747702078065", rarity = "Ancient", offset = { X = -1.2, Y = -1.4, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "BandedDagger", name = "Banded Dagger", image = "http://www.roblox.com/asset/?id=135931359432760", rarity = "Legendary", offset = { X = -1.2, Y = -1.4, Z = 0.2 }, angles = { X = -1.13446401379631, Y = -1.5707963267949, Z = -3.14159265358979 } },
            { key = "Popsicle", name = "Popsicle", image = "http://www.roblox.com/asset/?id=109225111915319", rarity = "Legendary", offset = { X = -1.2, Y = -1, Z = -0.5 }, angles = { X = 2.0943951023932, Y = 0, Z = 0 } },
            { key = "SunsetBlade", name = "Sunset Blade", image = "http://www.roblox.com/asset/?id=82401180230677", rarity = "Rare", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = 3.66519142918809, Y = 0, Z = 0 } },
            { key = "LeafKnife", name = "Leaf Knife", image = "http://www.roblox.com/asset/?id=109631618859513", rarity = "Rare", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = 1.91986217719376, Y = 1.5707963267949, Z = 0 } },
            { key = "SummerSandal", name = "Summer Sandal", image = "http://www.roblox.com/asset/?id=110182100627740", rarity = "Legendary", offset = { X = -1.25, Y = -1.3, Z = 0.2 }, angles = { X = 3.66519142918809, Y = 0, Z = -1.5707963267949 } },
            { key = "GardeningTrowel", name = "Gardening Trowel", image = "http://www.roblox.com/asset/?id=83014041662708", rarity = "Common", offset = { X = -1.15, Y = -1.3, Z = 0.2 }, angles = { X = -2.44346095279206, Y = 0, Z = -1.5707963267949 } },
            { key = "PineappleKnife", name = "Pineapple Knife", image = "http://www.roblox.com/asset/?id=82853211390897", rarity = "Common", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = 3.66519142918809, Y = 0, Z = 0 } },
            { key = "ShovelEdge", name = "Shovel Edge", image = "http://www.roblox.com/asset/?id=110356719035315", rarity = "Common", offset = { X = -1.2, Y = -1.3, Z = 0.2 }, angles = { X = -4.01425727958696, Y = 0, Z = 0 } },
            { key = "SealordTrident", name = "Sea Lord Trident", image = "http://www.roblox.com/asset/?id=128290884273763", rarity = "Ancient", offset = { X = -1.2, Y = -1.4, Z = 0.2 }, angles = { X = -1.13446401379631, Y = -1.5707963267949, Z = -3.14159265358979 } },
            { key = "DuskveilDagger", name = "Duskveil Dagger", image = "http://www.roblox.com/asset/?id=108663922848610", rarity = "Ancient", offset = { X = -1.2, Y = -1.4, Z = 0.2 }, angles = { X = -1.13446401379631, Y = -1.5707963267949, Z = -3.14159265358979 } },
            { key = "DragonpetalBlade", name = "Dragonpetal Blade", image = "http://www.roblox.com/asset/?id=107815570610664", rarity = "Ancient", offset = { X = -1.2, Y = -1.4, Z = 0.2 }, angles = { X = -1.13446401379631, Y = 1.5707963267949, Z = -3.14159265358979 } },
            { key = "BlingSword", name = "Bling Sword", image = "http://www.roblox.com/asset/?id=111660507643113", rarity = "Mythic", offset = { X = -1.2, Y = -1, Z = -0.8 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "MatchaBobaKnife", name = "Matcha Boba Blade", image = "http://www.roblox.com/asset/?id=131562913225164", rarity = "Ancient", offset = { X = -1.2, Y = -1, Z = -0.8 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "LightningBolt", name = "Lightning Bolt", image = "http://www.roblox.com/asset/?id=99021663251552", rarity = "Ancient", offset = { X = -1.2, Y = -1, Z = -0.6 }, angles = { X = -2.61799387799149, Y = 0, Z = 1.5707963267949 } },
            { key = "SteelcoreDagger", name = "Steelcore Dagger", image = "http://www.roblox.com/asset/?id=105510498306117", rarity = "Common", offset = { X = -1.2, Y = -1.5, Z = 0.1 }, angles = { X = -2.35619449019234, Y = 0, Z = 1.5707963267949 } },
            { key = "AureliaHammer", name = "Aurelia Hammer", image = "http://www.roblox.com/asset/?id=107422418776659", rarity = "Rare", offset = { X = -1.2, Y = -1.5, Z = 0.1 }, angles = { X = -2.70526034059121, Y = 0, Z = 1.5707963267949 } },
            { key = "RedcliffEye", name = "Redcliff Eye", image = "http://www.roblox.com/asset/?id=90984794622819", rarity = "Legendary", offset = { X = -1.2, Y = -1.5, Z = 0.1 }, angles = { X = 0.436332312998582, Y = 3.14159265358979, Z = 1.5707963267949 } },
            { key = "Soulthorn", name = "Soulthorn", image = "http://www.roblox.com/asset/?id=94015185344988", rarity = "Mythic", offset = { X = -1.2, Y = -1.5, Z = 0.1 }, angles = { X = 2.0943951023932, Y = 0, Z = 0 } },
            { key = "GrimjawScythe", name = "Grimjaw Scythe", image = "http://www.roblox.com/asset/?id=109310029301133", rarity = "Mythic", offset = { X = -1, Y = -1.2, Z = 0.3 }, angles = { X = 3.31612557878923, Y = 0, Z = 1.5707963267949 } },
            { key = "AetherisBattleaxe", name = "Aetheris Battleaxe", image = "http://www.roblox.com/asset/?id=85795743639022", rarity = "Ancient", offset = { X = -1.2, Y = -1.7, Z = -0.3 }, angles = { X = 2.0943951023932, Y = 0, Z = 0 } },
            { key = "DuskRoseReaper", name = "Dusk Rose Reaper", image = "http://www.roblox.com/asset/?id=90782751388266", rarity = "Ancient", offset = { X = -1, Y = -1.7, Z = 0.1 }, angles = { X = -1.48352986419518, Y = 0, Z = 3.14159265358979 } },
            { key = "RainbowFang", name = "Rainbow Fang", image = "http://www.roblox.com/asset/?id=77127783694353", rarity = "Ancient", offset = { X = -1.1, Y = -0.9, Z = -0.6 }, angles = { X = -1.0471975511966, Y = 0, Z = 3.14159265358979 } },
            { key = "Lumenbloom", name = "Lumenbloom", image = "http://www.roblox.com/asset/?id=100624489590707", rarity = "Ancient", offset = { X = -1.1, Y = -1.6, Z = 0.75 }, angles = { X = -1.0471975511966, Y = 0, Z = 3.14159265358979 } },
            { key = "StardustFang", name = "Stardust Fang", image = "http://www.roblox.com/asset/?id=97573096170508", rarity = "Ancient", offset = { X = -1.1, Y = -1.6, Z = 0.75 }, angles = { X = -1.0471975511966, Y = 0, Z = 3.14159265358979 } },
            { key = "TideCleaver", name = "Tide Cleaver", image = "http://www.roblox.com/asset/?id=119843941989117", rarity = "Ancient", offset = { X = -1.1, Y = -1.4, Z = 0 }, angles = { X = -1.0471975511966, Y = 0, Z = 3.14159265358979 } },
            { key = "StarKnife", name = "Star Knife", image = "http://www.roblox.com/asset/?id=133893578276151", rarity = "Common", offset = { X = -1.1, Y = -1.6, Z = 0.75 }, angles = { X = -1.0471975511966, Y = 0, Z = 3.14159265358979 } },
            { key = "AnchorKnife", name = "Anchor Knife", image = "http://www.roblox.com/asset/?id=119729135176281", rarity = "Rare", offset = { X = -1.1, Y = -1.5, Z = 0.25 }, angles = { X = -1.0471975511966, Y = 0, Z = 0 } },
            { key = "EyeDagger", name = "Eye Dagger", image = "http://www.roblox.com/asset/?id=108358661995915", rarity = "Common", offset = { X = -1.1, Y = -1.6, Z = 0.75 }, angles = { X = -1.0471975511966, Y = 0, Z = 3.14159265358979 } },
            { key = "MoonpearlEdge", name = "Moonpearl Edge", image = "http://www.roblox.com/asset/?id=88485081960060", rarity = "Legendary", offset = { X = -1.1, Y = -1.6, Z = 0.75 }, angles = { X = -1.0471975511966, Y = 0, Z = 3.14159265358979 } },
            { key = "Nautilus", name = "Nautilus", image = "http://www.roblox.com/asset/?id=76275593011922", rarity = "Mythic", offset = { X = -1.1, Y = -1.6, Z = 0.5 }, angles = { X = -1.0471975511966, Y = 0, Z = 3.14159265358979 } },
            { key = "AurelionSword", name = "Aurelion Sword", image = "http://www.roblox.com/asset/?id=88448213715773", rarity = "Mythic", offset = { X = -1.1, Y = -1.6, Z = 0.75 }, angles = { X = -1.0471975511966, Y = 0, Z = 3.14159265358979 } },
            { key = "Frostwake", name = "Frostwake", image = "http://www.roblox.com/asset/?id=127154738206860", rarity = "Mythic", offset = { X = -1.1, Y = -1.6, Z = 0.75 }, angles = { X = -1.0471975511966, Y = 0, Z = 3.14159265358979 } },
            { key = "FrostseerAxe", name = "Frostseer Axe", image = "http://www.roblox.com/asset/?id=123354327029772", rarity = "Mythic", offset = { X = -1.1, Y = -1.3, Z = 0.25 }, angles = { X = 1.91986217719376, Y = 0, Z = 0 } },
            { key = "Voidgaze", name = "Voidgaze", image = "http://www.roblox.com/asset/?id=79803711509240", rarity = "Mythic", offset = { X = -1.1, Y = -1.3, Z = 0.3 }, angles = { X = -2.61799387799149, Y = 0, Z = 1.5707963267949 } },
            { key = "OverseerDagger", name = "Overseer Dagger", image = "http://www.roblox.com/asset/?id=109252270095251", rarity = "Mythic", offset = { X = -1.1, Y = -1.4, Z = 0.5 }, angles = { X = 0, Y = -1.5707963267949, Z = -2.0943951023932 } },
            { key = "SkullHammer", name = "Skull Hammer", image = "http://www.roblox.com/asset/?id=80209341076964", rarity = "Mythic", offset = { X = -1.1, Y = -1.4, Z = 0.5 }, angles = { X = 2.0943951023932, Y = 0, Z = 0 } },
            { key = "OverseerHarbinger", name = "Overseer\\226\\128\\153s Harbinger", image = "http://www.roblox.com/asset/?id=125564663031019", rarity = "Mythic", offset = { X = -1.1, Y = -1.4, Z = 0.5 }, angles = { X = 2.0943951023932, Y = 0, Z = 0 } },
            { key = "DeadlyMoth", name = "Deadly Moth", image = "http://www.roblox.com/asset/?id=116198538364298", rarity = "Mythic", offset = { X = -1.1, Y = -1.4, Z = 0.5 }, angles = { X = 3.49065850398866, Y = 0, Z = 0 } },
            { key = "Rimefang", name = "Rimefang", image = "http://www.roblox.com/asset/?id=73359454996170", rarity = "Mythic", offset = { X = -1.05, Y = -1.698, Z = 1.173 }, angles = { X = 2.00712863979348, Y = -1.5707963267949, Z = 0 } },
            { key = "HalloweenAxe", name = "Twilight Reign", image = "http://www.roblox.com/asset/?id=135515433801829", rarity = "Ancient", offset = { X = -1.2, Y = -1.4, Z = 0.5 }, angles = { X = 0, Y = -1.5707963267949, Z = -2.0943951023932 } },
            { key = "GiftoftheEye", name = "Gift of the Eye", image = "http://www.roblox.com/asset/?id=120730606847766", rarity = "Ancient", offset = { X = -1.2, Y = -1.4, Z = 0.5 }, angles = { X = 0, Y = -1.5707963267949, Z = -2.0943951023932 } },
            { key = "PatriotKnife", name = "Patriot Knife", image = "http://www.roblox.com/asset/?id=82860831257303", rarity = "Legendary", offset = { X = -1.1, Y = -1.6, Z = 0.75 }, angles = { X = -1.0471975511966, Y = 0, Z = 3.14159265358979 } },
            { key = "GhostbringerBlade", name = "Ghostbringer Blade", image = "http://www.roblox.com/asset/?id=73832417806884", rarity = "Ancient", offset = { X = -1.1, Y = -1.3, Z = 0.25 }, angles = { X = -1.0471975511966, Y = 0, Z = 3.14159265358979 } },
            { key = "DreamwalkerEclipse", name = "Dreamwalker Eclipse", image = "http://www.roblox.com/asset/?id=73492027581273", rarity = "Ancient", offset = { X = -1.1, Y = -1.9, Z = 0.75 }, angles = { X = 2.0943951023932, Y = 0, Z = 0 } },
            { key = "SpiderFang", name = "Spider Fang", image = "http://www.roblox.com/asset/?id=129550443806933", rarity = "Ancient", offset = { X = -1.1, Y = -1.9, Z = 0.75 }, angles = { X = 2.0943951023932, Y = 0, Z = 0 } },
            { key = "CatSword", name = "Cat Sword", image = "http://www.roblox.com/asset/?id=86977821465270", rarity = "Legendary", offset = { X = -1.1, Y = -1.4, Z = 0.25 }, angles = { X = -1.0471975511966, Y = 0, Z = 3.14159265358979 } },
            { key = "LightbringerDagger", name = "Lightbringer Dagger", image = "http://www.roblox.com/asset/?id=125311377784939", rarity = "Common", offset = { X = -1.1, Y = -1.5, Z = 0.25 }, angles = { X = 2.0943951023932, Y = 0, Z = 0 } },
            { key = "Ironclad", name = "Ironclad", image = "http://www.roblox.com/asset/?id=82509570935830", rarity = "Common", offset = { X = -1.1, Y = -1.5, Z = 0.25 }, angles = { X = 2.0943951023932, Y = 0, Z = 0 } },
            { key = "Wildwood", name = "Wildwood", image = "http://www.roblox.com/asset/?id=82020955900016", rarity = "Rare", offset = { X = -1.1, Y = -1.4, Z = 0 }, angles = { X = 2.0943951023932, Y = 0, Z = 0 } },
            { key = "Rockbreaker", name = "Rockbreaker", image = "http://www.roblox.com/asset/?id=106019587033224", rarity = "Rare", offset = { X = -1.1, Y = -1.4, Z = 0.1 }, angles = { X = 1.91986217719376, Y = 0, Z = 0 } },
            { key = "ViridianVow", name = "Viridian Vow", image = "http://www.roblox.com/asset/?id=81153021101132", rarity = "Legendary", offset = { X = -1.1, Y = -1.5, Z = 0.25 }, angles = { X = 2.0943951023932, Y = 0, Z = 0 } },
            { key = "Petalreaper", name = "Petalreaper", image = "http://www.roblox.com/asset/?id=105678500062041", rarity = "Legendary", offset = { X = -1.15, Y = -1.6, Z = 0.5 }, angles = { X = 5.14872129338327, Y = 0, Z = 3.14159265358979 } },
            { key = "LightbringerStaff", name = "Lightbringer's Staff", image = "http://www.roblox.com/asset/?id=83512152877171", rarity = "Legendary", offset = { X = -1.1, Y = -1.5, Z = 0.5 }, angles = { X = 1.91986217719376, Y = 0, Z = 0 } },
            { key = "SoulwingAxe", name = "Soulwing Axe", image = "http://www.roblox.com/asset/?id=110030941223881", rarity = "Ancient", offset = { X = -1.1, Y = -1.4, Z = 0.25 }, angles = { X = 1.91986217719376, Y = 0, Z = 0 } },
            { key = "Soulstealer", name = "Soulstealer", image = "http://www.roblox.com/asset/?id=132778027375857", rarity = "Mythic", offset = { X = -1.1, Y = -1.5, Z = 0.75 }, angles = { X = 2.0943951023932, Y = 1.5707963267949, Z = 0 } },
            { key = "VoidreaverAxe", name = "Voidreaver Axe", image = "http://www.roblox.com/asset/?id=71316662414646", rarity = "Ancient", offset = { X = -1.1, Y = -1.3, Z = 0.5 }, angles = { X = 2.0943951023932, Y = 0, Z = 0 } },
            { key = "InfernalSword", name = "Infernal Sword", image = "http://www.roblox.com/asset/?id=111399194006530", rarity = "Ancient", offset = { X = -1.1, Y = -1.3, Z = 0.5 }, angles = { X = 2.0943951023932, Y = 0, Z = 0 } },
            { key = "KitsuneBlade", name = "Kitsune Blade", image = "http://www.roblox.com/asset/?id=100121132991335", rarity = "Ancient", offset = { X = -1.1, Y = -1.6, Z = 0.75 }, angles = { X = 0, Y = 1.5707963267949, Z = 2.0943951023932 } },
            { key = "1x1x1x1Blade", name = "1x1x1x1 Blade", image = "http://www.roblox.com/asset/?id=73681882274500", rarity = "Ancient", offset = { X = -1.1, Y = -1.6, Z = 0.5 }, angles = { X = 2.0943951023932, Y = 0, Z = 0 } },
            { key = "SteelcrestBlade", name = "Steelcrest Blade", image = "http://www.roblox.com/asset/?id=115389249530089", rarity = "Common", offset = { X = -1.1, Y = -1.5, Z = 0.4 }, angles = { X = -2.61799387799149, Y = 0, Z = 1.5707963267949 } },
            { key = "Acidbite", name = "Acidbite", image = "http://www.roblox.com/asset/?id=113009908533929", rarity = "Mythic", offset = { X = -1.1, Y = -1.5, Z = 0.4 }, angles = { X = 0, Y = 1.5707963267949, Z = 2.0943951023932 } },
            { key = "Nightfang", name = "Nightfang", image = "http://www.roblox.com/asset/?id=85292969190490", rarity = "Ancient", offset = { X = -1.1, Y = -2.3, Z = 1.1 }, angles = { X = 0, Y = 1.5707963267949, Z = 2.0943951023932 } },
            { key = "ShadowcrestPiercer", name = "Shadowcrest Piercer", image = "http://www.roblox.com/asset/?id=139377894444635", rarity = "Ancient", offset = { X = -1.1, Y = -1.4, Z = 1 }, angles = { X = 0, Y = 1.5707963267949, Z = 1.91986217719376 } },
            { key = "HeartbreakerRequiem", name = "Heartbreaker's Requiem", image = "http://www.roblox.com/asset/?id=138277660522084", rarity = "Ancient", offset = { X = -1.2, Y = -1.4, Z = 0.6 }, angles = { X = 1.91986217719376, Y = 3.14159265358979, Z = 0 } },
            { key = "Cratercore", name = "Cratercore", image = "http://www.roblox.com/asset/?id=125879762212175", rarity = "Common", offset = { X = -1.1, Y = -1.4, Z = 1 }, angles = { X = 0, Y = 1.5707963267949, Z = 1.91986217719376 } },
            { key = "StarShard", name = "Star Shard", image = "http://www.roblox.com/asset/?id=75912440879858", rarity = "Common", offset = { X = -1.1, Y = -1.4, Z = 0.5 }, angles = { X = 2.0943951023932, Y = 0, Z = 0 } },
            { key = "Launchbreaker", name = "Launchbreaker ", image = "http://www.roblox.com/asset/?id=114116989219596", rarity = "Rare", offset = { X = -1.1, Y = -1.4, Z = 0.5 }, angles = { X = 0, Y = 1.5707963267949, Z = 1.91986217719376 } },
            { key = "GalaxyFederation", name = "Galaxy Federation", image = "http://www.roblox.com/asset/?id=92355854465234", rarity = "Legendary", offset = { X = -1.1, Y = -1.4, Z = 0.5 }, angles = { X = 2.0943951023932, Y = 0, Z = 0 } },
            { key = "AstralCrescent", name = "Astral Crescent", image = "http://www.roblox.com/asset/?id=70398928489343", rarity = "Mythic", offset = { X = -1.15, Y = -2.1, Z = 3.2 }, angles = { X = 1.91986217719376, Y = 3.14159265358979, Z = 0 } },
            { key = "Starweaver", name = "Starweaver", image = "http://www.roblox.com/asset/?id=118398267497346", rarity = "Mythic", offset = { X = -1.1, Y = -1.5, Z = 0.8 }, angles = { X = 1.91986217719376, Y = 0, Z = 0 } },
            { key = "SolarisReaper", name = "Solaris Reaper", image = "http://www.roblox.com/asset/?id=136291246386444", rarity = "Ancient", offset = { X = -1.05, Y = -1.8, Z = 0.3 }, angles = { X = 1.91986217719376, Y = 3.14159265358979, Z = 0 } },
            { key = "VenomFang", name = "Venom Fang", image = "http://www.roblox.com/asset/?id=75301470172271", rarity = "Ancient", offset = { X = -1.1, Y = -1.6, Z = 1 }, angles = { X = 1.91986217719376, Y = 0, Z = 0 } },
            { key = "BloodmoonTalon", name = "Bloodmoon Talon", image = "http://www.roblox.com/asset/?id=130176226929018", rarity = "Ancient", offset = { X = -1.1, Y = -1.65, Z = 0.8 }, angles = { X = 2.0943951023932, Y = 0, Z = 0 } },
            { key = "BlackheartBlade", name = "Blackheart Blade", image = "http://www.roblox.com/asset/?id=102163038276631", rarity = "Ancient", offset = { X = -1.1, Y = -1.5, Z = 0.3 }, angles = { X = 2.0943951023932, Y = 3.14159265358979, Z = 0 } },
            { key = "PharaohJudgment", name = "Pharaoh\\226\\128\\153s Judgment", image = "http://www.roblox.com/asset/?id=79520503500627", rarity = "Legendary", offset = { X = -1.1, Y = -1.5, Z = 0.4 }, angles = { X = 0, Y = 1.5707963267949, Z = 2.0943951023932 } },
            { key = "Dreamwave", name = "Dreamwave", image = "http://www.roblox.com/asset/?id=102163950150422", rarity = "Legendary", offset = { X = -1.1, Y = -1.65, Z = 0.8 }, angles = { X = 2.0943951023932, Y = 0, Z = 0 } },
            { key = "Deathwave", name = "Deathwave", image = "http://www.roblox.com/asset/?id=99094153255189", rarity = "Ancient", offset = { X = -1.1, Y = -1.4, Z = 0.4 }, angles = { X = 2.0943951023932, Y = 0, Z = 1.5707963267949 } },
            { key = "TyrantFang", name = "Tyrant's Fang", image = "http://www.roblox.com/asset/?id=133845738248874", rarity = "Ancient", offset = { X = -1.1, Y = -1.65, Z = 0.8 }, angles = { X = 2.0943951023932, Y = 0, Z = 0 } },
            { key = "StarwingMonarch", name = "Starwing Monarch", image = "http://www.roblox.com/asset/?id=118999138541436", rarity = "Ancient", offset = { X = -1.1, Y = -1.7, Z = 0.75 }, angles = { X = 2.0943951023932, Y = 3.14159265358979, Z = 0 } },
            { key = "PhoenixFirewing", name = "Phoenix Firewing", image = "http://www.roblox.com/asset/?id=85228003590395", rarity = "Ancient", offset = { X = -1.1, Y = -1.4, Z = 0.75 }, angles = { X = 2.0943951023932, Y = 3.14159265358979, Z = 0 } },
            { key = "Honorbound", name = "Honorbound", image = "http://www.roblox.com/asset/?id=136492136997228", rarity = "Common", offset = { X = -1.1, Y = -1.2, Z = 0.25 }, angles = { X = 2.0943951023932, Y = 3.14159265358979, Z = 0 } },
            { key = "RubyDivinity", name = "Ruby Divinity", image = "http://www.roblox.com/asset/?id=123017080164059", rarity = "Mythic", offset = { X = -1.1, Y = -1.5, Z = 0.5 }, angles = { X = 2.0943951023932, Y = 3.14159265358979, Z = 0 } },
            { key = "CelestialJudgment", name = "Celestial Judgment", image = "http://www.roblox.com/asset/?id=108984022872339", rarity = "Ancient", offset = { X = -1.1, Y = -1.5, Z = 0.5 }, angles = { X = 2.0943951023932, Y = 3.14159265358979, Z = 0 } },
            { key = "RavenClaw", name = "Raven Claw", image = "http://www.roblox.com/asset/?id=94539992022459", rarity = "Ancient", offset = { X = -1.1, Y = -1.2, Z = 0.25 }, angles = { X = 2.0943951023932, Y = 3.14159265358979, Z = 0 } },
            { key = "InterstellarStarcarver", name = "Interstellar Starcarver", image = "http://www.roblox.com/asset/?id=76492315370480", rarity = "Ancient", offset = { X = -1.1, Y = -1.5, Z = 0.9 }, angles = { X = 2.0943951023932, Y = 3.14159265358979, Z = 0 } },
            { key = "DJSoundcutter", name = "DJ Soundcutter", image = "http://www.roblox.com/asset/?id=115985602633307", rarity = "Ancient", offset = { X = -1.1, Y = -2, Z = 1.3 }, angles = { X = 2.0943951023932, Y = 3.14159265358979, Z = 0 } },
            { key = "FrankenBlade", name = "Franken Blade", image = "http://www.roblox.com/asset/?id=127750910720980", rarity = "Common", offset = { X = -1.1, Y = -1.3, Z = 0.5 }, angles = { X = 2.0943951023932, Y = 3.14159265358979, Z = 0 } },
            { key = "Batbite", name = "Batbite", image = "http://www.roblox.com/asset/?id=117324373555632", rarity = "Common", offset = { X = -1.1, Y = -1.2, Z = 0.5 }, angles = { X = 2.0943951023932, Y = 3.14159265358979, Z = 0 } },
            { key = "GraveMistake", name = "Grave Mistake", image = "http://www.roblox.com/asset/?id=120624940230368", rarity = "Rare", offset = { X = -1.1, Y = -1.2, Z = 0.5 }, angles = { X = 2.0943951023932, Y = 3.14159265358979, Z = 0 } },
            { key = "HallowHarvest", name = "Hallow's Harvest", image = "http://www.roblox.com/asset/?id=130662460545030", rarity = "Legendary", offset = { X = -1.1, Y = -1.2, Z = 0.5 }, angles = { X = 2.0943951023932, Y = 3.14159265358979, Z = 0 } },
            { key = "Jack-o-blade", name = "Jack-o-Blade", image = "http://www.roblox.com/asset/?id=88077499975858", rarity = "Legendary", offset = { X = -1.1, Y = -1.25, Z = 0.3 }, angles = { X = 2.0943951023932, Y = 3.14159265358979, Z = 0 } },
            { key = "HallowTyrant", name = "Hallow's Tyrant", image = "http://www.roblox.com/asset/?id=89602107060606", rarity = "Mythic", offset = { X = -1.1, Y = -1.25, Z = 0.3 }, angles = { X = 2.0943951023932, Y = 3.14159265358979, Z = 0 } },
            { key = "CrimsonSevernace", name = "Crimson Severance", image = "http://www.roblox.com/asset/?id=124619539714549", rarity = "Ancient", offset = { X = -1.1, Y = -1.6, Z = 0.8 }, angles = { X = 2.0943951023932, Y = 3.14159265358979, Z = 0 } },
            { key = "SkeletalScythe", name = "Skeletal Scythe", image = "http://www.roblox.com/asset/?id=93022833432754", rarity = "Ancient", offset = { X = -1.1, Y = -2, Z = 0.9 }, angles = { X = 1.91986217719376, Y = 3.14159265358979, Z = 0 } },
            { key = "DuskwingFang", name = "Duskwing Fang", image = "http://www.roblox.com/asset/?id=91734155748367", rarity = "Ancient", offset = { X = -1.1, Y = -1.45, Z = 0.6 }, angles = { X = 1.91986217719376, Y = 3.14159265358979, Z = 0 } },
            { key = "Maplefang", name = "Maplefang", image = "http://www.roblox.com/asset/?id=130471711755231", rarity = "Common", offset = { X = -1.1, Y = -1.45, Z = 0.6 }, angles = { X = 1.91986217719376, Y = 3.14159265358979, Z = 0 } },
            { key = "PieCutter", name = "Pie Cutter", image = "http://www.roblox.com/asset/?id=113189782250789", rarity = "Rare", offset = { X = -1.1, Y = -1.45, Z = 0.6 }, angles = { X = 1.91986217719376, Y = 3.14159265358979, Z = 0 } },
            { key = "Berrythorn", name = "Berrythorn", image = "http://www.roblox.com/asset/?id=120215704709639", rarity = "Legendary", offset = { X = -1.1, Y = -1.45, Z = 0.6 }, angles = { X = 0.349065850398866, Y = 0, Z = 0 } },
            { key = "AmberReaver", name = "Amber Reaver", image = "http://www.roblox.com/asset/?id=131631996256564", rarity = "Ancient", offset = { X = -1.1, Y = -1.45, Z = 0.6 }, angles = { X = 1.91986217719376, Y = 0, Z = 0 } },
            { key = "Deadseam", name = "Deadseam", image = "http://www.roblox.com/asset/?id=89442818934510", rarity = "Common", offset = { X = -1.1, Y = -1.45, Z = 0.6 }, angles = { X = 2.0943951023932, Y = 0, Z = 0 } },
            { key = "Plaguecleaver", name = "Plaguecleaver", image = "http://www.roblox.com/asset/?id=116032192644045", rarity = "Rare", offset = { X = -1.1, Y = -1.6, Z = 0.5 }, angles = { X = 1.91986217719376, Y = 0, Z = 0 } },
            { key = "Venommaul", name = "Venommaul", image = "http://www.roblox.com/asset/?id=120603647500428", rarity = "Ancient", offset = { X = -1.1, Y = -1.4, Z = 0.5 }, angles = { X = 1.91986217719376, Y = 0, Z = 0 } },
            { key = "PumpkingsReaper", name = "Pumpking's Reaper", image = "http://www.roblox.com/asset/?id=125402119180549", rarity = "Ancient", offset = { X = -1.1, Y = -1.3, Z = 0.5 }, angles = { X = 1.91986217719376, Y = 0, Z = 0 } },
            { key = "SkeletonAxe", name = "Skeleton Axe", image = "http://www.roblox.com/asset/?id=118474136003132", rarity = "Mythic", offset = { X = -1.1, Y = -1.3, Z = 0.5 }, angles = { X = 1.91986217719376, Y = 0, Z = 0 } },
            { key = "GhoulishKatana", name = "Ghoulish Katana", image = "http://www.roblox.com/asset/?id=131024085078135", rarity = "Ancient", offset = { X = -1.1, Y = -1.4, Z = 0.5 }, angles = { X = -1.0471975511966, Y = 0, Z = -3.14159265358979 } },
            { key = "WidowsWrath", name = "Widow's Wrath", image = "http://www.roblox.com/asset/?id=131323545959981", rarity = "Ancient", offset = { X = -1.1, Y = -1.7, Z = 0.75 }, angles = { X = -1.22173047639603, Y = 0, Z = -3.14159265358979 } },
            { key = "Amberpetal", name = "Amberpetal", image = "http://www.roblox.com/asset/?id=119961716816813", rarity = "Common", offset = { X = -1.1, Y = -1.1, Z = 0.1 }, angles = { X = 2.0943951023932, Y = -3.14159265358979, Z = 0 } },
            { key = "BlueFlourish", name = "Blue Flourish", image = "http://www.roblox.com/asset/?id=79470739493880", rarity = "Common", offset = { X = -1.1, Y = -1.3, Z = 0.1 }, angles = { X = 2.0943951023932, Y = -3.14159265358979, Z = 0 } },
            { key = "Bloomhook", name = "Bloomhook", image = "http://www.roblox.com/asset/?id=116444083293846", rarity = "Rare", offset = { X = -1.1, Y = -1, Z = 0.1 }, angles = { X = 0.349065850398866, Y = 0, Z = 0 } },
            { key = "EverlastingAmber", name = "Everlasting Amber", image = "http://www.roblox.com/asset/?id=73056129521856", rarity = "Legendary", offset = { X = -1.1, Y = -1, Z = 0.1 }, angles = { X = 2.0943951023932, Y = -3.14159265358979, Z = 0 } },
            { key = "Spiritshard", name = "Spiritshard", image = "http://www.roblox.com/asset/?id=81662692254086", rarity = "Mythic", offset = { X = -1.1, Y = -1.6, Z = 1 }, angles = { X = 2.0943951023932, Y = -3.14159265358979, Z = 0 } },
            { key = "MonarchsKunai", name = "Monarch's Kunai", image = "http://www.roblox.com/asset/?id=74133631258870", rarity = "Ancient", offset = { X = -1.1, Y = -1.6, Z = 0.75 }, angles = { X = 2.0943951023932, Y = -3.14159265358979, Z = 0 } },
            { key = "EmberbloomsReaper", name = "Emberbloom's Reaper", image = "http://www.roblox.com/asset/?id=107825355137063", rarity = "Ancient", offset = { X = -1.1, Y = -1.8, Z = 0.1 }, angles = { X = 1.74532925199433, Y = -3.14159265358979, Z = 0 } },
            { key = "PrismbloomThorn", name = "Prismbloom Thorn", image = "http://www.roblox.com/asset/?id=95353300875383", rarity = "Ancient", offset = { X = -1.1, Y = -1.8, Z = 0.75 }, angles = { X = 2.0943951023932, Y = -3.14159265358979, Z = 0 } },
            { key = "DusekkarsMalice", name = "Dusekkar's Malice", image = "http://www.roblox.com/asset/?id=73794058240726", rarity = "Ancient", offset = { X = -1.1, Y = -1.6, Z = 0.75 }, angles = { X = 2.0943951023932, Y = -3.14159265358979, Z = 0 } },
            { key = "DarkheartsPromise", name = "Darkheart's Promise", image = "http://www.roblox.com/asset/?id=113383381902153", rarity = "Ancient", offset = { X = -1.05, Y = -1.55, Z = 1.066 }, angles = { X = -1.22173047639603, Y = 0, Z = -3.14159265358979 } },
            { key = "RebelsEdge", name = "Rebel\\226\\128\\153s Edge", image = "http://www.roblox.com/asset/?id=122540106246206", rarity = "Legendary", offset = { X = -1.05, Y = -1.338, Z = 0.224 }, angles = { X = -2.79252680319093, Y = 0, Z = -3.14159265358979 } },
            { key = "Starwake", name = "Starwake", image = "http://www.roblox.com/asset/?id=140194986501393", rarity = "Legendary", offset = { X = -1.05, Y = -1.215, Z = 0.07 }, angles = { X = 2.0943951023932, Y = -1.5707963267949, Z = 0 } },
            { key = "AbyssalCrown", name = "Abyssal Crown", image = "http://www.roblox.com/asset/?id=93573135781823", rarity = "Mythic", offset = { X = -1.1, Y = -1.416, Z = 0.634 }, angles = { X = 1.91986217719376, Y = -1.5707963267949, Z = 0 } },
            { key = "BlossomTempest", name = "Blossom Tempest", image = "http://www.roblox.com/asset/?id=123331232578851", rarity = "Mythic", offset = { X = -1.05, Y = -1.801, Z = -0.144 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "NightshadesThorn", name = "Nightshade\\226\\128\\153s Thorn", image = "http://www.roblox.com/asset/?id=113985641537483", rarity = "Ancient", offset = { X = -1.05, Y = -1.656, Z = 1.082 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
            { key = "Otherworld", name = "Otherworld", image = "http://www.roblox.com/asset/?id=94152359892474", rarity = "Ancient", offset = { X = -1.1, Y = -1.6, Z = 0.75 }, angles = { X = 2.0943951023932, Y = -3.14159265358979, Z = 0 } },
            { key = "AstralAscendant", name = "Astral Ascendant", image = "http://www.roblox.com/asset/?id=134655875866443", rarity = "Ancient", offset = { X = -1.1, Y = -1.397, Z = 0.762 }, angles = { X = -1.13446401379631, Y = 0, Z = -3.14159265358979 } },
        },
        effects = {
            { key = "DefaultEffect", name = "Default Effect", image = "http://www.roblox.com/asset/?id=84777154787719", rarity = "Common", offset = nil, angles = nil },
            { key = "Batstorm", name = "Batstorm", image = "http://www.roblox.com/asset/?id=92947313623851", rarity = "Common", offset = nil, angles = nil },
            { key = "SoulReaper", name = "Soul Reaper", image = "http://www.roblox.com/asset/?id=139488326961899", rarity = "Common", offset = nil, angles = nil },
            { key = "PumpkinCurse", name = "Pumpkin Curse", image = "http://www.roblox.com/asset/?id=119276342573957", rarity = "Common", offset = nil, angles = nil },
            { key = "Ghosted", name = "Ghosted", image = "http://www.roblox.com/asset/?id=85372258717724", rarity = "Common", offset = nil, angles = nil },
            { key = "Frostbite", name = "Frostbite", image = "http://www.roblox.com/asset/?id=96237284722724", rarity = "Mythic", offset = nil, angles = nil },
            { key = "CandyCane", name = "Candy Cane", image = "http://www.roblox.com/asset/?id=105160670763202", rarity = "Rare", offset = nil, angles = nil },
            { key = "Decorated", name = "Decorated", image = "http://www.roblox.com/asset/?id=126996456069513", rarity = "Uncommon", offset = nil, angles = nil },
            { key = "Gifted", name = "Gifted", image = "http://www.roblox.com/asset/?id=73654149552603", rarity = "Legendary", offset = nil, angles = nil },
            { key = "SantaClaus", name = "Santa", image = "http://www.roblox.com/asset/?id=135085444847867", rarity = "Rare", offset = nil, angles = nil },
            { key = "Freeze", name = "Freeze", image = "http://www.roblox.com/asset/?id=73353943790875", rarity = "Uncommon", offset = nil, angles = nil },
            { key = "SnowMan", name = "SnowMan", image = "http://www.roblox.com/asset/?id=122576698317333", rarity = "Rare", offset = nil, angles = nil },
            { key = "Confetti", name = "Confetti", image = "http://www.roblox.com/asset/?id=108505632837799", rarity = "Mythic", offset = nil, angles = nil },
            { key = "Heartache", name = "Heartache", image = "http://www.roblox.com/asset/?id=84840525397695", rarity = "Ancient", offset = nil, angles = nil },
            { key = "LoveExplosion", name = "Love Explosion", image = "http://www.roblox.com/asset/?id=98786428621798", rarity = "Mythic", offset = nil, angles = nil },
            { key = "Featherlight", name = "Featherlight", image = "http://www.roblox.com/asset/?id=136984323983320", rarity = "Rare", offset = nil, angles = nil },
            { key = "Heartbeat", name = "Heartbeat", image = "http://www.roblox.com/asset/?id=140350269884652", rarity = "Mythic", offset = nil, angles = nil },
            { key = "SpiritOverload", name = "Spirit Overload", image = "http://www.roblox.com/asset/?id=108801276756465", rarity = "Ancient", offset = nil, angles = nil },
            { key = "MoneyMaker", name = "Money Maker", image = "http://www.roblox.com/asset/?id=103800630555365", rarity = "Legendary", offset = nil, angles = nil },
            { key = "NiceHat", name = "Nice Hat", image = "http://www.roblox.com/asset/?id=131063991892457", rarity = "Ancient", offset = nil, angles = nil },
            { key = "CloverMadness", name = "Clover Madness", image = "http://www.roblox.com/asset/?id=130254823913252", rarity = "Rare", offset = nil, angles = nil },
            { key = "BunnyBoys", name = "BunnyBoys", image = "http://www.roblox.com/asset/?id=71188020684810", rarity = "Rare", offset = nil, angles = nil },
            { key = "Eggsplosion", name = "Eggsplosion", image = "http://www.roblox.com/asset/?id=126255618095204", rarity = "Rare", offset = nil, angles = nil },
            { key = "Egged", name = "Egged", image = "http://www.roblox.com/asset/?id=106853935542832", rarity = "Rare", offset = nil, angles = nil },
            { key = "HexaKill", name = "Hexa Kill", image = "http://www.roblox.com/asset/?id=131227708807868", rarity = "Ancient", offset = nil, angles = nil },
            { key = "SandEffect", name = "Sand", image = "http://www.roblox.com/asset/?id=78673019764685", rarity = "Mythic", offset = nil, angles = nil },
            { key = "DragonBlossom", name = "Dragon Blossom", image = "http://www.roblox.com/asset/?id=108853261294319", rarity = "Mythic", offset = nil, angles = nil },
            { key = "GreenJelly", name = "Green Jelly", image = "http://www.roblox.com/asset/?id=95346228886490", rarity = "Ancient", offset = nil, angles = nil },
            { key = "Water", name = "Water", image = "rbxassetid://5", rarity = "Mythic", offset = nil, angles = nil },
            { key = "SakuraEffect", name = "Sakura", image = "http://www.roblox.com/asset/?id=123662324147699", rarity = "Mythic", offset = nil, angles = nil },
            { key = "LightningEffect", name = "Lightning", image = "rbxassetid://5", rarity = "Mythic", offset = nil, angles = nil },
            { key = "LightningStrike", name = "Lightning Strike", image = "http://www.roblox.com/asset/?id=113153033238495", rarity = "Mythic", offset = nil, angles = nil },
            { key = "GothEffect", name = "Duskveil", image = "http://www.roblox.com/asset/?id=90983010539470", rarity = "Mythic", offset = nil, angles = nil },
            { key = "ValkyrieEffect", name = "Valkyrie", image = "http://www.roblox.com/asset/?id=99453530501374", rarity = "Mythic", offset = nil, angles = nil },
            { key = "PurpleJelly", name = "Purple Jelly", image = "http://www.roblox.com/asset/?id=96654110616368", rarity = "Mythic", offset = nil, angles = nil },
            { key = "BlueJelly", name = "Blue Jelly", image = "http://www.roblox.com/asset/?id=95313705711364", rarity = "Mythic", offset = nil, angles = nil },
            { key = "RedJelly", name = "Red Jelly", image = "http://www.roblox.com/asset/?id=78390032635269", rarity = "Mythic", offset = nil, angles = nil },
            { key = "IceEffect", name = "Ice", image = "http://www.roblox.com/asset/?id=113987959793494", rarity = "Rare", offset = nil, angles = nil },
            { key = "GreenIce", name = "Green Ice", image = "http://www.roblox.com/asset/?id=129123524310992", rarity = "Rare", offset = nil, angles = nil },
            { key = "PurpleIce", name = "Purple Ice", image = "http://www.roblox.com/asset/?id=89738414659508", rarity = "Rare", offset = nil, angles = nil },
            { key = "RedIce", name = "Red Ice", image = "http://www.roblox.com/asset/?id=128313793032508", rarity = "Rare", offset = nil, angles = nil },
            { key = "YellowIce", name = "Yellow Ice", image = "http://www.roblox.com/asset/?id=78672804353675", rarity = "Rare", offset = nil, angles = nil },
            { key = "GrassEffect", name = "Grass", image = "http://www.roblox.com/asset/?id=87739237009826", rarity = "Rare", offset = nil, angles = nil },
            { key = "BlueNature", name = "Blue Grass", image = "http://www.roblox.com/asset/?id=131453430496815", rarity = "Rare", offset = nil, angles = nil },
            { key = "PurpleGrass", name = "Purple Grass", image = "http://www.roblox.com/asset/?id=74570881493081", rarity = "Rare", offset = nil, angles = nil },
            { key = "RedNature", name = "Red Grass", image = "http://www.roblox.com/asset/?id=110230129585180", rarity = "Rare", offset = nil, angles = nil },
            { key = "YellowGrass", name = "Yellow Grass", image = "http://www.roblox.com/asset/?id=88604312139749", rarity = "Rare", offset = nil, angles = nil },
            { key = "FireEffect", name = "Fire", image = "http://www.roblox.com/asset/?id=106759741299588", rarity = "Legendary", offset = nil, angles = nil },
            { key = "BlueFire", name = "Blue Fire", image = "http://www.roblox.com/asset/?id=127168902954086", rarity = "Legendary", offset = nil, angles = nil },
            { key = "PurpleFire", name = "Purple Fire", image = "http://www.roblox.com/asset/?id=77223925621337", rarity = "Legendary", offset = nil, angles = nil },
            { key = "RedFire", name = "Red Fire", image = "http://www.roblox.com/asset/?id=121513010660006", rarity = "Legendary", offset = nil, angles = nil },
            { key = "YellowFire", name = "Yellow Fire", image = "http://www.roblox.com/asset/?id=90405768407195", rarity = "Legendary", offset = nil, angles = nil },
            { key = "SmokeEffect", name = "Smoke", image = "http://www.roblox.com/asset/?id=127232653669869", rarity = "Common", offset = nil, angles = nil },
            { key = "BlueSmoke", name = "Blue Smoke", image = "http://www.roblox.com/asset/?id=82022124848285", rarity = "Common", offset = nil, angles = nil },
            { key = "PurpleSmoke", name = "Purple Smoke", image = "http://www.roblox.com/asset/?id=132305410489772", rarity = "Common", offset = nil, angles = nil },
            { key = "RedSmoke", name = "Red Smoke", image = "http://www.roblox.com/asset/?id=104996815675171", rarity = "Common", offset = nil, angles = nil },
            { key = "YellowSmoke", name = "Yellow Smoke", image = "http://www.roblox.com/asset/?id=103247984389108", rarity = "Common", offset = nil, angles = nil },
            { key = "Sunburn", name = "Sunburn", image = "http://www.roblox.com/asset/?id=113032207515450", rarity = "Mythic", offset = nil, angles = nil },
            { key = "PineappleEffect", name = "Pineapple", image = "http://www.roblox.com/asset/?id=109092023931302", rarity = "Mythic", offset = nil, angles = nil },
            { key = "MatchaEffect", name = "Matcha Boba", image = "http://www.roblox.com/asset/?id=75199108121278", rarity = "Ancient", offset = nil, angles = nil },
            { key = "LavaEffect", name = "Lava Effect", image = "http://www.roblox.com/asset/?id=94364905941265", rarity = "Ancient", offset = nil, angles = nil },
            { key = "DuskRoseEffect", name = "Dusk Rose Effect", image = "http://www.roblox.com/asset/?id=105937173950030", rarity = "Ancient", offset = nil, angles = nil },
            { key = "RainbowEffect", name = "Rainbow", image = "http://www.roblox.com/asset/?id=101698880748524", rarity = "Ancient", offset = nil, angles = nil },
            { key = "LumenburstEffect", name = "Lumenburst", image = "http://www.roblox.com/asset/?id=124606339236181", rarity = "Ancient", offset = nil, angles = nil },
            { key = "StardustCollapseEffect", name = "StardustCollapse", image = "http://www.roblox.com/asset/?id=122741879869892", rarity = "Ancient", offset = nil, angles = nil },
            { key = "SplashEffect", name = "Splash", image = "http://www.roblox.com/asset/?id=97202871895923", rarity = "Mythic", offset = nil, angles = nil },
            { key = "FishDeathEffect", name = "Fish Death", image = "http://www.roblox.com/asset/?id=86847857644139", rarity = "Legendary", offset = nil, angles = nil },
            { key = "BubbleDeathEffect", name = "Bubble Death", image = "http://www.roblox.com/asset/?id=84306903549178", rarity = "Legendary", offset = nil, angles = nil },
            { key = "GhostbringerEffect", name = "Ghostbringer", image = "http://www.roblox.com/asset/?id=118352579117309", rarity = "Ancient", offset = nil, angles = nil },
            { key = "DreamwalkerEffect", name = "Dreamwalker", image = "http://www.roblox.com/asset/?id=113569852372904", rarity = "Ancient", offset = nil, angles = nil },
            { key = "SlimeEffect", name = "Slime", image = "http://www.roblox.com/asset/?id=80578732911863", rarity = "Mythic", offset = nil, angles = nil },
            { key = "IcemanEffect", name = "Iceman", image = "http://www.roblox.com/asset/?id=129114219188176", rarity = "Mythic", offset = nil, angles = nil },
            { key = "EclipseEffect", name = "Eclipse", image = "http://www.roblox.com/asset/?id=129027480174322", rarity = "Ancient", offset = nil, angles = nil },
            { key = "SpiderEffect", name = "Spider", image = "http://www.roblox.com/asset/?id=130821233506508", rarity = "Ancient", offset = nil, angles = nil },
            { key = "InfernalEffect", name = "Infernal", image = "http://www.roblox.com/asset/?id=93316005427331", rarity = "Ancient", offset = nil, angles = nil },
            { key = "KitsuneEffect", name = "Kitsune", image = "http://www.roblox.com/asset/?id=128765075583571", rarity = "Ancient", offset = nil, angles = nil },
            { key = "MagicSparksEffect", name = "Magic Sparks", image = "http://www.roblox.com/asset/?id=120657990433656", rarity = "Legendary", offset = nil, angles = nil },
            { key = "1x1x1x1Effect", name = "1x1x1x1", image = "http://www.roblox.com/asset/?id=115333253051095", rarity = "Ancient", offset = nil, angles = nil },
            { key = "PortalEffect", name = "Portal", image = "http://www.roblox.com/asset/?id=76849746062082", rarity = "Mythic", offset = nil, angles = nil },
            { key = "ShadowcrestEffect", name = "Shadowcrest", image = "http://www.roblox.com/asset/?id=102424221290910", rarity = "Ancient", offset = nil, angles = nil },
            { key = "HeartbreakerEffect", name = "Heartbreaker", image = "http://www.roblox.com/asset/?id=79981515408948", rarity = "Ancient", offset = nil, angles = nil },
            { key = "BlackvalkEffect", name = "Blackvalk Effect", image = "http://www.roblox.com/asset/?id=105580331861157", rarity = "Ancient", offset = nil, angles = nil },
            { key = "UFOEffect", name = "UFO", image = "http://www.roblox.com/asset/?id=92351502532565", rarity = "Mythic", offset = nil, angles = nil },
            { key = "RocketEffect", name = "Rocket", image = "http://www.roblox.com/asset/?id=122617583521425", rarity = "Rare", offset = nil, angles = nil },
            { key = "BlackholeEffect", name = "Blackhole", image = "http://www.roblox.com/asset/?id=75780810568882", rarity = "Legendary", offset = nil, angles = nil },
            { key = "BloodmoonEffect", name = "Bloodmoon", image = "http://www.roblox.com/asset/?id=138629040572221", rarity = "Ancient", offset = nil, angles = nil },
            { key = "VenomEffect", name = "Venom", image = "http://www.roblox.com/asset/?id=133918079985505", rarity = "Ancient", offset = nil, angles = nil },
            { key = "BlackheartEffect", name = "Blackheart", image = "http://www.roblox.com/asset/?id=81953240524624", rarity = "Ancient", offset = nil, angles = nil },
            { key = "ClanFlagEffect", name = "Clan Flag", image = "http://www.roblox.com/asset/?id=128861901469270", rarity = "Ancient", offset = nil, angles = nil },
            { key = "ClanEmblemEffect", name = "Clan Emblem", image = "http://www.roblox.com/asset/?id=85022505470082", rarity = "Ancient", offset = nil, angles = nil },
            { key = "StarwingEffect", name = "Starwing", image = "http://www.roblox.com/asset/?id=80029246809260", rarity = "Ancient", offset = nil, angles = nil },
            { key = "PhoenixEffect", name = "Phoenix", image = "http://www.roblox.com/asset/?id=97407535213337", rarity = "Ancient", offset = nil, angles = nil },
            { key = "RankedBronzeEffect", name = "Ranked Bronze Wings", image = "http://www.roblox.com/asset/?id=108807439301621", rarity = "Rare", offset = nil, angles = nil },
            { key = "RankedSilverEffect", name = "Ranked Silver Wings", image = "http://www.roblox.com/asset/?id=73487796773544", rarity = "Rare", offset = nil, angles = nil },
            { key = "RankedGoldEffect", name = "Ranked Gold Wings", image = "http://www.roblox.com/asset/?id=84422474965318", rarity = "Legendary", offset = nil, angles = nil },
            { key = "RankedDiamondEffect", name = "Ranked Diamond Wings", image = "http://www.roblox.com/asset/?id=133319647481056", rarity = "Mythic", offset = nil, angles = nil },
            { key = "RankedEmeraldEffect", name = "Ranked Emerald Wings", image = "http://www.roblox.com/asset/?id=111782752364653", rarity = "Mythic", offset = nil, angles = nil },
            { key = "RankedGrandmasterEffect", name = "Ranked Grandmaster Wings", image = "http://www.roblox.com/asset/?id=98845832149577", rarity = "Ancient", offset = nil, angles = nil },
            { key = "RankedChampionEffect", name = "Ranked Champion Wings", image = "http://www.roblox.com/asset/?id=138240994894301", rarity = "Ancient", offset = nil, angles = nil },
            { key = "LEffect", name = "L", image = "http://www.roblox.com/asset/?id=118276022970959", rarity = "Rare", offset = nil, angles = nil },
            { key = "CheckmateEffect", name = "Checkmate", image = "http://www.roblox.com/asset/?id=121782370696137", rarity = "Legendary", offset = nil, angles = nil },
            { key = "PrismaticEffect", name = "Prismatic", image = "http://www.roblox.com/asset/?id=106971079991986", rarity = "Ancient", offset = nil, angles = nil },
            { key = "RavenEffect", name = "Raven", image = "http://www.roblox.com/asset/?id=73618842596434", rarity = "Ancient", offset = nil, angles = nil },
            { key = "DJEffect", name = "DJ", image = "http://www.roblox.com/asset/?id=97924317336941", rarity = "Ancient", offset = nil, angles = nil },
            { key = "InterstellarEffect", name = "Interstellar", image = "http://www.roblox.com/asset/?id=108710390727479", rarity = "Ancient", offset = nil, angles = nil },
            { key = "SpookyNightEffect", name = "Spooky Night", image = "http://www.roblox.com/asset/?id=71730126747858", rarity = "Legendary", offset = nil, angles = nil },
            { key = "GhostHauntEffect", name = "Ghost Haunt", image = "http://www.roblox.com/asset/?id=106953983980513", rarity = "Rare", offset = nil, angles = nil },
            { key = "JackoLanternEffect", name = "Jack-o-Lantern", image = "http://www.roblox.com/asset/?id=112206828532075", rarity = "Mythic", offset = nil, angles = nil },
            { key = "DuskwingEffect", name = "Duskwing", image = "http://www.roblox.com/asset/?id=97332480457122", rarity = "Ancient", offset = nil, angles = nil },
            { key = "PumpkingEffect", name = "Pumpking", image = "http://www.roblox.com/asset/?id=121365590525869", rarity = "Ancient", offset = nil, angles = nil },
            { key = "SoulveilEffect", name = "Soulveil", image = "http://www.roblox.com/asset/?id=83924702217832", rarity = "Ancient", offset = nil, angles = nil },
            { key = "WidowsEffect", name = "Widow", image = "http://www.roblox.com/asset/?id=103490070555142", rarity = "Ancient", offset = nil, angles = nil },
            { key = "PrismbloomEffect", name = "Prismbloom", image = "http://www.roblox.com/asset/?id=88508862326368", rarity = "Ancient", offset = nil, angles = nil },
            { key = "DusekkarEffect", name = "Dusekkar", image = "http://www.roblox.com/asset/?id=117476540333240", rarity = "Ancient", offset = nil, angles = nil },
            { key = "SweetDemiseEffect", name = "Sweet Demise", image = "http://www.roblox.com/asset/?id=70391820059506", rarity = "Legendary", offset = nil, angles = nil },
            { key = "MarigoldEffect", name = "Marigold", image = "http://www.roblox.com/asset/?id=82127765074860", rarity = "Legendary", offset = nil, angles = nil },
            { key = "FireworkSkullEffect", name = "Firework Skull", image = "http://www.roblox.com/asset/?id=128178595140065", rarity = "Legendary", offset = nil, angles = nil },
            { key = "SweetAfterlifeEffect", name = "Sweet Afterlife", image = "http://www.roblox.com/asset/?id=139948912676843", rarity = "Mythic", offset = nil, angles = nil },
            { key = "MonarchEffect", name = "Monarch", image = "http://www.roblox.com/asset/?id=122271450826863", rarity = "Mythic", offset = nil, angles = nil },
            { key = "DarkheartsEffect", name = "Darkheart's Effect", image = "http://www.roblox.com/asset/?id=81168673267467", rarity = "Ancient", offset = nil, angles = nil },
        },
    }
    local weaponCatalog = {}
    local weaponCatalogDisplay = {}
    local weaponCatalogImage = {}
    local weaponCatalogSide = {}
    local weaponCatalogKeyByAlias = {}
    local weaponCatalogAliasAmbiguous = {}
    local weaponCatalogRecords = { guns = {}, knives = {} }
    local weaponCatalogRecordByKey = {}
    local weaponEntriesByKey = {}
    local effectEntriesByKey = {}
    local effectCatalog = {}
    local effectCatalogDisplay = {}
    local effectCatalogImage = {}
    local effectCatalogKeyByAlias = {}
    local effectCatalogAliasAmbiguous = {}
    local effectCatalogRecordByKey = {}
    local weaponCatalogCounts = { guns = 0, knives = 0, effects = 0 }

    local function catalogImage(value)
        if type(value) == "number" then
            return "http://www.roblox.com/asset/?id=" .. tostring(math.floor(value))
        end
        if type(value) ~= "string" or value == "" then return nil end
        local id = value:match("(%d%d%d%d%d+)")
        if id then return "http://www.roblox.com/asset/?id=" .. id end
        return value
    end

    local function registerWeaponAlias(alias, category, displayName, image, side, itemKey)
        local key = squash(alias)
        if key == "" or weaponCatalogAliasAmbiguous[key] then return end
        local canonicalKey = itemKey or alias
        local previousKey = weaponCatalogKeyByAlias[key]
        if previousKey and squash(previousKey) ~= squash(canonicalKey) then
            weaponCatalogAliasAmbiguous[key] = true
            weaponCatalogKeyByAlias[key] = nil
            weaponCatalog[key] = nil
            weaponCatalogDisplay[key] = nil
            weaponCatalogImage[key] = nil
            weaponCatalogSide[key] = nil
            return
        end
        weaponCatalogKeyByAlias[key] = canonicalKey
        weaponCatalog[key] = category
        weaponCatalogDisplay[key] = displayName
        weaponCatalogImage[key] = image
        if side then
            if weaponCatalogSide[key] and weaponCatalogSide[key] ~= side then
                weaponCatalogSide[key] = nil
            else
                weaponCatalogSide[key] = side
            end
        end
    end

    local function catalogWeaponRecordForName(value)
        if type(value) ~= "string" or value == "" then return nil end
        local alias = squash(value)
        if alias == "" then return nil end
        local function lookup(key)
            if weaponCatalogAliasAmbiguous[key] then return nil end
            local itemKey = weaponCatalogKeyByAlias[key]
            return itemKey and weaponCatalogRecordByKey[squash(itemKey)] or nil
        end
        local record = lookup(alias)
        if record then return record end
        -- Stands and bundle rigs sometimes prefix the catalogue key with the slot name.
        for _, prefix in ipairs({ "knife", "gun", "weapon", "skin", "item" }) do
            if #alias > #prefix then
                local candidate = alias:sub(#prefix + 1)
                record = lookup(candidate)
                if record then return record end
            end
        end
        for _, suffix in ipairs({ "skin", "weapon", "model", "tool" }) do
            if #alias > #suffix then
                local candidate = alias:sub(1, #alias - #suffix)
                record = lookup(candidate)
                if record then return record end
            end
        end
        return nil
    end

    local function catalogWeaponRecordFromInstance(inst)
        if not inst then return nil end
        local record = catalogWeaponRecordForName(inst.Name)
        if record then return record end
        local function inspectMeta(container)
            if not container then return nil end
            for attributeName, value in pairs(container:GetAttributes()) do
                local key = squash(attributeName)
                if key:find("item", 1, true) or key:find("skin", 1, true)
                    or key:find("weapon", 1, true) or key:find("gun", 1, true)
                    or key:find("knife", 1, true) then
                    if type(value) == "string" then
                        local found = catalogWeaponRecordForName(value)
                        if found then return found end
                    end
                end
            end
            return nil
        end
        record = inspectMeta(inst)
        if record then return record end
        local checked = 0
        for _, descendant in ipairs(inst:GetDescendants()) do
            checked = checked + 1
            if checked > 160 then break end
            if descendant:IsA("StringValue") or descendant:IsA("ObjectValue") then
                local key = squash(descendant.Name)
                if key:find("item", 1, true) or key:find("skin", 1, true)
                    or key:find("weapon", 1, true) or key:find("gun", 1, true)
                    or key:find("knife", 1, true) then
                    local value
                    if descendant:IsA("StringValue") then value = descendant.Value
                    elseif descendant.Value then value = descendant.Value.Name end
                    record = catalogWeaponRecordForName(value)
                    if record then return record end
                end
            end
            record = inspectMeta(descendant)
            if record then return record end
        end
        return nil
    end

    local function registerEffectAlias(alias, record)
        local key = squash(alias)
        if key == "" or effectCatalogAliasAmbiguous[key] then return end
        local previous = effectCatalogKeyByAlias[key]
        if previous and squash(previous) ~= squash(record.key) then
            effectCatalogAliasAmbiguous[key] = true
            effectCatalogKeyByAlias[key] = nil
            effectCatalogDisplay[key] = nil
            effectCatalogImage[key] = nil
            return
        end
        effectCatalogKeyByAlias[key] = record.key
        effectCatalogDisplay[key] = record.name
        effectCatalogImage[key] = record.image
    end

    local function catalogEffectRecordForName(value)
        if type(value) ~= "string" or value == "" then return nil end
        local key = squash(value)
        local itemKey = not effectCatalogAliasAmbiguous[key] and effectCatalogKeyByAlias[key] or nil
        if not itemKey then
            for _, suffix in ipairs({ "killeffect", "finisher", "effect", "vfx", "killfx", "fx" }) do
                if #key > #suffix and key:sub(-#suffix) == suffix then
                    local base = key:sub(1, #key - #suffix)
                    if not effectCatalogAliasAmbiguous[base] then itemKey = effectCatalogKeyByAlias[base] end
                    if itemKey then break end
                end
            end
        end
        if not itemKey then
            for _, prefix in ipairs({ "killeffect", "finisher", "effect", "killfx" }) do
                if #key > #prefix then
                    local base = key:sub(#prefix + 1)
                    if not effectCatalogAliasAmbiguous[base] then itemKey = effectCatalogKeyByAlias[base] end
                    if itemKey then break end
                end
            end
        end
        return itemKey and effectCatalogRecordByKey[squash(itemKey)] or nil
    end

    local function catOfName(name)
        local key = squash(name)
        if not weaponCatalogAliasAmbiguous[key] and weaponCatalog[key] then return weaponCatalog[key] end
        local n = norm(name)
        if hasAny(n, BLADE_SUB) or hasWordKW(n, BLADE_WORD) then return "melee" end
        if hasAny(n, GUN_SUB) or hasWordKW(n, GUN_WORD) then return "gun" end
        return nil
    end

    local function loadWeaponCatalog()
        table.clear(weaponCatalog)
        table.clear(weaponCatalogDisplay)
        table.clear(weaponCatalogImage)
        table.clear(weaponCatalogSide)
        table.clear(weaponCatalogKeyByAlias)
        table.clear(weaponCatalogAliasAmbiguous)
        table.clear(weaponCatalogRecordByKey)
        table.clear(weaponCatalogRecords.guns)
        table.clear(weaponCatalogRecords.knives)
        table.clear(weaponEntriesByKey)
        table.clear(effectEntriesByKey)
        table.clear(effectCatalog)
        table.clear(effectCatalogDisplay)
        table.clear(effectCatalogImage)
        table.clear(effectCatalogKeyByAlias)
        table.clear(effectCatalogAliasAmbiguous)
        table.clear(effectCatalogRecordByKey)
        weaponCatalogCounts.guns = 0
        weaponCatalogCounts.knives = 0
        weaponCatalogCounts.effects = 0

        for _, source in ipairs({
            { source = STATIC_CATALOG.guns, category = "gun", bucket = weaponCatalogRecords.guns },
            { source = STATIC_CATALOG.knives, category = "melee", bucket = weaponCatalogRecords.knives },
        }) do
            for _, raw in ipairs(source.source) do
                local record = {
                    key = raw.key, name = raw.name, image = catalogImage(raw.image), rarity = raw.rarity,
                    setName = raw.setName or raw.SetName or raw.set or raw.collection,
                    offset = raw.offset, angles = raw.angles, cat = source.category,
                }
                source.bucket[#source.bucket + 1] = record
                weaponCatalogRecordByKey[squash(record.key)] = record
                registerWeaponAlias(record.key, record.cat, record.name, record.image, nil, record.key)
                registerWeaponAlias(record.name, record.cat, record.name, record.image, nil, record.key)
            end
            if source.category == "gun" then
                weaponCatalogCounts.guns = #source.bucket
            else
                weaponCatalogCounts.knives = #source.bucket
            end
        end

        for _, raw in ipairs(STATIC_CATALOG.effects) do
            local record = {
                key = raw.key, name = raw.name, image = catalogImage(raw.image), rarity = raw.rarity,
                setName = raw.setName or raw.SetName or raw.set or raw.collection,
            }
            effectCatalog[#effectCatalog + 1] = record
            effectCatalogRecordByKey[squash(record.key)] = record
            registerEffectAlias(record.key, record)
            registerEffectAlias(record.name, record)
        end
        weaponCatalogCounts.effects = #effectCatalog

        -- The game's DualWield resolver may map a catalog entry to differently named
        -- left/right 3D templates. This only adds aliases; it never adds catalog items.
        local replicated = game:GetService("ReplicatedStorage")
        local shared = replicated:FindFirstChild("Shared")
        local itemRoot = shared and shared:FindFirstChild("Item")
        local utils = itemRoot and itemRoot:FindFirstChild("Utils")
        local dualModule = utils and utils:FindFirstChild("DualWield")
        if dualModule and dualModule:IsA("ModuleScript") then
            local ok, dual = pcall(require, dualModule)
            if ok and type(dual) == "table" then
                for _, record in ipairs(weaponCatalogRecords.guns) do
                    if type(dual.getSide) == "function" then
                        for _, side in ipairs({ "Right", "Left" }) do
                            local sideOk, sideData = pcall(dual.getSide, record.key, side)
                            if sideOk and type(sideData) == "table" and type(sideData.Skin) == "string" then
                                record.sideTransforms = record.sideTransforms or {}
                                record.sideTransforms[side] = {
                                    skin = sideData.Skin, offset = sideData.Offset,
                                    angles = sideData.Angles, mirror = sideData.Mirror,
                                }
                                registerWeaponAlias(sideData.Skin, "gun", record.name, record.image, side, record.key)
                            end
                        end
                    end
                    if type(dual.getSkins) == "function" then
                        local skinOk, skinNames = pcall(dual.getSkins, record.key)
                        if skinOk and type(skinNames) == "table" then
                            for _, skinName in ipairs(skinNames) do
                                if type(skinName) == "string" then
                                    registerWeaponAlias(skinName, "gun", record.name, record.image, nil, record.key)
                                end
                            end
                        end
                    end
                end
            end
        end
        return weaponCatalogCounts
    end
    local function metadataCat(inst, includeDescendants)
        local function fromMetadata(key, value)
            if type(value) ~= "string" then return nil end
            if not hasAny(squash(key), CAT_META_KEYS) then return nil end
            return catOfName(value)
        end
        for key, value in pairs(inst:GetAttributes()) do
            local cat = fromMetadata(key, value)
            if cat then return cat end
        end
        local descendants = includeDescendants and descendantsOf(inst) or inst:GetChildren()
        local checked = 0
        for _, d in ipairs(descendants) do
            checked = checked + 1
            if checked > 250 then break end
            if includeDescendants then
                for key, value in pairs(d:GetAttributes()) do
                    local cat = fromMetadata(key, value)
                    if cat then return cat end
                end
            end
            if d:IsA("ValueBase") and hasAny(squash(d.Name), CAT_META_KEYS) then
                local ok, value = pcall(function() return d.Value end)
                if ok then
                    local cat = catOfName(value)
                    if cat then return cat end
                end
            end
        end
        return nil
    end
    local function catOfContent(inst)
        local gun, mel, count = 0, 0, 0
        for _, d in ipairs(descendantsOf(inst)) do
            count = count + 1
            if count > 200 then break end
            local n = norm(d.Name)
            if hasAny(n, GUN_HINT) then gun = gun + 1 end
            if hasAny(n, MELEE_HINT) then mel = mel + 1 end
            if d:IsA("ValueBase") then
                local ok, value = pcall(function() return d.Value end)
                if ok and type(value) == "string" then
                    local cat = catOfName(value)
                    if cat == "gun" then gun = gun + 1 end
                    if cat == "melee" then mel = mel + 1 end
                end
            end
        end
        for k in pairs(inst:GetAttributes()) do
            local n = norm(k)
            if hasAny(n, GUN_HINT) then gun = gun + 1 end
            if hasAny(n, MELEE_HINT) then mel = mel + 1 end
        end
        if gun > mel and gun > 0 then return "gun" end
        if mel > gun and mel > 0 then return "melee" end
        return nil
    end
    local function stopWalk(p)
        if p == game or p == workspace then return true end
        if p:IsA("Backpack") or p:IsA("Player") then return true end
        if p:IsA("Model") and p:FindFirstChildOfClass("Humanoid") then return true end
        return false
    end
    local function classifyWeapon(inst)
        local c = catOfName(inst.Name)
        if c then return c end
        c = metadataCat(inst, true)
        if c then return c end
        local p, depth = inst.Parent, 0
        while p and depth < 8 and not stopWalk(p) do
            c = catOfName(p.Name)
            if c then return c end
            c = metadataCat(p, false)
            if c then return c end
            p = p.Parent
            depth = depth + 1
        end
        return nil
    end
    local function partsOf(inst)
        local list = {}
        if inst:IsA("BasePart") then list[1] = inst end
        local cached = partsCache[inst]
        if cached then return cached end
        for _, d in ipairs(descendantsOf(inst)) do
            if d:IsA("BasePart") then list[#list + 1] = d end
        end
        partsCache[inst] = list
        return list
    end
    local function boundsIn(parts, ref)
        local inv = ref:Inverse()
        local mn, mx
        local cx, cy, cz, tw = 0, 0, 0, 0
        for _, p in ipairs(parts) do
            local cf = inv * p.CFrame
            local s = p.Size / 2
            for ix = -1, 1, 2 do
                for iy = -1, 1, 2 do
                    for iz = -1, 1, 2 do
                        local v = cf:PointToWorldSpace(Vector3.new(s.X * ix, s.Y * iy, s.Z * iz))
                        if not mn then
                            mn, mx = v, v
                        else
                            mn = Vector3.new(math.min(mn.X, v.X), math.min(mn.Y, v.Y), math.min(mn.Z, v.Z))
                            mx = Vector3.new(math.max(mx.X, v.X), math.max(mx.Y, v.Y), math.max(mx.Z, v.Z))
                        end
                    end
                end
            end
            local vol = p.Size.X * p.Size.Y * p.Size.Z
            local pos = cf.Position
            cx = cx + pos.X * vol
            cy = cy + pos.Y * vol
            cz = cz + pos.Z * vol
            tw = tw + vol
        end
        if not mn then return Vector3.zero, Vector3.new(1, 1, 1), Vector3.zero end
        local center = (mn + mx) / 2
        local cen = center
        if tw > 0 then cen = Vector3.new(cx / tw, cy / tw, cz / tw) end
        return center, mx - mn, cen
    end
    local function refPartOf(parts)
        local ref = parts[1]
        for _, p in ipairs(parts) do
            if p.Name == "Handle" then
                ref = p
                break
            end
        end
        return ref
    end
    local boundsCache = setmetatable({}, { __mode = "k" })
    local function boundsFor(inst)
        local cached = boundsCache[inst]
        if cached then return cached[1], cached[2], cached[3] end
        local parts = partsOf(inst)
        if #parts == 0 then return Vector3.zero, Vector3.zero, Vector3.zero end
        local center, size, weighted = boundsIn(parts, refPartOf(parts).CFrame)
        boundsCache[inst] = { center, size, weighted }
        return center, size, weighted
    end
    local function shapeCat(inst)
        local _, s = boundsFor(inst)
        local a = { s.X, s.Y, s.Z }
        table.sort(a, function(x, y) return x > y end)
        if a[1] <= 0 then return nil end
        if a[2] / a[1] >= 0.4 then return "gun" end
        return "melee"
    end
    local function sizeOk(inst)
        local _, s = boundsFor(inst)
        if s == Vector3.zero then return false end
        local long = math.max(s.X, s.Y, s.Z)
        return long >= 0.4 and long <= 14
    end
    local function meshSig(inst)
        local cached = meshSigCache[inst]
        if cached ~= nil then return cached end
        local ids = {}
        local function add(d)
            if d:IsA("MeshPart") then
                if d.MeshId ~= "" then ids[#ids + 1] = d.MeshId .. d.TextureID end
            elseif d:IsA("SpecialMesh") then
                if d.MeshId ~= "" then ids[#ids + 1] = d.MeshId .. d.TextureId end
            end
        end
        add(inst)
        local n = 0
        for _, d in ipairs(descendantsOf(inst)) do
            add(d)
            n = n + 1
            if n > 80 then break end
        end
        if #ids == 0 then
            meshSigCache[inst] = ""
            return ""
        end
        table.sort(ids)
        local signature = table.concat(ids, "|", 1, math.min(#ids, 5))
        meshSigCache[inst] = signature
        return signature
    end
    local function meshIdsOf(inst)
        local ids, seen = {}, {}
        local function add(value)
            if type(value) ~= "string" or value == "" or seen[value] then return end
            seen[value] = true
            ids[#ids + 1] = value
        end
        local function inspect(d)
            if d:IsA("MeshPart") then
                add(d.MeshId)
                add(d.TextureID)
            elseif d:IsA("SpecialMesh") then
                add(d.MeshId)
                add(d.TextureId)
            end
        end
        inspect(inst)
        local descendants = descendantsOf(inst)
        for i, d in ipairs(descendants) do
            inspect(d)
            if i % 500 == 0 then task.wait() end
        end
        return ids
    end
    local function catOfTool(t)
        local record = catalogWeaponRecordFromInstance(t)
        return record and record.cat or nil
    end
    local FX_CLASSES = {
        "ParticleEmitter", "Beam", "Trail", "Fire", "Smoke", "Sparkles", "Explosion",
        "PointLight", "SpotLight", "SurfaceLight", "Highlight",
    }
    local KILL_NAMES = { "kill", "elimination", "eliminat", "finisher", "finish", "execution", "execut", "slay", "fatal", "death" }
    local KILL_LIBRARY_NAMES = { "previeweffects", "killeffects", "killeffectlibrary", "killfx", "finishers" }
    local WEAPON_FOLDER_NAMES = {
        knifepartsfolder = true, gunpartsfolder = true,
        weaponassets = true, weaponmodels = true, meleemodels = true, gunmodels = true,
    }
    local killLibraryCache = setmetatable({}, { __mode = "k" })
    local function insideKillLibrary(inst)
        local cached = killLibraryCache[inst]
        if cached ~= nil then return cached end
        local path, p, found = {}, inst, false
        while p and p ~= game do
            local known = killLibraryCache[p]
            if known ~= nil then
                found = known
                break
            end
            path[#path + 1] = p
            if hasAny(squash(p.Name), KILL_LIBRARY_NAMES) then
                found = true
                break
            end
            p = p.Parent
        end
        for _, node in ipairs(path) do killLibraryCache[node] = found end
        return found
    end
    local function isWeaponTreeContent(inst)
        if insideKillLibrary(inst) then return false end
        local cached = weaponTreeCache[inst]
        if cached ~= nil then return cached end
        local path, p, found = {}, inst, false
        while p and p ~= game do
            local known = weaponTreeCache[p]
            if known ~= nil then
                found = known
                break
            end
            path[#path + 1] = p
            if p:IsA("Tool") or p:IsA("Accessory") or p:IsA("Accoutrement") then
                found = true
                break
            end
            local key = squash(p.Name)
            if WEAPON_FOLDER_NAMES[key] then
                found = true
                break
            end
            if (p:IsA("Model") or p:IsA("Folder")) and catOfName(p.Name) then
                found = true
                break
            end
            if p:IsA("Model") or p:IsA("Folder") then
                local hasVisual, hasVfx, hasRoot, hasWeaponChild = false, false, false, false
                for _, child in ipairs(p:GetChildren()) do
                    local childName = squash(child.Name)
                    if childName == "visual" then hasVisual = true end
                    if childName == "vfx" then hasVfx = true end
                    if childName == "root" or childName == "handle" then hasRoot = true end
                    if catOfName(child.Name) then hasWeaponChild = true end
                end
                if (hasVisual and hasVfx and hasRoot) or (hasVfx and hasWeaponChild) then
                    found = true
                    break
                end
            end
            p = p.Parent
        end
        for _, node in ipairs(path) do weaponTreeCache[node] = found end
        return found
    end
    local KILL_BAD = {
        "feed", "streak", "count", "counter", "brick", "zone", "trap", "gui", "hud", "board",
        "announcer", "notification", "message", "script", "remote",
    }
    local KILL_FX_TERMS = { "effect", "efecto", "fx", "vfx", "animation", "anim", "sound", "sfx", "particle", "visual" }
    local function isFx(i)
        for _, c in ipairs(FX_CLASSES) do
            if i:IsA(c) then return true end
        end
        return false
    end
    local fxDescendantPresence, contentDescendantPresence
    local function buildFxPresence(all)
        fxDescendantPresence = fxDescendantPresence or setmetatable({}, { __mode = "k" })
        contentDescendantPresence = contentDescendantPresence or setmetatable({}, { __mode = "k" })
        local startedAt = os.clock()
        local inScan = {}
        for i, inst in ipairs(all) do
            inScan[inst] = true
            fxDescendantPresence[inst] = nil
            contentDescendantPresence[inst] = nil
            if i % 900 == 0 then task.wait(0) end
        end
        -- Clear ancestor flags outside this scan so a changed live model can be
        -- refreshed without erasing the metadata of other independently scanned roots.
        local cleared = {}
        for _, inst in ipairs(all) do
            local parent = inst.Parent
            while parent and parent ~= game and not inScan[parent] and not cleared[parent] do
                cleared[parent] = true
                fxDescendantPresence[parent] = nil
                contentDescendantPresence[parent] = nil
                parent = parent.Parent
            end
        end
        -- allInstances() is parent-before-child DFS order. Reverse traversal propagates
        -- each subtree's FX metadata once, while retaining results from earlier roots.
        for i = #all, 1, -1 do
            local inst = all[i]
            local ownFx = isFx(inst)
            local hasFx = ownFx or fxDescendantPresence[inst] == true
            local hasContent = ownFx or inst:IsA("Sound") or inst:IsA("Animation")
                or contentDescendantPresence[inst] == true
            local parent = inst.Parent
            if parent and parent ~= game then
                if hasFx then fxDescendantPresence[parent] = true end
                if hasContent then contentDescendantPresence[parent] = true end
            end
            if i % 500 == 0 then task.wait(0) end
        end
        return os.clock() - startedAt
    end
    local function skipCommon(inst)
        if inst:GetAttribute("NxTV") then return true end
        if inst:IsA("LuaSourceContainer") or inst:IsA("GuiBase") or inst:IsA("LayerCollector") then return true end
        if inst:IsA("Terrain") or inst:IsA("Camera") or inst:IsA("Humanoid") then return true end
        if inst:IsA("RemoteEvent") or inst:IsA("RemoteFunction") or inst:IsA("BindableEvent") or inst:IsA("BindableFunction") then
            return true
        end
        if inst:IsA("Model") and Players:GetPlayerFromCharacter(inst) then return true end
        return false
    end
    local function skipFx(inst)
        if skipCommon(inst) then return true end
        if inst:IsA("Tool") or inst:IsA("Accessory") or inst:IsA("Accoutrement") then return true end
        if inst:IsA("Model") and inst:FindFirstChildOfClass("Humanoid") then return true end
        if isWeaponTreeContent(inst) then return true end
        return false
    end
    local function weaponRoots()
        local list, seen = {}, {}
        local function add(inst)
            if inst and not seen[inst] then
                seen[inst] = true
                list[#list + 1] = inst
            end
        end

        local replicated = game:GetService("ReplicatedStorage")
        local assets = replicated:FindFirstChild("Assets")
        if assets then
            add(assets:FindFirstChild("Weapons"))
            -- Preview rigs can contain full client-visible weapon models.
            add(assets:FindFirstChild("BundlePreviewSet"))
        end

        local replicatedSkins = replicated:FindFirstChild("ReplicatedSkins")
        if replicatedSkins then
            add(replicatedSkins:FindFirstChild("Weapons"))
        end
        add(game:GetService("StarterPack"))

        -- Workspace stands are a fallback catalogue source, not a source of live targets.
        local ws = Workspace
        local limited = ws:FindFirstChild("LimitedBundle")
        if limited then
            local rigs = limited:FindFirstChild("Rigs")
            if rigs then
                add(rigs:FindFirstChild("RigLeft"))
                add(rigs:FindFirstChild("RigRight"))
            end
        end
        local dia = ws:FindFirstChild("Dia De los MuertosEvent")
        if dia then add(dia:FindFirstChild("Item")) end
        local crate = ws:FindFirstChild("LimitedCrateStand")
        if crate then
            local objects = crate:FindFirstChild("Objects")
            if objects then add(objects) end
        end
        local bench = ws:FindFirstChild("Workbench")
        if bench then
            local model = bench:FindFirstChild("Model")
            if model then add(model:FindFirstChild("Weapons")) end
        end
        local clan = ws:FindFirstChild("ClanStand")
        if clan then add(clan:FindFirstChild("Visuals")) end
        -- DualWieldGunCopies is a live target, not a skin catalogue source.
        -- The dump also places the live clan display under Lobby_Original/Clan.
        local lobby = ws:FindFirstChild("Lobby_Original")
        local clanFolder = lobby and lobby:FindFirstChild("Clan")
        local nestedClan = clanFolder and clanFolder:FindFirstChild("ClanStand")
        if nestedClan then add(nestedClan:FindFirstChild("Visuals")) end

        -- Inventory and actual player rigs.
        for _, player in ipairs(Players:GetPlayers()) do
            local backpack = player:FindFirstChildOfClass("Backpack")
            if backpack then add(backpack) end
            add(player:FindFirstChild("StarterGear"))
            if player.Character then add(player.Character) end
        end
        return list
    end

    local function effectRoots()
        local list, seen = {}, {}
        local function add(inst)
            if inst and not seen[inst] then
                seen[inst] = true
                list[#list + 1] = inst
            end
        end

        local replicated = game:GetService("ReplicatedStorage")
        local assets = replicated:FindFirstChild("Assets")
        if assets then
            add(assets:FindFirstChild("Finishers"))
            add(assets:FindFirstChild("Effects"))
        end

        local replicatedSkins = replicated:FindFirstChild("ReplicatedSkins")
        if replicatedSkins then
            add(replicatedSkins:FindFirstChild("PreviewEffects"))
            add(replicatedSkins:FindFirstChild("Effects"))
        end
        local shared = replicated:FindFirstChild("Shared")
        if shared then add(shared:FindFirstChild("Finishers")) end

        -- Runtime effect containers are explicit roots; never crawl the whole Workspace.
        for _, name in ipairs({ "Effects", "KillEffects", "KillEffectLibrary", "FinisherEffects", "DeathEffects" }) do
            add(Workspace:FindFirstChild(name))
        end
        local character = LocalPlayer.Character
        if character then
            for _, name in ipairs({ "Effects", "KillEffects", "FinisherEffects", "DeathEffects" }) do
                add(character:FindFirstChild(name))
            end
        end
        return list
    end

    local function remoteRoots()
        local list, seen = {}, {}
        local function add(inst)
            if inst and not seen[inst] then
                seen[inst] = true
                list[#list + 1] = inst
            end
        end

        local replicated = game:GetService("ReplicatedStorage")
        add(replicated:FindFirstChild("Remotes"))
        local packages = replicated:FindFirstChild("Packages")
        if packages then
            add(packages:FindFirstChild("Net"))
            local networking = packages:FindFirstChild("Networking")
            if networking then
                add(networking:FindFirstChild("RE"))
                add(networking:FindFirstChild("RF"))
            end
        end
        return list
    end

    local function scanRoots()
        local list, seen = {}, {}
        for _, group in ipairs({ weaponRoots(), effectRoots(), remoteRoots() }) do
            for _, root in ipairs(group) do
                if not seen[root] then
                    seen[root] = true
                    list[#list + 1] = root
                end
            end
        end
        return list
    end

    local function allInstances(roots)
        local list = {}
        local stack = roots or scanRoots()
        local seen = {}
        local processed = 0
        while #stack > 0 do
            local inst = table.remove(stack)
            if inst and not seen[inst] then
                seen[inst] = true
                list[#list + 1] = inst
                local children = inst:GetChildren()
                for i = #children, 1, -1 do
                    stack[#stack + 1] = children[i]
                end
                processed = processed + 1
                -- Yield frequently to keep frame time reasonable on mobile.
                if processed % 90 == 0 then task.wait() end
            end
        end
        return list
    end
    local function cloneComplete(source)
        if not source then return nil end
        local sourceNodes = { source }
        for _, descendant in ipairs(source:GetDescendants()) do
            sourceNodes[#sourceNodes + 1] = descendant
        end

        -- Instance:Clone() omits non-Archivable descendants. Temporarily enable them,
        -- clone synchronously, then restore every source flag before returning.
        local archivable = table.create(#sourceNodes)
        for i, node in ipairs(sourceNodes) do
            local ok, value = pcall(function() return node.Archivable end)
            archivable[i] = ok and value or nil
            if ok and not value then
                pcall(function() node.Archivable = true end)
            end
        end

        local ok, clone = pcall(function() return source:Clone() end)

        -- Restore source state and mirror the original Archivable flags onto the clone.
        local cloneNodes = {}
        if ok and clone then
            cloneNodes[1] = clone
            for _, descendant in ipairs(clone:GetDescendants()) do
                cloneNodes[#cloneNodes + 1] = descendant
            end
        end
        for i = #sourceNodes, 1, -1 do
            local oldValue = archivable[i]
            if oldValue ~= nil then
                pcall(function() sourceNodes[i].Archivable = oldValue end)
                if cloneNodes[i] then
                    pcall(function() cloneNodes[i].Archivable = oldValue end)
                end
            end
        end

        if not ok or not clone then return nil end
        return clone
    end

    local function stripJunk(root)
        -- Keep scripts and every visual descendant in the hierarchy, but disable
        -- executable scripts on the local copy so game/server logic cannot run.
        for _, d in ipairs(root:GetDescendants()) do
            if d:IsA("BaseScript") then
                pcall(function() d.Disabled = true end)
            end
        end
    end
    local function collectAnims(inst)
        local specs, seen = {}, {}
        local function addId(id, name)
            if type(id) == "number" then id = "rbxassetid://" .. tostring(math.floor(id)) end
            if type(id) ~= "string" or id == "" then return end
            if id:match("^%d+$") then id = "rbxassetid://" .. id end
            if seen[id] then return end
            seen[id] = true
            specs[#specs + 1] = { id = id, name = name or "AttributeAnimation" }
        end
        local function add(a)
            if a.AnimationId ~= "" then addId(a.AnimationId, a.Name) end
        end
        if inst:IsA("Animation") then add(inst) end
        for _, d in ipairs(descendantsOf(inst)) do
            if d:IsA("Animation") then add(d) end
        end
        -- Some finishers store animation asset IDs as attributes instead of Animation instances.
        local nodes = { inst }
        for _, d in ipairs(descendantsOf(inst)) do nodes[#nodes + 1] = d end
        for _, node in ipairs(nodes) do
            for key, value in pairs(node:GetAttributes()) do
                local normalized = tostring(key):lower():gsub("[^%w]", "")
                if normalized == "animid" or normalized == "animationid" then
                    addId(value, key)
                end
            end
        end
        return specs
    end
    local function existsInGame(inst)
        if not inst then return false end
        local ok, r = pcall(function() return inst:IsDescendantOf(game) end)
        return ok and r
    end
    local function killContent(i)
        if isFx(i) or i:IsA("Sound") or i:IsA("Animation") then return true end
        if contentDescendantPresence then return contentDescendantPresence[i] == true end
        local cached = killContentCache[i]
        if cached ~= nil then return cached end
        local found = false
        for _, d in ipairs(descendantsOf(i)) do
            if isFx(d) or d:IsA("Sound") or d:IsA("Animation") then
                found = true
                break
            end
        end
        killContentCache[i] = found
        return found
    end
    local function fxInfo(inst)
        local list = {}
        if isFx(inst) then list[#list + 1] = inst end
        local descendants = descendantsOf(inst)
        for i, d in ipairs(descendants) do
            if isFx(d) then list[#list + 1] = d end
            if i % 180 == 0 then task.wait(0) end
        end
        local tex, col, col2
        for _, d in ipairs(list) do
            if d:IsA("ParticleEmitter") or d:IsA("Beam") or d:IsA("Trail") then
                if not tex then
                    local ok, t = pcall(function() return d.Texture end)
                    if ok and t and t ~= "" then tex = t end
                end
                if not col then
                    local okc, ks = pcall(function() return d.Color.Keypoints end)
                    if okc and ks and #ks > 0 then
                        col, col2 = ks[1].Value, ks[#ks].Value
                    end
                end
            elseif not col and (d:IsA("PointLight") or d:IsA("SpotLight") or d:IsA("SurfaceLight")) then
                col = d.Color
            end
        end
        return tex, col, col2 or col, #list
    end
    local function sourcePriority(inst, kind)
        local path = ""
        pcall(function() path = inst:GetFullName():lower() end)
        if kind == "effect" then
            if path:find("previeweffects", 1, true) or path:find("replicatedskins.effects", 1, true) then return 1 end
            if path:find("assets.finishers", 1, true) or path:find("assets.effects", 1, true) then return 2 end
            if path:find("killeffect", 1, true) or path:find("killfx", 1, true) then return 3 end
            return 4
        end
        if inst:IsA("Tool") and (path:find("backpack", 1, true) or path:find("character", 1, true)) then return 1 end
        if path:find("gunpartsfolder", 1, true) or path:find("knifepartsfolder", 1, true) then return 1 end
        if path:find("replicatedskins.weapons", 1, true) then return 2 end
        if path:find("bundlepreviewset", 1, true) then return 3 end
        if path:find("limitedbundle", 1, true) or path:find("limitedcratestand", 1, true)
            or path:find("workbench", 1, true) or path:find("clanstand", 1, true)
            or path:find("diadelosmuertosevent", 1, true) then return 4 end
        return 5
    end
    local function isCachedTemplate(inst)
        if not inst then return false end
        local ok, marker = pcall(function()
            return inst:GetAttribute("NxTVAssetCacheV6") == true
        end)
        return ok and marker == true
    end
    local function cacheQuality(inst)
        local counts = {
            parts = 0, effects = 0, attachments = 0, joints = 0,
            sounds = 0, animations = 0, nodes = 1,
        }
        local nodes = { inst }
        for _, d in ipairs(descendantsOf(inst)) do nodes[#nodes + 1] = d end
        for i, d in ipairs(nodes) do
            counts.nodes = counts.nodes + (d == inst and 0 or 1)
            if d:IsA("BasePart") then counts.parts = counts.parts + 1 end
            if isFx(d) then counts.effects = counts.effects + 1 end
            if d:IsA("Attachment") then counts.attachments = counts.attachments + 1 end
            if d:IsA("Constraint") or d:IsA("JointInstance") then counts.joints = counts.joints + 1 end
            if d:IsA("Sound") then counts.sounds = counts.sounds + 1 end
            if d:IsA("Animation") then counts.animations = counts.animations + 1 end
            if i % 300 == 0 then task.wait(0) end
        end
        -- Prefer complete visual sources (especially their VFX/attachments), then use
        -- source priority as a tie-breaker. No geometry is scaled or simplified.
        local score = counts.parts * 2 + counts.effects * 16 + counts.attachments * 4
            + counts.joints * 3 + counts.sounds * 6 + counts.animations * 2
            + math.min(counts.nodes, 1500) * 0.01
        return score, counts
    end

    local cacheFingerprintMemo = setmetatable({}, { __mode = "k" })
    local function cacheFingerprint(inst, counts)
        local memoized = cacheFingerprintMemo[inst]
        if memoized then return memoized end
        local sig = meshSig(inst)
        counts = counts or select(2, cacheQuality(inst))
        local hashA, hashB, fingerprintLength = 17, 29, 0
        local function feedFingerprint(value)
            local textValue = tostring(value == nil and "" or value)
            fingerprintLength = fingerprintLength + #textValue + 1
            for j = 1, #textValue do
                local byte = string.byte(textValue, j)
                hashA = (hashA * 131 + byte) % 2147483647
                hashB = (hashB * 137 + byte) % 2147483629
            end
            hashA = (hashA * 131 + 31) % 2147483647
            hashB = (hashB * 137 + 31) % 2147483629
        end
        feedFingerprint(sig)
        feedFingerprint(counts.parts or 0)
        feedFingerprint(counts.effects or 0)
        feedFingerprint(counts.attachments or 0)
        feedFingerprint(counts.joints or 0)
        feedFingerprint(counts.sounds or 0)
        feedFingerprint(counts.animations or 0)
        feedFingerprint(counts.nodes or 0)
        local nodes = { inst }
        for _, d in ipairs(descendantsOf(inst)) do nodes[#nodes + 1] = d end
        local referencePart
        if inst:IsA("BasePart") then
            referencePart = inst
        else
            for _, rootName in ipairs({ "Root", "Handle", "KnifeDisplay", "GunDisplay", "Main", "Display" }) do
                local candidate = inst:FindFirstChild(rootName, true)
                if candidate and candidate:IsA("BasePart") then
                    referencePart = candidate
                    break
                end
            end
            if not referencePart then referencePart = inst:FindFirstChildWhichIsA("BasePart", true) end
        end
        local referenceCFrame = referencePart and referencePart.CFrame
        for i, d in ipairs(nodes) do
            local fields = { d.ClassName, d.Name }
            -- Include attributes because several of the game's VFX use attributes
            -- to describe emission count, timing and animation IDs.
            local attributeKeys = {}
            for attributeName in pairs(d:GetAttributes()) do
                attributeKeys[#attributeKeys + 1] = attributeName
            end
            table.sort(attributeKeys)
            for _, attributeName in ipairs(attributeKeys) do
                fields[#fields + 1] = "A:" .. attributeName .. "=" .. tostring(d:GetAttribute(attributeName))
            end
            if d:IsA("BasePart") then
                fields[#fields + 1] = tostring(d.Size)
                fields[#fields + 1] = tostring(d.Color)
                fields[#fields + 1] = tostring(d.Material)
                fields[#fields + 1] = tostring(d.Transparency)
                fields[#fields + 1] = tostring(d.Reflectance)
                fields[#fields + 1] = tostring(d.CastShadow)
                if referenceCFrame then
                    fields[#fields + 1] = tostring(referenceCFrame:ToObjectSpace(d.CFrame))
                end
                if d:IsA("MeshPart") then
                    fields[#fields + 1] = d.MeshId
                    fields[#fields + 1] = d.TextureID
                end
            elseif d:IsA("SpecialMesh") then
                fields[#fields + 1] = d.MeshId
                fields[#fields + 1] = d.TextureId
                fields[#fields + 1] = tostring(d.Scale)
                fields[#fields + 1] = tostring(d.Offset)
            elseif d:IsA("Decal") or d:IsA("Texture") then
                fields[#fields + 1] = d.Texture
                fields[#fields + 1] = tostring(d.Transparency)
                fields[#fields + 1] = tostring(d.Color3)
            elseif d:IsA("ParticleEmitter") then
                for _, propertyName in ipairs({
                    "Texture", "Enabled", "Rate", "Lifetime", "Speed", "Size", "Transparency",
                    "Color", "Rotation", "RotSpeed", "SpreadAngle", "Acceleration", "Drag",
                    "TimeScale", "LightEmission", "LightInfluence", "VelocityInheritance", "ZOffset",
                    "EmissionDirection", "Orientation", "Shape", "ShapeStyle", "ShapeInOut",
                }) do
                    local ok, value = pcall(function() return d[propertyName] end)
                    if ok then fields[#fields + 1] = propertyName .. "=" .. tostring(value) end
                end
            elseif d:IsA("Beam") then
                for _, propertyName in ipairs({
                    "Texture", "Enabled", "Width0", "Width1", "CurveSize0", "CurveSize1",
                    "Color", "Transparency", "Segments", "FaceCamera", "LightEmission",
                    "LightInfluence", "TextureMode", "TextureLength", "TextureSpeed", "ZOffset",
                }) do
                    local ok, value = pcall(function() return d[propertyName] end)
                    if ok then fields[#fields + 1] = propertyName .. "=" .. tostring(value) end
                end
            elseif d:IsA("Trail") then
                for _, propertyName in ipairs({
                    "Texture", "Enabled", "Color", "Transparency", "Lifetime", "MinLength",
                    "MaxLength", "FaceCamera", "LightEmission", "LightInfluence", "TextureMode",
                    "TextureLength", "TextureSpeed",
                }) do
                    local ok, value = pcall(function() return d[propertyName] end)
                    if ok then fields[#fields + 1] = propertyName .. "=" .. tostring(value) end
                end
            elseif d:IsA("Sound") then
                for _, propertyName in ipairs({
                    "SoundId", "Volume", "PlaybackSpeed", "Looped", "TimePosition",
                    "RollOffMaxDistance", "RollOffMinDistance", "PlayOnRemove",
                }) do
                    local ok, value = pcall(function() return d[propertyName] end)
                    if ok then fields[#fields + 1] = propertyName .. "=" .. tostring(value) end
                end
            elseif d:IsA("SurfaceAppearance") then
                fields[#fields + 1] = d.ColorMap
                fields[#fields + 1] = d.NormalMap
                fields[#fields + 1] = d.RoughnessMap
                fields[#fields + 1] = d.MetalnessMap
            elseif d:IsA("Attachment") then
                fields[#fields + 1] = tostring(d.CFrame)
                fields[#fields + 1] = tostring(d.Axis)
                fields[#fields + 1] = tostring(d.SecondaryAxis)
            elseif d:IsA("JointInstance") then
                fields[#fields + 1] = tostring(d.C0)
                fields[#fields + 1] = tostring(d.C1)
                fields[#fields + 1] = tostring(d.Part0 and d.Part0.Name)
                fields[#fields + 1] = tostring(d.Part1 and d.Part1.Name)
            elseif d:IsA("WeldConstraint") then
                fields[#fields + 1] = tostring(d.Part0 and d.Part0.Name)
                fields[#fields + 1] = tostring(d.Part1 and d.Part1.Name)
            end
            for _, field in ipairs(fields) do feedFingerprint(field) end
            feedFingerprint("node-end")
            if i % 240 == 0 then task.wait(0) end
        end
        -- Compact signature of the entire tree and its visual/FX properties.
        local fingerprint = tostring(fingerprintLength) .. ":" .. tostring(hashA) .. ":" .. tostring(hashB)
        cacheFingerprintMemo[inst] = fingerprint
        return fingerprint
    end

    local function cacheTemplate(bucketName, cacheKey, inst, recordData)
        if not inst then return nil end
        local bucket = AssetCache[bucketName]
        if type(bucket) ~= "table" then bucket = {}; AssetCache[bucketName] = bucket end

        local rank = sourcePriority(inst, bucketName == "effects" and "effect" or "weapon")
        local quality, counts = cacheQuality(inst)
        local fingerprint = cacheFingerprint(inst, counts)
        local sourcePath = ""
        pcall(function() sourcePath = inst:GetFullName() end)
        local variantKey = fingerprint

        local record = bucket[cacheKey]
        if type(record) ~= "table" then record = {} end
        record.variants = type(record.variants) == "table" and record.variants or {}

        local variant = record.variants[variantKey]
        local variantValid = variant and isCachedTemplate(variant.template)
        local needsClone = not variantValid
            or quality > (variant.quality or 0)
            or rank < (variant.rank or 99)
        if needsClone then
            local clone = cloneComplete(inst)
            if clone then
                pcall(function()
                    clone:SetAttribute("NxTVAssetCacheV6", true)
                end)
                variant = {
                    template = clone,
                    rank = rank,
                    quality = quality,
                    counts = counts,
                    sourcePath = sourcePath,
                    fingerprint = fingerprint,
                    cachedAt = os.clock(),
                }
                record.variants[variantKey] = variant
                if bucketName == "effects" then
                    AssetCache.stats.effectAdds = (AssetCache.stats.effectAdds or 0) + 1
                elseif bucketName == "knives" then
                    AssetCache.stats.knifeAdds = (AssetCache.stats.knifeAdds or 0) + 1
                else
                    AssetCache.stats.gunAdds = (AssetCache.stats.gunAdds or 0) + 1
                end
            end
        end

        -- Preserve every distinct source variant; the best complete visual is exposed
        -- through record.template for the existing catalogue/apply pipeline.
        local best
        for _, candidate in pairs(record.variants) do
            if candidate and isCachedTemplate(candidate.template) then
                if not best or (candidate.quality or 0) > (best.quality or 0)
                    or ((candidate.quality or 0) == (best.quality or 0)
                        and (candidate.rank or 99) < (best.rank or 99)) then
                    best = candidate
                end
            end
        end

        if best then
            record.template = best.template
            record.rank = best.rank or 99
            record.quality = best.quality or 0
            record.counts = best.counts
            record.sourcePath = best.sourcePath
            record.fingerprint = best.fingerprint
        end
        for key, value in pairs(recordData or {}) do
            if record[key] == nil then record[key] = value end
        end
        record.variantCount = 0
        for _ in pairs(record.variants) do record.variantCount = record.variantCount + 1 end
        record.cachedAt = os.clock()
        bucket[cacheKey] = record
        return record
    end
    local function weaponCacheKey(cat, catalogKey, side)
        return tostring(cat) .. ":" .. squash(catalogKey) .. ":" .. tostring(side or "Default")
    end
    local function cacheWeaponSource(inst, record, side)
        if not record then return nil end
        local cat = record.cat
        local key = weaponCacheKey(cat, record.key, side)
        local section = cat == "melee" and "knives" or "guns"
        return cacheTemplate(section, key, inst, {
            name = record.name, catalogKey = record.key, cat = cat,
            side = side or "Default", tex = record.image,
            rarity = record.rarity or "Unknown", setName = record.setName,
        })
    end
    local function cacheEffectSource(inst, record, tex)
        if not record then return nil end
        return cacheTemplate("effects", squash(record.key), inst, {
            name = record.name, catalogKey = record.key, tex = record.image or tex,
            rarity = record.rarity or "Unknown", setName = record.setName,
        })
    end
    local function addEffect(inst, out, seen, nameOverride, lib, imageOverride, registeredSource, recordOverride)
        if not inst or underNxTV(inst) or (isWeaponTreeContent(inst) and not registeredSource) then return false end
        local record = recordOverride or catalogEffectRecordForName(nameOverride or inst.Name)
        if not record then return false end
        local key = squash(record.key)
        if key == "" then return false end
        local tex, col, col2, count = fxInfo(inst)
        tex = record.image or imageOverride or tex
        local candidateRank = sourcePriority(inst, "effect")
        local cached = cacheEffectSource(inst, record, tex)
        local existing = effectEntriesByKey[key]
        if existing then
            if cached and cached.template then
                existing.cacheTemplate = cached.template
                if not existing.inst or not existsInGame(existing.inst) then
                    existing.inst = cached.template
                    existing.sourceRank = cached.rank or candidateRank
                    existing.sourcePath = cached.sourcePath
                elseif candidateRank <= (existing.sourceRank or 99) then
                    existing.inst = inst
                    existing.sourceRank = candidateRank
                    existing.sourcePath = cached.sourcePath
                end
            end
            existing.tex = record.image
            existing.imgs = record.image and { record.image } or {}
            existing.fxCount = math.max(existing.fxCount or 0, count or 0)
            existing.catalogOnly = false
            existing.inst = existing.inst or inst
            if seen then seen[key] = true end
            return true
        end
        if seen and seen[key] then return false end
        if seen then seen[key] = true end
        local entry = {
            tab = "effects", name = record.name, lname = record.name:lower(), catalogKey = record.key,
            catalogRecord = record, rarity = record.rarity or "Unknown", setName = record.setName,
            inst = inst, tex = record.image, col = col, col2 = col2,
            fxCount = count, priority = isPriority(record.name), lib = lib or false,
            imgs = record.image and { record.image } or {}, cacheTemplate = cached and cached.template or nil,
            sourceRank = candidateRank, sourcePath = cached and cached.sourcePath or nil,
            catalogOnly = false,
        }
        effectEntriesByKey[key] = entry
        out[#out + 1] = entry
        return true
    end
    local function catalogEffectScan(roots, out, seen)
        local replicated = game:GetService("ReplicatedStorage")
        local assets = replicated:FindFirstChild("Assets")
        local replicatedSkins = replicated:FindFirstChild("ReplicatedSkins")
        local candidates = {
            assets and assets:FindFirstChild("Finishers"),
            assets and assets:FindFirstChild("Effects"),
            replicatedSkins and replicatedSkins:FindFirstChild("Effects"),
            replicatedSkins and replicatedSkins:FindFirstChild("PreviewEffects"),
        }
        local candidateSet = {}
        for _, root in ipairs(candidates) do if root then candidateSet[root] = true end end
        for _, root in ipairs(roots or {}) do
            if root and not candidateSet[root] then
                candidateSet[root] = true
                candidates[#candidates + 1] = root
            end
        end
        local function isDedicatedLibrary(root)
            return root ~= nil and (
                (assets and (root == assets:FindFirstChild("Finishers") or root == assets:FindFirstChild("Effects")))
                or (replicatedSkins and (
                    root == replicatedSkins:FindFirstChild("Effects")
                    or root == replicatedSkins:FindFirstChild("PreviewEffects")
                ))
            )
        end
        local claimed = {}
        for _, root in ipairs(candidates) do
            if root then
                local nodes = { root }
                for i, node in ipairs(root:GetDescendants()) do
                    nodes[#nodes + 1] = node
                    if i % 600 == 0 then task.wait(0) end
                end
                for _, node in ipairs(nodes) do
                    if not node:IsA("LuaSourceContainer") then
                        local directRegistryItem = node.Parent == root and isDedicatedLibrary(root)
                            and (node:IsA("Folder") or node:IsA("Model") or node:IsA("BasePart"))
                        local record = catalogEffectRecordForName(node.Name)

                        -- Dedicated effect folders are authoritative. A live game update can
                        -- add entries before the embedded static catalogue is refreshed.
                        if not record and directRegistryItem and killContent(node) then
                            local image = select(1, fxInfo(node))
                            local rarity = node:GetAttribute("Rarity")
                            if type(rarity) ~= "string" or rarity == "" then rarity = "Unknown" end
                            local setName = node:GetAttribute("SetName") or node:GetAttribute("Set")
                            if type(setName) ~= "string" then setName = nil end
                            record = {
                                key = node.Name,
                                name = node.Name,
                                image = catalogImage(node:GetAttribute("Image")) or image,
                                rarity = rarity,
                                setName = setName,
                            }
                            local recordKey = squash(record.key)
                            effectCatalogRecordByKey[recordKey] = record
                            effectCatalog[#effectCatalog + 1] = record
                            registerEffectAlias(record.key, record)
                            registerEffectAlias(record.name, record)
                        end

                        if record and not claimed[squash(record.key)] then
                            local source = node
                            if not (source:IsA("Model") or source:IsA("Folder") or source:IsA("BasePart")) then
                                source = node:FindFirstAncestorOfClass("Model")
                            end
                            if source and killContent(source) then
                                if addEffect(
                                    source, out, seen, record.key, true, record.image,
                                    directRegistryItem == true, record
                                ) then
                                    claimed[squash(record.key)] = true
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    local GENERIC_EFFECT_NODE = {
        model = true, folder = true, effect = true, effects = true, vfx = true,
        fx = true, container = true, object = true, part = true, attachment = true,
        workspace = true, previeweffects = true, killeffects = true,
        killeffectlibrary = true, deatheffects = true,
        root = true, handle = true, humanoidrootpart = true, torso = true,
        uppertorso = true, lowertorso = true, head = true, leftarm = true,
        rightarm = true, leftleg = true, rightleg = true, lefthand = true,
        righthand = true, leftfoot = true, rightfoot = true,
    }
    local function catalogEffectName(node)
        if not node then return nil end
        local function resolve(value)
            local record = catalogEffectRecordForName(value)
            return record and record.name or nil
        end
        local current = node
        local depth = 0
        while current and current ~= game and depth < 4 do
            local matched = resolve(current.Name)
            if matched then return matched end
            for attributeName, value in pairs(current:GetAttributes()) do
                local key = squash(attributeName)
                if key:find("effect", 1, true) or key:find("finisher", 1, true)
                    or key:find("item", 1, true) or key:find("skin", 1, true) then
                    matched = resolve(tostring(value))
                    if matched then return matched end
                end
            end
            current = current.Parent
            depth = depth + 1
        end
        local checked = 0
        for _, descendant in ipairs(descendantsOf(node)) do
            checked = checked + 1
            if checked > 350 then break end
            if descendant:IsA("StringValue") or descendant:IsA("ObjectValue") then
                local matched = resolve(descendant.Name)
                if not matched and descendant:IsA("StringValue") then matched = resolve(descendant.Value) end
                if not matched and descendant:IsA("ObjectValue") and descendant.Value then matched = resolve(descendant.Value.Name) end
                if matched then return matched end
            end
            if checked % 175 == 0 then task.wait(0) end
        end
        return nil
    end
    local function scanRuntimeEffects(root, out, seen, preferredName)
        if not root or not out or not seen then return 0 end
        local before = #out
        local candidates, candidateSet = {}, {}
        local function addCandidate(node)
            if node and not candidateSet[node] and not skipFx(node) and not isWeaponTreeContent(node) then
                candidateSet[node] = true
                candidates[#candidates + 1] = node
            end
        end
        local descendants = descendantsOf(root)
        local rootContainsModels = false
        if root:IsA("Folder") then
            for i, child in ipairs(descendants) do
                if child:IsA("Model") then rootContainsModels = true; break end
                if i % 600 == 0 then task.wait(0) end
            end
        end
        if not rootContainsModels then addCandidate(root) end
        for i, d in ipairs(descendants) do
            if d:IsA("Model") then
                addCandidate(d)
            elseif d:IsA("BasePart") and isFx(d) then
                local model = d:FindFirstAncestorOfClass("Model")
                addCandidate(model or d)
            end
            if i % 500 == 0 then task.wait(0) end
        end
        -- Prefer complete ancestor models, but don't index each nested VFX submodel
        -- separately when an enclosing named effect already owns the same tree.
        table.sort(candidates, function(a, b)
            local da, db = 0, 0
            local p = a
            while p do da = da + 1; p = p.Parent end
            p = b
            while p do db = db + 1; p = p.Parent end
            return da < db
        end)
        local acceptedRoots = {}
        for _, candidate in ipairs(candidates) do
            local covered = false
            for _, accepted in ipairs(acceptedRoots) do
                if candidate ~= accepted and candidate:IsDescendantOf(accepted) then
                    covered = true
                    break
                end
            end
            if not covered and killContent(candidate) then
                local name = catalogEffectName(candidate)
                if not name then
                    local candidateName = tostring(candidate.Name or "")
                    local normalized = squash(candidateName)
                    if candidateName ~= "" and not GENERIC_EFFECT_NODE[normalized] then
                        name = candidateName
                    end
                end
                -- preferredName is only safe when the source itself carries the same
                -- catalogue identity. Never label an unrelated runtime particle as the
                -- user's currently selected effect.
                if name and preferredName and squash(name) == squash(preferredName) then
                    name = preferredName
                end
                if name then
                    local beforeAdd = #out
                    addEffect(candidate, out, seen, name, false)
                    local record = catalogEffectRecordForName(name)
                    if #out > beforeAdd or (record and effectEntriesByKey[squash(record.key)]) then
                        acceptedRoots[#acceptedRoots + 1] = candidate
                    end
                end
            end
        end
        return #out - before
    end

    local function findAssetByName(name)
        local function buildIndex()
            assetIndex = {}
            local counter = 0
            local source = activeScanInstances or {}
            for _, d in ipairs(source) do
                counter = counter + 1
                if counter % 300 == 0 then task.wait() end
                if d ~= workspace and not d:IsDescendantOf(workspace)
                    and (d:IsA("Folder") or d:IsA("Model") or d:IsA("BasePart") or d:IsA("Attachment")
                        or d:IsA("Configuration")) and not skipFx(d) and not isWeaponTreeContent(d)
                    and d.Name ~= "" and killContent(d) then
                    local k = squash(d.Name)
                    if k ~= "" and not assetIndex[k] then assetIndex[k] = d end
                end
            end
        end
        local function findIndexed()
            for _, k in ipairs(nameKeys(name)) do
                if assetIndex[k] then return assetIndex[k] end
            end
            return nil
        end
        if not assetIndex then buildIndex() end
        local found = findIndexed()
        return found
    end
    local KILL_CFG = {
        match = function(n)
            if hasWord(n, KILL_BAD) then return false end
            if not hasAny(n, KILL_NAMES) then return false end
            if hasAny(n, KILL_FX_TERMS) then return true end
            return n:find("s$") ~= nil
                or n == "kill" or n == "death" or n == "elimination" or n == "finisher" or n == "execution"
        end,
        content = killContent,
        plural = function(n)
            return n:find("s$") ~= nil
        end,
        direct = function(c) return isFx(c) end,
        add = addEffect,
        values = true,
        fromValues = function(inst, out, seen)
            for _, c in ipairs(inst:GetChildren()) do
                if c:IsA("ValueBase") then
                    local asset = findAssetByName(c.Name)
                    if asset then addEffect(asset, out, seen, c.Name) end
                end
            end
        end,
    }
    local function scanGeneric(inst, ctx, cfg, out, seen, counter)
        local stack = { { inst = inst, ctx = ctx } }
        while #stack > 0 do
            local node = table.remove(stack)
            local current, inherited = node.inst, node.ctx
            if current and current.Parent and not skipFx(current) then
                counter.n = counter.n + 1
                if counter.n % 180 == 0 then task.wait() end
                local n = norm(current.Name)
                local here = inherited or cfg.match(n)
                local children = current:GetChildren()
                if here and cfg.values then
                    for _, child in ipairs(children) do
                        if child:IsA("ValueBase") then
                            cfg.fromValues(current, out, seen)
                            break
                        end
                    end
                end
                if here and cfg.content(current) then
                    local plural = cfg.plural(n)
                    local holders, direct = 0, 0
                    local canContain = current:IsA("Folder") or current:IsA("Configuration")
                        or current:IsA("Model") or current:IsA("BasePart")
                    if canContain then
                        for _, child in ipairs(children) do
                            if cfg.direct(child) then
                                direct = direct + 1
                            elseif not skipFx(child) and cfg.content(child) then
                                holders = holders + 1
                            end
                        end
                    end
                    local container = (plural and (holders > 0 or direct > 0))
                        or (not inherited and direct == 0 and holders >= 2
                            and (current:IsA("Folder") or current:IsA("Configuration")))
                    if container then
                        for i = #children, 1, -1 do
                            local child = children[i]
                            if cfg.direct(child) then
                                cfg.add(child, out, seen)
                            else
                                stack[#stack + 1] = { inst = child, ctx = true }
                            end
                        end
                    else
                        cfg.add(current, out, seen)
                    end
                else
                    for i = #children, 1, -1 do
                        stack[#stack + 1] = { inst = children[i], ctx = inherited }
                    end
                end
            end
        end
    end
    local function priorityScan(all, out, seen)
        local p1, p2 = {}, {}
        for i, inst in ipairs(all) do
            if i % 1200 == 0 then task.wait() end
            local n = inst.Name:lower()
            if (n:find("hip", 1, true) or n:find("hyp", 1, true)) and isPriority(n) and not seen[n] and not skipFx(inst) then
                if inst:IsA("ValueBase") then
                    local asset = findAssetByName(inst.Name)
                    if not asset then
                        local okv, v = pcall(function() return inst.Value end)
                        if okv and type(v) == "string" and v ~= "" then asset = findAssetByName(v) end
                    end
                    if asset then addEffect(asset, out, seen, inst.Name) end
                elseif inst:IsA("Folder") or inst:IsA("Model") or inst:IsA("Configuration")
                    or inst:IsA("BasePart") or inst:IsA("Attachment") then
                    if killContent(inst) then p1[#p1 + 1] = inst end
                elseif killContent(inst) then
                    p2[#p2 + 1] = inst
                end
            end
        end
        for _, inst in ipairs(p1) do addEffect(inst, out, seen) end
        for _, inst in ipairs(p2) do addEffect(inst, out, seen) end
    end
    local LIB_NAMES = KILL_LIBRARY_NAMES
    local function isHolder(c)
        if isFx(c) then return false end
        if fxDescendantPresence then return fxDescendantPresence[c] == true end
        if c:IsA("Folder") or c:IsA("Model") or c:IsA("Attachment") or c:IsA("BasePart") or c:IsA("Configuration") then
            for _, d in ipairs(descendantsOf(c)) do
                if isFx(d) then return true end
            end
        end
        return false
    end
    local function libraryScan(all, out, seen)
        for i, inst in ipairs(all) do
            if i % 800 == 0 then task.wait() end
            if (inst:IsA("Folder") or inst:IsA("Configuration")) and not skipFx(inst) then
                local key = squash(inst.Name)
                if hasAny(key, LIB_NAMES) and not hasWord(norm(inst.Name), KILL_BAD)
                    and not inst:IsDescendantOf(workspace) and not isWeaponTreeContent(inst) then
                    local kids = inst:GetChildren()
                    if #kids >= 2 then
                        local hold = {}
                        for _, c in ipairs(kids) do
                            if isHolder(c) and not isWeaponTreeContent(c) then
                                hold[#hold + 1] = c
                            end
                        end
                        if #hold >= 2 and #hold / #kids >= 0.7 then
                            for _, c in ipairs(hold) do addEffect(c, out, seen, nil, true) end
                        end
                    end
                end
            end
        end
    end
    local ICON_KEYS = {
        "icon", "iconid", "image", "imageid", "thumb", "thumbnail", "texture", "textureid",
        "picture", "img", "previewimage", "assetimage",
    }
    local function nameIsIcon(n)
        local s = squash(n)
        for _, k in ipairs(ICON_KEYS) do
            if s:find(k, 1, true) then return true end
        end
        return false
    end
    local function assetStr(v)
        if type(v) == "number" then
            if v >= 1000 and v == math.floor(v) then return "rbxassetid://" .. string.format("%d", v) end
            return nil
        end
        if type(v) == "string" then
            if v:find("rbxassetid://", 1, true) or v:find("roblox.com/asset", 1, true) or v:find("rbxthumb", 1, true) then
                return v
            end
            if v:match("^%d%d%d%d%d+$") then return "rbxassetid://" .. v end
        end
        return nil
    end
    local function explicitIcon(inst)
        local list = { inst }
        for _, d in ipairs(descendantsOf(inst)) do list[#list + 1] = d end
        for _, d in ipairs(list) do
            for k, v in pairs(d:GetAttributes()) do
                if nameIsIcon(k) then
                    local a = assetStr(v)
                    if a then return a end
                end
            end
            if d:IsA("ValueBase") and nameIsIcon(d.Name) then
                local okv, v = pcall(function() return d.Value end)
                if okv then
                    local a = assetStr(v)
                    if a then return a end
                end
            end
        end
        return nil
    end
    local function embeddedImage(inst)
        local list = { inst }
        for _, d in ipairs(descendantsOf(inst)) do list[#list + 1] = d end
        for _, d in ipairs(list) do
            if d:IsA("ImageLabel") or d:IsA("ImageButton") then
                if d.Image ~= "" then return d.Image end
            elseif d:IsA("Decal") or d:IsA("Texture") then
                if d.Texture ~= "" then return d.Texture end
            elseif d:IsA("MeshPart") and d.TextureID ~= "" then
                return d.TextureID
            elseif d:IsA("SpecialMesh") and d.TextureId ~= "" then
                return d.TextureId
            end
        end
        return nil
    end
    local WCONT = {
        "weapon", "weaponassets", "weaponmodels", "skin", "skins", "loadout", "arsenal", "armas",
        "equipment", "gunmodels", "meleemodels", "firearms", "bundlepreviewset",
    }
    local function inWeaponContainer(inst)
        local p, depth = inst.Parent, 0
        while p and depth < 6 and p ~= game do
            if hasAny(norm(p.Name), WCONT) then return true end
            p = p.Parent
            depth = depth + 1
        end
        return false
    end
    local WEAPON_SOURCE_FOLDER_NAMES = {
        weapons = true, items = true, item = true, objects = true, visuals = true,
        guns = true, knives = true,
    }
    local function isDirectKnownWeaponSourceChild(inst)
        local parent = inst and inst.Parent
        if not parent then return false end
        local key = squash(parent.Name)
        return WEAPON_SOURCE_FOLDER_NAMES[key] == true or catOfName(parent.Name) ~= nil
    end
    local function underKnownWeaponSourceFolder(inst)
        local p, depth = inst.Parent, 0
        while p and depth < 12 and p ~= game do
            -- Do not promote nested VFX/Visuals models from inside a direct
            -- weapon child, even when that weapon name is absent from the catalog.
            if p:IsA("Model") and (classifyWeapon(p) or isDirectKnownWeaponSourceChild(p)) then
                return false
            end
            local key = squash(p.Name)
            if WEAPON_SOURCE_FOLDER_NAMES[key] or catOfName(p.Name) then
                return true
            end
            if p:IsA("Tool") or p:IsA("Accessory") then return false end
            p = p.Parent
            depth = depth + 1
        end
        return false
    end
    local function toolValid(t)
        for _, d in ipairs(descendantsOf(t)) do
            if d:IsA("BasePart") then return true end
        end
        return false
    end
    local function modelValid(m)
        for _, d in ipairs(descendantsOf(m)) do
            if d:IsA("BasePart") then return true end
        end
        return false
    end
    local function underNxTV(inst)
        local current = inst
        while current and current ~= game do
            if current:GetAttribute("NxTV") or current:GetAttribute("NxTVP") then return true end
            current = current.Parent
        end
        return false
    end
    local function indexW(inst)
        local k = squash(inst.Name)
        if k == "" then return end
        local cur = wIndex[k]
        if not cur or (inst:IsA("Tool") and not cur:IsA("Tool")) then wIndex[k] = inst end
    end
    local function pushWeapon(inst, cat, out, seen, sig, tex, displayName, sideOverride)
        if not inst or underNxTV(inst) then return false end
        local record = catalogWeaponRecordForName(displayName or inst.Name)
            or catalogWeaponRecordFromInstance(inst)
        if not record then return false end
        cat = record.cat
        local itemKey = record.key
        local key = squash(itemKey)
        if key == "" then return false end
        local sourceAlias = squash(displayName or inst.Name)
        local side = sideOverride or weaponCatalogSide[sourceAlias] or "Default"
        local image = record.image
        local candidateRank = sourcePriority(inst, "weapon")
        local cached = cacheWeaponSource(inst, record, side)
        local existing = weaponEntriesByKey[key]
        if existing then
            existing.sourcesBySide = existing.sourcesBySide or {}
            existing.sourceRanks = existing.sourceRanks or {}
            existing.cacheSourcesBySide = existing.cacheSourcesBySide or {}
            existing.cacheSourceRanks = existing.cacheSourceRanks or {}
            local oldRank = existing.sourceRanks[side] or 99
            local candidatePath = ""
            pcall(function() candidatePath = inst:GetFullName() end)
            if not existing.sourcesBySide[side] or candidateRank < oldRank then
                existing.sourcesBySide[side] = inst
                existing.sourceRanks[side] = candidateRank
            end
            if cached and cached.template then
                existing.cacheSourcesBySide[side] = cached.template
                existing.cacheSourceRanks[side] = cached.rank or 99
            end
            if candidateRank < (existing.sourcePriority or 99) or existing.catalogOnly then
                existing.inst = inst
                existing.sourcePriority = candidateRank
                existing.sourcePath = candidatePath
                existing.catalogOnly = false
                existing.isTool = inst:IsA("Tool")
            end
            existing.tex = image
            existing.meshIds = existing.meshIds or {}
            existing.meshSigs = existing.meshSigs or {}
            local knownIds, knownSigs = {}, {}
            for _, id in ipairs(existing.meshIds) do knownIds[id] = true end
            for _, signature in ipairs(existing.meshSigs) do knownSigs[signature] = true end
            local signature = meshSig(inst)
            if signature ~= "" and not knownSigs[signature] then
                knownSigs[signature] = true
                existing.meshSigs[#existing.meshSigs + 1] = signature
            end
            for _, id in ipairs(meshIdsOf(inst)) do
                if not knownIds[id] then knownIds[id] = true; existing.meshIds[#existing.meshIds + 1] = id end
            end
            if seen then seen[key] = true end
            return false
        end
        if seen and seen[key] then return false end
        if seen then seen[key] = true end
        local entry = {
            tab = cat == "melee" and "knives" or "guns", name = record.name,
            lname = record.name:lower(), catalogKey = itemKey, catalogRecord = record,
            inst = inst, tex = image, isTool = inst:IsA("Tool"), cat = cat,
            sourcesBySide = {}, sourceRanks = {}, cacheSourcesBySide = {}, cacheSourceRanks = {},
            meshSig = meshSig(inst), meshSigs = {}, meshIds = meshIdsOf(inst), sourceName = displayName or inst.Name,
            sourcePriority = candidateRank, sourcePath = cached and cached.sourcePath or nil,
        }
        entry.sourcesBySide[side] = inst
        entry.sourceRanks[side] = candidateRank
        if cached and cached.template then
            entry.cacheSourcesBySide[side] = cached.template
            entry.cacheSourceRanks[side] = cached.rank or 99
        end
        if entry.meshSig ~= "" then entry.meshSigs[1] = entry.meshSig end
        weaponEntriesByKey[key] = entry
        out[#out + 1] = entry
        return true
    end
    local function hydrateWeaponCache(out, seen)
        local sections = {
            { name = "knives", cat = "melee", bucket = AssetCache.knives },
            { name = "guns", cat = "gun", bucket = AssetCache.guns },
        }
        for _, section in ipairs(sections) do
            for _, cacheRecord in pairs(section.bucket) do
                local template = cacheRecord and cacheRecord.template
                if template and isCachedTemplate(template) then
                    local catalogRecord = type(cacheRecord.catalogKey) == "string"
                        and catalogWeaponRecordForName(cacheRecord.catalogKey) or nil
                    if catalogRecord and catalogRecord.cat == section.cat then
                        local key = squash(catalogRecord.key)
                        local sideKey = cacheRecord.side or "Default"
                        local entry = weaponEntriesByKey[key]
                        if not entry then
                            entry = {
                                tab = section.name, name = catalogRecord.name, lname = catalogRecord.name:lower(),
                                catalogKey = catalogRecord.key, catalogRecord = catalogRecord,
                                inst = template, tex = catalogRecord.image, isTool = template:IsA("Tool"), cat = section.cat,
                                sourcesBySide = {}, sourceRanks = {}, cacheSourcesBySide = {}, cacheSourceRanks = {},
                                meshSig = meshSig(template), meshSigs = {}, meshIds = meshIdsOf(template),
                                sourceName = catalogRecord.name, sourcePriority = cacheRecord.rank or 99,
                                sourcePath = cacheRecord.sourcePath, cached = true, catalogOnly = false,
                            }
                            weaponEntriesByKey[key] = entry
                            out[#out + 1] = entry
                        end
                        entry.sourcesBySide = entry.sourcesBySide or {}
                        entry.sourceRanks = entry.sourceRanks or {}
                        entry.cacheSourcesBySide = entry.cacheSourcesBySide or {}
                        entry.cacheSourceRanks = entry.cacheSourceRanks or {}
                        entry.cacheSourcesBySide[sideKey] = template
                        entry.cacheSourceRanks[sideKey] = cacheRecord.rank or 99
                        entry.catalogOnly = false
                        if seen then seen[key] = true end
                    end
                end
            end
        end
    end

    local function hydrateWeaponCatalogPlaceholders(out, seen)
        local added = 0
        for _, section in ipairs({
            { records = weaponCatalogRecords.knives, cat = "melee", tab = "knives" },
            { records = weaponCatalogRecords.guns, cat = "gun", tab = "guns" },
        }) do
            for _, record in ipairs(section.records) do
                local key = squash(record.key)
                local existing = weaponEntriesByKey[key]
                if not existing then
                    local entry = {
                        tab = section.tab, name = record.name, lname = record.name:lower(),
                        catalogKey = record.key, catalogRecord = record, inst = nil, tex = record.image,
                        isTool = false, cat = section.cat, sourcePriority = 99,
                        sourcesBySide = {}, sourceRanks = {}, cacheSourcesBySide = {}, cacheSourceRanks = {},
                        meshSigs = {}, meshIds = {}, catalogOnly = true,
                    }
                    weaponEntriesByKey[key] = entry
                    out[#out + 1] = entry
                    if seen then seen[key] = true end
                    added = added + 1
                else
                    existing.tex = record.image
                    existing.catalogRecord = record
                    existing.catalogKey = record.key
                    existing.catalogOnly = existing.catalogOnly == true and not existing.inst
                end
            end
        end
        return added
    end
    local function resolveWeaponSource(entry, side)
        if not entry then return nil end
        local sources = entry.sourcesBySide or {}
        local cached = entry.cacheSourcesBySide or {}
        local liveRanks = entry.sourceRanks or {}
        local cacheRanks = entry.cacheSourceRanks or {}
        local order = {}
        if side then order[#order + 1] = side end
        order[#order + 1] = "Default"
        if side ~= "Right" then order[#order + 1] = "Right" end
        if side ~= "Left" then order[#order + 1] = "Left" end
        for _, key in ipairs(order) do
            local live = sources[key]
            local template = cached[key]
            local cacheValid = isCachedTemplate(template)
            local liveValid = live and existsInGame(live)
            -- The cached model is an exact clone captured while the source existed.
            -- Prefer it so a removed/replaced source cannot change the selected asset.
            if cacheValid then return template end
            if liveValid then return live end
        end
        if entry.inst and existsInGame(entry.inst) then return entry.inst end
        if isCachedTemplate(entry.inst) then return entry.inst end
        return nil
    end
    local function consider(inst, out, seen, sig, ov)
        indexW(inst)
        local knownSource = underKnownWeaponSourceFolder(inst)
        local cat = ov[inst.Name:lower()] or classifyWeapon(inst)
        if not cat then
            if inst:IsDescendantOf(workspace) and not knownSource then return end
            if not knownSource and not inWeaponContainer(inst) then return end
            cat = catOfContent(inst) or shapeCat(inst)
        end
        if not cat then return end
        if not sizeOk(inst) then return end
        pushWeapon(inst, cat, out, seen, sig, nil)
    end
    local function scanWeapons(list, out, seen, sig)
        local char = LocalPlayer.Character
        for i, inst in ipairs(list) do
            if i % 700 == 0 then task.wait(0) end
            if inst:IsA("Tool") and not inst:GetAttribute("NxTV") and not insideKillLibrary(inst)
                and not inst:FindFirstAncestorWhichIsA("Accessory") and toolValid(inst) then
                local record = catalogWeaponRecordFromInstance(inst)
                if record then pushWeapon(inst, record.cat, out, seen, sig) end
            end
        end
        for i, inst in ipairs(list) do
            if i % 700 == 0 then task.wait(0) end
            if inst:IsA("Model") and not insideKillLibrary(inst)
                and not inst:FindFirstAncestorWhichIsA("Tool")
                and not inst:FindFirstAncestorWhichIsA("Accessory")
                and not inst:FindFirstChildOfClass("Humanoid") and modelValid(inst) then
                local rig, ancestor = nil, inst.Parent
                while ancestor and ancestor ~= workspace do
                    if ancestor:IsA("Model") and (ancestor.Name == "RigLeft" or ancestor.Name == "RigRight") then
                        rig = ancestor
                        break
                    end
                    ancestor = ancestor.Parent
                end
                local rigItem = rig and rig:GetAttribute("Item")
                local record = type(rigItem) == "string" and catalogWeaponRecordForName(rigItem) or nil
                local rigVisual = rig and inst.Parent and inst.Parent:IsA("BasePart")
                    and inst:FindFirstChild("Visual") and inst:FindFirstChild("VFX")
                    and (inst:FindFirstChild("Root") or inst:FindFirstChild("Handle"))
                if record and rigVisual then
                    local side = rig.Name == "RigLeft" and "Left" or "Right"
                    pushWeapon(inst, record.cat, out, seen, sig, nil, record.key, side)
                else
                    record = catalogWeaponRecordFromInstance(inst)
                    if record then
                        local insideOtherModel = inst:FindFirstAncestorWhichIsA("Model") ~= nil
                        local directFolderChild = inst.Parent
                            and (inst.Parent:IsA("Folder") or inst.Parent:IsA("Configuration"))
                        if not insideOtherModel or (directFolderChild and underKnownWeaponSourceFolder(inst)) then
                            pushWeapon(inst, record.cat, out, seen, sig)
                        end
                    end
                end
            elseif inst:IsA("BasePart") and not insideKillLibrary(inst)
                and not inst:FindFirstAncestorWhichIsA("Model")
                and not inst:FindFirstAncestorWhichIsA("Tool") then
                local record = catalogWeaponRecordFromInstance(inst)
                if record then pushWeapon(inst, record.cat, out, seen, sig) end
            end
        end
    end
    local GENERIC_UI = {}
    for _, n in ipairs({
        "icon", "image", "frame", "button", "template", "item", "slot", "label", "text", "background", "bg",
        "holder", "container", "content", "close", "title", "shop", "inventory", "main", "list", "scroll",
        "scrollingframe", "textlabel", "imagelabel", "imagebutton", "textbutton", "buy", "equip", "equipped",
        "locked", "price", "name", "desc", "description", "rarity", "count", "amount", "info", "preview",
        "display", "viewport", "top", "bottom", "left", "right", "new", "tab", "tabs", "page", "pages", "menu",
        "topbar", "hud", "gui", "effect", "effects", "knife", "knives", "gun", "guns", "weapon", "weapons",
        "skin", "skins",
    }) do GENERIC_UI[n] = true end
    local function ctxCatOf(p)
        local depth = 0
        while p and depth < 7 do
            local c = catOfName(p.Name)
            if c then return c end
            p = p.Parent
            depth = depth + 1
        end
        return nil
    end
    local function buildGuiMap()
        local roots = {}
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg then roots[#roots + 1] = pg end
        for _, n in ipairs({ "StarterGui", "ReplicatedStorage" }) do
            local ok, s = pcall(function() return game:GetService(n) end)
            if ok and s then roots[#roots + 1] = s end
        end
        local counter = 0
        for _, root in ipairs(roots) do
            local source = {}
            if root == pg then
                source = descendantsOf(root)
            else
                for _, d in ipairs(activeScanInstances or {}) do
                    if d:IsDescendantOf(root) then source[#source + 1] = d end
                end
            end
            for _, d in ipairs(source) do
                counter = counter + 1
                if counter % 220 == 0 then task.wait() end
                if not d:FindFirstAncestor(GUI_NAME) then
                    local img
                    if d:IsA("ImageLabel") or d:IsA("ImageButton") then
                        img = d.Image
                    elseif d:IsA("Decal") or d:IsA("Texture") then
                        img = d.Texture
                    end
                    if img and img ~= "" then
                        local p, depth = d, 0
                        while p and p ~= root and depth < 4 do
                            local k = squash(p.Name)
                            if k ~= "" and not GENERIC_UI[k] and not guiMap[k] then
                                guiMap[k] = img
                                guiCat[k] = ctxCatOf(p)
                            end
                            p = p.Parent
                            depth = depth + 1
                        end
                    elseif d:IsA("TextLabel") or d:IsA("TextButton") then
                        local t = d.Text
                        if #t >= 3 and #t <= 32 and not t:find("^[%d%p%s]+$") then
                            local k = squash(t)
                            if k ~= "" and not GENERIC_UI[k] and not guiMap[k] then
                                local p, depth, found = d.Parent, 0, nil
                                while p and p ~= root and depth < 3 and not found do
                                    for _, c in ipairs(p:GetChildren()) do
                                        if (c:IsA("ImageLabel") or c:IsA("ImageButton")) and c.Image ~= "" then
                                            found = c
                                            break
                                        end
                                    end
                                    p = p.Parent
                                    depth = depth + 1
                                end
                                if found then
                                    guiMap[k] = found.Image
                                    guiCat[k] = ctxCatOf(d)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    local function iconFor(name)
        for _, k in ipairs(nameKeys(name)) do
            if iconMap[k] then return iconMap[k] end
            if guiMap[k] then return guiMap[k] end
        end
        if isPriority(name) then
            for _, term in ipairs(PRIORITY) do
                for k, img in pairs(guiMap) do
                    if k:find(term, 1, true) then return img end
                end
            end
        end
        return nil
    end
    local function attachIcons(effects, weapons)
        local processed = 0
        for _, e in ipairs(effects) do
            processed = processed + 1
            if processed % 12 == 0 then task.wait() end
            local explicit = e.inst and explicitIcon(e.inst) or nil
            local g = iconFor(e.name)
            local embedded = e.inst and embeddedImage(e.inst) or nil
            local imgs, seenI = {}, {}
            for _, v in ipairs({ explicit or "", g or "", embedded or "", e.tex or "" }) do
                if v ~= "" and not seenI[v] then
                    seenI[v] = true
                    imgs[#imgs + 1] = v
                end
            end
            e.imgs = imgs
        end
        for _, w in ipairs(weapons) do
            processed = processed + 1
            if processed % 12 == 0 then task.wait() end
            if not w.tex or w.tex == "" then
                w.tex = (w.inst and explicitIcon(w.inst)) or iconFor(w.name)
                    or (w.inst and embeddedImage(w.inst)) or nil
            end
        end
    end
    local function guiDiscover(wOut, wSeen, wSig)
        local added = 0
        for k, img in pairs(guiMap) do
            local inst = wIndex[k]
            if inst and not wSeen[k] and existsInGame(inst) then
                local cat = guiCat[k] or classifyWeapon(inst) or catOfContent(inst) or shapeCat(inst)
                if cat and sizeOk(inst) then
                    if pushWeapon(inst, cat, wOut, wSeen, wSig, img) then added = added + 1 end
                end
            end
        end
        return added
    end
    local function attachSounds(all, effects)
        local idx, hasSound = {}, {}
        for i, d in ipairs(all) do
            if i % 700 == 0 then task.wait() end
            if d:IsA("Sound") and not d:GetAttribute("NxTV") then
                local p, depth = d, 0
                while p and p ~= game and depth < 8 do
                    hasSound[p] = true
                    local k = squash(p.Name)
                    if k ~= "" then
                        idx[k] = idx[k] or {}
                        if #idx[k] < 4 then table.insert(idx[k], d) end
                    end
                    p = p.Parent
                    depth = depth + 1
                end
            end
        end
        for _, e in ipairs(effects) do
            if not hasSound[e.inst] then
                e.sounds = {}
                for _, k in ipairs(nameKeys(e.name)) do
                    local l = idx[k]
                    if l then
                        for _, sound in ipairs(l) do
                            if #e.sounds < 3 then table.insert(e.sounds, sound) end
                        end
                    end
                end
            end
        end
    end
    M.norm, M.squash, M.hasAny, M.catOfName, M.catOfTool = norm, squash, hasAny, catOfName, catOfTool
    M.isFx = isFx
    M.meshIdsOf = meshIdsOf
    M.loadWeaponCatalog = loadWeaponCatalog
    M.scanRoots, M.allInstances, M.scanWeapons, M.scanGeneric, M.KILL_CFG = scanRoots, allInstances, scanWeapons, scanGeneric, KILL_CFG
    M.weaponRoots, M.effectRoots, M.remoteRoots = weaponRoots, effectRoots, remoteRoots
    M.invalidateScanCaches = function(root)
        local p = root
        while p and p ~= game do
            descendantCache[p] = nil
            partsCache[p] = nil
            meshSigCache[p] = nil
            cacheFingerprintMemo[p] = nil
            weaponTreeCache[p] = nil
            killContentCache[p] = nil
            killLibraryCache[p] = nil
            p = p.Parent
        end
        assetIndex = nil
    end
    M.setActiveScanInstances = function(list)
        activeScanInstances = list
    end
    M.buildFxPresence = buildFxPresence
    M.priorityScan, M.libraryScan = priorityScan, libraryScan
    M.catalogEffectScan = catalogEffectScan
    M.scanRuntimeEffects = scanRuntimeEffects
    M.buildGuiMap, M.guiDiscover, M.attachIcons, M.attachSounds = buildGuiMap, guiDiscover, attachIcons, attachSounds
    M.collectAnims, M.stripJunk, M.existsInGame = collectAnims, stripJunk, existsInGame
    M.cloneComplete = cloneComplete
    M.partsOf, M.boundsIn = partsOf, boundsIn
    M.hydrateWeaponCache, M.resolveWeaponSource = hydrateWeaponCache, resolveWeaponSource
    M.hydrateWeaponCatalogPlaceholders = hydrateWeaponCatalogPlaceholders
    M.resolveEffectSource = function(entry)
        if not entry then return nil end
        local catalogRecord = entry.catalogRecord or catalogEffectRecordForName(entry.catalogKey or entry.name)
        local cacheKey = catalogRecord and squash(catalogRecord.key)
            or squash(entry.catalogKey or entry.name)
        if cacheKey == "" then return nil end
        local cached = AssetCache.effects[cacheKey]
        local template = entry.cacheTemplate
        if not isCachedTemplate(template) and cached then template = cached.template end
        if isCachedTemplate(template) then return template end
        local live = entry.inst
        if live and existsInGame(live) then return live end
        return nil
    end
    M.hydrateEffectCache = function(out, seen)
        for _, cacheRecord in pairs(AssetCache.effects) do
            local template = cacheRecord and cacheRecord.template
            if template and isCachedTemplate(template) then
                local catalogRecord = type(cacheRecord.catalogKey) == "string"
                    and catalogEffectRecordForName(cacheRecord.catalogKey) or nil
                if not catalogRecord and type(cacheRecord.catalogKey) == "string" and cacheRecord.catalogKey ~= "" then
                    catalogRecord = {
                        key = cacheRecord.catalogKey,
                        name = cacheRecord.name or cacheRecord.catalogKey,
                        image = cacheRecord.tex,
                        rarity = cacheRecord.rarity or "Unknown",
                        setName = cacheRecord.setName,
                    }
                    effectCatalogRecordByKey[squash(catalogRecord.key)] = catalogRecord
                    registerEffectAlias(catalogRecord.key, catalogRecord)
                    registerEffectAlias(catalogRecord.name, catalogRecord)
                end
                if catalogRecord then
                    local key = squash(catalogRecord.key)
                    local entry = effectEntriesByKey[key]
                    if not entry then
                        entry = {
                            tab = "effects", name = catalogRecord.name, lname = catalogRecord.name:lower(),
                            catalogKey = catalogRecord.key, catalogRecord = catalogRecord,
                            rarity = catalogRecord.rarity or "Unknown", setName = catalogRecord.setName,
                            inst = template, cacheTemplate = template,
                            tex = catalogRecord.image, imgs = catalogRecord.image and { catalogRecord.image } or {},
                            sourceRank = cacheRecord.rank or 99, sourcePath = cacheRecord.sourcePath,
                            fxCount = 0, priority = isPriority(catalogRecord.name), lib = false,
                        }
                        effectEntriesByKey[key] = entry
                        out[#out + 1] = entry
                    else
                        entry.cacheTemplate = template
                        if not entry.inst or not existsInGame(entry.inst) then
                            entry.inst = template
                            entry.sourceRank = cacheRecord.rank or 99
                        end
                        entry.catalogOnly = false
                        entry.tex = catalogRecord.image
                        entry.imgs = catalogRecord.image and { catalogRecord.image } or {}
                    end
                    if seen then seen[key] = true end
                end
            end
        end
    end
    M.assetCacheStats = function()
        local k, g, e, kv, gv, ev = 0, 0, 0, 0, 0, 0
        local function countBucket(bucket, category)
            local count, variants = 0, 0
            for _, record in pairs(bucket or {}) do
                local catalogRecord
                if type(record) == "table" and type(record.catalogKey) == "string" then
                    if category == "effects" then
                        catalogRecord = catalogEffectRecordForName(record.catalogKey)
                    else
                        catalogRecord = catalogWeaponRecordForName(record.catalogKey)
                    end
                end
                local valid = (category == "effects" and record.template ~= nil)
                    or (catalogRecord ~= nil and catalogRecord.cat == (category == "knives" and "melee" or "gun"))
                if valid then
                    count = count + 1
                    if type(record.variants) == "table" then
                        for _ in pairs(record.variants) do variants = variants + 1 end
                    elseif record.template then
                        variants = variants + 1
                    end
                end
            end
            return count, variants
        end
        k, kv = countBucket(AssetCache.knives, "knives")
        g, gv = countBucket(AssetCache.guns, "guns")
        e, ev = countBucket(AssetCache.effects, "effects")
        return k, g, e, kv, gv, ev,
            AssetCache.stats.knifeAdds or 0,
            AssetCache.stats.gunAdds or 0,
            AssetCache.stats.effectAdds or 0
    end
    M.hydrateEffectCatalogPlaceholders = function(out, seen)
        local added = 0
        for _, record in ipairs(effectCatalog) do
            local key = squash(record.key)
            if not effectEntriesByKey[key] then
                local entry = {
                    tab = "effects", name = record.name, lname = record.name:lower(), catalogKey = record.key,
                    inst = nil, cacheTemplate = nil, tex = record.image,
                    imgs = record.image and { record.image } or {}, fxCount = 0,
                    priority = isPriority(record.name), lib = false, catalogOnly = true,
                }
                effectEntriesByKey[key] = entry
                out[#out + 1] = entry
                if seen then seen[key] = true end
                added = added + 1
            end
        end
        return added
    end
    return M
end)()
local function App()
    local norm, squash, hasAny, catOfName, catOfTool = M.norm, M.squash, M.hasAny, M.catOfName, M.catOfTool
    local isFx = M.isFx
    local loadWeaponCatalog = M.loadWeaponCatalog
    local scanRoots, allInstances, scanWeapons, scanGeneric, KILL_CFG = M.scanRoots, M.allInstances, M.scanWeapons, M.scanGeneric, M.KILL_CFG
    local weaponRoots, effectRoots, remoteRoots = M.weaponRoots, M.effectRoots, M.remoteRoots
    local invalidateScanCaches, setActiveScanInstances = M.invalidateScanCaches, M.setActiveScanInstances
    local buildFxPresence = M.buildFxPresence
    local priorityScan, libraryScan = M.priorityScan, M.libraryScan
    local catalogEffectScan = M.catalogEffectScan
    local buildGuiMap, guiDiscover, attachIcons, attachSounds = M.buildGuiMap, M.guiDiscover, M.attachIcons, M.attachSounds
    local collectAnims, stripJunk, existsInGame = M.collectAnims, M.stripJunk, M.existsInGame
    local cloneComplete = M.cloneComplete
    local partsOf, boundsIn = M.partsOf, M.boundsIn
    local hydrateWeaponCache, resolveWeaponSource = M.hydrateWeaponCache, M.resolveWeaponSource
    local hydrateWeaponCatalogPlaceholders = M.hydrateWeaponCatalogPlaceholders
    local hydrateEffectCache, resolveEffectSource = M.hydrateEffectCache, M.resolveEffectSource
    local hydrateEffectCatalogPlaceholders = M.hydrateEffectCatalogPlaceholders
    local scanRuntimeEffects = M.scanRuntimeEffects
    local assetCacheStats = M.assetCacheStats
    local Kill = {
        entry = nil, deaths = {}, pending = {}, lastAct = 0, lastHit = {}, lastFire = 0,
        hasStat = false, hasRemote = false, statVals = {}, attrVals = {}, folder = nil,
    }
    local function updateMove()
        local weaponTab = activeTab == "knives" or activeTab == "guns"
        btnMove.btn.Visible = weaponTab and Selected[activeTab] ~= nil
        btnMove.label.Text = activeTab == "knives" and "> Pistolas" or "> Cuchillos"
    end
    local function glyph(host, text)
        return new("TextLabel", {
            Parent = host, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = text,
            Font = Enum.Font.Garamond, TextSize = 22, TextColor3 = IC.gold,
        })
    end
    local function fxSwatch(host, entry)
        local f = new("Frame", {
            Parent = host, Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, BorderSizePixel = 0,
        })
        corner(f, 6)
        local c1 = entry.col and entry.col:Lerp(WHITE, 0.3) or IC.gold
        local c2 = entry.col2 and entry.col2:Lerp(WHITE, 0.3) or IC.btnLine
        new("UIGradient", {
            Parent = f, Color = ColorSequence.new(c1, c2), Rotation = 45,
            Transparency = NumberSequence.new(0.35),
        })
        new("TextLabel", {
            Parent = f, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "FX",
            Font = Enum.Font.Garamond, TextSize = 22, TextColor3 = WHITE,
            TextStrokeTransparency = 0.6, TextStrokeColor3 = BLACK,
        })
        return f
    end
    local cards = {}
    local function resolveEntrySource(entry)
        if not entry then return nil end
        if entry.tab == "effects" then
            return resolveEffectSource(entry)
        end
        return resolveWeaponSource(entry, entry.cat == "gun" and "Right" or nil)
    end
    local function buildViewport(host, src, spinOn, effectPreview)
        if not src or not host or not host.Parent then return nil end
        local clone = cloneComplete(src)
        if not clone then return nil end
        stripJunk(clone)

        local parts = {}
        if clone:IsA("BasePart") then parts[#parts + 1] = clone end
        for _, d in ipairs(clone:GetDescendants()) do
            if d:IsA("BasePart") then parts[#parts + 1] = d end
        end
        if #parts == 0 then
            pcall(function() clone:Destroy() end)
            return nil
        end

        -- Viewport copy only: preserve Size/Transparency/Color/Material/Mesh/attachments.
        -- A source's runtime LocalTransparencyModifier is not part of the asset look.
        local mn, mx
        local visibleParts = {}
        for _, part in ipairs(parts) do
            pcall(function() part.LocalTransparencyModifier = 0 end)
            if part.Transparency < 0.99 then visibleParts[#visibleParts + 1] = part end
        end
        local frameParts = #visibleParts > 0 and visibleParts or parts
        for _, part in ipairs(frameParts) do
            local cf, size = part.CFrame, part.Size
            local extent = Vector3.new(
                (math.abs(cf.RightVector.X) * size.X + math.abs(cf.UpVector.X) * size.Y + math.abs(cf.LookVector.X) * size.Z) / 2,
                (math.abs(cf.RightVector.Y) * size.X + math.abs(cf.UpVector.Y) * size.Y + math.abs(cf.LookVector.Y) * size.Z) / 2,
                (math.abs(cf.RightVector.Z) * size.X + math.abs(cf.UpVector.Z) * size.Y + math.abs(cf.LookVector.Z) * size.Z) / 2
            )
            local lo, hi = cf.Position - extent, cf.Position + extent
            if not mn then
                mn, mx = lo, hi
            else
                mn = Vector3.new(math.min(mn.X, lo.X), math.min(mn.Y, lo.Y), math.min(mn.Z, lo.Z))
                mx = Vector3.new(math.max(mx.X, hi.X), math.max(mx.Y, hi.Y), math.max(mx.Z, hi.Z))
            end
        end

        local center = (mn + mx) / 2
        local recenter = CFrame.new(-center)
        if clone:IsA("Model") then
            pcall(function() clone:PivotTo(recenter * clone:GetPivot()) end)
        elseif clone:IsA("BasePart") then
            pcall(function() clone.CFrame = recenter * clone.CFrame end)
        else
            -- Tools/Folders are not PVInstances; translate all parts by one identical offset.
            for _, part in ipairs(parts) do
                pcall(function() part.CFrame = recenter * part.CFrame end)
            end
        end

        local vf = new("ViewportFrame", {
            Parent = host, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
            BorderSizePixel = 0, ClipsDescendants = true,
            Ambient = Color3.fromRGB(190, 190, 190),
            LightColor = Color3.fromRGB(255, 255, 255),
            LightDirection = Vector3.new(-1, -1, -1),
        })
        local world = Instance.new("WorldModel")
        world.Name = "PreviewWorld"
        world.Parent = vf
        -- A wrapper Model provides a common pivot even when the source is a Tool/Folder.
        -- Its WorldPivot is the visual center, so the entire original tree rotates together.
        local previewRoot = Instance.new("Model")
        previewRoot.Name = "PreviewRoot"
        previewRoot.Parent = world
        clone.Parent = previewRoot
        pcall(function() previewRoot.WorldPivot = CFrame.new() end)

        -- Preview-only VFX activation. The original cached template is never modified.
        if effectPreview ~= false then
            for _, d in ipairs(clone:GetDescendants()) do
                if d:IsA("ParticleEmitter") then
                    -- Preserve already-running emitters; disabled emitters get one burst.
                    if not d.Enabled then
                        local count = tonumber(d:GetAttribute("EmitCount"))
                            or math.clamp(math.floor(d.Rate * 0.25 + 8), 8, 28)
                        pcall(function() d:Emit(math.clamp(math.floor(count), 1, 32)) end)
                    end
                elseif d:IsA("Beam") or d:IsA("Trail") or d:IsA("Fire") or d:IsA("Smoke")
                    or d:IsA("Sparkles") or d:IsA("PointLight") or d:IsA("SpotLight")
                    or d:IsA("SurfaceLight") or d:IsA("Highlight") then
                    if not d.Enabled then
                        pcall(function() d.Enabled = true end)
                        task.delay(0.85, function()
                            if d.Parent then pcall(function() d.Enabled = false end) end
                        end)
                    end
                end
            end
        end

        local camera = Instance.new("Camera")
        camera.FieldOfView = 38
        camera.Parent = vf
        vf.CurrentCamera = camera

        local radius = math.max((mx - mn).Magnitude / 2, 0.5)
        local distance = radius / math.sin(math.rad(camera.FieldOfView / 2)) * 1.12
        camera.CFrame = CFrame.lookAt(Vector3.new(distance, distance * 0.38, distance), Vector3.zero)
        if spinOn then
            Spin.views[vf] = {
                camera = camera, model = previewRoot, center = Vector3.zero,
                basePivot = previewRoot:GetPivot(), angle = 0, host = host,
            }
        end
        return vf
    end
    local imageLoadCache = {}
    local function texCandidates(tex)
        local out = {}
        if not tex or tex == "" then return out end
        local original = tostring(tex)
        local seen = {}
        local function add(value)
            if value and value ~= "" and not seen[value] then seen[value] = true; out[#out + 1] = value end
        end
        local id = original:match("(%d%d%d%d%d+)")
        if id then
            add("rbxassetid://" .. id)
            add(original)
            add("https://www.roblox.com/asset/?id=" .. id)
            add("http://www.roblox.com/asset/?id=" .. id)
            add("rbxthumb://type=Asset&id=" .. id .. "&w=150&h=150")
        else
            add(original)
        end
        return out
    end
    local imageLoadQueue = {}
    local imageQueueRunning = false
    local function runImageLoadQueue()
        if imageQueueRunning then return end
        imageQueueRunning = true
        task.spawn(function()
            while #imageLoadQueue > 0 do
                local job = table.remove(imageLoadQueue, 1)
                local img, host = job.img, job.host
                local loaded = false
                if img and img.Parent and host and host.Parent then
                    for _, candidate in ipairs(job.candidates) do
                        if not img.Parent or not host.Parent then break end
                        if imageLoadCache[candidate] == true then
                            img.Image = candidate
                            loaded = true
                            break
                        elseif imageLoadCache[candidate] == false then
                            -- A previous request already rejected this URI in this session.
                        else
                            img.Image = candidate
                            local fetched = false
                            local preloadOk = pcall(function()
                                ContentProvider:PreloadAsync({ img }, function(_, status)
                                    if status == Enum.AssetFetchStatus.Success then fetched = true end
                                end)
                            end)
                            local isLoaded = false
                            pcall(function() isLoaded = img.IsLoaded end)
                            if fetched or isLoaded then
                                imageLoadCache[candidate] = true
                                loaded = true
                                break
                            end
                            if preloadOk then imageLoadCache[candidate] = false end
                        end
                    end
                    if loaded then
                        if job.onLoaded then pcall(job.onLoaded, img) end
                    elseif img.Parent then
                        img:Destroy()
                        if host.Parent and job.onFail then pcall(job.onFail) end
                    end
                end
                task.wait(0.02)
            end
            imageQueueRunning = false
            if #imageLoadQueue > 0 then runImageLoadQueue() end
        end)
    end
    local function loadImageChain(host, texList, onFail, onLoaded)
        local candidates, seen = {}, {}
        for _, tex in ipairs(texList or {}) do
            for _, candidate in ipairs(texCandidates(tex)) do
                if not seen[candidate] then seen[candidate] = true; candidates[#candidates + 1] = candidate end
            end
        end
        if #candidates == 0 then if onFail then onFail() end; return nil end
        local img = new("ImageLabel", {
            Parent = host, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
            ScaleType = Enum.ScaleType.Fit, Image = candidates[1], ImageTransparency = 0,
            BorderSizePixel = 0, ZIndex = 5,
        })
        imageLoadQueue[#imageLoadQueue + 1] = {
            img = img, host = host, candidates = candidates, onFail = onFail, onLoaded = onLoaded,
        }
        runImageLoadQueue()
        return img
    end
    local function renderVisual(host, entry, big)
        local isFxTab = entry.tab == "effects"
        local label = isFxTab and "FX" or (entry.cat == "melee" and "CUCH" or "PIST")
        local function fallback()
            if not host.Parent then return end
            if isFxTab then fxSwatch(host, entry) else glyph(host, label) end
        end

        -- Kill effects intentionally use the same 2D catalog image in cards and detail.
        if isFxTab then
            local image = entry.tex or (entry.catalogRecord and entry.catalogRecord.image)
            local list = image and { image } or entry.imgs
            if list and #list > 0 then loadImageChain(host, list, fallback, nil) else fallback() end
            return
        end

        -- List cards remain 2D. Only the selected knife/gun opens a rotating viewport.
        if big then
            local source = resolveEntrySource(entry)
            if source then
                local viewport = buildViewport(host, source, true, false)
                if viewport then return viewport end
            end
        end
        local image = entry.tex or (entry.catalogRecord and entry.catalogRecord.image)
        if image then loadImageChain(host, { image }, fallback, nil) else fallback() end
    end
    track(RunService.Heartbeat:Connect(function(dt)
        if not Window.Visible then return end
        local now = os.clock()
        if now - Spin.last >= 1 / 12 then
            local step = math.min(now - (Spin.last or now), 0.12)
            Spin.last = now
            for viewport, view in pairs(Spin.views) do
                if not viewport.Parent or not view.camera.Parent then
                    Spin.views[viewport] = nil
                elseif viewport.Visible and view.host and view.host.Visible then
                    view.angle = view.angle + step * 0.72
                    -- Rotate the model itself instead of orbiting the camera. This also
                    -- moves Trail attachments, so sword/gun trails can render in previews.
                    pcall(function()
                        view.model:PivotTo(CFrame.new(view.center) * CFrame.Angles(0, view.angle, 0) * view.basePivot)
                    end)
                end
            end
        end
    end))
    local function showSelected(entry)
        for viewport in pairs(Spin.views) do
            if viewport:IsDescendantOf(previewContent) then Spin.views[viewport] = nil end
        end
        for _, c in ipairs(previewContent:GetChildren()) do c:Destroy() end
        if not entry then
            previewHint.Visible = true
            previewHint.Text = "Sin seleccion"
            nameLabel.Text = "-"
            idLabel.Text = "-"
            updateMove()
            return
        end
        previewHint.Visible = false
        nameLabel.Text = entry.name
        if entry.tab == "effects" then
            local lead = entry.lib and "EFECTO" or "KILL EFFECT"
            idLabel.Text = lead .. " | " .. tostring(entry.fxCount or 0) .. " fx"
        else
            idLabel.Text = entry.cat == "melee" and "CUCHILLO" or "PISTOLA"
        end
        if entry.tab ~= "effects" and not resolveEntrySource(entry) then
            idLabel.Text = idLabel.Text .. " | 3D PENDIENTE"
        elseif entry.tab == "effects" then
            idLabel.Text = idLabel.Text .. " | VISTA 2D"
        end
        renderVisual(previewContent, entry, true)
        updateMove()
    end
    local function positionClonePreservingTree(root, targetCF)
        -- Align the model's real mount/root part to the target while preserving every
        -- descendant's original relative transform and dimensions.
        local sourceRoot
        if root:IsA("BasePart") then
            sourceRoot = root
        else
            for _, name in ipairs({ "Root", "KnifeDisplay", "GunDisplay", "Main", "MainDeathEffect", "Handle", "Display" }) do
                local found = root:FindFirstChild(name, true)
                if found and found:IsA("BasePart") then sourceRoot = found; break end
            end
            if not sourceRoot and root:IsA("Model") and root.PrimaryPart then sourceRoot = root.PrimaryPart end
            if not sourceRoot then sourceRoot = root:FindFirstChildWhichIsA("BasePart", true) end
        end
        if root:IsA("Model") then
            local ok = pcall(function()
                if sourceRoot then
                    local delta = targetCF * sourceRoot.CFrame:Inverse()
                    root:PivotTo(delta * root:GetPivot())
                else
                    root:PivotTo(targetCF)
                end
            end)
            return ok
        elseif root:IsA("BasePart") then
            local ok = pcall(function()
                local delta = targetCF * root.CFrame:Inverse()
                root:PivotTo(delta * root:GetPivot())
            end)
            return ok
        end
        local parts = {}
        for _, d in ipairs(root:GetDescendants()) do
            if d:IsA("BasePart") then parts[#parts + 1] = d end
        end
        if #parts == 0 then return false end
        sourceRoot = sourceRoot or parts[1]
        local delta = targetCF * sourceRoot.CFrame:Inverse()
        for _, part in ipairs(parts) do
            pcall(function() part.CFrame = delta * part.CFrame end)
        end
        return true
    end
    local function triggerVisualTree(root, fallbackDuration)
        if not root then return 0.75 end
        local total = 0.5
        local defaultDuration = math.max(0, tonumber(fallbackDuration) or 0)
        local nodes = { root }
        for _, d in ipairs(root:GetDescendants()) do nodes[#nodes + 1] = d end
        for _, d in ipairs(nodes) do
            local emitDelay = tonumber(d:GetAttribute("EmitDelay")) or tonumber(d:GetAttribute("Delay")) or 0
            local emitDuration = tonumber(d:GetAttribute("EmitDuration")) or 0
            if d:IsA("ParticleEmitter") then
                local rawCount = tonumber(d:GetAttribute("EmitCount")) or 0
                local count = rawCount > 0 and math.clamp(math.ceil(rawCount), 1, 200) or 0
                local life = 1
                pcall(function() life = d.Lifetime.Max end)
                local scaleStart = tonumber(d:GetAttribute("TimeScale_Start"))
                local scaleEnd = tonumber(d:GetAttribute("TimeScale_End"))
                local scaleDuration = tonumber(d:GetAttribute("TimeScale_Duration")) or 0
                if scaleStart ~= nil and scaleEnd ~= nil then
                    local duration = math.max(0, scaleDuration)
                    task.delay(emitDelay, function()
                        if not d.Parent then return end
                        pcall(function() d.TimeScale = math.clamp(scaleStart, 0, 1) end)
                        if duration > 0 then
                            local tweenOk, scaleTween = pcall(function()
                                return TweenService:Create(d, TweenInfo.new(duration), {
                                    TimeScale = math.clamp(scaleEnd, 0, 1),
                                })
                            end)
                            if tweenOk and scaleTween then pcall(function() scaleTween:Play() end) end
                        else
                            pcall(function() d.TimeScale = math.clamp(scaleEnd, 0, 1) end)
                        end
                    end)
                    total = math.max(total, emitDelay + duration)
                end
                total = math.max(total, emitDelay + math.max(life, emitDuration))
                local continuousDuration = emitDuration
                if continuousDuration <= 0 and count == 0 then
                    continuousDuration = defaultDuration
                end
                if continuousDuration > 0 then
                    local previous = d.Enabled
                    total = math.max(total, emitDelay + continuousDuration)
                    task.delay(emitDelay, function()
                        if d.Parent then pcall(function() d.Enabled = true end) end
                    end)
                    task.delay(emitDelay + continuousDuration, function()
                        if d.Parent then pcall(function() d.Enabled = previous end) end
                    end)
                end
                if count > 0 then
                    task.delay(emitDelay, function()
                        if d.Parent then pcall(function() d:Emit(count) end) end
                    end)
                end
            elseif d:IsA("Beam") or d:IsA("Trail") or d:IsA("Fire") or d:IsA("Smoke")
                or d:IsA("Sparkles") or d:IsA("PointLight") or d:IsA("SpotLight")
                or d:IsA("SurfaceLight") or d:IsA("Highlight") then
                local duration = emitDuration > 0 and emitDuration or defaultDuration
                if duration > 0 and d.Enabled == false then
                    local previous = d.Enabled
                    total = math.max(total, emitDelay + duration)
                    task.delay(emitDelay, function()
                        if d.Parent then pcall(function() d.Enabled = true end) end
                    end)
                    task.delay(emitDelay + duration, function()
                        if d.Parent then pcall(function() d.Enabled = previous end) end
                    end)
                end
            elseif d:IsA("Sound") then
                local soundDelay = tonumber(d:GetAttribute("Delay")) or emitDelay
                local length = 4
                pcall(function()
                    if d.TimeLength > 0 then length = d.TimeLength end
                end)
                total = math.max(total, math.min(length, 12) + soundDelay)
                task.delay(soundDelay, function()
                    if d.Parent then
                        pcall(function()
                            d.TimePosition = 0
                            d:Play()
                        end)
                    end
                end)
            end
        end
        return math.clamp(total + 0.5, 0.75, 15)
    end
    local function loadAnimator(char)
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then return nil, nil end
        local animator = hum:FindFirstChildOfClass("Animator")
        if not animator then
            animator = Instance.new("Animator")
            animator.Parent = hum
        end
        return hum, animator
    end
    local function isOurs(d, char)
        local p = d
        while p and p ~= char do
            if p:GetAttribute("NxTV") then return true end
            p = p.Parent
        end
        return false
    end
    local function rootPartOf(v, sourceSide, category)
        if not v then return nil end
        if v:IsA("BasePart") then return v end
        if v:IsA("Tool") or v:IsA("Accessory") then
            local handle = v:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then return handle end
            if v:IsA("Accessory") then return v:FindFirstChildWhichIsA("BasePart", true) end
        end
        if v:IsA("Model") or v:IsA("Folder") then
            local folderName = squash(v.Name)
            local names
            if folderName == "knifepartsfolder" or category == "melee" then
                names = { "KnifeDisplay", "KnifeDisplay2", "Display", "Root", "Handle" }
            elseif folderName == "gunpartsfolder2" or sourceSide == "Left" then
                names = { "GunDisplay2", "GunDisplay", "Display", "Root", "Handle" }
            elseif folderName == "gunpartsfolder" or category == "gun" then
                names = { "GunDisplay", "GunDisplay2", "Display", "Root", "Handle" }
            else
                names = { "KnifeDisplay", "GunDisplay", "GunDisplay2", "KnifeDisplay2", "Display", "Root", "Handle" }
            end
            for _, name in ipairs(names) do
                local candidate = v:FindFirstChild(name, true)
                if candidate and candidate:IsA("BasePart") then return candidate end
            end
            if v:IsA("Model") and v.PrimaryPart then return v.PrimaryPart end
            return v:FindFirstChildWhichIsA("BasePart", true)
        end
        return nil
    end
    local function holsterFolder(char)
        local f = char:FindFirstChild("NxTVHolster")
        if f then return f end
        f = Instance.new("Folder")
        f.Name = "NxTVHolster"
        f:SetAttribute("NxTV", true)
        f.Parent = char
        return f
    end
    local function compOf(v, i)
        if i == 1 then return v.X end
        if i == 2 then return v.Y end
        return v.Z
    end
    local function axisVec(i)
        return Vector3.new(i == 1 and 1 or 0, i == 2 and 1 or 0, i == 3 and 1 or 0)
    end
    local function frameOf(size, off)
        local idx = { 1, 2, 3 }
        local v = { size.X, size.Y, size.Z }
        table.sort(idx, function(a, b)
            if v[a] ~= v[b] then return v[a] > v[b] end
            return a < b
        end)
        local long = v[idx[1]]
        local function sgn1(i)
            local c = compOf(off, i)
            if math.abs(c) < math.max(0.03 * long, 0.01) then return 1 end
            if c > 0 then return 1 end
            return -1
        end
        local x = axisVec(idx[1]) * sgn1(idx[1])
        local y = axisVec(idx[2]) * sgn1(idx[2])
        return CFrame.fromMatrix(Vector3.zero, x, y, x:Cross(y))
    end
    local function catalogVector(value)
        if typeof(value) == "Vector3" then return value end
        if type(value) ~= "table" then return nil end
        local x = tonumber(value.X or value.x or value[1])
        local y = tonumber(value.Y or value.y or (value.x and value[1]) or value[2])
        local z = tonumber(value.Z or value.z or (value.x and value[2]) or value[3])
        if x == nil or y == nil or z == nil then return nil end
        return Vector3.new(x, y, z)
    end
    local function catalogHolsterCFrame(entry, char, sourceSide)
        local record = entry and entry.catalogRecord
        if not record or not char then return nil end
        local transform = record
        if entry.cat == "gun" and record.sideTransforms then
            transform = record.sideTransforms[sourceSide or "Right"] or record
        end
        local offset = catalogVector(transform.offset) or catalogVector(record.offset)
        local angles = catalogVector(transform.angles) or catalogVector(record.angles)
        if not offset or not angles then return nil end
        local basis = char:FindFirstChild("HumanoidRootPart")
            or char:FindFirstChild("LowerTorso") or char:FindFirstChild("Torso")
        if not basis or not basis:IsA("BasePart") then return nil end
        return basis.CFrame * CFrame.new(offset) * CFrame.Angles(angles.X, angles.Y, angles.Z)
    end

    local function buildSkin(entry, origRoot, origParts, origGrip, sourceSide, mountCFrame)
        local src = resolveWeaponSource(entry, sourceSide)
        if not src or not origRoot or not origRoot.Parent then return nil end

        local clone = cloneComplete(src)
        if not clone then return nil end

        -- Keep every descendant, including scripts, effects, attachments, joints and parts.
        -- Executable scripts remain present but disabled inside this local visual clone.
        stripJunk(clone)

        local sourceParts = {}
        if clone:IsA("BasePart") then sourceParts[#sourceParts + 1] = clone end
        for _, d in ipairs(clone:GetDescendants()) do
            if d:IsA("BasePart") then sourceParts[#sourceParts + 1] = d end
        end
        if #sourceParts == 0 then
            pcall(function() clone:Destroy() end)
            return nil
        end

        local sourceRoot
        if clone:IsA("BasePart") then
            sourceRoot = clone
        else
            -- Use the same mount semantic as the live target. The old implementation
            -- always preferred Handle, even when the target was a Root part; this
            -- caused a visible offset and made some weapon models look oversized.
            local preferredName = origRoot.Name
            if type(preferredName) == "string" and preferredName ~= "" then
                local preferred = clone:FindFirstChild(preferredName, true)
                if preferred and preferred:IsA("BasePart") then sourceRoot = preferred end
            end
            if not sourceRoot then
                local preferredNames
                if entry.cat == "melee" then
                    preferredNames = { "KnifeDisplay", "KnifeDisplay2", "Display", "Root", "Handle" }
                elseif sourceSide == "Left" then
                    preferredNames = { "GunDisplay2", "GunDisplay", "Display", "Root", "Handle" }
                else
                    preferredNames = { "GunDisplay", "GunDisplay2", "Display", "Root", "Handle" }
                end
                for _, name in ipairs(preferredNames) do
                    local candidate = clone:FindFirstChild(name, true)
                    if candidate and candidate:IsA("BasePart") then sourceRoot = candidate; break end
                end
            end
            if not sourceRoot and clone:IsA("Model") then
                local primary = clone.PrimaryPart
                if primary and primary:IsA("BasePart") then sourceRoot = primary end
            end
            if not sourceRoot then sourceRoot = clone:FindFirstChildWhichIsA("BasePart", true) end
        end
        if not sourceRoot then sourceRoot = sourceParts[1] end
        if not sourceRoot then
            pcall(function() clone:Destroy() end)
            return nil
        end

        -- A wrapper gives Tool and Model sources a common pivot without flattening
        -- or reparenting any of the source's internal children.
        local model = Instance.new("Model")
        model.Name = "NxTVSkin"
        model:SetAttribute("NxTV", true)
        clone:SetAttribute("NxTV", true)
        clone.Parent = model
        model.PrimaryPart = sourceRoot

        local targetCF = mountCFrame or origRoot.CFrame
        local targetTool = origRoot:FindFirstAncestorWhichIsA("Tool")
        if not mountCFrame and targetTool and typeof(origGrip) == "CFrame" then
            local sourceGrip = src:IsA("Tool") and src.Grip or CFrame.new()
            -- Convert the selected source Tool grip to the currently equipped Handle frame.
            -- Both frames come from the original Tools; no forward axis or arbitrary angle is guessed.
            targetCF = origRoot.CFrame * origGrip:Inverse() * sourceGrip
        end
        local sourceCF = sourceRoot.CFrame
        local delta = targetCF * sourceCF:Inverse()
        local pivotOk = pcall(function()
            model:PivotTo(delta * model:GetPivot())
        end)
        if not pivotOk then
            pcall(function() model:Destroy() end)
            return nil
        end

        -- Physics-only local-clone settings keep the attached copy from colliding with
        -- the player/world. No size, transparency, color, material, texture or VFX is changed.
        for _, part in ipairs(sourceParts) do
            pcall(function()
                -- Clear only an inherited local hide override on the replica.
                part.LocalTransparencyModifier = 0
                part.Anchored = false
                part.CanCollide = false
                part.CanTouch = false
                part.CanQuery = false
                part.Massless = true
            end)
        end

        -- Attach the weapon root to the live mount, then link any loose visual parts
        -- to the source root. Some display models contain decorative parts without
        -- internal joints; leaving them free makes them fall away after equip.
        local connected = { [sourceRoot] = true }
        local connectedOk, connectedParts = pcall(function()
            return sourceRoot:GetConnectedParts(true)
        end)
        if connectedOk then
            for _, part in ipairs(connectedParts) do connected[part] = true end
        end
        for _, part in ipairs(sourceParts) do
            if part ~= sourceRoot and not connected[part] then
                local link = Instance.new("WeldConstraint")
                link.Name = "NxTVVisualPartLink"
                link.Part0 = sourceRoot
                link.Part1 = part
                link.Parent = model
            end
        end

        local attachment = Instance.new("WeldConstraint")
        attachment.Name = "NxTVSkinAttachment"
        attachment.Part0 = origRoot
        attachment.Part1 = sourceRoot
        attachment.Parent = model
        return model
    end
    local Applied = {}
    local SkinLoop = { conn = nil, last = 0, lastRefresh = 0 }
    local projFolderObj
    local function projFolder()
        if projFolderObj and projFolderObj.Parent then return projFolderObj end
        local f = Instance.new("Folder")
        f.Name = "NxTVProj"
        f:SetAttribute("NxTV", true)
        f.Parent = workspace
        projFolderObj = f
        return f
    end
    local function suppressOriginalVisuals(parts)
        local snapshot = {}
        for _, part in ipairs(parts or {}) do
            if part and part.Parent and part:IsA("BasePart") then
                local ok, previous = pcall(function() return part.LocalTransparencyModifier end)
                if ok then
                    snapshot[#snapshot + 1] = { instance = part, value = previous }
                    pcall(function() part.LocalTransparencyModifier = 1 end)
                end
            end
        end
        return snapshot
    end
    local function restoreOriginalVisuals(snapshot)
        for _, item in ipairs(snapshot or {}) do
            local inst = item.instance
            if inst then pcall(function() inst.LocalTransparencyModifier = item.value end) end
        end
    end
    local function ensureOriginalVisualSuppressed(info, target)
        if not info or not target then return end
        info.originalVisualState = info.originalVisualState or {}
        local known, currentParts = {}, {}
        for _, item in ipairs(info.originalVisualState) do
            if item.instance then known[item.instance] = true end
        end
        local function include(part)
            if not part or not part:IsA("BasePart") then return end
            local isClone = false
            local ancestor = part
            while ancestor and ancestor ~= target do
                if ancestor:GetAttribute("NxTV") or ancestor:GetAttribute("NxTVP") then
                    isClone = true
                    break
                end
                ancestor = ancestor.Parent
            end
            if isClone then return end
            currentParts[#currentParts + 1] = part
            if not known[part] then
                local ok, previous = pcall(function() return part.LocalTransparencyModifier end)
                if ok then
                    info.originalVisualState[#info.originalVisualState + 1] = { instance = part, value = previous }
                    known[part] = true
                end
            end
            pcall(function() part.LocalTransparencyModifier = 1 end)
        end
        if target:IsA("BasePart") then include(target) end
        for _, descendant in ipairs(target:GetDescendants()) do
            if descendant:IsA("BasePart") then include(descendant) end
        end
        info.parts = currentParts
        partsCache[target] = currentParts
    end
    local function unskin(info)
        if not info then return end
        -- Restore the exact prior local transparency values before removing our clone.
        restoreOriginalVisuals(info.originalVisualState)
        if info.activatedConn then pcall(function() info.activatedConn:Disconnect() end) end
        if info.model then pcall(function() info.model:Destroy() end) end
    end
    local lastHolsterFxAt = 0
    local lastWeaponFxAt = 0
    local function triggerAppliedHolsterVfx()
        local now = os.clock()
        if now - lastHolsterFxAt < 0.12 then return end
        lastHolsterFxAt = now
        for _, rec in pairs(Applied) do
            for _, info in pairs(rec.targets) do
                if info.kind == "holster" and info.model and info.model.Parent then
                    triggerVisualTree(info.model, 0.35)
                end
            end
        end
    end
    local function triggerAppliedWeaponVfx(targetTool)
        local now = os.clock()
        if now - lastWeaponFxAt < 0.12 then return end
        lastWeaponFxAt = now
        local character = LocalPlayer.Character
        for _, rec in pairs(Applied) do
            for tool, info in pairs(rec.targets) do
                local equipped = tool and tool:IsA("Tool") and character
                    and tool:IsDescendantOf(character)
                if info.kind == "tool" and info.model and info.model.Parent
                    and ((targetTool and tool == targetTool) or (not targetTool and equipped)) then
                    triggerVisualTree(info.model, 0.45)
                end
            end
        end
    end
    local function skinTool(rec, tool)
        local origParts = {}
        for _, p in ipairs(partsOf(tool)) do
            if not p:FindFirstAncestor("NxTVSkin") then origParts[#origParts + 1] = p end
        end
        local handle = tool:FindFirstChild("Handle", true)
        local isHandle = handle ~= nil and handle:IsA("BasePart")
        if not isHandle then handle = rootPartOf(tool) end
        if not isHandle and (not handle or not handle:IsA("BasePart")) then handle = origParts[1] end
        if not handle then return end
        local model = buildSkin(rec.entry, handle, origParts, tool.Grip, rec.cat == "gun" and "Right" or nil)
        if not model then return end
        model.Parent = tool
        local info = {
            kind = "tool", model = model, parts = origParts, root = handle,
            skinParts = partsOf(model), originalVisualState = suppressOriginalVisuals(origParts),
        }
        rec.targets[tool] = info
        local connected, activatedConnection = pcall(function()
            return tool.Activated:Connect(function()
                triggerAppliedWeaponVfx(tool)
                -- InputBegan usually triggers holster-folder effects first; this call is
                -- debounced and remains a fallback for tools consumed by game UI input.
                triggerAppliedHolsterVfx()
            end)
        end)
        if connected then info.activatedConn = activatedConnection end
    end
    local function skinHolster(rec, target, char, sourceSide)
        local root = rootPartOf(target, sourceSide, rec.cat)
        if not root then return end
        local origParts = partsOf(target)
        if #origParts == 0 then return end
        local mountCFrame = catalogHolsterCFrame(rec.entry, char, sourceSide)
        local model = buildSkin(rec.entry, root, origParts, CFrame.new(), sourceSide, mountCFrame)
        if not model then return end
        model.Parent = holsterFolder(char)
        rec.targets[target] = {
            kind = "holster", model = model, parts = origParts, root = root,
            skinParts = partsOf(model), originalVisualState = suppressOriginalVisuals(origParts),
        }
    end
    local function refreshRec(rec)
        local char = LocalPlayer.Character
        local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
        local dead = {}
        for inst, info in pairs(rec.targets) do
            local alive = inst.Parent ~= nil and existsInGame(inst)
            if alive then ensureOriginalVisualSuppressed(info, inst) end
            if alive and info.kind == "holster" then
                local ownedDualCopy = false
                local dualCopies = Workspace:FindFirstChild("DualWieldGunCopies")
                if char and dualCopies and inst:IsDescendantOf(dualCopies) then
                    local owner = inst:FindFirstChild("Owner")
                    ownedDualCopy = owner ~= nil and owner:IsA("ObjectValue") and owner.Value == char
                end
                alive = char ~= nil and (inst:IsDescendantOf(char) or ownedDualCopy)
            end
            if alive and info.kind == "tool" then
                alive = (inst.Parent == bp) or (inst.Parent == char)
            end
            if alive and not info.model.Parent then alive = false end
            if not alive then dead[#dead + 1] = inst end
        end
        for _, inst in ipairs(dead) do
            unskin(rec.targets[inst])
            rec.targets[inst] = nil
        end
        local function claimed(inst)
            for _, r in pairs(Applied) do
                if r ~= rec and r.targets[inst] then return true end
            end
            return false
        end
        for _, container in ipairs({ bp, char }) do
            if container then
                for _, t in ipairs(container:GetChildren()) do
                    if t:IsA("Tool") and not t:GetAttribute("NxTV") and not rec.targets[t] and not claimed(t) then
                        local cc = rec.cc[t]
                        if cc == nil then
                            cc = catOfTool(t) or false
                            rec.cc[t] = cc
                        end
                        if cc == rec.cat then
                            rec.toolNames[squash(t.Name)] = true
                            pcall(skinTool, rec, t)
                        end
                    end
                end
            end
        end
        if char then
            local descendants = char:GetDescendants()
            for _, d in ipairs(descendants) do
                local key = squash(d.Name)
                local folderCat = key == "knifepartsfolder" and "melee"
                    or (key == "gunpartsfolder" or key == "gunpartsfolder2") and "gun" or nil
                if (d:IsA("Folder") or d:IsA("Model")) and folderCat == rec.cat and not rec.targets[d]
                    and not d:FindFirstChildOfClass("Humanoid")
                    and not isOurs(d, char) and not d:FindFirstAncestorWhichIsA("Tool")
                    and not claimed(d) then
                    pcall(skinHolster, rec, d, char, key == "gunpartsfolder2" and "Left" or (rec.cat == "gun" and "Right" or nil))
                end
            end
            if rec.cat == "gun" then
                local dualCopies = Workspace:FindFirstChild("DualWieldGunCopies")
                if dualCopies then
                    for _, copy in ipairs(dualCopies:GetChildren()) do
                        local owner = copy:FindFirstChild("Owner")
                        if owner and owner:IsA("ObjectValue") and owner.Value == char
                            and not rec.targets[copy] and not claimed(copy) then
                            pcall(skinHolster, rec, copy, char, "Left")
                        end
                    end
                end
            end
            for _, d in ipairs(descendants) do
                if (d:IsA("Model") or d:IsA("BasePart") or d:IsA("Accessory")) and not rec.targets[d]
                    and not isOurs(d, char) and not d:FindFirstAncestorWhichIsA("Tool") then
                    if catOfName(d.Name) == rec.cat or rec.toolNames[squash(d.Name)] then
                        if not claimed(d) then
                            local nested = false
                            for t in pairs(rec.targets) do
                                if t ~= d and d:IsDescendantOf(t) then
                                    nested = true
                                    break
                                end
                            end
                            local inSecondGunFolder = d:FindFirstAncestor("GunPartsFolder2") ~= nil
                            local sourceSide = rec.cat == "gun" and (inSecondGunFolder and "Left" or "Right") or nil
                            if not nested then pcall(skinHolster, rec, d, char, sourceSide) end
                        end
                    end
                end
            end
        end
    end
    local function stepRec(rec)
        -- Re-assert the reversible local replacement only on the original target parts.
        -- The cached replica is excluded; no property of the replica's visual geometry,
        -- transparency, texture, materials or VFX is modified here.
        for _, info in pairs(rec.targets) do
            for _, part in ipairs(info.parts or {}) do
                if part and part.Parent then
                    pcall(function()
                        if part.LocalTransparencyModifier ~= 1 then
                            part.LocalTransparencyModifier = 1
                        end
                    end)
                end
            end
        end
        local gone
        local now = os.clock()
        for inst, info in pairs(rec.proj) do
            local targetAlive = inst.Parent ~= nil
            local rootAlive = info.root ~= nil and info.root.Parent ~= nil
            if targetAlive and rootAlive then
                info.lostAt = nil
            else
                -- Keep the local replacement during a short replication reparenting gap.
                info.lostAt = info.lostAt or now
                if now - info.lostAt >= 0.4 then
                    gone = gone or {}
                    gone[#gone + 1] = inst
                end
            end
        end
        if gone then
            for _, inst in ipairs(gone) do
                local info = rec.proj[inst]
                rec.proj[inst] = nil
                if info and info.model then pcall(function() info.model:Destroy() end) end
            end
        end
    end
    local function startLoop()
        if SkinLoop.conn then return end
        SkinLoop.last = 0
        SkinLoop.lastRefresh = 0
        SkinLoop.conn = RunService.Heartbeat:Connect(function()
            local now = os.clock()
            -- No per-frame descendant scans. Visual enforcement runs at 5 Hz;
            -- expensive character discovery/refresh runs once per second.
            if now - SkinLoop.last < 0.2 then return end
            SkinLoop.last = now
            local refresh = now - SkinLoop.lastRefresh >= 1.0
            if refresh then SkinLoop.lastRefresh = now end
            for _, rec in pairs(Applied) do
                if refresh then pcall(refreshRec, rec) end
                pcall(stepRec, rec)
            end
        end)
    end
    local function oursDeep(d)
        local p, depth = d, 0
        while p and p ~= workspace and depth < 8 do
            if p:GetAttribute("NxTV") or p:GetAttribute("NxTVP") then return true end
            p = p.Parent
            depth = depth + 1
        end
        return false
    end
    local function charLike(m)
        local p = m
        while p and p ~= workspace do
            if p:IsA("Model") and p:FindFirstChildOfClass("Humanoid") then return true end
            p = p.Parent
        end
        return false
    end
    local function meleeNamed(d)
        if catOfName(d.Name) == "melee" then return true end
        local p = d.Parent
        if p and p ~= workspace and catOfName(p.Name) == "melee" then return true end
        return false
    end
    local function isLikelyProjectile(d)
        local projectileTerms = { "knife", "dagger", "cuchillo", "kunai", "scythe", "guadana" }
        local name = norm(d.Name)
        if hasAny(name, projectileTerms) then return true end
        local parent = d.Parent
        return parent ~= nil and hasAny(norm(parent.Name), projectileTerms)
    end
    local projectileSeen = setmetatable({}, { __mode = "k" })
    local function tryProjectile(d)
        local rec = Applied.melee
        if not rec or not d.Parent or not isLikelyProjectile(d) then return end
        if os.clock() - Kill.lastAct > 3.2 then return end
        if oursDeep(d) then return end
        if d:FindFirstAncestorWhichIsA("Tool") or d:FindFirstAncestorOfClass("Backpack") then return end
        local target = d
        if d:IsA("BasePart") and d.Parent and d.Parent:IsA("Model") and d.Parent ~= workspace
            and not d.Parent:FindFirstChildOfClass("Humanoid") then
            target = d.Parent
        end
        if charLike(target) then return end
        if not (meleeNamed(target) or meleeNamed(d)) then return end
        task.wait()
        if not target.Parent or projectileSeen[target] or rec ~= Applied.melee then return end
        local root = target:IsA("Model") and target.PrimaryPart or nil
        root = root and root:IsA("BasePart") and root or rootPartOf(target)
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root or not hrp then return end
        if (root.Position - hrp.Position).Magnitude > 16 then return end
        projectileSeen[target] = true
        local origParts = partsOf(target)
        local model = buildSkin(rec.entry, root, origParts, CFrame.new(), nil)
        if not model then
            projectileSeen[target] = nil
            return
        end
        model.Parent = projFolder()
        rec.proj[target] = { model = model, parts = origParts, root = root, lostAt = nil }
    end
    local function dropWeapon(cat)
        local rec = Applied[cat]
        if not rec then return end
        Applied[cat] = nil
        if rec.projConn then pcall(function() rec.projConn:Disconnect() end) end
        for _, info in pairs(rec.targets) do pcall(unskin, info) end
        for _, info in pairs(rec.proj) do pcall(unskin, info) end
        rec.targets, rec.proj = {}, {}
        if next(Applied) == nil and SkinLoop.conn then
            SkinLoop.conn:Disconnect()
            SkinLoop.conn = nil
        end
    end
    local function applyWeapon(entry)
        local cat = entry.cat
        if cat ~= "melee" and cat ~= "gun" then return false, "Categoria invalida." end
        if not resolveWeaponSource(entry, nil) then return false, "No hay un modelo disponible en la caché ni en el cliente." end
        if Applied[cat] then dropWeapon(cat) end
        local rec = { cat = cat, entry = entry, targets = {}, proj = {}, toolNames = {}, cc = {} }
        Applied[cat] = rec
        if cat == "melee" then
            rec.projConn = workspace.DescendantAdded:Connect(function(d)
                if os.clock() - Kill.lastAct < 3.2 and (d:IsA("BasePart") or d:IsA("Model")) then
                    task.defer(tryProjectile, d)
                end
            end)
        end
        startLoop()
        pcall(refreshRec, rec)
        local n, tools, holsters = 0, 0, 0
        for _, info in pairs(rec.targets) do
            n = n + 1
            if info.kind == "tool" then tools = tools + 1 end
            if info.kind == "holster" then holsters = holsters + 1 end
        end
        if n == 0 then
            local what = cat == "melee" and "cuchillo" or "pistola"
            return true, "Skin preparada: " .. entry.name .. ". Aún no detecto el " .. what
                .. " equipado ni su carpeta visual; seguiré observando su aparición."
        end
        return true, "Skin aplicada: " .. entry.name .. " | Tool: " .. tools .. " | visual enfundada: " .. holsters
    end
    local function killFolder()
        if Kill.folder and Kill.folder.Parent then return Kill.folder end
        local f = Instance.new("Folder")
        f.Name = "NxTVKillFx"
        f:SetAttribute("NxTV", true)
        f.Parent = workspace
        Kill.folder = f
        return f
    end
    local function playOnVictim(specs, char)
        if #specs == 0 then return end
        local _, animator = loadAnimator(char)
        if not animator then return end
        for _, spec in ipairs(specs) do
            local a = Instance.new("Animation")
            a.AnimationId = spec.id
            local ok, tr = pcall(function() return animator:LoadAnimation(a) end)
            if ok and tr then
                pcall(function()
                    tr.Priority = Enum.AnimationPriority.Action4
                    tr:Play(0.05)
                end)
                task.delay(8, function() pcall(function() tr:Stop(0.2) end) end)
            end
        end
    end
    local function playKillEffect(entry, d)
        local src = resolveEffectSource(entry)
        if not src then return end
        local c = cloneComplete(src)
        if not c then return end
        local specs = collectAnims(c)
        stripJunk(c)
        local holder = Instance.new("Folder")
        holder.Name = "NxTVKill_" .. entry.name
        holder:SetAttribute("NxTV", true)
        holder.Parent = killFolder()
        c.Parent = holder
        -- Finisher geometry is a local static visual. Anchor only its cloned BaseParts
        -- so unjointed effect pieces cannot fall away from their original attachments.
        -- Meshes, sizes, textures, transparency and all VFX instances remain unchanged.
        for _, part in ipairs(partsOf(c)) do
            pcall(function()
                part.LocalTransparencyModifier = 0
                part.Anchored = true
                part.CanCollide = false
                part.CanTouch = false
                part.CanQuery = false
            end)
        end
        local positioned = positionClonePreservingTree(c, d.cf)
        if not positioned then
            local victimRoot = d.char and (d.char:FindFirstChild("HumanoidRootPart") or d.char:FindFirstChild("Torso"))
            if victimRoot then
                -- Reparent only the cloned root. Never split or discard descendants;
                -- the effect's internal hierarchy and attachments remain intact.
                pcall(function() c.Parent = victimRoot end)
                if c:IsA("Attachment") then
                    pcall(function() c.CFrame = victimRoot.CFrame:ToObjectSpace(d.cf) end)
                end
            end
        end
        playOnVictim(specs, d.char)
        local total = triggerVisualTree(c, 1.0)
        task.delay(total, function()
            pcall(function() c:Destroy() end)
            pcall(function() holder:Destroy() end)
        end)
    end
    local function nameIsMe(v)
        if typeof(v) == "Instance" then
            return v == LocalPlayer or (LocalPlayer.Character ~= nil and v == LocalPlayer.Character)
        end
        if type(v) == "number" then return v == LocalPlayer.UserId end
        if type(v) == "string" then
            return v == LocalPlayer.Name or v == LocalPlayer.DisplayName or v == tostring(LocalPlayer.UserId)
        end
        return false
    end
    local function argIsMe(v, depth)
        if nameIsMe(v) then return true end
        if type(v) == "table" and depth < 2 then
            for _, x in pairs(v) do
                if argIsMe(x, depth + 1) then return true end
            end
        end
        return false
    end
    local TAG_NAMES = { "creator", "Creator", "killer", "Killer", "LastAttacker", "LastDamager", "KilledBy" }
    local function taggedMine(hum, char, victimPlayer)
        local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
        for _, holder in ipairs({ hum, char, root }) do
            if holder then
                for _, tn in ipairs(TAG_NAMES) do
                    local tag = holder:FindFirstChild(tn)
                    if tag and tag:IsA("ValueBase") then
                        local okv, val = pcall(function() return tag.Value end)
                        if okv and nameIsMe(val) then return true end
                    end
                    local attr = holder:GetAttribute(tn)
                    if attr ~= nil and nameIsMe(attr) then return true end
                end
            end
        end

        -- Tool creator values are useful only when this victim was recently damaged
        -- during a local action; a stale creator tag alone must never credit a kill.
        local lastHit = victimPlayer and Kill.lastHit[victimPlayer]
        if not lastHit or os.clock() - lastHit > 3 then return false end
        local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
        for _, container in ipairs({ LocalPlayer.Character, backpack }) do
            if container then
                for _, tool in ipairs(container:GetChildren()) do
                    if tool:IsA("Tool") then
                        for _, d in ipairs(tool:GetDescendants()) do
                            if d:IsA("ObjectValue") and d.Name:lower():find("creator", 1, true) then
                                local okv, value = pcall(function() return d.Value end)
                                if okv and value == LocalPlayer then return true end
                            end
                        end
                    end
                end
            end
        end
        return false
    end
    local function fireKill(d)
        if d.fired then return end
        d.fired = true
        local entry = Kill.entry
        if not entry then return end
        if not resolveEffectSource(entry) then
            setStatus("No hay un modelo de efecto disponible en la caché ni en el cliente.", T.warn)
            return
        end
        Kill.lastFire = os.clock()
        setStatus("Kill: " .. d.name, T.green)
        task.spawn(function() pcall(playKillEffect, entry, d) end)
    end
    local function tryMatch()
        local now = os.clock()
        for i = #Kill.pending, 1, -1 do
            if now - Kill.pending[i] > 3.5 then table.remove(Kill.pending, i) end
        end
        while #Kill.pending > 0 do
            local credit = Kill.pending[1]
            local best, bd
            for _, d in ipairs(Kill.deaths) do
                if not d.fired and not d.consumed then
                    local dt = math.abs(d.t - credit)
                    if dt <= 3.5 and (not bd or dt < bd) then best, bd = d, dt end
                end
            end
            if not best then return end
            table.remove(Kill.pending, 1)
            best.consumed = true
            fireKill(best)
        end
    end
    local function addCredit()
        local now = os.clock()
        if now - Kill.lastFire < 2 then return end
        local last = Kill.pending[#Kill.pending]
        if last and now - last < 1.2 then return end
        Kill.pending[#Kill.pending + 1] = now
        tryMatch()
    end
    local function hookCharacter(p, char)
        task.spawn(function()
            local hum = char:WaitForChild("Humanoid", 10)
            if not hum then return end
            local last = hum.Health
            local dead = false
            local function onDead()
                if dead then return end
                dead = true
                local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
                    or char:FindFirstChild("Head")
                local cf = hrp and hrp.CFrame or CFrame.new(0, 0, 0)
                local now = os.clock()
                local d = {
                    player = p, char = char, cf = cf, t = now, name = p.DisplayName,
                    fired = false, consumed = false,
                }
                Kill.deaths[#Kill.deaths + 1] = d
                for i = #Kill.deaths, 1, -1 do
                    if now - Kill.deaths[i].t > 8 then table.remove(Kill.deaths, i) end
                end
                if taggedMine(hum, char, p) then
                    d.consumed = true
                    fireKill(d)
                elseif Kill.hasStat or Kill.hasRemote then
                    tryMatch()
                else
                    local lh = Kill.lastHit[p]
                    if lh and now - lh < 3 then
                        d.consumed = true
                        fireKill(d)
                    end
                end
            end
            hum.HealthChanged:Connect(function(h)
                if h < last and os.clock() - Kill.lastAct < 1.5 then
                    local mine = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local theirs = char:FindFirstChild("HumanoidRootPart")
                    if mine and theirs and (mine.Position - theirs.Position).Magnitude < 400 then
                        Kill.lastHit[p] = os.clock()
                    end
                end
                last = h
                if h <= 0 then onDead() end
            end)
            hum.Died:Connect(onDead)
        end)
    end
    local function hookPlayer(p)
        if p == LocalPlayer then return end
        if p.Character then hookCharacter(p, p.Character) end
        track(p.CharacterAdded:Connect(function(char) hookCharacter(p, char) end))
    end
    local KILL_STAT = { "kill", "elim", "frag", "takedown", "kos" }
    local function statLike(name)
        return hasAny(norm(name), KILL_STAT)
    end
    local function hookStat(v)
        if Kill.statVals[v] ~= nil then return end
        Kill.statVals[v] = v.Value
        Kill.hasStat = true
        track(v.Changed:Connect(function(nv)
            local oldv = Kill.statVals[v]
            Kill.statVals[v] = nv
            if type(nv) == "number" and type(oldv) == "number" and nv > oldv then
                addCredit()
            end
        end))
    end
    local REMOTE_TERMS = { "kill", "elim", "knock", "defeat", "slain" }
    local function onRemote(...)
        local args = table.pack(...)
        for i = 1, args.n do
            if argIsMe(args[i], 0) then
                Kill.hasRemote = true
                addCredit()
                return
            end
        end
    end
    local hookedRemotes = setmetatable({}, { __mode = "k" })
    local function hookRemoteInstance(d)
        if not d or not d:IsA("RemoteEvent") or hookedRemotes[d] then return end
        if not hasAny(norm(d.Name), REMOTE_TERMS) then return end
        hookedRemotes[d] = true
        track(d.OnClientEvent:Connect(onRemote))
    end
    local function hookRemotes(instances)
        local n = 0
        for i, d in ipairs(instances or {}) do
            if i % 900 == 0 then task.wait() end
            if d:IsA("RemoteEvent") and hasAny(norm(d.Name), REMOTE_TERMS) then
                n = n + 1
                if n > 40 then break end
                hookRemoteInstance(d)
            end
        end
    end
    local function hookLocalToolRemotes(container)
        if not container then return end
        for _, d in ipairs(container:GetDescendants()) do hookRemoteInstance(d) end
        track(container.DescendantAdded:Connect(hookRemoteInstance))
    end
    local function hookLocalToolContainers()
        local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
        local character = LocalPlayer.Character
        hookLocalToolRemotes(backpack)
        hookLocalToolRemotes(character)
        track(LocalPlayer.ChildAdded:Connect(function(child)
            if child:IsA("Backpack") then hookLocalToolRemotes(child) end
        end))
        track(LocalPlayer.CharacterAdded:Connect(function(char)
            hookLocalToolRemotes(char)
        end))
    end
    local function initKills()
        for _, p in ipairs(Players:GetPlayers()) do hookPlayer(p) end
        hookLocalToolContainers()
        track(Players.PlayerAdded:Connect(hookPlayer))
        track(UIS.InputBegan:Connect(function(input, gameProcessed)
            local t = input.UserInputType
            if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch
                or t == Enum.UserInputType.Keyboard or t == Enum.UserInputType.Gamepad1 then
                Kill.lastAct = os.clock()
            end
            local attackInput = t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch
                or (t == Enum.UserInputType.Gamepad1 and (input.KeyCode == Enum.KeyCode.ButtonR2
                    or input.KeyCode == Enum.KeyCode.ButtonL2))
            if attackInput and not gameProcessed and not UIS:GetFocusedTextBox() then
                triggerAppliedWeaponVfx()
                triggerAppliedHolsterVfx()
            end
        end))
        for _, d in ipairs(LocalPlayer:GetDescendants()) do
            if (d:IsA("IntValue") or d:IsA("NumberValue")) and statLike(d.Name)
                and not d:FindFirstAncestorOfClass("Backpack") then
                hookStat(d)
            end
        end
        track(LocalPlayer.DescendantAdded:Connect(function(d)
            if (d:IsA("IntValue") or d:IsA("NumberValue")) and statLike(d.Name) then hookStat(d) end
        end))
        for name, val in pairs(LocalPlayer:GetAttributes()) do
            if statLike(name) and type(val) == "number" then
                Kill.attrVals[name] = val
                Kill.hasStat = true
            end
        end
        track(LocalPlayer.AttributeChanged:Connect(function(name)
            if not statLike(name) then return end
            local v = LocalPlayer:GetAttribute(name)
            if type(v) ~= "number" then return end
            local oldv = Kill.attrVals[name]
            Kill.attrVals[name] = v
            Kill.hasStat = true
            if oldv ~= nil and v > oldv then addCredit() end
        end))
        -- Tool-local remotes are hooked separately because they are outside shared net folders.
    end
    local View = { token = 0, built = 0, limit = PAGE, list = {}, more = nil }
    cards = {}
    local function isApplied(entry)
        if entry.tab == "effects" then
            return Kill.entry == entry
        end
        local rec = Applied[entry.cat]
        return rec ~= nil and rec.entry == entry
    end
    paintCards = function()
        for entry, c in pairs(cards) do
            if c.card.Parent then
                local sel = Selected[entry.tab] == entry
                c.st.Color = sel and IC.gold or IC.btnLine
                c.st.Transparency = sel and 0.05 or 0.7
                c.dot.Visible = isApplied(entry)
            end
        end
    end
    local function selectEntry(entry)
        Selected[entry.tab] = entry
        showSelected(entry)
        paintCards()
    end
    local function makeCard(entry, order, parent)
        local card = new("TextButton", {
            Parent = parent or listFrame, BackgroundColor3 = IC.btnBg, BackgroundTransparency = 0.35,
            AutoButtonColor = false, Text = "", BorderSizePixel = 0, LayoutOrder = order,
        })
        corner(card, 5)
        local st = stroke(card, IC.btnLine, 1, 0.7)
        local imgHost = new("Frame", {
            Parent = card, Position = UDim2.fromOffset(4, 4), Size = UDim2.new(1, -8, 0, 54),
            BackgroundTransparency = 1, BorderSizePixel = 0, ClipsDescendants = true,
        })
        renderVisual(imgHost, entry, false)
        new("TextLabel", {
            Parent = card, Position = UDim2.fromOffset(4, 59), Size = UDim2.new(1, -8, 0, 16),
            BackgroundTransparency = 1, Text = entry.name, Font = Enum.Font.GothamMedium, TextSize = 10,
            TextColor3 = IC.title, TextSize = 9, TextTruncate = Enum.TextTruncate.AtEnd,
        })
        local dot = new("Frame", {
            Parent = card, Position = UDim2.fromOffset(7, 7), Size = UDim2.fromOffset(7, 7),
            BackgroundColor3 = T.green, BorderSizePixel = 0, Visible = isApplied(entry), ZIndex = 3,
        })
        corner(dot, 4)
        cards[entry] = { card = card, st = st, dot = dot, imgHost = imgHost }
        card.MouseButton1Click:Connect(function() selectEntry(entry) end)
        card.MouseEnter:Connect(function()
            if touchOnly then return end
            if Selected[entry.tab] ~= entry then tween(st, TweenInfo.new(0.12), { Transparency = 0.4 }) end
        end)
        card.MouseLeave:Connect(function()
            if Selected[entry.tab] ~= entry then tween(st, TweenInfo.new(0.12), { Transparency = 0.7 }) end
        end)
    end
    local function filterList()
        local q = string.lower(string.match(input.Text, "^%s*(.-)%s*$") or "")
        local res = {}
        for _, e in ipairs(Data[activeTab]) do
            if q == "" or string.find(e.lname, q, 1, true) then res[#res + 1] = e end
        end
        return res
    end
    local function clearCards()
        for _, info in pairs(cards) do
            if info.cardViewport then
                Spin.views[info.cardViewport] = nil
                pcall(function() info.cardViewport:Destroy() end)
            end
        end
        for _, c in ipairs(listFrame:GetChildren()) do
            if c:IsA("GuiObject") then c:Destroy() end
        end
        cards = {}
        View.more = nil
    end
    local rarityOrder = { Ancient = 1, Mythic = 2, Legendary = 3, Rare = 4, Uncommon = 5, Common = 6 }
    local function rarityOf(entry)
        return entry.rarity or (entry.catalogRecord and entry.catalogRecord.rarity) or "Unknown"
    end
    local function allEntriesForSetInference()
        local all = {}
        for _, tab in ipairs({ "knives", "guns", "effects" }) do
            for _, entry in ipairs(Data[tab]) do all[#all + 1] = entry end
        end
        return all
    end
    local function explicitSetOf(entry)
        local value = entry.setName or (entry.catalogRecord and entry.catalogRecord.setName)
        if type(value) == "string" and value ~= "" then return value end
        if entry.inst then
            local ok, setName = pcall(function()
                return entry.inst:GetAttribute("SetName") or entry.inst:GetAttribute("Set")
            end)
            if ok and type(setName) == "string" and setName ~= "" then return setName end
        end
        return nil
    end
    local function inferredSetKey(entry)
        local key = tostring(entry.catalogKey or entry.name or "")
        key = key:gsub("(%l)(%u)", "%1 %2"):gsub("[_%-%.]+", " ")
        local tokens = {}
        for word in key:gmatch("%w+") do tokens[#tokens + 1] = word:lower() end
        if #tokens < 2 then return nil end
        table.remove(tokens, #tokens)
        if #tokens == 0 then return nil end
        return table.concat(tokens, " ")
    end
    local function setNameOf(entry, allEntries)
        local explicit = explicitSetOf(entry)
        if explicit then return explicit end
        local candidate = inferredSetKey(entry)
        if not candidate then return "Otros" end
        local matches = 0
        for _, other in ipairs(allEntries) do
            if inferredSetKey(other) == candidate then
                matches = matches + 1
                if matches >= 2 then
                    return candidate:gsub("(%a)([%w]*)", function(first, rest)
                        return string.upper(first) .. rest
                    end)
                end
            end
        end
        return "Otros"
    end
    local function sortedEntriesForView(list)
        local result = table.clone(list)
        local allEntries = allEntriesForSetInference()
        table.sort(result, function(a, b)
            local ar = rarityOrder[rarityOf(a)] or 99
            local br = rarityOrder[rarityOf(b)] or 99
            if ar ~= br then return ar < br end
            local as = setNameOf(a, allEntries)
            local bs = setNameOf(b, allEntries)
            if as ~= bs then return as < bs end
            return a.lname < b.lname
        end)
        return result
    end
    local function buildCards(reset, preserveScroll)
        View.token = View.token + 1
        local my = View.token
        local previousPosition = listFrame.CanvasPosition
        local previousLimit = View.limit
        if reset then
            clearCards()
            View.built = 0
            View.limit = preserveScroll and math.max(PAGE, previousLimit or PAGE) or PAGE
            View.list = sortedEntriesForView(filterList())
            if not preserveScroll then
                listFrame.CanvasPosition = Vector2.new(0, 0)
            end
        else
            if View.more then
                View.more:Destroy()
                View.more = nil
            end
        end
        local list = View.list
        countLabel.Text = #list .. TAB_INFO[activeTab].plural
        if #list == 0 then
            emptyLabel.Visible = true
            if not Scan.done then
                emptyLabel.Text = "Preparando catálogo en segundo plano..."
            else
                emptyLabel.Text = TAB_INFO[activeTab].empty
            end
            return
        end
        emptyLabel.Visible = false
        local target = math.min(View.limit, #list)
        local allEntries = allEntriesForSetInference()
        local groups = {}
        local rarityNames = {}
        for i = 1, target do
            local entry = list[i]
            local rarity = rarityOf(entry)
            local setName = setNameOf(entry, allEntries)
            if not groups[rarity] then
                groups[rarity] = {}
                rarityNames[#rarityNames + 1] = rarity
            end
            groups[rarity][setName] = groups[rarity][setName] or {}
            local bucket = groups[rarity][setName]
            bucket[#bucket + 1] = entry
        end
        table.sort(rarityNames, function(a, b)
            local ar, br = rarityOrder[a] or 99, rarityOrder[b] or 99
            if ar ~= br then return ar < br end
            return a < b
        end)
        local sectionOrder = 0
        local rendered = 0
        for _, rarity in ipairs(rarityNames) do
            local sets = groups[rarity]
            local setNames = {}
            for setName in pairs(sets) do setNames[#setNames + 1] = setName end
            table.sort(setNames, function(a, b)
                if a == "Otros" then return false end
                if b == "Otros" then return true end
                return a < b
            end)
            local sectionHeight = 22
            for _, setName in ipairs(setNames) do
                local rows = math.ceil(#sets[setName] / 4)
                local gridHeight = rows * 80 + math.max(0, rows - 1) * 6
                sectionHeight = sectionHeight + 22 + gridHeight + 5
            end
            local section = new("Frame", {
                Parent = listFrame, Size = UDim2.new(1, -12, 0, sectionHeight),
                BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = sectionOrder,
            })
            sectionOrder = sectionOrder + 1
            new("TextLabel", {
                Parent = section, Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1, Text = rarity, Font = Enum.Font.GothamBold,
                TextSize = 12, TextColor3 = IC.gold, TextXAlignment = Enum.TextXAlignment.Left,
            })
            local y = 22
            for _, setName in ipairs(setNames) do
                local entries = sets[setName]
                local rows = math.ceil(#entries / 4)
                local gridHeight = rows * 80 + math.max(0, rows - 1) * 6
                local groupHeight = 22 + gridHeight
                local group = new("Frame", {
                    Parent = section, Position = UDim2.fromOffset(0, y),
                    Size = UDim2.new(1, 0, 0, groupHeight),
                    BackgroundTransparency = 1, BorderSizePixel = 0,
                })
                new("TextLabel", {
                    Parent = group, Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1, Text = setName, Font = Enum.Font.GothamMedium,
                    TextSize = 9, TextColor3 = IC.soft, TextXAlignment = Enum.TextXAlignment.Left,
                })
                local grid = new("Frame", {
                    Parent = group, Position = UDim2.fromOffset(0, 20),
                    Size = UDim2.new(1, 0, 0, gridHeight),
                    BackgroundTransparency = 1, BorderSizePixel = 0,
                })
                new("UIGridLayout", {
                    Parent = grid, CellSize = UDim2.fromOffset(86, 80),
                    CellPadding = UDim2.fromOffset(6, 6), SortOrder = Enum.SortOrder.LayoutOrder,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                })
                for i, entry in ipairs(entries) do
                    if View.token ~= my then return end
                    makeCard(entry, i, grid)
                    rendered = rendered + 1
                    if rendered % 6 == 0 then task.wait() end
                end
                y = y + groupHeight + 5
            end
        end
        if View.token ~= my then return end
        View.built = target
        paintCards()
        if #list > View.built then
            local more = new("TextButton", {
                Parent = listFrame, Size = UDim2.new(1, -12, 0, 28),
                BackgroundColor3 = IC.btnBgMain, BackgroundTransparency = 0.35,
                AutoButtonColor = false, Text = "Ver mas (" .. (#list - View.built) .. ")",
                Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = WHITE,
                BorderSizePixel = 0, LayoutOrder = 1000000,
            })
            corner(more, 5)
            stroke(more, IC.gold, 1, 0.5)
            View.more = more
            more.MouseButton1Click:Connect(function()
                View.limit = View.limit + PAGE
                task.spawn(buildCards, true, true)
            end)
        end
        if preserveScroll then
            task.defer(function()
                RunService.Heartbeat:Wait()
                if listFrame and listFrame.Parent then
                    local maxY = math.max(0, listFrame.AbsoluteCanvasSize.Y - listFrame.AbsoluteSize.Y)
                    listFrame.CanvasPosition = Vector2.new(0, math.clamp(previousPosition.Y, 0, maxY))
                end
            end)
        end
    end
    local function updateLabels()
        local info = TAB_INFO[activeTab]
        btnApply.label.Text = info.apply
        btnRemove.label.Text = info.remove
        input.PlaceholderText = info.ph
    end
    local function setTab(name)
        activeTab = name
        local info = TweenInfo.new(0.15)
        for key, btn in pairs(tabButtons) do
            local on = key == name
            tween(btn, info, {
                BackgroundTransparency = on and 0.25 or 1,
                TextColor3 = on and WHITE or IC.soft,
            })
            tween(tabStrokes[key], info, { Transparency = on and 0.4 or 1 })
        end
        updateLabels()
        showSelected(Selected[name])
        task.spawn(buildCards, true)
    end
    local function moveEntry(entry)
        if entry.tab ~= "knives" and entry.tab ~= "guns" then return end
        local from = entry.tab
        local to = from == "knives" and "guns" or "knives"
        local rec = Applied[entry.cat]
        if rec and rec.entry == entry then dropWeapon(entry.cat) end
        for i, e in ipairs(Data[from]) do
            if e == entry then
                table.remove(Data[from], i)
                break
            end
        end
        -- Catalogue category is canonical; movement is a UI shortcut only and must not
        -- redefine the item's actual type. Keep the entry in its authoritative tab.
        entry.cat = entry.catalogRecord and entry.catalogRecord.cat or entry.cat
        entry.tab = entry.cat == "melee" and "knives" or "guns"
        Data[entry.tab][#Data[entry.tab] + 1] = entry
        table.sort(Data[to], function(a, b) return a.lname < b.lname end)
        Selected[from] = nil
        Selected[entry.tab] = entry
        setTab(entry.tab)
        setStatus("La categoría del catálogo es fija: " .. (entry.tab == "guns" and "Pistolas" or "Cuchillos") .. ".", T.warn)
    end
    local function runScan()
        if Scan.running or Scan.done then return end
        local scanStartedAt = os.clock()
        Scan.running = true
        Scan.done = false
        setStatus("Preparando catálogo...", IC.soft)
        setProgress(0.03)

        local weapons, effects = {}, {}
        local seenW, sigW, seenE = {}, {}, {}
        local weaponInstances, effectInstances = {}, {}
        local catalogCounts = loadWeaponCatalog()
        local weaponOk, effectOk = true, true
        local weaponErr, effectErr

        local function publishWeaponLists()
            local knives, guns = {}, {}
            for _, entry in ipairs(weapons) do
                if entry.catalogRecord then entry.cat = entry.catalogRecord.cat end
                if entry.cat == "melee" then
                    entry.tab = "knives"
                    knives[#knives + 1] = entry
                elseif entry.cat == "gun" then
                    entry.tab = "guns"
                    guns[#guns + 1] = entry
                end
            end
            local function rarityRank(entry)
                local rarity = entry.rarity or (entry.catalogRecord and entry.catalogRecord.rarity) or "Unknown"
                local order = { Ancient = 1, Mythic = 2, Legendary = 3, Rare = 4, Uncommon = 5, Common = 6 }
                return order[rarity] or 99
            end
            local function sortByRarity(a, b)
                local ar, br = rarityRank(a), rarityRank(b)
                if ar ~= br then return ar < br end
                return a.lname < b.lname
            end
            table.sort(knives, sortByRarity)
            table.sort(guns, sortByRarity)
            Data.knives, Data.guns = knives, guns
            return knives, guns
        end

        -- Stage 1: scan only the weapon registries, inventory and player rigs.
        weaponOk, weaponErr = pcall(function()
            weaponInstances = allInstances(weaponRoots())
            scanWeapons(weaponInstances, weapons, seenW, sigW)
            hydrateWeaponCache(weapons, seenW)
            publishWeaponLists()
        end)
        if not weaponOk then
            warn("[SnowX-Armas] Weapon scan failed: " .. tostring(weaponErr))
        end
        pcall(buildCards, true)
        setProgress(0.34)
        setStatus(
            tostring(catalogCounts.knives) .. " cuchillos y " .. tostring(catalogCounts.guns)
                .. " pistolas del catálogo; " .. tostring(catalogCounts.effects)
                .. " efectos del catálogo; asociando modelos 3D disponibles...",
            IC.soft
        )

        -- Stage 2: hook only known networking folders; never traverse the whole DataModel.
        pcall(function()
            hookRemotes(allInstances(remoteRoots()))
        end)

        -- Stage 3: scan the dedicated kill-effect libraries, not weapon VFX or world props.
        effectOk, effectErr = pcall(function()
            effectInstances = allInstances(effectRoots())
            setActiveScanInstances(effectInstances)
            Scan.fxPresenceSeconds = buildFxPresence(effectInstances)
            local counter = { n = 0 }
            for _, root in ipairs(effectRoots()) do
                scanRuntimeEffects(root, effects, seenE, nil)
                scanGeneric(root, false, KILL_CFG, effects, seenE, counter)
            end
            catalogEffectScan(effectRoots(), effects, seenE)
            priorityScan(effectInstances, effects, seenE)
            libraryScan(effectInstances, effects, seenE)
            hydrateEffectCache(effects, seenE)
        end)
        if not effectOk then
            warn("[SnowX-Armas] Effect scan failed: " .. tostring(effectErr))
        end

        Data.effects = effects
        setProgress(0.78)
        setStatus(#effects .. " efectos encontrados; finalizando catálogo...", IC.soft)
        local knives, guns = publishWeaponLists()
        local function rarityRank(entry)
            local rarity = entry.rarity or (entry.catalogRecord and entry.catalogRecord.rarity) or "Unknown"
            local order = { Ancient = 1, Mythic = 2, Legendary = 3, Rare = 4, Uncommon = 5, Common = 6 }
            return order[rarity] or 99
        end
        table.sort(effects, function(a, b)
            local ar, br = rarityRank(a), rarityRank(b)
            if ar ~= br then return ar < br end
            if a.priority ~= b.priority then return a.priority end
            return a.lname < b.lname
        end)
        Data.knives, Data.guns, Data.effects = knives, guns, effects

        -- Complete the main catalogue before optional icon/sound enrichment.
        Scan.elapsedSeconds = os.clock() - scanStartedAt
        Scan.running = false
        Scan.done = true
        if not weaponOk or not effectOk then
            local reason = not weaponOk and tostring(weaponErr) or tostring(effectErr)
            setStatus("Catálogo parcial: " .. reason .. " (" .. string.format("%.2fs", Scan.elapsedSeconds) .. ")", T.warn)
        else
            local cachedKnives, cachedGuns, cachedEffects, knifeVariants, gunVariants, effectVariants = assetCacheStats()
            local modelKnives, modelGuns, modelEffects = 0, 0, 0
            for _, entry in ipairs(knives) do if resolveWeaponSource(entry) then modelKnives = modelKnives + 1 end end
            for _, entry in ipairs(guns) do if resolveWeaponSource(entry, "Right") then modelGuns = modelGuns + 1 end end
            for _, entry in ipairs(effects) do if resolveEffectSource(entry) then modelEffects = modelEffects + 1 end end
            setStatus(tostring(#knives) .. " cuchillos (" .. modelKnives .. " modelos 3D) | "
                .. tostring(#guns) .. " pistolas (" .. modelGuns .. " modelos 3D) | "
                .. tostring(#effects) .. " efectos (" .. modelEffects .. " modelos 3D) | caché K/G/E "
                .. cachedKnives .. "/" .. cachedGuns .. "/" .. cachedEffects .. " ("
                .. knifeVariants .. "/" .. gunVariants .. "/" .. effectVariants .. " variantes) | "
                .. string.format("%.2fs", Scan.elapsedSeconds) .. ".", T.green)
        end
        setProgress(1)
        pcall(buildCards, true)
        task.delay(0.6, function()
            if progressFill and progressFill.Parent then setProgress(0) end
        end)

        -- Optional metadata is deliberately detached from catalogue completion.
        task.spawn(function()
            local ok, err = pcall(function()
                attachIcons(effects, weapons)
                attachSounds(effectInstances, effects)
            end)
            if not ok then warn("[SnowX-Armas] Optional metadata skipped: " .. tostring(err)) end
            if gui and gui.Parent and Scan.done then
                pcall(buildCards, true)
            end
        end)

        -- Runtime source discovery (client-replicated only): observe new models arriving
        -- in ReplicatedStorage, Workspace stands/dual-wield copies and the local player.
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local WEAPON_RUNTIME_ROOTS = {
            weapons = true, bundlepreviewset = true, weaponassets = true, weaponmodels = true,
            guns = true, knives = true,
            limitedbundle = true, limitedcratestand = true, workbench = true,
            clanstand = true, ["diadelosmuertosevent"] = true,
            gunpartsfolder = true, gunpartsfolder2 = true, knifepartsfolder = true,
        }
        local EFFECT_RUNTIME_ROOTS = {
            effects = true, previeweffects = true, finishers = true,
            killeffects = true, killeffectlibrary = true, killfx = true,
        }
        local runtimePending = setmetatable({}, { __mode = "k" })
        local runtimeDirty = setmetatable({}, { __mode = "k" })
        local runtimeLatest = setmetatable({}, { __mode = "k" })
        local runtimeLastScan = setmetatable({}, { __mode = "k" })
        local function runtimeContext(inst)
            local weaponContext, effectContext = catOfName(inst.Name) ~= nil, false
            local normalizedName = norm(inst.Name)
            local namedEffectHint = hasAny(normalizedName, {
                "kill effect", "killfx", "finisher", "effect", "vfx", "death",
            })
            if isFx(inst) or inst:IsA("Sound") or inst:IsA("Animation") then
                effectContext = true
            end
            local p = inst
            while p and p ~= game do
                local key = squash(p.Name)
                if WEAPON_RUNTIME_ROOTS[key] then weaponContext = true end
                if EFFECT_RUNTIME_ROOTS[key] then effectContext = true end
                p = p.Parent
            end
            if namedEffectHint then effectContext = true end
            if inst:IsDescendantOf(LocalPlayer) then
                weaponContext = weaponContext or inst:IsA("Tool") or inst:IsA("Model")
                    or inst:IsA("Folder") or inst:IsA("Accessory")
            end
            return weaponContext, effectContext
        end
        local function runtimeCandidateRoot(inst)
            if inst:IsA("Tool") or inst:IsA("Accessory") then return inst end
            local p = inst
            local firstUsefulModel, firstUsefulPart
            while p and p ~= game do
                if p:IsA("Tool") or p:IsA("Accessory") then return p end
                if p:IsA("Model") and not p:FindFirstChildOfClass("Humanoid") then
                    local hasVisualRoot = p:FindFirstChild("Visual") and p:FindFirstChild("VFX")
                        and (p:FindFirstChild("Root") or p:FindFirstChild("Handle"))
                    if hasVisualRoot or catOfName(p.Name) then return p end
                    firstUsefulModel = firstUsefulModel or p
                elseif p:IsA("BasePart") and not firstUsefulPart then
                    -- The triggering emitter/sound is already a descendant of this part;
                    -- no need to enumerate the part's entire subtree for each event.
                    firstUsefulPart = p
                end
                if p:IsA("Folder") and (WEAPON_RUNTIME_ROOTS[squash(p.Name)]
                    or EFFECT_RUNTIME_ROOTS[squash(p.Name)]) then
                    -- Prefer the nearest contained model/part over scanning an entire
                    -- shared Effects/Weapons folder.
                    return firstUsefulModel or firstUsefulPart or p
                end
                p = p.Parent
            end
            return firstUsefulModel or firstUsefulPart or inst
        end
        local function invalidateRuntimeCaches(root)
            invalidateScanCaches(root)
        end
        local function onRuntimeDescendantAdded(inst)
            if not inst or inst:GetAttribute("NxTV") or oursDeep(inst) then return end
            if not (inst:IsA("Tool") or inst:IsA("Accessory") or inst:IsA("Model")
                or inst:IsA("Folder") or inst:IsA("BasePart") or isFx(inst)
                or inst:IsA("Sound") or inst:IsA("Animation")) then return end
            local weaponContext, effectContext = runtimeContext(inst)
            local toolAncestor = inst:IsA("Tool") and inst or inst:FindFirstAncestorWhichIsA("Tool")
            if toolAncestor then
                local toolCategory = catOfTool(toolAncestor)
                if toolCategory and (toolAncestor:IsDescendantOf(LocalPlayer)
                    or catOfName(toolAncestor.Name) ~= nil
                    or toolAncestor:FindFirstAncestor("GunPartsFolder")
                    or toolAncestor:FindFirstAncestor("KnifePartsFolder")) then
                    weaponContext = true
                    -- The full Tool clone includes its native FX tree. Do not also
                    -- index its emitter as a separate kill effect.
                    effectContext = false
                end
            end
            if not weaponContext and not effectContext then return end
            local candidate = toolAncestor or runtimeCandidateRoot(inst)
            if not candidate then return end
            if runtimePending[candidate] then
                -- Coalesce additions while a source is being assembled, then schedule
                -- one trailing capture so late attachments/emitters are not missed.
                runtimeDirty[candidate] = true
                runtimeLatest[candidate] = inst
                return
            end
            local now = os.clock()
            local waitForCooldown = runtimeLastScan[candidate]
                and math.max(0, 0.85 - (now - runtimeLastScan[candidate])) or 0
            runtimePending[candidate] = true
            runtimeLastScan[candidate] = now
            task.delay(math.max(0.62, waitForCooldown), function()
                if not existsInGame(candidate) then
                    runtimePending[candidate] = nil
                    runtimeDirty[candidate] = nil
                    runtimeLatest[candidate] = nil
                    return
                end
                invalidateRuntimeCaches(candidate)
                local list = allInstances({ candidate })
                local changed = false
                local isWeaponContext, isEffectContext = runtimeContext(candidate)

                if weaponContext or isWeaponContext then
                    local discovered = {}
                    local _, _, _, _, _, _, knifeAddsBefore, gunAddsBefore = assetCacheStats()
                    local sourceCountBefore = 0
                    for _, entry in ipairs(weapons) do
                        if entry.catalogOnly ~= true and entry.inst then sourceCountBefore = sourceCountBefore + 1 end
                    end
                    scanWeapons(list, discovered, seenW, sigW)
                    for _, entry in ipairs(discovered) do
                        weapons[#weapons + 1] = entry
                        changed = true
                    end
                    hydrateWeaponCache(weapons, seenW)
                    local sourceCountAfter = 0
                    for _, entry in ipairs(weapons) do
                        if entry.catalogOnly ~= true and entry.inst then sourceCountAfter = sourceCountAfter + 1 end
                    end
                    if sourceCountAfter > sourceCountBefore then changed = true end
                    local _, _, _, _, _, _, knifeAddsAfter, gunAddsAfter = assetCacheStats()
                    if knifeAddsAfter > knifeAddsBefore or gunAddsAfter > gunAddsBefore then
                        changed = true
                    end
                    if changed then
                        local newKnives, newGuns = publishWeaponLists()
                        if gui and gui.Parent then
                            pcall(buildCards, true)
                            if Selected[activeTab] then pcall(showSelected, Selected[activeTab]) end
                        end
                        setStatus("Descubrimiento dinámico: " .. #newKnives .. " cuchillos y "
                            .. #newGuns .. " pistolas; caché actualizada.", IC.soft)
                    end
                end

                if effectContext or isEffectContext then
                    setActiveScanInstances(list)
                    pcall(buildFxPresence, list)
                    local counter = { n = 0 }
                    local before = #effects
                    scanRuntimeEffects(candidate, effects, seenE,
                        Kill.entry and Kill.entry.name or nil)
                    scanGeneric(candidate, false, KILL_CFG, effects, seenE, counter)
                    priorityScan(list, effects, seenE)
                    libraryScan(list, effects, seenE)
                    catalogEffectScan(effectRoots(), effects, seenE)
                    hydrateEffectCache(effects, seenE)
                    if #effects > before then
                        Data.effects = effects
                        table.sort(effects, function(a, b)
                            local function rank(entry)
                                local rarity = entry.rarity or (entry.catalogRecord and entry.catalogRecord.rarity) or "Unknown"
                                local order = { Ancient = 1, Mythic = 2, Legendary = 3, Rare = 4, Uncommon = 5, Common = 6 }
                                return order[rarity] or 99
                            end
                            local ar, br = rank(a), rank(b)
                            if ar ~= br then return ar < br end
                            if a.priority ~= b.priority then return a.priority end
                            return a.lname < b.lname
                        end)
                        if gui and gui.Parent then
                            pcall(buildCards, true)
                            if Selected.effects then pcall(showSelected, Selected.effects) end
                        end
                        setStatus("Efectos dinámicos detectados: " .. #effects .. "; caché sincronizada.", IC.soft)
                    elseif gui and gui.Parent then
                        pcall(buildCards, true)
                        if Selected.effects then pcall(showSelected, Selected.effects) end
                    end
                end

                runtimePending[candidate] = nil
                local dirty = runtimeDirty[candidate]
                local latest = runtimeLatest[candidate]
                runtimeDirty[candidate] = nil
                runtimeLatest[candidate] = nil
                if dirty and latest and existsInGame(latest) then
                    task.delay(0.08, function()
                        if existsInGame(latest) then onRuntimeDescendantAdded(latest) end
                    end)
                end
            end)
        end
        track(ReplicatedStorage.DescendantAdded:Connect(onRuntimeDescendantAdded))
        track(Workspace.DescendantAdded:Connect(onRuntimeDescendantAdded))
        track(LocalPlayer.DescendantAdded:Connect(onRuntimeDescendantAdded))
        local function watchCharacterRuntime(char)
            if char then
                track(char.DescendantAdded:Connect(onRuntimeDescendantAdded))
            end
        end
        watchCharacterRuntime(LocalPlayer.Character)
        track(LocalPlayer.CharacterAdded:Connect(watchCharacterRuntime))
    end
    local function doSearch()
        buildCards(true)
        setStatus(#View.list .. TAB_INFO[activeTab].plural .. ".", IC.soft)
    end
    btnSearch.btn.MouseButton1Click:Connect(function() task.spawn(doSearch) end)
    input.FocusLost:Connect(function(enter)
        if enter then task.spawn(doSearch) end
    end)
    local typeToken = 0
    track(input:GetPropertyChangedSignal("Text"):Connect(function()
        typeToken = typeToken + 1
        local my = typeToken
        task.delay(0.25, function()
            if typeToken == my then buildCards(true) end
        end)
    end))
    btnMove.btn.MouseButton1Click:Connect(function()
        local e = Selected[activeTab]
        if e then moveEntry(e) end
    end)
    btnApply.btn.MouseButton1Click:Connect(function()
        task.spawn(function()
            if busy then return end
            local entry = Selected[activeTab]
            if not entry then
                setStatus("Selecciona uno primero.", T.warn)
                return
            end
            busy = true
            setStatus("Aplicando...", IC.soft)
            setProgress(0.5)
            local ok, success, msg
            if activeTab == "effects" then
                Kill.entry = entry
                if resolveEffectSource(entry) then
                    ok, success, msg = true, true, "Efecto preparado para la próxima baja detectada: " .. entry.name
                else
                    ok, success, msg = true, true,
                        "Efecto seleccionado. Se guardará cuando el juego replique su modelo visual al cliente; todavía no hay una plantilla 3D disponible."
                end
            else
                ok, success, msg = pcall(applyWeapon, entry)
            end
            if not ok then
                setStatus("Error: " .. tostring(success), T.red)
                setProgress(0)
            elseif success then
                setStatus(msg, T.green)
                setProgress(1)
                task.delay(0.6, function() setProgress(0) end)
            else
                setStatus(tostring(msg), T.red)
                setProgress(0)
            end
            paintCards()
            busy = false
        end)
    end)
    btnRemove.btn.MouseButton1Click:Connect(function()
        task.spawn(function()
            if busy then return end
            if activeTab == "effects" then
                if not Kill.entry then
                    setStatus("No hay kill effect activo.", T.warn)
                    return
                end
                Kill.entry = nil
                setStatus("Kill effect borrado.", IC.soft)
            else
                local cat = TAB_INFO[activeTab].cat
                if not Applied[cat] then
                    setStatus("No hay skin aplicada.", T.warn)
                    return
                end
                pcall(dropWeapon, cat)
                setStatus("Skin borrada, original restaurado.", IC.soft)
            end
            paintCards()
        end)
    end)
    for key, btn in pairs(tabButtons) do
        btn.MouseButton1Click:Connect(function() setTab(key) end)
    end
    local FLOAT_WIDTH, FLOAT_HEIGHT = 150, 46
    local floatingPositionInitialized = false
    local floatingCenter = nil
    local floatRoot = new("Frame", {
        Parent = gui, Name = "FloatingReopen", AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(FLOAT_WIDTH, FLOAT_HEIGHT), Position = UDim2.fromOffset(0, 0),
        BackgroundColor3 = Color3.fromRGB(18, 18, 22), BackgroundTransparency = 0.05,
        BorderSizePixel = 0, ClipsDescendants = true, Visible = true, Active = true, ZIndex = 50,
    })
    corner(floatRoot, 12)
    floatingBackground = new("ImageLabel", {
        Parent = floatRoot, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        Image = bgAsset or "", ImageTransparency = bgAsset and 0.5 or 1,
        ScaleType = Enum.ScaleType.Crop, BorderSizePixel = 0, ZIndex = 50,
    })
    corner(floatingBackground, 12)
    floatingOverlay = new("Frame", {
        Parent = floatRoot, Size = UDim2.fromScale(1, 1), BackgroundColor3 = BLACK,
        BackgroundTransparency = bgAsset and 0.55 or 0.82, BorderSizePixel = 0, ZIndex = 51,
    })
    local reopenDot = new("Frame", {
        Parent = floatRoot, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -12, 0, 10),
        Size = UDim2.fromOffset(8, 8), BackgroundColor3 = IC.title,
        BorderSizePixel = 0, ZIndex = 53,
    })
    corner(reopenDot, 4)
    new("TextLabel", {
        Parent = floatRoot, BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 0),
        Size = UDim2.new(1, -24, 1, 0), Font = Enum.Font.GothamBold,
        Text = "Open Armas", TextSize = 13, TextColor3 = IC.title,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 53,
    })
    local floatBtn = new("TextButton", {
        Parent = floatRoot, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        AutoButtonColor = false, Active = true, Selectable = false, Text = "", ZIndex = 54,
    })

    local function clampGuiCenter(size, position)
        local viewport = UI.viewport()
        local halfSize = Vector2.new(size.X * 0.5 + 2, size.Y * 0.5 + 2)
        local maxX, maxY = viewport.X - halfSize.X, viewport.Y - halfSize.Y
        if maxX < halfSize.X or maxY < halfSize.Y then
            return Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
        end
        return Vector2.new(
            math.clamp(position.X, halfSize.X, maxX),
            math.clamp(position.Y, halfSize.Y, maxY)
        )
    end

    local function setFloatingCenter(position)
        local size = Vector2.new(FLOAT_WIDTH, FLOAT_HEIGHT)
        floatingCenter = clampGuiCenter(size, position)
        floatRoot.Position = UDim2.fromOffset(floatingCenter.X, floatingCenter.Y)
        floatingPositionInitialized = true
        return floatingCenter
    end

    local function initializeFloatingPosition()
        if floatingPositionInitialized then return end
        local viewport = UI.viewport()
        setFloatingCenter(Vector2.new(viewport.X - FLOAT_WIDTH * 0.5 - 16, viewport.Y * 0.5))
    end

    local function getFloatingCenter()
        return floatingCenter or Vector2.new(0, 0)
    end

    initializeFloatingPosition()

    local TI_CLOSE = TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    local token = 0
    local function openWindow(fromFloating)
        token = token + 1
        local my = token
        initializeFloatingPosition()
        floatRoot.Visible = false
        setMainCenter(mainCenter)
        Window.Visible = true
        Window.GroupTransparency = 1
        local startCenter = fromFloating and getFloatingCenter() or mainCenter
        Window.Position = UDim2.fromOffset(startCenter.X, startCenter.Y)
        winScale.Scale = BASE * (fromFloating and 0.2 or 0.8)
        bgScale.Scale = 1.14
        Left.Position = UDim2.fromOffset(-24, 60)
        Right.Position = UDim2.fromOffset(238, 60)
        headLine.Size = UDim2.new(0, 0, 0, 1)
        tween(Window, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { GroupTransparency = 0 })
        tween(winScale, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = BASE })
        tween(Window, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.fromOffset(mainCenter.X, mainCenter.Y),
        })
        tween(headLine, TweenInfo.new(0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 0.1), {
            Size = UDim2.new(1, 0, 0, 1),
        })
        tween(Left, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 0.08), {
            Position = UDim2.fromOffset(8, 60),
        })
        tween(Right, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 0.16), {
            Position = UDim2.fromOffset(194, 60),
        })
        tween(bgScale, TweenInfo.new(7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1 })
    end

    local function minimizeWindow()
        token = token + 1
        local my = token
        keepMainInsideViewport()
        initializeFloatingPosition()
        floatRoot.Visible = false
        local target = getFloatingCenter()
        tween(Window, TI_CLOSE, {
            GroupTransparency = 1,
            Position = UDim2.fromOffset(target.X, target.Y),
        })
        tween(winScale, TI_CLOSE, { Scale = BASE * 0.2 }).Completed:Connect(function()
            if token == my then
                Window.Visible = false
                Window.GroupTransparency = 0
                Window.Position = UDim2.fromOffset(mainCenter.X, mainCenter.Y)
                floatRoot.Visible = true
            end
        end)
    end

    local mainDrag = nil
    local floatingDrag = nil
    local suppressFloatOpen = false

    local function beginMainDrag(input)
        local inputType = input.UserInputType
        if inputType ~= Enum.UserInputType.MouseButton1 and inputType ~= Enum.UserInputType.Touch then return end
        mainDrag = {
            input = input, inputType = inputType,
            start = Vector2.new(input.Position.X, input.Position.Y),
            origin = mainCenter, moved = false,
        }
    end

    local function beginFloatingDrag(input)
        local inputType = input.UserInputType
        if inputType ~= Enum.UserInputType.MouseButton1 and inputType ~= Enum.UserInputType.Touch then return end
        suppressFloatOpen = false
        floatingDrag = {
            input = input, inputType = inputType,
            start = Vector2.new(input.Position.X, input.Position.Y),
            origin = getFloatingCenter(), moved = false,
        }
    end

    local function moveDrag(drag, input, isTouch, setter)
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
        if drag.moved then setter(drag.origin + delta) end
    end

    local function finishMainDrag(input, isTouch)
        local drag = mainDrag
        if not drag then return end
        local ended = isTouch
            and drag.inputType == Enum.UserInputType.Touch and input == drag.input
            or (not isTouch and drag.inputType == Enum.UserInputType.MouseButton1
                and input.UserInputType == Enum.UserInputType.MouseButton1)
        if ended then mainDrag = nil end
    end

    local function finishFloatingDrag(input, isTouch)
        local drag = floatingDrag
        if not drag then return end
        local ended = isTouch
            and drag.inputType == Enum.UserInputType.Touch and input == drag.input
            or (not isTouch and drag.inputType == Enum.UserInputType.MouseButton1
                and input.UserInputType == Enum.UserInputType.MouseButton1)
        if not ended then return end
        floatingDrag = nil
        if drag.moved then suppressFloatOpen = true end
    end

    track(dragArea.InputBegan:Connect(beginMainDrag))
    track(floatBtn.InputBegan:Connect(beginFloatingDrag))
    track(floatBtn.Activated:Connect(function()
        if suppressFloatOpen then
            suppressFloatOpen = false
            return
        end
        openWindow(true)
    end))
    track(UIS.InputChanged:Connect(function(input)
        moveDrag(mainDrag, input, false, setMainCenter)
        moveDrag(floatingDrag, input, false, setFloatingCenter)
    end))
    track(UIS.TouchMoved:Connect(function(input)
        moveDrag(mainDrag, input, true, setMainCenter)
        moveDrag(floatingDrag, input, true, setFloatingCenter)
    end))
    track(UIS.InputEnded:Connect(function(input)
        finishMainDrag(input, false)
        finishFloatingDrag(input, false)
    end))
    track(UIS.TouchEnded:Connect(function(input)
        finishMainDrag(input, true)
        finishFloatingDrag(input, true)
    end))

    btnMin.MouseButton1Click:Connect(minimizeWindow)

    local function updateScale()
        local viewport = UI.viewport()
        BASE = calculateBaseScale(viewport)
        winScale.Scale = BASE
        setMainCenter(mainCenter)
        if floatingPositionInitialized then setFloatingCenter(getFloatingCenter()) end
    end

    local cameraViewportConnection = nil
    local function connectCurrentCamera()
        if cameraViewportConnection then
            cameraViewportConnection:Disconnect()
            cameraViewportConnection = nil
        end
        local camera = Workspace.CurrentCamera
        if camera then
            cameraViewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
            track(cameraViewportConnection)
        end
        updateScale()
    end
    connectCurrentCamera()
    track(Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(connectCurrentCamera))

    local function destroyAll()
        local cats = {}
        for cat in pairs(Applied) do cats[#cats + 1] = cat end
        for _, cat in ipairs(cats) do pcall(dropWeapon, cat) end
        if SkinLoop.conn then
            SkinLoop.conn:Disconnect()
            SkinLoop.conn = nil
        end
        Kill.entry = nil
        if Kill.folder then pcall(function() Kill.folder:Destroy() end) end
        if projFolderObj then pcall(function() projFolderObj:Destroy() end) end
        for viewport in pairs(Spin.views) do Spin.views[viewport] = nil end
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        conns = {}
        if gui then gui:Destroy() end
        env.SnowXArmasVisualCleanup = nil
        env.NexvyrToolsVisualCleanup = nil
    end
    env.SnowXArmasVisualCleanup = destroyAll
    env.NexvyrToolsVisualCleanup = destroyAll
    btnClose.MouseButton1Click:Connect(function()
        Modal.show({
            title = "Realmente quieres cerrar?",
            text = "Si cierras la GUI por completo tendras que ejecutar el script otra vez.",
            leftText = "Abrir denuevo", leftStyle = "main",
            rightText = "Cerrar Gui", rightStyle = "danger",
            onRight = function()
                tween(winScale, TI_CLOSE, { Scale = BASE * 0.85 })
                tween(Window, TI_CLOSE, { GroupTransparency = 1 }).Completed:Connect(destroyAll)
            end,
        })
    end)
    updateLabels()
    setTab("knives")
    initKills()
    task.spawn(runScan)
end
local appOk, appErr = pcall(App)
if not appOk then warn("[SnowX-Armas] " .. tostring(appErr)) end