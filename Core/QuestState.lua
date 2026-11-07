local _, ns = ...

ns.QuestState = {
    activeQuests = {},
    lastUpdatedAt = 0,
    characterDB = nil,
}

local function SafeCall(fn, ...)
    if type(fn) ~= "function" then
        return nil
    end
    local ok, a, b, c = pcall(fn, ...)
    if ok then
        return a, b, c
    end
    return nil
end

local function AddQuest(target, questID, title, isReady, objectives)
    if type(questID) ~= "number" or questID <= 0 then
        return
    end

    target[#target + 1] = {
        id = questID,
        title = type(title) == "string" and title or nil,
        isReady = isReady == true or isReady == 1,
        objectives = objectives or {},
    }
end

local function ReadModernObjectives(questID)
    local source = SafeCall(C_QuestLog and C_QuestLog.GetQuestObjectives, questID)
    local objectives = {}
    if type(source) ~= "table" then
        return objectives
    end

    for index, objective in ipairs(source) do
        if type(objective) == "table" then
            objectives[index] = {
                text = objective.text,
                fulfilled = tonumber(objective.numFulfilled) or 0,
                required = tonumber(objective.numRequired) or 1,
                finished = objective.finished == true or objective.finished == 1,
            }
        end
    end
    return objectives
end

local function ReadLegacyObjectives(questLogIndex)
    local objectives = {}
    if type(GetNumQuestLeaderBoards) ~= "function" or type(GetQuestLogLeaderBoard) ~= "function" then
        return objectives
    end

    local count = GetNumQuestLeaderBoards(questLogIndex) or 0
    for index = 1, count do
        local text, _, finished = GetQuestLogLeaderBoard(index, questLogIndex)
        objectives[index] = {
            text = text,
            fulfilled = (finished == true or finished == 1) and 1 or 0,
            required = 1,
            finished = finished == true or finished == 1,
        }
    end
    return objectives
end

function ns.QuestState:ReadQuestLog()
    local quests = {}

    if type(C_QuestLog) == "table"
        and type(C_QuestLog.GetNumQuestLogEntries) == "function"
        and type(C_QuestLog.GetInfo) == "function" then
        local count = SafeCall(C_QuestLog.GetNumQuestLogEntries) or 0
        for index = 1, count do
            local info = SafeCall(C_QuestLog.GetInfo, index)
            if type(info) == "table" and not info.isHeader and type(info.questID) == "number" then
                local ready = SafeCall(C_QuestLog.IsComplete, info.questID)
                AddQuest(quests, info.questID, info.title, ready, ReadModernObjectives(info.questID))
            end
        end
    elseif type(GetNumQuestLogEntries) == "function" and type(GetQuestLogTitle) == "function" then
        local count = GetNumQuestLogEntries() or 0
        for index = 1, count do
            local title, _, _, isHeader, _, isComplete, _, questID = GetQuestLogTitle(index)
            if not isHeader then
                AddQuest(quests, questID, title, isComplete, ReadLegacyObjectives(index))
            end
        end
    end

    self.activeQuests = quests
    self.lastUpdatedAt = GetTime and GetTime() or 0
end

function ns.QuestState:Initialize()
    self.characterDB = ns:GetCharacterDB()
    self.characterDB.completedQuestIDs = type(self.characterDB.completedQuestIDs) == "table"
        and self.characterDB.completedQuestIDs or {}

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

function ns.QuestState:HandleEvent(event, ...)
    if event == "QUEST_TURNED_IN" then
        local questID = ...
        if type(questID) == "number" then
            self.characterDB.completedQuestIDs[questID] = true
        end
    end

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

function ns.QuestState:FindActiveQuest(questID)
    for _, quest in ipairs(self.activeQuests) do
        if quest.id == questID then
            return quest
        end
    end
    return nil
end

function ns.QuestState:IsQuestActive(questID)
    return self:FindActiveQuest(questID) ~= nil
end

function ns.QuestState:FindActiveQuestsByName(name)
    local matches = {}
    local target = string.lower(name or "")
    if target == "" then
        return matches
    end

    for _, quest in ipairs(self.activeQuests) do
        local title = quest.title or ns.Provider:GetQuestName(quest.id)
        if type(title) == "string" and string.lower(title) == target then
            matches[#matches + 1] = quest
        end
    end
    return matches
end

function ns.QuestState:IsQuestReady(questID)
    local quest = self:FindActiveQuest(questID)
    if quest and quest.isReady then
        return true
    end
    return false
end

function ns.QuestState:IsQuestTurnedIn(questID)
    if self.characterDB and self.characterDB.completedQuestIDs[questID] then
        return true
    end

    if type(C_QuestLog) == "table" and type(C_QuestLog.IsQuestFlaggedCompleted) == "function" then
        local completed = SafeCall(C_QuestLog.IsQuestFlaggedCompleted, questID)
        return completed == true or completed == 1
    end
    return false
end

function ns.QuestState:IsObjectiveComplete(questID, objectiveIndex, requiredCount)
    local quest = self:FindActiveQuest(questID)
    local objective = quest and quest.objectives[objectiveIndex]
    if not objective then
        return false
    end
    return objective.finished or objective.fulfilled >= requiredCount
end
