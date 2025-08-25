for _,force in pairs(game.forces) do
  force.recipes["player-combinator"].enabled = force.technologies["advanced-combinators"].researched
end
