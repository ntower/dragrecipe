# Unit testing with Busted

This project uses [busted](https://lunarmodules.github.io/busted/) for Lua unit tests.

## Prerequisites

- **Lua 5.1** — same as for luacheck (e.g. [Lua for Windows](https://github.com/rjpcomputing/luaforwindows) at `C:\Program Files (x86)\Lua\5.1`, or set `LUA_51_PATH`).

Busted and its Lua dependencies are **vendored** in `busted-2.1.1/` (copied from a sibling project or set up per the steps below).

## Setup (first time or after clone)

From the project root, create the vendored busted tree so `npm test` works.

1. **Download busted and extract**
   - Get [busted v2.1.1](https://github.com/lunarmodules/busted/archive/refs/tags/v2.1.1.zip) and extract so the top-level folder is named `busted-2.1.1`.

2. **Add Lua dependencies into `busted-2.1.1/`**
   - **say** — [say v1.4.1](https://github.com/lunarmodules/say/archive/refs/tags/v1.4.1.zip): copy `say/` from `say-1.4.1/src/` into `busted-2.1.1/`.
   - **luassert** — [luassert v1.9.0](https://github.com/lunarmodules/luassert/archive/refs/tags/v1.9.0.zip): copy all of `luassert-1.9.0/src/` into `busted-2.1.1/luassert/`.
   - **mediator_lua** — copy `mediator_lua-master/src/mediator.lua` into `busted-2.1.1/`.

3. **Add stubs in `busted-2.1.1/`**
   - **term.lua** — returns `{ isatty = function() return false end }`.
   - **system.lua** — returns `{ gettime = os.time, monotime = os.clock, sleep = function() end }`.

Alternatively, copy `busted-2.1.1/` from the `altarmy_tbc` project if you have it locally.

## Run tests

```bash
npm test
```

Tests live in `spec/` (outside the addon zip so they are not shipped). Pass extra busted options:

```bash
npm test -- --verbose
npm test -- spec/Logic_spec.lua
```

## Writing tests

Name specs `*_spec.lua` and use `describe` / `it` with `assert`. Mock WoW globals on `_G` in `setup` or `before_each`.

See the [busted overview](https://lunarmodules.github.io/busted/#overview) for more.
