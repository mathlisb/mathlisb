# Year One Spell Toolkit — Remaster Retune

**Purpose:** Keep the spell bar Year-One-true (book/film + GBC shove tool) while ensuring every kept spell gates a puzzle or story beat.  
**Updated:** 2026-11-11

---

## Current inventory (before retune)

| Spell | Slot | Unlock | Mechanical use |
|-------|------|--------|----------------|
| Lumos | 1 | Starter | Toggle ambient light (Diagon / dark stretches) |
| Wingardium Leviosa | 2 | Starter | Lift crates |
| Flipendo | 3 | Starter | Shove props + light combat |
| Incendio | 4 | Charms lesson | Light practice candle |
| Protego | 5 | Defense lesson | Timed shield vs dummy |
| Immobulus | 6 | Defense lesson | Freeze dummy |

**Gap:** Alohomora (Year One classic) was missing. Remaster plan also listed Patronum as a late tool — that breaks Year One tone as a climax tool.

---

## Keep / cut / defer

| Spell | Decision | Why |
|-------|----------|-----|
| **Lumos** | **Keep** | Year One staple; gates dark-room readability |
| **Wingardium Leviosa** | **Keep** | Core Charms identity; gates crate puzzles |
| **Flipendo** | **Keep** | GBC-classic shove; still the remaster’s push/combat opener |
| **Alohomora** | **Add** | Book/film Year One unlock charm; gates locked corridor seal |
| **Incendio** | **Keep** | Taught in Charms; gates candle lesson |
| **Protego** | **Keep** | Basic Defense shield; gates surviving dummy lunges |
| **Immobulus** | **Keep** | Early Defense utility only — lesson-tied freeze, not mid-series power creep |
| Expecto Patronum | **Defer** | Not a Year One toolkit / climax spell here |
| Expelliarmus, Accio, Petrificus… | **Defer** | Later years or redundant with Flipendo/Immobulus |
| Unforgivables / dark curses | **Never** | Breaks tone and rating |

---

## Year One bar (after retune)

| Slot | Spell | Unlock | Gates |
|------|-------|--------|-------|
| 1 | **Lumos** | Starter (Diagon) | Dark ambient / corridor stretches |
| 2 | **Wingardium Leviosa** | Starter | Lift crates / float props |
| 3 | **Flipendo** | Starter | Shove blocks; damage dummy |
| 4 | **Alohomora** | Hermione (Great Hall) | Open the third-floor seal → reveals Fluffy / harp / trapdoor stub |
| 5 | **Incendio** | Charms (Flitwick) | Light the practice candle → charms lesson done |
| 6 | **Protego** | Defense lesson | Block dummy hits |
| 7 | **Immobulus** | Defense lesson | Freeze dummy mid-lunge |

No vanity spells: if it is on the bar, it opens, lights, lifts, shoves, kindles, shields, or freezes something the player needs.

---

## Lesson / story wiring

1. **Diagon** — practice 1–3; shopkeep points at the toolkit.
2. **Great Hall** — Sorting locks house; Hermione places **Alohomora** on the bar (Year One peer beat).
3. **Corridors** — sealed latch: inspect hints “locked”; cast Alohomora to set `forbidden_tease_done` and reveal Fluffy → trapdoor stub.
4. **Charms** — Flitwick unlocks **Incendio** (slot 5); candle still completes the lesson.
5. **Defense** — professor unlocks **Protego** (6) + **Immobulus** (7); dummy bout unchanged in spirit.
6. **Potions** — inventory craft only (asphodel + wormwood + **Lumos** at cauldron). No new spells; sets `undercroft_tonic_ready`.
7. **Undercroft** — Leviosa/Flipendo keys · Flipendo chess · Lumos (or tonic) bottles · Mirror look.
8. **Climax** — Protego / Immobulus / Flipendo (Incendio OK) vs Quirrell. **No Patronum.** Flags: `stone_secured`, `year_one_complete`.


---

## Explicitly out of Year One scope

- Patronum as combat/climax tool  
- Advanced DADA beyond basic shield + freeze  
- Unforgivables and gore-forward curses  
- Spell bloat that is not tied to a door, light, object, candle, or training bout  

See also: [`gbc-plot-beat-map.md`](./gbc-plot-beat-map.md), remaster plan spell table (updated to match this note).
