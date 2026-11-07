# WildQuest research index

## Scope

Static source audit of user-provided clean packages: RestedXP Guides, Zygor Guides Viewer Forever, Questie, the separate QuestieDB provider, and QuestieTrace.

The goal is to learn their architecture and identify compatible patterns for an original WoW Forever quest guide. This review covers file structure, metadata, principal lifecycle, guide progression, data interfaces, navigation, persistence, and relevant boundaries. It is not a line-by-line commentary on every bundled third-party library or a claim that every function was dynamically exercised.

## Findings

| System | Main responsibility | WildQuest research takeaway |
|---|---|---|
| RestedXP | Guide DSL/runtime, event-driven objectives, saved progression, map/arrow, guide sharing | A declarative step runtime and objective model are useful patterns. Implement an original DSL and event layer. |
| Zygor Forever | Guide/step/goal runtime, route/waypoint UI, quest tracking, Forever-specific quest-chain and travel modules | Guide → Step → Goal lifecycle is a strong model. Keep route computation separate from objective tracking. |
| Questie | Player-facing quest/map features consuming QuestieDB | Separate static facts from player-specific eligibility, progress, and display decisions. |
| QuestieDB | Versioned provider API and baked Forever entity data/corrections | An optional provider adapter can avoid duplicated data when a compatible provider is installed. Verify contract and provenance. |
| QuestieTrace | Local event/session capture and user-controlled reporting/export | Use explicit capture consent, data minimization, export visibility, and no background upload. |

## Documents

- [Audit coverage and package inventory](audit-coverage.md)
- [RestedXP audit](audits/restedxp.md)
- [Zygor Forever audit](audits/zygor-forever.md)
- [Questie and QuestieDB audit](audits/questie-questiedb.md)
- [Questie runtime and database module map](audits/questie-runtime-map.md)
- [RestedXP and Zygor runtime comparison](audits/guide-runtime-comparison.md)
- [QuestieTrace audit](audits/questietrace.md)
- [WildQuest design map](architecture/wildquest-design-map.md)
- [Source manifest and update protocol](sources.md)

## Confidence and limits

Findings describe the uploaded archives, not necessarily current upstream branches. Static inspection cannot establish runtime correctness on the live WoW Forever client. Package counts are inventory measurements, not completeness or quality scores. Compatibility claims should be validated against the target client before implementation.
