# WildQuest

WildQuest is a standalone WoW Forever questing addon (client 1.60.1 / interface 16001). It uses its own bundled quest facts and route records; it does not require Questie or QuestieDB.

## Current personal build: 0.1.0-alpha.12

The private install ZIP includes the bundled database and generated route catalog. This public repository contains only the runtime code and empty private-data placeholders.

## Questing layout

Alpha.12 introduces three separate, movable questing windows:

- **Guide tracker at the left:** current route, step, live quest objective progress, and next/previous controls.
- **Quick button strip above it:** expand quest-item details, toggle destination tracking, and open the options panel. The strip can be dragged separately.
- **Destination arrow near the bottom:** points toward the current quest objective or turn-in when the bundled coordinates and client map APIs are available. The arrow is independently movable.
- **Options panel at the right:** guide library, quests, gear, talents, gold/AH, and profession pages.

Use /wq to show or hide the left guide tracker, /wq guides to browse routes, and /wq menu to open the options panel. The minimap button opens the guide tracker.

## Data and route coverage

The private route catalog contains 334 synthesized packs based on 585 quest-bearing sections parsed from RXP and Zygor Forever sources, with both-source coverage in 61 packs. It stores ordered quest IDs and WildQuest-generated metadata; it does not include the original guide scripts, prose, or artwork. Fifty-three route IDs are absent from the bundled database snapshot.

The source archives are not copied into this public repository. The uploaded QuestieDB archive notes that some historical contributions may have unclear redistribution rights. The private build is for the owner's personal use; do not redistribute it.

## Other tools and limits

WildQuest also includes quest tracking, XP observations, gear audit, talent snapshots, wallet/session tracking, an Auction House scan when the client exposes the required API, and profession skill display. Stat-weight upgrades, talent build recommendations, recipe planning, market history, and map overlays beyond the destination arrow are not included. The alpha.12 layout and arrow have not yet been verified in the WoW client.

See [standalone architecture](research/architecture/standalone-addon-design.md) and [source manifest](research/library-source-manifest.md).
