--[[
    STARFALL | PERSONAL EDITION
    Roblox Studio-native testing UI.
    Install as a LocalScript in StarterPlayer > StarterPlayerScripts.
    Toggle UI: RightShift

    This script is designed for your own Studio experience. It does not use
    executor APIs or call game-specific remotes.
]]

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local COLORS = {
    background = Color3.fromRGB(12, 14, 28),
    panel = Color3.fromRGB(19, 23, 43),
    panel2 = Color3.fromRGB(27, 32, 59),
    blue = Color3.fromRGB(77, 139, 255),
    violet = Color3.fromRGB(151, 94, 255),
    text = Color3.fromRGB(239, 242, 255),
    muted = Color3.fromRGB(153, 164, 195),
    success = Color3.fromRGB(104, 226, 177),
    danger = Color3.fromRGB(255, 111, 145),
}

local oldGui = playerGui:FindFirstChild("StarfallUI")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "StarfallUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = parent
    return c
end

local function stroke(parent, color, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or COLORS.violet
    s.Thickness = 1
    s.Transparency = transparency or 0.35
    s.Parent = parent
    return s
end

local function make(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end

local toastHolder = make("Frame", {
    Name = "ToastHolder", BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -20, 0, 20),
    Size = UDim2.fromOffset(280, 200),
}, gui)
make("UIListLayout", {
    Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
}, toastHolder)

local function notify(message, color)
    local toast = make("TextLabel", {
        BackgroundColor3 = COLORS.panel, BackgroundTransparency = 0.05,
        Size = UDim2.new(1, 0, 0, 42), Font = Enum.Font.GothamMedium,
        Text = "  ✦  " .. tostring(message), TextColor3 = color or COLORS.text,
        TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
    }, toastHolder)
    corner(toast, 10)
    stroke(toast, color or COLORS.violet, 0.45)
    task.delay(3, function()
        if toast.Parent then
            TweenService:Create(toast, TweenInfo.new(0.25), {
                BackgroundTransparency = 1, TextTransparency = 1,
            }):Play()
            task.wait(0.3)
            if toast.Parent then toast:Destroy() end
        end
    end)
end

local main = make("Frame", {
    Name = "Main", Size = UDim2.fromOffset(690, 440),
    Position = UDim2.new(0.5, -345, 0.5, -220),
    BackgroundColor3 = COLORS.background, BorderSizePixel = 0,
}, gui)
corner(main, 14)
stroke(main, COLORS.violet, 0.2)

local top = make("Frame", {
    Name = "TopBar", Size = UDim2.new(1, 0, 0, 62),
    BackgroundColor3 = COLORS.panel, BorderSizePixel = 0,
}, main)
corner(top, 14)
make("Frame", {
    Position = UDim2.new(0, 0, 1, -14), Size = UDim2.new(1, 0, 0, 14),
    BackgroundColor3 = COLORS.panel, BorderSizePixel = 0,
}, top)
local accent = make("Frame", {
    Position = UDim2.new(0, 0, 1, -2), Size = UDim2.new(1, 0, 0, 2),
    BorderSizePixel = 0, BackgroundColor3 = COLORS.blue,
}, top)
make("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, COLORS.blue),
        ColorSequenceKeypoint.new(1, COLORS.violet),
    }),
}, accent)

make("TextLabel", {
    BackgroundTransparency = 1, Position = UDim2.fromOffset(20, 10),
    Size = UDim2.fromOffset(230, 25), Font = Enum.Font.GothamBold,
    Text = "✦  STARFALL", TextColor3 = COLORS.text, TextSize = 19,
    TextXAlignment = Enum.TextXAlignment.Left,
}, top)
make("TextLabel", {
    BackgroundTransparency = 1, Position = UDim2.fromOffset(22, 34),
    Size = UDim2.fromOffset(300, 16), Font = Enum.Font.Gotham,
    Text = "PERSONAL EDITION  •  STUDIO TOOLS", TextColor3 = COLORS.muted,
    TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left,
}, top)

local close = make("TextButton", {
    Name = "Close", AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -16, 0.5, 0), Size = UDim2.fromOffset(32, 30),
    BackgroundColor3 = COLORS.panel2, Text = "×", TextSize = 21,
    Font = Enum.Font.Gotham, TextColor3 = COLORS.text, AutoButtonColor = true,
}, top)
corner(close, 8)

