# WildQuest guide format (prototype)

This format is original WildQuest data. It uses a declarative Lua table and does not execute guide-supplied code. Guide registration runs schema validation before a guide can be selected.

## Current runtime behavior

- Guides are registered with ns:RegisterGuide(definition).
- Guide and step IDs are stable strings; progression saves IDs per character.
- Steps run in listed order. A step advances automatically when its goals satisfy goalMode; /wq next lets the player deliberately skip.
- An empty goals list is a manual step and does not auto-advance.
- Supported goal types: manual, quest_active, quest_ready, quest_turned_in, objective.
- goalMode may be all (default) or any.
- The current build has no authored leveling route registered yet. The sample below is a schema illustration only; quest ID 12345 is a placeholder, not verified Forever data.

## Example definition

~~~lua
local _, ns = ...

ns:RegisterGuide({
    id = "example.route",
    title = "Example route",
    version = "1",
    flavor = "forever",
    steps = {
        {
            id = "start",
            text = "Accept the selected quest.",
            goals = {
                { type = "quest_active", questID = 12345 },
            },
        },
        {
            id = "finish-objectives",
            text = "Complete the first objective.",
            goals = {
                { type = "objective", questID = 12345, index = 1, count = 1 },
            },
        },
        {
            id = "turn-in",
            text = "Turn in the quest.",
            goals = {
                { type = "quest_turned_in", questID = 12345 },
            },
        },
    },
})
~~~

## Generated active-quest guide

Use /wq quest <active quest ID or exact title> to create a temporary guide for a quest already in the log. It builds one goal step per objective exposed by the client, then a turn-in step. If objective details are unavailable, it falls back to a quest-ready step. The guide uses the native quest title/objective text when available and can query QuestieDB for a missing title.

Generated guides are in-memory registrations; they are not persisted as definitions. The selected generated guide ID and step ID are persisted per character. After reload, a generated definition is not present, so the saved selection is cleared safely until a new generated guide is created. Objective schemas vary by quest/client; generated steps remain advisory and may require /wq next when the client does not expose a completion count.

This feature is not a replacement for authored leveling routes. It exercises the guide engine against live quest-log state without embedding QuestieDB rows or copying third-party guide text.

## Validation rules

- Guide IDs and step IDs: 1–80 characters using letters, digits, dot, underscore, or hyphen.
- Guide title: required, maximum 160 characters.
- Guide flavor: forever.
- Guide size: 1–500 steps; maximum 100 goals per step.
- Step text: maximum 1,200 characters; manual-goal text: maximum 300.
- Quest IDs, objective indexes, and objective counts must be positive integers.
- Unsupported goal types, duplicate step IDs, duplicate guide IDs, and invalid goal modes are rejected.
- Unknown fields are ignored by the current validator; do not rely on them until the schema is extended.

## Objective data limits

Current objective completion reads the native quest log. Data may be unavailable while the client is loading or for unsupported quest types; unknown data remains incomplete. The initial API normalizer currently uses numFulfilled, numRequired, and finished when exposed by the client. Before authored routes depend on these fields, verify their shape against the live Forever client and add diagnostics for unavailable values.

QuestieDB can provide optional names and static relations, but it does not decide whether this character has accepted, completed, or turned in a quest. Runtime state remains in QuestState.
