-- Common Technology with some of Optera's simple combinator mods
local unlocks = {
  {type = "unlock-recipe", recipe = "bonus-combinator"},
  {type = "unlock-recipe", recipe = "location-combinator"},
  {type = "unlock-recipe", recipe = "player-combinator"},
  {type = "unlock-recipe", recipe = "research-combinator"},
}

if data.raw["technology"]["circuit-network-2"] then
  for _,unlock in pairs(unlocks) do
    table.insert( data.raw["technology"]["circuit-network"].effects, unlock)
  end
else
  data:extend({
    {
      type = "technology",
      name = "circuit-network-2",
      icon = "__base__/graphics/technology/circuit-network.png",
      icon_size = 128,
      prerequisites = {"circuit-network", "advanced-electronics"},
      effects = unlocks,
      unit =
      {
        count = 150,
        ingredients = {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
        },
        time = 30
      },
      order = "a-d-d"
    }
  })
end
