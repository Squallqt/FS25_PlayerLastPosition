-- Copyright © 2026 Squallqt. All rights reserved.
-- Mod bootstrap: source loading and mission lifecycle hooks.
local modDirectory = g_currentModDirectory

source(modDirectory .. "scripts/PlayerLastPositionRepository.lua")
source(modDirectory .. "scripts/PlayerLastPositionService.lua")

PlayerLastPosition = {}

---Initialize service on mission load (server-side only)
local function onMissionLoaded()
    if g_server == nil then
        return
    end
    PlayerLastPosition.service = PlayerLastPositionService.new()
    PlayerLastPosition.service:initialize()
end

---Cleanup service on mission end
local function onMissionDeleted()
    if PlayerLastPosition.service ~= nil then
        PlayerLastPosition.service:cleanup()
        PlayerLastPosition.service = nil
    end
end

Mission00.loadMission00Finished = Utils.appendedFunction(Mission00.loadMission00Finished, onMissionLoaded)
BaseMission.delete = Utils.appendedFunction(BaseMission.delete, onMissionDeleted)
