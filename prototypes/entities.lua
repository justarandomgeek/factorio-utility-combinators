local entity = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
entity.name = "research-combinator"
entity.minable.result = "research-combinator"
entity.item_slot_count = 30

data:extend{entity}
