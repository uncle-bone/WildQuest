local _, ns = ...

ns.Provider = { library = nil, status = "not detected", contract = nil }

local function ReadField(entity, id, key)
    if type(entity) ~= "table" or type(entity.Get) ~= "function" then return nil end
    local ok, value = pcall(entity.Get, id, key)
    if ok then return value end
end

function ns.Provider:Initialize()
    local library = _G.LibQuestieDB
    if type(library) ~= "table" then self.status = "not detected"; return end
    if type(library.RequireContract) ~= "function" then self.status = "incompatible API"; return end
    local ok, supported = pcall(library.RequireContract, 4)
    if not ok or not supported then self.status = "incompatible contract"; return end
    self.library, self.contract = library, library.contractVersion
    self.status = "connected (contract " .. tostring(self.contract or "?") .. ")"
end

function ns.Provider:GetStatus() return self.status end

function ns.Provider:GetQuestName(questID)
    local name = ReadField(self.library and self.library.Quest, questID, "name")
    return type(name) == "string" and name or nil
end

function ns.Provider:GetQuestExists(questID)
    local api = self.library and self.library.Quest
    if not api or type(api.Exists) ~= "function" then return false end
    local ok, exists = pcall(api.Exists, questID)
    return ok and exists == true
end

function ns.Provider:GetQuestDetails(questID)
    local api = self.library and self.library.Quest
    if not api then return nil end
    return {
        name = ReadField(api, questID, "name"),
        questLevel = ReadField(api, questID, "questLevel"),
        requiredLevel = ReadField(api, questID, "requiredLevel"),
        zoneOrSort = ReadField(api, questID, "zoneOrSort"),
        preQuestSingle = ReadField(api, questID, "preQuestSingle"),
        preQuestGroup = ReadField(api, questID, "preQuestGroup"),
        startedBy = ReadField(api, questID, "startedBy"),
        finishedBy = ReadField(api, questID, "finishedBy"),
    }
end

function ns.Provider:GetQuestGiverLocations(questID, finishing)
    local details = self:GetQuestDetails(questID)
    local groups = details and (finishing and details.finishedBy or details.startedBy)
    local result = {}
    if type(groups) ~= "table" or not self.library then return result end
    for groupID = 1, 2 do
        local entity = groupID == 1 and self.library.Npc or self.library.Object
        local ids = groups[groupID]
        if type(ids) == "table" and entity then
            for _, entityID in ipairs(ids) do
                local spawns = ReadField(entity, entityID, "spawns")
                if type(spawns) == "table" then
                    for areaID, points in pairs(spawns) do
                        if type(points) == "table" then
                            for _, point in ipairs(points) do
                                if type(point) == "table" and tonumber(point[1]) and tonumber(point[2]) then
                                    result[#result + 1] = {
                                        kind = groupID == 1 and "NPC" or "object",
                                        id = entityID, area = areaID, x = point[1], y = point[2],
                                    }
                                    if #result >= 3 then return result end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return result
end
