local addonName, ns = ...

ns.name = addonName
ns.version = "0.1.0-alpha.1"
ns.initialized = false

function ns:Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff67d5ffWildQuest|r: " .. tostring(message))
end

function ns:Initialize()
    if self.initialized then
        return
    end

    self.initialized = true
    WildQuestDB = type(WildQuestDB) == "table" and WildQuestDB or {}
    WildQuestDB.profile = type(WildQuestDB.profile) == "table" and WildQuestDB.profile or {}
    WildQuestDB.profile.trackerShown = WildQuestDB.profile.trackerShown ~= false

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
            self:Initialize()
            self.EventFrame:UnregisterEvent("ADDON_LOADED")
        end
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

SLASH_WILDQUEST1 = "/wildquest"
SLASH_WILDQUEST2 = "/wq"
SlashCmdList.WILDQUEST = function(message)
    local command = string.lower((message or ""):match("^%s*(.-)%s*$"))

    if command == "status" then
        if not ns.initialized then
            ns:Print("still initializing.")
            return
        end
        ns:Print(ns.QuestState:GetActiveCount() .. " active quests; QuestieDB " .. ns.Provider:GetStatus() .. ".")
        return
    end

    if not ns.initialized then
        ns:Print("still initializing.")
        return
    end

    ns.Tracker:Toggle()
end
