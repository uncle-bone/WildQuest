# WildQuest

WildQuest is a questing addon for WoW Forever, informed by research into RestedXP, Zygor Forever, Questie, QuestieDB, and QuestieTrace.

## Live-test build: 0.1.0-alpha.5

The in-game window has **My Quests** and **Guide** pages. Click an active quest to create and open an objective-by-objective guide from the live quest log. The guide tracks quest state, shows progress, and supports manual previous/next controls. When QuestieDB contract 4 is available, the guide can also show quest levels, prerequisite IDs, and quest-giver coordinates. The objective list and level-aware route suggestions use the character's current state. The panel shows world or dungeon context.

XP bar changes are tracked as unattributed XP; combat XP chat messages are tallied separately. WildQuest does not infer that a gray quest or mob gives no XP.

This remains an early alpha, not a 1.0.0 release. It does not yet include authored leveling/dungeon route packs, a complete character-specific prerequisite evaluator, map pins/navigation, or automatic safe skipping. Reference addon routes are being used to shape original WildQuest data and runtime behavior; their guide scripts and prose are not copied into this repository. WoW Forever client behavior still needs live verification.

## Install

Download the [WildQuest source ZIP](https://github.com/uncle-bone/WildQuest/archive/refs/heads/main.zip), extract it, rename the folder to `WildQuest`, and place it in the Forever client's `Interface/AddOns` folder. Enable WildQuest.

Type `/wq` to open the quest list. Click an active quest to open its guide. Use `/wq help` for commands; `/wq xp` shows XP observations.

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

The audits describe the uploaded builds. Third-party guide text, artwork, and database payloads are not mirrored into this repository; see audits for provenance and licensing notes.
