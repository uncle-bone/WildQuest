# WildQuest

WildQuest is a WoW Forever addon project informed by source audits of RestedXP Guides, Zygor Guides Viewer Forever, Questie, QuestieDB, and QuestieTrace.

## Prototype status

Version 0.1.0-alpha.1 includes a declarative guide validator/runtime, per-character saved progress, quest-active/ready/turned-in/objective goals, optional QuestieDB contract-4 lookups, and a tracker window. No authored leveling route is registered yet. The prototype has not been verified in the live client; there is no install-ready release ZIP. See the [guide format](Guide/GuideFormat.md) for its schema and current limits.

Source entry point: [WildQuest.toc](WildQuest.toc). Core modules: [initialization](Core/Init.lua), [quest state](Core/QuestState.lua), [QuestieDB adapter](Core/Provider.lua), [guide validation](Guide/Validation.lua), [guide runtime](Guide/Runtime.lua), and [tracker UI](UI/Tracker.lua).

## Research

- [Research index](research/README.md)
- [Audit coverage and package inventory](research/audit-coverage.md)
- [RestedXP audit](research/audits/restedxp.md)
- [Zygor Forever audit](research/audits/zygor-forever.md)
- [Questie and QuestieDB audit](research/audits/questie-questiedb.md)
- [QuestieTrace audit](research/audits/questietrace.md)
- [WildQuest architecture proposal](research/architecture/wildquest-design-map.md)
- [Detailed Questie runtime/database map](research/audits/questie-runtime-map.md)
- [RestedXP and Zygor runtime comparison](research/audits/guide-runtime-comparison.md)
- [Source manifest, fingerprints, and update protocol](research/sources.md)

The audits describe the uploaded builds. They are research, not claims that WildQuest contains or is derived from any reference addon. Third-party archives, guide text, artwork, and database payloads are deliberately not mirrored here. See each audit for observed license/provenance limits.

When newer packages or WoW Forever data sources are reviewed, record version/build, inspection date, SHA-256, scope, and findings in research/sources.md; update the relevant audit and design proposal. Keep verified facts distinct from hypotheses and record the source file/API behind each conclusion.
