local _, ns = ...

ns.GuideRuntime = {
    currentGuideID = nil,
    currentStepID = nil,
}

local function SaveProgress(self)
    local characterDB = ns:GetCharacterDB()
    characterDB.currentGuideID = self.currentGuideID
    characterDB.currentStepID = self.currentStepID
end

local function GetNextStep(guide, stepID)
    local index = guide.stepIndexes[stepID]
    if not index then
        return nil
    end
    local nextStep = guide.steps[index + 1]
    return nextStep and nextStep.id or nil
end

function ns.GuideRuntime:Initialize()
    local characterDB = ns:GetCharacterDB()
    local guideID = characterDB.currentGuideID
    local guide = guideID and ns.Guides[guideID]

    if guide then
        self.currentGuideID = guideID
        if characterDB.currentStepID == nil then
            self.currentStepID = nil
        elseif guide.stepIndexes[characterDB.currentStepID] then
            self.currentStepID = characterDB.currentStepID
        else
            self.currentStepID = guide.steps[1].id
        end
        SaveProgress(self)
        self:Evaluate()
    else
        self.currentGuideID = nil
        self.currentStepID = nil
        SaveProgress(self)
    end
end

function ns.GuideRuntime:SelectGuide(guideID)
    local guide = ns.Guides[guideID]
    if not guide then
        return false, "guide not found"
    end

    self.currentGuideID = guideID
    self.currentStepID = guide.steps[1].id
    SaveProgress(self)
    self:Evaluate()
    return true
end

function ns.GuideRuntime:Reset()
    local guide = self.currentGuideID and ns.Guides[self.currentGuideID]
    if not guide then
        return false, "no guide selected"
    end
    self.currentStepID = guide.steps[1].id
    SaveProgress(self)
    self:Evaluate()
    return true
end

function ns.GuideRuntime:GetCurrentGuide()
    return self.currentGuideID and ns.Guides[self.currentGuideID] or nil
end

function ns.GuideRuntime:GetCurrentStep()
    local guide = self:GetCurrentGuide()
    if not guide or not self.currentStepID then
        return nil
    end
    local index = guide.stepIndexes[self.currentStepID]
    return index and guide.steps[index] or nil
end

function ns.GuideRuntime:IsGoalComplete(goal)
    if goal.type == "manual" then
        return false
    elseif goal.type == "quest_active" then
        return ns.QuestState:IsQuestActive(goal.questID)
    elseif goal.type == "quest_ready" then
        return ns.QuestState:IsQuestReady(goal.questID)
    elseif goal.type == "quest_turned_in" then
        return ns.QuestState:IsQuestTurnedIn(goal.questID)
    elseif goal.type == "objective" then
        return ns.QuestState:IsObjectiveComplete(goal.questID, goal.index, goal.count)
    end
    return false
end

function ns.GuideRuntime:IsStepComplete(step)
    if not step or #step.goals == 0 then
        return false
    end

    local completed = 0
    for _, goal in ipairs(step.goals) do
        if self:IsGoalComplete(goal) then
            completed = completed + 1
        end
    end

    if step.goalMode == "any" then
        return completed > 0
    end
    return completed == #step.goals
end

function ns.GuideRuntime:Evaluate()
    local guide = self:GetCurrentGuide()
    if not guide or not self.currentStepID then
        return
    end

    local advances = 0
    while self.currentStepID and advances < #guide.steps do
        local step = self:GetCurrentStep()
        if not self:IsStepComplete(step) then
            break
        end

        self.currentStepID = GetNextStep(guide, self.currentStepID)
        advances = advances + 1
    end

    SaveProgress(self)
end

function ns.GuideRuntime:NextStep()
    local guide = self:GetCurrentGuide()
    if not guide or not self.currentStepID then
        return false, "no active step"
    end

    self.currentStepID = GetNextStep(guide, self.currentStepID)
    SaveProgress(self)
    return true
end

function ns.GuideRuntime:HandleEvent()
    self:Evaluate()
end

function ns.GuideRuntime:GetDisplayState()
    local guide = self:GetCurrentGuide()
    if not guide then
        return "No guide selected"
    end
    if not self.currentStepID then
        return guide.title .. " (complete)"
    end
    return guide.title .. " / " .. self.currentStepID
end

function ns.GuideRuntime:GetProgressText()
    local step = self:GetCurrentStep()
    if not step then
        return ""
    end
    if #step.goals == 0 then
        return "Manual step"
    end

    local complete = 0
    for _, goal in ipairs(step.goals) do
        if self:IsGoalComplete(goal) then
            complete = complete + 1
        end
    end
    return "Goals: " .. complete .. "/" .. #step.goals
end
