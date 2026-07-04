# Linting and static analysis (Luacheck)

This project uses [Luacheck](https://github.com/lunarmodules/luacheck) for linting and static analysis of Lua code. Configuration is in [`.luacheckrc`](.luacheckrc) at the repo root.

## How it runs

**`npm run check`** (or **`npm run lint`**) runs Luacheck via a local runner:

- **Lua 5.1** from [Lua for Windows](https://github.com/rjpcomputing/luaforwindows) at `C:\Program Files (x86)\Lua\5.1` (or set `LUA_51_PATH`).
- **Luacheck** from the cloned source in `luacheck-src/` (no system-wide luacheck required).
- **argparse** is provided as `luacheck-src/argparse.lua`.

Install [Lua for Windows](https://github.com/rjpcomputing/luaforwindows) so the runner can find `lua.exe`. Copy `luacheck-src/` from `altarmy_tbc` or clone luacheck into that folder.

## Run Luacheck

From the project root:

```bash
npm run check
# or
npm run lint
```

To pass a different target or options:

```bash
node scripts/run-luacheck.js DragRecipe
```

Add any new WoW API or addon globals to `.luacheckrc` under `read_globals` or `globals` as needed.
