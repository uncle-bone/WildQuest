local _, ns = ...

ns.MinimapButton = { button = nil }

local function PositionButton(button)
    local profile = WildQuestDB and WildQuestDB.profile or {}
    local angle = math.rad(tonumber(profile.minimapAngle) or 220)
    local radius = 80
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
end

local function SetShown(shown)
    local profile = WildQuestDB.profile
    profile.minimapShown = shown and true or false
    if shown then
        ns.MinimapButton.button:Show()
    else
        ns.MinimapButton.button:Hide()
    end
end

function ns.MinimapButton:Initialize()
    if self.button or not Minimap then return end

    local button = CreateFrame("Button", "WildQuestMinimapButton", Minimap)
    button:SetSize(32, 32)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel((Minimap:GetFrameLevel() or 0) + 8)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:EnableMouse(true)

    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetTexture("Interface/Icons/INV_Misc_Map_01")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER")
    button.icon = icon

    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface/Minimap/MiniMap-TrackingBorder")
    border:SetSize(54, 54)
    border:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)

    button:SetHighlightTexture("Interface/Minimap/UI-Minimap-ZoomButton-Highlight")
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("WildQuest", 0.4, 0.85, 1)
        GameTooltip:AddLine("Left-click: open or close guide", 1, 1, 1)
        GameTooltip:AddLine("Drag: move button around minimap", 0.75, 0.75, 0.75)
        GameTooltip:AddLine("/wq minimap to show or hide", 0.75, 0.75, 0.75)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    button:SetScript("OnClick", function(_, mouseButton)
        if mouseButton == "LeftButton" then
            ns.Tracker:Toggle()
        elseif mouseButton == "RightButton" then
            SetShown(false)
            ns:Print("minimap button hidden. Use /wq minimap to show it again.")
        end
    end)
    button:SetScript("OnDragStart", function(self)
        self.dragging = true
        self:SetScript("OnUpdate", function(active)
            if not active.dragging then return end
            local x, y = GetCursorPosition()
            local scale = UIParent:GetEffectiveScale()
            x, y = x / scale, y / scale
            local cx, cy = Minimap:GetCenter()
            local dx, dy = x - cx, y - cy
            local angle = math.atan2(dy, dx)
            WildQuestDB.profile.minimapAngle = math.deg(angle)
            PositionButton(active)
        end)
    end)
    button:SetScript("OnDragStop", function(self)
        self.dragging = false
        self:SetScript("OnUpdate", nil)
    end)
    button:RegisterForDrag("LeftButton")

    self.button = button
    PositionButton(button)
    if WildQuestDB.profile.minimapShown == false then button:Hide() else button:Show() end
end

function ns.MinimapButton:SetShown(shown)
    if not self.button then return end
    SetShown(shown)
end
