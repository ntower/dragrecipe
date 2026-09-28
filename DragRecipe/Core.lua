-- DragRecipe — Core: hook profession windows for drag-to-bar.

DragRecipe = DragRecipe or {}
DragRecipe.Version = "1.0.1"

local Logic = DragRecipe.Logic

local TRADE_SKILL_BUTTON_PREFIX = "TradeSkillSkill"
local CRAFT_BUTTON_PREFIX = "Craft"
local BUTTONS_DISPLAYED = 8

local function enableDragOnButton(button, context, getIndex, pickup)
    if not button or button._DragRecipeEnabled then
        return
    end
    if not getIndex then
        getIndex = function(self)
            return self:GetID()
        end
    end
    if not pickup then
        pickup = function(self)
            local index = getIndex(self)
            if not index or index <= 0 then
                return
            end
            Logic.PickupRecipeAt(context, index)
        end
    end
    button._DragRecipeEnabled = true
    button:RegisterForDrag("LeftButton")
    button:HookScript("OnDragStart", function(self)
        if InCombatLockdown and InCombatLockdown() then
            return
        end
        pickup(self)
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

-- WoW Forever uses retail's Blizzard_Professions window: recipe rows are pooled
-- buttons in a ScrollBox, so hook each row as it's initialized and read the
-- recipe from the row's element data at drag time.
local function getHighestLearnedRecipe()
    return Professions and Professions.GetHighestLearnedRecipe
end

local function enableProfessionsDrag()
    local craftingPage = ProfessionsFrame and ProfessionsFrame.CraftingPage
    if not craftingPage then
        return
    end

    local scrollBox = craftingPage.RecipeList and craftingPage.RecipeList.ScrollBox
    if scrollBox and ScrollUtil and ScrollUtil.AddInitializedFrameCallback then
        ScrollUtil.AddInitializedFrameCallback(scrollBox, function(_, button)
            enableDragOnButton(button, nil, nil, function(self)
                local node = self.GetElementData and self:GetElementData()
                local data = node and node.GetData and node:GetData()
                return Logic.PickupProfessionsRecipe(data and data.recipeInfo, getHighestLearnedRecipe())
            end)
        end, craftingPage, true)
    end

    local schematicForm = craftingPage.SchematicForm
    if schematicForm and schematicForm.OutputIcon then
        enableDragOnButton(schematicForm.OutputIcon, nil, nil, function()
            local recipeInfo = schematicForm.GetRecipeInfo and schematicForm:GetRecipeInfo()
            return Logic.PickupProfessionsRecipe(recipeInfo, getHighestLearnedRecipe())
        end)
    end
end

local function isAddOnLoaded(name)
    if C_AddOns and C_AddOns.IsAddOnLoaded then
        return C_AddOns.IsAddOnLoaded(name)
    end
    return IsAddOnLoaded and IsAddOnLoaded(name)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(_, _, addonName)
    if addonName == "Blizzard_Professions" then
        enableProfessionsDrag()
    elseif addonName == "Blizzard_TradeSkillUI" then
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

if isAddOnLoaded("Blizzard_Professions") then
    enableProfessionsDrag()
end
