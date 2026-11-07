# Uploaded route sets — architecture and inventory audit

This audit inspects the actual guide files in the uploaded RestedXP and Zygor Forever archives. It records route structure and feature coverage without reproducing the guide text, route order, coordinates, or screenshots. Those guide files remain available in the user-provided packages; they are not copied into WildQuest.

## Inventory from the reviewed archives

The archive fingerprints are recorded in [sources.md](../sources.md).

| Package area | Lua guide files | Category/file scope |
|---|---:|---|
| RestedXP Guides/forever | 22 | 13 main Forever routes and 9 dungeon variants, selected by the Forever guide manifest |
| Zygor Guides-Forever | 104 | 6 leveling, 3 dailies, 13 dungeons/gear, 4 events, 18 gold, 21 includes, 14 pets/mounts, 6 professions, 4 reputations, 4 titles, 9 POI Lua files, plus guide image/support files |

The Zygor category counts above include its Includes and POI code, not only player-selectable routes. Its whole Guides-Forever directory contains 222 files, including 114 BLP images, 3 TGA images and an XML manifest. RestedXP's full Guides directory contains 214 files across all flavors; the 22 count is specifically the Forever route folder.

## Syntactic feature counts

A simple case-insensitive source scan over the route Lua files found:

| Pattern | RestedXP Forever | Zygor Forever |
|---|---:|---:|
| Step declaration lines | 27,745 | 17,807 |
| Coordinate/goto tokens | 42,254 .goto | 20,832 goto |
| Waypoint path tokens | 316 .waypoint | Included in route/map API, not represented by the same token |
| Quest/objective action tokens | 8,135 .accept; 8,090 .turnin; 7,747 .complete | 1,741 |complete; actions often use parser verbs or goal expressions |
| Conditional/optional controls | 6,694 #completewith; 3,394 #optional; 467 #sticky | 10,220 |only if |

These are token/line occurrence counts from this exact package, not counts of unique objectives, quests, or verified coordinates. Different parser languages make raw counts non-comparable.

## RestedXP route model observed

The 22 Forever files are Lua wrappers that register readable text guides with RXPGuides.RegisterGuide. The guide header declares flavor/season, faction, race/class eligibility, version, group/subgroup, next guide, and optional dungeon/variant behavior. Step blocks mix player-facing instructions with declarative tags and predicates.

Observed route capabilities include:

- Accept, turn in, and complete quest objectives; record NPC/object/item targets.
- Coordinates, route loops, radii, pins, waypoint paths and movement modes.
- Softcore/hardcore, faction/race/class/season conditions and guide-specific variants.
- Step labels and jumps, complete-with dependencies, sticky and optional side objectives.
- Travel instructions for flight masters, hearth/bind, death skips and mount/flying requirements.
- Vendor/trainer/bank/inventory actions, item counts, skills, reputation, talents and money.
- Human-readable instructions interleaved with machine-readable actions.

The loader parses text entries into step elements. Runtime event handlers drive objective completion; map and target modules consume coordinate/entity actions. The route is therefore both an ordered workflow and a declarative event/map program, rather than a static list of quest IDs.

## Zygor route model observed

The Forever manifest autoloads routes and common includes for neutral/Alliance/Horde content. Guide files register a title/header and a step script. Header fields can suggest or hide guides based on character state, set next-guide transitions, bind guide relationships, and apply product-specific modes. Step text is mixed with parser verbs, conditions and goal expressions.

Observed route capabilities include:

- Step requirements and conditional display/skip, with explicit next links and guide suggestions.
- Quest, NPC, item, skill/profession, travel, dungeon, event and gold-guide actions.
- Coordinate movement and waypoint selection; route planning and taxi/flight data are owned by separate navigation libraries.
- Inline completion expressions and conditional lines, plus tooltips/instructions as separate presentation.
- Shared includes that avoid duplicating common data/actions across faction route files.
- Larger feature catalog than leveling: profession, reputation, daily, dungeon, gold, pet/mount, event, title and POI guides.

Guide parses header and steps; Step activates/deactivates Goal objects; Goal owns its event/completion status. The route pointer and route planner are separate from the Guide/Step cursor. This separation is important for sticky objectives and travel steps.

## Lessons for WildQuest's guide format

The current WildQuest schema handles ordered steps and quest-active/ready/turned-in/objective goals. It does not yet support authored route data, coordinates, navigation, branches, sticky side goals, vendor/trainer actions, or step visibility conditions.

A compatible original extension should add the following explicitly rather than accepting raw RXP/Zygor scripts:

1. Step requirements and branch references with validated conditions.
2. Goal groups supporting required, optional/sticky and complete-with relationships.
3. Map target records with Forever map/zone IDs, normalized coordinates, radius and optional route path.
4. Action/goal types for NPC/object/item/loot/trainer/vendor/flight-path objectives, each backed by a bounded event subscription.
5. Guide-to-guide transitions and race/faction/class/level filters.
6. A renderer and route planner that consume the same normalized route records without changing progression state.

Keep imported guide content non-executable. Re-author route instructions and verify each Forever quest/entity/coordinate against independent sources or observed gameplay. QuestieDB can be an optional lookup source for entity facts; it should not be mistaken for a license to redistribute the guide scripts or database payload.

## Coverage limits

I inspected route folder manifests, representative route scripts, parser/runtime boundaries and aggregate syntactic patterns. I did not transcribe or quality-score every copyrighted step, validate every route coordinate in game, or independently verify every quest chain. For implementation, each route should get its own provenance and live verification record.
