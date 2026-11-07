local addonName, ns = ...

ns.name = addonName
ns.version = "0.1.0-alpha.2"
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

function ns:Initialize()
    if self.initialized then
        return
    end

    WildQuestDB = type(WildQuestDB) == "table" and WildQuestDB or {}
    WildQuestDB.profile = type(WildQuestDB.profile) == "table" and WildQuestDB.profile or {}
    WildQuestDB.profile.trackerShown = WildQuestDB.profile.trackerShown ~= false

    self.initialized = true
    self.Provider:Initialize()
    self.QuestState:Initialize()
    self.GuideRuntime:Initialize()
    self.Tracker:Initialize()
    self.Tracker:Refresh()

    self:Print("loaded. Use /wq to toggle the tracker.")
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

    if not self.initialized then
        return
    end

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
    for id in pairs(ns.Guides) do
        ids[#ids + 1] = id
    end
    table.sort(ids)

    if #ids == 0 then
        ns:Print("no guide data is registered yet.")
        return
    end

    ns:Print("available guides: " .. table.concat(ids, ", "))
end

SLASH_WILDQUEST1 = "/wildquest"
SLASH_WILDQUEST2 = "/wq"
SlashCmdList.WILDQUEST = function(message)
    local command, argument = (message or ""):match("^%s*(%S*)%s*(.-)%s*$")
    command = string.lower(command or "")

    if command == "status" then
        if not ns.initialized then
            ns:Print("still initializing.")
            return
        end
        ns:Print(ns.QuestState:GetActiveCount() .. " active quests; QuestieDB " .. ns.Provider:GetStatus() .. ".")
    elseif command == "guides" then
        PrintGuides()
    elseif command == "select" then
        if not ns.initialized then
            ns:Print("still initializing.")
            return
        end
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
        if not ns.initialized then
            ns:Print("still initializing.")
            return
        end
        ns.Tracker:Toggle()
    end
end
