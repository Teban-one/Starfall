--[[
    STARFALL | SERVER TEST CONTROLS
    Install as a Script in ServerScriptService.
    Studio-only by default. These test attributes can be connected to your
    own server-side round/economy systems.
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

local STUDIO_ONLY = true
local ALLOWLIST_USER_IDS = {
    -- If you later disable STUDIO_ONLY, add your Roblox numeric UserId here.
    -- [123456789] = true,
}
local remote = ReplicatedStorage:FindFirstChild("StarfallTestAction")
if remote and not remote:IsA("RemoteFunction") then remote:Destroy(); remote = nil end
if not remote then
    remote = Instance.new("RemoteFunction")
    remote.Name = "StarfallTestAction"
    remote.Parent = ReplicatedStorage
end
local ALLOWED_ROLES = {Murderer = true, Sheriff = true, Innocent = true}
local ALLOWED_POINTS = {TestSpawn = true, GunDrop = true}
local ALLOWED_TOOLS = {TestKnife = true, TestGun = true}

local function isAuthorized(player)
    if STUDIO_ONLY and not RunService:IsStudio() then return false end
    if RunService:IsStudio() then return true end
    return ALLOWLIST_USER_IDS[player.UserId] == true
end
local function handleAction(player, actionName, value)
    if typeof(actionName) ~= "string" or #actionName > 40 then return false, "Solicitud inválida." end
    if not isAuthorized(player) then
        warn(("[Starfall] Unauthorized request from %s (%d): %s"):format(player.Name, player.UserId, actionName))
        return false, "Herramientas disponibles solo para desarrolladores autorizados en Studio."
    end
    if actionName == "SetTestRole" then
        if typeof(value) ~= "string" or not ALLOWED_ROLES[value] then return false, "Rol de prueba no válido." end
        player:SetAttribute("StarfallTestRole", value)
        return true, "Rol de prueba establecido: " .. value
    elseif actionName == "ClearTestRole" then
        player:SetAttribute("StarfallTestRole", nil)
        return true, "Rol de prueba eliminado."
    elseif actionName == "EndTestRound" then
        workspace:SetAttribute("StarfallTestRoundEnded", true)
        return true, "Indicador de fin de ronda activado."
    elseif actionName == "ResetTestRound" then
        workspace:SetAttribute("StarfallTestRoundEnded", false)
        return true, "Indicador de fin de ronda reiniciado."
    elseif actionName == "TeleportTestPoint" then
        if typeof(value) ~= "string" or not ALLOWED_POINTS[value] then return false, "Punto no válido." end
        local folder = workspace:FindFirstChild("StarfallTestPoints")
        local point = folder and folder:FindFirstChild(value)
        if not point or not point:IsA("BasePart") then return false, "Crea Workspace/StarfallTestPoints/" .. value .. " (Part)." end
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return false, "Tu personaje aún no está listo." end
        player.Character:PivotTo(point.CFrame + Vector3.new(0, 3, 0))
        return true, "Teletransporte de prueba realizado."
    elseif actionName == "GrantTestCoins" then
        if typeof(value) ~= "number" or value ~= 100 then return false, "Cantidad no válida." end
        local current = player:GetAttribute("StarfallTestCoins")
        if typeof(current) ~= "number" then current = 0 end
        player:SetAttribute("StarfallTestCoins", math.clamp(current + 100, 0, 100000))
        return true, "Saldo de prueba: " .. tostring(player:GetAttribute("StarfallTestCoins"))
    elseif actionName == "ResetMyTestData" then
        player:SetAttribute("StarfallTestRole", nil)
        player:SetAttribute("StarfallTestCoins", 0)
        return true, "Datos de prueba reiniciados."
    elseif actionName == "GiveTestTool" then
        if typeof(value) ~= "string" or not ALLOWED_TOOLS[value] then return false, "Herramienta no válida." end
        local folder = ServerStorage:FindFirstChild("StarfallTestTools")
        local tool = folder and folder:FindFirstChild(value)
        if not tool or not tool:IsA("Tool") then return false, "Crea ServerStorage/StarfallTestTools/" .. value .. " (Tool)." end
        local backpack = player:FindFirstChildOfClass("Backpack")
        if not backpack then return false, "No se encontró Backpack." end
        tool:Clone().Parent = backpack
        return true, value .. " entregado para pruebas."
    end
    return false, "Acción desconocida."
end
remote.OnServerInvoke = function(player, actionName, value)
    local ok, allowed, message = pcall(handleAction, player, actionName, value)
    if not ok then warn("[Starfall] Test action failed:", allowed); return false, "Error interno en la herramienta de pruebas." end
    return allowed, message
end
Players.PlayerAdded:Connect(function(player)
    if typeof(player:GetAttribute("StarfallTestCoins")) ~= "number" then player:SetAttribute("StarfallTestCoins", 0) end
end)
print("[Starfall] Server test controls ready. Studio-only:", STUDIO_ONLY)
