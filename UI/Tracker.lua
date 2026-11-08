local _, ns = ...

ns.Tracker = { frame = nil, page = "overview", questPage = 1, routePage = 1,
    guideCategory = "All", rows = {}, nav = {} }
local ROWS = 8
local CATEGORIES = { "All", "Leveling", "Dungeons", "Events", "Professions", "Reputations" }

local function CurrentLocation()
    if type(GetInstanceInfo) == "function" then
        local name, instanceType = GetInstanceInfo()
        if instanceType == "party" then return "Dungeon: " .. tostring(name or "unknown") end
        if instanceType == "raid" then return "Raid: " .. tostring(name or "unknown") end
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
    label:SetPoint("LEFT", button, "LEFT", 7, 0)
    label:SetPoint("RIGHT", button, "RIGHT", -7, 0)
    label:SetJustifyH("LEFT")
    label:SetText(text or "")
    button.label = label
    button:SetScript("OnClick", callback)
    return button
end

local function FormatMoney(copper)
    copper = math.max(0, tonumber(copper) or 0)
    if type(GetCoinTextureString) == "function" then return GetCoinTextureString(copper) end
    local gold = math.floor(copper / 10000)
    local silver = math.floor((copper % 10000) / 100)
    local remainder = copper % 100
    return gold .. "g " .. silver .. "s " .. remainder .. "c"
end

local function HideRows(self)
    for i = 1, ROWS do self.rows[i]:Hide() end
    self.rowQuests, self.rowRoutes = nil, nil
end

