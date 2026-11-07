# WildQuest

WildQuest is a standalone questing addon for WoW Forever (client 1.60.1 / interface 16001). Its runtime reads quest facts from WildQuest's own bundled database and the character's live quest log. It does not load or query Questie, QuestieDB, or any other addon.

## Current development build: 0.1.0-alpha.9

This build removes the Questie/QuestieDB runtime integration and adds an internal database provider. The personal install package includes bundled Forever quest, NPC, object, and item facts (5,233 quests, 13,417 NPCs, 7,045 objects, 21,442 items). `/wq route` builds a catch-up route from quests already in the live quest log; quest detail lookup, prerequisites, and giver coordinates come from WildQuest's own data. The draggable minimap button and XP observations remain available.

The source repository's `Data/QuestDB.lua` is an empty public placeholder. The full generated database stays in the owner's private/local install package because the uploaded QuestieDB source warns that historical contributions may not have clear redistribution rights. The public repository is therefore the addon source, not the full personal install package.

## Still in development

WildQuest is not a complete leveling or dungeon guide product yet. It still needs original authored leveling and dungeon route packs, character-aware route selection and safe chain-aware skipping, a player-confirmed catch-up/override flow for unknown quest history, useful in-game navigation/map pins, and live verification on WoW Forever. Quest chains preserve OR (`preQuestSingle`) versus AND (`preQuestGroup`) semantics; unknown quests are never silently marked completed. Route-source IDs are only coverage signals and no RXP/Zygor route prose or scripts are included.

## Commands

- `/wq` opens or hides the tracker.
- `/wq route` builds a catch-up route from active quests.
- `/wq quest <ID or title>` opens a guide for an active quest.
- `/wq quests`, `/wq guides`, `/wq status`, `/wq dungeon`, `/wq xp`, `/wq next`, `/wq reset`, and `/wq minimap` provide tracker controls and status.

## Install

Use the private `WildQuest-0.1.0-alpha.9-Forever.zip` install package from the owner's Library for the self-contained build with bundled data. Extract its `WildQuest` folder into `Interface/AddOns`. Do not install or enable Questie or QuestieDB for WildQuest.

## Research

- [Standalone addon architecture](research/architecture/standalone-addon-design.md)
- [Source inputs and extraction summary](research/library-source-manifest.md)
- [Research index](research/README.md)

The research notes document source provenance. Third-party guide scripts, prose, and assets are not bundled.

