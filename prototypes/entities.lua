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