function ns.Tracker:Initialize()
    if self.frame then return end
    local frame = CreateFrame("Frame", "WildQuestTrackerFrame", UIParent)
    frame:SetSize(700, 560)
    frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -35, -70)
    frame:SetClampedToScreen(true)
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
        if type(frame.SetBackdropColor) == "function" then frame:SetBackdropColor(0.025, 0.045, 0.07, 0.98) end
    else
        local bg = frame:CreateTexture(nil, "BACKGROUND")
        bg:SetTexture("Interface/Tooltips/UI-Tooltip-Background")
        bg:SetAllPoints(frame)
        bg:SetVertexColor(0.025, 0.045, 0.07, 0.98)
    end

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -13)
    title:SetText("|cff67d5ffWildQuest|r  |cffaaaaaaalpha.12|r")
    self.locationText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    self.locationText:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -5)

    local close = MakeButton(frame, 28, 24, "X", function()
        frame:Hide()
        WildQuestDB.profile.trackerShown = false
    end)
    close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -12, -10)

    local nav = {
        { "overview", "Home" }, { "quests", "My Quests" }, { "guides", "Guides" },
        { "guide", "Current Guide" }, { "gear", "Gear" }, { "talents", "Talents" },
        { "gold", "Gold / AH" }, { "professions", "Professions" },
    }
    local navWidth = 102
    for i, entry in ipairs(nav) do
        local page, label = entry[1], entry[2]
        local button = MakeButton(frame, navWidth, 27, label, function() self:SetPage(page) end)
        button:SetPoint("TOPLEFT", frame, "TOPLEFT", 11, -61 - ((i - 1) * 31))
        self.nav[page] = button
    end

    self.pageTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.pageTitle:SetPoint("TOPLEFT", frame, "TOPLEFT", 128, -68)
    self.pageText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    self.pageText:SetPoint("TOPLEFT", frame, "TOPLEFT", 128, -93)
    self.pageText:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -15, 54)
    self.pageText:SetJustifyH("LEFT")
    self.pageText:SetJustifyV("TOP")

    for i = 1, ROWS do
        local rowIndex = i
        local row = MakeButton(frame, 555, 34, "", function()
            local quest = self.rowQuests and self.rowQuests[rowIndex]
            local route = self.rowRoutes and self.rowRoutes[rowIndex]
            if quest then
                local ok, err = ns.GuideRuntime:TrackQuest(quest.id)
                if ok then self:SetPage("guide"); if ns.GuidePane then ns.GuidePane:Show() end else ns:Print(err) end
            elseif route then
                local ok, err = ns.GuideRuntime:SelectGuide(route.id)
                if ok then self:SetPage("guide"); if ns.GuidePane then ns.GuidePane:Show() end else ns:Print(err) end
            end
        end)
        row:SetPoint("TOPLEFT", frame, "TOPLEFT", 125, -130 - ((i - 1) * 37))
        self.rows[i] = row
    end

    self.prevPage = MakeButton(frame, 145, 28, "Previous", function()
        if self.page == "quests" then self.questPage = math.max(1, self.questPage - 1)
        else self.routePage = math.max(1, self.routePage - 1) end
        self:Refresh()
    end)
    self.prevPage:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 20, 18)
    self.nextPage = MakeButton(frame, 145, 28, "More", function()
        if self.page == "quests" then self.questPage = self.questPage + 1
        else self.routePage = self.routePage + 1 end
        self:Refresh()
    end)
    self.nextPage:SetPoint("LEFT", self.prevPage, "RIGHT", 8, 0)
    self.categoryButton = MakeButton(frame, 165, 28, "Category: All", function()
        local at = 1
        for i, category in ipairs(CATEGORIES) do if category == self.guideCategory then at = i break end end
        at = at % #CATEGORIES + 1
        self.guideCategory = CATEGORIES[at]
        self.routePage = 1
        self:Refresh()
    end)
    self.categoryButton:SetPoint("LEFT", self.nextPage, "RIGHT", 8, 0)

    self.prevStep = MakeButton(frame, 130, 28, "Previous step", function()
        local ok, err = ns.GuideRuntime:PreviousStep()
        if not ok then ns:Print(err) end
        self:Refresh()
    end)
    self.prevStep:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 20, 18)
    self.nextStep = MakeButton(frame, 130, 28, "Skip step", function()
        local ok, err = ns.GuideRuntime:NextStep()
        if not ok then ns:Print(err) else ns:Print("step skipped by your override; quest completion was not recorded.") end
        self:Refresh()
        ns.GuidePane:Refresh()
    end)
    self.nextStep:SetPoint("LEFT", self.prevStep, "RIGHT", 8, 0)
    self.backButton = MakeButton(frame, 150, 28, "Back to guides", function() self:SetPage("guides") end)
    self.backButton:SetPoint("LEFT", self.nextStep, "RIGHT", 8, 0)

    self.talentSaveButton = MakeButton(frame, 170, 28, "Save talent snapshot", function()
        local ok, result = ns.TalentNotebook:CaptureCurrentBuild("Current build")
        ns:Print(ok and "talent snapshot saved." or result)
        self:Refresh()
    end)
    self.talentSaveButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 20, 18)

    self.auctionQuery = CreateFrame("EditBox", "WildQuestAuctionQuery", frame, "InputBoxTemplate")
    self.auctionQuery:SetSize(235, 26)
    self.auctionQuery:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 20, 18)
    self.auctionQuery:SetAutoFocus(false)
    self.auctionQuery:SetMaxLetters(100)
    self.auctionQuery:SetScript("OnEnterPressed", function(box)
        local ok, err = ns.Auction:Scan(box:GetText())
        if not ok then ns:Print(err) else ns:Print("Auction House search sent.") end
        box:ClearFocus()
    end)
    self.auctionScanButton = MakeButton(frame, 140, 28, "Scan Auction House", function()
        local ok, err = ns.Auction:Scan(self.auctionQuery:GetText())
        if not ok then ns:Print(err) else ns:Print("Auction House search sent.") end
        self:Refresh()
    end)
    self.auctionScanButton:SetPoint("LEFT", self.auctionQuery, "RIGHT", 12, 0)

    self.frame = frame
    if WildQuestDB.profile.trackerShown then frame:Show() else frame:Hide() end
end

function ns.Tracker:SetPage(page)
    local valid = { overview = true, quests = true, guides = true, guide = true,
        gear = true, talents = true, gold = true, professions = true }
    self.page = valid[page] and page or "overview"
    self:Refresh()
end

