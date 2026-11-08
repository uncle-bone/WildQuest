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

local function GetOverrides(self, guideID)
    local characterDB = ns:GetCharacterDB()
    characterDB.stepOverrides = type(characterDB.stepOverrides) == "table" and characterDB.stepOverrides or {}
    characterDB.stepOverrides[guideID] = type(characterDB.stepOverrides[guideID]) == "table"
        and characterDB.stepOverrides[guideID] or {}
    return characterDB.stepOverrides[guideID]
end

local function GetNextStep(guide, stepID)
    local index = guide.stepIndexes[stepID]
    if not index then
        return nil
    end
    local nextStep = guide.steps[index + 1]
    return nextStep and nextStep.id or nil
end

local function StepQuestID(step)
    for _, goal in ipairs(step and step.goals or {}) do
        local questID = tonumber(goal.questID)
        if questID then return questID end
    end
    local fromID = tostring(step and step.id or ""):match("^q(%d+)")
    return tonumber(fromID)
end

function ns.GuideRuntime:FindActiveQuestStep(guide)
    if not guide then return nil end
    for _, step in ipairs(guide.steps) do
        local questID = StepQuestID(step)
        if questID and ns.QuestState:IsQuestActive(questID) and not self:IsStepComplete(step) then
            return step
        end
    end
end

function ns.GuideRuntime:FindAdaptiveStep(guide)
    if not guide then return nil end
    local activeStep = self:FindActiveQuestStep(guide)
    if activeStep then return activeStep end
    local overrides = GetOverrides(self, guide.id)
    for _, step in ipairs(guide.steps or {}) do
        if not self:IsStepComplete(step) then
            local questID = StepQuestID(step)
            if questID then
                local levelStatus = ns.Provider:GetQuestLevelStatus(questID)
                if levelStatus == "gray" then
                    local prerequisitesConfirmed = ns.Provider:AreQuestPrerequisitesConfirmed(questID)
                    if prerequisitesConfirmed then
                        overrides[step.id] = "auto:gray-level"
                    else
                        return step
                    end
                else
                    return step
                end
            else
                return step
            end
        end
    end
    return nil
end
function ns.GuideRuntime:GetRouteProgress()
    local guide = self:GetCurrentGuide()
    if not guide then return 0, 0, 0, 0 end
    local complete, skipped = 0, 0
    for _, step in ipairs(guide.steps) do
        if self:IsStepSkipped(step, guide.id) then
            skipped = skipped + 1
        elseif self:IsStepComplete(step) then
            complete = complete + 1
        end
    end
    local current = self.currentStepID and guide.stepIndexes[self.currentStepID] or #guide.steps
    return complete, #guide.steps, current, skipped
end

function ns.GuideRuntime:Initialize()
    local characterDB = ns:GetCharacterDB()
    if type(characterDB.generatedGuide) == "table" then
        local restored = ns:RegisterGuide(characterDB.generatedGuide)
        if not restored then
            characterDB.generatedGuide = nil
        end
    end

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
    if not guide then return false, "guide not found" end

    self.currentGuideID = guideID

    -- Resume from the earliest uncompleted step for an active quest in this
    -- guide. This uses the live quest log, so starting a guide mid-chain does
    -- not force the player to replay its opening steps.
    local adaptiveStep = self:FindAdaptiveStep(guide)
    self.currentStepID = adaptiveStep and adaptiveStep.id or nil
    SaveProgress(self)
    self:Evaluate()
    return true
end

function ns.GuideRuntime:Reset()
    local guide = self.currentGuideID and ns.Guides[self.currentGuideID]
    if not guide then
        return false, "no guide selected"
    end
    local overrides = GetOverrides(self, guide.id)
    for stepID in pairs(overrides) do overrides[stepID] = nil end
    self.currentStepID = guide.steps[1].id
    SaveProgress(self)
    self:Evaluate()
    return true
end

function ns.GuideRuntime:TrackQuest(questID)
    local quest = ns.QuestState:FindActiveQuest(questID)
    if not quest then
        return false, "quest is not in your active quest log"
    end

    local guideID = "quest-" .. tostring(questID)
    if not ns.Guides[guideID] then
        local steps = {}
        for index, objective in ipairs(quest.objectives or {}) do
            local count = tonumber(objective.required) or 1
            if count < 1 then
                count = 1
            end
            steps[#steps + 1] = {
                id = "objective-" .. tostring(index),
                text = type(objective.text) == "string" and objective.text ~= ""
                    and objective.text or ("Complete objective " .. tostring(index) .. "."),
                goals = {
                    { type = "objective", questID = questID, index = index, count = count },
                },
            }
        end

        if #steps == 0 then
            steps[#steps + 1] = {
                id = "quest-ready",
                text = "Complete the quest objectives.",
                goals = {
                    { type = "quest_ready", questID = questID },
                },
            }
        end

        steps[#steps + 1] = {
            id = "turn-in",
            text = "Return to the quest giver and turn in the quest.",
            goals = {
                { type = "quest_turned_in", questID = questID },
            },
        }

        local title = quest.title or ns.Provider:GetQuestName(questID) or ("Quest " .. tostring(questID))
        local definition = {
            id = guideID,
            title = title,
            version = "generated-1",
            flavor = "forever",
            steps = steps,
        }
        local registered, err = ns:RegisterGuide(definition)
        if not registered then
            return false, err
        end
        ns:GetCharacterDB().generatedGuide = definition
    end

    if self.currentGuideID == guideID then return true end
    return self:SelectGuide(guideID)
