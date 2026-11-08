local _, ns = ...

ns.GuidePane = { frame = nil, quick = nil, itemsExpanded = false }

local function Button(parent, width, label, click)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetSize(width, 25)
    b:SetText(label)
    b:SetScript("OnClick", click)
    return b
end

local function Backdrop(frame, alpha)
    if type(frame.SetBackdrop) == "function" then
        frame:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 },
        })
        if frame.SetBackdropColor then frame:SetBackdropColor(0.025, 0.03, 0.04, alpha or 0.96) end
    else
        local bg = frame:CreateTexture(nil, "BACKGROUND")
        bg:SetTexture("Interface/Tooltips/UI-Tooltip-Background")
        bg:SetAllPoints(frame)
        bg:SetVertexColor(0.025, 0.03, 0.04, alpha or 0.96)
    end
end

local function CurrentStepQuest(guide, step)
    if not guide or not step then return nil end
    for _, goal in ipairs(step.goals or {}) do
        if tonumber(goal.questID) then return tonumber(goal.questID), tonumber(goal.index) end
    end
    local id = tostring(step.id or ""):match("^q(%d+)")
    return tonumber(id)
end

local function ObjectiveSummary(active)
    if not active then return "Accept the quest to begin tracking objectives." end
    if active.isReady then return "Objectives complete - return and turn in the quest." end
    local lines, completed = {}, 0
    for i, objective in ipairs(active.objectives or {}) do
        local done = objective.finished or (tonumber(objective.fulfilled) or 0) >= (tonumber(objective.required) or 1)
        if done then completed = completed + 1 end
        if #lines < 3 then
            local mark = done and "|cff70d090[OK]|r " or "|cffffd060[ ]|r "
            local count = tostring(objective.fulfilled or 0) .. "/" .. tostring(objective.required or 1)
            lines[#lines + 1] = mark .. count .. "  " .. tostring(objective.text or ("Objective " .. i))
        end
    end
    if #lines == 0 then return "Follow the current step, then use Next if it does not advance automatically." end
    if #active.objectives > #lines then lines[#lines + 1] = "... and " .. (#active.objectives - #lines) .. " more objectives" end
    return table.concat(lines, "\n")
end

function ns.GuidePane:Initialize()
    if self.frame then return end
    local frame = CreateFrame("Frame", "WildQuestGuidePane", UIParent)
    frame:SetSize(350, 260)
    frame:SetPoint("CENTER", UIParent, "CENTER", -600, 25)
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    Backdrop(frame, 0.97)

    local titleBar = CreateFrame("Button", nil, frame)
    titleBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 7, -5)
    titleBar:SetSize(290, 24)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function() frame:StartMoving() end)
    titleBar:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)
    self.title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.title:SetPoint("LEFT", titleBar, "LEFT", 5, 0)
    self.title:SetJustifyH("LEFT")
    self.title:SetText("|cff67d5ffWILDQUEST|r  GUIDE TRACKER")

    local close = Button(frame, 25, "X", function() self:Hide() end)
    close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -7, -5)

    self.routeText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    self.routeText:SetPoint("TOPLEFT", frame, "TOPLEFT", 13, -34)
    self.routeText:SetWidth(320)
    self.routeText:SetJustifyH("LEFT")

    self.stepText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.stepText:SetPoint("TOPLEFT", frame, "TOPLEFT", 13, -56)
    self.stepText:SetWidth(320)
    self.stepText:SetJustifyH("LEFT")

    self.objectiveText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    self.objectiveText:SetPoint("TOPLEFT", frame, "TOPLEFT", 13, -82)
    self.objectiveText:SetWidth(322)
    self.objectiveText:SetJustifyH("LEFT")
    self.objectiveText:SetJustifyV("TOP")

    self.stepsText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    self.stepsText:SetPoint("TOPLEFT", self.objectiveText, "BOTTOMLEFT", 0, -6)
    self.stepsText:SetWidth(322)
    self.stepsText:SetJustifyH("LEFT")
    self.stepsText:SetJustifyV("TOP")

    self.itemsText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    self.itemsText:SetPoint("TOPLEFT", self.objectiveText, "BOTTOMLEFT", 0, -6)
    self.itemsText:SetWidth(322)
    self.itemsText:SetJustifyH("LEFT")
    self.itemsText:Hide()

    self.statusText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    self.statusText:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 13, 42)
    self.statusText:SetWidth(320)
    self.statusText:SetJustifyH("LEFT")

    self.previous = Button(frame, 54, "< Prev", function()
        local ok, err = ns.GuideRuntime:PreviousStep()
        if not ok then ns:Print(err) end
        self:Refresh()
    end)
    self.previous:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 8)

    self.next = Button(frame, 54, "Skip >", function()
        local ok, err = ns.GuideRuntime:NextStep()
        if not ok then ns:Print(err) else ns:Print("step skipped by your override; quest completion was not recorded.") end
        self:Refresh()
    end)
    self.next:SetScript("OnEnter", function(button)
        GameTooltip:SetOwner(button, "ANCHOR_TOP")
        GameTooltip:SetText("Skip this guide step", 1, 0.82, 0)
        GameTooltip:AddLine("This is a guide-only override. It does not mark the quest complete.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    self.next:SetScript("OnLeave", function() GameTooltip:Hide() end)
    self.next:SetPoint("LEFT", self.previous, "RIGHT", 5, 0)

    self.here = Button(frame, 54, "Here", function()
        local ok, err = ns.GuideRuntime:JumpToActiveQuest()
        if not ok then ns:Print(err) end
        self:Refresh()
    end)
    self.here:SetPoint("LEFT", self.next, "RIGHT", 4, 0)

    self.browse = Button(frame, 68, "Guides", function()
        ns.Tracker:SetPage("guides")
        ns.Tracker.frame:Show()
        WildQuestDB.profile.trackerShown = true
    end)
    self.browse:SetPoint("LEFT", self.here, "RIGHT", 4, 0)

    self.options = Button(frame, 72, "Options", function()
        ns.Tracker:SetPage("overview")
        ns.Tracker.frame:Show()
        WildQuestDB.profile.trackerShown = true
    end)
    self.options:SetPoint("LEFT", self.browse, "RIGHT", 5, 0)

    local quick = CreateFrame("Frame", "WildQuestQuickButtonPane", UIParent)
    quick:SetSize(350, 31)
    quick:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 3)
    quick:SetFrameStrata("DIALOG")
    quick:SetClampedToScreen(true)
    quick:SetMovable(true)
    quick:EnableMouse(true)
    Backdrop(quick, 0.92)
    local grip = CreateFrame("Button", nil, quick)
    grip:SetSize(20, 25)
    grip:SetPoint("LEFT", quick, "LEFT", 4, 0)
    grip:RegisterForDrag("LeftButton")
    grip:SetScript("OnDragStart", function() quick:StartMoving() end)
    grip:SetScript("OnDragStop", function() quick:StopMovingOrSizing() end)
    local gripLabel = grip:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    gripLabel:SetPoint("CENTER")
    gripLabel:SetText("::")

    self.itemsButton = Button(quick, 74, "Items", function()
        self.itemsExpanded = not self.itemsExpanded
        self:Refresh()
    end)
    self.itemsButton:SetPoint("LEFT", grip, "RIGHT", 2, 0)
    self.trackButton = Button(quick, 80, "Target", function()
        ns.TrackerArrow:Toggle()
    end)
    self.trackButton:SetPoint("LEFT", self.itemsButton, "RIGHT", 5, 0)
    local quickOptions = Button(quick, 84, "Options", function()
        ns.Tracker:SetPage("overview"); ns.Tracker.frame:Show(); WildQuestDB.profile.trackerShown = true
    end)
    quickOptions:SetPoint("LEFT", self.trackButton, "RIGHT", 5, 0)
    self.quick = quick
    self.frame = frame
    if WildQuestDB.profile.guidePaneShown ~= false then frame:Show() else frame:Hide() end
    if WildQuestDB.profile.quickPaneShown ~= false then quick:Show() else quick:Hide() end
end

function ns.GuidePane:Hide()
    if self.frame then self.frame:Hide() end
    if self.quick then self.quick:Hide() end
    if WildQuestDB and WildQuestDB.profile then WildQuestDB.profile.guidePaneShown = false end
end

function ns.GuidePane:Show()
    if not self.frame then return end
    self:Refresh()
    self.frame:Show()
    if self.quick then self.quick:Show() end
    WildQuestDB.profile.guidePaneShown = true
    WildQuestDB.profile.quickPaneShown = true
end

function ns.GuidePane:Toggle()
    if self.frame and self.frame:IsShown() then self:Hide() else self:Show() end
end

function ns.GuidePane:Refresh()
    if not self.frame or not ns.initialized then return end
    local guide = ns.GuideRuntime:GetCurrentGuide()
    local step = ns.GuideRuntime:GetCurrentStep()
    if not guide or not step then
        self.routeText:SetText("No guide selected")
        self.stepText:SetText("Choose Guides to start a route.")
        self.objectiveText:SetText("The tracker stays compact while you play; open the Options panel for the full library and character tools.")
        self.statusText:SetText("")
        self.itemsText:Hide()
        self.stepsText:Hide()
        ns.TrackerArrow:SetTargets(nil)
        return
    end

    local stepNumber = guide.stepIndexes[step.id] or 1
    local confirmed, _, _, skipped = ns.GuideRuntime:GetRouteProgress()
    self.routeText:SetText(guide.title .. "  -  Step " .. stepNumber .. "/" .. #guide.steps
        .. "  |  " .. confirmed .. " confirmed, " .. skipped .. " skipped")
    local questID, objectiveIndex = CurrentStepQuest(guide, step)
    local active = questID and ns.QuestState:FindActiveQuest(questID)
    local questName = questID and (ns.Provider:GetQuestName(questID) or ("Quest " .. questID))
    self.stepText:SetText(questName or step.text or "Current step")
    self.objectiveText:SetText(ObjectiveSummary(active))

    local currentIndex = guide.stepIndexes[step.id] or 1
    local firstVisible = math.max(1, math.min(currentIndex - 1, #guide.steps - 3))
    local lastVisible = math.min(#guide.steps, firstVisible + 3)
    local routeLines = {}
    for index = firstVisible, lastVisible do
        local routeStep = guide.steps[index]
        local marker
        if index == currentIndex then
            marker = "|cff67d5ff[NOW]|r "
        elseif ns.GuideRuntime:IsStepSkipped(routeStep, guide.id) then
            marker = "|cffff9d4d[SKIP]|r "
        elseif ns.GuideRuntime:IsStepComplete(routeStep) then
            marker = "|cff70d090[OK]|r "
        else
            local stepQuestID = CurrentStepQuest(guide, routeStep)
            marker = stepQuestID and ns.QuestState:IsQuestActive(stepQuestID)
                and "|cffffd060[ACTIVE]|r " or "|cffaaaaaa[ ]|r "
        end
        routeLines[#routeLines + 1] = marker .. tostring(index) .. ". " .. tostring(routeStep.text or "Guide step")
    end
    self.stepsText:SetText(table.concat(routeLines, "\n"))

    if self.itemsExpanded and questID then
        local details = ns.Provider:GetQuestDetails(questID)
        local itemNames = {}
        for _, rawItemID in ipairs(details and details.requiredSourceItems or {}) do
            local itemID = type(rawItemID) == "table" and rawItemID[1] or rawItemID
            local item = ns.BundledDatabase.entities.Item[tonumber(itemID)]
            itemNames[#itemNames + 1] = item and item.name or ("Item " .. tostring(itemID))
        end
        if #itemNames > 0 then self.itemsText:SetText("Quest items: " .. table.concat(itemNames, ", "))
        else self.itemsText:SetText("No bundled quest-start item for this step.") end
        self.itemsText:Show()
    else
        self.itemsText:Hide()
    end
    if self.itemsExpanded and questID then self.stepsText:Hide() else self.stepsText:Show() end

    local targets = questID and ns.Navigation:TargetsForQuest(questID, active, objectiveIndex) or {}
    ns.TrackerArrow:SetTargets(targets)
    if active and active.isReady then
        self.statusText:SetText("|cff70d090Quest ready - follow the arrow to turn it in.|r")
    elseif active then
        self.statusText:SetText("|cffffd060" .. ns.GuideRuntime:GetProgressText() .. "|r")
    else
        self.statusText:SetText("Accept the quest, or Skip to override guide progress. Skips do not confirm quest history.")
    end
end
