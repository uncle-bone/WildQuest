# WildQuest

WildQuest is a questing addon for WoW Forever, informed by research into RestedXP, Zygor Forever, Questie, QuestieDB, and QuestieTrace.

## First live-test build: 0.1.0-alpha.3

This is an early, installable test build, not a 1.0.0 release. It provides:

- A movable tracker showing location, character level, active quests, selected guide step, and up to two objectives per quest.
- Persistent per-character progress for a selected guide.
- `/wq quest <active quest ID or exact title>` to create a temporary objective and turn-in guide from the live quest log.
- `/wq quests` and `/wq status` for quest and addon status.
- Dungeon/raid context detection, while preserving the selected guide when entering or leaving an instance.
- Session XP observations: XP-bar changes are labeled unattributed; combat XP chat messages are separately tallied. WildQuest does not infer that a gray quest or mob gives zero XP.
- Optional QuestieDB contract-4 quest-name lookup when a compatible QuestieDB provider is present.

### Known limits for this test

No original leveling or dungeon route pack is included yet. This build does not import RXP/Zygor guide text, does not yet build a verified complete quest-prerequisite graph, does not auto-skip route steps, and does not prove whether a particular quest or mob awarded XP. The active quest tracker and generated quest guide are the first client-side baseline; route selection, prerequisite-aware catch-up, and original dungeon guide content will be developed from live feedback and validated data.

The addon source has not yet been verified in the live WoW Forever client. Treat this build as an initial test and report any Lua errors, missing objectives, or display issues.

## Install

Download the [WildQuest source ZIP](https://github.com/uncle-bone/WildQuest/archive/refs/heads/main.zip) and extract it. Rename the extracted `WildQuest-main` folder to `WildQuest`, then place that folder in the Forever client's `Interface/AddOns` directory. Enable WildQuest in the AddOns list.

In game, type `/wq help`. Use `/wq quests` to see active quest IDs and titles, then `/wq quest <ID or exact title>` to create a temporary guide for a quest currently in your log.

## Research

- [Research index](research/README.md)
- [Audit coverage and package inventory](research/audit-coverage.md)
- [RestedXP audit](research/audits/restedxp.md)
- [Zygor Forever audit](research/audits/zygor-forever.md)
- [Questie and QuestieDB audit](research/audits/questie-questiedb.md)
- [QuestieTrace audit](research/audits/questietrace.md)
- [WildQuest architecture proposal](research/architecture/wildquest-design-map.md)
- [Detailed Questie runtime/database map](research/audits/questie-runtime-map.md)
- [RestedXP and Zygor runtime comparison](research/audits/guide-runtime-comparison.md)
- [Uploaded route-set inventory and architecture](research/audits/route-data-architecture.md)
- [Source manifest, fingerprints, and update protocol](research/sources.md)

The audits describe the uploaded builds. Third-party guide text, artwork, and database payloads are not mirrored into this repository; see the audits for provenance and licensing notes.
