# WildQuest

WildQuest is a standalone questing and character helper for WoW Forever client 1.60.1 (interface 16001). It does not require Questie, QuestieDB, or another addon.

## Current development build: 0.1.0-alpha.15

Alpha.14 adds an explicit guide-step catch-up override. Use **Skip step** in the tracker or `/wq skip` (also `/wq next`) to move past a guide step the character has already completed or does not need. The choice persists per character and guide, is labeled as skipped, and is not recorded as quest completion. `/wq reset` clears those overrides for the current guide. Selecting a guide starts at an unfinished quest already present in the live quest log when one is found; unobserved history is never silently treated as complete.

The personal install bundle contains a standalone Forever quest database and a 334-pack ordered route index (7,049 quest steps) assembled from the supplied RXP and Zygor route coverage. Route names, quest facts and ordering are generated for WildQuest; third-party prose and scripts are not bundled. The full data payload is intentionally absent from this public repository because its upstream redistribution rights have not been cleared.

See [the Forever guide source inventory](research/forever-guide-source-inventory.md) for available guide archives, additional Forever sources, and the current import status. The current merged catalog is still based on the earlier RXP/Zygor cross-reference; newly supplied FlowUp, ForeverQuest, and ForeverGuide archives have not yet been fully parsed and integrated.\n\n## Included addon features

- Guide browser, compact tracker pane, detachable quick-button pane, minimap access and waypoint arrow
- Live quest/objective tracking and active-quest catch-up routing
- XP observations, equipped gear audit, talent snapshots, wallet/session tracking, Auction House scan and profession skill display

## Work still in progress

- This is not a LevelForge source-code port. The supplied uploads include FlowUp, ForeverQuest and Forever Guide, but no LevelForge addon archive. This branch implements WildQuest-owned catch-up behavior while source access is resolved.
- The route catalog is an ordered index, not finished narrated leveling or dungeon guides. Original directions, travel details, objective-specific map points and dungeon walkthrough content are incomplete.
- Gear stat weights, talent recommendations and recipe planning are not implemented.
- WoW Forever API behavior has not been live-tested in this environment.

## Install

The public source ZIP is not a complete install package because it omits the private database and route data. For the current personal all-in-one build, use the separately supplied `WildQuest-0.1.0-alpha.14-Forever.zip`, extract its `WildQuest` folder into `Interface/AddOns`, and leave Questie/QuestieDB disabled.

## Research

- [Standalone addon design](research/architecture/standalone-addon-design.md)
- [Leveling foundation and source review](research/audits/leveling-addon-foundation-review.md)
- [Research index](research/README.md)
