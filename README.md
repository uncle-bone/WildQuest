# WildQuest

WildQuest is a standalone questing and character helper for WoW Forever (client 1.60.1 / interface 16001). It uses its own bundled data and the game's APIs; it does not require Questie or QuestieDB.

## Current personal build: 0.1.0-alpha.11

[Download the owner-only install ZIP](https://chatgpt.com/library?file_id=libfile_34c18d0f92288191b1d771b200788911&account_id=personal). The private package contains the bundled data; the public repository intentionally keeps those data files empty.

### Quick start

1. Extract the ZIP and place its `WildQuest` folder in `Interface/AddOns`.
2. Enable WildQuest and reload the UI.
3. Type `/wq` to open the tracker. Use `/wq guides` to open the guide browser, or click WildQuest's minimap button.

### Included features

- Home dashboard, active quest list, live objectives, and catch-up route from the active quest log.
- Guide browser for leveling, dungeons, events, professions, and reputations.
- Current guide with quest details, prerequisite OR/AND groups, and bundled quest giver locations.
- Gear item-level audit, talent build snapshot, gold/session tracking, and profession skill overview.
- Auction House scan when the Forever client supports the required search API and result event. On clients without that event, scanning reports unavailable and WildQuest continues loading.

The route catalog contains 334 synthesized packs based on 585 quest-bearing guide sections parsed from RXP and Zygor Forever sources; 61 packs have coverage from both. This is a generated quest-order catalog, not a copy of the original guide archives. WildQuest does not include their original scripts, prose, or artwork. Fifty-three route quest IDs are absent from the bundled database snapshot and may lack bundled names or details.

Gear and talent sections are audits/notebooks; they do not yet provide stat-weight upgrades or talent build recommendations. Recipe planning, market history, and map arrows are also not included. This is an alpha and has not been verified in the WoW Forever client in this session.

The full database and generated route catalog are kept out of public GitHub because the QuestieDB archive notes historical contributions with unclear redistribution rights. Do not redistribute the personal ZIP.

See [standalone architecture](research/architecture/standalone-addon-design.md) and [source manifest](research/library-source-manifest.md).
