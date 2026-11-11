# Harry Potter Remaster (macOS)

Modern remake inspired by the Game Boy Color *Philosopher’s Stone* adventure — **not** a ROM hack. Built with **Godot 4.3+ (2D)** for native macOS first.

Design plan (Project store): see coordinator docs / `remaster-plan.md`.

## Project path

```
game/
```

Open **`game/project.godot`** in the Godot Editor (4.3 or newer recommended).

## What runs today (scaffold)

| Scene | Path | Notes |
|-------|------|--------|
| Main menu | `game/scenes/main_menu.tscn` | Brand + **Enter Diagon Alley** |
| Diagon Alley | `game/scenes/diagon_alley.tscn` | Placeholder outdoor street, shops, shopkeep |
| Player | `game/characters/player.tscn` | WASD / arrows move |
| Dialogue UI | `game/ui/dialogue_ui.tscn` | Parchment stub (`E` / Space) |
| Spell HUD + FX | `game/ui/spell_hud.tscn`, `game/scenes/spell_fx.tscn` | **1** Lumos · **2** Leviosa · **3** Flipendo · **J** / click cast |

**Controls:** WASD or arrows · `E` / Space interact · `1`–`3` select spell · `J` or LMB cast.

Art placeholders under `game/assets/placeholders/` are **original** (no ROM tiles/audio/text). Palette: deep greens, candle gold, night blues.

## Open in Godot

1. Install [Godot 4.3+](https://godotengine.org/download) (standard build is fine).
2. **Project → Import** → select `game/project.godot` (or drag the `game/` folder onto the Project Manager).
3. Press **F5** (Play). Main menu should appear; **Enter Diagon Alley** loads the slice.

## Export for macOS (on a Mac)

1. In Godot: **Editor → Manage Export Templates…** → download templates matching your Godot version.
2. **Project → Export…** → preset **macOS** (already in `game/export_presets.cfg`).
3. Confirm:
   - **Bundle Identifier:** `com.mathlisb.harrypotterremaster`
   - **Architecture:** `universal` (Apple Silicon + Intel)
   - **Export path:** `../build/macos/HarryPotterRemaster.app` (create `build/macos/` if needed)
4. Click **Export Project**.
5. For distribution outside your machine: add Apple Developer signing + notarization in the preset (Codesign / Notarization sections). Local playtesting can run unsigned with a right-click → Open the first time.

### CLI export (optional)

```bash
godot --path game --export-release "macOS" build/macos/HarryPotterRemaster.app
```

## Repo layout

```
game/
  project.godot
  export_presets.cfg
  scenes/          # main_menu, diagon_alley, spell_fx
  characters/      # player
  ui/              # dialogue + spell HUD
  scripts/         # GDScript stubs
  autoload/        # SpellBook, GameState
  assets/placeholders/
  theme/           # ArtDirection palette constants
  tools/           # optional screenshot helper
```

## Constraints

- Do **not** ship or rip assets from the reference GBC ROM.
- Fan / portfolio remake unless licensing changes.
