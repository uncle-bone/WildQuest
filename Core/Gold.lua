local _, ns = ...
ns.Gold = { sessionDelta = 0, current = 0, baseline = 0 }
function ns.Gold:Initialize()
    local characterDB = ns:GetCharacterDB()
    characterDB.gold = type(characterDB.gold) == "table" and characterDB.gold or {}
    self.current = type(GetMoney) == "function" and (tonumber(GetMoney()) or 0) or 0
    self.baseline = self.current
    self.sessionDelta = 0
    ns.EventFrame:RegisterEvent("PLAYER_MONEY")
end
function ns.Gold:HandleEvent(event)
    if event ~= "PLAYER_MONEY" then return end
    local current = type(GetMoney) == "function" and (tonumber(GetMoney()) or 0) or self.current
    self.sessionDelta = self.sessionDelta + current - self.current
    self.current = current
    local data = ns:GetCharacterDB().gold
    data.lastKnownCopper = current
    data.lifetimeObservedDelta = (tonumber(data.lifetimeObservedDelta) or 0) + (current - (tonumber(data.previousCopper) or current))
    data.previousCopper = current
end
function ns.Gold:GetSummary()
    self.current = type(GetMoney) == "function" and (tonumber(GetMoney()) or 0) or self.current
    return { copper = self.current, sessionDelta = self.sessionDelta, baseline = self.baseline }
end
