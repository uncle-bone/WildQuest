# WildQuest architecture map (research proposal)

This is a design proposal from the source audits, not implemented addon behavior. It is a maintainable starting point for WoW Forever.

## Suggested modules

| Module | Responsibility | Inputs / outputs |
|---|---|---|
| Bootstrap | TOC, startup, client/flavor checks, module wiring | client APIs → initialized services |
| DataProvider | Normalize local records and optional QuestieDB adapter | provider records → stable WildQuest entities |
| QuestState | Read quest log/event state; derive player eligibility/progress | game events/APIs → quest status |
| GuideParser | Parse WildQuest's documented declarative format | authored guides → validated steps/goals |
| GuideRuntime | Current guide/step, requirements, completion and persistence | parsed guide + quest state → progression |
| GoalEvents | Subscribe only to active goals; unregister on exit | events → goal updates |
| RoutePlanner | Select destination and account for travel graph/flight paths | coordinates/travel data → route |
| MapPresentation | Arrow, pins, tracker and map-addon compatibility | route/goals → frames |
| Sync (later/optional) | Share explicitly defined guide/data records | validated versioned messages |

## Core boundaries

**Static facts vs player state.** Entity/quest definitions and coordinates belong to a provider. Whether a character can accept a quest or has completed an objective belongs to runtime state.

**Goal progress vs travel.** A goal can remain incomplete while the player is near a target. Travel selects a destination; local presentation shows how to reach it. Keep route planning separate from completion logic.

**Data vs authored guide content.** Quest facts should not require a leveling route. Guides reference stable entity/quest IDs and express original ordering, conditions and instructions.

**Optional integration.** A QuestieDB adapter should detect version/contract and degrade cleanly if absent or incompatible. Do not hard-depend on it until product scope and data rights are clear.

## Initial schema direction

Use stable IDs and explicit types. Conceptual records:

- Quest: id, optional title, start/end entity refs, objective refs, prerequisites, faction/class/level restrictions, source/build, confidence.
- Entity: kind (NPC/object/item), id, names, map/zone, coordinate/spawn set, related quests, source/build, confidence.
- Guide: id, title, version, client flavor, minimum schema, ordered steps.
- Step: stable id, requirements, goals, optional text/travel target, branch references.
- Goal: kind, referenced ID/objective index, completion policy, event subscriptions.

Validate types, limits and references; reject malformed or unsupported schemas. Avoid executable Lua in imported guide content. Keep third-party route text and assets out of entity facts.

## Progress and event lifecycle

1. Load and validate provider records.
2. Resolve character quests/state.
3. Load selected guide and persisted stable step ID.
4. Activate current-step goals and register needed events.
5. Reconcile on quest-log/world/map changes.
6. Mark completion from authoritative game state where possible.
7. Unregister old goals before activating next goals.
8. Persist stable IDs/schema version and recover if an update removed a step.

## Delivery sequence

1. Confirm target client API/interface behavior and create original module skeleton.
2. Build minimal original guide runtime and guide sample.
3. Add quest event reconciliation and lightweight map/arrow.
4. Add optional provider adapter.
5. Build independently sourced Forever records with field-level provenance.
6. Add routing and optional sharing after accuracy is stable.

## Research update checklist

For every source, record repository/archive and exact revision, inspection date, SHA-256 if local, client build, license/provenance, fields supported, validation and known gaps. Mark findings observed, derived, inferred or unverified. Preserve historical versions and note superseded builds.
