# WildQuest source inputs

The source archives below are maintained in the owner's ChatGPT Library. They are research inputs, not part of the public WildQuest install package. Do not copy third-party guide prose or the full Questie database into this public repository without confirming distribution rights.

| Input | Library file ID | Purpose |
|---|---|---|
| Questie-RXPGuides-Zygor.zip | `libfile_d60485d843508191b998bc12868d09a4` | Combined source archive used for quest facts and route-coverage research |
| QuestieDB archive | `libfile_8a8635c339c08191998e2ce8e6cf197c` | Quest metadata and prerequisite research |
| RXPGuides archive | `libfile_8a25af7bcb9881919d58a986af654f1f` | Route coverage research |
| Zygor Forever archive | `libfile_f0a57ab9b6d08191a98b13d6e315b11c` | Route coverage research |
| Latest combined archive | `libfile_cf9acd9e6bbc8191802cd16159699708` | Latest uploaded Questie/RXP/Zygor source ZIP, used for the 2026-11-07 extraction |
| Private extraction bundle | `libfile_2d370265601c8191b69c71e42c8ec802` | Normalized QuestieDB Forever data, source inventory, and parsed route-ID coverage; owner Library only |

## 2026-11-07 extraction summary

The uploaded combined archive contained 2,881 non-empty files across Questie, QuestieDB, QuestieTrace, RXP Guides, and Zygor Forever. QuestieDB Forever v1.0.12 / contract 4 yielded 5,233 quests, 13,417 NPCs, 7,045 objects, and 21,442 items. The route parser found 22 RXP Forever Lua files (2,691 unique quest-action IDs) and 19 Zygor Forever guide files (2,726 unique IDs), with 2,293 IDs shared. These are source-coverage figures, not a validation of guide correctness or complete authored WildQuest routes. Earlier notes used a narrower parser and reported different figures.

The private extraction bundle is not committed here because the QuestieDB archive warns some historical contributions may not have explicit redistribution rights. RXP's archive declares CC BY-NC-SA 4.0; Zygor guide content must not be copied into WildQuest. The public repository records provenance and summary counts only.

## Runtime requirement

WildQuest's goal is all-in-one and must not require Questie or QuestieDB to be loaded. Quest data included in WildQuest must be independently packaged and must not require these external addons at runtime. Until a distributable, provenance-reviewed data bundle and complete authored guides are available, do not claim full quest database coverage or complete authored routes.

Route-ID coverage may inform original WildQuest-authored content. Do not copy source route scripts or prose verbatim.
