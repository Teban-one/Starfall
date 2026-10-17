--[[
    STARFALL | ESP EDITION
    For your own Roblox experience / Studio test place.
    RightShift toggles the panel. Hide button leaves a small reopen button.
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
    Name = "Main", Size = UDim2.fromOffset(430, 390),
    Position = UDim2.new(0.5, -215, 0.5, -195),
    BackgroundColor3 = C.bg, BorderSizePixel = 0,
}, gui)
corner(main, 14)
outline(main, C.violet, 0.15)

local top = make("Frame", {
    Name = "TopBar", Size = UDim2.new(1, 0, 0, 62),
    BackgroundColor3 = C.panel, BorderSizePixel = 0,
}, main)
corner(top, 14)
make("Frame", {Position = UDim2.new(0, 0, 1, -12), Size = UDim2.new(1, 0, 0, 12), BackgroundColor3 = C.panel, BorderSizePixel = 0}, top)
local accent = make("Frame", {Position = UDim2.new(0, 0, 1, -2), Size = UDim2.new(1, 0, 0, 2), BorderSizePixel = 0, BackgroundColor3 = C.blue}, top)
make("UIGradient", {Color = ColorSequence.new(C.blue, C.violet)}, accent)
label(top, "✦  STARFALL", UDim2.fromOffset(16, 8), UDim2.new(1, -110, 0, 28), 19, C.text, Enum.Font.GothamBold)
label(top, "ESP  •  SPEED  •  NIGHT", UDim2.fromOffset(18, 35), UDim2.new(1, -120, 0, 15), 9, C.muted)
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
    main.Visible = value
    reopen.Visible = not value
end
hideButton.Activated:Connect(function() setPanelVisible(false) end)
reopen.Activated:Connect(function() setPanelVisible(true) end)
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        setPanelVisible(not main.Visible)
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

local body = make("Frame", {
    Name = "Controls", Position = UDim2.fromOffset(14, 76),
    Size = UDim2.new(1, -28, 1, -90), BackgroundTransparency = 1,
}, main)
make("UIListLayout", {Padding = UDim.new(0, 9), SortOrder = Enum.SortOrder.LayoutOrder}, body)

local function sectionTitle(text)
    local f = make("Frame", {Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = C.panel, BorderSizePixel = 0}, body)
    corner(f, 7)
    label(f, text, UDim2.fromOffset(10, 0), UDim2.new(1, -20, 1, 0), 11, C.violet, Enum.Font.GothamBold)
end
local function infoCard(title, description, height)
    local f = make("Frame", {Size = UDim2.new(1, 0, 0, height or 54), BackgroundColor3 = C.panel, BorderSizePixel = 0}, body)
    corner(f, 8)
    label(f, title, UDim2.fromOffset(11, 6), UDim2.new(1, -22, 0, 18), 12, C.text, Enum.Font.GothamBold)
    label(f, description, UDim2.fromOffset(11, 25), UDim2.new(1, -22, 1, -29), 10, C.muted)
    return f
end

sectionTitle("01  /  ROLE ESP")
infoCard("Automatic role labels", "Murderer = red  •  Sheriff = blue  •  Innocent = green", 44)
local espStatus = infoCard("ESP: OFF", "Waiting for round data.", 46)
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
        espStatus:FindFirstChildWhichIsA("TextLabel").Text = "ESP: OFF"
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
    espStatus:FindFirstChildWhichIsA("TextLabel").Text = ("ESP: ON  •  %d players detected"):format(count)
end

local espToggle
local function setESP(value)
    espEnabled = value
    espToggle.Text = value and "ESP  •  ON" or "ESP  •  OFF"
    espToggle.BackgroundColor3 = value and C.violet or C.panel2
    updateESP()
end
espToggle = button(body, "ESP  •  OFF", UDim2.new(), UDim2.new(1, 0, 0, 38), function()
    setESP(not espEnabled)
end)
espToggle.LayoutOrder = 10

button(body, "↻  Refresh roles now", UDim2.new(), UDim2.new(1, 0, 0, 34), function()
    refreshRoundData()
    updateESP()
end, C.panel2).LayoutOrder = 11

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

sectionTitle("02  /  MOVEMENT")
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
speedToggle = button(body, "RUN SPEED  •  OFF", UDim2.new(), UDim2.new(1, 0, 0, 36), function()
    setSpeed(not speedOn)
end, C.panel2)
speedToggle.LayoutOrder = 20
player.CharacterAdded:Connect(function(char)
    task.wait(0.4)
    if speedOn then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then originalSpeed = hum.WalkSpeed; hum.WalkSpeed = math.max(originalSpeed, 20) end
    end
end)

sectionTitle("03  /  NIGHT TEXTURE")
infoCard("Nightfall visual preset", "Dark blue night atmosphere, cool ambient light and subtle fog. Local visual effect.", 44)
local nightOn = false
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
nightToggle = button(body, "NIGHT TEXTURE  •  OFF", UDim2.new(), UDim2.new(1, 0, 0, 36), function()
    setNight(not nightOn)
end, C.panel2)
nightToggle.LayoutOrder = 30

-- Restore local modifications when the UI is destroyed.
gui.Destroying:Connect(function()
    if speedOn then setSpeed(false) end
    if nightOn then setNight(false) end
    clearESP()
end)

label(main, "RightShift: hide/show  •  — : hide to floating button", UDim2.new(0, 16, 1, -20), UDim2.new(1, -32, 0, 14), 9, C.muted)
notify = function(message) print("[Starfall] " .. tostring(message)) end
