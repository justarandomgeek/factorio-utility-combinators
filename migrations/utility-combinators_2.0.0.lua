for _,force in pairs(game.forces) do
  force.recipes["bonus-combinator"].enabled = force.technologies["advanced-combinators"].researched
  force.recipes["location-combinator"].enabled = force.technologies["advanced-combinators"].researched
  force.recipes["research-combinator"].enabled = force.technologies["advanced-combinators"].researched
end
