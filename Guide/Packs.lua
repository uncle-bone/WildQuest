local _, ns = ...

ns.GuidePacks = { byID = {}, byGuideID = {}, initialized = false }

local function BuildGuide(pack)
    local steps = {}
    for index, row in ipairs(pack.steps or {}) do
        local questID = tonumber(row.questID)
        if questID and questID > 0 then
            local questName = ns.Provider:GetQuestName(questID) or ("Quest " .. questID)
            local label = questName
            if row.both then label = label .. "  |cff71d7a5(cross-checked)|r" end
            steps[#steps + 1] = {
                id = "q" .. questID,
                text = label,
                goals = { { type = "quest_turned_in", questID = questID } },
            }
        end
    end
    if #steps == 0 then return nil end
    return {
        id = pack.id, title = pack.title, version = "merged-1",
        flavor = "forever", steps = steps,
    }
end

function ns.GuidePacks:Initialize()
    if self.initialized then return end
    self.initialized = true
    local source = ns.WildQuestRoutePacks
    if type(source) ~= "table" then return end
    for _, pack in ipairs(source) do
        if type(pack.id) == "string" and type(pack.steps) == "table" then
            local guide = BuildGuide(pack)
            if guide then
                local ok = ns:RegisterGuide(guide)
                if ok then
                    self.byID[pack.id] = pack
                    self.byGuideID[guide.id] = pack
                end
            end
        end
    end
end

function ns.GuidePacks:Get(packID)
    return self.byID[packID]
end

function ns.GuidePacks:GetForGuide(guideID)
    return self.byGuideID[guideID]
end

function ns.GuidePacks:GetAvailable(category, includeOutOfRange)
    local playerFaction = type(UnitFactionGroup) == "function" and UnitFactionGroup("player") or nil
    local level = type(UnitLevel) == "function" and (tonumber(UnitLevel("player")) or 1) or 1
    local zone = string.lower(tostring(GetZoneText and GetZoneText() or ""))
    local active = {}
    for _, quest in ipairs(ns.QuestState:GetActiveQuests()) do active[quest.id] = true end

    local result = {}
    for _, pack in pairs(self.byID) do
        local factionOK = not playerFaction or pack.faction == "Any" or pack.faction == playerFaction
        local categoryOK = not category or category == "All" or pack.category == category
        local inRange = not pack.minLevel or not pack.maxLevel
            or (level >= pack.minLevel - 2 and level <= pack.maxLevel + 3)
        if factionOK and categoryOK and (inRange or includeOutOfRange) then
            local matches = 0
            for _, row in ipairs(pack.steps or {}) do
                if active[row.questID] then matches = matches + 1 end
            end
            local zoneMatch = zone ~= "" and string.find(string.lower(pack.title or ""), zone, 1, true) ~= nil
            result[#result + 1] = {
                pack = pack,
                activeMatches = matches,
                recommended = inRange,
                zoneMatch = zoneMatch,
            }
        end
    end
    table.sort(result, function(a, b)
        if a.zoneMatch ~= b.zoneMatch then return a.zoneMatch end
        if a.activeMatches ~= b.activeMatches then return a.activeMatches > b.activeMatches end
        if a.recommended ~= b.recommended then return a.recommended end
        if (a.pack.minLevel or 0) ~= (b.pack.minLevel or 0) then
            return (a.pack.minLevel or 0) < (b.pack.minLevel or 0)
        end
        return a.pack.title < b.pack.title
    end)
    return result
end

function ns.GuidePacks:GetStep(guideID, stepID)
    local pack = self:GetForGuide(guideID)
    local questID = tonumber(tostring(stepID or ""):match("^q(%d+)$"))
    if not pack or not questID then return nil, pack end
    for _, row in ipairs(pack.steps or {}) do
        if row.questID == questID then return row, pack end
    end
    return nil, pack
end
