-- Luacheck config for DragRecipe (WoW TBC Classic addon).
-- See https://luacheck.readthedocs.io/

std = "lua51"
self = false

exclude_files = {
    "DragRecipe/Libs",
}

globals = {
    "DragRecipe",
}

read_globals = {
    "CreateFrame",
    "_G",
    "hooksecurefunc",
    "InCombatLockdown",
    "PickupSpell",
    "GetTradeSkillRecipeLink",
    "GetCraftRecipeLink",
    "GetTradeSkillInfo",
    "GetCraftInfo",
    "GetTradeSkillSelectionIndex",
    "GetCraftSelectionIndex",
    "TradeSkillSkillIcon",
    "CraftIcon",
    "TradeSkillFrame_Update",
    "CraftFrame_Update",
}

files = {
    ["spec/**/*_spec.lua"] = {
        read_globals = {
            "describe",
            "it",
            "setup",
            "teardown",
            "pending",
            "context",
            "insulate",
            "expose",
        },
        ignore = { "143" },
    },
}
