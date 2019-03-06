data:extend{
  {
    type = "item",
    name = "location-combinator",
    icons = {
      { icon = "__base__/graphics/icons/constant-combinator.png", icon_size = 32, },
      { icon = "__base__/graphics/icons/signal/signal_X.png", icon_size = 32, scale = 0.5, shift = {-8,0} },
      { icon = "__base__/graphics/icons/signal/signal_Y.png", icon_size = 32, scale = 0.5, shift = {8,0} },
    },
    subgroup = "circuit-network",
    place_result="location-combinator",
    order = "b[combinators]-d[location-combinator]",
    stack_size = 50,
  },
  {
    type = "item",
    name = "bonus-combinator",
    icons = {
      { icon = "__base__/graphics/icons/constant-combinator.png", icon_size = 32, },
      { icon = "__base__/graphics/icons/signal/signal_B.png", icon_size = 32, scale = 0.6, },
    },
    subgroup = "circuit-network",
    place_result="bonus-combinator",
    order = "b[combinators]-d[bonus-combinator]",
    stack_size = 50,
  },
  {
    type = "item",
    name = "player-combinator",
    icons = {
      { icon = "__base__/graphics/icons/constant-combinator.png", icon_size = 32, },
      { icon = "__base__/graphics/icons/signal/signal_P.png", icon_size = 32, scale = 0.6, },
    },
    subgroup = "circuit-network",
    place_result="player-combinator",
    order = "b[combinators]-d[player-combinator]",
    stack_size = 50,
  },
  {
    type = "item",
    name = "research-combinator",
    icons = {
      { icon = "__base__/graphics/icons/constant-combinator.png", icon_size = 32, },
      { icon = "__base__/graphics/icons/signal/signal_R.png", icon_size = 32, scale = 0.6, },
    },
    subgroup = "circuit-network",
    place_result="research-combinator",
    order = "b[combinators]-d[research-combinator]",
    stack_size = 50,
  },
  }
