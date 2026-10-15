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

local sidebar = make("Frame", {
    Name = "Sidebar", Position = UDim2.fromOffset(14, 78),
    Size = UDim2.new(0, 150, 1, -94), BackgroundColor3 = COLORS.panel,
    BorderSizePixel = 0,
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
        button.BackgroundColor3 = tabName == name and COLORS.panel2 or COLORS.panel
        button.TextColor3 = tabName == name and COLORS.text or COLORS.muted
    end
    content.CanvasPosition = Vector2.zero
end

local function addTab(name, icon)
    local button = make("TextButton", {
        Name = name .. "Tab", Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = COLORS.panel, BorderSizePixel = 0,
        Text = "  " .. icon .. "   " .. name, TextColor3 = COLORS.muted,
        TextSize = 12, Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, sidebar)
    corner(button, 8)
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
addTab("Visuals", "◈")
addTab("Environment", "☾")
addTab("Movement", "➤")
addTab("Settings", "⚙")
addTab("Roles", "♜")
addTab("Round", "◷")
addTab("Player Test", "✦")
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
heading(visuals, "Visual diagnostics", "Client-side diagnostics for testing your own place.")
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

local roles = pages.Roles
heading(roles, "Role testing", "Only changes test attributes used by your own game. Wire these into your round system.")
for _, roleName in ipairs({"Murderer", "Sheriff", "Innocent"}) do
    action(roles, "Set my test role: " .. roleName, "Server-validated; stores StarfallTestRole on your player.", function()
        requestTest("SetTestRole", roleName)
    end)
end
action(roles, "Clear test role", "Removes the Starfall test-role attribute.", function()
    requestTest("ClearTestRole")
end)

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
heading(espPage, "Role ESP", "Highlights only players with StarfallTestRole attributes in your own test experience.")
local espEnabled = false
local highlights = {}
local function clearRoleHighlights()
    for playerTarget, highlight in pairs(highlights) do
        if highlight and highlight.Parent then highlight:Destroy() end
        highlights[playerTarget] = nil
    end
end
local function refreshRoleHighlights()
    clearRoleHighlights()
    if not espEnabled then return end
    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= player and target:GetAttribute("StarfallTestRole") then
            local char = target.Character
            if char then
                local role = target:GetAttribute("StarfallTestRole")
                local h = Instance.new("Highlight")
                h.Name = "StarfallTestRoleHighlight"
                h.Adornee = char
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                h.FillTransparency = 0.55
                h.OutlineTransparency = 0
                h.FillColor = role == "Murderer" and COLORS.danger or (role == "Sheriff" and COLORS.blue or COLORS.success)
                h.OutlineColor = h.FillColor
                h.Parent = gui
                highlights[target] = h
            end
        end
    end
end
toggle(espPage, "Enable role highlights", "Only reads StarfallTestRole attributes.", false, function(value)
    espEnabled = value
    refreshRoleHighlights()
end)
Players.PlayerAdded:Connect(function(p)
    p:GetAttributeChangedSignal("StarfallTestRole"):Connect(refreshRoleHighlights)
    p.CharacterAdded:Connect(refreshRoleHighlights)
end)
for _, p in ipairs(Players:GetPlayers()) do
    p:GetAttributeChangedSignal("StarfallTestRole"):Connect(refreshRoleHighlights)
    p.CharacterAdded:Connect(refreshRoleHighlights)
end
Players.PlayerRemoving:Connect(function(p)
    if highlights[p] then highlights[p]:Destroy(); highlights[p] = nil end
end)


selectTab("Home")
notify("Starfall listo. RightShift abre/cierra el panel.", COLORS.success)
