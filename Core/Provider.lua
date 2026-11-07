local _, ns = ...

-- WildQuest uses only its own packaged data. No external quest addon or library is probed.
ns.Provider = { database = nil, status = "bundled data not loaded" }

local function EntityRow(entityType, id)
    local database = ns.BundledDatabase
    local entities = database and database.entities
    local rows = entities and entities[entityType]
    return type(rows) == "table" and rows[id] or nil
end

local function SpawnLocations(entityType, ids, limit, result)
    for _, entityID in ipairs(ids or {}) do
        local entity = EntityRow(entityType, entityID)
        local spawns = type(entity) == "table" and entity.spawns or nil
        if type(spawns) == "table" then
            for areaID, points in pairs(spawns) do
                if type(points) == "table" then
                    for _, point in ipairs(points) do
                        local x = type(point) == "table" and tonumber(point[1])
                        local y = type(point) == "table" and tonumber(point[2])
                        if x and y then
                            result[#result + 1] = {
                                kind = entityType == "Npc" and "NPC" or "object",
                                id = entityID, area = areaID, x = x, y = y,
                                name = entity.name,
                            }
                            if #result >= limit then return true end
                        end
                    end
                end
            end
        end
    end
    return false
end

function ns.Provider:Initialize()
    local database = ns.BundledDatabase
    if type(database) ~= "table" or type(database.entities) ~= "table"
        or type(database.entities.Quest) ~= "table" then
        self.database = nil
        self.status = "bundled quest data missing"
        return false
    end
    self.database = database
    local counts = database.summary or {}
    local questCount = counts.Quest and counts.Quest.rows or "available"
    self.status = "bundled WildQuest data ready (" .. tostring(questCount) .. " quests)"
    return true
end

function ns.Provider:GetStatus()
    return self.status
end

function ns.Provider:GetQuestRecord(questID)
    return EntityRow("Quest", tonumber(questID))
end

function ns.Provider:GetQuestName(questID)
    local record = self:GetQuestRecord(questID)
    return record and type(record.name) == "string" and record.name or nil
end

function ns.Provider:GetQuestExists(questID)
    return self:GetQuestRecord(questID) ~= nil
end

function ns.Provider:GetQuestDetails(questID)
    local quest = self:GetQuestRecord(questID)
    if not quest then return nil end
    return {
        name = quest.name,
        questLevel = quest.questLevel,
        requiredLevel = quest.requiredLevel,
        requiredMaxLevel = quest.requiredMaxLevel,
        requiredRaces = quest.requiredRaces,
        requiredClasses = quest.requiredClasses,
        zoneOrSort = quest.zoneOrSort,
        preQuestSingle = quest.preQuestSingle,
        preQuestGroup = quest.preQuestGroup,
        parentQuest = quest.parentQuest,
        availableStartingWith = quest.availableStartingWith,
        availableUntilCompleted = quest.availableUntilCompleted,
        disabledByQuest = quest.disabledByQuest,
        nextQuestInChain = quest.nextQuestInChain,
        exclusiveTo = quest.exclusiveTo,
        requiredSkill = quest.requiredSkill,
        requiredMinRep = quest.requiredMinRep,
        requiredMaxRep = quest.requiredMaxRep,
        requiredSourceItems = quest.requiredSourceItems,
        startedBy = quest.startedBy,
        finishedBy = quest.finishedBy,
        objectivesText = quest.objectivesText,
    }
end

function ns.Provider:GetQuestGiverLocations(questID, finishing)
    local quest = self:GetQuestRecord(questID)
    local groups = quest and (finishing and quest.finishedBy or quest.startedBy)
    local result = {}
    if type(groups) ~= "table" then return result end
    local npcIDs, objectIDs = groups[1], groups[2]
    if SpawnLocations("Npc", npcIDs, 4, result) then return result end
    SpawnLocations("Object", objectIDs, 4, result)
    return result
end

function ns.Provider:GetQuestPrerequisiteState(questID)
    local quest = self:GetQuestRecord(questID)
    if not quest then return nil end
    return {
        -- OR alternatives: one confirmed completed quest is sufficient.
        anyOf = quest.preQuestSingle or {},
        -- AND groups: every prerequisite is required.
        allOf = quest.preQuestGroup or {},
        activeParent = quest.parentQuest,
        availableStartingWith = quest.availableStartingWith,
        availableUntilCompleted = quest.availableUntilCompleted,
        disabledByQuest = quest.disabledByQuest,
        exclusiveTo = quest.exclusiveTo,
    }
end

