-- Copyright © 2026 Squallqt. All rights reserved.
-- XML persistence for player positions in modSettings/. No business logic. No network.
PlayerLastPositionRepository = {}

PlayerLastPositionRepository.MOD_SETTINGS_DIR = "modSettings/FS25_PlayerLastPosition/"
PlayerLastPositionRepository.savegameId = nil
PlayerLastPositionRepository.generation = nil

---Initialize repository: resolve savegame slot and generation counter
function PlayerLastPositionRepository.initialize()
    PlayerLastPositionRepository.savegameId = "savegame" .. tostring(g_currentMission.missionInfo.savegameIndex)

    local baseDir = getUserProfileAppPath() .. PlayerLastPositionRepository.MOD_SETTINGS_DIR
    createFolder(baseDir)
    local slotDir = baseDir .. PlayerLastPositionRepository.savegameId .. "/"
    createFolder(slotDir)
    local genFilePath = slotDir .. "_generation.xml"

    if not g_currentMission.missionInfo.isValid then
        local oldGen = 0
        if fileExists(genFilePath) then
            local xmlId = loadXMLFile("plpGen", genFilePath)
            if xmlId ~= nil and xmlId ~= 0 then
                oldGen = getXMLInt(xmlId, "generation#value") or 0
                delete(xmlId)
            end
        end
        PlayerLastPositionRepository.generation = oldGen + 1
        local xmlId = createXMLFile("plpGen", genFilePath, "generation")
        if xmlId ~= nil and xmlId ~= 0 then
            setXMLInt(xmlId, "generation#value", PlayerLastPositionRepository.generation)
            saveXMLFile(xmlId)
            delete(xmlId)
        end
    else
        if fileExists(genFilePath) then
            local xmlId = loadXMLFile("plpGen", genFilePath)
            if xmlId ~= nil and xmlId ~= 0 then
                PlayerLastPositionRepository.generation = getXMLInt(xmlId, "generation#value")
                delete(xmlId)
            end
        end
    end
end

---Save player position to XML
-- @param string playerKey Unique player identifier
-- @param number x World X coordinate
-- @param number y World Y coordinate
-- @param number z World Z coordinate
-- @param number yaw Y rotation in radians
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
    if PlayerLastPositionRepository.generation ~= nil then
        setXMLInt(xmlId, "position#gen", PlayerLastPositionRepository.generation)
    end
    saveXMLFile(xmlId)
    delete(xmlId)

    Logging.info("[PlayerLastPosition] Saved '%s' (%.1f, %.1f, %.1f)",
        PlayerLastPositionRepository.sanitizeKey(playerKey), x, y, z)
end

---Load player position from XML
-- @param string playerKey Unique player identifier
-- @return table|nil position {x, y, z, yaw} or nil if not found or generation mismatch
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
    local gen = getXMLInt(xmlId, "position#gen")
    delete(xmlId)

    local currentGen = PlayerLastPositionRepository.generation
    if currentGen ~= nil and gen ~= currentGen then
        deleteFile(filePath)
        return nil
    end

    if x == nil or y == nil or z == nil then
        return nil
    end

    return { x = x, y = y, z = z, yaw = yaw or 0 }
end

---Remove saved position file
-- @param string playerKey Unique player identifier
function PlayerLastPositionRepository.remove(playerKey)
    local filePath = PlayerLastPositionRepository.getFilePath(playerKey)
    if fileExists(filePath) then
        deleteFile(filePath)
    end
end

---Build file path for player position XML
-- @param string playerKey Unique player identifier
-- @return string filePath Absolute path to player XML file
function PlayerLastPositionRepository.getFilePath(playerKey)
    local baseDir = getUserProfileAppPath() .. PlayerLastPositionRepository.MOD_SETTINGS_DIR
    createFolder(baseDir)
    local dir = baseDir .. PlayerLastPositionRepository.savegameId .. "/"
    createFolder(dir)
    return dir .. PlayerLastPositionRepository.sanitizeKey(playerKey) .. ".xml"
end

---Sanitize player key for safe filesystem usage
-- @param string key Raw player key
-- @return string sanitized Safe key with non-alphanumeric chars replaced
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
