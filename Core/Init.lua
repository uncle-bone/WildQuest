local addonName, ns = ...

ns.name = addonName
ns.version = "0.1.0-alpha.15"
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
    if WildQuestDB.profile.guideLayoutVersion ~= 1 then
        WildQuestDB.profile.trackerShown = false
        WildQuestDB.profile.guidePaneShown = true
        WildQuestDB.profile.quickPaneShown = true
        WildQuestDB.profile.guideLayoutVersion = 1
    end
    if WildQuestDB.profile.trackerShown == nil then WildQuestDB.profile.trackerShown = false end
    if WildQuestDB.profile.guidePaneShown == nil then WildQuestDB.profile.guidePaneShown = true end
    if WildQuestDB.profile.minimapShown == nil then WildQuestDB.profile.minimapShown = true end

    self.Provider:Initialize()
    self.QuestState:Initialize()
    self.GuidePacks:Initialize()
    self.XPObserver:Initialize()
    self.Gold:Initialize()
    self.Auction:Initialize()
    self.GuideRuntime:Initialize()
    self.Tracker:Initialize()
    self.TrackerArrow:Initialize()
    self.GuidePane:Initialize()
    self.MinimapButton:Initialize()
    self.initialized = true
    self.Tracker:Refresh()
    self.GuidePane:Refresh()

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

    if event == "PLAYER_ENTERING_WORLD" then self.Provider:Initialize() end
    self.XPObserver:HandleEvent(event, ...)
    self.Gold:HandleEvent(event, ...)
    self.Auction:HandleEvent(event, ...)
    self.QuestState:HandleEvent(event, ...)
    self.GuideRuntime:HandleEvent(event, ...)
    self.Tracker:Refresh()
    self.GuidePane:Refresh()
end

local eventFrame = CreateFrame("Frame")
ns.EventFrame = eventFrame
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(_, event, ...)
    ns:HandleEvent(event, ...)
end)

local function PrintGuides()
    local counts = {}
    for _, pack in pairs(ns.GuidePacks.byID) do counts[pack.category] = (counts[pack.category] or 0) + 1 end
    local labels = {}
    for category, count in pairs(counts) do labels[#labels + 1] = category .. " " .. count end
    table.sort(labels)
    ns:Print("open WildQuest and choose Guides. " .. #labels .. " categories: " .. table.concat(labels, ", "))
end

local function PrintHelp()
    ns:Print("/wq — show or hide tracker | /wq status | /wq quests | /wq guides")
    ns:Print("/wq quest <ID or exact title> — build a tracker guide from an active quest")
    ns:Print("/wq skip (or /wq next) — override this guide step without marking the quest complete")
    ns:Print("/wq step <number> — jump to a guide step | /wq here — find your active quest")
    ns:Print("/wq reset — reset selected guide | /wq select <guide ID>")
    ns:Print("/wq dungeon — show current location or dungeon | /wq xp — show XP observations")
    ns:Print("/wq route — build a catch-up route from your active quests using bundled route coverage")
    ns:Print("/wq minimap — show or hide the minimap button")
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
            .. ns.QuestState:GetActiveCount() .. " active quests; WildQuest data " .. ns.Provider:GetStatus() .. ".")
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
        if not ns.Tracker.frame then
            ns:Print("tracker window is not ready yet; use /reload if startup previously failed.")
            return
        end
        ns.Tracker:SetPage("guides")
        ns.Tracker.frame:Show()
        ns.GuidePane:Show()
        WildQuestDB.profile.trackerShown = true
    elseif command == "menu" then
        ns.Tracker:SetPage("overview")
        ns.Tracker.frame:Show()
        WildQuestDB.profile.trackerShown = true
    elseif command == "route" then
        local ok, err = ns.GuideRuntime:BuildQuestLogRoute()
        ns:Print(ok and "built route from your active quest log." or err)
        if ok then ns.GuidePane:Show() end
    elseif command == "minimap" then
        local shown = WildQuestDB.profile.minimapShown ~= false
        ns.MinimapButton:SetShown(not shown)
        ns:Print(not shown and "minimap button shown." or "minimap button hidden.")
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
        ns.GuidePane:Show()
    elseif command == "select" then
        local ok, err = ns.GuideRuntime:SelectGuide(argument)
        ns:Print(ok and ("selected guide " .. argument .. ".") or err)
        ns.Tracker:Refresh()
    elseif command == "next" or command == "skip" then
        local ok, err = ns.GuideRuntime:SkipCurrentStep()
        ns:Print(ok and "step skipped by your override; quest completion was not recorded." or err)
        ns.Tracker:Refresh()
        ns.GuidePane:Refresh()
    elseif command == "step" then
        local ok, err = ns.GuideRuntime:SelectStepNumber(argument)
        ns:Print(ok and ("jumped to guide step " .. argument .. ".") or err)
        ns.Tracker:Refresh()
        ns.GuidePane:Refresh()
    elseif command == "here" then
        local ok, err = ns.GuideRuntime:JumpToActiveQuest()
        ns:Print(ok and "jumped to the next unfinished quest in this guide." or err)
        ns.Tracker:Refresh()
        ns.GuidePane:Refresh()
    elseif command == "reset" then
        local ok, err = ns.GuideRuntime:Reset()
        ns:Print(ok and "guide progress reset." or err)
        ns.Tracker:Refresh()
    else
        ns.GuidePane:Toggle()
    end
end




