# GBC Philosopher’s Stone vs Remaster — Plot Beat Map

**Purpose:** Align the remaster’s Year One hubs with the GBC adventure’s major location order (design reference only — no ROM text/assets).  
**Remaster engine:** Godot 4 2D · macOS-first.  
**Updated:** 2026-11-11 (Year One climax: Mirror → Quirrell/Stone stub).

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
| 1 | **Privet Drive** | **In** | Short intro |
| 2 | **Diagon Alley** | **In** | Shops still thin |
| 3 | **Platform 9¾** | **In** | — |
| 4 | **Express / lakeside** | **In** | Brief |
| 5 | **Great Hall / Sorting** | **In** | House lock |
| 6 | **Corridors** | **In** | — |
| 7 | **Classrooms** | **In** Charms / Defense / Potions | Flying / History missing |
| 8 | **Forbidden corridor** | **In / Stub** | Alohomora → Fluffy → trapdoor |
| 9 | **Quidditch** | **Missing** | Optional |
| 10 | **Forest / detention** | **Missing** | Later |
| 11 | **Under the trapdoor** | **In / Stub** | Keys · chess · bottles |
| 12 | **Mirror / Quirrell / Stone** | **In / Stub** | Protego fight; no Patronum; short epilogue |

Book-shaped climax staging (original dialogue): Mirror wish → Quirrell demands the Stone → first-year Defense toolkit wins → Stone secured → Hall return.

---

## Playable spine

```
… → Forbidden Corridor → Undercroft
  → Keys → Chess → Logic bottles
  → Mirror of Erised (mirror_reached)
  → Quirrell / Stone vault (stone_secured · year_one_complete)
  → Great Hall
```

### Climax combat (Year One only)

| Tool | Role |
|------|------|
| Protego (6) | Block Quirrell lunges |
| Immobulus (7) | Freeze window |
| Flipendo (3) / Incendio (5) | Damage |
| — | No Patronum |

### Key flags

| Flag | Meaning |
|------|---------|
| `mirror_reached` | Looked into Erised; climax path open |
| `quirrell_defeated` | Combat won |
| `stone_secured` | Stone out of Quirrell's hands |
| `year_one_complete` | Epilogue + Hall portal |

See [`year-one-spells.md`](./year-one-spells.md).

---

## Highest-value missing (next chunks)

1. Richer Quirrell/Stone presentation (still stub-scale).
2. Diagon checklist depth.
3. Quidditch decision.
4. Flying / History classrooms.

---

## Constraints

- No ROM dumps; no copyrighted book prose — original lines only.
- Year One spell bar only.