local sidebar = make("ScrollingFrame", {
    Name = "Sidebar", Position = UDim2.fromOffset(14, 78),
    Size = UDim2.new(0, 150, 1, -94), BackgroundColor3 = COLORS.panel,
    BorderSizePixel = 0, ScrollBarThickness = 3,
    ScrollBarImageColor3 = COLORS.violet, CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y,
}, main)
corner(sidebar, 10)
make("UIPadding", {
    PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 8),
    PaddingRight = UDim.new(0, 8),
}, sidebar)
make("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, sidebar)

local content = make("ScrollingFrame", {
    Name = "Content", Position = UDim2.fromOffset(178, 78),
    Size = UDim2.new(1, -192, 1, -94), BackgroundColor3 = COLORS.panel,
    BorderSizePixel = 0, ScrollBarThickness = 4, ScrollBarImageColor3 = COLORS.violet,
    CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, main)
corner(content, 10)
make("UIPadding", {
    PaddingTop = UDim.new(0, 16), PaddingBottom = UDim.new(0, 16),
    PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16),
}, content)
local contentLayout = make("UIListLayout", {
    Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder,
}, content)

local pages, tabButtons = {}, {}
local currentTab = nil

local function createPage(name)
    local page = make("Frame", {
        Name = name, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y, Visible = false,
    }, content)
    make("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder}, page)
    pages[name] = page
    return page
end

local function selectTab(name)
    currentTab = name
    for tabName, page in pairs(pages) do page.Visible = tabName == name end
    for tabName, button in pairs(tabButtons) do
        local selected = tabName == name
        if tabName == "Visuals" then
            button.BackgroundColor3 = selected and Color3.fromRGB(53, 61, 116) or Color3.fromRGB(38, 43, 83)
            button.TextColor3 = COLORS.text
        else
            button.BackgroundColor3 = selected and COLORS.panel2 or COLORS.panel
            button.TextColor3 = selected and COLORS.text or COLORS.muted
        end
    end
    content.CanvasPosition = Vector2.zero
end

local function addSectionLabel(text)
    make("TextLabel", {
        Name = text:gsub("%W", "") .. "Section",
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20),
        Font = Enum.Font.GothamBold, Text = text, TextColor3 = COLORS.muted,
        TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left,
    }, sidebar)
end

local function addTab(name, icon)
    local isVisuals = name == "Visuals"
    local button = make("TextButton", {
        Name = name .. "Tab", Size = UDim2.new(1, 0, 0, isVisuals and 42 or 36),
        BackgroundColor3 = isVisuals and Color3.fromRGB(38, 43, 83) or COLORS.panel,
        BorderSizePixel = 0,
        Text = (isVisuals and "  ✦  " or "  ") .. icon .. "   " .. name,
        TextColor3 = isVisuals and COLORS.text or COLORS.muted,
        TextSize = isVisuals and 13 or 12,
        Font = isVisuals and Enum.Font.GothamBold or Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, sidebar)
    corner(button, 8)
    if isVisuals then
        stroke(button, COLORS.violet, 0.15)
        make("Frame", {
            Name = "VisualsAccent", Position = UDim2.new(0, 0, 0, 5),
            Size = UDim2.new(0, 3, 1, -10), BackgroundColor3 = COLORS.violet,
            BorderSizePixel = 0,
        }, button)
    end
    tabButtons[name] = button
    createPage(name)
    button.Activated:Connect(function() selectTab(name) end)
end

local function heading(page, title, subtitle)
    make("TextLabel", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24),
        Font = Enum.Font.GothamBold, Text = title, TextColor3 = COLORS.text,
        TextSize = 17, TextXAlignment = Enum.TextXAlignment.Left,
    }, page)
    if subtitle then
        make("TextLabel", {
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28),
            Font = Enum.Font.Gotham, Text = subtitle, TextColor3 = COLORS.muted,
            TextSize = 11, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
        }, page)
    end
end

