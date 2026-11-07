# Audit coverage and package inventory

Inspection date: 2026-11-07. All counts below were computed from the exact user-provided archives identified in [sources.md](sources.md). Counts include bundled dependencies, assets, and content unless a narrower folder is named. They describe package scope, not files independently read line by line.

## Package inventory

| Package | Total files | Main inventory observations |
|---|---:|---|
| RestedXP Guides | 1,406 | 1,039 Lua, 78 XML, 214 files under Guides, 52 under DB, 734 under lang, 81 under libs, 278 under Textures |
| Zygor Guides Viewer Forever | 836 | 406 Lua, 54 XML, 222 files under Guides-Forever, 20 under Code-Forever, 24 under Data-Forever, 161 under Libs, 14 under Libs-Forever, 223 under Skins |
| Questie | 531 | 358 Lua, 207 under Modules, 38 under Database, 61 under Localization, 97 under Libs, 5 under Public |
| QuestieDB | 64 | 58 Lua; 42 source files under src, 9 support files, 7 type declaration files |
| QuestieTrace | 46 | 38 Lua; 35 files under Modules, plus TOCs, UI/XML and bundled libraries |

## First-party architecture areas reviewed

### RestedXP

- TOC/game-flavor selection, initialization/SavedVariables and Forever XML manifests.
- Guide registration, parser/import/cache lifecycle and guide-step runtime.
- GuideWindow event binding, objective completion and persisted progression.
- Quest log reconciliation, targeting, map pins/arrow, communications.
- Forever data manifest and sample guide category inventory.
- Reviewed key files include RXPGuides.lua, GuideLoader.lua, GuideWindow.lua, functions.lua, QuestLog.lua, map.lua, Targeting.lua, Communications.lua, and DB/forever.xml.

### Zygor Forever

- Root TOC and files-Forever.xml load order.
- Guide/Step/Goal/Parser/QuestTracking and quest-chain helper boundaries.
- Pointer, route/taxi libraries and Forever pointer-map integration.
- Data-Forever manifest and guide-category inventory.
- Reviewed key files include ZygorGuidesViewer.lua, Guide.lua, Step.lua, Goal.lua, Parser.lua, QuestTracking.lua, QuestDB.lua, Code-Forever/QuestDB.lua, Pointer.lua, Code-Forever/PointerMap.lua, NotificationCenter.lua and Data-Forever/data.xml.

### Questie and QuestieDB

- Forever TOC ordering, compatibility layer, staged initialization and public API readiness.
- Quest log cache/events/lifecycle, availability filtering, map queues/waypoints, tracker, Journey, options, party comms, and helper modules.
- QuestieDB config/flavor contract, type declarations, metadata/schema, baked reader, normalization, corrections registry, localization, provenance and support modules.
- Baked data inventory counted by entity prefix in QuestieDB_Forever.toc; count method and limitations are documented in the Questie audit.

### QuestieTrace

- Forever TOC/load order; consent state and capture lifecycle.
- Tracker modules and event categories; chat sanitization; SavedVariables recovery/encoding and retention.
- Export payload construction, scrub pass, codec, preview/stat display, manual handoff and post-report deletion.
- Reminder and dump/map hierarchy modules.

## Forever data and guide-category inventory

### RestedXP

The Forever DB manifest loads shared database helpers plus Forever flight data, quest data, spells, rares, core database records, dangerous-mob records, stat weights and spirit-healer data, then shared quest DB logic. The Forever guide manifest contains 13 non-dungeon route files (starter/level ranges, faction paths, mage paths and a Skyborne route) plus 9 dungeon-variant files. The build also includes Survival Guide and general Classic guide groups. This is an inventory of content classes only; the actual copyrighted route text is not reproduced.

### Zygor Forever

The Forever data manifest loads NPC/object models, NPC data, trade-skill recipes/status, skill training, Foglight, quest DB tables/season data, dungeons, phases, XP tables, item stat weights and route caches for both factions. The guide autoload manifest organizes content into neutral/Alliance/Horde includes, leveling, dailies, dungeons, gear, professions, pets/mounts, titles, reputations, events, gold farming/gathering/runs, points of interest and talent builds. The 222-file Guides-Forever inventory includes guide material and image support; guide scripts themselves are not copied or summarized step by step.

### QuestieDB support and corrections

The baked Forever provider includes support payload folders for classic item drops/corrections, faction templates, Quest XP, and zone mappings (AreaID↔UiMapID, instance↔AreaID, subzone↔parent zone, dungeon list). Questie itself layers in quest/NPC/item blacklists, policy corrections, phase rules, holiday quest data, daily quest rules, drop tables and manual correction files. Those are runtime policy/correction layers, not interchangeable base entity rows.

## Remaining limits

This is a source architecture and execution-path audit, not a certification of every bundled library, every localization entry, every authored route, or every generated database record. The large content sets were inventoried and their schemas/interfaces inspected; rows and guide steps were not individually quality-scored. Static review does not prove runtime compatibility on the live Forever client. Those boundaries prevent the notes from overstating what “front to back” means.

For WildQuest implementation, revisit a specific reference function/file when adopting a behavior, verify current rights before reusing code/content, and validate target-client behavior independently.
