# WildQuest

WildQuest is a questing addon for WoW Forever, informed by research into RestedXP, Zygor Forever, Questie, QuestieDB, and QuestieTrace.

## First live-test build: 0.1.0-alpha.4

This is an early, installable test build, not a 1.0.0 release. It provides a movable quest tracker, per-character guide progress, temporary guides generated from active quest objectives, dungeon/raid context, and XP observations. XP-bar changes are labeled unattributed; combat XP chat messages are tallied separately. WildQuest does not infer that a gray quest or mob gives no XP.

This build does not include original leveling or dungeon route packs, a complete verified quest-prerequisite graph, or automatic route skipping. The addon has not yet been verified in the live WoW Forever client.

## Install

Download the [WildQuest source ZIP](https://github.com/uncle-bone/WildQuest/archive/refs/heads/main.zip) and extract it. Rename the extracted `WildQuest-main` folder to `WildQuest`, then place that folder in the Forever client's `Interface/AddOns` directory. Enable WildQuest in the AddOns list.

In game, type `/wq help`. Use `/wq quests` to see active quest IDs and titles, then `/wq quest <ID or exact title>` to create a temporary guide for a quest currently in your log. Other useful commands: `/wq status`, `/wq dungeon`, and `/wq xp`.

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