local function action(page, title, detail, callback)
    local button = make("TextButton", {
        Size = UDim2.new(1, 0, 0, 52), BackgroundColor3 = COLORS.panel2,
        BorderSizePixel = 0, Text = "", AutoButtonColor = true,
    }, page)
    corner(button, 9)
    make("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 7),
        Size = UDim2.new(1, -24, 0, 18), Font = Enum.Font.GothamMedium,
        Text = title, TextColor3 = COLORS.text, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, button)
    make("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 26),
        Size = UDim2.new(1, -24, 0, 16), Font = Enum.Font.Gotham,
        Text = detail or "", TextColor3 = COLORS.muted, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, button)
    button.Activated:Connect(callback)
    return button
end

local function toggle(page, title, detail, initial, callback)
    local enabled = initial == true
    local button = make("TextButton", {
        Size = UDim2.new(1, 0, 0, 52), BackgroundColor3 = COLORS.panel2,
        BorderSizePixel = 0, Text = "", AutoButtonColor = true,
    }, page)
    corner(button, 9)
    make("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 7),
        Size = UDim2.new(1, -76, 0, 18), Font = Enum.Font.GothamMedium,
        Text = title, TextColor3 = COLORS.text, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, button)
    make("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 26),
        Size = UDim2.new(1, -76, 0, 16), Font = Enum.Font.Gotham,
        Text = detail or "", TextColor3 = COLORS.muted, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, button)
    local pill = make("TextLabel", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(42, 22), BackgroundColor3 = enabled and COLORS.violet or COLORS.background,
        Text = enabled and "ON" or "OFF", TextColor3 = COLORS.text,
        Font = Enum.Font.GothamBold, TextSize = 10,
    }, button)
    corner(pill, 7)
    local function setEnabled(value, shouldNotify)
        enabled = value
        pill.Text = enabled and "ON" or "OFF"
        pill.BackgroundColor3 = enabled and COLORS.violet or COLORS.background
        callback(enabled)
        if shouldNotify then
            notify(title .. (enabled and " activado" or " desactivado"), enabled and COLORS.success or COLORS.muted)
        end
    end
    button.Activated:Connect(function() setEnabled(not enabled, true) end)
    callback(enabled)
    return setEnabled
end

addTab("Home", "⌂")
addSectionLabel("APPEARANCE")
addTab("Visuals", "◈")
addTab("Environment", "☾")
addSectionLabel("TEST TOOLS")
addTab("Movement", "➤")
addTab("Settings", "⚙")
addTab("Roles", "♜")
addTab("Round", "◷")
addTab("Player Test", "✦")
addSectionLabel("DEBUG OVERLAYS")
addTab("ESP", "◎")

local home = pages.Home
heading(home, "Welcome to Starfall", "A personal testing panel for your own Roblox Studio experience.")
action(home, "Studio-native foundation", "No executor, external loader, or HTTP request required.", function()
    notify("Starfall is running inside Roblox Studio.", COLORS.success)
end)
local fpsLabel = make("TextLabel", {
    BackgroundColor3 = COLORS.panel2, Size = UDim2.new(1, 0, 0, 42),
    Font = Enum.Font.GothamMedium, Text = "FPS: --   •   Ping: Studio",
    TextColor3 = COLORS.success, TextSize = 13,
}, home)
corner(fpsLabel, 9)
local frameCount, elapsed = 0, 0
RunService.RenderStepped:Connect(function(dt)
    frameCount += 1
    elapsed += dt
    if elapsed >= 0.5 then
        fpsLabel.Text = ("FPS: %d   •   Ping: Studio"):format(math.floor(frameCount / elapsed + 0.5))
        frameCount, elapsed = 0, 0
    end
end)

