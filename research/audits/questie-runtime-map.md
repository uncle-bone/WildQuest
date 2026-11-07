# Questie runtime and database — detailed module map

This supplements the [Questie/QuestieDB audit](questie-questiedb.md) with the actual load order and principal code paths found in the uploaded Forever build (Questie 12.6.3; QuestieDB contract 4). This remains a static source review; client behavior and all edge cases were not executed.

## Addon load order and initialization

Questie_Forever.toc intentionally loads QuestieLoader first so later module load time can be observed. QuestieProfilerPreHook follows, but is inert unless profiling is enabled. QuestieCompat loads before embedded libraries because it provides Forever/client API bridges. Version/status checks and expansion/source-mode identification precede ThreadLib and data modules.

The TOC then loads support validation and Quest XP, QuestieStream, zone/database modules, corrections/blacklists/content phases/holiday data/drop tables, localization, utility modules, and runtime subsystems. Questie.lua is explicitly last. That order matters: modules use QuestieLoader:ImportModule and depend on already-defined compatibility and data APIs.

QuestieInit exposes staged initialization. It verifies QuestieDB API/localization compatibility, preloads entity data, selects locale, initializes QuestieDB and its corrections/support data, then moves into later integrations and UI setup. It waits for a valid game cache before making availability decisions. Failure paths stop initialization and present actionable update/support errors rather than silently continuing with a partial provider.

## Data path

1. QuestieDB owns base quest/NPC/item/object records and the public LibQuestieDB access layer.
2. Questie applies its own corrections, blacklists, policy rules, content phases, holiday/daily rules and client-flavor adjustments.
3. QuestiePlayer and quest-log cache provide character/runtime state.
4. AvailableQuests combines data with level/faction/class/phase/blacklist and active-quest state, then requests map drawing.
5. Quest lifecycle updates accepted, abandoned, completed and repeatable state.
6. Map, tracker, tooltips, Journey/search and NPC menus present filtered results.

This means a raw database lookup is not equivalent to “show this quest as available now.” WildQuest should preserve that distinction and have tests/diagnostics that report which condition suppressed a point.

## Core subsystem map

### Loader, compatibility and diagnostics

- QuestieLoader creates named modules and supports imports; load timing can be observed.
- QuestieCompat wraps client APIs that differ by flavor/build, including quest log, quest-giver selection, map, bag and widget behavior.
- ThreadLib schedules chunked work for large scans, map redraws and queue processing.
- Profiler hooks/report/UI are optional diagnostics, not part of normal progression.
- VersionCheck and VersionCheckDB report addon/provider mismatch; SourceModeStatus reports the selected data mode.
- Migration upgrades saved configuration; GameVersionError/Expansions guard unsupported client assumptions.

### Quest state and lifecycle

- QuestLogCache snapshots and diffs the native quest log/objectives and handles loading-screen invalidation.
- QuestEventHandler maps accept, turn-in, removal, watch, criteria, reputation and recipe events to state transitions.
- QuestLifecycle centralizes accept/adopt/update/complete/abandon handling, including parent/child chains and repeatable/daily/weekly/monthly completion semantics.
- ActiveQuests and BreadcrumbQuests represent dependencies and chain behavior.
- AvailableQuests calculates candidates in threaded passes; level requirement logic is split out. DailyQuests/QuestHubs and event modules apply reset/calendar and hub-specific logic.
- QuestieQuest owns map-note visibility, tracking/hidden state, auto-blacklists and per-quest refreshes.
- AutoQuesting hooks quest/gossip/progress/completion UI and applies settings/disallowed-ID guards before accepting or turning in.

### Map, waypoints and world representation

- QuestieMap owns quest and manual map/minimap frames, draw queue, scale and map icon refresh.
- WaypointGeometry normalizes lines/patrol segments; QuestieWaypoints manages owner lifetimes/highlighting; WaypointMap and WaypointMinimap render on separate canvases; WaypointRenderer handles pooled drawing.
- HBDHooks and QuestieMapUtils bridge map-coordinate transforms; phase/floor and visibility constraints remain relevant.
- QuestieFramePool reuses Blizzard frames, while map queues spread work to avoid building all pins in one synchronous burst.
- NPC/object/quest points are derived from QuestieDB plus Questie corrections and player filters, not copied as opaque presentation data.

### Tracker and Journey

