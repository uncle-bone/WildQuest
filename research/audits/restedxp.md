# RestedXP Guides — source audit

## Audited package

User-provided clean RXPGuides archive. Its TOC identifies build v4.11.34-6-g8c13da7, interface 16001, and Forever/Camelot support. Exact SHA-256 and archive name are in [sources.md](../sources.md). Review focused on addon architecture and Forever integration, not every bundled library or guide sentence.

## Architecture and startup

The TOC separates shared runtime, UI/localization/settings, game-flavor data, helper systems, and guide lists. Important modules include RXPGuides.lua, GuideLoader.lua, GuideWindow.lua, functions.lua, QuestLog.lua, map.lua, Targeting.lua, LevelingTracker.lua, InventoryManager.lua, Talents.lua, and Communications.lua. Forever XML/data and GuideList-forever.xml select game-specific content. The package also carries extensive localized text, guide and image sets.

Initialization creates AceDB state and runtime services, then loads guides progressively. Embedded registrations are queued until initialization; guide parsing is spread over frames to avoid one large startup stall. Guide metadata/progress migration is centralized. Account/profile state includes RXPData, RXPDB, RXPSettings and RXPString; per-character state includes RXPCData, tracking, communications and settings.

## Guide language and parsing

Guides are authored as text with step markers, tags and conditions. The parser turns each step into elements; tags map to handler functions. Concepts include quest accept/turn-in/completion, coordinates, NPC/object/loot objectives, text and conditional branches. Conditions are evaluated against character/game state. Imported guide text is decoded/decompressed, integrity checked, parsed in bounded chunks and cached with metadata.

This is an effective content/runtime separation: author-readable instructions compile into objective records. For WildQuest, adopt the architecture only. Define a smaller original schema with explicit types and validation; avoid permissive string evaluation or executable imported content.

## Progression and objective events

GuideWindow binds active-step objective elements to the events or update handlers they need. Event handlers update completion state; a watcher coordinates active objective tags. Step completion considers visible/active elements, sticky steps, completion dependencies and saved skips. Advancing saves guide/step progress, resets transient objective state, releases old frames, binds the new step and refreshes presentation.

Quest tracking combines quest-log APIs and game events to reconcile objective counts. QuestLog augments the standard log with guide references and scans guide chains to estimate relevant quests. The Forever-specific path accounts for the larger quest-log limit than older Classic. The game quest log and observed events should remain authoritative where available.

## Map, arrow, route and communication

map.lua and bundled mapping helpers own map pins and waypoint display. The arrow uses player position/facing and destination coordinates to derive direction and distance. Map updates are queued or gated, pins/lines are pooled, and visible pins refresh as objectives/map state change. Separate coordinate data from rendering and avoid repeated full map rebuilds.

Communications.lua provides group-oriented guide status/step sharing and announcements through AceComm/AceSerializer. It is not a general quest-record synchronization database. Guide sharing and factual-data sharing require separate protocols, validation and user controls.

## WildQuest patterns

- Parse guide content into validated step/object records before display.
- Bind only active-step event handlers and unregister them on exit.
- Persist stable guide/step identifiers, not transient widget state.
- Use incremental parsing/loading and pooled map widgets.
- Keep objective detection, route selection and UI rendering separate.
- Make imports versioned, integrity checked, bounded and non-executable.

## License/content boundary

The uploaded package includes copyrighted guide writing, assets and libraries with their own licenses. Its LICENSE states CC BY-NC-SA 4.0 for covered work; this is not blanket permission for commercial reuse or redistribution. Do not copy routes, wording, icons, textures or source into WildQuest without compatible terms and provenance review. This audit is an architectural summary, not a license grant.

## References

- [RestedXP Guides source](https://github.com/RestedXP/RXPGuides)
- [RestedXP website](https://www.restedxp.com/)
