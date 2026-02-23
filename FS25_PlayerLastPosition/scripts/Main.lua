--[[
    FS25_PlayerLastPosition
    Saves player position on disconnect, restores on reconnect.
    Server-side only.

    Author: Squallqt
]]

local modDirectory = g_currentModDirectory

source(modDirectory .. "scripts/PlayerLastPositionRepository.lua")
source(modDirectory .. "scripts/PlayerLastPositionService.lua")

PlayerLastPosition = {}

local function onMissionLoaded()
    if g_server == nil then
        return
    end
    PlayerLastPosition.service = PlayerLastPositionService.new()
    PlayerLastPosition.service:initialize()
end

local function onMissionDeleted()
    if PlayerLastPosition.service ~= nil then
        PlayerLastPosition.service:cleanup()
        PlayerLastPosition.service = nil
    end
end

Mission00.loadMission00Finished = Utils.appendedFunction(Mission00.loadMission00Finished, onMissionLoaded)
BaseMission.delete = Utils.appendedFunction(BaseMission.delete, onMissionDeleted)
