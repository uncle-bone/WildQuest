# RestedXP and Zygor — runtime comparison and component map

This supplements the separate [RestedXP](restedxp.md) and [Zygor Forever](zygor-forever.md) audits with a comparative view of execution and subsystem ownership. It is based on the supplied archives, not current online builds.

## Shared architectural shape

Both systems separate authored guide instructions from runtime UI, track one active guide position, derive objective state from events/game APIs, and present a map/arrow target. Both also ship substantial guide data and multiple unrelated product features. Their guide languages and data are not interchangeable.

## RestedXP path

### Package/load structure

RXPGuides.toc includes interface 16001 and the camelot game type through the mainline embedded-library manifest. It declares optional Questie/theme integrations and separate account/profile and per-character SavedVariables. The TOC selects common runtime plus DB/forever.xml and GuideList-forever.xml.

### Principal runtime modules

- RXPGuides.lua owns addon setup, registration, global services, saved state and lifecycle.
- GuideLoader.lua parses/validates guide source, resolves imports/conditions and caches parsed/compressed guide data.
- functions.lua provides guide-tag handlers and reusable predicates, coordinates, event declarations and quest/object/NPC actions.
- GuideWindow.lua owns current/next step rendering, active-element event binding, completion evaluation and step progression.
- QuestLog.lua reconciles guide expectations with live quest log state and quest chains.
- map.lua owns quest/map pins, arrow targets and map refresh.
- Targeting.lua tracks current objective target and NPC/object state.
- LevelingTracker.lua and Timers.lua provide auxiliary progression/timing display.
- InventoryManager.lua, ActiveItemFrame.lua and ItemUpgrades.lua handle item goals and inventory/gear guidance.
- Talents.lua, Tips.lua and Help/settings/UI modules cover the broader product.
- Communications.lua shares guide/step status with group members; it is not a general quest database sync protocol.

### Execution pattern

Guide registration is followed by parse/cache. Runtime selects a current step, derives the handlers required by that step, subscribes only those handlers, and recomputes completion when relevant events arrive. Progress is persisted via stable guide/step metadata; advancing tears down old transient UI and subscriptions. Import handling is bounded and checks content integrity before caching.

## Zygor Forever path

### Package/load structure

The addon TOC identifies Forever v1.6/interface 16001 and loads files-Forever.xml. That manifest orders shared UI/core, then parser/waypoint/quest tracking, Forever QuestDB and profession/talent modules, Guide/Step/Goal, notification policy, pointer/routes, item scoring, Data-Forever, guide categories, initial flight paths, sync/telemetry/widgets and chain parser/data.

### Principal runtime modules

- ZygorGuidesViewer.lua, Modules.lua, Class.lua, Functions.lua create core services and shared object patterns.
- Parser.lua turns guide script entries into runtime structures.
- Guide.lua handles guide registration, availability/status, loading, completion and recommendations.
- Step.lua handles requirements, labels/jumps, sticky progression, goal activation and step transitions.
- Goal.lua owns objective state, event registration and completion/visited checks.
- QuestTracking.lua tracks quest log/events and daily resets.
- QuestDB.lua and Code-Forever/QuestDB.lua provide chain/eligibility/suggestion logic over Forever-specific data.
- Waypoints.lua and Pointer.lua manage waypoint and map/taxi presentation; LibRover and LibTaxi support travel-route calculation.
- NotificationCenter.lua queues contextual suggestions and injected events.
- Data-Forever contains guide list/menu, routes/flight paths, quest/NPC/object/trainer/profession/item tables, dungeons and related product data.
- Additional modules implement talent advisor, profession, pet battle, gold, inventory, item score/upgrades, foglight, skins and widgets.

### Execution pattern

Guide evaluation decides whether a guide is applicable. The current step checks conditions and activates its goals; goals register only needed events. State changes update goal completion; when a step completes, sticky/jump/next-valid logic selects the next eligible step. Guide progress and quest tracking are distinct state layers. Route selection chooses travel between targets; pointer/UI then projects destination direction and map markers. Notifications/suggestions run as their own policy layer.

## Practical comparison

| Concern | RestedXP emphasis | Zygor emphasis | WildQuest decision |
|---|---|---|---|
| Content model | Text DSL parsed into elements/tags | Guide/Step/Goal objects built by parser | Keep declarative data, but use explicit validated records |
| Event subscriptions | Active-step tag handlers/watchers | Goal activation/deactivation | Model subscriptions per active goal and cleanly dispose them |
| Step progression | Visible/active element aggregation, sticky/completion dependencies | Requirements, labels/jumps, sticky and next-valid logic | Stable step IDs with explicit branch and recovery behavior |
| Quest tracking | Expected/relevant guide quests and standard quest log | Quest log cache and guide/goal reconciliation | Native quest state is truth; guide state is advisory |
| Navigation | Arrow/pins and objective targeting | Route graph, taxi/flight choices, pointer | Separate global travel choice from local objective arrow |
| Persistence/import | Saved guide progress, bounded compressed imports | Saved guide state and broader product settings | Versioned safe schema; avoid executable imports |
| Sharing | Group guide-step progress | Sync/telemetry features in package | Keep optional, separately consented and separately validated |

## Licensing and reuse

Use these systems to understand patterns. Do not copy guide routes, text, images, brand assets or data. RestedXP's covered materials carry a non-commercial share-alike notice; Zygor's package TOC license does not establish the license of every bundled content type. Any code reuse needs file-specific rights review and license compliance. The WildQuest repository contains findings only.
