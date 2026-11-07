# WildQuest

WildQuest is a questing addon for WoW Forever, informed by research into RestedXP, Zygor Forever, Questie, QuestieDB, and QuestieTrace.

## Live-test build: 0.1.0-alpha.7

The in-game window has **My Quests** and **Guide** pages. Use `/wq route` to assemble a catch-up route from your active quest log. It orders ready-to-turn-in quests first, then prioritizes quests found in both uploaded RXP and Zygor route sets, and keeps completed quest objectives moving automatically. The generated route uses original WildQuest text and the live quest log; QuestieDB provides optional names, levels, prerequisite facts, and giver coordinates. Click an active quest to create and open an objective-by-objective guide from the live quest log. The guide tracks quest state, shows progress, and supports manual previous/next controls. When QuestieDB contract 4 is available, the guide can also show quest levels, prerequisite IDs, and quest-giver coordinates. The panel shows world or dungeon context.

A draggable WildQuest minimap button opens and closes the tracker. Left-click opens the tracker, right-click hides the button, and `/wq minimap` toggles it back on or off. The button is shown by default.

XP bar changes are tracked as unattributed XP; combat XP chat messages are tallied separately. WildQuest does not infer that a gray quest or mob gives no XP.

This remains an early alpha, not a 1.0.0 release. The current build does not yet include full authored leveling/dungeon route packs, a complete character-specific prerequisite evaluator, map pins/navigation, or automatic safe skipping. RXP and Zygor guide coverage (2,596 RXP quest IDs, 1,743 Zygor quest IDs, 1,460 overlapping) now informs route ordering; their guide scripts and prose are not copied into this repository. QuestieDB is used as an optional source of quest metadata and prerequisite facts. WoW Forever client behavior still needs live verification.

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
