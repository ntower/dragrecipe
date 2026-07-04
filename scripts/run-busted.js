#!/usr/bin/env node
"use strict";
/**
 * Run busted (Lua unit tests) using Lua 5.1.
 * Uses vendored busted in busted-2.1.1/ (and deps: say, luassert, term stub).
 * Requires: Lua 5.1 at LUA_51_PATH (same as run-luacheck.js).
 * See TESTING.md for setup.
 */
const path = require("path");
const { execSync } = require("child_process");

const root = path.resolve(__dirname, "..");
const lua51Path =
  process.env.LUA_51_PATH || "C:\\Program Files (x86)\\Lua\\5.1";
const luaExe = path.join(lua51Path, "lua.exe");
const args = process.argv.slice(2);
const bustedArgs = args.length ? args : [];

const bootstrap = path.join(root, "scripts", "busted_bootstrap.lua");
try {
  const cmd = [
    `"${luaExe}"`,
    `"${bootstrap}"`,
    ...bustedArgs.map((a) => `"${a}"`),
  ].join(" ");
  execSync(cmd, { cwd: root, stdio: "inherit", shell: true });
} catch (e) {
  process.exit(e.status || 1);
}
