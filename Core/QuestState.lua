local _, ns = ...

ns.QuestState = {
    activeQuests = {},
    lastUpdatedAt = 0,
}

local function AddQuest(target, questID, title)
    if type(questID) ~= "number" or questID <= 0 then
        return
    end

    target[#target + 1] = {
        id = questID,
        title = type(title) == "string" and title or nil,
    }
end

function ns.QuestState:ReadQuestLog()
    local quests = {}

    if type(C_QuestLog) == "table" and type(C_QuestLog.GetNumQuestLogEntries) == "function"
        and type(C_QuestLog.GetInfo) == "function" then
        local ok, count = pcall(C_QuestLog.GetNumQuestLogEntries)
        if ok and type(count) == "number" then
            for index = 1, count do
                local infoOK, info = pcall(C_QuestLog.GetInfo, index)
                if infoOK and type(info) == "table" and not info.isHeader then
                    AddQuest(quests, info.questID, info.title)
                end
            end
        end
    elseif type(GetNumQuestLogEntries) == "function" and type(GetQuestLogTitle) == "function" then
        local count = GetNumQuestLogEntries()
        for index = 1, count do
            local title, _, _, isHeader, _, _, _, questID = GetQuestLogTitle(index)
            if not isHeader then
                AddQuest(quests, questID, title)
            end
        end
    end

    self.activeQuests = quests
    self.lastUpdatedAt = GetTime and GetTime() or 0
end

function ns.QuestState:Initialize()
    self:ReadQuestLog()

    local events = {
        "PLAYER_ENTERING_WORLD",
        "QUEST_LOG_UPDATE",
        "QUEST_ACCEPTED",
        "QUEST_REMOVED",
        "QUEST_TURNED_IN",
        "UNIT_QUEST_LOG_CHANGED",
    }

    for _, event in ipairs(events) do
        ns.EventFrame:RegisterEvent(event)
    end
end

function ns.QuestState:HandleEvent(event)
    if event == "PLAYER_ENTERING_WORLD"
        or event == "QUEST_LOG_UPDATE"
        or event == "QUEST_ACCEPTED"
        or event == "QUEST_REMOVED"
        or event == "QUEST_TURNED_IN"
        or event == "UNIT_QUEST_LOG_CHANGED" then
        self:ReadQuestLog()
    end
end

function ns.QuestState:GetActiveCount()
    return #self.activeQuests
end

function ns.QuestState:GetActiveQuests()
    return self.activeQuests
end
