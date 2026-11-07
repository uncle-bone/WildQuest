local _, ns = ...

ns.XPObserver = {
    baselineXP = nil,
    baselineLevel = nil,
    sessionDelta = 0,
    combatTextXP = 0,
    combatTextEvents = 0,
    lastObservation = "Waiting for XP change",
}

local function ReadXP()
    if type(UnitXP) ~= "function" or type(UnitXPMax) ~= "function" then
        return nil, nil
    end
    return tonumber(UnitXP("player")), tonumber(UnitXPMax("player"))
end

function ns.XPObserver:Snapshot(reset)
    local xp, maximum = ReadXP()
    local level = type(UnitLevel) == "function" and UnitLevel("player") or nil
    if not xp or not maximum then
        return
    end

    if self.baselineXP ~= nil and self.baselineLevel == level and not reset then
        local delta = xp - self.baselineXP
        if delta > 0 then
            self.sessionDelta = self.sessionDelta + delta
            self.lastObservation = "Observed +" .. tostring(delta) .. " XP; source unknown"
        elseif delta < 0 then
            self.lastObservation = "XP bar changed; level boundary or correction"
        end
    end

    self.baselineXP = xp
    self.baselineLevel = level
end

function ns.XPObserver:HandleEvent(event, ...)
    if event == "PLAYER_XP_UPDATE" then
        self:Snapshot(false)
    elseif event == "PLAYER_LEVEL_UP" then
        self:Snapshot(true)
        self.lastObservation = "Level changed; XP baseline reset"
    elseif event == "CHAT_MSG_COMBAT_XP_GAIN" then
        local message = ...
        if type(message) == "string" then
            local number = message:match("(%d+)")
            number = tonumber(number)
            if number and number > 0 then
                self.combatTextXP = self.combatTextXP + number
                self.combatTextEvents = self.combatTextEvents + 1
                self.lastObservation = "Combat XP chat observed +" .. tostring(number) .. " XP"
            end
        end
    end
end

function ns.XPObserver:Initialize()
    self.characterDB = ns:GetCharacterDB()
    self.characterDB.xpObservations = type(self.characterDB.xpObservations) == "table"
        and self.characterDB.xpObservations or {}
    self.sessionDelta = 0
    self.combatTextXP = 0
    self.combatTextEvents = 0
    self:Snapshot(true)

    ns.EventFrame:RegisterEvent("PLAYER_XP_UPDATE")
    ns.EventFrame:RegisterEvent("PLAYER_LEVEL_UP")
    ns.EventFrame:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")
end

function ns.XPObserver:GetSummary()
    return {
        sessionDelta = self.sessionDelta,
        combatTextXP = self.combatTextXP,
        combatTextEvents = self.combatTextEvents,
        lastObservation = self.lastObservation,
        level = type(UnitLevel) == "function" and UnitLevel("player") or 0,
    }
end