end

function ns.GuideRuntime:BuildQuestLogRoute()
    local active = ns.QuestState:GetActiveQuests()
    if #active == 0 then return false, "accept quests first; no active quests are available to route." end

    local playerLevel = tonumber(UnitLevel and UnitLevel("player")) or 1
    local ordered = {}
    for _, quest in ipairs(active) do
        local details = ns.Provider:GetQuestDetails(quest.id)
        local questLevel = tonumber(details and details.questLevel) or playerLevel
        ordered[#ordered + 1] = {
            quest = quest,
            level = questLevel,
            agreement = ns.RouteSourceCoverage and ns.RouteSourceCoverage:GetAgreement(quest.id) or 0,
            ready = quest.isReady and 1 or 0,
        }
    end
    table.sort(ordered, function(a, b)
        if a.ready ~= b.ready then return a.ready > b.ready end
        if a.agreement ~= b.agreement then return a.agreement > b.agreement end
        local aDistance, bDistance = math.abs(a.level - playerLevel), math.abs(b.level - playerLevel)
        if aDistance ~= bDistance then return aDistance < bDistance end
        return a.quest.id < b.quest.id
    end)

    local steps = {}
    for _, entry in ipairs(ordered) do
        local quest = entry.quest
        local title = quest.title or ns.Provider:GetQuestName(quest.id) or ("Quest " .. quest.id)
        local sourceLabel = entry.agreement == 2 and "RXP + Zygor coverage"
            or (entry.agreement == 1 and "single guide-source coverage" or "QuestieDB quest-log data")
        local hasObjective = false
        for index, objective in ipairs(quest.objectives or {}) do
            hasObjective = true
            steps[#steps + 1] = {
                id = "q" .. quest.id .. "-o" .. index,
                text = title .. ": " .. (objective.text or ("complete objective " .. index))
                    .. " (" .. sourceLabel .. ")",
                goals = {
                    { type = "objective", questID = quest.id, index = index,
                        count = tonumber(objective.required) or 1 },
                },
            }
        end
        if not hasObjective then
            steps[#steps + 1] = {
                id = "q" .. quest.id .. "-ready",
                text = title .. ": complete the quest objectives (" .. sourceLabel .. ").",
                goals = { { type = "quest_ready", questID = quest.id } },
            }
        end
        steps[#steps + 1] = {
            id = "q" .. quest.id .. "-turnin",
            text = "Turn in " .. title .. " (" .. sourceLabel .. ").",
            goals = { { type = "quest_turned_in", questID = quest.id } },
        }
    end

    local routeID = "active-quest-route"
    local definition = {
        id = routeID,
        title = "Active Quest Route",
        version = "generated-1",
        flavor = "forever",
        steps = steps,
    }
    ns.Guides[routeID] = nil
    local registered, err = ns:RegisterGuide(definition)
    if not registered then return false, err end
    ns:GetCharacterDB().generatedGuide = definition
    return self:SelectGuide(routeID)
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
    if self:IsStepSkipped(step) then return true end
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

function ns.GuideRuntime:IsStepSkipped(step, guideID)
    local guide = guideID and ns.Guides[guideID] or self:GetCurrentGuide()
    if not guide or not step then return false end
    local override = GetOverrides(self, guide.id)[step.id]
    return override == true or type(override) == "string"
end

-- Explicit catch-up override: advances guide presentation only and does not
-- record a quest as completed in character history.
function ns.GuideRuntime:SkipCurrentStep()
    local guide = self:GetCurrentGuide()
    local step = self:GetCurrentStep()
    if not guide or not step then return false, "no active guide step" end
    GetOverrides(self, guide.id)[step.id] = true
    self.currentStepID = GetNextStep(guide, step.id)
    SaveProgress(self)
    self:Evaluate()
    return true
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

function ns.GuideRuntime:JumpToActiveQuest()
    local guide = self:GetCurrentGuide()
    if not guide then return false, "select a guide first" end
    local step = self:FindActiveQuestStep(guide)
    if not step then
        return false, "none of this guide's unfinished quests are in your quest log"
    end
    self.currentStepID = step.id
    self:Evaluate()
    return true
end

function ns.GuideRuntime:SelectStepNumber(number)
    local guide = self:GetCurrentGuide()
    number = tonumber(number)
    if not guide then return false, "select a guide first" end
    if not number or number < 1 or number > #guide.steps or number ~= math.floor(number) then
        return false, "step number must be between 1 and " .. #guide.steps
    end
    self.currentStepID = guide.steps[number].id
    SaveProgress(self)
    return true
end

function ns.GuideRuntime:NextStep()
    return self:SkipCurrentStep()
end

function ns.GuideRuntime:PreviousStep()
    local guide = self:GetCurrentGuide()
    if not guide or not self.currentStepID then return false, "no active step" end
    local index = guide.stepIndexes[self.currentStepID]
    if not index or index <= 1 then return false, "already at the first step" end
    self.currentStepID = guide.steps[index - 1].id
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
    if self:IsStepSkipped(step) then
        local override = GetOverrides(self, self.currentGuideID)[step.id]
        return override == "auto:gray-level"
            and "Skipped automatically: below-level quest; known prerequisites are confirmed."
            or "Skipped by player override; quest history remains unconfirmed."
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

