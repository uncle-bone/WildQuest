local _, ns = ...
ns.ProfessionView = {}
function ns.ProfessionView:GetCurrent()
    local rows = {}
    if type(GetProfessions) ~= "function" or type(GetProfessionInfo) ~= "function" then
        return rows, "Profession inspection API is unavailable on this client build."
    end
    local ids = { GetProfessions() }
    for _, id in ipairs(ids) do
        if id then
            local name, icon, skill, maxSkill, modifier, professionID = GetProfessionInfo(id)
            if name then rows[#rows + 1] = { name = name, icon = icon,
                skill = tonumber(skill) or 0, maxSkill = tonumber(maxSkill) or 0,
                professionID = professionID or id } end
        end
    end
    return rows, #rows == 0 and "Open each profession window once if the client has not populated profession data." or nil
end
