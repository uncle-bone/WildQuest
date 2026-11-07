# WildQuest source inputs

The uploads below are research inputs, not runtime dependencies. The public repository contains original WildQuest runtime code and empty placeholders for private data. The personal install package includes the generated quest facts, route order, and navigation map lookup.

| Input | Library file ID | Purpose |
|---|---|---|
| Combined Questie/RXP/Zygor archive | libfile_d60485d843508191b998bc12868d09a4 | Quest facts and route coverage research |
| QuestieDB archive | libfile_8a8635c339c08191998e2ce8e6cf197c | Quest metadata and prerequisites |
| RXPGuides archive | libfile_8a25af7bcb9881919d58a986af654f1f | Route coverage research |
| Zygor Forever archive | libfile_f0a57ab9b6d08191a98b13d6e315b11c | Route coverage research |
| Latest combined archive | libfile_cf9acd9e6bbc8191802cd16159699708 | Combined source ZIP used for extraction |
| Private extraction bundle | libfile_2d370265601c8191b69c71e42c8ec802 | Normalized facts, source inventory, and route-ID coverage |
| WildQuest alpha.9 ZIP | libfile_5830706f3aec81918d6e73f4dfb6b8fb | Earlier standalone build |
| WildQuest alpha.10 ZIP | libfile_23413ff3e8dc81919b7c23f98e911ac2 | Earlier standalone build |
| WildQuest alpha.11 ZIP | libfile_34c18d0f92288191b1d771b200788911 | Auction event/startup fix |
| WildQuest alpha.12 ZIP | libfile_fd77ecb4bb648191bcd702ee556ff538 | Split guide tracker, quick buttons, options panel, and destination arrow |

## Extracted research

The normalized Forever database contains 5,233 quests, 13,417 NPCs, 7,045 objects, and 21,442 items. Parsed route coverage included 22 RXP Forever files (2,691 unique quest-action IDs) and 19 Zygor guide files (2,726 unique IDs), with 2,293 IDs shared. These are coverage counts, not a validation of route correctness.

Alpha.12 contains 334 synthesized route packs based on 585 quest-bearing guide sections and 3,347 distinct route quest IDs. Sixty-one packs include route coverage from both sources. Fifty-three route IDs are not present in the normalized quest database snapshot. The packs store quest order and WildQuest-generated metadata, not original route scripts or prose.

## Rights and distribution boundary

The uploaded QuestieDB archive notes historic contributions whose redistribution rights may be unclear. RXP declares CC BY-NC-SA 4.0, and Zygor guide content is not copied. The full normalized facts and generated route/map data are therefore kept out of this public repository. The personal ZIP is not attached as a public GitHub release.

## Scope

Alpha.12 adds the three-window questing layout: compact route tracker and detachable quick controls on the left, movable destination arrow, and route/options panel on the right. Navigation uses bundled NPC/object/item-drop coordinates and an area-to-UI-map lookup. When the map or coordinate APIs do not provide a usable target, the arrow shows the zone or unavailable state.

The private build remains an alpha and has not been verified in the WoW Forever client in this session.
