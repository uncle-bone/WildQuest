# WildQuest source inputs

The source archives below are maintained in the owner's ChatGPT Library. They are research inputs, not part of the public WildQuest install package. Do not copy third-party guide prose or the full Questie database into this public repository without confirming distribution rights.

| Input | Library file ID | Purpose |
|---|---|---|
| Questie-RXPGuides-Zygor.zip | `libfile_d60485d843508191b998bc12868d09a4` | Combined source archive used for quest facts and route-coverage research |
| QuestieDB archive | `libfile_8a8635c339c08191998e2ce8e6cf197c` | Quest metadata and prerequisite research |
| RXPGuides archive | `libfile_8a25af7bcb9881919d58a986af654f1f` | Route coverage research |
| Zygor Forever archive | `libfile_f0a57ab9b6d08191a98b13d6e315b11c` | Route coverage research |
| Latest combined archive | `libfile_cf9acd9e6bbc8191802cd16159699708` | Latest uploaded Questie/RXP/Zygor source ZIP used for extraction |
| Private extraction bundle | `libfile_2d370265601c8191b69c71e42c8ec802` | Normalized database facts, source inventory, and parsed route-ID coverage |
| Standalone personal install build | `libfile_5830706f3aec81918d6e73f4dfb6b8fb` | WildQuest alpha.9 with bundled internal quest data; owner Library only |

## 2026-11-07 extraction and standalone build

The combined archive contained 2,881 non-empty files across Questie, QuestieDB, QuestieTrace, RXP Guides, and Zygor Forever. QuestieDB Forever v1.0.12 / contract 4 yielded 5,233 quests, 13,417 NPCs, 7,045 objects, and 21,442 items. Parsed route coverage: 22 RXP Forever files (2,691 unique quest-action IDs), 19 Zygor Forever files (2,726 unique IDs), and 2,293 IDs shared. These counts indicate source coverage, not route correctness or completeness.

WildQuest alpha.9 removes Questie/QuestieDB from OptionalDeps and the runtime provider. The addon now reads from its own bundled Lua data. The public repository includes a blank database placeholder; the private install build replaces that file with the full normalized Forever data.

The full dataset is kept out of public GitHub because the QuestieDB archive warns that some historical contributions may lack explicit redistribution rights. RXP declares CC BY-NC-SA 4.0. No RXP/Zygor route scripts or prose are copied.

## Remaining development

The standalone runtime/data packaging is in place, but authored leveling and dungeon route packs, safe player-confirmed catch-up overrides, chain-aware route selection and skips, and useful map navigation still need implementation. Do not describe this alpha as a complete guide product or live verified.
