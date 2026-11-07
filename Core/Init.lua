local addonName, ns = ...

ns.name = addonName
ns.version = "0.1.0-alpha.3"
ns.initialized = false

function ns:Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff67d5ffWildQuest|r: " .. tostring(message))
end

function ns:GetCharacterDB()
    WildQuestDB.characters = type(WildQuestDB.characters) == "table" and WildQuestDB.characters or {}

    local playerName = UnitName and UnitName("player") or "Unknown"
    local realmName = GetRealmName and GetRealmName() or "UnknownRealm"
    local key = tostring(realmName) .. "-" .. tostring(playerName)
    WildQuestDB.characters[key] = type(WildQuestDB.characters[key]) == "table" and WildQuestDB.characters[key] or {}
    return WildQuestDB.characters[key]
end

local function GetDungeonContext()
    if type(GetInstanceInfo) ~= "function" then
        return "Instance information unavailable"
    end
    local name, instanceType, difficulty = GetInstanceInfo()
    if instanceType == "party" then
        return "Dungeon: " .. tostring(name or "unknown") .. " (difficulty " .. tostring(difficulty or "?") .. ")"
    elseif instanceType == "raid" then
        return "Raid: " .. tostring(name or "unknown")
    end
    return "World: " .. tostring(GetZoneText and GetZoneText() or "unknown")
end

local function PrintQuestList()
    local quests = ns.QuestState:GetActiveQuests()
    if #quests == 0 then
        ns:Print("your quest log has no active quests.")
        return
    end
    for _, quest in ipairs(quests) do
        local title = quest.title or ns.Provider:GetQuestName(quest.id) or ("Quest " .. tostring(quest.id))
        local state = quest.isReady and "ready to turn in" or "in progress"
        ns:Print("[" .. tostring(quest.id) .. "] " .. title .. " — " .. state)
    end
end

function ns:Initialize()
    if self.initialized then return end

    WildQuestDB = type(WildQuestDB) == "table" and WildQuestDB or {}
    WildQuestDB.profile = type(WildQuestDB.profile) == "table" and WildQuestDB.profile or {}
    WildQuestDB.profile.trackerShown = WildQuestDB.profile.trackerShown ~= false

    self.initialized = true
    self.Provider:Initialize()
    self.QuestState:Initialize()
    self.XPObserver:Initialize()
    self.GuideRuntime:Initialize()
    self.Tracker:Initialize()
    self.Tracker:Refresh()

    self:Print("WildQuest " .. self.version .. " loaded. Use /wq help for commands.")
end

function ns:HandleEvent(event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...
        if loadedAddon == self.name then
            WildQuestDB = type(WildQuestDB) == "table" and WildQuestDB or {}
            self.EventFrame:RegisterEvent("PLAYER_LOGIN")
            self.EventFrame:UnregisterEvent("ADDON_LOADED")
        end
        return
    end

    if event == "PLAYER_LOGIN" then
        self:Initialize()
        self.EventFrame:UnregisterEvent("PLAYER_LOGIN")
        return
    end

    if not self.initialized then return end

    self.XPObserver:HandleEvent(event, ...)
    self.QuestState:HandleEvent(event, ...)
    self.GuideRuntime:HandleEvent(event, ...)
    self.Tracker:Refresh()
end

local eventFrame = CreateFrame("Frame")
ns.EventFrame = eventFrame
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(_, event, ...)
    ns:HandleEvent(event, ...)
end)

local function PrintGuides()
    local ids = {}
    for id in pairs(ns.Guides) do ids[#ids + 1] = id end
    table.sort(ids)
    if #ids == 0 then
        ns:Print("no authored route packs are included yet. Track a live quest with /wq quest <ID or exact title>.")
        return
    end
    ns:Print("available guides: " .. table.concat(ids, ", "))
end

local function PrintHelp()
    ns:Print("/wq — show or hide tracker | /wq status | /wq quests | /wq guides")
    ns:Print("/wq quest <ID or exact title> — build a tracker guide from an active quest")
    ns:Print("/wq next — manually advance | /wq reset — reset selected guide | /wq select <guide ID>")
    ns:Print("/wq dungeon — show current location or dungeon | /wq xp — show XP observations")
end

SLASH_WILDQUEST1 = "/wildquest"
SLASH_WILDQUEST2 = "/wq"
SlashCmdList.WILDQUEST = function(message)
    local command, argument = (message or ""):match("^%s*(%S*)%s*(.-)%s*$")
    command = string.lower(command or "")

    if command == "help" then
        PrintHelp()
    elseif not ns.initialized then
        ns:Print("still initializing.")
    elseif command == "status" then
        local xp = ns.XPObserver:GetSummary()
        ns:Print(tostring(UnitLevel and UnitLevel("player") or "?") .. " level; "
            .. ns.QuestState:GetActiveCount() .. " active quests; QuestieDB " .. ns.Provider:GetStatus() .. ".")
        ns:Print("XP this session: +" .. xp.sessionDelta .. " observed, source unknown.")
    elseif command == "quests" then
        PrintQuestList()
    elseif command == "dungeon" then
        ns:Print(GetDungeonContext())
    elseif command == "xp" then
        local xp = ns.XPObserver:GetSummary()
        ns:Print("Session XP-bar increase: +" .. xp.sessionDelta .. " (unattributed).")
        ns:Print("Combat XP chat: +" .. xp.combatTextXP .. " across " .. xp.combatTextEvents .. " messages.")
        ns:Print("Latest observation: " .. xp.lastObservation .. ". Gray status/no-XP decisions are not inferred.")
    elseif command == "guides" then
        PrintGuides()
    elseif command == "quest" then
        local questID = tonumber(argument)
        if not questID then
            local matches = ns.QuestState:FindActiveQuestsByName(argument)
            if #matches == 0 then
                ns:Print("quest not found. Use /wq quests to list active quest IDs and titles.")
                return
            elseif #matches > 1 then
                local ids = {}
                for _, quest in ipairs(matches) do ids[#ids + 1] = tostring(quest.id) end
                ns:Print("multiple quests match; use one of these IDs: " .. table.concat(ids, ", "))
                return
            end
            questID = matches[1].id
        end
        local ok, err = ns.GuideRuntime:TrackQuest(questID)
        ns:Print(ok and ("tracking quest " .. tostring(questID) .. ".") or err)
        ns.Tracker:Refresh()
    elseif command == "select" then
        local ok, err = ns.GuideRuntime:SelectGuide(argument)
        ns:Print(ok and ("selected guide " .. argument .. ".") or err)
        ns.Tracker:Refresh()
    elseif command == "next" then
        local ok, err = ns.GuideRuntime:NextStep()
        ns:Print(ok and "moved to the next step." or err)
        ns.Tracker:Refresh()
    elseif command == "reset" then
        local ok, err = ns.GuideRuntime:Reset()
        ns:Print(ok and "guide progress reset." or err)
        ns.Tracker:Refresh()
    else
        ns.Tracker:Toggle()
    end
end
