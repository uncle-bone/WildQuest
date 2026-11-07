# WildQuest standalone architecture

## Product goal

WildQuest is a self-contained WoW Forever quest tracker, leveling/dungeon guide, and character helper. It operates with WildQuest alone enabled. Quest facts, route records, and persisted preferences are stored in WildQuest. The game supplies live quest, equipment, talent, money, auction, and profession state through native APIs. No third-party addon or runtime library is queried.

## Route synthesis

The uploaded archive's route data was parsed as quest-action sequences and player availability metadata. From 104 source Lua files, WildQuest derived 585 quest-bearing guide blocks and compiled them into 334 zone/activity packs covering 3,347 distinct quest IDs. Sixty-one packs combine both RXP and Zygor route coverage. For each combined pack, WildQuest compares source sequence completeness against its bundled quest facts and AND-prerequisite ordering. Strongly agreeing paths are blended by shared quest order; conflicting paths use the higher-scoring source sequence as the base, then merge compatible extra quests. The pack stores quest IDs and WildQuest-generated metadata only. It does not store source route text or scripts.

The data snapshot does not contain 53 route quest IDs. These remain in guide order but lack bundled titles/facts unless the player's quest log supplies them. Level/race/class conditions from some source guides are not fully normalized yet; the route browser filters faction and level, while quest-level gates remain visible.

## Runtime layout

1. `Data/QuestDB.lua` loads the local bundled quest/NPC/object/item facts before the provider. The public repository has a blank placeholder; the private install replaces it with the full dataset.
2. `Data/GuidePacks.lua` loads WildQuest-generated guide records. The public placeholder is empty; the private install includes the route catalog.
3. `Core/Provider.lua` is WildQuest's internal fact lookup. It never probes other addons or contract APIs.
4. `Core/QuestState.lua` reads the current quest log and client completion flags/events. History is scoped per character.
5. `Guide/Packs.lua` registers the bundled guide catalog. `Guide/Runtime.lua` follows pack steps against quest state and persists the selected guide/step.
6. `UI/Tracker.lua` provides a wide tabbed window for home, quests, guides, current guide, gear, talents, gold/AH, and professions.

## Prerequisites and safe catch-up

- `preQuestSingle` is OR: any one confirmed completed quest is sufficient.
- `preQuestGroup` is AND: each listed prerequisite is required.
- `parentQuest` means the parent must be active; `availableStartingWith`, `availableUntilCompleted`, `disabledByQuest`, and exclusive quests remain separate constraints.
- Other gates include faction, race/class, level, profession, reputation, spell, specialization, and required source items.
- Unknown history is never inferred complete. `/wq route` starts with active quests; manual guide navigation does not rewrite completion state.

## Zygor-style feature areas

WildQuest uses an original navigation and content layout rather than Zygor assets or copied UI code. The current alpha includes an equipment audit, saved talent snapshot, current-money/session tracker, click-to-scan Auction House price lookup, and profession skill display. A complete recipe planner, defensible stat weights/upgrade recommendations, talent build advisor, persistent market trend database, and full route arrow/map overlay remain future work and need verified Forever-specific data/APIs.

## Publication boundary

Public GitHub contains runtime code, provenance notes, and high-level coverage counts. The private install package contains normalized quest facts and generated route-order data. The uploaded QuestieDB license warns that some historic contributions may not have explicit redistribution rights; RXP declares CC BY-NC-SA 4.0; Zygor source content must not be copied. Keep original guide prose, scripts, and assets out of WildQuest.
