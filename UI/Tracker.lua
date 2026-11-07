local _, ns = ...

ns.Tracker = { frame = nil, page = "quests", questPage = 1, rows = {} }
local ROWS_PER_PAGE = 8

local function CurrentLocation()
    if type(GetInstanceInfo) == "function" then
        local name, instanceType, difficulty = GetInstanceInfo()
        if instanceType == "party" then return "Dungeon: " .. tostring(name) .. " | " .. tostring(difficulty or "?") end
        if instanceType == "raid" then return "Raid: " .. tostring(name) end
    end
    return tostring(GetZoneText and GetZoneText() or "World")
end

local function MakeButton(parent, width, height, text, callback)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(width, height)
    local bg = button:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture("Interface/Tooltips/UI-Tooltip-Background")
    bg:SetAllPoints(button)
    bg:SetVertexColor(0.10, 0.15, 0.21, 0.96)
    local hi = button:CreateTexture(nil, "HIGHLIGHT")
    hi:SetTexture("Interface/Buttons/ButtonHilight-Square")
    hi:SetAllPoints(button)
    hi:SetBlendMode("ADD")
    local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", button, "LEFT", 8, 0)
    label:SetPoint("RIGHT", button, "RIGHT", -8, 0)
    label:SetJustifyH("LEFT")
    label:SetText(text or "")
    button.label = label
    button:SetScript("OnClick", callback)
    return button
end

local function AddLocationLines(lines, label, locations)
    if type(locations) ~= "table" or #locations == 0 then return end
    lines[#lines + 1] = label
    for _, row in ipairs(locations) do
        lines[#lines + 1] = row.kind .. " " .. tostring(row.id) .. " — area "
            .. tostring(row.area) .. " (" .. string.format("%.1f", tonumber(row.x) or 0)
            .. ", " .. string.format("%.1f", tonumber(row.y) or 0) .. ")"
    end
end

function ns.Tracker:Initialize()
    if self.frame then return end
    local frame = CreateFrame("Frame", "WildQuestTrackerFrame", UIParent)
    frame:SetSize(470, 500)
    frame:SetPoint("CENTER", UIParent, "CENTER", 300, 0)
    frame:SetFrameStrata("MEDIUM")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    if type(frame.SetBackdrop) == "function" then
        frame:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border", tile = true, tileSize = 16,
            edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 } })
        if type(frame.SetBackdropColor) == "function" then frame:SetBackdropColor(0.025, 0.045, 0.07, 0.97) end
    else
        local bg = frame:CreateTexture(nil, "BACKGROUND")
        bg:SetTexture("Interface/Tooltips/UI-Tooltip-Background")
        bg:SetAllPoints(frame)
        bg:SetVertexColor(0.025, 0.045, 0.07, 0.97)
    end

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -13)
    title:SetText("|cff67d5ffWildQuest|r  |cffaaaaaaalpha.5|r")
    self.locationText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    self.locationText:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)

    local close = MakeButton(frame, 30, 24, "X", function()
        frame:Hide()
        WildQuestDB.profile.trackerShown = false
    end)
    close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -12, -10)

    self.questTab = MakeButton(frame, 205, 30, "My Quests", function() self:SetPage("quests") end)
    self.questTab:SetPoint("TOPLEFT", frame, "TOPLEFT", 14, -62)
    self.guideTab = MakeButton(frame, 205, 30, "Guide", function() self:SetPage("guide") end)
    self.guideTab:SetPoint("LEFT", self.questTab, "RIGHT", 8, 0)

    self.pageTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.pageTitle:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -104)
    self.pageText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    self.pageText:SetPoint("TOPLEFT", self.pageTitle, "BOTTOMLEFT", 0, -9)
    self.pageText:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -18, 66)
    self.pageText:SetJustifyH("LEFT")
    self.pageText:SetJustifyV("TOP")

    for i = 1, ROWS_PER_PAGE do
        local row = MakeButton(frame, 434, 34, "", function()
            local quest = self.rowQuests and self.rowQuests[i]
            if quest then
                local ok, err = ns.GuideRuntime:TrackQuest(quest.id)
                if ok then self:SetPage("guide") else ns:Print(err) end
            end
        end)
        row:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -158 - ((i - 1) * 36))
        self.rows[i] = row
    end

    self.prevPage = MakeButton(frame, 120, 28, "Previous quests", function()
        self.questPage = math.max(1, self.questPage - 1)
        self:Refresh()
    end)
    self.prevPage:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 18, 18)
    self.nextPage = MakeButton(frame, 120, 28, "More quests", function()
        self.questPage = self.questPage + 1
        self:Refresh()
    end)
    self.nextPage:SetPoint("LEFT", self.prevPage, "RIGHT", 8, 0)

    self.prevStep = MakeButton(frame, 112, 30, "Previous step", function()
        local ok, err = ns.GuideRuntime:PreviousStep()
        if not ok then ns:Print(err) end
        self:Refresh()
    end)
    self.prevStep:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 18, 18)
    self.nextStep = MakeButton(frame, 112, 30, "Next step", function()
        local ok, err = ns.GuideRuntime:NextStep()
        if not ok then ns:Print(err) end
        self:Refresh()
    end)
    self.nextStep:SetPoint("LEFT", self.prevStep, "RIGHT", 8, 0)
    self.backButton = MakeButton(frame, 112, 30, "Quest list", function() self:SetPage("quests") end)
    self.backButton:SetPoint("LEFT", self.nextStep, "RIGHT", 8, 0)

    self.frame = frame
    if WildQuestDB.profile.trackerShown then frame:Show() else frame:Hide() end
