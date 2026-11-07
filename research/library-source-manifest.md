# WildQuest source inputs

The archives below are research inputs, not runtime dependencies. Do not copy third-party guide prose or the full QuestieDB-derived database into this public repository; the private install package contains generated route order and normalized data for the owner's personal use.

| Input | Library file ID | Purpose |
|---|---|---|
| Questie-RXPGuides-Zygor.zip | `libfile_d60485d843508191b998bc12868d09a4` | Combined source archive used for quest facts and route coverage |
| QuestieDB archive | `libfile_8a8635c339c08191998e2ce8e6cf197c` | Quest metadata and prerequisite research |
| RXPGuides archive | `libfile_8a25af7bcb9881919d58a986af654f1f` | Route coverage research |
| Zygor Forever archive | `libfile_f0a57ab9b6d08191a98b13d6e315b11c` | Route coverage research |
| Latest combined archive | `libfile_cf9acd9e6bbc8191802cd16159699708` | Uploaded Questie/RXP/Zygor archive used for extraction |
| Private extraction bundle | `libfile_2d370265601c8191b69c71e42c8ec802` | Normalized facts, source inventory, and parsed route coverage |
| WildQuest alpha.9 personal build | `libfile_5830706f3aec81918d6e73f4dfb6b8fb` | Earlier standalone build |
| WildQuest alpha.10 personal build | `libfile_23413ff3e8dc81919b7c23f98e911ac2` | Previous standalone install ZIP |\n| WildQuest alpha.11 personal build | `libfile_34c18d0f92288191b1d771b200788911` | Current startup-fix install ZIP; owner Library only |

## Extracted input summary

The combined archive contained Questie/QuestieDB, RXP Guides, and Zygor Forever data. The normalized Forever snapshot contains 5,233 quests, 13,417 NPCs, 7,045 objects, and 21,442 items. Parsed route coverage included 22 RXP Forever files (2,691 unique quest-action IDs) and 19 Zygor guide files (2,726 unique IDs), with 2,293 IDs shared. These are source coverage counts, not proof of route quality.

WildQuest alpha.11 contains 334 synthesized route packs derived from 585 quest-bearing guide blocks and 3,347 distinct route quest IDs. Sixty-one packs include both-source coverage. The catalog covers leveling, dungeons, events, professions, and reputations. It stores quest ordering and WildQuest-generated metadata, not source scripts or prose. Fifty-three route IDs are missing from the normalized database snapshot and may be shown without bundled facts.

## Distribution boundary

The public repository contains the runtime code and empty data placeholders. The personal alpha.10 ZIP includes the private generated quest facts and route ordering. It is not attached to a public GitHub release because the uploaded QuestieDB archive notes historic contributions with unclear redistribution rights; RXP declares CC BY-NC-SA 4.0, and Zygor content is not copied.

## Product scope

Alpha.11 removes the Questie/QuestieDB runtime dependency. It includes route browsing/tracking, live objectives and prerequisite details, gear audit, talent snapshots, wallet/session tracking, an Auction House search snapshot, and profession skill display. These character tools are a foundation, not full Zygor-equivalent stat-weight, talent-planning, recipe, or market-history systems. The addon has not been verified in the WoW Forever client in this session.