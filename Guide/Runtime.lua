local _, ns = ...

ns.GuideRuntime = {
    currentGuideID = nil,
    currentStepID = nil,
}

function ns.GuideRuntime:Initialize()
    local profile = WildQuestDB and WildQuestDB.profile or {}
    self.currentGuideID = profile.currentGuideID
    self.currentStepID = profile.currentStepID
end

function ns.GuideRuntime:HandleEvent(_event)
    -- Guide progression will be driven by validated guide records and quest-state events.
end

function ns.GuideRuntime:GetDisplayState()
    if not self.currentGuideID then
        return "No guide selected"
    end
    return tostring(self.currentGuideID) .. " / " .. tostring(self.currentStepID or "start")
end
