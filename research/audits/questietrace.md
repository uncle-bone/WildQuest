# QuestieTrace — source audit

## Purpose and source facts

QuestieTrace is packaged separately from Questie and QuestieDB. Its Forever TOC identifies version 1.9.0; its Lua source defines schema version 16. It captures local gameplay/addon events into sessions, with a maximum of 10 retained sessions as a storage backstop. Observed categories include quest/dialog state, NPC interactions, player state, map/zone, selected chat system messages, group/world, inventory and display.

The source documents privacy filtering for potentially identifying chat payloads. Capture is local in the inspected code; export/reporting is a separate user action. This audit did not execute the addon, verify external reporting endpoints, or inspect every exporter path, so it is not a network/privacy guarantee.

## Design lessons

- Make capture opt-in and visibly show when active.
- Keep a bounded, versioned local event schema.
- Minimize collection and redact identity/chat data at capture time.
- Preview exact export contents and require explicit user action.
- Provide deletion/reset, retention limits and a clear event list.
- Keep diagnostics separate from core guide behavior; normal operation should not require uploaded traces.

For WildQuest, record only fields needed to address a concrete bug or improve a specific datum. Never include chat/group identity by default. Review consent and transport design separately if reporting is added.

## Licensing note

The uploaded QuestieTrace notice states GPLv3 for QuestieTrace, while bundled libraries keep their own licenses. This does not grant rights to Questie/QuestieDB datasets, names or logos. QuestieTrace source is not copied here.

## Reference

- [QuestieTrace source folder](https://github.com/Questie/Questie/tree/master/QuestieTrace)
