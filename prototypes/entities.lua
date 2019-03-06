local p = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
p.name = "location-combinator"
p.minable.result = "location-combinator"

data:extend{p}

local entity = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
entity.name = "bonus-combinator"
entity.minable.result = "bonus-combinator"
entity.item_slot_count = 30
data:extend{entity}

local entity = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
entity.name = "player-combinator"
entity.minable.result = "player-combinator"
entity.item_slot_count = 30
data:extend{entity}
