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
end)
