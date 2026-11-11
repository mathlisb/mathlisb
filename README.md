# Harry Potter Remaster (macOS)

Modern remake inspired by the Game Boy Color *Philosopher’s Stone* adventure — **not** a ROM hack. Built with **Godot 4.3+ (2D)** for native macOS first.

## Project path

```
game/
```

Open **`game/project.godot`** in Godot 4.3+.

## Diagon Alley vertical slice (current)

Playable loop on macOS via the editor (or exported `.app`):

| Feature | How |
|---------|-----|
| Move | WASD / arrow keys |
| Talk | Walk to shopkeep near Ollivanders · **E** / Space |
| Dialogue | **E** / Space advances lines |
| Inventory | **I** opens satchel (wand, letter, knuts) · Esc / I closes |
| Spells | **1** Lumos · **2** Leviosa · **3** Flipendo · **J** or LMB cast |
| Feedback | Lumos brightens the street + wand glow; Leviosa lifts crate/barrel; Flipendo shoves them |

Scenes: `scenes/main_menu.tscn` → `scenes/diagon_alley.tscn`.

Pixel art under `assets/pixel/` is **original** (deep greens, candle gold, night blues — no ROM tiles). Legacy stubs remain in `assets/placeholders/` unused by the slice.

### Art on Mac
Godot imports PNGs with **Nearest** filter (set on sprites). If new sheets look blurry: select the texture → Import → Filter Off → Reimport. Player / shopkeep sheets are sliced in script from `player_sheet.png` / `shopkeep_sheet.png` (32×32 frames).

## How Matheus runs it on a Mac

1. Install [Godot 4.3+](https://godotengine.org/download) (standard / non-.NET is fine).
2. Clone this repo and open **`game/project.godot`** (Project Manager → Import, or drag `game/`).
3. Press **F5**. Click **Enter Diagon Alley**.
4. Optional export: **Editor → Manage Export Templates** → download matching templates → **Project → Export…** → preset **macOS** → export to `build/macos/HarryPotterRemaster.app`.
   - Bundle id: `com.mathlisb.harrypotterremaster`
   - Architecture: `universal`
   - First unsigned launch: right-click the `.app` → Open.

```bash
# From repo root, if `godot` is on PATH:
godot --path game
godot --path game --export-release "macOS" build/macos/HarryPotterRemaster.app
```

## Repo layout

```
game/
  project.godot
  export_presets.cfg
  scenes/          # main_menu, diagon_alley, spell_fx, spellable_prop
  characters/      # player
  ui/              # dialogue, spell HUD, inventory
  scripts/
  autoload/        # Inventory, SpellBook, GameState
  assets/placeholders/
  theme/
  tools/
```

## Constraints

- Do **not** ship or rip assets from the reference GBC ROM.
- Fan / portfolio remake unless licensing changes.
