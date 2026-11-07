# WildQuest

WildQuest is a standalone questing and character helper for WoW Forever (client 1.60.1 / interface 16001). It uses WildQuest's own packaged data and the game's live APIs; it does not require Questie, QuestieDB, or another addon.

## Current personal build: 0.1.0-alpha.10\n\n[Download the owner-only install ZIP](https://chatgpt.com/library?file_id=libfile_23413ff3e8dc81919b7c23f98e911ac2&account_id=personal). The full data bundle is not published in this public repository.\n

The private install build contains the full bundled Forever quest database: 5,233 quests, 13,417 NPCs, 7,045 objects, and 21,442 items. It includes the redesigned navigation window, live quest tracker, route browser, XP observations, gear audit, talent snapshots, gold tracking, Auction House search, and profession overview.

The route library contains 334 WildQuest guide packs synthesized from 585 quest-bearing guide blocks across the uploaded RXP and Zygor Forever sources. It covers leveling, dungeons, events, professions, and reputations. Where both source sets cover a route, WildQuest compares their quest order and bundled quest facts, keeps the stronger sequence as the base when paths conflict, and folds in compatible quest steps. Guide instructions are generated from WildQuest's own quest facts and live quest log; third-party scripts and prose are not copied. A total of 53 route quest IDs were absent from the bundled QuestieDB snapshot and may show as ID-only until the live quest log supplies their names.

The public repository contains an empty database and guide-pack placeholder. The full data and synthesized route order remain in the owner's private install build because the QuestieDB source flags historic contributions with unclear redistribution rights and the guide ordering is derived from third-party route sets.

## In-game sections

- **Home:** character, route, quest, XP, and wallet overview with a suggested guide.
- **My Quests:** active quest list and live objective tracking.
- **Guides:** faction/level-aware route browser with zone and active-quest relevance sorting.
- **Current Guide:** ordered quest steps, live quest objectives, prerequisite AND/OR details, and bundled giver locations.
- **Gear:** equipped-slot and item-level audit; it does not invent stat weights or best-in-slot claims.
- **Talents:** read the current talent trees and save a local build snapshot; spending/respecs remain controlled by the game.
- **Gold / AH:** track wallet changes and scan the current Auction House search for lowest buyouts when the client exposes the API.
- **Professions:** show profession skill data reported by the client.

Use `/wq` to open the window, `/wq guides` to open the route browser, and `/wq route` for a catch-up route from the active quest log. `/wq help` lists commands.

## Still in development

The alpha does not yet provide tested stat-weight recommendations, a complete recipe/reagent planner, full Zygor-equivalent routing arrows/map overlays, or a robust confirmation dialog for every unknown-history quest-chain skip. OR prerequisites remain alternatives; AND groups remain required. WildQuest never silently marks an unobserved quest complete. Client compatibility and Auction House behavior still need live verification.

## Install

Use the private `WildQuest-0.1.0-alpha.10-Forever.zip` install package from the owner's Library for the full self-contained build. Extract the `WildQuest` folder into `Interface/AddOns`. Do not install or enable Questie or QuestieDB for WildQuest.

## Research

- [Standalone architecture](research/architecture/standalone-addon-design.md)
- [Source inputs and extraction summary](research/library-source-manifest.md)
- [Research index](research/README.md)

