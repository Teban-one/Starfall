--[[
    STARFALL | CONTROL CENTER
    For your own Roblox experience / Studio test place.
    K toggles the panel. Hidden panel becomes a movable floating button.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local C = {
    bg = Color3.fromRGB(10, 13, 27),
    panel = Color3.fromRGB(20, 25, 47),
    panel2 = Color3.fromRGB(31, 38, 68),
    blue = Color3.fromRGB(80, 145, 255),
    violet = Color3.fromRGB(153, 100, 255),
    text = Color3.fromRGB(240, 243, 255),
    muted = Color3.fromRGB(160, 170, 200),
    red = Color3.fromRGB(255, 88, 115),
    green = Color3.fromRGB(80, 220, 155),
}

local old = playerGui:FindFirstChild("StarfallUI")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "StarfallUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local function make(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end
local function corner(obj, radius)
    make("UICorner", {CornerRadius = UDim.new(0, radius or 10)}, obj)
end
local function outline(obj, color, transparency)
    make("UIStroke", {Color = color or C.violet, Thickness = 1, Transparency = transparency or 0.3}, obj)
end
local function label(parent, text, pos, size, textSize, color, font)
    return make("TextLabel", {
        BackgroundTransparency = 1, Position = pos, Size = size,
        Font = font or Enum.Font.Gotham, Text = text,
        TextColor3 = color or C.text, TextSize = textSize or 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
    }, parent)
end
local function button(parent, text, pos, size, callback, color)
    local b = make("TextButton", {
        Position = pos, Size = size, BackgroundColor3 = color or C.panel2,
        BorderSizePixel = 0, Text = text, TextColor3 = C.text,
        Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = true,
    }, parent)
    corner(b, 8)
    b.Activated:Connect(callback)
    return b
end

local main = make("Frame", {
    Name = "Main", Size = UDim2.fromOffset(650, 455),
    Position = UDim2.new(0.5, -325, 0.5, -227),
    BackgroundColor3 = C.bg, BorderSizePixel = 0,
}, gui)
corner(main, 14)
outline(main, C.violet, 0.15)
local mainScale = make("UIScale", {Scale = 1}, main)

local function updateResponsiveScale()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    local scaleX = (viewport.X - 24) / 650
    local scaleY = (viewport.Y - 24) / 455
    mainScale.Scale = math.clamp(math.min(scaleX, scaleY, 1), 0.55, 1)
end
updateResponsiveScale()
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsiveScale)
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    task.defer(updateResponsiveScale)
    local camera = workspace.CurrentCamera
    if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsiveScale) end
end)

local top = make("Frame", {
    Name = "TopBar", Size = UDim2.new(1, 0, 0, 62),
    BackgroundColor3 = C.panel, BorderSizePixel = 0,
}, main)
corner(top, 14)
make("Frame", {Position = UDim2.new(0, 0, 1, -12), Size = UDim2.new(1, 0, 0, 12), BackgroundColor3 = C.panel, BorderSizePixel = 0}, top)
local accent = make("Frame", {Position = UDim2.new(0, 0, 1, -2), Size = UDim2.new(1, 0, 0, 2), BorderSizePixel = 0, BackgroundColor3 = C.blue}, top)
make("UIGradient", {Color = ColorSequence.new(C.blue, C.violet)}, accent)
label(top, "✦  STARFALL", UDim2.fromOffset(16, 8), UDim2.new(1, -110, 0, 28), 19, C.text, Enum.Font.GothamBold)
label(top, "CONTROL CENTER  •  K TO TOGGLE", UDim2.fromOffset(18, 35), UDim2.new(1, -120, 0, 15), 9, C.muted)
local hideButton = button(top, "—", UDim2.new(1, -48, 0, 15), UDim2.fromOffset(32, 30), function()
    main.Visible = false
end, C.panel2)
hideButton.TextSize = 18

-- Persistent reopen button remains visible while the main panel is hidden.
local reopen = button(gui, "✦", UDim2.new(0, 18, 0.5, -24), UDim2.fromOffset(48, 48), function()
    main.Visible = true
end, C.panel)
reopen.Name = "ReopenStarfall"
reopen.TextSize = 20
outline(reopen, C.violet, 0.1)
reopen.Visible = false