local visuals = pages.Visuals
local visualHero = make("Frame", {
    Name = "VisualsHero", Size = UDim2.new(1, 0, 0, 94),
    BackgroundColor3 = Color3.fromRGB(36, 39, 79), BorderSizePixel = 0,
}, visuals)
corner(visualHero, 12)
stroke(visualHero, COLORS.violet, 0.15)
make("TextLabel", {
    BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 12),
    Size = UDim2.new(1, -28, 0, 26), Font = Enum.Font.GothamBold,
    Text = "◈  VISUALS  /  APPEARANCE", TextColor3 = COLORS.text,
    TextSize = 17, TextXAlignment = Enum.TextXAlignment.Left,
}, visualHero)
make("TextLabel", {
    BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 42),
    Size = UDim2.new(1, -28, 0, 38), Font = Enum.Font.Gotham,
    Text = "ONLY visual settings live here: previews, highlights and on-screen labels. Gameplay tests are in the other tabs.",
    TextColor3 = Color3.fromRGB(202, 207, 238), TextSize = 11,
    TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
}, visualHero)
heading(visuals, "Appearance & diagnostics", "Local-only previews for your own Studio test experience.")
local roleLegend = make("Frame", {
    Name = "RoleColorLegend", BackgroundColor3 = COLORS.panel2,
    BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 52),
}, visuals)
corner(roleLegend, 9)
make("TextLabel", {
    BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 5),
    Size = UDim2.new(1, -20, 0, 15), Font = Enum.Font.GothamBold,
    Text = "TEST ROLE COLOR KEY", TextColor3 = COLORS.muted, TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left,
}, roleLegend)
for index, entry in ipairs({
    {name = "Murderer", color = COLORS.danger},
    {name = "Sheriff", color = COLORS.blue},
    {name = "Innocent", color = COLORS.success},
}) do
    local chip = make("Frame", {
        Position = UDim2.new((index - 1) / 3, 10, 0, 25),
        Size = UDim2.new(1 / 3, -14, 0, 19),
        BackgroundColor3 = entry.color, BorderSizePixel = 0,
    }, roleLegend)
    corner(chip, 5)
    make("TextLabel", {
        BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
        Font = Enum.Font.GothamBold, Text = entry.name,
        TextColor3 = Color3.new(1, 1, 1), TextSize = 9,
    }, chip)
