local _, ns = ...
ns.TalentNotebook = { lastSnapshot = nil }
function ns.TalentNotebook:CaptureCurrentBuild(label)
    if type(GetNumTalentTabs) ~= "function" or type(GetTalentTabInfo) ~= "function"
        or type(GetTalentInfo) ~= "function" then
        return false, "this Forever client does not expose the classic talent inspection API"
    end
    local classToken
    if type(UnitClass) == "function" then local _, token = UnitClass("player"); classToken = token end
    local snapshot = { label = label or "Current build", level = UnitLevel and UnitLevel("player") or 0,
        class = classToken, tabs = {} }
    local tabCount = tonumber(GetNumTalentTabs()) or 0
    for tab = 1, tabCount do
        local name, _, pointsSpent = GetTalentTabInfo(tab)
        local row = { name = name or ("Tree " .. tab), pointsSpent = tonumber(pointsSpent) or 0, talents = {} }
        local talentCount = type(GetNumTalents) == "function" and (tonumber(GetNumTalents(tab)) or 0) or 0
        for index = 1, talentCount do
            local talentName, _, tier, column, rank, maxRank = GetTalentInfo(tab, index)
            rank, maxRank = tonumber(rank) or 0, tonumber(maxRank) or 0
            if rank > 0 then
                row.talents[#row.talents + 1] = { name = talentName or ("Talent " .. index),
                    index = index, tier = tonumber(tier) or 0, column = tonumber(column) or 0,
                    rank = rank, maxRank = maxRank }
            end
        end
        snapshot.tabs[#snapshot.tabs + 1] = row
    end
    self.lastSnapshot = snapshot
    local db = ns:GetCharacterDB()
    db.talentNotebook = type(db.talentNotebook) == "table" and db.talentNotebook or {}
    db.talentNotebook.savedCurrent = snapshot
    return true, snapshot
end
function ns.TalentNotebook:GetSaved()
    local db = ns:GetCharacterDB()
    return type(db.talentNotebook) == "table" and db.talentNotebook.savedCurrent or nil
end