local function setPanelVisible(value)
    reopen.Visible = not value
    if value then
        main.Visible = true
        mainScale.Scale = 0.94
        TweenService:Create(mainScale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Scale = 1
        }):Play()
    else
        main.Visible = false
    end
end
hideButton.Activated:Connect(function() setPanelVisible(false) end)
reopen.Activated:Connect(function() setPanelVisible(true) end)
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.K then
        setPanelVisible(not main.Visible)
    end
end)

local miniDragging, miniDragStart, miniStartPos
reopen.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        miniDragging, miniDragStart, miniStartPos = true, input.Position, reopen.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if miniDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - miniDragStart
        reopen.Position = UDim2.new(miniStartPos.X.Scale, miniStartPos.X.Offset + delta.X, miniStartPos.Y.Scale, miniStartPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        miniDragging = false
    end
end)

-- Drag panel by the top bar.
local dragging, dragStart, startPos
top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging, dragStart, startPos = true, input.Position, main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

-- Sidebar + animated page container.
local workspace = make("Frame", {
    Name = "Workspace", Position = UDim2.fromOffset(14, 76),
    Size = UDim2.new(1, -28, 1, -104), BackgroundTransparency = 1,
}, main)
local sidebar = make("Frame", {
    Name = "Sidebar", Size = UDim2.new(0, 142, 1, 0),
    BackgroundColor3 = C.panel, BorderSizePixel = 0,
}, workspace)
corner(sidebar, 12)
make("UIPadding", {PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, sidebar)
make("UIListLayout", {Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder}, sidebar)
local pageHost = make("Frame", {
    Name = "PageHost", Position = UDim2.new(0, 154, 0, 0),
    Size = UDim2.new(1, -154, 1, 0), BackgroundTransparency = 1,
    ClipsDescendants = true,
}, workspace)
local pageNames = {"Home", "Visual", "Perks", "Whitelist", "Teleport", "Other"}
local pages, navButtons = {}, {}
local activePageName = "Home"
local activePage
for _, pageName in ipairs(pageNames) do
    local page = make("ScrollingFrame", {
        Name = pageName .. "Page", Size = UDim2.fromScale(1, 1),
        Position = UDim2.fromScale(0, 0), BackgroundTransparency = 1,
        BorderSizePixel = 0, ScrollBarThickness = 4, ScrollBarImageColor3 = C.violet,
        AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollingDirection = Enum.ScrollingDirection.Y, Visible = pageName == "Home",
    }, pageHost)
    make("UIPadding", {PaddingRight = UDim.new(0, 5), PaddingBottom = UDim.new(0, 8)}, page)
    make("UIListLayout", {Padding = UDim.new(0, 9), SortOrder = Enum.SortOrder.LayoutOrder}, page)
    pages[pageName] = page
end
activePage = pages.Home
local function switchPage(name)
    if not pages[name] or activePageName == name then return end
    local previous = pages[activePageName]
    local target = pages[name]
    activePageName = name
    activePage = target
    target.Visible = true
    target.Position = UDim2.new(0, 14, 0, 0)
    target.BackgroundTransparency = 1
    TweenService:Create(target, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()
    if previous then
        previous.Visible = false
        previous.Position = UDim2.new(0, 0, 0, 0)
    end
    for pageName, nav in pairs(navButtons) do
        local selected = pageName == name
        TweenService:Create(nav, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = selected and C.violet or C.panel2,
            TextColor3 = selected and Color3.new(1, 1, 1) or C.muted,
        }):Play()
    end
end
for i, pageName in ipairs(pageNames) do
    local nav = button(sidebar, "  " .. pageName, UDim2.new(), UDim2.new(1, 0, 0, 36), function()
        switchPage(pageName)
    end, pageName == "Home" and C.violet or C.panel2)
    nav.TextXAlignment = Enum.TextXAlignment.Left
    nav.LayoutOrder = i
    navButtons[pageName] = nav
end
local function pageHeader(titleText, subtitle)
    local f = make("Frame", {Size = UDim2.new(1, -5, 0, 54), BackgroundColor3 = C.panel, BorderSizePixel = 0}, activePage)
    corner(f, 10)
    label(f, titleText, UDim2.fromOffset(13, 7), UDim2.new(1, -26, 0, 22), 17, C.text, Enum.Font.GothamBold)
    label(f, subtitle, UDim2.fromOffset(14, 31), UDim2.new(1, -28, 0, 16), 10, C.muted)
    return f
end

local nextLayoutOrder = 1
local function ordered(obj)
    obj.LayoutOrder = nextLayoutOrder
    nextLayoutOrder += 1
    return obj
end
local function sectionTitle(text)
    local f = ordered(make("Frame", {Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = C.panel, BorderSizePixel = 0}, activePage))
    corner(f, 7)
    label(f, text, UDim2.fromOffset(10, 0), UDim2.new(1, -20, 1, 0), 11, C.violet, Enum.Font.GothamBold)
end
local function infoCard(title, description, height)
    local f = ordered(make("Frame", {Size = UDim2.new(1, 0, 0, height or 54), BackgroundColor3 = C.panel, BorderSizePixel = 0}, activePage))
    corner(f, 8)
    label(f, title, UDim2.fromOffset(11, 6), UDim2.new(1, -22, 0, 18), 12, C.text, Enum.Font.GothamBold)
    label(f, description, UDim2.fromOffset(11, 25), UDim2.new(1, -22, 1, -29), 10, C.muted)
    return f
end

activePage = pages.Visual
nextLayoutOrder = 1
pageHeader("Visual", "Role ESP and player indicators")
nextLayoutOrder = 1
sectionTitle("ROLE ESP")
infoCard("Automatic role labels", "Murderer = red  •  Sheriff = blue  •  Innocent = green", 44)
local espStatus = infoCard("ESP: OFF", "Waiting for round data.", 46)
local espStatusTitle = espStatus:FindFirstChildWhichIsA("TextLabel")
local espEnabled = false
local roleColors = {Murderer = C.red, Sheriff = C.blue, Innocent = C.green}
local highlights, labels = {}, {}

local currentRoundClient
local roundPlayerData = {}
do
    local modules = ReplicatedStorage:FindFirstChild("Modules")
    local moduleScript = modules and modules:FindFirstChild("CurrentRoundClient")
    if moduleScript and moduleScript:IsA("ModuleScript") then
        local ok, result = pcall(require, moduleScript)
        if ok and type(result) == "table" then
            currentRoundClient = result
            if type(result.PlayerData) == "table" then roundPlayerData = result.PlayerData end
        else
            warn("[Starfall] CurrentRoundClient load failed:", result)
        end
    end
end

local function refreshRoundData()
    if not currentRoundClient then return end
    local ok, latest = pcall(function() return currentRoundClient.GetLatestPlayerData() end)
    if ok and type(latest) == "table" then
        roundPlayerData = latest
    elseif type(currentRoundClient.PlayerData) == "table" then
        roundPlayerData = currentRoundClient.PlayerData
    end
end

local function roleFor(target)
    local testRole = target:GetAttribute("StarfallTestRole")
    if roleColors[testRole] then return testRole end
    local entry = roundPlayerData[target.Name]
    if type(entry) == "table" and roleColors[entry.Role] then return entry.Role end
    for key, value in pairs(roundPlayerData) do
        if type(value) == "table" and roleColors[value.Role] then
            local name = value.Name or value.PlayerName or value.Username
            if name == target.Name or key == target.Name then return value.Role end
        end
    end
    return nil
end

local function clearESP()
    for _, item in pairs(highlights) do if item then item:Destroy() end end
    for _, item in pairs(labels) do if item then item:Destroy() end end
    table.clear(highlights)
    table.clear(labels)
end

local function updateESP()
    clearESP()
    if not espEnabled then
        espStatusTitle.Text = "ESP: OFF"
        return
    end
    local count = 0
    for _, target in ipairs(Players:GetPlayers()) do
        local role = roleFor(target)
        local char = target.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local color = roleColors[role]
        if color and char and root then
            count += 1
            local h = Instance.new("Highlight")
            h.Name = "StarfallRoleHighlight"
            h.Adornee = char
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.FillColor, h.OutlineColor = color, color
            h.FillTransparency, h.OutlineTransparency = 0.78, 0.05
            h.Parent = gui
            highlights[target] = h

            local bb = Instance.new("BillboardGui")
            bb.Name = "StarfallRoleLabel"
            bb.Adornee = root
            bb.AlwaysOnTop = true
            bb.Size = UDim2.fromOffset(190, 30)
            bb.StudsOffsetWorldSpace = Vector3.new(0, 3.1, 0)
            bb.MaxDistance = 900
            bb.Parent = gui
            local txt = make("TextLabel", {
                BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
                Font = Enum.Font.GothamBold, TextSize = 12,
                TextStrokeTransparency = 0.25, TextColor3 = color,
                Text = string.upper(role) .. "  •  " .. target.DisplayName,
            }, bb)
            labels[target] = bb
        end
    end
    espStatusTitle.Text = ("ESP: ON  •  %d players detected"):format(count)
end

local espToggle
local function setESP(value)
    espEnabled = value
    espToggle.Text = value and "ESP  •  ON" or "ESP  •  OFF"
    espToggle.BackgroundColor3 = value and C.violet or C.panel2
    updateESP()
end
espToggle = button(activePage, "ESP  •  OFF", UDim2.new(), UDim2.new(1, 0, 0, 38), function()
    setESP(not espEnabled)
end)
ordered(espToggle)

local refreshButton = button(activePage, "↻  Refresh roles now", UDim2.new(), UDim2.new(1, 0, 0, 34), function()
    refreshRoundData()
    updateESP()
end, C.panel2)
ordered(refreshButton)

if currentRoundClient and currentRoundClient.PlayerDataChanged then
    pcall(function()
        currentRoundClient.PlayerDataChanged.Event:Connect(function()
            if type(currentRoundClient.PlayerData) == "table" then roundPlayerData = currentRoundClient.PlayerData end
            updateESP()
        end)
    end)
end
task.spawn(function()
    refreshRoundData()
    updateESP()
end)
local function watchPlayer(p)
    p:GetAttributeChangedSignal("StarfallTestRole"):Connect(updateESP)
    p.CharacterAdded:Connect(function()
        task.wait(0.35)
        updateESP()
    end)
end
for _, p in ipairs(Players:GetPlayers()) do watchPlayer(p) end
Players.PlayerAdded:Connect(function(p) watchPlayer(p); task.defer(updateESP) end)
Players.PlayerRemoving:Connect(function(p)
    if highlights[p] then highlights[p]:Destroy(); highlights[p] = nil end
    if labels[p] then labels[p]:Destroy(); labels[p] = nil end
    task.defer(updateESP)
end)

activePage = pages.Other
nextLayoutOrder = 1
pageHeader("Other", "Small quality-of-life options")
nextLayoutOrder = 1
sectionTitle("MOVEMENT")
infoCard("Slightly faster", "Local test speed: 20 WalkSpeed. Toggle off to restore your original speed.", 44)
local speedOn, originalSpeed = false, nil
local speedToggle
local function setSpeed(value)
    speedOn = value
    speedToggle.Text = value and "RUN SPEED  •  ON" or "RUN SPEED  •  OFF"
    speedToggle.BackgroundColor3 = value and C.blue or C.panel2
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        if value then
            if originalSpeed == nil then originalSpeed = hum.WalkSpeed end
            hum.WalkSpeed = math.max(originalSpeed, 20)
        else
            if originalSpeed ~= nil then hum.WalkSpeed = originalSpeed end
            originalSpeed = nil
        end
    end
end
speedToggle = button(activePage, "RUN SPEED  •  OFF", UDim2.new(), UDim2.new(1, 0, 0, 36), function()
    setSpeed(not speedOn)
end, C.panel2)
ordered(speedToggle)
player.CharacterAdded:Connect(function(char)
    task.wait(0.4)
    if speedOn then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then originalSpeed = hum.WalkSpeed; hum.WalkSpeed = math.max(originalSpeed, 20) end
    end
end)

sectionTitle("NIGHT TEXTURE")
infoCard("Nightfall visual preset", "Dark blue night atmosphere, cool ambient light and subtle fog. Local visual effect.", 44)
local nightOn = false
local nightToggle
local oldLighting = {}
local atmosphere, colorCorrection
local function setNight(value)
    nightOn = value
    nightToggle.Text = value and "NIGHT TEXTURE  •  ON" or "NIGHT TEXTURE  •  OFF"
    nightToggle.BackgroundColor3 = value and C.violet or C.panel2
    if value then
        if next(oldLighting) == nil then
            for _, prop in ipairs({"ClockTime", "Brightness", "Ambient", "OutdoorAmbient", "FogColor", "FogEnd", "ExposureCompensation", "GlobalShadows"}) do
                local ok, val = pcall(function() return Lighting[prop] end)
                if ok then oldLighting[prop] = val end
            end
        end
        Lighting.ClockTime = 0.15
        Lighting.Brightness = 1.8
        Lighting.Ambient = Color3.fromRGB(36, 42, 78)
        Lighting.OutdoorAmbient = Color3.fromRGB(42, 49, 88)
        Lighting.FogColor = Color3.fromRGB(13, 17, 38)
        Lighting.FogEnd = 950
        Lighting.ExposureCompensation = -0.15
        Lighting.GlobalShadows = true
        atmosphere = Lighting:FindFirstChild("StarfallNightAtmosphere") or Instance.new("Atmosphere")
        atmosphere.Name = "StarfallNightAtmosphere"
        atmosphere.Density = 0.24
        atmosphere.Offset = 0.1
        atmosphere.Color = Color3.fromRGB(115, 130, 205)
        atmosphere.Decay = Color3.fromRGB(30, 35, 75)
        atmosphere.Glare = 0
        atmosphere.Haze = 1.2
        atmosphere.Parent = Lighting
        colorCorrection = Lighting:FindFirstChild("StarfallNightColor") or Instance.new("ColorCorrectionEffect")
        colorCorrection.Name = "StarfallNightColor"
        colorCorrection.TintColor = Color3.fromRGB(180, 190, 255)
        colorCorrection.Saturation = -0.18
        colorCorrection.Contrast = 0.12
        colorCorrection.Brightness = -0.03
        colorCorrection.Parent = Lighting
    else
        for prop, val in pairs(oldLighting) do pcall(function() Lighting[prop] = val end) end
        table.clear(oldLighting)
        if atmosphere and atmosphere.Parent then atmosphere:Destroy() end
        if colorCorrection and colorCorrection.Parent then colorCorrection:Destroy() end
        atmosphere, colorCorrection = nil, nil
    end
end
nightToggle = button(activePage, "NIGHT TEXTURE  •  OFF", UDim2.new(), UDim2.new(1, 0, 0, 36), function()
    setNight(not nightOn)
end, C.panel2)
ordered(nightToggle)

sectionTitle("ANTI FLYING")
infoCard("Anti-flying protection", "Not active yet. Real anti-fling protection must be validated by the server; this switch is only a UI status until that server logic exists.", 66)
local antiFlyingEnabled = false
local antiFlyingButton = button(activePage, "ANTI FLYING  •  NOT CONFIGURED", UDim2.new(), UDim2.new(1, 0, 0, 36), function()
    antiFlyingEnabled = not antiFlyingEnabled
    antiFlyingButton.Text = antiFlyingEnabled and "ANTI FLYING  •  PLACEHOLDER ON" or "ANTI FLYING  •  NOT CONFIGURED"
    antiFlyingButton.BackgroundColor3 = antiFlyingEnabled and C.blue or C.panel2
    print("[Starfall] Anti-flying is a UI placeholder; server protection is not active.")
end, C.panel2)
ordered(antiFlyingButton)

-- Restore local modifications when the UI is destroyed.
gui.Destroying:Connect(function()
    if speedOn then setSpeed(false) end
    if nightOn then setNight(false) end
    clearESP()
end)

-- Static informational pages and future feature placeholders.
activePage = pages.Home
nextLayoutOrder = 1
pageHeader("Welcome to Starfall", "Your control center at a glance")
infoCard("Session", "Player: " .. player.DisplayName .. "  •  Username: @" .. player.Name, 54)
local statusCard = infoCard("Quick status", "Panel ready  •  Toggle key: K  •  Build: Starfall Control Center", 54)
local statusText = statusCard:FindFirstChildWhichIsA("TextLabel")
local clockCard = infoCard("LOCAL TIME", "--:--:--", 54)
local clockTitle = clockCard:FindFirstChildWhichIsA("TextLabel")
local clockDetail = clockCard:FindFirstChildWhichIsA("TextLabel")
-- Keep the dashboard useful without requiring any game-specific remotes.
task.spawn(function()
    while gui.Parent do
        local now = DateTime.now():ToLocalTime()
        local timeText = string.format("%02d:%02d:%02d", now.Hour, now.Minute, now.Second)
        if clockTitle then clockTitle.Text = "LOCAL TIME  •  " .. timeText end
        if clockDetail then
            clockDetail.Text = string.format("%04d-%02d-%02d  •  Starfall is running", now.Year, now.Month, now.Day)
        end
        task.wait(1)
    end
end)
infoCard("Navigation", "Use the left menu to open Visual, Perks, Whitelist, Teleport and Other.", 54)

activePage = pages.Perks
nextLayoutOrder = 1
pageHeader("Perks", "Admin-only tools")
infoCard("Autoshoot", "Prototype entry added. Target selection, firing and permissions are not implemented; configure only for an experience you own or administer.", 72)
local autoshootEnabled = false
local autoshootButton
autoshootButton = button(activePage, "AUTOSHOOT  •  NOT CONFIGURED", UDim2.new(), UDim2.new(1, -5, 0, 38), function()
    autoshootEnabled = not autoshootEnabled
    autoshootButton.Text = autoshootEnabled and "AUTOSHOOT  •  PLACEHOLDER ON" or "AUTOSHOOT  •  NOT CONFIGURED"
    autoshootButton.BackgroundColor3 = autoshootEnabled and C.violet or C.panel2
    print("[Starfall] Autoshoot is a UI placeholder; no automatic firing is active.")
end, C.panel2)
ordered(autoshootButton)
infoCard("Admin permissions", "For a real admin perk, verify authorized UserIds on the server. A client toggle alone is not a security check.", 62)

activePage = pages.Whitelist
nextLayoutOrder = 1
pageHeader("Whitelist", "Panel access list")
infoCard("Access control", "This page is a UI placeholder. A client-side list cannot securely prevent other players from using scripts; enforce access on your own game server.", 82)
local whitelistInput = make("TextBox", {
    Size = UDim2.new(1, -5, 0, 36), BackgroundColor3 = C.panel,
    BorderSizePixel = 0, PlaceholderText = "Enter username or UserId",
    Text = "", TextColor3 = C.text, PlaceholderColor3 = C.muted,
    Font = Enum.Font.Gotham, TextSize = 12, ClearTextOnFocus = false,
}, activePage)
corner(whitelistInput, 8)
local whitelistNote = infoCard("No entries", "No access list has been saved. Configure authoritative permissions in the server script.", 54)
local whitelistAdd = button(activePage, "＋  Add to local draft", UDim2.new(), UDim2.new(1, -5, 0, 36), function()
    local value = string.gsub(whitelistInput.Text, "^%s*(.-)%s*$", "%1")
    if value ~= "" then
        whitelistNote:FindFirstChildWhichIsA("TextLabel").Text = "Draft entry: " .. value
        whitelistInput.Text = ""
    end
end, C.panel2)
ordered(whitelistAdd)

activePage = pages.Teleport
nextLayoutOrder = 1
pageHeader("Teleport", "Destinations and player jumps")
infoCard("Map destinations", "Teleport points and map locations need named parts and server-side support in your own experience.", 66)
local mapPlaceholder = button(activePage, "MAP DESTINATIONS  •  COMING SOON", UDim2.new(), UDim2.new(1, -5, 0, 38), function()
    print("[Starfall] Map teleport destinations are not configured yet.")
end, C.panel2)
ordered(mapPlaceholder)
local playerPlaceholder = button(activePage, "PLAYER TELEPORT  •  COMING SOON", UDim2.new(), UDim2.new(1, -5, 0, 38), function()
    print("[Starfall] Player teleport is not configured yet.")
end, C.panel2)
ordered(playerPlaceholder)

-- Restore local modifications when the UI is destroyed.
gui.Destroying:Connect(function()
    if speedOn then setSpeed(false) end
    if nightOn then setNight(false) end
    clearESP()
end)

label(main, "K: open/close  •  drag ✦ to move it", UDim2.new(0, 16, 1, -20), UDim2.new(1, -32, 0, 14), 9, C.muted)