function ns.Tracker:RefreshOverview()
    local xp = ns.XPObserver:GetSummary()
    local gold = ns.Gold:GetSummary()
    local guide = ns.GuideRuntime:GetCurrentGuide()
    local routeCount = 0
    for _ in pairs(ns.GuidePacks.byID) do routeCount = routeCount + 1 end
    local recommended = ns.GuidePacks:GetAvailable("All", false)[1]
    local lines = {
        "|cff67d5ffCharacter|r  Level " .. tostring(UnitLevel and UnitLevel("player") or "?")
            .. "  |  " .. tostring(UnitFactionGroup and UnitFactionGroup("player") or "Faction unknown")
            .. "  |  " .. CurrentLocation(),
        "Active quests: " .. ns.QuestState:GetActiveCount() .. "     Bundled route guides: " .. routeCount,
        "Current route: " .. (guide and guide.title or "none selected"),
        "XP observed this session: +" .. tostring(xp.sessionDelta) .. " (source not inferred)",
        "Current gold: " .. FormatMoney(gold.copper) .. "     Session change: " .. FormatMoney(math.abs(gold.sessionDelta))
            .. (gold.sessionDelta < 0 and " spent" or " gained"),
        "",
        recommended and ("Suggested next guide: " .. recommended.pack.title .. "  (" .. recommended.activeMatches .. " active quest matches)")
            or "No nearby guide matches this level and faction. Browse Guides for the full catalog.",
        "",
        "Choose a section above. Guides include leveling, dungeon, event, profession, and reputation quest packs.",
        "Gear audit, talent snapshots, gold tracking, and in-client Auction House scans are built into WildQuest.",
    }
    self.pageTitle:SetText("Adventure overview")
    self.pageText:SetText(table.concat(lines, "\n"))
end