end
action(visuals, "Open Role ESP settings →", "Role outlines and labels are grouped in the ESP tab under Debug Overlays.", function()
    selectTab("ESP")
    notify("Role ESP is under DEBUG OVERLAYS.", COLORS.violet)
end)
action(visuals, "Inspect local character", "Prints the character and Humanoid state to Output.", function()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    print("[Starfall] Character:", char and char:GetFullName() or "none",
        "Humanoid:", hum and hum:GetState().Name or "none")
    notify("Diagnóstico enviado a Output.", COLORS.success)
end)
action(visuals, "Refresh diagnostics", "Reports player count and current camera.", function()
    print(("[Starfall] Players: %d | Camera: %s"):format(#Players:GetPlayers(), tostring(workspace.CurrentCamera)))
    notify("Diagnóstico actualizado.", COLORS.success)
end)
action(visuals, "Preview: highlight my character", "Adds a temporary violet outline to your own avatar.", function()
    local char = player.Character
    if not char then notify("Tu personaje aún no está listo.", COLORS.danger) return end
    local existing = gui:FindFirstChild("StarfallVisualPreview")
    if existing then existing:Destroy() end
    local h = Instance.new("Highlight")
    h.Name = "StarfallVisualPreview"
    h.Adornee = char
    h.FillColor = COLORS.violet
    h.OutlineColor = COLORS.blue
    h.FillTransparency = 0.8
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = gui
    notify("Vista previa visual activada.", COLORS.success)
end)
action(visuals, "Clear visual preview", "Removes the temporary character outline.", function()
    local existing = gui:FindFirstChild("StarfallVisualPreview")
    if existing then existing:Destroy() end
    notify("Vista previa eliminada.", COLORS.success)
end)

local environment = pages.Environment
heading(environment, "Environment", "Reversible local lighting presets. These changes affect only your client.")
local originalLighting = {}
local savedLighting = false
local function saveLighting()
    if savedLighting then return end
    savedLighting = true
    for _, property in ipairs({
        "Brightness", "ClockTime", "Ambient", "OutdoorAmbient", "ColorShift_Bottom",
        "ColorShift_Top", "FogColor", "FogEnd", "ExposureCompensation",
        "GlobalShadows", "ShadowSoftness",
    }) do
        local ok, value = pcall(function() return Lighting[property] end)
        if ok then originalLighting[property] = value end
    end
end
local function restoreLighting()
    for property, value in pairs(originalLighting) do
        pcall(function() Lighting[property] = value end)
    end
    savedLighting = false
    table.clear(originalLighting)
end
action(environment, "Nightfall preset", "Deep navy atmosphere with cool moonlit highlights.", function()
    saveLighting()
    Lighting.ClockTime = 0
    Lighting.Brightness = 2
    Lighting.Ambient = Color3.fromRGB(35, 40, 75)
    Lighting.OutdoorAmbient = Color3.fromRGB(45, 55, 95)
    Lighting.ColorShift_Top = Color3.fromRGB(90, 110, 210)
    Lighting.ColorShift_Bottom = Color3.fromRGB(25, 20, 65)
    Lighting.FogColor = Color3.fromRGB(15, 18, 40)
    Lighting.FogEnd = 1200
    Lighting.GlobalShadows = true
    notify("Preset Nightfall aplicado. Usa Restore para volver.", COLORS.success)
end)
action(environment, "Restore lighting", "Restores the values saved before the preset.", function()
    if not savedLighting then
        notify("No hay cambios guardados para restaurar.", COLORS.muted)
        return
    end
    restoreLighting()
    notify("Iluminación restaurada.", COLORS.success)
end)

local movement = pages.Movement
heading(movement, "Movement test", "Local-only movement diagnostics for your own test place.")
local originalWalkSpeed
local speedConnection
action(movement, "Toggle test speed", "Sets your own Humanoid WalkSpeed to 24; press again to restore.", function()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then notify("No se encontró Humanoid.", COLORS.danger) return end
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
        if originalWalkSpeed then hum.WalkSpeed = originalWalkSpeed end
        originalWalkSpeed = nil
        notify("Velocidad original restaurada.", COLORS.success)
    else
        originalWalkSpeed = hum.WalkSpeed
        hum.WalkSpeed = 24
        notify("Velocidad de prueba activada.", COLORS.success)
        speedConnection = player.CharacterAdded:Connect(function()
            if speedConnection then speedConnection:Disconnect(); speedConnection = nil end
            originalWalkSpeed = nil
        end)
    end
end)

local settings = pages.Settings
heading(settings, "Settings", "Starfall preferences and cleanup.")
action(settings, "Reset lighting", "Undo the local environment preset.", function()
    if savedLighting then restoreLighting() end
    notify("Restauración completada.", COLORS.success)
end)
action(settings, "About Starfall", "Personal Edition • Roblox Studio • UI foundation.", function()
    notify("Starfall | Personal Edition", COLORS.violet)
end)

local visible = true
local function setVisible(value)
    visible = value
    main.Visible = value
end
close.Activated:Connect(function() setVisible(false) end)
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        setVisible(not visible)
    end
end)

-- Drag the window from the top bar.
local dragging, dragStart, startPos
top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
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


-- Server-authorized test controls. The server rejects calls outside Studio by default.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local testRemote = ReplicatedStorage:WaitForChild("StarfallTestAction", 10)
local function requestTest(actionName, value)
    if not testRemote then
        notify("Falta StarfallServer.server.lua en ServerScriptService.", COLORS.danger)
        return nil
    end
    local ok, allowed, message = pcall(function()
        return testRemote:InvokeServer(actionName, value)
    end)
    if not ok then
        notify("No se pudo contactar el servidor de pruebas.", COLORS.danger)
        warn("[Starfall] Remote error:", allowed)
        return nil
    end
    notify(message or (allowed and "Acción completada." or "Acción rechazada."), allowed and COLORS.success or COLORS.danger)
    return allowed
end

local refreshRoleHighlights
local roles = pages.Roles
heading(roles, "Role preview", "TEST TOOLS: assign preview attributes here. Appearance controls are in Visuals; role overlays are in ESP.")
local rolePreviewColors = {
    Murderer = COLORS.danger,
    Sheriff = COLORS.blue,
    Innocent = COLORS.success,
}
local rolePreviewStatus = make("TextLabel", {
    BackgroundColor3 = COLORS.panel2, Size = UDim2.new(1, 0, 0, 38),
    Font = Enum.Font.GothamMedium, Text = "PREVIEW ROLE: NONE",
    TextColor3 = COLORS.muted, TextSize = 11,
}, roles)
corner(rolePreviewStatus, 9)
local function setLocalRolePreview(roleName)
    player:SetAttribute("StarfallTestRole", roleName)
    rolePreviewStatus.Text = "PREVIEW ROLE: " .. string.upper(roleName)
    rolePreviewStatus.TextColor3 = rolePreviewColors[roleName]
    notify("Vista previa de rol: " .. roleName, rolePreviewColors[roleName])
end
for _, roleName in ipairs({"Murderer", "Sheriff", "Innocent"}) do
    action(roles, "Preview role: " .. roleName, "Applies a local visual tag for ESP testing.", function()
        setLocalRolePreview(roleName)
        refreshRoleHighlights()
    end)
end
action(roles, "Clear preview role", "Removes the local preview tag.", function()
    player:SetAttribute("StarfallTestRole", nil)
    rolePreviewStatus.Text = "PREVIEW ROLE: NONE"
    rolePreviewStatus.TextColor3 = COLORS.muted
    refreshRoleHighlights()
    notify("Vista previa de rol eliminada.", COLORS.success)
end)
action(roles, "Apply role on server (Studio only)", "Sets your own server-side test role.", function()
    requestTest("SetTestRole", player:GetAttribute("StarfallTestRole"))
end)

local rosterFrame = make("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y}, roles)
local rosterLayout = Instance.new("UIListLayout")
rosterLayout.Padding = UDim.new(0, 6)
rosterLayout.SortOrder = Enum.SortOrder.LayoutOrder
rosterLayout.Parent = rosterFrame
local rosterHint = make("TextLabel", {
    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30),
    Font = Enum.Font.Gotham, Text = "Server role assignment • Studio test only",
    TextColor3 = COLORS.muted, TextSize = 10, TextWrapped = true,
}, rosterFrame)
local function refreshRoleRoster()
    for _, child in ipairs(rosterFrame:GetChildren()) do
        if child ~= rosterLayout and child ~= rosterHint then child:Destroy() end
    end
    for _, target in ipairs(Players:GetPlayers()) do
        local row = make("Frame", {BackgroundColor3 = COLORS.panel2, Size = UDim2.new(1, 0, 0, 86)}, rosterFrame)
        corner(row, 8)
        make("TextLabel", {
            BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 5),
            Size = UDim2.new(1, -20, 0, 18), Font = Enum.Font.GothamMedium,
            Text = target.DisplayName .. "  (@" .. target.Name .. ")",
            TextColor3 = COLORS.text, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
        }, row)
        for index, roleName in ipairs({"Murderer", "Sheriff", "Innocent"}) do
            local button = make("TextButton", {
                Position = UDim2.new((index - 1) / 3, 6, 0, 31),
                Size = UDim2.new(1 / 3, -8, 0, 25),
                BackgroundColor3 = rolePreviewColors[roleName], BorderSizePixel = 0,
                Font = Enum.Font.GothamBold, Text = roleName, TextSize = 9,
                TextColor3 = Color3.new(1, 1, 1), AutoButtonColor = true,
            }, row)
            corner(button, 6)
            button.Activated:Connect(function()
                local ok = requestTest("AssignTestRole", {UserId = target.UserId, Role = roleName})
                if ok then task.defer(refreshRoleHighlights) end
            end)
        end
        local clear = make("TextButton", {
            Position = UDim2.new(0, 6, 0, 60), Size = UDim2.new(1, -12, 0, 20),
            BackgroundColor3 = COLORS.panel, BorderSizePixel = 0,
            Font = Enum.Font.Gotham, Text = "Clear role", TextSize = 9, TextColor3 = COLORS.muted,
        }, row)
        corner(clear, 5)
        clear.Activated:Connect(function()
            requestTest("ClearPlayerTestRole", target.UserId)
            task.defer(refreshRoleHighlights)
        end)
    end
