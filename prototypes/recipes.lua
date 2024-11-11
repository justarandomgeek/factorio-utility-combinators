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
