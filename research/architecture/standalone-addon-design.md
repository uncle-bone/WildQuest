# WildQuest standalone architecture

## Questing UI

The UI is split into independent windows modeled on common guide-addon workflows, implemented with original WildQuest code:

1. The left guide tracker shows the active route, current step, live objective progress, and step controls.
2. A draggable quick-button strip sits above the guide tracker. It opens the step's quest-item detail and toggles the destination tracker.
3. A movable destination arrow displays a heading and distance for the current task when client position and map data are available.
4. A separate right-side options window contains the route library and character tools.

The compact guide tracker is the default entry point. /wq guides opens the route browser; /wq menu opens the complete options window. The minimap button opens the compact tracker.

## Navigation data and behavior

The private install package includes an area-to-UI-map lookup extracted from the uploaded Forever database snapshot. WildQuest maps bundled NPC/object spawn coordinates to the client's map IDs. For an inactive quest it points at a quest starter; for an active quest it points at the first incomplete objective with a known creature, object, item-drop, or event coordinate; for a completed quest it points at a turn-in. When the map or coordinates are unavailable, the arrow reports the destination zone or unavailable state rather than inventing a direction.

Player position and facing are read through the client's C_Map and unit APIs. The arrow hides its directional sprite when map-coordinate conversion is unavailable. The quick strip's target button controls the movable arrow.

## Private data and route synthesis

The private data package contains normalized quest facts and generated quest-order records. The public repository keeps those data files empty. QuestieDB's upload warns some historic contributions may not have explicit redistribution rights, and RXP/Zygor guide scripts, prose, and artwork are not copied.

The route catalog has 334 synthesized packs built from 585 quest-bearing guide sections; 61 packs include coverage from both RXP and Zygor. It records ID order, source concordance, and WildQuest metadata rather than full narrative instructions. Fifty-three route quest IDs lack facts in the bundled database snapshot.

## Runtime and prerequisites

WildQuest loads its own quest, entity, route, and private map lookup data. No Questie or QuestieDB addon is required or queried.

- preQuestSingle is OR: any one confirmed completed quest is sufficient.
- preQuestGroup is AND: all listed quests are required.
- parentQuest, level, faction, race, class, profession, reputation, and item conditions remain distinct.
- Unknown quest history is never inferred complete. Catch-up route generation starts from the active quest log.

## Feature scope

The options window includes route browsing, live quest tracking, XP observations, a gear audit, saved talent snapshots, wallet/session tracking, conditional Auction House search, and profession skill display. Full stat-weight advice, talent builds, recipe planning, persistent market trends, full route text, and full map overlays remain outside this alpha.

No WoW Forever client verification has been performed for alpha.12.
