local _, ns = ...

ns.Tracker = {
    frame = nil,
    text = nil,
}

local function CurrentLocation()
    if type(GetInstanceInfo) == "function" then
        local name, _, difficulty, _, _, _, _, instanceType = GetInstanceInfo()
        if instanceType == "party" then
            return "Dungeon: " .. tostring(name or "unknown") .. " (" .. tostring(difficulty or "?") .. ")"
        elseif instanceType == "raid" then
            return "Raid: " .. tostring(name or "unknown")
        end
    end
    return "Zone: " .. tostring(GetZoneText and GetZoneText() or "unknown")
end

function ns.Tracker:Initialize()
    if self.frame then return end

    local frame = CreateFrame("Frame", "WildQuestTrackerFrame", UIParent)
    frame:SetSize(380, 360)
    frame:SetPoint("CENTER", UIParent, "CENTER", 320, 0)
    frame:SetFrameStrata("MEDIUM")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(0.03, 0.05, 0.08, 0.94)

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", frame, "TOPLEFT", 14, -12)
    title:SetText("WildQuest  |cffaaaaaaalpha.3|r")

    local body = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    body:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -12)
    body:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -14, 14)
    body:SetJustifyH("LEFT")
    body:SetJustifyV("TOP")
    body:SetText("Loading…")

    self.frame = frame
    self.text = body
    if WildQuestDB.profile.trackerShown then frame:Show() else frame:Hide() end
end

function ns.Tracker:Refresh()
    if not self.frame or not self.text or not ns.initialized then return end

    local quests = ns.QuestState:GetActiveQuests()
    local guide = ns.GuideRuntime:GetCurrentGuide()
    local step = ns.GuideRuntime:GetCurrentStep()
    local xp = ns.XPObserver:GetSummary()
    local lines = {
        CurrentLocation(),
        "Level " .. tostring(xp.level) .. " | Active quests: " .. tostring(#quests),
        "QuestieDB: " .. ns.Provider:GetStatus(),
        "XP bar gained this session: +" .. tostring(xp.sessionDelta) .. " (source unknown)",
    }

    if guide then
        lines[#lines + 1] = ""
        lines[#lines + 1] = "Guide: " .. guide.title
        if step then
            lines[#lines + 1] = "Step " .. step.id .. " — " .. ns.GuideRuntime:GetProgressText()
            if step.text ~= "" then lines[#lines + 1] = step.text end
        else
            lines[#lines + 1] = "Guide complete"
        end
    else
        lines[#lines + 1] = ""
        lines[#lines + 1] = "No guide selected."
        lines[#lines + 1] = "Use /wq quest <ID or exact title> to track an active quest."
    end

    lines[#lines + 1] = ""
    lines[#lines + 1] = "ACTIVE QUESTS"
    if #quests == 0 then
        lines[#lines + 1] = "No quests in the log."
    end

    local shown = math.min(#quests, 7)
    for index = 1, shown do
        local quest = quests[index]
        local name = quest.title or ns.Provider:GetQuestName(quest.id) or ("Quest " .. tostring(quest.id))
        local status = quest.isReady and " [READY]" or ""
        lines[#lines + 1] = "[" .. tostring(quest.id) .. "] " .. name .. status
        for objectiveIndex, objective in ipairs(quest.objectives or {}) do
            if objective.text and objective.text ~= "" then
                local progress = tostring(objective.fulfilled or 0) .. "/" .. tostring(objective.required or 1)
                lines[#lines + 1] = "  " .. progress .. " " .. objective.text
            end
            if objectiveIndex >= 2 then break end
        end
    end
    if #quests > shown then lines[#lines + 1] = "...and " .. tostring(#quests - shown) .. " more" end

    lines[#lines + 1] = ""
    lines[#lines + 1] = "Use /wq help | drag to move | /wq toggles window"
    self.text:SetText(table.concat(lines, "\n"))
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
