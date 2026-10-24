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

local STUDIO_ONLY = false
local ALLOWLIST_USER_IDS = {
    -- Optional extra developer accounts: [123456789] = true,
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
    -- In a user-owned experience, automatically authorize the actual creator.
    -- Never trust a client-side whitelist for privileged server actions.
    local isUserOwnedCreator = game.CreatorType == Enum.CreatorType.User and player.UserId == game.CreatorId
    return isUserOwnedCreator or ALLOWLIST_USER_IDS[player.UserId] == true
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
    elseif actionName == "AssignTestRole" then
        if typeof(value) ~= "table" or typeof(value.UserId) ~= "number" or not ALLOWED_ROLES[value.Role] then return false, "Asignación de rol no válida." end
        local target = Players:GetPlayerByUserId(value.UserId)
        if not target then return false, "Ese jugador ya no está en la sesión." end
        target:SetAttribute("StarfallTestRole", value.Role)
        return true, ("Rol de prueba %s asignado a %s."):format(value.Role, target.Name)
    elseif actionName == "ClearPlayerTestRole" then
        if typeof(value) ~= "number" then return false, "Jugador no válido." end
        local target = Players:GetPlayerByUserId(value)
        if not target then return false, "Ese jugador ya no está en la sesión." end
        target:SetAttribute("StarfallTestRole", nil)
        return true, "Rol de prueba eliminado para " .. target.Name
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
    elseif actionName == "SetNoclip" then
        if typeof(value) ~= "boolean" then return false, "Estado de noclip no válido." end
        local character = player.Character
        if not character then return false, "Tu personaje aún no está listo." end
        character:SetAttribute("StarfallNoclip", value)
        local function applyPart(part)
            if not part:IsA("BasePart") then return end
            if value then
                if part:GetAttribute("StarfallOriginalCanCollide") == nil then
                    part:SetAttribute("StarfallOriginalCanCollide", part.CanCollide)
                end
                part.CanCollide = false
            else
                local original = part:GetAttribute("StarfallOriginalCanCollide")
                if typeof(original) == "boolean" then part.CanCollide = original end
                part:SetAttribute("StarfallOriginalCanCollide", nil)
            end
        end
        for _, part in ipairs(character:GetDescendants()) do applyPart(part) end
        -- Keep newly added character parts consistent while noclip is enabled.
        local oldConnection = character:FindFirstChild("StarfallNoclipWatcher")
        if oldConnection then oldConnection:Destroy() end
        if value then
            local watcher = Instance.new("Folder")
            watcher.Name = "StarfallNoclipWatcher"
            watcher.Parent = character
            local connection
            connection = character.DescendantAdded:Connect(function(part)
                if character:GetAttribute("StarfallNoclip") == true then
                    task.defer(function()
                        if part.Parent and character:GetAttribute("StarfallNoclip") == true then applyPart(part) end
                    end)
                end
            end)
            watcher.Destroying:Connect(function() if connection then connection:Disconnect() end end)
        end
        return true, value and "Noclip activado; nuevas partes incluidas." or "Noclip desactivado; colisiones originales restauradas."
    elseif actionName == "TeleportToGunDrop" then
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not root then return false, "Tu personaje aún no está listo." end
        local drop = workspace:FindFirstChild("GunDrop", true)
        if not drop then return false, "No se encontró un objeto llamado GunDrop en Workspace." end
        local targetCFrame
        if drop:IsA("BasePart") then
            targetCFrame = drop.CFrame
        elseif drop:IsA("Model") then
            targetCFrame = drop:GetPivot()
        else
            return false, "GunDrop debe ser un Part o Model."
        end
        character:PivotTo(targetCFrame + Vector3.new(0, 3, 0))
        return true, "Teletransporte al GunDrop realizado."
    elseif actionName == "TeleportToPlayer" then
        if typeof(value) ~= "number" then return false, "Jugador no válido." end
        local target = Players:GetPlayerByUserId(value)
        local character = player.Character
        local targetCharacter = target and target.Character
        if not targetCharacter or not targetCharacter:FindFirstChild("HumanoidRootPart") or not character or not character:FindFirstChild("HumanoidRootPart") then
            return false, "No se encontró el personaje de uno de los jugadores."
        end
        character:PivotTo(targetCharacter:GetPivot() * CFrame.new(3, 0, 0))
        return true, "Teletransporte de prueba realizado."
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