end
action(roles, "Refresh player roster", "Reload players and assign test roles from the server.", refreshRoleRoster)
refreshRoleRoster()
Players.PlayerAdded:Connect(function() task.defer(refreshRoleRoster) end)
Players.PlayerRemoving:Connect(function() task.defer(refreshRoleRoster) end)

local round = pages.Round
heading(round, "Round controls", "Developer test flags; connect these to your own round manager.")
action(round, "Mark test round ended", "Sets Workspace attribute StarfallTestRoundEnded = true.", function()
    requestTest("EndTestRound")
end)
action(round, "Reset test round flag", "Sets the test round flag back to false.", function()
    requestTest("ResetTestRound")
end)
action(round, "Teleport to TestSpawn", "Uses Workspace > StarfallTestPoints > TestSpawn.", function()
    requestTest("TeleportTestPoint", "TestSpawn")
end)
action(round, "Teleport to GunDrop", "Uses Workspace > StarfallTestPoints > GunDrop.", function()
    requestTest("TeleportTestPoint", "GunDrop")
end)

local playerTest = pages["Player Test"]
heading(playerTest, "Player test tools", "Server-side test values; not a live economy or production inventory.")
action(playerTest, "Grant 100 test coins", "Adds 100 to the StarfallTestCoins attribute.", function()
    requestTest("GrantTestCoins", 100)
end)
action(playerTest, "Reset my test data", "Clears test role and test coin attributes.", function()
    requestTest("ResetMyTestData")
end)
action(playerTest, "Give test knife", "Clones ServerStorage > StarfallTestTools > TestKnife if configured.", function()
    requestTest("GiveTestTool", "TestKnife")
end)
action(playerTest, "Give test gun", "Clones ServerStorage > StarfallTestTools > TestGun if configured.", function()
    requestTest("GiveTestTool", "TestGun")
end)

