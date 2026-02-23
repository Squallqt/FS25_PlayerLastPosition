--[[
    PlayerLastPositionRepository.lua
    XML persistence for player positions in modSettings/.

    Author: Squallqt
]]

PlayerLastPositionRepository = {}

PlayerLastPositionRepository.MOD_SETTINGS_DIR = "modSettings/FS25_PlayerLastPosition/"

---@param playerKey string
---@param x number
---@param y number
---@param z number
---@param yaw number
function PlayerLastPositionRepository.save(playerKey, x, y, z, yaw)
    local filePath = PlayerLastPositionRepository.getFilePath(playerKey)
    local xmlId = createXMLFile("playerPos", filePath, "position")
    if xmlId == nil or xmlId == 0 then
        return
    end
    setXMLFloat(xmlId, "position#x", x)
    setXMLFloat(xmlId, "position#y", y)
    setXMLFloat(xmlId, "position#z", z)
    setXMLFloat(xmlId, "position#yaw", yaw)
    saveXMLFile(xmlId)
    delete(xmlId)

    Logging.info("[PlayerLastPosition] Saved '%s' (%.1f, %.1f, %.1f)",
        PlayerLastPositionRepository.sanitizeKey(playerKey), x, y, z)
end

---@param playerKey string
---@return table|nil {x, y, z, yaw}
function PlayerLastPositionRepository.load(playerKey)
    local filePath = PlayerLastPositionRepository.getFilePath(playerKey)
    if not fileExists(filePath) then
        return nil
    end
    local xmlId = loadXMLFile("playerPos", filePath)
    if xmlId == nil or xmlId == 0 then
        return nil
    end
    local x   = getXMLFloat(xmlId, "position#x")
    local y   = getXMLFloat(xmlId, "position#y")
    local z   = getXMLFloat(xmlId, "position#z")
    local yaw = getXMLFloat(xmlId, "position#yaw")
    delete(xmlId)
    if x == nil or y == nil or z == nil then
        return nil
    end

    return { x = x, y = y, z = z, yaw = yaw or 0 }
end

---@param playerKey string
function PlayerLastPositionRepository.remove(playerKey)
    local filePath = PlayerLastPositionRepository.getFilePath(playerKey)
    if fileExists(filePath) then
        deleteFile(filePath)
    end
end

---@param playerKey string
---@return string
function PlayerLastPositionRepository.getFilePath(playerKey)
    local dir = getUserProfileAppPath() .. PlayerLastPositionRepository.MOD_SETTINGS_DIR
    createFolder(dir)
    return dir .. PlayerLastPositionRepository.sanitizeKey(playerKey) .. ".xml"
end

---@param key string
---@return string
function PlayerLastPositionRepository.sanitizeKey(key)
    if key == nil then
        return "unknown"
    end
    local safe = tostring(key):gsub("[^%w_%-]", "_")
    if safe == "" then
        return "unknown"
    end
    return safe
end
