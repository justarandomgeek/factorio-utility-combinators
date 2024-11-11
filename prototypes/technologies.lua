local unlocks = {
  {type = "unlock-recipe", recipe = "bonus-combinator"},
  {type = "unlock-recipe", recipe = "location-combinator"},
  {type = "unlock-recipe", recipe = "research-combinator"},
}

for _,unlock in pairs(unlocks) do
  table.insert( data.raw["technology"]["advanced-combinators"].effects, unlock)
end
