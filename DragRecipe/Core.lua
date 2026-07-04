-- DragRecipe — Core: hook profession windows for drag-to-bar.

DragRecipe = DragRecipe or {}
DragRecipe.Version = "1.0.0"

local Logic = DragRecipe.Logic

local TRADE_SKILL_BUTTON_PREFIX = "TradeSkillSkill"
local CRAFT_BUTTON_PREFIX = "Craft"
local BUTTONS_DISPLAYED = 8

local function enableDragOnButton(button, context, getIndex)
    if not button or button._DragRecipeEnabled then
        return
    end
    if not getIndex then
        getIndex = function(self)
            return self:GetID()
        end
    end
    button._DragRecipeEnabled = true
    button:RegisterForDrag("LeftButton")
    button:HookScript("OnDragStart", function(self)
        if InCombatLockdown and InCombatLockdown() then
            return
        end
        local index = getIndex(self)
        if not index or index <= 0 then
            return
        end
        Logic.PickupRecipeAt(context, index)
    end)
end

local function enableTradeSkillDrag()
    for i = 1, BUTTONS_DISPLAYED do
        enableDragOnButton(_G[TRADE_SKILL_BUTTON_PREFIX .. i], "trade")
    end
    enableDragOnButton(_G.TradeSkillSkillIcon, "trade", function()
        if GetTradeSkillSelectionIndex then
            return GetTradeSkillSelectionIndex()
        end
        return nil
    end)
end

local function enableCraftDrag()
    for i = 1, BUTTONS_DISPLAYED do
        enableDragOnButton(_G[CRAFT_BUTTON_PREFIX .. i], "craft")
    end
    enableDragOnButton(_G.CraftIcon, "craft", function()
        if GetCraftSelectionIndex then
            return GetCraftSelectionIndex()
        end
        return nil
    end)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(_, _, addonName)
    if addonName == "Blizzard_TradeSkillUI" then
        enableTradeSkillDrag()
        if hooksecurefunc then
            hooksecurefunc("TradeSkillFrame_Update", enableTradeSkillDrag)
        end
    elseif addonName == "Blizzard_CraftUI" then
        enableCraftDrag()
        if hooksecurefunc then
            hooksecurefunc("CraftFrame_Update", enableCraftDrag)
        end
    end
end)
