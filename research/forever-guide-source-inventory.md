# Forever Guide Source Inventory

## User-provided source archives already available

These files are already in the project Library; they do not need to be uploaded again:

- `RXPGuides-v4.11.34.zip` — RestedXP guide addon and source data.
- `Zygor Forever 1.6.37551.zip` — Zygor Forever addon and guides.
- `FlowUp-1.0.18.zip` — Forever leveling addon and route data.
- `ForeverQuest-0.21.0.zip` — Forever quest guide addon and data.
- `ForeverGuide-1.38.5.zip` — Forever guide addon and data.
- `Questie-RXPGuides-Zygor.zip` and `Questie(1).zip` — quest facts and earlier route research.

The current public WildQuest guide catalog only reflects the earlier RXP/Zygor cross-reference. The newer FlowUp, ForeverQuest, and ForeverGuide archives still need to be inventoried and compared before their routes can be counted as integrated.

## Additional Forever guide sources to include in the comparison

- [Polestar](https://github.com/fitzforge/polestar) — Forever-native source repo with guide files under `guides/forever`; inspect its current guide corpus and adapt route ideas into WildQuest-authored content. Its docs allow independently authored community packs to be distributed, but do not grant permission to copy Polestar's own guide text.
- [LevelForge](https://levelforge.dev/guides) — Forever Alliance and Horde chains, including Skyborne; supports downloads of individual guides or whole chains as `.guide` files.
- [Guidelime Sage](https://www.curseforge.com/wow/addons/guidelime-sage) and [TUGs](https://www.curseforge.com/wow/addons/guidelime_tugs) — Forever-compatible guide packs. Check each pack's current guide coverage and license.
- [Follow The Arrow](https://www.curseforge.com/wow/addons/followthearrow) — has a Forever build; inspect bundled route files and licensing before using its route data.
- [Journey](https://www.curseforge.com/wow/addons/journey) — Forever-specific route addon; its CurseForge listing reports All Rights Reserved, so keep its files private and do not publish copied content.
- [Zygor's Forever guides](https://zygorguides.com/launch/) — compare the user-provided Zygor archive with the current Forever release before relying on its level coverage.
- RestedXP Forever guides — compare the supplied archive against the current supported Forever route set and separately note any paid or account-bound content.

## WildQuest integration rules

1. Preserve source/version/provenance per imported route record.
2. Compare overlapping quest order, level ranges, objectives, chain gates, and travel quality; do not count a source as integrated until its actual Forever guide files have been parsed.
3. Use route structure and quest facts to author WildQuest's own steps. Do not copy another addon’s prose, Lua scripts, UI, artwork, or protected database into this public repository.
4. Keep uncleared third-party source files and full database bundles out of the public repo. Personal install packages stay separate.
5. Adapt catch-up from confirmed game state: prioritize matching active quests, identify below-level steps, check OR and AND prerequisites without guessing completion, and explain when a low-level step is still a required chain gate.

## Research status

- RXP/Zygor route overlap: earlier derived catalog exists (334 route packs, 7,049 ordered quest references; 61 packs had both-source coverage).
- FlowUp, ForeverQuest, and ForeverGuide: uploaded archives available, full source-by-source route comparison pending.
- Polestar, LevelForge, Guidelime Sage/TUGs, Follow The Arrow, and Journey: identified as additional Forever inputs; source files and route coverage still need per-source import/review.
- No WoW client verification is claimed.
