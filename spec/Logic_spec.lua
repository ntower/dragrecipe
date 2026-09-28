--[[
  Unit tests for Logic.lua (recipe link parsing and PickupRecipeAt).
  Run from project root: npm test
]]

describe("Logic", function()
  local Logic

  setup(function()
    _G.DragRecipe = _G.DragRecipe or {}
    package.path = package.path .. ";DragRecipe/?.lua"
    require("Logic")
    Logic = DragRecipe.Logic
  end)

  describe("GetSpellIDFromRecipeLink", function()
    it("extracts spell ID from enchant recipe link", function()
      local link = "|Henchant:27960|h[Enchant Bracer - Superior Healing]|h|r"
      assert.are.equal(27960, Logic.GetSpellIDFromRecipeLink(link))
    end)

    it("extracts spell ID from spell recipe link", function()
      local link = "|Hspell:13635|h[Enchant Bracer - Lesser Spirit]|h|r"
      assert.are.equal(13635, Logic.GetSpellIDFromRecipeLink(link))
    end)

    it("returns nil for nil link", function()
      assert.is_nil(Logic.GetSpellIDFromRecipeLink(nil))
    end)

    it("returns nil for empty link", function()
      assert.is_nil(Logic.GetSpellIDFromRecipeLink(""))
    end)

    it("returns nil for malformed link", function()
      assert.is_nil(Logic.GetSpellIDFromRecipeLink("|Hitem:12345|h[Not a recipe]|h|r"))
    end)
  end)

  describe("PickupRecipeAt", function()
    local pickupCalled
    local pickupSpellID

    before_each(function()
      pickupCalled = false
      pickupSpellID = nil
      _G.PickupSpell = function(spellID)
        pickupCalled = true
        pickupSpellID = spellID
      end
    end)

    it("picks up trade skill recipe by index", function()
      _G.GetTradeSkillInfo = function(index)
        if index == 3 then
          return "Enchant Bracer - Superior Healing", "optimal"
        end
        return nil, "header"
      end
      _G.GetTradeSkillRecipeLink = function(index)
        if index == 3 then
          return "|Henchant:27960|h[Enchant Bracer - Superior Healing]|h|r"
        end
        return nil
      end

      local ok = Logic.PickupRecipeAt("trade", 3)
      assert.is_true(ok)
      assert.is_true(pickupCalled)
      assert.are.equal(27960, pickupSpellID)
    end)

    it("picks up craft recipe by index", function()
      _G.GetCraftInfo = function(index)
        if index == 5 then
          return "Enchant Bracer - Lesser Spirit", nil, "optimal"
        end
        return nil, nil, "header"
      end
      _G.GetCraftRecipeLink = function(index)
        if index == 5 then
          return "|Henchant:13635|h[Enchant Bracer - Lesser Spirit]|h|r"
        end
        return nil
      end

      local ok = Logic.PickupRecipeAt("craft", 5)
      assert.is_true(ok)
      assert.is_true(pickupCalled)
      assert.are.equal(13635, pickupSpellID)
    end)

    it("returns false when recipe link is missing", function()
      _G.GetTradeSkillInfo = function()
        return "Some Recipe", "optimal"
      end
      _G.GetTradeSkillRecipeLink = function()
        return nil
      end

      local ok = Logic.PickupRecipeAt("trade", 1)
      assert.is_false(ok)
      assert.is_false(pickupCalled)
    end)

    it("returns false when link has no spell ID", function()
      _G.GetTradeSkillInfo = function()
        return "Some Recipe", "optimal"
      end
      _G.GetTradeSkillRecipeLink = function()
        return "|Hitem:12345|h[Not a recipe]|h|r"
      end

      local ok = Logic.PickupRecipeAt("trade", 1)
      assert.is_false(ok)
      assert.is_false(pickupCalled)
    end)

    it("returns false for unknown context", function()
      local ok = Logic.PickupRecipeAt("unknown", 1)
      assert.is_false(ok)
      assert.is_false(pickupCalled)
    end)

    it("returns false for category header rows", function()
      _G.GetTradeSkillInfo = function()
        return "Daggers", "header"
      end
      _G.GetTradeSkillRecipeLink = function()
        return "|Henchant:27960|h[Enchant Bracer - Superior Healing]|h|r"
      end

      local ok = Logic.PickupRecipeAt("trade", 1)
      assert.is_false(ok)
      assert.is_false(pickupCalled)
    end)

    it("returns false when PickupSpell is unavailable", function()
      _G.GetTradeSkillInfo = function()
        return "Some Recipe", "optimal"
      end
      _G.PickupSpell = nil
      _G.GetTradeSkillRecipeLink = function()
        return "|Henchant:27960|h[Enchant Bracer - Superior Healing]|h|r"
      end

      local ok = Logic.PickupRecipeAt("trade", 1)
      assert.is_false(ok)
    end)
  end)

  describe("PickupSpellByID", function()
    after_each(function()
      _G.PickupSpell = nil
      _G.C_Spell = nil
    end)

    it("uses the global PickupSpell when present (TBC)", function()
      local picked
      _G.PickupSpell = function(spellID) picked = spellID end
      _G.C_Spell = { PickupSpell = function() error("should not be called") end }

      assert.is_true(Logic.PickupSpellByID(3275))
      assert.are.equal(3275, picked)
    end)

    it("falls back to C_Spell.PickupSpell (WoW Forever)", function()
      local picked
      _G.PickupSpell = nil
      _G.C_Spell = { PickupSpell = function(spellID) picked = spellID end }

      assert.is_true(Logic.PickupSpellByID(3275))
      assert.are.equal(3275, picked)
    end)

    it("returns false when no pickup API exists", function()
      assert.is_false(Logic.PickupSpellByID(3275))
    end)

    it("returns false for nil spell ID", function()
      _G.C_Spell = { PickupSpell = function() error("should not be called") end }
      assert.is_false(Logic.PickupSpellByID(nil))
    end)
  end)

  describe("PickupProfessionsRecipe", function()
    local picked

    before_each(function()
      picked = nil
      _G.PickupSpell = nil
      _G.C_Spell = { PickupSpell = function(spellID) picked = spellID end }
    end)

    after_each(function()
      _G.C_Spell = nil
    end)

    it("picks up a learned recipe by recipeID", function()
      assert.is_true(Logic.PickupProfessionsRecipe({ recipeID = 2963, learned = true }))
      assert.are.equal(2963, picked)
    end)

    it("does not pick up an unlearned recipe", function()
      assert.is_false(Logic.PickupProfessionsRecipe({ recipeID = 2963, learned = false }))
      assert.is_nil(picked)
    end)

    it("returns false for nil or malformed recipeInfo", function()
      assert.is_false(Logic.PickupProfessionsRecipe(nil))
      assert.is_false(Logic.PickupProfessionsRecipe("not a table"))
      assert.is_false(Logic.PickupProfessionsRecipe({ learned = true }))
      assert.is_nil(picked)
    end)

    it("picks up the highest learned rank when a resolver is given", function()
      local rank1 = { recipeID = 100, learned = true }
      local rank2 = { recipeID = 200, learned = true }
      local function getHighestLearned(info)
        assert.are.equal(rank1, info)
        return rank2
      end

      assert.is_true(Logic.PickupProfessionsRecipe(rank1, getHighestLearned))
      assert.are.equal(200, picked)
    end)

    it("keeps the original recipe when the resolver finds no learned rank", function()
      local info = { recipeID = 100, learned = false }
      assert.is_false(Logic.PickupProfessionsRecipe(info, function() return nil end))
      assert.is_nil(picked)
    end)
  end)
end)
