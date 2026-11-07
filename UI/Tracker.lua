local _, ns = ...

ns.Tracker = {
    frame = nil,
    text = nil,
}

function ns.Tracker:Initialize()
    if self.frame then
        return
    end

    local frame = CreateFrame("Frame", "WildQuestTrackerFrame", UIParent)
    frame:SetSize(310, 190)
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
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(0.03, 0.05, 0.08, 0.94)

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", frame, "TOPLEFT", 14, -12)
    title:SetText("WildQuest")

    local body = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    body:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -12)
    body:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -14, 14)
    body:SetJustifyH("LEFT")
    body:SetJustifyV("TOP")
    body:SetText("Loading…")

    self.frame = frame
    self.text = body

    if WildQuestDB.profile.trackerShown then
        frame:Show()
    else
        frame:Hide()
    end
end

function ns.Tracker:Refresh()
    if not self.frame or not self.text then
        return
    end

    local quests = ns.QuestState:GetActiveQuests()
    local lines = {
        "QuestieDB: " .. ns.Provider:GetStatus(),
        "Active quests: " .. tostring(#quests),
        "Guide: " .. ns.GuideRuntime:GetDisplayState(),
        "",
    }

    local shown = math.min(#quests, 6)
    for index = 1, shown do
        local quest = quests[index]
        local name = quest.title or ns.Provider:GetQuestName(quest.id) or ("Quest " .. tostring(quest.id))
        lines[#lines + 1] = "- " .. name
    end

    if #quests > shown then
        lines[#lines + 1] = "...and " .. tostring(#quests - shown) .. " more"
    end

    lines[#lines + 1] = ""
    lines[#lines + 1] = "/wq toggles this window"

    self.text:SetText(table.concat(lines, "\n"))
end

function ns.Tracker:Toggle()
    if not self.frame then
        return
    end

    if self.frame:IsShown() then
        self.frame:Hide()
        WildQuestDB.profile.trackerShown = false
    else
        self:Refresh()
        self.frame:Show()
        WildQuestDB.profile.trackerShown = true
    end
end
