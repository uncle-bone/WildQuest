local _, ns = ...

ns.TrackerArrow = { frame = nil, targets = {}, elapsed = 0, enabled = true }

local function SafeCall(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b = pcall(fn, ...)
    if ok then return a, b end
end

local function PlayerPosition(mapID)
    if not C_Map or not mapID then return nil end
    local pos = SafeCall(C_Map.GetPlayerMapPosition, mapID, "player")
    if not pos or type(pos.GetXY) ~= "function" then return nil end
    return SafeCall(pos.GetXY, pos)
end

local function WorldPosition(mapID, x, y)
    if not C_Map or type(C_Map.GetWorldPosFromMapPos) ~= "function"
        or type(CreateVector2D) ~= "function" then return nil end
    local point = CreateVector2D(x, y)
    local continent, world = SafeCall(C_Map.GetWorldPosFromMapPos, mapID, point)
    if not world then return nil end
    return continent, world
end

function ns.TrackerArrow:Initialize()
    if self.frame then return end
    local frame = CreateFrame("Frame", "WildQuestTrackerArrow", UIParent)
    frame:SetSize(240, 66)
    frame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 175)
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    if type(frame.SetBackdrop) == "function" then
        frame:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border", tile = true, tileSize = 16,
            edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
        if frame.SetBackdropColor then frame:SetBackdropColor(0.02, 0.025, 0.035, 0.88) end
    else
        local bg = frame:CreateTexture(nil, "BACKGROUND")
        bg:SetTexture("Interface/Tooltips/UI-Tooltip-Background")
        bg:SetAllPoints(frame)
        bg:SetVertexColor(0.02, 0.025, 0.035, 0.88)
    end

    self.arrow = frame:CreateTexture(nil, "ARTWORK")
    self.arrow:SetTexture("Interface/MINIMAP/MiniMap-DeadArrow")
    self.arrow:SetSize(42, 42)
    self.arrow:SetPoint("LEFT", frame, "LEFT", 9, 0)
    self.arrow:Hide()

    self.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    self.title:SetPoint("TOPLEFT", frame, "TOPLEFT", 58, -10)
    self.title:SetWidth(170)
    self.title:SetJustifyH("LEFT")
    self.title:SetText("WildQuest destination")

    self.readout = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    self.readout:SetPoint("TOPLEFT", self.title, "BOTTOMLEFT", 0, -4)
    self.readout:SetWidth(170)
    self.readout:SetJustifyH("LEFT")
    self.readout:SetText("Choose a guide to show a target")

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetSize(20, 20)
    close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -1)
    close:SetScript("OnClick", function() self:Hide() end)

    frame:SetScript("OnUpdate", function(_, elapsed)
        self.elapsed = self.elapsed + elapsed
        if self.elapsed >= 0.25 then
            self.elapsed = 0
            self:UpdateDirection()
        end
    end)
    self.frame = frame
    frame:Hide()
end

function ns.TrackerArrow:SetTargets(targets)
    self.targets = type(targets) == "table" and targets or {}
    if #self.targets == 0 then
        if self.frame and self.frame:IsShown() then
            self.arrow:Hide()
            self.title:SetText("WildQuest destination")
            self.readout:SetText("No coordinate for this step")
        end
        return
    end
    if self.enabled then self:Show() end
    self:UpdateDirection()
end

function ns.TrackerArrow:Show()
    self.enabled = true
    if self.frame then self.frame:Show(); self:UpdateDirection() end
end

function ns.TrackerArrow:Hide()
    self.enabled = false
    if self.frame then self.frame:Hide() end
end

function ns.TrackerArrow:Toggle()
    if self.enabled then self:Hide() else self:Show() end
end

function ns.TrackerArrow:UpdateDirection()
    if not self.frame or not self.frame:IsShown() then return end
    local targets = self.targets or {}
    if #targets == 0 then
        self.arrow:Hide()
        return
    end
    local currentMap = C_Map and SafeCall(C_Map.GetBestMapForUnit, "player")
    local playerX, playerY = PlayerPosition(currentMap)
    local best, bestDistance, bestTurn, offMap

    for _, target in ipairs(targets) do
        local mapID = tonumber(target.uiMapID)
        if mapID and currentMap and mapID == currentMap and playerX and playerY then
            local continentA, playerWorld = WorldPosition(mapID, playerX, playerY)
            local continentB, targetWorld = WorldPosition(mapID, (tonumber(target.x) or 0) / 100,
                (tonumber(target.y) or 0) / 100)
            if playerWorld and targetWorld and (not continentA or not continentB or continentA == continentB) then
                local ok, distance, turn = pcall(function()
                    local dx = targetWorld.x - playerWorld.x
                    local dy = targetWorld.y - playerWorld.y
                    local facing = type(GetPlayerFacing) == "function" and (GetPlayerFacing() or 0) or 0
                    return math.sqrt(dx * dx + dy * dy), math.atan2(dy, dx) - facing
                end)
                if ok and (not bestDistance or distance < bestDistance) then
                    best, bestDistance, bestTurn = target, distance, turn
                end
            end
        elseif not offMap then
            offMap = target
        end
    end

    if best then
        local info = C_Map and SafeCall(C_Map.GetMapInfo, best.uiMapID)
        self.title:SetText((best.name and (best.name .. "  -  ") or "") .. tostring(info and info.name or "Target"))
        if bestDistance <= 12 then
            self.readout:SetText("|cff70d090Arrived|r")
        else
            self.readout:SetText(string.format("%.0f yd", bestDistance))
        end
        if type(self.arrow.SetRotation) == "function" then
            pcall(self.arrow.SetRotation, self.arrow, bestTurn or 0)
        end
        self.arrow:Show()
    elseif offMap then
        local info = C_Map and C_Map.GetMapInfo and SafeCall(C_Map.GetMapInfo, offMap.uiMapID)
        self.title:SetText(offMap.name or "Next destination")
        self.readout:SetText("Travel to " .. tostring(info and info.name or "the marked zone"))
        self.arrow:Hide()
    else
        self.title:SetText("WildQuest destination")
        self.readout:SetText("Position data unavailable here")
        self.arrow:Hide()
    end
end
