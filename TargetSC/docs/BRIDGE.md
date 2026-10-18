# Skillchains → TargetSC interface v1

Owner: Skillchains `targetsc_bridge.lua`; receiver: TargetSC `resonance.lua`.
All transport stays inside one Windower process. Each addon has its own Lua
state, so plain Lua tables/globals are not assumed shared. The documented
Windower `lua i <addon> ...` command dispatches messages at transitions only.
No custom undocumented Windower event API is assumed.

## Subscription and lifecycle

TargetSC requests `lua i Skillchains targetsc subscribe`. The publisher emits
`online`, all nonexpired states as snapshots, then `synced`. It publishes a
single `state` for each new opener/extension, `burst` for confirmed MB actions,
`expire` during its existing cleanup, `reset` for zone/logout and `offline` on
unload. `unsubscribe` stops delivery. Skillchains load emits one `_ready`
notification so a running companion can resubscribe. An absent TargetSC has no
rendering/native dependency in Skillchains; no probe runs every frame.

No event is sent on each countdown tick or movement frame. Native drawing uses
direct Lua C functions and cannot broadcast combat state to another client.
The subscriber receives every newly tracked enemy state, but draws only the
current living enemy selected by the same `t`/`bt` preference. Switching back
uses the original absolute deadlines and cannot replay the strike.

## Envelope

```text
lua i TargetSC _event 1 <session> <sequence> <kind> <source_clock> [fields...]
```

Session: numeric time/clock token, replaced on source reload. Sequence increments
within the publisher session. Source clock and deadlines use the same LuaCore
`os.clock()` in the same process, serialized to six decimal places. Receiver
clock deltas are diagnostics; it does not recalculate combat durations. Receipt
latency does not restart a window. Snapshot responses increment sequence too.
The receiver rejects duplicates and detects gaps, requesting a fresh snapshot.
All tokens are numeric or enumerated property/element names: no Lua evaluation,
user text, quotes or console separators enter the wire.

| Kind | Fields after source_clock |
| --- | --- |
| `online`, `synced`, `offline` | none |
| `state` | enemy_id revision created sc_open sc_close mb_close step resolved_level closed properties_csv elements_csv snapshot |
| `burst` | enemy_id element spell_or_action_id resource |
| `expire` | enemy_id |
| `reset` | zone or logout |

`closed` and `snapshot` are 0/1. `mb_close=0` means no burst opportunity.
`sc_open=state.delay`, `sc_close=state.times`, `mb_close=state.mb_window` are
copied exactly. The existing resolver's `result_level` is metadata only; it
does not change active properties or the bar's timer math. The publisher
assigns a revision and created time when Skillchains applies new properties;
a snapshot retains them rather than retriggering animation.

## Confirmed bursts

The bridge observes known Magic Burst action message IDs in Skillchains'
existing `ActionPacket` callback before its existing category filtering.
Messages: 252,265,268,269,271,272,274,275,379,650,747–755,803,804.
Source: Windower/Resources `resources_data/action_messages.lua`, inspected
2026-10-18. Ordinary damage never counts. AoE targets are enumerated and one
event is sent per target per action packet, even if several hits report MB.
For category 4, `res.spells[act.param].element` maps to Windower resource element
IDs 0–7. Other/missing elements publish `Unknown`; TargetSC counts/skips their
flash instead of guessing from a skillchain's eligible elements.

**No burst mutates resonating, created, revision, sc_open, sc_close or mb_close.**
A burst renders only against a tracked source state whose MB deadline has not
passed. Late packets are bounded by their receipt timestamp; no independent
MB-duration calculation exists in TargetSC. The source's inherited 10-second
MB model remains provisional, exactly as recorded in Skillchains' historical
TESTING.md. Improving it belongs in Skillchains after live evidence.

## Known scope

Existing Skillchains chain detection inspects its original first target/action;
that behavior is deliberately preserved. Only the new confirmed-burst observer
walks all targets. Combat inference is never duplicated in TargetSC. Events
remain an optional companion seam suitable for an eventual in-addon event sink.
