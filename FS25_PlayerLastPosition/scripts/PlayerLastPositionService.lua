--[[
    PlayerLastPositionService.lua
    Player lifecycle hooks: save on disconnect, restore on reconnect.
    Server-side only.

    Save: prependedFunction on Player.delete runs BEFORE the engine
    ejects the player from the vehicle (Player.lua:583), so
    getCurrentVehicle() still returns the active vehicle.

    Restore: the engine parks new players at y=-200 (Player.lua:483)
    then repositions them at the spawn point. We poll rootNode.y and
    teleport once the player leaves the parking zone (y > -100).

    Author: Squallqt
]]

PlayerLastPositionService = {}
local PlayerLastPositionService_mt = Class(PlayerLastPositionService)

PlayerLastPositionService.TIMEOUT_MS       = 15000
PlayerLastPositionService.PARKING_Y_THRESH = -100

---@return PlayerLastPositionService
function PlayerLastPositionService.new()
    local self = setmetatable({}, PlayerLastPositionService_mt)
    self.knownPlayers    = {}
    self.pendingRestores = {}
    self.hasWork         = false
    return self
end

function PlayerLastPositionService:initialize()
    PlayerLastPositionRepository.initialize()
    Player.delete        = Utils.prependedFunction(Player.delete, PlayerLastPositionService.onPlayerDelete)
    FSBaseMission.update = Utils.appendedFunction(FSBaseMission.update, PlayerLastPositionService.onUpdate)
end

function PlayerLastPositionService:cleanup()
    self.knownPlayers    = nil
    self.pendingRestores = nil
end

-- Save ----------------------------------------------------------------------

---@param player table
function PlayerLastPositionService.onPlayerDelete(player)
    if player == nil or g_server == nil then
        return
    end

    local playerKey = PlayerLastPositionService.getPlayerKey(player)
    if playerKey == nil then
        return
    end

    local x, y, z, yaw
    local currentVehicle = player:getCurrentVehicle()

    if currentVehicle ~= nil then
        local exitNode = currentVehicle:getExitNode(player)
        if exitNode ~= nil and exitNode ~= 0 then
            x, y, z = getWorldTranslation(exitNode)
            local dx, _, dz = localDirectionToWorld(exitNode, 0, 0, 1)
            yaw = MathUtil.getYRotationFromDirection(dx, dz)
        elseif currentVehicle.rootNode ~= nil and currentVehicle.rootNode ~= 0 then
            x, y, z = getWorldTranslation(currentVehicle.rootNode)
            local dx, _, dz = localDirectionToWorld(currentVehicle.rootNode, 0, 0, 1)
            yaw = MathUtil.getYRotationFromDirection(dx, dz)
            local sideX, _, sideZ = localDirectionToWorld(currentVehicle.rootNode, 3, 0, 0)
            x = x + sideX
            z = z + sideZ
        end
    end

    if x == nil then
        local rootNode = player.rootNode
        if rootNode ~= nil and rootNode ~= 0 then
            local rx, ry, rz = getWorldTranslation(rootNode)
            if rx ~= nil and ry ~= nil and rz ~= nil then
                local dx, _, dz = localDirectionToWorld(rootNode, 0, 0, 1)
                x, y, z = rx, ry, rz
                yaw = MathUtil.getYRotationFromDirection(dx, dz)
            end
        end
    end

    local service = PlayerLastPosition.service
    if service ~= nil and service.knownPlayers ~= nil then
        service.knownPlayers[playerKey] = nil
        service.hasWork = true
    end

    if not PlayerLastPositionService.isPositionValid(x, y, z, yaw) then
        return
    end

    PlayerLastPositionRepository.save(playerKey, x, y, z, yaw)
end

-- Restore -------------------------------------------------------------------

---@param mission table
---@param dt number
function PlayerLastPositionService.onUpdate(mission, dt)
    local service = PlayerLastPosition.service
    if service == nil or g_server == nil then
        return
    end

    local playerSystem = g_currentMission.playerSystem
    if playerSystem ~= nil and playerSystem.players ~= nil then
        for _, player in pairs(playerSystem.players) do
            local playerKey = PlayerLastPositionService.getPlayerKey(player)

            if playerKey ~= nil and not service.knownPlayers[playerKey] then
                service.knownPlayers[playerKey] = true

                local saved = PlayerLastPositionRepository.load(playerKey)
                if saved ~= nil then
                    service.pendingRestores[playerKey] = {
                        timer    = 0,
                        position = saved,
                        player   = player
                    }
                    service.hasWork = true
                end
            end
        end
    end

    if not service.hasWork then
        return
    end

    local toRemove = {}

    for playerKey, entry in pairs(service.pendingRestores) do
        entry.timer = entry.timer + dt

        local player = entry.player
        local canTeleport = false

        if player ~= nil and player.rootNode ~= nil and player.rootNode ~= 0 then
            local _, curY, _ = getWorldTranslation(player.rootNode)

            -- Player left engine parking zone (0, -200, 0)
            if curY ~= nil and curY > PlayerLastPositionService.PARKING_Y_THRESH then
                canTeleport = true
            end

            if entry.timer >= PlayerLastPositionService.TIMEOUT_MS then
                canTeleport = true
            end
        elseif entry.timer >= PlayerLastPositionService.TIMEOUT_MS then
            PlayerLastPositionRepository.remove(playerKey)
            table.insert(toRemove, playerKey)
        end

        if canTeleport then
            local pos = entry.position
            local terrainY = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, pos.x, 0, pos.z)
            local safeY = math.max(pos.y, terrainY + 0.2)

            setWorldTranslation(player.rootNode, pos.x, safeY, pos.z)

            Logging.info("[PlayerLastPosition] Restored '%s' to (%.1f, %.1f, %.1f) after %dms",
                PlayerLastPositionRepository.sanitizeKey(playerKey), pos.x, safeY, pos.z, entry.timer)

            PlayerLastPositionRepository.remove(playerKey)
            table.insert(toRemove, playerKey)
        end
    end

    for _, key in ipairs(toRemove) do
        service.pendingRestores[key] = nil
    end

    if next(service.pendingRestores) == nil then
        service.hasWork = false
    end
end

-- Helpers -------------------------------------------------------------------

---@param player table
---@return string|nil
function PlayerLastPositionService.getPlayerKey(player)
    if player.uniqueUserId ~= nil and player.uniqueUserId ~= "" then
        return tostring(player.uniqueUserId)
    end
    if player.nickname ~= nil and player.nickname ~= "" then
        return "nick_" .. tostring(player.nickname)
    end
    if player.userId ~= nil then
        return "uid_" .. tostring(player.userId)
    end
    return nil
end

---@param x number|nil
---@param y number|nil
---@param z number|nil
---@param yaw number|nil
---@return boolean
function PlayerLastPositionService.isPositionValid(x, y, z, yaw)
    if x == nil or y == nil or z == nil or yaw == nil then
        return false
    end
    if x == 0 and z == 0 then
        return false
    end
    if g_currentMission == nil or g_currentMission.terrainRootNode == nil then
        return false
    end
    local terrainSize = g_currentMission.terrainSize
    if terrainSize == nil or terrainSize == 0 then
        return true
    end
    local halfSize = terrainSize / 2
    return math.abs(x) <= halfSize and math.abs(z) <= halfSize
end
