# Source manifest and audit update protocol

## Uploaded archives audited

| Package | Archive | Observed build/metadata | SHA-256 |
|---|---|---|---|
| RestedXP Guides | RXPGuides-clean.zip | TOC build v4.11.34-6-g8c13da7; Interface 16001; Forever-enabled | 1C3D049846A1C4337077F9387210E697F3A672C95D82E0F18ACA8A2D337768D9 |
| Zygor Guides Viewer Forever | ZygorGuidesViewerForever-clean.zip | Forever; version 1.6; Interface 16001 | 01EDACA89B11751EA46564BB370DFE931FACBB12676729FFDF74715627C508EC |
| Questie + QuestieDB + QuestieTrace | Questie-Uploaded.zip | Questie 12.6.3, build commit fc60e5600c2ca1c2878880bbf3d732233a60d2d5; QuestieDB 1.0.12, contract 4, Forever baked mode, build commit 4d31c10394b11bd133069ecf1662062cdf4d8691, embedded build time 2023-11-14T22:13:20Z; QuestieTrace 1.9.0 | 43B4A8766349E11742ABC6703C0A225688FD98492DE47AFBBA1C0B5D3A2BDDF9 |

Fingerprints identify the reviewed files exactly. Inspection date: 2026-11-07. TOCs target interface 16001. Static source inspection only; no runtime validation is implied.

Package inventories and coverage boundaries: [audit-coverage.md](audit-coverage.md).\n\n## Repository contents

Only original audit notes, architecture proposals and references are included. The supplied archives, addon source trees, guide text, embedded data and artwork are not mirrored. This keeps the repo focused on research rather than republishing third-party packages.

## Evidence labels

- **Observed:** directly read from a package file or TOC.
- **Derived:** computed from package contents (such as identifier-prefix counts); include method and limits.
- **Inferred:** architectural interpretation of code paths.
- **Unverified:** not dynamically tested, not checked against live-server behavior, or not confirmed against current upstream.

## Updating this manifest

For each new build:

1. Preserve archive name and calculate SHA-256.
2. Record source URL/user-provided origin, inspection date, addon version/revision, client/interface, flavor and layout.
3. Note audited modules and exclusions.
4. Update relevant audit with evidence filenames/functions.
5. Review code, guide prose, database, assets and libraries as separate license scopes.
6. Preserve old fingerprints and mark superseded builds instead of erasing evidence.
7. Update the design proposal only when findings change an implementation decision.

## Upstream references

- RestedXP: https://github.com/RestedXP/RXPGuides
- Zygor: https://zygorguides.com/
- Questie: https://github.com/Questie/Questie
- QuestieDB: https://github.com/Questie/QuestieDB


## Additional sources supplied 2026-11-07

The following uploads are registered for research. The new ZIPs were not byte-hashed or exhaustively inspected internally in this pass; the rights notes below are based on the public project listings. Archive-level TOCs and per-file/data notices remain to be audited.

| Source | User Library reference or URL | Project metadata and use |
|---|---|---|
| LevelForge addon and studio | https://levelforge.dev/ | Website and CurseForge listing reviewed. v0.1.22 is listed for Forever 1.60.1 under MIT. Candidate foundation; acquire and audit exact source package before porting. |
| LevelForge community guides | https://levelforge.dev/restedxp | Site lists 1–60 Forever Alliance and Horde chains, says catalog guides are free to read/import/copy/change, and keeps author identity visible. Preserve author and guide-version attribution; inspect individual guide credits. |
| FlowUp | `FlowUp-1.0.18.zip`; libfile_53330905a0488191b1c4eec3d284e881 | User-supplied Forever route addon. Project listing states GPLv3. Verify exact upload version and any separate route-data terms. |
| ForeverQuest | `ForeverQuest-0.21.0.zip`; libfile_cf2a19440fbc8191a5989b9f1a75b82a | User-supplied Forever 1.60.1 quest helper. Project listing states All Rights Reserved; feature reference only absent permission. |
| Forever Guide by LFYZ | `ForeverGuide-1.38.5.zip`; libfile_32b430ac2fd88191962c780a0a05df0a | User-supplied large Forever reference/quest addon. Project listing states All Rights Reserved. It is not the similarly named MIT class-guide project. |

See [the foundation review](audits/leveling-addon-foundation-review.md) for feature comparison, rights boundaries, and the proposed adoption sequence.
