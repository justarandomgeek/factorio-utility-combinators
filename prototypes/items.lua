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
