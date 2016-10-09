local entity = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
entity.name = "player-combinator"
entity.minable.result = "player-combinator"
entity.item_slot_count = 30

data:extend{entity}
