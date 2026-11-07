local _, ns = ...
-- The public source omits the personal full database payload. Replace this file in the private install bundle.
ns.BundledDatabase = {
    format = "WildQuestDB",
    schemaVersion = 1,
    summary = { Quest = { rows = 0 }, Npc = { rows = 0 }, Object = { rows = 0 }, Item = { rows = 0 } },
    entities = { Quest = {}, Npc = {}, Object = {}, Item = {} },
}