- TrackerData builds a normalized tracker view from quest cache/state, sorts by completion/level/zone and publishes layout revisions.
- QuestieTracker owns frame lifecycle, visibility/combat/instance behavior, quest-item handling, collapse/expand and refresh triggers.
- Sections and line pools render quest, achievement, recipe and scenario entries with reusable widgets.
- Journey is a separate exploration/planning UI: My Journey/history/notes, quests by zone/faction, quest details, search/results and character data/share functions. It is not the leveling-guide step engine used by RXP/Zygor.
- Tooltips and QuestLinks expose quest/entity context and chat hyperlinks; nameplate, coordinates, sounds, trainer/menu and profession/reputation helpers extend the runtime beyond quest pins.

### Network and cooperation

- QuestieComms exchanges party quest progress/log visibility, using CommsEncoding, CommsRouting and visibility policy.
- QuestiePartyObjectives updates party objective display through scheduled queues.
- DailyQuestComms has a separate daily-quest coordination path and blacklist.
- These are player/group coordination protocols; they are not a general public database replication service. WildQuest should not infer that a peer-synced quest state is verified world data.
- Communications must validate message format, sender/group context, rate, and size; presentation visibility must respect local settings and remote-player lifecycle.

### Public interfaces and settings

The Public directory declares Questie.API as the supported stable API surface and provides readiness callbacks and quest update subscriptions. This is distinct from internal QuestieLoader modules. External addons should wait for API readiness instead of reaching into internal globals. Options are organized by behavior (general, map, icons, tracker, auto quest, nameplates, DBM, advanced), with defaults/controls/layout/native widgets separated from the engine.

## QuestieDB internals

QuestieDB config defines supported flavors, interface values, entity types (Quest, Npc, Item, Object), key/data fields, locales, and storage format. Forever maps to camelot/forever game-type aliases and Classic legacy ordering while using its own Forever data set. Contract version and minimum supported contract are explicit and checked.

Baked mode reads generated TOC metadata blocks. Source mode can read raw entity files. Shared entity construction normalizes/pads rows and freezes records to guard accidental mutation. Metadata/codec modules decode and normalize fields. Corrections are owner-registered and deterministically ordered; static and runtime corrections are applied through a registry that can publish changed IDs and provenance. Support data is installed/removed by named module. The API exposes contract checks, cache invalidation and provenance queries in addition to entity accessors.

### Entity schema details observed in QuestieDB Types

The type declarations describe 36 quest fields, 15 NPC fields, 16 item fields and 7 object fields. Important quest fields include starter/finisher references, required level and quest level, race/class masks, objective text and typed objective tuples, start/end triggers, prerequisite groups, child/parent/next-chain links, exclusive/group relations, required profession/reputation/source items/spells, availability gates, breadcrumbs, repeatable/reset flags and extra objectives. Extra objectives can carry spawn locations, icon/text metadata and entity references.

NPC and object data include names, faction/flags, zones, spawn coordinates and waypoint paths; NPCs additionally have min/max level, rank, subname and quest starts/ends. Item data includes NPC/object/container drops, start quest, quest rewards, vendors, related quests, class/subclass, item/required level and taught spells.

Coordinates are grouped by AreaID; an optional third coordinate slot can encode phase. Waypoint lists are grouped by zone and retain path segmentation. Objective tuples distinguish creatures, objects, items, reputation, kill credit and spell use. These packed shapes explain why consumers should use named getters/type definitions rather than guessing positional columns.

QuestieDB exposes Get/GetAll/GetRaw/Exists/GetAllIds/IdsByName patterns. Get returns corrected/localized composed data; GetRaw bypasses corrections and localization. Name indices may be built synchronously or asynchronously in batches. Entity lists and rows are documented read-only. Localization covers selected fields and falls back to base entity values.

Corrections support static registration, runtime/query-time corrections and direct data slots, with owner, load order, registration sequence, flavor filtering, deterministic composition, invalidation and provenance. Objective-order hints are supplied as a separate set. A consumer should not mutate these tables or assume a correction to one entity automatically changes Questie runtime policy.

Consequences for WildQuest:

- Check provider readiness, flavor and supported contract before calling it.
- Treat records as immutable; make WildQuest-owned normalized copies if needed.
- Never use internal correction registry APIs as if they were a stable consumer API.
- Cache only with invalidation/correction awareness.
- Keep source/provenance alongside WildQuest-specific corrections.
- Distinguish static entity data from Questie's runtime policy layer.

## QuestieTrace boundary

QuestieTrace listens to a broad event set and writes bounded local sessions. It is a separate tool for structured diagnostics. WildQuest should not collect the same event breadth by default; any capture should be narrowly scoped to an issue and user-controlled.

## Scope still not claimed

Bundled Ace libraries, every locale string, every generated entity row and every conditional quest rule have not been audited individually. This file maps the first-party subsystem boundaries and principal execution path. Compatibility with live Forever must still be verified.
