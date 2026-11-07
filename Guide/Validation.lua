local _, ns = ...

ns.Guides = ns.Guides or {}
ns.GuideValidation = ns.GuideValidation or {}

local function IsPositiveInteger(value)
    return type(value) == "number" and value > 0 and value == math.floor(value)
end

local function IsStableID(value)
    return type(value) == "string"
        and #value > 0
        and #value <= 80
        and value:match("^[%w%._%-]+$") ~= nil
end

local function IsString(value, maxLength)
    return type(value) == "string" and #value <= maxLength
end

local function ValidateGoal(goal, stepID, goalIndex)
    if type(goal) ~= "table" or type(goal.type) ~= "string" then
        return nil, "step " .. stepID .. " goal " .. goalIndex .. " must be a typed table"
    end

    local clean = { type = goal.type }

    if goal.type == "manual" then
        if goal.text ~= nil and not IsString(goal.text, 300) then
            return nil, "step " .. stepID .. " manual goal " .. goalIndex .. " text must be 300 characters or fewer"
        end
        clean.text = goal.text or ""
    elseif goal.type == "quest_active" or goal.type == "quest_ready" or goal.type == "quest_turned_in" then
        if not IsPositiveInteger(goal.questID) then
            return nil, "step " .. stepID .. " goal " .. goalIndex .. " needs a positive questID"
        end
        clean.questID = goal.questID
    elseif goal.type == "objective" then
        if not IsPositiveInteger(goal.questID) or not IsPositiveInteger(goal.index) then
            return nil, "step " .. stepID .. " objective goal " .. goalIndex .. " needs questID and index"
        end
        clean.questID = goal.questID
        clean.index = goal.index
        clean.count = IsPositiveInteger(goal.count) and goal.count or 1
    else
        return nil, "step " .. stepID .. " uses unsupported goal type " .. tostring(goal.type)
    end

    return clean
end

function ns.GuideValidation:Validate(definition)
    if type(definition) ~= "table" then
        return nil, "guide must be a table"
    end
    if not IsStableID(definition.id) then
        return nil, "guide id must be a stable string (letters, digits, dot, underscore, hyphen)"
    end
    if not IsString(definition.title, 160) or definition.title == "" then
        return nil, "guide title is required and must be 160 characters or fewer"
    end
    if type(definition.steps) ~= "table" or #definition.steps == 0 or #definition.steps > 500 then
        return nil, "guide must contain 1 to 500 ordered steps"
    end

    local version = definition.version or "1"
    if not IsString(version, 40) or version == "" then
        return nil, "guide version is required and must be 40 characters or fewer"
    end

    local normalized = {
        id = definition.id,
        title = definition.title,
        version = version,
        flavor = definition.flavor or "forever",
        steps = {},
        stepIndexes = {},
    }

    if normalized.flavor ~= "forever" then
        return nil, "guide flavor must be forever"
    end

    for index, step in ipairs(definition.steps) do
        if type(step) ~= "table" or not IsStableID(step.id) then
            return nil, "step " .. index .. " must have a stable id"
        end
        if normalized.stepIndexes[step.id] then
            return nil, "duplicate step id " .. step.id
        end
        if not IsString(step.text or "", 1200) then
            return nil, "step " .. step.id .. " text must be 1200 characters or fewer"
        end
        if step.goals ~= nil and (type(step.goals) ~= "table" or #step.goals > 100) then
            return nil, "step " .. step.id .. " may have at most 100 goals"
        end
        if step.goalMode ~= nil and step.goalMode ~= "all" and step.goalMode ~= "any" then
            return nil, "step " .. step.id .. " goalMode must be all or any"
        end

        local cleanStep = {
            id = step.id,
            text = step.text or "",
            goalMode = step.goalMode or "all",
            goals = {},
        }

        for goalIndex, goal in ipairs(step.goals or {}) do
            local cleanGoal, err = ValidateGoal(goal, step.id, goalIndex)
            if not cleanGoal then
                return nil, err
            end
            cleanStep.goals[#cleanStep.goals + 1] = cleanGoal
        end

        normalized.stepIndexes[cleanStep.id] = index
        normalized.steps[index] = cleanStep
    end

    return normalized
end

function ns:RegisterGuide(definition)
    local guide, err = self.GuideValidation:Validate(definition)
    if not guide then
        return false, err
    end
    if self.Guides[guide.id] then
        return false, "guide id already registered: " .. guide.id
    end

    self.Guides[guide.id] = guide
    return true
end
