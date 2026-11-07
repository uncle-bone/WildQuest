# Questie and QuestieDB — source audit

## Audited package

The uploaded package contains three folders: Questie, QuestieDB, and QuestieTrace. Forever TOCs target interface 16001. Questie reports v12.6.3, TOC build commit fc60e5600c2ca1c2878880bbf3d732233a60d2d5; QuestieDB reports v1.0.12, contract 4, Forever flavor, baked mode, build commit 4d31c10394b11bd133069ecf1662062cdf4d8691. The database TOC embeds build time 2023-11-14T22:13:20Z, so do not infer database freshness from the Questie addon version. See [detailed Questie runtime/DB map](questie-runtime-map.md) and [coverage counts](../audit-coverage.md). Archive fingerprint is in [sources.md](../sources.md).

QuestieDB's Forever TOC is a generated baked dataset with runtime loader/API and embedded entity metadata. A raw identifier-prefix count in this uploaded TOC found 5,233 quest IDs, 13,417 NPC IDs, 21,442 item IDs and 7,045 object IDs. These are inventory counts only; they do not prove rows are complete, correct or usable in every context.

## Separation of responsibilities

Questie is the player-facing addon: it consumes database facts and applies runtime policy for quest state, eligibility, map display, tracking, filtering and UI. QuestieDB is a separate provider/library-style addon offering entity records, names/locations/relations, localized fields, support data and corrections through a versioned contract. The Questie TOC in this package lists QuestieDB as an optional dependency; that is specific to this uploaded build.

The provider API is exposed through LibQuestieDB and namespaces such as QuestDB, NpcDB, ItemDB and ObjectDB. Data can use baked or source modes, with corrections/support data layered into the provider. The key design lesson is to separate facts from character-specific availability and display policy.

## Data and corrections

The Forever baked TOC contains large encoded metadata blocks while Lua files define loader and access behavior. This makes installation self-contained but updates large and review less transparent. Corrections are part of the provider pipeline and must preserve the contract. WildQuest should use inspectable records and track source, confidence, observed client build and correction history.

An entity name/position alone may not identify a quest objective. Quest relations, objective ordering, faction/class/level restrictions, spawn variants and map/phase context affect accuracy.

## QuestieTrace

QuestieTrace is a separate data-collection addon, not the core database. Its inspected source defines categories for quest/dialog state, NPC interactions, player state, map/zone, selected chat messages, groups/world, inventory and display. It holds local capture state and caps retained sessions. Comments explicitly filter some potentially identifying chat payloads. See the separate [QuestieTrace audit](questietrace.md).

## WildQuest integration options

1. **Preferred early option — optional adapter.** Detect compatible QuestieDB at runtime, verify contract/flavor, and query only needed public API fields. WildQuest remains functional without it.
2. **Independent embedded data.** Build only when each field has provenance and redistribution rights. Prefer original observations, sources with verified terms, and user-submitted records with consent.
3. **Do not silently mirror.** Do not copy the uploaded QuestieDB baked rows wholesale. Its notices describe historical contributor licensing uncertainty and say unclear content should be treated as all rights reserved. Questie's name/logo are excluded from the stated permission.

The uploaded Questie license discusses consent for contributions after 21 October 2026. This reports the supplied package notice and is not legal advice. Treat it as a provenance constraint and obtain a clear license/source for redistributed material.

## References

- [Questie repository](https://github.com/Questie/Questie)
- [QuestieDB repository](https://github.com/Questie/QuestieDB)
- [QuestieDB integration documentation](https://github.com/Questie/QuestieDB/blob/master/README.md)
