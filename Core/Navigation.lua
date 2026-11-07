local _, ns = ...

ns.Navigation = {}

local function Entity(entityType, id)
    local database = ns.BundledDatabase
    local entities = database and database.entities
    local rows = entities and entities[entityType]
    return type(rows) == "table" and rows[tonumber(id)] or nil
end

local function AddSpawnPoints(entityType, ids, result, limit)
    for _, rawID in ipairs(ids or {}) do
        local id = tonumber(rawID)
        local entity = id and Entity(entityType, id)
        local spawns = entity and entity.spawns
        if type(spawns) == "table" then
            for area, points in pairs(spawns) do
                local areaID = tonumber(area)
                for _, point in ipairs(type(points) == "table" and points or {}) do
                    local x = type(point) == "table" and tonumber(point[1])
                    local y = type(point) == "table" and tonumber(point[2])
                    if areaID and x and y then
                        result[#result + 1] = {
                            id = id, kind = entityType, name = entity.name,
                            areaID = areaID, uiMapID = ns.AreaToUiMap and ns.AreaToUiMap[areaID],
                            x = x, y = y,
                        }
                        if #result >= limit then return true end
                    end
                end
            end
        end
    end
    return false
end

local function AddGivers(quest, finishing, result)
    local groups = quest and (finishing and quest.finishedBy or quest.startedBy)
    if type(groups) ~= "table" then return end
    AddSpawnPoints("Npc", groups[1], result, 40)
    AddSpawnPoints("Object", groups[2], result, 40)
end

local function AddItemSources(itemID, result)
    local item = Entity("Item", itemID)
    if item then
        AddSpawnPoints("Npc", item.npcDrops, result, 40)
        AddSpawnPoints("Object", item.objectDrops, result, 40)
    end
end

local function AddObjectiveSources(quest, objectiveIndex, result)
    local raw = quest and quest.objectives
    if type(raw) ~= "table" then return end

    local flattened = {}
    for group = 1, 6 do
        for _, row in ipairs(type(raw[group]) == "table" and raw[group] or {}) do
            flattened[#flattened + 1] = { group = group, row = row }
        end
    end

    local entry = flattened[objectiveIndex or 1]
    if not entry or type(entry.row) ~= "table" then return end
    local row, group = entry.row, entry.group
    if group == 1 then
        AddSpawnPoints("Npc", { row[1] }, result, 40)
    elseif group == 2 then
        AddSpawnPoints("Object", { row[1] }, result, 40)
    elseif group == 3 then
        AddItemSources(row[1], result)
    elseif group == 5 then
        AddSpawnPoints("Npc", { row[1], row[2] }, result, 40)
    elseif group == 6 then
        AddItemSources(row[3], result)
    end
end

local function AddTriggerEnd(quest, result)
    local trigger = quest and quest.triggerEnd
    local areas = type(trigger) == "table" and trigger[2]
    if type(areas) ~= "table" then return end
    for area, points in pairs(areas) do
        local areaID = tonumber(area)
        for _, point in ipairs(type(points) == "table" and points or {}) do
            if areaID and type(point) == "table" then
                local x, y = tonumber(point[1]), tonumber(point[2])
                if x and y then
                    result[#result + 1] = {
                        kind = "event", name = trigger[1], areaID = areaID,
                        uiMapID = ns.AreaToUiMap and ns.AreaToUiMap[areaID], x = x, y = y,
                    }
                    if #result >= 40 then return end
                end
            end
        end
    end
end

function ns.Navigation:TargetsForQuest(questID, activeQuest, objectiveIndex)
    local quest = Entity("Quest", questID)
    local result = {}
    if not quest then return result end

    if not activeQuest then
        AddGivers(quest, false, result)
        return result
    end

    if activeQuest.isReady then
        AddGivers(quest, true, result)
        return result
    end

    if not objectiveIndex then
        for index, objective in ipairs(activeQuest.objectives or {}) do
            if not objective.finished and (tonumber(objective.fulfilled) or 0) < (tonumber(objective.required) or 1) then
                objectiveIndex = index
                break
            end
        end
    end

    AddObjectiveSources(quest, objectiveIndex, result)
    if #result == 0 then AddTriggerEnd(quest, result) end
    return result
end
