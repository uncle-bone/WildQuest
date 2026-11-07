# QuestieTrace — detailed capture and export audit

## Audited package

The uploaded Forever TOC targets interface 16001 and reports QuestieTrace 1.9.0. QuestieTrace.lua declares schema version 16. SavedVariables are split among global QuestieTrace settings, global QuestieTraceDumps, and per-character QuestieTraceCharacter sessions. The package includes 38 Lua files, including 35 under Modules, plus LibStub/LibDeflate and UI XML. See [audit coverage](../audit-coverage.md) for package counts.

## Consent and capture lifecycle

Consent is tri-state: nil means not asked, true means consent to local collection, false means declined. On first login with nil, the addon prompts before capture. Accept stores true, starts capture and enables share reminders. Decline stores false and does not ask again until the user invokes /qlt consent. If consent is revoked during capture, the live capture is discarded rather than saved. Existing recovered in-progress data is discarded when consent is not true.

With consent true, capture starts locally. A session records start/end times, events and tracker function streams. The session is placed in SavedVariables so it can survive reload/logout. On a later load, an unfinished session can be recovered/finalized. Sessions are encoded when saved; old plain-table sessions are migrated to encoded records. The oldest saved entries are pruned beyond a hard cap of 10.

Commands include /qlt status, /qlt consent, /qlt debug, and /qlt export, plus dump providers. The event handler is limited to a deduplicated list of events, but the installed trackers sample a broad set of API state and some event arguments. The main event groups are:

- Quest state/dialog and quest POI/log changes.
- NPC interactions, gossip, quest dialogs, merchants and loot.
- Player identity/progression, level, skills, spells, reputation, carried item counts and equipment-related state.
- Position, map exploration, map/zone changes and map hierarchy dumps.
- Unit/nameplate/interactions, group state and game-object tooltip data.
- Display state and frame heartbeat/performance context.
- Selected system/loot/money/skill chat events.

Many tracker streams append only when values change, use delayed probes around API updates, and safely wrap API calls that may be absent or return different shapes. This reduces duplicate records and accommodates the Forever client API. It still means the trace can contain a detailed timeline of a character's questing, location, inventory/progression and nearby interactions. “Anonymized” in the consent text should not be read as “contains no sensitive gameplay context.”

## Privacy processing

Tracked chat events pass through Core.SanitizeChatMsgArgs before they are written to events or passed to tracker callbacks. The privacy module builds player-name variants and redacts name text; the main event list deliberately omits DUEL_REQUESTED because it carries the challenger's name. Export construction deep-copies sessions and scrubs player GUID observations and matching name observations before encoding.

These are meaningful safeguards, but they are transformations rather than a proof of anonymity: location/time, quest choices, group/world context, item/loot sequences and residual identifiers may still be identifying in combination. A WildQuest trace should default to less collection and clearly disclose exact fields.

## Export and report handoff

The export path is manual in the inspected code:

1. The player opens /qlt export or clicks a reminder link.
2. The addon builds a scrubbed copy and encodes it as CBOR, compresses it with Deflate, then converts it to printable text using LibDeflate. The game-native C_EncodingUtil codec is checked; missing codec support produces an error and disables the “reported” confirmation.
3. The window displays the fixed destination https://questie.dev/trace, a single-line copy field, and counts for events, time, accepted quests and turned-in quests. The UI directs the player to copy the text and submit it at that URL. It does not send the payload itself; the browser submission is a separate user action.
4. Closing the window leaves the sessions available. The “I reported this” button is only offered for a valid encoded payload and its tooltip says to click it after submission.
5. On confirmation, only the exact source sessions included in that payload are deleted. Opening/closing alone does not delete them. If the live capture was included, the window rotates it into a saved snapshot and begins a fresh capture so later events do not alter the exported payload.

The export UI locks the destination URL field, uses a single-line box because the game client can stall rendering large multiline strings, and permits Ctrl+A/Ctrl+C to copy the full encoded text. Export reminders are scheduled around resting/inn state after enough play time, are clickable, and are rate-limited to inn entry/login rather than repeated hourly while a player stays there.

No automatic network upload call was found in the inspected export/trace path. The intended handoff is copy/paste to the web page. This is a static source finding, not a live network capture or verification of the website's server behavior.

## Tracker module inventory

The Forever TOC loads these first-party trackers before the capture controller. The table records each module's observed domain; exact samples depend on supported client APIs and change-detection logic.

| Module | Captured domain / mechanism |
|---|---|
| PlayerIdentity | Character identity context used by the local trace and export scrubber |
| UnitLevel | Player/unit level observations |
| Position | Current map/position and explored-map data, sampled on relevant events/timer |
| Loot | Loot open/close and safe probes of loot slots/API results |
| Merchant | Merchant open/close and item-list/API observations |
| ItemCount | Carried item counts, collected from known item IDs with delayed rescans |
| Reputation | Faction rows and reputation values |
| QuestLog | Quest log rows, quest state/objectives, rewards and direct quest API probes; delayed follow-up probes cover removed/invalidated quests |
| CompletedQuests | Completed quest IDs from modern and legacy APIs |
| QuestPOI | Quest map points across maps |
| QuestDialog | Gossip/quest dialog options, flags, offered quests and quest-item details, sampled around dialog events |
| UnitInteraction | Available/active gossip quests, interaction state and selected nameplate/unit observations |
| GameObject | Game-object identity/data from tooltip processing |
| UnitState | Unit names/subnames and state obtained from tooltip/API paths |
| GroupState | Group roster/world state |
| SkillLines | Skill lines, profession data and trade-skill records |
| SpellBook | Spellbook snapshots and incremental known-spell changes |
| ResetTime | Daily reset timing/calendar observations |
| Display | Display-related values recorded only when changed |
| PlayerProgress | Experience/level/progress functions sampled at change points |
| ItemInfo | Item metadata cache/API results associated with observed item requests |
| FrameHeartbeat | Frame heartbeat/timing context for trace interpretation |
| Dumps/MapHierarchy | On-demand map hierarchy dump; registered as a diagnostic dump, not a continuous world database |

Together, these trackers explain why consent text says quest progress, positions and loot: the actual local event/func streams also cover inventory, professions, spells, reputation, map exploration, NPC interactions and display context. The capture should therefore be treated as detailed behavioral telemetry even though the export pipeline scrubs selected identity fields.

## WildQuest application

If WildQuest adds diagnostics, use a narrower opt-in schema tied to a specific issue. Show capture state, field list, retention and export destination. Sanitize before persistence, not only before export; provide preview and explicit copy/share; never send in the background. Keep normal addon operation independent from diagnostics. Do not treat trace data as canonical world facts until reviewed and independently corroborated.

## Licensing

The uploaded QuestieTrace notice states GPLv3 for QuestieTrace, while bundled libraries have individual licenses. This does not grant rights to Questie/QuestieDB data, names or logos. QuestieTrace source and payloads are not copied into WildQuest.

## References

- [QuestieTrace source folder](https://github.com/Questie/Questie/tree/master/QuestieTrace)