end

function ns.Tracker:SetPage(page)
    self.page = page == "guide" and "guide" or "quests"
    self:Refresh()
end

function ns.Tracker:RefreshQuestPage()
    local quests = ns.QuestState:GetActiveQuests()
    local pages = math.max(1, math.ceil(#quests / ROWS_PER_PAGE))
    self.questPage = math.min(self.questPage, pages)
    self.rowQuests = {}
    local first = (self.questPage - 1) * ROWS_PER_PAGE + 1
    for i = 1, ROWS_PER_PAGE do
        local quest, row = quests[first + i - 1], self.rows[i]
        if quest then
            self.rowQuests[i] = quest
            local name = quest.title or ns.Provider:GetQuestName(quest.id) or ("Quest " .. quest.id)
            local detail = ns.Provider:GetQuestDetails(quest.id)
            local level = detail and tonumber(detail.questLevel)
            local suffix = quest.isReady and "  [READY]" or ""
            if level and level > 0 then suffix = suffix .. "  (level " .. level .. ")" end
            if ns.GuideRuntime.currentGuideID == "quest-" .. quest.id then name = "|cff67d5ff» |r" .. name end
            row.label:SetText(name .. suffix)
            row:Show()
        else
            row:Hide()
        end
    end
    self.pageText:ClearAllPoints()
    self.pageText:SetPoint("TOPLEFT", self.pageTitle, "BOTTOMLEFT", 0, -5)
    self.pageText:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -18, 330)
    self.pageTitle:SetText("Select an active quest to open its guide")
    self.pageText:SetText(#quests == 0
        and "No active quests found. Accept a quest, then use /wq to refresh this list."
        or "Select any quest below. WildQuest turns its in-game objectives into tracked steps and preserves your selected quest progress.")
    if self.questPage > 1 then self.prevPage:Show() else self.prevPage:Hide() end
    if self.questPage < pages then self.nextPage:Show() else self.nextPage:Hide() end
    self.prevStep:Hide()
    self.nextStep:Hide()
    self.backButton:Hide()
end

function ns.Tracker:RefreshGuidePage()
    local guide = ns.GuideRuntime:GetCurrentGuide()
    self.pageText:ClearAllPoints()
    self.pageText:SetPoint("TOPLEFT", self.pageTitle, "BOTTOMLEFT", 0, -9)
    self.pageText:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -18, 66)
    self.pageTitle:SetText(guide and guide.title or "No quest guide selected")
    self.prevPage:Hide()
    self.nextPage:Hide()
    self.prevStep:Show()
    self.nextStep:Show()
    self.backButton:Show()
    if not guide then
        self.pageText:SetText("Open My Quests and click an active quest. Its quest-log objectives will become guide steps.")
        return
    end

    local questID = tonumber(guide.id:match("^quest%-(%d+)$"))
    local quest = questID and ns.QuestState:FindActiveQuest(questID)
    local details = questID and ns.Provider:GetQuestDetails(questID)
    local lines = { "Quest ID: " .. tostring(questID or "?") }
    if details then
        local qLevel, minLevel = tonumber(details.questLevel), tonumber(details.requiredLevel)
        if qLevel and qLevel > 0 then lines[#lines + 1] = "Quest level: " .. qLevel end
        if minLevel and minLevel > 0 then lines[#lines + 1] = "Minimum level: " .. minLevel end
        if tonumber(details.zoneOrSort) then lines[#lines + 1] = "QuestieDB zone/sort: " .. details.zoneOrSort end
    end
    lines[#lines + 1] = quest and (quest.isReady and "Status: ready to turn in" or "Status: in progress")
        or "Status: no longer active in quest log"

    local step = ns.GuideRuntime:GetCurrentStep()
    if step then
        local currentGuide = ns.GuideRuntime:GetCurrentGuide()
        lines[#lines + 1] = ""
        lines[#lines + 1] = "STEP " .. tostring(currentGuide.stepIndexes[step.id]) .. " OF " .. tostring(#currentGuide.steps)
        lines[#lines + 1] = step.text
        lines[#lines + 1] = ns.GuideRuntime:GetProgressText()
    else
        lines[#lines + 1] = ""
        lines[#lines + 1] = "Quest guide complete."
    end

    lines[#lines + 1] = ""
    lines[#lines + 1] = "OBJECTIVES"
    for i, objective in ipairs(quest and quest.objectives or {}) do
        local status = objective.finished and "✓ " or ""
        lines[#lines + 1] = status .. tostring(objective.fulfilled or 0) .. "/" .. tostring(objective.required or 1)
            .. "  " .. tostring(objective.text or ("Objective " .. i))
    end

    if details then
        local prerequisites = details.preQuestSingle
        if type(prerequisites) == "table" and #prerequisites > 0 then
            lines[#lines + 1] = ""
            lines[#lines + 1] = "PREREQUISITES (QuestieDB)"
            for _, id in ipairs(prerequisites) do
                local complete = ns.QuestState:IsQuestTurnedIn(id)
                local name = ns.Provider:GetQuestName(id) or ("Quest " .. id)
                lines[#lines + 1] = (complete and "[done] " or "[not confirmed] ") .. name .. " (" .. id .. ")"
            end
        end
        local startLoc = ns.Provider:GetQuestGiverLocations(questID, false)
        local finishLoc = ns.Provider:GetQuestGiverLocations(questID, true)
        AddLocationLines(lines, "START LOCATIONS", startLoc)
        AddLocationLines(lines, "TURN-IN LOCATIONS", finishLoc)
        local groups = details.preQuestGroup
        if type(groups) == "table" and #groups > 0 then
            lines[#lines + 1] = "Other grouped requirements are kept; WildQuest will not skip them."
        end
    else
        lines[#lines + 1] = ""
        lines[#lines + 1] = "QuestieDB is not connected; showing quest-log data only."
    end
    self.pageText:SetText(table.concat(lines, "\n"))
end

function ns.Tracker:Refresh()
    if not self.frame or not self.pageText or not ns.initialized then return end
    self.locationText:SetText(CurrentLocation() .. "   |   Level " .. tostring(UnitLevel and UnitLevel("player") or "?")
        .. "   |   " .. ns.QuestState:GetActiveCount() .. " active")
    for i = 1, ROWS_PER_PAGE do self.rows[i]:Hide() end
    if self.page == "guide" then self:RefreshGuidePage() else self:RefreshQuestPage() end
end

function ns.Tracker:Toggle()
    if not self.frame then return end
    if self.frame:IsShown() then
        self.frame:Hide()
        WildQuestDB.profile.trackerShown = false
    else
        self:Refresh()
        self.frame:Show()
        WildQuestDB.profile.trackerShown = true
    end
end

function ns.Tracker:OpenGuide()
    if not self.frame then return end
    self.page = "guide"
    self:Refresh()
    self.frame:Show()
    WildQuestDB.profile.trackerShown = true
end
