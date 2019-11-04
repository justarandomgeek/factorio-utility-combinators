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

local entity = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
entity.name = "research-combinator"
entity.minable.result = "research-combinator"
entity.item_slot_count = 30

data:extend{entity}

local entity = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
entity.name = "large-combinator"
entity.minable.result = "large-combinator"
entity.item_slot_count = 1000
data:extend{entity}
