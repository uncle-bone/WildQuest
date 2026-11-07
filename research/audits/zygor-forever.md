# Zygor Guides Viewer Forever — source audit

## Audited package

User-provided ZygorGuidesViewerForever archive. The TOC reports interface 16001, version 1.6, Forever edition, and optional integrations including Cartographer and TomTom. It labels the package license GPL; this is not proof that every bundled guide, brand asset, or dependency has the same licensing status. Archive SHA-256 is in [sources.md](../sources.md).

The package contains shared code/UI, Forever-specific code and data, guide files, libraries, localization and image assets. This audit focuses on runtime boundaries and Forever integration, not every dependency or guide entry.

## Load architecture

The root TOC loads shared libraries and localization, then files-Forever.xml. That manifest selects the common guide engine/UI and Forever-specific modules/data: talent advisor, professions, QuestDB, pointer-map adjustments, item/trainer/recipe tables, routing, teleport and flight-path data.

Core modules include Guide.lua, Step.lua, Goal.lua, Parser.lua, QuestTracking.lua, Waypoints.lua, Pointer.lua, and NotificationCenter.lua. Forever-specific Code-Forever/QuestDB.lua uses quest-chain data to assess quest possibility, traverse chains/future quests, find starting points, suggest guides and skip objectives under conditions. Data files cover quests, NPCs, objects, trainers, professions/recipes, dungeons and travel.

## Guide → Step → Goal lifecycle

A Guide owns metadata, conditions, loading state, completion/status, quest references and next-guide/suggestion behavior. A Step evaluates class/race/level and other requirements, handles labels/jumps/sticky progression, and activates/deactivates goals on entry/exit. A Goal owns event registrations and completion/visited state. Goal activation registers needed events; leaving unregisters them. This lifecycle limits always-on polling and keeps objective state localized.

The parser translates guide entries and conditions into guide/step/goal records and coordinate/zone information. QuestTracking reconciles goal state with the quest log and game events. NotificationCenter supports suggestions and event-driven quest, daily, dungeon and travel prompts.

## Navigation and Forever travel

Pointer.lua owns waypoint presentation and map/taxi integration, including map/floor/phase checks, markers and route display. Forever-specific pointer code manages map settings around movement. The package includes LibRover-1.0 and LibTaxi-1.0 to model route and taxi travel. Travel choice and local objective direction are distinct concerns.

The Forever guide set includes faction/leveling, dungeons, professions, reputation, pets/mounts and gear categories. Package presence does not establish every route or datum is current for the live server.

## WildQuest patterns

- Use explicit Guide, Step and Goal lifecycle methods.
- Scope goal subscriptions to active steps and unregister on exit.
- Keep quest-chain knowledge and player-specific eligibility separate.
- Route between destinations at a higher layer; render local arrow/pin from the chosen destination.
- Store progress with stable identifiers and reconcile after loading.
- Keep suggestions/notifications in a policy module with user settings.
- Make map behavior tolerant of other map addons and restore temporary map state.

## Cautions

Although the TOC says GPL, the archive also contains guides, branded assets and dependencies with their own licenses. Do not assume the TOC applies to all content. Do not copy guide text, route sequences, images, names or bundled files into WildQuest. Any code reuse requires checking file-level licenses and complying with them. Guide data and branding are excluded from this repository.

## References

- [Zygor guide overview](https://zygorguides.com/guides/overview/)
- [Waypoint system](https://zygorguides.com/guides/waypoints/)
- [Travel system](https://zygorguides.com/guides/travel/)
- [Zygor Guides](https://zygorguides.com/)
