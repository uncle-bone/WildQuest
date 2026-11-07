# Leveling addon foundation and source review

**Reviewed:** 2026-11-07  
**Purpose:** Select a technically useful, legally reusable foundation for WildQuest, and record the newest user-provided addon/source inputs.  
**Review level:** Public project pages and license listings checked. The newly uploaded ZIPs are recorded by their exact Library names and IDs; their internal TOCs, per-file notices, and hashes still need a binary-level audit before any code or data is adopted.

## Recommendation

Use the **LevelForge addon** as the primary candidate foundation. Its CurseForge listing identifies the addon as MIT-licensed and supports WoW Forever 1.60.1. MIT permits copying and modification when its copyright and license notice are retained. The public LevelForge site describes an addon/studio workflow with guide progress, automatic catch-up, an arrow, step/objective tracking, and guide imports. It also reports complete Forever 1–60 Alliance and Horde community chains. The addon itself does not ship with those guides; players import guides from the catalog.

Before porting, obtain and inspect the actual LevelForge v0.1.22 package/source. That package was not among the new uploads referenced here, so this is a metadata and feature review rather than a source-code audit.

## Input comparison

| Input | Version / target | License signal | What it contributes | WildQuest treatment |
|---|---|---|---|---|
| LevelForge addon and guide studio — https://levelforge.dev/ | Site lists v0.1.22; Forever 1.60.1 | MIT for addon code. Site says catalog guides are free to read, import, copy, and change; each guide is published under its author's name. | Guide runtime, resync/catch-up, ordered objectives, waypoint arrow, guide authoring/import. Public catalog lists 1–60 Forever faction chains. | Candidate code foundation. Keep MIT notice; identify source version and mark WildQuest modifications. Preserve guide author/credit and source metadata when adapting community-authored guides. Import support for RXP/Zygor does not override those guides' own terms. |
| FlowUp | User upload `FlowUp-1.0.18.zip`; target Forever | Project listing states GPLv3. The upload filename's exact internal version and any separate data notices have not yet been verified. | Forever leveling-route runtime and route data; the public feature description emphasizes quest-by-quest routing and route optimization. | Reuse is possible only with GPLv3-compatible distribution and notices. Review the uploaded archive's own license and route-data headers before adopting its bundled routes. |
| ForeverQuest | User upload `ForeverQuest-0.21.0.zip`; target Forever 1.60.1 | CurseForge marks it All Rights Reserved. | Quest tracker, clustered map markers, dotted minimap guidance, objective selection, destination priorities, per-character location corrections and compact tracking. | Feature reference only; do not copy its source or bundled data into WildQuest without permission. |
| Forever Guide (LFYZ) | User upload `ForeverGuide-1.38.5.zip`; target Forever 1.60.1 | CurseForge marks it All Rights Reserved. This is the 17.1 MB project by LinFeiyizu, not the separate MIT class-guide project with a similar name. | Large in-game reference system: full quest chains, dungeon quests, boss loot, item drops, gear, professions, recipes, rare information and library books. | Feature and coverage reference only; do not copy its code, prose, or bundled database without permission. |
| ForeverGuide (KonDerZiller) | Public project, not one of the supplied ZIPs | MIT | Separate class guide for talents, trainer abilities, food, campsites, professions, and Legacy perks. | A possible separate code/data source to assess later; do not conflate it with the uploaded LFYZ Forever Guide. |
| RestedXP Guides | Previously supplied archive | RestedXP's guide terms distinguish free and paid guide content; paid content and derivatives are restricted. | Route coverage and authored leveling routes. | Only use content clearly authorized for the intended use; do not treat the addon repository license as blanket permission for paid guide data. |
| Zygor Guides Viewer Forever | Previously supplied archive | Proprietary/licensed product; no permission to rebrand or redistribute its code or content was identified. | Reference for guide behavior and feature workflows. | Study behavior; implement independently unless a written license is obtained. |
| QuestieDB | Previously supplied archive | Uploaded material records uncertain historic contributor licensing. | Quest facts, prerequisite semantics, NPC/object/item metadata. | Keep copied full database out of the public WildQuest repository; document provenance and confirm rights before redistributing. |

## Rights and provenance rules

- Treat addon code, route/guide files, databases, artwork, and third-party libraries as separate license scopes.
- A feature that imports another format is not permission to redistribute the imported guide. LevelForge's site credits guide authors, and its published guide pages keep author identity visible.
- For LevelForge community guide content, record the original author, guide URL/ID, version, and modifications. Do not remove source credits.
- For FlowUp, preserve GPLv3 notices and make any distributed derivative source available under the applicable GPL terms. Verify whether its route files carry additional terms.
- Keep All-Rights-Reserved ForeverQuest and LFYZ Forever Guide code/content out of WildQuest unless their authors grant permission.
- Do not upload the user-supplied third-party ZIPs or copied guide/database payloads to the public WildQuest repository.

## Research inputs and traceability

| Input | User-provided Library reference |
|---|---|
| FlowUp 1.0.18 ZIP | `libfile_53330905a0488191b1c4eec3d284e881` |
| ForeverQuest 0.21.0 ZIP | `libfile_cf2a19440fbc8191a5989b9f1a75b82a` |
| Forever Guide 1.38.5 ZIP (LFYZ) | `libfile_32b430ac2fd88191962c780a0a05df0a` |
| LevelForge site | https://levelforge.dev/ |

These references are source inventory only. No ZIP contents are mirrored in the public repository.

## Next audit actions

1. Obtain LevelForge v0.1.22 through its official download and inventory its TOC, code modules, license notice, dependencies, and guide format.
2. Audit the three supplied ZIPs' TOCs, embedded licenses, guide/data file boundaries, and hashes.
3. Compare LevelForge's guide state machine and catch-up behavior to WildQuest's current runtime before choosing a migration path.
4. Build an original route catalog using only guide content with confirmed reuse rights and independently verified Forever quest facts.
5. Keep the interim interface close to the chosen foundation; defer the unique WildQuest redesign until route progression and guide data work.

## Public references

- LevelForge project and MIT license: https://www.curseforge.com/wow/addons/levelforge and https://www.curseforge.com/wow/addons/levelforge/license
- LevelForge site, features and guide catalog: https://levelforge.dev/ and https://levelforge.dev/restedxp
- FlowUp Forever project and GPLv3 listing: https://www.curseforge.com/wow/addons/flowup-forever
- ForeverQuest project/license listing: https://www.curseforge.com/wow/addons/foreverquest
- LFYZ Forever Guide project/license listing: https://www.curseforge.com/wow/addons/forever-guide
- Separate ForeverGuide MIT class guide: https://www.curseforge.com/wow/addons/foreverguide
- RestedXP guide terms: https://shop.restedxp.com/terms-conditions/
