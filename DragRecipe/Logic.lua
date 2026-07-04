-- DragRecipe — Pure logic for recipe link parsing and spell pickup.

DragRecipe = DragRecipe or {}
DragRecipe.Logic = DragRecipe.Logic or {}

local Logic = DragRecipe.Logic

--- Extract spell ID from a TBC tradeskill/craft recipe link.
--- Recipe links use enchant: or spell: format.
--- @param link string|nil
--- @return number|nil
function Logic.GetSpellIDFromRecipeLink(link)
    if type(link) ~= "string" or link == "" then
        return nil
    end
    local spellID = string.match(link, "enchant:(%d+)")
        or string.match(link, "spell:(%d+)")
    if spellID then
        return tonumber(spellID)
    end
    return nil
end

--- Pick up a recipe spell at the given tradeskill/craft index.
--- @param context string "trade" or "craft"
--- @param index number
--- @return boolean true if PickupSpell was called
function Logic.PickupRecipeAt(context, index)
    if not PickupSpell or not index or index <= 0 then
        return false
    end

    if context == "trade" and GetTradeSkillInfo then
        local _, skillType = GetTradeSkillInfo(index)
        if not skillType or skillType == "header" then
            return false
        end
    elseif context == "craft" and GetCraftInfo then
        local _, _, craftType = GetCraftInfo(index)
        if not craftType or craftType == "header" then
            return false
        end
    else
        return false
    end

    local link
    if context == "trade" and GetTradeSkillRecipeLink then
        link = GetTradeSkillRecipeLink(index)
    elseif context == "craft" and GetCraftRecipeLink then
        link = GetCraftRecipeLink(index)
    else
        return false
    end

    local spellID = Logic.GetSpellIDFromRecipeLink(link)
    if not spellID then
        return false
    end

    PickupSpell(spellID)
    return true
end
