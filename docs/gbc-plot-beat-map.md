# GBC Philosopher’s Stone vs Remaster — Plot Beat Map

**Purpose:** Align the remaster’s Year One hubs with the GBC adventure’s major location order (design reference only — no ROM text/assets).  
**Remaster engine:** Godot 4 2D · macOS-first.  
**Updated:** 2026-11-11 (Platform 9¾ + Forbidden Corridor fidelity chunk).

## Legend

| Status | Meaning |
|--------|---------|
| **In** | Playable hub in remaster |
| **Stub** | Present but thin |
| **Missing** | Not yet in remaster |
| **Diff** | Exists but order/role differs from GBC |

---

## Major beat comparison (order)

| # | GBC-style major beat | Remaster now | Gap |
|---|----------------------|--------------|-----|
| 1 | **Privet Drive** — letter, leave the Dursleys | **In** `privet_drive.tscn` | Short but objective-clear |
| 2 | **Diagon Alley** — shops, wand, gear | **In** `diagon_alley.tscn` | Gringotts / full shop quests still thin |
| 3 | **King’s Cross / Platform 9¾** — board the Express | **In** `platform_nine.tscn` | Express travel room still **Missing** |
| 4 | **Hogwarts Express** (travel beat) | **Missing** | Barrier dialogue stands in; optional later room |
| 5 | **Great Hall / Sorting arrival** | **In / Stub** `hogwarts_arrival.tscn` | Hat lean only — not full ceremony |
| 6 | **Hogwarts corridors** — navigate the castle | **In** `hogwarts_corridor.tscn` | Mid-castle hub toward Forbidden |
| 7 | **Classrooms** (Charms, Defense, …) | **In** Charms + Defense | Potions / Flying / History **Missing** |
| 8 | **Forbidden / Third-floor corridor** | **Stub** sealed door + prefect | Fluffy / trapdoor chain **Missing** |
| 9 | **Quidditch** | **Missing** | Optional per plan |
| 10 | **Detention / Forbidden Forest** | **Missing** | Later phase |
| 11 | **Under the trapdoor** (keys / chess / potions) | **Missing** | Phase 3 |
| 12 | **Mirror / climax** | **Missing** | Phase 3 |

---

## Playable spine (this chunk)

```
Main Menu
  → Privet Drive          (letter → Hagrid → gate)
  → Diagon Alley          (shopkeep → north to station)
  → Platform 9¾           (porter + barrier → Express door)
  → Hogwarts Great Hall   (Ron / Hermione / Hat · classes · corridors)
  → Hogwarts Corridors    (prefect + sealed Forbidden door)
  ↳ Charms / Defense      (side hubs from Hall)
```

### Gate flags (`GameState`)

| Flag | Set when | Unlocks |
|------|----------|---------|
| `left_privet` | Talk to Hagrid | Privet → Diagon |
| `talked_to_shopkeep` | Talk to shopkeep | Diagon → Platform |
| `boarded_express` | Run the 9¾ barrier | Platform → Hogwarts |
| `forbidden_tease_done` | Inspect sealed door | Objective advances (no new portal yet) |

Also tracked: `reached_platform`, `visited_corridor`, plus existing Hogwarts / lesson flags.

### Objective UX

Hubs surface a short **Next:** line (hint and/or objective label) so the player always knows the next GBC-style station — not a quest log, just station clarity.

---

## Dialogue tightening notes

- Privet / Diagon / Hall lines state the **route** (Diagon → 9¾ → Hogwarts → corridors), not flavor-only.
- Platform porter + barrier choices are the boarding beat.
- Corridor prefect + sealed door are the Year One “out of bounds” tease without opening Fluffy yet.
- No verbatim GBC cart strings; pacing and objective shape only.

---

## Highest-value missing (next chunks)

1. Express / lakeside arrival room (even one beat).
2. Full Sorting ceremony with house lock.
3. Potions classroom + light inventory craft.
4. Forbidden **puzzle gate** (Fluffy tease → trapdoor).
5. Stronger Diagon checklist (Gringotts → Ollivanders → gear).

---

## Constraints

- No ROM tile / audio / text dumps.
- Original dialogue inspired by GBC pacing and objectives, not cart strings.
- Pixel art: deep greens, candle gold, night blues.
