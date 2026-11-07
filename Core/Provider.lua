local _, ns = ...

ns.Provider = {
    library = nil,
    status = "not detected",
    contract = nil,
}

function ns.Provider:Initialize()
    local library = _G.LibQuestieDB
    if type(library) ~= "table" then
        self.status = "not detected"
        return
    end

    if type(library.RequireContract) ~= "function" then
        self.status = "incompatible API"
        return
    end

    local ok, supported = pcall(library.RequireContract, 4)
    if not ok or not supported then
        self.status = "incompatible contract"
        return
    end

    self.library = library
    self.contract = library.contractVersion
    self.status = "connected (contract " .. tostring(self.contract or "?") .. ")"
end

function ns.Provider:GetStatus()
    return self.status
end

function ns.Provider:GetQuestName(questID)
    local library = self.library
    local questAPI = library and library.Quest
    if not questAPI or type(questAPI.Get) ~= "function" then
        return nil
    end

    local ok, name = pcall(questAPI.Get, questID, "name")
    if ok and type(name) == "string" then
        return name
    end
    return nil
end

function ns.Provider:GetQuestExists(questID)
    local library = self.library
    local questAPI = library and library.Quest
    if not questAPI or type(questAPI.Exists) ~= "function" then
        return false
    end

    local ok, exists = pcall(questAPI.Exists, questID)
    return ok and exists == true
end