local espPage = pages.ESP
heading(espPage, "Automatic Role ESP", "Detects Murderer, Sheriff and Innocent from CurrentRoundClient.PlayerData when the server provides those roles. StarfallTestRole remains available as a test fallback.")
local espNotice = make("TextLabel", {
    BackgroundColor3 = Color3.fromRGB(47, 34, 60),
    Size = UDim2.new(1, 0, 0, 44), Font = Enum.Font.GothamMedium,
    Text = "ROLE SOURCE: CurrentRoundClient.PlayerData → Role",
    TextColor3 = Color3.fromRGB(255, 205, 220), TextSize = 11,
    TextWrapped = true,
}, espPage)
corner(espNotice, 9)
stroke(espNotice, COLORS.danger, 0.35)
local espEnabled = false
local highlights, labels = {}, {}
local roleColors = {
    Murderer = COLORS.danger,
    Sheriff = COLORS.blue,
    Innocent = COLORS.success,
}
local espStatus = make("TextLabel", {
    BackgroundColor3 = COLORS.panel2, Size = UDim2.new(1, 0, 0, 38),
    Font = Enum.Font.GothamMedium, Text = "ESP OFF  •  waiting for round data",
    TextColor3 = COLORS.muted, TextSize = 11, TextWrapped = true,
}, espPage)
corner(espStatus, 9)

-- Automatic role source. CurrentRoundClient is the game's client module; it can only
-- show roles actually returned to this client by the server.
local currentRoundClient
local roundPlayerData = {}
do
    local modules = ReplicatedStorage:FindFirstChild("Modules")
    local moduleScript = modules and modules:FindFirstChild("CurrentRoundClient")
    if moduleScript and moduleScript:IsA("ModuleScript") then
        local ok, result = pcall(require, moduleScript)
        if ok and type(result) == "table" then
            currentRoundClient = result
            if type(result.PlayerData) == "table" then
                roundPlayerData = result.PlayerData
            end
        else
            warn("[Starfall] Could not load CurrentRoundClient:", result)
        end
    end
end

local function refreshRoundPlayerData()
    if currentRoundClient then
        local ok, latest = pcall(function()
            return currentRoundClient.GetLatestPlayerData()
        end)
        if ok and type(latest) == "table" then
            roundPlayerData = latest
        elseif type(currentRoundClient.PlayerData) == "table" then
            roundPlayerData = currentRoundClient.PlayerData
        end
    end
end

local function getRoleForPlayer(target)
    -- Explicit test tags take precedence for local Studio testing.
    local testRole = target:GetAttribute("StarfallTestRole")
    if roleColors[testRole] then return testRole end

    -- PlayerData is commonly keyed by player name in this game's spectator modules.
    local entry = roundPlayerData[target.Name]
    if type(entry) == "table" and roleColors[entry.Role] then
        return entry.Role
    end

    -- Some game versions may return an array of player records instead.
    for key, value in pairs(roundPlayerData) do
        if type(value) == "table" and roleColors[value.Role] then
            local recordName = value.Name or value.PlayerName or value.Username
            if recordName == target.Name or key == target.Name then
                return value.Role
            end
        end
    end
    return nil
