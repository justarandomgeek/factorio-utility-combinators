local entity = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
entity.name = "bonus-combinator"
entity.minable.result = "bonus-combinator"
entity.item_slot_count = 30

data:extend{entity}
