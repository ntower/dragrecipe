# DragRecipe

Drag profession recipe names to your action bars in WoW TBC Classic.

When you open a profession window (e.g. Tailoring, Enchanting), click and drag a recipe name—or the selected recipe icon at the bottom of the detail panel—to pick up the recipe spell on your cursor, then drop it onto an action bar.

## Installation

Copy the `DragRecipe` folder into your WoW `Interface/AddOns` directory, or install from CurseForge once published.

## Supported windows

- **Trade Skill** window (Tailoring, Blacksmithing, Alchemy, etc.) — `TradeSkillFrame`
- **Craft** window (Enchanting, Beast Training) — `CraftFrame`

## Development

```bash
npm test          # run unit tests (busted)
npm run check     # lint (luacheck)
```

See [TESTING.md](TESTING.md) and [LINTING.md](LINTING.md) for setup details.

## Release

Push a tag (`v1.0.0`) or use the GitHub Actions workflow dispatch to build and upload to CurseForge. Configure these repository settings:

- **Secret:** `CURSEFORGE_API_TOKEN`
- **Vars:** `CURSEFORGE_PROJECT_ID`, `CURSEFORGE_DISPLAY_NAME`
- **Workflow env:** `CURSEFORGE_GAME_VERSIONS` in `.github/workflows/release.yml` (CurseForge game version ID for TBC 2.5.6)

## License

Private / all rights reserved unless otherwise noted.
