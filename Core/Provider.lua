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
        objectives = quest.objectives,
        triggerEnd = quest.triggerEnd,
    }
end

function ns.Provider:GetQuestLevelStatus(questID)
    local quest = self:GetQuestRecord(questID)
    local questLevel = tonumber(quest and quest.questLevel)
    local playerLevel = tonumber(UnitLevel and UnitLevel("player"))
    if not questLevel or questLevel <= 0 or not playerLevel then
        return "unknown", questLevel, playerLevel
    end
    if type(GetQuestDifficultyColor) == "function" then
        local ok, color = pcall(GetQuestDifficultyColor, questLevel)
        if ok and type(color) == "table" then
            local r, g, b = tonumber(color.r), tonumber(color.g), tonumber(color.b)
            if r and g and b and math.abs(r - g) < 0.035 and math.abs(g - b) < 0.035 then
                return "gray", questLevel, playerLevel
            end
        end
    end
    local gap = playerLevel - questLevel
    if gap >= 6 then return "gray", questLevel, playerLevel end
    if gap <= -3 then return "above", questLevel, playerLevel end
    return "level-appropriate", questLevel, playerLevel
end

function ns.Provider:AreQuestPrerequisitesConfirmed(questID)
    local quest = self:GetQuestRecord(questID)
    if not quest then return false, "quest facts unavailable" end
    local anyOf = quest.preQuestSingle or {}
    local allOf = quest.preQuestGroup or {}
    if #anyOf > 0 then
        local satisfied = false
        for _, prerequisiteID in ipairs(anyOf) do
            if ns.QuestState:IsQuestTurnedIn(tonumber(prerequisiteID)) then
                satisfied = true
                break
            end
        end
        if not satisfied then return false, "no OR prerequisite is confirmed complete" end
    end
    for _, prerequisiteID in ipairs(allOf) do
        if not ns.QuestState:IsQuestTurnedIn(tonumber(prerequisiteID)) then
            return false, "an AND prerequisite is not confirmed complete"
        end
    end
    local parentID = tonumber(quest.parentQuest)
    if parentID and parentID > 0 and not ns.QuestState:IsQuestTurnedIn(parentID) then
        return false, "parent quest is not confirmed complete"
    end
    return true, "all known prerequisites are confirmed complete"
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


local raceIDs = { Human=1, Orc=2, Dwarf=3, NightElf=4, Scourge=5, Tauren=6, Gnome=7,
    Troll=8, BloodElf=10, Draenei=11 }
local classIDs = { WARRIOR=1, PALADIN=2, HUNTER=3, ROGUE=4, PRIEST=5,
    DEATHKNIGHT=6, SHAMAN=7, MAGE=8, WARLOCK=9, DRUID=11 }
local function MaskContains(mask, id)
    mask, id = tonumber(mask), tonumber(id)
    if not mask or not id or mask <= 0 then return nil end
    return math.floor(mask / (2 ^ (id - 1))) % 2 == 1
end
function ns.Provider:GetCharacterAvailability(questID)
    local quest = self:GetQuestRecord(questID)
    if not quest then return nil, "quest facts are unavailable" end
    local raceToken, classToken
    if type(UnitRace) == "function" then local _, token = UnitRace("player"); raceToken = token end
    if type(UnitClass) == "function" then local _, token = UnitClass("player"); classToken = token end
    local raceAllowed = MaskContains(quest.requiredRaces, raceIDs[raceToken])
    local classAllowed = MaskContains(quest.requiredClasses, classIDs[classToken])
    if raceAllowed == false then return false, "race restriction" end
    if classAllowed == false then return false, "class restriction" end
    if quest.requiredLevel and UnitLevel and UnitLevel("player") < quest.requiredLevel then
        return false, "below required level"
    end
    if raceAllowed == nil and tonumber(quest.requiredRaces) and tonumber(quest.requiredRaces) > 0 then
        return nil, "race requirement is not recognized by this client"
    end
    if classAllowed == nil and tonumber(quest.requiredClasses) and tonumber(quest.requiredClasses) > 0 then
        return nil, "class requirement is not recognized by this client"
    end
    return true, "requirements appear satisfied"
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



