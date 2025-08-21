local meld = require('meld')

---@param name string
local function make_cc(name, icons)
  data:extend{
    meld.meld(table.deepcopy(data.raw["constant-combinator"]["constant-combinator"]), {
      name = name,
      minable = {
        result = name,
      },
      created_effect = meld.overwrite{
        type = "direct",
        action_delivery = {
          type = "instant",
          source_effects = {
            {
              type = "script",
              effect_id = "utility-combinator-created",
            },
          }
        }
      }
    }),
    {
      type = "recipe",
      name = name,
      ingredients = {
        {type="item", name="constant-combinator", amount=1},
        {type="item", name="electronic-circuit", amount=1},
      },
      results = {
        {type="item", name=name, amount=1}
      },
    }--[[@as data.RecipePrototype]],
    {
      type = "item",
      name = name,
      icons = icons,
      subgroup = "circuit-network",
      place_result=name,
      order = "b[combinators]-d["..name.."]",
      stack_size = 50,
    }--[[@as data.ItemPrototype]],
  }
end

make_cc("location-combinator", {
  { icon = "__base__/graphics/icons/constant-combinator.png", icon_size = 64, },
  { icon = "__base__/graphics/icons/signal/signal_X.png", icon_size = 64, scale = 0.25, shift = {-8,0} },
  { icon = "__base__/graphics/icons/signal/signal_Y.png", icon_size = 64, scale = 0.25, shift = {8,0} },
})
make_cc("bonus-combinator", {
  { icon = "__base__/graphics/icons/constant-combinator.png", icon_size = 64, },
  { icon = "__base__/graphics/icons/signal/signal_B.png", icon_size = 64, scale = 0.3, },
})
make_cc("research-combinator", {
  { icon = "__base__/graphics/icons/constant-combinator.png", icon_size = 64, },
  { icon = "__base__/graphics/icons/signal/signal_R.png", icon_size = 64, scale = 0.3, },
})

meld.meld(data.raw["technology"]["advanced-combinators"], {
  effects = meld.append({
  {type = "unlock-recipe", recipe = "bonus-combinator"},
  {type = "unlock-recipe", recipe = "location-combinator"},
  {type = "unlock-recipe", recipe = "research-combinator"},
  })
})
