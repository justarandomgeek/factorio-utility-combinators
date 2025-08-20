---@param name string
local function make_cc_entity(name)
  local entity = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
  entity.name = name
  entity.minable.result = name
  entity.created_effect = {
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
  data:extend{entity}
end

make_cc_entity("location-combinator")
make_cc_entity("bonus-combinator")
make_cc_entity("research-combinator")

data:extend{
  {
    type = "item",
    name = "location-combinator",
    icons = {
      { icon = "__base__/graphics/icons/constant-combinator.png", icon_size = 64, },
      { icon = "__base__/graphics/icons/signal/signal_X.png", icon_size = 64, scale = 0.25, shift = {-8,0} },
      { icon = "__base__/graphics/icons/signal/signal_Y.png", icon_size = 64, scale = 0.25, shift = {8,0} },
    },
    subgroup = "circuit-network",
    place_result="location-combinator",
    order = "b[combinators]-d[location-combinator]",
    stack_size = 50,
  }--[[@as data.ItemPrototype]],
  {
    type = "item",
    name = "bonus-combinator",
    icons = {
      { icon = "__base__/graphics/icons/constant-combinator.png", icon_size = 64, },
      { icon = "__base__/graphics/icons/signal/signal_B.png", icon_size = 64, scale = 0.3, },
    },
    subgroup = "circuit-network",
    place_result="bonus-combinator",
    order = "b[combinators]-d[bonus-combinator]",
    stack_size = 50,
  }--[[@as data.ItemPrototype]],
  {
    type = "item",
    name = "research-combinator",
    icons = {
      { icon = "__base__/graphics/icons/constant-combinator.png", icon_size = 64, },
      { icon = "__base__/graphics/icons/signal/signal_R.png", icon_size = 64, scale = 0.3, },
    },
    subgroup = "circuit-network",
    place_result="research-combinator",
    order = "b[combinators]-d[research-combinator]",
    stack_size = 50,
  }--[[@as data.ItemPrototype]],
  }

---@param name string
local function make_recipe(name)
  data:extend{
    {
      type = "recipe",
      name = name,
      enabled = false,
      ingredients = {
        {type="item", name="constant-combinator", amount=1},
        {type="item", name="electronic-circuit", amount=1},
      },
      results = {
        {type="item", name=name, amount=1}
      },
    }--[[@as data.RecipePrototype]]
  }
end

make_recipe("location-combinator")
make_recipe("bonus-combinator")
make_recipe("research-combinator")

local unlocks = {
  {type = "unlock-recipe", recipe = "bonus-combinator"},
  {type = "unlock-recipe", recipe = "location-combinator"},
  {type = "unlock-recipe", recipe = "research-combinator"},
}

for _,unlock in pairs(unlocks) do
  table.insert( data.raw["technology"]["advanced-combinators"].effects, unlock)
end

