# Harry Potter Remaster (macOS)

Modern remake inspired by the Game Boy Color *Philosopher’s Stone* adventure — **not** a ROM hack. Built with **Godot 4.3+ (2D)** for native macOS first.

## Project path

```
game/
```

Open **`game/project.godot`** in Godot 4.3+.

## Year One demo flow

```
Main Menu → Privet Drive → Diagon Alley → Platform 9¾ → Black Lake / Express
  → Hogwarts Great Hall (Sorting locks house)
  → Forbidden Corridor (Fluffy → trapdoor → undercroft)
  → Undercroft stub (keys → chess → bottles → Mirror of Erised)
  → Charms / Defense / Potions (bridge tonic soft-helps undercroft)
```

GBC plot beat map: [`docs/gbc-plot-beat-map.md`](docs/gbc-plot-beat-map.md).  
Year One spell toolkit: [`docs/year-one-spells.md`](docs/year-one-spells.md).

| Feature | How |
|---------|-----|
| Move / talk / doors | WASD · **E** |
| Satchel | **I** |
| Spells | **1–3** starters · **4** Alohomora · **5** Incendio · **6** Protego · **7** Immobulus · **J** cast |
| **Save / Load** | **Esc** pause → Save / Load · Main Menu **Continue / Load** |
| Save file | `user://hp_remaster_slot0.json` (Godot user data dir on Mac) |

### Alohomora (Year One lock charm)
Great Hall → talk to **Hermione** (unlocks Alohomora, slot **4**). North corridors → cast **4+J** on the sealed latch to finish the Forbidden tease.

### Charms lesson
Great Hall **east** → Charms. Talk to Flitwick (unlocks Incendio), cast **5+J** on the candle.

### Defense lesson
Great Hall **west** → Defense. Talk to the professor (unlocks Protego + Immobulus). Use **6** Protego to block dummy lunges, **7** Immobulus to freeze, Flipendo/Incendio to finish. Saves with the rest.

### Potions lesson
Great Hall **southeast** → Potions. Talk to Snape, take asphodel + wormwood from shelves (**I** satchel), **Lumos** at the cauldron, then bottle the Herbology bridge tonic (`undercroft_tonic_ready`). No new spells.

### Undercroft (trapdoor stub)
Corridor trapdoor when `trapdoor_ready` (tonic optional). Chambers: flying keys (**Leviosa/Flipendo**) → chess shove (**Flipendo**) → logic bottles (**Lumos** or bridge tonic) → **Mirror of Erised** tease (`mirror_reached`). No final boss yet.

### Save location on Mac
With the editor: `~/Library/Application Support/Godot/app_userdata/Harry Potter Remaster/`  
Exported `.app`: `~/Library/Application Support/Harry Potter Remaster/` (or the bundle name variant). File: `hp_remaster_slot0.json`.

## How Matheus runs it on a Mac

1. Install [Godot 4.3+](https://godotengine.org/download).
2. Open `game/project.godot` → **F5** → **Begin Year One**.
3. **Esc** anytime in a room to save. Use **Continue / Load** on the title screen later.
4. Export: Manage Export Templates → **Project → Export…** → **macOS**.

```bash
godot --path game
godot --path game --export-release "macOS" build/macos/HarryPotterRemaster.app
```

Pixel art in `assets/pixel/` is original (deep greens, candle gold, night blues — no ROM tiles).

## Constraints

- Do **not** ship or rip assets from the reference GBC ROM.
- Fan / portfolio remake unless licensing changes.
