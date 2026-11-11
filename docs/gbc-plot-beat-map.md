# GBC Philosopher’s Stone vs Remaster — Plot Beat Map

**Purpose:** Align the remaster’s Year One hubs with the GBC adventure’s major location order (design reference only — no ROM text/assets).  
**Remaster engine:** Godot 4 2D · macOS-first.  
**Updated:** 2026-11-11 (undercroft stub: keys / chess / bottles / Mirror).

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
| 7 | **Classrooms** (Charms, Defense, Potions, …) | **In** Charms + Defense + Potions stub | Flying / History still **Missing** |
| 8 | **Forbidden / Third-floor corridor** | **In / Stub** Alohomora → Fluffy → trapdoor | Entry to undercroft |
| 9 | **Quidditch** | **Missing** | Optional per plan |
| 10 | **Detention / Forbidden Forest** | **Missing** | Later phase |
| 11 | **Under the trapdoor** (keys / chess / potions) | **In / Stub** three chambers | No full dungeon combat |
| 12 | **Mirror / climax** | **Stub** `undercroft_mirror.tscn` | Tease only — no Quirrell/Stone fight |

---

## Playable spine

```
Main Menu
  → Privet → Diagon → Platform 9¾ → Lakeside
  → Great Hall (Sorting · Alohomora · classes)
  → Forbidden Corridor (seal → Fluffy → trapdoor)
  → Undercroft: Keys → Chess → Logic bottles → Mirror
  ↳ Charms / Defense / Potions (tonic soft-helps bottles)
```

### Undercroft chamber gates (Year One spells only)

| Chamber | Tool | Flag |
|---------|------|------|
| Flying keys | Leviosa / Flipendo | `keys_chamber_done` |
| Chess aisle | Flipendo (Leviosa OK) | `chess_chamber_done` |
| Logic bottles | Lumos + safe brew **or** bridge tonic | `undercroft_logic_done` |
| Mirror of Erised | Look (E) | `mirror_reached` |

Soft gate: `trapdoor_ready` required to enter; `undercroft_tonic_ready` is optional prep / bottle shortcut.

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
| `trapdoor_ready` | Inspect / open trapdoor | Descent to undercroft keys |
| `potions_lesson_*` / `undercroft_tonic_ready` | Potions brew | Soft prep + bottle shortcut |
| `undercroft_entered` | Enter keys chamber | Progress marker |
| `keys_chamber_done` / `chess_chamber_done` / `undercroft_logic_done` | Clear each room | Chain forward |
| `mirror_reached` | Look into Mirror | Year One climax tease complete |

### Spell toolkit (Year One)

See [`year-one-spells.md`](./year-one-spells.md). No Patronum / late-series curses in undercroft.

---

## Highest-value missing (next chunks)

1. Mirror climax / Stone confrontation (consume `mirror_reached`).
2. Stronger Diagon checklist (Gringotts → Ollivanders → gear).
3. Quidditch decision (ship or skip).
4. Flying / History classrooms.

---

## Constraints

- No ROM tile / audio / text dumps.
- Original dialogue inspired by GBC pacing and objectives, not cart strings.
- Pixel art: deep greens, candle gold, night blues.
