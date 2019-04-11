for _,force in pairs(game.forces) do
  force.recipes["bonus-combinator"].enabled = force.technologies["circuit-network-2"].researched
  force.recipes["location-combinator"].enabled = force.technologies["circuit-network-2"].researched
  force.recipes["player-combinator"].enabled = force.technologies["circuit-network-2"].researched
  force.recipes["research-combinator"].enabled = force.technologies["circuit-network-2"].researched
end
