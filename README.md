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
  → Forbidden Corridor (Fluffy → trapdoor flag for undercroft)
  → Charms Classroom (Incendio)
  → Defense Classroom (Protego / Immobulus + dummy)
```

GBC plot beat map: [`docs/gbc-plot-beat-map.md`](docs/gbc-plot-beat-map.md).

| Feature | How |
|---------|-----|
| Move / talk / doors | WASD · **E** |
| Satchel | **I** |
| Spells | **1–3** starters · **4** Incendio · **5** Protego · **6** Immobulus · **J** cast |
| **Save / Load** | **Esc** pause → Save / Load · Main Menu **Continue / Load** |
| Save file | `user://hp_remaster_slot0.json` (Godot user data dir on Mac) |

### Charms lesson
Great Hall **east** → Charms. Talk to Flitwick (unlocks Incendio), cast **4+J** on the candle.

### Defense lesson
Great Hall **west** → Defense. Talk to the professor (unlocks Protego + Immobulus). Use **5** Protego to block dummy lunges, **6** Immobulus to freeze, Flipendo/Incendio to finish. Saves with the rest.

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