function ns.Tracker:RefreshQuestPage()
    local quests = ns.QuestState:GetActiveQuests()
    local pages = math.max(1, math.ceil(#quests / ROWS))
    self.questPage = math.min(self.questPage, pages)
    self.rowQuests, self.rowRoutes = {}, nil
    local first = (self.questPage - 1) * ROWS + 1
    for i = 1, ROWS do
        local quest, row = quests[first + i - 1], self.rows[i]
        if quest then
            self.rowQuests[i] = quest
            local name = quest.title or ns.Provider:GetQuestName(quest.id) or ("Quest " .. quest.id)
            local details = ns.Provider:GetQuestDetails(quest.id)
            local level = details and tonumber(details.questLevel)
            local suffix = quest.isReady and "  |cff71d7a5[READY]|r" or ""
            if level and level > 0 then suffix = suffix .. "  (level " .. level .. ")" end
            row.label:SetText(name .. suffix)
            row:Show()
        else row:Hide() end
    end
    self.pageText:ClearAllPoints(); self.pageText:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 128, -93); self.pageText:SetWidth(550); self.pageText:SetHeight(28)
    self.pageTitle:SetText("My active quests   -   " .. #quests)
    self.pageText:SetText("Select a quest to track its live objectives. Quest facts, prerequisite records, and giver locations are bundled with WildQuest.")
    self.prevPage:SetText("Previous quests")
    self.nextPage:SetText("More quests")
    if self.questPage > 1 then self.prevPage:Show() else self.prevPage:Hide() end
    if self.questPage < pages then self.nextPage:Show() else self.nextPage:Hide() end
    self.categoryButton:Hide(); self.prevStep:Hide(); self.nextStep:Hide(); self.backButton:Hide()
    self.talentSaveButton:Hide(); self.auctionQuery:Hide(); self.auctionScanButton:Hide()
end

function ns.Tracker:RefreshRoutePage()
    local routes = ns.GuidePacks:GetAvailable(self.guideCategory, true)
    local pages = math.max(1, math.ceil(#routes / ROWS))
    self.routePage = math.min(self.routePage, pages)
    self.rowRoutes, self.rowQuests = {}, nil
    local first = (self.routePage - 1) * ROWS + 1
    for i = 1, ROWS do
        local rowData, row = routes[first + i - 1], self.rows[i]
        if rowData then
            local pack = rowData.pack
            self.rowRoutes[i] = pack
            local level = pack.minLevel and ("   -   Lv " .. pack.minLevel .. " - " .. pack.maxLevel) or ""
            local active = rowData.activeMatches > 0 and ("   -   " .. rowData.activeMatches .. " active") or ""
            local marker = rowData.zoneMatch and "|cff71d7a5HERE  |r" or ""
            row.label:SetText(marker .. pack.title .. level .. active)
            row:Show()
        else row:Hide() end
    end
    local count = #routes
    self.pageText:ClearAllPoints(); self.pageText:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 128, -93); self.pageText:SetWidth(550); self.pageText:SetHeight(28)
    self.pageTitle:SetText("Guide library   -   " .. self.guideCategory .. "   -   " .. count .. " guides")
    self.pageText:SetText("Active quests resume first. WildQuest checks quest levels and confirmed OR/AND prerequisites. A grey quest is auto-skipped only when all known chain gates are confirmed complete; uncertain gates stay in the guide for you to resolve.")
    self.prevPage:SetText("Previous guides"); self.nextPage:SetText("More guides")
    if self.routePage > 1 then self.prevPage:Show() else self.prevPage:Hide() end
    if self.routePage < pages then self.nextPage:Show() else self.nextPage:Hide() end
    self.categoryButton.label:SetText("Category: " .. self.guideCategory)
    self.categoryButton:Show(); self.prevStep:Hide(); self.nextStep:Hide(); self.backButton:Hide()
    self.talentSaveButton:Hide(); self.auctionQuery:Hide(); self.auctionScanButton:Hide()
end

function ns.Tracker:RefreshGuidePage()
    local guide = ns.GuideRuntime:GetCurrentGuide()
    self.pageTitle:SetText(guide and guide.title or "No guide selected")
    self.prevPage:Hide(); self.nextPage:Hide(); self.categoryButton:Hide()
    self.prevStep:Show(); self.nextStep:Show(); self.backButton:Show()
    self.talentSaveButton:Hide(); self.auctionQuery:Hide(); self.auctionScanButton:Hide()
    if not guide then
        for i = 1, ROWS do self.rows[i]:Hide() end
        self.pageText:SetText("Open Guides and choose a route, or choose an active quest from My Quests.")
        return
    end
    local step = ns.GuideRuntime:GetCurrentStep()
    local routeRow, pack = step and ns.GuidePacks:GetStep(guide.id, step.id) or nil, ns.GuidePacks:GetForGuide(guide.id)
    if type(routeRow) == "table" then pack = ns.GuidePacks:GetForGuide(guide.id) end
    local questID = type(routeRow) == "table" and routeRow.questID or tonumber(guide.id:match("^quest%-(%d+)$"))
    local active = questID and ns.QuestState:FindActiveQuest(questID)
    local details = questID and ns.Provider:GetQuestDetails(questID)
    local lines = {}
    if pack then
        lines[#lines + 1] = "|cff67d5ff" .. pack.category .. "|r   -   " .. pack.faction
            .. (pack.minLevel and ("   -   Levels " .. pack.minLevel .. " - " .. pack.maxLevel) or "")
        lines[#lines + 1] = "Route quality: " .. tostring(pack.quality or "?") .. "% database/prerequisite fit"
            .. "   -   " .. tostring(#guide.steps) .. " quest steps"
    elseif questID then
        lines[#lines + 1] = "Quest ID: " .. questID
    end
    if step then
        lines[#lines + 1] = ""
        lines[#lines + 1] = "STEP " .. guide.stepIndexes[step.id] .. " OF " .. #guide.steps
        lines[#lines + 1] = step.text
        lines[#lines + 1] = ns.GuideRuntime:GetProgressText()
    else
        lines[#lines + 1] = ""
        lines[#lines + 1] = "Guide complete. All included quest steps are already recorded complete."
    end
    if questID then
        lines[#lines + 1] = ""
        lines[#lines + 1] = "QUEST DETAILS   -   " .. (ns.Provider:GetQuestName(questID) or ("Quest " .. questID)) .. " (#" .. questID .. ")"
        if details then
            local allowed, reason = ns.Provider:GetCharacterAvailability(questID)
            if allowed == false then lines[#lines + 1] = "Character gate: " .. tostring(reason) .. " (not auto-skipped)." end
            if details.questLevel and details.questLevel > 0 then lines[#lines + 1] = "Quest level: " .. details.questLevel end
            local levelStatus, questLevel, playerLevel = ns.Provider:GetQuestLevelStatus(questID)
            if levelStatus == "gray" then
                local chainOK, chainReason = ns.Provider:AreQuestPrerequisitesConfirmed(questID)
                lines[#lines + 1] = "|cffff7777Below your level: quest " .. tostring(questLevel)
                    .. " is grey at level " .. tostring(playerLevel) .. ". "
                    .. (chainOK and "Its known chain gates are confirmed; the route can skip it."
                        or ("It may still gate later quests (" .. tostring(chainReason) .. "). Finish it or use Skip step.")) .. "|r"
            end
            if details.requiredLevel and details.requiredLevel > 0 then lines[#lines + 1] = "Minimum level: " .. details.requiredLevel end
            for _, objective in ipairs(details.objectivesText or {}) do lines[#lines + 1] = "- " .. tostring(objective) end
            local ors, ands = details.preQuestSingle, details.preQuestGroup
            if type(ors) == "table" and #ors > 0 then
                local names = {}
                for _, id in ipairs(ors) do names[#names + 1] = (ns.Provider:GetQuestName(id) or ("Quest " .. id)) .. " (#" .. id .. ")" end
                lines[#lines + 1] = "Prerequisite: complete any one of " .. table.concat(names, ", ") .. "."
            end
            if type(ands) == "table" and #ands > 0 then
                local names = {}
                for _, id in ipairs(ands) do names[#names + 1] = (ns.Provider:GetQuestName(id) or ("Quest " .. id)) .. " (#" .. id .. ")" end
                lines[#lines + 1] = "Required prerequisite group: complete all of " .. table.concat(names, ", ") .. "."
            end
            if details.parentQuest then lines[#lines + 1] = "Requires parent quest active: " .. (ns.Provider:GetQuestName(details.parentQuest) or details.parentQuest) end
            local locations = ns.Provider:GetQuestGiverLocations(questID, active and active.isReady or false)
            if #locations > 0 then
                lines[#lines + 1] = active and active.isReady and "TURN-IN LOCATIONS" or "START LOCATIONS"
                for _, loc in ipairs(locations) do
                    lines[#lines + 1] = (loc.name or loc.kind) .. "  -  area " .. tostring(loc.area)
                        .. "  (" .. string.format("%.1f", loc.x) .. ", " .. string.format("%.1f", loc.y) .. ")"
                end
            end
        end
        if active then
            lines[#lines + 1] = ""
            lines[#lines + 1] = active.isReady and "Quest status: ready to turn in" or "Quest status: active"
            for i, objective in ipairs(active.objectives or {}) do
                lines[#lines + 1] = tostring(objective.fulfilled or 0) .. "/" .. tostring(objective.required or 1)
                    .. "  " .. tostring(objective.text or ("Objective " .. i))
            end
        elseif not ns.QuestState:IsQuestTurnedIn(questID) then
            lines[#lines + 1] = "Quest status: not active. Accept it if it is available to your character."
        end
    end
    self.pageText:SetText(table.concat(lines, "\n"))
    for i = 1, ROWS do self.rows[i]:Hide() end
end

function ns.Tracker:RefreshGearPage()
    local slots = { {1,"Head"},{2,"Neck"},{3,"Shoulder"},{5,"Chest"},{6,"Waist"},{7,"Legs"},
        {8,"Feet"},{9,"Wrist"},{10,"Hands"},{11,"Ring"},{12,"Ring"},{13,"Trinket"},
        {14,"Trinket"},{15,"Back"},{16,"Main hand"},{17,"Off hand"},{18,"Ranged"} }
    local lines = { "Equipped gear audit   -   item levels are read from the client tooltip cache.", "" }
    local total, count = 0, 0
    for _, slot in ipairs(slots) do
        local link = type(GetInventoryItemLink) == "function" and GetInventoryItemLink("player", slot[1]) or nil
        if link then
            local name, itemLevel
            if type(GetItemInfo) == "function" then local itemName, _, _, foundLevel = GetItemInfo(link); name, itemLevel = itemName, foundLevel end
            itemLevel = type(GetDetailedItemLevelInfo) == "function" and GetDetailedItemLevelInfo(link) or itemLevel
            itemLevel = tonumber(itemLevel)
            if itemLevel then total, count = total + itemLevel, count + 1 end
            lines[#lines + 1] = slot[2] .. ": " .. tostring(name or link) .. (itemLevel and ("   -   iLvl " .. itemLevel) or "   -   details loading")
        else lines[#lines + 1] = slot[2] .. ": empty" end
    end
    lines[#lines + 1] = ""
    lines[#lines + 1] = count > 0 and ("Average equipped item level: " .. string.format("%.1f", total / count))
        or "Item-level data is not available yet."
    lines[#lines + 1] = "This is a personal gear audit; WildQuest does not invent stat weights or claim best-in-slot upgrades."
    self.pageTitle:SetText("Gear advisor")
    self.pageText:SetText(table.concat(lines, "\n"))
end

function ns.Tracker:RefreshTalentPage()
    local lines = { "Talent notebook   -   inspect your active build and save a snapshot for later comparison.", "" }
    local saved = ns.TalentNotebook:GetSaved()
    if saved then lines[#lines + 1] = "Saved: " .. tostring(saved.label) .. "   -   level " .. tostring(saved.level) else lines[#lines + 1] = "No talent snapshot saved yet." end
    lines[#lines + 1] = ""
    if type(GetNumTalentTabs) == "function" and type(GetTalentTabInfo) == "function" then
        for tab = 1, tonumber(GetNumTalentTabs()) or 0 do
            local name, _, spent = GetTalentTabInfo(tab)
            lines[#lines + 1] = tostring(name or ("Tree " .. tab)) .. ": " .. tostring(spent or 0) .. " points"
        end
    else lines[#lines + 1] = "This client build does not expose the classic talent inspection API." end
    lines[#lines + 2] = ""
    lines[#lines + 1] = "WildQuest records your build; talent spending and respecs remain controlled by the game UI."
    self.pageTitle:SetText("Talent advisor")
    self.pageText:SetText(table.concat(lines, "\n"))
    self.talentSaveButton:Show()
end

function ns.Tracker:RefreshGoldPage()
    local gold = ns.Gold:GetSummary()
    local deltaLabel = gold.sessionDelta < 0 and "spent" or "gained"
    local lines = { "Wallet: " .. FormatMoney(gold.copper),
        "Observed since opening this session: " .. FormatMoney(math.abs(gold.sessionDelta)) .. " " .. deltaLabel,
        "",
        "Auction House price scan: open the Auction House, enter an item name, then request a scan below.",
        "Scan results show the lowest observed buyout per item and are saved locally as notes.",
        "",
        ns.Auction.lastMessage or "No Auction House search yet." }
    for i = 1, math.min(8, #(ns.Auction.results or {})) do
        local item = ns.Auction.results[i]
        lines[#lines + 1] = tostring(item.name) .. "  -  " .. FormatMoney(item.unitPrice) .. " each"
    end
    self.pageTitle:SetText("Gold and Auction House")
    self.pageText:SetText(table.concat(lines, "\n"))
    self.auctionQuery:Show(); self.auctionScanButton:Show()
end

function ns.Tracker:RefreshProfessionPage()
    local professions, note = ns.ProfessionView:GetCurrent()
    local lines = { "Profession dashboard   -   readings come from the Forever client profession API.", "" }
    for _, prof in ipairs(professions) do
        lines[#lines + 1] = prof.name .. "   -   " .. prof.skill .. "/" .. prof.maxSkill
    end
    if #professions == 0 then lines[#lines + 1] = note or "No profession data reported by the client." end
    lines[#lines + 2] = ""
    lines[#lines + 1] = "A recipe planner can be added when a verified Forever recipe and reagent dataset is available."
    self.pageTitle:SetText("Professions")
    self.pageText:SetText(table.concat(lines, "\n"))
end

function ns.Tracker:Refresh()
    if not self.frame or not self.pageText or not ns.initialized then return end
    self.locationText:SetText(CurrentLocation() .. "   -   Level " .. tostring(UnitLevel and UnitLevel("player") or "?")
        .. "   -   " .. ns.QuestState:GetActiveCount() .. " active quests")
    HideRows(self)
    self.pageText:ClearAllPoints()
    self.pageText:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 128, -93)
    self.pageText:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -15, 54)
    self.pageText:SetHeight(0)
    self.prevPage:Hide(); self.nextPage:Hide(); self.categoryButton:Hide()
    self.prevStep:Hide(); self.nextStep:Hide(); self.backButton:Hide()
    self.talentSaveButton:Hide(); self.auctionQuery:Hide(); self.auctionScanButton:Hide()
    if self.page == "quests" then self:RefreshQuestPage()
    elseif self.page == "guides" then self:RefreshRoutePage()
    elseif self.page == "guide" then self:RefreshGuidePage()
    elseif self.page == "gear" then self:RefreshGearPage()
    elseif self.page == "talents" then self:RefreshTalentPage()
    elseif self.page == "gold" then self:RefreshGoldPage()
    elseif self.page == "professions" then self:RefreshProfessionPage()
    else self:RefreshOverview() end
end

function ns.Tracker:Toggle()
    if not self.frame then return end
    if self.frame:IsShown() then self.frame:Hide(); WildQuestDB.profile.trackerShown = false
    else self:Refresh(); self.frame:Show(); WildQuestDB.profile.trackerShown = true end
end
function ns.Tracker:OpenGuide()
    if not self.frame then return end
    self.page = "guide"; self:Refresh(); self.frame:Show(); WildQuestDB.profile.trackerShown = true
end





