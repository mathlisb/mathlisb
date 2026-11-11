# GBC Philosopher’s Stone vs Remaster — Plot Beat Map

**Purpose:** Align the remaster’s Year One hubs with the GBC adventure’s major location order (design reference only — no ROM text/assets).  
**Remaster engine:** Godot 4 2D · macOS-first.  
**Updated:** 2026-11-11 (spell retune + Express / Sorting / Fluffy spine).

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
| 3 | **King’s Cross / Platform 9¾** — board the Express | **In** `platform_nine.tscn` | Barrier + porter |
| 4 | **Hogwarts Express / lakeside arrival** | **In** `lakeside_arrival.tscn` | Carriage + boats; no long travel sim |
| 5 | **Great Hall / Sorting** | **In** `hogwarts_arrival.tscn` | Full ceremony **locks** `sorted_house` |
| 6 | **Hogwarts corridors** | **In** `hogwarts_corridor.tscn` | Gated on `house_locked` |
| 7 | **Classrooms** (Charms, Defense, …) | **In** Charms + Defense | Potions / Flying / History **Missing** |
| 8 | **Forbidden / Third-floor corridor** | **In / Stub** Alohomora seal → Fluffy → trapdoor | Flags undercroft; no dungeon dive yet |
| 9 | **Quidditch** | **Missing** | Optional per plan |
| 10 | **Detention / Forbidden Forest** | **Missing** | Later phase |
| 11 | **Under the trapdoor** (keys / chess / potions) | **Missing** | `trapdoor_ready` set; content later |
| 12 | **Mirror / climax** | **Missing** | Phase 3 |

---

## Playable spine

```
Main Menu
  → Privet Drive
  → Diagon Alley
  → Platform 9¾
  → Black Lake / Express arrival
  → Hogwarts Great Hall            ← Sorting locks house · Hermione → Alohomora
  → Forbidden Corridor             ← Alohomora seal → Fluffy + trapdoor stub
  ↳ Charms / Defense
```

### Gate flags (`GameState`)

| Flag | Set when | Unlocks / meaning |
|------|----------|-------------------|
| `left_privet` | Talk to Hagrid | Privet → Diagon |
| `talked_to_shopkeep` | Talk to shopkeep | Diagon → Platform |
| `boarded_express` | Run the 9¾ barrier | Platform → Lakeside |
| `visited_express` / `lakeside_arrived` | Enter lakeside hub | Progress markers |
| `house_locked` + `sorted_house` | Sorting Hat ceremony | Hall → Corridors |
| `forbidden_tease_done` | Cast **Alohomora** on sealed latch | Reveals Fluffy / harp / trapdoor |
| `fluffy_teased` | Talk to Fluffy | Enables meaningful trapdoor |
| `trapdoor_ready` | Inspect trapdoor | Undercroft flagged for later |

### Sorting

- Ceremony choices apply affinity **and** `lock_house` to the chosen house string.
- Affinity house bumps no-op once `house_locked` is true.
- UI shows locked house via `house_display()` / status line.

### Objective UX

Hubs keep a short **Next:** line so the player always knows the next GBC-style station.

### Spell toolkit (Year One)

See [`year-one-spells.md`](./year-one-spells.md). Bar: Lumos · Leviosa · Flipendo · **Alohomora** (Hermione → corridor seal) · Incendio (Charms) · Protego / Immobulus (Defense). Patronum and late-series curses deferred.

---

## Highest-value missing (next chunks)

1. Undercroft dungeon start (consume `trapdoor_ready`).
2. Potions classroom + light inventory craft.
3. Stronger Diagon checklist (Gringotts → Ollivanders → gear).
4. Quidditch decision (ship or skip).

---

## Constraints

- No ROM tile / audio / text dumps.
- Original dialogue inspired by GBC pacing and objectives, not cart strings.
- Pixel art: deep greens, candle gold, night blues.
