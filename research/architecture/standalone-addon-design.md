# WildQuest standalone architecture

## Product goal

WildQuest is a self-contained WoW Forever quest tracker and guide addon. It must operate with WildQuest alone enabled. Quest names, levels, prerequisite relationships, givers, spawn coordinates, objective metadata, and route data belong to WildQuest's own packaged data files. The game quest log and client APIs supply live character state; other addons are never runtime providers.

## Runtime layout

1. `Data/QuestDB.lua` loads the local bundled data into `ns.BundledDatabase` before the core/provider modules. The public repository carries an empty placeholder; the owner-only install bundle replaces it with the full generated Forever data.
2. `Core/Provider.lua` is the sole internal fact lookup API. It reads WildQuest data for quest records, prerequisite facts, givers, and locations. It never probes addon-loaded state, globals owned by Questie, library contracts, or optional dependencies.
3. `Core/QuestState.lua` reads only the current character's quest log and client completion flags/events. Persisted observations are character-scoped.
4. `Guide/Runtime.lua` uses route definitions registered by WildQuest and live quest-log progress. A source coverage table may prioritize factual overlap but cannot supply copied guide steps.
5. `UI/*` presents the tracker, active guide, XP observations, and minimap access without requiring companion addons.

## Data contract

- Data file format is a Lua 5.1 table loaded through the addon TOC; no JSON decoder, network request, external library, or companion addon is needed in-game.
- The current Forever extraction contains 5,233 quest, 13,417 NPC, 7,045 object, and 21,442 item records. The bundled build carries all four entity types so quest giver and objective lookups are internal.
- Schema and source build provenance are retained in the generated data header/payload and the private extraction research bundle.
- Keep generated data separate from runtime code so an approved source refresh does not require changing user-facing logic.
- The complete data payload remains in the owner's private install package and Library. Do not commit it to the public GitHub repository while the source license's historic contributions remain unclear.

## Quest prerequisite rules

- `preQuestSingle` is an OR list: one confirmed completed prerequisite is enough.
- `preQuestGroup` is an AND group: every listed prerequisite is required.
- `parentQuest` requires the parent to be active.
- `availableStartingWith`, `availableUntilCompleted`, `disabledByQuest`, exclusives, faction/race/class gates, level, profession, reputation, spell, specialization, and required source items remain distinct conditions.
- States are completed, active, unavailable, or unknown. Missing history is unknown, never inferred complete. A catch-up UI must let the player confirm prior completion or explicitly override a gate while recording that choice.

## Route and guide model

Guides are original WildQuest-authored step graphs with stable IDs, level/faction/class/zone filters, quest goals, explicit prerequisite edges, and optional XP/no-XP annotations. The current route command only reorders active quests using readiness, internal quest levels, and derived RXP/Zygor ID coverage. Coverage is a weak planning signal, not endorsement or copied route logic. Build authored leveling and dungeon packs independently, and allow safe skip/revisit controls without rewriting quest history.

## Publication boundary

The repository contains addon code, public metadata, and source coverage facts. The personal install package contains the private full static quest dataset. Do not publish the full database, original RXP/Zygor guides, prose, or scripts into the public repository. Do not describe the current alpha as a complete guide product or as live-verified.