end

local function clearRoleESP()
    for target, item in pairs(highlights) do
        if item and item.Parent then item:Destroy() end
        highlights[target] = nil
    end
    for target, item in pairs(labels) do
        if item and item.Parent then item:Destroy() end
        labels[target] = nil
    end
end

refreshRoleHighlights = function()
    clearRoleESP()
    if not espEnabled then
        espStatus.Text = "ESP OFF"
        espStatus.TextColor3 = COLORS.muted
        return
    end
    local tagged = 0
    for _, target in ipairs(Players:GetPlayers()) do
        local role = getRoleForPlayer(target)
        local char = target.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local color = roleColors[role]
        if color and char and root then
                tagged += 1
                local h = Instance.new("Highlight")
                h.Name = "StarfallRoleHighlight"
                h.Adornee = char
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                h.FillTransparency = 0.72
                h.OutlineTransparency = 0.05
                h.FillColor, h.OutlineColor = color, color
                h.Parent = gui
                highlights[target] = h

                local billboard = Instance.new("BillboardGui")
                billboard.Name = "StarfallRoleLabel"
                billboard.Adornee = root
                billboard.AlwaysOnTop = true
                billboard.Size = UDim2.fromOffset(180, 44)
                billboard.StudsOffsetWorldSpace = Vector3.new(0, 3.2, 0)
                billboard.MaxDistance = 1200
                billboard.Parent = gui

                local text = Instance.new("TextLabel")
                text.BackgroundTransparency = 1
                text.Size = UDim2.fromScale(1, 1)
                text.Font = Enum.Font.GothamBold
                text.TextSize = 12
                text.TextStrokeTransparency = 0.25
                text.TextColor3 = color
                text.Text = string.upper(role) .. "  •  " .. target.DisplayName
                text.Parent = billboard
                labels[target] = billboard
        end
    end
    espStatus.Text = ("ESP ON  •  %d role(s) detected"):format(tagged)
    espStatus.TextColor3 = tagged > 0 and COLORS.success or COLORS.muted
end

toggle(espPage, "Enable role ESP", "Outline + role name + display name for tagged test players.", false, function(value)
    espEnabled = value
    refreshRoleHighlights()
end)
action(espPage, "Refresh role ESP", "Rechecks character and role attributes now.", refreshRoleHighlights)
action(espPage, "Clear ESP tags (test)", "Clears only this client's visual overlays.", function()
    clearRoleESP()
    espEnabled = false
    espStatus.Text = "ESP cleared"
    espStatus.TextColor3 = COLORS.muted
    notify("Visual overlays cleared.", COLORS.success)
end)

local function watchPlayer(p)
    p:GetAttributeChangedSignal("StarfallTestRole"):Connect(refreshRoleHighlights)
    p.CharacterAdded:Connect(function()
        task.wait(0.25)
        refreshRoleHighlights()
    end)
end

-- Refresh when the game's round-data module signals changes.
if currentRoundClient and currentRoundClient.PlayerDataChanged then
    pcall(function()
        currentRoundClient.PlayerDataChanged.Event:Connect(function()
            task.defer(function()
                if type(currentRoundClient.PlayerData) == "table" then
                    roundPlayerData = currentRoundClient.PlayerData
                else
                    refreshRoundPlayerData()
                end
                refreshRoleHighlights()
            end)
        end)
    end)
end

-- Fetch the latest snapshot once at startup; no repeated polling.
task.spawn(function()
    refreshRoundPlayerData()
    refreshRoleHighlights()
end)
Players.PlayerAdded:Connect(watchPlayer)
for _, p in ipairs(Players:GetPlayers()) do watchPlayer(p) end
Players.PlayerRemoving:Connect(function(p)
    if highlights[p] then highlights[p]:Destroy(); highlights[p] = nil end
    if labels[p] then labels[p]:Destroy(); labels[p] = nil end
    task.defer(refreshRoleHighlights)
end)


selectTab("Home")
notify("Starfall listo. RightShift abre/cierra el panel.", COLORS.success)
