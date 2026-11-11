# Harry Potter Remaster (macOS)

Modern remake inspired by the Game Boy Color *Philosopher’s Stone* adventure — **not** a ROM hack. Built with **Godot 4.3+ (2D)** for native macOS first.

## Project path

```
game/
```

Open **`game/project.godot`** in Godot 4.3+.

## Year One story flow (current)

```
Main Menu → Privet Drive → Diagon Alley → Hogwarts (Great Hall stub)
```

| Room | What to do |
|------|------------|
| **Privet Drive** | Read the letter (choice → house lean) · talk to Hagrid (choice) · garden gate unlocks Diagon Alley |
| **Diagon Alley** | Shopkeep + spells · after talking, north door → Hogwarts · south returns to Privet |
| **Hogwarts** | Talk to Ron / Hermione (trust flags) · Sorting Hat whispers house lean · door back to Diagon |

### Controls

| Action | Keys |
|--------|------|
| Move | WASD / arrows |
| Talk / continue / enter door | **E** / Space |
| Dialogue choices | Click a reply (or focus + Enter) |
| Satchel | **I** |
| Spells | **1** Lumos · **2** Leviosa · **3** Flipendo · **J** / LMB cast |

Light RPG flags live in `GameState` (house affinity, Ron/Hermione trust, story visited flags).

Pixel art under `assets/pixel/` is **original** (deep greens, candle gold, night blues — no ROM tiles).

### Art on Mac
Nearest filter on sprites. If blurry: texture Import → Filter Off → Reimport. Sheets: `player_sheet.png`, `shopkeep_sheet.png`.

## How Matheus runs it on a Mac

1. Install [Godot 4.3+](https://godotengine.org/download) (standard / non-.NET).
2. Open **`game/project.godot`**.
3. Press **F5** → **Begin Year One** (Privet Drive).
4. Optional export: Manage Export Templates → **Project → Export…** → **macOS** → `build/macos/HarryPotterRemaster.app`.

```bash
godot --path game
godot --path game --export-release "macOS" build/macos/HarryPotterRemaster.app
```

## Repo layout

```
game/
  scenes/     # main_menu, privet_drive, diagon_alley, hogwarts_arrival, portals…
  autoload/   # Inventory, SpellBook, GameState (story + RPG flags)
  assets/pixel/
  ui/         # dialogue (with choices), satchel, spell HUD
```

## Constraints

- Do **not** ship or rip assets from the reference GBC ROM.
- Fan / portfolio remake unless licensing changes.
